xor ax,ax
sti
inc ax
cli
inc ax
sti
inc ax
times 510-($-$$)    db 0
                    db 0x55,0xaa