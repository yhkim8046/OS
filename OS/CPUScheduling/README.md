# ReadMe: xv6 Custom Scheduler with Nice Values

## Overview
This project extends the xv6 kernel to support custom scheduling policies, including **Round Robin (RR)**, **First Come First Serve (FCFS)**, and **Priority Scheduling**, along with **nice value adjustments** for fine-grained process priority control.

## Key Features
### Custom System Calls
- **`setnice(pid, nice)`**: Adjusts the nice value of a process. Higher nice values correspond to lower priority.
- **`getnice(pid)`**: Retrieves the nice value of a process.
- **`wait2`**: Returns detailed execution statistics for processes, including run time, wait time, and sleep time.

### Enhanced Scheduling Policies
- **Round Robin (RR)**: Default policy in xv6 for time-sharing between processes.
- **First Come First Serve (FCFS)**: New scheduling policy where processes are scheduled based on arrival time. The impact of nice values may vary based on implementation.
- **Priority Scheduling**: Processes are scheduled based on their priority values, which are influenced by their nice values.

### Scheduling Tests (`schedtest2`)
- Generates a mix of I/O-bound and CPU-bound processes.
- Adjusts priorities for I/O-bound processes using `setnice`.

## How to Build and Run
### Build xv6 with Custom Scheduler
1. Clone the repository:
   ```bash
   git clone https://github.com/yhkim8046/OS.git
   cd your-repo-name/xv6-riscv
   ```
2. Compile the xv6 kernel:
   ```bash
   make clean && make
   ```

### Run with Different Policies
#### Round Robin (RR):
```bash
make qemu CPUS=3 RR
```
**Description**: This is the default policy in xv6, where processes are time-shared equally.

#### First Come First Serve (FCFS):
```bash
make qemu CPUS=3 FCFS=1
```
**Description**: Processes are scheduled based on their arrival time. Nice values may have limited effect depending on implementation.

#### Priority Scheduling:
```bash
make qemu CPUS=3 PRIORITY=1
```
**Description**: Processes are scheduled based on their priority values, with lower nice values corresponding to higher priorities.

### Test with Custom Scheduler
Run the `schedtest2` program inside xv6 to verify the functionality:
```bash
(xv6)$ schedtest2
```
**Example Output**:
```plaintext
Process 4 original nice is 10, now changed to 18
Process 5 original nice is 10, now changed to 18
Process 6 original nice is 10, now changed to 18
Process 7 original nice is 10, now changed to 18
Process 8 original nice is 10, now changed to 18
Average run-time = 20,  wait time = 122, sleep time = 90
```

## Features
### Custom System Calls
- **`setnice`**: Adjusts the priority (nice value) of processes. Higher nice values correspond to lower priority.
- **`getnice`**: Queries the current nice value of a process.
- **`wait2`**: Collects detailed process statistics, including run time, wait time, and sleep time.

### Custom Scheduling Policies
- **RR (Round Robin)**: Time-sharing between processes using time quanta.
- **FCFS (First Come First Serve)**: Processes are executed in the order of their arrival.
- **Priority Scheduling**: Processes are executed based on their priority values, influenced by their nice values.

### Scheduling Tests (`schedtest2`)
- Generates a mix of I/O-bound and CPU-bound processes.
- Adjusts priorities for I/O-bound processes using `setnice`.

## File Modifications
- **`kernel/sysproc.c`**: Added `sys_setnice`, `sys_getnice`, and `wait2` system calls.
- **`kernel/proc.c`**: Implemented FCFS and Priority scheduling logic and extended process statistics.
- **`kernel/proc.h`**: Added fields for nice value, priority, and additional statistics.
- **`user/schedtest2.c`**: Test program to validate the custom scheduler.

## Contributing
Feel free to submit issues or pull requests to improve functionality or add features.

## License
This project is licensed under the MIT License.

## Acknowledgments
Based on MIT's xv6 Operating System.

