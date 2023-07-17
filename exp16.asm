assume cs:code

code segment

start:
    ;安装int7ch
        mov ax,cs
        mov ds,ax
        mov si,offset int7ch

        mov ax,0
        mov es,ax
        mov di,200h

        mov cx,offset int7chend - offset int7ch
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

int7ch:
;==========================================================
;
;作用: 可以为显示输出提供如下功能
;   (1) 清屏
;   (2) 设置前景色
;   (3) 设置背景色
;   (4) 向上滚动一行
;
;参数: ah, al
;   功能号ah, 0清屏, 1设置前景色, 2设置背景色, 3向上滚动一行
;   颜色值al, 对于1和2号功能, 用al传送颜色值, 范围0-7
;
;==========================================================

    setscreen:  ;选择功能

            jmp short set

            dw offset sub1 - offset setscreen + 200h
            dw offset sub2 - offset setscreen + 200h
            dw offset sub3 - offset setscreen + 200h
            dw offset sub4 - offset setscreen + 200h
            ;这里不能照抄书本, 不能用table dw sub1-4
            ;因为这样记录的是安装程序运行时, sub1-4的偏移地址
            ;而不是程序安装在0:200后的偏移地址
            ;所以采用相对位移 + 绝对地址的形式

        set:
        ;保存使用的寄存器
            push bx

        ;主体
            cmp ah,3    ;判断功能号是否大于3
            ja sret

            mov bl,ah
            mov bh,0
            add bx,bx   ;计算子程序在table表中的偏移

            call word ptr cs:[bx+202h]      ;调用子程序
            ;202是因为jmp short set占了2字节
            ;这里不能照抄书本, 不能用table[bx]
            ;因为table指向的是安装程序运行时, table的偏移地址
            ;而不是程序在安装到0:200后的偏移地址
            
            sret:
        ;恢复使用的寄存器
            pop bx

        ;结束
            iret

    sub1:   ;清屏

        ;保存使用的寄存器
            push bx
            push es
            push cx
        

        ;主体
            mov bx,0b800h
            mov es,bx
            mov bx,0    ;改字符
            mov cx,2000 ;全屏25*80=2000字
            
            sub1_s:
            mov byte ptr es:[bx],' '    ;替换为空格
            add bx,2
            loop sub1_s

        ;恢复使用的寄存器
            pop cx
            pop es
            pop bx

        ;结束
            ret
    
    sub2:   ;设置前景色
    
        ;保存使用的寄存器
            push bx
            push es
            push cx
        ;主体
            mov bx,0b800h
            mov es,bx
            mov bx,1    ;改颜色
            mov cx,2000
            
            sub2_s:
            and byte ptr es:[bx],11111000b
            or es:[bx],al
            add bx,2
            loop sub2_s

        ;恢复使用的寄存器
            pop cx
            pop es
            pop bx

        ;结束
            ret
    
    sub3:   ;设置背景色

        ;保存使用的寄存器
            push bx
            push es
            push cx

        ;主体
            mov bx,0b800h
            mov es,bx
            mov cl,4
            shl al,cl   ;al左移4位, 以便设置背景色
            mov bx,1    ;改颜色
            mov cx,2000

            sub3_s:
            and byte ptr es:[bx],10001111b
            or es:[bx],al
            add bx,2
            loop sub3_s

        ;恢复使用的寄存器
            pop cx
            pop es
            pop bx

        ;结束
            ret
    
    sub4:   ;向上滚动一行

        ;保存使用的寄存器
            push si
            push di
            push es
            push ds
            push cx

        ;主体
            mov si,0b800h
            mov es,si
            mov ds,si
            mov si,160  ;ds:si指向第n+1行
            mov di,0    ;es:si指向第n行
            cld
            mov cx,24*160   ;共转移24(行)*160(列)个字节
            rep movsb

            mov cx,80
            mov si,0
            
            sub4_s1:
            mov byte ptr es:[si+24*160],' '
            add si,2
            loop sub4_s1

        ;恢复使用的寄存器
            pop cx
            pop ds
            pop es
            pop di
            pop si

        ;结束
            ret

    int7chend:
    nop

code ends

end start