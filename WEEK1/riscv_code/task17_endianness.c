#include <stdio.h>
#include <stdint.h>
#include <string.h>

// Test endianness using union trick
void test_endianness(void) {
    union {
        uint32_t i;
        uint8_t c[4];
    } test_union;

    test_union.i = 0x01020304;

    printf("=== Endianness Test ===\n");
    printf("32-bit value: 0x%08X\n", test_union.i);
    printf("Byte order in memory: ");
    for (int j = 0; j < 4; j++) {
        printf("%02X ", test_union.c[j]);
    }
    printf("\n");

    if (test_union.c[0] == 0x04) {
        printf("System is LITTLE-ENDIAN\n");
        printf("Least significant byte (0x04) stored at lowest address\n");
    } else if (test_union.c[0] == 0x01) {
        printf("System is BIG-ENDIAN\n");
        printf("Most significant byte (0x01) stored at lowest address\n");
    } else {
        printf("Unknown endianness\n");
    }
}

// Test struct packing and alignment
void test_struct_packing(void) {
    printf("\n=== Struct Packing Test ===\n");

    // Regular struct (with padding)
    struct regular_struct {
        uint8_t  a;    // 1 byte
        uint32_t b;    // 4 bytes (3 bytes padding after 'a')
        uint16_t c;    // 2 bytes
        uint8_t  d;    // 1 byte (1 byte padding after to align to 4-byte boundary)
    };

    // Packed struct (no padding)
    struct __attribute__((packed)) packed_struct {
        uint8_t  a;    // 1 byte
        uint32_t b;    // 4 bytes
        uint16_t c;    // 2 bytes
        uint8_t  d;    // 1 byte
    };

    printf("Regular struct size: %zu bytes\n", sizeof(struct regular_struct));
    printf("Packed struct size:  %zu bytes\n", sizeof(struct packed_struct));
    
    // Test actual memory layout
    struct regular_struct reg = {0xAA, 0x12345678, 0xBBCC, 0xDD};
    struct packed_struct pack = {0xAA, 0x12345678, 0xBBCC, 0xDD};
    
    printf("\nRegular struct memory layout:\n");
    uint8_t *reg_ptr = (uint8_t *)&reg;
    for (size_t i = 0; i < sizeof(struct regular_struct); i++) {
        printf("Offset %zu: 0x%02X\n", i, reg_ptr[i]);
    }
    
    printf("\nPacked struct memory layout:\n");
    uint8_t *pack_ptr = (uint8_t *)&pack;
    for (size_t i = 0; i < sizeof(struct packed_struct); i++) {
        printf("Offset %zu: 0x%02X\n", i, pack_ptr[i]);
    }
}

// Test different data type endianness
void test_data_types_endianness(void) {
    printf("\n=== Data Type Endianness Test ===\n");
    
    // Test 16-bit value
    union {
        uint16_t val16;
        uint8_t bytes16[2];
    } test16;
    test16.val16 = 0x1234;
    
    printf("16-bit value 0x%04X: ", test16.val16);
    printf("bytes = [0x%02X, 0x%02X]\n", test16.bytes16[0], test16.bytes16[1]);
    
    // Test 64-bit value
    union {
        uint64_t val64;
        uint8_t bytes64[8];
    } test64;
    test64.val64 = 0x0102030405060708ULL;
    
    printf("64-bit value 0x%016llX:\n", test64.val64);
    printf("bytes = [");
    for (int i = 0; i < 8; i++) {
        printf("0x%02X", test64.bytes64[i]);
        if (i < 7) printf(", ");
    }
    printf("]\n");
}

// Test pointer and address layout
void test_pointer_layout(void) {
    printf("\n=== Pointer and Address Layout ===\n");
    
    uint32_t array[4] = {0x11111111, 0x22222222, 0x33333333, 0x44444444};
    
    printf("Array addresses and values:\n");
    for (int i = 0; i < 4; i++) {
        printf("array[%d] @ %p = 0x%08X\n", i, &array[i], array[i]);
    }
    
    printf("\nMemory dump of array:\n");
    uint8_t *byte_ptr = (uint8_t *)array;
    for (int i = 0; i < 16; i++) {
        printf("Byte %2d: 0x%02X\n", i, byte_ptr[i]);
    }
}

int main() {
    printf("=== Task 17: RISC-V Endianness & Struct Packing ===\n\n");
    
    test_endianness();
    test_struct_packing();
    test_data_types_endianness();
    test_pointer_layout();
    
    printf("\n=== RISC-V Endianness Conclusion ===\n");
    printf("RV32 is LITTLE-ENDIAN by default\n");
    printf("- Least significant byte stored at lowest memory address\n");
    printf("- Most significant byte stored at highest memory address\n");
    printf("- This matches x86/x86_64 byte ordering\n");
    
    return 0;
}
