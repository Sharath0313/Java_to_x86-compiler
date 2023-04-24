.LC0:
	.string "%d\n"
	.text
	.globl Main.sum
	.type Main.sum, @function
Main.sum:
	pushq %rbp
	movq %rsp, %rbp
	subq $24, %rsp
	movq %rdi, -8(%rbp)
	movq %rsi, -16(%rbp)
	movq $0, %rbx
	movq -8(%rbp), %r12
	cmp %rbx, %r12
	jg .L0
	movq $0, %rax
	leave
	ret
	jmp .L1
.L0:
	movq $1, %rbx
	movq -8(%rbp), %r12
	subq %rbx, %r12
	movq -16(%rbp), %rsi
	movq %r12, %rdi
	call Main.sum
	movq %rax, %rbx
	movq -8(%rbp), %r12
	addq %rbx, %r12
	movq %r12, %rax
	leave
	ret
.L1:
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
	movq -16(%rbp), %rsi
	movq $10, %rdi
	call Main.sum
	movq %rax, %rbx
	movq %rbx, -24(%rbp)
	movq -24(%rbp), %rdi
	movq %rdi, %rsi
	leaq .LC0(%rip), %rdi
	movl $0, %eax
	call printf@PLT
	leave
	ret
