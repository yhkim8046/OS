//22151849 Yuhwan Kim

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
    int p[2]; // file descriptors: 0 = reading, 1 = writing
    int r;
    int x; //for integer

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

        x = 4; //variable init

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
