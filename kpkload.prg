#define _T CHR(9)
#translate  NTRIM(< v1 >) => LTRIM(STR(< v1 >))

#ifdef __CLIP__
#else
  #translate  DTOC(< v1 >, <v2>) => ;
  (iif(<v2> = NIL,DTOC(<v1>),;
    (;
    _sdtf:=Set(_SET_DATEFORMAT,<v2>);
    ,_cDtoC:=DTOC(<v1>);
    ,Set(_SET_DATEFORMAT,_sdtf);
    ,_cDtoC;
  );
 ))
  #translate  CTOD(< v1 >, <v2>) => ;
  (iif(<v2> = NIL,CTOD(<v1>),;
    (;
    _sdtf:=Set(_SET_DATEFORMAT,<v2>);
    ,_cCtoD:=CTOD(<v1>);
    ,Set(_SET_DATEFORMAT,_sdtf);
    ,_cCtoD;
  );
 ))
#endif


/*
GUID_KPK("C", - �������
GUID_KPK("B" - ⮣஢� �����
GUID_KPK("A"  - ⮢��
GUID_KPK("F" - ���� �����
GUID_KPK("D"  - ���� ���
GUID_KPK("D0"  - �������
GUID_KPK("CAC"  - ��� �� �����
GUID_KPK("�0" - ��⥣���
GUID_KPK("AD5" - ��� ����樨
GUID_KPK("CA1" - ⨯ �� �窨

*/
//FUNCTION main()
//set("PRINTER_CHARSET", "cp866")
LOCAL dSHDATEBG, dSHDATEEND

set(_SET_FILECREATEMODE, "664")
set(_SET_DIRCREATEMODE, "775")
#ifdef __CLIP__
   set translate path ON
#endif
set autopen ON
set optimize OFF

rddSetDefault("DBFCDX")
  dSHDATEBG  := STOD("20061115")-(7*3) //�� ������ �����
  dSHDATEEND := STOD("20061115")-7

kpk_load()
//RETURN

FUNCTION kpk_load(ktar,nAgSk,cFio,dShDateBg, dShDateEnd, aKop,;
     nRef_Price,nDoc_Debt,nRef_Sales,nRef_Routes, nRef_Ini)

  LOCAL oRef_System
  LOCAL cktar:=PADL(LTRIM(STR(ktar,3)), 3, "0")
  LOCAL aLoadFile

  set("PRINTER_CHARSET","cp1251")
  SET DATE FORMAT "yyyy-mm-dd"
  SET CENTURY ON

  USE (gcPath_ew+"deb\deb") ALIAS deb NEW SHARED
  SET ORDER TO TAG t1

  IF gnEnt=20
    USE (gcPath_ew+"deb\accord_deb") ALIAS skdoc NEW SHARED READONLY
    SET ORDER TO TAG t1
  else
    USE (gcPath_ew+"deb\skdoc") ALIAS skdoc NEW SHARED READONLY
    SET ORDER TO TAG t1
  endif
     //index on str(kpl)+str(ktan) tag t1


  USE (gcPath_ew+"deb\bdoc") ALIAS bdoc  NEW SHARED
  SET ORDER TO TAG t1

  USE ('k'+cktar+'pcen.dbf')  ALIAS PersonalPrice NEW EXCLUSIVE

  USE ('k'+cktar+'cnfr.dbf') ALIAS Confirm NEW EXCLUSIVE

  USE ('k'+cktar+'mrch.dbf') ALIAS Merch NEW EXCLUSIVE
  IF FILE('k'+cktar+'mrch.cdx')
    ERASE ('k'+cktar+'mrch.cdx')
  ENDIF
  INDEX ON STR(Kpl)+STR(Kgp)+STR(MNTOV)+STR(WEEK(Dop),2) TAG KGp_MnTov
  INDEX ON STR(Kpl)+STR(Kgp)+STR(MNTOVT)+STR(WEEK(Dop),2) TAG KGp_MnTovT

  USE ('k'+cktar+'sale.dbf') ALIAS Sales NEW EXCLUSIVE
  IF FILE('k'+cktar+'sale.cdx')
    ERASE ('k'+cktar+'sale.cdx')
  ENDIF
  INDEX ON STR(Kpl)+STR(Kgp)+STR(MNTOV)+STR(WEEK(Dop),2) TAG KGp_MnTov
  INDEX ON STR(Kpl)+STR(Kgp)+STR(MNTOVT)+STR(WEEK(Dop),2) TAG KGp_MnTovT

  USE ("k"+cktar+"ost") ALIAS price_full NEW EXCLUSIVE
  IF FILE('k'+cktar+'ost.cdx')
    ERASE ('k'+cktar+'ost.cdx')
  ENDIF
  INDEX ON STR(mkeep)+STR(INT(MnTov/10^4),3)+Nat TAG Nat
  INDEX ON nmkeep+STR(INT(MnTov/10^4),3)+Nat TAG mnkeep

  USE ("k"+cktar+"ot") ALIAS price NEW EXCLUSIVE
  IF FILE('k'+cktar+'ot.cdx')
    ERASE ('k'+cktar+'ot.cdx')
  ENDIF
  INDEX ON STR(mkeep)+STR(INT(MnTov/10^4),3)+Nat TAG Nat
  INDEX ON nmkeep+STR(INT(MnTov/10^4),3)+Nat TAG mnkeep

  USE ("k"+cktar+"firm") ALIAS TPoints NEW EXCLUSIVE
  IF FILE('k'+cktar+'firm.cdx')
    ERASE ('k'+cktar+'firm.cdx')
  ENDIF
  INDEX ON STR(KPL)+STR(KGP) TAG "kgp_kpl"

  //�࣮�� �窨
  TOTAL ON STR(KPL)+STR(KGP) TO tmp_ktt
  //������
  TOTAL ON STR(KPL) TO tmp_kpl
  //CLOSE TPoints

  USE tmp_ktt NEW EXCLUSIVE
  USE tmp_kpl NEW EXCLUSIVE

  tmp_kpl->(AddKplKgpSkDoc())


  //����� 業� ��㧨��
  aPrice:=PriceType2Kop("Price")
         //���ਭ�  152
  oRef_System:=Ref_System_ini(nRef_Ini, ktar, nAgSk, cFio,dShDateBg, dShDateEnd,aPrice)
  RSSave(oRef_System)

  Ref_Sales(nRef_Sales, dShDateBg, dShDateEnd)

  Ref_TblStruct(nRef_Ini)

  Doc_Move(nDoc_Debt,ktar)
  Doc_Sale(nDoc_Debt)
  Doc_Debt(nDoc_Debt,ktar)
  Doc_Cash(nDoc_Debt)

  Ref_Routes(nRef_Routes)
  Ref_Clients(nRef_Routes,aKop)
  Ref_TPoints(nRef_Routes)


  IF STR(s_tag->Ref_Price) $ "7,8" //s_tag->Dt_Price#DATE()
    //��।��� ���� 業� � ���� �������㠫�� 業�
    Ref_Price(nRef_Price,aPrice)
    Ref_GoodsStock(0)
  ELSE
    //��।��� ���� 業�
    Ref_Price(0,aPrice)
    Ref_GoodsStock(nRef_Price)
    //���� ���⪨
  ENDIF

  IF (STR(s_tag->Ref_Price) $ "7,8" .AND. ; //s_tag->Dt_Price#DATE() .AND.;
     !EMPTY(nRef_Price)) .OR. !EMPTY(nRef_Routes)
    Ref_PersonalPrices(nRef_Price+nRef_Routes)
  ELSE
    Ref_PersonalPrices(0)
  ENDIF

  Ref_Barcodes()
  Ref_Firms(nRef_Ini)
  Ref_Stores(nRef_Ini)
  Ref_Sertif(nRef_Ini)

  Ref_Commands(.T.) //nRef_Ini)

  Ref_Confirm()

  Ref_AttrTypes(nRef_Ini,aKop)
  Ref_PrnScripts(nRef_Ini)
  Ref_FirmsPrnLinks(nRef_Ini)
  Ref_RepScripts(nRef_Ini)
  Ref_FillDocScripts(nRef_Ini)
  Ref_Scripts(nRef_Ini)

//set translate path OFF

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO From1C.dat

  IF .F. .AND. ktar=688
    QQOUT("agentp_data"+_T+"to_ppc"+_T+"k"+LTRIM(STR(688)))
  ELSE
    QQOUT("agentp_data"+_T+"to_ppc"+_T+"�᭮����")
  ENDIF


  //QQOUT("agentp_data"+_T+"to_ppc"+_T+"�த�����")
  QOUT("")
  SET PRINT TO
  SET PRINT OFF

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO QOUT.dat
  QOUT("")
  SET PRINT TO
  SET PRINT OFF

  FILEAPPEND("Ref_System.txt","From1C.dat")
  FILEAPPEND("QOUT.dat","From1C.dat")

  aLoadFile:={"Ref_Sales.txt",;
  "Ref_TblStruct.txt",;
  "Doc_Move.txt",;
  "Doc_Sale.txt",;
  "Doc_Debt.txt",;
  "Doc_Cash.txt",;
  "Ref_Routes.txt",;
  "Ref_Clients.txt",;
  "Ref_TPoints.txt",;
  "Ref_Price.txt",;
  "Ref_GoodsStock.txt",;
  "Ref_PersonalPrices.txt",;
  "Ref_Barcodes.txt",;
  "Ref_Firms.txt",;
  "Ref_Stores.txt",;
  "Ref_Commands.txt",;
  "Ref_Sertif.txt",;
  "Ref_AttrTypes.txt",;
  "Ref_Confirm.txt",;
  "Ref_PrnScripts.txt",;
  "Ref_FirmsPrnLinks.txt",;
  "Ref_RepScripts.txt",;
  "Ref_FillDocScripts.txt",;
  "Ref_Scripts.txt"}

//outlog(__FILE__,__LINE__,ktar, s_tag->kod)

   AEVAL(aLoadFile,{|cFile| IIF(FILESIZE(cFile)=0,;
   (NIL),;//(outlog(__FILE__,__LINE__,FILE(cFile),cFile,FILESIZE(cFile))),;
    (;
    ;//outlog(__FILE__,__LINE__,FILE(cFile),cFile,FILESIZE(cFile)),;
    FILEAPPEND(cFile,"From1C.dat"),;
    FILEAPPEND("QOUT.dat","From1C.dat");
  );
  )})

  CLOSE deb
  CLOSE skdoc
  CLOSE bdoc

  CLOSE PersonalPrice
  CLOSE Confirm
  CLOSE Merch

  CLOSE Sales
  CLOSE price
  CLOSE price_full
  CLOSE tmp_ktt
  CLOSE tmp_kpl
  CLOSE TPoints

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  16.11.06 * 13:28:59
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Ref_System_ini(nRun,ktar, nAgSk,cFio,dShDateBg, dShDateEnd,aPrice)
#ifdef __CLIP__
  LOCAL oObj:=map()
#endif
  //��� � �६� ���㧪� ������. ���祭�� �⮩ ����⠭�� ������ ���������
  //� ����� 䠩� ���㧪�.
  oObj:GUID_SYSTEM_TIMEUNLD:={ DTOC(DATE())+" "+CHARREPL(":", TIME(), "-"), "5A9D4A4C-CC7A-49F8-8C4E-6E23B964CACB" }
  //"2006-10-15 15-12-36"

    //��� ��砫� ��ਮ�� ���ਨ �த��, ���㦠���� � 䠩��.
    oObj:GUID_SYSTEM_SHDATEBG:={ DTOC(LastMonday(dSHDATEBG)), "3935BEAE-9F40-4BA5-BA9E-03F860CC1750" }
    //
    //��� ���� ��ਮ�� ���ਨ �த��, ���㦠���� � 䠩��
    oObj:GUID_SYSTEM_SHDATEND:={ DTOC(LastMonday(dShDateEnd)+7-2), "3343E400-1577-4DDE-9A82-BF1E53267FD6" }

  IF !EMPTY(nRun)
    //����⠭� = 1, � �ணࠬ�� �஢���� ��� ���㬥�⮢ "���", "���������"
    //� "��������� ஧��筠�" �롮� ���㬥�� "���祭�������" � ���� "���祭�������"
    //������� �������⥫쭮. �᫨ �-�� �� ��࠭, � �ணࠬ�� �।�०���� �
    //����室����� ����� ���-�� ���祭�������� � �� ���뢠�� ���� ������. �����
    //�� �஢�ઠ ᤥ���� � �� ����⪥ ��������� ⠡����� ���� ���-� �.�.
    //���⥪�⭮� ���� ⠡��筮� ���.
    //���⨥ ०��� �஢�ન ����砥��� �� ���㧪� � ��� �⮩ ���⠭�� � ���祭��� "0"
    IF gnEnt=20
      oObj:GUID_SYSTEM_DOCMERCHSEL:={"1","19AB0B3D-EE81-461B-91E8-C47C5E76E324"}
    ELSE
      oObj:GUID_SYSTEM_DOCMERCHSEL:={"0","19AB0B3D-EE81-461B-91E8-C47C5E76E324"}
    ENDIF
    //
    //������⠭� �ᯮ������ ��� ���㧪� � ��� ᮪�饭���� �������� �������
    //����७�� ��� �� 㬮�砭��. �᫨ ���祭�� ����⠭�� �� 㪠����, � ��
    //���祭�� ��⠭���������� � "��".
    oObj:GUID_SYSTEM_WEIGHT_UNIT:={"��","CF527139-1867-4A66-8C44-ABD2D9AE202C"}
    //
    //������� � ��ப� �������� ���ਨ ���⪮� ⮢�஢ (���ਨ
    //���祭��������). �᫨ ���祭�� ����⠭�� �� 㪠����, � �� ���祭��
    //��⠭���������� � "����.:" (�.�. "���祭�������").
    oObj:GUID_SYSTEM_MERCH:={"����.","3A27217E-46BD-449E-8C95-574076DB9087"}
    //
    //��� �࣮���� �����, ��� ���ண� �।�����祭� ���㦠��� �����.
    oObj:GUID_SYSTEM_AGENTNAME:={ ;
    ALLTRIM(PADL(LTRIM(STR(ktar,3)), 3, "0"))+ALLTRIM(STR(nAgSk,3))+" "+;
    cFio, "FB55C4DC-885C-4D39-AB62-44FBAE50F1AC" }
    //
    //�����䨪��� �࣮���� �����.
    oObj:GUID_SYSTEM_AGENTID:={ GUID_KPK("B",ALLTRIM(PADL(LTRIM(STR(ktar,3)), 3, "0"))+ALLTRIM(STR(nAgSk,3))), "A2F737BD-37CD-4F08-910B-9E2A130226D4" }
    //
    //�����䨪��� ��� �� 㬮�砭��. ��ଠ ���⠢����� ��⮬���᪨ � �����
    //���� ᮧ������� ���㬥��.
    oObj:GUID_SYSTEM_FIRMID:={ "8FC6CB94-AEFD-4498-951C-7BAEA9298658", "30AC90F6-99D2-439f-8AA2-007FF391DEA4" }
    //��� "�த������"
    //
    //���᮪ ᪨��� � ���㬥�� "���". ���ਬ��: "0, 1, 2.5, 3, 5". �᫨
    //���祭�� ����⠭�� ���⮥ (���ਬ��, ���祭�� "�஡��"), ⮣�� ���짮��⥫�
    //� ��� ����� 㪠�뢠�� ᪨��� �� �롨�� �� �� ᯨ᪠, � � ���� �᫮����
    //���祭��, ����� ��� � ����������.
    //������ 㪠�뢠���� � �筮���� �� 0 �� 4 ������ ��᫥ ����⮩.
    //����⥫쭮 ᪨��� �ᯮ������ � ���浪� �����⠭��. ������⢮ ᪨���
    //��࠭�稢����� ࠧ��஬ ��ப� ᯨ᪠ ᪨��� - ��� �� ������ �ॢ���� 128
    //ᨬ�����.
    oObj:GUID_SYSTEM_DISCOUNTS:={ "0", "AA82CC96-4485-4351-98D8-BCF2EFFB5F7D" }
    //7D  0,3,4,5,5.5,7,10
    //

    //��� � �६� ���㧪� ������. ���祭�� �⮩ ����⠭�� ������ ���������
    //� ����� 䠩� ���㧪�.
    oObj:GUID_SYSTEM_TIMEUNLD:={ DTOC(DATE())+" "+CHARREPL(":", TIME(), "-"), "5A9D4A4C-CC7A-49F8-8C4E-6E23B964CACB" }
    //"2006-10-15 15-12-36"

    //
    //������⢮ ������ ��᫥ ����⮩ ��� 㪠����� �஡���� ������⢠ ⮢��
    //(�� 0 �� 4 ������). � ��� �� ������ ⮢�� � ���㬥��� (��� ��
    //।���஢���� ������⢠ ⮢�� � ���㬥��) ����᪠����  㪠����� �஡���
    //������� ⮫쪮 ��� ⮢�஢, � ������
    //������� �ਧ��� "��ᮢ��" (�. ࠧ��� 2.8 "�� Ref_Price" �� ���. 23).
    oObj:GUID_SYSTEM_AMNTPRECISION:={ "1", "0980573E-CA63-4C1D-941D-09218063BF40" }
    //
    //�������� ��樮���쭮� ������ (�� ����� ��� ᨬ�����). �᫨ ����⠭� ��
    //㪠����, � �������� ������ ��⠭���������� ��� "��".
    oObj:GUID_SYSTEM_MONEYNAME:={ "��", "28C8F78E-61BB-4F8A-AA5E-E242B680067B" }
    //
    //�ᯮ������ ��� 㪠����� ����७��� ����஥� �����+. � ����⠭�
    //㪠�뢠���� ���祭�� ��᪮�쪨� ��ࠬ��஢, ������� �� ࠡ��� �����+.
    //� ����⠭� 㪠�뢠���� ᫥���騥 ��ࠬ����:
    //discount - �ਭ����� ���祭��, ����� ��������� ᫮������ �᫮��� ����稭,
    //             ����뢠���� ����:
    //1 - � ���㬥��� "���" � "���������" �ਬ������ ��業��� ������
    //     ���� ᪨���: (X * 100 / (100+������), ���� � ���㬥��� �ਬ������
    //     �⠭����� ������ ���� ᪨���: (X * (100-������) / 100)
    //     (���祭�� �� 㬮�砭�� - 0);
    //2 - � ���㬥��� "���" � "���������" �������� 㪠����� ᪨��� ���
    //    ������� ⮢�� � ⠡��筮� ���, ���� ᪨��� 㪠�뢠���� ⮫쪮
    //    �� ���� ���㬥��;
    //4 - � ���㬥��� "���" � "���������" ���� ᪨��� ���� �� �㬬�
    //    ⮢�஢ � ������ ��ப� ���㬥�⮢, ���� ���� ᪨��� ���� ��
    //    業� ⮢�� � ������ ��ப� ���㬥��.
    //�ਬ�� �ᯮ�짮����� ��ࠬ��� discount.
    //�᫨ � ����⠭� 㪠���� ���祭�� "discount=6" (१���� �㬬� 2+4),
    //� �� ����砥�, �� � ���㬥��� �ᯮ������ �⠭����� ������ ����
    //᪨���, �������� 㪠����� ᪨��� ��� ������� ⮢�� � ⠡��筮� ���,
    //���� ᪨��� ���� �� �㬬� ⮢�� � ������ ��ப�.
    //
    //fltgoods - ��ࠬ��� ������ ०�� �ᯮ�짮����� ���ᮭ����� 䨫��஢ ⮢�஢
    // �� ������ ⮢�஢ � ���㬥���. ������ ⮢�஢ ��⠭���������� ���ᮭ��쭮
    // � ����ᨬ��� �� ��࠭���� � ���㬥�� ������ ��� �࣮��� �窨.
    //�������� ���祭�� ��ࠬ���:
    //0 - �� �ᯮ�짮���� ���ᮭ���� 䨫���� ⮢�஢;
    //1 - ⮢���, �⢥��騥 䨫����, �����뢠���� ����ભ��묨 � ���� ������
    //    ⮢�஢;
    //2 - ⮢���, �� �⢥��騥 䨫����, �� �����뢠���� � ���� ������ ⮢�஢.
    //4 - ����砥��� 䨫��� �᫮��� ���, ���� ����砥��� 䨫��� �᫮��� �.
    //��� �������� ���祭�� ���ᮭ����� 䨫��஢ ⮢�஢ ���ᠭ� � ࠧ�����
    //2.4 "�� Ref_Clients" � "2.5 �� Ref_TPoints".
    oObj:GUID_SYSTEM_FLAGS:={ "discount=6 fltgoods=1", "A44AFE59-9F8B-47D8-BB94-4CB447170EF2" }
    //oObj:GUID_SYSTEM_FLAGS:={ "discount=4 fltgoods=1", "A44AFE59-9F8B-47D8-BB94-4CB447170EF2" }
    //
    //
    //�ᯮ������ ��� ��।�� � ��� �����䨪��� ��।������� ᪫���, �����
    //���९��� �� �࣮�� ����⮬. ����⠭� �ᯮ������ ⮫쪮 � "������"
    oObj:GUID_SYSTEM_MSTOREID:={ NIL, "2AEBEC0B-20B0-46f1-99D9-20661AEDA77A" }
    //
    //���ᨬ��쭮� ������⢮ ⨯�� 業, �ᯮ��㥬�� � �ࠩ�-����.
    //�᫨ ����⠭� �� 㪠����, � �� ���祭�� ��⠥��� ࠢ�� 10. ���ᨬ��쭮
    //�����⨬�� ������⢮ ⨯�� 業 � �����+ - �� ����� 32 ⨯� 業.
    //������������ 㪠�뢠�� ⮫쪮 �ᯮ��㥬�� ������⢮ ⨯�� 業 -
    //祬 ����� ���祭�� �⮩ ����⠭��, ⥬ ����� �㤥� ��ꥬ �� � ���.
    //�����! ����⠭�� � 䠩�� ���㧪� ᫥��� �ᥣ�� 㪠�뢠�� ��। ���
    //Ref_Price (�� ��易⥫쭮 �ࠧ� ��। ��� - �����筮, �⮡� ���祭��
    //����⠭�� � 䠩�� ���㧪� �뫮 ������ �� ��砫� �� Ref_Price).
    //������ ⠪ �� ࠧ��� 2.8 "�� Ref_Price".
    oObj:GUID_SYSTEM_PRICECOUNT:={ LTRIM(STR(LEN(aPrice),2)), "8166BF59-8507-45B3-AF14-A3D111DBC61C" }
    //
    //���饭�� � ��� ��� ��⮬���᪮�� ���� �६��� ���⠢�� ⮢��.
    //���祭�� ����⠭�� �ᯮ������ ��� ��⮬���᪮�� ���⠢����� �६���
    //���⠢�� ⮢�஢ � ���㬥��� "���". �� ᮧ����� ������ ���㬥�� �
    //��� � ⥪�饬� ��⥬���� �६��� � ��� �ਡ������� ���祭�� �⮩ ����⠭��
    //� ⠪�� ��ࠧ�� �����뢠���� �ਬ��� ��� � �६� ���⠢�� ⮢��,
    //���஥ ���⠢����� � ���㬥�� � ४����� "�६� ���⠢��". �����⨬�
    //�㫥��� ���祭�� ����⠭�� - � �⮬ ��砥 ���짮��⥫� �ᥣ�� �ॡ���
    //� 㪠�뢠�� �६� ���⠢�� ᠬ����⥫쭮.
    oObj:GUID_SYSTEM_TIMEDLVDISP:={ "24", "24EB38BB-DD8E-4816-9A29-9DA53EEB6BAE" }
    //
    //������⢮ ������ ��᫥ ����⮩ ��� 㪠����� �஡��� ���祭�� ᪨���
    //(�� 0 �� 4 ������) � ���㬥��� � �ࠢ�筨�� �����⮢. �᫨ ����⠭� �
    //�� �� 㪠����, � �� ���祭�� ��ࠢ�������� � 1. ���祭�� ����⠭��
    //���뢠���� ⮫쪮 �᫨ � �����+ ����祭 �᫮��� ०�� ����� ᪨���
    //(ᬮ��� ��� ���ᠭ�� ����⠭�� oObj:GUID_SYSTEM_DISCOUNTS).
    oObj:GUID_SYSTEM_DSCNTRECISION:={ NIL, "24EB38BB-DD8E-4816-9A29-9DA53EEB6BAE" }
    //
    //�᭮���� �⠢�� ��� � ��業��. �᫨ ����⠭� �� 㪠����, � ���祭��
    //����⠭�� ��ࠢ�������� � 18.
    oObj:GUID_SYSTEM_VATRATE:={ "20", "EE7AE207-9BE2-4494-85C8-433DB1AEA735" }

    //
    //�������� � ����⠭� ⥫�䮭�� ����� �����뢠���� � ��� � ����
    //"� �ணࠬ��" � ���� ���� ����� ⥫�䮭���� ����� �� ����⨨ �� ������
    //"������ ���ࠬ". �᫨ ⥫�䮭��� ����஢ ��᪮�쪮, �� ����� 㪠�뢠��
    //�१ �������.
    //�᫨ �����+ ��⠭���������� �� ����㭨����**, ������ �㭪�� ������� ���
    //���������� ���짮��⥫� ����� �易���� � �ମ�, ����ਢ襩 �����+
    //�������.
    oObj:GUID_SYSTEM_AUTHOR_TEL:={ "+380972137756", "2D9C4ED7-6CC4-4145-8721-F344BC24E1FA" }

    //
    //��������㥬�� �६� (� ᥪ㭤��), ����稢����� �� 㯠����� �ࠩ�-���� �
    //��� (㯠����� �ࠩ�-���� ����᪠���� �ᥣ�� ��। ����㧪�� � ��� ��
    //Ref_Price � ०��� Full). �᫨ �६�, ����稢����� ��� �� 㯠�����
    //�ࠩ�-����, �ॢ�蠥� ४�����㥬��, � ��� ��᫥ ����㧪� ������
    //�����뢠�� ���짮��⥫� � ���ଠ樮���� ���� ४������樨 ��� ����襭��
    //᪮��� ����㧪� ������ � ���. ���祭�� ����⠭�� ����� �� ����� ��
    //१���� ����㧪� ��� ������ � ��� - �� ����� �� 䠩�� ����㦠����
    //���४⭮ � �� ��砥.
    //�᫨ ����⠭� � �� �� 㪠����, � �� ���祭�� ��ࠢ�������� � 60
    //ᥪ㭤��.
    oObj:GUID_SYSTEM_PRICEPACKTIME:={ "60", "F83718D6-C6E8-404A-AFF5-B4D3A3F9503F" }


    //
    //���� � ����� ���⨭�� ⮢�஢ � ���. ���祭�� ������ ����⠭�� �ᯮ������
    //�� ������ � ��� ���⨭�� ⮢�஢. ������ ⠪ �� ࠧ��� 2.13
    //"�� Ref_GoodsPictures".
    oObj:GUID_SYSTEM_GOODS_PICT_PATH:={ NIL, "FA6B30C2-1D7F-46EC-8EAD-0979D2965747" }

  ENDIF

  RETURN (oObj)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  16.11.06 * 13:42:11
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION RSSave(oRef_System)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_System.txt

  qqout('<Begin>'+_T+'Ref_System'+_T+'Struct:ObjID,Value')
#ifdef __CLIP__
  FOR elem IN oRef_System
    IF (elem[ 1 ]#NIL)
      qout(elem[ 2 ]+_T+elem[ 1 ])
    ENDIF

  NEXT
#endif

  qout('<End>'+_T+'Ref_System')
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  20.11.06 * 12:18:33
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Ref_Sales(nRun, dSHDATEBG, dShDateEnd)
  LOCAL nKgp, nKpl, nMnTov, nQRest, i, nCurWeek, nCurWeekFor
  LOCAL cSales, nSales
  LOCAL aDt_Range,k

  /*
  IF DOW(dShDateEnd) >= 2 //����, ���
    dShDateEnd:=LastMonday(dShDateEnd)-2 //��३��� � �। ������
  ELSE
    dShDateEnd:=dShDateEnd - 3 //��३��� � �। ������
  ENDIF
  */

    dShDateBg:=LastMonday(dShDateBg) //�������쭨� �⮩ ������
    dShDateEnd:=LastMonday(dShDateEnd)+7-2 //�㡡�� ��������㥬�� ������

  //SEEK(STR(2399705))
  //BROWSE()

  //TOTAL ON STR(Kgp)+STR(MNTOV) FIELDS KVP TO KGp_MnTov
  //USE KGp_MnTov NEW

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_Sales.txt

  IF !EMPTY(nRun)
    QQOUT('<Begin>'+_T+'Ref_Sales'+_T+'Struct:TPointID,GoodsID,Sales')

    SELE tmp_ktt //�࣮�� �窨
    DBGOTOP()
    DO WHILE !EOF()
      nKgp:=Kgp
      nKpl:=Kpl

      lWeek_One:=.F.
      aDt_Range:={}

      IF TPoints->(DBSEEK(STR(nKPL)+STR(nKGP)))
        IF !EMPTY(TPoints->RouteTime) .AND. LEN(ALLTRIM(TPoints->RouteTime))>1

          aDt_Range:=Dt_Range(dShDateEnd,TPoints->RouteTime)
          //outlog(__FILE__,__LINE__,'"',TPoints->RouteTime,'"')
          //outlog(__FILE__,__LINE__,aDt_Range)
          //lWeek_One:=.T.
          //QUIT

        ELSE
          lWeek_One:=.T.
        ENDIF
      ELSE
        lWeek_One:=.T.
      ENDIF

      IF lWeek_One
        nWeekEnd:=WEEK(dSHDATEEND)+IIF(WEEK(dSHDATEBG) > WEEK(dSHDATEEND), 52, 0)
        //outlog(__FILE__,__LINE__,nCurWeekFor,nWeekEnd,WEEK(dSHDATEBG),WEEK(dSHDATEEND))

        k:=0
        FOR nCurWeekFor:=WEEK(dSHDATEBG) TO nWeekEnd

          IF WEEK(dSHDATEBG) > WEEK(dSHDATEEND)
            nCurWeek:=nCurWeekFor-IIF(WEEK(dSHDATEBG) > WEEK(dSHDATEEND) .AND. nCurWeekFor<=52, 0, 52)
           ELSE
            nCurWeek:=nCurWeekFor
          ENDIF
          AADD(aDt_Range,{dSHDATEBG+(7*k), dSHDATEBG+(7*(k+1))-1})
          k++
        NEXT
      ENDIF

      /*
      outlog(__FILE__,__LINE__,lWeek_One,'"',TPoints->RouteTime,'"',aDt_Range)
      IF nKgp = 8460198
        outlog(__FILE__,__LINE__,"!!!!!!!",nKgp,nKpl)
      ENDIF
      */

      i:=0

      SELE price
      DBGOTOP()
      DO WHILE !EOF()

        //nMnTov:=MnTov
        nMnTov:=MnTovT

        cSales:="" //��ப� � �த�����
        nSales:=0

        FOR k:=1 TO LEN(aDt_Range)
        //FOR nCurWeekFor:=WEEK(dSHDATEBG) TO nWeekEnd

          SELE Sales
          OrdSetFocus("KGp_MnTovT")
          IF DBSEEK(STR(nKpl)+STR(nKgp)+STR(nMnTov)) //+STR(nCurWeek,2))
            SUM KVP TO nKVP ;
            WHILE STR(nKpl)+STR(nKgp)+STR(nMnTov) = ;
              STR(Kpl)+STR(Kgp)+STR(MnTovT) ; // MnTov MnTovT
            FOR  Dop>=aDt_Range[k,1] .AND. Dop<=aDt_Range[k,2]
            //WHILE STR(nKpl)+STR(nKgp)+STR(nMnTov)+STR(nCurWeek,2) = STR(Kpl)+STR(Kgp)+STR(MnTov)+STR(WEEK(Dop),2)
          ELSE
            nKVP:=0
          ENDIF

          nQRest:=0
          SELE Merch
          OrdSetFocus("KGp_MnTovT")
          IF DBSEEK(STR(nKpl)+STR(nKgp)+STR(nMnTov)) //+STR(nCurWeek,2))
            SUM KVP TO nQRest ;
            WHILE STR(nKpl)+STR(nKgp)+STR(nMnTov) = ;
                  STR(Kpl)+STR(Kgp)+STR(MnTovT) ; // MnTov MnTovT
            FOR  Dop>=aDt_Range[k,1] .AND. Dop<=aDt_Range[k,2]
            //WHILE STR(nKpl)+STR(nKgp)+STR(nMnTov)+STR(nCurWeek,2) = STR(Kpl)+STR(Kgp)+STR(MnTov)+STR(WEEK(Dop),2)
          ELSE
            nQRest:=0
          ENDIF

          cSales+=LTRIM(STR(nQRest ,4,0))+":"+LTRIM(STR(nKVP ,4,0))+" "
          //cSales+=LTRIM(STR(nQRest ,4,0))+"|"+LTRIM(STR(nKVP ,4,0))+" "
          nSales+=(nQRest+nKVP)

          /*
          IF nKgp = 8460198
            outlog(__FILE__,__LINE__,nMnTov,nQRest,nKVP,aDt_Range[k,1],aDt_Range[k,2])
          ENDIF
          */

        NEXT

        IF ROUND(nSales,3) # 0 //���� �த���
          cSales:=RTRIM(cSales)
          QOUT(;
              ;//TPointID
                IIF(i=0, GUID_KPK("C",ALLTRIM(STR(nKgp)),ALLTRIM(STR(nKpl))),"*")+_T+      ;
              ;//GoodsID
                GUID_KPK("A",ALLTRIM(STR(nMnTov)))+_T+;
              ;//Sales
              RIGHT(cSales, 127)  ;
            )
          i++//����� ��㧮�����⥫�
        ENDIF


        SELE price
        SKIP
      ENDDO

      SELE tmp_ktt //�࣮�� �窨
      SKIP
    ENDDO

    QOUT('<End>'+_T+'Ref_Sales')

  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  12-28-07 * 01:02:08pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Dt_Range(dDateEnd,cRouteTime)
  LOCAL i, aDtRouteTime,dRouteTime, aDt_Range, dDate

  aDtRouteTime:={}
  aDt_Range:={}
  dDate:=dDateEnd

  DO WHILE .T.
    FOR i:=1 TO 7
      IF !EMPTY(SUBSTR(cRouteTime,i,1))

        dRouteTime:=LastMonday(dDate)+i-1
        AADD(aDtRouteTime, dRouteTime)


      ENDIF
    NEXT

    FOR i:=LEN(aDtRouteTime) TO 1 STEP -1
      IF i = LEN(aDtRouteTime)
        AADD(aDt_Range,{aDtRouteTime[i],dDateEnd+1}) //+1 - �.�. �㡡��, � �㤥� ����
      ELSE
        AADD(aDt_Range,{aDtRouteTime[i],aDtRouteTime[i+1]-1})
      ENDIF
      IF LEN(aDt_Range)=4 //���� ���������
        EXIT
      ENDIF
    NEXT
    IF LEN(aDt_Range)=4 //���� ���������
      EXIT
    ENDIF
    dDate:=dDate-7
    dDateEnd:=aDtRouteTime[1]-1-1 //�. ��� ���������� +1
    aDtRouteTime:={}
  ENDDO

  RETURN (aDt_Range)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  20.11.06 * 12:54:14
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Ref_TblStruct(nRun)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_TblStruct.txt

  IF !EMPTY(nRun)

    QQOUT('<Begin>'+_T+'Ref_TblStruct'+_T+'Struct:TblCD,FormOrder,Name,Present,Type,TypeID,Size,Flags')
    QOUT('Firms'+_T+'1'+_T+'FNAME'+_T+'����.������������'+_T+'2'+_T+''+_T+'128'+_T+'0')
    QOUT('Firms'+_T+'2'+_T+'INN'+_T+'���'+_T+'2'+_T+''+_T+'32'+_T+'0')
    QOUT('Firms'+_T+'3'+_T+'KPP'+_T+'���'+_T+'2'+_T+''+_T+'32'+_T+'0')
    QOUT('Firms'+_T+'4'+_T+'OKPO'+_T+'����'+_T+'2'+_T+''+_T+'16'+_T+'0')
    QOUT('Firms'+_T+'5'+_T+'BANK'+_T+'����'+_T+'2'+_T+''+_T+'64'+_T+'0')
    QOUT('Firms'+_T+'6'+_T+'BIK'+_T+'���'+_T+'2'+_T+''+_T+'32'+_T+'0')
    QOUT('Firms'+_T+'7'+_T+'BANKADR'+_T+'���� �����'+_T+'2'+_T+''+_T+'64'+_T+'0')
    QOUT('Firms'+_T+'8'+_T+'KSCHET'+_T+'���.���'+_T+'2'+_T+''+_T+'32'+_T+'0')
    QOUT('Firms'+_T+'9'+_T+'RSCHET'+_T+'����.���'+_T+'2'+_T+''+_T+'32'+_T+'0')
    QOUT('Firms'+_T+'10'+_T+'DIREKTOR'+_T+'��४��'+_T+'2'+_T+''+_T+'64'+_T+'0')
    QOUT('Firms'+_T+'11'+_T+'GLBUH'+_T+'��.��壠���'+_T+'2'+_T+''+_T+'64'+_T+'0')
    QOUT('Clients'+_T+'1'+_T+'INN'+_T+'���'+_T+'2'+_T+''+_T+'21'+_T+'1')
    QOUT('Clients'+_T+'2'+_T+'KPP'+_T+'���'+_T+'2'+_T+''+_T+'9'+_T+'1')
    QOUT('Clients'+_T+'3'+_T+'FNAME'+_T+'����.������������'+_T+'2'+_T+''+_T+'128'+_T+'0')
    QOUT('Clients'+_T+'4'+_T+'MSALES'+_T+'����� �த��'+_T+'1'+_T+''+_T+'2'+_T+'2')
    QOUT('Clients'+_T+'5'+_T+'SROKDOG'+_T+'������� ��'+_T+'3'+_T+''+_T+''+_T+'0')
    QOUT('Clients'+_T+'6'+_T+'VIP'+_T+'VIP-������'+_T+'20'+_T+''+_T+''+_T+'0')
    QOUT('Clients'+_T+'7'+_T+'CLKONKUR'+_T+'������ �����७⮢'+_T+'20'+_T+''+_T+''+_T+'0')
    QOUT('Clients'+_T+'8'+_T+'DEBTLIST'+_T+'��䨪 ������'+_T+'2'+_T+''+_T+'128'+_T+'0')
    QOUT('TPoints'+_T+'1'+_T+'TPTYPE'+_T+'��� �窨'+_T+'10'+_T+'5BB29DAF-6769-423A-AEAF-AEFE111736A0'+_T+''+_T+'0')
    QOUT('TPoints'+_T+'2'+_T+'WORKTIME'+_T+'�६� ࠡ���'+_T+'2'+_T+' '+_T+'64'+_T+'0')
    QOUT('Price'+_T+'1'+_T+'GTD'+_T+'���'+_T+'10'+_T+'EA2D47CD-0E34-4176-8EBF-F4A9AAF2716D'+_T+''+_T+'0')
    QOUT('Price'+_T+'2'+_T+'STRANA'+_T+'��࠭�-�ந��.'+_T+'10'+_T+'2BA57449-AECB-4C00-BDA0-E08120251AC7'+_T+''+_T+'0')
    QOUT('Sertif'+_T+'1'+_T+'BLANKN'+_T+'����� �'+_T+'2'+_T+''+_T+'32'+_T+'0')
    QOUT('Sertif'+_T+'2'+_T+'ADRES'+_T+'����'+_T+'2'+_T+''+_T+'64'+_T+'0')
    QOUT('Stores'+_T+'1'+_T+'AVTOSKLAD'+_T+'��।������ ᪫��'+_T+'20'+_T+''+_T+''+_T+'0')
    QOUT('Stores'+_T+'2'+_T+'TONNAJ'+_T+'������'+_T+'1'+_T+''+_T+'3'+_T+'0')
    QOUT('Stores'+_T+'3'+_T+'TEHOSM'+_T+'���ᬮ��'+_T+'3'+_T+''+_T+''+_T+'0')

    QOUT('Order'+_T+'1'+_T+'TRASP'+_T+'�࠭ᯮ��� ��㣨'+_T+'20'+_T+' '+_T+''+_T+'0')
    QOUT('Order'+_T+'2'+_T+'REPORT'+_T+'���� ��㣮� ���'+_T+'20'+_T+' '+_T+''+_T+'0')
    QOUT('Order'+_T+'3'+_T+'SERTIF'+_T+'����䨪���'+_T+'20'+_T+' '+_T+''+_T+'0')
    //QOUT('Order'+_T+'2'+_T+'REPORT'+_T+'���� �� ���������⠬'+_T+'20'+_T+' '+_T+''+_T+'0')
    QOUT('Order'+_T+'4'+_T+'DOSTAVKA'+_T+'��� ���⠢��'+_T+'10'+_T+'1124A28B-63EE-4F01-9AFA-37594D06CCCB'+_T+'0'+_T+'1')
    QOUT('Order'+_T+'5'+_T+'ADRES'+_T+'�����.���� ���⠢��'+_T+'2'+_T+' '+_T+'64'+_T+'0')
    QOUT('Order'+_T+'6'+_T+'SROK'+_T+'����� ��'+_T+'3'+_T+' '+_T+''+_T+'0')

    QOUT('Sale'+_T+'1'+_T+'DOSTAVKA'+_T+'��� ���⠢��'+_T+'10'+_T+'1124A28B-63EE-4F01-9AFA-37594D06CCCB'+_T+'0'+_T+'0')
    QOUT('Sale'+_T+'2'+_T+'ADRES'+_T+'�����.���� ���⠢��'+_T+'2'+_T+' '+_T+'64'+_T+'0')
    QOUT('Sale'+_T+'3'+_T+'DOSTAVLEN'+_T+'����� ���⠢���'+_T+'20'+_T+' '+_T+''+_T+'0')
    QOUT('Merch'+_T+'1'+_T+'FKAT_A'+_T+'���ᨭ� A (��⥣��� ⮢�஢ "A")'+_T+'1'+_T+''+_T+'0'+_T+'1')
    QOUT('Merch'+_T+'2'+_T+'FKAT_B'+_T+'���ᨭ� B (��⥣��� ⮢�஢ "B")'+_T+'1'+_T+''+_T+'0'+_T+'0')
    QOUT('Merch'+_T+'3'+_T+'FKAT_C'+_T+'���ᨭ� C (��⥣��� ⮢�஢ "C")'+_T+'1'+_T+''+_T+'0'+_T+'0')
    QOUT('Merch'+_T+'4'+_T+'FKAT_RP'+_T+'���ᨭ� �� (४������ �த���)'+_T+'1'+_T+''+_T+'0'+_T+'1')
    QOUT('Visit'+_T+'1'+_T+'VISIT'+_T+'������ ���饭��'+_T+'10'+_T+'FC233E4A-DA80-4481-B280-76CE1855CA9C'+_T+''+_T+'1')
    QOUT('<End>'+_T+'Ref_TblStruct')

  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  20.11.06 * 13:10:56
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Ref_Scripts(nRun)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_Scripts.txt
  IF !EMPTY(nRun)

    QQOUT('<Begin>'+_T+'Ref_Scripts'+_T+'Struct:ObjectID,Script')

    QOUT('CC56ADA6-3584-40A1-A83E-B5B1F5FA8648'+_T+'[Name]|�।��: [Credit], ������: [Discount]%|����: [Debt]|')
    QOUT('*'+_T+'[_DEBTLIST]|')
    QOUT('*'+_T+'VIP: [_VIP]; ������ �����७⮢: [_CLKONKUR]|-------|')
    QOUT('*'+_T+'���.: [Tel]|����: [Addr]|���: [_INN], ���: [_KPP]|[_FNAME]|')
    QOUT('*'+_T+'�த��� ���. �����: [_MSALES]|�ப �������: [_SROKDOG]')

    QOUT('5BD7E0A7-4B93-4962-8A62-1DF6F40FB56C'+_T+'[Name]|��⥣���: [Category]|����: [Zone]|-------|')
    QOUT('*'+_T+'����: [Addr]|���: [Tel]|����. ���: [Contact]|-------|')
    QOUT('*'+_T+'���: [_TPTYPE]|�६� ࠡ���: [_WORKTIME]')

    QOUT('<End>'+_T+'Ref_Scripts')

  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  20.11.06 * 13:17:34
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Doc_Move(nRun, ktar)
 LOCAL i1, i2
      i1:=0
      i2:=0
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Doc_Move.txt
  IF .F. .AND. !EMPTY(nRun)
    QQOUT('<Begin>'+_T+'Doc_Move'+_T+'Struct:DocID,DocState,DocFlags,TimeCrt,DocNumber,FirmID,StoreID,DocSum,MoveType,Comment,MDocID')
    QOUT('<Sub>'+_T+'Lines'+_T+'Struct:GoodsID,Amount,Price,Sum,=VAT')

    DBGOTOP()
    DO WHILE !EOF()
    //蠯�� ���㬥��
    QOUT(;
          ;//DocID GUID �����䨪��� ���㬥��.
          GUID_KPK("F",ALLTRIM(LTRIM(STR(SK))+PADL(LTRIM(STR(TTN)),7,"0")))+_T+             ;
          ;//DocState ��᫮ - 1.0 ����ﭨ� ���㬥��, ��� �� ������ ���� �।�⠢��� � ��ୠ�� ���㬥�⮢ ���:
          ;//1 - �஢����;2 - ����ᠭ.
          STR(1,1)+_T+;
          ;//DocFlags ��᫮ - 3.0 ���ᠭ�� ��ࠬ��� ᬮ��� � ࠧ���� 2.28 "�� Doc_Debt".
          STR(2+8+(64*0),3)+_T+;
          ;//TimeCrt ��� � �६� ��� � �६� ᮧ����� ���㬥��
          DTOC(DOP)+_T+;
          ;//DocNumber ��ப� - 25 ����� ���㬥��
          ALLTRIM(STR(SK))+" "+ALLTRIM(STR(TTN))+":"+STR(KOP)+":���"+_T+;
          ;//FirmID GUID �����䨪��� ���, �� ����� ���ன ��ଫ�� ���㬥��.
          IIF(i1=0,'8FC6CB94-AEFD-4498-951C-7BAEA'+PADL(LTRIM(STR(gnKkl_c)),7,'0'),"*")+_T+      ;
          ;//StoreID, GUID �����䨪��� ������ (��� �� �����)
          IIF(i2=0, GUID_KPK("CAC",PADL(LTRIM(STR(ktar,3)), 3, "0")),"*")+_T+      ;
          ;//DocSum ��᫮ 15.2 �㬬� ����� �� ���㬥��.
          LTRIM(STR(SDV,15,2))+_T+;
          ;//MoveType 1 - ����㧪� � ��設�, 2-���㧪�
          IIF(.T.,"1","2")+_T+;
          ;//Comment ��ப� - 128 �������਩ � ���㬥���.
          LEFT(PADL(LTRIM(STR(ktar,3)), 3, "0"),128)+_T+;
          ;//MDocID
          ;//MDocID GUID �����䨪��� ���㬥��, �� �᭮����� ���ண� ������ �थ�.
          IIF(.T.,"",GUID_KPK("D",ALLTRIM(PADL(LTRIM(STR(898989)),6,"0"))))             ;
      )
        //⮢�ୠ� ����
         QOUT('<Begin>'+_T+'Lines')
         nTtn:=Ttn
         DO WHILE nTTn = ttn
           QOUT(;
              ;//GoodsID
              GUID_KPK("A",ALLTRIM(STR(MnTovT)))+_T+;
              ;//Amount �᫮ 15.4 -  ������⢮ ⮢�� � ������� ��.���
              ALLTRIM(STR(KVP, 15, 4))+_T+        ;
              ;//Price
              ALLTRIM(STR(ZEN, 15, 2))+_T+        ;
              ;//Sum
              ALLTRIM(STR(SVP, 15, 2))+_T+        ;
              ;//=VAT 15, 2
              ALLTRIM("")        ;
              )
          DBSKIP()
         ENDDO
        QOUT('<End>'+_T+'Lines')
    ENDDO
    QOUT('<End>'+_T+'Doc_Move')

  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  20.11.06 * 13:37:11
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Doc_Sale(nRun)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Doc_Sale.txt

  IF !EMPTY(nRun)
    /*
    QQOUT('<Begin>'+_T+'Doc_Sale'+_T+'Struct:DocID,DocState,DocFlags,TimeCrt,DocNumber,FirmID,ClientID,=TPointID,DocSum,=DocVAT,=Discount,Comment,=PaymntType,=PriceType,=PayDate,MDocID,=SFNumber,=UseVAT,_DOSTAVKA,_ADRES,_DOSTAVLEN')

    QOUT('<Sub>'+_T+'Lines Struct:GoodsID,Amount,Price,Sum,=VAT")
    QOUT('//5272A5EA-67D6-421E-68E5-A7824FA3798A  2 10  2006-10-02 15-34-36 0CKC000003  8FC6CB94-AEFD-4498-951C-7BAEA9298658  A0BA5952-CA7C-4510-8DBC-4F87492B08A3  CB17BD0F-3EFA-41E4-AEF6-C99B6B3BBE3F  926.9 141.39  0   0 1 2006-08-16  52724719-B7D6-47FE

    -C4BD-7107F46BBD42  1 0  0')
    QOUT('//<Begin>'+_T+'Lines')
    QOUT('//F51F7461-A33D-4838-9D19-758344C30997  23  40.3  926.9 141.39')
    QOUT('//<End>'+_T+'Lines')
    QOUT('<End>'+_T+'Doc_Sale')
    */
  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  20.11.06 * 13:45:35
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Doc_Debt(nRun,ktar)
  LOCAL i1, i2, ktasr
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Doc_Debt.txt
  IF !EMPTY(nRun)
  //QQOUT("<Begin>"+_T+"Doc_Debt"+_T+"Struct:DocID,DocState,DocFlags,TimeCrt,DocNumber,FirmID,ClientID,=TPointID,DocSum,Comment,=DocDescr,FullSum,PayDate")
  QQOUT("<Begin>"+_T+"Doc_Debt"+_T+"Struct:DocID,DocState,DocFlags,TimeCrt,DocNumber,FirmID,ClientID,=TPointID,DocSum,Comment,=DocDescr,FullSum,PayDate")
    SELE skdoc
    SET FILTER TO !DELETED()

    locate for ktan=ktar
    ktasr:=ktas

    DBGOTOP()

    SELE tmp_kpl
    //SET RELA TO STR(kpl,7) INTO skdoc
    DBGOTOP()
    WHILE (!EOF())
      IF STR(tmp_kpl->Kpl)$"     20034"
        SELECT tmp_kpl
        DBSKIP()
        LOOP
      ENDIF
      IF !skdoc->(DBSEEK(STR(tmp_kpl->kpl,7)))
        SELECT tmp_kpl
        DBSKIP()
        LOOP
      ENDIF
      i1:=0
      i2:=0

      SELE skdoc
      DO WHILE skdoc->Kpl = tmp_kpl->Kpl

        IF iif(.F.,ktasr=ktas,.T.) //�뢮��� ⮫쪮 �-��, � ����� � ������ � �ਭ������� �㯥�� ��ࣀ����
          QOUT(;
            ;//DocID GUID �����䨪��� ���㬥��.
            GUID_KPK("F",ALLTRIM(LTRIM(STR(SK))+PADL(LTRIM(STR(TTN)),7,"0")))+_T+             ;
            ;//DocState ��᫮ - 1.0 ����ﭨ� ���㬥��, ��� �� ������ ���� �।�⠢��� � ��ୠ�� ���㬥�⮢ ���:
            ;//1 - �஢����;2 - ����ᠭ.
            STR(1,1)+_T+;
            ;//DocFlags ��᫮ - 3.0 ���ᠭ�� ��ࠬ��� ᬮ��� � ࠧ���� 2.28 "�� Doc_Debt".
            ;//STR(2+8+(64*iif(ktasr=ktas,1,0)),3)+_T+;
            STR(2+8+(64*iif(ktan=ktar,1,0)),3)+_T+;
            ;//TimeCrt ��� � �६� ��� � �६� ᮧ����� ���㬥��
            DTOC(DOP)+_T+;
            ;//DocNumber ��ப� - 25 ����� ���㬥��
            ALLTRIM(STR(SK))+" "+ALLTRIM(STR(TTN))+":"+STR(KOP)+":���"+_T+;
            ;//FirmID GUID �����䨪��� ���, �� ����� ���ன ��ଫ�� ���㬥��.
            IIF(i1=0,'8FC6CB94-AEFD-4498-951C-7BAEA'+PADL(LTRIM(STR(gnKkl_c)),7,'0'),"*")+_T+      ;
            ;//ClientID GUID �����䨪��� ������.
            IIF(i2=0, GUID_KPK("C",ALLTRIM(STR(Kpl))),"*")+_T+      ;
            ;//=TPointID GUID �����䨪��� �࣮��� �窨 (�� ��易⥫��).
            GUID_KPK("C",ALLTRIM(STR(KGp)),ALLTRIM(STR(Kpl)))+_T+      ;
            ;//DocSum ��᫮ 15.2 �㬬� ����� �� ���㬥��.
            LTRIM(STR(SDP,15,2))+_T+;
            ;//Comment ��ப� - 128 �������਩ � ���㬥���.
            LEFT(ALLTRIM(NKtaN),128)+_T+;
            ;// ,=DocDescr ��� ���㬥�� (�� ��易⥫��)
            LEFT(ALLTRIM("���"),24)+_T+;
            ;//FullSum ��᫮ 15.2 �㬬� ���㬥��.
            LTRIM(STR(SDV,15,2))+_T+;
            ;//PayDate  ��� ������ ���㬥��
            DTOC(IIF(EMPTY(DtOpl), DOP+14,DtOpl));
          )
          i1:=0//1
          i2:=0//1
        ENDIF
        DBSKIP()
      ENDDO

      SELECT tmp_kpl
      DBSKIP()
    ENDDO

  /*
  QOUT("//926A2A53-07D0-48C6-B539-084C8599B5C6  1 73  2004-02-28 12-00-00 0000000008  C76B90B5-9180-4E0E-B723-6A864BB408A8  99663023-26D9-4963-B71E-BF7246718A55  6BBBA48E-E872-453F-B470-DFF6F91444C0  1291.4    ���������  1491.4  2004-03-04")
  */
    QOUT("<End>"+_T+"Doc_Debt")

    SELE skdoc
    SET FILTER TO
    SELE tmp_kpl
    SET RELA TO

  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  01-15-07 * 02:29:25pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Doc_Cash(nRun)
  LOCAL i1, i2
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Doc_Cash.txt
  IF !EMPTY(nRun)
  //QQOUT("<Begin>"+_T+"Doc_Cash"+_T+"Struct:DocID,DocState,DocFlags,TimeCrt,DocNumber,FirmID,ClientID,=TPointID,DocSum,=DocVAT,MDocID,Comment,=PaymntType")
  QQOUT("<Begin>"+_T+"Doc_Cash"+_T+"Struct:DocID,DocState,DocFlags,TimeCrt,DocNumber,FirmID,ClientID,DocSum,MDocID,Comment")
    SELE bdoc
    SET FILTER TO !DELETED()
    DBGOTOP()

    SELE tmp_kpl
    //SET RELA TO STR(kpl,7) INTO skdoc
    DBGOTOP()
    WHILE (!EOF())
      IF STR(tmp_kpl->Kpl)$"     20034"
        SELECT tmp_kpl
        DBSKIP()
        LOOP
      ENDIF
      IF !bdoc->(DBSEEK(STR(tmp_kpl->kpl,7)))
        SELECT tmp_kpl
        DBSKIP()
        LOOP
      ENDIF
      i1:=0
      i2:=0

      SELE bdoc
      DO WHILE bdoc->KKl = tmp_kpl->Kpl
        QOUT(;
          ;//DocID GUID �����䨪��� ���㬥��.
          GUID_KPK("D",ALLTRIM(LTRIM(DTOS(DDK))+PADL(LTRIM(STR(RND)),6,"0")))+_T+             ;
          ;//DocState ��᫮ - 1.0 ����ﭨ� ���㬥��, ��� �� ������ ���� �।�⠢��� � ��ୠ�� ���㬥�⮢ ���:
          ;//1 - �஢����;2 - ����ᠭ.
          STR(1,1)+_T+;
          ;//DocFlags ��᫮ - 3.0 ���ᠭ�� ��ࠬ��� ᬮ��� � ࠧ���� 2.28 "�� Doc_Debt".
          STR(2+8+(64*0),3)+_T+;
          ;//TimeCrt ��� � �६� ��� � �६� ᮧ����� ���㬥��
          DTOC(DDK)+_T+;
          ;//DocNumber ��ப� - 25 ����� ���㬥��
          ALLTRIM(STR(NPLP))+"/"+ALLTRIM(STR(RND))+_T+;
          ;//FirmID GUID �����䨪��� ���, �� ����� ���ன ��ଫ�� ���㬥��.
          IIF(i1=0,'8FC6CB94-AEFD-4498-951C-7BAEA'+PADL(LTRIM(STR(gnKkl_c)),7,'0'),"*")+_T+      ;
          ;//ClientID GUID �����䨪��� ������.
          IIF(i2=0, GUID_KPK("C",ALLTRIM(STR(KKL))),"*")+_T+      ;
          ;//=TPointID GUID �����䨪��� �࣮��� �窨 (�� ��易⥫��).
          ;//DocSum ��᫮ 15.2 �㬬� ���㬥��. ��� ��室��� ���ᮢ�� �थ஢ �㬬� 㪠�뢠���� ����� ���.
          LTRIM(STR(BS_S,15,2))+_T+;
          ;//=DocVAT ��᫮ 15.2 �㬬� ��� ���㬥��.
          ;//MDocID GUID �����䨪��� ���㬥��, �� �᭮����� ���ண� ������ �थ�.
          IIF(.T.,"",GUID_KPK("D",ALLTRIM(LTRIM(DTOS(DDK))+PADL(LTRIM(STR(RND)),6,"0"))))+_T+             ;
          ;//Comment ��ப� - 128 �������਩ � ���㬥���.
          LEFT(ALLTRIM(STR(BS_D,6,0)+":"+OSN),128);
          ;//= PaymntType ��᫮ - 10.0 ��� ���� ������ ���㬥�� (�� ��易⥫��)
        )
        i1:=0//1
        i2:=0//1
        DBSKIP()
      ENDDO

      SELECT tmp_kpl
      DBSKIP()
    ENDDO

  /*
  QOUT("//926A2A53-07D0-48C6-B539-084C8599B5C6  1 73  2004-02-28 12-00-00 0000000008  C76B90B5-9180-4E0E-B723-6A864BB408A8  99663023-26D9-4963-B71E-BF7246718A55  6BBBA48E-E872-453F-B470-DFF6F91444C0  1291.4    ���������  1491.4  2004-03-04")
  */
    QOUT("<End>"+_T+"Doc_Cash")

    SELE bdoc
    SET FILTER TO
    SELE tmp_kpl
    SET RELA TO

  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  20.11.06 * 13:52:32
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Ref_Barcodes()
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_Barcodes.txt

  /*
  QQOUT('<Begin>'+_T+'Ref_Barcodes'+_T+'Struct:GoodsID,Name,=UnitCode')

  //QQOUT('6B8C0DC0-38EE-4B6A-883D-F432FCC0C5E4'+_T+'5995327275147'+_T+'2')
  //QQOUT('9867C63E-BF08-41B8-833B-3110695BF708'+_T+'4605658044060'+_T+'0')
  //QQOUT('*'+_T+'5411416003731'+_T+'0')
  //QQOUT('B694272D-C5F9-4E29-896F-EE7EB2085DD0'+_T+'5000174439090'+_T+'1')

  QOUT('<End>'+_T+'Ref_Barcodes')
  */

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  20.11.06 * 14:26:30
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Ref_Firms(nRun)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_Firms.txt
  IF !EMPTY(nRun)
    kln->(netseek("t1","gnKkl_c"))
    QQOUT('<Begin>'+_T+'Ref_Firms'+_T+'Struct:FirmID,Name,=CodesList,=Addr,=Tel,=UseVAT,=UseSF,=DocPrefix,_FNAME,_INN,_KPP,_OKPO,_BANK,_BIK,_BANKADR,_KSCHET,_RSCHET,_DIREKTOR,_GLBUH')
    QOUT('8FC6CB94-AEFD-4498-951C-7BAEA'+PADL(LTRIM(STR(gnKkl_c)),7,'0')+_T+;//'9298658'
    LEFT(ALLTRIM(kln->NKLE),64)+_T+; //'�த�����'
    '1,2,3,4,5'+_T+;
    LEFT(ALLTRIM(kln->ADR),128)+_T+; //'�.���, �. ����� 7'
    LEFT(ALLTRIM(kln->TLF),64)+_T+; //'22-33-55, 56-66-67'
    '1'+_T+'1'+_T+'����'+_T+;
    LEFT(ALLTRIM(kln->NKL),64)+_T+;//'��� "�த�����"'
    '0056123412'+_T+'005601123'+_T+'4564311'+_T+;
    '��� "���-����"'+_T+'044599774'+_T+;
    '�.����'+_T+'30101810100000000774'+_T+'40702810900000109991'+_T+'����஢ �.�.'+_T+'���祭�� �.�.')

    QOUT('<End>'+_T+'Ref_Firms')

  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  21.11.06 * 08:59:00
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Ref_Stores(nRun)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_Stores.txt
  IF !EMPTY(nRun)
    /*
    QQOUT('<Begin>'+_T+'Ref_Stores'+_T+'Struct:ObjID,Name,_AVTOSKLAD,_TONNAJ,_TEHOSM')
    QOUT('//3746A311-78A0-463E-B61D-5D0263C38920'+_T+'�/� ������ �248'+_T+'1'+_T+'0'+_T+'2005-12-01')
    QOUT('//0B452C0F-0EC7-46F7-8669-5487662F92D7'+_T+'�/� ��� �329'+_T+'1'+_T+'1.5'+_T+'2005-07-01')
    QOUT('//F58FBEC2-FAC4-48A3-AB7B-AA28259189AD'+_T+'�᭮����'+_T+'0'+_T+'0'+_T+'2000-01-01')
    QOUT('//4F049830-21D7-4C7E-A593-4FA800D198FB'+_T+'������'+_T+'0'+_T+'0'+_T+'2000-01-01')
    QOUT('<End>'+_T+'Ref_Stores')
    */
  ENDIF
  SET PRINT TO
  SET PRINT OFF
 RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  21.11.06 * 08:59:00
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Ref_Commands(nRun)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_Commands.txt
  IF !EMPTY(nRun)
    QQOUT('<Begin>'+_T+'Ref_Commands'+_T+'Struct:CmdCode,Arg')
    //QOUT('DeleteOldDocuments'+_T+'-31 DocList:Order,Sale,Merch') //�� ���⢥ত���� �� 㤠���
    QOUT('DeleteAllDocuments'+_T+'-14 DocList:Order,Sale,Merch') //�� 㤠���
    IF DATE()<=STOD("20071231")
      QOUT('Message'+_T+;
      ;//'       ======         '+;
      ;//'   === �������� ===   '+;
      ;//'       ======         '+;
      ;//'                       '+;
      ;//'     �������� �����        '     �����������       '+;
         '    ������� ������ ������������ �� ����������      '+;
         '              (� �� �������쭮)                    '+;
         '      �������, �᫨ �㦭� ����� �த��          '+;
      ;//'                       '+;
      ;//'       ======         '+;
      "";//'       ======         ';
    )
    ENDIF
    /*QOUT('Message'+_T+'!   === �������� ===   ')
    QOUT('Message'+_T+'!       ======         ')
    QOUT('Message'+_T+'                       ')
    QOUT('Message'+_T+'    �������� �����     ')
    QOUT('Message'+_T+'     �����������       ')
    QOUT('Message'+_T+' (���/�������⥫쭮)')
    QOUT('Message'+_T+'                       ')
    QOUT('Message'+_T+'!       ======         ')
    QOUT('Message'+_T+'!       ======         ')*/

    /*
    QOUT('//0B452C0F-0EC7-46F7-8669-5487662F92D7'+_T+'�/� ��� �329'+_T+'1'+_T+'1.5'+_T+'2005-07-01')
    QOUT('//F58FBEC2-FAC4-48A3-AB7B-AA28259189AD'+_T+'�᭮����'+_T+'0'+_T+'0'+_T+'2000-01-01')
    QOUT('//4F049830-21D7-4C7E-A593-4FA800D198FB'+_T+'������'+_T+'0'+_T+'0'+_T+'2000-01-01')
    */
    QOUT('<End>'+_T+'Ref_Commands')
  ENDIF
  SET PRINT TO
  SET PRINT OFF
 RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  21.11.06 * 09:05:06
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Ref_Sertif(nRun)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_Sertif.txt
  IF !EMPTY(nRun)
    /*
    QQOUT('<Begin>'+_T+'Ref_Sertif'+_T+'Struct:SertifID,Name,OrgSertif,DateBgn,DateEnd,_BLANKN,_ADRES')
    QOUT('<End>'+_T+'Ref_Sertif')
    */
  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  21.11.06 * 09:07:26
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Ref_AttrTypes(nRun,aKop)
  LOCAL aNn_price, i
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_AttrTypes.txt
  IF !EMPTY(nRun)
    QQOUT('<Begin>'+_T+'Ref_AttrTypes'+_T+'Struct:AttrID,Code,Name,=DocList,=AddValue')

    QOUT('A1F1127E-BB91-41DE-87F5-4A00E5C4C409'+_T+'-1'+_T+'�������਩:'+_T+' '+_T+' ')
    QOUT('*'+_T+'1'+_T+'������!'+_T+'Order'+_T+' ')
    QOUT('*'+_T+'2'+_T+'�����뢮�'+_T+'Order'+_T+' ')
    QOUT('*'+_T+'3'+_T+'����'+_T+'Order'+_T+' ')
    QOUT('*'+_T+'4'+_T+'������:  , ���:  , ���:  , ���:'+_T+' '+_T+' ')
    QOUT('*'+_T+'5'+_T+'��� �� ����㧪�'+_T+'Order'+_T+' ')
    QOUT('*'+_T+'6'+_T+'�ࠪ!'+_T+'Arrival'+_T+' ')

    aNn_price:=PriceType2Kop('Nm_price')

    QOUT('08449B6B-75CA-464A-8D29-42EE6E94E08F'+_T+'1'+_T+aNn_price[1]+_T+'Order,Sale,Arrival'+_T+'')
    FOR i:=2 TO LEN(aNn_price)
      QOUT('*'+_T+'2'+_T+aNn_price[2]+_T+'Order,Sale,Arrival'+_T+'')
    NEXT
    QOUT('*'+_T+'3'+_T+'�����筠�'+_T+'Order,Sale,Arrival'+_T+'')
    QOUT('*'+_T+'4'+_T+'��⮢��, ������'+_T+'Order,Sale,Arrival'+_T+'')

    QOUT('60277704-5AB1-4FC5-BF78-9B032723B8B7'+_T+'-1'+_T+'��� ������:'+_T+'Order,Sale,Cash,Arrival'+_T+' ')
    FOR i:=1 TO LEN(aKop) //-1
      QOUT('*'+_T+LTRIM(STR(aKop[i,3],2))+_T+aKop[i,2]+_T+'Order,Sale,Cash,Arrival'+_T+'1,2')
    NEXT
    /*
    QOUT('*'+_T+'169'+_T+'169-���.���.���'+_T+'Order,Sale,Cash,Arrival'+_T+'1,2')
    QOUT('*'+_T+'161'+_T+'161-���.�.���'+_T+'Order,Sale,Cash,Arrival'+_T+'1,2')
    QOUT('*'+_T+'160'+_T+'160-����. � ���'+_T+'Order,Sale,Cash,Arrival'+_T+'1,2')
    QOUT('*'+_T+'126'+_T+'126-����. ��� ���'+_T+'Order,Sale,Cash,Arrival'+_T+'1,2')
    */
    QOUT('51DA11C0-6B6A-4EE7-BB9E-CB9E5515B536'+_T+'1'+_T+'FF0000'+_T+''+_T+'')
    QOUT('*'+_T+'2'+_T+'FF0000'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'FF00FF'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'00��00'+_T+''+_T+'')
    QOUT('3C1B73C4-7956-4CA2-84C0-118E20847BB6'+_T+'1'+_T+'��ଫ���� ���㬥�⮢ �த�� ��� �⮣� ������ ����饭�!'+_T+''+_T+'')
    QOUT('*'+_T+'2'+_T+'��������! � ������ ��� �������饣� �������! �।�।�� ������ - ����� �� 䠪�� ���⠢��!'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'��������! � ������ �����稢����� ������� �� ᫥���饩 ������! �।�।�� ������!'+_T+''+_T+'')
    QOUT('*'+_T+'4'+_T+'�� ���� ������! ������ ��� �ᮡ�� ��������!'+_T+''+_T+'')

    QOUT('4FD62396-E3F5-409F-A84E-A390D6876766'+_T+'2'+_T+'����.�।.��� VIP'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'����.�।.��� CM A'+_T+''+_T+'')
    QOUT('*'+_T+'4'+_T+'����.�।.��� B'+_T+''+_T+'')
    QOUT('*'+_T+'5'+_T+'����.�।.��� C'+_T+''+_T+'')
    /*
    QOUT('4FD62396-E3F5-409F-A84E-A390D6876766'+_T+'7'+_T+'�������'+_T+''+_T+'')
    QOUT('*'+_T+'8'+_T+'����.�।�������'+_T+''+_T+'')
    QOUT('*'+_T+'6'+_T+'������ ���ᥤ������� ���'+_T+''+_T+'')
    QOUT('*'+_T+'10'+_T+'������ ᥧ������ ���'+_T+''+_T+'')
    QOUT('*'+_T+'9'+_T+'������ �⭮�� ���'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'�࠭���� �� -10�C �� -5�C'+_T+''+_T+'')
    QOUT('*'+_T+'1'+_T+'�࠭���� �� -20�C �� -18�C'+_T+''+_T+'')
    QOUT('*'+_T+'2'+_T+'�࠭���� �� -5�C �� -3�C'+_T+''+_T+'')
    QOUT('*'+_T+'5'+_T+'�࠭���� �� 1�C �� 5�C'+_T+''+_T+'')
    */

    QOUT('1CABA333-1D1D-4F41-86C8-B175E9CEB6B3'+_T+'1'+_T+'�������� ���⪨'+_T+''+_T+'')
    QOUT('*'+_T+'2'+_T+'�������� �����������'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'�������� ����� �த��'+_T+''+_T+'')
    QOUT('*'+_T+'4'+_T+'�������� ��������'+_T+''+_T+'')

    QOUT('1124A28B-63EE-4F01-9AFA-37594D06CCCB'+_T+'1'+_T+'�����뢮�'+_T+''+_T+'')
    QOUT('*'+_T+'2'+_T+'�������� ���⠢��'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'��筠� ���⠢��!'+_T+''+_T+'')

    QOUT('FC233E4A-DA80-4481-B280-76CE1855CA9C'+_T+'1'+_T+'��� �����'+_T+''+_T+'')
    QOUT('*'+_T+'2'+_T+'������� ⮢��� �����'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'��� �⢥��⢥����� ���'+_T+''+_T+'')
    QOUT('*'+_T+'4'+_T+'���訥 業� � �����७⮢'+_T+''+_T+'')
    QOUT('*'+_T+'5'+_T+'�����஢����'+_T+''+_T+'')
    QOUT('*'+_T+'6'+_T+'���⠢�� �� ��㣮�� ���⠢騪�'+_T+''+_T+'')
    QOUT('*'+_T+'7'+_T+'�����쪨� �।��'+_T+''+_T+'')
    QOUT('*'+_T+'8'+_T+'������'+_T+''+_T+'')
    QOUT('*'+_T+'9'+_T+'��㣮�'+_T+''+_T+'')

    SELE kgpcat
    DBGOTOP()
    DO WHILE !EOF()
      IF RECNO()=1
        QOUT('5BB29DAF-6769-423A-AEAF-AEFE111736A0'+_T)
      ELSE
        QOUT('*'+_T)
      ENDIF
      QQOUT(LTRIM(STR(kgpcat+1,2))+_T+ALLTRIM(nkgpcat)+_T+''+_T+'')
      DBSKIP()
    ENDDO

    /*
    QOUT('5BB29DAF-6769-423A-AEAF-AEFE111736A0'+_T+'1'+_T+'�㯥ଠથ�'+_T+''+_T+'')
    QOUT('*'+_T+'2'+_T+'����. �������'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'�⤥�'+_T+''+_T+'')
    QOUT('*'+_T+'4'+_T+'��࣮��� ����'+_T+''+_T+'')
    QOUT('*'+_T+'5'+_T+'����'+_T+''+_T+'')
    QOUT('*'+_T+'6'+_T+'�����쮭'+_T+''+_T+'')
    QOUT('*'+_T+'7'+_T+'�������'+_T+''+_T+'')
    */

    QOUT('3B4E9F70-9F00-4C15-99B8-81E1DF95DC2C'+_T+'1'+_T+'���짠��'+_T+''+_T+'')
    QOUT('*'+_T+'9'+_T+'������࠭��'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'�㡭� �����'+_T+''+_T+'')
    QOUT('*'+_T+'10'+_T+'�६�'+_T+''+_T+'')
    QOUT('*'+_T+'4'+_T+'�뫮'+_T+''+_T+'')
    QOUT('*'+_T+'5'+_T+'����⪨'+_T+''+_T+'')
    QOUT('*'+_T+'8'+_T+'�த��� ��⠭��'+_T+''+_T+'')
    QOUT('*'+_T+'11'+_T+'����'+_T+''+_T+'')
    QOUT('*'+_T+'6'+_T+'��ࠫ�� ���誨'+_T+''+_T+'')
    QOUT('*'+_T+'7'+_T+'������ �������'+_T+''+_T+'')
    QOUT('*'+_T+'2'+_T+'����㭨'+_T+''+_T+'')
    QOUT('EA2D47CD-0E34-4176-8EBF-F4A9AAF2716D'+_T+'1'+_T+'01234/11020/7654321'+_T+''+_T+'')
    QOUT('*'+_T+'2'+_T+'11234/11020/7654321'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'12345/11031/7654321'+_T+''+_T+'')
    QOUT('*'+_T+'4'+_T+'123456/11032/765432'+_T+''+_T+'')
    QOUT('*'+_T+'5'+_T+'21234/11020/7654321'+_T+''+_T+'')
    QOUT('*'+_T+'6'+_T+'34534/54654/5676346'+_T+''+_T+'')
    QOUT('*'+_T+'7'+_T+'43535/65748/6774356'+_T+''+_T+'')
    QOUT('*'+_T+'8'+_T+'50245/11020/7684323'+_T+''+_T+'')
    QOUT('*'+_T+'9'+_T+'51239/11020/7654324'+_T+''+_T+'')
    QOUT('*'+_T+'10'+_T+'51239/11023/7653327'+_T+''+_T+'')
    QOUT('*'+_T+'11'+_T+'56445/77645/7564876'+_T+''+_T+'')
    QOUT('*'+_T+'12'+_T+'56765/45666/4565445'+_T+''+_T+'')
    QOUT('*'+_T+'13'+_T+'84345/54623/5645645'+_T+''+_T+'')
    QOUT('2BA57449-AECB-4C00-BDA0-E08120251AC7'+_T+'1'+_T+'���죨�'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'���������'+_T+''+_T+'')
    QOUT('*'+_T+'4'+_T+'�ᯠ���'+_T+''+_T+'')
    QOUT('*'+_T+'5'+_T+'��ࢥ���'+_T+''+_T+'')
    QOUT('*'+_T+'2'+_T+'�����'+_T+''+_T+'')
    QOUT('F07C563C-8EC9-44FA-8EDA-CBECBA4DF43B'+_T+'0'+_T+'---������---'+_T+'Visit'+_T+'')
    QOUT('81A492CE-D274-48FF-97BB-49FD4F69EE9D'+_T+'0'+_T+'��� �� �業����� ࠡ��� �㦡� ���⠢��?'+_T+'Visit,!'+_T+'')
    QOUT('*'+_T+'1'+_T+'�⫨筮'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'2'+_T+'����'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'3'+_T+'������⢮�⥫쭮'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'4'+_T+'����'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'5'+_T+'�祭� ����'+_T+'Visit'+_T+'')
    QOUT('72D89678-3E88-442A-8837-F9C8E0597F48'+_T+'0'+_T+'��� ���ࠨ���� ��ਮ��筮��� ���饭�� ����⠬�?'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'1'+_T+'��'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'2'+_T+'���, ����⥫쭮 ࠧ � ������'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'3'+_T+'���, ����⥫쭮 2 ࠧ� � �����'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'4'+_T+'���, ����⥫쭮 1 ࠧ � �����'+_T+'Visit'+_T+'')
    QOUT('9F1B99FE-A5CC-4499-9E74-EFD75746B23B'+_T+'0'+_T+'�������� �� ��㣠�� ��㣨� ���⠢騪��?'+_T+'Visit,!'+_T+'')
    QOUT('*'+_T+'1'+_T+'��'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'2'+_T+'���'+_T+'Visit'+_T+'')
    QOUT('9DF88983-874D-4634-A5F1-C3085A2DDE88'+_T+'0'+_T+'����⥫쭮� �६� ���饭�� ��� �࣮�� ����⮬?'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'1'+_T+'��'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'2'+_T+'9.00'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'3'+_T+'10.00'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'4'+_T+'11.00'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'5'+_T+'12.00'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'6'+_T+'13.00'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'7'+_T+'14.00'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'8'+_T+'15.00'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'9'+_T+'16.00'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'10'+_T+'17.00'+_T+'Visit'+_T+'')
    QOUT('8FE3E181-DE1A-4F1D-9A20-98DDF760DDC8'+_T+'0'+_T+'��� ���ࠨ���� ����⨬��� ��ࠫ��� ���誮�?'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'1'+_T+'��'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'2'+_T+'���'+_T+'Visit'+_T+'')
    QOUT('0F3F2988-733C-43ED-843A-C06BB41E3F86'+_T+'0'+_T+'��� ���ࠨ���� ����⨬��� 蠬�㭥�?'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'1'+_T+'��'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'2'+_T+'���'+_T+'Visit'+_T+'')
    QOUT('4C34BAF0-A4D2-467E-A820-4E2BF20FC637'+_T+'0'+_T+'��� ���ࠨ���� ����⨬��� ᨣ���?'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'1'+_T+'��'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'2'+_T+'���'+_T+'Visit'+_T+'')

    QOUT('<End>'+_T+'Ref_AttrTypes')
  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  21.11.06 * 09:11:49
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Ref_Confirm()
  LOCAL nDocState
  LOCAL cDocState
  cDocState:="��ᮯ"

  SELE Confirm

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_Confirm.txt

  QQOUT('<Begin>'+_T+'Ref_Confirm'+_T+'Struct:DocID,DocState,DocNumber')
  DBGOTOP()
  WHILE (!EOF())

    IF !EMPTY(DocGUID)

      nDocState:=1+8    // 8-����� ��������� (����ᠭ)
      DO CASE
      CASE EMPTY(dFp)
        cDocState:="�----"
      CASE EMPTY(dSp)
        cDocState:="��---"
      CASE EMPTY(dTOt) .AND. PRZ=0
        cDocState:="���--"
      CASE !EMPTY(dTOt) .AND. PRZ=0
        cDocState:="���-"
        nDocState:=1+8+64 //64-����   (����ᠭ + ����)
      CASE PRZ=1
        cDocState:="��ᮯ"
      ENDCASE
        /*
        cDocState:= 3453466 �. . . . . "
        cDocState:="�.�. . . .3434566"
        cDocState:="�.�.C. . ."
        cDocState:="�.�.C.O. ."
        cDocState:="�.�.C.O.�."
        */

          qout(                               ;
              ;//DocID
                DocGUID+_T+      ;
              ;//DocState
                ALLTRIM(STR(nDocState, 2, 0))+_T+      ;
              ;//DocNumber
                ALLTRIM(cDocState)+""+ALLTRIM(STR(TTN));
             )
    ENDIF
    DBSKIP()
  ENDDO
  QOUT('<End>'+_T+'Ref_Confirm')

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  21.11.06 * 09:15:13
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Ref_PrnScripts(nRun)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_PrnScripts.txt

  IF !EMPTY(nRun)
    QQOUT('<Begin>'+_T+'Ref_PrnScripts'+_T+'Struct:ObjCode,Name,FileName,Copyes,=ScriptName')
    QOUT('Cash'+_T+'���ᮢ� �थ�'+_T+'PrnCash.lua'+_T+'1'+_T+'Cash')
    QOUT('Move'+_T+'��६�饭��'+_T+'PrnMove.lua'+_T+'2'+_T+'Move')
    QOUT('Sale'+_T+'���祭� ���䨪�⮢'+_T+'PrnSaleSertif.lua'+_T+'1'+_T+'Sertif')
    QOUT('Arrival'+_T+'����㯫����'+_T+'PrnArrival.lua'+_T+'1'+_T+'Arrival')

    QOUT('Order'+_T+'���'+_T+'PrnOrder.lua'+_T+'1'+_T+'Order')
    QOUT('Order'+_T+'���� �� ����'+_T+'RepOrder.lua'+_T+'1'+_T+'Order')
    QOUT('Order'+_T+'���� �� ����.txt'+_T+'RepOrder_txt.lua'+_T+'1'+_T+'Order')

    QOUT('Sale'+_T+'���-䠪���'+_T+'PrnSaleInvoice.lua'+_T+'1'+_T+'SaleInv')
    QOUT('Sale'+_T+'���饭��� �ଠ'+_T+'PrnSaleSimple.lua'+_T+'2'+_T+'Sale')
    QOUT('Sale'+_T+'���� �� �த����'+_T+'RepSale.lua'+_T+'1'+_T+'Sale')
    QOUT('Sale'+_T+'���� �� �த����.txt'+_T+'RepSale_txt.lua'+_T+'1'+_T+'Sale')
    QOUT('Sale'+_T+'��ଠ ���-12'+_T+'PrnSaleT12.lua'+_T+'2'+_T+'SaleT12')

    QOUT('<End>'+_T+'Ref_PrnScripts')
  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  21.11.06 * 09:15:13
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION  Ref_FirmsPrnLinks(nRun)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_FirmsPrnLinks.txt

  IF !EMPTY(nRun)

    QQOUT('<Begin>'+_T+'Ref_FirmsPrnLinks'+_T+'Struct:FirmID,ScriptName')
    QOUT('<End>'+_T+'Ref_FirmsPrnLinks')

  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  20.11.06 * 13:10:56
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION  Ref_RepScripts(nRun)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_RepScripts.txt

  IF !EMPTY(nRun)

    QQOUT('<Begin>'+_T+'Ref_RepScripts'+_T+'Struct:Name,FileName')
    QOUT('������ ���ᮢ�� �थ஢'+_T+'RepCashList.lua')
    QOUT('���⪨ ⮢�஢'+_T+'RepGoodsList.lua')
    QOUT('<End>'+_T+'Ref_RepScripts')

  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  16.11.06 * 16:16:02
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Ref_Clients(nRun,aKop)
  LOCAL cCodeList
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_Clients.txt

  IF !EMPTY(nRun)
    qqout('<Begin>'+_T+'Ref_Clients'+_T+'Struct:ClientID,Name,Credit,Debt,Discount,Tel,=BlockSales,=Addr,=CodesList,=PriceTypes,=PriceType,=UsePPrices,_DEBTLIST,_INN,_KPP,_FNAME,_MSALES,_SROKDOG,_VIP,_CLKONKUR')
    SELE tmp_kpl
    SET RELA TO STR(Kpl,7) INTO deb
    DBGOTOP()
    WHILE (!EOF())
      cCodeList:=""
      IF !EMPTY(CodeList)
        FOR i:=1 TO LEN(aKop) //-1
          //�஢�ਬ �宦����� � ࠧ�襭��� ��� � ��ப�
          //�஢�ਬ �㡫�
          IF PADL(LTRIM(STR(aKop[i,1],3,0)),3,"0")$CodeList .AND. ;
            !(PADL(LTRIM(STR(aKop[i,3],3,0)),2,"0")$cCodeList)
            IF EMPTY(cCodeList)
              cCodeList:=PADL(LTRIM(STR(aKop[i,3],3,0)),2,"0")
            ELSE
              cCodeList+=","+PADL(LTRIM(STR(aKop[i,3],3,0)),2,"0")
            ENDIF
          ENDIF
          /*
          IF LTRIM(STR(aKop[i,1],3,0))$CodeList .AND. ;
            !(LTRIM(STR(aKop[i,3],3,0))$CodeList)
            IF EMPTY(cCodeList)
              cCodeList:=LTRIM(STR(aKop[i,3],3,0))
            ELSE
              cCodeList+=","+LTRIM(STR(aKop[i,3],3,0))
            ENDIF
          ENDIF
          */
        NEXT
      ENDIF
      //outlog(__FILE__,__LINE__,cCodeList)

      qout(                                      ;
          ;//ClientID
            GUID_KPK("C",ALLTRIM(STR(Kpl)))+_T+             ;
          ;//Name
            LEFT(ALLTRIM(Npl), 50)+_T+        ;
          ;// Credit  15.2
            ALLTRIM(STR(deb->KZ, 15, 2))+_T+        ;
          ;// Debt
            ALLTRIM(STR(deb->DZ, 15, 2))+_T+        ;
          ;//  Discount
            ALLTRIM(STR(IIF(discount=999,0,discount), 4, 1))+_T+         ;
          ;// Tel
            LEFT(ALLTRIM(TelPl), 50)+_T+ ;
          ;//  =BlockSales �����஢�� �த�� �᫨-1,
          ;// 2-������ �������� ����祭��,
          ;// 3-������ �������� �����稢�����,
          ;// 4-����
            ALLTRIM(STR(;
            IIF(dogPl < DATE(), 2,;
              IIF(dogPl <= DATE()+7, 3,;
                IIF(dtDogB >= DATE() .AND. dtDogB <= DATE()+7, 4,;
                                     0);
                  )                  ;
                ),                   ;
                  1, 0))+_T+         ;
          ;//=Addr
            LEFT(ALLTRIM(Apl), 50)+_T+        ;
          ;//=CodesList ᯨ᮪ �����⨬�� ����� �����, �� 1 �� 32. ����뢠���� �.� �������
            LEFT(ALLTRIM(cCodeList), 128)+_T+        ;
          ;//=PriceTypes - ᯨ᮪ ����� ⨯�� 業 ��� ������. ����뢠���� �.� �������
            LEFT(ALLTRIM(""), 128)+_T+        ;
          ;//=PriceType - ��� ⨯� 業�, ���९ �� �����⮬.
            ALLTRIM(STR(0, 2, 0))+_T+         ;
          ;//=UsePPrice - �ਧ��� �ᯮ�������� ���ᮭ����� 業
            ALLTRIM(STR(IIF(discount=999,1,0), 1, 0))+_T+         ;
          ;// _DEBTLIST ᯨ᮪ ������ �� ��ਮ���
            LEFT(ALLTRIM(">7��:"+LTRIM(STR(deb->PDZ,10,2))+" >14��:"+LTRIM(STR(deb->PDZ1,10,2))+" >21��:"+LTRIM(STR(deb->PDZ3,10,2))), 128)+_T+        ;
          ;//_INN
            ALLTRIM(STR(OKPO, 32, 0))+_T+     ;
          ;//_KPP
            LEFT(ALLTRIM(""), 32)+_T+         ;
          ;//_FNAME - ������ ������������
            LEFT(ALLTRIM(Apl), 128)+_T+       ;
          ;//_MSALES - ����� �த��
            ALLTRIM(STR(0, 15, 2))+_T+        ;
          ;//_SROKDOG
            DTOC(DogPl)+_T+     ;
          ;//_VIP
            IIF(.F., "1", "0")+_T+              ;
          ;//_CLKONKUR - ������ �����७⮢
            IIF(.F., "1", "0")                  ;
        )

      DBSKIP()
    ENDDO
  qout('<End>'+_T+'Ref_Clients')
  SELE tmp_kpl
  SET RELA TO

  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  17.11.06 * 10:11:26
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Ref_TPoints(nRun)
  Local cNGp, nDD, nSDD
  SELE tmp_ktt
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_TPoints.txt

  IF !EMPTY(nRun)
    qqout('<Begin>'+_T+'Ref_TPoints'+_T+'Struct:ClientID,TPointID,Name,Addr,=Zone,=Tel,=Category,=Contact,=FltGdsProp,_TPTYPE,_WORKTIME')
    DBGOTOP()
    WHILE (!EOF())

      nDD:=dol-date()
      nSDD:=14
      DO CASE
      CASE Empty(dol) .or. nDD > nSDD
        cNGp:=""
      CASE nDD >= 0 .and. nDD <= nSDD
        cNGp:="!"
      CASE nDD < 0
        cNGp:="*"
      ENDCASE
      cNGp+=alltrim(NGp)
  #ifdef __CLIP__
      qout(                               ;
          ;//ClientID
            GUID_KPK("C",ALLTRIM(STR(Kpl)))+_T+      ;
          ;//TPointID
            GUID_KPK("C",ALLTRIM(STR(KGp)),ALLTRIM(STR(Kpl)))+_T+      ;
          ;//Name
            LEFT(ALLTRIM(cNGp), 50)+_T+ ;
          ;//Addr
            LEFT(ALLTRIM(AGp), 64)+_T+ ;
          ;//=Zone - ����� ����,  �᫨ �窨 �������஢��� �� ����� �����⠬
            LEFT(ALLTRIM(""), 8)+_T+ ;
          ;//=Tel
            LEFT(ALLTRIM(TelGp), 50)+_T+ ;
          ;//=Category "��⥣.��.��.A|B|C"
            LEFT(ALLTRIM(STR(KgpCat)), 24)+_T+ ;
          ;//=Contact
            ;//LEFT(ALLTRIM("���⠪�� ���"), 128)+_T+        ;
            LEFT(ALLTRIM(DTOC(dnl,"DD.MM.YY")+"-"+DTOC(dol,"DD.MM.YYYY")+" "+alltrim(serlic)+ltrim(str(numlic))), 128)+_T+        ;
          ;//=FltGdsProp
            LEFT(ALLTRIM(IIF(KgpCat=0,;
                               "",;
                               IIF(KgpCat=1 .OR. KgpCat>=5,;
                                  "5",;
                                   STR(KgpCat);
                                );
                            ) ;
                        ), 24)+_T+        ;
          ;//_TPTYPE - ����᫥���
          ;// 1 �㯥ଠથ�      2 ����. ������� 3 �⤥�  4 ��࣮��� ����
          ;// 5 ����           6 �����쮭       7 �������
            ALLTRIM(STR(KgpCat+1))+_T+      ;
          ;//_WORKTIME
            LEFT(ALLTRIM("� 9.00 �� 18.00, ���� � 13.00 �� 13.30, ���. �㡡��,����ᥭ�"), 64);
        )
  #endif
      DBSKIP()
    ENDDO

    qout('<End>'+_T+'Ref_TPoints')
  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  17.11.06 * 11:12:25
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION  Ref_Price(nRun,aPrice)
  LOCAL MKeepr,i
  LOCAL nGUID_Mkeep, nKg

  SELE price
  ORDSETFOCUS("Nat")

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_Price.txt

  IF !EMPTY(nRun)
    //qqout('<Begin>'+_T+'Ref_Price'+_T+'Mode:Full'+_T+;
    //'Struct:GoodsID,FolderID,IsFolder,Name,=Code,=NameUnits,=Unit0,=Unit1,=Unit2,=MinAmount,Price1,=Price2,=Price3,=Price4,Rest,=RDiscount,=Action,=Weight,=PropList,=Comment,=VAT,=Category,=SertifID,_GTD,_STRANA')
    qqout('<Begin>'+_T+'Ref_Price'+_T+'Mode:Full'+_T+;
           'Struct:GoodsID,FolderID,IsFolder,Name,=Code,=NameUnits,=Unit0,=Unit1,=Unit2,=MinAmount,Price1,=Price2,Rest,=RDiscount,=Action,=Weight,=Weight0,=PropList,=Comment,=VAT,=Category,=SertifID,_GTD,_STRANA')
    i:=0
  DBGOTOP()
  DO WHILE !EOF()

    If !(gnEnt = 21)
      IF MNTOV < 10^6
        DBSKIP()
        LOOP
      ENDIF
    EndIf

    MKeepr:=MKeep
    i:=i+1

    //�뢮� ��ઠ��ঠ⥫�
    nGUID_Mkeep:=111111+mkeep+i

    qout(;
  ;//GoodsID
    GUID_KPK("A", LTRIM(STR(nGUID_Mkeep)))+_T+; //����� �㤥� ⠪�� ��� �����쪠 ஧����
  ;//FolderID
    ''+_T+;
  ;//IsFolder
    '1'+_T+;
  ;//Name
    ALLTRIM(nmkeep)+_T+; //'�����쪠 ஧����'
  ;//Code
    '1';
  )

  DO WHILE MKeepr = MKeep
    kg_r:=INT(MNTOV/10^4)
    ng_r:=getfield('t1',"kg_r","cgrp","ngr")//�������� ��㯯�

    nGUID_Kg:=nGUID_MKeep+222222+kg_r


    //�뢮� ��ઠ��ঠ⥫� + ��㯯�
      qout(;
    ;//GoodsID
      GUID_KPK("A", LTRIM(STR(nGUID_Kg)))+_T+; //����� �㤥� ⠪��
    ;//FolderID
      GUID_KPK("A",LTRIM(STR(nGUID_MKeep)))+_T+;
    ;//IsFolder
      '1'+_T+;
    ;//Name
      ALLTRIM(ng_r)+_T+; //�������� ��㯯�
    ;//Code
      '1';
    )

    //DO WHILE kg_r = INT(MNTOV/10^4)
    DO WHILE kg_r = INT(MNTOV/10^4) .AND. MKeepr = MKeep
      qout(;
      ;//GoodsID
        GUID_KPK("A",ALLTRIM(STR(MNTOVT)))+_T+;
      ;//FolderID
          GUID_KPK("A", LTRIM(STR(nGUID_Kg)))+_T+; //����� �㤥� ⠪��
      ;//IsFolder
        '0'+_T+;
      ;//Name
          LEFT(ALLTRIM(Nat), 64)+_T+ ;
      ;//Code
        LEFT(ALLTRIM(STR(MNTOVT)),64)+_T+;
      ;//NameUnits -  ��. �����
          LEFT(ALLTRIM(NEi)+',�', 11)+_T+ ;
      ;//Unit0
        ALLTRIM(STR(1, 12, 2))+_T+        ;
      ;//Unit1
        ALLTRIM(STR(Upak, 12, 2))+_T+        ;
      ;//Unit2
        ALLTRIM(STR(1, 12, 2))+_T+        ;
      ;//MinAmount - �������쭮� �-�� �믨᪨
        '0'+_T)

      FOR i:=1 TO LEN(aPrice)
        IF !EMPTY(FIELDPOS(aPrice[i]))
          qqout(;
          ;//Price1
            ALLTRIM(STR(FIELDGET(FIELDPOS(aPrice[i])), 12, 2))+_T        ;
        )
        ELSE
          qqout(;
          ;//Price1
            ALLTRIM(STR(0, 12, 2))+_T        ;
        )
        ENDIF
      NEXT

      qqout(;
      ;//Rest
        ALLTRIM(STR(OsV, 15, 4))+_T+        ;
      ;//RDiscount - ��࠭�祭�� ᪨���
        ALLTRIM(STR(0, 4, 1))+_T+        ;
      ;//Action 0 - ���, 1 - ����
        ALLTRIM(STR(IIF(Merch=2,1,0), 1, 0))+_T+        ; //ALLTRIM(STR(IIF((-1)^RECNO()>0,0,1), 1, 0))+_T+        ;
      ;//Weight  - 1 - ��ᮢ��, 0 - ��  ��ᮢ��
        ALLTRIM(STR(iif("��" $ lower(NEi),1,0), 1, 0))+_T+        ;
      ;//Weight0  - ��� ��ࢮ� ������� ����७�� ⮢��
        ALLTRIM(STR(Ves, 15, 4))+_T+        ;
      ;//PropList - ᯨ᮪  ᢮���
        LEFT(ALLTRIM(PropList), 128)+_T+ ;
      ;//Comment
          LEFT(ALLTRIM("���� ������ 業�!"), 48)+_T+ ;
      ;//VAT
        ALLTRIM(STR(20, 12, 2))+_T+        ;
      ;//Category - ��� ��⥣�ਨ ⮢��
        ALLTRIM(STR(1, 10, 0))+_T+        ;
      ;//SertifID
          LEFT(ALLTRIM(""), 12)+_T+ ;
      ;//_GTD
        ALLTRIM(STR(0, 2, 0))+_T+        ;
      ;//_STRANA - ��࠭� �ந�����⥫�
        ALLTRIM(STR(0, 2, 0))        ;
      )
          DBSKIP()

      ENDDO
    ENDDO
  ENDDO
    qout('<End>'+_T+'Ref_Price')
  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  11-11-07 * 12:33:26pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Ref_GoodsStock(nRun)
  SELE price
  ORDSETFOCUS("Nat")

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_GoodsStock.txt
  IF !EMPTY(nRun)
    qqout('<Begin>'+_T+'Ref_GoodsStock'+_T+'Mode:Full'+_T+'Struct:GoodsID,Rest')
    DBGOTOP()
    DO WHILE !EOF()
      IF MNTOV < 10^6
        DBSKIP()
        LOOP
      ENDIF
      qout(;
      ;//GoodsID
        GUID_KPK("A",ALLTRIM(STR(MNTOVT)))+_T+;
      ;//Rest
        ALLTRIM(STR(OsV, 15, 4));
      )
      DBSKIP()
    ENDDO
      qout('<End>'+_T+'Ref_GoodsStock')
  ENDIF


  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  12-29-06 * 10:06:22am
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Ref_PersonalPrices(nRun)
  LOCAL i
  SELE PersonalPrice

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_PersonalPrices.txt

  IF !EMPTY(nRun)

    QQOUT('<Begin>'+_T+'Ref_PersonalPrices'+_T+'Mode:Full'+_T+'Struct:ClientID,GoodsID,Price,=Discount')
    DBGOTOP()
    i:=0
    DO WHILE !EOF()
          QOUT(;
          ;//ClientID
            IIF(i=0, GUID_KPK("C",ALLTRIM(STR(kpl))),"*")+_T+      ;
          ;//GoodsID
            GUID_KPK("A",ALLTRIM(STR(MnTovT)))+_T+;
          ;//Price
            ALLTRIM(STR(Cenpr, 15, 2))+_T+        ;
          ;//=Discount'
            ALLTRIM(STR(Discount, 15, 4))        ;
        )

      i++//����� ��㧮�����⥫�
      i:=0
      DBSKIP()
    ENDDO

    QOUT('<End>'+_T+'Ref_PersonalPrices')

  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  01.12.06 * 11:03:32
 ����������......... ��楤�� ��� ���㧪� � ��� ���ᠭ�� �ਯ⮢ ���������� ���㬥�⮢
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION  Ref_FillDocScripts(nRun)
    SET CONSOLE OFF
    SET PRINT ON
    SET PRINT TO Ref_FillDocScripts.txt

    IF !EMPTY(nRun)

    qqout('<Begin>'+_T+'Ref_FillDocScripts'+_T+'Struct:DocList,Name,Message,FileNameAndFunct')

    qout("Order" +_T+;
     "�� ��㫥 1.5 (�����)"+_T+;
     "��������� ���㬥�� ᮣ��᭮ ���� 1.5 (�����) "+;
     "⮢�� � �窥?" +_T+;
      "FillDocuments.lua:FillOrderK15")

    qout("Order" +_T+;
     "�� ��㫥 1.5 (�����) (� 㯠�.)"+_T+;
     "��������� ���㬥�� ᮣ��᭮ ���� 1.5 (�����) "+;
     "⮢�� � �窥 (� ���㣫����� �� 㯠�����)?" +_T+;
      "FillDocuments.lua:FillOrderPackK15")

   /*
    qout("Order" +_T+;
     "�।. �த��� ����� ����稥"+_T+;
     "��������� ���㬥�� ᮣ��᭮ �।��� ������ ���ਨ �த�� � ������ "+;
     "⮢�� � �窥?" +_T+;
      "FillDocuments.lua:FillOrder")

    qout("Order" +_T+;
     "�।. �த. ����� �����.(� 㯠�.)"+_T+;
     "��������� ���㬥�� ᮣ��᭮ �।��� ������ ���ਨ �த�� � ������ "+;
     "⮢�� � �窥 (� ���㣫����� �� 㯠�����)?" +_T+;
      "FillDocuments.lua:FillOrderPack")

    qout("Sale,RSale" +_T+ "�।. �த��� ����� ����稥" +_T+;
         "��������� ���㬥�� ᮣ��᭮ �।��� ������ ���ਨ �த�� � ������"+;
         "⮢�� � �窥?" +_T+;
         "FillDocuments.lua:FillSale")

    qout("Sale,RSale" +_T+ "�।. �த. ����� �����.(� 㯠�.)" +_T+;
     "��������� ���㬥�� ᮣ��᭮ �।��� ������ ���ਨ �த�� � ������ "+;
     "⮢�� � �窥 (� ���㣫����� �� 㯠�����)?" +_T+;
     "FillDocuments.lua:FillSalePack")
    */
    qout('<End>'+_T+'Ref_FillDocScripts')

    ENDIF

    SET PRINT TO
    SET PRINT OFF
  RETURN (NIL)
/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  12-15-06 * 01:10:52pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Ref_Routes(nRun,dDate)
    LOCAL dRouteTime, i, m

    dDate:=DATE()

    crtt('tempRtDt','f:kgp c:n(7) f:kpl c:n(7)  f:rtdt c:d(10) f:Comment c:c(64)')
    USE tempRtDt NEW EXCLUSIVE
    IF FILE('tempRtDt.cdx')
      ERASE ('tempRtDt.cdx')
    ENDIF
    INDEX ON rtdt TAG RtDt

    SELE TPoints
    DBGOTOP()
    WHILE (!EOF())
      FOR i:=1 TO 7
        IF !EMPTY(SUBSTR(RouteTime,i,1))
          dRouteTime:=LastMonday(dDate)+i-1
          FOR m:=0 TO 0 // 1-�� ��� ������ 0-����
            tempRtDt->(DBAPPEND())
            tempRtDt->Kpl:=TPoints->Kpl
            tempRtDt->Kgp:=TPoints->Kgp
            tempRtDt->rtdt:=dRouteTime+(7*m)
            tempRtDt->Comment:=""
          NEXT
        ENDIF
      NEXT
      DBSKIP()
    ENDDO


    SELE tempRtDt
    DBGOTOP()

    SET CONSOLE OFF
    SET PRINT ON
    SET PRINT TO Ref_Routes.txt

    IF !EMPTY(nRun)
      qqout('<Begin>'+_T+'Ref_Routes'+_T+'Struct:=RouteID,ClientID,=TPointID,RouteTime,=Comment')
      DBGOTOP()
      DO WHILE !EOF()
        qout(                               ;
            ;//RouteId
            " "+_T+      ;
            ;//ClientID
              GUID_KPK("C",ALLTRIM(STR(Kpl)))+_T+      ;
            ;//TPointID
              GUID_KPK("C",ALLTRIM(STR(KGp)),ALLTRIM(STR(Kpl)))+_T+      ;
            ;//RouteTime
              DTOC(rtdt)+_T+     ;
            ;//Comment
              LEFT(ALLTRIM(""), 64) ;
            )
        DBSKIP()
      ENDDO
      qout('<End>'+_T+'Ref_Routes')

    ENDIF
    CLOSE tempRtDt


    SET PRINT TO
    SET PRINT OFF
    RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  22.11.06 * 08:12:41
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION GUID_KPK(cPref,cKod, cKod1)
  LOCAL cGUID
  cGUID:="FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"
  //outlog(__FILE__,__LINE__,cGUID,LEN(cGUID)-(LEN(cPref)+LEN(cKod))+1,LEN(cPref+cKod), cPref+cKod)
  cGUID:=STUFF(cGUID,LEN(cGUID)-(LEN(cPref)+LEN(cKod))+1,LEN(cPref+cKod), cPref+cKod)
  IF !EMPTY(cKod1)
    cGUID:=STUFF(cGUID,1,LEN(cKod1), cKod1)
  ENDIF
  //outlog(__FILE__,__LINE__,cGUID)
  RETURN (cGUID)

FUNCTION LastMonday(dDate)
   RETURN (dDate - DOW(dDate) + 2)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  05-30-07 * 11:50:21am
 ����������.........
 ���������..........
 �����. ��������....
 ����������......... ᤥ���� ��������� kta_ost() ��� ����㧪� ����� 業
 */
FUNCTION PriceType2Kop(cTypeArr)
  LOCAL aMass

  DO CASE
  CASE UPPER(cTypeArr)=UPPER("kop")

    IF gnEnt = 21  // �����
      aMass:={0,150}
    ELSE //IF gnEnt = 20  // �����
      //aMass:={0,152}
      aMass:={0,160}
    ENDIF

  CASE UPPER(cTypeArr)=UPPER("price")
    IF gnEnt = 21  // �����
      aMass:={"CenPr","CenPs"}
    ELSE //IF gnEnt = 20  // �����
      //aMass:={"CenPr","c29"}
      aMass:={"CenPr","CenPr"}
    ENDIF

  CASE UPPER(cTypeArr)=UPPER("nm_price")
    IF gnEnt = 21  // �����
      aMass:={'���ਭ�','���� +% (150)'}
    ELSE //IF gnEnt = 20  // �����
      //aMass:={'���ਭ�','������� (152)'}
      aMass:={'���ਭ�','!!-������-!!'}
    ENDIF

  CASE UPPER(cTypeArr)=UPPER("guid_price")
      aMass:={;
      "CBCF495A-55BC-11D9-848A-00112F43529A",;
      "CBCF495B-55BC-11D9-848A-00112F43529A";
               }

  ENDCASE
  RETURN (aMass)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  12-13-15 * 05:07:16pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION AddKplKgpSkDoc()

  COPY STRU TO tmp_ktt1
  USE tmp_ktt1 NEW EXCLUSIVE
  INDEX ON STR(KPL)+STR(KGP) TAG "kgp_kpl"

    SELE tmp_kpl
    DBGOTOP()
    WHILE (!EOF())
      IF STR(tmp_kpl->Kpl)$"     20034"
        SELECT tmp_kpl
        DBSKIP()
        LOOP
      ENDIF
      IF !skdoc->(DBSEEK(STR(tmp_kpl->kpl,7)))
        SELECT tmp_kpl
        DBSKIP()
        LOOP
      ENDIF

      SELE skdoc
      DO WHILE skdoc->Kpl = tmp_kpl->Kpl
        // ��६ �� �-�� � ���.�����.
        IF skdoc->KGP # 0 ;
           .AND. .NOT. TPoints->(DBSEEK(STR(skdoc->KPL)+STR(skdoc->KGP))) ;
           .AND. .NOT. tmp_ktt1->(DBSEEK(STR(skdoc->KPL)+STR(skdoc->KGP)))
           COPY TO tmp1 NEXT 1
           SELE tmp_ktt1
           APPEND FROM tmp1
           SELE skdoc
        ENDIF
        DBSKIP()
      ENDDO

      SELECT tmp_kpl
      DBSKIP()
    ENDDO

    //������塞
    SELE tmp_ktt1
    DBGOTOP()
    DO WHILE !EOF()
      kln->(netseek("t1","tmp_ktt1->kgp"))
      _FIELD->ngp:=kln->nkl
      _FIELD->agp:=kln->adr
      _FIELD->telGp:=kln->tlf
      SELE tmp_ktt1
      DBSKIP()
    ENDDO
    CLOSE tmp_ktt1

  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  11-20-15 * 11:25:27am
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION cdb_load(ktar,nAgSk,cFio,dShDateBg, dShDateEnd, aKop,;
     nRef_Price,nDoc_Debt,nRef_Sales,nRef_Routes, nRef_Ini)

  LOCAL oRef_System
  LOCAL cktar:=PADL(LTRIM(STR(ktar,3)), 3, "0")
  LOCAL aLoadFile //, a PlSl_TA

  set("PRINTER_CHARSET", "cp1251") //"utf-8")//"cp1251")
  SET DATE FORMAT "yyyy-mm-dd"
  SET CENTURY ON

  USE (gcPath_ew+"deb\deb") ALIAS deb NEW SHARED
  SET ORDER TO TAG t1

  IF gnEnt=20
    USE (gcPath_ew+"deb\accord_deb") ALIAS skdoc NEW SHARED READONLY
    SET ORDER TO TAG t1
  else
    USE (gcPath_ew+"deb\skdoc") ALIAS skdoc NEW SHARED READONLY
    SET ORDER TO TAG t1
  endif
     //index on str(kpl)+str(ktan) tag t1


  USE (gcPath_ew+"deb\bdoc") ALIAS bdoc  NEW SHARED
  SET ORDER TO TAG t1

  USE ('k'+cktar+'pcen.dbf')  ALIAS PersonalPrice NEW EXCLUSIVE

  USE ('k'+cktar+'cnfr.dbf') ALIAS Confirm NEW EXCLUSIVE
  USE ('k'+cktar+'plsl.dbf') ALIAS PlanSale NEW EXCLUSIVE

  IF FILE('k'+cktar+'mrch.cdx');  ERASE ('k'+cktar+'mrch.cdx');  ENDIF
  USE ('k'+cktar+'mrch.dbf') ALIAS Merch NEW EXCLUSIVE
  INDEX ON STR(Kpl)+STR(Kgp)+STR(MNTOV)+STR(WEEK(Dop),2) TAG KGp_MnTov
  INDEX ON STR(Kpl)+STR(Kgp)+STR(MNTOVT)+STR(WEEK(Dop),2) TAG KGp_MnTovT

  IF FILE('k'+cktar+'sale.cdx');   ERASE ('k'+cktar+'sale.cdx');  ENDIF
  USE ('k'+cktar+'sale.dbf') ALIAS Sales NEW EXCLUSIVE
  INDEX ON STR(Kpl)+STR(Kgp)+STR(MNTOV)+STR(WEEK(Dop),2) TAG KGp_MnTov
  INDEX ON STR(Kpl)+STR(Kgp)+STR(MNTOVT)+STR(WEEK(Dop),2) TAG KGp_MnTovT

  IF FILE('k'+cktar+'ost.cdx'); ERASE ('k'+cktar+'ost.cdx');  ENDIF
  USE ("k"+cktar+"ost") ALIAS price_full NEW EXCLUSIVE
  INDEX ON STR(mkeep)+STR(INT(MnTov/10^4),3)+Nat TAG Nat
  INDEX ON nmkeep+STR(INT(MnTov/10^4),3)+Nat TAG mnkeep

  IF FILE('k'+cktar+'ot.cdx');    ERASE ('k'+cktar+'ot.cdx');  ENDIF
  USE ("k"+cktar+"ot") ALIAS price NEW EXCLUSIVE
  INDEX ON STR(mkeep)+STR(INT(MnTov/10^4),3)+Nat TAG Nat
  INDEX ON nmkeep+STR(INT(MnTov/10^4),3)+Nat TAG mnkeep

  IF FILE('k'+cktar+'firm.cdx');    ERASE ('k'+cktar+'firm.cdx');  ENDIF
  USE ("k"+cktar+"firm") ALIAS TPoints NEW EXCLUSIVE
  INDEX ON STR(KPL)+STR(KGP) TAG "kgp_kpl"

  //�࣮�� �窨
  TOTAL ON STR(KPL)+STR(KGP) TO tmp_ktt
  //������
  TOTAL ON STR(KPL) TO tmp_kpl
  //CLOSE TPoints

  USE tmp_ktt NEW EXCLUSIVE
  USE tmp_kpl NEW EXCLUSIVE

   tmp_kpl->(AddKplKgpSkDoc())
  SELE tmp_ktt
  APPEND FROM tmp_ktt1

  //����� 業� ��㧨��
  aPrice:=PriceType2Kop("Price")


         //���ਭ�  152
  cdbSystem_ini(nRef_Ini, ktar, nAgSk, cFio,dShDateBg, dShDateEnd,aPrice)
  cdbCategory()
  cdbSales(nRef_Sales, dShDateBg, dShDateEnd)

  cdbDoc_Debt(nDoc_Debt,ktar)
  cdbDoc_Cash(nDoc_Debt,aKop)

  cdbRoutes(nRef_Routes)
  cdbFirms(nRef_Ini)
  cdbClients(nRef_Routes,aKop)
  cdbTPoints(nRef_Routes)


  IF STR(s_tag->Ref_Price) $ "7,8" //s_tag->Dt_Price#DATE()
    //��।��� ���� 業� � ���� �������㠫�� 業�
    cdbPrice(nRef_Price,aPrice)
    cdbPlanSale(1)
  ELSE
    //��।��� ���� 業�
    #ifdef CDBFULLPRICE
      cdbPrice(nRef_Price,aPrice,aPrice)
    #else
      cdbGoodsStock(nRef_Price)
      cdbPlanSale(0)
    #endif
    //���� ���⪨
  ENDIF

  IF (STR(s_tag->Ref_Price) $ "7,8" .AND. ; //s_tag->Dt_Price#DATE() .AND.;
     !EMPTY(nRef_Price)) .OR. !EMPTY(nRef_Routes)
    cdbPersonalDiscount(nRef_Price+nRef_Routes)
  ELSE
    cdbPersonalDiscount(0)
  ENDIF

  //Ref_Barcodes()
  //Ref_Stores(nRef_Ini)
  //Ref_Sertif(nRef_Ini)

  //Ref_Commands(.T.) //nRef_Ini)

  CdbDoc_Confirm()

  //Ref_AttrTypes(nRef_Ini,aKop)
  //Ref_PrnScripts(nRef_Ini)
  //Ref_FirmsPrnLinks(nRef_Ini)
  //Ref_RepScripts(nRef_Ini)
  //Ref_FillDocScripts(nRef_Ini)
  //Ref_Scripts(nRef_Ini)

  //set translate path OFF
  SET CONSOLE OFF;  SET PRINT ON
  SET PRINT TO QOUT.dat
  QOUT("")
  SET PRINT TO  ;  SET PRINT OFF




  SET CONSOLE OFF;  SET PRINT ON
  SET PRINT TO DATAEND.txt
    QQOUT("</DATA>")
  SET PRINT TO  ;  SET PRINT OFF

  SET CONSOLE OFF;  SET PRINT ON
  SET PRINT TO CATALOGS.txt
    QQOUT('<CATALOGS Comment="��ࠢ�筨��">')
  SET PRINT TO;  SET PRINT OFF


  SET CONSOLE OFF;  SET PRINT ON
  SET PRINT TO CATALOGSEND.txt
  QQOUT("</CATALOGS>")
  SET PRINT TO  ;  SET PRINT OFF

  SET CONSOLE OFF;  SET PRINT ON
  SET PRINT TO DOCUMENTS.txt
    QQOUT('<DOCUMENTS Comment="���㬥���">')
  SET PRINT TO;  SET PRINT OFF


  SET CONSOLE OFF;  SET PRINT ON
  SET PRINT TO DOCUMENTSEND.txt
    QQOUT("</DOCUMENTS>")
  SET PRINT TO  ;  SET PRINT OFF




  SET CONSOLE OFF;  SET PRINT ON
  SET PRINT TO FromCDB.dat
    QQOUT('<?xml version="1.0" encoding="UTF-8"?>')
     QOUT('<DATA DBVERSION="1977">')
  SET PRINT TO;  SET PRINT OFF
    FILEAPPEND("QOUT.dat","FromCDB.dat")
    FILEAPPEND("cdbSystem.txt","FromCDB.dat");FILEAPPEND("QOUT.dat","FromCDB.dat")

  aLoadFile:={;
  "CATALOGS.txt",;
    "cdbClients.txt" ,;
    "cdbTPoints.txt" ,;
    "cdbDogovor.txt" ,;
    "cdbCodeList.txt",;
    "cdbPersDisc.txt",;
    "cdbPrice.txt"   ,;
    "cdbSales.txt"   ,;
    "cdbCategory.txt",;
    "cdbFirms.txt"   ,;
  "CATALOGSEND.txt",;
  "DOCUMENTS.txt",;
    "cdbDoc_Debt.txt"   ,;
    "cdbDoc_Cash.txt"   ,;
    "cdbDoc_Routes.txt" ,;
    "cdbDoc_Confirm.txt",;
  "DOCUMENTSEND.txt",;
  "cdbPlanSale.txt";
  }

   AEVAL(aLoadFile,{|cFile| IIF(FILESIZE(cFile)=0,;
   (NIL),;//(outlog(__FILE__,__LINE__,FILE(cFile),cFile,FILESIZE(cFile))),;
    (;
    ;//outlog(__FILE__,__LINE__,FILE(cFile),cFile,FILESIZE(cFile)),;
    FILEAPPEND(cFile,"FromCDB.dat"),;
    FILEAPPEND("QOUT.dat","FromCDB.dat");
  );
  )})

  FILEAPPEND("DATAEND.txt","FromCDB.dat");FILEAPPEND("QOUT.dat","FromCDB.dat")



  CLOSE deb
  CLOSE skdoc
  CLOSE bdoc

  CLOSE PersonalPrice
  CLOSE Confirm
  CLOSE Merch

  CLOSE Sales
  CLOSE price
  CLOSE price_full
  CLOSE tmp_ktt
  CLOSE tmp_kpl
  CLOSE TPoints
  CLOSE PlanSale
  //iconv -f CP1251 -t UTF8 fromCDB.dat -o /tmp/fromCDB.dat

  RETURN (NIL)



/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  11-20-15 * 11:25:27am
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION cdbSystem_ini(nRef_Ini, ktar, nAgSk, cFio,dShDateBg, dShDateEnd,aPrice)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbSystem.txt
  //qqout('<?xml version="1.0" encoding="UTF-8"?>')
  //qout('<DATA DBVERSION="1977">')
  qqout('  <CONSTANTS Comment="����⠭��">')
  qout('    <ELEMENTS>')
  qout('      <ITEM GUID="D2B5508C-7453-4A52-B803-A846992A485D" VALUE="��."/>')
  qout('      <ITEM GUID="ADB99DF4-739B-4E6F-AEA9-E751B55CB18A" VALUE="�����: ������������, ��� �ਢ��, 980"/>')
  qout('      <ITEM GUID="13AF34A5-664D-4AAD-A29C-EEFC04FEFCA9" VALUE="��"/>')
  //�ଠ �� ���ன �믨�뢠���� ������ �� �ࠢ�筨��
  qout('      <ITEM GUID="13FAF2A0-3D1E-469E-BC53-CDADA6AC1375" VALUE="'+GUID_KPK("C",ALLTRIM(STR(gnKkl_c)))+'"/>')

  // �ᯮ�짮���� �����த��
  qout('      <ITEM GUID="C26639D8-F729-4C9F-ABB4-7154AE9C632B" VALUE="0"/>')

  // ������ � ������� ��. ���.
  qout('      <ITEM GUID="0D0B118F-A77D-4A90-ADFB-C79E5EB08CDB" VALUE="1"/>')
  qout('      <ITEM GUID="0DE4A49F-691B-4910-95BF-6F25A281D9E1" VALUE="0"/>')
  qout('      <ITEM GUID="6E9470DB-C618-4BF8-B510-D1E39E2217F6" VALUE="0"/>')
  qout('      <ITEM GUID="C21ED754-43D4-423D-BDB6-8D2F36B9F8D1" VALUE=""/> ')
  qout('      <ITEM GUID="63B7D515-CE1D-4F91-B65E-1293495A07E1" VALUE="0"/>')
  //᪫�� �ࠢ�筨�� ᪫����
  qout('      <ITEM GUID="86BA5DAD-16D0-46B8-9D8D-3EAB2CF08685" VALUE="BD72D91F-55BC-11D9-848A-00112F43529A"/>')
  qout('      <ITEM GUID="8C52BBBF-8BBB-447D-B18B-06860D372818" VALUE="1"/>')
  qout('      <ITEM GUID="B201164E-E265-4C1D-B3D0-0579BCD1FDA6" VALUE="0"/>')
  //����䨪��������᪮������ - ��� ���� ���� ���ࠣ���, ����� �⮡ࠦ����� � "������". ���祭�� �� ��. ���� ���⠪� ���ଠ樨.
  qout('      <ITEM GUID="1B3D41B2-EB00-4F25-A476-6A668C5E69F0" VALUE="663DE54A-DA59-44A4-9BD0-7509DFA63856"/>')
  qout('      <ITEM GUID="7BC85296-F536-411E-AAA9-74AD5C7ADEA2" VALUE=""/>')
  qout('      <ITEM GUID="0270B3D5-4213-419B-9E3A-48CBA4CAEC04" VALUE="1"/>')
  qout('      <ITEM GUID="0A253E8B-9043-414B-8026-0C9369F781AD" VALUE=""/>')
  //�筮��� �-�� ⮢�� 0...4
  qout('      <ITEM GUID="27952AB3-1365-4B56-A0EF-34EC0133E5D3" VALUE="1"/>')
  qout('      <ITEM GUID="5D54ED85-FDEA-4027-8ECD-129C27BDBF64" VALUE="2"/>')
  qout('      <ITEM GUID="A978F039-3F17-4705-B7F6-16C580C9AC5F" VALUE="2"/>')
  // ������� ᪫�� D54381E5-D965-11DC-B30B-0018F30B88B5
  qout('      <ITEM GUID="448B6FAB-5E21-479C-9A9A-63E8ECED59B9" VALUE=""/>')
  qout('      <ITEM GUID="F4F9EA70-D4F9-4F21-AC4A-F073C5D08B95" VALUE=""/>')
  qout('      <ITEM GUID="5DC7AEA9-E9DA-4AA4-BABB-DF5A43AF1AD5" VALUE="0"/>')
  qout('      <ITEM GUID="DDEDCE5E-7A69-4858-BC89-F48E3E44A8EF" VALUE=""/>')
  qout('      <ITEM GUID="8E0A70A1-476C-4C7B-A8A7-0C9CE334FC68" VALUE="0"/>')
  qout('      <ITEM GUID="36767A2E-4DF5-43B5-9813-893BF6F65A7F" VALUE="0"/>')
  qout('      <ITEM GUID="73355324-F463-428A-91D2-2868DD35A168" VALUE="0"/>')
  qout('      <ITEM GUID="B0FDDB94-CAF7-4003-B2FD-DF15BD2F1F1B" VALUE="0"/>')
  qout('      <ITEM GUID="A2E1CC68-0624-45A6-8057-EFD35259B9FE" VALUE="'+;
    ALLTRIM(PADL(LTRIM(STR(ktar,3)), 3, "0"))+ALLTRIM(STR(nAgSk,3))+" "+;
    cFio +'"/>')
  qout('      <ITEM GUID="6D4C184B-810D-4C23-BA6E-FB7E03B48812" VALUE="1"/>')
  qout('      <ITEM GUID="B8396958-7D13-4633-A6C3-C8D639CBF9E6" VALUE="1"/>')
  // ४����� �=�� �����뢠�� 1
  qout('      <ITEM GUID="E4D51F85-CC81-402C-9F14-A8EAA07B945F" VALUE="1"/>')
  qout('      <ITEM GUID="690B5736-E1B9-41EF-A132-807ACAD31687" VALUE="0"/>')
  qout('      <ITEM GUID="D2DD4509-E164-4E6C-A0B2-C46B5CA0397D" VALUE="1"/>')
  qout('      <ITEM GUID="D902C64A-9A7A-40D1-8067-E4BB6B309534" VALUE="0"/>')
  qout('      <ITEM GUID="79C698DB-3C55-465E-ACFE-4741ACDD5655" VALUE="'+GUID_KPK("B",ALLTRIM(PADL(LTRIM(STR(ktar,3)), 3, "0"))+ALLTRIM(STR(nAgSk,3)))+'"/>')
  qout('      <ITEM GUID="4A6B2C4C-445B-4985-A509-10FB1A2D57CE" VALUE="0"/>')
  qout('      <ITEM GUID="3ABCD996-1632-46F6-8855-CB25759BC304" VALUE="0"/>')
  qout('      <ITEM GUID="8DEB5086-FB67-436E-A5F7-5118CE0DC09E" VALUE="0"/>')
  qout('      <ITEM GUID="B1945151-4055-4BC4-A9A0-9E1D39BABE99" VALUE="0"/>')
  //������ �����뢠�� 1
  qout('      <ITEM GUID="99EEEEF3-015A-4727-8166-65F2DCCEAB29" VALUE="1"/>')
  qout('      <ITEM GUID="ED0274E1-3B90-4DB9-951F-3037260B80AC" VALUE="1"/>')
  qout('      <ITEM GUID="EF7C73D2-D745-4E04-A5F1-AFCBBCB72F05" VALUE="0"/>')
  qout('      <ITEM GUID="6E7183CC-ABF6-4B18-AF75-F4D851551FD4" VALUE="0"/>')
  qout('      <ITEM GUID="6517DA49-A145-43A7-8730-A3E9978E437B" VALUE="0"/>')
  qout('      <ITEM GUID="16D90B81-6BA0-4E72-A471-4350213B934E" VALUE="1"/>')
  qout('      <ITEM GUID="32CD846C-CAFA-4006-BC05-EF2CD135E2EA" VALUE="1"/>')
  //ࠡ�� � ���� ᪨����
  qout('      <ITEM GUID="4838F24A-FFAA-48F3-98F8-7863125944C8" VALUE="1"/>')
  qout('      <ITEM GUID="54E2A0B0-4F94-499D-875A-9D2EE7634DA9" VALUE="300"/>')

  IF .T. // PADL(LTRIM(STR(ktar,3)), 3, "0") $ "482 775"
    //GPS
    //���.
    qout('      <ITEM GUID="E8DCA437-FA0D-4F92-B7B8-4A7A162638C5" VALUE="1"/>')

    //"�������।������न���"
    aRegOprKt:={;
    {'GPS',              '95013C3C-BC8B-468B-A797-69998743613A' },;// 1
    {'GPS�������륑��','F1D4E26C-BECE-495B-BFED-F42F4B40AE4A' },;// 2
    {'������륑��',    'C0BE1868-DD2F-4245-95B3-4BFFE605C470' }; // 3
    }
    /*
    �������।������न���
    � ���祭�� ����⠭�� 㪠�뢠���� ०�� ��।������ GPS-���न���.
    ���祭�� �롨ࠥ��� �� ����᫥��� "�������।������न���".
    */
    qout('      <ITEM GUID="964FFAD2-52AC-4C67-8B36-C7F99D08445C" VALUE="'+aRegOprKt[2,2]+'"/>')



  ELSE
    qout('      <ITEM GUID="E8DCA437-FA0D-4F92-B7B8-4A7A162638C5" VALUE="0"/>')
  ENDIF

  qout('      <ITEM GUID="711587ED-1589-4E69-A7F7-09ADE3FB5888" VALUE="0"/>')
  qout('      <ITEM GUID="23AE51B7-55DE-46A0-9ECC-A796EB5035D2" VALUE="111"/>')
  qout('      <ITEM GUID="138F9A6C-7F96-4136-9FBC-0663476BC094" VALUE="1"/>')
  qout('      <ITEM GUID="E41A7026-551C-44F9-997F-51A8B68B88AC" VALUE="0"/>')
  qout('      <ITEM GUID="C6B9563F-947A-46C2-82DD-D375E103317D" VALUE="0"/>')
  qout('      <ITEM GUID="CCD3F25E-A29B-419F-B8A2-D58E380EFAE2" VALUE="0"/>')
  qout('      <ITEM GUID="F52E3C06-48D6-4809-AE16-13C61E78EABD" VALUE="0"/>')
  qout('      <ITEM GUID="83A6772E-4DDE-4668-9318-BDF82BFDE445" VALUE="0"/>')
  qout('      <ITEM GUID="A86959B3-ED83-44D8-B457-DF8DFEA9EFDD" VALUE="1"/>')
  qout('      <ITEM GUID="AEDDB719-EB7A-493E-B80E-EE2D63E76FE5" VALUE="0"/>')
  qout('      <ITEM GUID="0DEEF076-FF1F-4E4D-ACB5-8344BE0281A1" VALUE="1"/>')
  qout('      <ITEM GUID="60A12916-08C0-4ABF-86D2-7F508282BAB8" VALUE="/data/data/ru.agentplus.agentp2/backup/"/>')
  qout('      <ITEM GUID="5616D1E9-BFA3-40FC-BABA-852D16B5E774" VALUE="0"/>')
  qout('      <ITEM GUID="FAF41508-AB25-4E1B-9BBD-F80634A3D264" VALUE="0"/>')
  qout('      <ITEM GUID="4C6B29D4-3D61-43C7-A063-A63823E55069" VALUE="0"/>')
  //qout('      <ITEM GUID="90C4C934-85A6-449E-A519-D5AE44DA667B" VALUE="5B629B5B-0D6E-081E-3335-323938353035"/>')
  qout('      <ITEM GUID="072EC906-BD0B-4B75-AFA8-BECE1434F1EB" VALUE="0"/>')
  qout('      <ITEM GUID="ABC5B73A-F477-406B-89C5-E9AAB3B4F1E1" VALUE="0"/>')
  qout('      <ITEM GUID="8886E1E1-FCDA-4EA0-85F8-DF3D3DD8A5E3" VALUE="1"/>')
  qout('      <ITEM GUID="72889BFF-CC95-4C2E-9C4E-0D28E2EFBF7C" VALUE="0"/>')
  qout('      <ITEM GUID="56649629-21E4-4116-AEC6-E794F12C62FE" VALUE="0"/>')
  qout('      <ITEM GUID="C64DAC8A-2FBC-40BF-BF49-143398AAAC9A" VALUE="0"/>')
  qout('      <ITEM GUID="DC63708B-9257-48DC-9F16-D9846AC7D5FE" VALUE="1"/>')
  qout('      <ITEM GUID="EA614964-30B8-4065-BD65-940E38DB1F31" VALUE="1"/>')
  qout('      <ITEM GUID="F984E263-B838-489E-A1D4-F775DB7EDE98" VALUE="1"/>')
  // ������ ��⮧��������� 1 - ���. �த. 2 - ��� �த��� 3 - ��.�த-����稥 4 - ��㫠 1.5
  qout('      <ITEM GUID="404D1878-4456-4095-BFD5-EAF93F6C0E1B" VALUE="3"/>')
  qout('      <ITEM GUID="195BCCD6-F8EA-481E-A411-1D33A52CFE49" VALUE="0"/>')
  qout('      <ITEM GUID="B69EC9A6-565F-4E3E-844F-0060C5975FED" VALUE="0"/>')
  qout('      <ITEM GUID="68524BCF-B992-4896-8A91-44EE31498831" VALUE="0"/>')
  qout('      <ITEM GUID="018DD98C-D617-4D35-B5C0-EFDABF6B37A2" VALUE="0"/>')
  qout('      <ITEM GUID="32798A23-C58F-4C7A-8C3D-36E5A60184D3" VALUE=""/>')
  qout('      <ITEM GUID="61A474B1-21D0-4047-B2D5-7213A7294050" VALUE="�����,����,���,���祭�������,���饭��,���������,��६�饭��,����㯫����,�������"/>')
  qout('      <ITEM GUID="B917AF50-AF2B-43C1-A111-CC8822B180C2" VALUE="0"/>')
  qout('      <ITEM GUID="4280AE75-B17C-48C2-9140-4FC09853A4AD" VALUE="0"/>')
  qout('      <ITEM GUID="344436BC-3E1B-42D7-B453-496D61EAE2D8" VALUE="/sdcard/AgentPlusPictures/"/>')
  qout('      <ITEM GUID="EC1C050F-9183-4CF8-9A40-8546C8617EBB" VALUE="1"/>')
  qout('      <ITEM GUID="DF297AD7-E2CE-478A-974E-FB399239E23E" VALUE="2013-03-29T11:10:15"/>')
  qout('    </ELEMENTS>')
  qout('  </CONSTANTS>')

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  11-20-15 * 09:46:58pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION cdbSales(nRun, dSHDATEBG, dShDateEnd)
  LOCAL nKgp, nKpl, nMnTov, nQRest, i, nCurWeek, nCurWeekFor
  LOCAL cSales, nSales
  LOCAL aDt_Range,k


    dShDateBg:=LastMonday(dShDateBg) //�������쭨� �⮩ ������
    dShDateEnd:=LastMonday(dShDateEnd)+7-2 //�㡡�� ��������㥬�� ������


  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbSales.txt

  IF !EMPTY(nRun)
    QQOUT('<CATALOG GUID="AF9FAA26-9638-41C5-BFCE-9514E670EF2E" KILLALL="1" Comment="��ࠢ�筨�.�����த��">')
     QOUT('  <ELEMENTS>')

    SELE tmp_ktt //�࣮�� �窨
    DBGOTOP()
    DO WHILE !EOF()
      nKgp:=Kgp
      nKpl:=Kpl

      lWeek_One:=.F.
      aDt_Range:={}

      IF TPoints->(DBSEEK(STR(nKPL)+STR(nKGP)))
        IF !EMPTY(TPoints->RouteTime) .AND. LEN(ALLTRIM(TPoints->RouteTime))>1

          aDt_Range:=Dt_Range(dShDateEnd,TPoints->RouteTime)

        ELSE
          lWeek_One:=.T.
        ENDIF
      ELSE
        lWeek_One:=.T.
      ENDIF

      IF lWeek_One
        nWeekEnd:=WEEK(dSHDATEEND)+IIF(WEEK(dSHDATEBG) > WEEK(dSHDATEEND), 52, 0)
        //outlog(__FILE__,__LINE__,nCurWeekFor,nWeekEnd,WEEK(dSHDATEBG),WEEK(dSHDATEEND))

        k:=0
        FOR nCurWeekFor:=WEEK(dSHDATEBG) TO nWeekEnd

          IF WEEK(dSHDATEBG) > WEEK(dSHDATEEND)
            nCurWeek:=nCurWeekFor-IIF(WEEK(dSHDATEBG) > WEEK(dSHDATEEND) .AND. nCurWeekFor<=52, 0, 52)
           ELSE
            nCurWeek:=nCurWeekFor
          ENDIF
          AADD(aDt_Range,{dSHDATEBG+(7*k), dSHDATEBG+(7*(k+1))-1})
          k++
        NEXT
      ENDIF

      i:=0

      SELE price
      DBGOTOP()
      DO WHILE !EOF()

        //nMnTov:=MnTov
        nMnTov:=MnTovT

        cSales:="" //��ப� � �த�����
        nSales:=0

        FOR k:=1 TO LEN(aDt_Range)
        //FOR nCurWeekFor:=WEEK(dSHDATEBG) TO nWeekEnd

          SELE Sales
          OrdSetFocus("KGp_MnTovT")
          IF DBSEEK(STR(nKpl)+STR(nKgp)+STR(nMnTov)) //+STR(nCurWeek,2))
            SUM KVP TO nKVP ;
            WHILE STR(nKpl)+STR(nKgp)+STR(nMnTov) = ;
              STR(Kpl)+STR(Kgp)+STR(MnTovT) ; // MnTov MnTovT
            FOR  Dop>=aDt_Range[k,1] .AND. Dop<=aDt_Range[k,2]
            //WHILE STR(nKpl)+STR(nKgp)+STR(nMnTov)+STR(nCurWeek,2) = STR(Kpl)+STR(Kgp)+STR(MnTov)+STR(WEEK(Dop),2)
          ELSE
            nKVP:=0
          ENDIF

          nQRest:=0
          SELE Merch
          OrdSetFocus("KGp_MnTovT")
          IF DBSEEK(STR(nKpl)+STR(nKgp)+STR(nMnTov)) //+STR(nCurWeek,2))
            SUM KVP TO nQRest ;
            WHILE STR(nKpl)+STR(nKgp)+STR(nMnTov) = ;
                  STR(Kpl)+STR(Kgp)+STR(MnTovT) ; // MnTov MnTovT
            FOR  Dop>=aDt_Range[k,1] .AND. Dop<=aDt_Range[k,2]
            //WHILE STR(nKpl)+STR(nKgp)+STR(nMnTov)+STR(nCurWeek,2) = STR(Kpl)+STR(Kgp)+STR(MnTov)+STR(WEEK(Dop),2)
          ELSE
            nQRest:=0
          ENDIF

          cSales+=LTRIM(STR(nKVP ,4,0))+" "
          nSales+=(nQRest+nKVP)

          /*
          IF nKgp = 8460198
            outlog(__FILE__,__LINE__,nMnTov,nQRest,nKVP,aDt_Range[k,1],aDt_Range[k,2])
          ENDIF
          */

        NEXT

        IF ROUND(nSales,3) # 0 //���� �த���
          cSales:=RTRIM(cSales)
          QOUT('    <ITEM '+;
          ' GUID="'+uuid()+'"'+;
              ;//TPointID
          ' A02="'+GUID_KPK("C",ALLTRIM(STR(nKgp)),ALLTRIM(STR(nKpl)))+'"'+; //GUID ������
              ;//GoodsID
          ' A04="'+GUID_KPK("A",ALLTRIM(STR(nMnTov)))+'"'+; //GUID ⮢��
              ;//Sales
          ' A07="'+RIGHT(cSales, 100)+'"'+;  // ��ઠ �-��
          '/>')
          i++//����� ��㧮�����⥫�
        ENDIF


        SELE price
        SKIP
      ENDDO

      SELE tmp_ktt //�࣮�� �窨
      SKIP
    ENDDO

    QOUT('  </ELEMENTS>')
    QOUT('</CATALOG>')
  //ELSE
    //QOUT('  </ELEMENTS>')
  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  01-21-17 * 01:38:24pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION cdbPlanSale(nRun)
  /*
  6.7.  ���� ������ �த�� (�⠭����)
  ����᫥��� "���� ������ �த��" �।�����祭� ��� �࠭���� ᯨ᪠ ⨯�� ������ �த��.
  */
  LOCAL aPlSl_Ctg:={;
                    { 'AFE4839F-2734-4BF0-A209-08CCB9A358E9',; //1,1
                    '����� �த�� �� ��⥣��� ⮢�஢.'; // 1,2
                    },;
                    {'DC403B36-A935-4624-AA96-CF4B85097612',; // 2,1
                    '����� �த�� �� ⮢�ࠬ.';              // 2,2
                    };
                  }
  LOCAL dBeg:=STOD(STR(YEAR(DATE()),4)+'01'+'01')
  LOCAL dEnd:=STOD(STR(YEAR(DATE()),4)+'12'+'31')
  LOCAL nPerCent


  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbPlanSale.txt
  IF !EMPTY(nRun)
    sele PlanSale
    DBGoTop()

    qqout('  <CONSTANTS Comment="����⠭��">')
    qout('    <ELEMENTS>')
    // �ᯮ�짮���� �����த��
    qout('      <ITEM GUID="C26639D8-F729-4C9F-ABB4-7154AE9C632B" VALUE="1"/>')
    // �᭮���� �����த��
    qout('      <ITEM GUID="50F284E8-BCD6-47D4-8DD1-181D9592CB20" VALUE="'+PlanSale->gplsl+'"/>')
    qout('    </ELEMENTS>')
    qout('  </CONSTANTS>')


    QOUT('<CATALOGS Comment="��ࠢ�筨��">')
    QOUT('     <CATALOG GUID="D6D52ADA-0F38-4112-AF3C-2F1E425A43D1"  Comment="��ࠢ�筨�.�����������">')

    QOUT('       <GROUPS>')
    QOUT('         <GROUP GUID="E42DA5B9-E29B-43E1-B7E3-9B500879D6B7" Comment="�������� ��㯯�஢�� �� ��⥣���">')
    QOUT('           <ELEMENTS>')

    DBGoTop()
    Do While !eof()
      nPerCent:= PlanSale->Fakt / PlanSale->Plan * 100
      QOUT('             <ITEM '+;
          ' GUID="' + PlanSale->gPlslTa + '"'+; // GUID - �-⮢ ������த��
            ' Name="'+LEFT(XmlCharTran(PADR(PlanSale->nplslta,25,' ');
            +'|'+STR(PlanSale->Plan,12,0);
            +'|'+STR(PlanSale->Fakt,12,0);
            +'|'+STR(nPerCent,12,0)+'%';
            ), 150)+'"'+;
            ' ParId="'+''+'"'+;
                '/>')

      sele PlanSale
      DBSkip()
    EndDo

    QOUT('           </ELEMENTS>')
    QOUT('         </GROUP>')

    QOUT('       </GROUPS>')

    QOUT('       <ELEMENTS Comment="�������� �ࠢ�筨�� �����������">')
    DBGoTop()
    Do While !eof()
      /*
      //{'���� �த��',ktar,'��騩 ��ꥬ',   9000,  1000,  11, i=8 , i=7 }
      _FIELD->nplsl :=  '���� �த��'
      _FIELD->nplslta := '��騩 ��ꥬ'
      _FIELD->plan := 9000
      _FIELD->fakt := 1000
      _FIELD->gPlsl:=cGuid_plsl
      _FIELD->gPlslTa:=uuid()
      */

        cDocID:=uuid() // ��㣠 ��� ��������� ��㯯�

        QOUT('     <ITEM'+;
        ' GUID="'+cDocID+'"'+;
        ' Name="'+XmlCharTran(alltrim(PlanSale->nplslta))+'"'+;
        ' Code="" A04="20" A05=""'+;
        ' A06="'+cDocID+'"'+;
        ' A08="0"'+;
        ' A013="'+cDocID+'"'+;
        ' A014="0" A015="0"'+; // 1 - ��㣠 0 - ⮢��
        ' A035="'+XmlCharTran(alltrim(PlanSale->nplslta))+'"'+;
        ' A038="0"'+;
        ' A039="'+cDocID+'"'+;
        ' A042="" A043=""  A044="" A048=""'+;
        ' A050="'+cDocID+'"'+;
        ' A037="0" A011="0" A041="0" A052="2"'+; // 2 ��� ���-��� �� �����
        ' A020="0" A021="0" A022="0" A023="0" A030="0" A031="0" A032="0"'+;
        ' A033="0" A034="0"'+;
        ' GrpID0="'+PlanSale->gPlslTa+'"'+;
        ' GrpID1="'+PlanSale->gPlslTa+'"'+;
        '>')
         /*
         QOUT('       <TABLES>')
         QOUT('         <TABLE GUID="AF0A6972-4BCA-4652-A3CF-8EBC1ED1EE0D" Comment="�����筠� ���� ���⪨">')
         QOUT('           <ITEM'+;
                           ' GUID="'+uuid()+'"'+;
                           ' CtlgId="'+cDocID+'"'+;
                           ' A06="1" A01="0" A02="0"/>')
         QOUT('         </TABLE>')
         QOUT('       </TABLES>')
         */
       QOUT('     </ITEM>')

      sele PlanSale
      DBSkip()
    EndDo
  qout('    </ELEMENTS>')
  QOUT('  </CATALOG>')


    sele PlanSale
    DBGoTop()
    cDocID := PlanSale->gPlsl // GUID - �����, ��� ���⠢�_�����

    QOUT('  <CATALOG GUID="41598C02-F788-48A7-A039-645EF74BD57F" Comment="���㬥��.����� �த��" KILLALL="1">')
    QOUT('    <ELEMENTS>')
          QOUT('      <ITEM'+;
            ;// GUID  GUID
                      ' GUID="'+cDocID+'"'+;
            ;// IsDeleted ��᫮ - 1.0
                      ' Name="'+LEFT(XmlCharTran(PlanSale->nPlSl), 50)+'"'+;
            ;// A02 ���
                      ' A02="'+aPlSl_Ctg[1,1]+'"'+;
            ;// A03 ��⏮��������
                      ' A03="1"'+;
            ;// A04 ��⏮�㬬�
                      ' A04="0"'+;
            ;// A05 ��砫���ਮ��
                      ' A05="'+cdbDTLM(dBeg,'00:00:00')+'"'+;
            ;// A06 ����砭����ਮ��
                      ' A06="'+cdbDTLM(dEnd,'23:59:59')+'"'+;
            ;// A07 ���㠫쭮���  0 - ���� �� ⥪. �����, 1 - �� �����
                      ' A07="1"'+;
            ;// A08 - ����ࠣ�� ���� �� ����� �९��� ����
                 '/>')
    QOUT('    </ELEMENTS>')
    QOUT('  </CATALOG>')

    //Q
    QOUT('  <CATALOG GUID="6B5D547E-B683-4990-89CD-61D0F8497A9C" Comment="���㬥��.���⠢ ����� �த��" KILLALL="1">')
    QOUT('    <ELEMENTS>')
    DBGoTop()
    Do While !eof()
      nPerCent:= PlanSale->Fakt / PlanSale->Plan * 100
        QOUT('      <ITEM'+;
          ;// GUID
              ' GUID="'+uuid()+'"'+;
          ;// IsDeleted
          ;// A01 �����த��
              ' A01="'+cDocID+'"'+;  // GUID - �����
          ;// A02 ��������������
              ' A02="'+PlanSale->gPlslTa +'"'+;  // GUID -  ��⥣�ਨ
          ;// A03 ����������⢮
              ' A03="'+LTRIM(STR(PlanSale->Plan,5,0))+'"'+;
          ;// A04 �����㬬�
          ;// A05 ���⊮����⢮
              ' A05="'+LTRIM(STR(PlanSale->Fakt,4,0))+'"'+;
          ;// A06 ����㬬�
          ;// A07 ��業�믮������
              ' A07="'+LTRIM(STR( nPerCent,3,0))+'"'+;
               '/>')
      sele PlanSale
      DBSkip()
    EndDo

    QOUT('    </ELEMENTS>')
    QOUT('  </CATALOG>')

    QOUT("</CATALOGS>")

  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  11-20-15 * 09:47:11pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION cdbDoc_Debt(nRun,ktar)
  LOCAL i1, i2, ktasr
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbDoc_Debt.txt
  IF !EMPTY(nRun)
  QQOUT('  <DOCUMENT GUID="A93AADFA-2A35-40FE-B88A-3768825CDD31" Comment="���㬥��.����" KILLALL="1">')
  QOUT('    <ELEMENTS>')

    SELE skdoc
    SET FILTER TO !DELETED()

    locate for ktan=ktar
    ktasr:=ktas

    DBGOTOP()

    SELE tmp_kpl
    //SET RELA TO STR(kpl,7) INTO skdoc
    DBGOTOP()
    WHILE (!EOF())
      IF STR(tmp_kpl->Kpl)$"     20034"
        SELECT tmp_kpl
        DBSKIP()
        LOOP
      ENDIF
      IF !skdoc->(DBSEEK(STR(tmp_kpl->kpl,7)))
        SELECT tmp_kpl
        DBSKIP()
        LOOP
      ENDIF
      i1:=0
      i2:=0

      SELE skdoc
      DO WHILE skdoc->Kpl = tmp_kpl->Kpl

        IF iif(.F.,ktasr=ktas,.T.) //�뢮��� ⮫쪮 �-��, � ����� � ������ � �ਭ������� �㯥�� ��ࣀ����
          dDtOpl:=IIF(EMPTY(DtOpl), DOP+14,DtOpl)
          QOUT('      <ITEM'+;
                      ;//GUID  GUID
                    ' GUID="';
                      +PADR(DTOS(DOP) ,8,'F')+'-';// NNNNNNNN- ���
                      +PADR(NTOC(Rand(0)*10^7,16),4,'F')+'-'; // NNNN-
                      +PADR(NTRIM(Nap),4,'F')+'-'; // NNNN- ���ࠢ�����
                      +PADR(NTRIM(Sk) ,4,'F')+'-'; // NNNN- ᪫��
                      +PADR(NTRIM(ABS(TTN)) ,12,'F');//NNNNNNNNNNNN // ����� ���
                      ;// +uuid();
                      +'"'+;
                      ;//DT  ��⠂६�
                    ' dt="'+cdbDTLM(DOP,'00:00:00')+'"'+;
                      ;//IsDeleted ��᫮ - 1.0
                      ;//IsPost  ��᫮ - 1.0
                    ' IsPost="1"'+;
                      ;//DocNumberPrefix ��䨪ᄮ�㬥��  ��ப�
                      ;//DocNumber ��������㬥��  ��᫮
                    ' DocNumber="'+NTRIM(NAP)+'_'+NTRIM(SK)+'_'+NTRIM(TTN)+'"'+;
                      ;//A01      ��⥣���  GUID
                      ;//  IIF(ktan=ktar,' A01="'+GUID_KPK("�0",'255000000')+'"','')+;
                      ;//A02      �࣠������  GUID
                    ' A02="'+GUID_KPK("C",ALLTRIM(STR(gnKkl_c)))+'"'+;
                      ;//A03      ����ࠣ��� GUID
                    ' A03="'+GUID_KPK("C",ALLTRIM(STR(Kpl)))+'"'+;
                      ;//A04      ��࣮��窠  GUID
                      IIF(KGp=0,;
                      '',;
                      ' A04="'+GUID_KPK("C",ALLTRIM(STR(KGp)),ALLTRIM(STR(Kpl)))+'"';
                    )+;
                      ;//A05      �������  GUID
                    ' A05=""'+;
                      ;//A06      ��⠎����� ��⠂६�
                    ' A06="'+cdbDTLM(dDtOpl,'00:00:00')+'"'+;
                      ;//A07      �㬬�  ��᫮ - *.4
                    ' A07="'+LTRIM(STR(SDP,15,2))+'"'+;
                      ;//A08      �������਩  ��ப� - 255
                    ' A08="';
                      +LEFT('';
                      +' ᮧ��� ��:'+NTRIM(KtaN)+' '+ALLTRIM(NKtaN);
                      +' ����.'+LTRIM(STR(Nap))+' '+alltrim(NNap);
                      ,255);
                      +'"'+;
                      ;//A011     ���㬥��᭮�����  ��ப� - 36
                    ' A011="C9A2F172-BC81-11E2-8971-B8AC6F8EA8C5"'+;
                      ;//�012     ���쏮�稭����  ��᫮ - 1.0
                      ;//A014     �뤥���� ��᫮ - 1.0
                    ' A014="'+IIF(dDtOpl>DATE(),'1','0')+'"'+;
                      ;//A015     �।�⠢�����  ��ப� - 255
                    ' A015="'+'��������� ⮢�஢ � ��� ';
                    +'�� '+DTOC(DOP,"DD.MM.YYYY")+' ';
                    +'N'; // '&#8470;';//'�'
                    +ALLTRIM(STR(TTN));
                    +' '+'�㬬�:';
                    +LTRIM(STR(SDV,15,2));
                    +'"'+;
               '/>')
          i1:=0//1
          i2:=0//1
        ENDIF
        DBSKIP()
      ENDDO

      SELECT tmp_kpl
      DBSKIP()
    ENDDO

    QOUT('    </ELEMENTS>')
    QOUT('  </DOCUMENT>')

    SELE skdoc
    SET FILTER TO
    SELE tmp_kpl
    SET RELA TO

  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  11-21-15 * 04:49:47pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION cdbDoc_Cash(nRun,aKop)
  LOCAL i1, i2
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbDoc_Cash.txt
  IF !EMPTY(nRun)
  QQOUT('  <DOCUMENT GUID="749BE2E0-9B00-4D7B-9D4D-88CA53327511" Comment="���㬥��.���� ����㯫����" KILLALL="1">')
  QOUT('    <ELEMENTS>')
    SELE bdoc
    SET FILTER TO !DELETED()
    DBGOTOP()

    SELE tmp_kpl
    //SET RELA TO STR(kpl,7) INTO skdoc
    DBGOTOP()
    WHILE (!EOF())
      IF STR(tmp_kpl->Kpl)$"     20034"
        SELECT tmp_kpl
        DBSKIP()
        LOOP
      ENDIF
      IF !bdoc->(DBSEEK(STR(tmp_kpl->kpl,7)))
        SELECT tmp_kpl
        DBSKIP()
        LOOP
      ENDIF
      i1:=0
      i2:=0

      SELE bdoc
      DO WHILE bdoc->KKl = tmp_kpl->Kpl
        QOUT('      <ITEM'+;
          ;//GUID  GUID
                    ' GUID="'+uuid()+'"'+; //GUID_KPK("D",ALLTRIM(LTRIM(DTOS(DDK))+PADL(LTRIM(STR(RND)),6,"0")))
          ;//DT  ��⠂६�
                    ' DT="'+cdbDTLM(DDK,'00:00:00')+'"'+;
          ;//IsDeleted ��᫮ - 1.0
          ;//IsPost  ��᫮ - 1.0
                    ' IsPost="1"'+;
          ;//DocNumberPrefix ��䨪� ���㬥�� ��ப�
          ;//DocNumber ��������㬥��  ��᫮
          ' DocNumber="'+ALLTRIM(STR(NPLP))+"/"+ALLTRIM(STR(RND))+'"'+;
          ;//A01  �࣠������  GUID
                    ' A01="'+GUID_KPK("C",ALLTRIM(STR(gnKkl_c)))+'"'+;
          ;//A02  ����ࠣ��� GUID
                    ' A02="'+GUID_KPK("C",ALLTRIM(STR(KKl)))+'"'+;
          ;//-A03  ��࣮��窠  GUID           ;//          ' A03="'+'???'+'"'+;
          ;//-A04  �������  GUID                    ' A04=""'+;
          ;//-A06  �������਩  ��ப� - 255
                    ' A06="'+LEFT(ALLTRIM(STR(BS_D,6,0)+":"+OSN),255)+'"'+;
          ;//A07  �㬬�  ��᫮ - *.4
                    ' A07="'+LTRIM(STR(BS_S,15,2))+'"'+;
          ;//-A09  ���㬥��᭮�����  GUID
          ;//-A011 ��⥣���  GUID
          ;//-A012 ���� ��ப� - 20
          ;//-A013 ������  ��ப� - 20
          ;//A014 ��⠍�砫� ��⠂६�
                    ' A014="'+cdbDTLM(DATE(),'00:00:00')+'"'+;
          ;//A015 ��⠎���砭��  ��⠂६�
                    ' A015="'+cdbDTLM(DATE(),'00:00:00')+'"'+;
          ;//A016 ���������  GUID
                    ' A016="'+aKop[1,4]+'"'+;
          ;//A017 ��⠒�窨�४� ��⠂६�
          ;//�018 ��ᯥ�⠭ ��᫮ - 1.0
                    ' A18="1"'+;
               '/>')
        i1:=0//1
        i2:=0//1
        DBSKIP()
      ENDDO

      SELECT tmp_kpl
      DBSKIP()
    ENDDO

    QOUT('    </ELEMENTS>')
    QOUT('  </DOCUMENT>')

    SELE bdoc
    SET FILTER TO
    SELE tmp_kpl
    SET RELA TO

  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  12-25-15 * 01:28:13pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION CdbDoc_Confirm()
  LOCAL nDocState
  LOCAL cDocState, aDocState
  cDocState:="��ᮯ"
  aDocState:={}

  SELE Confirm

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbDoc_Confirm.txt

  QQOUT('  <DOCUMENT GUID="E01E1F5C-D6E4-46E8-B923-3758B0D79BDE" Comment="���⢥ত���� ���㬥�⮢ ����� ���㯠⥫�">')
   QOUT('    <CONFIRMATIONS>')
  DBGOTOP()
  WHILE (!EOF())

    IF LEN(ALLTRIM(DocGUID)) = 36

      nDocState:=1+8    // 8-����� ��������� (����ᠭ)
      DO CASE
      CASE EMPTY(dFp)
        cDocState:="�----"
      CASE EMPTY(dSp)
        cDocState:="��---"
      CASE EMPTY(dTOt) .AND. PRZ=0
        cDocState:="���--"
      CASE !EMPTY(dTOt) .AND. PRZ=0
        cDocState:="���-"
        nDocState:=1+8+64 //64-����   (����ᠭ + ����)
      CASE PRZ=1
        cDocState:="��ᮯ"
      ENDCASE
        /*
        cDocState:= 3453466 �. . . . . "
        cDocState:="�.�. . . .3434566"
        cDocState:="�.�.C. . ."
        cDocState:="�.�.C.O. ."
        cDocState:="�.�.C.O.�."
        */
        QOUT('      <ITEM'+;
            ;//GUID  GUID
                  ' GUID="'+DocGUID+'"'+;
                     '/>')
        // ������ ����� ���
        AADD(aDocState,{DocGUID,;
        CHARREPL('-',UPPER(cDocState),'#'),;
        ALLTRIM(STR(TTN))})

        // �����ত���� �� 02-18-17 02:48am
        sele phtdoc
        ordsetfocus('t1')
        If DBSeek(Confirm->DocGUID)
          Do While DocGUID = Confirm->DocGUID
            QOUT('      <ITEM'+;
                ;//GUID  GUID
                      ' GUID="'+GUID+'"'+;
                         '/>')
            QOUT('      <ITEM'+;
                ;//GUID  GUID
                      ' GUID="'+PhotGUID+'"'+;
                         '/>')
            sele phtdoc
            DBSkip()
          EndDo
        EndIf

    ENDIF
    SELE Confirm
    DBSKIP()
  ENDDO
  QOUT('  </CONFIRMATIONS>')
  QOUT('  <ELEMENTS>')
  FOR i:=1 TO LEN(aDocState)
        QOUT('       <ITEM'+;
          ' GUID="'+aDocState[i,1]+'"'+;
          ' DocNumberPrefix="'+aDocState[i,2]+'"'+;
          ' DocNumber="'+aDocState[i,3]+'"'+;
          '/>')
  NEXT
  QOUT('  </ELEMENTS>')
  QOUT('  </DOCUMENT>')

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  11-24-15 * 02:37:46pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION cdbRoutes(nRun,dDate)
  LOCAL dRouteTime, i, m
  LOCAL cDocId

  dDate:=DATE()

  crtt('tempRtDt','f:kgp c:n(7) f:kpl c:n(7)  f:rtdt c:d(10) f:Comment c:c(64)')
  USE tempRtDt NEW EXCLUSIVE
  IF FILE('tempRtDt.cdx')
    ERASE ('tempRtDt.cdx')
  ENDIF
  INDEX ON rtdt TAG RtDt

  SELE TPoints
  DBGOTOP()
  WHILE (!EOF())
    IF EMPTY(RouteTime)
      DBSKIP()
      LOOP
    ENDIF
    FOR i:=1 TO 7
      IF !EMPTY(SUBSTR(RouteTime,i,1))
        dRouteTime:=LastMonday(dDate)+i-1
        FOR m:=0 TO 0 // 1-�� ��� ������ 0-����
          tempRtDt->(DBAPPEND())
          tempRtDt->Kpl:=TPoints->Kpl
          tempRtDt->Kgp:=TPoints->Kgp
          tempRtDt->rtdt:=dRouteTime+(7*m)
          tempRtDt->Comment:=""
        NEXT
      ENDIF
    NEXT
    DBSKIP()
  ENDDO


  SELE tempRtDt
  DBGOTOP()

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbDoc_Routes.txt

  IF !EMPTY(nRun)
    QQOUT('  <DOCUMENT GUID="43920FA1-745D-4499-84AF-7000672CEEFF" Comment="���㬥��.������" KILLALL="1">')
    QOUT('    <ELEMENTS>')
    cDocID:=uuid()
    QOUT('       <ITEM'+;
                    ;//GUID  GUID
                  ' GUID="'+cDocID+'"'+;
                    ;//DT  ��⠂६�
                  ' dt="'+cdbDTLM(DATE(),'00:00:00')+'"'+;
                    ;//IsDeleted ��᫮ - 1.0
                    ;//IsPost  ��᫮ - 1.0
                  ' IsPost="1"'+;
                    ;//DocNumber ��������㬥��  ��ப� 16
                  ' DocNumber="'+'���-� ������ �����'+'"'+;
                 '>')
    QOUT('         <TABLES>')
    //GUID ⠡��筮� ��� "��窨 �������" - ED832712-A167-4B9E-87F1-5127E6F70814
    QOUT('           <TABLE GUID="ED832712-A167-4B9E-87F1-5127E6F70814">')

    DBGOTOP()
    DO WHILE !EOF()
      QOUT('             <ITEM'+;
                      ;//GUID  GUID
                    ' GUID="'+UuID()+'"'+;
                      ;//DocID GUID
                    ' DocID="'+cDocID+'"'+;
                      ;//A01 ����ࠣ���  GUID
                    ' A01="'+GUID_KPK("C",ALLTRIM(STR(Kpl)))+'"'+;
                      ;//A02 ��࣮��窠 GUID
                    ' A02="'+GUID_KPK("C",ALLTRIM(STR(KGp)),ALLTRIM(STR(Kpl)))+'"'+;
                      ;//A03 �६� ��ப� - 16
                    ' A03="'+DTOC(rtdt)+'"'+;
                      ;//A04 ����������� ��ப� - 255
                    ' A04="'+LEFT(ALLTRIM(""), 255)+'"'+;
                      ;//A05 ���冷� ��᫮
                        '/>')

      DBSKIP()
    ENDDO
    QOUT('           </TABLE>')
    QOUT('         </TABLES>')
    QOUT('       </ITEM>')
    QOUT('    </ELEMENTS>')
    QOUT('  </DOCUMENT>')

  ENDIF
  CLOSE tempRtDt


  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  11-24-15 * 06:18:06pm
 ����������.........3.1.  �࣠����樨
 ��ࠢ�筨� "�࣠����樨" �।�����祭 ��� �࠭���� ���ଠ樨 �� �࣠�������,
  �� ����� ������ ��ଫ����� ���㬥���

 ������ 3 4 ���᮪ ��ਡ�⮢ �ࠢ�筨�� "����ࠣ����"

 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION cdbClients(nRun,aKop)
  LOCAL cCodeList, aClientsA08, aClient_KOP, cGuIdClient, cGuId_Base_KOP
  LOCAL cGuIdGrClient
  LOCAL aGuId_price:=PriceType2Kop('guid_price')


  aClientsA08:={}
  aClient_KOP:={}

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbClients.txt

  IF !EMPTY(nRun)

    QQOUT('<CATALOG GUID="9450980F-FB59-47E3-BAE2-AA3C58441B1A" KILLALL="1" Comment="����ࠣ����" >')
    QOUT('          <GROUPS>')
    QOUT('            <GROUP GUID="1E18C8DB-08F6-47DA-874B-100D6E109AB8" Comment="��㯯�">')
    QOUT('               <ELEMENTS>')
          cGuIdGrClient:="CBCF494A-55BC-11D9-848A-00112F43529A"
    QOUT('                  <ITEM GUID="'+cGuIdGrClient+'" IsDeleted="0" Name="����������" ParId=""/>')
    QOUT('               </ELEMENTS>')
    QOUT('            </GROUP>')
    QOUT('         </GROUPS>')
    QOUT('         <ELEMENTS Comment="�������� �ࠢ�筨��.����ࠣ����">')

    SELE tmp_kpl
    SET RELA TO STR(Kpl,7) INTO deb
    DBGOTOP()
    WHILE (!EOF())
      cGuIdClient:=GUID_KPK("C",ALLTRIM(STR(Kpl)))
      cCodeList:=""
      IF !EMPTY(CodeList)
        FOR i:=1 TO LEN(aKop) //-1
          //�஢�ਬ �宦����� � ࠧ�襭��� ��� � ��ப�
          //�஢�ਬ �㡫�
          IF PADL(LTRIM(STR(aKop[i,1],3,0)),3,"0")$CodeList .AND. ;
            !(PADL(LTRIM(STR(aKop[i,3],3,0)),2,"0")$cCodeList)
            IF EMPTY(cCodeList)
              cCodeList:=PADL(LTRIM(STR(aKop[i,3],3,0)),2,"0")
              cGuId_Base_KOP:=aKop[i,4]
            ELSE
              cCodeList+=","+PADL(LTRIM(STR(aKop[i,3],3,0)),2,"0")
            ENDIF
            AADD(aClient_KOP,{cGuIdClient,aKop[i,4]})
          ENDIF
        NEXT
      ENDIF
      //outlog(__FILE__,__LINE__,cCodeList)
      /*
      3.10 �������
      */
      // AADD(aClientsA08,{uuid(),cGuIdClient,NDog,dtDogB,dogPl})
      AADD(aClientsA08,{;
      GUID_KPK("D0",ALLTRIM(STR(Kpl))), cGuIdClient,NDog,dtDogB,dogPl})
      /*
      3.32 ���� �����
      3.33 ���� ����� �࣠����権


      */
      QOUT('  <ITEM'+;
            ;//GUID  GUID
                    ' GUID="'+cGuIdClient+'"'+;
            ;//IsDeleted ��᫮ - 1.0
            ;//Name ������������  ��ப� - 100
                    ' Name="'+LEFT(XmlCharTran(Npl), 100)+'"'+;
            ;//-A05 ������  ��᫮ - *.2
            ;//-A06 �����  GUID
                    ' A06="'+ClientStatus()+'"'+;
            ;//-A08 �᭮����������� GUID
                    ' A08="'+ATAIL(aClientsA08)[1]+'"'+;
            ;//-A09 ������� GUID
                    ' A09="'+aGuId_price[1]+'"'+;
            ;//A010 �����த�� ��᫮ - 1.0
            ;//A011 ��⥣���  GUID
            ;//-A012 ������������������ ��ப� - 255
                    ' A012="'+LEFT(XmlCharTran(Apl), 255)+'"'+;
            ;//-A013 ������ ��ப� - 22
                    ' A013="'+"!"+ALLTRIM(STR(OKPO, 22, 0))+'"'+;
            ;//-A014 �����멑��  ��ப� - 255
            ;//-A015 ���� ��᫮ - *.4
                    ' A015="'+ALLTRIM(STR(deb->DZ, 15, 2))+'"'+;
            ;//-A016 ������  ��ப� - 20
            ;//-A017 ���� ��ப� - 20
            ;//-A018 �ᯮ�짮���쏥�ᮭ���륖��� ��᫮ - 1.0
                    ' A018="'+'1'+'"'+;
            ;//-A019 ���������  GUID
                    ' A019="'+cGuId_Base_KOP+'"'+;
            ;//-A020 �࣠������  GUID
            ;//-A021 �����⬀�⮧��������� ��᫮ - 1.0
            ;//-�022 ���������  ��ப� - 10
                    ' A022="'+"$"+ALLTRIM(STR(OKPO, 10, 0))+'"'+;
            ;//-�023 �������਩  ��ப� - 255
                    ' A023="';
                    +'������� �'+LTRIM(STR(NDog))+' �� '+DTOC(dtDogB,'dd.mm.yy');
                    +' �ப �����. '+DTOC(dogPl,'dd.mm.yy'); // +LEFT(ALLTRIM(">7��:"+LTRIM(STR(deb->PDZ,10,2))+" >14��:"+LTRIM(STR(deb->PDZ1,10,2))+" >21��:"+LTRIM(STR(deb->PDZ3,10,2))), 255);
                    +'"'+;
            ;//-A024 ����㦥�늮�न����  ��᫮ - 1.0
            ;//-GrpID0 ��㯯� GUID
                    ' GrpID0="'+cGuIdGrClient+'"'+;
                        '/>')

      DBSKIP()
    ENDDO
    QOUT('        </ELEMENTS>')
    QOUT('      </CATALOG>')
    SELE tmp_kpl
    SET RELA TO

    //Comment="��ࠢ�筨�.�����늮��ࠣ��⮢"
    QOUT('  <CATALOG GUID="74046D94-B25D-4F3A-B553-27B7FDD3C60C" KILLALL="0" Comment="��ࠢ�筨�.�����늮��ࠣ��⮢">')
    QOUT('    <ELEMENTS>')
    QOUT('      <ITEM GUID="5BB4A902-C29F-11DC-96A3-0018F30B88B5" Name="������� ����祭��" A02="������� ����祭��" A03="250,130,250"/>')
    QOUT('      <ITEM GUID="5BB4A903-C29F-11DC-96A3-0018F30B88B5" Name="������� �����稢�����" A02="������� �����稢����� � 28 ����" A03="230,225,200"/>') //���
    QOUT('      <ITEM GUID="5BB4A904-C29F-11DC-96A3-0018F30B88B5" Name="���� ������" A02="�� ���� ������! ������ ��� �ᮡ�� ��������!" A03="0,231,0"/>')
    QOUT('      <ITEM GUID="5BB4A905-C29F-11DC-96A3-0018F30B88B5" Name="������ �������������" A02="� ������� ������ ������ �������������!" A03="255,188,0"/>')
    QOUT('      <ITEM GUID="5BB4A906-C29F-11DC-96A3-0018F30B88B5" Name="���쭮���" A02="���쭮��� ������" A03="0,108,155"/>')
    QOUT('      <ITEM GUID="50D75AAF-45D8-4542-A3AA-09B13A5B909D" Name="����� �த��" A02="��� ������� ������ ����饭� ��ଫ���� �த��!" A03="255,0,0"/>')
    QOUT('      <ITEM GUID="9B2C0187-0922-11E0-8764-6CF04917B338" Name="����让 ���" A02="" A03="128,128,0"/>')
    QOUT('      <ITEM GUID="E88D5533-7217-11DF-9314-8000600FE800" Name="����� ������" A02="�祭� ����� ������. ����� ��������!" A03="12,115,26"/>')
    QOUT('      <ITEM GUID="E88D5534-7217-11DF-9314-8000600FE800" Name="������ �����७⮢" A02="������ ࠡ�⠥� � �����७⠬�" A03="98,79,172"/>')
    QOUT('      <ITEM GUID="D54381E3-D965-11DC-B30B-0018F30B88B5" Name="����祭��� �����" A02="��� ������ ����稫 ������!" A03="240,17,211"/>')
    QOUT('    </ELEMENTS>')
    QOUT('  </CATALOG>')

    //Comment="��ࠢ�筨�.��⥣�ਨ����ࠣ��⮢"
    QOUT('  <CATALOG GUID="C75131A9-F98E-4443-B790-3ADA6137440B" KILLALL="0" Comment="��ࠢ�筨�.��⥣�ਨ����ࠣ��⮢">')
    QOUT('    <ELEMENTS>')
    QOUT('      <ITEM GUID="EA1ABCD6-0F34-11DF-A13A-001921430A4C" Name="��⥣��� VIP" A01=""/>')
    QOUT('      <ITEM GUID="12F17A17-8BFA-11DE-A11F-001921430A4C" Name="��⥣��� �" A01=""/>')
    QOUT('      <ITEM GUID="12F17A16-8BFA-11DE-A11F-001921430A4C" Name="��⥣��� �" A01=""/>')
    QOUT('      <ITEM GUID="51665E76-0F36-11DF-A13A-001921430A4C" Name="��⥣��� &quot;��⥭樠���&quot;" A01=""/>')
    QOUT('      <ITEM GUID="12F17A18-8BFA-11DE-A11F-001921430A4C" Name="��⥣��� �" A01=""/>')
    QOUT('      <ITEM GUID="AF5F45C9-9007-11DF-8D14-6CF04917B338" Name="���� �������" A01=""/>')
    QOUT('    </ELEMENTS>')
    QOUT('  </CATALOG>')

  ENDIF


  SET PRINT TO
  SET PRINT OFF


  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbDogovor.txt

  IF !EMPTY(LEN(aClientsA08))

    QQOUT('  <CATALOG GUID="735A9CE5-DCC1-4D1A-8F8D-643A50A6BEFC" KILLALL="1"  Comment="��ࠢ�筨�.�������늮��ࠣ��⮢">')
    QOUT('    <ELEMENTS>')
          //3.10. ��������
          //��ࠢ�筨� "��������" �।�����祭 ��� �࠭���� ���ଠ樨
          //� ��������, �����祭��� � ����ࠣ��⠬�
          //AADD(aClientsA08,{uuid(),cGuIdClient,NDog,dtDogB,dogPl})

          FOR i:=1 TO LEN(aClientsA08)
            QOUT('      <ITEM'+;
                        ;//GUID  GUID
                      ' GUID="'+aClientsA08[i,1]+'"'+;
            ;//IsDeleted ��᫮ - 1.0
            ;//Name        ������������  ��ப� - 50
                      ' Name="'+'������� ���⠢�� �'+LTRIM(STR(aClientsA08[i,3]))+'"'+;
            ;//A02 ����ࠣ���  GUID
                      ' A02="'+aClientsA08[i,2]+'"'+;
            ;//-A03 ��⠇����祭�� ��⠂६�
                      ' A03="'+cdbDTLM(aClientsA08[i,4],'00:00:00')+'"'+;
            ;//-A04  �ப����⢨�  ��⠂६�
                      ' A04="'+cdbDTLM(aClientsA08[i,5],'00:00:00')+'"'+;
            ;//A05 �࣠������ GUID
                      ' A05="'+GUID_KPK("C",ALLTRIM(STR(gnKkl_c)))+'"'+;
            ;//-A06 �������  GUID
            ;//A07 �ᯮ�짮���썄� ��᫮ - 1.0
            ;//-A08 ������ ��᫮ - *.2
            ;//-A09 ���������  GUID
            ;//-A010 ��࣮��窠  GUID
                 '/>')
          NEXT
    QOUT('    </ELEMENTS>')
    QOUT('  </CATALOG>')
    SET PRINT TO
    SET PRINT OFF
  ENDIF


  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbCodeList.txt
  IF !EMPTY(LEN(aClient_KOP))
    QQOUT('<CATALOG GUID="04977681-EBAF-4589-B6E7-93E883333DB7" KILLALL="1"  Comment="��ࠢ�筨�.���뎯���">')
    QOUT('   <ELEMENTS>')
          //FOR i:=LEN(aKop) TO 1 STEP -1
          FOR i:=1 TO LEN(aKop) STEP 1
            QOUT('      <ITEM'+;
              ;//GUID  GUID
                      ' GUID="'+aKop[i,4]+'"'+;
              ;//IsDeleted ��᫮ - 1.0
              ;//Name     ������������ ��ப� - 50
                      ' Name="'+aKop[i,2]+'"'+;
              ;//A01      ���넮�㬥�⮢ ��ப� - 255
                      ' A01="'+'�����,���������,���,���,�����⒮��஢,����㯫����'+'"'+;
                 '/>')
          NEXT
    QOUT('   </ELEMENTS>')
    QOUT('  </CATALOG>')

    QOUT('  <CATALOG GUID="1362EC92-F3F9-43AF-94CD-6937CEBA0AEE" KILLALL="1" Comment="��ࠢ�筨�.���뎯���࣠����権">')
    QOUT('   <ELEMENTS>')
          FOR i:=LEN(aClient_KOP) TO 1 STEP -1
            QOUT('      <ITEM'+;
            ;//GUID  GUID
            ' GUID="'+uuid()+'"'+;
            ;//IsDeleted ��᫮ - 1.0
            ;//A01 �࣠������ GUID
                      ' A01="'+aClient_KOP[i,1]+'"'+;
            ;//A02 ��������� GUID
                      ' A02="'+aClient_KOP[i,2]+'"'+;
                 '/>')
          NEXT
    QOUT('   </ELEMENTS>')
    QOUT('  </CATALOG>')


    SET PRINT TO
    SET PRINT OFF
  ENDIF

  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  11-26-15 * 06:20:04pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........   //"��ࠢ�筨�.�����늮��ࠣ��⮢"
 */
STATIC FUNCTION ClientStatus()
  LOCAL cGUID
  DO CASE
  CASE dogPl < DATE() // ����祭
    //, 2
    cGUID:="5BB4A902-C29F-11DC-96A3-0018F30B88B5"
  CASE dogPl <= DATE()+14+14
    //, 3
    cGUID:="5BB4A903-C29F-11DC-96A3-0018F30B88B5"
  CASE dtDogB >= DATE() .AND. dtDogB <= DATE()+14
    //, 4,
    cGUID:="5BB4A904-C29F-11DC-96A3-0018F30B88B5"
  OTHERWISE
    // ��稥 ������
    cGUID:=""
  ENDCASE

  RETURN (cGUID)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  12-03-15 * 10:11:11am
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION cdbTPoints(nRun)
  Local cNGp, nDD, nSDD
  SELE tmp_ktt
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbTPoints.txt

  IF !EMPTY(nRun)
    QQOUT('<CATALOG GUID="D3DBB02E-681E-4FC2-AD0E-8EF1234E9F48" KILLALL="1" Comment="��ࠢ�筨�.��࣮�륒�窨">')
    QOUT('   <ELEMENTS>')
    DBGOTOP()
    WHILE (!EOF())
      QOUT('      <ITEM'+;
        ;//GUID  GUID
           ' GUID="'+GUID_KPK("C",ALLTRIM(STR(KGp)),ALLTRIM(STR(Kpl)))+'"'+;
        ;//IsDeleted ��᫮ - 1.0Name
        ;//������������  ��ப� - 150
            ' Name="'+LEFT(XmlCharTran(iif(empty(gpslon),'~','')+ NGp), 150)+'"'+;
        ;//A02����ࠣ��� GUID
        IIF(;
        EMPTY(RouteTime),;
        '',;
        ' A02="'+GUID_KPK("C",ALLTRIM(STR(Kpl)))+'"';
      )+;
        ;//A05��⥣���  GUID
        ;//A06���  GUID
            ' A06="'+GUID_KPK("CA1",ALLTRIM(STR(kgpcat)))+'"'+;
        ;//A07�������਩  ��ப� - 250
            ' A07="'+LEFT(XmlCharTran(AGp)+" ⥫."+XmlCharTran(TelGp), 250)+'"'+;
        ;//-A08�������  GUID
        ;//-A09������  ��ப� - 20
            ' A09="'+ alltrim(gpslon)+'"'+;
        ;//-A010����  ��ப� - 20
            ' A10="'+ alltrim(gpslat)+'"'+;
        ;//-A011�ᯮ�짮���쏥�ᮭ���륖���  ��᫮ - 1.0
             ' A011="'+'1'+'"'+;
        ;//-A012������  ��᫮ - *.2
        ;//-A013�����⬀�⮧���������  ��᫮ - 1.0
               '/>')
     /*
      qout(                               ;
          ;//Addr
            LEFT(ALLTRIM(AGp), 64)+_T+ ;
          ;//=Tel
            LEFT(ALLTRIM(TelGp), 50)+_T+ ;
          ;//=Contact
            ;//LEFT(ALLTRIM("���⠪�� ���"), 128)+_T+        ;
            LEFT(ALLTRIM(DTOC(dnl,"DD.MM.YY")+"-"+DTOC(dol,"DD.MM.YYYY")+" "+alltrim(serlic)+ltrim(str(numlic))), 128)+_T+        ;
        )*/
      DBSKIP()
    ENDDO

    QOUT('  </ELEMENTS>')
    QOUT(' </CATALOG>')

    QOUT('  <CATALOG GUID="EDB6B6C0-922F-42D2-8868-CBEB347D8C74" KILLALL="0" Comment="��ࠢ�筨�.���뒮࣮��咮祪">')
    QOUT('    <ELEMENTS>')
      SELE kgpcat
      DBGOTOP()
      DO WHILE !EOF()
        QOUT('      <ITEM'+;
          ;//GUID  GUID
             ' GUID="'+GUID_KPK("CA1",ALLTRIM(STR(kgpcat)))+'"'+;
          ;//������������  ��ப� -
              ' Name="'+LEFT(XmlCharTran(ALLTRIM(nkgpcat)), 50)+'"'+;
               '/>')
        DBSKIP()
      ENDDO
    QOUT('    </ELEMENTS>')
    QOUT('  </CATALOG>')
  ENDIF




  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  12-03-15 * 04:12:41pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION cdbPrice(nRun,aPrice)
  LOCAL MKeepr,i
  LOCAL nGUID_Mkeep, nKg, nGUID_Kg
  LOCAL aDicEi, cGuId_MNTOVT

  aDicEi:={}

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbPrice.txt

  IF !EMPTY(nRun)
    QQOUT('     <CATALOG GUID="D6D52ADA-0F38-4112-AF3C-2F1E425A43D1" KILLALL="1" Comment="��ࠢ�筨�.�����������">')

    QOUT('       <GROUPS>')

    QOUT('         <GROUP GUID="8E502A85-8DD4-41CF-A7A4-17AB50872D36" KILLALL="1" Comment="�������� ��㯯�஢�� �� ����娨">')
    QOUT('           <ELEMENTS>')
    SELE price
    //  ORDSETFOCUS("Nat")
    ORDSETFOCUS("mnkeep")
    DBGOTOP()
    DO WHILE !EOF()
      If !(gnEnt = 21)
        IF MNTOV < 10^6
          DBSKIP()
          LOOP
        ENDIF
      EndIf

      //�뢮� ��ઠ��ঠ⥫�
      MKeepr:=MKeep
      nGUID_Mkeep:=111111+mkeep
      QOUT('             <ITEM'+;
          ' GUID="'+GUID_KPK("A", LTRIM(STR(nGUID_Mkeep)))+'"'+;
          ' Name="'+XmlCharTran(nmkeep)+'"'+;
          ' ParId="'+''+'"'+;
      '/>')

      DO WHILE MKeepr = MKeep
        kg_r:=INT(MNTOV/10^4)
        ng_r:=getfield('t1',"kg_r","cgrp","ngr")//�������� ��㯯�

        //�뢮� ��ઠ��ঠ⥫� + ��㯯�      0.89  -> 89

        nGUID_Kg:=nGUID_MKeep + VAL(SUBSTR(LTRIM(STR(RAND(kg_r),18,15)),3,6))
        //222222+kg_r //+ROUND(RAND(kg_r)*100,0)
                //outlog(__FILE__,__LINE__,nGUID_MKeep,kg_r, nGUID_Kg,VAL(SUBSTR(LTRIM(STR(RAND(nGUID_Kg),18,15)),3,6)))
        //nGUID_Kg:=VAL(SUBSTR(LTRIM(STR(RAND(nGUID_Kg),18,15)),3,6))

        QOUT('             <ITEM'+;
            ' GUID="'+GUID_KPK("A", LTRIM(STR(nGUID_Kg)))+'"'+;
            ' Name="'+XmlCharTran(ng_r)+'"'+;
            ' ParId="'+GUID_KPK("A", LTRIM(STR(nGUID_Mkeep)))+'"'+;
        '/>')

        DO WHILE kg_r = INT(MNTOV/10^4) .AND. MKeepr = MKeep
          DBSKIP()
        ENDDO
      ENDDO

    ENDDO
  QOUT('           </ELEMENTS>')
  QOUT('         </GROUP>')

  QOUT('         <GROUP GUID="E42DA5B9-E29B-43E1-B7E3-9B500879D6B7" KILLALL="1" Comment="�������� ��㯯�஢�� �� ��⥣���">')
  QOUT('           <ELEMENTS>')
  QOUT('             <ITEM GUID="A8EBEAC9-5818-11D9-A2C3-00055D80A2D1" Name="�த���� ��⠭��" ParId=""/>')
  QOUT('           </ELEMENTS>')
  QOUT('         </GROUP>')

  QOUT('       </GROUPS>')

  QOUT('       <ELEMENTS Comment="�������� �ࠢ�筨�� �����������">')
    i:=0
  SELE price
  ORDSETFOCUS("Nat")
  DBGOTOP()
  DO WHILE !EOF()

    If !(gnEnt = 21)
      IF MNTOV < 10^6
        DBSKIP()
        LOOP
      ENDIF
    EndIf

      //�뢮� ��ઠ��ঠ⥫�
      MKeepr:=MKeep
      nGUID_Mkeep:=111111+mkeep

      kg_r:=INT(MNTOV/10^4)
      ng_r:=getfield('t1',"kg_r","cgrp","ngr")//�������� ��㯯�
      //�뢮� ��ઠ��ঠ⥫� + ��㯯�        0.0000000
        nGUID_Kg:=nGUID_MKeep + VAL(SUBSTR(LTRIM(STR(RAND(kg_r),18,15)),3,6))
      // +222222 + kg_r //+ROUND(RAND(kg_r)*100,0)
      // nGUID_Kg:=VAL(SUBSTR(LTRIM(STR(RAND(nGUID_Kg),18,15)),3,6))

      //�� ���.
      cGuId_MNTOVT:=GUID_KPK("A",ALLTRIM(STR(MNTOVT)))
      cGuId_Ei2_MNTOV:=GUID_KPK("A",ALLTRIM(STR(MNTOVT)),ALLTRIM(STR(778)))
      cGuId_Ei1_MNTOV:=GUID_KPK("A",ALLTRIM(STR(MNTOVT)),ALLTRIM(STR(796)))
      AADD(aDicEi,{cGuId_Ei2_MNTOV,          "�",Upak,cGuId_MNTOVT,NIL})
      AADD(aDicEi,{cGuId_Ei1_MNTOV,ALLTRIM(NEi),   1,cGuId_MNTOVT,Ves})

       QOUT('     <ITEM '+;
        ;//GUID  GUID
                ' GUID="'+cGuId_MNTOVT+'"'+;
        ;//-IsDeleted ��᫮ - 1.0
        ;//-Code ���  ��ப� - 20
                ' Code="'+LEFT(ALLTRIM(STR(MNTOVT)),20)+'"'+;
        ;//Name ������������ ��ப� - 200
                ' Name="'+LEFT(XmlCharTran(Nat), 200)+'"'+;
        ;//A04  �⠢�����  ��᫮ - 3.2
                ' A04="'+ALLTRIM(STR(20, 12, 2))+'"'+;
        ;//A06  ���������� GUID
                ' A06="'+ATAIL(aDicEi)[1]+'"'+;
        ;//A08 ��⏮��ࠪ���⨪�� ��᫮ - 1.0
        ;//A010 ��������멎��⮪ ��᫮ - *.3
        ;//A011 ���⮪  ��᫮ - *.3
                ' A011="'+ALLTRIM(STR(OsV, 15, 4))+'"'+;
        ;//A013 �����栕࠭������⪮�  GUID
                ' A013="'+ATAIL(aDicEi)[1]+'"'+;
        ;//A014 ��ᮢ��  ��᫮ - 1.0
                ' A014="'+ALLTRIM(STR(iif("��" $ lower(NEi),1,0), 1, 0))+'"'+;
        ;//A015 ��㣠 ��᫮ - 1.0
        ;//A020 ����0  ��᫮ - *.4
                ' A020="'+ALLTRIM(STR(FIELDGET(FIELDPOS(aPrice[1])), 12, 2)) +'"'+;
        ;//A021 ����1  ��᫮ - *.4
        ;//A022 ����2  ��᫮ - *.4
        ;//A023 ����3  ��᫮ - *.4
        ;//A024 ����4  ��᫮ - *.4
        ;//A025 ����5  ��᫮ - *.4
        ;//A026 ����6  ��᫮ - *.4
        ;//A027 ����7  ��᫮ - *.4
        ;//A028 ����8  ��᫮ - *.4
        ;//A029 ����9  ��᫮ - *.4
        ;//A030 ���⮪0 ��᫮ - *.4
        ;//A031 ���⮪1 ��᫮ - *.4
        ;//A032 ���⮪2 ��᫮ - *.4
        ;//A033 ���⮪3 ��᫮ - *.4
        ;//A034 ���⮪4 ��᫮ - *.4
        ;//�035 ������������������ ��ப� - 255
                ' �035="'+LEFT(XmlCharTran(Nat), 255)+'"'+;
        ;//�036 ��࠭�祭��������  ��᫮ - *.2
        ;//A037 ������⪨  ��᫮ - 1.0
        ;//A038 ����  ��᫮ - 1.0
        ;//A039 �����栎��㧪�  GUID
                ' A039="'+ATAIL(aDicEi)[1]+'"'+;
        ;//A040 �������쭠��  ��᫮ - *.4
        ;//A041 ���⮪������� ��᫮ - *.4
        ;//A042 ���஡������ᠭ��  ��ப� - 255
                ' �042="'+LEFT(ALLTRIM(IIF(Merch=2,'Merch','')), 255)+'"'+;
        ;//A043 �᭮����⨭�� GUID
        ;//A044 ���冷����������㧪�  ��᫮ - *.0
        ;//A045 �������� ��᫮ - 1.0
        ;//A046 ��⠐������  ��⠂६�
        ;//A048 ��������㯯�  ��ப� - 36
        ;//A049 ��������멇���� ��᫮ - *.4
        ;//A050 �����栖���  GUID
                ' A050="'+ATAIL(aDicEi)[1]+'"'+;
        ;//A051 �����栏���  GUID
        ;//�052 ������⪨������� ��᫮ - 0 1 2
        ;//�053 ��㯯������戧��७��  GUID
        ;//GrpID0 ��㯯� GUID
           ' GrpID0="'+GUID_KPK("A", LTRIM(STR(nGUID_Kg)))+'"'+;
        ;//GrpID1 ��⥣���  GUID
           ' GrpID1="'+'A8EBEAC9-5818-11D9-A2C3-00055D80A2D1'+'"'+;
       '>')
            /*
              <TABLES>
                <TABLE GUID="AF0A6972-4BCA-4652-A3CF-8EBC1ED1EE0D" Comment="�����筠� ���� '���⪨'">
                  <ITEM GUID="00B4790F-51B7-4BBD-B48C-5494993A67B8" CtlgId="5CA073EB-8661-11DA-9AEA-000D884F5D77" A06="1" A01="0" A02="0"/>
                </TABLE>
              </TABLES>
            */
       QOUT('     </ITEM>')

     DBSKIP()

  ENDDO
  qout('    </ELEMENTS>')

  qout('  </CATALOG>')

  QOUT('  <CATALOG GUID="80452C60-B442-4DA9-A048-42F63270CA14" KILLALL="1" Comment="��ࠢ�筨�.���녤���戬�७��">')
  QOUT('   <ELEMENTS>')
        FOR i:=1 TO LEN(aDicEi)
      //AADD(aDicEi,{uuid(),ALLTRIM(NEi),   1,cGuId_MNTOVT, Ves})
          QOUT('      <ITEM'+;
          ;//GUID  GUID
            ' GUID="'+aDicEi[i,1]+'"'+;
          ;//IsDeleted ��᫮ - 1.0
          ;//Name ������������ ��ப� - 50
            ' Name="'+LEFT(ALLTRIM(aDicEi[i,2]), 50)+'"'+;
          ;//A02  �����樥��  ��᫮ - *.3
            ' A02="'+ALLTRIM(STR(aDicEi[i,3], 12,0))+'"'+;
          ;//A03  ����������� GUID
            ' A03="'+aDicEi[i,4]+'"'+;
          ;//A04  ���  ��᫮ - *.3
            ' A04="'+IIF(aDicEi[i,5]=NIL,'',ALLTRIM(STR(aDicEi[i,5], 12,3)))+'"'+;
          ;//�05  �⮃�㯯�  ��᫮ - 1.0
          ;//�06  ����⥫� GUID
          ;//�07  �����䨪���  ��ப� - 36
               '/>')
        NEXT
  QOUT('   </ELEMENTS>')
  QOUT('  </CATALOG>')

  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  03-22-16 * 04:02:14pm
 ����������......... ���������� ���⪮�
 ���������..........
 �����. ��������....
 ����������.........
 */
STATIC FUNCTION CdbGoodsStock(nRun)
  LOCAL cGuId_MNTOVT


  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbPrice.txt

  IF !EMPTY(nRun)
    //!!KILLALL="0"
    QQOUT('     <CATALOG GUID="D6D52ADA-0F38-4112-AF3C-2F1E425A43D1" KILLALL="0" Comment="��ࠢ�筨�.�����������">')

    QOUT('       <ELEMENTS Comment="�������� �ࠢ�筨�� �����������">')
      i:=0
    SELE price
    ORDSETFOCUS("Nat")
    DBGOTOP()
    DO WHILE !EOF()

      If !(gnEnt = 21)
        IF MNTOV < 10^6
          DBSKIP()
          LOOP
        ENDIF
      EndIf
      cGuId_MNTOVT:=GUID_KPK("A",ALLTRIM(STR(MNTOVT)))

        QOUT('     <ITEM '+;
        ;//GUID  GUID
                ' GUID="'+cGuId_MNTOVT+'"'+;
        ;//A011 ���⮪  ��᫮ - *.3
                ' A011="'+ALLTRIM(STR(OsV, 15, 4))+'"'+;
        '>')
        QOUT('     </ITEM>')

      DBSKIP()

  ENDDO
  qout('    </ELEMENTS>')

  qout('  </CATALOG>')

  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  12-08-15 * 02:10:56pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION cdbPersonalDiscount(nRun)
  LOCAL cGuId_MNTOVT
  SELE PersonalPrice

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbPersDisc.txt

  IF !EMPTY(nRun)

    QQOUT('  <CATALOG GUID="12CF8990-D7D7-4CFA-9CCD-AD4CCB5EE9E6" KILLALL="1" Comment="��ࠢ�筨�.���ᮭ���� ᪨���">')
    QOUT('   <ELEMENTS>')

    DBGOTOP()
    DO WHILE !EOF()
      cGuId_MNTOVT:=GUID_KPK("A",ALLTRIM(STR(MNTOVT)))
          QOUT('      <ITEM'+;
            ;//GUID  GUID
          ' GUID="'+uuid()+'"'+;
            ;//IsDeleted ��᫮ - 1.0
            ;//A01 ����ꥪ� GUID
                ' A01="'+GUID_KPK("C",ALLTRIM(STR(kpl)))+'"'+;
            ;//A02 �������  GUID
                ' A02="'+cGuId_MNTOVT+'"'+;
            ;//A03 ������  ��᫮ - *.4
                ' A03="'+ALLTRIM(STR(Discount, 15, 4))+'"'+;
            ;//A04 ����厡ꥪ⮢ ��᫮ - 1.0
               '/>')

      DBSKIP()
    ENDDO

    QOUT('   </ELEMENTS>')
    QOUT('  </CATALOG>')

  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  11-21-15 * 01:33:22pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION cdbDTLM(dDate,cTime)
  LOCAL cDTLM
  #ifdef __CLIP__
    cDTLM:=DTOC(dDate,"yyyy-mm-dd")+'T'+cTime
  #endif
  RETURN (cDTLM)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  11-21-15 * 02:29:29pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION cdbCategory()
  LOCAL  i
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbCategory.txt
  QQOUT('<CATALOG GUID="F997F837-8721-4896-8FE8-3497C6C38206" KILLALL="0" Comment="��ࠢ�筨�.��⥣���㬥�⮢">')
     QOUT('  <ELEMENTS>')

          aCateg:={;
          {'255000000','����'},; //GUID_KPK("�0",'255000000')
          NIL;
          }

          FOR i:=1 TO LEN(aCateg)-1
            QOUT('    <ITEM '+;
            ' GUID="'+GUID_KPK("C0",aCateg[i,1])+'"'+;
                ;//������������
            ' Name="'+aCateg[i,2]+'"'+;
                ;//梥�
            ' A02="'+TRANSFORM(aCateg[i,1],"@R 999,999,999")+'"'+;
                ;//���� �-⮢
            ' A03="'+'�����,����,���,���祭�������,���饭��,���������,��६�饭��,����㯫����,�������'+'"'+;  // ��ઠ �-��
            '/>')
          NEXT

    QOUT('  </ELEMENTS>')
    QOUT('</CATALOG>')

    QOUT('<CATALOG GUID="E4623B4E-2F19-47AB-B158-EE0E021D3911" KILLALL="1" Comment="��ࠢ�筨�.���넮�⠢��">')
    QOUT('  <ELEMENTS>')
    QOUT('    <ITEM GUID="84D92255-6C8A-496D-8793-9EC28A04E33F" Code="1" Name="�������� ���⠢��"/>')
    QOUT('    <ITEM GUID="0473367A-03C0-46B7-A7D3-23E08A314066" Code="2" Name="�����뢮�"/>')
    //QOUT('    <ITEM GUID="CB88674C-7A2A-4792-8A4E-97C55395BE91" Name="��� ���⠢��"/>')
    //QOUT('    <ITEM GUID="A6E5F825-AA13-4117-9754-B5FA4278FC32" Name="���⭠� ���⠢��"/>')
    //QOUT('    <ITEM GUID="7F95F9A4-41CD-45A5-B03C-0503EDB8487D" Name="�᫮��� ��ᯫ�⭠� ���⠢��"/>')
    QOUT('  </ELEMENTS>')
    QOUT('</CATALOG>')

    QOUT('<CATALOG GUID="564E0ECA-C498-4D28-83D7-4BDEAEC558E2" Comment="��ࠢ�筨�.���늮�⠪⭮����ଠ樨" KILLALL="0">')
    QOUT('  <ELEMENTS>')
    QOUT('    <ITEM GUID="968558FF-8FE0-40D0-84E3-CA694ACBC839" Name="����䮭 ��.���" A02="8FC8F351-14F0-48EB-952A-38BB313B28D5" A03="����ࠣ����"/>')
    QOUT('    <ITEM GUID="87D961A6-9E2F-405C-855E-215869755D34" Name="�ਤ��᪨� ���� ��.���" A02="A4D0F540-64ED-4F3E-B2BB-818DA38F5AB2" A03="����ࠣ����"/>')
    QOUT('    <ITEM GUID="4E1FCD79-FFE7-42C0-8944-2FA878EA7246" Name="���� ���஭��� ����� ����ࠣ��� ��� ������ ���஭�묨 ���㬥�⠬�" A02="52477200-AF54-405B-9888-14B8BDED0E19" A03="����ࠣ����"/>')
    QOUT('    <ITEM GUID="663DE54A-DA59-44A4-9BD0-7509DFA63856" Name="�����᪨� ���� ��.���" A02="A4D0F540-64ED-4F3E-B2BB-818DA38F5AB2" A03="����ࠣ����"/>')
    QOUT('    <ITEM GUID="17CBA4A2-5872-420A-A3E3-C01B4186F873" Name="���� ����ࠣ���" A02="8FC8F351-14F0-48EB-952A-38BB313B28D5" A03="����ࠣ����"/>')
    QOUT('    <ITEM GUID="EB76D981-09C1-4968-B969-67D016F86B83" Name="���� ���⠢��" A02="A4D0F540-64ED-4F3E-B2BB-818DA38F5AB2" A03="����ࠣ����"/>')
    QOUT('    <ITEM GUID="0B82B2C7-BEDA-448C-9F17-6652E106471A" Name="������� ⥫�䮭 ���⠪⭮�� ��� ����ࠣ���" A02="8FC8F351-14F0-48EB-952A-38BB313B28D5" A03="���⠪�륋��"/>')
    QOUT('    <ITEM GUID="EEFB301E-97D3-4197-A472-816B951FB280" Name="���� ���஭��� ����� ���⠪⭮�� ��� ����ࠣ���" A02="52477200-AF54-405B-9888-14B8BDED0E19" A03="���⠪�륋��"/>')
    QOUT('    <ITEM GUID="CE482D50-E425-4A87-BF1E-21E55285DC32" Name="����稩 ⥫�䮭 ���⠪⭮�� ��� ����ࠣ���" A02="8FC8F351-14F0-48EB-952A-38BB313B28D5" A03="���⠪�륋��"/>')
    QOUT('  </ELEMENTS>')
    QOUT('</CATALOG>')

    QOUT('<CATALOG GUID="00F1FFE7-E16E-4FF4-9EF1-B8D0C54BDF59" Comment="��ࠢ�筨�.���떥�">')
    QOUT('  <ELEMENTS>')
      aNn_price:=PriceType2Kop('Nm_price')
      aGuId_price:=PriceType2Kop('guid_price')
      FOR i:=1 TO 1
          QOUT('    <ITEM'+;
          ' GUID="'+aGuId_price[i]+'"'+;
          ' Name="'+aNn_price[i]+'"'+;
          ' Code="'+ALLTRIM(STR(i-1))+'"'+;
          ' A02="1"'+;
          '/>')
      NEXT
    QOUT('  </ELEMENTS>')
    QOUT('</CATALOG>')


    QOUT('<CATALOG GUID="2516FFCE-F46F-4326-BE00-438EF0871D30" Comment="��ࠢ�筨�.������">')
    QOUT('  <ELEMENTS>')
    QOUT('    <ITEM GUID="BD72D91F-55BC-11D9-848A-00112F43529A" Name="������ ᪫��" Code="0"/>')
    /*
    QOUT('    <ITEM GUID="CBCF4956-55BC-11D9-848A-00112F43529A" Name="����� ����⮢�஢" Code="1"/>
    QOUT('    <ITEM GUID="1DE4815D-FD36-11DB-A40E-00055D80A2D1" Name="������� �1" Code="2"/>
    QOUT('    <ITEM GUID="1DE4815E-FD36-11DB-A40E-00055D80A2D1" Name="������� �2" Code="3"/>
    QOUT('    <ITEM GUID="1DE4815F-FD36-11DB-A40E-00055D80A2D1" Name="��࣮�� ��� (���)" Code="4"/>
    QOUT('    <ITEM GUID="49F16893-6380-11E0-A8CB-00004917B338" Name="�த�⮢� ᪫��" Code="5"/>')
    QOUT('    <ITEM GUID="D54381E5-D965-11DC-B30B-0018F30B88B5" Name="��⮬����� ���㧨� 402" Code="6" A02="CBCF493B-55BC-11D9-848A-00112F43529A"/>')
    */
    QOUT('  </ELEMENTS>')
    QOUT('</CATALOG>')

    QOUT('<CATALOG GUID="1941E3E0-EEEF-43D2-A986-4A97000079B0" Comment="��ࠢ�筨�.�������" KILLALL="1">')
    QOUT('   <ELEMENTS>')
    QOUT('    <ITEM GUID="B69D62A5-B856-11E5-82AD-BC5FF4E8425E" Name="DeleteAllDocuments" A01="������⢮����:7;���᮪���㬥�⮢:�����,���祭�������,���,���;" A02="1" A03="12"/>')
    QOUT('   </ELEMENTS>')
    QOUT('  </CATALOG>')



  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  11-26-15 * 11:32:54am
 ����������.........  3.1.  �࣠����樨
  GUID �ࠢ�筨�� - 0E3CBAEA-5467-45CD-8C86-FB1777DA435B.
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION cdbFirms(nRun)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbFirms.txt
  IF !EMPTY(nRun)
    kln->(netseek("t1","gnKkl_c"))

    QQOUT('<CATALOG GUID="0E3CBAEA-5467-45CD-8C86-FB1777DA435B" KILLALL="1" Comment="��ࠢ�筨�.�࣠����樨" >')
    QOUT('  <ELEMENTS>')
    QOUT('     <ITEM '+;
                ;//GUID  GUID
              ' GUID="'+GUID_KPK("C",ALLTRIM(STR(gnKkl_c)))+'"'+;
                ;//IsDeleted ��᫮ - 1.0
                ;//Name ������������ ��ப� - 150
              ' Name="'+LEFT(XmlCharTran(kln->NKLE),150)+'"'+;
                ;//A02  �ᯮ�짮���썄�  ��᫮ - 1.0
              ' A02="'+'0'+'"'+;
                ;//-A03  ������  ��ப� - 250
                ;//-A04  ����䮭  ��ப� - 150
              ' A04="'+ LEFT(ALLTRIM(kln->TLF),250)+'"'+;
                ;//A05  ���  ��ப� - 20
              ' A05="'+'0056123412'+'"'+;
                ;//A06  ���  ��ப� - 20
              ' A06="'+'0056123412'+'"'+;
                ;//A07  ���� ��ப� - 20
              ' A07="'+'0056123412'+'"'+;
                ;//-A08  �������਩  ��ப� - 250
                ;//-A09  ���․��  ��ப� - 250
              ' A09="'+LEFT(ALLTRIM(kln->ADR),250)+'"'+;
                ;//-A010 ��䨪�  ��ப� - 3
                ;//-A011 ���������������� ��ப� - 255
                ;//-A012 �������� ��ப� - 20
                ;//-A013 ������� ��ப� - 20
                ;//-A014 �㪮����⥫� ��ப� - 150
                ;//-A015 ��壠���  ��ப� - 150
                ;//-A016 ���  �⮪� - 9
                ;//-A017 ������������������ ��ப� - 255
              ' A17="'+LEFT(XmlCharTran(kln->NKL),255)+'"'+;
                ;//A018 �ᯮ�짮�����⠔������ ��᫮ - 1.0
              ' A018="'+'0'+'"'+;
                ;//-�019 ���������  ��ப� - 10
             '/>')
    QOUT('  </ELEMENTS>')
    QOUT('</CATALOG>')

    QOUT('<CATALOG GUID="CC458719-5078-4DC8-9A0C-FA19E3904F39" Comment="��ࠢ�筨�.������">')
    QOUT('  <ELEMENTS>')
    QOUT('    <ITEM GUID="4D7EA2A2-C2A1-11DC-96A3-0018F30B88B5" Name="�������� ���⪨" Code="4"/>')
    QOUT('    <ITEM GUID="4D7EA2A1-C2A1-11DC-96A3-0018F30B88B5" Name="�������� ��������" Code="3"/>')
    QOUT('    <ITEM GUID="4DBB8283-C2AD-11DD-926C-001FC6A1D79B" Name="�������� ��" Code="5"/>')
    QOUT('    <ITEM GUID="4D7EA2A0-C2A1-11DC-96A3-0018F30B88B5" Name="�������� ����� �த��" Code="2"/>')
    QOUT('    <ITEM GUID="4D7EA29F-C2A1-11DC-96A3-0018F30B88B5" Name="�������� �����������" Code="1"/>')
    QOUT('  </ELEMENTS>')
    QOUT('</CATALOG>')
  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)


