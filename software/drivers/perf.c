#include "perf.h"

uint32_t perf_get_cycles(void)
{
    return CYCLE;
}

uint32_t perf_get_instructions(void)
{
    return INST_RETIRED;
}