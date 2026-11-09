#ifndef PERF_H
#define PERF_H

#include <stdint.h>

#define CYCLE_ADDR         0x80000020u
#define INST_RETIRED_ADDR  0x80000024u

#define CYCLE \
    (*(volatile uint32_t *)CYCLE_ADDR)

#define INST_RETIRED \
    (*(volatile uint32_t *)INST_RETIRED_ADDR)

uint32_t perf_get_cycles(void);
uint32_t perf_get_instructions(void);

#endif