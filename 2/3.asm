.model small
option casemap: none

;size = 18 = max using(14) + reversed(4)
.stack 18
.data
arr dw 78, 92, 85, 62, 45, 90, 66, 74, 88, 100
avg dw ?
.code

; summary (*data, n)
; using ax, dx, si
sum proc
  push bp
  mov bp, sp
  sub sp, 4 ; allocate for local variable
  ; stack
  ; [bp+6]: the length of data (n)
  ; [bp+4]: address of data
  ; [bp+2]: the old IP register
  ; [bp]: the old BP register
  ; [bp-2]: the summary
  ; [sp=bp-4]: counter i
  mov word ptr [bp-2], 0 ; ret = 0
  mov word ptr [bp-4], 0 ; i = 0
  sum_L1S:
    mov ax, word ptr [bp-4] ; ax = i
    cmp ax, word ptr [bp+6] ; if ax >= n break
      jge sum_L1E
    
    mov ax, word ptr [bp-4] ; ax = i
    mov dx, ax
    add dx, ax              ; dx = i * sizeof(dw)
    mov ax, word ptr [bp+4] ; ax = &data
    add ax, dx              ; ax = &data[i]
    mov si, ax
    mov ax, word ptr [si]   ; ax = data[i]
    
    add word ptr [bp-2], ax ; ret += data[i]
    
    inc word ptr [bp-4]     ; i++

    jmp sum_L1S
  sum_L1E:
  
  mov ax, word ptr [bp-2] ; ax = ret
  
  add sp, 4 ; free local variable
  pop bp
  ret
sum endp

; sort (*data, n)
; using ax, dx, si, di
sort proc
  push bp
  mov bp, sp
  sub sp, 6
  ; stack
  ; [bp+6]: the length of data (n)
  ; [bp+4]: the address of data
  ; [bp+2]: the old IP register
  ; [bp]: the old BP register
  ; [bp-2]: the counter i
  ; [bp-4]: the counter j
  ; [bp-6]: the variable x
  mov word ptr [bp-2], 1  ; i = 1
  sort_L1S:
    mov ax, word ptr [bp-2] ; ax = i
    
    cmp ax, word ptr [bp+6] ; if i >= n break
      jge sort_L1E

    mov ax, word ptr [bp-2] ; ax = i
    mov dx, ax
    add dx, ax              ; dx = i * sizeof(dw)
    mov ax, word ptr [bp+4] ; ax = data
    add ax, dx              ; ax = &data[i]
    mov si, ax
    mov ax, word ptr [si]   ; ax = data[i]
    mov word ptr [bp-6], ax ; x = data[i]
    
    mov ax, word ptr [bp-2] ; ax = i
    dec ax                  ; ax = i - 1
    mov word ptr [bp-4], ax ; j = i - 1
    
    sort_L2S:
      cmp word ptr [bp-4], 0 ; if j < 0 break
        js sort_L2E

      mov ax, word ptr [bp-4] ; ax = j
      mov dx, ax
      add dx, ax              ; dx = j * sizeof(dw)
      mov ax, word ptr [bp+4] ; ax = data
      add ax, dx              ; ax = &data[j]
      mov si, ax
      mov ax, word ptr [si]   ; ax = data[j]
      
      cmp ax, word ptr [bp-6] ; if data[j] <= x break
        jle sort_L2E
      
      mov ax, word ptr [bp-4] ; ax = j
      inc ax                  ; ax = j + 1
      mov dx, ax
      add dx, ax              ; dx = (j + 1) * sizeof(dw)
      mov ax, word ptr [bp+4] ; ax = data
      add ax, dx              ; ax = &data[j + 1]
      mov di, ax              ; dx = &data[j + 1]
      
      ; trick
      sub ax, 2               ; ax = &data[j]
      mov si, ax
      mov ax, word ptr [si]   ; ax = data[j]
      mov word ptr [di], ax   ; data[j + 1] = data[j]
      
      dec word ptr [bp-4]     ; j--

      jmp sort_L2S
    sort_L2E:
    
    mov ax, word ptr [bp-4] ; ax = j
    inc ax                  ; ax = j + 1
    mov dx, ax
    add dx, ax              ; dx = (j + 1) * sizeof(dw)
    mov ax, word ptr [bp+4] ; ax = data
    add ax, dx              ; ax = &data[j + 1]
    mov di, ax              ; di = &data[j + 1]
    
    mov ax, word ptr [bp-6] ; ax = x
    mov word ptr [di], ax   ; data[j + 1] = x
    
    inc word ptr [bp-2]     ; i++
    
    jmp sort_L1S
  sort_L1E:
  
  add sp, 6 ; free local variable
  pop bp    ; restore BP
  ret
sort endp


main proc far
  mov ax, @data
  mov ds, ax
  ; push arguments (arr, 10)
  mov ax, 10
  push ax
  mov ax, offset arr
  push ax

  call sum ; ax = sum
  ; ax /= 10
  mov dx, 0
  mov bx, 10
  div bx
  
  lea bx, avg
  mov [bx], ax ; store avg

  call sort ; just using the same arguments
  add sp, 4 ; pop arguments or not

  mov ax, 4c00h
  int 21h
  ret
main endp

end main
