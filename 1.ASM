DATA SEGMENT
score           DB    0;每次存入的分数
allscore        DW     0
ERRORmsg   DB "error input,please re-enter!",0DH,0AH,'$'
INPUTmsg   DB "Enter the grade of a class,separated by a Space, and enter Enter to end",0DH,0AH,'$'
averagemsg db 0dh,0ah,"the average score is:",'$'
maxminmsg db 0dh,0ah,"the max and min score is:",'$'
differnumber db 0dh,0ah,"total number/excellent/good/medium/pass/fail number",0DH,0AH,'$'
differrate   db  0dh,0ah,"total rate/excellent/good/medium/pass/fail rate",0dh,0ah,'$'

Result         DB   "Total number:"
TEMPRATE   DW  0;暂存用于输出
ALLNUM   DB   0;总人数
amsg         DB   0dh,0ah,"Excellent number";
ANUM       DB  0;优的人数
ARATE       DW  0;rate不会超过10000，但是db不够
BNUM       DB  0;良
BRATE       DW 0
CNUM       DB  0;中
CRATE        DW 0;
DNUM       DB  0;及格
DRATE       DW  0
ENUM        DB   0;不及格
ERATE        DW    0
MAX  DB   0;最高分
MIN    DB  0;最低分
AVERAGE  DW 0;平均分
 DATA  ENDS

CODE SEGMENT
ASSUME  CS:CODE,DS:DATA
MAIN PROC FAR
    PUSH DS
    MOV  AX,0
    PUSH   AX
    MOV AX,DATA
    MOV DS,AX;填充数据段
;again的错误处理记得将计数器都清零
AGAIN:  MOV ALLNUM,0
    MOV  ANUM,0
    MOV BNUM,0
    MOV  CNUM,0
    MOV   DNUM,0
    MOV  ENUM,0 
    MOV MAX,0
    MOV MIN,100
    MOV score,0
    MOV allscore,0
    LEA   DX,INPUTmsg
    MOV   AH,09H
    INT     21H;输出提示信息
L:  MOV  AH,01H;默认成绩是二位数,对一位数和三位数做特殊处理
    INT 21H
    CMP AL,0DH
    JZ   MIDDLE;输入回车代表结束
    SUB AL,'0';减去0，转化成asc码
    MOV DL,AL;十位数存在DL中
    CMP AL,9
     JA  MIDDLE2
     CMP AL,0
     JB  MIDDLE2
    MOV score,AL;将十位数暂存在score
    MOV AH,01H
    INT 21H
    CMP AL,' ';如果是空格，证明输入的是个位数
    JNZ DOUBLE
    MOV AL,score
    JMP  SINGLE
  DOUBLE:
     SUB AL,'0'
    CMP AL,9
    JA MIDDLE2;MIDDLE2再转一次得到错误处理方式
    CMP AL,0
    JB MIDDLE2
    PUSH AX;将al（个位存入堆栈保存） 
   MOV AL,DL
    MOV BL,10
    MOV AH,0
    MUL  BL
    MOV   score,AL;乘以十倍 假设score是80
    POP AX
    ADD score,AL
   JMP BLANK
;可以转化成正常的score
SINGLE:   add score,al
    ;读取后面的空格
BLANK:  MOV AH,01H
    INT 21H
    CMP AL,0DH;先和回车比较，如果是回车，则到HUI
    JZ   HUI
    CMP AL,' '
   JNZ MIDDLE2;错误处理
HUI:   
    INC ALLNUM      
    MOV  BL,score
    MOV BH,0
    ADD allscore,BX
   MOV  BL,MAX
    CMP  BL,score
    JNB NEXT
    MOV  BL,score;交换到最大
    MOV MAX,BL;将较大的数转换到MAX中
JMP NEXT
MIDDLE2:JMP ERROR
MIDDLE:JMP DELDATA
NEXT:  MOV BL,MIN
CMP BL,score
    JNA NEXTT
   MOV BL,score 
   MOV  MIN,BL
NEXTT:cmp score,90
   JNB YOU
  cmp score,80
  JNB LIANG
  cmp score,70
  JNB ZHONG 
  CMP score,60
  JNB PASS
  JMP FAIL
YOU:INC ANUM
        JMP L
LIANG: INC BNUM
        JMP L
ZHONG: INC CNUM
       JMP L
PASS:INC DNUM
       JMP L
FAIL:INC  ENUM
       JMP L
ERROR:  LEA DX,ERRORmsg
              MOV  AH,09H
              INT   21H
              JMP  AGAIN
;**************************输入结束后处理数据，计算************************************
DELDATA:  ;处理数据

CALL AVERAGECUL;调用求平均分的子程序求平均分

;然后再输出最高分和最低分(调用函数的形式来写
;**********************repeat to output max and min**********************
lea dx,maxminmsg
mov ah,09h
int 21h
mov dl,max
mov al,max;寄存器传参
CALL OUTPUTDOUBLE
mov dl,' '
mov ah,02h
int 21h;输出一个空格
mov dl,min
mov al,min
CALL OUTPUTDOUBLE
MOV DL,0DH
MOV AH,02H;回车
INT 21H
MOV DL,0AH;换行
MOV AH,02H
INT 21H
;再输出优中良及格的人数以及百分比，还有总人数
;********************下面输出各个优良的人数和总人数
lea  dx,differnumber
mov ah,09h
int 21h
;****************************输出总人数
mov dl,ALLNUM
mov al,ALLNUM
CALL OUTPUTDOUBLE
;再输出一个空格
mov dl,' '
mov ah,02h
int 21h
;上面是相同的部分，copy即可
;*******************优良中的人数，先分别重复，之后再整合
mov dl,ANUM 
mov al,ANUM
CALL OUTPUTDOUBLE
;再输出一个空格
mov dl,' '
mov ah,02h
int 21h
;************************良的人数
mov dl,BNUM 
mov al,BNUM
mov ah,0
CALL OUTPUTDOUBLE
;再输出一个空格
mov dl,' '
mov ah,02h
int 21h
;*****************中的人数
mov dl,CNUM 
mov al,CNUM
CALL OUTPUTDOUBLE
;再输出一个空格
mov dl,' '
mov ah,02h
int 21h
;*******************及格人数
mov dl,DNUM 
mov al,DNUM
CALL OUTPUTDOUBLE
;再输出一个空格
mov dl,' '
mov ah,02h
int 21h

;**************不及格人数
mov dl,ENUM 
mov al,ENUM
CALL OUTPUTDOUBLE
;再输出一个空格
mov dl,' '
mov ah,02h
int 21h
;***************************求各个比率，保留一位小数，首先总比率肯定是100%
LEA DX,differrate
MOV AH,09H
INT 21H
;********************************然后再计算各自的比率
;**********************总体：一定是100%
MOV DL,'1'
MOV AH,02H
INT 21H
MOV DL,'0'
MOV AH,02H
INT 21H
MOV DL,'0'
MOV AH,02H
INT 21H
MOV DL,'%'
MOV AH,02H
INT 21H
MOV DL,' '
MOV AH,02H
INT 21H

;******************************然后计算优的百分比,调用子程序
MOV AL,ANUM
CALL CULRATE
MOV AL,BNUM
CALL CULRATE
MOV AL,CNUM
CALL CULRATE
MOV AL,DNUM
CALL CULRATE
MOV AL,ENUM
CALL CULRATE
RET
MAIN ENDP
;************************************以下是子程序部分*************************************************

;1.*********************************计算平均数的子函数**************************
;***子程序说明：利用内存传递参数，allscore为班级总分，allnum为班级总人数*****
;***返回值：无************************************************************
;***功能：计算保留一位小数并且输出班级平均分***************************

AVERAGECUL PROC;计算平均数的子函数
MOV AX,allscore
mov bx,100
mul bx;ax的结果是153100
mov BL,ALLNUM;18
MOV BH,0
DIV BX;商在ax,余数在DX;ax中是8505
;要输出average这个四位数
MOV AVERAGE,AX;不要先输出
PUSH  AX
;*********************以下计算平均分
lea  dx,averagemsg
mov ah,09h
int 21h
POP AX
;************四舍五入的算法：
;假设ax是8505
;先判断第四位让其进位
MOV DX,0
MOV BX,10;ax/BX商在AX，余数在DX
DIV BX
CMP DX,5
JB  IG           ;大于等于五要进位
INC AX;进位+1此时 ax的值是851
IG: ;输出ax的前三位即可，中间记得要加一个小数点
MOV BL,10
DIV BL ;商在al寄存器中,余数在ah寄存器中
push ax
;******************************调用函数输出这个两位数先
mov dl,al
mov ah,0
mov DH,10
div  dh;余数在ah寄存器中，商在al寄存器中
push ax
mov dl,al;十位数在dl中了
add dl,30h
mov ah,02h
int 21h
pop ax;输出ah余数
mov dl,ah
add dl,30h
mov ah,02h
int 21h
MOV DL,'.'
MOV AH,02H
INT 21H
pop ax;出栈，ah是要输出的数
add ah,30h
mov dl,ah
mov ah,02h
int 21h     
   RET
AVERAGECUL ENDP

;2.*********************************输出2位数的子程序**************************
;***子程序说明：利用寄存器传递参数，DL和al中都要存放要输出的数***************
;***返回值：无************************************************************
;***功能：输出一个存放在dl中的二位数（十进制方式输出）***************
OUTPUTDOUBLE PROC
mov ah,0
mov DH,10
div  dh;余数在ah寄存器中，商在al寄存器中
push ax
mov dl,al;十位数在dl中了
add dl,30h
mov ah,02h
int 21h
pop ax;输出ah余数
mov dl,ah
add dl,30h
mov ah,02h
int 21h
  RET
OUTPUTDOUBLE ENDP

;3.*********************************输出百分比的子程序**************************
;***子程序说明：利用寄存器传递参数，AL中要存放要计算的分子，
                   ;内存传递参数，ALLNUM 中存放要计算的分母***************
;***返回值：无************************************************************
;***功能：输出百分比，保留一位小数（十进制方式输出）***************
CULRATE  PROC
MOV AH,0
MOV DX,0
MOV BX,10000
MUL BX;值放在dx和ax中，
MOV BL,ALLNUM;
MOV BH,0
DIV BX;商保存在AX寄存器中，余数保存在DX寄存器中
MOV DX,0;不需要余数
;除以10后看余数是否要进位，仿照四舍五入(也可以整合为一个函数)
MOV BX,10
DIV BX;商保存在AX寄存器中，余数保存在DX寄存器中
CMP DX,5
JB JINWEI 
INC AX
JINWEI:;ax中存放的是要输出的数，要加一个小数点
MOV BL,10
DIV BL ;商在al寄存器中,余数在ah寄存器中
push ax
;******************************调用函数输出这个两位数先，子程序嵌套
mov dl,al
CALL OUTPUTDOUBLE
MOV DL,'.'
MOV AH,02H
INT 21H
pop ax;出栈，ah是要输出的数
add ah,30h
mov dl,ah
mov ah,02h
int 21h
;再输出一个百分号
MOV DL,'%'
MOV AH,02H
INT 21H
MOV DL,' '
MOV AH,02H
INT 21H
RET
CULRATE ENDP
CODE    ENDS
       END MAIN

;输出部分重复太多，一定要写一个输出二位数的转换函数，把内存中的变量，比如ALLNUM 转换成输出函数



    
