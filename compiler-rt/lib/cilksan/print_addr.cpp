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

// void print_race_report();

// A map keeping track of races found, keyed by the larger instruction address
// involved in the race.  Races that have same instructions that made the same
// types of accesses are considered as the the same race (even for races where
// one is read followed by write and the other is write followed by read, they
// are still considered as the same race).  Races that have the same instruction
// addresses but different address for memory location is considered as a
// duplicate.  The value of the map stores the number duplicates for the given
// race.
// class RaceMap_t : public std::unordered_multimap<uint64_t, RaceInfo_t> {
// public:
//   RaceMap_t() {}
//   ~RaceMap_t() {
//     print_race_report();
//   }

// };
// typedef std::unordered_multimap<uint64_t, RaceInfo_t> RaceMap_t;
// static RaceMap_t races_found;
// // The number of duplicated races found
// static uint32_t duplicated_races = 0;

// Mappings from CSI ID to associated program counter.
uintptr_t *call_pc = nullptr;
uintptr_t *spawn_pc = nullptr;
uintptr_t *loop_pc = nullptr;
uintptr_t *load_pc = nullptr;
uintptr_t *store_pc = nullptr;
uintptr_t *alloca_pc = nullptr;
uintptr_t *allocfn_pc = nullptr;
allocfn_prop_t *allocfn_prop = nullptr;
uintptr_t *free_pc = nullptr;

class ProcMapping_t {
public:
  unsigned long low,high;
  std::string path;
  ProcMapping_t(unsigned long low, unsigned long high, std::string path) :
    low(low), high(high), path(path) { }
};

static std::vector<ProcMapping_t> *proc_maps = NULL;

// declared in cilksan.cpp
extern uintptr_t stack_low_addr;
extern uintptr_t stack_high_addr;

void read_proc_maps(void) {
  if (proc_maps) return;

  proc_maps = new std::vector<ProcMapping_t>;
  pid_t pid = getpid();
  char path[100];
  snprintf(path, sizeof(path), "/proc/%d/maps", pid);
  DBG_TRACE(DEBUG_BACKTRACE, "path = %s\n", path);
  FILE *f = fopen(path, "r");
  DBG_TRACE(DEBUG_BACKTRACE, "file = %p\n", f);
  cilksan_assert(f);

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
      cilksan_assert(stack_low_addr == 0);
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
  convert << std::hex << inst_addr << std::dec
          << ": (" << file << ":" << std::dec << line_no << ")";
  // XXX: Let's not do this for now; maybe come back later
  //   // convert << "\t called at " << bag->get_call_context();

  return convert.str();
}

typedef enum {
  LOAD_ACC,
  STORE_ACC,
  FREE_ACC,
  REALLOC_ACC,
} ACC_TYPE;

// Helper function to get string describing a variable location from a
// obj_source_loc_t.
static std::string
get_obj_info_str(const obj_source_loc_t *obj_src_loc, const Decorator &d) {
  if (!obj_src_loc)
    return "<no information on variable>";

  std::ostringstream convert;
  // std::string type(obj_src_loc->type ?
  //                  obj_src_loc->type :
  //                  "<no variable type>");
  std::string variable(obj_src_loc->name ?
                       (std::string(d.Variable()) + obj_src_loc->name +
                        std::string(d.Default())) :
                       "<no variable name>");
  std::string filename(obj_src_loc->filename ?
                       (std::string(d.Filename()) + obj_src_loc->filename +
                        std::string(d.Default())) :
                       "<no filename>");
  int32_t line_no = obj_src_loc->line_number;

  // if (obj_src_loc->type)
  //   convert << type << " ";

  convert << variable
          << " (declared at " << filename;
  if (line_no >= 0)
    convert << d.Filename() << ":" << std::dec << line_no << d.Default();
  convert << ")";

  return convert.str();
}

// Helper function to get string describing source location from a
// csan_source_loc_t.
static std::string
get_src_info_str(const csan_source_loc_t *src_loc, const Decorator &d) {
  if (!src_loc)
    return "<no information on source location>";

  std::ostringstream convert;
  std::string file(src_loc->filename ?
                   (std::string(d.Filename()) + src_loc->filename +
                    std::string(d.Default())) :
                   "<no filename>");
  std::string funcname(src_loc->name ?
                       (std::string(d.Function()) + src_loc->name +
                        std::string(d.Default())) :
                       "<no function name>");
  int32_t line_no = src_loc->line_number;
  int32_t col_no = src_loc->column_number;

  convert << " " << funcname;
  convert << " " << file;
  if (line_no >= 0 && col_no >= 0) {
    convert << d.Filename();
    convert << ":" << std::dec << line_no;
    convert << ":" << std::dec << col_no;
    convert << d.Default();
  }
  return convert.str();
}

static std::string get_info_on_alloca(const csi_id_t alloca_id,
                                      const Decorator &d) {
  std::ostringstream convert;

  // Get source and object information.
  const csan_source_loc_t *src_loc = nullptr;
  const obj_source_loc_t *obj_src_loc = nullptr;
  // Even alloca_id's are stack allocations
  if (alloca_id % 2) {
    convert << d.RaceLoc() << " Heap object " << d.Default();
    src_loc = __csan_get_allocfn_source_loc(alloca_id / 2);
    obj_src_loc = __csan_get_allocfn_obj_source_loc(alloca_id / 2);
  } else {
    convert << d.RaceLoc() << "Stack object " << d.Default();
    src_loc = __csan_get_alloca_source_loc(alloca_id / 2);
    obj_src_loc = __csan_get_alloca_obj_source_loc(alloca_id / 2);
  }

  convert << get_obj_info_str(obj_src_loc, d) << std::endl;

  uintptr_t pc = (alloca_id % 2) ? allocfn_pc[alloca_id / 2] :
                     alloca_pc[alloca_id / 2];

  convert << d.RaceLoc();
  if (alloca_id % 2) {
    convert << "      Call "
            << d.InstAddress() << std::hex << pc << d.Default();
    if (allocfn_prop[alloca_id / 2].allocfn_ty != uint8_t(-1))
      convert << " to " << d.Function()
              << __csan_get_allocfn_str(allocfn_prop[alloca_id / 2])
              << d.Default();
  } else {
    convert << "     Alloc "
            << d.InstAddress() << std::hex << pc << d.Default();
  }

  if (alloca_id % 2) {
    convert << " in" << get_src_info_str(src_loc, d);
  }

  return convert.str();
}

static std::string
get_info_on_mem_access(const csi_id_t acc_id, ACC_TYPE type, uint8_t endpoint,
                       const Decorator &d) {
  std::ostringstream convert;

  convert << d.Bold() << d.RaceLoc();
  switch (type) {
  case LOAD_ACC:
    convert << "   Read ";
    break;
  case STORE_ACC:
    convert << "  Write ";
    break;
  case FREE_ACC:
    convert << "   Free ";
    break;
  case REALLOC_ACC:
    convert << "Realloc ";
    break;
  }
  convert << d.Default();

  // Get PC for this access.
  if (UNKNOWN_CSI_ID != acc_id) {
    convert << d.InstAddress();
    switch (type) {
    case LOAD_ACC:
      convert << std::hex << load_pc[acc_id];
      break;
    case STORE_ACC:
      convert << std::hex << store_pc[acc_id];
      break;
    case FREE_ACC:
      convert << std::hex << free_pc[acc_id];
      break;
    case REALLOC_ACC:
      convert << std::hex << allocfn_pc[acc_id];
      break;
    }
    convert << d.Default();
  }

  // Get source information.
  const csan_source_loc_t *src_loc = nullptr;
  if (UNKNOWN_CSI_ID != acc_id) {
    switch (type) {
    case LOAD_ACC:
      src_loc = __csan_get_load_source_loc(acc_id);
      break;
    case STORE_ACC:
      src_loc = __csan_get_store_source_loc(acc_id);
      break;
    case FREE_ACC:
      src_loc = __csan_get_free_source_loc(acc_id);
      break;
    case REALLOC_ACC:
      src_loc = __csan_get_allocfn_source_loc(acc_id);
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

  convert << get_src_info_str(src_loc, d);

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
    // TODO: Track objects modified by free's and realloc's.
    default:
      break;
    }
  }
  if (obj_src_loc) {
    convert << std::endl << (endpoint == 0 ? "| " : "||")
            << "       `-to variable ";

    convert << get_obj_info_str(obj_src_loc, d);
  }

  return convert.str();
}

static std::string get_info_on_call(const CallID_t &call, const Decorator &d) {
  std::ostringstream convert;
  convert << d.RaceLoc();
  switch (call.getType()) {
  case CALL:
    convert << "  Call ";
    break;
  case SPAWN:
    convert << " Spawn ";
    break;
  case LOOP:
    convert << "Parfor ";
    break;
  }
  convert << d.Default();

  if (call.isUnknownID()) {
    convert << "<no information on source location>";
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
  case LOOP:
    pc = loop_pc[call.getID()];
    break;
  }
  convert << d.InstAddress() << std::hex << pc << d.Default();

  const csan_source_loc_t *src_loc = nullptr;
  switch (call.getType()) {
  case CALL:
    src_loc = __csan_get_call_source_loc(call.getID());
    break;
  case SPAWN:
    src_loc = __csan_get_detach_source_loc(call.getID());
    break;
  case LOOP:
    src_loc = __csan_get_loop_source_loc(call.getID());
    break;
  }

  convert << get_src_info_str(src_loc, d);

  return convert.str();
}

int get_call_stack_divergence_pt(
    const std::unique_ptr<std::pair<CallID_t, uintptr_t>[]> &first_call_stack,
    int first_call_stack_size,
    const std::unique_ptr<std::pair<CallID_t, uintptr_t>[]> &second_call_stack,
    int second_call_stack_size) {
  int i;
  int end =
    (first_call_stack_size < second_call_stack_size) ?
    first_call_stack_size : second_call_stack_size;
  for (i = 0; i < end; ++i)
    // if (first_call_stack[i].first != second_call_stack[i].first)
    if (first_call_stack[i].second != second_call_stack[i].second)
      // TODO: For Loop entries in the call stack, use versioning to distinguish
      // different iterations of the loop.
      break;
  return i;
}

// extern void print_current_function_info();

static std::unique_ptr<std::pair<CallID_t, uintptr_t>[]>
get_call_stack(const AccessLoc_t &instrAddr) {
  int stack_size = instrAddr.getCallStackSize();
  std::unique_ptr<std::pair<CallID_t, uintptr_t>[]>
      call_stack(new std::pair<CallID_t, uintptr_t>[stack_size]);
  {
    const call_stack_node_t *call_stack_node = instrAddr.getCallStack();
    for (int i = stack_size - 1;
         i >= 0;
         --i, call_stack_node = call_stack_node->getPrev()) {
      call_stack[i].first = call_stack_node->getCallID();
      call_stack[i].second = reinterpret_cast<uintptr_t>(call_stack_node);
    }
  }
  return call_stack;
}

bool CilkSanImpl_t::ColorizeReports() {
  char *e = getenv("CILKSAN_COLOR_REPORT");
  if (e && 0 == strcmp(e, "0"))
    return false;
  return isatty(STDERR_FILENO) != 0;
}

// static void print_race_info(const RaceInfo_t& race) {
void RaceInfo_t::print(const AccessLoc_t &first_inst,
                       const AccessLoc_t &second_inst,
                       const AccessLoc_t &alloc_inst,
                       const Decorator &d) const {
  std::cerr << d.Bold() << d.Error() << "Race detected at address "
    // << (is_on_stack(race.addr) ? "stack address " : "address ")
            << std::hex << addr << d.Default() << std::dec << std::endl;

  // std::string first_acc_info = get_info_on_mem_access(race.first_inst);
  // std::string second_acc_info = get_info_on_mem_access(race.second_inst);

  std::string first_acc_info, second_acc_info;
  ACC_TYPE first_acc_type, second_acc_type;
  switch(type) {
  case RW_RACE:
    first_acc_type = LOAD_ACC;
    switch (second_inst.getType()) {
    case MAType_t::FREE:
      second_acc_type = FREE_ACC;
      break;
    case MAType_t::REALLOC:
      second_acc_type = REALLOC_ACC;
      break;
    default:
      second_acc_type = STORE_ACC;
      break;
    }
    break;
  case WW_RACE:
    switch (first_inst.getType()) {
    case MAType_t::FREE:
      first_acc_type = FREE_ACC;
      break;
    case MAType_t::REALLOC:
      first_acc_type = REALLOC_ACC;
      break;
    default:
      first_acc_type = STORE_ACC;
      break;
    }
    switch (second_inst.getType()) {
    case MAType_t::FREE:
      second_acc_type = FREE_ACC;
      break;
    case MAType_t::REALLOC:
      second_acc_type = REALLOC_ACC;
      break;
    default:
      second_acc_type = STORE_ACC;
      break;
    }
    break;
  case WR_RACE:
    switch (first_inst.getType()) {
    case MAType_t::FREE:
      first_acc_type = FREE_ACC;
      break;
    case MAType_t::REALLOC:
      first_acc_type = REALLOC_ACC;
      break;
    default:
      first_acc_type = STORE_ACC;
      break;
    }
    second_acc_type = LOAD_ACC;
    break;
  }
  first_acc_info =
      get_info_on_mem_access(first_inst.getID(), first_acc_type, 0, d);
  second_acc_info =
      get_info_on_mem_access(second_inst.getID(), second_acc_type, 1, d);

  // Extract the two call stacks
  int first_call_stack_size = first_inst.getCallStackSize();
  int second_call_stack_size = second_inst.getCallStackSize();
  auto first_call_stack = get_call_stack(first_inst);
  auto second_call_stack = get_call_stack(second_inst);

  // Determine where the two call stacks diverge
  int divergence = get_call_stack_divergence_pt(
      first_call_stack,
      first_call_stack_size,
      second_call_stack,
      second_call_stack_size);

  // Print the two accesses involved in the race
  std::cerr << "*  " << first_acc_info << std::endl;
  for (int i = first_call_stack_size - 1;
       i >= divergence; --i)
    std::cerr << "+   " << get_info_on_call(first_call_stack[i].first, d)
              << std::endl;
  std::cerr << "|* " << second_acc_info << std::endl;
  for (int i = second_call_stack_size - 1;
       i >= divergence; --i)
    std::cerr << "|+  " << get_info_on_call(second_call_stack[i].first, d)
              << std::endl;

  // Print the common calling context
  if (divergence > 0) {
    std::cerr << "\\| Common calling context" << std::endl;
    for (int i = divergence - 1; i >= 0; --i)
      std::cerr << " +  " << get_info_on_call(first_call_stack[i].first, d)
                << std::endl;
  }

  // Print the allocation
  if (alloc_inst.isValid()) {
    std::cerr << "   Allocation context" << std::endl;
    const csi_id_t alloca_id = alloc_inst.getID();
    std::cerr << "    " << get_info_on_alloca(alloca_id, d) << std::endl;

    auto alloc_call_stack = get_call_stack(alloc_inst);
    for (int i = alloc_inst.getCallStackSize() - 1; i >= 0; --i)
      std::cerr << "    " << get_info_on_call(alloc_call_stack[i].first, d)
                << std::endl;
  }

  std::cerr << std::endl;

  // print_current_function_info();
}

// Log the race detected
void CilkSanImpl_t::report_race(
    const AccessLoc_t &first_inst, const AccessLoc_t &second_inst,
    const AccessLoc_t &alloc_inst, uint64_t addr,
    enum RaceType_t race_type) {
  bool found = false;
  // TODO: Make the key computation consistent with is_equivalent_race().
  uint64_t key = first_inst < second_inst ?
                              first_inst.getID() : second_inst.getID();
  RaceInfo_t race(first_inst, second_inst, alloc_inst, addr, race_type);

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
    duplicated_races++;
  } else {
    // have to get the info before user program exits
    race.print(first_inst, second_inst, alloc_inst, Decorator(color_report));
    races_found.insert(std::make_pair(key, race));
  }
}

void CilkSanImpl_t::report_race(
    const AccessLoc_t &first_inst, const AccessLoc_t &second_inst,
    uint64_t addr, enum RaceType_t race_type) {
  report_race(first_inst, second_inst, AccessLoc_t(), addr, race_type);
}

// Report viewread race
void report_viewread_race(uint64_t first_inst, uint64_t second_inst,
                          uint64_t addr) {
  // For now, just print the viewread race
  std::cerr << "Race detected at address "
            << std::hex << addr << std::dec << std::endl;
  std::string first_acc_info = get_info_on_mem_access(first_inst);
  std::string second_acc_info = get_info_on_mem_access(second_inst);
  std::cerr << "  read access at " << first_acc_info << std::endl;
  std::cerr << "  write access at " << second_acc_info << std::endl;
  std::cerr << std::endl;
}

int CilkSanImpl_t::get_num_races_found() {
  return races_found.size();
}

void CilkSanImpl_t::print_race_report() {
  std::cerr << std::endl;
  std::cerr << "Race detector detected total of " << get_num_races_found()
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
		"%p is offset %lx in %s\n", a, off, path);
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

