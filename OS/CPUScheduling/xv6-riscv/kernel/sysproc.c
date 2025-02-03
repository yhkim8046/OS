#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

extern struct proc proc[NPROC];


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


uint64
sys_wait2(void)
{
  uint64 addr, addr1, addr2, addr3;
  int wtime, rtime, stime; // Change to int
  if (argaddr(0, &addr) < 0)
    return -1;
  if (argaddr(1, &addr1) < 0) // user virtual memory
    return -1;
  if (argaddr(2, &addr2) < 0)
    return -1;
  if (argaddr(3, &addr3) < 0)
    return -1;

  int ret = wait2(&rtime, &wtime, &stime, 0); // Pass addresses

  struct proc *p = myproc();
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    return -1;
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    return -1;
  if (copyout(p->pagetable, addr3, (char *)&stime, sizeof(int)) < 0)
    return -1;

  return ret;
}


/**
 * sys_setnice
 * -----------
 * Sets the "nice" value of a process, which is used to adjust its scheduling priority.
 *
 * Parameters:
 * - pid (int): The process ID of the target process.
 * - n (int): The new "nice" value to assign to the process (range: 0-20).
 *
 * Returns:
 * - int: The original "nice" value of the process before the change.
 * - -1: If the process is not found or the input values are invalid.
 *
 * Behavior:
 * - Validates the input `pid` and `nice` value.
 * - Locks the process to ensure thread safety while updating the "nice" value.
 * - Searches the process table to find the process with the given `pid`.
 * - If found, updates its "nice" value and returns the original "nice" value.
 */
uint64
sys_setnice(void)
{
  //init variables
  int pid, n, original_nice;
  struct proc *p;
  
  //validating process
  if(argint(0, &pid) < 0 || argint(1, &n) < 0)
    return -1;
  
  //validating nice value in the proper range
  if(n < 0 || n > 20)
    return -1;

  // loop process table
  for(p = proc; p < &proc[NPROC]; p++)
  {
    //lock
    acquire(&p->lock);
    
    //set value
    if(p->pid == pid)
    {
      original_nice = p->nice;
      p->nice = n;
      release(&p->lock);
      
      //return original nice value
      return original_nice;
    }
    
    //unlock
    release(&p->lock);
  }
  return -1; //process not found
}


/**
 * sys_getnice
 * -----------
 * Retrieves the "nice" value of a specified process.
 *
 * Parameters:
 * - pid (int): The process ID of the target process.
 *
 * Returns:
 * - int: The "nice" value of the process.
 * - -1: If the process is not found or the input `pid` is invalid.
 *
 * Behavior:
 * - Validates the input `pid`.
 * - Locks the process to ensure thread safety while reading the "nice" value.
 * - Searches the process table to find the process with the given `pid`.
 * - If found, retrieves and returns its "nice" value.
 */
uint64
sys_getnice(void)
{
  //init variables
  int pid;
  struct proc *p;
  
  //validating process
  if(argint(0, &pid) < 0)
    return -1;

  //loop process table
  for(p = proc; p < &proc[NPROC]; p++){
    
    //lock
    acquire(&p->lock);
    
    //find target and set value
    if(p->pid == pid){
      int nice_value = p->nice;
      
      //unlock
      release(&p->lock);
      
      //get value
      return nice_value;
    }
    
    //unlock
    release(&p->lock);
  }
  return -1; // process not found
}
