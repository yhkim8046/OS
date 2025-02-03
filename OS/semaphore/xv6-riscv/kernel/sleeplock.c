// Sleeping locks

#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
  initlock(&lk->lk, "sleep lock");
  lk->name = name;
  lk->locked = 0;
  lk->pid = 0;
}

/*void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
  lk->pid = myproc()->pid;
  release(&lk->lk);
}

void
releasesleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  lk->locked = 0;
  lk->pid = 0;
  wakeup(lk);
  release(&lk->lk);
}*/

int
holdingsleep(struct sleeplock *lk)
{
  int r;
  
  acquire(&lk->lk);
  r = lk->locked && (lk->pid == myproc()->pid);
  release(&lk->lk);
  return r;
}


// Lab 9
void
acquiresleep(struct sleeplock *lk)
{
  struct proc *p;

  acquire(&lk->lk);
  while (lk->locked) {
    p = lk->head;
    if (p == 0) {
      lk->head = myproc();
    } else {
      while (p->next) {
        p = p->next;
      }
      p->next = myproc();
    }
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
  lk->pid = myproc()->pid;
  release(&lk->lk);
}

// Lab 9 
void
releasesleep(struct sleeplock *lk)
{
  struct proc *p;

  acquire(&lk->lk);
  lk->locked = 0;
  lk->pid = 0;
  
  p = lk->head;
  if(p) { 
    acquire(&p->lock); 
    if(p->state == SLEEPING && p->chan == lk) 
      p->state = RUNNABLE;
    release(&p->lock);
    lk->head = p->next;
  }
//  wakeup(lk);
  release(&lk->lk);
}


