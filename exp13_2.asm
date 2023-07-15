assume cs:code

code segment

start:
    ;安装int 7ch中断例程, 

        ;ds:si
            mov ax,cs
            mov ds,ax
            mov si,offset lp

        ;es:di
            mov ax,0
            mov es,ax
            mov di,200h

        ;设置长度, 方向
            mov cx,offset lp_end - offset lp
            cld

        ;传输lp
            rep movsb

    ;设置中断向量表
        mov ax,0
        mov es,ax
        mov word ptr es:[7ch*4+2],0
        mov word ptr es:[7ch*4],200h

    ;结束
        mov ax,4c00h
        int 21h

lp: ;实现loop指令的功能. 参数: 循环次数cx, 位移bx
    
    ;保存使用的寄存器
        push bp

    ;主体
        lp_s:
        mov bp,sp
        dec cx
        jcxz lp_ok
        add [bp+2],bx
        lp_ok:

    ;恢复使用的寄存器
        pop bp

    ;结束
        iret

    lp_end:
        nop

code ends

end start
