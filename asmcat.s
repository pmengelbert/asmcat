MAX_READ_BYTES = 1 << 16
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
	movl $2, %eax #
	movl 8(%rsp), %edi
	xorq %rsi, %rsi
	syscall
	movl %eax, %r15d

read_and_write:
	xorq %rax, %rax
	movl %r15d, %edi
	movl $buf, %esi
	movl $MAX_READ_BYTES, %edx
	syscall
	testl %eax, %eax
	jz close_file
	movl %eax, %edx

	movl $1, %eax
	movl $1, %edi
	syscall
	testl %eax, %eax
	jg read_and_write

close_file:
	pushq %rax
	testl %r15d, %r15d
	jz exit

	movl $3, %eax
	movl %r15d, %edi
	syscall

exit:
	movl $60, %eax
	popq %rdi
	syscall
