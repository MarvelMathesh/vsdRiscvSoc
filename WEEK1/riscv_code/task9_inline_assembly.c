#include <stdio.h>
#include <stdint.h>

// Example 1: Simple inline assembly with constraints explanation
static inline uint32_t rdcycle_demo(void) {
    uint32_t c = 12345; // Simulated cycle count for demo
    // This demonstrates the inline assembly syntax without CSR dependency
    asm volatile ("mv %0, %0" : "=r"(c) : "r"(c));
    return c;
}

// Example 2: Working arithmetic inline assembly
static inline uint32_t add_inline(uint32_t a, uint32_t b) {
    uint32_t result;
    asm volatile ("add %0, %1, %2" 
        : "=r"(result)     // Output constraint: =r means write-only register
        : "r"(a), "r"(b)   // Input constraints
    );
    return result;
}

// Example 3: Demonstrate volatile keyword importance
static inline uint32_t demo_volatile(uint32_t input) {
    uint32_t output;
    // volatile prevents compiler from optimizing away the assembly
    asm volatile ("slli %0, %1, 1"  // Shift left logical immediate by 1
        : "=r"(output)    // =r: output constraint, write-only register
        : "r"(input)      // r: input constraint
    );
    return output;
}

int main() {
    printf("=== Task 9: Inline Assembly Basics ===\n");
    printf("CSR 0xC00 (cycle counter) inline assembly demo\n\n");

    // Demonstrate the rdcycle function structure
    uint32_t cycles = rdcycle_demo();
    printf("Simulated cycle count: %u\n", cycles);

    // Demonstrate working inline assembly
    uint32_t sum = add_inline(15, 25);
    printf("15 + 25 = %u (using inline assembly)\n", sum);

    uint32_t shifted = demo_volatile(5);
    printf("5 << 1 = %u (using volatile inline assembly)\n", shifted);

    printf("\n=== Constraint Explanations ===\n");
    printf("\"=r\"(output) - Output constraint:\n");
    printf("  '=' means write-only (output)\n");
    printf("  'r' means general-purpose register\n\n");

    printf("\"r\"(input) - Input constraint:\n");
    printf("  'r' means general-purpose register (read)\n\n");

    printf("'volatile' keyword:\n");
    printf("  Prevents compiler optimization\n");
    printf("  Ensures assembly code is not removed\n");
    printf("  Required for CSR reads and hardware operations\n");

    return 0;
}
