OUTPUT_FORMAT("binary")/* We want raw binary image */
OUTPUT_ARCH(i386:x86-64)

/* Specify input and output sections */

SECTIONS {
  . = 0x8200;
  .text   : { *(.text) }    /* Executable codes */
  .data   : { *(.data) }    /* Initialized data */
  .bss    : { *(.bss) }     /* Uninitialized data */
  .rodata : { *(.rodata*) } /* Constant data (R/O) */
  .sign   : { *(.sign) }    /* Boot signature */
}
