.intel_syntax noprefix
#define CYLS 10
	
.file "ipl.S"

.code16gcc

.section .rodata

msg1:
.string "load error!!"

.text
main:
	cli
	mov ax, 0
	mov ds, ax
	mov es, ax
	mov sp, 0x7c00
	mov ss, ax
	sti
	
	mov ax, 0x0820
	mov es, ax
	mov ch, 0x0
	mov dh, 0x0
	mov cl, 0x2

readloop:	
	mov si, 0        // 失敗回数を数える
retry:
	mov ah, 0x02     // AH=0x02:ディスクの読み込み
	mov al, 0x01     // 1セクタ読み込み
	mov bx, 0x00
	mov dl, 0x00     // Aドライブ
	int 0x13
	jnc next         // エラーでなければ終了
	inc si
	cmp si, 5        // 5回失敗でerrorへ
	jae error
	mov ah, 0x00
	mov dl, 0x00
	int 0x13         // ドライブリセット
	jmp retry

next:
	mov ax, es
	add ax, 0x0020
	mov es, ax       // アドレスとを0x0200(0x20じゃない)進める
	add cl, 1
	cmp cl, 18
	jbe readloop     // 18セクタまで読む
	mov cl, 1
	add dh, 1
	cmp dh, 2
	jb readloop      // ヘッド2まで読む

	// デバッグのためにシリンダごとに'.'を出力
	mov al, '.'
	mov ah, 0x0e
	mov bx, 0x07
	int 0x10
	
	mov dh, 0
	add ch, 1
	cmp ch, CYLS
	jb readloop

	jmp 0x8200
fin:
	hlt
	jmp fin

error:
	mov si, offset msg1
putloop:
	mov al, [si]
	inc si
	cmp al, 0
	je fin
	mov ah, 0x0e
	mov bx, 0x07
	int 0x10
	jmp putloop

.section .sign, "a"
sign:	.word 0xaa55
