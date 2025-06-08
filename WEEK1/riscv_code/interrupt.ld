/*
 * Linker Script for Timer Interrupt - RV32IMC
 * Places .text at 0x00000000 (Flash/ROM)
 * Places .data at 0x10000000 (SRAM)
 */

ENTRY(_start)

MEMORY
{
    FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 256K
    SRAM  (rwx) : ORIGIN = 0x10000000, LENGTH = 64K
}

SECTIONS
{
    /* Text section in Flash at 0x00000000 */
    .text 0x00000000 : {
        *(.text.start)    /* Entry point first */
        *(.text*)         /* All other text */
        *(.rodata*)       /* Read-only data */
    } > FLASH

    /* Data section in SRAM at 0x10000000 */
    .data 0x10000000 : {
        _data_start = .;
        *(.data*)         /* Initialized data */
        _data_end = .;
    } > SRAM

    /* BSS section in SRAM */
    .bss : {
        _bss_start = .;
        *(.bss*)          /* Uninitialized data */
        _bss_end = .;
    } > SRAM

    /* Stack at end of SRAM */
    _stack_top = ORIGIN(SRAM) + LENGTH(SRAM);
}
