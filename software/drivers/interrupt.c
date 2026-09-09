#include "interrupt.h"

void interrupt_enable(void)
{
    __asm__ volatile ("csrsi mstatus, 8");
}

void interrupt_disable(void)
{
    __asm__ volatile ("csrci mstatus, 8");
}

void interrupt_set_handler(void (*handler)(void))
{
    __asm__ volatile (
        "csrw mtvec, %0"
        :
        : "r"(handler)
    );
}