assume cs:code

stack segment
    db 16 dup (0)
stack ends

code segment

start:

    ;初始化
        mov ax,stack
        mov ss,ax
        mov sp,16

    ;传送新的int9
        push cs
        pop ds
        mov si,offset int9
        
        mov ax,0
        mov es,ax
        mov di,204h

        mov cx,offset int9end - offset int9
        cld
        rep movsb

    ;保存旧的int9
        push es:[9*4]
        pop es:[200h]
        push es:[9*4+2]
        pop es:[202h]   

    ;设置中断向量表
        cli
        mov word ptr es:[9*4+2],0
        mov word ptr es:[9*4],204h
        sti
    
    ;结束
        mov ax,4c00h
        int 21h


int9:
;功能: 在DOS下, 按下"A"键后, 除非不再松开, 如果松开, 就显示满屏幕的"A", 其他的键照常处理

    ;保存使用的寄存器
        push ax
        push es
        push bx
        push cx

    ;主体
        in al,60h

        pushf
        call dword ptr cs:[200h]    ;此时cs=0

        cmp al,1eh+80h  ;'A'的断码=1eh+80h
        jne int9ret

        mov ax,0b800h
        mov es,ax
        mov bx,0
        mov cx,2000
        s:
        mov byte ptr es:[bx],'A'
        add bx,2
        loop s

        int9ret:

    ;恢复使用的寄存器
        pop cx
        pop bx
        pop es
        pop ax

    ;结束
        iret
        int9end:
        nop

code ends

end start
