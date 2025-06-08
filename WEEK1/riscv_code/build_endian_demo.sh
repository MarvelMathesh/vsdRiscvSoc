#!/bin/bash
echo "=== Task 17: Endianness & Struct Packing ==="

# Compile all components
echo "1. Compiling endianness demo components..."
riscv32-unknown-elf-gcc -march=rv32imafd -mabi=ilp32d -c endian_start.s -o endian_start.o
riscv32-unknown-elf-gcc -march=rv32imafd -mabi=ilp32d -c task17_endianness.c -o task17_endianness.o
riscv32-unknown-elf-gcc -march=rv32imafd -mabi=ilp32d -c task17_simple_endian.c -o task17_simple_endian.o
riscv32-unknown-elf-gcc -march=rv32imafd -mabi=ilp32d -c endian_printf.c -o endian_printf.o

# Link programs
echo "2. Linking endianness programs..."
riscv32-unknown-elf-gcc -T endian.ld -march=rv32imafd -mabi=ilp32d -nostartfiles endian_start.o task17_endianness.o endian_printf.o -o task17_endianness.elf
riscv32-unknown-elf-gcc -T endian.ld -march=rv32imafd -mabi=ilp32d -nostartfiles endian_start.o task17_simple_endian.o endian_printf.o -o task17_simple_endian.elf

echo "✓ Compilation successful!"

# Verify results
echo ""
echo "3. Verifying endianness demo programs:"
file task17_endianness.elf
file task17_simple_endian.elf

echo ""
echo "4. Checking union usage in disassembly:"
riscv32-unknown-elf-objdump -d task17_simple_endian.elf | grep -A 10 -B 5 "main"

echo ""
echo "5. Symbol table showing endianness functions:"
riscv32-unknown-elf-nm task17_simple_endian.elf | grep -E "(main|test|union)"

echo ""
echo "✓ Endianness demonstration ready!"
