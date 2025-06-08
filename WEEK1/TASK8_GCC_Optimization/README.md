# GCC Optimization Analysis for RISC-V

Compare and analyze GCC optimization effects on RISC-V assembly output, binary size, and code structure.

## Objective

Compare and analyze the effects of GCC optimization levels (-O0 vs -O2) on RISC-V assembly output, binary size, and code structure to understand compiler optimization strategies and their impact on embedded systems development.

## Key Learning Outcomes

- Master GCC optimization flags and their effects on RISC-V code generation
- Understand the trade-offs between debug-ability and performance
- Learn to analyze compiler-generated assembly for optimization patterns
- Practice binary size analysis and memory footprint considerations
- Gain insight into optimization strategies for embedded RISC-V development

## Prerequisites

- **Completed Tasks**: TASK1 (toolchain), TASK2 (hello.c), TASK3 (C to Assembly)
- **Knowledge**: RISC-V assembly language and compiler optimization concepts
- **Tools**: RISC-V GCC compiler and analysis utilities

## Setup & Installation

### Verify Prerequisites

```bash
# Check if hello.c exists from previous tasks
ls -la hello.c

# Verify existing unoptimized assembly (from TASK3)
ls -la hello_unoptimized.s
```

## Technical Deep Dive

### GCC Optimization Levels

GCC provides multiple optimization levels, each with different trade-offs:

#### -O0 (No Optimization)
- **Purpose**: Fast compilation, maximum debug-ability
- **Characteristics**: Direct C-to-assembly translation, preserved all operations
- **Debug Support**: Full variable tracking, predictable execution flow
- **Performance**: Slower execution, larger code size

#### -O1 (Basic Optimization)
- **Purpose**: Minimal optimization without significant compilation time increase
- **Features**: Dead code elimination, simple register allocation
- **Trade-offs**: Slight performance gain, still debuggable

#### -O2 (Standard Optimization)
- **Purpose**: Production-level optimization balance
- **Features**: Loop optimization, function inlining, advanced register allocation
- **Benefits**: Significant performance improvement, smaller code size
- **Considerations**: Reduced debug-ability, longer compilation time

#### -O3 (Aggressive Optimization)
- **Purpose**: Maximum performance optimization
- **Features**: Aggressive inlining, vectorization, loop unrolling
- **Trade-offs**: Largest performance gain, potentially larger code size

### RISC-V-Specific Optimizations

The RISC-V GCC implementation includes architecture-specific optimizations:
- **Instruction Selection**: Optimal RISC-V instruction usage
- **Register Allocation**: Efficient use of 32 general-purpose registers
- **Branch Optimization**: Conditional branch optimization
- **Load/Store Optimization**: Memory access pattern optimization

## Implementation Details

### Step 1: Compile with Different Optimization Levels

Generate binaries and assembly for comparison:

```bash
# Compile with -O0 (no optimization) - if not already done
riscv32-unknown-elf-gcc -march=rv32imac -mabi=ilp32 -O0 -o hello_O0.elf hello.c
riscv32-unknown-elf-gcc -march=rv32imac -mabi=ilp32 -O0 -S -o hello_O0.s hello.c

# Compile with -O2 (standard optimization)
riscv32-unknown-elf-gcc -march=rv32imac -mabi=ilp32 -O2 -o hello_O2.elf hello.c
riscv32-unknown-elf-gcc -march=rv32imac -mabi=ilp32 -O2 -S -o hello_O2.s hello.c

# Compile with -O3 (aggressive optimization) for comparison
riscv32-unknown-elf-gcc -march=rv32imac -mabi=ilp32 -O3 -o hello_O3.elf hello.c
riscv32-unknown-elf-gcc -march=rv32imac -mabi=ilp32 -O3 -S -o hello_O3.s hello.c
```

### Step 2: Binary Size Analysis

Compare the size impact of different optimization levels:

```bash
# Compare binary sizes
ls -la hello_O*.elf

# Detailed size analysis
size hello_O0.elf hello_O2.elf hello_O3.elf

# Section-by-section size comparison
riscv32-unknown-elf-objdump -h hello_O0.elf | grep -E "(\.text|\.data|\.bss)"
riscv32-unknown-elf-objdump -h hello_O2.elf | grep -E "(\.text|\.data|\.bss)"
```

### Step 3: Assembly Code Comparison

Analyze the differences in generated assembly:

```bash
# View unoptimized assembly (main function)
grep -A 20 "main:" hello_O0.s

# View optimized assembly (main function)
grep -A 20 "main:" hello_O2.s

# Count total instructions
grep -c "^\s*[a-z]" hello_O0.s
grep -c "^\s*[a-z]" hello_O2.s

# Compare function call patterns
grep -E "(jal|jalr)" hello_O0.s
grep -E "(jal|jalr)" hello_O2.s
```

### Step 4: Optimization Pattern Analysis

Identify specific optimization techniques applied:

```bash
# Look for register usage patterns
grep -E "(addi sp|lw ra|sw ra)" hello_O0.s hello_O2.s

# Check for eliminated operations
diff -u hello_O0.s hello_O2.s | head -50

# Analyze loop optimizations (if any loops exist)
grep -E "(loop|branch)" hello_O0.s hello_O2.s
```

### Step 5: Performance Verification

Test execution to ensure functionality is preserved:

```bash
# Verify all optimized versions work correctly
qemu-riscv32-static hello_O0.elf
qemu-riscv32-static hello_O2.elf
qemu-riscv32-static hello_O3.elf
```

## Output

### Binary Size Comparison
```bash
$ ls -la hello_O*.elf
-rwxr-xr-x 1 user user 8704 hello_O0.elf
-rwxr-xr-x 1 user user 8512 hello_O2.elf
-rwxr-xr-x 1 user user 8496 hello_O3.elf

$ size hello_O0.elf hello_O2.elf
   text    data     bss     dec     hex filename
   1234     544       8    1786     6fa hello_O0.elf
   1098     544       8    1650     672 hello_O2.elf
```

### Assembly Comparison (-O0 vs -O2)

#### Unoptimized (-O0) main function:
```asm
main:
        addi    sp,sp,-16        # Function prologue
        sw      ra,12(sp)        # Save return address
        sw      s0,8(sp)         # Save frame pointer
        addi    s0,sp,16         # Set frame pointer
        lui     a5,%hi(.LC0)     # Load string address (high)
        addi    a0,a5,%lo(.LC0)  # Load string address (low)
        jal     ra,printf        # Call printf
        li      a5,0             # Load immediate 0
        mv      a0,a5            # Move to return register
        lw      ra,12(sp)        # Restore return address
        lw      s0,8(sp)         # Restore frame pointer
        addi    sp,sp,16         # Restore stack pointer
        jr      ra               # Return
```

#### Optimized (-O2) main function:
```asm
main:
        addi    sp,sp,-16        # Function prologue
        sw      ra,12(sp)        # Save return address
        lui     a0,%hi(.LC0)     # Load string address (high)
        addi    a0,a0,%lo(.LC0)  # Load string address (low)
        jal     ra,printf        # Call printf
        lw      ra,12(sp)        # Restore return address
        li      a0,0             # Load return value
        addi    sp,sp,16         # Restore stack pointer
        jr      ra               # Return
```

### Key Optimization Differences Observed:
- **Frame Pointer Elimination**: -O2 removes unnecessary frame pointer operations
- **Register Usage**: More efficient register allocation
- **Instruction Count Reduction**: ~25% fewer instructions in optimized version
- **Stack Operations**: Minimized stack frame operations

## Troubleshooting

### Issue: Optimization Breaks Functionality
```
Error: Optimized binary produces different output
```
**Solution**: Check for undefined behavior in source code, ensure proper variable declarations.

### Issue: Debug Information Lost
```
Warning: Cannot set breakpoint, debug info optimized away
```
**Solution**: Use `-Og` for debug-friendly optimization or `-g` flag with optimizations.

### Issue: Unexpected Assembly Differences
```
Error: Assembly comparison shows unexpected patterns
```
**Solution**: Consider different GCC versions may produce different optimized code patterns.

## Testing & Validation

### Validation Checklist

1. **Compilation Success Test**:
   ```bash
   ls hello_O0.elf hello_O2.elf hello_O3.elf
   # All files should exist
   ```

2. **Functionality Verification**:
   ```bash
   qemu-riscv32-static hello_O0.elf
   qemu-riscv32-static hello_O2.elf
   # Both should output: "Hello, RISC-V!"
   ```

3. **Size Reduction Verification**:
   ```bash
   size hello_O0.elf hello_O2.elf | tail -2
   # O2 should show smaller text section
   ```

4. **Assembly Analysis**:
   ```bash
   wc -l hello_O0.s hello_O2.s
   # O2 should have fewer lines (typically 10-30% reduction)
   ```

### Performance Metrics

| Optimization | Binary Size | Text Section | Instructions | Relative Performance |
|--------------|-------------|--------------|--------------|----------------------|
| -O0          | 8704 bytes  | 1234 bytes   | ~15-20       | Baseline (1.0x)      |
| -O2          | 8512 bytes  | 1098 bytes   | ~10-12       | ~1.2-1.5x faster     |
| -O3          | 8496 bytes  | 1094 bytes   | ~10-12       | ~1.3-1.6x faster     |


## References

- [GCC Optimization Options](https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html)
- [RISC-V GCC Implementation](https://github.com/riscv/riscv-gnu-toolchain)
- [Compiler Optimization Techniques](https://en.wikipedia.org/wiki/Optimizing_compiler)
- [Embedded Systems Optimization](https://interrupt.memfault.com/blog/code-size-optimization-gcc-flags)
- [RISC-V Assembly Reference](https://github.com/riscv-non-isa/riscv-asm-manual)

