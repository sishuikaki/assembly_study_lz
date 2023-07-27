assume cs:code
data segment
    db 'Welcom to masm!',0
data ends

stack segment
    db 16 dup (0)
stack ends

code segment
start:
    mov dh,8    ;行号
    mov dl,3    ;列号
    mov cl,2    ;颜色
    mov ax,data
    mov ds,ax
    mov ax,stack
    mov ss,ax
    mov sp,16
    mov si,0
    call show_str

    mov ax,4c00h
    int 21h

show_str:   ;显示字符串, 参数: dh, dl, cl, 返回: 无
        
    ;额外使用的寄存器入栈
    push ax
    push bx
    push cx
    push es
    push bp
    push di
    push si
    
    ;主体
    mov di,0
    mov al,dh
    mov bx,0a0h
    mul bl
    mov bp,0    ;bp初始为0
    mov bp,ax   ;bp加上行的偏移
    mov ax,0b800h
    mov es,ax
    mov ah,0
    mov al,dl
    mov bx,2
    mul bl
    add bp,ax   ;bp加上列的偏移
    mov ah,cl

    show_str_s:
    mov al,ds:[si]          ;循环字符串的每个字符
    push cx
    mov ch,0
    mov cl,al   ;如果al读到0就退出循环
    jcxz show_str_ok
    pop cx
    mov es:[bp+di],ax       ;循环显存上每个彩色字符
    inc si
    add di,2
    jmp show_str_s

    
    show_str_ok:
    pop cx      ;jcxz跳到这里后没有pop cx, 所以补上
    
    ;额外使用的寄存器出栈
    pop si
    pop di
    pop bp
    pop es
    pop cx
    pop bx
    pop ax

    ;结束
    ret

code ends

end start
