.PHONY: clean

asmcat: asmcat.o
	ld -o asmcat asmcat.o

asmcat.o:
	as -o asmcat.o asmcat.s

clean:
	rm asmcat.o asmcat || true
