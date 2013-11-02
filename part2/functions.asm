; Stałe:
; WIDTH, HEIGHT - prawdziwe wymiary planszy,
; EXT_WIDTH, EXT_HEIGHT - wymiary poszerzonej planszy,
; H_EXT - margines o który została rozszerzone plansza z lewej i prawej,
; RIGHT_EXT - dopełnienie szerokości planszy do wielokrotności długości
;             używanego wektora,
; IT_WIDTH - pomocne przy warunku w pętli (WIDTH+H_EXT+RIGHT_EXT),
;
;

section .text
        global next_state
        extern printf
section .data
        array_3     dd      3,3,3,3
        array_2     dd      2,2,2,2
        array_1     dd      1,1,1,1

; ##############################################################################
; Wylicza nowy stan tablicy z żyjątkami na podstawie tablicy ze starym stanem.
; rdi - tablica ze starym stanem
; rsi - tablica z nowym stanem
; ##############################################################################
next_state:
        push    rbp
        mov     rbp, rsp
        
        push    r14
        push    r15

        mov     r15, qword 1    ; i = 1. Zmienna iteracyjna zewnętrzna.
        mov     r14, qword H_EXT; j = 4. Zmienna iteracyjna wewnętrzna.

        movups  xmm7, [array_3]
        movups  xmm6, [array_2]
        movups  xmm5, [array_1]

        jmp     loop_cond_i
 
loop_body_i:
        mov     r14, qword H_EXT; j = 4 
        jmp     loop_cond_j
        
loop_body_j:
        ; Zliczanie liczby sąsiadów.
        ; i-1, j-1
        mov     rax, r15
        dec     rax
        imul    rax, EXT_WIDTH
        add     rax, r14
        dec     rax
        movups  xmm0, [rax*4 + rdi]
        ; i-1, j
        inc     rax
        movaps  xmm1, [rax*4 + rdi] ; można pobrać "aligned"
        paddd   xmm0, xmm1
        ; i-1, j+1
        inc     rax
        movups  xmm1, [rax*4 + rdi]
        paddd   xmm0, xmm1
        ; i, j+1
        add     rax, EXT_WIDTH
        movups  xmm1, [rax*4 + rdi]
        paddd   xmm0, xmm1
        ; i, j
        dec     rax
        ; i, j-1
        dec     rax
        movups  xmm1, [rax*4 + rdi]
        paddd   xmm0, xmm1
        ; i+1, j-1
        add     rax, EXT_WIDTH
        movups  xmm1, [rax*4 + rdi]
        paddd   xmm0, xmm1
        ; i+1, j
        inc     rax
        movaps  xmm1, [rax*4 + rdi] ; można pobrać "aligned"
        paddd   xmm0, xmm1
        ; i+1,j+1
        inc     rax
        movups  xmm1, [rax*4 + rdi]
        paddd   xmm0, xmm1

        ; Pobieranie informacji o tym, czy komórka żyje.
        mov     rax, r15
        imul    rax, EXT_WIDTH
        add     rax, r14
        movaps  xmm1, [rax*4 + rdi] ; można pobrać "aligned"

        ; xmm0 <- liczba żyjących sąsiadów.

        pcmpeqd xmm1, xmm5  ; xmm1 <- czy komórka żyje.

        movaps  xmm2, xmm7
        pcmpeqd xmm2, xmm0  ; xmm2 <- czy komórka ma 3 sąsiadów.

        movaps  xmm3, xmm6
        pcmpeqd xmm3, xmm0  ; xmm3 <- czy komórka ma 2 sąsiadów.

        ; xmm3 <- komórka żyje i ma dwóch sąsiadów, więc przeżywa.
        pand    xmm3, xmm1
        ; xmm3 <- komórka jest żywa w przyszłej iteracji.
        por     xmm3, xmm2

        ; zamiana 111...111 na 00..001
        pand    xmm3, xmm5

        movaps  [rax*4 + rsi], xmm3 ; można zapisać "aligned"
        
        add     r14, 4          ; j += 4
        
loop_cond_j:
        cmp     r14, IT_WIDTH   ;
        jl      loop_body_j

        ; Zerowanie marginesu (dopełnienia do wielokrotności 4).
        mov     r14, IT_WIDTH
        sub     r14, RIGHT_EXT
        jmp     zero_margin_cond
zero_margin_body:
        mov     rax, r15 
        imul    rax, EXT_WIDTH
        add     rax, r14
        mov     [rax*4 + rsi], dword 0

        inc     r14
zero_margin_cond:
        cmp     r14, qword IT_WIDTH
        jle     zero_margin_body

        inc     r15             ; i++
loop_cond_i:
        cmp     r15, HEIGHT     ; i <= HEIGHT
        jle     loop_body_i
        
        pop     r15
        pop     r14
             
        mov     rsp, rbp
        pop     rbp
        ret
