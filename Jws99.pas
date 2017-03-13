Unit jws99;

{$D Win32 Библиотека обработки строк }

interface

uses Windows, Classes, StdCtrls, Messages, Forms,
SysUtils;


Type
  UkrChar = (UkrI, UkrJi, UkrE);
  UkrChars = Set of UkrChar;
  S_String = String[15];


Function GrivnaToStr(Grivna: LongInt; Kop: Word) : String;
Function DosToWinStr(DosStr : String): String;
Function WinToDosStr(WinStr : String): String;
Function UpCaseDosStr(DosStr: String) : String;
Function GetMonthStr(D : TDateTime; Mode : Byte): String;
Function GetYearStr(D: TDateTime): String; Export;
Function GetDayStr(D: TDateTime): String;
Function GetDayOfWeek(D: TDateTime): String;
Function DateToWinStr(D: TDateTime): String;
Function NewLengthStr(Str: String; Len: Byte): String;
Procedure ReplaceDosUkrChar(Var Str: String; CharsToReplace: UkrChars);
Procedure ReplaceWinUkrChar(Var Str: String; CharsToReplace: UkrChars);
Function UpCaseWinStr(WinStr: String) : String;
Function AllTrim(Str: String) : String;


Function TrimStr(SSSS : String) : String;
Function AllTrimStr(SSSS : String) : String;
Function CmpStr(SSSS1,SSSS2 : String) : Boolean;
Function UpCaseChar( CCCC : Char) : Char;
Function UpCaseStr( SSSS : String) : String;
Function SetStrLen(SSSS : String; Len : Byte) : String;
Function StrGrivna(Grivna: LongInt; Kop: Word) : String;

Function Dos2MyChar(DosChar:Char): Char;       { Replace Dos Cyr Chars }
Function Dos2MyString(DosStr:String): String;
Function My2DosChar(MyChar:Char): Char;        { Restore Dos Cyr Chars }
Function My2DosString(MyStr:String): String;
Function Win2DosChar(WinChar:Char): Char;      { Ansi to OEM Chars }
Function Win2DosString(WinStr:String): String;
Function Dos2WinChar(DosChar:Char): Char;      { OEM to Ansi Chars }
Function Dos2WinString(DosStr:String): String;
Function Win2MyChar(WinChar:Char): Char;       { Replace Win Cyr Chars }
Function Win2MyString(WinStr:String): String;
Function My2WinString(MyStr:String): String;   { Restore Win Cyr Chars }
Function My2WinChar(MyChar:Char): Char;
Function UpCaseDosChar( CCCC : Char) : Char;
//Function UpCaseDosStr( SSSS : String) : String;

//function KeyAccountNew(Account, MFO: string): string; //Control digit definition

Procedure WritePrn(Str: String);
Procedure WritelnPrn(Str: String);
Procedure PrintTextFile(TxtName: String);
Procedure PrnOpenBuffer;
Procedure PrnCloseBuffer;
procedure AppSingle;

Function AppPath(K: integer): string;

implementation

const
  ConstStrSpace = '                                                                                     ';
  MaxErrorCount: Byte = 2;

Var Lst: System.Text;
    PortName: string;
    App_Start_Path: String;
    I_: Byte;

function AppPath(K: integer): string;
begin
  App_Start_Path := ParamStr(K);
  I_ := Length(App_Start_Path);
  While (I_>0) and (App_Start_Path[I_] <> '\') do
  begin
    System.Delete(App_Start_Path, I_, 1);
    Dec(I_);
  end;
 result := App_Start_Path;
end;

{
function MoreOne(Value: integer): integer;
var Vals: string;
BEGIN
ValS:=IntToStr(Value);
IF (Value>9) then
  result:= StrToInt(Copy(ValS, length(Vals) ,1 ))
  else result:=Value;
END;

function KeyAccountNew(Account, MFO: string): string;
var Add, r1, r2, r3, i:integer;
begin
 WHILE Length(Account) < 14
  DO  Account := Account+'0';
  IF (length(MFO)<6) then begin
  MessageBeep(0);
//  Showmessage('╠╘╬ ьхэ№°х 6-Єш чэръ│т!');
  Exit;
  end;

Add:=0; i:=1;
{║Єю фы  ёўхЄр}{
while (i<14) do begin
 r1:= MoreOne(StrToInt(Copy(Account, i,1) )*3);
IF (i=4) then r2:=0 {control digit}{ else
  r2:= MoreOne(StrToInt(Copy(Account, i+1,1) )*7);
   IF (i=13) then r3:=0 else
    r3:= MoreOne(StrToInt(Copy(Account, i+2,1) )*1);

     Add:=Add+r1+r2+r3;
     r1:=0; r2:=0; r3:=0; i:=i+3;
     end;{while}
{║Єю фы  MFO}
{
i:=1;
while (i<6) do begin
 r1:= MoreOne(StrToInt(Copy(MFO, i,1) )*1);
  r2:= MoreOne(StrToInt(Copy(MFO, i+1,1) )*3);
   IF (i=4) then r3:=0 else
    r3:= MoreOne(StrToInt(Copy(MFO, i+2,1) )*7);

     Add:=Add+r1+r2+r3;
     r1:=0; r2:=0; r3:=0; i:=i+3;
     end;{while}
{
result := IntToStr(MoreOne(MoreOne(Add+14)*7));
  end;
}
Function GrivnaToStr(Grivna: LongInt; Kop: Word) : String;
begin
   GrivnaToStr := StrGrivna(Grivna, Kop);
end;

Function DosToWinStr(DosStr : String): String;
begin
   DosToWinStr := Dos2WinString(DosStr);
end;

Function WinToDosStr(WinStr : String): String;
begin
   WinToDosStr := Win2DosString(WinStr);
end;

Function UpCaseDosStr(DosStr: String) : String;
begin
   UpCaseDosStr:=UpCaseStr(DosStr);
end;

Function GetMonthStr(D : TDateTime; Mode : Byte): String;
var Y, M, Day : Word;
    S_tmp : String[2];
begin
  DecodeDate(D, Y, M, Day);

  if Mode = 0 then
  begin
    case M of
        1 : GetMonthStr :='сўчень';
        2 : GetMonthStr :='лютий';
        3 : GetMonthStr :='березень';
        4 : GetMonthStr :='квўтень';
        5 : GetMonthStr :='травень';
        6 : GetMonthStr :='червень';
        7 : GetMonthStr :='липень';
        8 : GetMonthStr :='серпень';
        9 : GetMonthStr :='вересень';
       10 : GetMonthStr :='жовтень';
       11 : GetMonthStr :='листопад';
       12 : GetMonthStr :='грудень';
     else GetMonthStr :='';
   end;
  end;

  if Mode = 1 then
  begin
    case M of
       1 : GetMonthStr :='сўчня';
       2 : GetMonthStr :='лютого';
       3 : GetMonthStr :='березня';
       4 : GetMonthStr :='квўтня';
       5 : GetMonthStr :='травня';
       6 : GetMonthStr :='червня';
       7 : GetMonthStr :='липня';
       8 : GetMonthStr :='серпня';
       9 : GetMonthStr :='вересня';
      10 : GetMonthStr :='жовтня';
      11 : GetMonthStr :='листопаду';
      12 : GetMonthStr :='грудня';
      else GetMonthStr :='';
    end;
  end;

  if Mode > 1 then
  begin
    Str(M:2, S_tmp);
    if S_tmp[1] = ' ' then S_tmp[1] := '0';
    if M = 0 then S_tmp := '';
    GetMonthStr := S_tmp;
  end;
end;

Function GetYearStr(D: TDateTime): String;
var Y, M, Day : Word;
    S_tmp : String[4];
begin
  DecodeDate(D, Y, M, Day);
  Str(Y, S_tmp);
  GetYearStr := S_tmp;
end;

Function GetDayStr(D: TDateTime): String;
var Y, M, Day : Word;
    S_tmp : String[2];
begin
  DecodeDate(D, Y, M, Day);
  Str(Day:2, S_tmp);
  if S_tmp[1] = ' ' then S_tmp[1] := '0';
  GetDayStr := S_tmp;
end;

Function GetDayOfWeek(D: TDateTime): String;
var I_Tmp : Integer;
begin
  I_Tmp := DayOfWeek(D);
  Case I_Tmp of
    1: GetDayOfWeek := 'недўля';
    2: GetDayOfWeek := 'понедўлок';
    3: GetDayOfWeek := 'вўвторок';
    4: GetDayOfWeek := 'середа';
    5: GetDayOfWeek := 'четвер';
    6: GetDayOfWeek := 'п`ятниця';
    7: GetDayOfWeek := 'субота';
    else GetDayOfWeek := '';
  end;
end;

Function DateToWinStr(D: TDateTime): String;
begin
  DateToWinStr := GetDayStr(D)+' '+ DosToWinStr(GetMonthStr(D,1))+
  ' '+ GetYearStr(D) +' p.';
end;

Function NewLengthStr(Str: String; Len: Byte): String;
begin
  NewLengthStr := SetStrLen(Str, Len);
end;

Procedure ReplaceDosUkrChar(Var Str: String; CharsToReplace: UkrChars);
var I, J : Byte;
begin
  J := Length(Str);

  if (CharsToReplace * [UkrI]) <> []  then
  for I := 1 to J do
  begin
    if Str[I] = 'ў' then  Str[I] := 'i';
    if Str[I] = 'Ў' then  Str[I] := 'I';
  end;

  if (CharsToReplace * [UkrJi]) <> []  then
  for I := 1 to J do
  begin
    if Str[I] = '∙' then  Str[I] := 'i';
    if Str[I] = '°' then  Str[I] := 'I';
  end;

  if (CharsToReplace * [UkrE]) <> []  then
  for I := 1 to J do
  begin
    if Str[I] = 'ї' then  Str[I] := 'е';
    if Str[I] = 'Ї' then  Str[I] := 'Е';
  end;
end;

Procedure ReplaceWinUkrChar(Var Str: String; CharsToReplace: UkrChars);
var I, J : Byte;
begin
  J := Length(Str);

  if (CharsToReplace * [UkrI]) <> []  then
  for I := 1 to J do
  begin
    if Str[I] = '│' then  Str[I] := 'i';
    if Str[I] = '▓' then  Str[I] := 'I';
  end;

  if (CharsToReplace * [UkrJi]) <> []  then
  for I := 1 to J do
  begin
    if Str[I] = '┐' then  Str[I] := 'i';
    if Str[I] = 'п' then  Str[I] := 'I';
  end;

  if (CharsToReplace * [UkrE]) <> []  then
  for I := 1 to J do
  begin
    if Str[I] = '║' then  Str[I] := 'х';
    if Str[I] = 'к' then  Str[I] := '┼';
  end;
end;

Function UpCaseWinStr(WinStr: String) : String;
begin
   UpCaseWinStr := DosToWinStr(UpCaseStr(WinToDosStr(WinStr)));
end;

Function AllTrim(Str: String) : String;
begin
   AllTrim := AllTrimStr(Str);
end;

{Embedded #1}

Function TrimStr(SSSS : String) : String;
var BBB : byte;
    SSOut : string;
begin
  {$V-}
  SSOut := SSSS;
  BBB := Length(SSOut);
//  showmessage(ssout+IntToStr(bbb));
  IF (BBB>0) then
  while ((SSOut[BBB]=' ') and (BBB>0)) do
  begin
    Delete(SSOut,BBB,1);
    dec(BBB);
  end;

  BBB := Pos('  ', SSOut);
  while (BBB>0) do
  begin
    Delete(SSOut,BBB,1);
    BBB := Pos('  ', SSOut);
  end;

  BBB := Pos(' ,', SSOut);
  while (BBB>0) do
  begin
    Delete(SSOut,BBB,1);
    BBB := Pos(' ,', SSOut);
  end;

  TrimStr := SSOut;
  {$V+}
end;

Function AllTrimStr;
var BBB : byte;
    SSOut : string;
begin
  {$V-}

  SSOut := SSSS;
  BBB := Length(SSOut);
  while (SSout[BBB]=' ') and (BBB>0) do
  begin
    Delete(SSOut,BBB,1);
    dec(BBB);
  end;

  while (Length(SSOut)>0) AND (SSOut[1] =' ') do
    Delete(SSOut,1,1);

  AllTrimStr := SSOut;
  {$V+}
end;

Function CmpStr;
begin
  {$V-}
  if ( Length(TrimStr(SSSS2)) > 0 ) AND
     (Pos(TrimStr(SSSS2), SSSS1) < 1 )
       then CmpStr := False
       else CmpStr :=True;
  {$V+}
end;

Function UpCaseChar;
Var CCCTmp : Char;
begin
  CCCTmp := CCCC;
    if CCCTmp in ['a'..'z'] then
          CCCTmp := Chr(Ord(CCCTmp)-32);
    if CCCTmp in ['а'..'п'] then
          CCCTmp := Chr(Ord(CCCTmp)-32);
    if CCCTmp in ['р'..'я'] then
          CCCTmp := Chr(Ord(CCCTmp)-80);
    if CCCTmp = 'ў' then CCCTmp := 'Ў';
    if CCCTmp = '∙' then CCCTmp := '°';
    if CCCTmp = 'ї' then CCCTmp := 'Ї';
    if CCCTmp = 'є' then CCCTmp := 'Є';
    if CCCTmp = 'ё' then CCCTmp := 'Ё';
  UpCaseChar := CCCTmp;
end;

Function UpCaseStr;
Var SSSTmp : String;
    BBBTmp : Byte;
begin
  {$V-}
  SSSTmp := SSSS;
  for BBBTmp := 1 to Length(SSSTmp) do
    SSSTmp[BBBTmp] := UpCaseChar(SSSTmp[BBBTmp]);
  UpCaseStr := SSSTmp;
  {$V+}
end;

Function SetStrLen;
begin
  SetStrLen := Copy(SSSS+ConstStrSpace+ConstStrSpace+ConstStrSpace, 1, Len);
end;


Function StrGrivna(Grivna: LongInt; Kop: Word) : String;
var S_Result, S_Tmp : String;

Function S_Grivna(S_Tmp : String): String;
var S_Tmp2, S_Tmp3 : String;
    I : Byte;

function As1W(Ch : Char): S_String;
begin
  Case Ch of
   '1': As1W := 'одна';
   '2': As1W := 'двў';
   '3': As1W := 'три';
   '4': As1W := 'чотири';
   '5': As1W := 'п`ять';
   '6': As1W := 'шўсть';
   '7': As1W := 'сўм';
   '8': As1W := 'вўсўм';
   '9': As1W := 'дев`ять';
   '0': As1W := '';
    else As1W := 'Error in As1W';
  end;
end;

function As1M(Ch : Char): S_String;
begin
  Case Ch of
   '1': As1M := 'один';
   '2': As1M := 'два';
   '3'..'9','0': As1M := As1W(Ch);
    else As1M := 'Error in As1M';
  end;
end;

function As1019(Ch : Char): S_String;
begin
  Case Ch of
   '0'            : As1019 := 'десять';
   '1'            : As1019 := 'одинадцять';
   '2','3','7','8': As1019 := As1M(Ch)+'надцять';
   '4'            : As1019 := 'чотирнадцять';
   '5'            : As1019 := 'п`ятнадцять';
   '6'            : As1019 := 'шўстнадцять';
   '9'            : As1019 := 'дев`ятнадцять';
    else As1019 := 'Error in As1019';
  end;
end;

function As20(Ch : Char): S_String;
begin
  Case Ch of
   '2': As20 := 'двадцять';
   '3': As20 := 'тридцять';
   '4': As20 := 'сорок';
   '5': As20 := 'п`ятдесят';
   '6': As20 := 'шўстдесят';
   '7': As20 := 'сўмдесят';
   '8': As20 := 'вўсўмдесят';
   '9': As20 := 'дев`яносто';
   '0': As20 := '';
    else As20 := 'Error in As20';
  end;
end;

function As100(Ch : Char): S_String;
begin
  Case Ch of
   '1': As100 := 'сто';
   '2': As100 := 'двўстў';
   '3': As100 := 'триста';
   '4': As100 := 'чотириста';
   '5': As100 := 'п`ятсот';
   '6': As100 := 'шўстсот';
   '7': As100 := 'сўмсот';
   '8': As100 := 'вўсўмсот';
   '9': As100 := 'дев`ятсот';
   '0': As100 := '';
    else As100 := 'Error in As100';
  end;
end;

function AsGrivna(Ch : Char): S_String;
begin
  Case Ch of
   '1'            : AsGrivna := 'гривня';
   '2'..'4'       : AsGrivna := 'гривнў';
    else            AsGrivna := 'гривень';
  end;
end;

function As1000(Ch : Char): S_String;
begin
  Case Ch of
   '1'            : As1000 := 'тисяча';
   '2'..'4'       : As1000 := 'тисячў';
    else            As1000 := 'тисяч';
  end;
end;

function As1E6(Ch : Char): S_String;
begin
  Case Ch of
   '1'            : As1E6 := 'мўльйон';
   '2'..'4'       : As1E6 := 'мўльйони';
    else            As1E6 := 'мўльйонўв';
  end;
end;

begin
  I := Length(S_Tmp);

    (*-------------  единицы - сотни  -----------------*)

  if (I>1) AND (S_Tmp[I-1]='1') then S_Tmp2 := As1019(S_Tmp[I])
                                else S_Tmp2 := As1W(S_Tmp[I]);
  if (I>1) AND (S_Tmp[I-1]<>'1') then S_Tmp2 := As20(S_Tmp[I-1])+ ' '+ S_Tmp2;

  if (I>2) then S_Tmp2 := As100(S_Tmp[I-2])+ ' '+ S_Tmp2;

  S_Tmp3 := '';

   (*--------------  тысячи - сотни тысяч  ------------*)

  if I>3 then
  begin
    if (I>4) AND (S_Tmp[I-4]='1') then S_Tmp3 := As1019(S_Tmp[I-3])
                                else S_Tmp3 := As1W(S_Tmp[I-3]);
    if (I>4) AND (S_Tmp[I-4]<>'1') then S_Tmp3 := As20(S_Tmp[I-4])+ ' '+ S_Tmp3;

    if (I>5) then S_Tmp3 := As100(S_Tmp[I-5])+ ' '+ S_Tmp3;

    if TrimStr(S_Tmp3) <> '' then
    begin
      if ((I>4) AND (S_Tmp[I-4]<>'1')) OR (I=4) then
         S_Tmp3 := S_Tmp3 +' '+As1000(S_Tmp[I-3])
         else S_Tmp3 := S_Tmp3 +' тисяч';
      S_Tmp2 := S_Tmp3 +' '+ S_Tmp2;
    end;
  end;

   (*--------------  миллионы - сотни миллионов  ------------*)

  if I>6 then
  begin
    S_Tmp3 := '';
    if (I>7) AND (S_Tmp[I-7]='1') then S_Tmp3 := As1019(S_Tmp[I-6])
                                else S_Tmp3 := As1M(S_Tmp[I-6]);
    if (I>7) AND (S_Tmp[I-7]<>'1') then S_Tmp3 := As20(S_Tmp[I-7])+ ' '+ S_Tmp3;

    if (I>8) then S_Tmp3 := As100(S_Tmp[I-8])+ ' '+ S_Tmp3;

    if TrimStr(S_Tmp3) <> '' then
    begin
      if ((I>7) AND (S_Tmp[I-7]<>'1')) OR (I=7) then
         S_Tmp3 := S_Tmp3 +' '+As1E6(S_Tmp[I-6])
         else S_Tmp3 := S_Tmp3 +' мўльйонўв';
      S_Tmp2 := S_Tmp3 +' '+ S_Tmp2;
    end;
  end;

   (*-------------------  миллиарды  ----------------------*)

  if I=10 then
  begin
    S_Tmp3 := '';
    if S_Tmp[1] ='1' then S_Tmp3 := 'один мўльярд';
    if S_Tmp[1] ='2' then S_Tmp3 := 'два мўльярди';
    S_Tmp2 := S_Tmp3+' '+S_Tmp2;
  end;

   (*----------------------------------------------------*)

  if TrimStr(S_Tmp2) = '' then S_Tmp2 := 'нуль';

  if ((I>1) AND (S_Tmp[I-1]<>'1')) OR (I=1) then
     S_Tmp2 := S_Tmp2 +' '+AsGrivna(S_Tmp[I])
     else S_Tmp2 := S_Tmp2 +' гривень';
  S_Grivna := TrimStr(S_Tmp2);
end;

begin
  Str(Abs(Grivna), S_Tmp);
  S_Result := S_Grivna(S_Tmp);
  Str(Kop :2, S_Tmp);
  if S_Tmp[1]=' ' then S_Tmp[1] := '0';
  if Grivna<0 then S_Result := 'мўнус '+ S_Result;
  S_Result := S_Result +' '+S_Tmp;
  Case Kop of
    1,21,31,41,51,61,71,81,91: S_Tmp := 'копўйка';
    2..4,22..24,32..34,42..44,52..54,62..64,72..74,82..84,92..94: S_Tmp := 'копўйки';
    else S_Tmp := 'копўйок'
  end;
  StrGrivna := S_Result +' '+S_Tmp;
end;


Function Dos2MyChar(DosChar:Char): Char;
var
  ChTmp : Char;
begin
  ChTmp := DosChar;
  Case ChTmp of
    'a'..'z' : ChTmp := Chr(Ord(ChTmp)-32);
    'А'..'Я' : ChTmp := Chr(Ord(ChTmp)-37);
    'а'..'п' : ChTmp := Chr(Ord(ChTmp)-69);
    'р'..'я' : ChTmp := Chr(Ord(ChTmp)-117);
    'Ё'..'ё' : ChTmp := '`';
    'Є'..'є' : ChTmp := '^';
    'Ї'..'ї' : ChTmp := '{';
    'Ў'..'ў' : ChTmp := '|';
    '°'..'∙' : ChTmp := '}';
  end;
  if DosChar in ['Б','б'] then ChTmp := '$';
  if DosChar in ['Д','д'] then ChTmp := '~';
  Dos2MyChar := ChTmp;
end;

Function Dos2MyString(DosStr:String): String;
Var SSSTmp : String;
    BBBTmp : Byte;
begin
  SSSTmp := DosStr;
  for BBBTmp := 1 to Length(SSSTmp) do
    SSSTmp[BBBTmp] := Dos2MyChar(SSSTmp[BBBTmp]);
  Dos2MyString := SSSTmp;
end;

Function My2DosChar(MyChar:Char): Char;
var
  ChTmp : Char;
begin
  ChTmp := MyChar;
  Case ChTmp of
    '['..'z' : ChTmp := Chr(Ord(ChTmp)+37);
    '{'      : ChTmp := 'Ї';
    '|'      : ChTmp := 'Ў';
    '}'      : ChTmp := '°';
  end;
  if MyChar = '$' then ChTmp := 'Б';
  if MyChar = '~' then ChTmp := 'Д';
  if MyChar = '\' then ChTmp := '\';
  if MyChar = '_' then ChTmp := '_';
  My2DosChar := ChTmp;
end;

Function My2DosString(MyStr:String): String;
Var SSSTmp : String;
    BBBTmp : Byte;
begin
  SSSTmp := MyStr;
  for BBBTmp := 1 to Length(SSSTmp) do
    SSSTmp[BBBTmp] := My2DosChar(SSSTmp[BBBTmp]);
  My2DosString := SSSTmp;
end;

Function Win2DosChar(WinChar:Char): Char;
var
  ChTmp : Char;
begin
  ChTmp := WinChar;
  Case ChTmp of
    #170       : ChTmp := #244 { Ї };
    #175       : ChTmp := #248 { ° };
    #178       : ChTmp := #246 { Ў };
    #179       : ChTmp := #247 { ў };
    #186       : ChTmp := #245 { ї };
    #191       : ChTmp := #249 { ∙ };
    #192..#239 : ChTmp := Chr(Ord(ChTmp)-64); { #128..#175, 'А'-'Я', 'а'-'п' }
    #240..#255 : ChTmp := Chr(Ord(ChTmp)-16); { #224..#239,'р'-'я' }
  end;
  Win2DosChar := ChTmp;
end;

Function Win2DosString(WinStr:String): String;
Var SSSTmp : String;
    BBBTmp : Byte;
begin
  SSSTmp := WinStr;
  for BBBTmp := 1 to Length(SSSTmp) do
    SSSTmp[BBBTmp] := Win2DosChar(SSSTmp[BBBTmp]);
  Win2DosString := SSSTmp;
end;

Function Dos2WinChar(DosChar:Char): Char;
var
  ChTmp : Char;
begin
  ChTmp := DosChar;
  Case ChTmp of
    #128..#175 : ChTmp := Chr(Ord(ChTmp)+64); { 'А'-'Я', 'а'-'п' }
    #176..#178 : ChTmp := ' ';
    #179..#182 : ChTmp := '|';
    #183..#184 : ChTmp := '+';
    #185..#186 : ChTmp := '|';
    #187..#194 : ChTmp := '+';
    #195       : ChTmp := '|';
    #196       : ChTmp := '-';
    #197       : ChTmp := '-';
    #198..#199 : ChTmp := '|';
    #200..#203 : ChTmp := '+';
    #204       : ChTmp := '|';
    #205       : ChTmp := '-';
    #206..#218 : ChTmp := '+';
    #219..#223 : ChTmp := ' ';
    #224..#239 : ChTmp := Chr(Ord(ChTmp)+16); { 'р'-'я' }
    #244       : ChTmp := #170 { Ї };
    #245       : ChTmp := #186 { ї };
    #246       : ChTmp := #178 { Ў };
    #247       : ChTmp := #179 { ў };
    #248       : ChTmp := #175 { ° };
    #249       : ChTmp := #191 { ∙ };
    #252       : ChTmp := 'N';
  end;
  Dos2WinChar := ChTmp;
end;

Function Dos2WinString(DosStr:String): String;
Var SSSTmp : String;
    BBBTmp : Byte;
begin
  SSSTmp := DosStr;
  for BBBTmp := 1 to Length(SSSTmp) do
    SSSTmp[BBBTmp] := Dos2WinChar(SSSTmp[BBBTmp]);
  Dos2WinString := SSSTmp;
end;

Function Win2MyChar(WinChar:Char): Char;
begin
  Win2MyChar := Dos2MyChar(Win2DosChar(WinChar));
end;

Function Win2MyString(WinStr:String): String;
begin
  Win2MyString := Dos2MyString(Win2DosString(WinStr));
end;

Function My2WinChar(MyChar:Char): Char;
begin
  My2WinChar := Dos2WinChar(My2DosChar(MyChar));
end;

Function My2WinString(MyStr:String): String;
begin
  My2WinString := Dos2WinString(My2DosString(MyStr));
end;

Function UpCaseDosChar;
Var CCCTmp : Char;
begin
  CCCTmp := CCCC;
    if CCCTmp in ['a'..'z'] then
          CCCTmp := Chr(Ord(CCCTmp)-32);
    if CCCTmp in ['а'..'п'] then
          CCCTmp := Chr(Ord(CCCTmp)-32);
    if CCCTmp in ['р'..'я'] then
          CCCTmp := Chr(Ord(CCCTmp)-80);
    if CCCTmp = 'ў' then CCCTmp := 'Ў';
    if CCCTmp = '∙' then CCCTmp := '°';
    if CCCTmp = 'ї' then CCCTmp := 'Ї';
    if CCCTmp = 'є' then CCCTmp := 'Є';
    if CCCTmp = 'ё' then CCCTmp := 'Ё';
  UpCaseDosChar := CCCTmp;
end;

{Function UpCaseDosStr;
Var SSSTmp : String;
    BBBTmp : Byte;
begin
  {$V-}
{  SSSTmp := SSSS;
  for BBBTmp := 1 to Length(SSSTmp) do
    SSSTmp[BBBTmp] := UpCaseDosChar(SSSTmp[BBBTmp]);
  UpCaseDosStr := SSSTmp;
  {$V+}
{end;}

Procedure WritePrn(Str: String);
begin
  {$I-}
  Write(Lst, Str);
  if IOResult <> 0 then ErrorAddr := Nil;
  {$I+}
end;

Procedure WritelnPrn(Str: String);
begin
  {$I-}
  Writeln(Lst, Str);
  if IOResult <> 0 then ErrorAddr := Nil;
  {$I+}
end;

Procedure PrintTextFile(TxtName: String);
Var Txt: System.Text;
    ErrorCount : Byte;
    Str : String;
begin
   PrnOpenBuffer;
  ErrorCount := 0;
  {$I-}
  System.Assign(Txt, TxtName);
  System.Reset(Txt);
  {$I+}
  if IOResult <> 0 then
  begin
    ErrorAddr := Nil;
    Exit;
  end;
  {$I-}
  While NOT eof(Txt) do
  begin
    Readln(Txt, Str);
    Writeln(Lst, Str);
    if IOResult <> 0 then
    begin
      ErrorAddr := Nil;
      Inc(ErrorCount);
    end;
    if ErrorCount >= MaxErrorCount then Break;
  end;
  System.Close(Txt);
  if IOResult <> 0 then ErrorAddr := Nil;
  {$I+}
  PrnCloseBuffer;
end;

Procedure PrnOpenBuffer;
begin
//  System.Close(Lst);
  System.Assign(Lst,'LPT1');
  System.Rewrite(Lst);
end;

Procedure PrnCloseBuffer;
begin
  System.Close(Lst);
  System.Assign(Lst,'LPT1');
  System.Rewrite(Lst);
end;

procedure AppSingle;
begin
  if HPrevInst > 0 then Application.Terminate;
end;

begin
// LPT1 interceptor !
{  System.Assign(Lst,'LPT1');
  System.Rewrite(Lst);
  System.Close(Lst);}
end.

