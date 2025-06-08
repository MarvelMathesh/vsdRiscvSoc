# Hex Dump & Disassembly Analysis

Convert compiled RISC-V binary to Intel HEX format and perform comprehensive disassembly analysis.

## Objective

Convert the compiled RISC-V ELF binary to Intel HEX format for embedded deployment, generate detailed disassembly output, analyze machine code instruction encoding, and understand the relationship between assembly mnemonics and binary representation.

## Key Learning Outcomes

- Binary format conversion and embedded deployment preparation
- Machine code instruction encoding and decoding
- Memory layout analysis and section organization
- Instruction address mapping and program counter flow
- Intel HEX format structure and embedded programming workflows

## Prerequisites

- **Completed Tasks**: Tasks 1-3 (Toolchain, Compilation, Assembly)
- **Required Files**: `hello.elf` binary from Task 2
- **Tools**: `objdump`, `objcopy`, `hexdump`, `file` utilities
- **Knowledge**: Basic understanding of hexadecimal and binary formats

## Setup & Installation

### Verify Required Files

```bash
# Ensure compiled binary exists
cd ~/riscv_code
ls -la hello.elf

# Verify binary format
file hello.elf
```

### Required Tools Check

```bash
# Verify objdump and objcopy availability
which riscv32-unknown-elf-objdump
which riscv32-unknown-elf-objcopy
```

## Technical Deep Dive

### Binary Analysis Workflow

1. **Disassembly Generation**: Convert machine code to assembly mnemonics
2. **Hex Format Conversion**: Transform ELF to Intel HEX for embedded deployment
3. **Instruction Encoding Analysis**: Examine machine code representation
4. **Memory Layout Inspection**: Understand section organization and addressing

### Intel HEX Format Structure

```
:LLAAAATT[DD...]CC
```

Where:
- **LL**: Byte count (data length)
- **AAAA**: Address (16-bit)
- **TT**: Record type (00=data, 01=EOF, 04=extended address)
- **DD**: Data bytes
- **CC**: Checksum (two's complement)

### RISC-V Instruction Encoding

RISC-V uses multiple instruction formats:
- **R-type**: Register-register operations
- **I-type**: Immediate operations
- **S-type**: Store operations
- **B-type**: Branch operations
- **U-type**: Upper immediate operations
- **J-type**: Jump operations

## Implementation Details

### Complete Disassembly Generation

```bash
# Generate comprehensive disassembly
riscv32-unknown-elf-objdump -d hello.elf > hello.dump

# Verify disassembly file creation
ls -la hello.dump
wc -l hello.dump
```

### Intel HEX Conversion

```bash
# Convert ELF binary to Intel HEX format
riscv32-unknown-elf-objcopy -O ihex hello.elf hello.hex

# Verify HEX file creation and format
ls -la hello.hex
file hello.hex
head -10 hello.hex
```

### Main Function Disassembly Analysis

```bash
# Extract main function disassembly
grep -A 20 "<main>:" hello.dump

# Analyze with context
grep -B 5 -A 20 "<main>:" hello.dump
```

### Binary Size Comparison

```bash
# Compare file sizes across formats
echo "=== File Size Comparison ==="
ls -la hello.c hello.s hello.elf hello.hex hello.dump

# Line count analysis
echo "=== Line Count Analysis ==="
wc -l hello.c hello.s hello.dump hello.hex
```

## Expected Output / Analysis Results

### Disassembly Output Structure

```assembly
hello.elf:     file format elf32-littleriscv

Disassembly of section .text:

00010000 <_start>:
   10000:	02c00093          	li	ra,44
   10004:	00001097          	auipc	ra,0x1
   10008:	ffc08093          	addi	ra,ra,-4

00010162 <main>:
   10162:	1141                	addi	sp,sp,-16
   10164:	c606                	sw	ra,12(sp)
   10166:	c422                	sw	s0,8(sp)
   10168:	0800                	addi	s0,sp,16
   1016a:	000127b7          	lui	a5,0x12
   1016c:	45c78513          	addi	a0,a5,1116 # 1245c <__global_pointer$+0x5c>
   10170:	36e000ef          	jal	ra,104de <puts>
   10174:	4781                	li	a5,0
   10176:	853e                	mv	a0,a5
   10178:	40b2                	lw	ra,12(sp)
   1017a:	4422                	lw	s0,8(sp)
   1017c:	0141                	addi	sp,sp,16
   1017e:	8082                	ret
```

### Instruction Encoding Analysis

| Address | Machine Code | Assembly | Instruction Type |
|---------|--------------|----------|------------------|
| `10162` | `1141` | `addi sp,sp,-16` | I-type (16-bit compressed) |
| `10164` | `c606` | `sw ra,12(sp)` | S-type (16-bit compressed) |
| `1016a` | `000127b7` | `lui a5,0x12` | U-type (32-bit) |
| `1016c` | `45c78513` | `addi a0,a5,1116` | I-type (32-bit) |
| `10170` | `36e000ef` | `jal ra,104de` | J-type (32-bit) |

### Intel HEX Output Sample

```hex
:020000040001F9
:10000000930C2002970100000830C0FF832301008F
:10001000B3010130930100309301003093010030B1
:10002000B301013093010030930100309301003091
:10003000B30101309301003093010030930100307F
:100040009301003093010030B30101309301003061
:10005000930100309301003093010030B301013041
:1000600093010030930100309301003093010030FF
:00000001FF
```

### Key Analysis Results

#### Disassembly Characteristics
- **Compressed Instructions**: Extensive use of 16-bit RV32C encoding
- **Address Layout**: Sequential instruction placement
- **Function Boundaries**: Clear start/end demarcation
- **Call Targets**: Resolved function addresses

#### HEX Format Characteristics
- **Record Types**: Data records (00) and EOF record (01)
- **Address Range**: 32-bit addressing with extended address records
- **Data Density**: Efficient binary representation
- **Checksum Validation**: Error detection capability

### Performance Metrics

```bash
# Instruction count in main function
$ grep -E "^\s+[0-9a-f]+:" hello.dump | grep -A 15 "main>:" | wc -l
13

# Compressed vs standard instruction ratio
$ grep -E "^\s+[0-9a-f]+:\s+[0-9a-f]{4}\s" hello.dump | wc -l  # 16-bit
$ grep -E "^\s+[0-9a-f]+:\s+[0-9a-f]{8}\s" hello.dump | wc -l  # 32-bit
```

## Testing & Validation

### Disassembly Verification

```bash
# Verify disassembly completeness
grep -c "<.*>:" hello.dump

# Check for main function presence
grep -q "<main>:" hello.dump && echo "✓ Main function found"

# Validate instruction format
grep -E "^\s+[0-9a-f]+:\s+[0-9a-f]+" hello.dump | head -5
```

### Intel HEX Validation

```bash
# Check HEX format validity
head -1 hello.hex | grep -q "^:" && echo "✓ Valid HEX format"

# Verify EOF record
tail -1 hello.hex | grep -q ":00000001FF" && echo "✓ Valid EOF record"

# Calculate total data bytes
grep -v ":00000001FF" hello.hex | cut -c2-3 | paste -sd+ | bc
```

### Binary Integrity Check

```bash
# Convert HEX back to binary for verification
riscv32-unknown-elf-objcopy -I ihex -O elf32-littleriscv hello.hex hello_restored.elf

# Compare original and restored binaries
diff <(riscv32-unknown-elf-objdump -d hello.elf) <(riscv32-unknown-elf-objdump -d hello_restored.elf)
```

## Troubleshooting Guide

### Disassembly Issues

**Issue**: Empty or incomplete disassembly
```bash
# Solution: Check binary format and sections
riscv32-unknown-elf-objdump -h hello.elf
riscv32-unknown-elf-objdump -t hello.elf
```

**Issue**: Missing function symbols
```bash
# Solution: Include debug symbols or use address ranges
riscv32-unknown-elf-objdump -d --start-address=0x10162 hello.elf
```

### HEX Conversion Issues

**Issue**: HEX file too large or malformed
```bash
# Solution: Check sections being converted
riscv32-unknown-elf-objcopy -j .text -j .rodata -O ihex hello.elf hello.hex
```

**Issue**: Invalid HEX records
```bash
# Solution: Verify objcopy parameters
riscv32-unknown-elf-objcopy --help | grep ihex
```

### Analysis Issues

**Issue**: Instruction encoding unclear
```bash
# Solution: Use detailed disassembly format
riscv32-unknown-elf-objdump -d -M numeric hello.elf
```

## References

- [Intel HEX Format Specification](https://en.wikipedia.org/wiki/Intel_HEX)
- [GNU Binutils objdump Documentation](https://sourceware.org/binutils/docs/binutils/objdump.html)
- [RISC-V Instruction Encoding](https://riscv.org/technical/specifications/)
- [ELF to HEX Conversion Guide](https://sourceware.org/binutils/docs/binutils/objcopy.html)
