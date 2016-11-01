.model small
option casemap: none

.stack 14
.code
; f (n)
; using 
f proc
  push bp
  mov bp, sp
  sub sp, 4
  ; stack
  ; [bp+4]: arg n
  ; [bp+2]: caller IP
  ; [bp]: caller BP
  ; [bp-2]: counter i
  ; [bp-4]: the value to return
  mov word ptr [bp-2], 0
  mov word ptr [bp-4], 0
  f_L1S:
    cmp word ptr [bp-2], 16 ; if i >= 16 break
    jge f_L1E
    
    mov ax, word ptr [bp+4] ; ax = n
    and ax, 1               ; ax = n & 1
    xor ax, 1               ; ax = 1 - (n & 1)
    add word ptr [bp-4], ax ; ret += 1 - (n & 1)
    shr word ptr [bp+4], 1  ; n >>= 1

    inc word ptr [bp-2]     ; i++
    jmp f_L1S
  f_L1E:
  mov ax, word ptr [bp-4]

  add sp, 4
  pop bp
  ret
f endp
main proc far
  mov ax, 6
  push ax
  call f

  mov ax, 4c00h
  int 21h
  ret
main endp
end main
