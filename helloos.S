#define INIT_SEG 0x07c0

.file "helloos.S"

.code16gcc

.section .rodata
msg1:
.string "hello,world"

.text
main:
	cli
	movw $INIT_SEG, %ax
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %sp
	movw $0, %ax
	movw %ax, %ss
	sti

	movl $msg1, %esi
putloop:
	movzbl (%esi), %eax
	cmpb $0, %al
	je fin
	incl %esi
	movb $0x0e, %ah
	movl $7, %ebx
	int $0x10
	jmp putloop

fin:
	hlt
	jmp fin

.section .sign, "a"
sign:	.word 0xaa55
