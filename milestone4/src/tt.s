.LC0:
	.string	"%d"
	.text
	.globl	main
	.type	main, @function
main:
    pushq	%rbp
	movq	%rsp, %rbp
    subq	$16, %rsp
    movl    $7, -0(%rbp)
    movl    $9, -4(%rbp)
	movl	-0(%rbp), %eax
    movl    %eax, %esi
	leaq	.LC0(%rip), %rdi
    movl    $0, %eax
    call    printf@PLT
    movl	-4(%rbp), %eax
    movl    %eax, %esi
	leaq	.LC0(%rip), %rdi
    movl    $0, %eax
    call    printf@PLT
    movl    $0, %eax
    leave
    ret
    

