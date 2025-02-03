----------------------------------------------------------
# ReadMe: xv6 Parent-Child Communication with Pipes

## Overview
This project demonstrates inter-process communication in the xv6 kernel using pipes. A parent process sends an integer to a child process through a pipe. The child modifies the integer and sends it back to the parent. This simple example highlights the use of pipes and the `fork()` system call for process communication in xv6.

## Key Features
1. **Parent-Child Communication**:
   - The parent process sends an integer to the child.
   - The child multiplies the integer by 4 and sends it back to the parent.
2. **Pipe Mechanism**:
   - Demonstrates the use of `pipe()` for creating a communication channel.
   - File descriptors: `p[0]` for reading, `p[1]` for writing.

3. **System Call Usage**:
   - `fork()` for creating a child process.
   - `read()` and `write()` for pipe-based communication.
   - `wait()` to ensure the parent waits for the child process to complete.

## How to Build and Run
### Prerequisites
1. Clone the xv6 repository and navigate to the project directory:
   ```bash
   git clone https://github.com/yhkim8046/OS.git
   cd xv6-riscv
   ```

2. Compile the xv6 kernel:
   ```bash
   make clean && make
   ```

### Run the Program
1. Boot xv6 using QEMU:
   ```bash
   qemu-system-riscv64 -machine virt -bios none -kernel kernel/kernel -m 128M -smp 3 -nographic -drive file=fs.img,if=none,format=raw,id=x0 -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0
   ```

2. In the xv6 shell, run the program:
   ```bash
   (xv6)$ pingpong
   ```

### Expected Output
If the program runs correctly, the output will be:
```plaintext
4 Integer from parent = 4
3 Integer from child = 16
```

## Code Explanation
### Program Logic
1. **Parent Process**:
   - Initializes an integer `x` to `4`.
   - Sends the integer to the child process using `write()`.
   - Waits for the modified integer to be sent back by the child.
   - Prints the result received from the child process.

2. **Child Process**:
   - Reads the integer from the parent using `read()`.
   - Multiplies the integer by `4`.
   - Sends the modified integer back to the parent using `write()`.

### Key File Modifications
- **`user/pingpong.c`**:
   - Contains the implementation of the parent-child communication logic.

## Example Code
```c
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
    int p[2]; // file descriptors: 0 = reading, 1 = writing
    int r;
    int x; // for integer

    // single pipe created
    pipe(p);

    // fork the child process
    r = fork();
  
    if(r < 0){
        // fork failed
        fprintf(2, "fork error\n");
        exit(1);
    } else if(r == 0){
        // child

        // get integer from parent
        if(read(p[0], &x, sizeof(int)) != sizeof(int)){
            fprintf(2, "child read error\n");
            exit(1);
        }

        printf("%d Integer from parent = %d\n", getpid(), x);

        // multiply the integer by 4
        x *= 4;
        
        // write the result and send it back to the parent
        if(write(p[1], &x, sizeof(int)) != sizeof(int)){
            fprintf(2, "child write error\n");
            exit(1);
        }

        exit(0);

    } else {
        // parent

        x = 4; // variable init

        // write the integer and send it to the child
        if(write(p[1], &x, sizeof(int)) != sizeof(int)){
            fprintf(2, "parent write error\n");
            exit(1);
        }

        // get the modified integer sent back
        if(read(p[0], &x, sizeof(int)) != sizeof(int)){
            fprintf(2, "parent read error\n");
            exit(1);
        }

        // print parent and the integer
        printf("%d Integer from child = %d\n", getpid(), x);

        // Wait for the child to finish
        wait(0);

        // parent end
        exit(0);
    }
}
```

## Contributing
Feel free to submit issues or pull requests to improve the program or add additional functionality.

## License
This project is licensed under the MIT License.

## Acknowledgments
Based on MIT's xv6 Operating System.

