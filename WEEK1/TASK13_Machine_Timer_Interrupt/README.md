# TASK 13: Machine Timer Interrupt (MTIP)

## Objective
Implement a complete machine timer interrupt system for RISC-V processors using Control and Status Registers (CSRs), demonstrating hardware-level interrupt handling, timer configuration, and interrupt service routine development for real-time embedded systems.

## Key Learning Outcomes
- **RISC-V Interrupt Architecture**: Understanding machine mode interrupts and privilege levels
- **CSR Programming**: Direct manipulation of mstatus, mie, mtvec, and timer registers
- **Timer Interrupt Configuration**: Setup of MTIME and MTIMECMP registers for periodic interrupts
- **Interrupt Service Routines**: Implementation of interrupt handlers with proper context preservation
- **Assembly/C Integration**: Combining assembly interrupt handlers with C-based service routines
- **Real-Time Programming**: Timer-based event handling for embedded applications
- **ZICSR Extension**: Utilization of RISC-V CSR instruction set extension

## Prerequisites
- RISC-V GCC toolchain with ZICSR extension support
- Understanding of interrupt concepts and real-time systems
- Knowledge of RISC-V privilege levels and machine mode
- Assembly language programming fundamentals
- C programming with inline assembly and function attributes

## Setup & Installation

### Environment Verification
```bash
# Verify toolchain supports ZICSR extension
riscv32-unknown-elf-gcc --target-help | grep zicsr
riscv32-unknown-elf-gcc -march=rv32imac_zicsr --version
```

### Project Structure Setup
```bash
# Create interrupt project directory
mkdir -p ~/riscv_code
cd ~/riscv_code
```

## Technical Deep Dive

### RISC-V Interrupt Architecture
The RISC-V machine timer interrupt (MTIP) operates at the highest privilege level:
- **Machine Mode**: Highest privilege level for interrupt handling
- **Memory-Mapped Timers**: MTIME (current time) and MTIMECMP (compare value)
- **CSR Registers**: Control and status registers for interrupt configuration

### Control and Status Registers (CSRs)
```c
// Critical CSRs for timer interrupts:
// mstatus (0x300): Global interrupt enable (MIE bit)
// mie (0x304): Individual interrupt enables (MTIE bit)
// mtvec (0x305): Trap vector base address
// mtime: Current timer value (memory-mapped)
// mtimecmp: Timer compare value (memory-mapped)
```

### Interrupt Flow Sequence
1. **Timer Setup**: Configure MTIMECMP for first interrupt
2. **CSR Configuration**: Enable timer interrupts in mie register
3. **Global Enable**: Set MIE bit in mstatus register
4. **Interrupt Occurrence**: Hardware triggers when MTIME >= MTIMECMP
5. **Context Switch**: Processor jumps to interrupt handler
6. **Service Routine**: Execute interrupt handler code
7. **Timer Reset**: Update MTIMECMP for next interrupt
8. **Return**: MRET instruction returns to interrupted code

## Implementation Details

### 1. Timer Interrupt Handler with Interrupt Attribute
```c
// Memory-mapped timer registers (QEMU virt machine)
#define MTIME_BASE 0x0200BFF8
#define MTIMECMP_BASE 0x02004000

volatile uint64_t *mtime = (volatile uint64_t *)MTIME_BASE;
volatile uint64_t *mtimecmp = (volatile uint64_t *)MTIMECMP_BASE;

// Timer interrupt handler with compiler interrupt attribute
void __attribute__((interrupt)) timer_interrupt_handler(void) {
    // Clear timer interrupt by setting next compare value
    *mtimecmp = *mtime + 10000000;  // Next interrupt in ~1 second
    interrupt_count++;
}
```

### 2. CSR Access Functions
```c
// Inline assembly for CSR operations
static inline uint32_t read_csr_mstatus(void) {
    uint32_t result;
    asm volatile ("csrr %0, mstatus" : "=r"(result));
    return result;
}

static inline void write_csr_mie(uint32_t value) {
    asm volatile ("csrw mie, %0" : : "r"(value));
}
```

### 3. Assembly Trap Handler
```assembly
trap_handler:
    # Save context (64-byte frame)
    addi sp, sp, -64
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    # ... save other registers
    
    # Call C interrupt handler
    call timer_interrupt_handler
    
    # Restore context
    lw ra, 0(sp)
    lw t0, 4(sp)
    # ... restore other registers
    addi sp, sp, 64
    
    # Return from interrupt
    mret
```

### 4. Build Process
```bash
# Compile with ZICSR extension
riscv32-unknown-elf-gcc -march=rv32imac_zicsr -mabi=ilp32 -c interrupt_start.s -o interrupt_start.o
riscv32-unknown-elf-gcc -march=rv32imac_zicsr -mabi=ilp32 -c task13_timer_interrupt.c -o task13_timer_interrupt.o -nostdlib

# Link with custom memory layout
riscv32-unknown-elf-ld -T interrupt.ld interrupt_start.o task13_timer_interrupt.o -o task13_timer_interrupt.elf
```

## Expected Output

### Compilation Success
```
$ riscv32-unknown-elf-gcc -march=rv32imac_zicsr -mabi=ilp32 -c task13_timer_interrupt.c -o task13_timer_interrupt.o -nostdlib
$ riscv32-unknown-elf-ld -T interrupt.ld interrupt_start.o task13_timer_interrupt.o -o task13_timer_interrupt.elf
```

### Symbol Analysis
```bash
$ riscv32-unknown-elf-nm task13_timer_interrupt.elf | grep -E "(interrupt|timer|handler)"
00000156 T enable_timer_interrupt
10000008 B interrupt_count
0000003a T timer_interrupt_handler
00000018 t trap_handler
```

### CSR Instruction Generation
```bash
$ riscv32-unknown-elf-objdump -d task13_timer_interrupt.elf | grep -A 10 -B 5 "csrr\|csrw"
c8:   300027f3    csrr    a5,mstatus     # Read machine status
10c:  30079073    csrw    mstatus,a5     # Write machine status
e6:   304027f3    csrr    a5,mie         # Read machine interrupt enable
12a:  30479073    csrw    mie,a5         # Write machine interrupt enable
148:  30579073    csrw    mtvec,a5       # Write machine trap vector
```

### Assembly Analysis
```bash
$ grep -A 3 -B 3 "csr" task13_timer_interrupt.s
csrr a5, mstatus    # Generated CSR read instruction
csrw mtvec, a5      # Generated CSR write instruction
```

## Troubleshooting

### Common Issues and Solutions

#### 1. ZICSR Extension Not Found
```
Error: unrecognized opcode `csrr`
Solution: Use -march=rv32imac_zicsr flag explicitly
Check: riscv32-unknown-elf-gcc -march=rv32imac_zicsr --version
```

#### 2. Timer Interrupt Not Firing
```
Problem: Interrupt handler never called
Solution: Verify timer compare value setup
Check: *mtimecmp = *mtime + 10000000;
Debug: Ensure MIE and MTIE bits are set correctly
```

#### 3. Context Corruption
```
Problem: System crashes after interrupt return
Solution: Verify all registers saved/restored in trap handler
Check: 64-byte frame allocation matches register count
Debug: Use debugger to verify stack pointer consistency
```

#### 4. CSR Access Faults
```
Problem: Illegal instruction on CSR operations
Solution: Ensure processor supports machine mode CSRs
Check: Verify ZICSR extension compilation flag
```

## Testing & Validation

### Static Analysis
```bash
# Verify interrupt handler symbol
riscv32-unknown-elf-nm task13_timer_interrupt.elf | grep timer_interrupt_handler

# Check CSR instruction generation
riscv32-unknown-elf-objdump -d task13_timer_interrupt.elf | grep -E "csrr|csrw"

# Validate memory layout
riscv32-unknown-elf-readelf -l task13_timer_interrupt.elf
```

### Runtime Validation
1. **Timer Configuration**: Verify MTIMECMP register setup
2. **CSR Programming**: Confirm mstatus and mie register values
3. **Interrupt Handler**: Test interrupt service routine execution
4. **Context Preservation**: Validate register save/restore

### Functional Testing
```bash
# Build and analyze interrupt system
gcc -march=rv32imac_zicsr -mabi=ilp32 -c task13_timer_interrupt.c
objdump -d task13_timer_interrupt.o | grep -A 5 -B 5 "csrr\|csrw"
```

## Future Improvements

### Enhanced Interrupt Features
- **Nested Interrupts**: Support for interrupt priority and nesting
- **Multiple Timer Sources**: Integration of additional timer peripherals
- **Interrupt Latency Optimization**: Assembly-only handlers for critical paths
- **Power Management**: Sleep modes between timer interrupts

### System Extensions
- **Real-Time Scheduler**: Task switching based on timer interrupts
- **Watchdog Integration**: System reset on timer timeout
- **Performance Counters**: Interrupt frequency and latency measurement
- **Debug Interface**: Interrupt monitoring and debugging support

### Advanced Features
- **Vectored Interrupts**: Direct dispatch to specific handlers
- **Interrupt Coalescing**: Combining multiple timer events
- **Dynamic Timer Adjustment**: Runtime modification of interrupt periods
- **Multi-Core Support**: Timer synchronization across RISC-V cores

## References

- [RISC-V Privileged Specification](https://riscv.org/specifications/privileged-isa/)
- [RISC-V Timer Specification](https://riscv.org/specifications/)
- [ZICSR Extension Documentation](https://riscv.org/specifications/)
- [GCC RISC-V Interrupt Attributes](https://gcc.gnu.org/onlinedocs/gcc/RISC-V-Options.html)
