# RISC-V Inline Assembly Programming

Integrate inline assembly within C code for RISC-V architecture, focusing on constraint syntax and register usage.

## Objective

Demonstrate the integration of inline assembly within C code for RISC-V architecture, focusing on constraint syntax, volatile keyword usage, and proper assembly code generation to bridge high-level C programming with low-level hardware control.

## Key Learning Outcomes

- Master RISC-V inline assembly syntax and constraints
- Understand input/output constraint mechanisms (`"=r"`, `"r"`)
- Learn volatile keyword importance for hardware operations
- Practice assembly template syntax (`%0`, `%1`, `%2`)
- Gain proficiency in mixed C/assembly programming
- Analyze generated assembly with `#APP`/`#NO_APP` markers

## Prerequisites

- **Completed Tasks**: TASK1 (RISC-V toolchain setup)
- **Knowledge**: RISC-V assembly language, C programming, compiler optimization
- **Environment**: WSL with build capabilities

## Setup & Installation

### Environment Preparation

```bash
# Navigate to working directory
cd ~/riscv_code
```

## Technical Deep Dive

### Inline Assembly Architecture

Inline assembly in GCC provides a mechanism to embed assembly instructions directly within C code while maintaining type safety and register allocation. For RISC-V, this enables:

- **Direct Hardware Access**: CSR reads, memory-mapped I/O operations
- **Performance Optimization**: Critical code paths with hand-optimized assembly
- **Constraint-Based Integration**: Compiler manages register allocation automatically
- **Volatile Semantics**: Prevents unwanted compiler optimizations

### RISC-V Constraint System

The constraint system defines how C variables map to assembly operands:

#### **Output Constraints (`"=r"`)**:
- **`=`**: Write-only output (result written to this operand)
- **`r`**: General-purpose register allocation
- **Combined**: Compiler selects available register for output

#### **Input Constraints (`"r"`)**:
- **`r`**: Read-only input from general-purpose register
- **Compiler managed**: Automatic register selection and data movement

#### **Template Syntax**:
- **`%0`**: First operand (typically output)
- **`%1`**: Second operand (first input)
- **`%2`**: Third operand (second input)

## Implementation Details

### Step 1: Create Inline Assembly Demonstration

```bash
nano task9_inline_assembly.c
```

Implementation includes three demonstration functions:

#### **Function 1: Register Move Operation**
```c
static inline uint32_t rdcycle_demo(void) {
    uint32_t c = 12345;
    asm volatile ("mv %0, %0" : "=r"(c) : "r"(c));
    return c;
}
```

#### **Function 2: Arithmetic Inline Assembly**
```c
static inline uint32_t add_inline(uint32_t a, uint32_t b) {
    uint32_t result;
    asm volatile ("add %0, %1, %2" 
        : "=r"(result)     // Output constraint
        : "r"(a), "r"(b)   // Input constraints
    );
    return result;
}
```

#### **Function 3: Volatile Keyword Demonstration**
```c
static inline uint32_t demo_volatile(uint32_t input) {
    uint32_t output;
    asm volatile ("slli %0, %1, 1"  // Shift left logical immediate
        : "=r"(output)
        : "r"(input)
    );
    return output;
}
```

### Step 2: Compilation and Analysis

```bash
# Compile the inline assembly program
riscv32-unknown-elf-gcc -o task9_inline.elf task9_inline_assembly.c

# Generate assembly to analyze inline integration
riscv32-unknown-elf-gcc -S task9_inline_assembly.c

# Verify inline assembly markers
grep -A 5 -B 5 "#APP\|#NO_APP" task9_inline_assembly.s
```

### Step 3: Execution and Validation

```bash
# Test with QEMU user-mode emulation
qemu-riscv32-static task9_inline.elf
```

## Output

### Program Execution Results
```
=== Task 9: Inline Assembly Basics ===
CSR 0xC00 (cycle counter) inline assembly demo

Simulated cycle count: 12345
15 + 25 = 40 (using inline assembly)
5 << 1 = 10 (using volatile inline assembly)

=== Constraint Explanations ===
"=r"(output) - Output constraint:
  '=' means write-only (output)
  'r' means general-purpose register

"r"(input) - Input constraint:
  'r' means general-purpose register (read)

'volatile' keyword:
  Prevents compiler optimization
  Ensures assembly code is not removed
  Required for CSR reads and hardware operations
```

### Assembly Generation Analysis
```assembly
# Inline assembly markers in generated code
#APP
# 8 "task9_inline_assembly.c" 1
        mv a5, a5
# 0 "" 2
#NO_APP

#APP
# 15 "task9_inline_assembly.c" 1
        add a5, a5, a4
# 0 "" 2
#NO_APP

#APP
# 26 "task9_inline_assembly.c" 1
        slli a5, a5, 1
# 0 "" 2
#NO_APP
```

## Troubleshooting

### Issue: Compilation Errors with Constraints
```
Error: impossible constraint in 'asm'
```
**Solution**: Verify constraint syntax matches RISC-V register capabilities.
```bash
# Use general register constraints for RISC-V
asm volatile ("add %0, %1, %2" : "=r"(result) : "r"(a), "r"(b));
```

### Issue: Assembly Code Not Generated
```
Warning: inline assembly optimized away
```
**Solution**: Use `volatile` keyword to prevent optimization:
```c
asm volatile ("instruction" : constraints);
```

### Issue: Register Allocation Conflicts
```
Error: can't find a register in class 'GENERAL_REGS'
```
**Solution**: Simplify constraints or reduce register pressure in surrounding code.

## Testing & Validation

### Validation Checklist

1. **Compilation Success**:
   ```bash
   ls task9_inline.elf
   # Should exist and be executable
   ```

2. **Assembly Marker Verification**:
   ```bash
   grep -c "#APP" task9_inline_assembly.s
   # Should return 3 (three inline assembly blocks)
   ```

3. **Execution Test**:
   ```bash
   qemu-riscv32-static task9_inline.elf | grep "15 + 25 = 40"
   # Should confirm arithmetic inline assembly works
   ```

4. **Volatile Effectiveness**:
   ```bash
   # Compare optimized vs unoptimized builds
   riscv32-unknown-elf-gcc -O2 -S task9_inline_assembly.c -o optimized.s
   grep -c "slli" optimized.s  # Should still contain shift instruction
   ```

## References

- [GCC Inline Assembly Documentation](https://gcc.gnu.org/onlinedocs/gcc/Using-Assembly-Language-with-C.html)
- [RISC-V Assembly Programming Manual](https://github.com/riscv-non-isa/riscv-asm-manual)
- [RISC-V Instruction Set Manual](https://riscv.org/specifications/)
- [GCC RISC-V Constraints](https://gcc.gnu.org/onlinedocs/gccint/Constraints.html)

