.section .text.start
.global _start

_start:
    # Initialize stack pointer
    lui sp, %hi(_stack_top)
    addi sp, sp, %lo(_stack_top)
    
    # Initialize data section (copy from Flash to SRAM)
    lui t0, %hi(_data_start)
    addi t0, t0, %lo(_data_start)
    lui t1, %hi(_data_end)
    addi t1, t1, %lo(_data_end)
    beq t0, t1, init_bss
    
copy_data:
    lw t2, 0(t0)
    sw t2, 0(t0)
    addi t0, t0, 4
    bne t0, t1, copy_data
    
init_bss:
    # Clear BSS section
    lui t0, %hi(_bss_start)
    addi t0, t0, %lo(_bss_start)
    lui t1, %hi(_bss_end)
    addi t1, t1, %lo(_bss_end)
    beq t0, t1, call_main
    
clear_bss:
    sw zero, 0(t0)
    addi t0, t0, 4
    bne t0, t1, clear_bss
    
call_main:
    # Call main program
    call main
    
    # Infinite loop if main returns
halt:
    j halt

.size _start, . - _start
