# TASK 15: Two-Thread Mutex with RISC-V LR/SC

Implementation of mutex synchronization using Load-Reserved/Store-Conditional atomic instructions.

## Objective

Implement two-thread mutex using Load-Reserved/Store-Conditional (LR/SC) atomic instructions on RV32, demonstrating spinlock-based mutual exclusion mechanisms with proper critical section protection.

## Key Learning Outcomes

- Load-Reserved/Store-Conditional (LR/SC) atomic primitive implementation
- Spinlock mutex design using atomic instructions
- Critical section protection and mutual exclusion techniques
- Race condition prevention through atomic operations
- Assembly optimization for high-performance synchronization
- Lock contention handling and performance analysis

## Prerequisites

- RISC-V cross-compilation toolchain with RV32IMAC support
- Understanding of concurrency concepts and mutex theory
- Knowledge of inline assembly syntax and memory barriers

## Setup & Installation

### Project Structure

```
mutex_project/
├── task15_complete_mutex.c      # Single-file complete solution
├── mutex_start.s                # Assembly startup code
├── mutex.ld                     # Linker script for mutex programs
└── build_mutex_demo.sh          # Complete build and test script
```

## Technical Deep Dive

### Load-Reserved/Store-Conditional Mechanism

#### LR/SC Operation Sequence
1. **lr.w rd, (rs1)**: Load word from memory address and set reservation
2. **sc.w rd, rs2, (rs1)**: Store word conditionally if reservation still valid
3. **Return Value**: sc.w returns 0 on success, 1 on failure

#### Atomic Spinlock Algorithm
```c
void spinlock_acquire(volatile int *lock) {
    int tmp;
    asm volatile (
        "1:\n"
        "    lr.w    %0, (%1)\n"     // Load-reserved from lock
        "    bnez    %0, 1b\n"       // If locked, retry
        "    li      %0, 1\n"        // Load immediate 1
        "    sc.w    %0, %0, (%1)\n" // Store-conditional
        "    bnez    %0, 1b\n"       // If failed, retry
        : "=&r" (tmp)                // Output: temporary register
        : "r" (lock)                 // Input: lock address
        : "memory"                   // Memory barrier
    );
}
```

### Why LR/SC is Superior to Test-and-Set

**Traditional Test-and-Set Issues:**
- Always writes to memory (even when lock is held)
- Causes cache coherency traffic
- Poor scalability on multicore systems

**LR/SC Advantages:**
- Only writes when likely to succeed
- Reduced memory traffic
- Better cache performance
- Naturally handles ABA problem

## Implementation Details

### Basic Spinlock Implementation

```c
// Global shared resources
volatile int spinlock = 0;
volatile int shared_counter = 0;

// Spinlock acquire using LR/SC
void spinlock_acquire(volatile int *lock) {
    int tmp;
    asm volatile (
        "1:\n"
        "    lr.w    %0, (%1)\n"           // Load-reserved
        "    bnez    %0, 1b\n"             // Spin if locked
        "    li      %0, 1\n"              // Load 1 (locked state)
        "    sc.w    %0, %0, (%1)\n"       // Store-conditional
        "    bnez    %0, 1b\n"             // Retry if failed
        : "=&r" (tmp)
        : "r" (lock)
        : "memory"
    );
}

// Spinlock release
void spinlock_release(volatile int *lock) {
    asm volatile (
        "sw      zero, 0(%0)\n"            // Store 0 (unlocked)
        :
        : "r" (lock)
        : "memory"
    );
}
```

### Critical Section Usage Pattern

```c
void thread_function(int thread_id, int iterations) {
    for (int i = 0; i < iterations; i++) {
        // Acquire spinlock (enter critical section)
        spinlock_acquire(&spinlock);
        
        // Critical section - atomic access to shared resource
        int temp = shared_counter;
        temp += thread_id;
        shared_counter = temp;
        
        // Release spinlock (exit critical section)  
        spinlock_release(&spinlock);
    }
}
```

### Advanced Features

#### Contention Statistics
```c
volatile int lock_acquisitions = 0;
volatile int lock_contentions = 0;

int spinlock_acquire_with_stats(volatile int *lock) {
    int tmp, attempts = 0;
    
    do {
        attempts++;
        asm volatile ("lr.w %0, (%1)" : "=&r" (tmp) : "r" (lock) : "memory");
        
        if (tmp != 0) {
            lock_contentions++;  // Track contention
            continue;
        }
        
        asm volatile (
            "li      %0, 1\n"
            "sc.w    %0, %0, (%1)\n"
            : "=&r" (tmp) : "r" (lock) : "memory"
        );
        
    } while (tmp != 0);
    
    lock_acquisitions++;
    return attempts;
}
```

## Step-by-Step Implementation

### Step 1: Create Basic Mutex Demo
```bash
# Create basic two-thread mutex demonstration
cat << 'EOF' > task15_mutex_demo.c
#include <stdint.h>

// Global shared resources
volatile int spinlock = 0;
volatile int shared_counter = 0;
volatile int thread1_iterations = 0;
volatile int thread2_iterations = 0;

// Spinlock acquire using LR/SC atomic instructions
void spinlock_acquire(volatile int *lock) {
    int tmp;
    asm volatile (
        "1:\n"
        "    lr.w    %0, (%1)\n"           // Load-reserved from lock address
        "    bnez    %0, 1b\n"             // If lock != 0, retry (spin)
        "    li      %0, 1\n"              // Load immediate 1 (locked state)
        "    sc.w    %0, %0, (%1)\n"       // Store-conditional 1 to lock
        "    bnez    %0, 1b\n"             // If sc.w failed, retry
        : "=&r" (tmp)                      // Output: temporary register
        : "r" (lock)                       // Input: lock address
        : "memory"                         // Memory barrier
    );
}

// Spinlock release
void spinlock_release(volatile int *lock) {
    asm volatile (
        "sw      zero, 0(%0)\n"            // Store 0 (unlocked state)
        :
        : "r" (lock)                       // Input: lock address
        : "memory"                         // Memory barrier
    );
}

// Critical section function with mutex protection
void increment_shared_counter(int thread_id, int iterations) {
    for (int i = 0; i < iterations; i++) {
        // Acquire spinlock (enter critical section)
        spinlock_acquire(&spinlock);
        
        // Critical section - only one thread can execute this
        int temp = shared_counter;
        temp += thread_id;
        shared_counter = temp;
        
        // Update thread-specific counter
        if (thread_id == 1) {
            thread1_iterations++;
        } else {
            thread2_iterations++;
        }
        
        // Release spinlock (exit critical section)
        spinlock_release(&spinlock);
    }
}

int main() {
    // Initialize shared variables
    spinlock = 0;
    shared_counter = 0;
    thread1_iterations = 0;
    thread2_iterations = 0;
    
    // Simulate two threads accessing shared resource
    increment_shared_counter(1, 1000);  // Thread 1
    increment_shared_counter(2, 1000);  // Thread 2
    
    return 0;
}
EOF
```

### Step 2: Create Assembly Startup Code
```bash
cat << 'EOF' > mutex_start.s
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
```

### Step 3: Create Linker Script
```bash
cat << 'EOF' > mutex.ld
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
```

### Step 4: Compile and Link
```bash
# Compile with RV32IMAC (includes atomic extension)
riscv32-unknown-elf-gcc -march=rv32imac -c mutex_start.s -o mutex_start.o
riscv32-unknown-elf-gcc -march=rv32imac -c task15_mutex_demo.c -o task15_mutex_demo.o

# Link the mutex program
riscv32-unknown-elf-ld -T mutex.ld mutex_start.o task15_mutex_demo.o -o task15_mutex_demo.elf
```

### Step 5: Create Complete Build Script
```bash
cat << 'EOF' > build_mutex_demo.sh
#!/bin/bash
echo "=== Task 15: Atomic Test Program - Two-Thread Mutex ==="

# Compile with RV32IMAC (includes atomic extension)
echo "1. Compiling mutex demo programs..."
riscv32-unknown-elf-gcc -march=rv32imac -c mutex_start.s -o mutex_start.o
riscv32-unknown-elf-gcc -march=rv32imac -c task15_mutex_demo.c -o task15_mutex_demo.o

# Link programs
echo "2. Linking mutex programs..."
riscv32-unknown-elf-ld -T mutex.ld mutex_start.o task15_mutex_demo.o -o task15_mutex_demo.elf

echo "✓ Compilation successful!"

# Verify results
echo -e "\n3. Verifying mutex demo programs:"
file task15_mutex_demo.elf

echo -e "\n4. Checking for LR/SC instructions in assembly:"
riscv32-unknown-elf-gcc -march=rv32imac -S task15_mutex_demo.c
grep -E "(lr\.w|sc\.w)" task15_mutex_demo.s

echo -e "\n5. Disassembly showing spinlock implementation:"
riscv32-unknown-elf-objdump -d task15_mutex_demo.elf | grep -A 10 -B 5 "lr\.w\|sc\.w"

echo -e "\n6. Symbol table showing shared variables:"
riscv32-unknown-elf-nm task15_mutex_demo.elf | grep -E "(spinlock|shared_counter|thread)"

echo -e "\n✓ Atomic test program ready!"
EOF

chmod +x build_mutex_demo.sh
```

### Step 6: Advanced Multi-Lock Example
```bash
cat << 'EOF' > task15_advanced_mutex.c
#include <stdint.h>

// Multiple spinlocks for different resources
volatile int lock1 = 0;
volatile int lock2 = 0;
volatile int global_lock = 0;

// Shared resources protected by different locks
volatile int resource1 = 0;
volatile int resource2 = 0;
volatile int global_resource = 0;

// Performance counters
volatile int lock_acquisitions = 0;
volatile int lock_contentions = 0;

// Enhanced spinlock with contention counting
int spinlock_acquire_with_stats(volatile int *lock) {
    int tmp, attempts = 0;
    
    do {
        attempts++;
        asm volatile ("lr.w %0, (%1)" : "=&r" (tmp) : "r" (lock) : "memory");
        
        if (tmp != 0) {
            lock_contentions++;
            continue;
        }
        
        asm volatile (
            "li      %0, 1\n"
            "sc.w    %0, %0, (%1)\n"
            : "=&r" (tmp) : "r" (lock) : "memory"
        );
        
    } while (tmp != 0);
    
    lock_acquisitions++;
    return attempts;
}

void spinlock_release(volatile int *lock) {
    asm volatile ("sw zero, 0(%0)" : : "r" (lock) : "memory");
}

// Test multiple locks with nested critical sections
void test_nested_critical_sections(void) {
    spinlock_acquire_with_stats(&global_lock);
    
    global_resource += 100;
    
    spinlock_acquire_with_stats(&lock1);
    resource1 += 100;
    spinlock_release(&lock1);
    
    global_resource += 200;
    spinlock_release(&global_lock);
}

int main() {
    // Initialize all locks and resources
    lock1 = 0;
    lock2 = 0;
    global_lock = 0;
    resource1 = 0;
    resource2 = 0;
    global_resource = 0;
    lock_acquisitions = 0;
    lock_contentions = 0;
    
    // Run nested critical section test
    test_nested_critical_sections();
    
    return 0;
}
EOF
```

## Output

### Successful Compilation
```bash
task15_mutex_demo.elf: ELF 32-bit LSB executable, UCB RISC-V, RVC, soft-float ABI
```

### Generated LR/SC Instructions
```assembly
# In spinlock_acquire function:
lr.w    t0, (a0)          # Load-reserved from lock address
bnez    t0, <loop>        # Branch if lock is held
li      t0, 1             # Load immediate 1
sc.w    t0, t0, (a0)      # Store-conditional to lock
bnez    t0, <loop>        # Retry if store-conditional failed

# In spinlock_release function:
sw      zero, 0(a0)       # Store 0 to unlock
```

### Symbol Table Verification
```bash
# Expected symbols in the program
00000000 B shared_counter
00000004 B spinlock
00000008 B thread1_iterations
0000000c B thread2_iterations
```

## Troubleshooting

### Common Issues

1. **LR/SC instructions not generated**
   - Verify using `-march=rv32imac` (not rv32imc)
   - Check inline assembly syntax is correct
   - Ensure memory constraints are properly specified

2. **"Invalid instruction" during assembly**
   - Confirm toolchain supports atomic extension
   - Check that target architecture includes 'A' extension

3. **Undefined symbols during linking**
   - Ensure all object files compiled with same architecture
   - Verify startup assembly file is included in link

4. **Memory access violations**
   - Check that BSS initialization is working
   - Verify stack pointer setup in startup code

### Debugging Commands
```bash
# Check if LR/SC instructions are present
riscv32-unknown-elf-objdump -d task15_mutex_demo.elf | grep -E "lr\.w|sc\.w"

# Verify architecture flags
riscv32-unknown-elf-readelf -h task15_mutex_demo.elf | grep Flags

# Check symbol addresses
riscv32-unknown-elf-nm task15_mutex_demo.elf | grep -E "spinlock|shared"
```

## Testing & Validation

### Validation Checklist
- [ ] Program compiles successfully with RV32IMAC
- [ ] Generated assembly contains lr.w and sc.w instructions
- [ ] Spinlock acquire/release functions work correctly
- [ ] Critical sections properly protect shared resources
- [ ] Memory barriers prevent instruction reordering
- [ ] Symbol table shows proper variable allocation

### Performance Verification
```bash
# Count atomic instructions in binary
echo "LR/SC instruction count:"
riscv32-unknown-elf-objdump -d task15_mutex_demo.elf | grep -E "lr\.w|sc\.w" | wc -l

# Verify memory access patterns
riscv32-unknown-elf-objdump -d task15_mutex_demo.elf | grep -E "lw|sw" | head -10
```

### Testing Script
```bash
#!/bin/bash
echo "=== TASK15 Validation ==="

# Check compilation
if [ -f "task15_mutex_demo.elf" ]; then
    echo "✓ ELF file created successfully"
else
    echo "✗ ELF file missing"
    exit 1
fi

# Check for atomic instructions
LR_COUNT=$(riscv32-unknown-elf-objdump -d task15_mutex_demo.elf | grep "lr\.w" | wc -l)
SC_COUNT=$(riscv32-unknown-elf-objdump -d task15_mutex_demo.elf | grep "sc\.w" | wc -l)

echo "✓ Load-Reserved instructions: $LR_COUNT"
echo "✓ Store-Conditional instructions: $SC_COUNT"

if [ $LR_COUNT -gt 0 ] && [ $SC_COUNT -gt 0 ]; then
    echo "✓ Atomic LR/SC instructions successfully generated"
else
    echo "✗ Missing atomic instructions"
    exit 1
fi

echo "✓ All validation checks passed!"
```
