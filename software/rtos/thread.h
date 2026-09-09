#ifndef THREAD_H
#define THREAD_H

#include <stdint.h>

typedef struct {
    uint32_t *sp;
    uint32_t pc;
} thread_t;

extern thread_t threads[2];
extern uint32_t current_thread;

void schedule(void);

#endif