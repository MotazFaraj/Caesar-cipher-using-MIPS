#Motaz Faraj-1190553
#Saliba Musleh-1190852
# First Project
# Objective:Text Message Encryption and Decryption.
# Input: read strings from the input file plain text , Output: is the encrypted string saved in cipher text
# Input: read encrypted strings from the input file cipher text , Output: is the decrypted string saved in plain text
################### Data segment ###################
.data
myFile: .space 20 
myFile2: .space 20 
myWrite: .space 20
myWrite2: .space 20
buffer: .space 10000
ModData: .space 10000
eData: .space 10000
dData: .space 10000
ndData: .space 10000
neData: .space 10000
wordcount:.space 100
nwordcount:.space 100
newline: .asciiz "\n"
array_max:  .asciiz "\nShift Value: "
inputFileStringE: .asciiz "\nPlease input the name of the plain text file:"
inputFileStringD: .asciiz "\nPlease input the name of the cipher text file:"
InputStringMenu: .asciiz "Please choose one of the following choices:\ne.Encryption\nd.decryption\nx.exit\n"
InputStringWrongChoice: .asciiz "Wrong choice please choose another"
inputchoice1: .byte 5 
ShiftValue: .byte
nShiftValue: .byte
str_data_end:
################### Code segment ###################
.text
.globl main
main:
	menu:
	li $v0, 4
	la $a0, newline
	syscall
	li $v0, 4
	la $a0, InputStringMenu
	syscall
	li $v0 , 8
	la $a0 , inputchoice1
	li $a1 , 2
	syscall
	lb $s5 , inputchoice1
	beq $s5 , 'e' , Encryptionchoice
	beq $s5 , 'd' , decryptionchoice
	beq $s5 , 'x' , Exitchoice
	j Wrongchoice	
#*****************
#*****************
#*****************
#if the user choses Encryption
#*****************
Encryptionchoice:
#read filename
#*****************
li $v0, 4
la $a0, inputFileStringE
syscall
li $v0 , 8
la $a0 , myFile
li $a1 , 10
syscall
#*****************
#open file
#*****************
li   $v0, 13          # system call for open file
la   $a0, myFile      # input file name
li   $a1, 0           # flag for reading
li   $a2, 0           # mode is ignored
syscall               # open a file 
move $s0, $v0         # save the file descriptor  
#*****************
# reading from file just opened
#*****************
li   $v0, 14        # system call for reading from file
move $a0, $s0       # file descriptor 
la   $a1, buffer    # address of buffer from which to read
li   $a2,  100       # hardcoded buffer length
syscall             # read from file
#*****************
#save data
#*****************
la $a0 , buffer
la $a1 , wordcount
la $a2 , ModData
#*****************
#to lower case
#*****************
li $t0 , 0 
li $t1 , 0
loop:
    lb  $t1,buffer($t0)
    beq $t1, 0, exit
    blt $t1, 'A', case
    bgt $t1, 'Z', case
    sub $t1, $t1, -32
    sb $t1, buffer($t0)    
case: 
    addi $t0, $t0, 1
    j loop
exit:
#*****************
#remove non-alphabet characters
#*****************
li $t0 , 0 
li $t1 , 0
stripNonAlpha:
	lb $t2 , buffer($t0)
	beq $t2 , 0 , stripEnd
	beq $t2 , ' ' , save
	beq $t2 , '\n' , save  
	#blt $t2 , 'a' , save
	#bgt $t2 , 'z' , save
	slti	$t4, $t2, 96		#if ascii code is greater than 96
	slti	$t5, $t2, 123		#if ascii code is less than 123
	slt	$t6, $t4, $t5
	bne	$t6, $zero, save
	j next
next:	
	addi $t0, $t0, 1	#i = i + 1
	j stripNonAlpha		#go to stripNonAlpha
save:
	sb $t2, ModData($t1)
	addi $t1 , $t1 , 1	#j = j + 1        
	addi $t0, $t0, 1	#i = i + 1
	j stripNonAlpha		#go to stripNonAlpha
stripEnd:
#*****************
#find the number of charecters in each word 
#*****************
li $t0 , 0
li $t4 , 0
count: 
	lb  $t1, ModData($t0)
	beq $t1 , 0 , exit2
	beq $t1 , ' ' , next2
	beq $t1 , '\n', next2
	addi $t3 , $t3 , 1
	j next3
next2:	
	sb $t3, wordcount($t4)
	li $t3 , 0
	addi $t4 , $t4 , 1
	addi $t0, $t0, 1   #i = i + 1
	j count		   #go to stripNonAlpha
next3:
	addi $t0, $t0, 1
	j count
exit2:
#*****************
#find max value which is the Shift value 
#*****************
    la $a0, wordcount
    li $a1, 25
    lb $t2, ($a0) # max
    lb $t3, ($a0) # min
    loop_array:
        beq $a1, $zero, print_and_exit
        lb $t0, ($a0)
        bge $t0, $t3, not_min # if (current_element >= current_min) {don't modify min} 
        move $t3, $t0
        not_min:
        ble $t0, $t2, not_max # if (current_element <= current_max) {don't modify max}
        move $t2, $t0
        not_max:
        addi $a1, $a1, -1
        addi $a0, $a0, 4
        j loop_array       
  print_and_exit:
    # print minimum
    sb $t2 , ShiftValue
    li $v0, 4
    la $a0, array_max
    syscall
    lb $t9 ,ShiftValue
    li $v0, 1
    move $a0, $t9
    syscall 
#***************** 
#Encryption	      
#*****************
#this is a code to Encrypt a charecter by adding the shift value to the charecter
#two cases where consider the first is when the output of the addtion dosen't exead the value of the char 'z'
#the second is when it dose exead the char 'z'
#and to solve this the difference between the char we want to encrypt and the char 'z' is found
#then it is compared with the shift value 
#if the shift value is larger then it will be subtracted from the difference and added to the char 'a' => LargDiff
#if the shift value is less than or equal the difference then it will be added to the char we want to encrypt => SmallDiff 
li $t0 , 0
li $t8 , 0
lb $t1 , ShiftValue
Encrypt:
	lb $t2 , ModData($t0)
	beq $t2 , 0 , EndEncrypt
	beq $t2 , ' ' , nextToEncrypt
	beq $t2 , '\n' , nextToEncrypt
	li $t6 , 0
	li $t7 , 'z'
	sub $t6 , $t7 , $t2
	bgt $t1 , $t6 , LargDiff 
	ble $t1 , $t6 , SmallDiff
nextToEncrypt:
	sb $t2 , eData($t8)
	addi $t8 , $t8 , 1
	addi $t0 , $t0 , 1
	j Encrypt
LargDiff:
	li $t5 , 0
	li $t3 , 'a'
	sub $t5 , $t1 , $t6
	subi $t5 , $t5 , 1
	add $t3 , $t3 , $t5
	sb $t3 , eData($t8)
	addi $t8 , $t8 , 1
	addi $t0 , $t0 , 1
	j Encrypt
SmallDiff:
	li $t9 , 0
	add $t9 , $t2 , $t1
	sb $t9 , eData($t8)
	addi $t8 , $t8 , 1
	addi $t0 , $t0 , 1
	j Encrypt	
EndEncrypt:
#*****************
#write to file 
#***************** 
	li $v0, 4
	la $a0, inputFileStringD
	syscall
	li $v0 , 8
	la $a0 , myWrite
	li $a1 , 11
	syscall
	#open file
	li   $v0, 13          
	la   $a0, myWrite      
	li   $a1, 1           
	syscall 
	move $s3 , $v0
	li $v0, 15
   	move $a0, $s3
   	la $a1, eData
   	la $a2, 100
    	syscall	
    	li $v0, 16  
    	move $a0 , $s3
    	syscall
    	j menu
#*****************
#*****************
#*****************
#if the user choses decryption
#*****************
decryptionchoice:
#read filename
#*****************
li $v0, 4
la $a0, inputFileStringD
syscall
li $v0 , 8
la $a0 , myFile2
li $a1 , 11
syscall
#*****************
#open file
#*****************
li   $v0, 13          # system call for open file
la   $a0, myFile2      # input file name
li   $a1, 0           # flag for reading
li   $a2, 0           # mode is ignored
syscall               # open a file 
move $s0, $v0         # save the file descriptor  
#*****************
# reading from file just opened
#*****************
li   $v0, 14        # system call for reading from file
move $a0, $s0       # file descriptor 
la   $a1, neData    # address of buffer from which to read
li   $a2,  100       # hardcoded buffer length
syscall
#*****************
#find the number of charecters in each word 
#*****************
li $t0 , 0
li $t4 , 0
count2: 
	lb  $t1, neData($t0)
	beq $t1 , 0 , exit12
	beq $t1 , ' ' , next12
	beq $t1 , '\n', next12
	addi $t3 , $t3 , 1
	j next13
next12:	
	sb $t3, nwordcount($t4)
	li $t3 , 0
	addi $t4 , $t4 , 1
	addi $t0, $t0, 1   #i = i + 1
	j count2		   #go to stripNonAlpha
next13:
	addi $t0, $t0, 1
	j count2
exit12:
#*****************
#find max value which is the Shift value 
#*****************
    la $a0, nwordcount
    li $a1, 25
    lb $t2, ($a0) # max
    lb $t3, ($a0) # min
    loop_array1:
        beq $a1, $zero, print_and_exit1
        lb $t0, ($a0)
        bge $t0, $t3,  not_min1 # if (current_element >= current_min) {don't modify min} 
        move $t3, $t0
        not_min1:
        ble $t0, $t2, not_max1 # if (current_element <= current_max) {don't modify max}
        move $t2, $t0
        not_max1:
        addi $a1, $a1, -1
        addi $a0, $a0, 4
        j loop_array1     
  print_and_exit1:
    # print minimum
    subi $t2 , $t2 , 92
    sb $t2 , nShiftValue
    li $v0, 4
    la $a0, array_max
    syscall
    lb $t9 ,nShiftValue
    li $v0, 1
    move $a0, $t9
    syscall 
#***************** 
# Decryption
#*****************
#this is a code to Decrypt a charecter by subtracting the charecter from the shift value 
#two cases where consider the first is when the output of the subtraction dosen't go below the value of the char 'a'
#the second is when it dose go below the char 'a'
#and to solve this the difference between the char we want to encrypt and the char 'a' is found
#then it is compared with the shift value 
#if the shift value is larger then it will be subtracted from the difference and then the char 'z' will be subtracted from the first subtraction=> LargDiff
#if the shift value is less than or equal the difference then the char will be subtracted from the shift value => SmallDiff 
li $t0 , 0
li $t8 , 0
lb $t1 , nShiftValue
Decrypt:
	lb $t2 , neData($t0)
	beq $t2 , 0 , EndDecrypt
	beq $t2 , ' ' , nextToDecrypt
	beq $t2 , '\n' , nextToDecrypt
	li $t6 , 0
	li $t7 , 'a'
	sub $t6 , $t2 , $t7
	bgt $t1 , $t6 , LargDiff2 
	ble $t1 , $t6 , SmallDiff2
nextToDecrypt:
	sb $t2 , ndData($t8)
	addi $t8 , $t8 , 1
	addi $t0 , $t0 , 1
	j Decrypt
LargDiff2:
	li $t5 , 0
	li $t3 , 'z'
	sub $t5 , $t1 , $t6
	subi $t5 , $t5 , 1
	sub $t3 , $t3 , $t5
	sb $t3 , ndData($t8)
	addi $t8 , $t8 , 1
	addi $t0 , $t0 , 1
	j Decrypt
SmallDiff2:
	li $t9 , 0
	sub $t9 , $t2 , $t1
	sb $t9 , ndData($t8)
	addi $t8 , $t8 , 1
	addi $t0 , $t0 , 1
	j Decrypt	
EndDecrypt:
#*****************
#write to file 
#***************** 
	li $v0, 4
	la $a0, inputFileStringE
	syscall
	li $v0 , 8
	la $a0 , myWrite2
	li $a1 , 11
	syscall
	#open file
	li   $v0, 13          
	la   $a0, myWrite2      
	li   $a1, 1           
	syscall 
	move $s3 , $v0
	li $v0, 15
   	move $a0, $s3
   	la $a1, ndData
   	la $a2, 100
    	syscall	
    	li $v0, 16  
    	move $a0 , $s3
    	syscall
    	j menu
#*****************
#if the user entrs a Wrong Choice
#*****************
Wrongchoice:
li $v0, 4
la $a0, InputStringWrongChoice
syscall
j menu
#*****************
#exit the program
#*****************   	
Exitchoice:
li $v0, 10
syscall
#*****************
