        ;文件名：xt8-2.asm
        ;文件说明：第8章习题第2题

        jmp near start

message db '1+2+3+...+1000='
    
start:
        mov ax,0x7c0           ;设置数据段的段基地址
        mov ds,ax

        mov ax,0xb800          ;设置附加段基址到显示缓冲区
        mov es,ax

        ;以下显示字符串 
        mov si,message          
        mov di,0
        mov cx,start-message
    @g:
        mov al,[si]
        mov [es:di],al
        inc di
        mov byte [es:di],0x07
        inc di
        inc si
        loop @g

        ;以下计算1到1000的和
        xor dx,dx
        xor ax,ax
        mov cx,1000
    @f:
        add ax,cx
        adc dx,0                ;dx保存高16位，ax保存低16位
        loop @f

        ;以下计算累加和的每个数位 
        xor cx,cx              ;设置堆栈段的段基地址
        mov ss,cx
        mov sp,cx

        mov bx,10
        xor cx,cx
    @d:
        inc cx
        div bx
        or dl,0x30
        push dx
        xor dx,dx               ;与c08_mbr.asm相比，将xor dx,dx移后到这里，因为第一次除以10时高16位dx不为0
        cmp ax,0
        jne @d

        ;以下显示各个数位 
    @a:
        pop dx
        mov [es:di],dl
        inc di
        mov byte [es:di],0x07
        inc di
        loop @a
    
        jmp near $ 
    

times 510-($-$$) db 0
                db 0x55,0xaa