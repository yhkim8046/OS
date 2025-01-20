#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define PGSIZE 4096

int main() {
    char *buf;
    unsigned int abits;
    printf("Page access test starting\n");

    buf = malloc(32 * PGSIZE);   // allocate 32 pages of physical memory
    if (pageAccess(buf, 32, &abits) < 0) {   // Call the system call
        printf("pageAccess failed\n");
        free(buf);
        exit(1);
    }

    // Initially, abits should be zero since no page has been accessed
    printf("Initial page access bitmap: %x\n", abits);

    // Access some pages
    buf[PGSIZE * 1] += 1;  // Access page 1
    buf[PGSIZE * 2] += 1;  // Access page 2
    buf[PGSIZE * 30] += 1; // Access page 30

    // Call pageAccess again to check the accessed pages
    if (pageAccess(buf, 32, &abits) < 0) {
        printf("pageAccess failed\n");
        free(buf);
        exit(1);
    }

    printf("Page access bitmap after access: %x\n", abits);

    // Check if the bitmap corresponds to pages 1, 2, and 30 being accessed
    if (abits != ((1 << 1) | (1 << 2) | (1 << 30))) {
        printf("Incorrect access bits set\n");
    } else {
        printf("pageAccess is working correctly\n");
    }

    free(buf);
    exit(0);
}
