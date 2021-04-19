.PHONY: clean

asmcat:
	gcc -nostdlib --static -o asmcat -v asmcat.S

clean:
	rm asmcat.o asmcat || true
