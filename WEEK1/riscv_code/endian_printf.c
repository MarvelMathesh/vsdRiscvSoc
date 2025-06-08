#include <stdio.h>
#include <stdint.h>
#include <sys/stat.h>
#include <unistd.h>

// UART for printf output
#define UART_BASE 0x10000000
#define UART_TX_REG (*(volatile uint32_t *)(UART_BASE + 0x00))

void uart_putchar(char c) {
    UART_TX_REG = (uint32_t)c;
}

int _write(int fd, char *buf, int len) {
    if (fd == STDOUT_FILENO || fd == STDERR_FILENO) {
        for (int i = 0; i < len; i++) {
            uart_putchar(buf[i]);
            if (buf[i] == '\n') {
                uart_putchar('\r');
            }
        }
        return len;
    }
    return -1;
}

// Minimal syscalls
int _close(int fd) { return -1; }
int _fstat(int fd, struct stat *st) { 
    if (fd <= 2) { st->st_mode = S_IFCHR; return 0; }
    return -1; 
}
int _isatty(int fd) { return (fd <= 2) ? 1 : 0; }
int _lseek(int fd, int offset, int whence) { return -1; }
int _read(int fd, char *buf, int len) { return -1; }
