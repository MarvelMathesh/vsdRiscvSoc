# TASK 14: RISC-V Atomic Extension Implementation

Implementation of atomic operations and lock-free programming using RISC-V atomic extension instructions.

## Objective

Demonstrate RISC-V atomic extension capabilities by implementing atomic memory operations, lock-free data structures, and multiprocessor synchronization primitives for concurrent programming.

## Key Learning Outcomes

- RISC-V atomic extension instruction set architecture
- Load-Reserved/Store-Conditional (LR/SC) atomic primitive implementation  
- Atomic Memory Operations (AMO) instruction usage and analysis
- Lock-free programming techniques and concurrent data structure design
- Assembly-level atomic instruction generation and verification
- Multiprocessor synchronization and race condition prevention

## Prerequisites

- RISC-V cross-compilation toolchain with RV32IMAC support
- Understanding of memory operations and concurrency concepts
- Basic assembly language and inline assembly syntax knowledge

## Setup & Installation

### Required Tools
```bash
# Verify atomic extension support
riscv32-unknown-elf-gcc --target-help | grep -i atomic

# Check RV32IMAC architecture support
riscv32-unknown-elf-gcc -march=rv32imac -v
```

## Technical Deep Dive

### RISC-V Atomic Extension Architecture

The atomic extension adds two categories of atomic instructions:

| Category | Instructions | Purpose |
|----------|-------------|---------|
| **Load-Reserved/Store-Conditional** | `lr.w`, `sc.w` | Lock-free atomic sequences |
| **Atomic Memory Operations** | `amoadd.w`, `amoswap.w`, etc. | Single-instruction read-modify-write |

### Atomic Instruction Set

#### Load-Reserved/Store-Conditional
- **lr.w rd, (rs1)**: Load-reserved word, sets reservation on memory address
- **sc.w rd, rs2, (rs1)**: Store-conditional word, succeeds only if reservation valid

#### Atomic Memory Operations
- **amoadd.w**: Atomic add operation returning previous value
- **amoswap.w**: Atomic swap operation  
- **amoand.w/amoor.w/amoxor.w**: Atomic bitwise operations
- **amomin.w/amomax.w**: Atomic minimum/maximum operations

### Race Condition Prevention

**Without Atomics (Race Condition):**
```c
// Thread 1          Thread 2
temp = counter;      temp = counter;    // Both read same value  
temp = temp + 1;     temp = temp + 1;   // Both increment
counter = temp;      counter = temp;    // Lost update!
```

**With Atomics (Race-Free):**
```c
old_value = atomic_add(&counter, 1);  // Atomic read-modify-write
```

## Implementation Details

### Core Atomic Operations Implementation

```c
// Load-Reserved/Store-Conditional atomic increment
void atomic_increment_lr_sc(volatile uint32_t *counter) {
    uint32_t old_value, result;
    
    do {
        old_value = atomic_load_reserved(counter);
        result = atomic_store_conditional(counter, old_value + 1);
    } while (result != 0);  // Retry if store-conditional failed
}

// Atomic Memory Operations
static inline uint32_t atomic_add(volatile uint32_t *addr, uint32_t value) {
    uint32_t result;
    asm volatile ("amoadd.w %0, %2, (%1)" 
                  : "=r"(result) 
                  : "r"(addr), "r"(value) 
                  : "memory");
    return result;  // Returns old value
}
```

### Spinlock Implementation
```c
void acquire_lock(volatile uint32_t *lock) {
    while (atomic_swap(lock, 1) != 0) {
        // Spin until lock is acquired (old value was 0)
    }
}

void release_lock(volatile uint32_t *lock) {
    atomic_swap(lock, 0);  // Release lock
}
```

## Step-by-Step Implementation

### Step 1: Create Atomic Operations Demo
```bash
# Create comprehensive atomic operations demonstration
cat << 'EOF' > task14_atomic_demo.c
#include <stdint.h>

volatile uint32_t shared_counter = 0;
volatile uint32_t lock_variable = 0;

// Atomic Load-Reserved / Store-Conditional operations
static inline uint32_t atomic_load_reserved(volatile uint32_t *addr) {
    uint32_t result;
    asm volatile ("lr.w %0, (%1)" : "=r"(result) : "r"(addr) : "memory");
    return result;
}

static inline uint32_t atomic_store_conditional(volatile uint32_t *addr, uint32_t value) {
    uint32_t result;
    asm volatile ("sc.w %0, %2, (%1)" : "=r"(result) : "r"(addr), "r"(value) : "memory");
    return result;  // 0 = success, 1 = failure
}

// Atomic Memory Operations (AMO)
static inline uint32_t atomic_add(volatile uint32_t *addr, uint32_t value) {
    uint32_t result;
    asm volatile ("amoadd.w %0, %2, (%1)" : "=r"(result) : "r"(addr), "r"(value) : "memory");
    return result;  // Returns old value
}

// Lock-free increment using Load-Reserved/Store-Conditional
void atomic_increment_lr_sc(volatile uint32_t *counter) {
    uint32_t old_value, result;
    
    do {
        old_value = atomic_load_reserved(counter);
        result = atomic_store_conditional(counter, old_value + 1);
    } while (result != 0);  // Retry if store-conditional failed
}

int main() {
    // Demonstrate atomic operations
    atomic_add(&shared_counter, 5);
    atomic_increment_lr_sc(&shared_counter);
    
    return 0;
}
EOF
```

### Step 2: Create Assembly Startup Code
```bash
cat << 'EOF' > atomic_start.s
.section .text.start
.global _start

_start:
    # Set up stack pointer
    lui sp, %hi(_stack_top)
    addi sp, sp, %lo(_stack_top)
    
    # Call main program
    call main
    
    # Infinite loop
1:  j 1b

.size _start, . - _start
EOF
```

### Step 3: Create Linker Script
```bash
cat << 'EOF' > atomic.ld
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

    _stack_top = ORIGIN(SRAM) + LENGTH(SRAM);
}
EOF
```

### Step 4: Compile with Atomic Extension
```bash
# Compile with RV32IMAC (includes atomic extension)
riscv32-unknown-elf-gcc -march=rv32imac -c atomic_start.s -o atomic_start.o
riscv32-unknown-elf-gcc -march=rv32imac -c task14_atomic_demo.c -o task14_atomic_demo.o

# Link the atomic operations program
riscv32-unknown-elf-ld -T atomic.ld atomic_start.o task14_atomic_demo.o -o task14_atomic_demo.elf
```

### Step 5: Analyze Generated Atomic Instructions
```bash
# Generate assembly to verify atomic instructions
riscv32-unknown-elf-gcc -march=rv32imac -S task14_atomic_demo.c

# Check for atomic instructions in generated assembly
grep -E "(lr\.w|sc\.w|amoadd|amoswap|amoand|amoor)" task14_atomic_demo.s
```

## Output

### Successful Compilation
```bash
task14_atomic_demo.elf: ELF 32-bit LSB executable, UCB RISC-V, RVC, soft-float ABI
```

### Generated Atomic Instructions
```assembly
lr.w    t0, (a0)          # Load-reserved
sc.w    t1, t2, (a0)      # Store-conditional
amoadd.w t0, t1, (a0)     # Atomic add
amoswap.w t0, t1, (a0)    # Atomic swap
```

### Verification Commands
```bash
# Verify atomic extension is used
riscv32-unknown-elf-objdump -d task14_atomic_demo.elf | grep -E "lr\.w|sc\.w|amo"

# Check symbol table
riscv32-unknown-elf-nm task14_atomic_demo.elf | grep -E "atomic|shared"
```

## Troubleshooting

### Common Issues

1. **"Unrecognized instruction" errors**
   - Ensure using `-march=rv32imac` (not rv32imc)
   - Verify toolchain supports atomic extension

2. **Linking errors with atomic operations**
   - Check that all object files compiled with same architecture
   - Verify linker script memory layout is correct

3. **Assembly syntax errors**
   - Ensure proper constraint usage in inline assembly
   - Check memory barrier ("memory") is included

### Debugging Commands
```bash
# Check architecture support
riscv32-unknown-elf-gcc -march=rv32imac -v 2>&1 | grep -i atomic

# Verify ELF file architecture
riscv32-unknown-elf-readelf -h task14_atomic_demo.elf | grep Flags
```

## Testing & Validation

### Validation Checklist
- [ ] Program compiles successfully with RV32IMAC
- [ ] Generated assembly contains atomic instructions (lr.w, sc.w, amo*)
- [ ] ELF file shows correct RISC-V architecture flags
- [ ] Symbol table contains atomic function symbols
- [ ] Disassembly shows proper atomic instruction encoding

### Verification Commands
```bash
# Complete verification script
echo "=== TASK14 Verification ==="
file task14_atomic_demo.elf
riscv32-unknown-elf-objdump -d task14_atomic_demo.elf | grep -E "lr\.w|sc\.w|amo" | wc -l
echo "Atomic instructions found: $(riscv32-unknown-elf-objdump -d task14_atomic_demo.elf | grep -E 'lr\.w|sc\.w|amo' | wc -l)"
```

