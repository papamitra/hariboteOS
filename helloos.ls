OUTPUT_FORMAT("binary")/* We want raw binary image */
OUTPUT_ARCH(i386:x86-64)

/* Define memory layout */

MEMORY {
  body : org =   0, len = 510
  sign : org = 510, len = 2
 }

/* Specify input and output sections */

SECTIONS {
  .text   : { *(.text) }   > body /* Executable codes */
  .data   : { *(.data) }   > body /* Initialized data */
  .bss    : { *(.bss) }    > body /* Uninitialized data */
  .rodata : { *(.rodata*) } > body /* Constant data (R/O) */
  .sign   : { *(.sign) }  > sign /* Boot signature */
}
