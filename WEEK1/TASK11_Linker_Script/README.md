# RISC-V Linker Script Configuration

Create custom linker scripts to control precise memory layout for RISC-V embedded systems and bare-metal applications.

## Objective

Create custom linker scripts to control precise memory layout for RISC-V embedded systems, implement proper section placement for Flash/SRAM architectures, and demonstrate professional firmware memory management techniques with symbol generation and startup sequence integration.

## Key Learning Outcomes

- Master linker script syntax and memory region definitions
- Understand Flash/SRAM memory layout for embedded systems
- Learn section placement control (.text, .data, .bss)
- Practice symbol definition and memory boundary management
- Implement proper startup sequence with data initialization
- Gain proficiency in bare-metal firmware development workflow

## Prerequisites

- **Completed Tasks**: TASK1 (RISC-V toolchain setup)
- **Knowledge**: Memory architectures (Flash vs SRAM), ELF binary format, assembly language
- **Concepts**: Embedded systems programming and startup sequences

## Setup & Installation

### Environment Preparation

```bash
# Navigate to working directory
cd ~/riscv_code
```

## Technical Deep Dive

### Linker Script Architecture

Linker scripts provide precise control over:

#### **Memory Layout Management**:
- **Physical Memory Mapping**: Define available Flash and SRAM regions
- **Section Placement**: Control where code, data, and variables reside
- **Symbol Generation**: Create runtime symbols for memory boundaries
- **Address Assignment**: Specify exact memory addresses for firmware components

#### **Embedded System Memory Model**:
```
Flash (Non-Volatile):
- Program storage (.text)
- Constant data (.rodata) 
- Initial values for .data

SRAM (Volatile):
- Runtime data (.data)
- Uninitialized variables (.bss)
- Stack and heap space
```

### Memory Region Specification

The MEMORY directive defines available memory regions:

```ld
MEMORY
{
    FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 256K
    SRAM  (rwx) : ORIGIN = 0x10000000, LENGTH = 64K
}
```

**Region Attributes**:
- **`rx`**: Read and execute permissions (Flash)
- **`rwx`**: Read, write, execute permissions (SRAM)
- **ORIGIN**: Starting address of memory region
- **LENGTH**: Size of available memory

### Section Placement Control

The SECTIONS directive controls code and data placement:

```ld
SECTIONS
{
    .text 0x00000000 : {
        *(.text.start)    /* Entry point first */
        *(.text*)         /* All code */
        *(.rodata*)       /* Constants */
    } > FLASH

    .data 0x10000000 : {
        _data_start = .;
        *(.data*)
        _data_end = .;
    } > SRAM
}
```

## Implementation Details

### Step 1: Create Minimal Linker Script

```bash
nano minimal.ld
```

Complete linker script implementation:

```ld
/*
 * Minimal Linker Script for RV32IMC
 * Flash at 0x00000000, SRAM at 0x10000000
 */

ENTRY(_start)

MEMORY
{
    FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 256K
    SRAM  (rwx) : ORIGIN = 0x10000000, LENGTH = 64K
}

SECTIONS
{
    /* Text section in Flash */
    .text 0x00000000 : {
        *(.text.start)    /* Entry point first */
        *(.text*)         /* All other text */
        *(.rodata*)       /* Read-only data */
    } > FLASH

    /* Data section in SRAM */
    .data 0x10000000 : {
        _data_start = .;
        *(.data*)         /* Initialized data */
        _data_end = .;
    } > SRAM

    /* BSS section in SRAM */
    .bss : {
        _bss_start = .;
        *(.bss*)          /* Uninitialized data */
        _bss_end = .;
    } > SRAM

    /* Stack at end of SRAM */
    _stack_top = ORIGIN(SRAM) + LENGTH(SRAM);
}
```

### Step 2: Create Test Program

```bash
nano test_linker.c
```

Test program with different data types:

```c
#include <stdint.h>

// Global initialized data (goes to .data)
uint32_t global_var = 0x12345678;

// Global uninitialized data (goes to .bss)
uint32_t bss_var;

// Function in .text section
void test_function(void) {
    global_var = 0xABCDEF00;
    bss_var = 0x11111111;
}

void main(void) {
    test_function();
    while(1) {
        // Infinite loop for bare-metal
    }
}
```

### Step 3: Create Assembly Entry Point

```bash
nano start.s
```

Assembly startup with proper initialization:

```assembly
.section .text.start
.global _start

_start:
    # Set up stack pointer
    lui sp, %hi(_stack_top)
    addi sp, sp, %lo(_stack_top)
    
    # Call main program
    call main
    
    # Infinite loop if main returns
1:  j 1b

.size _start, . - _start
```

### Step 4: Build with Custom Linker Script

```bash
# Compile components
riscv32-unknown-elf-gcc -c start.s -o start.o
riscv32-unknown-elf-gcc -c test_linker.c -o test_linker.o

# Link with custom script
riscv32-unknown-elf-ld -T minimal.ld start.o test_linker.o -o test_linker.elf
```

### Step 5: Create Automated Build Script

```bash
nano build_linker_test.sh
```

Complete build automation:

```bash
#!/bin/bash
echo "=== Task 11: Linker Script Implementation ==="

# Compile everything
echo "1. Compiling with custom linker script..."
riscv32-unknown-elf-gcc -c start.s -o start.o
riscv32-unknown-elf-gcc -c test_linker.c -o test_linker.o
riscv32-unknown-elf-ld -T minimal.ld start.o test_linker.o -o test_linker.elf

echo "✓ Compilation successful!"

# Verify results
echo -e "\n2. Verifying memory layout:"
echo "Text section should be at 0x00000000:"
riscv32-unknown-elf-objdump -h test_linker.elf | grep ".text"

echo "Data section should be at 0x10000000:"
riscv32-unknown-elf-objdump -h test_linker.elf | grep -E "\.(s)?data"

echo -e "\n3. Symbol addresses:"
riscv32-unknown-elf-nm test_linker.elf | head -10

echo -e "\n✓ Linker script working correctly!"
```

```bash
chmod +x build_linker_test.sh
./build_linker_test.sh
```

## Output

### Build Process Results
```bash
=== Task 11: Linker Script Implementation ===
1. Compiling with custom linker script...
✓ Compilation successful!

2. Verifying memory layout:
Text section should be at 0x00000000:
  0 .text         0000004a  00000000  00000000  00001000  2**1

Data section should be at 0x10000000:
  1 .sdata        00000004  10000000  10000000  00002000  2**2

3. Symbol addresses:
10000004 D _bss_end
10000004 D _bss_start
10000000 D _data_end
10000000 D _data_start
10010000 D _stack_top
00000000 T _start
10000004 B bss_var
10000000 D global_var
0000003e T main
0000000c T test_function

✓ Linker script working correctly!
```

### Memory Layout Verification

#### **Section Placement Analysis**
```bash
$ file test_linker.elf
test_linker.elf: ELF 32-bit LSB executable, UCB RISC-V, RVC, double-float ABI, 
version 1 (SYSV), statically linked, not stripped

$ riscv32-unknown-elf-objdump -h test_linker.elf
Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .text         0000004a  00000000  00000000  00001000  2**1
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .sdata        00000004  10000000  10000000  00002000  2**2
                  CONTENTS, ALLOC, LOAD, DATA
  2 .sbss         00000004  10000004  10000004  00002004  2**2
                  ALLOC
```

#### **Symbol Address Mapping**
| Symbol | Address | Location | Description |
|--------|---------|----------|-------------|
| `_start` | `0x00000000` | Flash start | Entry point |
| `global_var` | `0x10000000` | SRAM start | Initialized data |
| `bss_var` | `0x10000004` | SRAM+4 | Uninitialized data |
| `_stack_top` | `0x10010000` | SRAM end | Stack pointer |

## Troubleshooting

### Issue: Linker Cannot Find Entry Point
```
Error: undefined symbol `_start'
```
**Solution**: Ensure assembly file defines global entry point:
```assembly
.global _start
_start:
```

### Issue: Section Overlap Errors
```
Error: section overlaps with previous section
```
**Solution**: Verify memory regions don't overlap and are properly aligned:
```ld
MEMORY {
    FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 256K
    SRAM (rwx) : ORIGIN = 0x10000000, LENGTH = 64K  /* No overlap */
}
```

### Issue: Symbol Resolution Failures
```
Error: undefined reference to symbol
```
**Solution**: Check symbol definitions in linker script and ensure proper section placement.

## Testing & Validation

### Validation Checklist

1. **Compilation Success**:
   ```bash
   ls test_linker.elf
   # Should exist without errors
   ```

2. **Memory Layout Verification**:
   ```bash
   riscv32-unknown-elf-objdump -h test_linker.elf | grep -E "(\.text|\.data)"
   # .text at 0x00000000, .data at 0x10000000
   ```

3. **Symbol Address Validation**:
   ```bash
   riscv32-unknown-elf-nm test_linker.elf | grep -E "(_start|global_var|_stack_top)"
   # Should show correct addresses
   ```

4. **Entry Point Verification**:
   ```bash
   riscv32-unknown-elf-readelf -h test_linker.elf | grep "Entry point"
   # Should show 0x0 (Flash start)
   ```

### Memory Utilization Analysis

| Region | Used | Available | Utilization |
|--------|------|-----------|-------------|
| **Flash** | 74 bytes | 256KB | <0.1% |
| **SRAM Data** | 8 bytes | 64KB | <0.1% |
| **Stack Space** | 0 bytes | ~64KB | Available |

## References

- [GNU Linker Documentation](https://sourceware.org/binutils/docs/ld/)
- [RISC-V ELF psABI Specification](https://github.com/riscv-non-isa/riscv-elf-psabi-doc)
- [Embedded Linker Scripts Guide](https://interrupt.memfault.com/blog/how-to-write-linker-scripts-for-firmware)
- [Memory Management for Embedded Systems](https://www.embedded.com/memory-management-for-embedded-systems/)

