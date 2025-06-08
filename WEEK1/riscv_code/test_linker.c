#include <stdint.h>

// Global initialized data (goes to .data section at 0x10000000)
uint32_t global_var = 0x12345678;

// Global uninitialized data (goes to .bss section)
uint32_t bss_var;

// Function in .text section (at 0x00000000)
void test_function(void) {
    global_var = 0xABCDEF00;
    bss_var = 0x11111111;
}

// Main function (called from assembly _start)
void main(void) {
    test_function();
    // Infinite loop for bare-metal
    while(1) {
        // Program continues running
    }
}
