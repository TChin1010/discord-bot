# TYLER BUN LEUNG CHIN UTORID: 1010324953

#####################################################################
# CSCB58 Summer 2025 Assembly Final Project - UTSC
# Name, Student Number, UTorID, official email
# Bitmap Display Configuration:
# - Unit width in pixels: 16 (update this as needed) 
# - Unit height in pixels: 16 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# Which approved features have been implemented?
# (See the assignment handout for the list of features)
# Easy Features:
# 1. Auto gravity
# 2. Speeds up with more lines clearred
# 3. Start with 5 unfinised rows

# Hard Features:
# 1. All shapes
# 2. Delete Animation

# How to play:
# (Include any instructions)
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - no
#
# Any additional information that the TA needs to know:
# - This assignmment has an approved extentsion from the professor
#
#####################################################################

##############################################################################

.data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL: .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD: .word 0xffff0000

##############################################################################
# Mutable Data
##############################################################################
current_shape: .word 0, 0, 0, 0, 0

blocks: .word 0:416
blocks_taken_out: .word 0:416
newline: .asciiz "\n"
space: .asciiz " "
##############################################################################
# Code
##############################################################################
.text
.globl main	
	
main:	
	la $t0, blocks
	addi $t0, $t0, 1344
	li $t1, 0x808080
	li $t2, 0 # counts rows
	li $t3, 0 # counts columns
	li $s4, 0 # how many lines have been completed
	li $s5, 0
	
	create_random_row:
		bge $t2, 5, end_create_random_row
		li $v0, 42
		li $a0, 0
		li $a1, 13
		syscall
		
		li $v0, 1
		li $a0, 1
		syscall
		
		addi $t0, $t0, 4
		
		create_random_column:
			bge $t3, 14, end_create_random_column
			beq $v0, $t3, dont_draw
			sw $t1, 0($t0)
			
			dont_draw:
			
			addi $t0, $t0, 4
			addi $t3, $t3, 1
			j create_random_column
		end_create_random_column:
		
		addi $t0, $t0, 4
		addi $t2, $t2, 1
		j create_random_row
	end_create_random_row:
	
	
	
	la $t0, blocks
	li $t1, 0 # counts the rows that have been counted
	li $t2, 0  #loop or each row
	li $t3, 0 # 0 for do not delete the row and 1 for delete the row
	li $t4, 0 # tracks the location of the start of the row
	
	jal paint
	j game_loop
paint:
	
	lw $t2, ADDR_DSPL
	addi $t2, $t2, 496
	li $t1, 0
	
	draw_boarder_black: # draw the background
		li $t3, 0x000000
		sw $t3, 0($t2)
		addi $t2, $t2, 4
		addi $t1, $t1, 1
		blt $t1, 16, draw_boarder_black
	
	
	li $t0, 14 #box width
	li $t1, 26 #box height
	li $t3, 0 #alternate pattern
	lw $t4, ADDR_DSPL
	li $t6, 0
	li $t7, 0
	li $t8, 0
	addi $t4, $t4, 324
	
	draw_boarder_h:
		bge $t6, $t1, end_draw_boarder_h
		draw_boarder_w:
			bge $t7, $t0, end_draw_boarder_w
			beq $t3, 1, blue_tile
			beq $t3, 2, dark_blue_tile
				li $t8, 0x8da5c2
				li $t3, 1
				j end_tile_chooser
			blue_tile:
				li $t8, 0x7592c7
				li $t3, 2
				j end_tile_chooser
			dark_blue_tile:
				li $t8, 0x6a7cb8
				li $t3, 0
				j end_tile_chooser
			end_tile_chooser:
				
			sw $t8, 0($t4)
			addi $t4, $t4, 4
			addi $t7, $t7, 1
			j draw_boarder_w
		end_draw_boarder_w:
		addi $t4, $t4, 8
		li $t7, 0
		addi $t6, $t6, 1
		j draw_boarder_h
	end_draw_boarder_h:
	
	lw $t0, ADDR_DSPL
	addi $t0, $t0, 320
	la $t1, blocks
	li $t2, 0
	
	spawn_blocks:
		bge $t2, 416, end_spawn_blocks
		lw $t3, 0($t1)
		
		bne $t3, 0, place_block_from_array
		j place_block_from_array_end
		
		place_block_from_array:
			sw $t3, 0($t0)
		place_block_from_array_end:
			addi $t0, $t0, 4
			addi $t1, $t1, 4
			addi $t2, $t2, 1		
		j spawn_blocks
	end_spawn_blocks:
		
	jr $ra

t_control: # CALL THIS FUNCTION WHEN THE CURRENT BLOCK IS A _|_
	lw $t1, ADDR_DSPL
	beq $s0, 1, continue_t_control
	li $v0, 42
	li $a0, 0
	li $a1, 7
	syscall
	move $s1, $a0
	
	li $s1, 2
	addi $s1, $s1, 1
	
	spawn_t:
		bne $s1, 1, spawn_L_R
		li $s0, 1
		li $s2, 0
		li $t0, 0x800080
		sw $t0, 352($t1)
		sw $t0, 420($t1)
		sw $t0, 412($t1)
		sw $t0, 416($t1)
		
		la $t2, current_shape
		li $t0, 352
		sw $t0, 0($t2)
		li $t0, 420
		sw $t0, 4($t2)
		li $t0, 412
		sw $t0, 8($t2)
		li $t0, 416
		sw $t0, 12($t2)
		li $t0, 0x800080
		sw $t0, 16($t2)
		
		j end_t_control
	
	spawn_L_R:
		bne $s1, 2, spawn_I
		li $s0, 1
		li $s2, 0
		li $t0, 0xFF7F00
		sw $t0, 352($t1)
		sw $t0, 416($t1)
		sw $t0, 480($t1)
		sw $t0, 484($t1)
		
		la $t2, current_shape
		li $t0, 352
		sw $t0, 0($t2)
		li $t0, 416
		sw $t0, 4($t2)
		li $t0, 480
		sw $t0, 8($t2)
		li $t0, 484
		sw $t0, 12($t2)
		li $t0, 0xFF7F00
		sw $t0, 16($t2)
		
		j end_t_control
	spawn_I:
		bne $s1, 3, spawn_L_L
		li $s0, 1
		li $s2, 0
		li $t0, 0x69a2ff
		sw $t0, 416($t1)
		sw $t0, 412($t1)
		sw $t0, 420($t1)
		sw $t0, 424($t1)
		
		la $t2, current_shape
		li $t0, 416
		sw $t0, 0($t2)
		li $t0, 412
		sw $t0, 4($t2)
		li $t0, 420
		sw $t0, 8($t2)
		li $t0, 424
		sw $t0, 12($t2)
		li $t0, 0x69a2ff
		sw $t0, 16($t2)
		
		j end_t_control
	spawn_L_L:
		bne $s1, 4, spawn_Square
		li $s0, 1
		li $s2, 0
		li $t0, 0x1616c9
		sw $t0, 352($t1)
		sw $t0, 416($t1)
		sw $t0, 480($t1)
		sw $t0, 476($t1)
		
		la $t2, current_shape
		li $t0, 352
		sw $t0, 0($t2)
		li $t0, 416
		sw $t0, 4($t2)
		li $t0, 480
		sw $t0, 8($t2)
		li $t0, 476
		sw $t0, 12($t2)
		li $t0, 0x1616c9
		sw $t0, 16($t2)
		
		j end_t_control
	spawn_Square:
		bne $s1, 5, spawn_Skew_R
		li $s0, 1
		li $s2, 0
		li $t0, 0xFFFF00
		sw $t0, 352($t1)
		sw $t0, 416($t1)
		sw $t0, 356($t1)
		sw $t0, 420($t1)
		
		la $t2, current_shape
		li $t0, 352
		sw $t0, 0($t2)
		li $t0, 416
		sw $t0, 4($t2)
		li $t0, 356
		sw $t0, 8($t2)
		li $t0, 420
		sw $t0, 12($t2)
		li $t0, 0xFFFF00
		sw $t0, 16($t2)
		
		j end_t_control
	spawn_Skew_R:
		bne $s1, 6, spawn_Skew_L
		li $s0, 1
		li $s2, 0
		li $t0, 0x00FF00
		sw $t0, 352($t1)
		sw $t0, 416($t1)
		sw $t0, 412($t1)
		sw $t0, 356($t1)
		
		la $t2, current_shape
		li $t0, 352
		sw $t0, 0($t2)
		li $t0, 416
		sw $t0, 4($t2)
		li $t0, 412
		sw $t0, 8($t2)
		li $t0, 356
		sw $t0, 12($t2)
		li $t0, 0x00FF00
		sw $t0, 16($t2)
		
		j end_t_control
	spawn_Skew_L:
		li $s0, 1
		li $s2, 0
		li $t0, 0xFF0000
		sw $t0, 352($t1)
		sw $t0, 416($t1)
		sw $t0, 420($t1)
		sw $t0, 348($t1)
		
		la $t2, current_shape
		li $t0, 352
		sw $t0, 0($t2)
		li $t0, 416
		sw $t0, 4($t2)
		li $t0, 420
		sw $t0, 8($t2)
		li $t0, 348
		sw $t0, 12($t2)
		li $t0, 0xFF0000
		sw $t0, 16($t2)
		
		j end_t_control
	
	continue_t_control:
		la $t2, current_shape
		lw $t3, 16($t2)
		
		lw $t0, 0($t2)
		add $t0, $t0, $s3
		add $t1, $t1, $t0
		sw $t3, 0($t1)
		sub $t1, $t1, $t0
		sw $t0, 0($t2)
		
		lw $t0, 4($t2)
		add $t0, $t0, $s3
		add $t1, $t1, $t0
		sw $t3, 0($t1)
		sub $t1, $t1, $t0
		sw $t0, 4($t2)
		
		lw $t0, 8($t2)
		add $t0, $t0, $s3
		add $t1, $t1, $t0
		sw $t3, 0($t1)
		sub $t1, $t1, $t0
		sw $t0, 8($t2)
		
		lw $t0, 12($t2)
		add $t0, $t0, $s3
		add $t1, $t1, $t0
		sw $t3, 0($t1)
		sub $t1, $t1, $t0
		sw $t0, 12($t2)
			
		reset_move:
	
	end_t_control:
	jr $ra

rotate_shape:
	la $t0, current_shape
	addi $s2, $s2, 1
	beq $s2, 4, reset_rotation
	j end_reset_rotation
	reset_rotation:
		li $s2, 0
	end_reset_rotation:
	
	beq $s1, 1, t_rotation
	beq $s1, 2, L_R_rotation
	beq $s1, 3, I_rotation
	beq $s1, 4, L_L_rotation
	beq $s1, 5, square_rotation
	beq $s1, 6, Skew_R_rotation
	beq $s1, 7, Skew_L_rotation
	
	t_rotation:
		beq $s2, 0, t_rotation_0
		beq $s2, 1, t_rotation_1
		beq $s2, 2, t_rotation_2
		beq $s2, 3, t_rotation_3
	
		t_rotation_0:
			lw $t1, 4($t0)	
			subi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 4($t0)
			jr $ra
		t_rotation_1:
			lw $t1, 8($t0)
			addi $t1, $t1, 68
			sw $t1, 8($t0)
			jr $ra
		t_rotation_2:
			lw $t1, 8($t0)
			subi $t1, $t1, 68
			sw $t1, 8($t0)
			lw $t1, 0($t0)
			addi $t1, $t1, 128
			sw $t1, 0($t0)
			jr $ra
		t_rotation_3:
			lw $t1, 4($t0)
			addi $t1, $t1, 60
			sw $t1, 4($t0)
			lw $t1, 0($t0)
			subi $t1, $t1, 128
			sw $t1, 0($t0)
			jr $ra
	L_R_rotation:
		beq $s2, 0, L_R_rotation_0
		beq $s2, 1, L_R_rotation_1
		beq $s2, 2, L_R_rotation_2
		beq $s2, 3, L_R_rotation_3
		
		L_R_rotation_0:
			lw $t1, 4($t0)	
			addi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 4($t0)
			
			lw $t1, 8($t0)	
			addi $a0, $t1, 132
			la $t0, current_shape
			sw $a0, 8($t0)
			
			lw $t1, 12($t0)	
			addi $a0, $t1, 192
			la $t0, current_shape
			sw $a0, 12($t0)
			
			jr $ra

			
		L_R_rotation_1:
			lw $t1, 4($t0)	
			subi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 4($t0)
			
			lw $t1, 8($t0)	
			subi $a0, $t1, 132
			la $t0, current_shape
			sw $a0, 8($t0)
			
			lw $t1, 12($t0)	
			subi $a0, $t1, 72
			la $t0, current_shape
			sw $a0, 12($t0)
			jr $ra
		L_R_rotation_2:
			lw $t1, 4($t0)	
			addi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 4($t0)
			
			lw $t1, 8($t0)	
			addi $a0, $t1, 132
			la $t0, current_shape
			sw $a0, 8($t0)
			
			lw $t1, 12($t0)	
			subi $a0, $t1, 64
			la $t0, current_shape
			sw $a0, 12($t0)
			jr $ra
		L_R_rotation_3:
			lw $t1, 4($t0)	
			subi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 4($t0)
			
			lw $t1, 8($t0)	
			subi $a0, $t1, 132
			la $t0, current_shape
			sw $a0, 8($t0)
			
			lw $t1, 12($t0)	
			subi $a0, $t1, 56
			la $t0, current_shape
			sw $a0, 12($t0)
			
			jr $ra
	
	I_rotation:
		beq $s2, 0, I_rotation_0
		beq $s2, 1, I_rotation_1
		beq $s2, 2, I_rotation_2
		beq $s2, 3, I_rotation_3
		I_rotation_0:
			lw $t1, 4($t0)	
			addi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 4($t0)
			
			lw $t1, 8($t0)	
			subi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 8($t0)
			
			lw $t1, 12($t0)	
			subi $a0, $t1, 120
			la $t0, current_shape
			sw $a0, 12($t0)
			jr $ra
		I_rotation_1:
			lw $t1, 4($t0)	
			subi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 4($t0)
			
			lw $t1, 8($t0)	
			addi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 8($t0)
			
			lw $t1, 12($t0)	
			addi $a0, $t1, 120
			la $t0, current_shape
			sw $a0, 12($t0)
			jr $ra
		I_rotation_2:
			lw $t1, 4($t0)	
			addi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 4($t0)
			
			lw $t1, 8($t0)	
			subi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 8($t0)
			
			lw $t1, 12($t0)	
			subi $a0, $t1, 120
			la $t0, current_shape
			sw $a0, 12($t0)
			jr $ra
		I_rotation_3:
			lw $t1, 4($t0)	
			subi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 4($t0)
			
			lw $t1, 8($t0)	
			addi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 8($t0)
			
			lw $t1, 12($t0)	
			addi $a0, $t1, 120
			la $t0, current_shape
			sw $a0, 12($t0)
			jr $ra
	
	L_L_rotation:
		beq $s2, 0, L_L_rotation_0
		beq $s2, 1, L_L_rotation_1
		beq $s2, 2, L_L_rotation_2
		beq $s2, 3, L_L_rotation_3
		L_L_rotation_0:
			lw $t1, 0($t0)	
			subi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 0($t0)
			
			lw $t1, 8($t0)	
			addi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 8($t0)
			
			lw $t1, 12($t0)	
			subi $a0, $t1, 8
			la $t0, current_shape
			sw $a0, 12($t0)
			
			jr $ra

		L_L_rotation_1:
			lw $t1, 0($t0)	
			addi $a0, $t1, 68
			la $t0, current_shape
			sw $a0, 0($t0)
			
			lw $t1, 8($t0)	
			subi $a0, $t1, 68
			la $t0, current_shape
			sw $a0, 8($t0)
			
			lw $t1, 12($t0)	
			subi $a0, $t1, 128
			la $t0, current_shape
			sw $a0, 12($t0)
			
			jr $ra
		L_L_rotation_2:
			lw $t1, 0($t0)	
			addi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 0($t0)
			
			lw $t1, 8($t0)	
			subi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 8($t0)
			
			lw $t1, 12($t0)	
			addi $a0, $t1, 8
			la $t0, current_shape
			sw $a0, 12($t0)
			jr $ra
		L_L_rotation_3:
			lw $t1, 0($t0)	
			subi $a0, $t1, 68
			la $t0, current_shape
			sw $a0, 0($t0)
			
			lw $t1, 8($t0)	
			addi $a0, $t1, 68
			la $t0, current_shape
			sw $a0, 8($t0)
			
			lw $t1, 12($t0)	
			addi $a0, $t1, 128
			la $t0, current_shape
			sw $a0, 12($t0)
			
			jr $ra
	square_rotation:
		jr $ra
		
	Skew_R_rotation:
		beq $s2, 0, Skew_R_rotation_0
		beq $s2, 1, Skew_R_rotation_1
		beq $s2, 2, Skew_R_rotation_2
		beq $s2, 3, Skew_R_rotation_3
		Skew_R_rotation_0:
			lw $t1, 0($t0)	
			subi $a0, $t1, 68
			la $t0, current_shape
			sw $a0, 0($t0)
			
			lw $t1, 8($t0)	
			addi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 8($t0)
			
			lw $t1, 12($t0)	
			subi $a0, $t1, 128
			la $t0, current_shape
			sw $a0, 12($t0)
			
			jr $ra

		Skew_R_rotation_1:
			lw $t1, 0($t0)	
			addi $a0, $t1, 68
			la $t0, current_shape
			sw $a0, 0($t0)
			
			lw $t1, 8($t0)	
			subi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 8($t0)
			
			lw $t1, 12($t0)	
			addi $a0, $t1, 128
			la $t0, current_shape
			sw $a0, 12($t0)
			
			jr $ra
		Skew_R_rotation_2:
			lw $t1, 0($t0)	
			subi $a0, $t1, 68
			la $t0, current_shape
			sw $a0, 0($t0)
			
			lw $t1, 8($t0)	
			addi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 8($t0)
			
			lw $t1, 12($t0)	
			subi $a0, $t1, 128
			la $t0, current_shape
			sw $a0, 12($t0)
			
			jr $ra
		Skew_R_rotation_3:
			lw $t1, 0($t0)	
			addi $a0, $t1, 68
			la $t0, current_shape
			sw $a0, 0($t0)
			
			lw $t1, 8($t0)	
			subi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 8($t0)
			
			lw $t1, 12($t0)	
			addi $a0, $t1, 128
			la $t0, current_shape
			sw $a0, 12($t0)
			
			jr $ra
	
	Skew_L_rotation:
		beq $s2, 0, Skew_L_rotation_0
		beq $s2, 1, Skew_L_rotation_1
		beq $s2, 2, Skew_L_rotation_2
		beq $s2, 3, Skew_L_rotation_3
		Skew_L_rotation_0:
			lw $t1, 0($t0)	
			subi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 0($t0)
			
			lw $t1, 8($t0)	
			addi $a0, $t1, 68
			la $t0, current_shape
			sw $a0, 8($t0)
			
			lw $t1, 12($t0)	
			subi $a0, $t1, 128
			la $t0, current_shape
			sw $a0, 12($t0)
			
			jr $ra

		Skew_L_rotation_1:
			lw $t1, 0($t0)	
			addi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 0($t0)
			
			lw $t1, 8($t0)	
			subi $a0, $t1, 68
			la $t0, current_shape
			sw $a0, 8($t0)
			
			lw $t1, 12($t0)	
			addi $a0, $t1, 128
			la $t0, current_shape
			sw $a0, 12($t0)
			
			jr $ra
		Skew_L_rotation_2:
			lw $t1, 0($t0)	
			subi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 0($t0)
			
			lw $t1, 8($t0)	
			addi $a0, $t1, 68
			la $t0, current_shape
			sw $a0, 8($t0)
			
			lw $t1, 12($t0)	
			subi $a0, $t1, 128
			la $t0, current_shape
			sw $a0, 12($t0)
			
			jr $ra
		Skew_L_rotation_3:
			lw $t1, 0($t0)	
			addi $a0, $t1, 60
			la $t0, current_shape
			sw $a0, 0($t0)
			
			lw $t1, 8($t0)	
			subi $a0, $t1, 68
			la $t0, current_shape
			sw $a0, 8($t0)
			
			lw $t1, 12($t0)	
			addi $a0, $t1, 128
			la $t0, current_shape
			sw $a0, 12($t0)
			
			jr $ra
		
		
	end_rotation:
		jr $ra	
wall_collision_check: # checks if the given value $a0 is out of bounds or not
	# 0 means no collision
	# 1 means collision with wall
	
	li $t9, 64
	div $a0, $t9
	mfhi $t9
	
	beq $t9, 0, wall_collision
	beq $t9, 60, wall_collision
	
	la $t9, blocks
	
	addi $a0, $a0, -320
	add $t9, $t9, $a0
	
	lw $t9, 0($t9)
	
	bne $t9, 0, collision
	
	li $v0, 0
	jr $ra
	
	wall_collision:
		li $v0, 1
		jr $ra

floor_collision_check: # checks if the shape has hit the floor or the top of another block
	# 0 means no collision
	# 1 means collision with floor/block
	
	bge $a0, 1984, collision
	
	la $t9, blocks
	
	addi $a0, $a0, -320
	add $t9, $t9, $a0
	
	lw $t9, 0($t9)
	
	bne $t9, 0, collision
	
	li $v0, 0
	jr $ra
	
	collision:
		li $v0, 1
		jr $ra


shape_reset:
	li $s0, 0
	
	li $t0, 0
	la $t1, blocks
	la $t3, current_shape
	lw $t4, 16($t3)
	
	lw $t5, 0($t3)
	addi $t5, $t5, -320
	add $t1, $t1, $t5
	sw $t4, 0($t1)
	sub $t1, $t1, $t5
	
	lw $t5, 4($t3)
	addi $t5, $t5, -320
	add $t1, $t1, $t5
	sw $t4, 0($t1)
	sub $t1, $t1, $t5
	
	lw $t5, 8($t3)
	addi $t5, $t5, -320
	add $t1, $t1, $t5
	sw $t4, 0($t1)
	sub $t1, $t1, $t5
	
	lw $t5, 12($t3)
	addi $t5, $t5, -320
	add $t1, $t1, $t5
	sw $t4, 0($t1)
	sub $t1, $t1, $t5
	
	la $a1, blocks
	li $a2, 0 # counts the rows that have been counted
	li $t2, 0  # loop for each row
	li $t3, 0 # 0 for do not delete the row and 1 for delete the row
	li $t4, 0 # tracks the location of the start of the row
	
	scroll_column:
		bge $a2, 26, scroll_column_end
		addi $a1, $a1, 4
		move $s7, $a1
		li $t3, 1
		li $t2, 0
		
		scroll_row:
			bge $t2, 14, scroll_row_end
			lw $t6, 0($a1)
			
			beq $t6, 0, dont_delete
			j dont_delete_end
			
			dont_delete:
				li $t3, 0
			dont_delete_end:
			
			addi $a1, $a1, 4
			addi $t2, $t2, 1
			j scroll_row
		scroll_row_end:
		
	
		addi $a1, $a1, 4
		addi $a2, $a2, 1
		
		beq $t3, 0, scroll_column
		
		addi $s4, $s4, 1
		
		li $s6, 0
		delete_row:
			li $v0, 32
			li $a0, 10
			syscall
			bge $s6, 14, delete_row_end
			li $t7, 0
			sw $t7, 0($s7)
			
			jal paint
			
			addi $s7, $s7, 4
			addi $s6, $s6, 1
			j delete_row
			
		delete_row_end:
		
		j scroll_column
	scroll_column_end:
	
	
	
	jal t_control
	
		
game_loop:
	li $s3, 64
	la $t0, current_shape
	
	lw $t1, 0($t0)
	add $a0, $s3, $t1
	jal floor_collision_check
	beq $v0, 1, shape_reset
	
	lw $t1, 4($t0)
	add  $a0, $s3, $t1
	jal floor_collision_check
	beq $v0, 1, shape_reset
	
	lw $t1, 8($t0)
	add $a0, $s3, $t1
	jal floor_collision_check
	beq $v0, 1, shape_reset
	
	lw $t1, 12($t0)
	add $a0, $s3, $t1
	jal floor_collision_check
	beq $v0, 1, shape_reset
	  
	jal paint
	jal t_control
	
	li $t9, 0
	delay_loop:
		addi $t9, $t9, 1
		li $s3, 0
		lw $t0, ADDR_KBRD              
    		lw $t8, 0($t0)                 
    		beq $t8, 1, keyboard_input
    		j keyboard_input_end
    		
    		keyboard_input:
    			lw $a0, 4($t0)                 
   			beq $a0, 0x71, quit  # q to quit 
			beq $a0, 0x61, move_left
			beq $a0, 0x64, move_right
			beq $a0, 0x73, move_down
			beq $a0, 0x77, move_up

			move_left:
				li $s3, -4
				la $t1, current_shape		
				
				j end_move_set
			move_right:
				li $s3, 4
				j end_move_set
			move_down:
				li $s3, 64 
				j end_move_down
			move_up:
				# rotatio						
				jal rotate_shape 
				j end_move_set
			end_move_down:
				li $t0, 0
				la $t1, current_shape
				la $t2, blocks
				lw $t3, 0($t1)
				lw $t4, 4($t1)
				lw $t5, 8($t1)
				lw $t6, 12($t1)
				addi $t3, $t3, -320
				addi $t4, $t4, -320
				addi $t5, $t5, -320
				addi $t6, $t6, -320
				
				
				lowest_point:			
					add $t3, $t3, $t0
					add $t2, $t2, $t3
					lw $t7, 0($t2)
					bne $t7, 0, lowest_point_end
					sub $t2, $t2, $t3
					sub $t3, $t3, $t0
					
					add $t4, $t4, $t0
					add $t2, $t2, $t4
					lw $t7, 0($t2)
					bne $t7, 0, lowest_point_end
					sub $t2, $t2, $t4
					sub $t4, $t4, $t0
					
					add $t5, $t5, $t0
					add $t2, $t2, $t5
					lw $t7, 0($t2)
					bne $t7, 0, lowest_point_end
					sub $t2, $t2, $t5
					sub $t5, $t5, $t0
					
					add $t6, $t6, $t0
					add $t2, $t2, $t6
					lw $t7, 0($t2)
					bne $t7, 0, lowest_point_end
					sub $t2, $t2, $t6
					sub $t6, $t6, $t0
					
					add $t3, $t3, $t0
					bge $t3, 1664, lowest_point_end
					sub $t3, $t3, $t0
					
					add $t4, $t4, $t0
					bge $t4, 1664, lowest_point_end
					sub $t4, $t4, $t0
					
					add $t5, $t5, $t0
					bge $t5, 1664, lowest_point_end
					sub $t5, $t5, $t0
					
					add $t6, $t6, $t0
					bge $t6, 1664, lowest_point_end
					sub $t6, $t6, $t0
					
					addi $t0, $t0, 64
					
					j lowest_point
				lowest_point_end:
				subi $t0, $t0, 64
				move $s3, $t0
				jal paint
				jal t_control
				jal shape_reset
				
				j keyboard_input_end
			end_move_set:
				la $t1, current_shape
	 			lw $t2, 0($t1)
				add $a0, $t2, $s3
				jal wall_collision_check
				beq $v0, 1, keyboard_input_end
				
				lw $t2, 4($t1)
				add $a0, $t2, $s3
				jal wall_collision_check
				beq $v0, 1, keyboard_input_end
				
				lw $t2, 8($t1)
				add $a0, $t2, $s3
				jal wall_collision_check
				beq $v0, 1, keyboard_input_end
				
				lw $t2, 12($t1)
				add $a0, $t2, $s3
				jal wall_collision_check
				beq $v0, 1, keyboard_input_end
				
			
				jal paint
				jal t_control

			
		keyboard_input_end:
	
	ble $s4, 2, speed_1
	ble $s4, 4, speed_2
	bgt $s4, 6, speed_3
	
	speed_1:
		li $t8,300000
		j speed_end
	speed_2:
		li $t8, 200000
		j speed_end
	speed_3:
		li $t8, 150000
		j speed_end
	speed_end:
		
	blt $t9, $t8, delay_loop # this allows for sleeping while processing keyboard controlls
    	
	b game_loop
    #5. Go back to 1


quit:
	li $a0, 10
	syscall

