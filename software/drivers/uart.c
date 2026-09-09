#include "uart.h"
#include <stdint.h>

#define UART_STATUS_ADDR  0x80000008u
#define UART_DATA_ADDR    0x8000000Cu

#define UART_STATUS \
    (*(volatile uint32_t *)UART_STATUS_ADDR)

#define UART_DATA \
    (*(volatile uint8_t *)UART_DATA_ADDR)

#define UART_TX_BUSY   (1u << 0)
#define UART_RX_READY  (1u << 1)

void uart_init(void)
{
    // The hardware UART does not require initialization.
}

void uart_putc(char c)
{
    // Bit 0 is 1 while the transmitter is busy.
    while ((UART_STATUS & UART_TX_BUSY) != 0u)
    {
        // Wait for the transmitter to become available.
    }

    UART_DATA = (uint8_t)c;
}

void uart_puts(const char *str)
{
    if (str == 0)
    {
        return;
    }

    while (*str != '\0')
    {
        uart_putc(*str);
        str++;
    }
}

char uart_getc(void)
{
    // Bit 1 becomes 1 when a received byte is available.
    while ((UART_STATUS & UART_RX_READY) == 0u)
    {
        // Wait for incoming data.
    }

    return (char)UART_DATA;
}

void uart_gets(char *buffer)
{
    char c;

    if (buffer == 0)
    {
        return;
    }

    while (1)
    {
        c = uart_getc();

        if ((c == '\n') || (c == '\r'))
        {
            *buffer = '\0';
            return;
        }

        *buffer = c;
        buffer++;
    }
}