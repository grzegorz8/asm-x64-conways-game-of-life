section .text
    global check_sse

check_sse:
    push    rbp
    mov     rbp, rsp
   
    push    rbx

    ; Sprawdzamy dostępność sse, sse2.
    ; sse  - 25. bit rejestru edx.
    ; sse2 - 26. bit rejestru edx.

    mov     eax, 1
    cpuid
    ; sse
    test    edx, 0x2000000  ; 25. bit
    jz      not_supported
    
    ; sse2
    test    edx, 0x4000000  ; 26. bit
    jz      not_supported

    ; sse i sse2 są wspierane.
    mov     rax, qword 1
    jmp     check_end
not_supported:
    ; sse lub sse2 nie jest wspierane.
    mov     rax, qword 0
check_end:
    pop     rbx
    mov     rsp, rbp
    pop     rbp
    ret
