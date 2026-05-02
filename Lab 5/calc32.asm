$MODDE0CV

	CSEG at 0
	ljmp main_code

	dseg at 30h
	x: ds 4 	; 32-bits for variable ‘x’
	y: ds 4 	; 32-bits for variable ‘y’
	w1: ds 4	; 32-bits for variable 'w1'. Used for storing "guess" in sqrtX and 'y' in squareX
	s0: ds 4	; Used for storing 's0' in sqrtX
	bcd: ds 5 ; 10-digit packed BCD (each byte stores 2 digits)

	bseg
	mf: dbit 1 			; Math functions flag
	negFlag: dbit 1		; to turn on LEDRA.0 if negative. UNUSED because haven't implemented add/mul/div of neg #'s
	equPressed: dbit 1	; If '=' pressed, then we are displaying a result. Next # input should clear display.

	$include(math32.asm)
	$include(readKeypad.asm)
	$include(math32PLUS.asm)

	CSEG
	
	; clears everything?
	main_code:
		mov SP, #7FH
		clr a
		mov LEDRA, a
		mov LEDRB, a
		mov bcd+0, a
		mov bcd+1, a
		mov bcd+2, a
		mov bcd+3, a
		mov bcd+4, a
		clr negFlag
		clr equPressed
		lcall Configure_Keypad_Pins
		Load_X(0)
		Load_Y(0)

	forever:
		lcall Keypad
		lcall Display
		jnc forever
		; lcall Shift_Digits_Left 	(made digits entered appear twice)
		; ljmp forever				(never made it to Is_Operation)
		; Keypad inputs are stored in R7. If 9-R7 > 0, then carryFlag = 1 and R7 = [A-F] is an operation.
		mov a, #9
		clr c
		subb a, R7
		jc Is_Operation
		jb equPressed, clearForNewInput
		lcall Shift_Digits_Left 
		ljmp forever
		
	clearForNewInput:
		clr negFlag
		clr equPressed
		clr LEDRA.0
		Load_X(0)
		lcall Display
		mov bcd+0, r7
		mov bcd+1, #0
		mov bcd+2, #0
		mov bcd+3, #0
		mov bcd+4, #0
		; lcall hex2bcd, for some reason this caused it to display 000000 on first # press.
		lcall Display
		ljmp forever
		
	Is_Operation:
		checkAdd:
			cjne R7, #0AH, checkSub
			mov b, #0 			; 0:add, 1:sub, 2:tri, 3:div, 4:mul, 5:equ
			ljmp storeXandZeroDisplay
		checkSub:
			cjne R7, #0BH, checkMul
			mov b, #1 			; 0:add, 1:sub, 2:tri, 3:div, 4:mul, 5:equ
			ljmp storeXandZeroDisplay
			ljmp forever 		; Go check for more input
		checkMul:
			cjne R7, #0EH, checkDiv
			mov b, #4 			; 0:add, 1:sub, 2:tri, 3:div, 4:mul, 5:equ
			ljmp storeXandZeroDisplay
			ljmp forever 		; Go check for more input
		checkDiv:
			cjne R7, #0DH, checkTri
			mov b, #3 			; 0:add, 1:sub, 2:tri, 3:div, 4:mul, 5:equ
			ljmp storeXandZeroDisplay
			ljmp forever 		; Go check for more input
		checkTri:
			cjne R7, #0CH, checkEqu
			mov b, #2 			; 0:add, 1:sub, 2:tri, 3:div, 4:mul, 5:equ
			ljmp storeXandZeroDisplay
			ljmp forever 		; Go check for more input
		checkEqu:
			cjne R7, #0FH, noMoreOps
			mov a, b
			lcall bcd2hex 		; Convert input in BCD to hex in x
			jb mf, inputTooBig	; Error if input for X larger than 32-bits
			setb equPressed
			ljmp doAdd
		
	storeXandZeroDisplay:
		lcall bcd2hex 		; Convert input in BCD to hex in x
		jb mf, inputTooBig	; Error if input for X larger than 32-bits
		lcall copy_xy 		; Copy X to Y
		Load_X(0) 			; Clear x (this is a macro)
		lcall hex2bcd 		; Convert result in x to BCD
		lcall Display 		; Display the new BCD number: ‘0000000000’
		ljmp forever 		; Go check for more input
	inputTooBig:
		ljmp error	
	noMoreOps:
		ljmp forever	
			
	doAdd:
		cjne a, #0, doSub
		lcall add32		; X + Y, where X is value entered before '=' pressed. Y is value entered before 'op' pressed
		lcall hex2bcd 	; Convert result in x to BCD
		jb mf, error	; Error if result is larger than 32-bits
		lcall Display 	; Display the new BCD number
		ljmp forever 	; Go check for more input
	doSub:
		cjne a, #1, doMul
		lcall xchg_xy	; If not, you're actually doing Y-X 
		lcall x_lt_y	; If x < y, mf=1
		jb mf, neg32	
		lcall sub32		; X - Y, where X is value entered before '=' pressed. Y is value entered before 'op' pressed
		lcall hex2bcd 	; Convert result in x to BCD
		; jb mf, error	; Error if result is larger than 32-bits. CORR: subtraction of 2 valid #'s should be still valid
		lcall Display 	; Display the new BCD number
		ljmp forever 	; Go check for more input
		; neg32 if X-Y < 0
		neg32:
		lcall xchg_xy	; Revert to Y-X
		lcall sub32
		lcall hex2bcd 	; Convert result in x to BCD
		setb negFlag	; negative number flag
		setb LEDRA.0	; CONSIDER PUTTING THIS IN A BETTER PLACE
		lcall Display 	; Display the new BCD number
		ljmp forever 	; Go check for more input	
	doMul:
		cjne a, #4, doDiv
		lcall bcd2hex 	; Convert input in BCD to hex in x
		lcall mul32		; Y*X
		lcall hex2bcd 	; Convert result in x to BCD
		jb mf, error	; Error if result is larger than 32-bits
		lcall Display 	; Display the new BCD number
		ljmp forever 	; Go check for more input
	doDiv:
		cjne a, #3, doTri
		lcall bcd2hex 	; Convert input in BCD to hex in x
		lcall xchg_xy	; If not, you're actually doing Y/X
		lcall div32		; 
		lcall hex2bcd 	; Convert result in x to BCD
		jb mf, error	; Error if division by 0
		lcall Display 	; Display the new BCD number
		ljmp forever 	; Go check for more input
	doTri:
		cjne a, #2, noMoreOps
		lcall bcd2hex 	; Convert input in BCD to hex in x
		lcall tri32	
		lcall hex2bcd 	; Convert result in x to BCD
		jb mf, error	; Error if result is larger than 32-bits
		lcall Display 	; Display the new BCD number
		clr c
		ljmp forever 	; Go check for more input
		
	error:
		mov HEX5, #00000110B 
		mov HEX4, #00101111B 
		mov HEX3, #00101111B 
		mov HEX2, #00100011B 
		mov HEX1, #00101111B
		mov HEX0, #11111111B
		clr a
		mov LEDRA, a
		ljmp error
		
end
