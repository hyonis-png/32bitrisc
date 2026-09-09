#include "timer.h"

#define TIMER_COUNT       (*(volatile uint32_t *)0x80000010)
#define TIMER_COMPARE     (*(volatile uint32_t *)0x80000014)
#define TIMER_IRQ_ENABLE  (*(volatile uint32_t *)0x80000018)
#define TIMER_IRQ_STATUS_CLEAR (*(volatile uint32_t *)0x8000001C)
uint32_t timer_read(void)
{
    return TIMER_COUNT;
}

void timer_set_compare(uint32_t value)
{
    TIMER_COMPARE = value;
}

void timer_irq_enable(void)
{
    TIMER_IRQ_ENABLE = 1;
}

void timer_irq_disable(void)
{
    TIMER_IRQ_ENABLE = 0;
}

void timer_irq_clear(void)
{
    TIMER_IRQ_STATUS_CLEAR = 1;
}

uint32_t timer_irq_pending(void)
{
    return TIMER_IRQ_STATUS_CLEAR & 1;
}