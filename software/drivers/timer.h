#ifndef TIMER_H
#define TIMER_H

#include <stdint.h>

uint32_t timer_read(void);

void timer_set_compare(uint32_t value);

void timer_irq_enable(void);
void timer_irq_disable(void);
void timer_irq_clear(void);
uint32_t timer_irq_pending(void);

#endif