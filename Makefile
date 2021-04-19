.PHONY: clean

asmcat: asmcat.o
	ld -o asmcat asmcat.o
	rm asmcat.s.tmp

asmcat.o: asmcat.s.tmp
	as -o asmcat.o asmcat.s.tmp

asmcat.s.tmp:
	gcc -o asmcat.s.tmp -E asmcat.S

clean:
	rm asmcat.o asmcat asmcat.tmp || true
