assume cs:code

data segment

    db '1975','1976','1977','1978','1979','1980','1981','1982','1983'  

    db '1984','1985','1986','1987','1988','1989','1990','1991','1992'  

    db '1993','1994','1995' 

    ;以上是表示21年的21个字符串

    dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514  

    dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000  

    ;以上是表示21年 公司总收入的21个dword型数据

    dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226  

    dw 11542,14430,15257,17800

    ;以上是表示21公司雇员人数的21个Word型数据。

data ends

table segment
    db 21 dup ('year',0,'summ',0,'ne',0,'??',0)
table ends

stack segment
    db 32 dup (0)
stack ends

string segment  ;用来存放show_str将要显示的字符串
    db 16 dup (0)
string ends

code segment

start:

    ;把data段按照格式写入table段, table段中, year为字符串, 其他都为16进制数据
        call _7exp_start

    ;初始化
        mov ax,table
        mov ds,ax
        mov ax,stack
        mov ss,ax
        mov sp,32
        mov ax,string
        mov es,ax

    ;循环显示table的每一行
        
        ;初始化
            mov dh,4            ;从第4行开始
            mov bp,0            ;从table:0开始读取
            mov cx,21           ;循环21行
        
        ;循环每一行
        s:
            push cx

            ;显示year字符串
                ;table段的year搬运到string段
                    mov si,0    ;第0列开始, 即年份所在的列
                    mov cx,4    ;搬4个字节
                    year_s:
                    mov al,ds:[bp+si]
                    mov es:[si],al
                    inc si
                    loop year_s
                    mov byte ptr es:[si],0  ;将string结尾设置为0

                ;调用show_str显示字符串
                    mov dl,0            ;从第0列开始显示year年份
                    call call_show_str
                    

            ;显示summ收入
                ;table段的summ转化为字符串到string段中
                    push dx
                    push ds

                    mov si,5        ;第5列开始, 即收入所在的列
                    mov ax,ds:[bp+si]   ;ax存低位
                    mov dx,ds:[bp+si+2] ;dx存高位
                    
                    push bx
                    push si
                    mov bx,string
                    mov ds,bx
                    call dtoc       ;把summ收入以十进制字符串形式保存在string段中
                    pop si
                    pop bx

                    pop ds
                    pop dx

                ;调用show_str显示字符串
                    mov dl,20            ;从第20列开始显示summ收入
                    call call_show_str

            ;显示ne雇员数
                ;table段的ne转化为字符串到string段中
                    push dx
                    push ds

                    mov si,0ah        ;第0ah列开始, 即雇员数所在的列
                    mov ax,ds:[bp+si]   ;ax存雇员数
                    mov dx,0            ;dx恒为0
                    
                    push bx
                    push si
                    mov bx,string
                    mov ds,bx
                    call dtoc       ;把ne雇员数以十进制字符串形式保存在string段中
                    pop si
                    pop bx

                    pop ds
                    pop dx
                ;调用show_str显示字符串
                    mov dl,40            ;从第40列开始显示ne雇员数
                    call call_show_str


            ;显示??人均收入
                ;table段的??转化为字符串到string段中
                    push dx
                    push ds

                    mov si,0dh        ;第0dh列开始, 即人均收入所在的列
                    mov ax,ds:[bp+si]   ;ax存人均收入
                    mov dx,0            ;dx恒为0
                    
                    push bx
                    push si
                    mov bx,string
                    mov ds,bx
                    call dtoc       ;把??人均收入以十进制字符串形式保存在string段中
                    pop si
                    pop bx

                    pop ds
                    pop dx
                ;调用show_str显示字符串
                    mov dl,60            ;从第60列开始显示??人均收入
                    call call_show_str


        inc dh      ;切换显示的下一行
        add bp,10h  ;切换table下一行
        pop cx
        loop s
    
    mov ax,4c00h
    int 21h


dtoc:   ;双字数据转化为字符串, 参数: 低位ax, 高位dx, 字符串段ds, 字符串首偏移地址si, 返回: 无
    
    ;额外使用的寄存器入栈
        push cx
        push di
        push bx

    ;主体
        mov di,0
        mov bx,0    ;bx用于记录字符串长度

        dtoc_s: ;双字数据转化成字符串
            mov cx,10   ;循环除以10
            call divdw  ;ax为低位,dx为高位,cx是余数
            
            push cx     ;将此时的余数入栈
            inc bx
            mov cx,ax
            jcxz dtoc_s_ax0   ;如果ax=0, 验证dx是否为0       
            jmp dtoc_s
            
            dtoc_s_ax0:
            mov cx,dx       ;验证dx
            jcxz dtoc_ok   ;如果ax=0, dx=0, 跳出循环
            jmp dtoc_s
        
        dtoc_ok:

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

    ;结束
        ret

call_show_str:  ;调用show_str. 年份, 收入, 雇员数, 人均收入调用show_str都是一样的指令
    push ds
    push si
    
    mov ax,string
    mov ds,ax   ;把ds改成string段的, 然后显示
    mov si,0
    mov cl,00000111b    ;颜色为黑底白字
    call show_str   ;显示字符串
    
    pop si
    pop ds
    
    ret

divdw:  ;双字除法, 参数: 低位ax, 高位dx, 除数cx, 返回: 低位ax, 高位dx, 余数cx

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

show_str:   ;显示字符串, 参数: 行号dh, 列号dl, 颜色cl,要显示的字符串所在的段ds, 返回: 无
        
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

_7exp_start: ;把data段的数据写入到table段, 参数: 无, 返回: 无
    
    ;把额外使用的寄存器入栈
        push ax
        push ds
        push es
        push cx
        push bx
        push bp
        push di
        push si
        push dx

    ;初始化
        mov ax,data
        mov ds,ax
        mov ax,table
        mov es,ax
        mov cx,21
        mov bx,0
        mov bp,0
        mov di,0

    _7exp_s:  
        push cx
        mov cx,4
        mov si,0

    ;填入年份
    _7exp_s1: 
        mov dh,0
        mov dl,ds:0[bp][si]
        mov es:[bx].0[si],dl
        inc si
        loop _7exp_s1

    ;填入收入, 以16进制保存
        mov dx,ds:84[bp]
        push dx
        mov es:[bx].5,dx   ;放低位
        mov dx,ds:84[bp+2]
        push dx
        mov es:[bx].7,dx   ;放高位

    ;填入雇员数, 以16进制保存
        mov dx,ds:168[di]
        mov es:[bx].0ah,dx

    ;计算人均收入, 以16进制保存, 舍去余数(向下取整)
        pop dx
        pop ax
        div word ptr es:[bx].0ah
        mov es:[bx].0dh,ax

    ;结尾操作
        add di,2
        add bp,4
        add bx,10h
        pop cx

        loop _7exp_s
    
    ;把额外使用的寄存器出栈
        pop dx
        pop si
        pop di
        pop bp
        pop bx
        pop cx
        pop es
        pop ds
        pop ax

    ;结束
        ret

code ends

end start
