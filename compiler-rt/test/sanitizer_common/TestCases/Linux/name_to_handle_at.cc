// RUN: %clangxx -O0 %s -o %t && %run %t
// UNSUPPORTED: android

#include <assert.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <errno.h>

int main(int argc, char **argv) {
  int mount_id;
  struct file_handle *handle = reinterpret_cast<struct file_handle *>(
      malloc(sizeof(*handle) + MAX_HANDLE_SZ));

  handle->handle_bytes = MAX_HANDLE_SZ;
  int res = name_to_handle_at(AT_FDCWD, argv[0], handle, &mount_id, 0);
  if (errno == EPERM) { // Function not permitted
    free(handle);
    return 0;
  }
  assert(!res);

  free(handle);
  return 0;
}
