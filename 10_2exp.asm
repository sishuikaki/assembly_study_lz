assume cs:code

stack segment
    db 16 dup (0)
stack ends

code segment
start:
    mov ax,stack
    mov ss,ax
    mov sp,16
    mov ax,4240h
    mov dx,000fh
    mov cx,0ah
    call divdw

    mov ax,4c00h
    int 21h

divdw:  ;双字除法, 参数: ax, dx, cx, 返回: ax, dx, cx

    ;额外使用的寄存器入栈
    push bx
    
    ;计算H/N
    push ax ;保存L, X的低位
    
    mov ax,dx
    mov dx,0
    div cx  ;H/N, ax为商, dx为H/N余数
    
    mov bx,ax ;保存H/N商

    pop ax  ;设置ax为L, X的低位

    div cx  ;[rem(H/N)*10000h+L]/N, ax为商, 也是X/N低位, dx为余数, 也是X/N余数

    mov cx,dx   ;cx存放余数
    mov dx,bx   ;dx存放高位
    
    ;额外使用的寄存器出栈
    pop bx

    ;结束
    ret

code ends

end start
