assume cs:code

code segment

start:
    ;安装7ch
        push cs
        pop ds
        mov si,offset lsec   ;Logical sector逻辑扇区, 和Logical volume简称lvol类似
        mov ax,0
        mov es,ax
        mov di,200h

        mov cx,offset lsec_end - offset lsec
        cld

        rep movsb

    ;设置中断向量表
        cli
        mov word ptr es:[7ch*4+2],0
        mov word ptr es:[7ch*4],200h
        sti

    ;结束
        mov ax,4c00h
        int 21h

lsec:
;==================================================
;
;作用: 将位于不同的磁道、面上的所以扇区统一编号
;   具体算法为: x面y道z扇区 对应 n逻辑扇区
;   x=n/1440, y=n%1440/18, z=n%1440%18+1
;   x∈[0,1] y∈[0,17] z∈[1,80]
;   n∈[0,2879]
;
;参数: ah, dx, es:bx
;   ah表示功能号, 0读, 1写
;   dx表示逻辑扇区号
;   es:bx指向存储读出数据或写入数据的内存区
;
;==================================================

    ;检测功能号是否大于1
        cmp ah,1
        ja lsec_ret

    ;寄存器入栈
        push ax
        push cx
        push dx

    ;主体

        ;目的: 求出n/1440面 n%1440/18道 n%1440%18+1扇区

        push ax     ;保存int 7ch功能号, 0读, 1写
        mov ax,dx
        mov dx,0    ;dx:ax=n
        mov cx,1440
        div cx      ;al=ax=n/1440, dx=n%1440

        push dx     ;保存n%1440

        mov dh,al   ;dh面
        mov dl,0    ;dl盘

        pop ax      ;ax=n%1440
        mov cl,18
        div cl      ;al=n%1440/18, ah=n%1440%18

        mov ch,al   ;ch道
        mov cl,ah
        inc cl      ;cl扇区

        pop ax      ;恢复int 7ch的功能号, 0读, 1写
        add ah,2    ;改为int 13h的功能号, 2读, 3写
        int 13h     ;dl盘dh面ch道cl扇区

    ;寄存器出栈
        pop dx
        pop cx
        pop ax

    lsec_ret:
    ;结束
        iret
        lsec_end:
        nop

code ends

end start
