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
	movq $3, -24(%rbp)
	movq -24(%rbp), %rdi
	movq %rdi, %rsi
	leaq .LC0(%rip), %rdi
	movl $0, %eax
	call printf@PLT
	leave
	ret
