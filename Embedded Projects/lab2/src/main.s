.cpu cortex-m0
.thumb
.syntax unified
.fpu softvfp



.data
.align 4
.global value
value:.word 0

.global source
source: .word 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610

.global str
str: .string "hello, 01234 world! 56789=="


.text
.global intsub
intsub:
		push {r4-r7,lr}
		ldr r0,=value
		ldr r1,[r0]
		ldr r0,=source
		movs r5,#0
		movs r7,#0
loop:
		ldr r2,[r0,r7]
		cmp r5,#10
		bge done

if1:
		movs r3,#1
		ands r3,r5
		beq else
		adds r7,#4
		ldr r4,[r0,r7]
		subs r7,#4
		muls r2,r4
		adds r1,r2

		b increment
else:
		movs r6,#3
		muls r2,r6
		adds r1,r2

		b increment
increment:
		adds r5,#1
		adds r7,#4
		b loop

done:
		ldr r0,=source
		str r1,[r0]
	 POP {r4,r7,PC}


.global charsub
charsub:
		ldr r0,=str

		movs r2,#0 // increment val
loop2:
		ldrb r1,[r0,r2]
		movs r3,r1
		cmp r3,#0
		beq done2

if2:
		cmp r3,#99
		blt increment2
		cmp r3,#122
		bgt increment2
		subs r3,#2
		strb r3,[r0,r2]

increment2:
			adds r2,#1
			b loop2
done2:
		bx lr




.global login
login: .string "ranka0" // Make sure you put your login here.
.align 2
.global main
main:
    bl autotest
    bl intsub
    bl charsub
    bkpt // not sure




