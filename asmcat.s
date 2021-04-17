.section .data
.set MAX_READ_BYTES, 0x7fff

.section .text
.globl main

main:
	pushq %rdi
	movl $12, %eax
	xorq %rdi, %rdi
	syscall

	leaq MAX_READ_BYTES(%rax), %rdi
	movl $12, %eax
	syscall
	leaq -MAX_READ_BYTES(%rax), %r13
	cmp $0, %rax
	jl exit

	popq %rdi
	# open the file
	cmpq $0x01, %rdi
	je stdin


	movl $0x02, %eax # syscall #2 = open.
	mov 8(%rsi), %rdi # first argument: filename; 8(%rsi) is argv[1].
	movl $0, %esi # second argument: flags. 0 means read-only.
	xorq %rdx, %rdx # this argument isn't used here, but zero it out for peace of mind.
	syscall # returns the file descriptor number in %rax
	movl %eax, %edi
	call read_and_write
	jmp cleanup

stdin:
	movl $0x0000, %edi # first argument: file descriptor.
	call read_and_write
	jmp cleanup

read_and_write:
	# read the file.
	movl %edi, %r14d
	movl $0, %eax # syscall #0 = read.
	movq %r13 /* pointer to allocated memory */, %rsi # second argument: address of a writeable buffer.
	movl $MAX_READ_BYTES, %edx # third argument: number of bytes to write.
	syscall # num bytes read in %rax
	movl %eax, %r15d

	# print the file
	movl $1, %eax # syscall #1 = write.
	movl $1, %edi # first argument: file descriptor. 1 is stdout.
	movq %r13, %rsi # second argument: address of data to write.
	movl %r15d, %edx # third argument: number of bytes to write.
	syscall # result ignored.
	ret

cleanup:
	# close the file
	movl $0x03, %eax # syscall #3 = close.
	movl %r14d, %edi # first arg: file descriptor number.
	syscall # result ignored.

exit:
	# set the exit code
	movl $60, %eax # syscall #60 = exit.
	movq $0, %rdi # exit 0 = success.
	syscall
