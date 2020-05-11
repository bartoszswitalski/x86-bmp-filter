;*****************************************************
; Name: filterBitmap.s
; Purpose: .bmp filtering
;
; @author Bartosz Switalski
;
; Warsaw University of Technology
; Faculty of Electronics and 
; Information Technology
;
;*****************************************************

section .text

global filterBitmap

;*********************
; bitmap in %rdi  
; matrix in %rsi  
; width  in %rdx  
; height in %rcx  
; offset in %r8
;*********************

filterBitmap:

    push    rbp
    mov	    rbp, rsp

    mov	    r12, rsi	    ;matrix pointer
    mov	    r13d, [rdx]	    ;width
    mov	    r14d, [rcx]	    ;height
    mov	    r15d, [r8]	    ;offset

setPadding:

    ;Set padding to r10d
    mov	    r10d, r13d	    ;move bitmap width to r10d
    shr	    r10d, 2	    ;bitmap width divided(int) by 4  
    shl	    r10d, 2	    ;bitmap multiplied by 4	

    sub	    r10d, r13d 	    ;@@ r10 @@ padding 

setMainLoop:

    add	    rdi, r15	    ;move address to pixel table 
   
    ;Set jumpRow length(in bytes)

    mov	    eax, r13d	    ;bitmap width 
    mov	    r8, 3	    ;bytes per pixel
    mul	    r8d		    ;bytes in row(bitmap width*3bytes per pixel)

    add	    r9d, r10d	    ;adjust padding in jump length
    mov	    r9d, eax	    ;@@ r9 @@ proper jump length

    ;Set number of pixels to convert

    mov	    eax, r13d	    
    mul	    r14d	    ;pixels in file

    sub	    eax, r13d	    ;substract pixels in top row
    sub	    eax, r13d	    ;substract pixels in bottom row
    sub	    eax, r14d	    ;substract pixels in top column
    sub	    eax, r14d	    ;substract pixels in bottom column

    add	    eax, 4	    ;add back twice substraced pixels

    mov	    r14d, eax	    ;@@ r14 @@ pixels to convert

    ;Set number of pixels to convert in row

    mov	    r15d, r13d	    
    sub	    r15d, 2	    ;@@ r15 @@ width - 2

    ;Prepare registers

    xor	    rax, rax	    ;temporary loaded byte
    xor	    rbx, rbx	    ;temporary loaded matrix factor
    xor	    rcx, rcx	    ;temporary sum for byte masking
    xor	    rdx, rdx	    ;clear for arithmetic operations
    xor	    r8, r8	    ;clear for pixelsInRow counter   
    xor	    r11, r11	    
    xor	    r13, r13	    ;clear for pixelsDone counter 

    ;Occuppied registers: rdi,r8,r9,r10,r12,r13,r14,r15
    ;Unused registers: r11

mask3Rows:

    ; Load one row

    xor	    ax, ax
    mov	    al, byte[rdi]   ;load first byte in row
    mov	    bl, [r12]	    ;load first factor in row
    mul	    bl	 	    ;a(n1)*f(n1) in ax

    add	    ecx, eax	    ;add to sum
    add	    rdi, 3	    ;move onto the next pixel 
    add	    r12, 4	    ;move onto the next factor in matrix
    
    xor	    ax, ax
    mov	    al, byte[rdi]   ;load second byte in row
    mov	    bl, [r12]	    ;load second factor in row
    mul	    bl		    ;a(n2)*f(n2) in ax

    add	    ecx, eax	    ;add to sum
    add	    rdi, 3	    ;move onto the next pixel
    add	    r12, 4	    ;move onto the next factor in matrix

    xor	    ax, ax
    mov	    al, byte[rdi]   ;load third byte in row
    mov	    bl, [r12]	    ;load third factor in row
    mul	    bl		    ;a(n3)*f(n3) in ax

    add	    ecx, eax	    ;add to sum
    add	    rdi, r9 	    ;move onto the next row
    add	    r12, 4	    ;move onto the next factor in matrix
    
    sub	    rdi, 6	    ;set rdi on first pixel in new row

    ; Check if 3 rows done

    add	    r11b, 1	    ;counter++
    cmp	    r11b, 3
    jne	    mask3Rows	    ;if 3 rows done, go to sumFactors, else keep loop
    
    ; XOR counter and factor
    xor	    r11b, r11b	    ;set counter to 0
    sub	    r12, 36	    ;set factor pointer on first factor
    xor	    rdx, rdx	    ;set rdx to 0

sumFactors:

    add	    dx, [r12]	    ;add factor to sum
    add	    r12, 4	    ;increment factor pointer
    add	    r11b, 1	    ;++counter

    cmp	    r11b, 9	    ;check counter
    jne	    sumFactors

    mov	    r11w, dx	    ;set factor sum to r11
    xor	    rdx, rdx	    ;set rdx to 0
    sub	    r12, 36	    ;set factor pointer on first factor

filter:

    sub	    rdi, r9	    ;go back one row
    sub	    rdi, r9	    ;go back one row
    add	    rdi, 3	    ;set on the middle pixel to filter
    
    mov	    eax, ecx	    ;set sum to eax
    div	    r11d	    ;mask sum /= mask weights sum
    xor	    r11, r11	    ;set r11 to 0

    mov	    byte[rdi], al   ;overwrite B value

    inc	    rdi
    mov	    byte[rdi], al   ;overwrite G value

    inc	    rdi
    mov	    byte[rdi], al   ;overwrite R value

    inc	    r8		    ;++pixelsDoneInRow
    inc	    r13		    ;++pixelsDone

    inc	    rdi		    ;move one pixel to the right
    sub	    rdi, r9	    ;go back to the first row
    sub	    rdi, 3	    ;move onto the next pixel(previously first row-middle one)

    xor	    rcx, rcx
    xor	    rax, rax

    cmp	    r8, r15	    ;if all pixels in row done 
    jne	    mask3Rows	    ;just skip this 
    
    cmp	    r13, r14
    je	    end	    	    ;if every pixel in file done

jumpRow:

    add	    rdi, r10	    ;adjust padding
    add	    rdi, 6	    ;move to the next row by jumping two pixels
    xor	    r8, r8	    ;reset pixelsDoneInRow counter

    jmp	    mask3Rows
    
end:

    mov	    rsp, rbp
    pop	    rbp
    ret
