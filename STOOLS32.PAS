
unit sTools32;

interface

uses SysUtils, Classes, StdCtrls, WinProcs, WinTypes, Messages,
  Forms;

function Path(P: String): String;
function Replicate(C: Char; N: Byte): String;

// Using exception handling
procedure File2File(const FName1, FName2: TFileName); //Always overwrite
procedure FileDel(const Mask: TFileName);
procedure FileCopy(const Mask: TFileName; Dir2: TFileName); //Always overwrite
procedure FileMove(const Mask: TFileName; Dir2: TFileName); //Always overwrite
function DirExist(Mask: TFileName): Boolean;
function FileExist(Mask: TFileName): Boolean;


// Using error code
function CopyFile(FName1: TFileName; Dir2: TFileName): Boolean;
function DelFile(FName1: TFileName): Boolean;
function MoveFile(FName1: TFileName; Dir2: TFileName): Boolean;
function FileName(FName: TFileName): TFileName; // Returns filename without extention
function FileSize(FName: TFileName): Integer;
function CopyFileToFile(FName1, FName2: TFileName): Boolean;

function InsertDiv(S: String): String;
function InsertDiv2(S: String): String;
function RemoveDiv(S: String): String;

procedure Beep;
procedure Kill(var AnObject);
procedure SendKey(Win: THandle; VKey: Integer; State: TShiftState);
procedure Pause(Sec100: Longint);
procedure CreateProcessNoWait(const AppPath, AppParams: String; Visibility: word);
function CreateProcessAndWait(const AppPath, AppParams: String; Visibility: word): DWord;

function ToOem(S: String): String;
function ToAnsi(S: String): String;
procedure LinesToOem(L: TStrings);
procedure LinesToAnsi(L: TStrings);


implementation

function Path(P: String): String;
begin
  if P <> '' then if P[Length(P)] <> '\' then P := P + '\';
  Result := P;
end;

function Replicate(C: Char; N: Byte): String;
var
  S: String;
begin
  SetLength(S, N);
  FillChar(S[1], N, C);
  Replicate := S;
end;

procedure Beep;
begin
  MessageBeep(MB_ICONASTERISK);
end;


procedure SetDateTime(const FName1, FName2: TFileName); // not debugged
var
  FHandle1, FHandle2: Integer;
  DateTime: Longint;
begin
  {$I-}
  FHandle1 := FileOpen(FName1, fmOpenRead);
  if FHandle1 < 0 then raise Exception.Create('I/O error');
  try
    FHandle2 := FileOpen(FName2, fmOpenRead);
    if FHandle2 < 0 then raise Exception.Create('I/O error');
    try
      DateTime := FileGetDate(FHandle1);
      FileSetDate(FHandle2, DateTime);
    finally
      FileClose(FHandle2);
    end;
  finally
    FileClose(FHandle1);
  end;
end;

procedure File2File(const FName1, FName2: TFileName);
var
  F1, F2: TFileStream;
  D: Longint;
  S: String;
const
  T: Word = 0;
begin
  F1 := nil;
  F2 := nil;
  try
    F1 := TFileStream.Create(FName1, fmOpenRead);
    F2 := TFileStream.Create(FName2, fmCreate);
    F2.CopyFrom(F1, F1.Size);
    D := FileGetDate(F1.Handle);
    S := DateToStr(FileDateToDateTime(D));
    T := FileSetDate(F2.Handle, FileGetDate(F1.Handle));
  finally
    F1.Free;
    F2.Free;
//    SetDateTime(FName1, FName2);
  end;
end;

procedure FileDel(const Mask: TFileName);
var
  R: TSearchRec;
  E: Word;
  Dir1: TFileName;
begin
  E := FindFirst(Mask, faArchive, R);
  try
    if E <> 2 then
    begin
      Dir1 := ExtractFilePath(Mask);
      while E = 0 do
      begin
        if not SysUtils.DeleteFile(Dir1 + R.Name) then
          raise Exception.Create('Cannot delete file ' + Dir1 + R.Name);
        E := FindNext(R);
      end;
    end;
  finally
    SysUtils.FindClose(R);
  end;
end;

procedure FileCopy(const Mask: TFileName; Dir2: TFileName);
var
  R: TSearchRec;
  E: Word;
  Dir1: String;
begin
  Dir2 := Path(Dir2);
  E := FindFirst(Mask, faArchive, R);
  try
    if E <> 2 then
    begin
      Dir1 := ExtractFilePath(Mask);
      while E = 0 do
      begin
        File2File(Dir1 + R.Name, Dir2 + R.Name);
        E := FindNext(R);
      end;
    end;
  finally
    SysUtils.FindClose(R);
  end;
end;

procedure FileMove(const Mask: TFileName; Dir2: TFileName);
var
  R: TSearchRec;
  E: Word;
  Dir1: String;
begin
  Dir2 := Path(Dir2);
  E := FindFirst(Mask, faArchive, R);
  try
    if E <> 2 then
    begin
      Dir1 := ExtractFilePath(Mask);
      while E = 0 do
      begin
        File2File(Dir1 + R.Name, Dir2 + R.Name);
        if not SysUtils.DeleteFile(Dir1 + R.Name) then
          raise Exception.Create('Cannot delete file ' + Dir1 + R.Name);
        E := FindNext(R);
      end;
    end;
  finally
    SysUtils.FindClose(R);
  end;
end;

function DirExist(Mask: TFileName): Boolean;
var
  DirInfo: TSearchRec;
begin
  try
    if FindFirst(Mask, faDirectory, DirInfo) <> 0 then
      DirExist := False else DirExist := True;
  finally
    SysUtils.FindClose(DirInfo);
  end;
end;

function FileExist(Mask: TFileName): Boolean;
var
  DirInfo: TSearchRec;
begin
  try
    if FindFirst(Mask, faArchive, DirInfo) <> 0 then
      FileExist := False else FileExist := True;
  finally
    SysUtils.FindClose(DirInfo);
  end;
end;






function CopyFile(FName1: TFileName; Dir2: TFileName): Boolean;
var
  DirInfo: TSearchRec;
  D: String;
  EC: Word;
begin
  Result := False;
  EC := FindFirst(FName1, faArchive, DirInfo);
  if (EC <> 0) and (EC <> 2) then Exit;
  D := ExtractFilePath(FName1);
  while EC = 0 do
  begin
    if not CopyFileToFile(D + DirInfo.Name, Dir2 + DirInfo.Name) then Exit;
    EC := FindNext(DirInfo);
  end;
  CopyFile := True;
end;

function DelFile(FName1: TFileName): Boolean;
var
  DirInfo: TSearchRec;
  D: String;
  EC: Word;
begin
  Result := False;
  EC := FindFirst(FName1, faArchive, DirInfo);
  if EC <> 0 then Exit;
  D := ExtractFilePath(FName1);
  while EC = 0 do
  begin
    if not SysUtils.DeleteFile(D + DirInfo.Name) then Exit;
    EC := FindNext(DirInfo);
  end;
  DelFile := True;
end;

function MoveFile(FName1: TFileName; Dir2: TFileName): Boolean;
label
  Fault;
var
  DirInfo: TSearchRec;
  D: String;
  EC: Word;
begin
  EC := FindFirst(FName1, faArchive, DirInfo);
  if EC <> 2 then
  begin
    if EC <> 0 then goto Fault;
    D := ExtractFilePath(FName1);
    if Dir2[Length(Dir2)] <> '\' then Dir2 := Dir2 + '\';
    while EC = 0 do
    begin
      CopyFileToFile(D + DirInfo.Name, Dir2 + DirInfo.Name);
      if IOResult <> 0 then goto Fault;
      SysUtils.DeleteFile(D + DirInfo.Name);
      EC := FindNext(DirInfo);
    end;
  end;
  MoveFile := True;
  Exit;
Fault:
  MoveFile := False;
end;

function CopyFileToFile(FName1, FName2: TFileName): Boolean;
var
  F1, F2: TFileStream;
begin
  Result := False;
  F1 := nil;
  try
    F1 := TFileStream.Create(FName1, fmOpenRead);
    F2 := TFileStream.Create(FName2, fmCreate);
    try
      F2.CopyFrom(F1, F1.Size);
      Result := True;
    finally
      F1.Free;
      F2.Free;
    end;
  except
    F1.Free;
  end;
end;

function FileName(FName: TFileName): TFileName;
begin
  Result := Copy(ExtractFileName(FName), 1, Pos('.', FName) - 1);
end;

function FileSize(FName: TFileName): Integer;
var
  F: TFileStream;
begin
  Result := 0;
  F := nil;
  try
    F := TFileStream.Create(FName, fmOpenRead);
    Result := F.Size;
  finally
    F.Free;
  end;
end;



function InsertDiv(S: String): String;
var
  C, I: Byte;
  R: String;
begin
  R := '';
  C := 0;
  for I := Length(S) downto 1 do
  begin
    if S[I] = ' ' then Continue;
    Inc(C);
    Insert(S[I], R, 1);
    if (C = 3) and (I <> 1) then
    begin
      Insert(',', R, 1);
      C := 0;
    end;
  end;
  InsertDiv := R;
end;

function InsertDiv2(S: String): String;
var
  C, I, SChar: Byte;
  R: String;
  F, Minus: Boolean;
begin
  R := '';
  C := 0;
  F := True;
  SChar := 0;
  if S[1] = '-' then
  begin
    S := Copy(S, 2, 40);
    Minus := True;
  end else Minus := False;
  for I := Length(S) downto 1 do
  begin
    if S[I] = ' ' then Continue;
    Inc(C);
    Insert(S[I], R, 1);
    if (C = 2) and F then
    begin
      F := False;
      Insert('.', R, 1);
      Inc(SChar);
      C := 0;
    end;
    if (C = 3) and (I <> 1) then
    begin
      Insert(' ', R, 1);
      Inc(SChar);
      C := 0;
    end;
  end;
  if Minus then
  begin
    R := '-' + R;
    Inc(SChar);
  end;
  InsertDiv2 := R;
//InsertDiv2 := Replicate(' ', 6 - SChar) +
//  Replicate(' ', 24 - (Length(R) - SChar) * 2) + R;
end;

function RemoveDiv(S: String): String;
const
  Digit: set of Char = ['0'..'9'];
var
  I: Integer;
begin
  Result := '';
  if S <> '' then
  for I := 1 to Length(S) do
    if (S[I] in Digit) or (S[I] = '-') then Result := Result + S[I];
end;

procedure Kill(var AnObject);
begin
  if Pointer(AnObject) <> nil then
  begin
    TObject(AnObject).Free;
    TObject(AnObject) := nil;
  end;
end;

procedure SendKey(Win: THandle; VKey: Integer; State: TShiftState);
const
  AsciiSet = ['0'..'9', 'a'..'z', 'A'..'Z'];
begin
  if ssCtrl  in State then SendMessage(Win, WM_KEYDOWN, vk_Control, 1);
{  if ssShift in State then SendMessage(Win, WM_KEYDOWN, vk_Shift, 1);}
  SendMessage(Win, WM_KEYDOWN, VKey, 1);
  if Chr(VKey) in AsciiSet then SendMessage(Win, WM_CHAR, VKey, 1);
  SendMessage(Win, WM_KEYUP, VKey, 0);
{  if ssCtrl in State then SendMessage(Win, WM_KEYUP, vk_Shift, 0);}
  if ssCtrl in State then SendMessage(Win, WM_KEYUP, vk_Control,  $80000001);
end;

procedure Pause(Sec100: Longint);
var
  Event: THandle;
begin
  Event := CreateEvent(nil, False, False, PChar('Event_6666666'));
  WaitForSingleObject(Event, Sec100);
  CloseHandle(Event);
end;

procedure CreateProcessNoWait(const AppPath, AppParams: String;
  Visibility: word);
var
  SI: TStartupInfo;
  PI: TProcessInformation;
begin
  ZeroMemory (@SI, SizeOf (TStartupInfo));
  SI.cb := SizeOf (TStartupInfo);
  SI.dwFlags := STARTF_USESHOWWINDOW;
  SI.wShowWindow := Visibility;
  if not CreateProcess(nil, PChar(AppPath + ' ' + AppParams), nil, nil, False,
    NORMAL_PRIORITY_CLASS, nil, nil, SI, PI) then
    raise Exception.CreateFmt('Failed to execute program. Error Code %d', [GetLastError]);
  CloseHandle(PI.hThread);
end;

function CreateProcessAndWait(const AppPath, AppParams: String;
  Visibility: word): DWord;
var
  SI: TStartupInfo;
  PI: TProcessInformation;
  Proc: THandle;
begin
  ZeroMemory (@SI, SizeOf (TStartupInfo));
  SI.cb := SizeOf (TStartupInfo);
  SI.dwFlags := STARTF_USESHOWWINDOW;
  SI.wShowWindow := Visibility;
  if not CreateProcess(nil, PChar(AppPath + ' ' + AppParams), nil, nil, False,
    NORMAL_PRIORITY_CLASS, nil, nil, SI, PI) then
    raise Exception.CreateFmt('Failed to execute program. Error Code %d', [GetLastError]);
  Proc := PI.hProcess;
  CloseHandle(PI.hThread);
  if WaitForSingleObject(Proc, Infinite) <> Wait_Failed then
    GetExitCodeProcess(Proc, Result);
  CloseHandle(Proc);
end;


function ToOem(S: String): String;
var
  A: array [0..1023] of Char;
begin
  CharToOem(PChar(S), @A);
  Result := StrPas(@A);
end;

function ToAnsi(S: String): String;
var
  A: array [0..1023] of Char;
begin
  OemToChar(PChar(S), @A);
  Result := StrPas(@A);
end;


procedure LinesToOem(L: TStrings);
var
  I: Integer;
begin
  if not Assigned(L) or (L.Count = 0) then Exit;
  for I := 0 to L.Count - 1 do L[I] := ToOem(L[I]);
end;

procedure LinesToAnsi(L: TStrings);
var
  I: Integer;
begin
  if not Assigned(L) or (L.Count = 0) then Exit;
  for I := 0 to L.Count - 1 do L[I] := ToAnsi(L[I]);
end;


end.

