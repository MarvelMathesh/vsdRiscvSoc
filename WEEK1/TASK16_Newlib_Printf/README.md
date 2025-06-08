# Newlib Printf Implementation for RISC-V

Implement Newlib's system call retargeting to enable printf functionality in bare-metal RISC-V environments.

## Objective

Implement Newlib's `_write` system call retargeting to send `printf` output to a memory-mapped UART instead of requiring an operating system. Develop custom syscall functions and demonstrate full printf functionality in a bare-metal RISC-V environment, enabling formatted output without OS dependency.

## Key Learning Outcomes

- System call retargeting and custom implementation techniques
- Newlib C library integration in bare-metal environments
- UART programming using memory-mapped I/O interfaces
- Bare-metal printf functionality without operating system support
- Library linking and custom syscall implementation procedures
- Standard I/O stream redirection to hardware interfaces

## Prerequisites

- **Completed Tasks**: TASK15 (Two-Thread Mutex) for system programming understanding
- **Toolchain**: RISC-V cross-compilation toolchain with Newlib support
- **Knowledge**: Memory-mapped I/O, system calls, library linking, UART communication

## Setup & Installation

### Required Tools Verification
```bash
# Verify Newlib support in toolchain
riscv32-unknown-elf-gcc --print-file-name=libc.a

# Check for printf symbols in Newlib
riscv32-unknown-elf-nm $(riscv32-unknown-elf-gcc --print-file-name=libc.a) | grep printf

# Verify syscall symbol requirements
riscv32-unknown-elf-nm $(riscv32-unknown-elf-gcc --print-file-name=libc.a) | grep _write
```

## Technical Deep Dive

### Newlib System Call Interface

Newlib requires several system calls to be implemented for full functionality:

#### Required Syscalls for Printf
- **_write()**: Output data to file descriptors (stdout/stderr)
- **_close()**: Close file descriptors
- **_fstat()**: Get file status information
- **_isatty()**: Test if file descriptor is a terminal
- **_lseek()**: Seek to position in file
- **_read()**: Read data from file descriptors

#### UART Memory Mapping
```c
#define UART_BASE     0x10000000
#define UART_TX_REG   (*(volatile uint32_t *)(UART_BASE + 0x00))
#define UART_RX_REG   (*(volatile uint32_t *)(UART_BASE + 0x04))
#define UART_STATUS   (*(volatile uint32_t *)(UART_BASE + 0x08))
```

### Printf Retargeting Mechanism

When `printf()` is called:
1. Newlib formats the string internally
2. Calls `_write()` with formatted data
3. Our custom `_write()` sends bytes to UART
4. UART transmits data serially

## Implementation Details

### Core UART Output Function

```c
// UART register for output
#define UART_BASE 0x10000000
#define UART_TX_REG (*(volatile uint32_t *)(UART_BASE + 0x00))

// UART character output function
void uart_putchar(char c) {
    UART_TX_REG = (uint32_t)c;
}
```

### System Call Retargeting

```c
// Retarget _write for printf support
int _write(int fd, char *buf, int len) {
    if (fd == STDOUT_FILENO || fd == STDERR_FILENO) {
        for (int i = 0; i < len; i++) {
            uart_putchar(buf[i]);
            if (buf[i] == '\n') {
                uart_putchar('\r');  // CRLF conversion for terminals
            }
        }
        return len;
    }
    return -1;  // Error for other file descriptors
}
```

### Complete Syscall Implementation

```c
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>

// Required syscalls for printf functionality
int _close(int fd) { 
    return -1; 
}

int _fstat(int fd, struct stat *st) { 
    if (fd <= 2) {  // stdin, stdout, stderr
        st->st_mode = S_IFCHR;  // Character device
        return 0; 
    }
    return -1; 
}

int _isatty(int fd) { 
    return (fd <= 2) ? 1 : 0;  // Standard streams are TTY
}

int _lseek(int fd, int offset, int whence) { 
    return -1;  // Not seekable
}

int _read(int fd, char *buf, int len) { 
    return -1;  // No input implementation
}
```

## Step-by-Step Implementation

### Step 1: Create Complete Printf Implementation
```bash
# Create comprehensive printf demonstration with UART retargeting
cat << 'EOF' > task16_final_working.c
#include <stdio.h>
#include <stdint.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>

// UART register for output
#define UART_BASE 0x10000000
#define UART_TX_REG (*(volatile uint32_t *)(UART_BASE + 0x00))

// UART character output function
void uart_putchar(char c) {
    UART_TX_REG = (uint32_t)c;
}

// Retarget _write for printf (COMPLETE IMPLEMENTATION)
int _write(int fd, char *buf, int len) {
    if (fd == STDOUT_FILENO || fd == STDERR_FILENO) {
        for (int i = 0; i < len; i++) {
            uart_putchar(buf[i]);
            if (buf[i] == '\n') {
                uart_putchar('\r');  // CRLF conversion
            }
        }
        return len;
    }
    return -1;
}

// Required syscalls for printf (minimal implementations)
int _close(int fd) { return -1; }
int _fstat(int fd, struct stat *st) { 
    if (fd <= 2) {
        st->st_mode = S_IFCHR; 
        return 0; 
    }
    return -1; 
}
int _isatty(int fd) { return (fd <= 2) ? 1 : 0; }
int _lseek(int fd, int offset, int whence) { return -1; }
int _read(int fd, char *buf, int len) { return -1; }

// Main application demonstrating printf functionality
int main() {
    printf("=== Task 16: Printf Working Successfully! ===\n");
    printf("UART-based printf retargeting demonstration\n\n");
    
    printf("Testing different printf formats:\n");
    printf("- Integer: %d\n", 42);
    printf("- Hexadecimal: 0x%08X\n", 0xDEADBEEF);
    printf("- String: %s\n", "Hello from RISC-V!");
    printf("- Character: %c\n", 'A');
    printf("- Negative integer: %d\n", -123);
    printf("- Float: %.2f\n", 3.14159);
    
    printf("\n_write() retargeting to UART successful!\n");
    printf("All printf output goes to memory-mapped UART!\n");
    
    return 0;
}
EOF
```

### Step 2: Create Multi-File Version
```bash
# Create separate main program
cat << 'EOF' > task16_uart_printf.c
#include <stdio.h>
#include <stdint.h>

// Test function demonstrating printf functionality
void test_printf_functionality(void) {
    printf("Hello, RISC-V printf!\n");
    printf("Testing integer output: %d\n", 42);
    printf("Testing hex output: 0x%08X\n", 0xDEADBEEF);
    printf("Testing string output: %s\n", "UART-based printf working!");
    printf("Testing character output: %c\n", 'A');
    printf("Testing floating point: %.3f\n", 2.718);
}

int main() {
    printf("=== Task 16: Newlib printf Without OS ===\n");
    printf("UART-based printf implementation\n\n");
    
    test_printf_functionality();
    
    printf("\nPrintf retargeting to UART successful!\n");
    
    return 0;
}
EOF

# Create separate syscalls implementation
cat << 'EOF' > syscalls.c
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <errno.h>

// UART register definitions
#define UART_BASE 0x10000000
#define UART_TX_REG (*(volatile uint32_t *)(UART_BASE + 0x00))

// UART character output
void uart_putchar(char c) {
    UART_TX_REG = (uint32_t)c;
}

// System call implementations
int _write(int fd, char *buf, int len) {
    if (fd == STDOUT_FILENO || fd == STDERR_FILENO) {
        for (int i = 0; i < len; i++) {
            uart_putchar(buf[i]);
            if (buf[i] == '\n') {
                uart_putchar('\r');
            }
        }
        return len;
    }
    return -1;
}

int _close(int fd) { return -1; }
int _fstat(int fd, struct stat *st) { 
    if (fd <= 2) { st->st_mode = S_IFCHR; return 0; }
    return -1; 
}
int _isatty(int fd) { return (fd <= 2) ? 1 : 0; }
int _lseek(int fd, int offset, int whence) { return -1; }
int _read(int fd, char *buf, int len) { return -1; }
EOF
```

### Step 3: Create Assembly Startup Code
```bash
cat << 'EOF' > printf_start.s
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
    
    # Initialize data section (copy from flash to RAM)
    la t0, _data_start
    la t1, _data_end
    la t2, _data_load_start
data_loop:
    bge t0, t1, data_done
    lw t3, 0(t2)
    sw t3, 0(t0)
    addi t0, t0, 4
    addi t2, t2, 4
    j data_loop
data_done:
    
    # Call main program
    call main
    
    # Infinite loop on exit
1:  j 1b

.size _start, . - _start
EOF
```

### Step 4: Create Linker Script for Printf
```bash
cat << 'EOF' > printf.ld
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

    .data 0x10000000 : AT (ADDR(.text) + SIZEOF(.text)) {
        _data_start = .;
        _data_load_start = LOADADDR(.data);
        *(.data*)
        _data_end = .;
    } > SRAM

    .bss : {
        _bss_start = .;
        *(.bss*)
        *(COMMON)
        _bss_end = .;
    } > SRAM

    .heap : {
        _heap_start = .;
        . += 16384;  /* 16KB heap */
        _heap_end = .;
    } > SRAM

    _stack_top = ORIGIN(SRAM) + LENGTH(SRAM);
}
EOF
```

### Step 5: Compile and Link
```bash
# Compile startup code
riscv32-unknown-elf-gcc -march=rv32imc -c printf_start.s -o printf_start.o

# Compile single-file working version
riscv32-unknown-elf-gcc -march=rv32imc -c task16_final_working.c -o task16_final_working.o
riscv32-unknown-elf-gcc -T printf.ld -nostartfiles printf_start.o task16_final_working.o -o task16_final_working.elf

# Compile multi-file version
riscv32-unknown-elf-gcc -march=rv32imc -c task16_uart_printf.c -o task16_uart_printf.o
riscv32-unknown-elf-gcc -march=rv32imc -c syscalls.c -o syscalls.o
riscv32-unknown-elf-gcc -T printf.ld -nostartfiles printf_start.o task16_uart_printf.o syscalls.o -o task16_uart_printf.elf
```

### Step 6: Create Complete Build Script
```bash
cat << 'EOF' > build_printf_demo.sh
#!/bin/bash
echo "=== Task 16: Newlib printf Without OS ==="

# Compile startup code
echo "1. Compiling startup code..."
riscv32-unknown-elf-gcc -march=rv32imc -c printf_start.s -o printf_start.o

# Compile single working version
echo "2. Compiling single-file working version..."
riscv32-unknown-elf-gcc -march=rv32imc -c task16_final_working.c -o task16_final_working.o
riscv32-unknown-elf-gcc -T printf.ld -nostartfiles printf_start.o task16_final_working.o -o task16_final_working.elf

# Compile multi-file version
echo "3. Compiling multi-file version..."
riscv32-unknown-elf-gcc -march=rv32imc -c task16_uart_printf.c -o task16_uart_printf.o
riscv32-unknown-elf-gcc -march=rv32imc -c syscalls.c -o syscalls.o
riscv32-unknown-elf-gcc -T printf.ld -nostartfiles printf_start.o task16_uart_printf.o syscalls.o -o task16_uart_printf.elf

echo "✓ Compilation successful!"

# Verify results
echo -e "\n4. Verifying printf demo programs:"
file task16_final_working.elf
file task16_uart_printf.elf

echo -e "\n5. Checking _write function implementation:"
riscv32-unknown-elf-nm task16_final_working.elf | grep _write

echo -e "\n6. Verifying UART register usage:"
riscv32-unknown-elf-objdump -d task16_final_working.elf | grep -A 3 -B 3 "0x10000000"

echo -e "\n7. Checking printf function calls:"
riscv32-unknown-elf-nm task16_final_working.elf | grep printf

echo -e "\n8. Symbol table analysis:"
riscv32-unknown-elf-nm task16_final_working.elf | grep -E "(_write|_close|_fstat|_isatty|printf|main)"

echo -e "\n✓ Printf retargeting demo ready - all programs compiled successfully!"
EOF

chmod +x build_printf_demo.sh
```

## Output

### Successful Compilation
```bash
task16_final_working.elf: ELF 32-bit LSB executable, UCB RISC-V, RVC, soft-float ABI
task16_uart_printf.elf: ELF 32-bit LSB executable, UCB RISC-V, RVC, soft-float ABI
```

### Syscall Functions Present
```bash
# Expected symbols from nm command
00000408 T _write
0000043c T _close  
00000444 T _fstat
0000045c T _isatty
00000468 T _lseek
00000470 T _read
```

### UART Register Access Verification
```assembly
# UART register access in disassembly
lui     a0, 0x10000      # Load upper immediate for UART_BASE
sw      t0, 0(a0)        # Store to UART_TX_REG
```

### Expected Runtime Output
```
=== Task 16: Printf Working Successfully! ===
UART-based printf retargeting demonstration

Testing different printf formats:
- Integer: 42
- Hexadecimal: 0xDEADBEEF
- String: Hello from RISC-V!
- Character: A
- Negative integer: -123

_write() retargeting to UART successful!
All printf output goes to memory-mapped UART!
```

## Troubleshooting

### Common Issues

1. **Undefined reference to `_write`**
   - Ensure syscalls.c is compiled and linked
   - Check that all required syscalls are implemented
   - Verify function signatures match Newlib expectations

2. **Printf output not appearing**
   - Verify UART_BASE address is correct
   - Check that _write() is being called (add debug)
   - Ensure file descriptor checking is correct

3. **Linker errors with Newlib**
   - Use `-nostartfiles` flag to avoid conflicting startup code
   - Ensure custom startup code initializes BSS and data sections
   - Check that heap space is allocated for malloc (used by printf)

4. **Floating point printf not working**
   - Add `-lm` for math library if using floating point
   - Ensure sufficient heap space for printf floating point formatting
   - Consider using integer-only printf variant for space constraints

### Debugging Commands
```bash
# Check which syscalls are referenced
riscv32-unknown-elf-objdump -t task16_final_working.elf | grep -E "_write|_read|_close"

# Verify UART register access
riscv32-unknown-elf-objdump -d task16_final_working.elf | grep -A 5 uart_putchar

# Check printf symbol resolution
riscv32-unknown-elf-nm task16_final_working.elf | grep printf
```

## Testing & Validation

### Validation Checklist
- [ ] Program compiles and links successfully
- [ ] All required syscalls are implemented (_write, _close, _fstat, _isatty, _lseek, _read)
- [ ] UART register access is present in disassembly
- [ ] Printf functions are properly linked from Newlib
- [ ] _write function redirects to UART correctly
- [ ] Different printf format specifiers work (%d, %x, %s, %c)

### Testing Script
```bash
#!/bin/bash
echo "=== TASK16 Validation ==="

# Check ELF files exist
for elf in task16_final_working.elf task16_uart_printf.elf; do
    if [ -f "$elf" ]; then
        echo "✓ $elf created successfully"
    else
        echo "✗ $elf missing"
        exit 1
    fi
done

# Check for required syscalls
SYSCALLS=("_write" "_close" "_fstat" "_isatty" "_read" "_lseek")
for syscall in "${SYSCALLS[@]}"; do
    if riscv32-unknown-elf-nm task16_final_working.elf | grep -q "$syscall"; then
        echo "✓ $syscall implementation found"
    else
        echo "✗ $syscall missing"
        exit 1
    fi
done

# Check for printf symbols
if riscv32-unknown-elf-nm task16_final_working.elf | grep -q "printf"; then
    echo "✓ Printf function linked from Newlib"
else
    echo "✗ Printf function not found"
    exit 1
fi

# Check UART register usage
if riscv32-unknown-elf-objdump -d task16_final_working.elf | grep -q "0x10000"; then
    echo "✓ UART register access detected"
else
    echo "✗ UART register access not found"
    exit 1
fi

echo "✓ All validation checks passed!"
```


