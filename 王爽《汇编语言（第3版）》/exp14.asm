assume cs:code

string segment
    db '00/00/00 00:00:00','$'
    ;年/月/日 时:分:秒
    ;偏移地址: 年:0 1, 月:3 4, 日:6 7, 时:9 a, 分:c d, 秒:f 10
string ends


code segment

unit:    db 9,8,7,4,2,0
;时间存放单元: 年:9 月:8 日:7 时:4 分:2 秒:0

start:
    ;初始化
        mov ax,string
        mov ds,ax
        
        mov ax,cs
        mov es,ax
        
        mov bx,offset unit
        mov cx,6

    ;把时间写入string段
        s:
        push cx
            
        ;从端口读取BCD码
            mov al,es:[bx]
            out 70h,al
            in al,71h

        ;处理ax
            mov ah,al
            mov cl,4
            shr ah,cl
            and al,00001111b
            
            add ah,30h
            add al,30h
        
        ;写入string
            mov [di],ah
            mov [di+1],al

        ;循环处理
            inc bx
            add di,3    ;年月日时分秒的起始地址都相差3字节
            pop cx
            loop s
    
    ;设置光标位置
        mov ah,2    ;置光标
        mov bh,0    ;第0页
        mov dh,12   ;行号
        mov dl,12   ;列号
        int 10h
    
    ;光标位置显示字符串
        mov dx,0    ;ds:dx指向字符串起始地址
        mov ah,9    ;在光标位置显示字符串
        int 21h
    
    ;结束
        mov ax,4c00h
        int 21h

code ends

end start
