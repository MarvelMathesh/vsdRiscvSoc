#!/bin/bash
echo "=== Task 12: Bare-Metal LED Blink Build ==="

# Clean previous builds
rm -f *.o *.elf

# Compile assembly startup
echo "1. Compiling startup assembly..."
riscv32-unknown-elf-gcc -c led_start.s -o led_start.o -march=rv32imc -mabi=ilp32

# Compile C program with correct architecture
echo "2. Compiling LED blink program..."
riscv32-unknown-elf-gcc -c led_blink.c -o led_blink.o -O2 -march=rv32imc -mabi=ilp32 -nostdlib

# Check if compilation succeeded
if [ ! -f led_blink.o ]; then
    echo "ERROR: C compilation failed!"
    exit 1
fi

# Link with custom linker script
echo "3. Linking with custom memory layout..."
riscv32-unknown-elf-ld -T led_blink.ld led_start.o led_blink.o -o led_blink.elf

# Check if linking succeeded
if [ ! -f led_blink.elf ]; then
    echo "ERROR: Linking failed!"
    exit 1
fi

# Verify build
echo "4. Verifying build results..."
file led_blink.elf

echo -e "\n5. Memory layout verification:"
riscv32-unknown-elf-objdump -h led_blink.elf | grep -E "\.(text|data|bss)"

echo -e "\n6. Symbol table (first 15 entries):"
riscv32-unknown-elf-nm led_blink.elf | head -15

echo -e "\n7. Program size analysis:"
size led_blink.elf

echo -e "\n✓ LED Blink bare-metal program ready!"
echo "✓ GPIO registers mapped at 0x10012000"
echo "✓ LED pins: Red(22), Green(19), Blue(21)"
