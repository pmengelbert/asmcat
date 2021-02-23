.PHONY: clean

asmcat: asmcat.o
	ld -o asmcat -dynamic-linker /lib64/ld-linux-x86-64.so.2 /usr/lib/gcc/x86_64-pc-linux-gnu/10.2.0/../../../../lib/Scrt1.o /usr/lib/gcc/x86_64-pc-linux-gnu/10.2.0/../../../../lib/crti.o  /usr/lib/gcc/x86_64-pc-linux-gnu/10.2.0/crtbeginS.o -lc asmcat.o /usr/lib/gcc/x86_64-pc-linux-gnu/10.2.0/crtendS.o /usr/lib/gcc/x86_64-pc-linux-gnu/10.2.0/../../../../lib/crtn.o

asmcat.o:
	as -o asmcat.o asmcat.s

clean:
	rm asmcat.o asmcat || true
