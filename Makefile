#!/usr/bin/make
CC = gcc
CFLAGS = -fno-common -Wall -O2 -c \
         -finhibit-size-directive -fno-ident \
         -fomit-frame-pointer -fcall-used-ebx

TARGET = hello
IPL = ipl
ASMHEAD = asmhead
BOOTPACK = bootpack
OBJS = crt.o bootpack.o

${TARGET}.bin: ${IPL} ${ASMHEAD} ${BOOTPACK}
	dd if=/dev/zero of=$@ bs=512 count=2880 &> /dev/null
	dd if=${IPL} of=$@ conv=notrunc &> /dev/null
	dd if=${ASMHEAD} of=$@ conv=notrunc seek=1 &> /dev/null
	dd if=${BOOTPACK} of=$@ conv=notrunc seek=2 &> /dev/null

${IPL}: ipl.o ipl.ls
	ld -T ipl.ls -o $@ ipl.o \
	-Map ${IPL}.map --cref

${ASMHEAD}: asmhead.o asmhead.ls
	ld -T asmhead.ls -o $@ asmhead.o \
	-Map ${ASMHEAD}.map --cref

${BOOTPACK}: ${OBJS} bootpack.ls
	ld -T bootpack.ls -o $@ ${OBJS} \
	-Map ${BOOTPACK}.map --cref

%.o: %.S Makefile
	${CC} ${CFLAGS} $<

%.o: %.c Makefile
	${CC} ${CFLAGS} $<

clean:
	rm -f *.o *.map ${IPL} ${ASMHEAD} ${BOOTPACK} ${TARGET}.bin
