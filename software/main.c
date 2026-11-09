#include <stdint.h>

#include "drivers/gpio.h"
#include "drivers/timer.h"
#include "drivers/interrupt.h"
#include "drivers/perf.h"
#include "rtos/thread.h"
#include "drivers/uart.h"

#define STACK_SIZE 256

uint32_t stack_A[STACK_SIZE];
uint32_t stack_B[STACK_SIZE];

int main(void)
{
    uint32_t start_cycles;
    uint32_t start_inst;

    uint32_t end_cycles;
    uint32_t end_inst;

    // read counters
    start_cycles = perf_get_cycles();
    start_inst = perf_get_instructions();

    // benchmark()
    volatile int sum = 0;
    for (int i = 0; i < 1000; i++)
    {
        sum += i;
    }

    // read counters
    end_cycles = perf_get_cycles();
    end_inst = perf_get_instructions();

    // calculate differences
    uint32_t diff_cycles = end_cycles - start_cycles;
    uint32_t diff_inst = end_inst - start_inst;

    // print results
    uart_puts("Cycles: ");
    uart_putnum(diff_cycles);
    uart_puts("\nInstructions: ");
    uart_putnum(diff_inst);

    while (1)
    {
    }
}