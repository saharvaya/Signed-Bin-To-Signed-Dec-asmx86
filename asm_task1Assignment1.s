section	.rodata
	format_string: db "%s", 10, 0	; format string with 0x0A ('\n') and 0x00 ('\0')

section .bss							; we define (global) uninitialized variables in .bss section
	an: resb 12							; enough to store integer in [-2,147,483,648 (-2^31) : 2,147,483,647 (2^31-1)]
	pow: resd 31  						; enough to store an array of powers -> 2^n where 0 <= n <= 31

section .text
	global convertor					; define global function convertor for c external use
	global calc_powers				; define global function calc_powers for c external use
	extern printf						; define external c function printf

calc_powers:							; calculates a table of 2^n (0 <= n <= 31)
	push ebp								; Enter function procedure
	mov ebp, esp
	pushad

	mov edx, 1							; assign edx with the value 1
	mov ebx, 31							; assign ebx with the value 31, will be used as iteration index
	mov eax, pow						; assign eax with the address to pow, the powers 32 bit integers array
	calc:
		mov dword [eax], edx			; mov edx value to the current location eax is pointing to
		shl edx, 1						; logical bit shift by one place to the left will give us 2*edx
		dec ebx							; decrease iteration index ebx
		add eax, 4						; increment the address stored in eax (powers array) by 4 bytes to store another 32 bit integer
		cmp ebx, 0						; check if ebx index is 0 to finish calculation all powers to 2^31
		jnz calc							; iterate again while ebx is not 0

	popad									; Finish function procedure and return from function
	mov eax, pow						; move return pointer value to eax
	mov esp, ebp
	pop ebp
	ret

str_len:								; calculates and returns the length of input string (swapping '\n' character from input string)
	push ebp							; Enter function procedure
	mov ebp, esp

	mov ecx, [ebp+8]				; get function argument pointer to input string

	mov ebx, ecx					; ebx holds a pointer to first string character
	xor eax, eax   				; we count the string length in eax, xor eax, eax => eax = 0
	jmp check_done					; start iteration to count string length
	swap_newline:
		mov [ecx], byte 0			; swap current input string character to '\0'
		jmp check_done				; return to check if iteration on input string is done
	increment:
		inc ecx						; increment to the next input string character
		inc eax						; increment string length counter
	check_done:
		cmp [ecx], byte 0x0A		; compare current input string character to '\n'
		jz swap_newline			; jump to swap '\n' new line character with null '\0'
		cmp byte [ecx], 0			; check for '\0' null terminator meaning string is over
		jnz increment				; jump to increment current string character location and string length counter

	mov esp, ebp					; Finish function procedure and return from function
	pop ebp
	ret

decimal_to_string:				; we will seperate each charcter from decimal string by divising by 10 and storing the remainder
	push ebp							; Enter function procedure
	mov ebp, esp

	mov esi, [ebp+8]				; get function argument pointer to output string

	mov ecx, 10	 					; assign ecx with the value 10, will be the divisor of the quotient
	mov eax, ebx 					; assign eax with the decimal value of the integer
	xor ebx, ebx					; assign 0 to ebx, we will store the decimal number length in it
	get_decimal_length:
		xor edx, edx				; assign the value 0 to edx
		div ecx						; divide eax (decimal value) with ecx = 10, quotient now stored in eax, remainder now stored in edx
		push dx						; we push the quotient to the stack (lsb in the decimal representation)
		inc ebx						; increment the length of decimal representation
		cmp eax, 0					; check is quotient is 0, meaning we got all digits from decimal representation
		jnz get_decimal_length	; we have all digits stored in stack
	string_loop:
		pop ax						; pop the digit from stack (will be poped msb to lsb)
		add al, '0'					; convert decimal digit to ascii value
		mov [esi], al				; store in the next significat position in output string the poped character representation of the digit
		inc esi						; increment to the next position in output string
		dec ebx						; decrement the stored length of decimal representation to check when we stored all digits
		cmp ebx, 0					; check if ebx = 0 we stored all digist in output byte array an
		jnz string_loop			; continue iteration while still have digits to store

	mov esp, ebp					; Finish function procedure and return from function
	pop ebp
	ret

convertor:
	push ebp								; Enter function procedure
	mov ebp, esp
	pushad

	mov ecx, dword [ebp+8]			; get first function argument (pointer to input string)
	mov esi, dword [ebp+12] 		; get second function argument (pointer to powers array)

	mov eax, an							; start clear output array procedure, point eax to output byte array
	mov ebx, 3							; set ebx to 3 used as index to iterate output byte array (we will fill it with 0x00 as dword(4 byte), so 3 times * 4 bytes will occupy 12 bytes total)
	clear_output:						; clears output byte array (could also be done with iterating 12 times)
		mov dword [eax], 0			; move 0x00 (null) represented as dword to set the current pointed place in the output array to null
		add eax, 4						; increment eax to point to the next dword (4 bytes) address in output byte array
		dec ebx							; decrement iteration index ebx
		cmp ebx, 0						; check if iteration index ebx reached to 0
		jne clear_output				; jump to next iteration to clear output array

	push ecx								; push pointer to input string to stack (argument for str_len)
	call str_len						; call function str_len, after call eax will contain the length of the string pointed by ecx
	add esp, 4							; move esp 4 bytes above to clear pushed arguments

	check_sign:
		mov dl, '1'						; we store in dl the byte to notify the sign of the integer '1' is positive, '0' is negative. will be used later to calculate the decimal value
		cmp eax, 32						; eax stores input string length, check if the input string length is 32 characters long
		jg finish						; if the input string is greater than 32 characters, it is illegal jump to finish function
		jnz to_decimal					; if it is less than 32 characters long it is a positive binary number, jump to convert it to decimal

		cmp byte [ebx], '1'			; ebx points to msb in input string, check if it is 1 to determine it is 2's complement negative binary num
		jnz to_decimal					; if it is 0 this is a positive number, jump to convert it to decimal

	negative:							; input string is a 2's complement binary negative number, convert the number to positive, first we negate bits
		mov dl, '0'						; assign dl with '0' meaning the number is negative

	to_decimal:							; convert the binary input string to decimal value
		xor ebx, ebx 					; decimal value will be stored in ebx, we intitialize with 0
		xor edi, edi 					; assign value 0 to edi will be used as iteration counter
		calc_sum:						; calculate the sum of the powers of 2 composing the binary number
			dec ecx						; point to the next significant bit in the input string
			cmp edi, eax 				; check if current iteration index reached the length of the input string
			je add_sign_output		; iteration is finished we can now add the sign of the decimal number to the output array
			cmp [ecx], dl				; if number is positive and if bit is 1 we need to sum the corresponding power of 2 else the number is negative we will sum if bit is 0 (stored in dl)
			jz inc_sum					; jump to increment total sum composing the number
			inc edi						; increment iteration index
			jmp calc_sum				; continue iteration on binary string
			inc_sum:
				add ebx, [esi+edi*4]	; esi points to powers array from argument,  ebx will contain ebx + powers[edi] meaning ebx + 2^edi (we multiply edi by 4 to get next dword)
				inc edi					; increment iteration index
				jmp calc_sum			; continue iteration on binary string

	add_sign_output:					; check if number is negative to add minus sign to output string
		mov esi, an						; assign esi with a pointer to output byte array
		cmp dl, byte '0'				; check if number is negative
		jnz to_string					; if not, number is positive, assign decimal string representation to output
		inc ebx							; add one to decimal number to complete 2's complement
		mov cx, 0x2D					; number is negative we need to add '-' minus character to output string, assign cx with 0x2D ascii for '-'
		mov [esi], cx					; store in first position in output array the sign
		inc esi							; point esi to next location after sign in output array

	to_string:
		push esi							; push pointer to output string stored in esi to stack (argument decimal_to_string)
		call decimal_to_string		; call function decimal_to_string, after call an output array should store the output byte string
		add esp, 4						; move esp 4 bytes above to clear pushed arguments

	finish:
		mov eax, an						; move the address of first position in output string array to eax (will be returned)

	push an								; call printf with 2 arguments -
	push format_string				; pointer to str and pointer to format string
	call printf
	add esp, 8							; clean up stack after call

	popad									; Finish function procedure and return from function
	mov esp, ebp
	pop ebp
	ret
