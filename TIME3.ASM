DATA SEGMENT  
    Count   DW  1          ;Count计数1秒
    Test1   DB 0AH,0DH,'This is a test $'   ;测试样例，后期删除
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

    MOV DX,SEG INT_1CH              ;SEG标号段地址
    MOV DS,DX
    MOV DX,OFFSET INT_1CH        ;调用子函数INT_1CH 取偏移地址 
	                                                     ;AH=25H功能:置中断向量AL=中断号 DS:DX=入口
     MOV AH,25H
     MOV AL,1CH                               ;设置新的1CH中断向量
     INT 21H
	
	                                                      ;退出程序
     MOV AX,4C00H
     INT 21H
MAIN ENDP 
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
    LEA DX,Test1
    MOV AH,09H
    INT 21H
    ;后期删除测试，调用其他程序
   



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
END START
