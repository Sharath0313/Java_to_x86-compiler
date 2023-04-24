.LC0:
	.string "%d\n"
	.text
	.globl main
	.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp
	movq %rdi, -8(%rbp)
	movq %rsi, -16(%rbp)
	movq $1, -24(%rbp)
.L0:
	movq $10, %rbx
	movq -24(%rbp), %r12
	cmp %rbx, %r12
	jg .L1
	movq $5, %rbx
	movq -24(%rbp), %r12
	cmp %rbx, %r12
	jne .L2
	movq -24(%rbp), %rbx
	movq $1, %r12
	movq -24(%rbp), %r13
	addq %r12, %r13
	movq %r13, -24(%rbp)
	jmp .L1
.L2:
	pushq %rbx
	movq -24(%rbp), %rdi
	movq %rdi, %rsi
	leaq .LC0(%rip), %rdi
	movl $0, %eax
	call printf@PLT
	popq %rbx
	movq -24(%rbp), %r12
	movq $1, %r13
	movq -24(%rbp), %r14
	addq %r13, %r14
	movq %r14, -24(%rbp)
	jmp .L0
.L1:
	leave
	ret
