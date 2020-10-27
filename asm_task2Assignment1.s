section	.rodata									; we define (global) read-only variables in .rodata section
	decimal_format: db "%d", 10, 0			; define the print format for decimal value followed by '\n' and '\0'
	error_msg: db "illegal input", 10, 0	; define a constant error message followed by '\n' and '\0'

section .text
	global assFunc
	extern printf
	extern c_checkValidity

assFunc:
	push ebp						; Enter function procedure
	mov ebp, esp
	pushad

	mov ecx, dword [ebp+8]	; get function first argument integer
	mov ebx, dword [ebp+12]	; get function second argument integer
	sub esp, 4					; allocate space for local variable z which will be the sum of arguments
	xor eax, eax				; Assign the value 0 to eax
	push dword ebx				; push variable y (second argument for c_checkValidity) to stack
	push dword ecx				; push variable x (first argument for c_checkValidity) to stack
	call c_checkValidity		; call c function to check x and y validity, output in eax will be 1 for true (valid) 0 for false (invalid)
	add esp, 8					; move esp 8 bytes above to clear pushed arguments

	cmp eax, byte 0			; 0 meaning c_checkValidity returned false, 1 meaning true
	jne calc						; if c_checkValidity was 1 (true) input is valid, jmp to calculation

	push error_msg				; input was not valid, push error message to stack (argument for printf)
	call printf					; call c function printf
	add esp, 4					; move esp 4 bytes above to clear pushed arguments
	jmp finish					; jmp to finish function

	calc:
		add ebx, ecx			; ebx = y, ecx = x => now ebx will contain x+y
		mov [ebp-4], ebx		; assign local variable z with the sum of x and y
		mov eax, [ebp-4]		; put z sum value in eax
		push eax					; push eax = z addition result to stack (second argument for printf)
		push decimal_format	; push print format to stack (first argument for printf)
		call printf				; call c function printf
		add esp, 8				; move esp 8 bytes above to clear pushed arguments

	finish:
		add esp, 4				; move esp 4 bytes above to clear assigned variable z
		popad						; Finish function procedure and return from function
		mov esp, ebp
		pop ebp
		ret
