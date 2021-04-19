#include <asm/unistd.h>
BUF_SIZE = 1 << 16
.section .bss
.lcomm buf, 1 << 16

.section .text
.globl _start

_start:
	xorl %r15d, %r15d # default to file descriptor 0 = stdin
	popq %rdi # this is argc
	decq %rdi
	jz read_and_write # if argc was 1, it will now be zero, in which case, read from stdin

open_file: # otherwise open the file and save the descriptor in %r15d
	movl $__NR_open, %eax # syscall 2: open
	movq 8(%rsp), %rdi
	xorq %rsi, %rsi
	syscall
	movl %eax, %r15d

read_and_write:
	movl $__NR_read, %eax
	movl %r15d, %edi
	movl $buf, %esi
	movl $BUF_SIZE, %edx
	syscall
	testl %eax, %eax
	jz close_file
	movl %eax, %edx

	movl $__NR_write, %eax
	movl $1, %edi
	syscall
	testl %eax, %eax
	jg read_and_write

close_file:
	pushq %rax
	testl %r15d, %r15d
	jz exit

	movl $__NR_close, %eax
	movl %r15d, %edi
	syscall

exit:
	movl $__NR_exit, %eax
	popq %rdi
	syscall
