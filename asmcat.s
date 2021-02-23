.section .data
filename: .asciz "/home/pme/butts"
buffer: .space 1024

.section .text
.globl main

main:

	#open the file
	movl $0x02, %eax # Syscall #2 = Open
	mov $filename, %rdi #first argument: filename; 16(%rsp) is argv[1].
	movl $0, %esi #second argument: flags. 0 means read-only.
	syscall

	#move the file descriptor to register 8
	movl %eax, %r8d

	#seek to the end of the file to discover its length
	movl $8, %eax # syscall #8 = lseek
	movl %r8d, %edi # first argument: file descriptor number
	xorq %rsi, %rsi # second argument: see lseek(2). add 0 bytes to the end of the file
	movl $2, %edx # third argument: constant 2 signifies the end of the file. See lseek(2).
	syscall

	#store the file size
	movq %rax, %r9

	#seek to the beginning of the file to read it
	movl $8, %eax # syscall #8 = lseek
	movl %r8d, %edi # first argument: file descriptor
	xorq %rsi, %rsi # second argument: no offset
	xorq %rdx, %rdx # Zero this out to get to the beginning of the file
	syscall

	#read the file
	movl $0, %eax # syscall #0 = read
	movl %r8d, %edi # first argument: file descriptor
	movq $buffer, %rsi # second argument: address of a writeable buffer
	movl %r9d, %edx # third argument: number of bytes to write
	syscall

	#print the file
	movl $1, %eax # syscall #1 = write
	movl $1, %edi # first argument: file descriptor. 1 is stdout.
	movq $buffer, %rsi # second argument: address of data to write.
	movl %r9d, %edx # third argument: number of bytes to write
	syscall

	#close the file
	movl $0x03, %eax # syscall #3 = close
	movl %r8d, %edi # first arg: file descriptor number
	syscall

	#set the exit code
	movl $60, %eax # syscall #60 = exit
	movl $0, %edi # exit 0 = success
	syscall

find_length:
	movq %rdi, %r10
	xorq %r11, %r11
.L_find_null:
	cmpb $0, (%r10,%r11)
	je .L_end_find_null
	incq %r11
	jmp .L_find_null
.L_end_find_null:
	movq %r11, %rax
	ret

