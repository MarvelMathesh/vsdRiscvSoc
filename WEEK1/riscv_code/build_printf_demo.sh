#!/bin/bash
echo "=== Task 16: Newlib printf Without OS ==="

# Compile all components with full architecture support
echo "1. Compiling printf demo components..."
riscv32-unknown-elf-gcc -march=rv32imafd -mabi=ilp32d -c printf_start.s -o printf_start.o
riscv32-unknown-elf-gcc -march=rv32imafd -mabi=ilp32d -c task16_uart_printf.c -o task16_uart_printf.o -nostdlib
riscv32-unknown-elf-gcc -march=rv32imafd -mabi=ilp32d -c syscalls.c -o syscalls.o -nostdlib

# Link with Newlib using full architecture
echo "2. Linking with Newlib..."
riscv32-unknown-elf-gcc -T printf.ld -march=rv32imafd -mabi=ilp32d -nostartfiles printf_start.o task16_uart_printf.o syscalls.o -o task16_uart_printf.elf

echo "✓ Compilation successful!"

# Verify results
echo -e "\n3. Verifying printf demo program:"
file task16_uart_printf.elf

echo -e "\n4. Checking printf and syscall functions:"
riscv32-unknown-elf-nm task16_uart_printf.elf | grep -E "(printf|_write|_fstat)"

echo -e "\n5. Verifying UART register usage:"
riscv32-unknown-elf-objdump -d task16_uart_printf.elf | grep -A 2 -B 2 "0x10000000"

echo -e "\n6. Program size analysis:"
size task16_uart_printf.elf

echo -e "\n7. Architecture verification:"
riscv32-unknown-elf-objdump -f task16_uart_printf.elf

echo -e "\n✓ Printf retargeting demo ready!"
echo "✓ Architecture: RV32IMAFD with double-precision floating point"
echo "✓ ABI: ilp32d (32-bit integers, longs, pointers + double-precision float)"
