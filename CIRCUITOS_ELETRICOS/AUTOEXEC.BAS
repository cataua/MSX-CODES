100 REM *****************************************
110 REM *                                       *
120 REM *     MENU PARA CARGA DOS PROGRAMAS     *
130 REM *    DO LIVRO CIRCUITOS ELETRONICOS     *
140 REM *                                       *
150 REM *****************************************
160 SCREEN 0:WIDTH 40:KEYOFF:CLS
170 LOCATE 4,10:PRINT"1 - MULTIVIBRADORES COM CI555":PRINT:PRINT
200 LOCATE 10,12:INPUT"ESCOLHA O PROGRAMA: ";OP:IF OP<1 OR OP>4 OR OP-FIX(OP)<>0 THEN GOTO 160 ELSE ON OP GOTO 500
500 RUN"MULTV555.BAS"
