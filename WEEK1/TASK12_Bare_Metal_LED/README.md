# Bare-Metal LED Control for RISC-V

Develop complete bare-metal LED blink firmware for RISC-V microcontrollers using memory-mapped I/O and custom startup code.

## Objective

Develop a complete bare-metal LED blink firmware for RISC-V microcontrollers using memory-mapped I/O, custom linker scripts, and startup assembly code. This task demonstrates system-level programming concepts including hardware abstraction, register-level programming, and embedded system initialization.

## Key Learning Outcomes
- **Memory-Mapped I/O Programming**: Direct hardware register manipulation using volatile pointers
- **Bare-Metal System Design**: Initialize hardware without operating system support
- **Custom Linker Integration**: Combine multiple object files with custom memory layout
- **GPIO Control**: Implement digital output control for LED management
- **Startup Assembly**: Write initialization code for embedded systems
- **Register-Level Programming**: Understand memory-mapped peripheral control
- **Embedded System Architecture**: Learn microcontroller memory organization

## Prerequisites
- RISC-V GCC toolchain installed (`riscv64-unknown-elf-gcc`)
- Understanding of memory-mapped I/O concepts
- Basic knowledge of linker scripts and memory layout
- Familiarity with assembly language and startup sequences
- Knowledge of GPIO and digital I/O concepts

## Setup & Installation

### Environment Verification
```bash
# Verify toolchain availability
riscv64-unknown-elf-gcc --version
riscv64-unknown-elf-as --version
riscv64-unknown-elf-ld --version
riscv64-unknown-elf-objdump --version
```

### Project Structure Setup
```bash
# Create project directory
mkdir -p bare_metal_led
cd bare_metal_led

# Organize source files
mkdir -p src include build
```

## Technical Deep Dive

### Memory-Mapped I/O Architecture
In RISC-V systems, peripherals are accessed through memory-mapped registers:
- **GPIO Base Address**: 0x10000000 (typical for development boards)
- **Control Registers**: Direction, output enable, data output
- **Memory Mapping**: Hardware registers appear as memory locations

### Bare-Metal System Components
1. **Linker Script**: Defines memory layout and section placement
2. **Startup Assembly**: Initialize stack pointer and call main
3. **Main Application**: GPIO control and LED blinking logic
4. **Hardware Abstraction**: Volatile pointer access to registers

### Register-Level GPIO Control
```c
// GPIO register structure (memory-mapped)
typedef struct {
    volatile uint32_t direction;    // 0x00: Pin direction (0=input, 1=output)
    volatile uint32_t output_en;    // 0x04: Output enable
    volatile uint32_t output_val;   // 0x08: Output value
    volatile uint32_t input_val;    // 0x0C: Input value (read-only)
} gpio_t;

// Base address for GPIO peripheral
#define GPIO_BASE 0x10000000
```

## Implementation Details

### 1. Custom Linker Script (rv32imc.ld)
```ld
MEMORY
{
    FLASH (rx)  : ORIGIN = 0x20000000, LENGTH = 256K
    RAM (rwx)   : ORIGIN = 0x80000000, LENGTH = 64K
}

SECTIONS
{
    .text : {
        *(.text.start)
        *(.text*)
    } > FLASH
    
    .data : {
        *(.data*)
    } > RAM AT > FLASH
    
    .bss : {
        *(.bss*)
    } > RAM
    
    . = ALIGN(4);
    _stack_top = ORIGIN(RAM) + LENGTH(RAM);
}
```

### 2. Startup Assembly (start.S)
```assembly
.section .text.start
.global _start

_start:
    # Initialize stack pointer
    la sp, _stack_top
    
    # Clear BSS section
    la t0, __bss_start
    la t1, __bss_end
    
clear_bss:
    beq t0, t1, call_main
    sw zero, 0(t0)
    addi t0, t0, 4
    j clear_bss
    
call_main:
    # Call main function
    jal main
    
    # Infinite loop if main returns
halt:
    j halt
```

### 3. Main Application (led_blink.c)
```c
#include <stdint.h>

#define GPIO_BASE 0x10000000
#define LED_PIN 0

typedef struct {
    volatile uint32_t direction;
    volatile uint32_t output_en;
    volatile uint32_t output_val;
    volatile uint32_t input_val;
} gpio_t;

static gpio_t* const gpio = (gpio_t*)GPIO_BASE;

void delay(uint32_t count) {
    volatile uint32_t i;
    for (i = 0; i < count; i++) {
        __asm__ volatile("nop");
    }
}

void gpio_init(void) {
    // Configure LED pin as output
    gpio->direction |= (1 << LED_PIN);
    gpio->output_en |= (1 << LED_PIN);
}

void led_set(uint8_t state) {
    if (state) {
        gpio->output_val |= (1 << LED_PIN);
    } else {
        gpio->output_val &= ~(1 << LED_PIN);
    }
}

int main(void) {
    gpio_init();
    
    while (1) {
        led_set(1);          // Turn LED on
        delay(1000000);      // Delay
        led_set(0);          // Turn LED off
        delay(1000000);      // Delay
    }
    
    return 0;
}
```

### 4. Build Process
```bash
# Compile startup assembly
riscv64-unknown-elf-as -march=rv32imc -mabi=ilp32 -o start.o start.S

# Compile main application
riscv64-unknown-elf-gcc -march=rv32imc -mabi=ilp32 -ffreestanding -nostdlib -O2 -c -o led_blink.o led_blink.c

# Link with custom linker script
riscv64-unknown-elf-ld -T rv32imc.ld -o led_blink.elf start.o led_blink.o

# Generate additional output formats
riscv64-unknown-elf-objcopy -O binary led_blink.elf led_blink.bin
riscv64-unknown-elf-objcopy -O ihex led_blink.elf led_blink.hex
```

## Expected Output

### Compilation Success
```
$ riscv64-unknown-elf-gcc -march=rv32imc -mabi=ilp32 -ffreestanding -nostdlib -O2 -c -o led_blink.o led_blink.c
$ riscv64-unknown-elf-ld -T rv32imc.ld -o led_blink.elf start.o led_blink.o
```

### ELF Analysis
```bash
# Check ELF sections and memory layout
$ riscv64-unknown-elf-objdump -h led_blink.elf
Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .text         000001a4  20000000  20000000  00001000  2**2
  1 .data         00000000  80000000  200001a4  00002000  2**0
  2 .bss          00000000  80000000  80000000  00002000  2**0

# Verify symbol addresses
$ riscv64-unknown-elf-nm led_blink.elf
20000000 T _start
20000020 T main
20000054 T gpio_init
20000070 T led_set
20000090 T delay
80010000 T _stack_top
```

### Disassembly Verification
```bash
# Examine generated assembly
$ riscv64-unknown-elf-objdump -d led_blink.elf
20000020 <main>:
20000020:	ff010113          	addi	sp,sp,-16
20000024:	00112623          	sw	ra,12(sp)
20000028:	02c000ef          	jal	ra,20000054 <gpio_init>
2000002c:	00100513          	li	a0,1
20000030:	040000ef          	jal	ra,20000070 <led_set>
20000034:	000f4537          	lui	a0,0xf4
20000038:	24050513          	addi	a0,a0,576 # f4240 <_start-0x1ff0bdc0>
2000003c:	054000ef          	jal	ra,20000090 <delay>
```

### Memory Map Verification
```bash
# Verify memory sections are correctly placed
$ riscv64-unknown-elf-size led_blink.elf
   text    data     bss     dec     hex filename
    420       0       0     420     1a4 led_blink.elf
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Linker Errors
```
Error: cannot find -lgcc
Solution: Use -nostdlib flag to avoid standard library linking
```

#### 2. Stack Pointer Issues
```
Problem: System crashes or hangs on startup
Solution: Verify _stack_top symbol is correctly defined in linker script
Check: la sp, _stack_top instruction in startup assembly
```

#### 3. GPIO Access Faults
```
Problem: System fault when accessing GPIO registers
Solution: Verify GPIO_BASE address matches target hardware
Check: Memory-mapped I/O region is accessible
```

#### 4. Optimization Issues
```
Problem: Compiler optimizes away GPIO writes
Solution: Use volatile keyword for all hardware register accesses
Verify: gpio_t structure uses volatile uint32_t members
```

## Testing & Validation

### Static Analysis
```bash
# Verify RISC-V instruction encoding
riscv64-unknown-elf-objdump -d led_blink.elf | grep -A5 -B5 "gpio"

# Check memory layout compliance
riscv64-unknown-elf-readelf -l led_blink.elf

# Validate symbol table
riscv64-unknown-elf-readelf -s led_blink.elf
```

### Runtime Validation
1. **GPIO Register Access**: Verify volatile accesses are preserved
2. **Memory Layout**: Confirm code loads at 0x20000000
3. **Stack Initialization**: Validate stack pointer setup
4. **Peripheral Control**: Test GPIO register manipulation

### Hardware Testing
```bash
# Load onto RISC-V development board
# Connect LED to GPIO pin 0
# Observe LED blinking at ~1Hz rate
# Verify GPIO registers show correct values
```

## References

### Technical Documentation
- **RISC-V Specification**: [RISC-V ISA Manual](https://riscv.org/specifications/)
- **ABI Documentation**: [RISC-V ELF psABI](https://github.com/riscv-non-isa/riscv-elf-psabi-doc)
- **GNU Linker**: [LD Manual](https://sourceware.org/binutils/docs/ld/)
- **GCC Cross-Compilation**: [GCC Manual](https://gcc.gnu.org/onlinedocs/)

### Embedded Systems Resources
- **Memory-Mapped I/O**: ARM Cortex-M Programming Guide
- **Bare-Metal Programming**: "Embedded Systems Architecture" by Tammy Noergaard
- **Linker Scripts**: "Mastering Embedded Linux Programming" by Chris Simmonds
- **GPIO Control**: Hardware-specific reference manuals

### Development Tools
- **RISC-V Toolchain**: [riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)
- **QEMU Emulation**: [QEMU RISC-V](https://www.qemu.org/docs/master/system/target-riscv.html)
- **Debugging**: [OpenOCD for RISC-V](https://openocd.org/)
- **Hardware Platforms**: SiFive HiFive1, Kendryte K210, ESP32-C3
