section .text
        global next_state
        
; ##############################################################################
; Wylicza nowy stan tablicy z żyjątkami na podstawie tablicy ze starym stanem.
; rdi - tablica ze starym stanem
; rsi - tablica z nowym stanem
; Używa (modyfikuje) rejestry rbx, rdi, rsi, r12..15.
; ##############################################################################
next_state:
        push    rbp
        mov     rbp, rsp
        
        push    rbx
        push    rdi
        push    rsi
        push    r12
        push    r13
        push    r14
        push    r15
        
        mov     r15, 0          ; i = 0. Zmienna iteracyjna zewnętrzna.
        mov     r14, 0          ; j = 0. Zmienna iteracyjna wewnętrzna.
        mov     r13, rdi        ; Zachowujemy sobie wskaźnik do tablicy ze
                                ; starym stanem. Taniej brać z rejestru.
        mov     rbx, rsi        ; Podobnie ze wskaźnikiem do nowego stanu.
        mov     r12, qword 0    ; s = 0. Wyzerowanie licznika sąsiadów.
        
        ; for (i = 0; i < HEIGHT; ++i)
        ;   for (j = 0; j < WIDTH; ++j)
        ;       cell_new_state(i,j,old,new)

        jmp     loop_cond_i
 
loop_body_i:
        mov     r14, 0          ; j = 0
        jmp     loop_cond_j
        
loop_body_j:
        ; Początek "funkcji" cell_new_state
        ; Najpierw zliczamy żywych sąsiadów komórki (i,j).
        mov     r12, qword 0    ; s = 0. Wyzerowanie liczby sąsiadów.
        ; s += a[i-1][j-1]
        mov     rdi, r15
        dec     rdi             ; i - 1
        mov     rsi, r14
        dec     rsi             ; j - 1
        mov     rdx, r13        ; stary stan
        call    in_board_and_alive
        add     r12, rax        ; aktualizujemy liczbę żywych sąsiadów.
        
        ; s += a[i-1][j]
        mov     rdi, r15
        dec     rdi             ; i - 1
        mov     rsi, r14        ; j
        mov     rdx, r13        ; stary stan
        call    in_board_and_alive
        add     r12, rax
        
        ; s += a[i-1][j+1]
        mov     rdi, r15
        dec     rdi             ; i - 1
        mov     rsi, r14
        inc     rsi             ; j + 1
        mov     rdx, r13        ; stary stan
        call    in_board_and_alive
        add     r12, rax
        
        ; s += a[i][j-1]
        mov     rdi, r15
        mov     rsi, r14
        dec     rsi
        mov     rdx, r13
        call    in_board_and_alive
        add     r12, rax
        
        ; s += a[i][j+1]
        mov     rdi, r15
        mov     rsi, r14
        inc     rsi
        mov     rdx, r13
        call    in_board_and_alive
        add     r12, rax
        
        ; s += a[i+1][j-1]
        mov     rdi, r15
        inc     rdi
        mov     rsi, r14
        dec     rsi
        mov     rdx, r13
        call    in_board_and_alive
        add     r12, rax
        
        ; s += a[i+1][j]
        mov     rdi, r15
        inc     rdi
        mov     rsi, r14
        mov     rdx, r13
        call    in_board_and_alive
        add     r12, rax
        
        ; s += a[i+1][j+1]
        mov     rdi, r15
        inc     rdi
        mov     rsi, r14
        inc     rsi
        mov     rdx, r13
        call    in_board_and_alive
        add     r12, rax
        
        ; Sprawdzenie, czy aktualna komórka jest żywa.
        mov     rax, r15
        imul    rax, WIDTH
        add     rax, r14
        movsx   rax, dword [rax*4 + r13]  ; rax mówi, czy komórka jest żywa czy martwa.
        
        cmp     rax, qword 0
        jne     now_cell_is_alive   ; komórka jest żywa.
        ; tutaj komórka jest martwa.
        cmp     r12, qword 3
        je      next_cell_is_alive  ; komórka ma trzech sąsiadów, więc ożywa.
        jmp     next_cell_is_dead   ; komórka nie ożywa.
now_cell_is_alive:
        cmp	    r12, qword 1        ; jeśli s <= 1 to żyjątko umiera
        jle     next_cell_is_dead
        cmp     r12, qword 3        ; jeśli s <= 3 to żyjątko przeżywa
        jle     next_cell_is_alive
next_cell_is_dead:
        mov     r12, qword 0
        jmp     end_check_alive
next_cell_is_alive:
        mov     r12, qword 1
end_check_alive:
        
        ; wstawienie liczby sąsiadów do tablicy z nowym stanem.
        mov     rax, r15
        imul    rax, WIDTH
        add     rax, r14
        mov     [rax*4 + rbx], r12d ; r12d, kopiujemy tylko 32 bity rejestru.
        
        ; koniec cell_new_state
        
        inc     r14             ; j++
        
loop_cond_j:
        cmp     r14, WIDTH      ; j < WIDTH
        jl      loop_body_j
        inc     r15             ; i++
        
loop_cond_i:
        cmp     r15, HEIGHT     ; i < HEIGHT
        jl      loop_body_i
        
        pop     r15
        pop     r14
        pop     r13
        pop     r12
        pop     rsi 
        pop     rdi
        pop     rbx
             
        mov     rsp, rbp
        pop     rbp
        ret
        

; ##############################################################################
; Sprawdza czy podane współrzędne (i,j) w tablicy opisującej stary stan są
; prawidłowe. Jeśli nie, traktujemy tę komórkę jak komórkę pustą.
; Jeśli współrzędne są prawidłowe, to funkcja zwraca zawartość danej komórki
; tablicy, czyli liczbę żywych istot w komórce (0 lub 1).
; rdi - współrzędna i
; rsi - współrzędna j   
; rdx - wskaźnik do tablicy ze starym stanem. 
; Wszystkie rejestry (oprócz rax) nie są modyfkowane. 
; ##############################################################################
in_board_and_alive:
        push    rbp
        mov     rbp, rsp
        
        ; sprawdzanie czy komórka T[i][j] nie wychodzi poza planszę.
        cmp     rdi, 0          ; i >= 0
        jl      outside
        cmp     rdi, HEIGHT     ; i < HEIGHT
        jge     outside
        cmp     rsi, 0          ; j >= 0
        jl      outside
        cmp     rsi, WIDTH      ; j < WIDTH
        jge     outside
        ; T[i][j] jest wewnątrz planszy.
        
        mov     rax, rdi        ; kopiujemy współrzędną i do rax, żeby zachować rdi.
        imul    rax, WIDTH      
        add     rax, rsi        ; dodajemy do adresu współrzędną j.
        movsx   rax, dword [rax*4 + rdx]    ; kopiujemy wartość T[i][j] do rejestru rax.
        jmp     end
outside:
        mov     rax, qword 0    ; T[i][j] jest poza planszą.
end:     
        ; W rax jest teraz 0 gdy T[i][j] poza plaszą lub w komórce tablicy nie ma
        ; żywej istoty. 1 gdy w komórce tablicy jest żywa istota.
        mov     rsp, rbp
        pop     rbp
        ret
