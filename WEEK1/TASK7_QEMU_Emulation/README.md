# RISC-V QEMU Emulation and Execution

Execute RISC-V ELF binaries using QEMU emulation in user and system modes.

## Objective

Execute RISC-V ELF binaries using QEMU emulation, understand the difference between system and user-mode emulation, address OpenSBI firmware requirements, and successfully run cross-compiled programs in an emulated RISC-V environment.

## Key Learning Outcomes

- Master QEMU RISC-V emulation modes and configurations
- Understand system vs user-mode emulation differences
- Learn to handle OpenSBI firmware requirements
- Practice debugging emulation issues and environment setup
- Gain experience with cross-platform program execution

## Prerequisites

- Completed TASK1 (RISC-V toolchain setup)
- Completed TASK2 (hello.c compiled to hello.elf)
- QEMU installed with RISC-V support
- Understanding of ELF binary format
- Basic knowledge of system emulation concepts

## Setup & Installation

### Install QEMU with RISC-V Support

```bash
# Install QEMU for RISC-V emulation
sudo apt update
sudo apt install qemu-system-riscv32 qemu-user-static

# Verify QEMU installation
qemu-system-riscv32 --version
qemu-riscv32-static --version
```

### Verify Target Binary

```bash
# Ensure hello.elf exists from previous task
ls -la hello.elf
file hello.elf
```

## Technical Deep Dive

### QEMU Emulation Modes

QEMU provides two primary emulation modes for RISC-V:

#### 1. User-Mode Emulation (`qemu-riscv32-static`)
- **Purpose**: Execute single ELF binaries in user space
- **Advantages**: Simpler setup, direct binary execution
- **Limitations**: No full system emulation, limited I/O
- **Use Case**: Basic program testing and validation

#### 2. System Emulation (`qemu-system-riscv32`)
- **Purpose**: Full RISC-V system simulation
- **Advantages**: Complete hardware emulation, full OS support
- **Requirements**: Bootloader, kernel, firmware (OpenSBI)
- **Use Case**: Operating system development, full system testing

### OpenSBI Firmware

OpenSBI (Open Source Supervisor Binary Interface) is the reference implementation of the RISC-V SBI specification:
- **Function**: Provides runtime services for RISC-V systems
- **Required For**: System-mode emulation
- **Components**: Bootloader, runtime services, platform abstraction

## Implementation Details

### Step 1: User-Mode Emulation (Recommended)

Execute the ELF binary directly using user-mode emulation:

```bash
# Run hello.elf using user-mode emulation
qemu-riscv32-static hello.elf

# Alternative with explicit library path
qemu-riscv32-static -L /usr/riscv32-linux-gnu hello.elf
```

### Step 2: System-Mode Emulation (Advanced)

For full system emulation, additional components are required:

```bash
# Attempt system-mode emulation (will show firmware requirement)
qemu-system-riscv32 -M virt -kernel hello.elf

# Download OpenSBI firmware (if needed)
wget https://github.com/riscv/opensbi/releases/download/v1.2/opensbi-1.2-rv-bin.tar.xz
tar -xf opensbi-1.2-rv-bin.tar.xz

# System emulation with OpenSBI
qemu-system-riscv32 -M virt -bios opensbi-1.2-rv-bin/share/opensbi/lp64/generic/firmware/fw_jump.elf -kernel hello.elf
```

### Step 3: Emulation Debugging

Enable debugging and verbose output:

```bash
# User-mode with debugging
qemu-riscv32-static -d in_asm,cpu hello.elf

# System-mode with serial output
qemu-system-riscv32 -M virt -nographic -serial stdio -kernel hello.elf
```

### Step 4: Performance Analysis

Compare emulation performance:

```bash
# Time the execution
time qemu-riscv32-static hello.elf

# Monitor system resources
qemu-system-riscv32 -M virt -monitor stdio -kernel hello.elf
```

## Output

### Successful User-Mode Execution
```
$ qemu-riscv32-static hello.elf
Hello, RISC-V!
```

### System-Mode Firmware Error
```
$ qemu-system-riscv32 -M virt -kernel hello.elf
qemu-system-riscv32: Unable to load the RISC-V firmware "opensbi-riscv32-generic-fw_dynamic.elf"
```

### Successful System-Mode with OpenSBI
```
$ qemu-system-riscv32 -M virt -bios fw_jump.elf -kernel hello.elf

OpenSBI v1.2
   ____                    _____ ____ _____
  / __ \                  / ____|  _ \_   _|
 | |  | |_ __   ___ _ __ | (___ | |_) || |
 | |  | | '_ \ / _ \ '_ \ \___ \|  _ < | |
 | |__| | |_) |  __/ | | |____) | |_) || |_
  \____/| .__/ \___|_| |_|_____/|____/_____|
        | |
        |_|

Platform Name             : riscv-virtio,qemu
Platform Features         : medeleg
Platform HART Count       : 1

Hello, RISC-V!
```

## Troubleshooting

### Issue: QEMU Not Found
```
bash: qemu-riscv32-static: command not found
```
**Solution**: Install QEMU with RISC-V support:
```bash
sudo apt install qemu-user-static
```

### Issue: OpenSBI Firmware Missing
```
qemu-system-riscv32: Unable to load the RISC-V firmware
```
**Solution**: Use user-mode emulation or download OpenSBI firmware:
```bash
# Use user-mode instead
qemu-riscv32-static hello.elf

# Or download OpenSBI for system-mode
wget https://github.com/riscv/opensbi/releases/latest
```

### Issue: Segmentation Fault
```
qemu: uncaught target signal 11 (Segmentation fault)
```
**Solution**: Check binary compatibility and compilation flags:
```bash
file hello.elf
readelf -h hello.elf
```

### Issue: No Output in System Mode
```
# QEMU hangs or shows no output
```
**Solution**: Use `-nographic` and `-serial stdio` options:
```bash
qemu-system-riscv32 -M virt -nographic -serial stdio -kernel hello.elf
```

## Testing & Validation

### Validation Checklist

1. **QEMU Installation Verification**:
   ```bash
   qemu-riscv32-static --version | head -1
   qemu-system-riscv32 --version | head -1
   ```

2. **User-Mode Execution Test**:
   ```bash
   qemu-riscv32-static hello.elf
   # Expected: "Hello, RISC-V!"
   ```

3. **Binary Compatibility Check**:
   ```bash
   file hello.elf
   # Expected: ELF 32-bit LSB executable, UCB RISC-V   ```

4. **System-Mode Firmware Check**:
   ```bash
   qemu-system-riscv32 -M virt -kernel hello.elf 2>&1 | grep -i firmware
   ```

## References

- [QEMU RISC-V Documentation](https://qemu.readthedocs.io/en/latest/system/target-riscv.html)
- [OpenSBI Documentation](https://github.com/riscv/opensbi/blob/master/docs/README.md)
- [RISC-V QEMU Wiki](https://wiki.qemu.org/Documentation/Platforms/RISCV)
- [QEMU User Mode Emulation](https://qemu.readthedocs.io/en/latest/user/index.html)
- [RISC-V SBI Specification](https://github.com/riscv/riscv-sbi-doc)