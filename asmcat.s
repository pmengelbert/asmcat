MAX_READ_BYTES = 1 << 16
.section .bss
.lcomm buf, 1 << 16

.section .text
.globl _start

_start:
	popq %rdi
	decq %rdi
	movl %edi, %r15d
	jz read_and_write

open_file:
	movl $2, %eax
	movq 8(%rsp), %rdi
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
	jg exit
	movl %eax, %edx

	movl $1, %eax
	movl $1, %edi
	syscall
	testl %eax, %eax
	jg read_and_write

exit:
	pushq %rax
	testl %r15d, %r15d
	jz final_exit

	movl $3, %eax
	movl %r15d, %edi
	syscall

final_exit:
	movl $60, %eax
	popq %rdi
	syscall


