#include "gpio.h"

#define GPIO_SWITCHES (*(volatile uint32_t *)0x80000000)
#define GPIO_LEDS     (*(volatile uint32_t *)0x80000004)

uint32_t gpio_read_switches(void)
{
    return GPIO_SWITCHES & 0xF;
}

void gpio_write_leds(uint32_t value)
{
    GPIO_LEDS = value & 0xF;
}