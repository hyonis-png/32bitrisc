#include <stdint.h>
#include "thread.h"

#define NUM_THREADS 2

thread_t threads[NUM_THREADS];

uint32_t current_thread = 0;

void schedule(void)
{
    current_thread++;

    if (current_thread >= NUM_THREADS)
    {
        current_thread = 0;
    }
}

void thread_create(uint32_t id,
                   void (*function)(void),
                   uint32_t *stack,
                   uint32_t stack_size)
{
    uint32_t *frame = (stack + stack_size) - 32;

    for (uint32_t i = 0; i < 32; i++)
    {
        frame[i] = 0;
    }

    threads[id].sp = frame;
    threads[id].pc = (uint32_t)function;
}