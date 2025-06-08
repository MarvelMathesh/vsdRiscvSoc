#!/bin/bash
echo "=== Task 14: Atomic Extension Demonstration ==="

# Compile with RV32IMAC (includes atomic extension)
echo "1. Compiling with atomic extension (RV32IMAC)..."
riscv32-unknown-elf-gcc -march=rv32imac -mabi=ilp32 -c atomic_start.s -o atomic_start.o
riscv32-unknown-elf-gcc -march=rv32imac -mabi=ilp32 -c task14_atomic_demo.c -o task14_atomic_demo.o -nostdlib
riscv32-unknown-elf-ld -T atomic.ld atomic_start.o task14_atomic_demo.o -o task14_atomic_demo.elf

echo "2. Compiling without atomic extension (RV32IMC)..."
riscv32-unknown-elf-gcc -march=rv32imc -mabi=ilp32 -c task14_non_atomic.c -o task14_non_atomic.o -nostdlib
riscv32-unknown-elf-ld -T atomic.ld atomic_start.o task14_non_atomic.o -o task14_non_atomic.elf

echo "✓ Compilation successful!"

# Verify results
echo ""
echo "3. Verifying atomic operations program:"
file task14_atomic_demo.elf

echo ""
echo "4. Checking for atomic instructions:"
riscv32-unknown-elf-gcc -march=rv32imac -mabi=ilp32 -S task14_atomic_demo.c -nostdlib
grep -E "(lr\.w|sc\.w|amoadd|amoswap|amoand|amoor)" task14_atomic_demo.s

echo ""
echo "5. Disassembly showing atomic instructions:"
riscv32-unknown-elf-objdump -d task14_atomic_demo.elf | grep -A 2 -B 2 "lr\.w\|sc\.w\|amo"

echo ""
echo "✓ Atomic extension demonstration ready!"
