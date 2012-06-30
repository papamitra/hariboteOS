
.intel_syntax noprefix

#define CYLS  10
#define LEDS  0x0ff1
#define VMODE 0x0ff2
#define SCRNX 0x0ff4
#define SCRNY 0x0ff6
#define VRAM  0x0ff8

#define BOTPAK	0x00280000		// bootpackのロード先.
#define DSKCAC	0x00100000		// ディスクキャッシュの場所.
#define DSKCAC0	0x00008000		// ディスクキャッシュの場所（リアルモード）.

	.file "asmhead.S"

	.code16gcc

	.text
main:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax

	// 画面モード切り替え
	mov al, 0x13
	mov ah, 0x00
	int 0x10

	mov [BYTE PTR VMODE], 8
	mov [WORD PTR SCRNX], 320
	mov [WORD PTR SCRNY], 200
	mov [DWORD PTR VRAM], 0x000a0000

	mov ah, 0x02
	int 0x16
	mov al, [LEDS]

// PICが一切の割り込みを受け付けないようにする
// AT互換機の仕様では、PICの初期化をするなら、
// こいつをCLI前にやっておかないと、たまにハングアップする
// PICの初期化はあとでやる

	mov al, 0xff
	out 0x21, al
	nop // OUT命令を連続させるとうまくいかない機種があるらしい
	out 0xa1, al
	cli

// CPUから1MB以上のメモリにアクセスできるように、A20GATEを設定

	call waitkbdout
	mov  al, 0xd1
	out  0x64, al
	call waitkbdout
	mov  al, 0xdf
	out  0x60, al
	call waitkbdout

// プロテクトモード移行
	xor eax, eax       // eax = 0
	mov ax, ds
	shl eax, 4
	add eax, offset gdt
	mov [gdtr + 2], eax // gdtrのbaseにgdtのアドレスを設定

	lgdt gdtr

	mov eax, cr0
	and eax, 0x7fffffff  // bit31を0にする(ページング禁止)
	or  eax, 0x00000001  // bit0を1にする (プロテクトモード移行)
	mov cr0, eax
	jmp pipelineflash

pipelineflash:
	mov ax, 0x08
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	// bootpackの転送
	mov esi, 0x8400      	// 転送元
				// asmhead.oは1セクタ分あるので
				// bootpack.oは0x8200 + 0x200の位置にいるはず
	mov edi, BOTPAK
	mov ecx, (512*1024/4)
	call memcpy

// ついでにディスクデータも本来の位置へ転送

// まずはブートセクタから
	mov esi, 0x7c00
	mov edi, DSKCAC
	mov ecx, 512/4
	call memcpy

// のこり全部
	mov esi, DSKCAC0 + 512	// 転送元
	mov edi, DSKCAC  + 512 	// 転送先
	mov ecx, 0
	mov cl, CYLS
	mov eax, 512*18*2/4
	imul ecx
	mov ecx, eax
	sub ecx, 512/4
	call memcpy

// asmheadでしなければいけないことは全部し終わったので、
// あとはbootpackに任せる

// bootpackの起動
skip:
	mov esp, 0x00310000
	ljmp 0x10:0x0

waitkbdout:
	in  al, 0x64
	and al, 0x02
	in  al, 0x60
	jnz waitkbdout
	ret

memcpy:
	mov eax, [esi]
	add esi, 4
	mov [edi], eax
	add edi, 4
	sub ecx, 1
	jnz memcpy
	ret

// memcpyはアドレスサイズプリフィクスを入れ忘れなければ、ストリング命令でも書ける

.section .data
	.align 16
gdt:
	.long 0
	.long 0		// ヌルセレクタ

	.long 0x0000ffff
	.long 0x00cf9200
				// 読み書き可能セグメント
				// 0x08 0x00cf92000000ffff
				// G = 4K, D = 32bit, P = S = 1,
				// Type = 7(exec/read), limit = 0xFFFFF
				// Base = 0x00000000

	.long 0x0000ffff
	.long 0x00479a28
				// 実行可能セグメント
				// 0x16 0x00479a280000ffff
				// G = 1B, D = 32bit, P = S = 1
				// Type = 5(exec/read), limit = 0x7FFFF
				// Base = 0x00280000

gdtr:
	.word 23
	.long 0			// ここにあとでgdtへのポインタが格納される
