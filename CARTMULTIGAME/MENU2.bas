10 ' Small menu example Made By: NYYRIKKI
    20 DEFINT A-Z:DIM NN$(200)
    30 FM$="????????.BAS" 'File mask '?' means any character
    40 DA$="0E11110E12C51100C10E1ACD7DF3C11180C0CD7DF332F8F7C9"
    50 AD=&HC080:POKE AD,0'Drive: 0=Default, 1=A: 2=B: ... 8=H:
    60 FOR I=1 TO 12:AD=AD-(I<>10):POKE AD,ASC(MID$(FM$,I,1)):NEXT I
    70 FOR I=&HC08C TO &HC0C0:POKE I,0:NEXT I
    80 FOR I=0 TO 25:POKE &HC000+I,VAL("&H"+MID$(DA$,I*2+1,2)):NEXT I
    90 DEFUSR=&HC000:DEFUSR1=&HC003
    100 IF USR(0)>0 THEN PRINT"Error: No files to load":END
    110 FC=FC+1:FOR I=1 TO 12:NN$(FC)=NN$(FC)+CHR$(PEEK(&HC100+I))
    120 IF I=8 THEN NN$(FC)=NN$(FC)+"."
    130 NEXT I
    140 IF USR1(0)=0 THEN 110
    150 CLS:NN$(0)=SPACE$(12):NN$(FC+1)=NN$(0)
    160 PRINT "------------------"
    161 PRINT "|  ";NN$(0);"  |"
    162 FOR I=1 TO FC:PRINT "|  ";NN$(I);"  |":NEXT I
    170 REM PRINT "|  ";NN$(S);  "  |"
    180 REM PRINT "| >";NN$(S+1);"< |"
    190 REM PRINT "|  ";NN$(S+2);"  |"
    191 PRINT "|  ";NN$(FC+1);"  |"
    200 PRINT "------------------"
    210 A$=INPUT$(1):S=S-(A$=CHR$(31)ANDS<FC-1)+(A$=CHR$(30)ANDS>0)
    220 IF A$<>" " AND A$<>CHR$(13) THEN LOCATE 0,1:GOTO 162
    230 RUN NN$(I+1)