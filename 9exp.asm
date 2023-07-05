assume cs:code

data segment
;无属性的字符串，总长16字节
db 'welcome to masm!'
data ends

pro segment
;绿色，绿底红色，白底蓝色
db 00000010b,00100100b,01110001b
pro ends

stack segment
;栈空间
db 16 dup (0)
stack ends

code segment

start:
    ;初始化
        mov ax,data
        mov ds,ax
        mov ax,0b800h
        mov es,ax
        mov ax,stack
        mov ss,ax
        mov sp,16


    ;s循环每一行
        mov bp,0        ;记录使用哪一个属性
        mov cx,3        ;共三行，第十二、十三、十四行
        mov bx,6e0h     ;第十二行，每次加一行
    s:  push cx
    ;改属性
        push ds
        mov ax,pro
        mov ds,ax
        mov dh,ds:[bp]  ;dh存放属性
        pop ds

        ;s0循环每个字
            mov si,0
            mov di,0
            mov cx,16
        s0: mov dl,ds:[si]  ;dl存放字符，此时dx存放着彩色字符
            mov es:[bx].64[di],dx   ;放在一行的中间，一行160字节，左右空出64字节，中间32字节放彩色字符
            inc si
            add di,2
            loop s0

        add bx,0a0h     ;切换下一行
        inc bp          ;切换属性
        pop cx
        loop s


    ;完成
        mov ax,4c00h
        int 21h
code ends
end start