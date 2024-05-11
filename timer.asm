stack segment stack
    dw 100h dup(?)
    ;DW 80 DUP(0)---huang??
stack ends

data segment
    buffer db 'The default timer is set to 2:00:00, if you want to change the time, please enter the new time with hours: $'
    set_hour_error_message db 'The hours must be greater or equal to 0. Please try again: $'

    newline db 0dh, 0ah, '$'

    ; These are for display purpose, the `Showing` function reads these three variables to display
    hour db 2
    minute db 0
    second db 0

    ; Total seconds, for comparing(`cmp`) purpose: while (total_seconds > 0) { /* do something ... */ }
    total_seconds dw 0

data ends

code segment
main PROC FAR
    assume cs:code, ds:data ,ss:stack
    
start:
    ; init
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax

    ; input hours 
    mov ah, 01h
    int 21h

    cmp al, '0'
    jl set_hour_exception

    mov hour, al

    ; total_seconds = hour * 3600 + minute * 60 + second
    call TimeToSeconds

    ; while (total_seconds > 0)
    jmp timer_loop_cond

timer_loop:
    call PerSecond;由Persecond调用Ten2
    jmp exit

timer_loop_cond:
    cmp [total_seconds], 0
    ja timer_loop

exit:
    mov ax,4c00h
    int 21h

set_hour_exception:
    ; print error message
    mov ah, 09h
    lea dx, [set_hour_error_message]
    int 21h

    jmp exit
    
main ENDP

; Description : every second give a interrupt to the program and call the PerSecond procedure to update the time.
; 每秒给出一个中断，调用INT_1CH，INT_1CH中断调用TEN2和Showing函数更新时间。
;-------------------------------------------------------------------------------------------------------------------------------------
PerSecond PROC NEAR
    MOV AX,STACK
    MOV SS,AX

    MOV DX,SEG INT_1CH               ;SEG标号段地址
    MOV DS,DX
    MOV DX,OFFSET INT_1CH            ;调用子函数INT_1CH 取偏移地址 
	                                 ;AH=25H功能:置中断向量AL=中断号 DS:DX=入口
    MOV AH,25H
    MOV AL,1CH                      ;设置新的1CH中断向量
    INT 21H
    ret
PerSecond ENDP
;--------------------------------------------------------------------------------------------------------------------------------------
; Description : transform the data and set the time to three registers or to data segment. update the time by after 1 second to the current time.
; 将时间转换，并将时间设置到三个寄存器或数据段。每秒更新当前时间。
; total_seconds--, and update the three variables `hours`, `minute`, `second`
Ten2 PROC NEAR
    dec [total_seconds]
    call SecondsToTime
    ret
Ten2 ENDP

; let total_seconds = hour * 3600 + minute * 60 + second
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

; let 
;   hour = total_seconds / 3600
;   minute = (total_seconds % 3600) / 60
;   second = (total_seconds % 3600) % 60
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

; Description : every second, show the current time on the screen,by using diffent corlars and formats.
; 输出函数，通过改变时间的格式和颜色显示当前时间。
; read `hours`, `minute`, `second` directly to display
; don't read `total_seconds`
Showing PROC NEAR
    
Showing ENDP

code ends
;----------------------------------------------------------------------------------------------------
;using by huang
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

    call Ten2;每秒调用Ten2更新时间
    call Showing;每秒调用Showing显示时间
    cmp total_seconds,0;若total_seconds=0则退出,否则继续循环
    jz ret
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
code2 ends
;-----------------------------------------------------------------------------------------------------
end start
