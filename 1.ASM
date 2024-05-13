DATA SEGMENT  
    Count   DW  1          ;Count计数1秒
    buffer db 'The default timer is set to 2:00:00, if you want to change the time, please enter the new time with hours: $'
    set_hour_error_message db 'The hours must be greater or equal to 0. Please try again: $'
    newline db 0dh, 0ah, '$'
    ; These are for display purpose, the `Showing` function reads these three variables to display
    hour db 2
    minute db 0
    second db 0

    ; Total seconds, for comparing(`cmp`) purpose: while (total_seconds > 0) { /* do something ... */ }
    total_seconds dw 0
DATA ENDS
 
STACK SEGMENT stack 's'
    DW 80 DUP(0)
STACK ENDS
 
CODE1 SEGMENT
assume cs:code1,ds:data,ss:stack
MAIN PROC FAR
start:

    MOV AX,DATA
    MOV DS,AX                                   ;将数据段DATAS存入DS中

    MOV AX,STACK
    MOV SS,AX

    mov ah, 01h
    int 21h

    cmp al, '0'
    jl set_hour_exception
    sub al,30h
    mov hour, al

    call TimeToSeconds

    MOV DX,SEG INT_1CH              ;SEG标号段地址
    MOV DS,DX
    MOV DX,OFFSET INT_1CH        ;调用子函数INT_1CH 取偏移地址 
	                                                     ;AH=25H功能:置中断向量AL=中断号 DS:DX=入口
     MOV AH,25H
     MOV AL,1CH                               ;设置新的1CH中断向量
     INT 21H
	
exit_end:	                                                      ;退出程序
     MOV AX,4C00H
     INT 21H
set_hour_exception:
    ; print error message
    mov ah, 09h
    lea dx, [set_hour_error_message]
    int 21h

    jmp exit_end
MAIN ENDP
TimeToSeconds PROC NEAR
    ; save registers
    push ax
    push bx
    push dx

    ; dx ax = hour
    mov dx, 0
    mov ah, 0
    mov al, [hour]
    ; bx = 3600
    mov bx, 3600
    ; ax *= bx
    mul bx
    ; total_seconds = ax
    mov [total_seconds], ax

    ; dx ax = minute
    mov dx, 0
    mov ah, 0
    mov al, [minute]
    ; bx = 60
    mov bx, 60
    ; ax *= bx
    mul bx
    ; total_seconds += ax
    add [total_seconds], ax

    ; total_seconds += second
    mov ah, 0
    mov al, [second]
    add [total_seconds], ax

    ; retreive registers
    pop dx
    pop bx
    pop ax
    
    ret
TimeToSeconds ENDP

CODE1 ENDS

code2 segment
assume cs:code2,ds:data,ss:stack
INT_1CH PROC far
    PUSH AX                  ;保存寄存器
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DS
    
    STI
    mov ax,data
    mov ds,ax
    ;- INT 1CH系统中断每秒发生18.2次          
    ;- Count计数至18为1秒         
    ;- Count初值为1,先减1执行一次
    ;- 执行时赋值为18,每次减1,减至0执行更新显示
       
    DEC Count                                                                 ;Count初值为1,先减1
    JNZ Exit                                                                      ;JNZ(结果不为0跳转) 否则Count=0执行更新显示         


    ;调用更新显示代码，以下为测试
    ; LEA DX,Test1
    ; MOV AH,09H
    ; INT 21H
    ;后期删除测试，调用其他程序
    call Ten2
    call Showing
    cmp total_seconds,0
    jz exit



    MOV Count,18             ;计数至18(1秒)重新开始,赋值为18减至0执行变色

Exit: 
    CLI                    ;关中断
    POP DS
    POP DX
    POP CX
    POP BX
    POP	AX		      ;恢复寄存器  
    IRET	              ;中断返回
INT_1CH  ENDP

Ten2 PROC NEAR
    dec [total_seconds]
    call SecondsToTime
    ret
Ten2 ENDP

SecondsToTime PROC NEAR
    ; save registers
    push ax
    push bx
    push dx

    ; dx ax = total_seconds
    mov dx, 0
    mov ax, [total_seconds]
    ; bx = 3600
    mov bx, 3600
    ; dx = total_seconds % 3600
    ; ax = total_seconds / 3600
    div bx
    ; hour = al
    mov [hour], al

    ; dx ax = dx (aka total_seconds % 3600)
    mov ax, dx
    mov dx, 0
    ; bx = 60
    mov bx, 60

    ; dx = (total_seconds % 3600) % 60
    ; ax = (total_seconds % 3600) / 60
    div bx

    ; minute = (total_seconds % 3600) / 60
    mov [minute], al
    ; second = (total_seconds % 3600) % 60
    mov [second], dl

    ; retreive registers
    pop dx
    pop bx
    pop ax
    
    ret
SecondsToTime ENDP

Showing PROC NEAR
    ; push ax
    ; push BX
    ; push cx
    ; push dx
    ; mov dl,hour
    ; mov ah,01h
    ; int 21h

    mov ax, 13h
    int 10h
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
    mov bx, 35  
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
    ; pop dx
    ; pop cx
    ; pop bx
    ; pop ax
    ret
Showing ENDP

code2 ends
END START
