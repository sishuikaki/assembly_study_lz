assume  cs:code

code segment

start:
    ;安装int 7ch中断例程, 显示字符串

        ;ds:si
            mov ax,cs
            mov ds,ax
            mov si,offset showstr

        ;es:di
            mov ax,0
            mov es,ax
            mov di,200h

        ;设置长度, 方向
            mov cx,offset showstr_end - offset showstr
            cld

        ;传输showstr
            rep movsb

    ;设置中断向量表
        mov ax,0
        mov es,ax
        mov word ptr es:[7ch*4+2],0
        mov word ptr es:[7ch*4],200h

    ;结束
        mov ax,4c00h
        int 21h
    
showstr:    ;显示一个用0结束的字符串. 参数: 行号dh, 列号dl, 颜色cl, ds:si指向字符串首地址 
    
    ;保存使用的寄存器
        push ax
        push es
        push bp
        push cx
        push di 

    ;主体
        mov ax,0b800h
        mov es,ax

        ;bp加上行偏移
            mov ax,160
            mul dh
            mov bp,ax

        ;bp加上列偏移
            mov ax,2
            mul dl
            add bp,ax
        
        ;al保存颜色
            mov al,cl

        ;初始化
            mov ch,0
            mov di,0

        ;显示字符串
            showstr_s:
            mov cl,ds:[si]
            jcxz showstr_ok
            mov es:[bp+di],cl       ;字符
            mov es:[bp+di+1],al     ;颜色
            inc si
            add di,2
            jmp showstr_s

            showstr_ok:

    ;恢复使用的寄存器
        pop di
        pop cx
        pop bp
        pop es
        pop ax

    ;结束
        iret

    showstr_end:
        nop

code ends

end start