.LC0:
	.string "%d\n"
	.text
	.globl Student.getRoll
	.type Student.getRoll, @function
Student.getRoll:
	pushq %rbp
	movq %rsp, %rbp
	subq $16, %rsp
	movq %rdi, -8(%rbp)
	movq -8(%rbp), %rbx
	movq 0(%rbx), %rax
	leave
	ret
	.text
	.globl Student.setRoll
	.type Student.setRoll, @function
Student.setRoll:
	pushq %rbp
	movq %rsp, %rbp
	subq $24, %rsp
	movq %rdi, -8(%rbp)
	movq %rsi, -16(%rbp)
	movq -16(%rbp), %rbx
	movq -8(%rbp), %r12
	movq %r12, 0(%rbx)
	leave
	ret
	.text
	.globl Student.display
	.type Student.display, @function
Student.display:
	pushq %rbp
	movq %rsp, %rbp
	subq $16, %rsp
	movq %rdi, -8(%rbp)
	movq -8(%rbp), %rbx
	movq 0(%rbx), %rdi
	movq %rdi, %rsi
	leaq .LC0(%rip), %rdi
	movl $0, %eax
	call printf@PLT
	leave
	ret
	.text
	.globl main
	.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	movq %rdi, -8(%rbp)
	movq %rsi, -16(%rbp)
	movq $8, %rbx
	movq %rbx, %rdi
	call malloc@PLT
	movq %rax, %rbx
	movq %rbx, -24(%rbp)
	movq -24(%rbp), %rsi
	movq $200477, %rdi
	call Student.setRoll
	movq -24(%rbp), %rdi
	call Student.getRoll
	movq %rax, %rbx
	movq $439, %r12
	addq %r12, %rbx
	movq -24(%rbp), %rsi
	movq %rbx, %rdi
	call Student.setRoll
	movq -24(%rbp), %rdi
	call Student.display
	leave
	ret
