#include <cstring>
#include <iostream>
#include <string>
#include <sstream>
#include <vector>
#include <unordered_map>
#include <memory>

#include <execinfo.h>
#include <malloc.h>
#include <inttypes.h>
#include <unistd.h>

#include "csan.h"
#include "cilksan_internal.h"
#include "debug_util.h"

// A map keeping track of races found, keyed by the larger instruction address
// involved in the race.  Races that have same instructions that made the same
// types of accesses are considered as the the same race (even for races where
// one is read followed by write and the other is write followed by read, they
// are still considered as the same race).  Races that have the same instruction
// addresses but different address for memory location is considered as a
// duplicate.  The value of the map stores the number duplicates for the given
// race.
typedef std::unordered_multimap<uint64_t, RaceInfo_t> RaceMap_t;
static RaceMap_t races_found;
// The number of duplicated races found
static uint32_t duplicated_races = 0;

// Mappings from CSI ID to associated program counter.
uintptr_t *call_pc = nullptr;
uintptr_t *spawn_pc = nullptr;
uintptr_t *load_pc = nullptr;
uintptr_t *store_pc = nullptr;

class ProcMapping_t {
public:
  unsigned long low,high;
  std::string path;
  ProcMapping_t(unsigned long low, unsigned long high, std::string path) :
    low(low), high(high), path(path) { }
};

static std::vector<ProcMapping_t> *proc_maps = NULL;

// declared in cilksan.cpp
extern uint64_t stack_low_addr;
extern uint64_t stack_high_addr;

void read_proc_maps(void) {
  if (proc_maps) return;

  proc_maps = new std::vector<ProcMapping_t>;
  pid_t pid = getpid();
  char path[100];
  snprintf(path, sizeof(path), "/proc/%d/maps", pid);
  DBG_TRACE(DEBUG_BACKTRACE, "path = %s\n", path);
  FILE *f = fopen(path, "r");
  DBG_TRACE(DEBUG_BACKTRACE, "file = %p\n", f);
  assert(f);

  char *lineptr = NULL;
  size_t n;
  while (1) {
    ssize_t s = getline(&lineptr, &n, f);
    if (s==-1) break;
    DBG_TRACE(DEBUG_BACKTRACE, "Got %ld line = %s size = %ld\n",
	      s, lineptr, n);
    unsigned long start, end;
    char c0, c1, c2, c3;
    int off, major, minor, inode;
    char *pathname;
    sscanf(lineptr, "%lx-%lx %c%c%c%c %x %x:%x %x %ms",
	   &start, &end, &c0, &c1, &c2, &c3, &off, &major, &minor,
	   &inode, &pathname);
    DBG_TRACE(DEBUG_BACKTRACE, " start = %lx end = %lx path = %s\n",
	      start, end, pathname);
    std::string paths(pathname ? pathname : "");
    ProcMapping_t m(start, end, paths);
    //if (paths.compare("[stack]") == 0) {
    if (paths.find("[stack") != std::string::npos) {
      assert(stack_low_addr == 0);
      stack_low_addr = start;
      stack_high_addr = end;
      DBG_TRACE(DEBUG_BACKTRACE, " stack = %lx--%lx\n", start, end);
    }
    free(pathname);
    proc_maps->push_back(m);
  }
  DBG_TRACE(DEBUG_BACKTRACE, "proc_maps size = %lu\n", proc_maps->size());
  fclose(f);
  if (lineptr) free(lineptr);
}

void delete_proc_maps() {
  if (proc_maps) {
    delete proc_maps;
    proc_maps = NULL;
  }
}

static void get_info_on_inst_addr(uint64_t addr, int *line_no, std::string *file) {

  for (unsigned int i=0; i < proc_maps->size(); i++) {
    if ((*proc_maps)[i].low <= addr && addr < (*proc_maps)[i].high) {
      unsigned long off = addr - (*proc_maps)[i].low;
      const char *path = (*proc_maps)[i].path.c_str();
      bool is_so = strcmp(".so", path+strlen(path)-3) == 0;
      char *command;
      if (is_so) {
        asprintf(&command, "echo %lx | addr2line -e %s", off, path);
      } else {
        asprintf(&command, "echo %lx | addr2line -e %s", addr, path);
      }
      FILE *afile = popen(command, "r");
      if (afile) {
        size_t linelen = -1;
        char *line = NULL;
        if (getline(&line, &linelen, afile)>=0) {
          const char *path = strtok(line, ":");
          const char *lno = strtok(NULL, ":");
          *file = std::string(path);
          *line_no = atoi(lno);
        }
        if (line) free(line);
        pclose(afile);
      }
      free(command);
      return;
    }
  }
  fprintf(stderr, "%lu is not in range\n", addr);
}

static std::string
get_info_on_mem_access(uint64_t inst_addr
                       /*, DisjointSet_t<SPBagInterface *> *d*/) {
  std::string file;
  int32_t line_no;
  std::ostringstream convert;
  // SPBagInterface *bag = d->get_node();
  // racedetector_assert(bag);

  get_info_on_inst_addr(inst_addr, &line_no, &file);
  convert << std::hex << "0x" << inst_addr << std::dec
          << ": (" << file << ":" << std::dec << line_no << ")";
  // XXX: Let's not do this for now; maybe come back later
  //   // convert << "\t called at " << bag->get_call_context();

  return convert.str();
}

typedef enum {
  LOAD_ACC,
  STORE_ACC,
} ACC_TYPE;

static std::string
get_info_on_mem_access(const csi_id_t acc_id, ACC_TYPE type) {
  std::ostringstream convert;
  // assert(UNKNOWN_CSI_ID != acc_id);

  switch (type) {
  case LOAD_ACC:
    convert << "  Read access to  ";
    break;
  case STORE_ACC:
    convert << "  Write access to ";
    break;
  }

  // Get object information
  const obj_source_loc_t *obj_src_loc = nullptr;
  if (UNKNOWN_CSI_ID != acc_id) {
    switch (type) {
    case LOAD_ACC:
      obj_src_loc = __csan_get_load_obj_source_loc(acc_id);
      break;
    case STORE_ACC:
      obj_src_loc = __csan_get_store_obj_source_loc(acc_id);
      break;
    }
  }
  if (obj_src_loc &&
      obj_src_loc->filename &&
      obj_src_loc->name) {
    std::string variable(obj_src_loc->name);
    std::string filename(obj_src_loc->filename);
    int32_t line_no = obj_src_loc->line_number;

    convert << variable
            << " (declared at " << filename
            << ":" << std::dec << line_no << ")";
  } else {
    convert << "<could not determine variable>";
  }

  convert << std::endl << "             from ";

  // Get PC for this access.
  if (UNKNOWN_CSI_ID != acc_id) {
    switch (type) {
    case LOAD_ACC:
      convert << "0x" << std::hex << load_pc[acc_id];
      break;
    case STORE_ACC:
      convert << "0x" << std::hex << store_pc[acc_id];
      break;
    }
  }

  // Get source information.
  const csan_source_loc_t *src_loc = nullptr;
  if (UNKNOWN_CSI_ID != acc_id) {
    switch (type) {
    case LOAD_ACC:
      src_loc = __csan_get_load_source_loc(acc_id);
      // std::cerr << "Load src loc for " << acc_id;
      break;
    case STORE_ACC:
      src_loc = __csan_get_store_source_loc(acc_id);
      // std::cerr << "Store src loc for " << acc_id;
      break;
    }
  }
  // if (!src_loc)
  //   std::cerr << " is null\n";
  // else if (!src_loc->filename)
  //   std::cerr << " has null filename\n";
  // else if (!src_loc->name)
  //   std::cerr << " has null function name\n";
  // else
  //   std::cerr << " is valid\n";

  if (src_loc &&
      src_loc->filename &&
      src_loc->name) {
    std::string file(src_loc->filename);
    std::string funcname(src_loc->name);
    int32_t line_no = src_loc->line_number;
    int32_t col_no = src_loc->column_number;

    // switch (type) {
    // case LOAD_ACC:
    //   convert << "LOAD_ID " << std::dec << acc_id;
    //   break;
    // case STORE_ACC:
    //   convert << "STORE_ID " << std::dec << acc_id;
    //   break;
    // }
    convert << " " << funcname;
    convert << " " << file
            << ":" << std::dec << line_no
            << ":" << std::dec << col_no;
  } else
    convert << " <could not determine source location>";

  return convert.str();
}

static std::string
get_info_on_call(const CallID_t &call) {
  std::ostringstream convert;
  switch (call.getType()) {
  case CALL:
    convert << " Called from ";
    break;
  case SPAWN:
    convert << "Spawned from ";
    break;
  }

  if (UNKNOWN_CSI_ID == call.getID()) {
    convert << "<could not determine source location>";
    return convert.str();
  }

  uintptr_t pc = (uintptr_t)nullptr;
  switch (call.getType()) {
  case CALL:
    pc = call_pc[call.getID()];
    break;
  case SPAWN:
    pc = spawn_pc[call.getID()];
    break;
  }
  convert << "0x" << std::hex << pc;

  const csan_source_loc_t *src_loc = nullptr;
  switch (call.getType()) {
  case CALL:
    src_loc = __csan_get_call_source_loc(call.getID());
    break;
  case SPAWN:
    src_loc = __csan_get_detach_source_loc(call.getID());
    break;
  }
  if (src_loc &&
      src_loc->filename &&
      src_loc->name) {
    std::string file(src_loc->filename);
    std::string funcname(src_loc->name);
    int32_t line_no = src_loc->line_number;
    int32_t col_no = src_loc->column_number;
    convert << " " << funcname;
    convert << " " << file
            << ":" << std::dec << line_no
            << ":" << std::dec << col_no;
  } else {
    convert << " <could not determine source location>";
  }

  return convert.str();
}

int get_call_stack_divergence_pt(
    const std::unique_ptr<CallID_t[]> &first_call_stack,
    int first_call_stack_size,
    const std::unique_ptr<CallID_t[]> &second_call_stack,
    int second_call_stack_size) {
  int i;
  int end =
    (first_call_stack_size < second_call_stack_size) ?
    first_call_stack_size : second_call_stack_size;
  for (i = 0; i < end; ++i)
    if (first_call_stack[i] != second_call_stack[i])
      break;
  return i;
}

extern void print_current_function_info();

static void print_race_info(const RaceInfo_t& race) {
  std::cerr << "Race detected at address "
    // << (is_on_stack(race.addr) ? "stack address " : "address ")
            << std::hex << "0x" << race.addr << std::dec << std::endl;

  // std::string first_acc_info = get_info_on_mem_access(race.first_inst);
  // std::string second_acc_info = get_info_on_mem_access(race.second_inst);

  std::string first_acc_info, second_acc_info;
  switch(race.type) {
  case RW_RACE:
    first_acc_info =
      get_info_on_mem_access(race.first_inst.getID(), LOAD_ACC);
    second_acc_info =
      get_info_on_mem_access(race.second_inst.getID(), STORE_ACC);
    break;
  case WW_RACE:
    first_acc_info =
      get_info_on_mem_access(race.first_inst.getID(), STORE_ACC);
    second_acc_info =
      get_info_on_mem_access(race.second_inst.getID(), STORE_ACC);
    break;
  case WR_RACE:
    first_acc_info =
      get_info_on_mem_access(race.first_inst.getID(), STORE_ACC);
    second_acc_info =
      get_info_on_mem_access(race.second_inst.getID(), LOAD_ACC);
    break;
  }

  // Extract the two call stacks
  int first_call_stack_size = race.first_inst.call_stack.size();
  std::unique_ptr<CallID_t[]> first_call_stack(
      new CallID_t[first_call_stack_size]);
  {
    call_stack_node_t *call_stack_node = race.first_inst.call_stack.tail;
    for (int i = first_call_stack_size - 1;
         i >= 0;
         --i, call_stack_node = call_stack_node->prev) {
      first_call_stack[i] = call_stack_node->id;
    }
  }
  int second_call_stack_size = race.second_inst.call_stack.size();
  std::unique_ptr<CallID_t[]> second_call_stack(
      new CallID_t[second_call_stack_size]);
  {
    call_stack_node_t *call_stack_node = race.second_inst.call_stack.tail;
    for (int i = second_call_stack_size - 1;
         i >= 0;
         --i, call_stack_node = call_stack_node->prev) {
      second_call_stack[i] = call_stack_node->id;
    }
  }

  // Determine where the two call stacks diverge
  int divergence = get_call_stack_divergence_pt(
      first_call_stack,
      first_call_stack_size,
      second_call_stack,
      second_call_stack_size);

  // Print the two accesses involved in the race
  switch(race.type) {
  case RW_RACE:
    std::cerr << first_acc_info << std::endl;
    for (int i = first_call_stack_size - 1;
         i >= divergence; --i)
      std::cerr << "     " << get_info_on_call(first_call_stack[i])
                << std::endl;
    std::cerr << second_acc_info << std::endl;
    for (int i = second_call_stack_size - 1;
         i >= divergence; --i)
      std::cerr << "     " << get_info_on_call(second_call_stack[i])
                << std::endl;
    break;

  case WW_RACE:
    std::cerr << first_acc_info << std::endl;
    for (int i = first_call_stack_size - 1;
         i >= divergence; --i)
      std::cerr << "     " << get_info_on_call(first_call_stack[i])
                << std::endl;
    std::cerr << second_acc_info << std::endl;
    for (int i = second_call_stack_size - 1;
         i >= divergence; --i)
      std::cerr << "     " << get_info_on_call(second_call_stack[i])
                << std::endl;
    break;

  case WR_RACE:
    std::cerr << first_acc_info << std::endl;
    for (int i = first_call_stack_size - 1;
         i >= divergence; --i)
      std::cerr << "     " << get_info_on_call(first_call_stack[i])
                << std::endl;
    std::cerr << second_acc_info << std::endl;
    for (int i = second_call_stack_size - 1;
         i >= divergence; --i)
      std::cerr << "     " << get_info_on_call(second_call_stack[i])
                << std::endl;
    break;
  }

  if (divergence > 0) {
    std::cerr << "  Common calling context" << std::endl;
    for (int i = divergence - 1; i >= 0; --i)
      std::cerr << "     " << get_info_on_call(first_call_stack[i])
                << std::endl;
  }

  std::cerr << std::endl;

  // print_current_function_info();
}

// Log the race detected
void report_race(const AccessLoc_t &first_inst, AccessLoc_t &&second_inst,
                 uint64_t addr, enum RaceType_t race_type) {
  bool found = false;
  uint64_t key =
    first_inst < second_inst ?
                 first_inst.getID() : second_inst.getID();
  RaceInfo_t race(first_inst, std::move(second_inst), addr, race_type);

  std::pair<RaceMap_t::iterator, RaceMap_t::iterator> range;
  range = races_found.equal_range(key);
  while (range.first != range.second) {
    const RaceInfo_t& in_map = range.first->second;
    if (race.is_equivalent_race(in_map)) {
      found = true;
      break;
    }
    range.first++;
  }
  if (found) { // increment the dup count
    // std::cerr << "REDUNDANT ";
    // print_race_info(race);
    duplicated_races++;
  } else {
    // have to get the info before user program exits
    print_race_info(race);
    races_found.insert(std::make_pair(key, race));
  }
}

// Report viewread race
void report_viewread_race(uint64_t first_inst, uint64_t second_inst,
                          uint64_t addr) {
  // For now, just print the viewread race
  std::cerr << "Race detected at address "
    // << (is_on_stack(race.addr) ? "stack address " : "address ")
            << std::hex << "0x" << addr << std::dec << std::endl;
  std::string first_acc_info = get_info_on_mem_access(first_inst);
  std::string second_acc_info = get_info_on_mem_access(second_inst);
  std::cerr << "  read access at " << first_acc_info << std::endl;
  std::cerr << "  write access at " << second_acc_info << std::endl;
  std::cerr << std::endl;
}

int get_num_races_found() {
  return races_found.size();
}

void print_race_report() {
  std::cerr << std::endl;
  std::cerr << "Race detector detected total of " << races_found.size()
            << " races." << std::endl;
  std::cerr << "Race detector suppressed " << duplicated_races
            << " duplicate error messages " << std::endl;
  std::cerr << std::endl;

}

void print_addr(FILE *f, void *a) {
  read_proc_maps();
  unsigned long ai = (long)a;
  DBG_TRACE(DEBUG_BACKTRACE, "print addr = %p.\n", a);

  for (unsigned int i=0; i < proc_maps->size(); i++) {
    DBG_TRACE(DEBUG_BACKTRACE, "Comparing %lu to %lu:%lu.\n",
	      ai, (*proc_maps)[i].low, (*proc_maps)[i].high);
    if ((*proc_maps)[i].low <= ai && ai < (*proc_maps)[i].high) {
      unsigned long off = ai-(*proc_maps)[i].low;
      const char *path = (*proc_maps)[i].path.c_str();
      DBG_TRACE(DEBUG_BACKTRACE,
		"%p is offset 0x%lx in %s\n", a, off, path);
      bool is_so = strcmp(".so", path+strlen(path)-3) == 0;
      char *command;
      if (is_so) {
	asprintf(&command, "echo %lx | addr2line -e %s", off, path);
      } else {
	asprintf(&command, "echo %lx | addr2line -e %s", ai, path);
      }
      DBG_TRACE(DEBUG_BACKTRACE, "Doing system(\"%s\");\n", command);
      FILE *afile = popen(command, "r");
      if (afile) {
	size_t linelen = -1;
	char *line = NULL;
	while (getline(&line, &linelen, afile)>=0) {
	  fputs(line, f);
	}
	if (line) free(line);
	pclose(afile);
      }
      free(command);
      return;
    }
  }
  fprintf(stderr, "%p is not in range\n", a);
}

