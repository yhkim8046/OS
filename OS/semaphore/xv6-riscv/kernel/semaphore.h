// Header file for semaphore

// Generic Counting Semaphore
struct semaphore {
  int value;
  struct spinlock lk;
};

// Prototype of the three semaphore functions in semaphore.c
void initsema(struct semaphore*, int);
int downsema(struct semaphore*);
int upsema(struct semaphore*);


// Read/Write Semaphore
struct rwsemaphore {
int readers;   // Number of active readers
int writers;   // Number of active writers
struct spinlock lk;  // Lock for synchronization
};

void initrwsema(struct rwsemaphore *rws);
int downreadsema(struct rwsemaphore *rws);
int upreadsema(struct rwsemaphore *rws);
void downwritesema(struct rwsemaphore *rws);
void upwritesema(struct rwsemaphore *rws);

