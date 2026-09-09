#ifndef GPIO_H
#define GPIO_H

#include <stdint.h>

uint32_t gpio_read_switches(void);
void gpio_write_leds(uint32_t value);

#endif