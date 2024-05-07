stack segment stack
    db 100h dup(?)
stack ends

data segment
    buffer db 'The default timer is set to 2:00:00, if you want to change the time, please enter the new time with hours: $'
    set_hour_error_message db 'The hours must be greater or equal to 0. Please try again: $'

    newline db 0dh, 0ah, '$'

    ; These are for display purpose, the `Showing` function reads these three variables to display
    hour db 2
    minute db 0
    second db 0

    ; Total seconds, for comparing(`cmp`) purpose: while (total_seconds > 0) { /* do something ... */}
    total_seconds db 0

data ends

code segment
main PROC Far
    assume cs:code, ds:data
    
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

    ; input minutes
    ; ...

    ; input seconds
    ; ...

    ; total_seconds = hour * 3600 + minute * 60 + second
    ; ...

    ; while (total_seconds > 0)
    jmp timer_loop_cond

timer_loop:
    call PerSecond
    call Ten2
    call Showing

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
; 每秒给出一个中断，调用Ten2或被Ten2调用
PerSecond PROC NEAR
    
PerSecond ENDP

; Description : transform the data and set the time to three registers or to data segment. update the time by after 1 second to the current time.
; 将时间转换，并将时间设置到三个寄存器或数据段。每秒更新当前时间。
; total_seconds--, and update the three variables `hours`, `minute`, `second`
Ten2 PROC NEAR
    
Ten2 ENDP

; Description : every second, show the current time on the screen,by using diffent corlars and formats.
; 输出函数，通过改变时间的格式和颜色显示当前时间。
; read `hours`, `minute`, `second` directly to display
; don't read `total_seconds`
Showing PROC NEAR
    
Showing ENDP

code ends
end start
