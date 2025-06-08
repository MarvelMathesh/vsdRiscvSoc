# RISC-V Toolchain Setup and Configuration

Cross-compilation toolchain installation and environment configuration for RV32IMAC development.

## Objective

Install and configure the RISC-V GCC toolchain in WSL2 environment, establish proper PATH variables, and verify all essential development tools are functional for bare-metal and embedded RISC-V development.

## Key Learning Outcomes

- RISC-V toolchain architecture and component identification
- Cross-compilation environment setup and configuration
- PATH environment variable management in Linux systems
- Toolchain verification and validation procedures
- WSL2 file system navigation and permissions handling

## Prerequisites

- **Operating System**: Windows 10/11 with WSL2 enabled
- **WSL Distribution**: Ubuntu 22.04 or 24.04 LTS
- **Required Packages**: `wget`, `tar`, basic GNU utilities
- **Toolchain**: `riscv32-elf-ubuntu-24.04-gcc-nightly-2025.06.07-nightly.tar.xz`
- **Network Access**: Required for toolchain download

## Setup & Installation

### Download RISC-V Toolchain

```bash
# Download latest nightly build
wget https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2025.06.07/riscv32-elf-ubuntu-24.04-gcc-nightly-2025.06.07-nightly.tar.xz

# Verify download integrity
ls -la riscv32-elf-ubuntu-24.04-gcc-nightly-2025.06.07-nightly.tar.xz
```

### Extract and Install Toolchain

```bash
# Extract to home directory
tar -xf riscv32-elf-ubuntu-24.04-gcc-nightly-2025.06.07-nightly.tar.xz

# Move to standard location
mv riscv32-elf-ubuntu-24.04-gcc-nightly-2025.06.07-nightly ~/riscv
```

### Configure Environment Variables

```bash
# Add toolchain to PATH permanently
echo 'export PATH=$PATH:/home/mathesh/riscv/bin' >> ~/.bashrc

# Reload shell configuration
source ~/.bashrc

# Verify PATH configuration
echo $PATH | grep riscv
```

### Install Missing Dependencies

```bash
# Install required mathematical libraries
sudo apt update
sudo apt install libmpc3 libmpfr6 libgmp10
sudo apt install libmpc-dev libmpfr-dev libgmp-dev
```

## Technical Deep Dive

### RISC-V Toolchain Components

| Component | Purpose | Executable |
|-----------|---------|------------|
| **Compiler** | C/C++ to RISC-V assembly compilation | `riscv32-elf-gcc` |
| **Assembler** | Assembly to object code conversion | `riscv32-elf-as` |
| **Linker** | Object files to executable linking | `riscv32-elf-ld` |
| **Debugger** | Remote debugging and analysis | `riscv32-elf-gdb` |
| **Objdump** | Disassembly and analysis | `riscv32-elf-objdump` |
| **Objcopy** | Binary format conversion | `riscv32-elf-objcopy` |

### Toolchain Architecture

The RISC-V toolchain consists of several integrated components:

- **GCC Compiler**: `riscv32-unknown-elf-gcc` - Cross-compiler for RV32IMAC
- **GNU Binutils**: Assembler, linker, and binary utilities
- **GDB Debugger**: `riscv32-unknown-elf-gdb` - Target-specific debugger
- **Standard Libraries**: Newlib C library for embedded systems

### Target Architecture Specification

- **ISA**: RV32IMAC (32-bit base + Integer + Multiplication + Atomic + Compressed)
- **ABI**: ILP32 (Integer, Long, Pointer are 32-bit)
- **Toolchain Target**: `riscv32-unknown-elf` (bare-metal/embedded)

### Directory Structure

```
~/riscv/
├── bin/                    # Executable binaries
├── include/               # Header files
├── lib/                   # Static libraries
├── libexec/              # Internal executables
├── riscv32-unknown-elf/  # Target-specific files
└── share/                # Documentation and data
```

## Implementation Details

### Toolchain Verification Commands

```bash
# Verify GCC installation
riscv32-unknown-elf-gcc --version

# Check target architecture
riscv32-unknown-elf-gcc -dumpmachine

# Verify binutils
riscv32-unknown-elf-objdump --version
riscv32-unknown-elf-as --version

# Test GDB functionality
riscv32-unknown-elf-gdb --version

# List all available tools
ls -la ~/riscv/bin/ | grep riscv32
```

### Available Tools

| Tool | Purpose | Command |
|------|---------|---------|
| GCC | C/C++ Compiler | `riscv32-unknown-elf-gcc` |
| G++ | C++ Compiler | `riscv32-unknown-elf-g++` |
| AS | Assembler | `riscv32-unknown-elf-as` |
| LD | Linker | `riscv32-unknown-elf-ld` |
| OBJDUMP | Disassembler | `riscv32-unknown-elf-objdump` |
| OBJCOPY | Binary Converter | `riscv32-unknown-elf-objcopy` |
| GDB | Debugger | `riscv32-unknown-elf-gdb` |
| SIZE | Size Analyzer | `riscv32-unknown-elf-size` |

## Expected Output / Analysis Results

### Successful Installation Verification

```bash
$ riscv32-unknown-elf-gcc --version
riscv32-unknown-elf-gcc () 15.1.0
Copyright (C) 2025 Free Software Foundation, Inc.

$ riscv32-unknown-elf-objdump --version
GNU objdump (GNU Binutils) 2.44
Copyright (C) 2025 Free Software Foundation, Inc.

$ riscv32-unknown-elf-gdb --version
GNU gdb (GDB) 16.3
Copyright (C) 2024 Free Software Foundation, Inc.

$ riscv32-unknown-elf-gcc -dumpmachine
riscv32-unknown-elf
```

### Directory Listing Verification

```bash
$ ls -la ~/riscv/bin | grep riscv32
-rwxr-xr-x 1 mathesh mathesh  12784960 Jun  7 01:12 riscv32-unknown-elf-gcc
-rwxr-xr-x 1 mathesh mathesh   9886576 Jun  7 00:38 riscv32-unknown-elf-objdump
-rwxr-xr-x 1 mathesh mathesh 182618888 Jun  7 00:45 riscv32-unknown-elf-gdb
```

## Troubleshooting Guide

### Common Installation Issues

**Issue**: `libmpc.so.3: cannot open shared object file`
```bash
# Solution: Install missing math libraries
sudo apt install libmpc3 libmpfr6 libgmp10 libmpc-dev libmpfr-dev libgmp-dev
```

**Issue**: `command not found: riscv32-unknown-elf-gcc`
```bash
# Solution: Verify PATH configuration
echo $PATH | grep riscv
source ~/.bashrc
```

**Issue**: Permission denied errors during extraction
```bash
# Solution: Check file permissions and ownership
chmod +x ~/riscv/bin/riscv32-unknown-elf-*
```

### Dependency Resolution

```bash
# Check missing libraries
ldd ~/riscv/libexec/gcc/riscv32-unknown-elf/15.1.0/cc1

# Install comprehensive build dependencies
sudo apt install build-essential libc6-dev
```

## Testing & Validation

### Toolchain Functionality Test

```bash
# Create minimal test program
echo 'int main() { return 0; }' > test.c

# Compile test program
riscv32-unknown-elf-gcc -o test.elf test.c

# Verify ELF file generation
file test.elf
```

### Expected Test Results

```bash
$ file test.elf
test.elf: ELF 32-bit LSB executable, UCB RISC-V, RVC, soft-float ABI, version 1 (SYSV), statically linked, not stripped
```

## References

- [RISC-V GNU Toolchain Repository](https://github.com/riscv-collab/riscv-gnu-toolchain)
- [RISC-V International Specification](https://riscv.org/technical/specifications/)
- [GNU Binutils Documentation](https://sourceware.org/binutils/docs/)
- [WSL2 Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
