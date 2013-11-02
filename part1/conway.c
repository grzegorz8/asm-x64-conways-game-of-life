#include<stdlib.h>
#include<stdio.h>
#include<sys/time.h>

#ifndef WIDTH
#define WIDTH   50
#endif
#ifndef HEIGHT
#define HEIGHT  60
#endif

extern void next_state(int old[HEIGHT][WIDTH], int new[HEIGHT][WIDTH]);

int a1[HEIGHT][WIDTH];
int a2[HEIGHT][WIDTH];
int steps;
int step = 0;
long int total_time = 0;

void read_board() {
    int i, j;
    for (i = 0; i < HEIGHT; ++i) {
        for (j = 0; j < WIDTH; ++j) {
            scanf("%d", &a1[i][j]);
        }
    }
}

void print_array(int step) {
    printf("\n");
    int i, j;
    for (i = 0; i < HEIGHT; ++i) {
        for (j = 0; j < WIDTH; ++j) {
            int val = (step % 2 == 0) ? a1[i][j] : a2[i][j];
            printf("%c", (val == 0 ? '.' : 'O'));
        }
        printf("\n");
    }
}

void execute(int old[HEIGHT][WIDTH], int new[HEIGHT][WIDTH]) {
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
    printf("TOTAL TIME: %ld [\u00B5s].\n", total_time);
    return 0;
}
