	.data
.align 2	# wyrownanie do 4 bajtow
	.space 2 
header:	.space 55	

input:	.asciiz "Jula.bmp"
output:	.asciiz "Jula.bmp"
liczbaBitow:	.word 1		# rozmiar pliku
szerokosc:	.word 1		# szerokosc pliku
wysokosc:	.word 1		# wysokosc pliku
padding:	.word 1
lbnw:		.word 1		# liczba bitow na wiersz - uwzgledniony padding
Xpocz:		.word 1
Ypocz:		.word 1

liczbaIteracji:	.asciiz "Podaj liczbe iteracji przy generowaniu zb. Julii: "
liczba1:	.asciiz "Wprowadz w formacie z przedziału <-16384; 16384), czyli <-1,1) w kodzie\nWprowadz czesc rzeczywista:\n"
liczba2:	.asciiz "Wprowadz czesc urojona:\n"
b1:		.asciiz "Blad otworania pliku. Koncze program."
.align 0
bmpBuffer:	.space 750000
	.text
	.globl main
	
main:

	li $v0, 4
	la $a0, liczbaIteracji
	syscall 

	li $v0, 5
	syscall

	move $t1, $v0 #t1 liczba iteracji

	li $v0, 4
	la $a0, liczba1
	syscall 

	li $v0, 5
	syscall

	move $s4, $v0 #s4 czesc rzeczywista

	li $v0, 4
	la $a0, liczba2
	syscall 

	li $v0, 5
	syscall

	move $s5, $v0 #s5 czesc zespolona

plikDoOdczytu:
	li $v0, 13
	la $a0, input
	li $a1, 0 #tylko do odczytu
	li $a2, 0
	syscall 
	
	bltz $v0, blad
	move $s0, $v0
	move $a0, $s0
	li $v0, 14
	la $a1, header
	li $a2, 54
	syscall
#zamkniecie pliku	
	li $v0, 16
	move $a0, $s0
	syscall
#odczytanie rozmiarow z headera	
	lw $t4, 18($a1) 
	sw $t4, szerokosc

	lw $t5, 22($a1)
	sw $t5, wysokosc	
				
			
#oblicznie paddingu i liczby pikseli	
	
	andi $s1, $t4, 3
	
	
	
	
	sw $s1,	padding
	
	mul $t6, $t4, 3
	add $t7, $t6, $s1
		sw $t6, lbnw #liczba bitow na wiersz
	mul $t7, $t7, $t5 
	sw $t7, liczbaBitow
	

	#move	$t2, $t4 # szerokosc w t2
	#move	$t3, $t5 # wysokosc w t3

	li $s6, 0 #liczy przy ktorym pixelu jestesmy w rzedzie
	li $s7, 0 #liczy przy ktorym pixelu jestesmy ogolnie
	la $t9, bmpBuffer
#  krok X i Y
	li $t7, 49151	#3 
	div $t7,$t7,$t4
	mflo $t7	#$t7 krok x
	
	li $t8, 49151	#3 
	div $t8,$t8,$t5
	mflo $t8	#$t8 krok y
#iteratory
	li $s6, 0 #liczy przy ktorym bicie jestesmy w rzedzie
	li $s7, 0 #liczy przy ktorym bicie jestesmy ogolnie
	la $t9, bmpBuffer
#punkt p
	li $t2, -24576 #-1,5
	li $t3, -24576	
			
			
	li	$s2, -24576
	li	$s3, -24576
			
nastepnyPixel:
	li $t0, 0 #iteracja dla julii

	lw $t6, liczbaBitow
	bge $s7, $t6, zapisDoPliku
	lw $t6, lbnw 
	bge $s6, $t6, nastepnyRzad
	
	move	$s2, $t2
	move	$s3, $t3
julia:
	#x^2	
	mul $t4, $s2, $s2
		sra $t4, $t4, 14
	#y^2
	mul $t5, $s3,$s3
	sra $t5, $t5, 14
	#x^2-y^2
	sub $t4, $t4, $t5
	#xy
	mul $t5, $s2, $s3
	sra $t5, $t5, 14
	#2xy	
	sll $t5, $t5, 1
	#nowa Re
	add $t4, $t4, $s4
	#nowa Im
	add $t5, $t5, $s5
	
		move	$s2, $t4
		move	$s3, $t5
		
	# |z|^2
	mul $t4, $t4,$t4
	sra $t4, $t4, 14
	mul $t5, $t5, $t5
	sra $t5, $t5, 14
	add $t4, $t4, $t5
	#x^2+y^2<4
	bgt $t4, 65534, zapiszPixel #4
	#zwiekszenie iteracji
	addi $t0, $t0, 1
	
		
		
	
	blt $t0, $t1, julia
	
zapiszPixel:

	li $s1, 10 #color const-B
	li $s2, 7 #color const-G
	li $s3, 5 #color const-R
	#red
	mult $t0, $s1
	mflo $t4

	sb $t4, ($t9)
	addiu $t9, $t9, 1
	#green
	mult $t0, $s2
	mflo $t4
	sb $t4, ($t9)
	addiu $t9, $t9, 1
	#blue
	mult $t0, $s3
	mflo $t4
	sb $t4, ($t9)
	addiu $t9, $t9, 1
	
	add $t2, $t2, $t7
	addi $s6, $s6, 3
	addi $s7, $s7, 3	
	
		#move	$s2, $t2
		#move	$s2, $t3	
	
	j nastepnyPixel
	
nastepnyRzad:
#dodanie paddingu
	lw $a0, padding
	add $s7, $s7, $a0
	add $t9, $t9, $a0
	
	li	$t2, -24576
	
	add $t3, $t3, $t8
	li $s6, 0
	j nastepnyPixel	
	
zapisDoPliku:
	li $v0, 13
	la $a0, output
	li $a1, 1
	li $a2, 0
	syscall
	
	bltz $v0, blad
	move $s0, $v0
	move $a0, $s0
	li $v0, 15
	la $a1, header
	li $a2, 54
	syscall
	
	move $a0, $s0
	li $v0, 15
	la $a1, bmpBuffer
	la $a2, 750000
	syscall
	
koniecProgramu:
	li $v0, 10
	syscall
	
blad:
	li $v0, 4
	la $a0, b1
	syscall
	b koniecProgramu	
