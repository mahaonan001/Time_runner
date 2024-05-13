data segment
  hour db 0
  minute db 0
  second db 0
data ends
code segment
 assume ds:data,cs:code
 main proc far
start:
    mov ax, data  
    mov ds, ax

    
    mov cx, 0  
    mov al, hour  
    cmp al, 10    
    inc cx

    mov al, minute  
    cmp al, 10  
    inc cx  
    
    mov al, second  
    cmp al, 10  

    mov dx, 14   
    mov bx, 70  
    sub bx, cx  
    shr bx, 1  

   
    mov ah, 02h  
    mov dh, dl  
    mov dl, bl 
    int 10h  

    mov ah,09h
    mov bh,0
    mov bl,0ch
    int 10h

    mov al,hour
    mov ah,0
    mov bh,10
    div bh
    mov dl,ah

    mov ah, 0eh    
    add al, '0'  
    int 10h 
    mov al,dl
    add al,'0'
    int 10h 
    
    mov al, ':'  
    int 10h

    mov ah,09h
    mov bh,0
    mov bl,0ch
    int 10h

    mov al,minute
    mov ah,0
    mov bh,10
    div bh
    mov dl,ah

    mov ah, 0eh    
    add al, '0'  
    int 10h 
    mov al,dl
    add al,'0'
    int 10h   

    mov al, ':'  
    int 10h

    mov ah,09h
    mov bh,0
    mov bl,0ch
    int 10h
    
    mov al,second
    mov ah,0
    mov bh,10
    div bh
    mov dl,ah

    mov ah, 0eh    
    add al, '0'  
    int 10h 
    mov al,dl
    add al,'0'
    int 10h 
 mov ax,4c00h
 int 21h
 main endp
code ends
end start
