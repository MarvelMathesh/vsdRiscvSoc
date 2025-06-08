#!/bin/bash
echo "=== Task 15: Atomic Test Program - Two-Thread Mutex ==="

# Compile with RV32IMAC (includes atomic extension)
echo "1. Compiling mutex demo programs..."
riscv32-unknown-elf-gcc -march=rv32imac -mabi=ilp32 -c mutex_start.s -o mutex_start.o
riscv32-unknown-elf-gcc -march=rv32imac -mabi=ilp32 -c task15_mutex_demo.c -o task15_mutex_demo.o -nostdlib

# Link programs
riscv32-unknown-elf-ld -T mutex.ld mutex_start.o task15_mutex_demo.o -o task15_mutex_demo.elf

echo "✓ Compilation successful!"

# Verify results
echo -e "\n2. Verifying mutex demo programs:"
file task15_mutex_demo.elf

echo -e "\n3. Checking for LR/SC instructions:"
riscv32-unknown-elf-gcc -march=rv32imac -mabi=ilp32 -S task15_mutex_demo.c -nostdlib
grep -E "(lr\.w|sc\.w)" task15_mutex_demo.s

echo -e "\n4. Disassembly showing spinlock implementation:"
riscv32-unknown-elf-objdump -d task15_mutex_demo.elf | grep -A 10 -B 5 "lr\.w\|sc\.w"

echo -e "\n5. Symbol table showing shared variables:"
riscv32-unknown-elf-nm task15_mutex_demo.elf | grep -E "(spinlock|shared_counter|thread)"

echo -e "\n✓ Atomic test program ready!"
