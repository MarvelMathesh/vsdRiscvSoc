#include <stdio.h>
#include <stdint.h>

int main() {
    // Union trick to test endianness
    union {
        uint32_t i;
        uint8_t c[4];
    } test_union;

    test_union.i = 0x01020304;

    printf("RISC-V Endianness Test\n");
    printf("======================\n");
    printf("32-bit value: 0x%08X\n", test_union.i);
    printf("Byte order: ");
    for (int j = 0; j < 4; j++) {
        printf("%02X ", test_union.c[j]);
    }
    printf("\n");

    if (test_union.c[0] == 0x04) {
        printf("Result: RISC-V is LITTLE-ENDIAN\n");
        printf("Explanation: LSB (0x04) is at lowest address\n");
    } else if (test_union.c[0] == 0x01) {
        printf("Result: RISC-V is BIG-ENDIAN\n");
        printf("Explanation: MSB (0x01) is at lowest address\n");
    } else {
        printf("Result: Unknown endianness\n");
    }

    return 0;
}
