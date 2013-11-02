#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>

extern void next_state(int old[EXT_HEIGHT][EXT_WIDTH],
                       int new[EXT_HEIGHT][EXT_WIDTH]);

extern int check_sse();

int __attribute__ ((aligned(16))) a1[EXT_HEIGHT][EXT_WIDTH];
int __attribute__ ((aligned(16))) a2[EXT_HEIGHT][EXT_WIDTH];
int steps;
int step = 0;
long int total_time = 0;

void read_board() {
    int i, j;
    for (i = 0; i < HEIGHT; ++i) {
        for (j = 0; j < WIDTH; ++j) {
            scanf("%d", &a1[i+1][j+H_EXT]);
        }
    }
}

void print_array(int step) {
    printf("\n");
    int i, j;
    for (i = 0; i < HEIGHT; ++i) {
        for (j = 0; j < WIDTH; ++j) {
            int val = (step % 2 == 0) ? a1[i+1][j+H_EXT] : a2[i+1][j+H_EXT];
            printf("%c", (val == 0 ? '.' : 'O'));
        }
        printf("\n");
    }
}

void execute(int old[EXT_HEIGHT][EXT_WIDTH],
             int new[EXT_HEIGHT][EXT_WIDTH]) {
    struct timeval start, end;
    gettimeofday(&start, NULL);
    next_state(old, new);
    gettimeofday(&end, NULL);
    total_time += (end.tv_sec - start.tv_sec) * 1000000 +
                  (end.tv_usec - start.tv_usec);

}

int main(int argc, char **argv) {
    if (argc != 2) {
        printf("Usage: ./conway <steps>\n");
        return 1;
    }

    steps = atoi(argv[1]);

    if (check_sse() != 1) {
        printf("SSE not supported.\n");
        return 1;
    }
    read_board();
    print_array(0);
    while(step < steps) {
        if (step % 2 == 0)
            execute(a1, a2);
        else
            execute(a2, a1);
        step++;
        print_array(step);
    }
    printf("Total time %ld [\u00B5s].\n", total_time);
    return 0;
}
