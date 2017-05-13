10 INPUT "Enter name of .TBI file to convert to text";FI$
20 OPEN "I",1,FI$
30 INPUT "Name of new text file";FO$
40 OPEN "O",2,FO$
50 LINE INPUT #1,A$
60 IF LEFT$(A$,1)="@" THEN 120
70 IF LEFT$(A$,1)<>":" THEN 50
80 LIN=VAL("&H"+MID$(A$,2,4))
90 PRINT #2,LIN;MID$(A$,6)
100 IF EOF(1) THEN 120
110 GOTO 50
120 CLOSE
130 END
