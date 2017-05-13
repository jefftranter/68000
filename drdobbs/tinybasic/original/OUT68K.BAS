10 NULL 40
20 INPUT "Enter name of file to send to 68000 system";FI$
30 OPEN "I",1,FI$
35 INPUT "Now exit Transparent Mode and type 'LO2 ='",JUNK$
40 LINE INPUT #1,A$
50 PRINT A$
55 IF EOF(1) THEN 100
60 GOTO 40
100 CLOSE
110 END
