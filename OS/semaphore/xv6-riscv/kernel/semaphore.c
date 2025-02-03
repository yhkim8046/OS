#include "kernel/types.h"
#include "kernel/riscv.h"
#include "kernel/spinlock.h"
#include "kernel/semaphore.h"
#include "kernel/defs.h"

void initsema(struct semaphore* s, int count) {
  s->value = count;
  initlock(&s->lk, "Counting Semaphore");
}

int downsema(struct semaphore* s) {
  acquire(&s->lk);
  while (s->value <=0)
    sleep(s,&s->lk);
  s->value--;
  release(&s->lk);
  return s->value;
}

int upsema(struct semaphore* s) {
  acquire(&s->lk);
  s->value++;
  wakeup(s);
  release(&s->lk);
  return s->value;
}

void initrwsema(struct rwsemaphore *rws)
{
   rws->readers = 0;
   rws->writers = 0;
   initlock(&rws->lk, "Read/Write Semaphore");
}

// A Reader enters room
int downreadsema(struct rwsemaphore *rws)
{
    acquire(&rws->lk);
    while (rws->writers > 0) {
        sleep(rws, &rws->lk); // Wait for no writers
    }
    rws->readers++;
    release(&rws->lk);
    return rws->readers;
}

// A Reader exits room
int upreadsema(struct rwsemaphore *rws)
{
    acquire(&rws->lk);
    rws->readers--;
    if (rws->readers == 0) {
        wakeup(rws); // Wake up waiting writers
    }
    release(&rws->lk);
    return rws->readers;
}

// A Writer enters room
void downwritesema(struct rwsemaphore *rws)
{
    acquire(&rws->lk);
    while (rws->writers > 0 || rws->readers > 0) {
        sleep(rws, &rws->lk);
    }
    rws->writers++;
    release(&rws->lk);
}

// A writer exits room
void upwritesema(struct rwsemaphore *rws)
{
    acquire(&rws->lk);
    rws->writers--;
    wakeup(rws);
    release(&rws->lk);
}
