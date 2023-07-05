assume cs:codesg,ds:data,es:table,ss:stack

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

    db 21 dup ('year summ ne ?? ')  

table ends

stack segment

    db 16 dup (0)

stack ends

codesg segment

start:
    ;初始化
        mov ax,data
        mov ds,ax
        mov ax,table
        mov es,ax
        mov ax,stack
        mov ss,ax
        mov cx,21
        mov bx,0
        mov bp,0
        mov di,0

    s:  push cx
        mov cx,4
        mov si,0

    ;填入年份
    s1: mov dh,0
        mov dl,ds:0[bp][si]
        mov es:[bx].0[si],dl
        inc si
        loop s1

    ;填入收入
        mov dx,ds:84[bp]
        push dx
        mov es:[bx].5,dx   ;放低位
        mov dx,ds:84[bp+2]
        push dx
        mov es:[bx].7,dx   ;放高位

    ;填入雇员数
        mov dx,ds:168[di]
        mov es:[bx].0ah,dx

    ;计算人均收入
        pop dx
        pop ax
        div word ptr es:[bx].0ah
        mov es:[bx].0dh,ax

    ;结尾操作
        add di,2
        add bp,4
        add bx,10h
        pop cx

        loop s


        mov ax,4c00H
        int 21H

codesg ends

end start