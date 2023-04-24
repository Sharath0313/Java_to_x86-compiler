.LC0:
	.string "%d\n"
	.text
	.globl main
	.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $40, %rsp
	movq %rdi, -8(%rbp)
	movq %rsi, -16(%rbp)
	movq $5, %rbx
	movq $8, %r12
	movq %r12, %rax
	imulq %rbx
	movq %rax, %r12
	movq %r12, %rdi
	call malloc@PLT
	movq %rax, %rbx
	movq %rbx, -24(%rbp)
	movq $8, %rbx
	movq $0, %r12
	movq %r12, %rax
	imulq %rbx
	movq %rax, %r12
	movq -24(%rbp), %rbx
	addq %r12, %rbx
	movq $10, (%rbx)
	movq $8, %rbx
	movq $1, %r12
	movq %r12, %rax
	imulq %rbx
	movq %rax, %r12
	movq -24(%rbp), %rbx
	addq %r12, %rbx
	movq $20, (%rbx)
	movq $8, %rbx
	movq $2, %r12
	movq %r12, %rax
	imulq %rbx
	movq %rax, %r12
	movq -24(%rbp), %rbx
	addq %r12, %rbx
	movq $70, (%rbx)
	movq $8, %rbx
	movq $3, %r12
	movq %r12, %rax
	imulq %rbx
	movq %rax, %r12
	movq -24(%rbp), %rbx
	addq %r12, %rbx
	movq $40, (%rbx)
	movq $8, %rbx
	movq $4, %r12
	movq %r12, %rax
	imulq %rbx
	movq %rax, %r12
	movq -24(%rbp), %rbx
	addq %r12, %rbx
	movq $50, (%rbx)
	movq $0, -32(%rbp)
.L0:
	movq $5, %rbx
	movq -32(%rbp), %r12
	cmp %rbx, %r12
	jge .L1
	movq $8, %rbx
	movq -32(%rbp), %r12
	movq %r12, %rax
	imulq %rbx
	movq %rax, %r12
	movq -24(%rbp), %rbx
	addq %r12, %rbx
	movq (%rbx), %rdi
	movq %rdi, %rsi
	leaq .LC0(%rip), %rdi
	movl $0, %eax
	call printf@PLT
	movq -32(%rbp), %rbx
	movq $1, %r12
	movq -32(%rbp), %r13
	addq %r12, %r13
	movq %r13, -32(%rbp)
	jmp .L0
.L1:
	leave
	ret
