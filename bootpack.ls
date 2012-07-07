OUTPUT_FORMAT("binary")/* We want raw binary image */
OUTPUT_ARCH(i386)

/* Define memory layout */

/* Specify input and output sections */

SECTIONS {  
  .text 0x00: 
    { *(.text) }  /* Executable codes */
  .data 0x280000 + SIZEOF(.text): 
    AT ( ADDR (.text) + SIZEOF (.text) )
    { *(.data) }  /* Initialized data */
  .rodata 0x280000 + SIZEOF(.text) + SIZEOF(.data):
    AT ( ADDR (.text) + SIZEOF (.text) + SIZEOF (.data) )
    { *(.rodata*) }/* Constant data (R/O) */
  .bss 0x280000 + SIZEOF(.text) + SIZEOF(.data) + SIZEOF(.rodata):
    AT ( ADDR (.text) + SIZEOF (.text) + SIZEOF (.data) + SIZEOF(.rodata))
    { *(.bss) }   /* Uninitialized data */
}