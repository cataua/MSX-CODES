100 REM *****************************************
110 REM *                                       *
120 REM *     MENU PARA CARGA DOS PROGRAMAS     *
130 REM *    DO LIVRO CIRCUITOS ELETRONICOS     *
140 REM *                                       *
150 REM *****************************************
160 SCREEN 0:WIDTH 40:KEYOFF:CLS
170 GOSUB 1000
200 LOCATE 10,30:INPUT"ESCOLHA O PROGRAMA: ";OP:IF OP<1 OR OP>4 OR OP-FIX(OP)<>0 THEN GOTO 160 ELSE ON OP GOTO 500
500 RUN"MULTV555.BAS"
1000 REM SUBROTINA PARA DESENHAR O MENU
1010 LOCATE 0,2:PRINT"+======================================+"
1020 PRINT"|              MENU DE OPCOES          |"
1030 PRINT"|     1 - MULTIVIBRADORES COM CI555    |"
1040 PRINT"|                                      |"
1050 PRINT"|                                      |"
1060 PRINT"|                                      |"
1070 PRINT"|                                      |"
1080 PRINT"|                                      |"
1090 PRINT"+======================================+"
1100 RETURN
