assume cs:installseg
installseg segment

install:
    mov ax,bootloader   ;安装引导程序
    mov es,ax
    mov bx,0

    mov ah,3    ;读磁盘
    mov al,1    ;引导程序小于512字节
    mov ch,0    ;0磁道
    mov cl,1    ;1扇区
    mov dh,0    ;0面
    mov dl,0    ;A盘
    int 13h

    mov ax,code         ;安装任务程序
    mov es,ax
    mov bx,0

    mov ah,3    ;写磁盘
    mov al,17   ;
    mov ch,0    ;0磁道
    mov cl,2    ;2扇区开始
    mov dh,0    ;0面
    mov dl,0    ;A盘
    int 13h

    mov ax,4c00h
    int 21h

installseg ends

assume cs:bootloader
bootloader segment  ;引导程序会被int 19h装载到0:7c00h

    mov ax,2000h
    mov ss,ax
    mov sp,0    ;2000:0前面是栈
    
    mov ax,2000h
    mov es,ax
    mov bx,0   ;2000:0后面是程序

    mov ah,2    ;读磁盘
    mov al,17   ;
    mov ch,0    ;0磁道
    mov cl,2    ;2扇区开始
    mov dh,0    ;0面
    mov dl,0    ;A盘
    int 13h

    ;jmp bootloader_go
    ;code_addr dw 7e00h,0
    ;bootloader_go:
    ;jmp dword ptr code_addr

    mov ax,2000h
    push ax
    mov ax,0
    push ax
    retf

bootloader ends

assume cs:code
code segment

    jmp start

main0       db  "Please select a function:","$"
main1       db  "1) reset pc","$"
main2       db  "2) start system","$"
main3       db  "3) clock","$"
main4       db  "4) set clock","$"
main5       db  "please input 1-4 to select:"
main5end    db  "$"
error       db  "error!",0dh,0ah,"Please input 1, 2, 3 or 4!","$"
retype      db  "      ","$"

tipstr      db  "F1: Turn color    Esc: Return to the main menu","$"

fun4text    db  "Please enter a string to change the system time.",0dh,0ah
            db  "The format should be ",22h,"YY MM DD HH mm ss",22h,".",0dh,0ah
            db  "For examle, enter 23 01 01 17 00 00 stand for Jan 1st, 2023, 17:00:00",0dh,0ah
line3       db  "Please enter:"
line3end    db  "$"
charstack   db  32 dup (" ")    ;以一个字节为单位的栈
            db "$"

start:
    ;安装int 9并初始化

        ;安装int 9
        push cs
        pop ds
        mov si,offset f1esc
        mov ax,0
        mov es,ax
        mov di,204h
        cld
        mov cx,offset f1escend - offset f1esc
        rep movsb

        ;保存原int 9中断向量
        push es:[9*4+2]
        pop es:[202h]
        push es:[9*4]
        pop es:[200h]

        mov ax,cs
        mov ds,ax

    cycle:
    ;显示界面
        call mainmenu   ;main menu

    ;选择功能
        call selfun     ;select function

    ;执行功能
        call execfun    ;execute function

    ;再次循环
        jmp cycle

mainmenu:   ;显示界面
    jmp mainmenu_start

    mainmenuTable dw main0,0,main1,1,main2,2,main3,3,main4,4,main5,5

    mainmenu_start:
    ;入栈
        push ax
        push ds
        push cx
        push bx
        push dx

    ;主体
        call cls    ;清屏

        mov cx,6
        mov bx,0
        mainmenu_s:
        push bx

        mov ax,mainmenuTable[bx]
        push ax     ;保存字符串地址
        mov ax,mainmenuTable[bx+2]
        push ax     ;保存行号

        mov bh,0    ;第0页
        pop dx
        mov dh,dl   ;dh为行号
        mov dl,0    ;列号
        mov ah,2    ;置光标
        int 10h

        pop dx      ;ds:dx指向字符串
        mov ah,9    ;显示$结尾的字符串
        int 21h

        pop bx
        add bx,4
        loop mainmenu_s


    ;出栈
        pop dx
        pop bx
        pop cx
        pop ds
        pop ax

    ;结束
        ret

cls:   ;清屏

    ;保存使用的寄存器
        push bx
        push es
        push cx
    

    ;主体
        mov bx,0b800h
        mov es,bx
        mov bx,0    ;改字符
        mov cx,2000 ;全屏25*80=2000字
        
        cls_s:
        mov byte ptr es:[bx],' '    ;替换为空格
        mov byte ptr es:[bx+1],7    ;黑底白字
        add bx,2
        loop cls_s

    ;恢复使用的寄存器
        pop cx
        pop es
        pop bx

    ;结束
        ret

selfun: ;选择功能. 返回: 功能号ax
    jmp selfun_start
    
    input dw 0      ;保存输入

    selfun_start:
    ;入栈
        push bx
        push es
        push cx
        push dx

    ;主体
        selfun_getchar:
        mov ah,0
        int 16h

        ;小于20h不是字符
        cmp al,20h
        jb selfun_notchar

        selfun_inputagain:
        ;是否为1-4
        cmp al,'1'
        jb selfun_invaild
        cmp al,'4'
        ja selfun_invaild

        ;显示字符
        mov input,ax    ;保存输入
        mov ah,9        ;在光标位置显示字符
        mov bl,00000111b    ;颜色属性
        mov bh,0            ;第0页
        mov cx,1
        int 10h
        
        jmp selfun_getchar

        selfun_notchar:
        ;输入回车确认
        cmp ah,1ch
        je selfun_enter
        jmp selfun_getchar

        selfun_enter:
        mov ax,input
        jmp selfun_ret

        selfun_invaild:
        mov dx,offset error
        mov ah,9
        int 21h     ;输出error

        mov ah,2
        mov bh,0
        mov dh,5
        mov dl,offset main5end - offset main5
        int 10h     ;置光标

        mov ah,0
        int 16h     ;读取输入

        push ax

        mov ah,9
        mov dx,offset retype
        int 21h     ;清除"error!"

        mov ah,2
        mov bh,0
        mov dh,5
        mov dl,offset main5end - offset main5
        int 10h     ;再次置回光标

        pop ax
        jmp selfun_inputagain
        


        selfun_ret:
    ;出栈
        pop dx
        pop cx
        pop es
        pop bx

    ;结束
        ret

execfun:    ;执行功能. 参数: 功能号ax
    cmp al,'1'
    je fun1
    cmp al,'2'
    je fun2
    cmp al,'3'
    je execfun_call3
    cmp al,'4'
    je execfun_call4

    ret

    execfun_call3:
    call fun3
    ret
    execfun_call4:
    call fun4
    ret

fun1:
    jmp fun1_start

    reboot dw 0,0ffffh

    fun1_start:
    call cls
    cli
    jmp dword ptr reboot

fun2:
    call cls
    cli
    int 19h

fun3:
    jmp fun3_start

    fun3_string db  '00/00/00 00:00:00','$'
    fun3_unit   db  9,8,7,4,2,0

    fun3_start:
    ;寄存器入栈
        push bx
        push di
        push cx
        push ax
        push dx
        push si ;_esc返回值

    ;初始化
        call cls
        call tips
        mov si,1
        call setint9
    
    fun3_cycle:
    ;无尽循环开始
        mov bx,0
        mov di,0
        mov cx,6

    ;把时间写入string段
        s:
        push cx
        ;从端口读取BCD码
            mov al,fun3_unit[bx]
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
            mov fun3_string[di],ah
            mov fun3_string[di+1],al

        ;循环处理
            inc bx
            add di,3    ;年月日时分秒的起始地址都相差3字节
            pop cx
            loop s

    ;设置光标位置
        mov ah,2    ;置光标
        mov bh,0    ;第0页
        mov dh,12   ;行号
        mov dl,31   ;列号
        int 10h
    
    ;光标位置显示字符串
        push ds
        push cs
        pop ds
        mov dx,offset fun3_string   ;ds:dx指向字符串起始地址
        mov ah,9                    ;在光标位置显示字符串
        int 21h
        pop ds

    cmp si,0
    je fun3_ret
    jmp fun3_cycle

    fun3_ret:
    ;恢复寄存器
        pop si
        pop dx
        pop ax
        pop cx
        pop di
        pop bx
    
    ;结束
        ret
fun4:
    jmp fun4_start

    fun4_unit   db  9,8,7,4,2,0

    fun4_start:
    ;保存寄存器
        push bx
        push dx
        push ax
        push si
        push di
        push cx

    ;显示文本提示
        call cls

        mov bh,0    ;第0页
        mov dh,0    ;dh为行号
        mov dl,0    ;列号
        mov ah,2    ;置光标
        int 10h

        mov dx,offset fun4text  ;ds:dx指向字符串
        mov ah,9                ;显示$结尾的字符串
        int 21h

    ;清空字符栈缓存
        mov cx,32
        mov bx,0                ;bx存储栈顶
        mov si,offset charstack ;ds:si指向字符栈起始地址
        fun4_clearchar:
        mov byte ptr [si][bx],' '
        inc bx
        loop fun4_clearchar

    ;读取输入
        mov bx,0                ;bx存储栈顶
        fun4_chars:
        mov ah,0
        int 16h
        
        ;小于20h舍去
        cmp al,20h
        jb fun4_notchar

        ;字符入栈并显示
        call fun4_charpush
        call fun4_charshow

        jmp fun4_chars

        fun4_notchar:
        cmp ah,0eh  ;退格
        je fun4_notchar_backspace
        cmp ah,1ch  ;回车
        je fun4_notchar_enter
        jmp fun4_chars

        fun4_notchar_backspace:
        ;字符出栈并显示
        call fun4_charpop
        call fun4_charshow
        jmp fun4_chars

        fun4_notchar_enter:
        mov al,0
        call fun4_charpush
        call fun4_charshow

    ;写入时间
        mov bx,0
        mov di,0
        fun4_chtime_s:
        mov al,[si][bx]     ;十位
        cmp al,'0'
        jb fun4_chtime_notnum
        cmp al,'9'
        ja fun4_chtime_notnum
        mov ah,[si][bx+1]   ;个位
        
        sub ax,3030h
        mov cl,4
        shl al,cl       ;十位放高4位
        or ah,al       ;ah暂时放BCD码

        mov al,fun4_unit[di]    ;al放要访问的单元号
        out 70h,al
        mov al,ah
        out 71h,al

        inc di
        add bx,2
        cmp di,6
        ja fun4_chtime_over
        cmp bx,32
        ja fun4_chtime_over

        fun4_chtime_notnum:
        inc bx
        cmp bx,31
        ja fun4_chtime_over
        jmp fun4_chtime_s

        fun4_chtime_over:

    ;恢复寄存器
        pop cx
        pop di
        pop si
        pop ax
        pop dx
        pop bx

    ;结束
        ret
tips:   ;fun3底下的提示
    ;保存寄存器
        push ax
        push bx
        push dx

    ;主体
        mov bh,0    ;第0页
        mov dh,24   ;dh为行号
        mov dl,0    ;列号
        mov ah,2    ;置光标
        int 10h

        mov dx,offset tipstr    ;ds:dx指向字符串
        mov ah,9                ;显示$结尾的字符串
        int 21h
    
    ;恢复寄存器
        pop dx
        pop bx
        pop ax

    ;结束
        ret

setint9: ;设置新的int 9中断向量

    ;主体
        ;设置中断向量
        mov word ptr es:[9*4+2],0
        mov word ptr es:[9*4],204h

    ;结束
        ret

f1esc:   ;改变颜色&回到主菜单, 返回: _esc的返回值si
    
    ;保存寄存器
        push ax
        push bx
        push cx
        push es

    ;主体
        in al,60h

        pushf
        call dword ptr cs:[200h]

        cmp al,3bh+80h
        je short f1
        cmp al,1+80h
        je short _esc
    
        f1esc_ret:
    
    ;恢复寄存器
        pop es
        pop cx
        pop bx
        pop ax

    ;结束
        iret

    f1:
        ;改12行31列开始的时间显示颜色
        mov bx,0b800h
        mov es,bx
        mov bx,12*160+31*2+1
        mov cx,17
        f1_s:
        inc byte ptr es:[bx]
        add bx,2
        loop f1_s
        jmp short f1esc_ret
    
    _esc:
        ;还原旧int 9中断向量
        mov word ptr es:[9*4+2],0
        mov word ptr es:[9*4],204h

        ;设置返回值si=0, 使无尽循环停止
        mov si,0
        jmp short f1esc_ret

    f1escend:
        nop


;================fun4及其子函数说明=================
 ;
 ;fun4_charpush, fun4_charpop, fun4_charshow
 ;
 ;作用: 分别为字符入栈, 字符出栈, 显示字符
 ;
 ;参数: ds:si, al, bx
 ;  ds:si指向字符栈起始地址
 ;  al表示字符
 ;  bx存储栈顶
 ;
;==================================================
fun4_charpush:

    ;主体
        cmp bx,32
        ja fun4_charpush_ret
        mov [si][bx],al
        inc bx

        fun4_charpush_ret:

    ;结束
        ret

fun4_charpop:

    ;主体
        cmp bx,0
        je fun4_charpop_ret
        dec bx
        mov byte ptr [si][bx],' '

        fun4_charpop_ret:

    ;结束
        ret

fun4_charshow:

    ;保存寄存器
        push bx
        push dx

    ;主体
        cmp bx,32
        ja fun4_charshow_ret
        
        mov dx,offset charstack ;ds:dx指向字符串
        mov ah,9
        int 21h

        mov ah,2
        mov bh,0
        mov dh,3
        mov dl,offset line3end - offset line3
        int 10h

        fun4_charshow_ret:

    ;恢复寄存器
        pop dx
        pop bx

    ;结束
        ret


code ends

end install
