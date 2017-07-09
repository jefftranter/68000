{********** convert MC6809 to MC68000 source utility **********}

program convert6809 (input,output);
uses Crt;

const    imagelen = 100; {input line length}
         labellen = 8;   {label length}
         opcodelen= 5;   {opcode length}
         maxmacro = 100; {max no. of macro names allowed}
         charlen  = 100; {general character length}
         instnum  = 110; {no. of entries in codes file}
         version  = '1.2'; {version number}
                           {1.1 : set lenopc after codes2 match (ln610)}
                           {1.2 : include command line param test}

type     labels = string[labellen];
         opcodes =string[opcodelen];
         chars = string[charlen];
         errortype = (warning,error);

var      image: string[imagelen];      { input image }
         lbl: labels;                  { label field }
         opc: chars;                   { opcode field }
         opr: chars;                   { operand }
         opr2: chars;                  { operand no.2}
         comment: string[imagelen];    { comment }
         lines: integer;               { total input lines read }
         comm_in: integer;             { input comment line count }
         reg  : integer;               { inherent register number}
         errors: integer;              { diagnostic count - errors }
         warnings: integer;            { diagnostic count - warnings }
         linesout: integer;            { code lines into output file }
         comm_out: integer;            { output comment line count }
         infile,outfile: text;         { in and out files }
         blank: string[1];             { dummy string for blank test }
         passthis: boolean;            { pass this record thru unaltered }
         passflag: boolean;            { pass flag for general pass }
         indirect: boolean;            { indirect address mode flag }
         pcr : boolean;                { pcr addr mode flag}
         direct: boolean;              { direct address mode flag }
         problem : boolean;            { fatal error flag}
         xflag: boolean;               { indicates type of indirection }
         interleave : boolean;         { 6809 source interleave flag }
         t : char;
         X,Y,U,S,A,B,DP,CC,PC,D : boolean;  { partial register set }
         DPR,DPW  : boolean;   {DP reg read and write flags}
         label_flag : boolean;  {prevents multiple label prints}
         index : char;
         first : char;
         t2 : chars;                   { temp}
         posi : integer;
         i : integer;
         temp :integer;
         temp2:integer;
         opcode : array[0..instnum] of opcodes;
         opcode2: array[0..instnum] of opcodes;
         expres : array[0..instnum] of chars;
         expres2: array[0..instnum] of chars;
         oprln  : array[0..5] of chars;
         macr_name : array[0..maxmacro] of labels;
         count : integer;              {macro name array pointer}
         macro : boolean;              {macro flag}
         codes : text;
         codes2: text;
         errorfile: text;
         stubxref: text;
         lenopr : integer;
          regnum : char;
          siz    : opcodes;
          opc1t  : chars;
          pos2   : integer;
          last1  : char;
          lenopc : integer;
          z      : integer;
          delim  : char;
          optab  : opcodes;
          lenoptab:integer;
          tempop : opcodes;
          match  : boolean;
          match2 : boolean;
          strg1,strg2,strg3 : chars;
          auto : integer;
          esc  : char;

procedure replace(strg1, strg2 :chars ; z : integer);
                                   {swop two strings within a string}
begin
  pos2:=pos(strg1,oprln[z]);
  if pos2<> 0 then
  begin
   delete(oprln[z],pos2,length(strg1));
   insert(strg2,oprln[z],pos2);
  end
end;

procedure create_line(delim:char; z:integer);
begin
  i:=length(oprln[z]);
  replace(delim,' ',z);
  if (pos2<>i)and(pos2<>0) then
   begin
    i:=5;
    while (oprln[i]='') do i:=i-1;   {find 1st non-blank entry}
    while i>z do                     {move all subsequent entries down by}
     begin                           {one to avoid overwriting           }
      oprln[i+1]:=oprln[i];
      i:=i-1
     end;
    oprln[z+1]:=copy(oprln[z],pos2+1,length(oprln[z])-pos2);
    oprln[z]:=copy(oprln[z],1,pos2);
   end
end;

procedure make_list(temp:integer);
 begin
  replace('o','',temp);
  t2:=oprln[temp];
  if s then insert('/A6',t2,pos2);
  if u then insert('/A5',t2,pos2);
  if dp then insert('/A4',t2,pos2);
  if y then insert('/A1',t2,pos2);
  if x then insert('/A0',t2,pos2);
  if b then insert('/D1',t2,pos2);
  if a then insert('/D0',t2,pos2);
  if d then insert('/D0/D1',t2,pos2);
  oprln[temp]:=t2;
  replace('/','',temp);                  {delete leading '/' char}
 end;

procedure diagnostic(severity:errortype; message:chars);
 begin
  if severity=warning then
   begin
    writeln(outfile,'** WARNING **',' ':22,message);
    comm_out:=comm_out+1;
    warnings:=warnings+1;
   end
  else
   begin
    writeln(outfile,'** ERROR ** ',message);
    writeln(outfile,' * ',image);              {force asm error}
    comm_out:=comm_out+2;
    writeln(errorfile,lines:6,linesout+comm_out:10,' ':5,image);
    writeln(errorfile,' ':31,message);
    problem:=true;
    errors:=errors+1;
   end;
 end;

procedure create_file;
begin
      z:=0;
      label_flag:=true;
      if interleave then               {output original 6809 code if requested}
       begin
         writeln(outfile);
         writeln(outfile,'* ',opc,' ':8-length(opc),opr2);
         comm_out:=comm_out+2;
       end;
      while (oprln[z]<>'')and(z<=5) do
       begin
        create_line(';',z);            {split off first line}
        replace('\',regnum,z);         {insert implied registers}
        replace('o',opr,z);            {insert instruction operand}
        t2:=oprln[z];
        if t2[1]='*' then
         diagnostic(warning,t2)
        else
         begin
          if t2[pos('.',t2)+1]=' ' then
           replace('.',siz,z);
          if label_flag then
            write(outfile,lbl,' ':10-length(lbl))
          else
            write(outfile,' ':10);
          write(outfile,oprln[z]);
          temp:=length(oprln[z]);
          if temp<20 then              {format comment provided it will fit}
           begin
            write(outfile,' ':22-temp);
            temp:=33;
           end
          else
           begin
            write(outfile,'   ');
            temp:=temp+14;
           end;
          if (label_flag)and(comment<>'') then
           begin
            temp:=81-temp;
            if length(comment)<temp then
              write(outfile,comment)
            else
              begin
               image:=copy(comment,1,temp-1);
               writeln(outfile,image);
               temp2:=length(comment)-temp+1;
               image:=copy(comment,temp,temp2);
               write(outfile,'*',' ':31,image);
              end;
            label_flag:=false;
           end;
          writeln(outfile);
          linesout:=linesout+1;
         end;
        z:=z+1;
       end;
end;
 
procedure check_comment(var y:integer);
begin
       {if no operand is expected, then any obtained through parsing must be}
       {part of the comment field. This is corrected here.}
       if pos('o',oprln[y])=0 then
        begin
         comment:=concat(opr,' ',comment);
         opr:='';
         opr2:=''
       end
end;

procedure convert;

label  endconvert;
 
begin
    for z:=0 to 5 do
     oprln[z]:='';

    if passthis then
     begin
      writeln(outfile,image);
      comm_out:=comm_out+1;
      comm_in:=comm_in+1;
      goto endconvert;
     end;

    if problem then goto endconvert;   {quit if fatal error already!}

    last1:=opc[lenopc];
    macro:=false;
    siz:='.B';
    temp:=0;

  if match2 then             {output result if match already found}
   begin
    oprln[0]:=expres2[posi-1];
    check_comment(temp);
    create_file;
   end
  else
   begin
    posi:=0;
    while (match=false)and(posi<=instnum)and(opcode[posi]<>'') do
     begin
      optab:=opcode[posi];
      lenoptab:=length(optab);
      if optab[1]='*' then
        begin           {must be an instruction group e.g LDA,LDB,LDS etc.,}
         if (lenopc=lenoptab) then
           begin
            tempop:=copy(optab,2,lenoptab-1);
            if (tempop=opc1t) then
             begin
              match:=true;
              if (last1='A')or(last1='B')then
                siz:='.B'
              else
               begin
                siz:='.W';
               end;
              case last1 of  {select registers - addrX,Y,U,S, data A,B,D}
                'A','X'     : regnum:='0';
                'B','Y'     : regnum:='1';
                'U'         : regnum:='5';
                'S'         : regnum:='6';
                'D'         : begin
                               regnum:='2';
                               D:=true
                              end;
               else
                diagnostic(error,'Invalid implied register')
                end;{case}
           end
        end
      end
     else
        begin
         if (opc=optab) then                 {not a group instruction }
           match:=true
         else
          begin
           z:=0;
           while(not match)and(z<=maxmacro)and(macr_name[z]<>'') do
            begin
             if opc=macr_name[z] then
              begin
               macro:=true;
               match:=true;
              end
             else
              z:=z+1
            end
          end
        end;
     posi:=posi+1;
    end;

    if problem then goto endconvert;

    if match then
     begin
      case index of      {assign addr reg no.}
       'X' : t:='0';
       'Y' : t:='1';
       'U' : t:='5';
       'S' : t:='6';
       'A','B','D','P','C' : t:='0';    {dummy to avoid case failure}
      end; {case}

      if D and(opc1t<>'PSH')and(opc1t<>'PUL') then
       begin               {add call to reg concat stub subroutine}
        oprln[temp]:='BSR ..DIN';
        temp:=temp+1
       end;
 
      if DPR then          {add call to shift DP for 8bit read}
       begin
        oprln[temp]:='BSR ..DPR;* CCR MODIFIED *';
        temp:=temp+1;
       end;

      if (auto<0)and(auto>-3)then
       begin
        if (((siz='.W')and(auto=-2))or((siz='.B')and(auto=-1)))
            and(opc1t<>'LEA')and(opc[1]<>'J')then
         opr:=concat('-',opr)
        else
         begin
          z:=auto+3;                {z=1 or 2}
          case z of
           1 : oprln[temp]:=concat('SUBQ.L #2,A',t);
           2 : oprln[temp]:=concat('SUBQ.L #1,A',t);
          end; {case}
          temp:=temp+1
         end;
       end;
 
      if macro then
        oprln[temp]:=concat(opc,' o ;')
      else
        oprln[temp]:=expres[posi-1];
 
      check_comment(temp);

      if opc='END' then                {special fudge for END}
       begin
        if opr='' then
         oprln[temp]:='END'
        else
         lbl:='..START'                {force application start address}
       end;

      {special case for instructions that do not support PCR addr mode}
      pos2:=pos('p',oprln[temp]);  {look for "no PCR addr mode" flag}
      if pos2<>0 then                  {replace PC with A2 if true}
       begin
        delete(oprln[temp],pos2,1);  {remove flag}
        pos2:=pos('(PC)',opr);
        if (pos2<>0)and(not indirect)then  {flag if PCR addr mode active}
         begin
          delete(opr,pos2,4);
          opr:=concat(opr,'(A2)');   {replace (PC) with (A2)}
                               {add code to get address of next instruction}
          oprln[temp]:=concat('LEA.L 0(PC),A2;',oprln[temp]);
          pcr:=true;
         end;
       end;
 
      if direct then     {add code to include DP reg (A4) into EA calculation}
       begin
        pos2:=pos('(',opr);
        if pos2<>0 then
         diagnostic(warning,'Mixed addressing mode - indexed assumed')
        else
         {add (A4) e.g. LDA <TEMP  :  MOVE.B  TEMP(A4),D0  }
         opr:=concat(opr,'(A4)');
      end;

      { special case for PSH/PUL instructions to handle PC/CC regs }
      if opc1t='PSH' then
       begin
        if (not cc)then replace('MOVE.W SR,-(A\);','',temp);
        if (not pc)then
          replace('LEA.L 0(PC),A3;MOVE.L A3,-(A\);','',temp);
        make_list(temp);
        if pos2=0 then replace('MOVEM.L ,-(A\)','',temp);
       end;
      if opc1t='PUL'then
       begin
        if (not cc)then replace('MOVE.W (A\)+,SR;','',temp);
        if (not pc)then
        replace('MOVE.L (A\)+,A3;JMP (A3);','',temp);
        make_list(temp);
        if pos2=0 then replace('MOVEM.L (A\)+,;','',temp);
       end;

      if indirect then
       begin
        oprln[temp+1]:=oprln[temp];      { copy translation to next entry }
        oprln[temp]:='MOVE.L o,A2';      { add MOVE.L opr,A2 }
        temp:=temp+1;
        replace('o','(A2)',temp);  { replace opr with (A2) in expres }
        replace('o','(A2)',temp);  { do twice to substitute all }
       end;                              { occurances}
 
       if optab[1]='*' then
        begin
         create_line('^',temp);
         if pos2<>0 then
          begin
           case last1 of
            'X','Y','S','U' : oprln[temp]:=oprln[temp+1];
           else
            begin end
           end; {case}
           oprln[temp+1]:='';
          end
       end;

     temp:=temp+1;
     if (auto>0)and(auto<3) then
      begin
       if (((siz='.W')and(auto=2))or((siz='.B')and(auto=1)))
        and(opc1t<>'LEA')and(opc[1]<>'J')then
        opr:=concat(opr,'+')
       else
        begin
         case auto of
          1 : oprln[temp]:=concat('ADDQ.L #1,A',t);
          2 : oprln[temp]:=concat('ADDQ.L #2,A',t);
         end; {case}
         t:=chr(auto+ord('0'));
        end;
       {special case for JSR & JMP to ensure auto incr occurs before jump}
        if opc='JSR' then
          begin
           oprln[temp]:=concat(oprln[temp],';BSR  ..JSR');
           oprln[temp-1]:=copy(oprln[temp-1],1,pos(';',oprln[temp-1])-1);
          end;
        if opc='JMP' then
          begin
           oprln[temp-1]:=oprln[temp];
           oprln[temp]:='JMP o ;';
           opr:=concat('-',t,opr);
          end;
        temp:=temp+1;
      end;
 
      {special case indicate Z flag state for LEAX & LEAY}
      if (opc1t='LEA')and((index='X')or(index='Y')) then
       begin
        oprln[temp]:='* Z-BIT NOT MODIFIED *';
        temp:=temp+1
       end;
 
      {add call to reg split stub subroutine}
      if D and(opc1t<>'PSH')and(opc1t<>'PUL') then
        oprln[temp]:='BSR ..DOUT';

      if DPW then oprln[temp]:='BSR ..DPW'; {add call to shift DP to MS byte}
 
      create_file;           {output resultant line to outfile}
     end
    else
     diagnostic(error,'Unable to translate')
   end;
endconvert: end;

procedure getstmt;           {get next line and parse}

label    endproc, endoperand;
 
var      i,j: integer;
         endofstring: boolean;
 
         procedure skipblanks;
 
                 begin  while not endofstring do begin
                             if image[i] <> ' ' then exit;
                             i := i + 1;
                             endofstring := i > length(image)
                             end
                        end;
 
         procedure skiptoblank;

                 begin  while not endofstring do begin
                             if image[i] = ' ' then exit;
                             i := i + 1;
                             endofstring := i > length(image)
                             end
                        end;

 
begin    lbl := '';
         opc := '';
         opr := '';
         opr2:= '';
         comment := '';
         passthis := false;
         endofstring := false;
         problem:=false;
         indirect:=false;
         direct:=false;
         match:=false;
         match2:=false;
         pcr:=false;
         A := false;
         B := false;
         DP:= false;
         CC:= false;
         X := false;
         Y := false;
         U := false;
         S := false;
         PC:= false;
         D := false;
         DPR:=false;
         DPW:=false;
         i := 1;
         auto:=0;
         index:='A';
         readln(infile,image);
         lines := lines + 1;
         if (lines mod 10)=0 then      {output status every 10 lines}
          begin
           writeln(lines-comm_in:8,linesout:15,errors:15,warnings:16);
           gotoxy(1,6);         {cursor line 6 col 1 }
          end;
 
        { ignore line numbers if present }
        if (length(image) > 0 ) and (image[1] in ['0'..'9']) then begin
                   skiptoblank;
                   delete(image,1,i);
                   i := 1
                   end;

         { check special bypass mode indicators }
         if image = '**PASS' then passflag := true;
         if image = '**PASSOFF' then passflag := false;
         if passflag then passthis := true;

         { skip empty or comment statements }
         if (image = blank)or(image[1]= '*')then
          begin
           passthis := true;
           goto endproc;
          end;
 
         {read label}
         if image[1] <> ' ' then begin
                   skiptoblank;
                   lbl := copy(image,1,i-1)
                   end;

         {read opcode}
         skipblanks;
         j := i;
         skiptoblank;
         opc := copy(image,j,i-j);

         if opc='MACR' then
          begin
           macr_name[count]:=lbl;
           if count<maxmacro then
             count:=count+1
           else
             diagnostic(error,'Too many macro names')
          end;
 
         { strip off unnecessary "L" in "LBxx" instructions }
 
         if((opc[1]='L')and(opc[2]='B'))then
           delete(opc,1,1);

         {read operand and determine if indirect mode is being used}
           skipblanks;                 {i := 1st char}
           if endofstring then goto endoperand;
           j := i;
           skiptoblank;                {i := 1st blank, starting from last i}
           if opc='FCC' then           {if FCC, string may contain spaces}
            begin
             t:=image[j];              {get opening delimiter}
             pos2:=j+1;
             while(image[pos2]<>t)and(pos2<=length(image)) do
               pos2:=pos2+1;           {find closing delimiter}
             if pos2<=length(image)then {if found, shift pointer to it}
              i:=pos2+1
            end;
           opr := copy(image,j,i-j);   {form operand}
           opr2:=opr;                  {keep a copy for "interleave" output}

           { remove redundant force extended ">" character }
           { or remove redundant force 8-bit offset "<" character }
           if(opr[1]='>')or((opr[1]='<')and(opr[2]='['))then
           delete(opr,1,1);

           skipblanks;                 {create comment field}
           if not endofstring then
             comment := copy(image,i,length(image)-i+1);

           indirect := (opr[1] = '[');
           if indirect then            {if flag is set, remove parentheses}
            begin
             delete(opr,pos('[',opr),1);
             delete(opr,pos(']',opr),1)
            end;


endoperand : if opc='NAM' then         {special fudge for NAM (IDNT) }
 begin
  lbl:=opr;
  opr:=''
 end;

                         {check for opcode in data base 2 (no operand change)}
   posi:=0;
   while (match2=false)and(posi<=instnum)and(opcode2[posi]<>'') do
    begin
     if opc=opcode2[posi] then
      begin
       match2:=true;
       lenopc:=length(opc);
      end;
     posi:=posi+1;
    end;

 if not match2 then                   {parse if match not already found}
  begin
   lenopc:=length(opc);
   opc1t:=copy(opc,1,(lenopc-1));{strip last char (may be an implied reg)}

         if (opc1t='PSH')or(opc1t='PUL')then   {now test for PSH/PUL and}
          begin                                {parse register list }
           pos2:=1;
           while pos2<>0 do
            begin
             t:=opr[pos2];
             case t of
              'A' : A:=true;
              'B' : B:=true;
              'X' : X:=true;
              'Y' : Y:=true;
              'U' : U:=true;
              'S' : S:=true;
              'D' : begin
                     if opr[pos2+1]='P'then      {decide between D & DP regs}
                      DP:=true
                     else
                      D:=true
                    end;
              'C' : CC:=true;
              'P' : PC:=true;
             else
              diagnostic(error,'Invalid PSH/PUL register')
             end; {case}
             pos2:=pos(',',opr);
             delete(opr,pos2,1);  {delete next (first) ','}
            end;
          end;

         {detect direct addr mode, and delete indicator }
             direct:=(opr[1]='<');
             if direct then delete(opr,1,1);

         {add preceding "," for opr= X,Y,U or S and warn of assumption}
         if (length(opr)=1)and(opc1t<>'PUL')and(opc1t<>'PSH')then
           begin
            case opr[1] of
             'X','Y','U','S' : begin
                                opr:=concat(',',opr);
                diagnostic(warning,'Indexed addr mode assumed in next inst.')
                               end;
            else
             begin end
            end    {case}
           end;
 
         { if operand is indexed convert 'offset,x' to 'offset(A0)',
           'offset,y' to 'offset(A1)', 'offset,u' to 'offset(A5)',
           and 'offset,s to 'offset(A6)'. Detect & strip autoincr/decr
           chars. Also include data reg for A,B,D (for EXG/TFR instr.) }
 
             j := pos(',',opr);
             if j > 0 then
                begin
   {ensure the effect of any "force 8-bit offset" characters (<) is removed!}
                  direct:=false;
                  while opr[j+1]='-' do    {detect & delete '-' chars}
                   begin
                    auto:=auto-1;
                    delete(opr,j+1,1)
                   end;
 
                  opr:=concat(opr,' ');  {necessary to ensure last char check}
                  for z:=2 to 3 do
                    if opr[j+z]='+' then auto:=auto+1; {detect '+' chars}

                  if (j=1)and(auto=0) then
                   begin
                    opr:=concat('0',opr);  {ensure valid offset!}
                    j:=j+1;
                   end;

                  index:=opr[j+1];
                  case index of
                     'X' : t2 :='(A0)';
                     'Y' : t2 :='(A1)';
                     'U' : t2 :='(A5)';
                     'S' : t2 :='(A6)';
                     'P' : begin
                            if (opc='EXG')or(opc='TFR')then
                              diagnostic(error,'PC not supported');
                            t2:='(PC)';
                           end;
                     'A' : t2 :='(D0)';
                     'B' : t2 :='(D1)';
                     'D' : begin
                            if opr[j+2]='P' then
                             begin
                              if opc='EXG' then
                                DPR:=true;
                              t2:='(D3)';
                              DPW:=true ;
                             end
                            else
                             begin
                              t2:='(D2)';
                              D:=true;
                             end
                           end;
                     'C' : begin
                            if opc='EXG' then
                             diagnostic(error,'CCR not supported');
                            t2:='(CCR)';
                           end;
                  else
                     diagnostic(error,'Invalid second (index) register')
                  end; {case}
                  opr := concat(copy(opr,1,j-1),t2);
                end;

         {detect acc offset addr mode and create opr }
         {i.e.  LDA A,Y ; <EA> = Y+A ; MOVE.B (A1,D0.W),D0  }
         {modify opr for EXG and TFR instructions (special cases) }
         {i.e.  EXG A,B ; <EA> = n/a ; EXG.L  D0,D1         }
                if (opc='EXG')or(opc='TFR') then
                   begin
                    case opr[1] of
                     'A' : insert('D0,',opr,j);
                     'B' : insert('D1,',opr,j);
                     'D' : begin
                            if opr[2]='P' then
                             begin
                              insert('D3,',opr,j);
                              DPR:=true;
                              if opc='EXG' then
                                DPW:=true;
                             end
                            else
                             begin
                              if opc='EXG' then
                               begin     {swop operands }
                                delete(opr,j,1);
                                delete(opr,j+2,1);
                                opr:=concat(opr,',(D2)');
                               end
                              else
                               insert('D2,',opr,j);
                              D:=true;
                             end
                           end;
                     'C' : begin
                            insert('SR,',opr,j);
                            if opc='EXG' then
                              diagnostic(error,'CCR not supported');
                           end;
                     'X' : insert('A0,',opr,j);
                     'Y' : insert('A1,',opr,j);
                     'U' : insert('A5,',opr,j);
                     'S' : insert('A6,',opr,j);
                    else
                     diagnostic(error,'Invalid first register')
                    end;  {case}
                    delete(opr,pos('(',opr),1);  {remove brackets}
                    delete(opr,pos(')',opr),1);
                    delete(opr,1,j-1);  {strip index register}
                   end
                else
                 begin
                  if j=2 then            {if only 1 char before ","}
                   begin
                    if(opr[1]='A')or(opr[1]='B')or(opr[1]='D')then
                     begin
                      case opr[1] of
                       'A': insert(',D0.W',opr,5);
                       'B': insert(',D1.W',opr,5);
                       'D': begin
                             insert(',D2.L',opr,5);
                             D:=true
                            end;
                      end;  {case}
                      delete(opr,1,1);      {strip first register}
                     end     {else must be a label}
                   end
                end;
 

         { convert 6800 type string to 68000 string }
         i:=pos('"',opr);              {find '"' char}
         if i<>0 then                  {replace with ' if found}
           opr[i]:='''';
         lenopr:=length(opr);
         if opr[lenopr]='"'then        {replace trailing " ,if any}
           opr[lenopr]:='''';
         i:=pos('''',opr);             {point to ' char}
         if(opr[i]='''')and(opr[lenopr]<>'''')then
           opr:=concat(opr,'''');      {ensure trailing ' char}
       end;
endproc: begin end;

{ writeln(lbl:10,opc:10,opr:10,comment:20,opc1t:10);
 writeln(image:30);      }
         end;


begin
blank := '';
passflag := false;
interleave:= false;
assign(infile,paramstr(1));
assign(outfile,paramstr(2));
assign(errorfile,'error.txt');
assign(codes,'codes.dbb');
assign(codes2,'codes2.dbb');
assign(stubxref,'stubxref.dbb');
{$I-}
rewrite(outfile);
if ioresult<>0 then
 begin
  writeln('Error : source and/or destination filename missing from command line');
  close(outfile);
  halt;
 end;
reset(infile);
if ioresult<>0 then
 begin
  writeln('Error : source file not found');
  close(infile);
  halt;
 end;
reset(codes);
reset(codes2);
reset(stubxref);
if ioresult<>0 then
 begin
  writeln('Error : database file(s) missing');
  close(codes);
  close(codes2);
  close(stubxref);
  halt;
 end;
{$I+}
rewrite(errorfile);
clrscr;                      {clear screen}
writeln('M6809 to M68000 Source Code Translator     Version ',version);
writeln('Systems Engg, E. Kilbride, Scotland');
writeln('Motorola Inc. Copyright 1986');
writeln;
writeln('Reading database ........');
for posi:=instnum downto 0 do          {clear opcode arrays}
 begin
  opcode[posi]:='';
  opcode2[posi]:='';
 end;
while not eof(codes) do                {read translation data base 1 }
  begin
   readln(codes,opcode[posi]);
   readln(codes,expres[posi]);
   posi:=posi+1
  end;
posi:=0;
while not eof(codes2) do {read translation data base 2 (operand not modified)}
  begin
   readln(codes2,opcode2[posi]);
   readln(codes2,expres2[posi]);
   posi:=posi+1
  end;
strg1:=paramstr(3);          {get command line option 'I'}
esc:=upcase(strg1[1]);
if esc='I' then interleave:=true;

gotoxy(1,5);          {cursor to line 5 col 1}
writeln('Code in':10,'Code out':15,'Errors':15,'Warnings':17);
lines := 0;
comm_in:=0;
linesout:=0;
comm_out:=2;
errors:= 0;
warnings:= 0;
count := 0;
for z:=0 to maxmacro do macr_name[z]:='';

writeln(outfile,'*++       ******   STUB EXTERNAL REFERENCES  ******');
writeln(outfile);

{ read stub XREF file (may be user modified) and merge with output file }
while not eof(stubxref) do
 begin
  readln(stubxref,image);
  writeln(outfile,' ':10,image);
  linesout:=linesout+1;
 end;

writeln(errorfile,' ':20,'*********  Translation Error List  ***********');
writeln(errorfile);
writeln(errorfile,'File in : File out');

while not eof(infile) do
 begin
  getstmt; { get next statement and parse }
  convert; { convert and output }
 end;
writeln(lines-comm_in:8,linesout:15,errors:15,warnings:16);
writeln;
close(infile);
close(outfile);
close(errorfile);
close(codes);
close(codes2);
close(stubxref);
end.
