assume cs:codesg
datasg segment
    db "Beginner's All-purpose Symbolic Instruction Code.",0
datasg ends

codesg segment

begin:
    mov ax,datasg
    mov ds,ax
    mov si,0
    call letterc

    mov ax,4c00h
    int 21h

letterc:    ;以0结尾的字符串中, 将字母小写转大写. 参数: ds, si
    
    ;额外使用的寄存器入栈

    ;主体
        letterc_s:

            cmp byte ptr ds:[si],0
            je letterc_ok
            cmp byte ptr ds:[si],'a'
            jb letterc_nextchar
            cmp byte ptr ds:[si],'z'
            ja letterc_nextchar
            
            sub byte ptr ds:[si],20h
            
            letterc_nextchar:
            inc si
            jmp letterc_s

        letterc_ok:

    ;额外使用的寄存器出栈

    ;结束
        ret


    

codesg ends
end begin