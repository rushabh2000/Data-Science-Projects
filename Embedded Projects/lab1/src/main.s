.cpu cortex-m0
.thumb
.syntax unified
.fpu softvfp

.global login
login: .asciz "ranka0"

.align 2
.global main
main:
    bl   autotest // Uncomment this ONLY when you're done.
    movs r0, #1
    movs r1, #2
    movs r2, #4
    movs r3, #8
    bl   example // invoke the example subroutine
    nop

    movs r0, #35
    movs r1, #18
    movs r2, #23
    movs r3, #12
    bl   step31 // invoke Step 3.1
    nop

    movs r0, #10
    movs r1, #3
    movs r2, #18
    movs r3, #42
    bl   step32 // invoke Step 3.2
    nop

    movs r0, #24
    movs r1, #35
    movs r2, #52
    movs r3, #85
    bl   step33 // invoke Step 3.3
    nop

    movs r0, #29
    movs r1, #42
    movs r2, #93
    movs r3, #184
    bl   step41 // invoke Step 4.1
    nop

    movs r0, #0xaa
    bl   step42 // invoke Step 4.2
    nop

    movs r0, #0 // unused as an input operand
    movs r1, #16
    movs r2, #2
    movs r3, #3
    bl   step51 // invoke Step 5.1
    nop

    movs r0, #5
    bl   step52 // invoke Step 5.2
    nop


    bl   setup_portc
loop:
    bl   toggle_leds
    ldr  r0, =500000000
wait:
    subs r0,#83
    bgt  wait
    b    loop

// The main function never returns.
// It ends with the endless loop, above.

// Subroutine for example in Step 3.0
.global example
example:
		adds r0, r1 // now, r0 = r0 + r1
        adds r0, r2 // now, r0 = r0 + r1 + r2
        adds r0, r3 // finally, r0 = r0 + r1 + r2 + r3
        bx lr// Enter your code here


// Subroutine for Step 3.1
.global step31
step31:
		adds r1, r2// Enter your code here
		subs r0, r3
		muls r1, r0
		movs r0, r1
    	bx   lr

// Subroutine for Step 3.2
.global step32
step32:
		subs r3 , r1// Enter your code here
		subs r3, r0
		movs r0, r3
		muls r0, r2

    	bx   lr

// Subroutine for Step 3.3
.global step33
step33:
    	subs r1, r0
    	subs r2 , r1
    	subs r3, r2
    	movs r0, r3// Enter your code here

    	bx   lr

// Subroutine for Step 4.1
.global step41
step41:
    	ORRS r1, r0// Enter your code here
    	ANDS r2,r0
    	ORRS r2, r3
    	EORS r1, r2
    	movs r0, r1

    	bx   lr

// Subroutine for Step 4.2
.global step42
step42:
    	movs r3, #0x10// Enter your code here
    	movs r1, #0xf0
    	ANDS r0, r1
    	ORRS r0, r3

   		bx   lr

// Subroutine for Step 5.1
.global step51
step51:
    	LSLS r3, r1// Enter your code here
    	LSRS r3, r2
    	movs r0, r3

    	bx   lr

// Subroutine for Step 5.2
.global step52
step52:
		movs r2,0x1
    	BICS r0, r2// Enter your code here
    	LSLS r0,#3
    	movs r1, #5
    	ORRS r0, r1

    	bx   lr

// Step 6: Type in the .equ constant initializations below
		.equ RCC,		0x40021000
		.equ AHBENR,	0x14
		.equ GPIOCEN,	0x00080000
		.equ GPIOC,		0x48000800
		.equ MODER,		0x00
		.equ ODR,		0x14
		.equ ENABLE6_TO_9,	0x55000
		.equ PINS6_TO_9,	0x3c0
.global setup_portc
setup_portc:
    		ldr r0, =RCC// Type in the code here.
    		ldr r1, [r0,#AHBENR]
    		ldr r2, =GPIOCEN
    		orrs r1,r2
    		str r1, [r0, #AHBENR]

    		ldr r0, =GPIOC
    		ldr r1, [r0,#MODER]
    		ldr r2, =ENABLE6_TO_9
    		orrs r1,r2
    		str r1, [r0,#MODER]

    		bx   lr

.global toggle_leds
toggle_leds:
    		ldr r0, =GPIOC// Type in the code here.
    		ldr r1, [r0,#ODR]
    		ldr r2, =PINS6_TO_9
    		eors r1, r2
    		str r1, [r0,#ODR]
    		bx   lr
