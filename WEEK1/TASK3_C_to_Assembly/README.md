# C to Assembly Code Generation and Analysis

Generate and analyze RISC-V assembly code from C source using GCC compiler.

## Objective

Generate human-readable RISC-V assembly code from C source, analyze instruction sequences, function prologue/epilogue patterns, and understand the translation process from high-level C constructs to low-level RISC-V machine instructions.

## Key Learning Outcomes

- Assembly code generation workflow and compiler phases
- RISC-V instruction set architecture and encoding
- Function calling conventions and stack frame management
- Register allocation and usage patterns
- Assembly directive interpretation and linker interaction

## Prerequisites

- **Completed Tasks**: Task 1 (Toolchain Setup), Task 2 (Cross-Compilation)
- **Source File**: `hello.c` from previous task
- **Toolchain**: RISC-V GCC 15.1.0 with assembly generation support
- **Knowledge**: Basic understanding of assembly language concepts

## Setup & Installation

### Verify Source File Availability

```bash
# Ensure working directory and source file exist
cd ~/riscv_code
ls -la hello.c hello.elf
```

### Required Tools Verification

```bash
# Verify GCC assembly generation capability
riscv32-unknown-elf-gcc --help | grep "\-S"
```

## Technical Deep Dive

### Assembly Generation Process

The GCC compilation pipeline for assembly generation:

1. **Preprocessing**: Macro expansion and header inclusion
2. **Parsing**: Syntax analysis and AST generation  
3. **Optimization**: Code transformation and optimization passes
4. **Code Generation**: Target-specific instruction selection
5. **Assembly Output**: Human-readable assembly code production

### RISC-V Assembly Structure

```assembly
# Assembler directives
.file   "hello.c"
.option nopic
.attribute arch, "rv32i2p1_m2p0_a2p1_f2p2_d2p2_c2p0..."

# Data section
.section .rodata
.LC0:
    .string "Hello, RISC-V!"

# Text section  
.text
.globl main
main:
    # Function implementation
```

### Instruction Set Architecture Features

- **RV32IMAFDC**: Base + Extensions (Integer, Multiplication, Atomic, Float, Double, Compressed)
- **Two-instruction addressing**: `lui` + `addi` for 32-bit address construction
- **Compressed instructions**: 16-bit encodings for common operations
- **Stack alignment**: 16-byte aligned stack frames per ABI

## Implementation Details

### Assembly Code Generation

```bash
# Generate assembly with no optimization for clarity
riscv32-unknown-elf-gcc -S -O0 hello.c

# Verify assembly file creation
ls -la hello.s
file hello.s
```

### Assembly Analysis Commands

```bash
# View complete assembly output
cat hello.s

# Display with line numbers for reference
nl hello.s

# Count total lines in assembly
wc -l hello.s

# Extract main function for focused analysis
grep -A 20 "main:" hello.s
```

### Function Structure Analysis

```bash
# Examine function prologue pattern
grep -A 5 "main:" hello.s

# Analyze register usage patterns
grep -E "(sp|ra|s0|a0|a5)" hello.s

# Check string constant handling
grep -A 3 ".LC0" hello.s
```

## Expected Output / Analysis Results

### Complete Assembly Output

```assembly
        .file   "hello.c"
        .option nopic
        .attribute arch, "rv32i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_zicsr2p0_zifencei2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zca1p0_zcd1p0_zcf1p0"
        .attribute unaligned_access, 0
        .attribute stack_align, 16
        .text
        .section        .rodata
        .align  2
.LC0:
        .string "Hello, RISC-V!"
        .text
        .align  1
        .globl  main
        .type   main, @function
main:
        addi    sp,sp,-16      # Allocate 16-byte stack frame
        sw      ra,12(sp)      # Save return address
        sw      s0,8(sp)       # Save frame pointer
        addi    s0,sp,16       # Set up frame pointer
        lui     a5,%hi(.LC0)   # Load upper 20 bits of string address
        addi    a0,a5,%lo(.LC0) # Complete address in a0
        call    puts           # Call puts function
        li      a5,0           # Load immediate 0 for return value
        mv      a0,a5          # Move return value to a0
        lw      ra,12(sp)      # Restore return address
        lw      s0,8(sp)       # Restore frame pointer
        addi    sp,sp,16       # Deallocate stack frame
        jr      ra             # Jump to return address
        .size   main, .-main
        .ident  "GCC: () 15.1.0"
        .section        .note.GNU-stack,"",@progbits
```

### Function Analysis Breakdown

#### Architecture Attributes (Line 3)
```assembly
.attribute arch, "rv32i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_zicsr2p0_zifencei2p0..."
```
- **RV32IMAFDC**: Full instruction set with extensions
- **Version Numbers**: Specification version compliance
- **Zicsr/Zifencei**: Control register and fence instruction support

#### Data Section (Lines 7-10)
```assembly
.section .rodata        # Read-only data section
.align  2              # 4-byte alignment
.LC0:                  # Local constant label
    .string "Hello, RISC-V!"  # String literal storage
```

#### Function Prologue (Lines 16-19)
```assembly
main:
    addi sp,sp,-16     # Stack pointer adjustment (16-byte aligned)
    sw   ra,12(sp)     # Save return address at SP+12
    sw   s0,8(sp)      # Save frame pointer at SP+8
    addi s0,sp,16      # Establish new frame pointer
```

#### Function Body (Lines 20-24)
```assembly
    lui  a5,%hi(.LC0)  # Load upper immediate (bits 31:12)
    addi a0,a5,%lo(.LC0) # Add lower immediate (bits 11:0)
    call puts          # Function call (GCC optimized printf to puts)
    li   a5,0          # Load immediate 0
    mv   a0,a5         # Move to return register
```

#### Function Epilogue (Lines 25-28)
```assembly
    lw   ra,12(sp)     # Restore return address
    lw   s0,8(sp)      # Restore frame pointer  
    addi sp,sp,16      # Deallocate stack space
    jr   ra            # Jump to return address
```

### Assembly Statistics

- **Total Lines**: 31 (including directives and metadata)
- **Actual Instructions**: 13 (executable code)
- **File Size**: 603 bytes
- **Register Usage**: sp, ra, s0, a0, a5

## Testing & Validation

### Assembly Verification

```bash
# Verify assembly syntax
riscv32-unknown-elf-as hello.s -o hello_asm.o

# Check object file generation
file hello_asm.o

# Compare with direct compilation
riscv32-unknown-elf-gcc -c hello.c -o hello_gcc.o
ls -la hello_asm.o hello_gcc.o
```

### Expected Validation Results

```bash
$ file hello_asm.o
hello_asm.o: ELF 32-bit LSB relocatable, UCB RISC-V, version 1 (SYSV), not stripped

$ ls -la hello_*.o
-rw-r--r-- 1 mathesh mathesh 2180 Jun  8 06:15 hello_asm.o
-rw-r--r-- 1 mathesh mathesh 2180 Jun  8 06:15 hello_gcc.o
```

### Assembly Quality Metrics

| Metric | Value | Analysis |
|--------|-------|----------|
| **Instructions** | 13 | Minimal overhead |
| **Stack Usage** | 16 bytes | ABI compliant alignment |
| **Register Preservation** | ra, s0 | Proper calling convention |
| **Optimization** | printf→puts | Compiler optimization active |

## Troubleshooting Guide

### Common Assembly Issues

**Issue**: Assembly file not generated
```bash
# Solution: Check compilation command
riscv32-unknown-elf-gcc -S -v hello.c  # Verbose output
```

**Issue**: Unreadable assembly output
```bash
# Solution: Disable optimization for clarity
riscv32-unknown-elf-gcc -S -O0 -fverbose-asm hello.c
```

**Issue**: Missing function labels
```bash
# Solution: Check for function definition
grep -n "main" hello.s
```

### Assembly Analysis Issues

**Issue**: Complex instruction sequences
```bash
# Solution: Use different optimization levels
riscv32-unknown-elf-gcc -S -O1 hello.c -o hello_O1.s
```

## References

- [RISC-V Assembly Programmer's Manual](https://github.com/riscv-non-isa/riscv-asm-manual)
- [GNU GCC Assembly Output Documentation](https://gcc.gnu.org/onlinedocs/gcc/Code-Gen-Options.html)
- [RISC-V Instruction Set Manual](https://riscv.org/technical/specifications/)
- [RISC-V ABI Specification](https://github.com/riscv-non-isa/riscv-elf-psabi-doc)
