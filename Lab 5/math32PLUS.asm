$NOLIST

CSEG

;----------------------------------------------------
; x^2
;---------------------------------------------------
squareX:
	push acc
	push psw
	
	mov w1+0, y+0
	mov w1+1, y+1
	mov w1+2, y+2
	mov w1+3, y+3
	
	lcall copy_xy
	lcall mul32
	
	mov y+0, w1+0
	mov y+1, w1+1
	mov y+2, w1+2
	mov y+3, w1+3
	
	pop psw
	pop acc
	ret
	
;----------------------------------------------------
; sqrt(x)
;---------------------------------------------------	
sqrtX:
	push acc
	push psw
	
	mov a, x+0
    orl a, x+1
    orl a, x+2
    orl a, x+3
    jnz startSqrt
    ret
    
    startSqrt:
		mov s0+0, x+0
		mov s0+1, x+1
		mov s0+2, x+2
		mov s0+3, x+3
		mov w1+0, x+0
		mov w1+1, x+1
		mov w1+2, x+2
		mov w1+3, x+3
		
	loop:
		; x=s0, y=guess
		mov x+0, s0+0
		mov x+1, s0+1
		mov x+2, s0+2
		mov x+3, s0+3
		mov y+0, w1+0
		mov y+1, w1+1
		mov y+2, w1+2
		mov y+3, w1+3
		
		lcall div32		; s0/guess
		lcall add32		; s0/guess + guess
		
		; (s0/guess + guess)/2
		clr c
	    mov a, x+3
	    rrc a
	    mov x+3, a
	    mov a, x+2
	    rrc a
	    mov x+2, a
	    mov a, x+1
	    rrc a
	    mov x+1, a
	    mov a, x+0
	    rrc a
	    mov x+0, a 	
	    
	    ; if (s0/guess + guess)/2 = g_n+1 == g_n, then done!
	    lcall x_eq_y
	    jb mf, done
	    ; otherwise, w1=g_n+1
	    mov w1+0, x+0
		mov w1+1, x+1
		mov w1+2, x+2
		mov w1+3, x+3
		sjmp loop
	    
	done:
		clr mf
		mov x+0, w1+0
		mov x+1, w1+1
		mov x+2, w1+2
		mov x+3, w1+3
	
	pop psw
	pop acc
	ret
	
;----------------------------------------------------
; tri32
;---------------------------------------------------
tri32:
	; do I need to clear the carryFlag here?
	lcall squareX
	lcall xchg_xy
	lcall squareX			; At this point, X = Y^2, Y = X^2 I think...
	jb SWA.1, X2minusY2
	ljmp X2plusY2
	
	X2plusY2:
		lcall add32
		lcall sqrtX
		ret
	X2minusY2:
		; lcall xchg_xy	; If not, you're actually doing Y-X CORR: Turns out its already in X^2-Y2 form
		lcall sub32
		jb mf, negative
		lcall sqrtX
		ret
	negative:
		lcall error
		ret
		
$LIST