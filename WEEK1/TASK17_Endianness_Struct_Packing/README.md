# TASK 17: Endianness & Struct Packing - RISC-V Byte Order Verification

## Objective

Verify that RV32 is little-endian by default using the classic union trick in C. Demonstrate comprehensive byte ordering verification by storing multi-byte values and examining individual bytes. Additionally, explore struct packing and alignment behavior to understand memory layout optimization and hardware interface considerations in RISC-V systems.

## Key Learning Outcomes

Upon completion of this task, you will have mastered:

- **Endianness Detection**: Professional techniques for runtime endianness verification
- **Union Programming**: Advanced C union usage for memory layout analysis
- **Struct Packing**: Understanding compiler alignment rules and memory optimization
- **Memory Layout Analysis**: Low-level memory organization and data representation
- **Cross-Platform Compatibility**: Endianness considerations for portable code
- **Hardware Interface Programming**: Byte order implications for device drivers and protocols

## Prerequisites

- Completed TASK16 (Newlib Printf) - Understanding of printf retargeting and system programming
- RISC-V cross-compilation toolchain with printf support
- Knowledge of C unions, structs, and memory layout concepts
- Understanding of endianness concepts and their importance in system programming
- Basic knowledge of compiler attributes and memory alignment

## Setup & Installation

### Environment Preparation

```bash
# Navigate to working directory
cd ~/riscv_code

# Verify printf functionality is available from previous task
ls -la printf_syscalls.c
```

## Technical Deep Dive

### Endianness in Computer Systems

#### Little-Endian vs Big-Endian
- **Little-Endian**: Least significant byte stored at lowest memory address
- **Big-Endian**: Most significant byte stored at lowest memory address
- **RISC-V Default**: Little-endian (configurable in some implementations)

#### Union Trick Mechanism
```c
union endian_test {
    uint32_t word;     // 32-bit integer
    uint8_t bytes[4];  // Array of 4 bytes
};

// Store 0x01020304
union endian_test test;
test.word = 0x01020304;

// Little-endian result: bytes[0]=0x04, bytes[1]=0x03, bytes[2]=0x02, bytes[3]=0x01
// Big-endian result:    bytes[0]=0x01, bytes[1]=0x02, bytes[2]=0x03, bytes[3]=0x04
```

### Struct Packing and Alignment

#### Default Alignment Rules
- **1-byte types** (char): No alignment requirement
- **2-byte types** (short): Aligned to 2-byte boundaries
- **4-byte types** (int): Aligned to 4-byte boundaries
- **8-byte types** (double): Aligned to 8-byte boundaries (on 64-bit systems)

#### Padding Example
```c
struct example {
    uint8_t  a;    // 1 byte
    uint32_t b;    // 4 bytes (3 bytes padding after 'a')
    uint16_t c;    // 2 bytes
    uint8_t  d;    // 1 byte (1 byte padding after for struct alignment)
};
// Total size: 12 bytes (with padding)
```

#### Packed Structures
```c
struct __attribute__((packed)) packed_example {
    uint8_t  a;    // 1 byte
    uint32_t b;    // 4 bytes (no padding)
    uint16_t c;    // 2 bytes
    uint8_t  d;    // 1 byte
};
// Total size: 8 bytes (no padding)
```

## Implementation Details

### Comprehensive Endianness Test

```c
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
```

### Struct Packing Analysis

```c
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
```

## Step-by-Step Implementation

### Step 1: Create Comprehensive Endianness Demo
```bash
# Create comprehensive endianness and struct packing demonstration
cat << 'EOF' > task17_endianness.c
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
EOF
```

### Step 2: Create Simple Endianness Test
```bash
# Create focused endianness test for quick verification
cat << 'EOF' > task17_simple_endian.c
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
EOF
```

### Step 3: Create Assembly Startup and Printf Support
```bash
# Create startup code for endianness demo
cat << 'EOF' > endian_start.s
.section .text.start
.global _start

_start:
    # Set up stack pointer
    lui sp, %hi(_stack_top)
    addi sp, sp, %lo(_stack_top)
    
    # Initialize BSS section
    la t0, _bss_start
    la t1, _bss_end
bss_loop:
    bge t0, t1, bss_done
    sw zero, 0(t0)
    addi t0, t0, 4
    j bss_loop
bss_done:
    
    # Call main program
    call main
    
    # Infinite loop
1:  j 1b

.size _start, . - _start
EOF

# Create linker script
cat << 'EOF' > endian.ld
ENTRY(_start)

MEMORY
{
    FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 256K
    SRAM  (rwx) : ORIGIN = 0x10000000, LENGTH = 64K
}

SECTIONS
{
    .text 0x00000000 : {
        *(.text.start)
        *(.text*)
        *(.rodata*)
    } > FLASH

    .data 0x10000000 : {
        _data_start = .;
        *(.data*)
        _data_end = .;
    } > SRAM

    .bss : {
        _bss_start = .;
        *(.bss*)
        _bss_end = .;
    } > SRAM

    .heap : {
        _heap_start = .;
        . += 8192;
        _heap_end = .;
    } > SRAM

    _stack_top = ORIGIN(SRAM) + LENGTH(SRAM);
}
EOF

# Create printf support for endianness test
cat << 'EOF' > endian_printf.c
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
EOF
```

### Step 4: Compile Endianness Programs
```bash
# Compile all components
riscv32-unknown-elf-gcc -march=rv32imc -c endian_start.s -o endian_start.o
riscv32-unknown-elf-gcc -march=rv32imc -c task17_endianness.c -o task17_endianness.o
riscv32-unknown-elf-gcc -march=rv32imc -c task17_simple_endian.c -o task17_simple_endian.o
riscv32-unknown-elf-gcc -march=rv32imc -c endian_printf.c -o endian_printf.o

# Link comprehensive version
riscv32-unknown-elf-gcc -T endian.ld -nostartfiles endian_start.o task17_endianness.o endian_printf.o -o task17_endianness.elf

# Link simple version
riscv32-unknown-elf-gcc -T endian.ld -nostartfiles endian_start.o task17_simple_endian.o endian_printf.o -o task17_simple_endian.elf
```

### Step 5: Create Complete Build Script
```bash
cat << 'EOF' > build_endian_demo.sh
#!/bin/bash
echo "=== Task 17: Endianness & Struct Packing ==="

# Compile all components
echo "1. Compiling endianness demo components..."
riscv32-unknown-elf-gcc -march=rv32imc -c endian_start.s -o endian_start.o
riscv32-unknown-elf-gcc -march=rv32imc -c task17_endianness.c -o task17_endianness.o
riscv32-unknown-elf-gcc -march=rv32imc -c task17_simple_endian.c -o task17_simple_endian.o
riscv32-unknown-elf-gcc -march=rv32imc -c endian_printf.c -o endian_printf.o

# Link programs
echo "2. Linking endianness programs..."
riscv32-unknown-elf-gcc -T endian.ld -nostartfiles endian_start.o task17_endianness.o endian_printf.o -o task17_endianness.elf
riscv32-unknown-elf-gcc -T endian.ld -nostartfiles endian_start.o task17_simple_endian.o endian_printf.o -o task17_simple_endian.elf

echo "✓ Compilation successful!"

# Verify results
echo -e "\n3. Verifying endianness demo programs:"
file task17_endianness.elf
file task17_simple_endian.elf

echo -e "\n4. Checking union usage in disassembly:"
riscv32-unknown-elf-objdump -d task17_simple_endian.elf | grep -A 10 -B 5 "main"

echo -e "\n5. Symbol table showing endianness functions:"
riscv32-unknown-elf-nm task17_simple_endian.elf | grep -E "(main|test|union)"

echo -e "\n6. Generate assembly to see union operations:"
riscv32-unknown-elf-gcc -march=rv32imc -S task17_simple_endian.c

echo -e "\n7. Check how union is implemented:"
grep -A 15 -B 5 "test_union" task17_simple_endian.s

echo -e "\n8. Check memory access patterns:"
grep -E "(sw|lw|lb|lbu)" task17_simple_endian.s | head -10

echo -e "\n✓ Endianness demonstration ready!"
EOF

chmod +x build_endian_demo.sh
```

### Step 6: Advanced Analysis
```bash
# Generate assembly for detailed analysis
riscv32-unknown-elf-gcc -march=rv32imc -S task17_simple_endian.c

# Check union implementation
echo "=== Union Implementation Analysis ==="
grep -A 15 -B 5 "test_union" task17_simple_endian.s

# Check memory access patterns
echo "=== Memory Access Patterns ==="
grep -E "(sw|lw|lb|lbu)" task17_simple_endian.s | head -10

# Verify struct alignment
echo "=== Struct Size Analysis ==="
echo 'struct test { char a; int b; short c; char d; }; int main() { return sizeof(struct test); }' | \
riscv32-unknown-elf-gcc -march=rv32imc -x c - -o struct_test && \
echo "Regular struct size: $(riscv32-unknown-elf-objdump -d struct_test | grep -A 5 'main:' | grep 'li.*a0' | awk '{print $3}')"
```

## Output

### Successful Compilation
```bash
task17_endianness.elf: ELF 32-bit LSB executable, UCB RISC-V, RVC, soft-float ABI
task17_simple_endian.elf: ELF 32-bit LSB executable, UCB RISC-V, RVC, soft-float ABI
```

### Expected Program Output
```
RISC-V Endianness Test
======================
32-bit value: 0x01020304
Byte order: 04 03 02 01 
Result: RISC-V is LITTLE-ENDIAN
Explanation: LSB (0x04) is at lowest address

=== Struct Packing Test ===
Regular struct size: 12 bytes
Packed struct size: 8 bytes

Regular struct memory layout:
Offset 0: 0xAA
Offset 1: 0x00
Offset 2: 0x00
Offset 3: 0x00
Offset 4: 0x78
Offset 5: 0x56
Offset 6: 0x34
Offset 7: 0x12
Offset 8: 0xCC
Offset 9: 0xBB
Offset 10: 0xDD
Offset 11: 0x00
```

### Assembly Analysis Results
```assembly
# Union access pattern in generated assembly
lw      a0, -20(s0)      # Load 32-bit word
lbu     a1, -20(s0)      # Load byte 0 (LSB)
lbu     a2, -19(s0)      # Load byte 1
lbu     a3, -18(s0)      # Load byte 2
lbu     a4, -17(s0)      # Load byte 3 (MSB)
```

## Troubleshooting

### Common Issues

1. **Unexpected endianness results**
   - Verify union is properly initialized
   - Check that compiler optimizations aren't affecting union access
   - Ensure proper casting and memory access patterns

2. **Struct size discrepancies**
   - Different compilers may have different alignment rules
   - Check compiler flags for packing/alignment options
   - Verify target architecture alignment requirements

3. **Printf formatting issues**
   - Ensure printf support is properly linked
   - Check format specifiers for different data types
   - Verify UART output is working correctly

### Debugging Commands
```bash
# Check endianness in binary
hexdump -C task17_simple_endian.elf | head -20

# Verify union operations in assembly
riscv32-unknown-elf-objdump -d task17_simple_endian.elf | grep -A 20 -B 5 "test_union"

# Check struct layout compilation
echo 'struct { char a; int b; } x;' | riscv32-unknown-elf-gcc -march=rv32imc -x c - -S -o - | grep -E "(align|size)"
```

## Testing & Validation

### Validation Checklist
- [ ] Union trick correctly detects little-endian byte order
- [ ] Assembly shows proper load/store operations (lbu, lw, sw)
- [ ] Struct packing demonstrates padding vs packed differences
- [ ] Memory layout analysis shows alignment behavior
- [ ] Printf output correctly displays byte ordering
- [ ] Different data types show consistent endianness

### Verification Script
```bash
#!/bin/bash
echo "=== TASK17 Validation ==="

# Check ELF files
for elf in task17_endianness.elf task17_simple_endian.elf; do
    if [ -f "$elf" ]; then
        echo "✓ $elf created successfully"
    else
        echo "✗ $elf missing"
        exit 1
    fi
done

# Check for union operations in assembly
if riscv32-unknown-elf-objdump -d task17_simple_endian.elf | grep -q "lbu.*-.*s0"; then
    echo "✓ Union byte access detected in assembly"
else
    echo "✗ Union operations not found"
    exit 1
fi

# Verify endianness test logic
if grep -q "test_union.c\[0\] == 0x04" task17_simple_endian.c; then
    echo "✓ Little-endian detection logic present"
else
    echo "✗ Endianness detection logic missing"
    exit 1
fi

# Check struct packing attributes
if grep -q "__attribute__((packed))" task17_endianness.c; then
    echo "✓ Packed struct attributes found"
else
    echo "✗ Struct packing demonstration missing"
    exit 1
fi

echo "✓ All validation checks passed!"
```
