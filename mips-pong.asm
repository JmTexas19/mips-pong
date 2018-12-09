#Julian Marin (jcm5814)
#October 24, 2018
#MIPS SIMON SAYS

.data
	#STACK
	stack_beg:
       				.word   0 : 80
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
        .byte   'W', 0x00,0xC6,0xC6,0xC6,0xC6,0xD6,0xD6,0x6C,0x6C,0x6C,0x00,0x00	
        .byte   'I', 0x00,0x78,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x78,0x00,0x00	
        .byte	'N', 0x00,0xC6,0xC6,0xE6,0xF6,0xFE,0xDE,0xCE,0xC6,0xC6,0x00,0x00
        .byte	'L', 0x00,0xf0,0x60,0x60,0x60,0x60,0x62,0x66,0x66,0xfe,0x00,0x00
        .byte	'O', 0x00,0x38,0x6C,0xC6,0xC6,0xC6,0xC6,0xC6,0x6C,0x38,0x00,0x00
        .byte	'S', 0x00,0x78,0xCC,0xCC,0xC0,0x70,0x18,0xCC,0xCC,0x78,0x00,0x00
       	.byte	'E', 0x00,0xFE,0x62,0x60,0x64,0x7C,0x64,0x60,0x62,0xFE,0x00,0x00
        
        #WIN
        win:			.asciiz "WIN"
        lose:			.asciiz "LOSE"
        
        #Digits
        digit0:			.asciiz "0"
        digit1:			.asciiz "1"
	digit2:			.asciiz "2"
	digit3:			.asciiz "3"
	digit4:			.asciiz "4"
	
	#Ball
	xDirection:		.word 	1	
	yDirection:		.word 	0	
	collision:		.word	0
	xOffset:		.word	1
	yOffset:		.word	0
	
	#Paddles
	paddleX:		.word	0
	paddleY:		.word	0
	aiPaddleX:		.word	0
	aiPaddleY:		.word	0
	aiPaddleCenter:		.word  	0
	
	#Score
	pScore:			.word	0
	aiScore:			.word	0
	
.text
main:
	#STACK
	la		$sp, stack_end
	
########################################## SETUP	
	#Draw Paddle 1
	li		$a0, 1
	sw		$a0, paddleX
	li		$a1, 32
	sw		$a1, paddleY
	li		$a2, 7
	li		$a3, 15
	jal		drawVertLine
	
	#Draw Paddle 2
	li		$a0, 62
	sw		$a0, aiPaddleX
	li		$a1, 32
	sw		$a1, aiPaddleY
	li		$a2, 7
	li		$a3, 15
	jal		drawVertLine
	
	#Get Paddle Center AI
	addi		$a1, $a1, -7
	sw		$a1, aiPaddleCenter
	
	#Draw Walls
	li		$a0, 0
	li		$a1, 16
	li		$a2, 7
	li		$a3, 64
	jal		drawHorzLine

	#Draw Walls
	li		$a0, 0
	li		$a1, 15
	li		$a2, 7
	li		$a3, 64
	jal		drawHorzLine
	
	#Draw Walls
	li		$a0, 0
	li		$a1, 63
	li		$a2, 7
	li		$a3, 64
	jal		drawHorzLine
	
	#Draw Walls
	li		$a0, 0
	li		$a1, 62
	li		$a2, 7
	li		$a3, 64
	jal		drawHorzLine
	
	#Draw Score
	jal		drawScore

########################################## SETUP	

########################################## START GAME
	#Spawn Ball
	jal		spawnBall
	jal		getInput

	#EXIT
	exit:
	li		$v0, 17			#Load exit call
	syscall					#Execute
########################################## START GAME

#Procedure: drawScore:
#Draw the score for the players
drawScore:
	#Stack
	addi		$sp, $sp, -4		#Make room on stack for 1 wo
	sw		$ra, 0($sp)		#Store $ra on element 4 of stack
	
	#Score Branches
	lw		$t0, pScore
	li		$a0, 1
	li		$a1, 2
	
	beq		$t0, 0, drawdigit0
	beq		$t0, 1, drawdigit1
	beq		$t0, 2, drawdigit2
	beq		$t0, 3, drawdigit3
	beq		$t0, 4, drawdigit4
	
	#Draw Score P1
	drawdigit0:
	la		$a2, digit0
	jal		outText
	j		aiDrawScore
	
	drawdigit1:
	la		$a2, digit1
	jal		outText
	j		aiDrawScore
	
	drawdigit2:
	la		$a2, digit2
	jal		outText
	j		aiDrawScore
	
	drawdigit3:
	la		$a2, digit3
	jal		outText
	j		aiDrawScore
	
	drawdigit4:
	la		$a2, digit4
	jal		outText
	j		aiDrawScore
	
	#Draw Score AI
	aiDrawScore:
	lw		$t1, aiScore
	li		$a0, 52
	li		$a1, 2
	beq		$t1, 0, drawaidigit0
	beq		$t1, 1, drawaidigit1
	beq		$t1, 2, drawaidigit2
	beq		$t1, 3, drawaidigit3
	beq		$t1, 4, drawaidigit4
	
	drawaidigit0:
	la		$a2, digit0
	jal		outText
	j		doneScore
	
	drawaidigit1:
	la		$a2, digit1
	jal		outText
	j		doneScore
	
	drawaidigit2:
	la		$a2, digit2
	jal		outText
	j		doneScore
	
	drawaidigit3:
	la		$a2, digit3
	jal		outText
	j		doneScore
	
	drawaidigit4:
	la		$a2, digit4
	jal		outText
	j		doneScore
	
	doneScore:
	lw		$ra, 0($sp)		#Restore $ra from stack
	addi		$sp, $sp, 4		#Readjust stack
	jr		$ra			#Return

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
	#Stack
	addi		$sp, $sp, -4		#Make room on stack for 1 wo
	sw		$ra, 0($sp)		#Store $ra on element 4 of stack

	#CALCULATIONS
	sll		$a0, $a0, 2		#Multiply $a0 by 4
	sll		$a1, $a1, 5		#Multiply $a1 by 256
	sll		$a1, $a1, 3		#Multiply $a1 by 4
	add		$a0, $a0, $a1		#Add $a1 to $a0
	addi		$v0, $a0, 0x10040000	#Add base address for display + $a0 to $v0
	
	lw		$ra, 0($sp)		#Restore $ra from stack
	addi		$sp, $sp, 4		#Readjust stack
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
	li		$t0, 0
	sw		$t0, yOffset		#Reset yOffset
	
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
	
	#Delete Old Ball Position
	lw		$a0, 4($sp)		#X
	lw		$a1, 8($sp)		#Y
	li		$a2, 0			#Color
	jal		drawDot
	
	#Check Collision
	lw		$a0, 4($sp)		#X
	lw		$a1, 8($sp)		#Y
	jal		getNextX
	jal		calculateAddress	#Get ball position address
	jal		checkCollision
	
	#Check X Collision
	lw		$t0, collision		#Load collision
	beqz 		$t0, noCollisionX	#If collision, calculate new Y
	
	#Reset Collision
	li		$t0, 0
	sw		$t0, collision

	#Calculate Y Offset
	lw		$a0, 4($sp)		#X
	lw		$a1, 8($sp)		#Y
	jal		getNextX
	jal		getNextY
	jal		calcY
	
	#Flip Sign of offset and X Direction
	lw		$t0, xOffset
	lw		$t1, xDirection
	mul		$t0, $t0, -1
	mul		$t1, $t1, -1
	sw		$t0, xOffset
	sw		$t0, xDirection
	j		moveBall		#Jump to move ball
	
	#No Collision, Continue
	noCollisionX:
	lw		$a0, 4($sp)		#X
	lw		$a1, 8($sp)		#Y
	
	#Check Twice
	jal		getNextY
	jal		calculateAddress	#Get ball position address
	jal		checkCollision
	
	#Check Y Collision
	lw		$t0, collision		#Load collision
	beqz 		$t0, moveBall		#If collision, calculate new Y
	jal		calcYWall

	moveBall:
	#Move
	lw		$a0, 4($sp)		#X
	lw		$a1, 8($sp)		#Y
	lw		$t0, xOffset		#Load offset
	add		$a0, $a0, $t0		#Add
	lw		$t0, yOffset		#Load offset
	add		$a1, $a1, $t0		#Add
	li		$a2, 7			#Color
	sw		$a0, 4($sp)		#Store $ra on element 4 of stack
	sw		$a1, 8($sp)		#Store $ra on element 4 of stack
	jal		drawDot
	
	#Do AI Action
	bne 		$s5, 5, skipAIAction	#Counter
	lw		$a0, 4($sp)		#X
	lw		$a1, 8($sp)		#X
	jal		aiAction		
	li		$s5, 0
	
	skipAIAction:
	addi		$s5, $s5, 1
	#Pause
	li		$a0, 50			#Sleep for 500ms
	li		$v0, 32			#Load syscall for sleep
	syscall					#Execute
	
	#Check Input
	jal		getInput	
	beqz		$v0, skipInput
	beq		$v0, 119, moveUp	#If input is w, move paddle up
	beq		$v0, 115, moveDown	#If input is s, move paddle up
	j		skipInput

	#Move Paddle Up
	moveUp:
	#PRINT INTRO
	li		$a0, 0			#Set $a0 to move up
	jal		movePaddle
	j		skipInput
	
	#Move Paddle Down
	moveDown:
	li		$a0, 1			#Set $a0 to move down
	jal		movePaddle
	j		skipInput
	
	skipInput:
	#Loop
	j		ballLoop
	
	#RESTORE $RA
	lw		$ra, 0($sp)		#Restore $ra from stack
	addi		$sp, $sp, 4		#Readjust stack
	
	#Return
	jr		$ra
	
#Procedure: calcYWall
#Calculates Y reflection of wall
#$a0 = x
#$a1 = y		
calcYWall:
	#Check Direction
	lw		$t0, yDirection
	beq		$t0, 1, reflectUp
	beq		$t0, -1, reflectDown

	#Up
	reflectUp:
	#Change Direction
	li		$t0, -1
	sw		$t0, yDirection
	#Flip Sign of offset
	lw		$t0, yOffset
	mul		$t0, $t0, -1
	sw		$t0, yOffset
	
	#Reset Collision
	li		$t1, 0				#Collision
	sw		$t1, collision			#Store collision
	
	#Return
	jr		$ra
	
	reflectDown:
	#Change Direction
	li		$t0, 1
	sw		$t0, yDirection
	#Flip Sign of offset
	lw		$t0, yOffset
	mul		$t0, $t0, -1
	sw		$t0, yOffset
	
	#Reset Collision
	li		$t1, 0				#Collision
	sw		$t1, collision			#Store collision
	
	#Return
	jr		$ra

#Procedure: checkCollision
#Checks if collision 
checkCollision:
	#Stack
	addi		$sp, $sp, -4		#Make room on stack for 1 words
	sw		$ra, 0($sp)		#Store $ra on element 4 of stack

	#Get Ball Address Color
	lw		$t1, 0($v0)			#Get color of ball position
	move		$t2, $t1			#Copy because broken stuff
	
	#Check if white or black
	beqz  	 	$t2, noCollision
	li		$t1, 1				#Collision
	sw		$t1, collision			#Store collision	
	lw		$ra, 0($sp)			#Restore $ra from stack
	addi		$sp, $sp, 4			#Readjust stack
	
	#Play Ball Collision Sound
	li		$a0, 100			#Pitch
	li		$a1, 300		#Duration
	li		$a2, 5			#Instrument
	li		$a3, 127		#Volume
	li		$v0, 31			#Load syscall
	syscall					#Execute
	
	jr		$ra
	
	noCollision:	
	#Return
	lw		$ra, 0($sp)		#Restore $ra from stack
	addi		$sp, $sp, 4		#Readjust stack
	jr		$ra	
	
#Procedure: calcY
#Calculates Y offset and direction based on paddle collision
#$a0 = x
#$a1 = y		
calcY:
	#Stack
	addi		$sp, $sp, -12		#Make room on stack for 1 words
	sw		$ra, 0($sp)		#Store $ra on element 4 of stack
	sw		$a0, 4($sp)		#Store $ra on element 4 of stack
	sw		$a1, 8($sp)		#Store $ra on element 4 of stack
	
	li		$v0, 0
	jal		calculateAddress	#Get Memory address of current position
	addi		$v0, $v0, -256		#Increment Address by 1 in y direction

	#Calculate direction of y
	li		$s0, 0			#Counter for paddles
	yLoop:
	addi		$s0, $s0, 1		#Increment Address by 1 in y direction
	
	#Increment Address
	addi		$v0, $v0, -256		#Increment Address by 1 in y direction
	lw		$t1, 0($v0)		#Get color of ball position
	move		$t2, $t1		#Copy because broken stuff
	beqz		$t2, finishCalcLoop
	j		yLoop
	
	finishCalcLoop:
	bgt		$s0, 11,yFarBottom
	bgt		$s0, 7, ySlightBottom
	beq 		$s0, 7, yStraight
	bgt		$s0, 3, ySlightTop
	
	#Hit Far Top
	lw		$a1, 8($sp)		#Store $ra on element 4 of stack
	li		$t0, -2
	li		$t1, 1
	sw		$t1, yDirection
	sw		$t0, yOffset
	
	
	#RESTORE $RA
	lw		$a0, 4($sp)		#Store $ra on element 4 of stack
	lw		$ra, 0($sp)		#Restore $ra from stack
	addi		$sp, $sp, 12		#Readjust stack
	jr		$ra
	
	#Hit Middle
	yStraight:
	lw		$a0, 4($sp)		#Store $ra on element 4 of stack
	lw		$a1, 8($sp)		#Store $ra on element 4 of stack
	li		$t1, 0
	sw		$t1, yDirection
	
	#RESTORE $RA
	lw		$ra, 0($sp)		#Restore $ra from stack
	addi		$sp, $sp, 12		#Readjust stack
	jr		$ra
	
	#Hit Top
	ySlightTop:
	lw		$a0, 4($sp)		#Store $ra on element 4 of stack
	lw		$a1, 8($sp)		#Store $ra on element 4 of stack
	li		$t1, 1
	sw		$t1, yDirection
	li		$t0, -1
	sw		$t0, yOffset
	
	#RESTORE $RA
	lw		$ra, 0($sp)		#Restore $ra from stack
	addi		$sp, $sp, 12		#Readjust stack
	jr		$ra
	
	#Hit Bottom
	ySlightBottom:
	lw		$a0, 4($sp)		#Store $ra on element 4 of stack
	lw		$a1, 8($sp)		#Store $ra on element 4 of stack
	li		$t1, -1
	sw		$t1, yDirection
	li		$t0, 1
	sw		$t0, yOffset
	
	#RESTORE $RA
	lw		$ra, 0($sp)		#Restore $ra from stack
	addi		$sp, $sp, 12		#Readjust stack
	jr		$ra
	
	#Hit Far Bottom
	yFarBottom:
	lw		$a0, 4($sp)		#Store $ra on element 4 of stack
	lw		$a1, 8($sp)		#Store $ra on element 4 of stack
	li		$t1, -1
	sw		$t1, yDirection
	li		$t0, 2
	sw		$t0, yOffset
	
	#RESTORE $RA
	lw		$ra, 0($sp)		#Restore $ra from stack
	addi		$sp, $sp, 12		#Readjust stack
	jr		$ra

#Procedure: getNextX
#Calculates next coordinates for X
#$a0 = x
getNextX:
	#Check X Direction
	lw		$t0, xOffset
	add		$a0, $a0, $t0
	
	ble 		$a0, 0, endRound		#If ball reaches edge, end round
	bge 		$a0, 63, endRound		#If ball reaches edge, end round
	jr		$ra

#Procedure: checkNextY
#Calculates next coordinates for Y
#$a1 = y
getNextY:
	#Check Y Direction
	lw		$t0, yDirection
	beq		$t0, 1, upY
	beq		$t0, 0, straightY
	beq		$t0, -1,downY
	
	upY:
	addi		$a1, $a1, -2		#Increment y by 2
	jr		$ra
	
	downY:
	addi		$a1, $a1, 2		#Decrement y by 2
	jr		$ra
	
	straightY:
	jr		$ra
	
#Procedure: endRound
#endRound and Increment Point
endRound:	
	ble 		$a0, 0, incrementAI
	
	#Add P Point
	#Clear Paddles
	li		$a0, 1
	li		$a1, 17
	li		$a2, 0
	li		$a3, 45
	jal		drawVertLine
	li		$a0, 62
	li		$a1, 17
	li		$a2, 0
	li		$a3, 45
	jal		drawVertLine
	
	#Reset Paddle Limits
	li		$s3, 0		#Reset Paddle Counter
	li		$s4, 0		#Reset Paddle Counter
	
	#Increment Score
	lw		$t0, pScore
	addi		$t0, $t0, 1
	sw		$t0, pScore
	
	#Play Sounds
	li		$a0, 100		#Pitch
	li		$a1, 300		#Duration
	li		$a2, 5			#Instrument
	li		$a3, 127		#Volume
	li		$v0, 31			#Load syscall
	syscall	
	
	#Pause
	li		$a0, 200		#Sleep for 500ms
	li		$v0, 32			#Load syscall for sleep
	syscall					#Execute
	
	li		$a0, 105		#Pitch
	li		$v0, 31			#Load syscall
	syscall	
	
	beq  		$t0, 4, winGame
	j		main
	
	#Add Ai Point
	incrementAI:
	#Clear Paddles
	li		$a0, 1
	li		$a1, 17
	li		$a2, 0
	li		$a3, 45
	jal		drawVertLine
	li		$a0, 62
	li		$a1, 17
	li		$a2, 0
	li		$a3, 45
	jal		drawVertLine
	
	#Reset Paddle Limits
	li		$s3, 0		#Reset Paddle Counter
	li		$s4, 0		#Reset Paddle Counter
	
	#Increment Score
	lw		$t0, aiScore
	addi		$t0, $t0, 1
	sw		$t0, aiScore
	
	#Play Sounds
	li		$a0, 100		#Pitch
	li		$a1, 300		#Duration
	li		$a2, 5			#Instrument
	li		$a3, 127		#Volume
	li		$v0, 31			#Load syscall
	syscall	
	
	#Pause
	li		$a0, 200		#Sleep for 500ms
	li		$v0, 32			#Load syscall for sleep
	syscall					#Execute
	
	li		$a0, 105		#Pitch
	li		$v0, 31			#Load syscall
	syscall	
		
	beq  		$t0, 4, loseGame
	j		main
	

#Procedure: winGame
#Player wins game, display winner screen
winGame:
	#Reset Scores
	jal		drawScore
	li		$t0, 0
	sw		$t0, aiScore
	sw		$t0, pScore
	
	#Draw Score WIN
	li		$a0, 18
	li		$a1, 30
	la		$a2, win
	jal		outText
	
	#Pause
	li		$a0, 2000		#Sleep for 500ms
	li		$v0, 32			#Load syscall for sleep
	syscall					#Execute
	
	#Clear Middle
	li		$a0, 12
	li		$a1, 14
	li		$a2, 0
	li		$a3, 50
	jal		drawBox
	
	#Done
	jal		drawScore
	j		main

#Procedure: loseGame
#Player loses game, display loser screen
loseGame:
	#Reset Scores
	jal		drawScore
	li		$t0, 0
	sw		$t0, aiScore
	sw		$t0, pScore	
	
	#Draw Score LOSE
	li		$a0, 13
	li		$a1, 30
	la		$a2, lose
	jal		outText
	
	#Pause
	li		$a0, 2000		#Sleep for 500ms
	li		$v0, 32			#Load syscall for sleep
	syscall					#Execute
	
	#Done
	jal		drawScore
	
	#Clear Middle
	li		$a0, 12
	li		$a1, 14
	li		$a2, 0
	li		$a3, 50
	jal		drawBox
	
	j		main

#Procedure: movePaddle
#Allow player to move paddle up and down
movePaddle:
	#Stack
	addi		$sp, $sp, -4		#Make room on stack for 1 words
	sw		$ra, 0($sp)		#Store $ra on element 4 of stack
	
	#Check which direction to move
	bnez		$a0, paddleDown
		
	bge 		$s3, 5, skipMove	#Max Movement Counter
	#Up
	#Erase Old Line
	lw		$a0, paddleX
	lw		$a1, paddleY
	li		$a2, 0
	li		$a3, 15
	jal		drawVertLine
	
	#Draw New Line
	lw		$a0, paddleX
	lw		$a1, paddleY
	addi		$a1, $a1, -3		#Increment Y
	sw		$a0, paddleX
	sw		$a1, paddleY
	li		$a2, 7
	li		$a3, 15
	jal		drawVertLine
	addi		$s3, $s3, 1
	
	#RESTORE $RA
	lw		$ra, 0($sp)		#Restore $ra from stack
	addi		$sp, $sp, 4		#Readjust stack
	jr		$ra
	
	#Down
	paddleDown:
	
	ble  		$s3, -5, skipMove	#Max Movement Counter
	#Erase Old Line
	lw		$a0, paddleX
	lw		$a1, paddleY
	li		$a2, 0
	li		$a3, 15
	jal		drawVertLine
	
	#Draw New Line
	lw		$a0, paddleX
	lw		$a1, paddleY
	addi		$a1, $a1, 3		#Increment Y
	sw		$a0, paddleX
	sw		$a1, paddleY
	li		$a2, 7
	li		$a3, 15
	jal		drawVertLine
	addi		$s3, $s3, -1
	
	skipMove:
	#RESTORE $RA
	lw		$ra, 0($sp)		#Restore $ra from stack
	addi		$sp, $sp, 4		#Readjust stack
	jr		$ra

#Procedure: drawBox:
#Draw a box on the bitmap display
#$a0 = x coordinate (0-31)
#$a1 = y coordinate (0-31)
#$a2 = colour number (0-7)
#$a3 = size of box (1-32)
drawBox:
	#MAKE ROOM ON STACK AND SAVE REGISTERS
	addi		$sp, $sp, -24		#Make room on stack for 5 words
	sw		$ra, 12($sp)		#Store $ra on element 4 of stack
	sw		$a0, 0($sp)		#Store $a0 on element 0 of stack
	sw		$a1, 4($sp)		#Store $a1 on element 1 of stack
	sw		$a2, 8($sp)		#Store $a2 on element 2 of stack
	sw		$a3, 20($sp)		#Store $a3 on element 5 of stack
	move		$s0, $a3		#Copy $a3 to temp register
	sw		$s0, 16($sp)		#Store $s0 on element 5 of stack
	
	boxLoop:
	jal 		drawHorzLine		#Jump and link to drawHorzLine
	
	#RESTORE REGISTERS
	lw		$a0, 0($sp)		#Restore $a0 from stack
	lw		$a1, 4($sp)		#Restore $a1 from stack
	lw		$a2, 8($sp)		#Restore $a2 from stack
	lw		$a3, 20($sp)		#Restore $a3 from stack
	lw		$s0, 16($sp)		#Restore $s0 from stack
	
	#INCREMENT VALUES
	addi		$a1, $a1, 1		#Increment y by 1
	sw		$a1, 4($sp)		#Store $a1 on element 1 of stack
	addi		$s0, $s0, -1		#Decrement counter
	sw		$s0, 16($sp)		#Store $s0 on element 5 of stack
	bne		$s0, $0, boxLoop	#If length is not 0, loop
	
	#RESTORE $RA
	lw		$ra, 12($sp)		#Restore $ra from stack
	addi		$sp, $sp, 24		#Readjust stack
	addi		$s0, $s0, 0		#Reset $s0
	
	jr		$ra			#Return

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
        
#Procedure: aiAction
#Does the action for the AI
aiAction:
	#Stack
	addi		$sp, $sp, -4		#Make room on stack for 1 words
	sw		$ra, 0($sp)		#Store $ra on element 4 of stack
	
	#Check y position of the ball
	lw		$t0, aiPaddleCenter
	blt 		$a1, $t0, moveAIUp
	bgt 		$a1, $t0, moveAIDown

	moveAIUp:
	#Up
	bge  		$s4, 5, skipMove	#Max Movement Counter
	#Erase Old Line
	lw		$a0, aiPaddleX
	lw		$a1, aiPaddleY
	li		$a2, 0
	li		$a3, 15
	jal		drawVertLine
	
	#Draw New Line
	lw		$a0, aiPaddleX
	lw		$a1, aiPaddleY
	addi		$a1, $a1, -3		#Increment Y
	sw		$a0, aiPaddleX
	sw		$a1, aiPaddleY
	li		$a2, 7
	li		$a3, 15
	jal		drawVertLine
	addi		$s4, $s4, 1
	
	#Get Paddle Center AI
	addi		$a1, $a1, -7
	sw		$a1, aiPaddleCenter
	
	#RESTORE $RA
	lw		$ra, 0($sp)		#Restore $ra from stack
	addi		$sp, $sp, 4		#Readjust stack
	jr		$ra
	
	moveAIDown:
	ble  		$s4, -5, skipMove	#Max Movement Counter
	#Erase Old Line
	lw		$a0, aiPaddleX
	lw		$a1, aiPaddleY
	li		$a2, 0
	li		$a3, 15
	jal		drawVertLine
	
	#Draw New Line
	lw		$a0, aiPaddleX
	lw		$a1, aiPaddleY
	addi		$a1, $a1, 3		#Increment Y
	sw		$a0, aiPaddleX
	sw		$a1, aiPaddleY
	li		$a2, 7
	li		$a3, 15
	jal		drawVertLine
	addi		$s4, $s4, -1
	
	#Get Paddle Center AI
	addi		$a1, $a1, -7
	sw		$a1, aiPaddleCenter
	
	#RESTORE $RA
	lw		$ra, 0($sp)		#Restore $ra from stack
	addi		$sp, $sp, 4		#Readjust stack
	jr		$ra


#Procedure: getChar
#Poll the keypad, wait for input
#$v0 = input or nothing
getInput:
	#MAKE ROOM ON STACK AND SAVE REGISTERS
	addi		$sp, $sp, -4		#Make room on stack for 1 words
	sw		$ra, 0($sp)		#Store $ra on element 0 of stack
	li		$s2, 0			#Counter
	j		check			#Skip first sleep
	
	#SLEEP
	li		$a0, 100		#1 second sleep
	li		$v0, 32			#Load syscall for sleep
	syscall					#Execute
	
	#POLLING
	check:
	jal		isCharThere		#Jump and link to isCharThere
	
	leaveChar:
	lui		$t0, 0xffff		#Register 0xffff0000
	lw		$v0, 4($t0)		#Get control
	sw		$0, 4($t0)		#Clear
	
	#RESTORE $RA
	lw		$ra, 0($sp)		#Restore $ra from stack
	addi		$sp, $sp, 4		#Readjust stack
	jr		$ra
	
#Procedure: isCharThere
#Poll the keypad, wait for input
#v0 = 0 (no data) or 1 (char in buffer)
isCharThere:
	lui		$t0, 0xffff		#Register 0xffff0000
	lw		$t1, 0($t0)		#Get control
	and		$v0, $t1, 1		#Look at least significent bit
	jr		$ra
