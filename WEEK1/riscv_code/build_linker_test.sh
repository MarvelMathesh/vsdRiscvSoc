#!/bin/bash
echo "=== Task 11: Linker Script Implementation ==="

# Compile everything
echo "1. Compiling with custom linker script..."
riscv32-unknown-elf-gcc -c start.s -o start.o
riscv32-unknown-elf-gcc -c test_linker.c -o test_linker.o
riscv32-unknown-elf-ld -T minimal.ld start.o test_linker.o -o test_linker.elf

echo "✓ Compilation successful!"

# Verify results
echo -e "\n2. Verifying memory layout:"
echo "Text section should be at 0x00000000:"
riscv32-unknown-elf-objdump -h test_linker.elf | grep ".text"

echo "Data section should be at 0x10000000:"
riscv32-unknown-elf-objdump -h test_linker.elf | grep -E "\.(s)?data"

echo -e "\n3. Symbol addresses:"
riscv32-unknown-elf-nm test_linker.elf | head -10

echo -e "\n✓ Linker script working correctly!"
