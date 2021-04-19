BUF_SIZE = 1 << 16
SYSCALL_READ = 0
SYSCALL_WRITE = 1
SYSCALL_OPEN = 2
SYSCALL_CLOSE = 3
SYSCALL_EXIT = 60
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
	movl $SYSCALL_OPEN, %eax # syscall 2: open
	movq 8(%rsp), %rdi
	xorq %rsi, %rsi
	syscall
	movl %eax, %r15d

read_and_write:
	movl $SYSCALL_READ, %eax
	movl %r15d, %edi
	movl $buf, %esi
	movl $BUF_SIZE, %edx
	syscall
	testl %eax, %eax
	jz close_file
	movl %eax, %edx

	movl $SYSCALL_WRITE, %eax
	movl $1, %edi
	syscall
	testl %eax, %eax
	jg read_and_write

close_file:
	pushq %rax
	testl %r15d, %r15d
	jz exit

	movl $SYSCALL_CLOSE, %eax
	movl %r15d, %edi
	syscall

exit:
	movl $SYSCALL_EXIT, %eax
	popq %rdi
	syscall
