/*
 * LED Blink Linker Script for RV32IMC
 * Memory layout for SiFive FE310-like microcontroller
 */

ENTRY(_start)

MEMORY
{
    FLASH (rx)  : ORIGIN = 0x20010000, LENGTH = 512K
    SRAM  (rwx) : ORIGIN = 0x80000000, LENGTH = 16K
}

SECTIONS
{
    /* Interrupt vector table first */
    .vectors 0x20010000 : {
        *(.vectors)
    } > FLASH

    /* Text section */
    .text : {
        *(.text.start)
        *(.text*)
        *(.rodata*)
    } > FLASH

    /* Data section in SRAM */
    .data 0x80000000 : AT (LOADADDR(.text) + SIZEOF(.text)) {
        _data_start = .;
        *(.data*)
        _data_end = .;
    } > SRAM

    /* BSS section */
    .bss : {
        _bss_start = .;
        *(.bss*)
        *(COMMON)
        _bss_end = .;
    } > SRAM

    /* Stack at end of SRAM */
    _stack_top = ORIGIN(SRAM) + LENGTH(SRAM);
    
    /* GPIO base address symbol */
    _gpio_base = 0x10012000;
}
