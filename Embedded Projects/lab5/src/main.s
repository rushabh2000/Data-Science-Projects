.cpu cortex-m0
.thumb
.syntax unified
.fpu softvfp

//===================================================================
// ECE 362 Lab Experiment 5
// Timers
//===================================================================

// RCC configuration registers
.equ  RCC,      0x40021000
.equ  AHBENR,   0x14
.equ  GPIOCEN,  0x00080000
.equ  GPIOBEN,  0x00040000
.equ  GPIOAEN,  0x00020000
.equ  APB1ENR,  0x1c
.equ  TIM6EN,   1<<4
.equ  TIM7EN,   1<<5


// NVIC configuration registers
.equ NVIC, 0xe000e000
.equ ISER, 0x100
.equ ICER, 0x180
.equ ISPR, 0x200
.equ ICPR, 0x280
.equ IPR,  0x400
.equ TIM6_DAC_IRQn, 17
.equ TIM7_IRQn, 18

// Timer configuration registers
.equ TIM6, 0x40001000
.equ TIM7, 0x40001400
.equ TIM_CR1,  0x0
.equ TIM_CR2,  0x4
.equ TIM_DIER, 0xc
.equ TIM_SR,   0x10
.equ TIM_EGR,  0x14
.equ TIM_CNT,  0x24
.equ TIM_PSC,  0x28
.equ TIM_ARR,  0x2c

// Timer configuration register bits
.equ TIM_CR1_CEN,  1<<0
.equ TIM_DIER_UDE, 1<<8
.equ TIM_DIER_UIE, 1<<0
.equ TIM_SR_UIF,   1<<0

// GPIO configuration registers
.equ  GPIOC,    0x48000800
.equ  GPIOB,    0x48000400
.equ  GPIOA,    0x48000000
.equ  MODER,    0x00
.equ  PUPDR,    0x0c
.equ  IDR,      0x10
.equ  ODR,      0x14
.equ  BSRR,     0x18
.equ  BRR,      0x28

//===========================================================================
// enable_ports  (Autotest 1)
// Enable the RCC clock for GPIO ports B and C.
// Parameters: none
// Return value: none
.global enable_ports
enable_ports:
	push {lr}
	// Student code goes below

		ldr r0, = RCC
		ldr r1,[r0,#AHBENR]
		ldr r2,=GPIOCEN   // enable c
		orrs r1,r2
		str r1,[r0,#AHBENR]


		ldr r1,[r0,#AHBENR]
		ldr r2,=GPIOBEN // enable b
		orrs r1,r2
		str r1,[r0,#AHBENR]

port_c_output:

    .equ OUT0_6,0x00155555
    // Student code goes here
	ldr r0, =GPIOC // Load, into RO, base address of GPIOC
	ldr r1, [r0, #MODER] // Load, into R1, value of GPIOC offset by MODER
	ldr r2,=#0x3fffff
    bics r1,r2
	ldr r2, =OUT0_6 // Load, into R2, value to enable PC0 ? PC12
	orrs r1, r2 // Combine R2 into R1
	str r1, [r0, #MODER] // Store new bits into GPIOC_MODER

port_b_output:

    .equ OUT0_3,0x00000055
    // Student code goes here
	ldr r0, =GPIOB // Load, into RO, base address of GPIOC
	ldr r1, [r0, #MODER]
	ldr r2,=#0xff
    bics r1,r2
	ldr r2, =OUT0_3
	orrs r1, r2
	str r1, [r0, #MODER]

port_b_input:


    .equ CLR4_7,0x0000ff00 // Value to clear from MODER
	ldr r0, =GPIOB // Load, into RO, base address of GPIOA
	ldr r1, [r0, #MODER] // Load, into R1, value of GPIOA offset by MODER
	ldr r2, = CLR4_7 // Load, into R2, value to clear
	bics r1, r2 // Clear the bits in R1 that are set in R2
	str r1, [r0, #MODER]

	.equ pupdr_2,0x0000aa00
	ldr r0, =GPIOB
	ldr r3,[r0,#PUPDR]
	ldr r2,=#0xff00
    bics r3,r2
    ldr r2, =pupdr_2
    ORRS r2,r3
    str r2,[r0,#PUPDR]


	pop  {pc}

//===========================================================================
// Timer 6 Interrupt Service Routine  (Autotest 2)
// Parameters: none
// Return value: none
// Write the entire subroutine below
.global TIM6_DAC_IRQHandler
.type TIM6_DAC_IRQHandler, %function
TIM6_DAC_IRQHandler:
	push {lr}
	ldr r0,=TIM6
	ldr r1,[r0,#TIM_SR] // read status reg
	ldr r2,=TIM_SR_UIF
	bics r1,r2 // turn off UIF
	str r1,[r0,#TIM_SR] // write it

	movs r0,#6
	ldr r1, =GPIOC
	ldr r2,[r1,#ODR]
    movs r3,#1
    lsls r3,r0
    eors r2,r3
    str r2,[r1,#ODR]

	pop {pc}
//===========================================================================
// setup_tim6  (Autotest 3)
// Configure timer 6
// Parameters: none
// Return value: none
.global setup_tim6
setup_tim6:
	push {lr}
	// Student code goes below
	ldr r0,=RCC
	ldr r1,[R0,#APB1ENR]
	ldr r2,=TIM6EN
	orrs r1,r2
	str r1,[r0,#APB1ENR]

	ldr r0,=TIM6
	ldr r1,=48000-1
	str r1,[r0,#TIM_PSC]

	ldr r1,=500-1
	str r1,[r0,#TIM_ARR]

	ldr r0,=TIM6
	ldr r1,[r0,#TIM_DIER]
	ldr r2,=TIM_DIER_UIE
	orrs r1,r2
	str r1,[r0,#TIM_DIER]

	ldr r0,=TIM6
	ldr r1,[r0,#TIM_CR1]
	ldr r2,=TIM_CR1_CEN
	orrs r1,r2
	str r1,[r0,#TIM_CR1]

	ldr r0,=NVIC
	ldr r1,= ISER
	ldr r2,=(1<<TIM6_DAC_IRQn)
	str r2,[r0,r1]
	// Student code goes above
	pop  {pc}

.data
.global display
display: .byte 0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07
.global history
history: .space 16
.global offset
offset: .byte 0
.text

//===========================================================================
// show_digit  (Autotest 4)
// Set up the Port C outputs to show the digit for the current
// value of the offset variable.
// Parameters: none
// Return value: none
.global show_digit
show_digit:
			push {lr}
			ldr r0,= offset
			ldrb r1,[r0]
			ldr r3, =display
			movs r2,#7
			ands r1,r2
			ldrb r2,[r3,r1]
			lsls r1,#8
			orrs r2,r1
			ldr r1, =GPIOC
			str r2,[r1,#ODR]
			pop {pc}

// Write the entire subroutine below.


//===========================================================================
// get_cols  (Autotest 5)
// Return the current value of the PC8 - PC4.
// Parameters: none
// Return value: 4-bit result of columns active for the selected row
// Write the entire subroutine below.
.global get_cols
get_cols:
		push {lr}
		ldr r1,=#0xf
		ldr r0,=GPIOB
		ldr r2,[r0,#IDR]
		lsrs r2,#4
		ands r2,r1
		movs r0,r2
		pop {pc}


//===========================================================================
// update_hist  (Autotest 6)
// Update the history byte entries for the current row.
// Parameters: r0: cols: 4-bit value read from matrix columns
// Return value: none
// Write the entire subroutine below.
.global update_hist
update_hist:
			push {r4-r7,lr}
			ldr r7,=history
			movs r2,#3
			ldr r1,=offset
			ldrb r1,[r1]
			ands r1,r2 // rows
			movs r2,#0 // i counter
		initialize:
					cmp r2,#4
					bge done_hist
					movs r3,#4
					movs r4,r1
					muls r4,r3 // r4 has the muls4 + i
					adds r4,r2 // addig to r4 i
					ldrb r5,[r7,r4]
					lsls r5,#1

					movs r6,r0
					lsrs r6,r2
					movs r3,#1
					ands r6,r3
					adds r6,r5
					strb r6,[r7,r4]
					adds r2,#1
					b initialize

		done_hist:
					pop {r4-r7,pc}


//===========================================================================
// set_row  (Autotest 7)
// Set PB3 - PB0 to represent the row being scanned.
// Parameters: none
// Return value: none
// Write the entire subroutine below.
.global set_row
set_row:
		push {lr}
		ldr r1, = offset
		ldrb r1,[r1]
		movs r2,#3
		ands r2,r1 // contains row
		ldr r0,=GPIOB
		ldr r1,=#0xf0000
		movs r3,#1
		lsls r3,r2
		orrs r3,r1
		str r3,[r0,#BSRR]
		pop {pc}
//===========================================================================
// Timer 7 Interrupt Service Routine  (Autotest 8)
// Parameters: none
// Return value: none
// Write the entire subroutine below
.global TIM7_IRQHandler
.type TIM7_IRQHandler, %function
TIM7_IRQHandler:
				push {lr}
				ldr r0,=TIM7
				ldr r1,[r0,#TIM_SR] // read status reg
				ldr r2,=TIM_SR_UIF
				bics r1,r2 // turn off UIF
				str r1,[r0,#TIM_SR] // write it


				bl show_digit
        		bl get_cols
                bl update_hist
                ldr r1,=offset
                ldrb r3,[r1]
                adds r3,#1
                ldr r2,=#0x7
                ands r3,r2
                strb r3,[r1]
                bl set_row
      			pop {pc}



//===========================================================================
// setup_tim7  (Autotest 9)
// Configure Timer 7.
// Parameters: none
// Return value: none
.global setup_tim7
setup_tim7:
	push {lr}
	// Student code goes below

	// Student code goes below
	ldr r0,=RCC
	ldr r1,[R0,#APB1ENR]
	ldr r3,=TIM6EN
	bics r3,r1

	ldr r2,=TIM7EN
	orrs r3,r2
	str r3,[r0,#APB1ENR]



	ldr r0,=TIM7
	ldr r1,=4800-1
	str r1,[r0,#TIM_PSC]

	ldr r1,=10-1
	str r1,[r0,#TIM_ARR]

	ldr r0,=TIM7
	ldr r1,[r0,#TIM_DIER]
	ldr r2,=TIM_DIER_UIE
	orrs r1,r2
	str r1,[r0,#TIM_DIER]

	ldr r0,=TIM7
	ldr r1,[r0,#TIM_CR1]
	ldr r2,=TIM_CR1_CEN
	orrs r1,r2
	str r1,[r0,#TIM_CR1]

	ldr r0,=NVIC
	ldr r1,= ISER
	ldr r2,=(1<<TIM7_IRQn)
	str r2,[r0,r1]
	// Student code goes above
	pop  {pc}

	// Student code goes above

//===========================================================================
// get_keypress  (Autotest 10)
// Wait for and return the number (0-15) of the ID of a button pressed.
// Parameters: none
// Return value: button ID
.global get_keypress
get_keypress:
	push {lr}
	// Student code goes below
loop_press:
				wfi
				ldr r1,=offset
				ldr r1,[r1]
				movs r0,#3
				ands r1,r0
				cmp r1,#0
				beq for2_press
				b loop_press

		for2_press:
					movs r0,#0 // i couter
			begin_loop:
						cmp r0,#16
						bge loop_press
			if_press:
						ldr r2,=history
						ldrb r3,[r2,r0]
						cmp r3,#1
						bne increment_for2
						b done_for2
			increment_for2:
						  adds r0,#1
						  b begin_loop

	done_for2:

	// Student code goes above
	pop  {pc}


//===========================================================================
// handle_key  (Autotest 11)
// Shift the symbols in the display to the left and add a new digit
// in the rightmost digit.
// ALSO: Create your "font" array just above.
// Parameters: ID of new button to display
// Return value: none
.data
.global font
font: .byte 0x06, 0x5b,0x4f, 0x77, 0x66, 0x6d, 0x7d ,0x7c, 0x07, 0x7f, 0x67, 0x39,0x49, 0x3f, 0x76, 0x5e
.text
.global handle_key
handle_key:
	push {r4-r7,lr}
	// Student code goes below
	ldr r1, =#0xf
	ands r0,r1
	movs r1,#0 // i counter
	ldr r2,=display

	loop_key:
			cmp r1,#7
			bge done_key

			movs r4,r1
			adds r4,#1
			ldrb r3,[r2,r4]
			strb r3,[r2,r1]
			adds r1,#1
			b loop_key
	done_key:
			ldr r5,=font
			ldrb r6,[r5,r0]
			movs r7,#7
			strb r6,[r2,r7]

	// Student code goes above
	pop  {r4-r7,pc}

.global login
login: .string "ranka0"
.align 2

//===========================================================================
// main
// Already set up for you.
// It never returns.
.global main
main:
    //bl  check_wiring
	bl  autotest
	bl  enable_ports
	bl  setup_tim6
	bl  setup_tim7

endless_loop:
	bl   get_keypress
	bl   handle_key
	b    endless_loop
