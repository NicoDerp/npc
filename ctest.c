#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stddef.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <sys/wait.h>

int main() {
  /* printf("macro sizeof(fstat) %ld end\n", sizeof(struct stat)); */
  /* printf("macro st_dev %ld + end \n", offsetof(struct stat, st_dev));      /\* ID of device containing file *\/ */
  /* printf("macro st_ino %ld + end \n", offsetof(struct stat, st_ino));      /\* inode number *\/ */
  /* printf("macro st_mode %ld + end \n", offsetof(struct stat, st_mode));     /\* protection *\/ */
  /* printf("macro st_nlink %ld + end \n", offsetof(struct stat, st_nlink));    /\* number of hard links *\/ */
  /* printf("macro st_uid %ld + end \n", offsetof(struct stat, st_uid));      /\* user ID of owner *\/ */
  /* printf("macro st_gid %ld + end \n", offsetof(struct stat, st_gid));      /\* group ID of owner *\/ */
  /* printf("macro st_rdev %ld + end \n", offsetof(struct stat, st_rdev));     /\* device ID (if special file) *\/ */
  /* printf("macro st_size %ld + end \n", offsetof(struct stat, st_size));     /\* total size, in bytes *\/ */
  /* printf("macro st_blksize %ld + end \n", offsetof(struct stat, st_blksize));  /\* blocksize for file system I/O *\/ */
  /* printf("macro st_blocks %ld + end \n", offsetof(struct stat, st_blocks));   /\* number of 512B blocks allocated *\/ */
  /* printf("macro st_atime %ld + end \n", offsetof(struct stat, st_atime));    /\* time of last access *\/ */
  /* printf("macro st_mtime %ld + end \n", offsetof(struct stat, st_mtime));    /\* time of last modification *\/ */
  /* printf("macro st_ctime %ld + end \n", offsetof(struct stat, st_ctime));    /\* time of last status change *\/ */

  /* printf("macro MAP_PRIVATE %d end\n", MAP_PRIVATE); */
  /* printf("macro PROT_READ %d end\n", PROT_READ); */
  /* printf("macro MAP_FAILED %p end\n", MAP_FAILED); */
  /* printf("a: %d\n", MAP_FAILED == -1); */

  /* printf("macro O_RDONLY %d end\n", O_RDONLY); */
  /* printf("macro O_WRONLY %d end\n", O_WRONLY); */
  /* printf("macro O_CREAT %d end\n", O_CREAT); */
  /* printf("macro O_TRUNC %d end\n", O_TRUNC); */
  /* printf("macro O_RDWR %d end\n", O_RDWR); */

  printf("Oooga booga: %d\n", WIFEXITED(0));
  
  return 0;
}
