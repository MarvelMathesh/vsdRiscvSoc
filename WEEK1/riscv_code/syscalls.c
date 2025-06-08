#include <stdio.h>
#include <stdint.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>

// UART register for output
#define UART_BASE 0x10000000
#define UART_TX_REG (*(volatile uint32_t *)(UART_BASE + 0x00))

// UART character output function
void uart_putchar(char c) {
    UART_TX_REG = (uint32_t)c;
}

// Retarget _write for printf
int _write(int fd, char *buf, int len) {
    if (fd == STDOUT_FILENO || fd == STDERR_FILENO) {
        for (int i = 0; i < len; i++) {
            uart_putchar(buf[i]);
            if (buf[i] == '\n') {
                uart_putchar('\r');  // CRLF conversion
            }
        }
        return len;
    }
    errno = EBADF;
    return -1;
}

// Required syscalls for printf (minimal implementations)
int _close(int fd) {
    errno = EBADF;
    return -1;
}

int _fstat(int fd, struct stat *st) {
    if (fd <= 2) {  // stdin, stdout, stderr
        st->st_mode = S_IFCHR;  // Character device
        return 0;
    }
    errno = EBADF;
    return -1;
}

int _isatty(int fd) {
    return (fd <= 2) ? 1 : 0;  // stdin, stdout, stderr are TTY
}

off_t _lseek(int fd, off_t offset, int whence) {
    errno = ESPIPE;  // Not seekable
    return -1;
}

ssize_t _read(int fd, void *buf, size_t len) {
    errno = EBADF;  // Not implemented
    return -1;
}
