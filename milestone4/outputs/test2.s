.LC0:
	.string "%d\n"
	.text
	.globl Circle.Circle
	.type Circle.Circle, @function
Circle.Circle:
	pushq %rbp
	movq %rsp, %rbp
	subq $24, %rsp
	movq %rdi, -8(%rbp)
	movq %rsi, -16(%rbp)
	movq $0, %rbx
	movq -8(%rbp), %r12
	addq %rbx, %r12
	movq -16(%rbp), %rbx
	movq %r12, 0(%rbx)
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
	movq $16, %rbx
	movq %rbx, %rdi
	call malloc@PLT
	movq %rax, %rbx
	movq %rbx, %rsi
	movq $5, %rdi
	call Circle.Circle
	movq %rbx, -24(%rbp)
	movq $8, %rbx
	movq -24(%rbp), %r12
	addq %rbx, %r12
	movq $0, %rbx
	movq -24(%rbp), %r13
	addq %rbx, %r13
	movq $2, %rbx
	movq (%r13), %r14
	movq %r14, %rax
	imulq %rbx
	movq %rax, %r14
	movq %r14, (%r12)
	movq $0, %rbx
	movq -24(%rbp), %r12
	addq %rbx, %r12
	movq (%r12), %rdi
	movq %rdi, %rsi
	leaq .LC0(%rip), %rdi
	movl $0, %eax
	call printf@PLT
	movq $8, %rbx
	movq -24(%rbp), %r12
	addq %rbx, %r12
	movq (%r12), %rdi
	movq %rdi, %rsi
	leaq .LC0(%rip), %rdi
	movl $0, %eax
	call printf@PLT
	leave
	ret
