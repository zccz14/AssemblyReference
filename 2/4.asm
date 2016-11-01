.model small
option casemap: none
.stack 52
.code
; f (n)
; recursive
; using ax, cx
f proc
  push bp
  mov bp, sp
  ; stack
  ; [bp+4]: n
  ; [bp+2]: caller IP
  ; [bp]: caller BP
  cmp word ptr [bp+4], 0
  jg f_B11
  f_B1D: ; default
    mov ax, 1
    jmp f_B1E
  f_B11:
    ; if n > 0
    mov cx, word ptr[bp+4]  ; cx = n
    dec cx                  ; cx = n - 1
    push cx                 ; push arg (n - 1)
    call f                  ; ax = f(n - 1)
    pop cx                  ; pop arg (n)
    inc cx                  ; cx = n
    mul cx                  ; ax *= n
  f_B1E:
  pop bp
  ret
f endp

main proc far
  mov cx, 8
  push cx
  call f ; ax = f(8) = 9D80H
  pop cx
  
  mov ax, 4c00h
  int 21h
  ret
main endp
end main
