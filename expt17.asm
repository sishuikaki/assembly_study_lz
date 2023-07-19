assume cs:code
code segment

start:
    ;初始化
        mov ax,0b800h
        mov es,ax
        mov bx,0

    ;调用7ch
        mov al,8    ;4000字节需要8个扇区(8*512)
        mov dx,1442 ;从1442逻辑扇区开始写
        mov ah,1    ;写入到es:bx
        int 7ch

    ;结束
        mov ax,4c00h
        int 21h

code ends

end start