#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <errno.h>

// Test function demonstrating printf functionality
void test_printf_functionality(void) {
    printf("Hello, RISC-V printf!\n");
    printf("Testing integer output: %d\n", 42);
    printf("Testing hex output: 0x%08X\n", 0xDEADBEEF);
    printf("Testing string output: %s\n", "UART-based printf working!");
    printf("Testing character output: %c\n", 'A');
}

int main() {
    // Initialize and test printf functionality
    printf("=== Task 16: Newlib printf Without OS ===\n");
    printf("UART-based printf implementation\n\n");
    
    test_printf_functionality();
    
    printf("\nPrintf retargeting to UART successful!\n");
    
    return 0;
}

/*
NOTE: All syscall functions (_write, _read, _close, etc.) are implemented 
in syscalls.c to avoid multiple definition errors during linking.
*/
