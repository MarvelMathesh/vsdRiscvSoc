.section .text.start
.global _start

_start:
    # Set up stack pointer
    lui sp, %hi(_stack_top)
    addi sp, sp, %lo(_stack_top)
    
    # Initialize trap vector
    la t0, trap_handler
    csrw mtvec, t0
    
    # Call main program
    call main
    
    # Infinite loop (shouldn't reach here)
1:  j 1b

# Simple trap handler (if needed)
trap_handler:
    # Save context
    addi sp, sp, -64
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw t2, 12(sp)
    sw a0, 16(sp)
    sw a1, 20(sp)
    
    # Call C interrupt handler
    call timer_interrupt_handler
    
    # Restore context
    lw ra, 0(sp)
    lw t0, 4(sp)
    lw t1, 8(sp)
    lw t2, 12(sp)
    lw a0, 16(sp)
    lw a1, 20(sp)
    addi sp, sp, 64
    
    # Return from interrupt
    mret

.size _start, . - _start
.size trap_handler, . - trap_handler
