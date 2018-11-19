.data
_Prompt: .asciiz "Enter an integer:  "
_ret: .asciiz "\n"
.globl main
.text
read:
  li $v0,4
  la $a0,_Prompt
  syscall
  li $v0,5
  syscall
  jr $ra
write:
  li $v0,1
  syscall
  li $v0,4
  la $a0,_ret
  syscall
  move $v0,$0
  jr $ra

main:
  addi $sp, $sp, -96
  li $t3, 1
  sw $t3, 52($sp)
  li $t3, 0
  sw $t3, 60($sp)
  lw $t1, 60($sp)
  move $t3, $t1
  sw $t3, 56($sp)
  li $t3, 0
  sw $t3, 72($sp)
  lw $t1, 72($sp)
  move $t3, $t1
  sw $t3, 68($sp)
  li $t3, 1
  sw $t3, 80($sp)
  lw $t1, 80($sp)
  move $t3, $t1
  sw $t3, 76($sp)
  addi $sp, $sp, -4
  sw $ra,0($sp)
  jal read
  lw $ra,0($sp)
  addi $sp, $sp, 4
  sw $v0, 84($sp)
  lw $t1, 84($sp)
  move $t3, $t1
  sw $t3, 64($sp)
label5:
  lw $t1, 56($sp)
  lw $t2, 64($sp)
  blt $t1,$t2,label4
  j label3
label4:
  lw $t1, 68($sp)
  lw $t2, 76($sp)
  add $t3,$t1,$t2
  sw $t3, 88($sp)
  lw $t1, 88($sp)
  move $t3, $t1
  sw $t3, 84($sp)
  lw $t1, 56($sp)
  lw $t2, 52($sp)
  mul $t3,$t1,$t2
  sw $t3, 96($sp)
  lw $t1, 96($sp)
  move $t3, $t1
  sw $t3, 96($sp)
  lw $t1, 76($sp)
  move $t3, $t1
  sw $t3, 92($sp)
  lw $t1, 76($sp)
  move $t3, $t1
  sw $t3, 68($sp)
  lw $t1, 84($sp)
  move $t3, $t1
  sw $t3, 76($sp)
  lw $t3, 56($sp)
  addi $t3, $t3, 1
  sw $t3, 56($sp)
  j label5
label3:
  li $t3, 0
  sw $t3, 84($sp)
  lw $t1, 84($sp)
  move $t3, $t1
  sw $t3, 56($sp)
  li $t3, 2
  sw $t3, 84($sp)
  lw $t1, 84($sp)
  lw $t2, 52($sp)
  mul $t3,$t1,$t2
  sw $t3, 92($sp)
  lw $t1, 92($sp)
  move $t3, $t1
  sw $t3, 92($sp)
  lw $t3, 88($sp)
  addi $t3, $t3, 1
  sw $t3, 88($sp)
label13:
  lw $t1, 56($sp)
  lw $t2, 64($sp)
  blt $t1,$t2,label12
  j label11
label12:
  lw $t1, 56($sp)
  lw $t2, 52($sp)
  mul $t3,$t1,$t2
  sw $t3, 88($sp)
  lw $t1, 88($sp)
  move $t3, $t1
  sw $t3, 88($sp)
  lw $a0, 84($sp)
  addi $sp, $sp, -4
  sw $ra,0($sp)
  jal write
  lw $ra,0($sp)
  addi $sp, $sp, 4
  lw $t3, 56($sp)
  addi $t3, $t3, 1
  sw $t3, 56($sp)
  j label13
label11:
  li $t3, 0
  sw $t3, 84($sp)
  lw $v0,84($sp)
  jr $ra
label1:
