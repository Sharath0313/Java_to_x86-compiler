.LC0:
	.string "%d\n"
	.text
	.globl GFG.fib
	.type GFG.fib, @function
GFG.fib:
	pushq %rbp
	movq %rsp, %rbp
	subq $24, %rsp
	movq %rdi, -8(%rbp)
	movq %rsi, -16(%rbp)
	movq $1, %rbx
	movq -8(%rbp), %r12
	cmp %rbx, %r12
	jg .L0
	movq -8(%rbp), %rax
	leave
	ret
.L0:
	movq $1, %rbx
	movq -8(%rbp), %r12
	subq %rbx, %r12
	movq -16(%rbp), %rsi
	movq %r12, %rdi
	call GFG.fib
	movq %rax, %rbx
	movq $2, %r12
	movq -8(%rbp), %r13
	subq %r12, %r13
	pushq %rbx
	movq -16(%rbp), %rsi
	movq %r13, %rdi
	call GFG.fib
	movq %rax, %r12
	popq %rbx
	addq %r12, %rbx
	movq %rbx, %rax
	leave
	ret
	.text
	.globl main
	.type main, @function
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $40, %rsp
	movq %rdi, -8(%rbp)
	movq %rsi, -16(%rbp)
	movq $10, -24(%rbp)
	movq $0, -32(%rbp)
.L1:
	movq -24(%rbp), %rbx
	movq -32(%rbp), %r12
	cmp %rbx, %r12
	jge .L2
	movq -16(%rbp), %rsi
	movq -32(%rbp), %rdi
	call GFG.fib
	movq %rax, %rbx
	movq %rbx, %rdi
	movq %rdi, %rsi
	leaq .LC0(%rip), %rdi
	movl $0, %eax
	call printf@PLT
	movq -32(%rbp), %rbx
	movq $1, %r12
	movq -32(%rbp), %r13
	addq %r12, %r13
	movq %r13, -32(%rbp)
	jmp .L1
.L2:
	leave
	ret
