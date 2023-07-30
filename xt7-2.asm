;文件名：xt7-2.asm
;文件说明：第7章习题第2题
         
        jmp near start
         
posi    db  'P',0x07,'o',0x07,'s',0x07,'i',0x07,'t',0x07,'i',0x07,'v',0x07,'e',0x07,':',0x07
posiend db  ' ',0x04
nega    db  'N',0x07,'e',0x07,'g',0x07,'a',0x07,'t',0x07,'i',0x07,'v',0x07,'e',0x07,':',0x07
negaend db  ' ',0x04
data1   db 0x05,0xff,0x80,0xf0,0x97,0x30                ;6个数
data2   dw 0x90,0xfff0,0xa0,0x1235,0x2f,0xc0,0xc5bc     ;7个数

start:
        mov ax,0x7c0                  ;设置数据段基地址
        mov ds,ax

        mov ax,0xb800                 ;设置附加段基地址
        mov es,ax

        cld
        mov si,posi                 
        mov di,0                       ;输出第一行文字
        mov cx,(posiend-posi)/2
        rep movsw

        cld
        mov si,nega                 
        mov di,160                     ;输出第二行文字
        mov cx,(negaend-nega)/2
        rep movsw

        xor ax,ax                       ;ax清0，用于保存正负数个数

        ;得到data1所代表的偏移地址
        mov bx,data1

        mov si,0
        xor dx,dx
        mov cx,6

data1cmp:                               ;计算data1的正数和负数个数
        mov dl,[bx+si]
        inc si
        cmp dl,0
        jg data1posi
        jl data1nega
        loop data1cmp                   ;循环判断正负
        jmp data1cmpover                ;结束跳出data1cmp
data1posi:
        inc ah                          ;ah保存正数个数
        loop data1cmp
        jmp data1cmpover
data1nega:
        inc al                          ;al保存负数个数
        loop data1cmp
data1cmpover:

        ;得到data2所代表的偏移地址
        mov bx,data2

        mov si,0
        xor dx,dx
        mov cx,7

data2cmp:                               ;计算data2的正数和负数个数
        mov dx,[bx+si]
        add si,2
        cmp dx,0
        jg data2posi
        jl data2nega
        loop data2cmp                   ;循环判断正负
        jmp data2cmpover                ;结束跳出data2cmp
data2posi:
        inc ah
        loop data2cmp
        jmp data2cmpover
data2nega:
        inc al
        loop data2cmp
data2cmpover:

show:
        add ax,0x3030                   ;将正数负数个数转换为字符
        mov di,0+posiend-posi
        mov [es:di],ah
        mov di,160+negaend-nega
        mov [es:di],al


        jmp near $

times 510-($-$$)    db 0
                    db 0x55,0xaa