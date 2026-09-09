#include <stdint.h>

#include "drivers/gpio.h"
#include "drivers/timer.h"
#include "drivers/interrupt.h"
#include "rtos/thread.h"

#define STACK_SIZE 256

uint32_t stack_A[STACK_SIZE];
uint32_t stack_B[STACK_SIZE];

void thread_A(void)
{
    while (1)
    {
        gpio_write_leds(0x1);
    }
}

void thread_B(void)
{
    while (1)
    {
        gpio_write_leds(0x2);
    }
}

// trap_entry is defined in trap_entry.S
extern void trap_entry(void);

void interrupt_handler(void)
{
    timer_irq_clear();

    schedule();
}

int main(void)
{
    interrupt_disable();

    // Create the two thread descriptions.
    thread_create(0, thread_A, stack_A, STACK_SIZE);
    thread_create(1, thread_B, stack_B, STACK_SIZE);

    interrupt_set_handler(trap_entry);

    uint32_t now = timer_read();
    timer_set_compare(now + 100000000);

    timer_irq_enable();

    gpio_write_leds(0x1);

    interrupt_enable();

    while (1)
    {
    }

    return 0;
}