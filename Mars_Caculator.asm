#Assignment10 - Đào Duy Thái - 20205019
.eqv SEVENSEG_LEFT 0xFFFF0011 			# Dia chi cua den led 7 doan trai.
 						# Bit 0 = doan a; 
 						# Bit 1 = doan b; ... 
						# Bit 7 = dau .
.eqv SEVENSEG_RIGHT 0xFFFF0010 			# Dia chi cua den led 7 doan phai
.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012 
.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014 
.data
	KeyBoard: .word 0x11, 0x21, 0x41, 0xffffff81, 0x12, 0x22, 0x42, 0xffffff82, 0x14, 0x24, 0x44, 0xffffff84, 0x18, 0x28, 0x48, 0xffffff88
	Number: .word 0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f, 0x40
	Message: .asciiz "Math Error!!!\n"
.text
main:
	xor $s0, $s0, $s0			#khởi tạo biến trạng thái $s0
	xor $s1, $s1, $s1			#khởi tạo biến $s1 là giá trị của led trái
 	li $a0, 0x3f 				# set value for segments
 	jal SHOW_7SEG_LEFT 			# show
	nop
	xor $s2, $s2, $s2			#khởi tạo biến $s2 là giá trị của led phải
 	li $a0, 0x3f 				# set value for segments
 	jal SHOW_7SEG_RIGHT 			# show 
 	nop
 	xor $s3, $s3, $s3			#khởi tạo biến $s3 là giá trị số hạng thứ nhất
 	xor $s4, $s4, $s4			#khởi tạo biến $s4 là giá trị số hạng thứ hai
	li $t1, IN_ADRESS_HEXA_KEYBOARD
 	li $t3, 0x80 				# bit 7 = 1 to enable 
 	sb $t3, 0($t1)
Loop:
	nop
	nop
	nop
sleep:
	addi $v0,$zero,32 
 	li $a0,300 				# sleep 300 ms
 	syscall
 	nop 					# WARNING: nop is mandatory here. 
 	b Loop 				
end_main:
	li $v0, 10
	syscall
#---------------------------------------------------------------
# Function SHOW_7SEG_LEFT : turn on/off the 7seg
# param[in] $s1 value to shown 
# remark $t0 changed
#---------------------------------------------------------------	
SHOW_7SEG_LEFT: 
	li $t0, SEVENSEG_LEFT 			# assign port's address
 	sb $a0, 0($t0) 				# assign new value 
 	nop
	jr $ra
	nop
#---------------------------------------------------------------
# Function SHOW_7SEG_RIGHT : turn on/off the 7seg
# param[in] $s2 value to shown 
# remark $t0 changed
#---------------------------------------------------------------
SHOW_7SEG_RIGHT: 
	li $t0, SEVENSEG_RIGHT 			# assign port's address
 	sb $a0, 0($t0) 				# assign new value
 	nop
	jr $ra 
 	nop
.ktext 0x80000180 
 #-------------------------------------------------------
 # SAVE the current REG FILE to stack
 #-------------------------------------------------------
IntSR: 
 	addi $sp, $sp, -4 # Save $ra because we may change it later
 	sw $v0, 0($sp)
 	addi $sp, $sp, -4 # Save $a0, because we may change it later
 	sw $a0, 0($sp)
#--------------------------------------------------------
# Processing
#-------------------------------------------------------- 
get_cod:
row1:
	li $t1, IN_ADRESS_HEXA_KEYBOARD
 	li $t3, 0x81 # check row 4 and re-enable bit 7
 	sb $t3, 0($t1) # must reassign expected row
 	li $t1, OUT_ADRESS_HEXA_KEYBOARD
 	lb $a0, 0($t1)
 	beqz $a0, row2
 	nop
 	j checkNum
 	nop
row2:
	li $t1, IN_ADRESS_HEXA_KEYBOARD
 	li $t3, 0x82 # check row 4 and re-enable bit 7
 	sb $t3, 0($t1) # must reassign expected row
 	li $t1, OUT_ADRESS_HEXA_KEYBOARD
 	lb $a0, 0($t1)
 	beqz $a0, row3
 	nop
 	j checkNum
 	nop
row3:
	li $t1, IN_ADRESS_HEXA_KEYBOARD
 	li $t3, 0x84 # check row 4 and re-enable bit 7
 	sb $t3, 0($t1) # must reassign expected row
 	li $t1, OUT_ADRESS_HEXA_KEYBOARD
 	lb $a0, 0($t1)
 	beqz $a0, row4
 	nop
 	j checkNum
 	nop
row4:
	li $t1, IN_ADRESS_HEXA_KEYBOARD
 	li $t3, 0x88 # check row 4 and re-enable bit 7
 	sb $t3, 0($t1) # must reassign expected row
 	li $t1, OUT_ADRESS_HEXA_KEYBOARD
 	lb $a0, 0($t1)
 	j checkNum
 	nop
checkNum:
	la $t0, KeyBoard				#lấy địa chỉ của mảng KeyBoard
	xor $t1, $t1, $t1			#khởi tạo $t1 = 0 (biến con chạy)
loop:
	add $t2, $t0, $t1			#gán $t2 = $t0 + $t1
	lw $t3, 0($t2)				#lấy giá trị tại địa chỉ $t2 lưu vào $t3
	beq $a0, $t3, the_number			#nếu $t3 = $a0 (tìm được phím trong bảng) thì chuyển đến the_number
	nop
	addi $t1, $t1, 4				#tăng giá trị $t1 thêm 4
	j loop					#quay lại vòng loop
	nop
end_loop:

the_number:
	div $t1, $t1, 4				#chia $t1 đi 4 lần (để tìm giá trị của phím trong bảng)
	beq $t1, 0xa, number_a			#nếu $t1 = 0xa thì chuyển đến number_a
	nop
	beq $t1, 0xb, number_b			#nếu $t1 = 0xb thì chuyển đến number_b
	nop
	beq $t1, 0xc, number_c			#nếu $t1 = 0xc thì chuyển đến number_c
	nop
	beq $t1, 0xd, number_d			#nếu $t1 = 0xd thì chuyển đến number_d
	nop
	beq $t1, 0xe, number_e			#nếu $t1 = 0xe thì chuyển đến number_e
	nop
	beq $t1, 0xf, number_f			#nếu $t1 = 0xf thì chuyển đến number_f
	nop
	la $t2, Number				#lấy địa chỉ của mảng Number
	add $s1, $s2, $0				#gán giá trị của $s2 cho $s1
	mul $t3, $s1, 4				#gán $t3 = $s1 * 4
	add $t4, $t2, $t3			#gán $t4 = $t2 + $t3 (vị trí của giá trị cần hiện trong mảng Number)
	lw $a0, 0($t4)				#lấy giá trị từ địa chỉ $t4 gán vào $a0
	jal SHOW_7SEG_LEFTK			#chuyển đến hàm SHOW_7SEG_LEFTK
	nop
	add $s2, $0, $t1				#gán $s2 = $t1
	mul $t3, $s2, 4				#gán $t3 = $s2 * 4
	add $t4, $t2, $t3			#gán $t4 = $t2 + $t3 (vị trí của giá trị cần hiện trong mảng Number)
	lw $a0, 0($t4)				#lấy giá trị từ địa chỉ $t4 gán vào $a0
	jal SHOW_7SEG_RIGHTK			#chuyển đến hàm SHOW_7SEG_RIGHTK
	nop
	j restore				#chuyển đến restore
	nop
number_a:
	mul $t0, $s1, 10				#gán $t0 = $s1 * 10
	add $s3, $t0, $s2			#gán $s3 = $t0 + $s2 ($s3 là số hạng thứ nhất)
	addi $s0, $0, 1				#gán $s0 = 1
	j restore				#chuyển đến restore
	nop
number_b:
	mul $t0, $s1, 10				#gán $t0 = $s1 * 10
	add $s3, $t0, $s2			#gán $s3 = $t0 + $s2 ($s3 là số hạng thứ nhất)
	addi $s0, $0, 2				#gán $s0 = 2
	j restore				#chuyển đến restore
	nop
number_c:
	mul $t0, $s1, 10				#gán $t0 = $s1 * 10
	add $s3, $t0, $s2			#gán $s3 = $t0 + $s2 ($s3 là số hạng thứ nhất)
	addi $s0, $0, 3				#gán $s0 = 3
	j restore				#chuyển đến restore
	nop
number_d:
	mul $t0, $s1, 10				#gán $t0 = $s1 * 10
	add $s3, $t0, $s2			#gán $s3 = $t0 + $s2 ($s3 là số hạng thứ nhất)
	addi $s0, $0, 4				#gán $s0 = 4
	j restore				#chuyển đến restore
	nop
number_e:
	xor $s1, $s1, $s1			#khởi tạo lại $s1
 	li $a0, 0x3f 				# set value for segments
 	jal SHOW_7SEG_LEFTK 			# show
	nop
	xor $s2, $s2, $s2			#khởi tạo lại $s2
 	li $a0, 0x3f 				# set value for segments
 	jal SHOW_7SEG_RIGHTK 			# show 
 	nop
 	xor $s3, $s3, $s3			#khởi tạo lại $s3
 	xor $s4, $s4, $s4			#khởi tạo lại $s4
 	j restore				#chuyển đến restore
 	nop
number_f:
	mul $t0, $s1, 10				#gán $t0 = $s1 * 10
	add $s4, $t0, $s2			#gán $s4 = $t0 + $s2 ($s4 chứa giá trị số hạng thứ 2
	beq $s0, 1, sum				#nếu $s0 = 0 chuyển đến sum
	nop
	beq $s0, 2, subtr			#nếu $s0 = 1 chuyển đến subtr
	nop
	beq $s0, 3, multi			#nếu $s0 = 2 chuyển đến multi
	nop
	beq $s0, 4, divi				#nếu $s0 = 3 chuyển đến divi
	nop
	j restore				#chuyển đến restore
	nop
sum:
	add $t0, $s3, $s4			#gán $t0 = $t3 + $t4
	bge $t0, 100, out_100			#nếu $t0 >= 100 thì chuyển đến out_100
	nop
	div $s1, $t0, 10				#nếu không gán $s1 = $t0/ 10 ($s1 chứa giá trị hàng chục)
	mfhi $s2					#$s2 = hi ($s2 chứa giá trị hàng đơn vị)
	j show					#chuyển đén show
	nop
subtr:
	sub $t0, $s3, $s4			#gán $t0 = $t3 - $t4
	bltz $t0, nega_number			#nếu $t0 < 0 thì chuyển đến nega_number
	nop
	div $s1, $t0, 10				#nếu không gán $s1 = $t0/ 10 ($s1 chứa giá trị hàng chục)
	mfhi $s2					#$s2 = hi ($s2 chứa giá trị hàng đơn vị)
	j show					#chuyển đén show
	nop
multi:
	mul $t0, $s3, $s4			#gán $t0 = $s3 * $s4
	seq $t2, $s3, $0			
	seq $t3, $s4, $0
	or $t1, $t2, $t3
	bnez $t1, number_e			#nếu $s3 hoặc $s4 = 0 thì chuyển đến number_e
	nop
	bge $t0, 100, out_100			#nếu $t0 >= 100 thì chuyển đến out_100
	nop
	div $s1, $t0, 10				#nếu không gán $s1 = $t0/ 10 ($s1 chứa giá trị hàng chục)
	mfhi $s2					#$s2 = hi ($s2 chứa giá trị hàng đơn vị)
	j show					#chuyển đén show
	nop
divi:
	beqz $s4, error				#nếu $s4 = 0 chuyển đến error
	nop
	div $t0, $s3, $s4			#gán $t0 = $s3 / $s4
	beqz $s3, number_e			#nếu $s3 = 0 chuyển đến number_e
	nop
	mfhi $t1					#phần dư đưa vào $t1
	bnez $t1, real				#nếu phần dư != 0 thì chuyển đến real
	nop
	div $s1, $t0, 10				#nếu không gán $s1 = $t0/ 10 ($s1 chứa giá trị hàng chục)	
	mfhi $s2					#$s2 = hi ($s2 chứa giá trị hàng đơn vị)
	j show					#chuyển đén show
	nop
out_100:
	div $t0, $t0, 10				#gán $t0 = $t0 / 10
	mfhi $s2					#phần dư đưa vào $s2 ($s2 chứa giá trị hàng đơn vị)
	div $t0, $t0, 10				#gán $t0 = $t0 / 10
	mfhi $s1					#phần dư đưa vào $s1 ($s1 chứa giá trị hàng chục)
	j show					#chuyển đén show
	nop
nega_number:
	addi $s1, $0, 0xa			#gán $s1 = 0xa (10)
	sub $s2, $0, $t0				#gán $s2 = 0 - $t0 (lấy phần không âm)
	div $t3, $s2, 10				#gán $t3 = $s2 / 10
	mfhi $t4					#phần dư gán vào $t4 ( chứa giá trị hàng đơn vị)
	mflo $t2					#phần nguyên gán vào $t2 (chứa giá trị hàng chục)
	addi $s0, $0, 5				#gán $s0 = 5
	j show					#chuyển đén show
	nop
real:
	mul $t1, $s3, 100			#gán $t1 = $s3 * 100 (để lấy thêm được 2 số sau dâu phẩy)
	div $t2, $t1, $s4			#gán $t2 = $t1 / $s4 
	div $t2, $t2, 10				#gán $t2 = $t2 / 10
	mfhi $s2					#gán $s2 = hi ($s2 chứa giá trị hàng đơn vị)
	div $t2, $t2, 10				#gán $t2 = $t2 / 10
	mfhi $s1					#gán $s1 = hi ($s1 chứa giá trị hàng đơn vị)
	add $s0, $0, 6				#gán $s0 = 6
	j show					#chuyển đén show
	nop
		
show:
	la $t0, Number				#lấy địa chỉ mảng Number
	beq $s0, 5, show_nega			#nếu $s0 = 5 thì chuyển đến show_nega
	nop
	beq $s0, 6, show_real			#nếu $s0 = 6 thì chuyển đến show_real
	nop
	mul $t3, $s1, 4				#tìm vị trí địa chỉ chứa giá trị led của $s1
	add $t1, $t0, $t3
	lw $a0, 0($t1)				#gán $a0 = giá trị led đó
	jal SHOW_7SEG_LEFTK 			#chuyển đến hàm SHOW_7SEG_LEFTK
	nop
	la $t0, Number				#lấy địa chỉ của mảng Number
	mul $t3, $s2, 4				#tìm vị trí địa chỉ chứa giá trị led của $s2
	add $t1, $t0, $t3
	lw $a0, 0($t1)				#gán $a0 = giá trị led đó
	jal SHOW_7SEG_RIGHTK 			#chuyển đến hàm SHOW_7SEG_RIGHTK
	nop
	j restore				#chuyển đến restore
	nop
show_nega:
	mul $t3, $s1, 4				#tìm vị trí địa chỉ chứa giá trị led của $s1
	add $t1, $t0, $t3
	lw $a0, 0($t1)				
	jal SHOW_7SEG_LEFTK 			#chuyển đến hàm SHOW_7SEG_LEFTK
	nop
	add $a0, $0, $0				#gán $a0 = 0
	jal SHOW_7SEG_RIGHTK 			#chuyển đến hàm SHOW_&SEG_RIGHTK
	nop
	li $v0, 32
	li $a0, 1500
	syscall					#sleep trong 1500ms
	nop
	add $s1, $t2, $0				#nếu $t2 hoặc $t4 = 0 thì 
	add $s2, $t4, $0
	la $t0, Number				#lấy địa chỉ Number gán vào $t0
	mul $t3, $s1, 4				#tìm vị trí địa chỉ chứa giá trị led của $s1
	add $t1, $t0, $t3
	lw $a0, 0($t1)				#lấy lại giá trị $a0 từ trong địa chỉ $t1
	jal SHOW_7SEG_LEFTK 
	nop
	la $t0, Number			
	mul $t3, $s2, 4				#tìm vị trí địa chỉ chứa giá trị led của $s2
	add $t1, $t0, $t3			
	lw $a0, 0($t1)				
	jal SHOW_7SEG_RIGHTK 			#lấy lại giá trị $a0 từ trong địa chỉ $t1
	nop
	j restore				#chuyển đến restore
	nop
show_real:
	div $t2, $t2, 10				#gán $t2 = $t2 / 10
	mfhi $t3					#gán phần dư vào $t3
	mul $t1, $t2, 4				#tìm vị trí để in ra led tương ứng
	add $t1, $t1, $t0
	lw $a0, 0($t1)				#lấy giá trị từ $t1
	jal SHOW_7SEG_LEFTK 			#chuyển đến SHOW_7SEG_LEFTK
	nop
	la $t0, Number				#lấy địa chỉ của mảng Number
	mul $t1, $t3, 4				#tìm vị trí led tương ứng
	add $t1, $t1, $t0
	lw $a0, 0($t1)				#lấy giá trị từ $t3
	add $a0, $a0, 0x80			#hiện ra dâu chấm ở led
	jal SHOW_7SEG_RIGHTK 			#chuyển đến SHOW_7SEG_RIGHTK
	nop		
	li $v0, 32				
	li $a0, 1500
	syscall					#nghỉ ngơi 1500ms
	nop
	la $t0, Number				#lấy địa chỉ của mảng Number
	mul $t3, $s1, 4				#tìm vị trí led tương ứng
	add $t1, $t0, $t3			#gán $t1 = $t0 + $t3
	lw $a0, 0($t1)				#lấy giá trị từu $t1 lưu vào $a0
	jal SHOW_7SEG_LEFTK 			#chuyên đến SHOW_7SEG_LEFTK
	nop
	la $t0, Number				#lấy địa chỉ của mảng Number
	mul $t3, $s2, 4				#tìm vị trí led tương ứng
	add $t1, $t0, $t3
	lw $a0, 0($t1)				#lấy giá trị từu $t1 lưu vào $a0
	jal SHOW_7SEG_RIGHTK			#chuyên đến SHOW_7SEG_RIGHTK
	nop
	j restore				#chuyển đến restore
	nop
error:
	li $v0, 55				#gán $v0 = 55
	la $a0, Message				#lấy địa chỉ của Message gán vào $a0
	syscall					#hiện thông báo với nội dung Message
	j number_e				#chuyển đến number_e
	nop
restore:
 	lw $a0, 0($sp) # Restore the registers from stack
 	addi $sp,$sp, 4
 	lw $v0, 0($sp) # Restore the registers from stack
 	addi $sp,$sp, 4 
return: 
	eret # Return from exception
#---------------------------------------------------------------
# Function SHOW_7SEG_LEFTK : turn on/off the 7seg
# param[in] $s1 value to shown 
# remark $t0 changed
#---------------------------------------------------------------	
SHOW_7SEG_LEFTK: 
	li $t0, SEVENSEG_LEFT 			# assign port's address
 	sb $a0, 0($t0) 				# assign new value 
 	nop
	jr $ra
	nop
#---------------------------------------------------------------
# Function SHOW_7SEG_RIGHTK : turn on/off the 7seg
# param[in] $s2 value to shown 
# remark $t0 changed
#---------------------------------------------------------------
SHOW_7SEG_RIGHTK: 
	li $t0, SEVENSEG_RIGHT 			# assign port's address
 	sb $a0, 0($t0) 				# assign new value
 	nop
	jr $ra 
 	nop
