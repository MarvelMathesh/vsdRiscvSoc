# RISC-V GDB Static Analysis and Debugging

Static analysis and debugging setup for RISC-V ELF binaries using cross-platform GDB.

## Objective

Demonstrate static analysis and debugging capabilities of the RISC-V GDB debugger on compiled ELF binaries, including symbol inspection, disassembly examination, and debugging session setup without execution.

## Key Learning Outcomes

- Master GDB for RISC-V cross-platform debugging
- Understand static analysis techniques for ELF binaries
- Learn symbol table inspection and function analysis
- Practice debugging session setup and navigation
- Gain proficiency in examining compiled binary structure

## Prerequisites

- **Completed Tasks**: TASK1 (toolchain setup), TASK2 (hello.elf binary)
- **Knowledge**: Basic GDB debugging concepts and ELF binary format
- **Tools**: RISC-V GDB debugger and compiled ELF binary

## Technical Deep Dive

### GDB Static Analysis Overview

GDB (GNU Debugger) provides powerful static analysis capabilities that allow examination of binary structure, symbols, and assembly code without executing the program. For RISC-V cross-development, this is essential for:

- **Symbol Table Analysis**: Inspect functions, variables, and their memory locations
- **Disassembly Inspection**: Examine generated RISC-V assembly code
- **Binary Structure**: Understand program layout and sections
- **Debug Information**: Access source-to-assembly mapping when available

### RISC-V-Specific GDB Features

The RISC-V GDB implementation includes:
- Support for RV32I/M/A/C instruction sets
- RISC-V register naming conventions
- Cross-platform debugging capabilities
- Static analysis without target hardware

## Implementation Details

### Step 1: Launch GDB Session

Start GDB with the compiled ELF binary:

```bash
# Launch GDB with hello.elf
riscv32-unknown-elf-gdb hello.elf
```

### Step 2: Symbol Table Inspection

Examine the binary's symbol information:

```gdb
# Display all symbols
info symbols

# Show function symbols specifically
info functions

# List variables and their locations
info variables

# Examine specific symbol details
info symbol main
```

### Step 3: Disassembly Analysis

Analyze the generated RISC-V assembly:

```gdb
# Disassemble main function
disassemble main

# Disassemble specific address range
disassemble 0x10000,0x10100

# Show mixed source and assembly (if debug info available)
set disassemble-next-line on
```

### Step 4: Binary Structure Examination

Investigate the ELF file structure:

```gdb
# Display section information
maintenance info sections

# Show program headers
info target

# Examine memory layout
info files
```

### Step 5: Register and Memory Analysis

Prepare for future debugging sessions:

```gdb
# Show available registers (static view)
info registers

# Display RISC-V specific registers
info all-registers

# Set breakpoints for future execution
break main
break _start
```

## Output

### GDB Version Information
```
GNU gdb (GDB) X.X
This GDB was configured as "--host=x86_64-linux-gnu --target=riscv32-unknown-elf"
```

### Symbol Table Output
```
All defined functions:
0x00010000  _start
0x00010074  main
0x000100a8  printf
```

### Disassembly of main()
```asm
Dump of assembler code for function main:
   0x00010074 <+0>:     addi    sp,sp,-16
   0x00010078 <+4>:     sw      ra,12(sp)
   0x0001007c <+8>:     lui     a0,0x10
   0x00010080 <+12>:    addi    a0,a0,184
   0x00010084 <+16>:    jal     ra,0x100a8 <printf>
   0x00010088 <+20>:    li      a0,0
   0x0001008c <+24>:    lw      ra,12(sp)
   0x00010090 <+28>:    addi    sp,sp,16
   0x00010094 <+32>:    jr      ra
```

## Troubleshooting

### Issue: GDB Cannot Find Binary
```
Error: "hello.elf": No such file or directory
```
**Solution**: Ensure you're in the correct directory or provide full path to ELF file.

### Issue: No Debug Information
```
Warning: debugging info missing
```
**Solution**: Compile with `-g` flag for debug symbols, or use static analysis features only.

### Issue: Cross-Platform Symbols
```
Error: Architecture mismatch
```
**Solution**: Ensure using `riscv32-unknown-elf-gdb`, not system `gdb`.

## Testing & Validation

### Validation Checklist

1. **GDB Launch Test**:
   ```bash
   riscv32-unknown-elf-gdb hello.elf | head -5
   ```

2. **Symbol Detection**:
   ```gdb
   (gdb) info functions
   # Should show main, _start, and library functions
   ```

3. **Disassembly Verification**:
   ```gdb
   (gdb) disassemble main
   # Should show RISC-V assembly instructions
   ```

4. **Exit Test**:
   ```gdb
   (gdb) quit
   ```

## References

- [GDB User Manual](https://sourceware.org/gdb/current/onlinedocs/gdb/)
- [RISC-V GDB Documentation](https://github.com/riscv/riscv-gnu-toolchain)
- [ELF Format Specification](https://refspecs.linuxfoundation.org/elf/elf.pdf)
- [Cross-Platform Debugging Guide](https://sourceware.org/gdb/current/onlinedocs/gdb/Remote-Debugging.html)

