#Julian Marin (jcm5814)
#October 24, 2018
#MIPS SIMON SAYS

.data
	#STACK
	stack_beg:
       				.word   0 : 40
	stack_end:
	
	#COLOR TABLE
	colourTable:		.word	0x000000	#Black
				.word	0x0000ff	#Blue
				.word	0x00ff00	#Green
				.word	0xff0000	#Red
				.word	0x00ffff	#Blue-Green
				.word	0xff00ff	#Blue-Red
				.word	0xffff00	#Green-Red
				.word	0xffffff	#White

	#DigitTable			
	DigitTable:
        .byte   ' ', 0,0,0,0,0,0,0,0,0,0,0,0
        .byte   '0', 0x7e,0xff,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xff,0x7e
        .byte   '1', 0x38,0x78,0xf8,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18
        .byte   '2', 0x7e,0xff,0x83,0x06,0x0c,0x18,0x30,0x60,0xc0,0xc1,0xff,0x7e
        .byte   '3', 0x7e,0xff,0x83,0x03,0x03,0x1e,0x1e,0x03,0x03,0x83,0xff,0x7e
        .byte   '4', 0xc3,0xc3,0xc3,0xc3,0xc3,0xff,0x7f,0x03,0x03,0x03,0x03,0x03
        
        #Digits
        digit0:			.asciiz "0"
        digit1:			.asciiz "1"
	digit2:			.asciiz "2"
	digit3:			.asciiz "3"
	digit4:			.asciiz "4"
	
	#Ball
	ballDirection:		.word 	0	
	
.text
main:
	#STACK
	la		$sp, stack_end
	
########################################## SETUP	
	#Draw Paddle 1
	li		$a0, 1
	li		$a1, 32
	li		$a2, 7
	li		$a3, 15
	jal		drawVertLine
	
	#Draw Paddle 2
	li		$a0, 62
	li		$a1, 32
	li		$a2, 7
	li		$a3, 15
	jal		drawVertLine
	
	#Draw Walls
	li		$a0, 0
	li		$a1, 16
	li		$a2, 7
	li		$a3, 64
	jal		drawHorzLine
	
	#Draw Score P1
	li		$a0, 1
	li		$a1, 2
	la		$a2, digit0
	jal		outText
	
	#Draw Score P2
	li		$a0, 53
	li		$a1, 2
	la		$a2, digit0
	jal		outText
########################################## SETUP	

########################################## START GAME
	#Spawn Ball
	jal		spawnBall


	#EXIT
	exit:
	li		$v0, 17			#Load exit call
	syscall					#Execute


#Procedure: drawDot:
#Draw a dot on the bitmap display
#$a0 = x coordinate (0-31)
#$a1 = y coordinate (0-31)	
#$a2 = colour number (0-7)
drawDot:
	#MAKE ROOM ON STACK
	addi		$sp, $sp, -8		#Make room on stack for 2 words
	sw		$a2, 0($sp)		#Store $a2 on element 0 of stack
	sw		$ra, 4($sp)		#Store $ra on element 1 of stack

	
	#CALCULATE ADDRESS
	jal		calculateAddress	#returns address of pixel in $v0
	lw		$a2, 0($sp)		#Restore $a2 from stack
	sw		$v0, 0($sp)		#Save $v0 on element 0 of stack
	
	#GET COLOR
	jal		getColour		#Returns colour in $v1
	lw		$v0, 0($sp)		#Restores $v0 from stack
	
	#MAKE DOT AND RESTORE $RA
	sw		$v1, 0($v0)		#Make dot
	lw		$ra, 4($sp)		#Restore $ra from stack
	addi		$sp, $sp, 8		#Readjust stack
	
	jr		$ra			#Return
	
#Procedure: calculateAddress:
#Convert x and y coordinate to address
#$a0 = x coordinate (0-31)
#$a1 = y coordinate (0-31)
#$v0 = memory address
calculateAddress:
	#CALCULATIONS
	sll		$a0, $a0, 2		#Multiply $a0 by 4
	sll		$a1, $a1, 5		#Multiply $a1 by 256
	sll		$a1, $a1, 3		#Multiply $a1 by 4
	add		$a0, $a0, $a1		#Add $a1 to $a0
	addi		$v0, $a0, 0x10040000	#Add base address for display + $a0 to $v0
	
	jr		$ra			#Return
	
#Procedure: getColour:
#Get the colour based on $a2
#$a2 = colour number (0-7)
getColour:
	#GET COLOUR	
	la		$a0, colourTable	#Load Base
	sll		$a2, $a2, 2		#Index x4 is offset
	add		$a2, $a2, $a0		#Address is base + offset
	lw		$v1, 0($a2)		#Get actual color from memory

	jr		$ra			#Return
	
#Procedure: drawHorzLine:
#Draw a horizontal line on the bitmap display
#$a0 = x coordinate (0-31)
#$a1 = y coordinate (0-31)
#$a2 = colour number (0-7)
#$a3 = length of the line
drawHorzLine:
	#MAKE ROOM ON STACK AND SAVE REGISTERS
	addi		$sp, $sp, -16		#Make room on stack for 4 words
	sw		$ra, 12($sp)		#Store $ra on element 4 of stack
	sw		$a0, 0($sp)		#Store $a0 on element 0 of stack
	sw		$a1, 4($sp)		#Store $a1 on element 1 of stack
	sw		$a2, 8($sp)		#Store $a2 on element 2 of stack
	
	#HORIZONTAL LOOP
	horzLoop:
	jal		drawDot			#Jump and Link to drawDot
	
	#RESTORE REGISTERS
	lw		$a0, 0($sp)		#Restore $a0 from stack
	lw		$a1, 4($sp)		#Restore $a1 from stack
	lw		$a2, 8($sp)		#Restore $a2 from stack
	
	#INCREMENT VALUES
	addi		$a0, $a0, 1		#Increment x by 1
	sw		$a0, 0($sp)		#Store $a0 on element 0 of stack
	addi		$a3, $a3, -1		#Decrement length of line
	bne		$a3, $0, horzLoop	#If length is not 0, loop
	
	#RESTORE $RA
	lw		$ra, 12($sp)		#Restore $ra from stack
	addi		$sp, $sp, 16		#Readjust stack
	
	jr		$ra			#Return
	
#Procedure: drawVertLine:
#Draw a vertical line on the bitmap display
#$a0 = x coordinate (0-31)
#$a1 = y coordinate (0-31)
#$a2 = colour number (0-7)
#$a3 = length of the line (1-32)
drawVertLine:
	#MAKE ROOM ON STACK AND SAVE REGISTERS
	addi		$sp, $sp, -16		#Make room on stack for 4 words
	sw		$ra, 12($sp)		#Store $ra on element 4 of stack
	sw		$a0, 0($sp)		#Store $a0 on element 0 of stack
	sw		$a1, 4($sp)		#Store $a0 on element 0 of stack
	sw		$a2, 8($sp)		#Store $a2 on element 2 of stack
	
	#HORIZONTAL LOOP
	vertLoop:
	jal		drawDot			#Jump and Link to drawDot
	
	#RESTORE REGISTERS
	lw		$a0, 0($sp)		#Restore $a0 from stack
	lw		$a1, 4($sp)		#Restore $a1 from stack
	lw		$a2, 8($sp)		#Restore $a2 from stack
	
	#INCREMENT VALUES
	addi		$a1, $a1, 1		#Increment y by 1
	sw		$a1, 4($sp)		#Store $a1 on element 1 of stack
	addi		$a3, $a3, -1		#Decrement length of line
	bne		$a3, $0, vertLoop	#If length is not 0, loop
	
	#RESTORE $RA
	lw		$ra, 12($sp)		#Restore $ra from stack
	addi		$sp, $sp, 16		#Readjust stack
	
	jr		$ra			#Return
	
#Procedure: spawnBall
#Spawns the ball in the middle of the playfield
spawnBall:
	#Ball Coordinates
	li		$a0, 31			#X
	li		$a1, 39			#Y
	
	#Stack
	addi		$sp, $sp, -12		#Make room on stack for 1 words
	sw		$ra, 0($sp)		#Store $ra on element 4 of stack
	sw		$a0, 4($sp)		#Store $ra on element 4 of stack
	sw		$a1, 8($sp)		#Store $ra on element 4 of stack
	
	#Draw Ball
	li		$a2, 7			#Color
	jal		drawDot			#Jump
	
	#Start Ball Movement
	ballLoop:
	#Check Collision
	lw		$a0, 4($sp)		#X
	lw		$a1, 8($sp)		#Y
	addi		$a0, $a0, 1
	jal	calculateAddress		#Get ball position address
	jal	checkCollision
	
	#Delete Old Ball Position
	lw		$a0, 4($sp)		#X
	lw		$a1, 8($sp)		#Y
	li		$a2, 0			#Color
	jal		drawDot
	
	#Move Ball
	lw		$a0, 4($sp)		#X
	lw		$a1, 8($sp)		#Y
	li		$a2, 7			#Color
	addi		$a0, $a0, 1		#Increment x by 1
	sw		$a0, 4($sp)		#Store $ra on element 4 of stack
	sw		$a1, 8($sp)		#Store $ra on element 4 of stack
	jal		drawDot
	
	#Pause
	li		$a0, 100		#Sleep for 500ms
	li		$v0, 32			#Load syscall for sleep
	syscall					#Execute
	
	#Loop
	j	ballLoop
	
	#RESTORE $RA
	lw		$ra, 0($sp)		#Restore $ra from stack
	addi		$sp, $sp, 4		#Readjust stack
	
	#Return
	jr		$ra

#Procedure: checkCollision
#Checks if collision 
checkCollision:
	#Get Ball Address Color
	li	$t0, 16711680			#Red
	lw	$t1, 0($v0)			#Get color of ball position
	move	$t2, $t1			#Copy because broken stuff
	
	#Check if white or black
	beqz   	$t2, noCollision
	sw	$t0, -16($v0)
	
	noCollision:
	#Return
	jr		$ra		




# OutText: display ascii characters on the bit mapped display
# $a0 = horizontal pixel co-ordinate (0-63)
# $a1 = vertical pixel co-ordinate (0-63)
# $a2 = pointer to asciiz text (to be displayed)
outText:
        addiu   $sp, $sp, -24
        sw      $ra, 20($sp)

        li      $t8, 1          # line number in the digit array (1-12)
_text1:
        la      $t9, 0x10040000 # get the memory start address
        sll     $t0, $a0, 2     # assumes mars was configured as 256 x 256
        addu    $t9, $t9, $t0   # and 1 pixel width, 1 pixel height
        sll     $t0, $a1, 8    # (a0 * 4) + (a1 * 4 * 256)
        addu    $t9, $t9, $t0   # t9 = memory address for this pixel

        move    $t2, $a2        # t2 = pointer to the text string
_text2:
        lb      $t0, 0($t2)     # character to be displayed
        addiu   $t2, $t2, 1     # last character is a null
        beq     $t0, $zero, _text9

        la      $t3, DigitTable # find the character in the table
_text3:
        lb      $t4, 0($t3)     # get an entry from the table
        beq     $t4, $t0, _text4
        beq     $t4, $zero, _text4
        addiu   $t3, $t3, 13    # go to the next entry in the table
        j       _text3
_text4:
        addu    $t3, $t3, $t8   # t8 is the line number
        lb      $t4, 0($t3)     # bit map to be displayed

        sw      $zero, 0($t9)   # first pixel is black
        addiu   $t9, $t9, 4

        li      $t5, 8          # 8 bits to go out
_text5:
        li      $t7, 0x000000
        andi    $t6, $t4, 0x80  # mask out the bit (0=black, 1=white)
        beq     $t6, $zero, _text6
        li      $t7, 0xffffff
_text6:
        sw      $t7, 0($t9)     # write the pixel color
        addiu   $t9, $t9, 4     # go to the next memory position
        sll     $t4, $t4, 1     # and line number
        addiu   $t5, $t5, -1    # and decrement down (8,7,...0)
        bne     $t5, $zero, _text5

        sw      $zero, 0($t9)   # last pixel is black
        addiu   $t9, $t9, 4
        j       _text2          # go get another character

_text9:
        addiu   $a1, $a1, 1     # advance to the next line
        addiu   $t8, $t8, 1     # increment the digit array offset (1-12)
        bne     $t8, 13, _text1

        lw      $ra, 20($sp)
        addiu   $sp, $sp, 24
        jr      $ra


