#ifndef INTERRUPT_H
#define INTERRUPT_H

void interrupt_enable(void);
void interrupt_disable(void);

void interrupt_set_handler(void (*handler)(void));

void interrupt_handler(void);

#endif