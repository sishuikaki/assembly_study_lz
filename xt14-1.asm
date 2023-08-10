       ;
       ;文件名：xt14-1.asm
       ;文件说明：第14章习题第1题
       ;

       ;设置堆栈段和栈指针 
       mov eax,cs      
       mov ss,eax
       mov sp,0x7c00

       ;计算GDT所在的逻辑段地址
       mov eax,[cs:pgdt+0x7c00+0x02]      ;GDT的32位线性基地址 
       xor edx,edx
       mov ebx,16
       div ebx                            ;分解成16位逻辑地址 

       mov ds,eax                         ;令DS指向该段以进行操作
       mov ebx,edx                        ;段内起始偏移地址 

       ;创建0#描述符，它是空描述符，这是处理器的要求
       mov dword [ebx+0x00],0x00000000
       mov dword [ebx+0x04],0x00000000  

       ;创建1#描述符，这是一个数据段，对应0~4GB的线性地址空间
       mov dword [ebx+0x08],0x0000ffff    ;基地址为0，段界限为0xfffff
       mov dword [ebx+0x0c],0x00cf9200    ;粒度为4KB，存储器段描述符 

       ;创建保护模式下初始代码段描述符
       mov dword [ebx+0x10],0x7c0001ff    ;基地址为0x00007c00，512字节 
       mov dword [ebx+0x14],0x00409800    ;粒度为1个字节，代码段描述符 

       ;创建以上代码段的别名描述符
       mov dword [ebx+0x18],0x7c0001ff    ;基地址为0x00007c00，512字节
       mov dword [ebx+0x1c],0x00409200    ;粒度为1个字节，数据段描述符

       mov dword [ebx+0x20],0x7c00fffe    ;基地址为0x00007c00，界限为0xffffe
       mov dword [ebx+0x24],0x00cf9600    ;粒度为4KB，向下扩展
       
       ;初始化描述符表寄存器GDTR
       mov word [cs: pgdt+0x7c00],39      ;描述符表的界限   

       lgdt [cs: pgdt+0x7c00]

       in al,0x92                         ;南桥芯片内的端口 
       or al,0000_0010B
       out 0x92,al                        ;打开A20

       cli                                ;中断机制尚未工作

       mov eax,cr0
       or eax,1
       mov cr0,eax                        ;设置PE位

       ;以下进入保护模式... ...
       jmp 0x0010:dword flush             ;16位的描述符选择子：32位偏移

       [bits 32]                          
flush:                                     
       mov eax,0x0018                      
       mov ds,eax

       mov eax,0x0008                     ;加载数据段(0..4GB)选择子
       mov es,eax
       mov fs,eax
       mov gs,eax

       mov eax,0x0020                     ;0000 0000 0010 0000
       mov ss,eax
       xor esp,esp                        ;ESP <- 0

       mov dword [es:0x0b8000],0x072e0750 ;字符'P'、'.'及其显示属性
       mov dword [es:0x0b8004],0x072e074d ;字符'M'、'.'及其显示属性
       mov dword [es:0x0b8008],0x07200720 ;两个空白字符及其显示属性
       mov dword [es:0x0b800c],0x076b076f ;字符'o'、'k'及其显示属性

       
       
       ;开始检测1MB以上的内存空间，从0x0010 0000到0x0050 0000

       ;将0x55aa55aa写入内存空间
       mov ebx,0x00100000   ;从0x0010 0000开始
       mov ecx,0x00100000   ;一次循环4字节，一共0x00100000次
       write: ;倒序写入0x55aa55aa
              mov dword [es:ebx+4*(ecx-1)],0x55aa55aa    ;ecx从0x10 0000到1，偏移量从0x0f ffff到0，所以ecx要减1
              loop write

       ;显示提示文字
       mov ecx,over - start
       mov ebx,start
       mov edi,160*1+2*35
       call showstring      ;显示正在检测中

       mov ecx,table - progressbar
       mov ebx,progressbar
       mov edi,160*2+31*2
       call showstring      ;显示进度条

       ;检测内存空间
       mov ebx,0x00100000   ;从0x0010 0000开始
       mov ecx,0x00100000   ;一次循环4字节，一共0x00100000次
       xor ebp,ebp          ;ebp清零
       xor edx,edx          ;edx用于记录检测数
       check:
              mov eax,[es:ebx+4*ebp]
              
              cmp eax,0x55aa55aa
              je check_ok

              ;没有检测到0x55aa55aa
              inc ebp
              loop check
              jmp check_end ;循环结束后退出循环
              
              ;检测到0x55aa55aa
              check_ok:
              mov dword [es:ebx+4*ebp],0xaa55aa55       ;写入0xaa55aa55表示已检测
              inc edx       ;已检测数+1
              call updataprogressbar      ;更新进度条
              inc ebp
              loop check
       check_end:

       ;提示检测已结束
       mov ecx,progressbar - over
       mov ebx,over
       mov edi,160*1+2*35   ;需要与检测中的提示位置相同，因为要替换掉原来的提示
       call showstring

       hlt

;-------------------------------------------------------------------------------
;显示字符串。es:ebx指向字符串开头，edi表示显存偏移量，ecx表示字符个数
showstring:
       push esi
       push eax
       
       xor esi,esi
       mov ah,0x07
       showstring_s:
              mov al,[ebx+esi]
              mov [es:0xb8000+edi],ax
              inc esi
              add edi,2
              loop showstring_s
       
       pop eax
       pop esi
       ret

;更新进度条。
updataprogressbar:
       push ecx
       push esi
       push eax
       push edx

       mov ecx,6     ;进度条有6个字符要替换
       xor esi,esi
       updataprogressbar_s: ;先把edx最低位显示出来，再让edx右移，像这样依次循环
              mov eax,edx
              and eax,1111b ;只保留edx的最后一位
              mov al,[table+eax]
              mov [es:0xb8000+160*2+(31+2)*2+2*(ecx-1)],al     ;ecx从6到1，偏移量从5到0，所以ecx要减1
              shr edx,4     ;十六进制的1位，是二进制的4位
              loop updataprogressbar_s

       pop edx
       pop eax
       pop esi
       pop ecx
       ret

;-------------------------------------------------------------------------------
start         db 'checking'               ;提示正在检测中
over          db '  done! '               ;提示检测结束。宽度不能小于start，因为要覆盖
progressbar   db '0x000000 / 0x100000'    ;进度条
table         db '0123456789abcdef'       ;字符数组，从数值1~f转换为字符1~f
;-------------------------------------------------------------------------------
pgdt          dw 0
              dd 0x00007e00        ;GDT的物理地址
;-------------------------------------------------------------------------------                             
times 510-($-$$)     db 0
                     db 0x55,0xaa
