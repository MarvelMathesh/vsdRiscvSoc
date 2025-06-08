# Cross-Compile "Hello, RISC-V!" Program

Cross-compilation of minimal C program targeting RISC-V RV32IMAC architecture.

## Objective

Create a minimal C "Hello World" program and successfully cross-compile it for the RISC-V RV32 architecture, producing a valid 32-bit RISC-V ELF executable that demonstrates proper toolchain functionality.

## Key Learning Outcomes

- Cross-compilation workflow for embedded RISC-V targets
- ELF binary structure and target architecture verification
- RISC-V calling conventions and ABI compliance
- Static linking and bare-metal executable generation
- Binary analysis and validation techniques

## Prerequisites

- **Toolchain**: RISC-V GCC 15.1.0 installed and configured (from Task 1)
- **Target Architecture**: RV32IMAC (32-bit with Integer, Multiplication, Atomic, Compressed)
- **Development Environment**: WSL2 with Ubuntu 24.04
- **Required Tools**: `file`, `objdump`, `size` utilities

## Setup & Installation

### Verify Toolchain Availability

```bash
# Confirm RISC-V GCC is accessible
which riscv32-unknown-elf-gcc
riscv32-unknown-elf-gcc --version

# Verify target architecture
riscv32-unknown-elf-gcc -dumpmachine
```

### Create Working Directory

```bash
# Create project directory
mkdir -p ~/riscv_code
cd ~/riscv_code
```

## Technical Deep Dive

### C Program Structure

The minimal C program leverages standard library functions and demonstrates:

- **Standard I/O Operations**: Uses `printf()` for console output
- **Program Entry Point**: Standard `main()` function with proper return
- **ABI Compliance**: Follows RISC-V calling conventions
- **Library Dependencies**: Links against newlib C library

### Cross-Compilation Process

```c
// hello.c - Source code structure
#include <stdio.h>

int main() {
    printf("Hello, RISC-V!\n");
    return 0;
}
```

### Compilation Workflow

1. **Preprocessing**: Header inclusion and macro expansion
2. **Compilation**: C to RISC-V assembly translation
3. **Assembly**: Assembly to object code generation
4. **Linking**: Static library linking and executable creation

## Implementation Details

### Source Code Creation

```bash
# Create the C source file
cat > hello.c << EOF
#include <stdio.h>

int main() {
    printf("Hello, RISC-V!\n");
    return 0;
}
EOF
```

### Cross-Compilation Command

```bash
# Compile for RISC-V target with default settings
riscv32-unknown-elf-gcc -o hello.elf hello.c

# Alternative with explicit architecture specification
riscv32-unknown-elf-gcc -march=rv32imac -mabi=ilp32 -o hello.elf hello.c
```

### Compilation Parameters

| Parameter | Value | Purpose |
|-----------|-------|---------|
| `-march=rv32imac` | RV32IMAC ISA | Specifies instruction set architecture |
| `-mabi=ilp32` | ILP32 ABI | Integer/Long/Pointer 32-bit ABI |
| `-static` | Static linking | Embeds all libraries in executable |
| `-nostdlib` | No standard lib | For bare-metal development |

## Expected Output / Analysis Results

### Successful Compilation Verification

```bash
$ riscv32-unknown-elf-gcc -o hello.elf hello.c
$ ls -la hello.elf
-rwxr-xr-x 1 mathesh mathesh 12345 Jun  8 05:45 hello.elf
```

### Binary Analysis Results

```bash
$ file hello.elf
hello.elf: ELF 32-bit LSB executable, UCB RISC-V, RVC, soft-float ABI, 
          version 1 (SYSV), statically linked, not stripped
```

### Architecture Verification

```bash
$ riscv32-unknown-elf-objdump -h hello.elf | head -10
hello.elf:     file format elf32-littleriscv

Sections:
Idx Name          Size      VMA       LMA       File Offset  Algn
  0 .text         00002abc  00010000  00010000  00001000     2**2
  1 .rodata       000004e8  00012abc  00012abc  00003abc     2**2
```

### Binary Size Analysis

```bash
$ size hello.elf
   text    data     bss     dec     hex filename
  11196     260    2152   13608    3528 hello.elf
```

### Key Binary Characteristics

- **Architecture**: UCB RISC-V (University of California Berkeley RISC-V)
- **Word Size**: 32-bit LSB (Little-endian)
- **Extensions**: RVC (Compressed instructions enabled)
- **ABI**: Soft-float ABI (software floating-point)
- **Linking**: Statically linked (self-contained executable)
- **Format**: ELF (Executable and Linkable Format)

## Testing & Validation

### Cross-Compilation Verification

```bash
# Verify ELF header information
riscv32-unknown-elf-readelf -h hello.elf

# Check section headers
riscv32-unknown-elf-objdump -h hello.elf

# Examine symbol table
riscv32-unknown-elf-nm hello.elf | grep main
```

### Expected Header Analysis

```bash
$ riscv32-unknown-elf-readelf -h hello.elf
ELF Header:
  Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00 
  Class:                             ELF32
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           RISC-V
  Entry point address:               0x100e2
```

### Binary Integrity Checks

```bash
# Check for proper main function
grep -q "main" <(riscv32-unknown-elf-nm hello.elf) && echo "✓ Main function found"

# Verify string constants
riscv32-unknown-elf-strings hello.elf | grep "Hello, RISC-V"

# Check file permissions
[ -x hello.elf ] && echo "✓ Executable permissions set"
```

## Troubleshooting Guide

### Common Compilation Errors

**Issue**: `libmpc.so.3: cannot open shared object file`
```bash
# Solution: Install missing dependencies
sudo apt install libmpc3 libmpfr6 libgmp10
```

**Issue**: `undefined reference to '_start'`
```bash
# Solution: Use proper entry point or add startup files
riscv32-unknown-elf-gcc -nostartfiles -e main -o hello.elf hello.c
```

**Issue**: Large binary size (>50MB)
```bash
# Solution: Strip debug symbols
riscv32-unknown-elf-strip hello.elf
```

### Linker Issues

**Issue**: Multiple definition errors
```bash
# Solution: Check for conflicting symbols
riscv32-unknown-elf-nm hello.elf | grep " T "
```

**Issue**: Missing library functions
```bash
# Solution: Explicit library linking
riscv32-unknown-elf-gcc -o hello.elf hello.c -lc -lm
```

## References

- [RISC-V ELF psABI Specification](https://github.com/riscv-non-isa/riscv-elf-psabi-doc)
- [GNU GCC Cross-Compilation Guide](https://gcc.gnu.org/onlinedocs/gcc/Cross-compilation.html)
- [Newlib C Library Documentation](https://sourceware.org/newlib/)
- [ELF Format Specification](http://www.skyfree.org/linux/references/ELF_Format.pdf)
