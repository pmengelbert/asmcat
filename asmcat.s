.section .data
filename: .asciz "/home/pme/butts"
buffer: .space 1024

.section .text
.globl main

main:
	#open the file
	movl $0x02, %eax # Syscall #2 = Open
	mov 8(%rsi), %rdi #first argument: filename; 8(%rsi) is argv[1].
	movl $0, %esi #second argument: flags. 0 means read-only.
	syscall # returns the file descriptor number in %rax

	#move the file descriptor to register 8
	movl %eax, %r8d

	#seek to the end of the file to discover its length
	movl $8, %eax # syscall #8 = lseek
	movl %r8d, %edi # first argument: file descriptor number
	xorq %rsi, %rsi # second argument: see lseek(2). add 0 bytes to the end of the file
	movl $2, %edx # third argument: constant 2 signifies the end of the file. See lseek(2).
	syscall # puts the offset (file size) in %rax

	#store the file size in %r9
	movq %rax, %r9

	#seek to the beginning of the file to read it
	movl $8, %eax # syscall #8 = lseek
	movl %r8d, %edi # first argument: file descriptor
	xorq %rsi, %rsi # second argument: no offset
	xorq %rdx, %rdx # Zero this out to get to the beginning of the file
	syscall # returns offset of 0; not used here.

	pushq %r8 # malloc will clobber r8, so save it on the stack
	pushq %r9 # malloc will clobber r9, so save it on the stack
	movq %r9, %rdi # allocate the same number of bytes as are in the file
	call malloc # do the allocation
	movq %rax, %r15
	popq %r9 # retrieve r9
	popq %r8 # retrieve r8

	#read the file
	movl $0, %eax # syscall #0 = read
	movl %r8d, %edi # first argument: file descriptor
	movq %r15, %rsi # second argument: address of a writeable buffer
	movl %r9d, %edx # third argument: number of bytes to write
	syscall # result ignored

	#print the file
	movl $1, %eax # syscall #1 = write
	movl $1, %edi # first argument: file descriptor. 1 is stdout.
	movq %r15, %rsi # second argument: address of data to write.
	movl %r9d, %edx # third argument: number of bytes to write
	syscall # result ignored

	#close the file
	movl $0x03, %eax # syscall #3 = close
	movl %r8d, %edi # first arg: file descriptor number
	syscall # result ignored

	# free the buffer
	movq %r15, %rdi # the pointer to the allocated memory is in %r15
	call free

	#set the exit code
	movl $60, %eax # syscall #60 = exit
	movq $0, %rdi # exit 0 = success
	syscall
