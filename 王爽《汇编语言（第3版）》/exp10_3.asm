assume cs:code

data segment
    dw 123,12666,1,8,3,38
data ends

string segment
    ;用来存放show_str将要显示的字符串
    db 16 dup (0)
string ends

stack segment
    db 32 dup (0)
stack ends

code segment
start:
    ;初始化
    mov ax,data
    mov ds,ax
    mov ax,stack
    mov ss,ax
    mov sp,16
    
    mov si,0    ;从data段的第一个数字开始
    mov cx,6    ;共6个数字要转化显示
    mov dh,8    ;从第8行开始显示

    s:  
        push cx
        ;转化显示
        ;转化
        mov ax,ds:[si]
        push ds
        mov bx,string
        mov ds,bx
        call dtoc   ;数据转化为字符串, 字符串存放在string段中
        pop ds

        ;显示
        mov dl,3    ;第三列
        mov cl,2    ;绿色
        push ds
        mov ax,string
        mov ds,ax   ;把ds改成string段的, 然后显示
        push si
        mov si,0
        call show_str   ;显示字符串
        pop si
        pop ds

        inc dh      ;切换下一行
        add si,2    ;切换下一个数字
        pop cx
        loop s

    mov ax,4c00h
    int 21h

dtoc:   ;数据转化为字符串, 参数: 字型数据ax, 字符串段ds, 字符串首偏移地址si, 返回: 无

    ;额外使用的寄存器入栈
        push dx
        push cx
        push di
        push bx

    ;主体
        mov di,0
        mov dx,0    ;dx存放高位, 恒为0, ax是低位
        mov bx,0    ;bx用于记录字符串长度

    dtoc_s: ;数字转化成字符串
        mov cx,10   ;除数
        call divdw  ;ax是商, ax只要不是0就要一直被除, dx是0, cx是余数
        
        push cx
        inc bx
        mov cx,ax
        jcxz dtoc_ok    ;ax为0就跳出循环
        jmp dtoc_s

    dtoc_ok:    ;将字符串从栈移到string段中
        mov cx,bx   ;cx改为字符串长度,用于控制循环
        dtoc_ok_s:  ;依次存入字符
            
            pop bx      ;bx存放字符
            add bx,30h
            mov ds:[di],bl
            
            inc di
            loop dtoc_ok_s
        mov byte ptr ds:[di],0    ;字符串结尾改成0

    ;额外使用的寄存器出栈
        pop bx
        pop di
        pop cx
        pop dx
    
    ;结束
        ret

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
