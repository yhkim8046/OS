#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
  int n;
  if(argint(0, &n) < 0)
    return -1;
  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  if(argaddr(0, &p) < 0)
    return -1;
  return wait(p);
}

uint64
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}


// Implementation of the pageAccess system call
// This system call checks if specific virtual memory pages have been accessed recently.
// It returns a bitmap where each bit corresponds to the access status of a page.
// Additionally, it clears the accessed (PTE_A) bit for the examined pages.
int sys_pageAccess(void) {
    
    uint64 usrpage_ptr; // Starting virtual address provided by the user
    int npages;         // Number of pages to examine
    uint64 usraddr;     // Address to store the resulting bitmap in user space
    
    // Retrieve arguments from the system call
    argaddr(0, &usrpage_ptr);
    argint(1, &npages);
    argaddr(2, &usraddr);

    struct proc* p = myproc(); // Get the current process
    unsigned long bitmap = 0;  // Initialize the bitmap to track accessed pages

    // Validate the number of pages
    if (npages <= 0 || npages > 64)
        return -1; // Return error if npages is out of bounds
  
    // Traverse the page table for the specified range
    for (int i = 0; i < npages; i++) {
        uint64 va = usrpage_ptr + i * PGSIZE; // Calculate the virtual address for the ith page

        // Ensure the virtual address is valid
        if (va >= MAXVA)
            return -1; // Return error if address exceeds the maximum valid address

        // Get the page table entry (PTE) for the current virtual address
        pte_t *pte = walk(p->pagetable, va, 0);
        if (pte == 0)
            return -1; // Return error if PTE is not found

        // Check if the page is valid (present in memory)
        if ((*pte & PTE_V) == 0)
            continue; // Skip invalid pages

        // Check if the page has been accessed (PTE_A bit set)
        if (*pte & PTE_A) {
            bitmap |= (1UL << i); // Set the corresponding bit in the bitmap for the accessed page
        }

        // Clear the PTE_A bit to reset the access record for future checks
        *pte &= ~PTE_A;
    }

    // Copy the resulting bitmap to the user-space address
    if (copyout(p->pagetable, usraddr, (char*)&bitmap, sizeof(bitmap)) < 0)
        return -1; // Return error if the bitmap could not be copied

    return 0; // Success
}
