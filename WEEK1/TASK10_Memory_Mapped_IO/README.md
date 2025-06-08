# Memory-Mapped I/O for RISC-V GPIO Control

Demonstrate memory-mapped I/O programming for GPIO control using volatile pointers and hardware register manipulation.

## Objective

Demonstrate memory-mapped I/O programming for GPIO control using volatile pointers, analyze compiler optimization effects on hardware register access, and implement proper bare-metal programming techniques for direct hardware manipulation in RISC-V systems.

## Key Learning Outcomes

- Master volatile keyword usage for hardware register access
- Understand memory-mapped I/O addressing and alignment requirements
- Learn compiler optimization prevention for hardware operations
- Practice direct hardware register manipulation techniques
- Analyze assembly generation differences between volatile and non-volatile access
- Gain proficiency in embedded systems programming patterns

## Prerequisites

- **Completed Tasks**: TASK1 (RISC-V toolchain setup)
- **Knowledge**: Memory addressing, pointer arithmetic, embedded systems hardware
- **Environment**: WSL with RISC-V development capabilities

## Setup & Installation

### Environment Preparation

```bash
# Navigate to working directory
cd ~/riscv_code
```

## Technical Deep Dive

### Memory-Mapped I/O Architecture

Memory-mapped I/O enables direct hardware control by mapping peripheral registers into the processor's memory address space. For RISC-V systems:

- **Address Space Integration**: Hardware registers appear as memory locations
- **Direct Access**: Load/store instructions manipulate hardware state
- **Alignment Requirements**: 32-bit registers require 4-byte aligned addresses
- **Volatile Necessity**: Prevents compiler from optimizing away hardware accesses

### Volatile Keyword Semantics

The `volatile` qualifier instructs the compiler that:

#### **Hardware Synchronization**:
- Memory location can change outside program control
- Every access must actually occur (no optimization elimination)
- Access order must be preserved as written
- No caching of values across accesses

#### **Compiler Optimization Prevention**:
- **Without volatile**: Compiler may eliminate "redundant" operations
- **With volatile**: Every register access generates actual hardware operations
- **Critical for Hardware**: Ensures timing-sensitive operations execute correctly

### GPIO Register Layout

Typical GPIO controller memory mapping:
```
Base Address: 0x10012000
+0x00: Input Value Register
+0x04: Input Enable Register  
+0x08: Output Enable Register
+0x0C: Output Value Register
+0x10: Pull-up Enable Register
```

## Implementation Details

### Step 1: Create GPIO Control Program

```bash
nano task10_gpio.c
```

Implementation demonstrating proper volatile usage:

#### **GPIO Control Functions**
```c
#define GPIO_ADDR 0x10012000

void toggle_gpio(void) {
    volatile uint32_t *gpio = (volatile uint32_t *)GPIO_ADDR;
    
    *gpio = 0x1;              // Set GPIO pin high
    uint32_t current_state = *gpio;  // Read current state
    *gpio = ~current_state;   // Toggle operation
    *gpio |= (1 << 0);        // Set bit 0
    *gpio &= ~(1 << 1);       // Clear bit 1
}
```

#### **Multiple GPIO Operations**
```c
void gpio_operations(void) {
    volatile uint32_t *gpio = (volatile uint32_t *)GPIO_ADDR;
    
    *gpio = 0x0;         // Clear all pins
    *gpio = 0x1;         // Set pin 0
    *gpio = 0xFFFFFFFF;  // Set all pins
    *gpio = 0x0;         // Clear all pins again
}
```

### Step 2: Create Non-Volatile Comparison

```bash
nano task10_no_volatile.c
```

Comparison version without volatile qualification:

```c
void toggle_gpio_no_volatile(void) {
    uint32_t *gpio = (uint32_t *)GPIO_ADDR;  // No volatile
    *gpio = 0x1;
    *gpio = 0x0;
    *gpio = 0x1;  // Compiler might optimize this away
}
```

### Step 3: Compile and Analyze Optimization Effects

```bash
# Compile both versions with -O2 optimization
riscv32-unknown-elf-gcc -S -O2 task10_gpio.c -o task10_with_volatile.s
riscv32-unknown-elf-gcc -S -O2 task10_no_volatile.c -o task10_no_volatile.s

# Compile ELF binary
riscv32-unknown-elf-gcc -o task10_gpio.elf task10_gpio.c
```

### Step 4: Compare Memory Operation Preservation

```bash
# Count memory operations in each version
echo "=== With Volatile (stores preserved) ==="
grep -c "sw\|lw" task10_with_volatile.s

echo "=== Without Volatile (stores might be optimized away) ==="
grep -c "sw\|lw" task10_no_volatile.s
```

## Output

### Compilation and Analysis Results

#### **Memory Operation Comparison**
```bash
=== With Volatile (stores preserved) ===
20

=== Without Volatile (stores might be optimized away) ===
2
```

#### **ELF Binary Properties**
```bash
$ file task10_gpio.elf
task10_gpio.elf: ELF 32-bit LSB executable, UCB RISC-V, RVC, double-float ABI, 
version 1 (SYSV), statically linked, not stripped
```

### Assembly Analysis - Volatile Preservation

#### **With Volatile (Hardware Operations Preserved)**
```assembly
# Every GPIO access generates actual hardware operations
lui     a3,0x10012     # Load GPIO base address
sw      a5,0(a3)       # Store to GPIO register - preserved
lw      a4,0(a3)       # Load from GPIO register - preserved  
sw      a4,0(a3)       # Another store - preserved
```

#### **Without Volatile (Optimized Away)**
```assembly
# Most operations eliminated by compiler optimization
lui     a3,0x10012     # Load GPIO base address
sw      a5,0(a3)       # Only final store remains
# Previous operations optimized away
```

### Key Insight: 10:1 Operation Ratio

The dramatic difference (20 vs 2 operations) demonstrates:
- **Volatile preserves all 20 hardware accesses** for proper GPIO control
- **Non-volatile allows optimization of 18 operations**, breaking hardware functionality
- **90% reduction** in actual hardware operations without volatile

## Troubleshooting

### Issue: Unexpected Assembly Output
```
Error: GPIO operations not appearing in assembly
```
**Solution**: Ensure volatile qualifier is used correctly:
```c
volatile uint32_t *gpio = (volatile uint32_t *)GPIO_ADDR;
```

### Issue: Alignment Warnings
```
Warning: unaligned memory access
```
**Solution**: Verify GPIO address is 4-byte aligned:
```c
#define GPIO_ADDR 0x10012000  // Must be 4-byte aligned for uint32_t
```

### Issue: Optimization Elimination
```
Warning: unused variable optimized away
```
**Solution**: Use volatile and ensure variables are actually used in meaningful operations.

## Testing & Validation

### Validation Checklist

1. **Compilation Success**:
   ```bash
   ls task10_gpio.elf
   # Should exist without compilation errors
   ```

2. **Volatile Effect Verification**:
   ```bash
   # Compare operation counts
   grep -c "sw\|lw" task10_with_volatile.s
   grep -c "sw\|lw" task10_no_volatile.s
   # Should show significant difference (typically 10:1 ratio)
   ```

3. **Assembly Analysis**:
   ```bash
   # Check for GPIO address usage
   grep "0x10012000" task10_with_volatile.s
   # Should appear multiple times with volatile
   ```

4. **Hardware Register Pattern**:
   ```bash
   # Verify store/load patterns
   grep -E "(sw|lw).*0x10012" task10_with_volatile.s
   # Should show preserved memory operations
   ```

### Performance Metrics

| Implementation | Memory Operations | Hardware Accesses | Optimization Effect |
|---------------|-------------------|-------------------|-------------------|
| **With Volatile** | 20 operations | All preserved | No optimization |
| **Without Volatile** | 2 operations | 90% eliminated | Aggressive optimization |


## References

- [Volatile Keyword in Embedded Systems](https://www.embedded.com/volatiles-are-misunderstood/)
- [RISC-V Memory Model Specification](https://riscv.org/specifications/)
- [Memory-Mapped I/O Programming](https://en.wikipedia.org/wiki/Memory-mapped_I/O)
- [GCC Optimization Documentation](https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html)

