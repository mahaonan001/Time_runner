stack segment stack
    db 100h dup(?)
stack ends
data segment
    buffer db 'The default timer is set to 2:00:00, if you want to change the time, please enter the new time with hours: $'
    set_hour_error_message db 'The hours must be greater or equal to 0. Please try again: $'

    newline db 0dh, 0ah, '$'

    hour db 2
    minute db 0
    second db 0
data ends

code segment
main PROC Far
    assume cs:code, ds:data
    
start:
    ; init
    mov ax, data
    mov ds, ax

    ; input hours 
    mov ah, 01h
    int 21h

    cmp al, '0'
    jl set_hour_exception

    mov hour, al

    ; input minutes
    ; ...

    ; input seconds
    ; ...

    call PerSecond

    call Ten2

    call Showing

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
end start

;description : every second give a interrupt to the program and call the PerSecond procedure to update the time./每秒给出一个中断，调用Ten2或被Ten2调用
PerSecond PROC NEAR
    
PerSecond ENDP

;description : transform the data and set the time to three registers or to data segment. update the time by after 1 second to the current time./将时间转换，并将时间设置到三个寄存器或数据段。每秒更新当前时间。
Ten2 PROC NEAR
    
Ten2 ENDP

;description : every second, show the current time on the screen,by using diffent corlars and formats./输出函数，通过改变时间的格式和颜色显示当前时间。
Showing PROC NEAR
    
Showing ENDP
code ends
