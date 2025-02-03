🔷 Semaphore Test Program for xv6
🚀 This repository contains a simple test program to demonstrate how semaphores work in xv6. The program creates multiple child processes, each of which performs down and up operations on a semaphore, simulating a synchronized environment.

📌 Features
Implements a counting semaphore using the sematest() system call.
Forks 10 child processes, each performing semaphore down (P()) and up (V()) operations.
Uses parent-child synchronization to ensure proper execution.
Demonstrates multi-process synchronization in xv6.

📌 How It Works
Initialize the semaphore with sematest(0).
Create 10 child processes using fork().
Each child process:
Decrements the semaphore (sematest(1)) → Entering critical section
Sleeps for 100 ticks (simulating work)
Increments the semaphore (sematest(2)) → Leaving critical section
The parent process:
Waits for all child processes to finish.
Prints the final semaphore value.

📌 How to run:
1. Clone this git
2. Place the folder xv6-riscv in terminal 
3. Run "make clean"
4. Run "make qemu"
5. Run "rwsematest"

