include HT66F70A.inc

ds  .section    'data'
TIME_A	DB		?	;分	十位數
TIME_B	DB		?	;分	個位數
TIME_C	DB		?	;秒 十位數
TIME_D	DB		?	;秒 個位數
DEL1	DB		?	;延遲副程式變數
DEL2	DB		?	;延遲副程式變數
DEL3	DB		?	;延遲副程式變數
INDEX	DB		?	;表格輸入值
COUNT	DB		?	;表格計數

ROMBANK 0 cs
cs  .section    at  000h    'code'

        ORG     00H             ;程式起始位置
MAIN:                           ;"MAIN:"代表label
        CLR     PCC             ;規劃PORT_C為輸出，輸出/入控制暫存器，1輸入；0輸出
        CLR		PDC
		MOV     A,10101111B
        MOV     WDTC,A          ;關閉看門狗計時器
		MOV		A,00010000B		;CTM控制暫存器0,CLK=fH(fsys/16=500KHz)
		MOV		TM0C0,A			
		MOV		A,00000000B		;CTM控制暫存器1,Compare Match Output Mode
		MOV		TM0C1,A			;CCLR=1,設定使用A比較器
		MOV		A,0FFH			;設定計數比較值=03FFH
		MOV		TM0AL,A			
		MOV		A,03H
		MOV		TM0AH,A
		SET		T0ON			;開始計數
		
		MOV		A,5				;測試用，設定初值
		MOV		TIME_A,A
		MOV		TIME_B,A
		MOV		TIME_C,A
		CLR		TIME_D
		
		MOV		A,TIME_D		;COUNT=TIME_D+1，目的為避免系統進入TRANS_7的ADDM，無法跳脫出來
		ADD		A,1
		MOV		COUNT,A
		
TIMER:
		MOV		A,100
		CALL	DELAY
		DEC		TIME_D
		SDZ		COUNT
		JMP		LIGHT
		JMP		INIT_TIME_D
INIT_TIME_A:
		MOV		A,5
		MOV		TIME_A,A
INIT_TIME_B:
		MOV		A,9
		MOV		TIME_B,A
		DEC		TIME_A
		SNZ		TIME_A
		JMP		INIT_TIME_A
		JMP		TIMER
INIT_TIME_C:
		MOV		A,5
		MOV		TIME_C,A
		DEC		TIME_B
		SNZ		TIME_B
		JMP		INIT_TIME_B
		JMP		TIMER
INIT_TIME_D:
		MOV		A,9
		MOV		TIME_D,A
		MOV		A,10
		MOV		COUNT,A
		DEC		TIME_C
		SNZ		TIME_C
		JMP		INIT_TIME_C
		JMP		TIMER					
LIGHT:
		CLR		T0AF			;清除A比較器中斷旗標
		MOV		A,01H			;點亮第一顆顯示器
		MOV		PD,A
		MOV		A,TIME_D			;送出點亮數字
		CALL	TRANS_7
		MOV		PC,A
MATCH1:
		SNZ		T0AF			;SNZ: 不是0就跳
		JMP		MATCH1
		CLR		T0AF			;清除A比較器中斷旗標
		
		MOV		A,02H			;點亮第二顆顯示器
		MOV		PD,A
		MOV		A,TIME_C			;送出點亮數字
		CALL	TRANS_7
		MOV		PC,A
MATCH2:
		SNZ		T0AF
		JMP		MATCH2
		CLR		T0AF			;清除A比較器中斷旗標
		
		MOV		A,04H			;點亮第三顆顯示器
		MOV		PD,A
		MOV		A,TIME_B			;送出點亮數字
		CALL	TRANS_7
		MOV		PC,A
MATCH3:
		SNZ		T0AF
		JMP		MATCH3
		CLR		T0AF			;清除A比較器中斷旗標
		
		MOV		A,08H			;點亮第四顆顯示器
		MOV		PD,A	
		MOV		A,TIME_A			;送出點亮數字
		CALL	TRANS_7
		MOV		PC,A
MATCH4:
		SNZ		T0AF
		JMP		MATCH4
		CLR		T0AF			;清除A比較器中斷旗標
		JMP		TIMER

DELAY	PROC
		MOV		DEL1,A
DEL_1: 	MOV		A,60
		MOV		DEL2,A
DEL_2:
		MOV		A,110
		MOV		DEL3,A
DEL_3:
		SDZ		DEL3
		JMP		DEL_3
		SDZ		DEL2
		JMP		DEL_2
		SDZ		DEL1
		JMP		DEL_1
		RET
DELAY	ENDP

TRANS_7	PROC				;七段顯示器表格
	ADDM		A,PCL		;PCL=PCL+Acc
	RET  		A,3FH		;"0"
	RET  		A,06H		;"1"
	RET  		A,5BH		;"2"
	RET  		A,4FH		;"3"
	RET			A,66H		;"4"
	RET			A,6DH		;"5"
	RET			A,7DH		;"6"
	RET			A,07H		;"7"
	RET			A,7FH		;"8"
	RET			A,67H		;"9"
	RET			A,77H		;"A"
	RET			A,7CH		;"b"
	RET			A,58H		;"c"
	RET			A,5EH		;"d"
	RET			A,79H		;"E"
	RET			A,71H		;"F"
TRANS_7	ENDP

		END