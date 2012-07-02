.intel_syntax noprefix
.file "asmfunc.S"

.code32

.globl io_hlt
io_hlt:
	hlt
	ret

.globl io_cli
io_cli:
	cli
	ret

.globl io_sti
io_sti:
	sti
	ret

.globl write_mem8
write_mem8:	// void write_mem8(int addr, int data)
	mov ecx, [esp+4]	// addrをecxへ
	mov al , [esp+8]	// dataをalへ
	mov BYTE [ecx], al
	ret

.globl io_out8
io_out8:	// void io_out8(int port, int data)
	mov edx, [esp+4]	// port
	mov al,  [esp+8]	// data
	out dx,  al

.globl io_in8
io_in8:		// int io_in8(int port)
	mov edx, [esp+4]	// port
	mov eax, 0		// ret = 0
	in  al, dx		// ret 
	ret

.globl io_load_eflags
io_load_eflags:	// int io_load_eflags(void)
	pushf	// push eflags
	pop eax
	ret

.globl io_store_eflags
io_store_eflags:
	mov eax, [esp + 4]
	push eax
	popf
	ret
