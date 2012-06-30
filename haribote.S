.intel_syntax noprefix
.file "haribote.S"

.code16gcc

.text
main:
	// 画面モードの切り替え
	mov al, 0x13
	mov ah, 0x00
	int 0x10

fin:
	hlt
	jmp fin
