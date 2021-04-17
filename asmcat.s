.section .data
.set MAX_READ_BYTES, 0xffff

.section .text
.globl _start

_start:
	movq (%rsp), %r10 # save the value of argc somewhere else
	movq 16(%rsp), %r9 # save the value of argv[1] somewhere else

	movl $12, %eax # syscall 12 is brk. see brk(2)
	xorq %rdi, %rdi # call with 0 as first arg to get current end of memory
	syscall
	movq %rax, %r8 # this is the address of the current end of memory

	leaq MAX_READ_BYTES(%rax), %rdi # let this be the new end of memory
	movl $12, %eax # syscall 12, brk
	syscall
	cmp %r8, %rax # compare the two; if the allocation failed, these will be equal
	je exit

	leaq -MAX_READ_BYTES(%rax), %r13 # store the start of the free area in %r13

	movq %r10, %rdi # retrieve the value of argc
	cmpq $0x01, %rdi # if there are no cli args, process stdin instead
	je stdin

	# open the file
	movl $0x02, %eax # syscall #2 = open.
	movq %r9, %rdi
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
