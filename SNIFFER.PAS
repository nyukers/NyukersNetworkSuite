unit sniffer;

interface

Uses Windows, Classes, SysUtils, Messages;

 // Скопированно из Packet32.pas

Const
  DLL  = 'packet.dll';
  DEFAULT_DRIVERBUFFER = 1000000;
  MAX_LINK_NAME_LENGTH = 64;

type Padapter = ^Tadapter;
     Tadapter = Record
                 hFile:LongWord;
                 SymbolicLink:array [0..MAX_LINK_NAME_LENGTH-1] of char;
                end;

     Ppacket = ^Tpacket;
     Tpacket = record
                OverLapped:TOVERLAPPED;
                Buffer:Pointer;
                Next:Pointer;
                Length:Word;
                ulBytesReceived:LongWord;
                bIoComplete:Boolean;
               end;

     PPACKET_OID_DATA = ^TPACKET_OID_DATA;
     TPACKET_OID_DATA = record
                         Oid:LongWord;
                         Length:LongWord;
                         Data:Pointer;
                        end;
     Pnet_type = ^Tnet_type;
     Tnet_type = record
                  LinkType,LinkSpeed:LongWord;
                 end;

// Скопированно из NDIS_DEF.pas

const
  SWAT_DIRECTED=$0001;
  SWAT_MULTICAST=$0002;
  SWAT_ALL_MULTICAST=$0004;
  SWAT_BROADCAST=$0008;
  SWAT_SOURCE_ROUTING=$0010;
  SWAT_PROMISCUOUS=$0020;
  SWAT_SMT=$0040;
  SWAT_MAC_FRAME=$8000;
  SWAT_FUNCTIONAL=$4000;
  SWAT_ALL_FUNCTIONAL=$2000;
  SWAT_GROUP=$1000;

// Собственно сам снифер

Const BUF_SIZE = 512000;
      WM_HAVEPACKET = WM_USER + 13;

type     Tbuffer = array [0..BUF_SIZE-1] of Char;

         TPacketType = record
                        TimeStamp:string[20];
                        HeaderSize,PacketSize, DataSize:dword;
                        MacSender,MacDest:string;
                        IPsender,IPDest:string;
                        PORTsender,PORTdest:word;

                        TimeToLive:LongWord;
                        Protocol:string[50];
                        Packet:string[20];

                        bufferlen:dword;
                        buffer:tbuffer;
                       end;
          TErrorType = (SE_NOADAPTERS, SE_CANTOPENADAPTER);


         TGetPacketEvent = procedure (data:TpacketType) of object;
         TErrorEvent = Procedure (ErrorType:TErrorType) of object;
         TCreateEvent = Procedure of object;

         Tsniffing = class (Tthread)
                     Private
                      Adapter: PAdapter;
                      Packet: PPacket;
                      Buffer: Pointer;
                     protected
                      Procedure Execute;Override;
                      Procedure GetPacket(APacket:Ppacket;ABuffer:Pointer);
                     Public
                      OnGetPacket:TGetPacketEvent;
                      Constructor Create(cadapter:padapter;cpacket:ppacket;cbuffer:pointer);

                    end;

        Tsniffer = class (Tcomponent)

                   private
                    Fadapter:Padapter;
                    Fpacket:Ppacket;
                    Fbuffer:Tbuffer;

                    FNetType:PNet_Type;

                    Fadapterslist:TstringList;

                    Open:boolean;

                    Snf_Thread:Tsniffing;
                    FOnGetPacket:tgetpacketevent;
                    FOnError:TerrorEvent;
                    FOnCreate:TCreateEvent;

                   Public

                    Property adapter:padapter read Fadapter;
                    Property packet:ppacket read Fpacket;
                    Property NetType:Pnet_Type read FNetType;
                    Property AdaptersList:TStringList read FAdaptersList;

                    Property Started:boolean read Open;

                    Constructor Create(owner:tcomponent);override;
                    Destructor Destroy;override;

                    Procedure OpenAdapter(ItemIndex:integer;OpenType:integer);
                    Procedure CloseAdapter;

                   Published
                    Property OnError:TErrorEvent read FOnError write FOnError;
                    Property OnGetPacket:tgetpacketevent read FOnGetPacket write FOnGetPacket;
                    Property OnCreate:TCreateEvent read FOnCreate write FOnCreate;

                   end;

Procedure Register;

implementation


// Взято из bpf.pas

Type  Tbpf_u_int32=LongWord;
        Tbpf_int32=Integer;
        PunixTimeVal=^TunixTimeVal;

        TunixTimeVal=record
                      tv_Sec,tv_uSec:LongWord;
                     end;

        Tbpf_insn=record
                   code:Word;
                   jt:Byte;
                   jf:Byte;
                   k:Integer;
                  end;

         Pbpf_program=^Tbpf_program;
         Tbpf_program=record
                       bf_len:LongWord;
                       bf_insns:^Tbpf_insn;
                      end;

         Pbpf_stat=^Tbpf_stat;
         Tbpf_stat=record
                    bs_recv,bs_drop:LongWord;
                   end;

         Pbpf_hdr = ^Tbpf_hdr;

         Tbpf_hdr =record
                    bh_tstamp:TunixTimeval;
                    bh_caplen,bh_datalen: Tbpf_u_int32;
                    bh_hdrlen:Word ;
                   end;

const BPF_ALIGNMENT = sizeof(Tbpf_int32);

      DLT_NULL=0;
      DLT_EN10MB=1;
      DLT_EN3MB=2;
      DLT_AX25=3;
      DLT_PRONET=4;
      DLT_CHAOS=5;
      DLT_IEEE802=6;
      DLT_ARCNET=7;
      DLT_SLIP=8;
      DLT_PPP=9;
      DLT_FDDI=10;
      DLT_ATM_RFC1483=11;
      DLT_RAW=12;
      DLT_SLIP_BSDOS=13;
      DLT_PPP_BSDOS=14;

      DLT_EN100MB=100;
      DLT_PPP_WIN32=101;

// Взято из Pcap.pas

type TWinVersion=(Wv_win31,Wv_win95,wv_win98,wv_winNT,wv_win2000,wv_unknown);

// Взято из ProtoHdr.pas

const PROTO_IP       =$0800;
      PROTO_ARP      =$0806;
      PROTO_XNS      =$0600;
      PROTO_SNMP     =$814C;
      PROTO_OLD_IPX  =$8137;
      PROTO_NOVELL   =$8138;
      PROTO_IPNG     =$86DD;

      OFFSET_IP      =14;

Type
ETHERNET_HDR = packed record
    Destination:array[0..5] of Byte;
    Source     :array[0..5] of Byte;
    Protocol   :array[0..1] of Byte;
//    Data       :array[0..0] of UCHAR;
                    end;
PETHERNET_HDR = ^ETHERNET_HDR;

ARP_HDR = Packed record
                Hardware_Type:array [0..1] of Byte;
                Protocol_Type:array [0..1] of Byte;
                HLen:Byte;
                Plen:Byte;
                Operation:array [0..1] of Byte;
                Send_Hardware_Address:array [0..5] of Byte;
                Send_Protocol_Address:array [0..3] of Byte;
                Targ_Hardware_Address:array [0..5] of Byte;
                Targ_Protocol_Address:array [0..3] of Byte;
               end;
PARP_HDR = ^ARP_HDR;


IP_HDR=packed record
     Verlen:Byte;
    Service:Byte;
     Length:array[0..1] of Byte;
      Ident:array[0..1] of Byte;
    Flagoff:array[0..1] of Byte;
   TimeLive:byte;
   Protocol:byte;
   Checksum:array[0..1] of byte;
     Source:array[0..3] of byte;
Destination:array[0..3] of byte;
//  Data:         array[0..0] of UCHAR;
            end;
PIP_HDR=^IP_HDR;

IPNG_RHDR = packed record
                  VerPrio:byte;
                  FlowLabel:array[0..2] of byte;
                  Length:array[0..1] of byte;
                  NextHadr:byte;
                  HopLimit:byte;
                  Source:array[0..15] of byte;
                  Destination:array[0..15] of byte;
                 end;
PIPNG_RHDR = ^IPNG_RHDR;

TCP_HDR = packed record
        Source:array[0..1] of byte;
   Destination:array[0..1] of byte;
           Seq:array[0..3] of byte;
           Ack:array[0..3] of byte;
     Rsvd0_Off:byte;
   Flags_Rsvd1:byte;
        Window:array[0..1] of byte;
      Checksum:array[0..1] of byte;
      UrgPoint:array[0..1] of byte;
//  Data        : array[0..0] of UCHAR;
               end;
PTCP_HDR = ^TCP_HDR;

const TCP_FLAG_FIN=$01;
      TCP_FLAG_SYN=$02;
      TCP_FLAG_RST=$04;
      TCP_FLAG_PSH=$08;
      TCP_FLAG_ACK=$10;
      TCP_FLAG_URG=$20;

      PROTO_TCP = 6;

type UDP_HDR = packed record
                Source:array[0..1] of byte;
                Destination:array[0..1] of byte;
                Length:array[0..1] of byte;
                Checksum:array[0..1] of byte;
               end;
     PUDP_HDR = ^UDP_HDR;

     ICMP_HDR = packed record
                 Type_Message:Byte;
                 Code:Byte;
                 CheckSum:array [0..1] of byte;
                end;
     PICMP_HDR = ^ICMP_HDR;

     IGMP_HDR = packed record
                 Vertype:Byte;
                 Unused:Byte;
                 CheckSum:array [0..1] of byte;
                 Group_Addr: array [0..3] of byte;
                end;
      PIGMP_HDR = ^IGMP_HDR;

      PSU_RHDR = packed record
                  Source:array[0..3] of byte;
                  Destination:array[0..3] of byte;
                  Zero:byte;
                  Protocol:byte;
                  Length:array[0..1] of byte;
                  Data:array[0..0] of byte;
                 end;
      PPSU_RHDR = ^PSU_RHDR;

// Взято из Ndis_Def.pas

const

  OID_GEN_CURRENT_PACKET_FILTER=$0001010E;
  OID_GEN_MEDIA_IN_USE=$00010104;
  OID_GEN_LINK_SPEED=$00010107;

  METHOD_BUFFERED=0;
  METHOD_IN_DIRECT=1;
  METHOD_OUT_DIRECT=2;
  METHOD_NEITHER=3;

  FILE_ANY_ACCESS=0;
  FILE_READ_ACCESS=1;
  FILE_WRITE_ACCESS=2;

  FILE_DEVICE_PROTOCOL=$8000;

Type TNDIS_MEDIUM=(NdisMedium802_3,NdisMedium802_5,NdisMediumFddi,
                     NdisMediumWan,NdisMediumLocalTalk,NdisMediumDix,
                     NdisMediumArcnetRaw,NdisMediumArcnet878_2,NdisMediumAtm,
                     NdisMediumWirelessWan,NdisMediumIrda,NdisMediumMax );

     DEVICE_TYPE  = LONGWORD;




var IOCTL_PROTOCOL_QUERY_OID,IOCTL_PROTOCOL_SET_OID,IOCTL_PROTOCOL_STATISTICS,
    IOCTL_PROTOCOL_RESET,IOCTL_PROTOCOL_WRITE,IOCTL_PROTOCOL_MACNAME,
    IOCTL_CLOSE,IOCTL_OPEN,IOCTL_PROTOCOL_READ:LongWord;


// Константы сниффера

Const Pcap_buf_size = 512000;
      Pcap_Read_TimeOut = 1000000;
      TCP_PACKET_SIZE =SizeOf(ETHERNET_HDR) + SizeOf(IP_HDR) + SizeOf(TCP_HDR);
      UDP_Packet_SIZE =SizeOf(ETHERNET_HDR) + SizeOf(IP_HDR) + SizeOf(UDP_HDR);


// Тоже скопированно из Packet32.pas

function PacketSetNumWrites(AdapterObject: PAdapter; Length: Integer): Boolean;cdecl external DLL;
function PacketSetReadTimeout(AdapterObject: PAdapter; timeout: Integer): Boolean;cdecl external DLL;
function PacketGetAdapterNames(pStr:pchar;BufferSize:PLongWord) : LongWord;cdecl external DLL;
Function PacketOpenAdapter(AdapterName:Pchar) : PAdapter;cdecl external dll;
procedure PacketCloseAdapter(pAdapter:Padapter);cdecl external dll;
function PacketAllocatePacket : PPacket;cdecl external dll;
procedure PacketInitPacket(pPacket:Ppacket;Buffer:Pointer;Length:LongWord);cdecl external DLL;
procedure PacketFreePacket( pPacket:Ppacket);cdecl external DLL;
function PacketReceivePacket(AdapterObject:Padapter;pPacket:PPacket;Sync:Boolean):Longbool;cdecl external DLL;
function PacketWaitPacket(AdapterObject:Padapter;lpPacket:Ppacket):LongBool;cdecl external dll;
function PacketSendPacket( AdapterObject:Padapter;pPacket:PPacket;Sync:boolean):Longbool ;cdecl external dll;
function PacketResetAdapter( AdapterObject:Padapter):Longbool; cdecl external dll;
function PacketSetHwFilter( AdapterObject:Pointer;Filter:Longword):Longbool;cdecl external dll;
function PacketRequest( AdapterObject:Padapter;isSet:Longbool;OidData:PPacket_oid_data ):Longbool;cdecl external DLL;
function PacketSetBuff(AdapterObject: Padapter;dim:integer) : Longbool;cdecl external DLL;
function PacketSetBpf( AdapterObject:Padapter;fp:Pbpf_program):Longbool;cdecl external DLL;
function PacketGetStats( AdapterObject:Padapter;s: Pbpf_stat):Longbool;cdecl external DLL;
Function PacketGetNetType (AdapterObject:Padapter; nettype:Pnet_Type):LongBool;cdecl external DLL;

// Тоже скопированно из Bpf.pas

function BPF_WORDALIGN(X:LongWord) : LongWord;
begin
  result := (((X)+(BPF_ALIGNMENT-1))and not(BPF_ALIGNMENT-1));
end;

// Тоже скопированно из Ndis_Def.pas

function CTL_CODE(Device,Func,Method,Access:LongWord):LongWord;
begin
 result :=( (Device shl 16) OR (Access shl 14) OR (func shl 2) OR method );
end;

// Взято из Pcap.pas

function pcap_getwinversion(var verstr:string) : Twinversion;
var
    Info:OSVERSIONINFO;
begin
  info.dwOSVersionInfoSize := Sizeof(OSVERSIONINFO);
  result:=wv_unknown;
  if not GetVersionEx(Info) then exit;
  Case info.dwPlatformId of
        VER_PLATFORM_WIN32s : begin
                               result := wv_win31;
                               verStr := 'Win3.1';
                             end;
        VER_PLATFORM_WIN32_WINDOWS :
                             begin
                               result := wv_win95;
                               verstr := 'Win95';
                              end;
       VER_PLATFORM_WIN32_NT :
                             begin
                               if info.dwMajorVersion<5 then
                                 begin
                                   result := WV_winNT;
                                   verstr := 'WinNT';
                                 end
                               else
                                 begin
                                   result := WV_Win2000;
                                   verstr := 'Win2000';
                                 end;
                             end;
  end;
end;

function Pcap_GetAdapternames(Delimiter:char):string;
var NameList:Array [0..(1024*2)-1] of char;
    NameLength,
    i:Longword;
    Ver:Twinversion;
    s:string;
begin
   NameLength := 1024;
   Ver := pcap_GetwinVersion(S);
   PacketGetAdapterNames(NameList,@NameLength);
   if (Ver=wv_Win95) OR (Ver=wv_Win98) then
   begin
     for i:=0 to NameLength-1 do
     begin
       if ((NameList[i]=#0) and (NameList[i+1]=#0))then
         break
       else
         if (NameList[i]=' ') or (NameList[i]=#0) then
           NameList[i]:=delimiter;
     end;
     result := NameList;
   end
   Else if (ver=wv_winNT) or (ver=wv_win2000) then
   begin
     for i:=0 to NameLength-1 do
     begin
       if (Pwidechar(@NameList)[i]=#0)and (PwideChar(@namelist)[i+1]<>#0) then
         PwideChar(@NameList)[i]:=WideChar(delimiter);
     end;
     result := WideCharToString(PWideChar(@NameList)) ;
   end;
  end;

// Взято из Proto_Hdr.pas

function TOUSmallint(x: PChar): Smallint;
begin
 Result := (Smallint(x^) shl 8) or (Smallint((x + 1)^));
end;

function TOULONG(x: PChar): LongWord;
begin
    Result := (LONGWORD(x^) shl 24) or (LONGWORD((x + 1)^) shl 16) or
              (LONGWORD((x + 2)^) shl 8) or (LONGWORD((x + 3)^));
end;

// Сам сниффер.

Constructor tsniffer.Create;
var adap,s:string;
    i:integer;
begin
fadaptersList:=tstringlist.Create;
adap:=pcap_getadapternames(#10);
s:='';
if adap<>'' then
begin
for i:=1 to length(adap) do
 if adap[i]=#10 then
 begin
  FadaptersList.Add(s);
  s:='';
 end else s:=s+adap[i];
if s<>'' then FadaptersList.Add(s);
end else if assigned(FOnError) then FOnError(SE_NOADAPTERS);
Open:=false;

inherited Create(Owner);

if assigned(FOnCreate) then FOnCreate;

end;

Destructor tsniffer.Destroy;
begin
 fadapterslist.Free;
 inherited Destroy;
end;

Procedure Tsniffer.OpenAdapter;
begin
if ItemIndex <= FAdaptersList.count then
 begin
  Fadapter:=packetOpenAdapter(pchar(FadaptersList.Strings[ItemIndex]));
  if fadapter=nil then begin if Assigned(FOnError) then FOnError(SE_CANTOPENADAPTER);exit; end;

  PacketSetHwFilter(FAdapter, OpenType);
  PacketSetBuff(FAdapter, PCAP_BUF_SIZE);
  PacketSetReadTimeout(FAdapter, PCAP_READ_TIMEOUT);
  FPacket := PacketAllocatePacket;
  PacketInitPacket(FPacket, @FBuffer, PCAP_BUF_SIZE);

  Snf_Thread:= tsniffing.Create(fadapter,fpacket,@fbuffer);
  Snf_Thread.OnGetPacket:= FonGetPacket;

//  PacketGetNetType(fadapter,@FnetType);

  Open:=true;

 end else if Assigned(FOnError) then FOnError(SE_CANTOPENADAPTER);
end;


Procedure Tsniffer.CloseAdapter;
begin
if Open then
 begin
  PacketCloseAdapter(Fadapter);
  Snf_Thread.Terminate;
  Snf_Thread.Free;
  Open:=false;
 end;
end;

// Поток сниффер.

procedure Tsniffing.Execute;
begin
while not terminated do
 if PacketReceivePacket(Adapter, Packet, false) then
  GetPacket(Packet, Buffer);
end;

Constructor Tsniffing.Create;
begin
adapter:=cadapter;
packet:=cpacket;
buffer:=cbuffer;

inherited Create(false);
end;

Procedure Tsniffing.GetPacket;
var data:TPacketType;
    Plength:LongWord;
    BufPtr :Pointer;
    Pstart:Pchar;
    i:integer;
    MAC_sours:array [0..5] of byte;
    Hour, Min, Sec, MSec: Word;
begin
if not terminated then
begin
data.HeaderSize:=0;data.PacketSize:=0;
data.DataSize:=0;data.MacSender:='';
data.MacDest:='';data.IPsender:='';
data.IPDest:='';data.PORTsender:=0;
data.PORTdest:=0;data.TimeToLive:=0;
data.Protocol:='';data.Packet:='';
data.bufferlen:=0;
Plength:=apacket.ulBytesReceived;
bufPtr:=Ptr(LongWord(abuffer)+plength);
DecodeTime(Time, Hour, Min, Sec, MSec);
data.TimeStamp:=
 IntToStr(Hour)+':'+IntToStr(Min)+':'+IntToStr(Sec)+','+IntToStr(MSec);
while (LongWord(aBuffer) < LongWord(BufPtr)) do
 begin
  data.HeaderSize:= DWORD(Pbpf_hdr(abuffer).bh_hdrlen);
  data.PacketSize:=DWORD(Pbpf_hdr(abuffer).bh_caplen);
  data.DataSize:=DWORD(Pbpf_hdr(abuffer).bh_datalen);

  Pstart:=Ptr(LongWord(abuffer)+data.HeaderSize);
  LongWord(aBuffer):=LongWord(aBuffer) + BPF_WORDALIGN(data.HeaderSize+ data.PacketSize);

  For i := 0 to 5 do MAC_Sours[i] := PETHERNET_HDR(Pstart).Source[i];

  data.MacSender:=inttohex(mac_sours[0],2) + '-' +
                  inttohex(mac_sours[1],2) + '-' +
                  inttohex(mac_sours[2],2) + '-' +
                  inttohex(mac_sours[3],2) + '-' +
                  inttohex(mac_sours[4],2) + '-' +
                  inttohex(mac_sours[5],2);

  For i := 0 to 5 do MAC_Sours[i] := PETHERNET_HDR(Pstart).Destination[i];

  data.MacDest:=inttohex(mac_sours[0],2) + '-' +
                  inttohex(mac_sours[1],2) + '-' +
                  inttohex(mac_sours[2],2) + '-' +
                  inttohex(mac_sours[3],2) + '-' +
                  inttohex(mac_sours[4],2) + '-' +
                  inttohex(mac_sours[5],2);


// Если это IP протокол

  If PETHERNET_HDR(PStart).Protocol[0] shl 8 + PETHERNET_HDR(Pstart).Protocol[1] = PROTO_IP
  Then
   begin
    Pstart:=Ptr(LongWord(Pstart)+SizeOf(EtherNet_HDR));
    data.Protocol:='IP';
    data.TimeToLive:=PIP_HDR(pstart).TimeLive;
    Data.IPsender:=inttostr(PIP_HDR(Pstart).Source[0])+'.'
                  +inttostr(PIP_HDR(Pstart).Source[1])+'.'
                  +inttostr(PIP_HDR(Pstart).Source[2])+'.'
                  +inttostr(PIP_HDR(Pstart).Source[3]);
    Data.IPdest:=inttostr(PIP_HDR(Pstart).Destination[0])+'.'
                +inttostr(PIP_HDR(Pstart).Destination[1])+'.'
                +inttostr(PIP_HDR(Pstart).Destination[2])+'.'
                +inttostr(PIP_HDR(Pstart).Destination[3]);


// Ежели TCP пакет
    case PIP_HDR(PStart).Protocol of
     6: begin
        data.Packet:='TCP';
        PStart := Ptr(LongWord(PStart) + SizeOf(IP_HDR));
        data.PORTsender:=PTCP_HDR(PStart).Source[0] shl 8 + PTCP_HDR(PStart).Source[1];
        data.PORTdest:=PTCP_HDR(PStart).Destination[0] shl 8 + PTCP_HDR(PStart).Destination[1];

        Pstart := Ptr(LongWord(Pstart) + SizeOf(TCP_HDR));

        if data.PacketSize - TCP_Packet_SIZE > High(data.buffer ) then Move(Pstart^, data.buffer, High(data.buffer) - 1)
                      else  Move(PStart^, data.buffer, data.PacketSize - TCP_Packet_SIZE);

        data.bufferlen:=data.PacketSize - TCP_Packet_SIZE;
        end;
    17: begin
          data.Packet:='UDP';
          PStart:=Ptr(LongWord(PStart) + SizeOf(IP_HDR));
          data.PORTsender:=PUDP_HDR(PStart).Source[0] shl 8 + PUDP_HDR(PStart).Source[1];
          data.PORTdest:=PUDP_HDR(PStart).Destination[0] shl 8 + PUDP_HDR(PStart).Destination[1];
          PStart:=Ptr(LongWord(PStart)+SizeOf(UDP_HDR));
          if data.PacketSize - UDP_Packet_SIZE > High(data.buffer) then
             Move(PStart^, data.buffer, High(data.buffer) - 1)
          else  Move(PStart^, data.buffer, data.PacketSize - UDP_Packet_SIZE);

          data.bufferlen:=data.PacketSize - UDP_Packet_SIZE;
        end;
     1:  begin
           data.Packet:='ICMP';
           Pstart:=Ptr(LongWord(Pstart)+SizeOf(IP_HDR));
           data.PORTsender:=$0;
           data.PORTdest:=$0;
           if data.PacketSize - UDP_Packet_SIZE > High(data.buffer) then
             Move(PStart^, data.buffer, High(data.buffer) - 1)
            else  Move(PStart^, data.buffer, data.PacketSize - UDP_Packet_SIZE);

           data.bufferlen:=data.PacketSize - UDP_Packet_SIZE;
          end;
     2: begin
            data.Packet:='IGMP';
            Pstart:=Ptr(LongWord(Pstart)+SizeOf(IP_HDR));
            data.PORTsender:=$0;
            data.PORTdest:=$0;
            if data.PacketSize - UDP_Packet_SIZE > High(data.buffer) then
             Move(PStart^, data.buffer, High(data.buffer) - 1)
            else  Move(PStart^, data.buffer, data.PacketSize - UDP_Packet_SIZE);
            data.bufferlen:=data.PacketSize - UDP_Packet_SIZE;
        end;
    end;//case
    end else

// SNMP протокол
  If (PETHERNET_HDR(Pstart).Protocol[0] shl 8 + PETHERNET_HDR(Pstart).Protocol[1] = PROTO_SNMP) then
   begin
    data.Protocol:='SNMP';
    if data.PacketSize - SizeOf(ETHERNET_HDR) > High(data.buffer) then
             Move(PStart^, data.buffer, High(data.buffer) - 1)
            else  Move(PStart^, data.buffer, data.PacketSize - SizeOf(ETHERNET_HDR));
     data.bufferlen:=data.PacketSize - SizeOf(ETHERNET_HDR);
   end else

// IPNG протокол
  If (PETHERNET_HDR(Pstart).Protocol[0] shl 8 + PETHERNET_HDR(Pstart).Protocol[1] = PROTO_IPNG) then
   begin
    data.Protocol:='IPNG';
    Pstart:=ptr(LONGWORD(PSTART)+SIZEOF(ETHERNET_HDR));
    if data.PacketSize - SizeOf(ETHERNET_HDR) > High(data.buffer) then
             Move(PStart^, data.buffer, High(data.buffer) - 1)
            else  Move(PStart^, data.buffer, data.PacketSize - SizeOf(ETHERNET_HDR));
     data.bufferlen:=data.PacketSize - SizeOf(ETHERNET_HDR);
   end else

// NOVELL
   if (PETHERNET_HDR(Pstart).Protocol[0] shl 8 + PETHERNET_HDR(Pstart).Protocol[1] = PROTO_NOVELL) then
   begin
    data.Protocol:='NOVELL';
    Pstart:=ptr(LONGWORD(PSTART)+SIZEOF(ETHERNET_HDR));
    if data.PacketSize - SizeOf(ETHERNET_HDR) > High(data.buffer) then
             Move(PStart^, data.buffer, High(data.buffer) - 1)
            else  Move(PStart^, data.buffer, data.PacketSize - SizeOf(ETHERNET_HDR));
     data.bufferlen:=data.PacketSize - SizeOf(ETHERNET_HDR);
   end else

// XNS

   if (PETHERNET_HDR(Pstart).Protocol[0] shl 8 + PETHERNET_HDR(Pstart).Protocol[1] = PROTO_XNS) then
   begin
    data.Protocol:='XNS';
    Pstart:=ptr(LONGWORD(PSTART)+SIZEOF(ETHERNET_HDR));
    if data.PacketSize - SizeOf(ETHERNET_HDR) > High(data.buffer) then
             Move(PStart^, data.buffer, High(data.buffer) - 1)
            else  Move(PStart^, data.buffer, data.PacketSize - SizeOf(ETHERNET_HDR));
     data.bufferlen:=data.PacketSize - SizeOf(ETHERNET_HDR);
   end else

// old IPX

   if (PETHERNET_HDR(Pstart).Protocol[0] shl 8 + PETHERNET_HDR(Pstart).Protocol[1] = PROTO_old_IPX) then
   begin
    data.Protocol:='oldIPX';
    Pstart:=ptr(LONGWORD(PSTART)+SIZEOF(ETHERNET_HDR));
    if data.PacketSize - SizeOf(ETHERNET_HDR) > High(data.buffer) then
             Move(PStart^, data.buffer, High(data.buffer) - 1)
            else  Move(PStart^, data.buffer, data.PacketSize - SizeOf(ETHERNET_HDR));
     data.bufferlen:=data.PacketSize - SizeOf(ETHERNET_HDR);
   end else


// ARP

  If (PETHERNET_HDR(Pstart).Protocol[0] shl 8 + PETHERNET_HDR(Pstart).Protocol[1] = PROTO_ARP) then
   begin
    data.Protocol:='ARP';
    data.IPsender:='Device '+IntToStr(PARP_HDR(PStart).Hardware_Type[0] shl 8 + PARP_HDR(PStart).Hardware_Type[1]);
    data.IPdest:='Subprot '+IntToStr(PARP_HDR(PStart).Protocol_Type[0] shl 8 + PARP_HDR(PStart).Protocol_Type[1]);
    data.HeaderSize:=PARP_HDR(Pstart).HLen;
    data.PacketSize:=PARP_HDR(Pstart).Plen;
    Case (PARP_HDR(PStart).Operation[0] shl 8 + PARP_HDR(PStart).Operation[1]) of
                              1: Data.Packet:='ARP request';
                              2: Data.Packet:='ARP response';
                              3: Data.Packet:='RARP request';
                              4: Data.Packet:='RARP response';
                              5: Data.Packet:='Dynamic RARP request';
                              6: Data.Packet:='Dynamic RARP reply';
                              7: Data.Packet:='Dynamic RARP error';
                              8: Data.Packet:='InARP request';
                              9: Data.Packet:='InARP reply';
                              else //Data.Packet:='unknown';
         Data.Packet:=
         inttostr(PARP_HDR(PStart).Operation[0] shl 8 + PARP_HDR(PStart).Operation[1]);
                             end;

   end else
    begin
//     data.Protocol:='UNKNOWN';
    case PIP_HDR(PStart).Protocol of
//    6,1,17,2 see above!
    3: data.Protocol:='GGP: Gateway To Gateway';
    4: data.Protocol:='IPinIP (encapsulation)';
    8: data.Protocol:='EGP: Exterior Gateway Prot';
    9: data.Protocol:='IGP: Interior Gateway Prot';
   27: data.Protocol:='RDP: Reliable Data Protocol';
   28: data.Protocol:='IRTP: Internet Reliable Transaction';
   29: data.Protocol:='ISO TP4: ISO Transport Protocol Class 4';
   35: data.Protocol:='IDPR: Inter-Domain Policy Routing Prot';
   37: data.Protocol:='DDP: Datagram Delivery Protocol';
   38: data.Protocol:='IDPR CMTP: IDPR Control Message Transport Prot';
   80: data.Protocol:='ISO IP';
   88: data.Protocol:='IGRP';
   89: data.Protocol:='OSPF';
   92: data.Protocol:='MTP: Multicast Transport Protocol';
   94: data.Protocol:='IPIP: IP-within-IP Encapsulation Protocol';
   97: data.Protocol:='ETHERIP: Ethernet-within-IP Encapsulation';
   98: data.Protocol:='ENCAP';
    else data.Protocol:=inttostr(PIP_HDR(PStart).Protocol)    +':'+
                        inttohex(PIP_HDR(PStart).Protocol,2)    +'h';
     end;//of

    data.Packet:=IntToStr
    (PETHERNET_HDR(Pstart).Protocol[0] shl 8 + PETHERNET_HDR(Pstart).Protocol[1])
    +':'+
    IntToHex(PETHERNET_HDR(Pstart).Protocol[0] shl 8 + PETHERNET_HDR(Pstart).Protocol[1],2)
    +'h';

     Pstart:=ptr(LONGWORD(PSTART)+SIZEOF(ETHERNET_HDR));
    Data.IPsender:=inttostr(PIP_HDR(Pstart).Source[0])+'.'
                  +inttostr(PIP_HDR(Pstart).Source[1])+'.'
                  +inttostr(PIP_HDR(Pstart).Source[2])+'.'
                  +inttostr(PIP_HDR(Pstart).Source[3]);
    Data.IPdest:=inttostr(PIP_HDR(Pstart).Destination[0])+'.'
                +inttostr(PIP_HDR(Pstart).Destination[1])+'.'
                +inttostr(PIP_HDR(Pstart).Destination[2])+'.'
                +inttostr(PIP_HDR(Pstart).Destination[3]);

     if data.PacketSize - SizeOf(ETHERNET_HDR) > High(data.buffer) then
         Move(PStart^, data.buffer, High(data.buffer) - 1)
        else  Move(PStart^, data.buffer, data.PacketSize - SizeOf(ETHERNET_HDR));
        data.bufferlen:=data.PacketSize - SizeOf(ETHERNET_HDR);

    end;

  if Assigned(OnGetPacket) then OnGetPacket(data);

 end;
end;
end;

Procedure Register;
begin
RegisterComponents('NetTools',[TSniffer]);
end;

initialization

// Инициализация Ndis_Def.pas

IOCTL_PROTOCOL_QUERY_OID:=CTL_CODE(FILE_DEVICE_PROTOCOL, 0 , METHOD_BUFFERED, FILE_ANY_ACCESS);
IOCTL_PROTOCOL_SET_OID:=CTL_CODE(FILE_DEVICE_PROTOCOL, 1 , METHOD_BUFFERED, FILE_ANY_ACCESS);
IOCTL_PROTOCOL_STATISTICS:=CTL_CODE(FILE_DEVICE_PROTOCOL, 2 , METHOD_BUFFERED, FILE_ANY_ACCESS);
IOCTL_PROTOCOL_RESET:=CTL_CODE(FILE_DEVICE_PROTOCOL, 3 , METHOD_BUFFERED, FILE_ANY_ACCESS);
IOCTL_PROTOCOL_READ:=CTL_CODE(FILE_DEVICE_PROTOCOL, 4 , METHOD_BUFFERED, FILE_ANY_ACCESS);
IOCTL_PROTOCOL_WRITE:=CTL_CODE(FILE_DEVICE_PROTOCOL, 5 , METHOD_BUFFERED, FILE_ANY_ACCESS);
IOCTL_PROTOCOL_MACNAME:=CTL_CODE(FILE_DEVICE_PROTOCOL, 6 , METHOD_BUFFERED, FILE_ANY_ACCESS);
IOCTL_OPEN:=CTL_CODE(FILE_DEVICE_PROTOCOL, 7 , METHOD_BUFFERED, FILE_ANY_ACCESS);
IOCTL_CLOSE:=CTL_CODE(FILE_DEVICE_PROTOCOL, 8 , METHOD_BUFFERED, FILE_ANY_ACCESS);
end.


