10 COLOR 15,0,0: SCREEN 2:X=50:Y=60:F=0:CX=42:OY=Y:O=0:DIM FILE$(4,2):KEYOFF
20 FILE$(0,0)="MENU1":FILE$(0,1)="MENU1.BAS":FILE$(1,0)="MENU2":FILE$(1,1)="MENU2.BAS":FILE$(2,0)="MENU3":FILE$(2,1)="MENU3.BAS":FILE$(3,0)="MENU4":FILE$(3,1)="MENU4.BAS"
50 BLOAD"TESTE1.SC2",S
60 OPEN"GRP:"FOR OUTPUT AS #1
65 FOR I=0 TO 3
71 PRESET(X,Y+(I*8)):PRINT#1,FILE$(I,0);
72 NEXT I
80 GOSUB 1100 ' RENDERIZA CURSOR
85 K$=INPUT$(1)
90 IF K$="" THEN GOTO 90 ELSE K=ASC(K$)
100 IF K=13 THEN GOTO 1400
110 IF K=31 THEN IF F>=3 THEN F=0:OY=Y:Y=60:O=O ELSE F=F+1:OY=Y:Y=Y+8:O=O+1
120 IF K=30 THEN IF F<=0 THEN F=F:OY=Y:Y=60:O=0 ELSE F=F-1:OY=Y:Y=Y-8:O=O-1
1000 GOTO 80
1100 REM RENDERIZA CURSOR NA POSICAO ATUAL
1200 LINE(CX,OY)-(CX,(OY+8)),0,BF:PRESET(CX,Y):PRINT #1,">"
1300 RETURN
1400 REM EXECUTA O PROGRAMA SELECIONADO
1500 'CLOSE #1
1600 PRESET(60,120):PRINT #1,FILE$(F,1);
1700 GOTO 1700
