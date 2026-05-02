; Work In Progress LAB4
$MODDE0CV

org 0000H
	ljmp checkKey3

T_7seg:
	DB 00H, 24H, 78H, 78H, 10H, 19H, 30H, 40H 	; [82779430] I don't know if I can have more than 5 per DB?
	DB 09H, 06H, 47H, 47H, 40H 					; [HELLO]

HalfDelay:
	 mov PSW, #00000000B
	 mov R2, #90
LF3: mov R1, #250
LF2: mov R0, #250
LF1: djnz R0, LF1 ; 3 machine cycles-> 3*30ns*250=22.5us
	djnz R1, LF2 ; 22.5us*250=5.625ms
	djnz R2, LF3 ; 5.625ms*90=0.50625s (approximately)
	ret

FullDelay:
	mov PSW, #00000000B
	mov R2, #180
L3: mov R1, #250
L2: mov R0, #250
L1: djnz R0, L1 ; 3 machine cycles-> 3*30ns*250=22.5us
	djnz R1, L2 ; 22.5us*250=5.625ms
	djnz R2, L3 ; 5.625ms*180=1.0125s (approximately)
	ret
	
checkKey3:
	jnb Key.3, checkSWA
	mov LEDRA,#0
	mov LEDRB,#0
	ret
	
checkSWA:
	mov a, SWA 
	anl a, #00001111B	; Ignore SW[4-9]
	ljmp check000

check000:
	cjne a,#00000000B, check001
	ljmp case000

check001:
	cjne a,#00000001B, check010
	ljmp case001

check010:
	cjne a,#00000010B, check011
	ljmp case010

check011:
	cjne a,#00000011B, check100
	ljmp case011

check100:
	cjne a,#00000100B, check101
	ljmp case100

check101:
	cjne a,#00000101B, check110
	ljmp case101

check110:
	cjne a,#00000110B, check111
	ljmp case110

check111:
	cjne a,#00000111B, check000f
	ljmp case111

check000f:
	cjne a,#00001000B, check001f
	ljmp case000f 

check001f:
	cjne a,#00001001B, check010f
	ljmp case001f 

check010f:
	cjne a,#00001010B, check011f
	ljmp case010f 

check011f:
	cjne a,#00001011B, check100f
	ljmp case011f 

check100f:
	cjne a,#00001100B, check101f
	ljmp case100f 

check101f:
	cjne a,#00001101B, check110f
	ljmp case101f 

check110f:
	cjne a,#00001110B, check111f
	ljmp case110f 

check111f:
	cjne a,#00001111B, check000
	ljmp case111f

case000:
	mov HEX5,#00H
	mov HEX4,#24H
	mov HEX3,#78H
	mov HEX2,#78H
	mov HEX1,#10H
	mov HEX0,#19H
	lcall checkKey3
	ljmp case000

case001:
	mov HEX5,#7FH
	mov HEX4,#7FH
	mov HEX3,#7FH
	mov HEX2,#7FH
	mov HEX1,#30H
	mov HEX0,#40H
	lcall checkKey3
	ljmp case001

case010:
	mov PSW, #00010000B

	mov R7,#00H
	mov R6,#24H
	mov R5,#78H
	mov R4,#78H
	mov R3,#10H
	mov R2,#19H
	mov R1,#30H
	mov R0,#40H

	mov HEX5,R7
	mov HEX4,R6
	mov HEX3,R5
	mov HEX2,R4
	mov HEX1,R3
	mov HEX0,R2
	ljmp case010loop

case010loop:
	lcall FullDelay

	mov PSW, #00010000B
	mov a, R7
	mov PSW, #00011000B
	mov R0,a
	mov PSW, #00010000B
	mov a, R6
	mov R7,a
	mov a, R5
	mov R6,a
	mov a, R4
	mov R5,a
	mov a, R3
	mov R4,a
	mov a, R2
	mov R3,a
	mov a, R1
	mov R2,a
	mov a, R0
	mov R1,a
	mov PSW, #00011000B
	mov a, R0
	mov PSW, #00010000B
	mov R0, a
	
	mov HEX5,R7
	mov HEX4,R6
	mov HEX3,R5
	mov HEX2,R4
	mov HEX1,R3
	mov HEX0,R2

	lcall checkKey3
	jnb Key.2, revLoop 
	ljmp case010loop
	
; revLoop not implemented for halfSecond speed	
revLoop:
	lcall FullDelay

	mov PSW, #00010000B
	mov a, R0
	mov PSW, #00011000B
	mov R0,a
	mov PSW, #00010000B
	mov a, R1
	mov R0,a
	mov a, R2
	mov R1,a
	mov a, R3
	mov R2,a
	mov a, R4
	mov R3,a
	mov a, R5
	mov R4,a
	mov a, R6
	mov R5,a
	mov a, R7
	mov R6,a
	mov PSW, #00011000B
	mov a, R0
	mov PSW, #00010000B
	mov R7, a
	
	mov HEX5,R7
	mov HEX4,R6
	mov HEX3,R5
	mov HEX2,R4
	mov HEX1,R3
	mov HEX0,R2
	
	lcall checkKey3
	jnb Key.2, revLoop 
	ljmp case010loop

case011:
	mov PSW, #00010000B
	mov R7,#00H
	mov R6,#24H
	mov R5,#78H
	mov R4,#78H
	mov R3,#10H
	mov R2,#19H
	mov R1,#30H
	mov R0,#40H

	mov HEX5,R7
	mov HEX4,R6
	mov HEX3,R5
	mov HEX2,R4
	mov HEX1,R3
	mov HEX0,R2
	ljmp case011loop

case011loop:
	lcall FullDelay

	mov PSW, #00010000B
	mov a, R0
	mov PSW, #00011000B
	mov R7,a
	mov PSW, #00010000B
	mov a, R1
	mov R0,a
	mov a, R2
	mov R1,a
	mov a, R3
	mov R2,a
	mov a, R4
	mov R3,a
	mov a, R5
	mov R4,a
	mov a, R6
	mov R5,a
	mov a, R7
	mov R6,a
	mov PSW, #00011000B
	mov a, R7
	mov PSW, #00010000B
	mov R7, a

	mov HEX5,R7	
	mov HEX4,R6
	mov HEX3,R5
	mov HEX2,R4
	mov HEX1,R3
	mov HEX0,R2

	lcall checkKey3
	ljmp case011loop

case100:
	mov R7,#00H
	mov R6,#24H
	mov R5,#78H
	mov R4,#78H
	mov R3,#10H
	mov R2,#19H

	mov HEX5,R7
	mov HEX4,R6
	mov HEX3,R5
	mov HEX2,R4
	mov HEX1,R3
	mov HEX0,R2
	ljmp case100loop

case100loop:
	lcall FullDelay

	mov HEX5,#7FH
	mov HEX4,#7FH
	mov HEX3,#7FH
	mov HEX2,#7FH
	mov HEX1,#7FH
	mov HEX0,#7FH

	lcall FullDelay

	lcall checkKey3
	ljmp case100

case101:
	mov R7,#00H
	mov R6,#24H
	mov R5,#78H
	mov R4,#78H
	mov R3,#10H

	mov HEX5,R7
	lcall FullDelay
	mov HEX4,R6
	lcall FullDelay
	mov HEX3,R5
	lcall FullDelay
	mov HEX2,R4
	lcall FullDelay
	mov HEX1,R3
	lcall FullDelay
	mov HEX0,#19H
	lcall FullDelay
	mov HEX5,#7FH
	mov HEX4,#7FH
	mov HEX3,#7FH
	mov HEX2,#7FH
	mov HEX1,#7FH
	mov HEX0,#7FH
	lcall FullDelay

	lcall checkKey3
	ljmp case101

case110:
	; HELLO
	mov HEX5,#7FH
	mov HEX4,#09H
	mov HEX3,#06H
	mov HEX2,#47H
	mov HEX1,#47H
	mov HEX0,#40H

	lcall FullDelay

	; 827794
	mov HEX5,#00H
	mov HEX4,#24H
	mov HEX3,#78H
	mov HEX2,#78H
	mov HEX1,#10H
	mov HEX0,#19H

	lcall FullDelay

	; CPN312
	mov HEX5,#46H
	mov HEX4,#0CH
	mov HEX3,#48H
	mov HEX2,#30H
	mov HEX1,#79H
	mov HEX0,#24H

	lcall FullDelay

	lcall checkKey3
	ljmp case110

case111:
	; Idea: Numbers move left if KEY2 = 0, right if = 1
	mov HEX5,#00H
	mov HEX4,#24H
	mov HEX3,#78H
	mov HEX2,#78H
	mov HEX1,#10H
	mov HEX0,#19H

	lcall FullDelay

	mov HEX5,#7FH
	mov HEX4,#7FH
	mov HEX3,#7FH
	mov HEX2,#7FH
	mov HEX1,#30H
	mov HEX0,#40H

	lcall FullDelay

	lcall checkKey3
	ljmp case111

case000f:
	mov HEX5,#00H
	mov HEX4,#24H
	mov HEX3,#78H
	mov HEX2,#78H
	mov HEX1,#10H
	mov HEX0,#19H
	lcall checkKey3
	ljmp case000f

case001f:
	mov HEX5,#7FH
	mov HEX4,#7FH
	mov HEX3,#7FH
	mov HEX2,#7FH
	mov HEX1,#30H
	mov HEX0,#40H
	lcall checkKey3
	ljmp case001f

case010f:
	mov PSW, #00010000B

	mov R7,#00H
	mov R6,#24H
	mov R5,#78H
	mov R4,#78H
	mov R3,#10H
	mov R2,#19H
	mov R1,#30H
	mov R0,#40H

	mov HEX5,R7
	mov HEX4,R6
	mov HEX3,R5
	mov HEX2,R4
	mov HEX1,R3
	mov HEX0,R2
	ljmp case010floop

case010floop:
	lcall HalfDelay

	mov PSW, #00010000B
	mov a, R7
	mov PSW, #00011000B
	mov R0,a
	mov PSW, #00010000B
	mov a, R6
	mov R7,a
	mov a, R5
	mov R6,a
	mov a, R4
	mov R5,a
	mov a, R3
	mov R4,a
	mov a, R2
	mov R3,a
	mov a, R1
	mov R2,a
	mov a, R0
	mov R1,a
	mov PSW, #00011000B
	mov a, R0
	mov PSW, #00010000B
	mov R0, a

	mov HEX5,R7
	mov HEX4,R6
	mov HEX3,R5
	mov HEX2,R4
	mov HEX1,R3
	mov HEX0,R2

	lcall checkKey3
	ljmp case010floop

case011f:
	mov PSW, #00010000B
	mov R7,#00H
	mov R6,#24H
	mov R5,#78H
	mov R4,#78H
	mov R3,#10H
	mov R2,#19H
	mov R1,#30H
	mov R0,#40H

	mov HEX5,R7
	mov HEX4,R6
	mov HEX3,R5
	mov HEX2,R4
	mov HEX1,R3
	mov HEX0,R2
	ljmp case011floop

case011floop:
	lcall HalfDelay

	mov PSW, #00010000B
	mov a, R0
	mov PSW, #00011000B
	mov R7,a
	mov PSW, #00010000B
	mov a, R1
	mov R0,a
	mov a, R2
	mov R1,a
	mov a, R3
	mov R2,a
	mov a, R4
	mov R3,a
	mov a, R5
	mov R4,a
	mov a, R6
	mov R5,a
	mov a, R7
	mov R6,a
	mov PSW, #00011000B
	mov a, R7
	mov PSW, #00010000B
	mov R7, a

	mov HEX5,R7
	mov HEX4,R6
	mov HEX3,R5
	mov HEX2,R4
	mov HEX1,R3
	mov HEX0,R2

	lcall checkKey3
	ljmp case011floop

case100f:
	mov R7,#00H
	mov R6,#24H
	mov R5,#78H
	mov R4,#78H
	mov R3,#10H
	mov R2,#19H

	mov HEX5,R7
	mov HEX4,R6
	mov HEX3,R5
	mov HEX2,R4
	mov HEX1,R3
	mov HEX0,R2
	ljmp case100floop

case100floop:
	lcall HalfDelay

	mov HEX5,#7FH
	mov HEX4,#7FH
	mov HEX3,#7FH
	mov HEX2,#7FH
	mov HEX1,#7FH
	mov HEX0,#7FH

	lcall HalfDelay

	lcall checkKey3
	ljmp case100f

case101f:
	mov R7,#00H
	mov R6,#24H
	mov R5,#78H
	mov R4,#78H
	mov R3,#10H

	mov HEX5,R7
	lcall HalfDelay
	mov HEX4,R6
	lcall HalfDelay
	mov HEX3,R5
	lcall HalfDelay
	mov HEX2,R4
	lcall HalfDelay
	mov HEX1,R3
	lcall HalfDelay
	mov HEX0,#19H
	lcall HalfDelay
	mov HEX5,#7FH
	mov HEX4,#7FH
	mov HEX3,#7FH
	mov HEX2,#7FH
	mov HEX1,#7FH
	mov HEX0,#7FH
	lcall HalfDelay

	lcall checkKey3
	ljmp case101f

case110f:
	; HELLO
	mov HEX5,#7FH
	mov HEX4,#09H
	mov HEX3,#06H
	mov HEX2,#47H
	mov HEX1,#47H
	mov HEX0,#40H

	lcall HalfDelay

	; 827794
	mov HEX5,#00H
	mov HEX4,#24H
	mov HEX3,#78H
	mov HEX2,#78H
	mov HEX1,#10H
	mov HEX0,#19H

	lcall HalfDelay

	; CPN312
	mov HEX5,#46H
	mov HEX4,#0CH
	mov HEX3,#48H
	mov HEX2,#30H
	mov HEX1,#79H
	mov HEX0,#24H

	lcall HalfDelay

	lcall checkKey3
	ljmp case110f

case111f:
	mov HEX5,#00H
	mov HEX4,#24H
	mov HEX3,#78H
	mov HEX2,#78H
	mov HEX1,#10H
	mov HEX0,#19H

	lcall HalfDelay

	mov HEX5,#7FH
	mov HEX4,#7FH
	mov HEX3,#7FH
	mov HEX2,#7FH
	mov HEX1,#30H
	mov HEX0,#40H

	lcall HalfDelay

	lcall checkKey3
	ljmp case111f

END
