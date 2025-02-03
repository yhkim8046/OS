# ReadMe: Page Access System Call for xv6-riscv

## Project Overview
This project extends the xv6-riscv operating system by implementing a custom system call named `pageAccess`. The system call tracks which pages in a process's virtual address space have been accessed. This feature is particularly useful for debugging or profiling applications.

## Features
1. **`pageAccess` System Call:**
   - Checks if specific pages in virtual memory have been accessed.
   - Returns a bitmap indicating access status for each page.
   - Clears the accessed bit (PTE_A) for examined pages, allowing repeated use.

2. **Test Program (`pgaccess_test`):**
   - Allocates pages in user space.
   - Accesses specific pages to simulate real-world use.
   - Verifies the correctness of the `pageAccess` system call.

## Implementation Details
### System Call Implementation
The `sys_pageAccess` function performs the following steps:
1. Retrieves the starting virtual address, number of pages, and user-space address for storing the bitmap.
2. Validates the number of pages and virtual addresses.
3. Iterates over the specified pages, examining their page table entries (PTEs):
   - Checks if the page is valid and present in memory.
   - Reads and records the accessed (PTE_A) bit in the bitmap.
   - Clears the PTE_A bit to reset the access state.
4. Copies the bitmap to the user-provided address.

### Test Program
The test program `pgaccess_test` performs the following:
1. Allocates 32 pages of memory.
2. Calls the `pageAccess` system call to retrieve the initial bitmap.
3. Accesses specific pages.
4. Calls `pageAccess` again to verify the bitmap reflects the accessed pages.
5. Checks the correctness of the bitmap against expected results.

### Key Files Modified
1. `kernel/sysproc.c`: Added `sys_pageAccess` implementation.
2. `user/user.h`: Declared the `pageAccess` system call.
3. `kernel/syscall.h`: Assigned a system call number for `pageAccess`.
4. `kernel/syscall.c`: Added `sys_pageAccess` to the system call table.

## Execution Instructions
### Prerequisites
1. Install QEMU for RISC-V.
2. Build the xv6 kernel with the added system call.

### Build the Kernel
1. Navigate to the xv6 source directory.
2. Run:
   ```bash
   make clean && make
   ```

### Boot xv6 in QEMU
Use the following command to boot xv6:
```bash
qemu-system-riscv64 -machine virt -bios none -kernel kernel/kernel -m 128M -smp 3 -nographic -drive file=fs.img,if=none,format=raw,id=x0 -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0
```

### Run the Test Program
1. Boot into the xv6 shell.
2. Run the test program:
   ```bash
   pgaccess_test
   ```

### Expected Output
The following output indicates successful execution:
```plaintext
Page access test starting
Initial page access bitmap: 1
Page access bitmap after access: 40000006
pageAccess is working correctly
```

## Contributions
- **System Call Design and Implementation:** Developed the `sys_pageAccess` system call.
- **Test Program Development:** Created `pgaccess_test` to validate functionality.
- **Integration:** Modified the syscall table and related files to integrate `pageAccess` into xv6.

## Troubleshooting
1. **QEMU Boot Errors:** Ensure you are using the correct QEMU version and command-line arguments.
2. **Build Errors:** Run `make clean` before rebuilding.
3. **Unexpected Test Output:** Double-check the modifications to the kernel files and ensure the PTE_A bit is being manipulated correctly.

## Future Work
1. Extend `pageAccess` to support larger ranges of pages.
2. Develop additional test programs to validate edge cases.
3. Explore use cases such as memory profiling and debugging.

---
Feel free to reach out with questions or feedback!

