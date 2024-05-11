#计时器程序
## 简介
计时器程序是一个简单的程序，它可以让用户输入一个时间（单位为秒），并在计时结束时显示剩余时间。

## 如何使用
```shell
masm timer;
link timer;
./timer.exe
```

## 程序结构
计时器程序的源代码文件为timer.asm，它包含三个部分：

- 秒中断(PerSecond)：每隔一秒，产生中断，可以由其他函数调用或者调用其他函数来实现计时功能。
```asm
;description : every second give a interrupt to the program and call the PerSecond procedure to update the time.
;每秒给出一个中断，调用Ten2或被Ten2调用

PerSecond PROC NEAR
    
PerSecond ENDP
```
- 进制转换(Ten2)：每秒产生中断时将时间秒数减一，保证时分秒的进制转换准确，每执行一次调用Show。
```asm
;description : transform the data and set the time to three registers or to data segment. update the time by after 1 second to the current time.
;将时间转换，并将时间设置到三个寄存器或数据段。每秒更新当前时间。

Ten2 PROC NEAR
    
Ten2 ENDP
```
- 屏幕计时(Show)：将剩余时间显示到屏幕上，改变格式和颜色，具体美化程度，programer决定。

```asm
;description : every second, show the current time on the screen,by using diffent corlars and formats.
;输出函数，通过改变时间的格式和颜色显示当前时间。

Showing PROC NEAR
    
Showing ENDP
```

### 鸣谢（不分先后顺序）

- [Bingo-Xiang](https://github.com/Bingo-Xiang)

- [QMEOWQ](https://github.com/QMEOWQ)

- [sdvasdfa](https://github.com/sdvasdfa)
  
- [ZureTz](https://github.com/ZureTz)