# RISC-V ABI & Register Reference Documentation

Comprehensive reference documentation for RISC-V calling conventions and register usage patterns.

## Objective

Create a complete technical reference for all 32 RISC-V integer registers, document calling convention rules, analyze ABI compliance in generated code, and establish a practical cheat sheet for RISC-V development.

## Key Learning Outcomes

- RISC-V register file architecture and naming conventions
- Function calling convention rules and stack management
- ABI compliance verification and validation techniques
- Register preservation requirements across function calls
- Assembly code analysis for ABI conformance

## Prerequisites

- **Completed Tasks**: Tasks 1-4 (Assembly analysis from Task 3 required)
- **Assembly File**: `hello.s` from Task 3 for ABI compliance verification
- **Knowledge**: Basic computer architecture and calling convention concepts
- **Tools**: Text editor, grep, and analysis utilities

## Setup & Installation

### Verify Prerequisites

```bash
# Navigate to working directory
cd ~/riscv_code

# Confirm assembly file exists from previous task
ls -la hello.s
```

## Technical Deep Dive

### RISC-V Register Architecture

The RISC-V architecture defines 32 general-purpose integer registers (x0-x31), each with specific roles defined by the Application Binary Interface (ABI).

#### Register Categories

1. **Special Purpose**: x0 (zero), x1 (ra), x2 (sp), x3 (gp), x4 (tp)
2. **Temporary Registers**: x5-x7 (t0-t2), x28-x31 (t3-t6)
3. **Saved Registers**: x8-x9 (s0-s1), x18-x27 (s2-s11)  
4. **Argument Registers**: x10-x17 (a0-a7)

### Calling Convention Rules

#### Stack Management
- **Alignment**: 16-byte alignment requirement
- **Growth Direction**: Stack grows downward (decreasing addresses)
- **Frame Pointer**: Optional use of s0/fp for stack frame management

#### Register Preservation
- **Caller-saved**: Must be preserved by calling function if needed after call
- **Callee-saved**: Must be preserved by called function if modified

## Implementation Details

### Complete Register Reference Table

```bash
# Create comprehensive register mapping
cat > risc_v_register_table.md << 'EOF'
# Complete RISC-V Integer Register Reference

| Register | ABI Name | Type | Calling Convention | Preserved Across Calls | Description |
|----------|----------|------|-------------------|------------------------|-------------|
| **x0** | `zero` | Special | Hard-wired zero | — (Immutable) | Always contains 0, writes ignored |
| **x1** | `ra` | Link | Caller-saved | No | Return address |
| **x2** | `sp` | Pointer | Callee-saved | Yes | Stack pointer (16-byte aligned) |
| **x3** | `gp` | Pointer | Unallocatable | — | Global pointer |
| **x4** | `tp` | Pointer | Unallocatable | — | Thread pointer |
| **x5** | `t0` | Temporary | Caller-saved | No | Temporary register 0 |
| **x6** | `t1` | Temporary | Caller-saved | No | Temporary register 1 |
| **x7** | `t2` | Temporary | Caller-saved | No | Temporary register 2 |
| **x8** | `s0/fp` | Saved | Callee-saved | Yes | Saved register 0 / Frame pointer |
| **x9** | `s1` | Saved | Callee-saved | Yes | Saved register 1 |
| **x10** | `a0` | Argument | Caller-saved | No | Function argument 0 / Return value 0 |
| **x11** | `a1` | Argument | Caller-saved | No | Function argument 1 / Return value 1 |
| **x12** | `a2` | Argument | Caller-saved | No | Function argument 2 |
| **x13** | `a3` | Argument | Caller-saved | No | Function argument 3 |
| **x14** | `a4` | Argument | Caller-saved | No | Function argument 4 |
| **x15** | `a5` | Argument | Caller-saved | No | Function argument 5 |
| **x16** | `a6` | Argument | Caller-saved | No | Function argument 6 |
| **x17** | `a7` | Argument | Caller-saved | No | Function argument 7 |
| **x18** | `s2` | Saved | Callee-saved | Yes | Saved register 2 |
| **x19** | `s3` | Saved | Callee-saved | Yes | Saved register 3 |
| **x20** | `s4` | Saved | Callee-saved | Yes | Saved register 4 |
| **x21** | `s5` | Saved | Callee-saved | Yes | Saved register 5 |
| **x22** | `s6` | Saved | Callee-saved | Yes | Saved register 6 |
| **x23** | `s7` | Saved | Callee-saved | Yes | Saved register 7 |
| **x24** | `s8` | Saved | Callee-saved | Yes | Saved register 8 |
| **x25** | `s9` | Saved | Callee-saved | Yes | Saved register 9 |
| **x26** | `s10` | Saved | Callee-saved | Yes | Saved register 10 |
| **x27** | `s11` | Saved | Callee-saved | Yes | Saved register 11 |
| **x28** | `t3` | Temporary | Caller-saved | No | Temporary register 3 |
| **x29** | `t4` | Temporary | Caller-saved | No | Temporary register 4 |
| **x30** | `t5` | Temporary | Caller-saved | No | Temporary register 5 |
| **x31** | `t6` | Temporary | Caller-saved | No | Temporary register 6 |
EOF
```

### Calling Convention Summary

```bash
# Create calling convention documentation
cat > calling_convention_summary.md << 'EOF'
# RISC-V Calling Convention Summary

## Function Arguments and Return Values:
- **a0-a7 (x10-x17)**: Function arguments and return values
- **a0-a1**: Also used for return values (up to 64-bit returns)
- **Arguments beyond a7**: Passed on stack

## Callee-Saved Registers (Must preserve if used):
- **sp (x2)**: Stack pointer - MUST always be preserved
- **s0-s11 (x8-x9, x18-x27)**: Saved registers - function must restore if modified
- **s0/fp (x8)**: Often used as frame pointer

## Caller-Saved Registers (Can freely modify):
- **ra (x1)**: Return address - caller saves if needed across calls
- **t0-t6 (x5-x7, x28-x31)**: Temporary registers - no preservation required
- **a0-a7 (x10-x17)**: Argument registers - caller saves if values needed after call

## Special Purpose Registers:
- **zero (x0)**: Always zero, writes ignored
- **gp (x3)**: Global pointer - unallocatable by compiler
- **tp (x4)**: Thread pointer - unallocatable by compiler
EOF
```

### ABI Compliance Analysis

```bash
# Analyze register usage in hello.s assembly
echo "=== ABI Compliance Analysis ==="
grep -E "(ra|sp|s0|a0|a5)" ../hello.s

# Check stack alignment compliance
echo "=== Stack Alignment Check ==="
grep "addi.*sp.*-16" ../hello.s && echo "✓ 16-byte stack alignment"

# Verify register preservation
echo "=== Register Preservation Verification ==="
grep "sw.*ra" ../hello.s && echo "✓ Return address preserved"
grep "sw.*s0" ../hello.s && echo "✓ Frame pointer preserved"
```

### Register Lookup Utility

```bash
# Create practical lookup script
cat > register_lookup.sh << 'EOF'
#!/bin/bash
# RISC-V Register Quick Lookup
case $1 in
    "x0"|"zero") echo "x0 (zero): Hard-wired zero, always 0" ;;
    "x1"|"ra") echo "x1 (ra): Return address, caller-saved" ;;
    "x2"|"sp") echo "x2 (sp): Stack pointer, callee-saved, 16-byte aligned" ;;
    "x8"|"s0"|"fp") echo "x8 (s0/fp): Saved register 0 / Frame pointer, callee-saved" ;;
    "x10"|"a0") echo "x10 (a0): Argument 0 / Return value 0, caller-saved" ;;
    "t"*) echo "Temporary register: caller-saved, can be freely modified" ;;
    "s"*) echo "Saved register: callee-saved, must be preserved if used" ;;
    "a"*) echo "Argument register: caller-saved, used for function parameters" ;;
    *) echo "Usage: $0 <register_name>" ;;
esac
EOF

chmod +x register_lookup.sh
```

## Output

### Assembly Code ABI Compliance Verification

From `hello.s` analysis, the following ABI compliance is demonstrated:

```assembly
main:
    addi sp,sp,-16     # ✓ 16-byte stack alignment
    sw   ra,12(sp)     # ✓ Return address preservation (callee-saved)
    sw   s0,8(sp)      # ✓ Frame pointer preservation (callee-saved)
    addi s0,sp,16      # ✓ Frame pointer setup
    lui  a5,%hi(.LC0)  # ✓ Temporary register usage (caller-saved)
    addi a0,a5,%lo(.LC0) # ✓ Argument register usage (caller-saved)
    call puts          # ✓ Function call with proper argument passing
    li   a5,0          # ✓ Return value preparation
    mv   a0,a5         # ✓ Return value in a0 register
    lw   ra,12(sp)     # ✓ Return address restoration
    lw   s0,8(sp)      # ✓ Frame pointer restoration
    addi sp,sp,16      # ✓ Stack deallocation
    jr   ra            # ✓ Return via return address register
```

### ABI Compliance Summary

| Register | Usage in Code | ABI Compliance | Status |
|----------|---------------|----------------|--------|
| **sp (x2)** | Stack operations with 16-byte alignment | Callee-saved, properly aligned | ✅ Perfect |
| **ra (x1)** | Saved/restored across function | Caller-saved, properly preserved | ✅ Perfect |
| **s0 (x8)** | Frame pointer saved/restored | Callee-saved, properly preserved | ✅ Perfect |
| **a0 (x10)** | Argument passing and return value | Caller-saved, proper usage | ✅ Perfect |
| **a5 (x15)** | Temporary address calculation | Caller-saved, proper usage | ✅ Perfect |

### Comprehensive Cheat Sheet

```bash
# Create final comprehensive reference
cat > risc_v_abi_cheatsheet.txt << 'EOF'
================================================================================
                           RISC-V ABI & Register Cheat-Sheet
================================================================================

REGISTER CATEGORIES:
✅ Special: x0 (zero), x1 (ra), x2 (sp), x3 (gp), x4 (tp)
✅ Temporaries: x5-x7 (t0-t2), x28-x31 (t3-t6) [Caller-saved]
✅ Saved: x8-x9 (s0-s1), x18-x27 (s2-s11) [Callee-saved]
✅ Arguments: x10-x17 (a0-a7) [Caller-saved]

CALLING CONVENTION RULES:
✅ Arguments: a0-a7 for first 8 parameters, stack for additional
✅ Returns: a0-a1 for return values (up to 64-bit)
✅ Preservation: Functions MUST preserve sp, s0-s11 if used
✅ Functions CAN modify ra, t0-t6, a0-a7 freely
✅ Stack: 16-byte aligned, grows downward
✅ Frame: s0/fp optional frame pointer

REGISTER USAGE PATTERNS:
✅ Function Entry: Save ra, s0, allocate stack
✅ Function Body: Use t-regs freely, preserve s-regs
✅ Function Exit: Restore s0, ra, deallocate stack, return

QUICK REFERENCE:
✅ Stack Allocation: addi sp,sp,-N (N multiple of 16)
✅ Save Return Addr: sw ra,offset(sp)
✅ Save Frame Ptr: sw s0,offset(sp)
✅ Function Args: a0-a7 for parameters
✅ Return Values: a0-a1 for results
✅ Temporaries: t0-t6 for scratch work
================================================================================
EOF
```

## Testing & Validation

### Register Lookup Testing

```bash
# Test the lookup utility
./register_lookup.sh ra
./register_lookup.sh s0
./register_lookup.sh a0
./register_lookup.sh t1
```

### ABI Compliance Verification

```bash
# Comprehensive ABI analysis
echo "=== Complete ABI Compliance Check ==="

# Check for proper function prologue
echo "Function Prologue:"
grep -A 4 "main:" ../hello.s

# Check for proper function epilogue  
echo -e "\nFunction Epilogue:"
grep -B 1 -A 1 "jr.*ra" ../hello.s

# Verify stack frame management
echo -e "\nStack Frame Management:"
grep -E "(addi.*sp|sw.*sp|lw.*sp)" ../hello.s
```

### Expected Validation Results

```bash
$ ./register_lookup.sh ra
x1 (ra): Return address, caller-saved

$ ./register_lookup.sh s0
x8 (s0/fp): Saved register 0 / Frame pointer, callee-saved

✓ All register usage follows RISC-V ABI specifications
✓ Stack alignment maintained at 16-byte boundaries
✓ Callee-saved registers properly preserved
✓ Function calling convention correctly implemented
```

## Troubleshooting Guide

### Reference Creation Issues

**Issue**: File creation permissions
```bash
# Solution: Check directory permissions
ls -la ~/riscv_code/abi_reference/
chmod 755 ~/riscv_code/abi_reference/
```

**Issue**: Script execution failures
```bash
# Solution: Set proper execute permissions
chmod +x register_lookup.sh
```

### ABI Analysis Issues

**Issue**: Assembly file not found
```bash
# Solution: Verify file location
find ~/riscv_code -name "hello.s" -type f
```

**Issue**: Grep patterns not matching
```bash
# Solution: Check assembly syntax variations
grep -i -E "(addi|sw|lw)" ../hello.s
```

## References

- [RISC-V Calling Convention Specification](https://github.com/riscv-non-isa/riscv-elf-psabi-doc)
- [RISC-V Instruction Set Manual](https://riscv.org/technical/specifications/)
- [System V ABI RISC-V Supplement](https://github.com/riscv-non-isa/riscv-elf-psabi-doc/blob/master/riscv-elf.adoc)
- [RISC-V Assembly Programming Guide](https://github.com/riscv-non-isa/riscv-asm-manual)
