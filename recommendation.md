# Recommendations

## #1

建议删除 `main` 中的以下代码

```asm
@@ -45,13 +45,7 @@ start:
-    ; while (total_seconds > 0)
-    jmp timer_loop_cond
 
-timer_loop:
     call PerSecond;由Persecond调用Ten2
-    jmp exit
-
-timer_loop_cond:
-    cmp [total_seconds], 0
-    ja timer_loop
 
 exit:
     mov ax,4c00h
```

仅保留一行代码:
```asm
     call PerSecond;由Persecond调用Ten2
```

让 `PerSecond` 完全控制循环和条件判断而 `main` 不参与该过程

## #2

建议将时分秒的输入单独封装为一个 (或多个) 函数