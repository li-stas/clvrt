#include "common.ch"
#include "set.ch"
#include "inkey.ch"

#define OB_IN_VATCALCMOD  0
/*
0 - VatCalcMod=0, Price - ���_���
1 - VatCalcMod=1, Price - �_���
2 - VatCalcMod=1, Price - ���_���
*/
#define OB_OUT_VATCALCMOD 0
#define OB_LIST_BRAK_S '262;263' // ᪫��� �ࠪ� ���
#define OB_LIST_BRAK_K '704;705' // ᪫��� �ࠪ� ����⮯
#define OB_LIST_SIDR '3400249 3400248 3400243' // ���� ᨤ�

  STATIC aMessErr


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  03-16-14 * 09:48:18am
 ����������.........
 ���������..........
 1 cDosParam
 2 dDt ���
 3  cSend
 4   aFileListZip
 5    lNo_deb - �� �����뢠�� �-��
 6     lNo_executed_order - ��������� "�� �믮����� ������"
 �����. ��������....
 ����������.........
 */
FUNCTION pilot2_obolon(cDosParam, dDt, cSend, aFileListZip, lNo_deb, lNo_executed_order)
  LOCAL cMkeep, aKta
  LOCAL lTmp_kpl:=.F. //�ࠢ�筨� ���� � �� �� ���㧪�(.T.) ��� ��騩 �� ��઄��.
  LOCAL aFlDir, aStruDbf, cFile, nPos, nRec
  LOCAL i, lZap, cCOX_Sl_list, cListSaleSk, aMessErr
  LOCAL nSdp_Deb, nSdp_SkDoc
  LOCAL nSumKop211p:=0,  nSumKop211n:=0
  LOCAL nQKop211p:=0,  nQKop211n:=0
  LOCAL lJoin, nNmOst
  LOCAL cRunUnZip:="/usr/bin/unzip"


  DEFAULT cSend TO "One"; //dDt TO date()
  , lNo_deb TO .f. ; // f - �����
  , lNo_executed_order TO NO

  cPath_Pilot:=gcPath_ew+"obolon\cus2swe"  //"j:\lodis\obolon\cus2swe"
  cPth_Plt_tmp:=gcPath_ew+"obolon\cus2swe.tmp" //cPath_Pilot+"\tmp"
  cPth_Plt_lpos=gcPath_ew+'arnd'

  outlog(__FILE__,__LINE__,procname(1),procline(1), cDosParam, dDt, cSend, aFileListZip, lNo_deb, lNo_executed_order)


  IF (UPPER("/no_zap") $ UPPER(cDosParam))
    lZap:=NO
  ELSE
    lZap:=YES
  ENDIF

  IF (UPPER("LPOS") $ UPPER(cDosParam))
    lPos:=YES
  ELSE
    lPos:=NO
  ENDIF

  cMkeep:="027"
  cCOX_Sl_list:="??? ???"
  //cListSaleSk:="232 700  1  2 237 238"
  cListSaleSk:="232 700 237 238 702 703 "+OB_LIST_BRAK_S+' '+OB_LIST_BRAK_K

  aMessErr:={}
      AADD(aMessErr, CHR(10)+CHR(13))
  if .T.
    dtBegr:=dtEndr:=DATE()

    IF (UPPER("/get-date") $ UPPER(cDosParam))

      lJoin:=(UPPER("/join") $ UPPER(DosParam()))

      clvrt_get_date(@dtBegr,@dtEndr,;
      "�����⮢�� ���� ������� ������ �� ��ਮ�.",;
      "��� 䠩�� ��娢� ol_<���1>-<���2>.zip",;
      {|a1,a2| a1<=a2 .and. BOM(a1)=BOM(a2) };
    )


      IF LASTKEY()=13
        set device to print
        set print to clvrt.log ADDI

        gdTd:=BOM(dtBegr)
        If lJoin
          JoinMkDt(027,dtBegr, dtEndr)
          RETURN
        EndIf

      ELSE
        RETURN
      ENDIF
    ELSE

      IF UPPER("/FlMn") $ cDosParam
        gdTd:=BOM(DATE())
        dtBegr:=BOM(DATE())
        dtEndr:=EOM(DATE())
      ENDIF

      IF UPPER("/dtBeg") $ cDosParam ;
        .OR. UPPER("/FlMn") $ cDosParam

        Dt_Beg_End(cDosParam,.T.,@dtBegr,@dtEndr)

        /// ������ ������ � 横��
        IF !(UPPER("/no_mkotch") $ UPPER(cDosParam))
          FOR dMkDt:=dtBegr TO dtEndr
            Do Case
            Case dMkDt=BOM(dMkDt)
              // 0 - �� ��� ��� ���
              // 1 - ���⮪ 䠪� OSN ����� �믨ᠭ�� (��� ����)
              // 2 - �� ��� ��� ��� � ���� ��� kop=211
              // 3 - ??? ���⮪ 䠪� OSN
              nNmOst:=2
              If UPPER("/OsFoN") $ cDosParam
                nNmOst:=kta_DosParam(cDosParam,'/OsFoN=',1,{2,{0,1,2}})
              EndIf

              mkotchd(dMkDt,027, nNmOst, lNo_executed_order)

            OtherWise
              // 0 - �� ��� ��� ���
              // 2 - �� ��� ��� ��� � ���� ��� kop=211
              nNmOst:=2
              If UPPER("/OsTD") $ cDosParam
                nNmOst:=kta_DosParam(cDosParam,'/OsTD=',1,{0,{0,2}})
              EndIf

              mkotchd(dMkDt, 027, nNmOst, lNo_executed_order)

            EndCase
            If !(lNo_deb)
              deb(361001, dMkDt)
              debn03(361002 ,dMkDt)
            ENDIF
          NEXT
          // ����� �����
          set print to clvrt.log ADDI
          ?"Stop clvrt", date(), time()
          quit
        ENDIF

      ELSE

        IF !EMPTY(dDt)
          dtEndr:=dDt
        ELSE
          IF (UPPER("/online") $ UPPER(cDosParam))
            dtEndr:=date()
          ELSE
            dtEndr:=date()-iif(val(ltrim(left(time(),2)))>=21,0,1)
          ENDIF
        ENDIF

        dtBegr:=BOM(dtEndr)

      ENDIF
    ENDIF

    IF (UPPER("/no_mkotch") $ UPPER(cDosParam))
      mkdt(dtEndr,027)
    ELSE

      FILEDELETE("mkdoc.*")
      FILEDELETE("mkpr.*")
      FILEDELETE("mkrs.*")
      FILEDELETE("mkost.*")

      mkkplkgp(027,nil)
      // mkotchn_Range(027,@dtBegr,@dtEndr,cDosParam)
      // outlog(__FILE__,__LINE__,dtEndr,lNo_executed_order)
      mkotchd(dtEndr,027,(NIL,2), lNo_executed_order)
      If !(lNo_deb)
        deb(361001, dtEndr)
        debn03(361002, dtEndr)
      ENDIF

      mkdt(dtEndr,027)
    ENDIF
  else
        dtEndr:=date()-iif(val(ltrim(left(time(),2)))>=21,0,1)
        dtBegr:=BOM(dtEndr)
  endif

  // outlog(__FILE__,__LINE__, dDt,  dtEndr,  dtBegr)

      FILEDELETE("mkdoc.*")
      FILEDELETE("mkpr.*")
      FILEDELETE("mkrs.*")
      FILEDELETE("mkost.*")

  select 0
  nMaxSelect:=SELECT()

  netuse('cskl')
   netuse('s_tag')
   netuse('kgp')
   netuse('kgpcat')
   netuse('krn')
   netuse('knasp')

   netuse('kpl')
   netuse('kln')
     netuse('klndog')
     netuse('mkeepe')
     netuse('klnnac')
   netuse('ctov')
   netuse('cgrp')

  netuse('mkcros')
  netuse('tmesto')
  netuse('etm')
   netuse('klnlic')


  IF lPos
    IF (UPPER("/start-lpos") $ UPPER(cDosParam))
      // outlog(__FILE__,__LINE__,'lPos',date(),"20150601")
      // LPosD(stod("20150601"))
      // LocalPosStatus()
    else
      // LPosD(dtEndr-5,date())
      // LocalPosStatus()
      // outlog(__FILE__,__LINE__,'lPos',date(),dtEndr,dtEndr-5)

      SbArOst(27)
      SbArOst2Swe(cPth_Plt_lpos) // �।���⥫쭮 ��⠭� pos.xml & ->pos_swe.dbf
      lod2swe2xml(cPth_Plt_lpos)

      //copy file pos.xml to (cPth_Plt_lpos+'\pos.xml')

      // ����� ��।�� ���
      cCmd:='CUR_PWD=`pwd`; cd /m1/upgrade2/lodis/arnd; ';
      +'./put-ftp-POS.sh;  cd $CUR_PWD'
      cLogSysCmd:=''
      SYSCMD(cCmd,"",@cLogSysCmd)
      outlog(__FILE__,__LINE__,cCmd)

    endif
  ENDIF


  // ��� ����祭�� ������ ��᫥���� ������
  USE (gcPath_ew+"deb\deb") ALIAS deb_dz NEW SHARED READONLY
  SET ORDER TO TAG t1

    If file('tmpskdoc.cdx'); erase ('tmpskdoc.cdx');    EndIf
    Crtt_SkDoc('tmpskdoc','f:keg c:n(3) f:kvp c:n(10,3)')
    use tmpskdoc alias skdoc NEW EXCLUSIVE

    // ⥪��� ������������
    append from (gcPath_ew+"deb\skdoc.dbf") ;
        for !(str(kpl,7) $ '  20034; 539105; 383053;2298568;5513371; 382533') ; // �஬� ������������, ���������ઠ

    // ������� ����/���
    If file(gcPath_ew+"deb\S361002\"+'tpdoc.dbf')
      append from (gcPath_ew+"deb\S361002\"+'tpdoc.dbf') ;
        for !(str(kpl,7) $ '  20034; 539105; 383053;2298568;5513371; 382533') ; // �஬� ������������, ���������ઠ
        all
    EndIf

    INDEX ON STR(KPL)+STR(KGP) TAG "kpl_kgp"
      TOTAL ON STR(KPL)+STR(KGP) ;//��� ���⥫�騪, �����⥫�
      for !(str(kpl,7) $ '  20034; 539105; 383053;2298568;5513371; 382533') ; // �஬� ������������, ���������ઠ
      FIELD Sdp TO tmpdeb
    close skdoc

    use tmpskdoc alias skdoc NEW EXCLUSIVE
    use tmpdeb alias deb NEW EXCLUSIVE

    // sele skdoc; sum Sdp to nSdp_skdoc
    // sele deb;  sum Sdp to nSdp_deb
    // outlog(__FILE__, __LINE__, nSdp_skdoc - nSdp_deb)

    // ���� ��娢��, ����� �� ᮯ����� � ⥪�騬
    mkeepr:=27
    cMKeepr:=padl(ltrim(str(mkeepr,3)),3,'0')
    PathDDr := PathOstDD(cMKeepr,dtEndr)
    If file(PathDDr+'skdoc.dbf')

      If file('tmp_trs2.cdx'); erase ('tmp_trs2.cdx');    EndIf
      Crtt_SkDoc('tmp_trs2','f:keg c:n(3) f:kvp c:n(10,3)')
      use tmp_trs2 alias trs2 NEW EXCLUSIVE

      // �������� ⮢��
      append from (PathDDr+'skdoc.dbf') ;
        for !(str(kpl,7) $ '  20034; 539105; 383053;2298568;5513371; 382533') ; // �஬� ������������, ���������ઠ
        all
      // ������� ����/���
      If file(PathDDr+'tpdoc.dbf')
        append from (PathDDr+'tpdoc.dbf') ;
        for !(str(kpl,7) $ '  20034; 539105; 383053;2298568;5513371; 382533') ; // �஬� ������������, ���������ઠ
        all
      EndIf

      INDEX ON STR(KPL)+STR(KGP) TAG "kpl_kgp"
        TOTAL ON STR(KPL)+STR(KGP) ;//��� ���⥫�騪, �����⥫�
        for !(str(kpl,7) $ '  20034; 539105; 383053;2298568;5513371; 382533') ; // �஬� ������������, ���������ઠ
        FIELD Sdp TO tmp_pdeb
      close trs2

    Else
      outlog(__FILE__,__LINE__,'!file(skdok) ��娢',PathDDr)
      // ��६ ⥪��� ������������
      copy file tmpskdoc.dbf to tmp_trs2.dbf
      copy file tmpdeb.dbf to tmp_pdeb.dbf
    EndIf

    // ��娢��� ������������
    use tmp_trs2 alias trs2 NEW EXCLUSIVE
    use tmp_pdeb alias pdeb NEW EXCLUSIVE


      copy file mkdoc027.dbf to mkdoc.dbf
      use mkdoc alias mkdoc new  Exclusive

      sele mkdoc

      copy to mkdoc01 ;
           for (vo=6 .and. (str(kop,3)$'188;189;180')) .or. vo=1 .or. vo=5 ;
            .or. (vo=9 .and. (sk=237 .or. sk=702))
      dele ;
           for (vo=6 .and. (str(kop,3)$'188;189;180')) .or. vo=1 .or. vo=5 ;
            .or. (vo=9 .and. (sk=237 .or. sk=702))
      pack

      use mkdoc01 new Exclusive
      repl all kvp with kvp*(-1)
      close mkdoc01

      COPY FILE mkpr027.dbf TO mkpr.dbf
      use mkpr alias mkpr  new Exclusive
      dele for kvp=0 ; pack

      //��७�ᥬ ������� vo=1 // NEW!!!-> ��⠢�� � ��室� -� ����������� (��ਪ�஢��) vo=6 & kop=111
      sele mkpr
      copy to mkprv01 for vo=1 //NEW!!!-> ��⠢�� � ��室�.or. (vo=6 .and. kop=111)
      dele for vo=1 //NEW!!! ��⠢�� � ��室�.or. (vo=6 .and. kop=111)
      pack
      use mkprv01 new Exclusive
      repl all kvp with kvp*(-1)
      close mkprv01

      sele mkdoc
      append from mkprv01

      test_doc_sk(232,dtEndr)
      //�������� ���㬥� ��� 㤠����� ����ᥩ
      IF .NOT. (UPPER("/CrmAdd") $ UPPER(cDosParam))
        dOtch := EOM(dtEndr)
        IF dtEndr = EOM(dtEndr)
          dOtch++
        ENDIF
        test_doc_sk(232,dOtch)
      ENDIF
      close

      sele mkpr
      append from mkdoc01
      test_doc_sk(232,dtEndr,,{||mkpr->vo:=5})

      //�������� ���㬥� ��� 㤠����� ����ᥩ
      IF .NOT. (UPPER("/CrmAdd") $ UPPER(cDosParam))
        dOtch := EOM(dtEndr)
        IF dtEndr = EOM(dtEndr)
          dOtch++
        ENDIF
        test_doc_sk(232,dOtch,,{||mkpr->vo:=5})
      ENDIF
      close



  #ifdef __CLIP__
    set translate path off
  #endif
  //quit
  // outlog(__FILE__,__LINE__, dDt,  dtEndr,  dtBegr)

  OblnDirBlock(cPth_Plt_tmp,"Clvrt Lodis Start SalOut")
  // 䠩�� ��४����
  /*
  aFlDir:=Directory(cPth_Plt_tmp+"\"+"*.DBF")
  aFlDir:={}
  For i:=1 To len(aFlDir)
    // �ய��⨬
    If aFlDir[i,1] # 'DIRBLOCK.DBF'
      cFile:= cPth_Plt_tmp+"\"+aFlDir[i,1]
      outlog(__FILE__,__LINE__,cFile)
      USE (cFile) NEW EXCLUSIVE
      aStruDbf:=DBStruct()
      CLOSE
      nPos:=ASCAN(aStruDbf,{|aFld| 'DTLM' = aFld[1] })
      outlog(__FILE__,__LINE__,nPos)
      IF nPos # 0
        aStruDbf[nPos,3]:=17 //YYYMMDD HH:MM:CC
        outlog(__FILE__,__LINE__,aStruDbf)
        // 䠪��᪨ �� ZAP
        //dbCreate(cFile,aStruDbf)
        dbCreate(aFlDir[i,1],aStruDbf)
        COPY FILE (aFlDir[i,1]) TO (cFile)
        outlog(__FILE__,__LINE__,aFlDir[i,1],cFile)
      ENDIF
    EndIf
  Next i

  //quit
  */

  //ZAP

  // �ਤ��᪨ ���
  USE (cPth_Plt_tmp+"\"+"PARCOMP.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF
  // �࣮�� �窨
  USE (cPth_Plt_tmp+"\"+"OUTLETS.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF
  index on ol_code to t1
  // ���ଠ�� � ��業����
  USE (cPth_Plt_tmp+"\"+"OLLICENS.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF

  //��⠪� ⮢�� �� ᫠��
  USE (cPth_Plt_tmp+"\"+"INISTOCK.DBF") NEW EXCLUSIVE
  //IF lZap; ZAP ;ENDIF
  //IF iMax(cDosParam)=1 //�� ��⮢�� ���⪨ ��� ���������� 1 ����������
    ZAP
  //ENDIF

  //��⠪� ⮢�� �� ����� ���
  USE (cPth_Plt_tmp+"\"+"ARSTOCK.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF
  //業� �த�樨
  USE (cPth_Plt_tmp+"\"+"PRLIST.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF

  //䠪��᪨ �த��� - 蠯��
  USE (cPth_Plt_tmp+"\"+"SALOUTH.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF
  //䠪��᪨ �த��� - ��⠫�
  USE (cPth_Plt_tmp+"\"+"SALOUTLD.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF

  // ��室 - 蠯��
  USE (cPth_Plt_tmp+"\"+"SALINH.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF
  // ��室 - ��⠫�
  USE (cPth_Plt_tmp+"\"+"SALINLD.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF

  // ����� �࣮��� �窨
  USE (cPth_Plt_tmp+"\"+"OLDEBTS.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF
  // ����� �࣮��� �窨 ��⠫�
  USE (cPth_Plt_tmp+"\"+"OLDEBDET.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF

  // ����� �࣮��� �窨
  USE (cPth_Plt_tmp+"\"+"ARDEBTS.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF
  // ����� �࣮��� �窨 ��⠫�
  USE (cPth_Plt_tmp+"\"+"ARDEBDET.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF


  //�ਢ猪 �� ������ � �࣮��� �窥
  USE (cPth_Plt_tmp+"\"+"OLPFORM.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF

  //�ਢ離� �����쭮� �த�樨
  USE (cPth_Plt_tmp+"\"+"LOCLPROD.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF

  //��� ����㤮�����
  USE (cPth_Plt_tmp+"\"+"LOCALPOS.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF
  inde on localcode tag t1

    //alias_1:=ALIAS()
    //sele (alias_1); copy to (alias_1)

  USE (cPth_Plt_tmp+"\"+"LPOSARCH.DBF") ALIAS LPOSARCH NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF
  inde on ol_code+localcode tag t1 // to (cPth_Plt_tmp+"\"+"LPOSARCH")
  // inde on localcode tag t2 to (cPth_Plt_tmp+"\"+"LPOSARCH")

    //alias_1:=ALIAS()
    //sele (alias_1); copy to (alias_1)

  USE (cPth_Plt_tmp+"\"+"LPOSSINH.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF
  inde on lposin_no tag t1
    //alias_1:=ALIAS()
    //sele (alias_1); copy to (alias_1)

  USE (cPth_Plt_tmp+"\"+"LPOSSIND.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF
  inde on lposin_no+localcode tag t1
    //alias_1:=ALIAS()
    //sele (alias_1); copy to (alias_1)

  USE (cPth_Plt_tmp+"\"+"LPOSTRSH.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF
  inde on lposth_no tag t1
    //alias_1:=ALIAS()
    //sele (alias_1); copy to (alias_1)

  USE (cPth_Plt_tmp+"\"+"LPOSTRSD.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF
  inde on lposth_no+localcode tag t1
    //alias_1:=ALIAS()
    //sele (alias_1); copy to (alias_1)
  //

  /*
  //�࣮��  �।�⠢�⥫�
  USE (cPth_Plt_tmp+"\"+"MERCHAND.DBF") NEW EXCLUSIVE
  ZAP
  // ������ - 蠯��
  USE (cPth_Plt_tmp+"\"+"OLORDERH.DBF") NEW EXCLUSIVE
  ZAP
  // ������ - ��⠫�
  USE (cPth_Plt_tmp+"\"+"OLORDERD.DBF") NEW EXCLUSIVE
  ZAP
  */

  /*            LOCALPOS.DBF
  ARSTOCK.DBF   LPOSSIND.DBF  OLLICENS.DBF  ORDDEN.DBF    ROUTES.DBF
  ARSTOCKG.DBF  LPOSSINH.DBF  OLORDDEN.DBF  ORDERD.DBF    SALIND.DBF
  bdbf.log      LPOSTRSD.DBF  OLORDEN.DBF   ORDERH.DBF    SALINH.DBF
  DIRBLOCK.DBF  LPOSTRSH.DBF  OLPFORM.DBF   ORDERLD.DBF   SALINLD.DBF
  INISTOCK.DBF  LPOSARCH.DBF  OLPRDDSC.DBF  ORDLDDEN.DBF  SALOUTD.DBF
  LPRODDET.DBF  OLDEBDET.DBF  OLROUTES.DBF  OUTLETS.DBF   SALOUTH.DBF
  LOCLPROD.DBF  OLDEBTS.DBF   OPERAT.DBF    PARCOMP.DBF   SALOUTLD.DBF
  OLDISCNT.DBF  ORDDDEN.DBF   PRLIST.DBF    SYNCSTAT.DBF
  */

  #ifdef __CLIP__
    set translate path on
  #endif
    IF FILE("mkkplkgp"+".cdx")
      ERASE ("mkkplkgp"+".cdx")
    ENDIF
    use mkkplkgp NEW //EXCLUSIVE
    COPY STRU TO tmpTT
    COPY TO tmp_ktt
    INDEX ON STR(KPL)+STR(KGP) TAG "kpl_kgp"
    INDEX ON STR(KGP) TAG "kgp"
    //CLOSE

    //////// ������� �� ������ ////////
    IF FILE("mktov"+cMkeep+".cdx")
      ERASE ("mktov"+cMkeep+".cdx")
    ENDIF
    USE ("mktov"+cMkeep+".dbf") ALIAS mktov NEW EXCLUSIVE
    copy to tmpmktov

    copy to mktov
    close mktov
    IF FILE("mktov"+".cdx")
      ERASE ("mktov"+".cdx")
    ENDIF

    //�㬬�஢���� �� � ��� ᪫���� ��� � ����⮯�
    USE tmpmktov NEW EXCLUSIVE
    REPL Sk WITH 262 FOR str(Sk) $ OB_LIST_BRAK_S  // �ࠪ
    REPL Sk WITH 704 FOR str(Sk) $ OB_LIST_BRAK_K  // �ࠪ ����

    REPL Sk WITH 1 FOR Sk=232 .OR. Sk=237
    REPL Sk WITH 2 FOR Sk=700 .OR. Sk=702
    INDEX ON STR(SK)+STR(MnTovT) TAG "sk"

    TOTAL ON STR(SK)+STR(MnTovT) TO tmpsumtv FIELD OsFo for sk=1 .or. sk=2
    TOTAL ON STR(SK)+STR(MnTovT) TO tmp262 FIELD OsFo for sk=262 // �ࠪ ��
    TOTAL ON STR(SK)+STR(MnTovT) TO tmp704 FIELD OsFo for sk=704 // �ࠪ ����

    CLOSE tmpmktov


    USE ("mktov"+".dbf") ALIAS mktov NEW EXCLUSIVE
    append from tmpsumtv //�㬬�஢���� �� � ��� ᪫���� ��� � ����⮯�

    dele for str(sk) $ OB_LIST_BRAK_S
    append from tmp262

    dele for str(sk) $ OB_LIST_BRAK_K
    append from tmp704
    pack

    /*  !!!! ���⪨ �� ��� 1. ��������� �� 2. ������� �� ���
    //�������� ���⮪ ����㠫�� ��� 㤠����� ��ਮ��...
      //�������� ���⮪ ��� 㤠����� ����ᥩ
      IF .NOT. (UPPER("/CrmAdd") $ UPPER(cDosParam))
        dOtch := EOM(dtEndr)
        IF dtEndr = EOM(dtEndr)
          dOtch++
        ENDIF
        APPEND FROM testtov.dbf
        REPL Dt WITH dOtch, ;
          OSFO WITH 0, ;  //DAY(dOtch), ;
          OSFON WITH 0, ; //DAY(dOtch),
          Sk WITH 232,;
          Opt WITH -1
      ENDIF
    */

    INDEX ON STR(SK)+STR(MnTovT) TAG "sk"
    SET INDEX TO
    INDEX ON STR(MnTovT) TAG "MnTov" UNIQUE
    //SET INDEX TO

    ORDSETFOCUS("sk")


    cMkeep:="" //᪮�஢��� � ���⠭�
    ////////// ��������� ������ //////////////////
    IF FILE("mkpr"+".cdx")
      ERASE ("mkpr"+".cdx")
    ENDIF
    USE ("mkpr"+".dbf") ALIAS mkpr NEW EXCLUSIVE
    INDEX ON STR(sk)+STR(ttn) TAG "sk_ttn"
    INDEX ON STR(KPL)+STR(KGP) TAG "kpl_kgp"

    ORDSETFOCUS("kpl_kgp")
      TOTAL ON STR(KPL)+STR(KGP) ;//��� ���⥫�騪, �����⥫�
      FOR .NOT. (mkkplkgp->(ORDSETFOCUS("kpl_kgp"),DBSEEK(STR(mkpr->KPL)+STR(mkpr->KGP)))) ;
         TO tmp_kttp

      TOTAL ON STR(KPL) ;
      FOR .NOT. (mkkplkgp->(ORDSETFOCUS("kpl_kgp"),DBSEEK(STR(mkpr->KPL)+STR(mkpr->KGP)))) ;
        TO tmp_kplp

    ORDSETFOCUS("sk_ttn")
    TOTAL ON STR(sk)+STR(ttn) FIELD dcl FOR !(LTRIM(STR(Sk)) $ cCOX_Sl_list) TO sk_ttnp
    //////////////////////////////////////////////


    ////////// ��������� ������ //////////////////
    IF FILE("mkdoc"+".cdx")
      ERASE ("mkdoc"+".cdx")
    ENDIF
    USE ("mkdoc"+".dbf") ALIAS mkdoc NEW EXCLUSIVE
    INDEX ON STR(sk)+STR(ttn) TAG "sk_ttn"
    INDEX ON STR(KPL)+STR(KGP) TAG "kpl_kgp"
    INDEX ON DocGuid TAG "DocGuid"

    ORDSETFOCUS("kpl_kgp")
      TOTAL ON STR(KPL)+STR(KGP) ;//��� ���⥫�騪, �����⥫�
    FOR .NOT. (mkkplkgp->(ORDSETFOCUS("kpl_kgp"),DBSEEK(STR(mkdoc->KPL)+STR(mkdoc->KGP)))) ;
        TO tmp_ktte

      TOTAL ON STR(KPL)  ;
    FOR .NOT. (mkkplkgp->(ORDSETFOCUS("kpl_kgp"),DBSEEK(STR(mkdoc->KPL)+STR(mkdoc->KGP)))) ;
      TO tmp_kple
    //////////////

    ////////// ��������� �-� //////////////////
    SELE skdoc
    INDEX ON STR(KPL)+STR(KGP) TAG "kpl_kgp"

        IF FILE("tmp_kttd"+".cdx")
          ERASE ("tmp_kttd"+".cdx")
        ENDIF
      ORDSETFOCUS("kpl_kgp")
        TOTAL ON STR(KPL)+STR(KGP) ;//��� ���⥫�騪, �����⥫�
      FOR .NOT. (mkkplkgp->(ORDSETFOCUS("kpl_kgp"),DBSEEK(STR(skdoc->KPL)+STR(skdoc->KGP)))) ;
        .and. KPL # 20034 ;
         TO tmp_kttd

    SELE trs2
    INDEX ON STR(KPL)+STR(KGP) TAG "kpl_kgp"
        IF FILE("tmp_ktta"+".cdx")
          ERASE ("tmp_ktta"+".cdx")
        ENDIF
      ORDSETFOCUS("kpl_kgp")
        TOTAL ON STR(KPL)+STR(KGP) ;//��� ���⥫�騪, �����⥫�
      FOR .NOT. (mkkplkgp->(ORDSETFOCUS("kpl_kgp"),DBSEEK(STR(trs2->KPL)+STR(trs2->KGP)))) ;
        .and. KPL # 20034 ;
         TO tmp_ktta


    //////////////

   ////////// ��������� �-� ��� //////////////////
   //USE (gcPath_ew+"deb\kegtov") ALIAS kegtov NEW SHARED READONLY
   USE (gcPath_ew+"deb\kegkpl") ALIAS kegkpl NEW SHARED //READONLY
   //INDEX ON STR(kpl)+STR(mntov) TAG "kpl_tov"
   INDEX ON STR(kpl)+STR(KGP)+STR(mntovt) TAG "kpl_tov"

   // ᢥ�㫨 ���⮪
   TOTAL ON STR(kpl)+STR(KGP)+STR(mntovt) FIELD Osf TO tmpKegO1
   CLOSE kegkpl

   // ����祭�� �祪 �� �����
   USE tmpKegO1 NEW
   INDEX ON STR(kpl)+STR(KGP) TO tmpKegO1

      TOTAL ON STR(KPL)+STR(KGP)  ;
    FOR .NOT. (mkkplkgp->(ORDSETFOCUS("kpl_kgp"),DBSEEK(STR(tmpKegO1->KPL)+STR(tmpKegO1->KGP)))) ;
      .AND. Osf <> 0 ;
      TO tmp_kplt

   // ��� 蠯�� � skdoc
      TOTAL ON STR(KPL)+STR(KGP)  ;
    FOR .NOT. (skdoc->(ORDSETFOCUS("kpl_kgp"),DBSEEK(STR(tmpKegO1->KPL)+STR(tmpKegO1->KGP)))) ;
      .AND. Osf <> 0 ;
      TO tmp_skdt


   sele tmpKegO1
   COPY TO tmpKegO2 // FOR Osf <> 0

   USE tmpKegO2 NEW
   COPY TO tmpKegO FOR Osf <> 0 // ⮫쪮 ������⥫��
   CLOSE



   //////////////


    SELE mkdoc
    ORDSETFOCUS("sk_ttn")
    TOTAL ON STR(sk)+STR(ttn) FIELD dcl FOR !(LTRIM(STR(Sk)) $ cCOX_Sl_list) TO sk_ttn
    //////////////////////////////

    USE tmp_ktt NEW
      //�᭮���� ���� �� mkkplkgp 㦥 ����
      append from tmp_kttp //���� � ��室�
      append from tmp_ktte //��� � ��室�
      append from tmp_kttd //���� � �-�
      append from tmp_ktta //���� � ��娢� �-�
      append from tmp_kplt //���⥫�騪 �� ᪫��� ����
    INDEX ON STR(KPL)+STR(KGP) TAG "kpl_kgp" UNIQ
    INDEX ON STR(KGP) TAG "kgp" UNIQ

  /*
2.1.    ������ ���ଠ樨 � �ਤ��᪨� ���� (䠩� ParComp)
  ���ଠ�� �㦭� ���㦠�� �� ��� �� �ࠢ�筨�� ����������� ��� �������筮��.
  ��� ������ ����묨 ����� ���� ���㧪� 㭨���쭮�� ���� �����������
  (���� Pcomp_Code) � ��� �������� (PC_Name). �� �� ����� ���� ��뫠����
  ��࣮�� ��窨.
  */

  SELE tmp_ktt
  ORDSETFOCUS("kpl_kgp")

  DBGOTOP()
  DO WHILE !EOF()
    kplr:=tmp_ktt->kpl
    kln->(netseek('t1','kplr'))
    SELE  PARCOMP
    alias_1:=ALIAS()
    DBAPPEND() //�஢�ઠ �� �㡫� STR(tmp_ktt->kpl,25)
    /*
    ����    ����    ���     �����   ���ᠭ��        ���� ��易⥫쭮�
    PK      PComp_Code      Character       25      ���譨� ���
    �ਤ��᪮�� ���.
    ��������� 㭨����� ����� ����ࠣ��� �� ���.  ��
    */
  _FIELD->PComp_Code:=STR(tmp_ktt->kpl,25)
  /*
          PC_Name Character       50      �������� �ਤ��᪮�� ���
  �� 㬮�砭�� '-'.       ��
  */
  _FIELD->PC_Name := kln->nkl //
  /*
          DTLM    Character       14      ��� � �६� ����䨪�樨 �����..
  ��ଠ�: "YYYYMMDD HH:MM"        ��

  */
  _FIELD->DTLM := DTLM()
  /*
          Status  Numeric 11      ����� (2 - '��⨢��', 9 - '����⨢��')
  �� 㬮�砭�� - 2        ��
  */
  _FIELD->Status := 2

   sele tmp_ktt
   DO WHILE kplr = tmp_ktt->kpl
     DBSKIP()
   ENDDO
 ENDDO
 sele (alias_1); copy to (""+alias_1)

  /*
          PC_Addr Character       80      ���� �ਤ��᪮�� ���
  �� 㬮�砭�� '-'.       ���
          PC_Zkpo Character       20      ��� ���� �ਤ��᪮�� ���
  �� 㬮�砭�� '-'.       ���
          PC_Tax_Num      Character       20      �������樮���
  �����
  �� 㬮�砭�� '-'.       ���
          PC_Vat_Num      Character       20      ����� ���⥫�騪�
  ���
  �� 㬮�砭�� '-'.       ���
          PC_B_Name       Character       80      �������� �����
  �� 㬮�砭�� '-'.       ���
          PC_B_MFO        Character       20      ��� ��� �����
  �� 㬮�砭�� '-'.       ���
          PC_B_Acc        Character       20      ����� ����_��쪮�� ��㭪�
  �� 㬮�砭�� '-'.       ���
          PC_Direct       Character       50      ��४�� �ਤ��᪮�� ���
  �� 㬮�砭�� '-'.       ���
          PC_Phone        Character       20      ����. ⥫�䮭 �ਤ��᪮�� ���.
  �� 㬮�砭�� '-'.       ���
          PC_Fax  Character       20      ���� �ਤ��᪮�� ���
  �� 㬮�砭�� '-'.       ���
          PC_EMail        Character       50      �����஭�� ���� �ਤ��᪮�� ���
  �� 㬮�砭�� '-'.       ���
          PC_Account      Character       50      ��壠��� �ਤ��᪮�� ���
  �� 㬮�砭�� '-'.       ���
          PC_Acc_Ph       Character       20      ����䮭 ��壠��� �ਤ��᪮�� ���
  �� 㬮�砭�� '-'.       ���
          PC_MManag       Character       50      ����஢�� �ਤ��᪮�� ���.
  �� 㬮�砭�� '-'.       ���
          PC_MM_Ph        Character       20      ����䮭 ⮢�஢���
  �� 㬮�砭�� '-'.       ���
          PC_PManag       Character       50      �������� �� ���㯪�� �ਤ��᪮�� ���
  �� 㬮�砭�� '-'.       ���
  */


  /*
2.2.    ������ ���ଠ樨 � ��࣮��� ��窠� (䠩� Outlets)
  ������ ���ଠ樨 � ��࣮��� ��窥-��窥 ���⠢��.
  ���ଠ�� �㦭� ���㦠�� �� ��� �� ᮮ⢥�����饣� �ࠢ�筨��, � ���஬ �࠭���� ����� � ��窠� ���⠢��\��࣮��� ��窠�.
  ��� ��砫� �㦭� �����⢨�� ᮯ��⠢����� ����� ��࣮��� �।�⠢�⥫�� � SalesWorks � ���.
  ���ᠭ� � �.2.5.1
  ����    ����    ���     �����   ���ᠭ��        ���� ��易⥫쭮�
  */
 SELE tmp_ktt
   ORDSETFOCUS("kpl_kgp")

 Outlets(,@aMessErr)

  //close tmp_ktt


  /*
2.3.    ������ ���ଠ樨 � ��業���� ������ OLLICENS
  ����室��� ��������� ⠡���� OLLICENS ᫥���騬� ����묨
  ����    ����    ���     �������         ����    ���� ����'離���
  */
  SELE tmp_ktt
  DBGOTOP()
  IF !(UPPER("/init") $ UPPER(cDosParam))
    //�� ��⮢��
    DBGOBOTTOM()
    DBSKIP()
    alias_1:="OlLicens"
  ENDIF
  DO WHILE !EOF()

    kplr:= tmp_ktt->kpl
    kgpr:= tmp_ktt->kgp
    dolr:= klnlic->(DtLic(kplr, kgpr, 2)) // 2 - ��業��� ��������
    If empty(dolr) .or. date() - dolr > 180
      klnlic->(DBGoBottom())
      klnlic->(DBSkip())

      //�� 祣� �� �����뢠��
      SELE tmp_ktt
      DBSKIP()
      LOOP

    EndIf

    dnlr:=klnlic->dnl
    dolr:=klnlic->dol
    serlicr:=klnlic->serlic
    numlicr:=klnlic->numlic
    licr:=klnlic->lic

   SELE  OLLICENS
   alias_1:=ALIAS()
   DBAPPEND() //�஢�ઠ �� �㡫� STR(tmp_ktt->kgp,7)+"-"+STR(tmp_ktt->kpl,7)
   /*
  PK      OL_CODE         Character       25      ��� ��  ���
   */
   _FIELD->OL_Code:=STR(tmp_ktt->kgp,7)+"-"+STR(tmp_ktt->kpl,7)
   /*
  PK      LT_ID   Numeric         5       _�����_���� ⨯� �_業�_�  ���襬 ��砥 ���㦠�� ���祭�� = 1 (��業��� �� ���)  ���
   */
  _FIELD->LT_ID := 1
   /*
          NUMBER  Character       20      ����� �_業�_�  ���
   */
   _FIELD->NUMBER := iif(empty(dolr) .or. (date() - dolr) > 180,;
   "empty(dolr).or.date()-dolr>180)",;
   allt(serlicr)+ltrim(str(numlicr));
 )

   /*
          STARTDATE       Date    8       ���⮪ �_�     ���
   */
   _FIELD->STARTDATE :=dnlr
   /*
          ENDDATE         Date    8       �_���� �_�      ���
   */
   _FIELD->ENDDATE := dolr
   /*
          DTLM    Character       14      ��� _ �� �����_���_� ������   ���
    */
  _FIELD->DTLM := DTLM()
    /*
          Status  Numeric         11      ����� (2 - "��⨢���?, 9 - "����⨢���?)       ���
    */
    _FIELD->Status := 2

    SELE tmp_ktt
    DBSKIP()
  ENDDO
 sele (alias_1); copy to (""+alias_1)

  /*
2.4.    ������ ���ଠ樨 �� ���⪠� ⮢�� �� ᪫��� (䠩� IniStock)
  ������ ���ଠ樨 � _�������_��������_ �த�樨 �� ᪫���� ����ਡ����,
  �㦭� ���㦠�� ���⪨ �� �᭮����� ᪫��� ⠪ � ��
  ᪫���� ��������(�᫨ ���� ⠪��).
    ����    ����    ���     �����   ���ᠭ��        ���� ��易⥫쭮�
  */

  SELECT mktov
  ORDSETFOCUS("sk")
  DBGOTOP()
  IF !(UPPER("/init") $ UPPER(cDosParam) .or. dtEndr=date()+1)
    //�� ��⮢��
    DBGOBOTTOM()
    DBSKIP()
    alias_1:="IniStock"
  ENDIF
  DO WHILE !EOF()
    //mntovt>=10000 .and. mntovt<=10^6  - �⥪����
    IF  !(MnTovT/10000=1) ; // 000 0000 0 000000
      .OR. INT(MnTovT/10000) = 250.0 ;
      .OR. !(STR(Sk,3) $ cListSaleSk)
      //DBSKIP();      LOOP
    ENDIF
    IF INT(mntovt/10000) = 250.0
      DBSKIP();      LOOP
    ENDIF
    If getfield('t1','mktov->mntovt','ctov','merch') = 0 // ��� ���
      // DBSKIP();      LOOP
    EndIf


   SELE  IniStock
   alias_1:=ALIAS()
   DBAPPEND() //�஢�ઠ �� �㡫�   Sk + MnTovT
     /*
      PK      Wareh_Code      Character       20      ���譨� ��� ᪫���  ��� ᪫��� �� ���       ��
    */
      _FIELD->Wareh_Code := ALLT(STR(mktov->Sk))
     /*
      PK      ProdCode  Character       20      ��⠢�塞 ����� (null) ��
    */
    _FIELD->ProdCode:="0"
     /*
      PK      LocalCode       Character       20      ������� ��� �த�樨 ��
    */
    _FIELD->LocalCode:=allt(STR(mktov->MnTovT))
     /*
      PK      LOT_ID  Character       20      �����䨪��� ���⨨ ⮢��   �� ��������� �᫨ �� �ᯮ������ ���⨩�� ��� ���⪮�       ��
    */
    _FIELD->LOT_ID:="0"
     /*
              STOCK   Numeric 14,3    ���⮪ ⮢��, ��.
              ��易⥫쭮 ���㦠�� "�㫥��� ���⮪"     ��
    */

    nVolume:=KegaVol('mktov->mntovt')
    /*
           !!KegaVolOrd
    nVolume:=1 // <- ���� �� ��ॢ���� �.�. �����뢠�� � �����
    */

    _FIELD->STOCK:=mktov->OsFo / nVolume
     /*
              DTLM    Character       14      ��� � �६� ����䨪�樨 �����.   ��ଠ�: "YYYYMMDD HH:MM"        ��
    */
  _FIELD->DTLM := DTLM()
    /*
            Status  Numeric 11      ����� ⮢�� (2 - '��⨢��', 9 - '����⨢��' ��
    */
   _FIELD->Status := 2

    SELECT mktov
    DBSKIP()
  ENDDO
 sele (alias_1); copy to (""+alias_1)

  /*
2.5.    ������ ���ଠ樨 � ��娢��� ���⪠� (䠩� ArStock)
  ����室��� ���㦠�� ⠪�� ��ࠧ�� �⮡� ���⪨ ���㦠���� �� ����� ���
  (� ���� � ��⮬ ��� �������� �� ⮢��� �� ������ ��ਮ� ���⭮�� � ��)
  ��易⥫쭮 ���㦠�� ���⪨ �� �᭮����� ᪫��� � ��
  ᪫���� �������� (�᫨ ���� ⠪��).
  ����    ����    ���     �����   ���ᠭ��        ���� ��易⥫쭮�
  */
  SELECT mktov
  ORDSETFOCUS("sk")

  iMax:=iMax(cDosParam)

  FOR i:=1 TO iMax // �ॡ������ ���㦠�� ���⪨ �� ��।...
    DBGOTOP()
    DO WHILE !EOF()
      IF .F. ; //!(MnTovT/10000=1) ;
        .OR. !(STR(Sk,3) $ cListSaleSk)
        DBSKIP();      LOOP
      ENDIF
      IF INT(mntovt/10000) = 250.0
        DBSKIP();      LOOP
      ENDIF
      If getfield('t1','mktov->mntovt','ctov','merch') = 0
        // DBSKIP();      LOOP
      EndIf

      SELE  ArStock
      alias_1:=ALIAS()
      DBAPPEND()
       /*
        PK      Wareh_Code      Character       20      ���譨� ��� ᪫���  ��� ᪫��� �� ���       ��
      */
        _FIELD->Wareh_Code :=allt(STR(mktov->Sk))
       /*
        PK      LocalCode       Character       20      ������� ��� �த�樨 ��
      */
      _FIELD->LocalCode:=allt(STR(mktov->MnTovT))
       /*
        PK      LOT_ID  Character       20      �����䨪��� ���⨨ ⮢��   �� ��������� �᫨ �� �ᯮ������ ���⨩�� ��� ���⪮�       ��
      */
      _FIELD->LOT_ID:="0"
       /*
                STOCK   Numeric 14,3    ���⮪ ⮢��, ��. ��易⥫쭮 ���㦠�� "�㫥��� ���⮪"     ��
      */
     nVolume:=KegaVol('mktov->mntovt')

      _FIELD->STOCK:=mktov->OsFo / nVolume
      /*
      PK      DATE    Date    8       ��� �१� ���⪮�.   ��ଠ�:   "DD.MM.YYYY"    ��
      */
      _FIELD->DATE:=mktov->DT+(i-1)
       /*
                DTLM    Character       14      ��� � �६� ����䨪�樨 �����.   ��ଠ�: "YYYYMMDD HH:MM"        ��
      */
    _FIELD->DTLM := DTLM()


      SELECT mktov
      DBSKIP()
    ENDDO
  NEXT
 sele (alias_1); copy to (""+alias_1)

  /*
2.6.    ������ ���ଠ樨 � 業�� �த�樨 (䠩� PrList)
  ��। ���㧪�� ���ଠ樨 � 䠩�, �㦭� ᭠砫� ᮯ��⠢��� ���� ��� ������\��⥣�਩ ��� � ���, ���ᠭ� � �.2.5.4
  ���祭�� ����� ��� ������, ����� ������� � DBF-䠩��- Payforms.dbf.
  ����    ����    ���     �����   ���ᠭ��        ���� ��易⥫쭮�
  */
  SELECT mktov
  ORDSETFOCUS("MnTov")
  aPayForm:={ 5200000, 5200003, 5200004}
  FOR i:=1 TO 3
    DBGOTOP()
    DO WHILE !EOF()
      IF  !(MnTovT/10000=1) ;
        .OR. !(STR(Sk,3) $ cListSaleSk)
        //DBSKIP();      LOOP
      ENDIF
      IF INT(mntovt/10000) = 250.0
        DBSKIP();      LOOP
      ENDIF
      nMnTovT:=mktov->MnTovT
      SELE PrList
      alias_1:=ALIAS()
      DBAPPEND() //�஢�ઠ �� �㡫�  allt(STR(mktov->MnTovT))
      /*
      FK      PayForm_ID      Numeric 11      �����䨪��� ��� ������.  ��� ��⥣�ਨ ����      ��
      */
      _FIELD->PayForm_ID := aPayForm[i] //5200000 //䠪�:  5200001 - ����窠
      /*
      FK      Code  �haracter       20      �� ����������  ��
      */
      _FIELD->Code:="" //STR(_FIELD->PayForm_ID)
      /*
      PK, FK  LocalCode   Character       20      ��� �����쭮� �த�樨 ��
      */
      _FIELD->LocalCode:=allt(STR(mktov->MnTovT))
      /*
            Price   Numeric 15,8    ���� ��� ���\� ���      ��
      */
       nVolume:=KegaVol('mktov->mntovt')

      NDSr:=round((100+gnNDS)/100,2) //  ���  1.20  20%
      _FIELD->Price:=ROUND(;
                    mktov->CenPr;
                    *NDSr;
                    *nVolume,;
                    2;
                  )
    If !empty(FieldPos('PayF_CODE'))
      _FIELD->PayF_CODE:='1' // c20
    EndIf

       /*
                DTLM    Character       14      ��� � �६� ����䨪�樨 �����.   ��ଠ�: "YYYYMMDD HH:MM"        ��
      */
    _FIELD->DTLM := DTLM()
      /*
              Status  Numeric 11      ����� ⮢�� (2 - '��⨢��', 9 - '����⨢��' ��
      */
      _FIELD->Status := 2

      SELECT mktov
      DO WHILE nMnTovT = mktov->MnTovT
        DBSKIP()
      ENDDO
    ENDDO
  NEXT
 sele (alias_1); copy to (""+alias_1)

  /*
2.7.    ������ ���ଠ樨 � 䠪��᪨� �த���� - ����� (䠩� SalOutH)
  �����᪨� �த���- �� ���㬥��� � 䠪��᪨ ���㦥���� (� ᪫��� ����ਡ����) ��������� �\�� ��.
  ���ଠ�� �㦭� ���㦠�� � 䠩�� SalOutH.dbf (蠯��) � SalOutLD.dbf (��⠫�)
  � 䠩�� �㦭� ���㦠�� ���ଠ�� � :
  -       �த��� � ��,
  -       ������� �� ��,
  -       ��६�饭�� ����� ᪫����� ����ਡ����, ��६�饭�� �� 䨫����,(㪠�뢠�� ᪫�� �� ���ண� ��६�頥��� ⮢��)
  -       ���४�஢�� (�᫨ ���� ⠪�� ���㬥���)
  -       ���ᠭ�� (�᫨ ���� ⠪�� ���㬥���)
  ����    ����    ���     �����   ���ᠭ��        ���� ��易⥫쭮�
  */
  aKta:={}
  AADD(aKta,1000)

  // �஢�ઠ �� ��८楪�, �.�. ��� "������" � vo=1, ������ ����
  // vo=9 ⮣�� �� "��८業��"
  /*
  �ࠪ169 ����⮯ 705 -> 700 ���?� ����⮯
  �ࠪ169 �㬨 263 ->232 ���?� �㬨
  */
  SELE  mkdoc
  ORDSETFOCUS("DocGuid")
  DBGoTop()
  Do While !eof()
    If Empty(DocGuid)
      DBSkip()
      Loop
    EndIf
    cDocGuid := DocGuid
    nRec:=RecNo()
    Do While cDocGuid = DocGuid
      If mkdoc->vo = 1
        DBGoTo(nRec)
        locate for mkdoc->vo = 9 while cDocGuid = DocGuid
        If found() // ��८楪�
          DBGoTo(nRec)
          repl all vo with 4, ;
          sk with iif(sk=705,700,iif(sk=263,232,232));
          while cDocGuid = DocGuid
        EndIf
        exit

      EndIf
      DBSkip()
    EndDo

  EndDo

  SELE  mkdoc
  ORDSETFOCUS("sk_ttn")

  set filt to .not. (INT(mntovt/10000) = 250.0)
  DBGOTOP()
  DO WHILE !EOF()
    nSk:=_FIELD->Sk
    nTtn:=_FIELD->Ttn
    IF  !(MnTovT/10000=1) ;
      .OR. !(STR(Sk,3) $ cListSaleSk)
      //DBSKIP();       LOOP
    ENDIF
    IF INT(mntovt/10000) = 250.0
      DBSKIP();      LOOP
    ENDIF

    vor := mkdoc->vo
    DO CASE
    CASE vor= 9
      nDoc_type := 2 //  ��室 ���㯠⥫�,
    CASE vor= 4
      nDoc_type := 4
    CASE vor= 1
      nDoc_type := 3 //  2 - ������ ���⠢騪�,
    //CASE vor= 6
    //  nDoc_type := 5 //  (5 - ���४��
    OTHERWISE
      nDoc_type := 99 //  6 - ᯨᠭ�� ⮢��
        AADD(aMessErr,"�� ���� ��� ��� ����樨'-' ��� VO="+STR(mkdoc->vo)+;
        " KOP="+STR(mkdoc->kop)+;
        "��� ���(mkdoc) "+DTOS(mkdoc->DTtn) +" "+STR(mkdoc->Sk)+' '+STR(mkdoc->Ttn)+;
        CHR(10)+CHR(13);
        +"��ࠬ���� �맮�� �ணࠬ�: ";
        + cDosParam ;
        + CHR(10)+CHR(13))

    ENDCASE

    /*
  PK, FK  Merch_ID        Numeric 11      �����䨪��� �࣮���� �।�⠢�⥫�
    ��� ��, ����� ������� � Merchand.dbf     ��� ��� ⨯�� �������� �஬� ⨯� 2 � 3 ��������� ���祭��� 0           ��
    */
    nIdLod:=mkdoc->(nIdLod('mkdoc->kta', @aMessErr, @aKta))

    SELE SalOutH
   alias_1:=ALIAS()
    DBAPPEND()
    _FIELD->Merch_ID:=IIF(mkdoc->kta=0 .OR. .NOT.(LTRIM(STR(nDoc_type))$"2 3") ,0,nIdLod) //5200000+mkdoc->kta)
    /*
  PK      Date    Date    8       ��� ���㧪� ⮢��,   ��� ���������  ��
    */
    _FIELD->Date := dtEndr //11-06-17 12:30pm mkdoc->DTtn

    /*
  PK, FK  Ol_Code Character       25      ��� ��࣮��� �窨 � ���
          ��� ��� ⨯�� �������� �஬� ⨯� 2 � 3 ��������� ���祭��� 0  ��
    */
   _FIELD->OL_Code:=STR(mkdoc->Kgp)+"-"+STR(mkdoc->Kpl)

    /*
  PK, FK  Order_No        Numeric 20      ��� ���㬥�� �����, ��ନ஢������ � SalesWorks.
      0 - �᫨ ����� ��ନ஢�� �� �१ SalesWorks  ��
    */
    cDocGuId:="0"
    IF LEFT(LTRIM(mkdoc->DocGuId),2)="52"
      cDocGuId:=LTRIM(mkdoc->DocGuId)
    ELSE
      //cDocGuId:=IIF(empty(mkdoc->DocGuId),GUID_KPK("F",PADL(LTRIM(STR(mkdoc->Sk)),3,"0")+PADL(LTRIM(STR(mkdoc->TTN)),7,"0"))),mkdoc->DocGuId)
    ENDIF
    _FIELD->Order_No := cDocGuId

    /*
  PK      Invoice_No      Character       58      ����� ���㬥�� � ���.
     ����� ������ ���� 㭨�����, �� ����室����� ��� ���ᯥ祭�� 㭨���쭮��, �㦭� � ���� ���㬥��� �������� ��䨪� �
     㪠������ ���� � �����: YYYYMM ��
    */
    _FIELD->Invoice_No := DTOS(mkdoc->DTtn)+"-"+;
                          PADL(LTRIM(Wareh_Code(mkdoc->Sk,.T.)),4,"0")+"-"+;
                          PADL(LTRIM(STR(mkdoc->TTN)),6,"0")
    If !empty(FieldPos('CInvoic_No'))
      _FIELD->CInvoic_No:=_FIELD->Invoice_No
    EndIf

    //STR(mkdoc->Sk)+STR(mkdoc->Ttn)

    If !empty(FieldPos('MERCH_CODE'))
      _FIELD->MERCH_CODE:=allt(str(mkdoc->kta))
    EndIf


    /*
          Status  Numeric 11      ����� ���㬥�� (0 - '����।������', 1 - '���㦥��', 2 - '����祭�', 3 - '���筮 ����祭�', 4 - '��������� ����祭�', 9 - '㤠����')      ��
    */
  _FIELD->Status := IIF(mkdoc->TTN<0,9,2)

    /*
          DateTo  Date    8       ��� �� ���ன ����室��� ������� ��������� ᮣ��᭮ ����窥 ������ ��       ��
    */
       d_DtOpl:=GetDataField(mkdoc->Sk,"rs1","_rs1","t1","mkdoc->ttn","_rs1->DtOpl")
       d_dop:= mkdoc->DTtn
                IF EMPTY(d_DtOpl)
                  DtOplr:=d_dop+14
                ELSEIF d_DtOpl = mkdoc->DTtn
                  DtOplr:=d_dop+14
                ELSE
                  DtOplr:=d_DtOpl
                ENDIF
    _FIELD->DateTo := d_DtOpl

    /*
      //param1 2 - ���� ��樧�� ⮢��, 1 - ��� ��樧���� ⮢��
      param1  - �ଠ ������ (��� ��� ���.���)
    */
    (alias_1)->param1 := IIF(mkdoc->KOP=169,2,1)

    sele (alias_1)
    /*
          VatCalcMod      Numeric 11
          ���� ⮢�� � ��� - ��� ���祭�� SALOUTH. VatCalcMod = 1.
          ���� ⮢�� ��� ��� - ��� ���祭�� SALOUTH. VatCalcMod = 0      ��
    */

    IF OB_OUT_VATCALCMOD = 0
      _FIELD->VatCalcMod :=  0 //IIF(mkdoc->Kop=170,1,0)
    ELSE
      _FIELD->VatCalcMod :=  1 //IIF(mkdoc->Kop=170,1,0)
    ENDIF

    /*
          DTLM    Character       14      ��� � �६� ����䨪�樨 �����.   ��ଠ�: "YYYYMMDD HH:MM"        ��
    */

    _FIELD->DTLM := DTLM()
    /*
    FK      Doc_Type        Numeric 2       ⨯ ���㬥��
    2       �த��� (+)     saloutH
    3       ������ �� ஧���� (-)  salOutH
    */

    _FIELD->Doc_Type := nDoc_type

    /*
  PK      Wareh_Code      Character       20      ���譨� ��� ᪫���  ��� ᪫��� �� ��� (ᮮ⢥����� ����� ᪫���� � ���) � ���ண� �뫠 �ந������� �த���       ��
    */
    _FIELD->Wareh_Code := Wareh_Code(mkdoc->Sk)



    SELECT mkdoc
    DO WHILE  nSk = _FIELD->Sk .AND.     nTtn = _FIELD->Ttn
      DBSKIP()
    ENDDO
  ENDDO
 sele (alias_1); copy to (""+alias_1)
  /*
          Param1  Numeric 11      ��������� - 0   ��
          PrintCheck      Logical 1       ��������� - 0   ��
          PrintOrder      Logical 1       ��������� - 0   ��
          PrnChkOnly      Logical 1       ��������� - 0   ��
  PK      Wareh_Code      Character       20      ���譨� ��� ᪫���
  ��� ᪫��� �� ��� (ᮮ⢥����� ����� ᪫���� � ���) � ���ண�
  �뫠 �ந������� �த���       ��
  */


  /*
2.8.    ������ ���ଠ樨 � 䠪��᪨� �த���� - ��⠫� (䠩� SalOutlD)
  ���ଠ�� � 䠪��᪨� �த���� (䠪���).
  ����    ����    ���     �����   ���ᠭ��        ���� ��易⥫쭮�
  */
  SELE  mkdoc
  ORDSETFOCUS("sk_ttn")
  DBGOTOP()
  DO WHILE !EOF()
    nSk:=_FIELD->Sk
    nTtn:=_FIELD->Ttn
    IF  !(MnTovT/10000=1) ;
      .OR. !(STR(Sk,3) $ cListSaleSk)
      //DBSKIP();       LOOP
    ENDIF
    IF INT(mntovt/10000) = 250.0
      DBSKIP();      LOOP
    ENDIF
    If getfield('t1','mkdoc->mntovt','ctov','merch') = 0 // ��� ���
      // DBSKIP();      LOOP
    EndIf

    IF ASCAN(aKta,mkdoc->kta) # 0
      DBSKIP();      LOOP
    ENDIF


    SELE SalOutlD
   alias_1:=ALIAS()
    DBAPPEND()
    /*
          VAT     Numeric 5,2     �⠢�� ��� � %  ��
    */
    _FIELD->VAT := IIF(mkdoc->(INT(MnTovT/10000)=0),0,20)// �� 0%,�.�. �����⭠�.
    /*
    PK, FK  LocalCode       Character       20      ��� �����쭮� �த�樨.
    */
    _FIELD->LocalCode:=allt(STR(mkdoc->MnTovT))
    /*
    PK      Price   Numeric 15,8
    ���� ⮢�� � ��� - ��� ���祭�� SALOUTH. VatCalcMod = 1.          ��
    ���� ⮢�� ��� ��� - ��� ���祭�� SALOUTH. VatCalcMod = 0.           ��
    */
    nVolume:=KegaVol('mkdoc->mntovt')

    nPriceSale:=;
       IIF(mkdoc->KOP=177, 0.01, mkdoc->zen) //zenn - ���⠭��, zen- c ���

    nKoef:=1.0
    If mkdoc->KOP=169
      // ��� ����樨 169 ���.,
      kg_r:=int(mkdoc->MnTovT/10000)
      //KolAkcr:=getfield('t1','mntovr','ctov','kolakc')
      if !empty(getfield('t1','kg_r','cgrp','nal'))
        // ��樧  � 業� + 5% (*1.05)
        nKoef:=1.05
      endif
    EndIf

    nPriceSale:= ROUND(nPriceSale * nKoef, 2)



    IF OB_OUT_VATCALCMOD = 0
      _FIELD->Price := nPriceSale  * nVolume
    ELSE
      _FIELD->Price := nPriceSale * 1.2  * nVolume
    ENDIF

    /*
          Qty     Numeric 14,3    ������⢮ ���㦥����� ⮢��.          ��
    */
    _FIELD->Qty := mkdoc->kvp / nVolume

    /*
    PK, FK  Invoice_No      Character       58      ����� ��������� (������ ���� 㭨�����).
    ����� ���㬥�⮢ ��� ࠧ��� ⨯�� �������� (���������) �� ������ ���ᥪ�����, �⮡� �᪫���� �� ���������.
    ������������ ������� � ����� ��������� 㭨����� ������ ��� ������� ⨯� ���������.
    � ��砥, �᫨ � ��⭮� ��⥬� �ந�室�� ���㫥��� �㬥�樨 ��������� (���ਬ�� � ��砫� ����), ��������� � ������ ��������� 㭨����� �����䨪��� (����. "2012_", �.�. ���+ᨬ��� "_"
    ���祭�� �� ������ ࠢ������ "0".       ��
    */
    _FIELD->Invoice_No := DTOS(mkdoc->DTtn)+"-"+;
                          PADL(LTRIM(Wareh_Code(mkdoc->Sk,.T.)),4,"0")+"-"+;
                          PADL(LTRIM(STR(mkdoc->TTN)),6,"0")
    //_FIELD->Invoice_No := PADL(LTRIM(STR(mkdoc->Sk)),3,"0")+PADL(LTRIM(STR(mkdoc->TTN)),6,"0")
    //STR(mkdoc->Sk)+STR(mkdoc->Ttn)

    /*
    PK      Lot_id  Character       20      ����� ���⨨.
    ���祭�� "0", �᫨ �� �������.  ��
    */
    _FIELD->Lot_id := "0"
    /*
          DTLM    Character       14      ��� � �६� ����䨪�樨 �����. ��ଠ�: "YYYYMMDD HH:MM"       ��
    */
  _FIELD->DTLM := DTLM()

    /*
          Status  Numeric 11      ����� ���㬥�� (0 - '����।������',

          1 - '���㦥��', 2 - '����祭�', 3 - '���筮 ����祭�',
          4 - '��������� ����祭�', 9 - '㤠����')      ��
    */
  _FIELD->Status := IIF(mkdoc->TTN<0,9,2)

    /*
          Order_No        Numeric 20      �����䨪��� ������.
     ��������� ���祭��� �����䨪��� ������, � ��砥 �᫨ ����� ����㯨� �� SalesWorks (Order_No).       ��
    cDocGuId:=IIF(empty(mkdoc->DocGuId),GUID_KPK("F",allt(LTRIM(STR(mkdoc->SK))+PADL(LTRIM(STR(mkdoc->TTN)),7,"0"))),mkdoc->DocGuId)
    _FIELD->Order_No := VAL(RIGHT(cDocGuId,20))
    */

    /*
          AccPrice        Numeric 15,8    ��⭠� 業� ⮢��
            ��������� ���祭��� "0" ��
    */
    _FIELD->AccPrice  := 0

    SELECT mkdoc
    //DO WHILE  nSk = _FIELD->Sk .AND.     nTtn = _FIELD->Ttn
      DBSKIP()
    //ENDDO
  ENDDO
 sele (alias_1); copy to (""+alias_1)
  CLOSE  mkdoc

  /*
2.9.    ������ ���ଠ樨 � ��室�� - ����� (䠩� SalInH)
  ����� ��室��.
  � 䠩�� �㦭� ���㦠�� ���ଠ�� �:
  -       ��室� �� �ந�����⥫� �� �᭮���� ᪫�� (��),
  -       ������� �ந�����⥫� � �᭮����� ᪫��� (��),
  -       ��६�饭�� (㪠�뢠�� ᪫�� �� ����� ��६�頥��� ⮢��)
  ����    ����    ���     �����   ���ᠭ��        ���� ��易⥫쭮�
  */
      nSumKop211p:=0
      nSumKop211n:=0
      nQKop211p:=0
      nQKop211n:=0
  SELE  mkpr
  ORDSETFOCUS("sk_ttn")
  DBGOTOP()
  DO WHILE !EOF()
    nSk:=_FIELD->Sk
    nTtn:=_FIELD->Ttn
    IF  !(MnTovT/10000=1) ;
      .OR. !(STR(Sk,3) $ cListSaleSk)
      //DBSKIP();      LOOP
    ENDIF
    IF INT(mntovt/10000) = 250.0
      DBSKIP();      LOOP
    ENDIF
    SELE SalInH
    alias_1:=ALIAS()
    DBAPPEND()
    /*
    PK      Date    Date    8       ��� ��室� ⮢�� �� �����    ��
    */
    _FIELD->Date := mkpr->DTtn
    /*
    PK      Invoice_No      Character       58      ����� ���������         ��
    */
    _FIELD->Invoice_No := DTOS(mkpr->DTtn)+"-"+;
                          PADL(LTRIM(Wareh_Code(mkpr->Sk,.T.)),4,"0")+"-"+;
                          PADL(LTRIM(STR(mkpr->TTN)),6,"0")
    //_FIELD->Invoice_No :=  PADL(LTRIM(STR(mkpr->Sk)),3,"0")+PADL(LTRIM(STR(mkpr->TTN)),6,"0")
    //STR(mkpr->Sk)+STR(mkpr->Ttn)
    /*
            Status  Numeric 11      ����� (2 - '��⨢��', 9 - '����⨢��')       ��
    */
    _FIELD->Status := IIF(mkpr->TTN<0,9,2)
    /*
    VatCalcMod      Numeric 11
    ���� ⮢�� � ��� - ��� ���祭�� SALINH. VatCalcMod = 1.
    ���� ⮢�� ��� ��� - ��� ���祭�� SALINH. VatCalcMod = 0      ��
    */
    DO CASE
    CASE OB_IN_VATCALCMOD = 0
      _FIELD->VatCalcMod :=  0
    CASE OB_IN_VATCALCMOD = 1
      _FIELD->VatCalcMod :=  1
    CASE OB_IN_VATCALCMOD = 2
      _FIELD->VatCalcMod :=  1
    ENDCASE

    /*
            DTLM    Character       14      ��� � �६� ����䨪�樨 �����.  ��ଠ�: "YYYYMMDD HH:MM"        ��
    */
    _FIELD->DTLM := DTLM()
    /*
    FK      Doc_Type        Numeric 2       ⨯ ���㬥��
    1       ��室 (+)      salInH
    2
    3
    5 !//4       ���ᠭ�� (+)    salinH
    5       ���४�஢�� (+/-)     salInH
    ����� "+" � "-" �⠢���� �� � �⮬ ���� � � ⠡��� ��⠫�� � ���� QTY  ��
    6       ��६�饭�� �� 䨫��� (+)       salInH
    7       ��६�饭�� � 䨫���� (-)       salInH
    8       ���⨥ � ��� (-)        salInH
    9       ������ �ந�����⥫� (-)       salInH
    ����� "+" � "-" �⠢���� �� � �⮬ ���� � � ⠡��� ��⠫�� � ���� QTY  ��
    */
    vor := mkpr->vo
    DO CASE
    CASE vor= 5
      nDoc_type := 5//4 //  (ᯨᠭ��
    CASE vor=6 .and. mkpr->kop=111
      nDoc_type := 5 //  (5 - ���४�� +/-
    CASE vor= 1 ;  // ������ �ந�����⥫�
     .or. (vor=9 .and. (mkpr->sk=237 .or. mkpr->sk=702) .and. mkpr->kvp<0) // ᯨᠭ�� � ���
      nDoc_type := 9 // - ������ �ந�����⥫� � ᯨᠭ�� � ���(-)
      mkpr->ttnpst:=iif(empty(mkpr->ttnpst),RIGHT(_FIELD->Invoice_No,6),mkpr->ttnpst)
    CASE vor= 9
      nDoc_type := 1 // - ��室 �� ���⠢騪�,
      mkpr->ttnpst:=iif(empty(mkpr->ttnpst),RIGHT(_FIELD->Invoice_No,6),mkpr->ttnpst)
      //mkpr->ttnpst:= // ������ ������� �㪠��_FIELD->Invoice_No
    CASE vor= 6 .and. mkpr->kvp>0 //6 ��६�饭�� �� 䨫��� (+)       salInH
      nDoc_type := 6
    CASE vor= 6 .and. mkpr->kvp<0 //7 ��६�饭�� � 䨫���� (-)       salInH
      nDoc_type := 7
    OTHERWISE
      nDoc_type := 99 //  ??
      AADD(aMessErr,"�� ���� ��� ��� ����樨'-' ��� VO="+STR(mkpr->vo)+;
      " KOP="+STR(mkpr->kop)+;
      "��� ��(mkpr) "+DTOS(mkpr->DTtn) +STR(mkpr->Sk)+STR(mkpr->Ttn)+;
      CHR(10)+CHR(13))

    ENDCASE

    _FIELD->Doc_Type := nDoc_type
    /*
    PK      Wareh_Code      Character       20      ���譨� ��� ᪫���
      ��� ᪫��� �� ��� (ᮮ⢥����� ���� � ���) �� ���஬� ���� �������� ⮢��   ��
    */
    cWareh_Code:=Wareh_Code(mkpr->Sk)
    // ⮢�� �ࠪ ���࠭� � �᭮���� ᪫�� �������� � ᪫. �ࠪ�
    If str(mkpr->Sk,3) $ '232;700' .and. mkpr->Kop = 108 .and. !Empty(mkpr->DocGuId)
      // ������ � ᪫��� �ࠪ�
      If mkpr->Sk = 232
        cWareh_Code:=Wareh_Code(262)
      Else
        cWareh_Code:=Wareh_Code(704)
      EndIf
    EndIf
    _FIELD->Wareh_Code := cWareh_Code

    /*
            CUSTDOC_NO      Character       58      ����� ���㬥�� �த��� ��      ���
    */
    IF mkpr->(FIELDPOS("ttnpst"))=0
    ELSE
    _FIELD->CUSTDOC_NO:= mkpr->ttnpst
    ENDIF
    IF EMPTY(_FIELD->CUSTDOC_NO)
      //_FIELD->CUSTDOC_NO:=    allt(_FIELD->Invoice_No)+"_"+DTOC(_FIELD->Date)
    ENDIF

    SELECT mkpr
    DO WHILE  nSk = _FIELD->Sk .AND.     nTtn = _FIELD->Ttn
      If kop=211
        If mkpr->kvp >0
          nSumKop211p += mkpr->kvp * _FIELD->Zen
          nQKop211p += mkpr->kvp
        Else
          nSumKop211n += mkpr->kvp * _FIELD->Zen
          nQKop211n += mkpr->kvp
        EndIf
      EndIf
      DBSKIP()
    ENDDO
  ENDDO
  If !EMPTY(nSumKop211p) .or. !EMPTY(nSumKop211p)
      AADD(aMessErr,DTOC(dtEndr);
      +" �業�� �-�� ���४権 �� kop=211 ";
      + STR(nQKop211p,10,3)+' � ';
      + STR(nQKop211n,10,3);
      +CHR(10)+CHR(13))

      AADD(aMessErr,SPACE(8);
      +" �業�� ����� ���४権 �� kop=211 ";
      + STR(nSumKop211p,10,2)+' � ';
      + STR(nSumKop211n,10,2);
      +CHR(10)+CHR(13))

      AADD(aMessErr,SPACE(8);
      +"�������� �㦥� �������� ������ � ����ୠ� ��������";
      +CHR(10)+CHR(13))
  EndIf


 sele (alias_1); copy to (""+alias_1)

  /*
2.10.   ������ ���ଠ樨 � ��室�� ⮢�� - ��⠫� (䠩� SalInLD)
  ��⠫� ��室��
  ����    ����    ���     �����   ���ᠭ��        ���� ��易⥫쭮�
  */
  SELE  mkpr
  ORDSETFOCUS("sk_ttn")
  DBGOTOP()
  DO WHILE !EOF()
    nSk:=_FIELD->Sk
    nTtn:=_FIELD->Ttn
    IF  !(MnTovT/10000=1) ;
      .OR. !(STR(Sk,3) $ cListSaleSk)
      //DBSKIP();      LOOP
    ENDIF
    IF INT(mntovt/10000) = 250.0
      DBSKIP();      LOOP
    ENDIF
    If getfield('t1','mkpr->mntovt','ctov','merch') = 0 // ��� ���
      // DBSKIP();      LOOP
    EndIf
    SELE SalInLD
   alias_1:=ALIAS()
    DBAPPEND()
    /*
           VAT     Numeric 5,2     �⠢�� ��� � %  ��
    */
    _FIELD->VAT := IIF(mkpr->(INT(MnTovT/10000)=0),0,20)// �� 0%,�.�. �����⭠�.

    /*
    PK, FK  LocalCode       Character       20      ��� �����쭮� �த�樨 ��
    */
    _FIELD->LocalCode:=allt(STR(mkpr->MnTovT))
    /*
    PK      Price   Numeric 15,8
    ���� ⮢�� � ��� - ��� ���祭�� SALINH. VatCalcMod = 1.
    ���� ⮢�� ��� ��� - ��� ���祭�� SALINH. VatCalcMod = 0.      ��
    */
     nVolume:=KegaVol('mkpr->mntovt')

    nPriceSale:= mkpr->zen //zenn - ���⠭��, zen- c ���

    DO CASE
    CASE OB_IN_VATCALCMOD = 0
      _FIELD->Price := nPriceSale  * nVolume
    CASE OB_IN_VATCALCMOD = 1
      _FIELD->Price := nPriceSale * 1.2  * nVolume
    CASE OB_IN_VATCALCMOD = 2
      _FIELD->Price := nPriceSale * nVolume
    ENDCASE

    /*
            Qty     Numeric 14,3    ������⢮ ����祭���� ⮢��.
            �� ������ "+". �� 10   ������ �ந�����⥫� (-)       salinH
            ��
    */
    _FIELD->Qty := mkpr->kvp / nVolume

    /*
    PK, FK  Invoice_No      Character       58
    ����� ��室��� ��������� � ��⭮� ��⥬� ����ਡ����.
    ��������� ᮮ⢥�����騬 ���祭��� �� SALINH.  ��
    */
    _FIELD->Invoice_No := DTOS(mkpr->DTtn)+"-"+;
                          PADL(LTRIM(Wareh_Code(mkpr->Sk,.T.)),4,"0")+"-"+;
                          PADL(LTRIM(STR(mkpr->TTN)),6,"0")
    //_FIELD->Invoice_No := PADL(LTRIM(STR(mkpr->Sk)),3,"0")+PADL(LTRIM(STR(mkpr->TTN)),6,"0")
    //STR(mkpr->Sk)+STR(mkpr->Ttn)

    /*
    PK      Lot_id  Character       20      ����� ���⨨    ��
    */
    _FIELD->LOT_ID:="0"
    /*
            DTLM    Character       14      ��� � �६� ����䨪�樨 ����� (���㧪� ���ଠ樨). ��ଠ�: "YYYYMMDD HH:MM" ��
    */
    _FIELD->DTLM := DTLM()
    /*
     Status  Numeric 11      ����� (2 - '��⨢��', 9 - '����⨢��')
     ��������� ���祭��� "2",        ��
    */
    _FIELD->Status := IIF(mkpr->TTN<0,9,2)

    SELECT mkpr
    //DO WHILE  nSk = _FIELD->Sk .AND.     nTtn = _FIELD->Ttn
      DBSKIP()
    //ENDDO
  ENDDO
 sele (alias_1); copy to (""+alias_1)

 //����⪠ �����
 //   SELE SalInH
 //   DELE FOR SalInLD->(__dbLocate({|| SalInH->Invoice_No = _FIELD->Invoice_No }), .not. found())


  /*
  2.11.   ���ଠ�� � ���祭�� ���� Doc_Type ��� ࠧ��� ⨯�� ���㬥�⮢, ⠪�� 㪠���� ��� ������ DBF- 䠩���.
  ���祭�� ���� Doc_Type ��� ࠧ��� ⨯�� ���㬥�⮢, ��ᠥ��� 䠩��� SalOutH � SalInH
  Doc_type        �������� ��     ������ (DBF)   ���ᠭ��
  1       ��室 (+)      salInH  ᪫�� �㤠 ���� ��室
  2       �த��� (+)     saloutH ᪫�� ��㤠 ���� �த���
  3       ������ �� ஧���� (-)  saloutH ᪫�� �㤠 ���� ������
  4       ���ᠭ�� (+)    saloutH ᪫�� ��㤠 ���� ᯨᠭ��
  5       ���४�஢�� (+/-)     saloutH ᪫�� ��� �ந�� ���४��.
  6       ��६�饭�� �� 䨫��� (+)       salInH  ᪫�� �㤠 ���� ��६�饭��
  7       ��६�饭�� � 䨫���� (-)       salInH  ᪫�� ��㤠 ���� ��६�饭��
  8       ���⨥ � ��� (-)        salInH  ᪫�� ��㤠 ���� ��⨥
  9       ������ �ந�����⥫� (-)       salInH  ᪫�� ��㤠 ���� ������
  */

  /*
2.12.   ������ ���ଠ樨 � ������ ��࣮��� ��祪 (䠩� OlDebts)
  ���� ���ଠ�� � ������ �࣮��� �祪, �㦭� ���㦠�� ����� �� ⮫쪮 �� �த�樨 �������.
  � ����� ��⠫�� ����� 㪠�뢠�� �������⥫��� ���ଠ��.
  ����    ����    ���     �����   ���ᠭ��        ���� ��易⥫쭮�
  */

  // ⥪�騥 �����
  SELE OlDebts
  alias_1:=ALIAS()

  SELE deb
  #ifdef DEB_KEGO
    append from tmp_skdt // �������� �� �����騥 ��
  #endif
  SET RELA TO STR(Kpl,7) INTO deb_dz

  SELE deb
  Debts('deb','OlDebts')

  sele (alias_1); copy to (""+alias_1)
  repl all _FIELD->Status with 2
  ///////////////// ////////////////////

  ////// ��娢�� �����
  sele ArDebts
  alias_1:=ALIAS()

  SELE pdeb
  // append from tmp_???? // �������� �窨 �� ������ ���
  SET RELA TO STR(Kpl,7) INTO deb_dz
  SELE pdeb
  Debts('pdeb','ArDebts')

  sele (alias_1); copy to (""+alias_1)
  repl all DebtDate WITH dtEndr //dDt //date()
  ////////////////////////////////////////////

  IF !(UPPER("/init") $ UPPER(cDosParam))
    //�� ��⮢��
    alias_1:="OlDebts"
    sele (alias_1)
    ZAP
  ENDIF


  // outlog(__FILE__,__LINE__, dDt,  dtEndr,  dtBegr)

  /*
2.13.   ������ ���ଠ樨 � ��⠫�� ������ ��࣮��� ��窨 (䠩� OlDebDet)
  ��⠫쭠� ���ଠ�� � ������ �࣮��� �祪.
  �㦭� ���㦠�� ���ଠ�� � ��������� �� ����� ���� ����,
  �� ⮢�ࠬ �㪠�.
  ����    ����    ���     �����   ���ᠭ��        ���� ��易⥫쭮�
  */

  alias_1:='OlDebDet'

  sele skdoc // �� �窨 �������� � tmp_ktt
  SET RELA TO STR(KPL,7) INTO tmp_ktt, STR(Kpl,7) INTO deb

  sele skdoc
  set filt to keg < 30
  DebDet('skdoc','OlDebDet',date(),aMessErr, aKta)

  ///////  ���� //////

  #ifdef DEB_KEGO
    USE tmpKegO ALIAS KegO NEW
    ali_etm:=ALIAS()
    DebDetKeg('KegO','OlDebDet',date(),aMessErr, aKta)
  #else
    sele skdoc
    set filt to keg >= 30
    DebDetKeg30('skdoc','OlDebDet',date(),aMessErr, aKta)
  #endif
    // ��⠢�� ��� ���ਨ
  sele (alias_1); copy to (""+alias_1)
  repl all _FIELD->Status with 2, FIELD->DTLM with DTLM()


  ////////////////////////////////////////////////////////////

  alias_1:='ArDebDet'
  sele trs2 //
  SET RELA TO STR(KPL,7) INTO tmp_ktt, STR(Kpl,7) INTO pdeb

  sele trs2
  set filt to keg < 30
  DebDet('trs2','ArDebDet',dtEndr,aMessErr, aKta)

  sele trs2
  set filt to keg >= 30
  DebDetKeg30('trs2','ArDebDet',date(),aMessErr, aKta)

  // DebDetKeg('KegO','ArDebDet',date())
  // repl all DebtDate WITH dtEndr

  sele (alias_1); copy to (""+alias_1)
  repl all DebtDate WITH dtEndr //dDt //date()


  IF !(UPPER("/init") $ UPPER(cDosParam))
    //�� ��⮢��
    alias_1:="OlDebDet"
    sele (alias_1)
    ZAP
  ENDIF
  close deb_dz
  close skdoc
  close deb
  close trs2
  close pdeb


   /*
2.14    ���ଠ�� � �ਢ離� �� ������ � �� (olpform)
  */

  SELE tmp_ktt
  DBGOTOP()
  DO WHILE !EOF()

   SELE  olpform
   alias_1:=ALIAS()
   DBAPPEND() //�஢�ઠ �� �㡫�  STR(tmp_ktt->kgp,7)+"-"+STR(tmp_ktt->kpl,7)
   /*
  PK      OL_CODE         Character       25      ��� ��  ���
   */
   _FIELD->OL_Code:=STR(tmp_ktt->kgp,7)+"-"+STR(tmp_ktt->kpl,7)

    /*
    FK      PayForm_ID      Numeric 11      �����䨪��� ��� ������.  ��� ��⥣�ਨ ����      ��
    */
    _FIELD->PayForm_ID:=5200000 //䠪�:  5200001 - ����窠

    If !empty(FieldPos('PayF_CODE'))
      _FIELD->PayF_CODE:='1' // c20
    EndIf

   /*
          DTLM    Character       14      ��� _ �� �����_���_� ������   ���
    */
  _FIELD->DTLM := DTLM()
    /*
          Status  Numeric         11      ����� (2 - "��⨢���?, 9 - "����⨢���?)       ���
    */
    _FIELD->Status := 2

    SELE tmp_ktt
    DBSKIP()
  ENDDO
 sele (alias_1); copy to (""+alias_1)


 close tmp_ktt


   //return (NIL)
  /*
2.15.   ������  LOCLPROD (������� ⠡���� ��⠥��� ����������, ��祣� �� ������)
  ������ ���ଠ樨 � �����쭮� �த�樨 � �� �ਢ離�� � ������쭮� ����஢�� �ந�
  ����⥫�.��� ��� �த�樨 � ��⭮� ��⥬� ����ਡ���� ������ ����⢮����
  �ࠢ�筨� ������������.
  � ��砥 ����� � �ࠢ�筨�� ������������ ��⭮� ��⥬� ����ਡ����
  ��������� ४����� 㭨����� ��� �த�樨 �ந�����⥫� (�������� ���),
  ������ ᮡ����� �᫮��� �ਢ離� ��������� ����� � ������� ����� ��� "����-�-������".
  � ��砥 ������������ �����ঠ��� 㭨���쭮�� ������쭮�� ���� �
  ���⭮� ��⥬� ����ਡ����, ᮮ⢥��⢨� �த�⮢ ����� �����ন������ ���祢�
  ���짮��⥫�� �����।�⢥��� � ��⥬� SalesWorks.

  ����室���:
  ॠ�������� ���㧪� ������ � ⠡���� ᫥���饣� �ଠ�.

  ����    ����    ���     �����   ���ᠭ��        ���� ��易⥫쭮�
  */
  SELE mktov
  ORDSETFOCUS("MnTov")
  DBGOTOP()
  DO WHILE !EOF()
    IF !(MnTovT/10000=1) ;
      .OR. !(STR(Sk,3) $ cListSaleSk)
      //DBSKIP();      LOOP
    ENDIF
    IF INT(mntovt/10000) = 250.0
      DBSKIP();      LOOP
    ENDIF
    SELE LocLProd
    alias_1:=ALIAS()
    DBAPPEND()
    /*
    PK      LocalCode       Character       20      ������� ��� �த�樨 �� ��⭮� ��⥬� ����ਡ����        ��
    */
   _FIELD->LocalCode :=allt(STR(mktov->MnTovT))
    /*
          Name    Character       50      �������� �த�樨      ��
    */
    _FIELD->Name := IIF(EMPTY(mktov->Nat),"Name LocalCode "+allt(STR(mktov->MnTovT)),mktov->Nat)
    /*
          ShortName       Character       25      ��⪮� �������� �த�樨      ��
    */
    _FIELD->ShortName := mktov->Nat

    /*
          Weight  Numeric 11,5    ��� ������� �த�樨   ��
    */
    mkcrosr:=getfield('t1','mktov->mntovt','ctov','mkcros')
    nWeight:=getfield('t1','mkcrosr','mkcros','keg')
    IF nWeight > 10 //����
      nWeight:=nWeight/10
    ELSE
      nWeight := getfield('t1','mktov->mntovt','ctov','vesp')
    ENDIF

    _FIELD->Weight := nWeight
    /*
          Pack_Qty        Numeric 14,3    ������⢮ ������ �த�樨 � ��஡��   ��
    */
    _FIELD->Pack_Qty := 1
    /*
          IsMix   Logical 1       ������, ����� 㪠�뢠��, ���� �� �த�� ���ᮬ, ᤥ����� ����ਡ���஬ ��
    */
    _FIELD->IsMix := .F.
    /*
            DTLM    Character       14      ��� � �६� ����䨪�樨 �����..
    ��ଠ�: "YYYYMMDD HH:MM"        ��

    */
    _FIELD->DTLM := DTLM()
    /*
            Status  Numeric 11      ����� (2 - '��⨢��', 9 - '����⨢��')
    �� 㬮�砭�� - 2        ��
    */
    _FIELD->Status := 2

    SELE mktov
    DBSKIP()
  ENDDO
  sele (alias_1); copy to (""+alias_1)
  close mktov

  //QUIT
  /*
  FK      Code    Character       20      ������쭮� ��� �ந�����⥫� �த�樨 (�᫨ �����⥭).
  �᫨ �������⥭ ��� ���� (ᬮ⪠) - ��⠢���� �����.   ��
  */
  /*
  2.16.   ������  LPRODDET (������� ⠡���� ��⠥��� ����������, ��祣� �� ������)
  ������ ��⠫쭮� ���ଠ樨 � ����� (ᬮ⪠�) ����ਡ���� � �� �ਢ離��
  � �����쭮� ����஢�� ����ਡ����.

  ����室���:
  ॠ�������� ���㧪� ������ � ⠡���� ᫥���饣� �ଠ�.
  ����    ����    ���     �����   ���ᠭ��        ���� ��易⥫쭮�
  PK, FK  LocalCode       Character       20      ������� ��� �த�樨 �� ��⭮� ��⥬� ����ਡ����        ��
  PK, FK  CompCode        Character       20      ������� ��� ��������� ���� (ᬮ⪨).        ��
          CompQTY Numeric 14,3    ������⢮ ��������� ����(ᬮ⪨).    ��
          Percentage      Numeric 6,2     ��������� ���祭��� ���� �������� ��������⮢ ���� � ��業⭮� ᮮ⭮襭�� � ���� �᫨ ��������� ���� 1 � ���祭�� 100 �᫨ 2 � �� 50 �� ������� � �.       ��
          Status  Numeric 11      ����� ⮢�� (2 - '��⨢��', 9 - '����⨢��' ��
          DTLM    Character       14      ��� � �६� ����䨪�樨 ����� � �ଠ� "YYYYMMDD HH:MM"      ��
  */
  /*

  2.17.   ��ᯮ�� ���ଠ樨  � ������� -����� (䠩� OlOrderH)-��易⥫쭮
  ����� ���㬥��.
  �� ᮧ����� ���㬥��� � ���, ��易⥫쭮 �㦭� ��࠭��� Order_No, ��� ⮣� �⮡� ������� �� ���祭�� ���㦠�� � 䠩� SalOutH.dbf
  ����    ����    ���     �����   ���ᠭ��        ���� ��易⥫쭮�
  PK      Order_No        Numeric 20      �����䨪��� ���㬥�� (����� ������ � SWE)    ��
  FK      OL_Code Character       25      ��� �� � ���    ��
  FK      OL_ID   Numeric 20      �����䨪��� ��࣮��� �窨 � SWE      ��
          Order_Date      Date    8       �६� � ��� ᮧ�����
  ���㬥��       ��
          Exec_Date       Date    8       ����⥫쭠� ��� �믮������ ������      ��
  FK      PayForm_ID      Numeric 11      �����䨪��� ��� ������.
  ���祭�� �� ��ࠢ�筨�� ��� ������ ���⮫쭮�� �����, �������筮 ��� � 䠩�� PayForms.dbf     ��
          Resp_Pers       Character       50      �⢥��⢥���� ��� (�࣮�� �।�⠢�⥫�)     ��
          Amount  Numeric 19,5    �㬬� ���㬥�� �
  ��⮬ ᪨���   ��
          Discount        Numeric 5,2     ������ � ��業��,%    ��
  FK      MERCH_ID        Numeric 11      �����䨪��� �࣮���� �।�⠢�⥫� � ����� SWE       ��
          Deliv_Addr      Character       255     ���� ���⠢�� � ��     ��
          DOUBLED Logical 1       ���樠��� ��ਡ��
  ����୮�� �ᯮ��
  ���㬥��
  0-���㬥�� �� �� ��ᯮ��஢����
  1-���㬥�� 㦥 �� ��ᯮ��஢��        ��
          COMMENT Character       100     �������ਨ � ������
  ����⥫쭮 �������ਨ �� �⮣� ���� ���㦠�� � ������ ��� ���������, �⮡� �ᯥ����� �� ���⠢�� ����� �ਭ����� �� �������� �� �������ਨ.  ��
          Op_Code Character       20      �����䨪��� ⨯� ����樨 (�᫮��� ������).
  ��� ����樨 �������� � ���⮫쭮� ���㫥 � �ࠢ�筨�� ���� ����権. ��� ������� ����ਡ��� ����ந��� �������㠫쭮. ��.:(1-���., 2-������, 3-�����窠)  ��
          DTLM    Character       14      ��� � �६� ����䨪�樨 ����� � SalesWorks. ���������� ⥪�饩 ��⮩ �믮������ ����樨 �ᯮ��. ��ଠ�: "YYYYMMDD HH:MM"  ��
          TranspCost      Numeric 9,2     �࠭ᯮ��� ��室�
  � ���
  �� ��ࠡ��뢠�� ��
          VatCalcMod      Numeric 11      ����� ���� 業:
  0-業� ��� ���
  1-業� � ���    ��
          VAT_SUM Numeric 19,5    �㬬� ���
          ProxSeries      Character       10      ���� ����७����
  �� ��ࠡ��뢠�� ���
          ProxNumber      Character       20      ����� ����७����
  �� ��ࠡ��뢠�� ���
          ProxDate        Date    8       ��� ����७����
  �� ��ࠡ��뢠�� ���
          Wareh_Code      Character       20      ���譨� ��� ᪫���      ��
          ISRETURN        Numeric 1       ���� �⢥砥� �� �����প�
  ����⥫쭮�� ������⢠ �த�樨 �� ���㬥�� �����-������.
  �� ������ �����⮢ � �� ᫥��� ���뢠�� �� ����� ����� � OLORDERH.DBF ����� �ਧ��� ISRETURN=0, � ������ �㤥� ����� �ਧ���
  ISRETURN=1. ����� ��ࠧ�� ����� ������ ����� �㤥� �⫨��� �� �����⮢
          ��
          TaxFactNo       Character       40      ����� ���������
  ���������
  �� ��ࠡ��뢠�� ���
          Route_id        Numeric 20      �����䨪���
  ������⮢       ���
          DC_ALLOW        Numeric 3       �ਧ��� ������ ��
  �� ��ࠡ��뢠�� ���
          OLDISTCENT      Character       25      ����ਡ����᪨�
  業�� (��� ��)
  �� ��ࠡ��뢠�� ���
          OLDISTSHAR      Numeric (7, 3)  ������ ��� ����ਡ�樨
  �� ��ࠡ��뢠�� ���
          DC_DELIVER      Logical 1       ���⠢�� � ��
  �� ��ࠡ��뢠�� ���
          DC_PAYER        Logical 1       ���⥫�騪 ��
  �� ��ࠡ��뢠�� ���
  */
  /*
  2.18.   ��ᯮ�� ���ଠ樨 � ������� - ��⠫� (䠩� OlOrderD) - ��易⥫쭮
  ������ ������.
  ����    ����    ���     �����   ���ᠭ��        ���� ��易⥫쭮�
  FK      Order_No        Numeric 20      �����䨪��� ���㬥�� (����� ������ � SWE)    ��
  FK      Code    �haracter       20      ��� ⮢�� � ����� �������      ��
          Price   Numeric 12,5    ���� ⮢��     ��
          Qty     Numeric 15,3    ������⢮ ⮢��       ��
          IsReturn        Numeric 11      ����, �����
  㪠�뢠��, ���� ��
  �� �����⭮� ��
          RDiscount       Numeric 5,2     ���祭��
  ������樮���� ᪨��� � ��業��,%      ��
          BasePrice       Numeric 15,8    ������� 業� ⮢�� ���
  ���     ��
          LOCALCODE       �haracter       20      �����쭠� ����஢�� ��� ���
          VAT     Numeric 5,2     ��� � ��業��,%       ��
  */
  /*
  2.19.   ��ᯮ�� ���ଠ樨 � ��࣮��� �।�⠢�⥫�� (䠩� Merchand) - �� ����室�����
  ���ଠ�� � �࣮��� ������: ��� �����, ���, �਩�� ����� ���.
  ��� 䠩� �㦭� ��ࠡ��뢠�� �᫨ ���������� ��⮬���᪠� �ਢ離� ����� ��࣮��� �।�⠢�⥫�� � ���.
  ����    ����    ���     �����   ���ᠭ��        ���� ��易⥫쭮�
  PK      Merch_ID        Numeric 11      �����䨪��� �࣮���� �����  ��
          Merch_Name      Character       50      �������� �࣮���� �����       ��
          DevSer_No       Character       255     ��਩�� ����� ���      ��
          Status  Numeric 11      ����� �� (2 - '��⨢��', 9 - '����⨢��'     ��
  */
IF lPos

//lposost()
    sele LPOSARCH
    append from  (cPth_Plt_lpos+"\LPOSARCH")
    OrdSetFocus('t2') //localcode

    sele LOCALPOS
    //copy file (cPth_Plt_lpos+"\LOCALPOS.dbf") to lpos01.dbf
    append from  (cPth_Plt_lpos+"\LOCALPOS") for Status = 2
    //copy to lpos02

    sele LPOSSIND
    append from  (cPth_Plt_lpos+"\LPOSSIND")
    sele LPOSSINH
    append from  (cPth_Plt_lpos+"\LPOSSINH")
    sele LPOSTRSD
    append from  (cPth_Plt_lpos+"\LPOSTRSD")
    sele LPOSTRSH
    append from  (cPth_Plt_lpos+"\LPOSTRSH")
  /*
1.4.    ������ LOCALPOS
  ���ଠ�� � �����쭮� POS-����㤮�����.

  ����  ����  ��� ����� ���ᠭ��  ����
  ��易⥫쭮�
  PK  LOCALCODE Character 20  ���譨� ��� (��� ��) �����쭮��
  POS-����㤮�����  ��
    NAME  Character 50  �������� �����쭮��
  POS-����㤮����� (������ �� �� ����ਡ����)  ��
  FK  POST_ID Numeric 11  ��� POS-����㤮����� (��� ⨯� ����㤮����� �� ��� - �ࠢ�筨� POS -����㤮�����)  ��
  FK  POSB_ID Numeric 11  �७� POS-����㤮����� ����㤮����� (��� ���� ����㤮����� �� ��� - �ࠢ�筨� POS -����㤮�����) ��
    SERIAL_NO Character 50  ��਩�� �����
  �����쭮�� POS-����㤮����� ���
    INVENT_NO Character 50  �������� �����
  �����쭮�� POS- ����㤮�����  ��
    DATE  Date  8 ��� �������� � �ᯫ���� �����쭮�� POS- ����㤮�����, �᫨ ���� � �� ���, ��������� ���祭��� 1945.05.09
  ��
    CONTR_NO  Character 50  ����� ������஭����
  �������  ��
    CONTR_SD  Date  8 ��� ��砫� ����⢨�
  ������஭���� ������� ��
    CONTR_ED  Date  8 ��� �����襭��
  ����⢨� ������஭���� �������  ���
    PRICE Numeric 15,8  ���� ��� ���  ���
    Status  Numeric 11  ����� ����� 2 -'��⨢��'
    ��
    DTLM  Character 14  ��� � �६�
  ����䨪�樨 ����� � �ଠ� "YYYYMMDD HH:MM" ��
    COMMENTS1 Character 254 �������਩1  ���
    ...
    COMMENTS9 Character 254 �������਩9  ���


  �ᮡ������ ������ ���ଠ樨 � ��娢��� ���⪠� �����쭮�� POS-����㤮�����
  ����������� ����������� ������ ��娢��� ���⪮� �����쭮�� POS-����㤮�����, ⠡���� ������ LPOSARCH.DBF.

  ����� ������������ � ⠡���� tblLocalPOSArchivedStocks �
  tblLocalPOSArchivedStocksDetails ᮮ⢥��⢥���. �� �⮬ �ନ����� ��
  ����� ����� � ⠡��� tblLocalPOSArchivedStocks �� ������ ��㯯� ���祭��
  WAREH_CODE, OL_CODE � STOCKDATE (W_id, Ol_id � StockDate).
  */

//lpos2d()
  /*
1.5.    ������ LPOSARCH
  ���ଠ�� � ��娢��� ���⪠� �����쭮�� POS-����㤮�����.


  ����  ����  ��� ����� ���ᠭ��  ����
  ��易⥫쭮�
  PK,
  FK  WAREH_CODE  Character 20
  ���譨� ��� ᪫��� (��� ᪫��� ����㤮����� � ���)  ���
  PK,
  FK  OL_CODE Character 25  ���譨� ��� �࣮���
  ��窨 (��� ��� � ��)  ���
  PK,
  FK  LOCALCODE Character 20  ���譨� ��� �����쭮��
  POS-����㤮�����  ��
    STOCKDATE Date  8 ��� ��娢�஢����
  ���⪮�  ��
    INSTDATE  Date  8 ��� ��⠭����
  ����㤮�����  ���
    DTLM  Character 14  ��� � �६�
  ����䨪�樨 ����� � �ଠ� "YYYYMMDD HH:MM" ��
    TSIDNUM Character 50  ����� �����஭����
  �������
  ��
    TSIDSDAT  Date  8 ��� ��砫� �����஭���� ������� �����஭���� ������� ��
    TSIDEDAT  Date  8 ��� ����砭��
  �����஭���� ������� ��
  */

//lpos3d()
  /*
1.6.  ������ LPOSSINH
  ���ଠ�� � ��室�� �����쭮�� POS-����㤮����� (蠯��).
  ����  ����  ��� ����� ���ᠭ��  ����
  ��易⥫쭮�
    DATE  Date  8 ��� ��室�/������
  �����쭮�� POS-
  ����㤮�����  ��
  PK  LPOSIN_NO Character 50  ����� ���㬥��
  䠪��᪮�� ��室�/������
  (��䨪� ���-��� ���㬥��) ��
    TOTALSUM  Numeric 19,5  ���� �㬬� ��
  ���㬥��� ���
    VAT Numeric 19,5  �㬬� ��� ���
  FK  DOC_TYPE  Numeric 2 �����䨪��� ⨯�
  ��������:
  11-��室 ����㤮����� �� ���⠢騪�
  12-������ ����㤮����� ���⠢騪�
  13-���४�஢�� �� ����㤮����� (+) (����� ���-�� 㢥��稢�����)
  14-��६�饭�� ����㤮����� �� 䨫���
  15-��६�饭�� ����㤮����� � 䨫����
  18-���४�஢�� �� ����㤮����� (-) - (����� ���-�� 㬥��蠥���)
    ��
  FK  WAREH_CODE  Character 20  ���譨� ��� ᪫��� (��� ᪫��� ����㤮����� � ���)  ��
    INVOICE_NO  Character 58  ����� ��室���
  ��������� ���⠢騪�  ���
    STATUS  Numeric 11  ����� �����
  (2 -'��⨢��',
   9 -'����⨢��') ��
    DTLM  Character 14  ��� � �६�
  ����䨪�樨 ����� � �ଠ� "YYYYMMDD HH:MM" ��
  */

//lpospr()
   /*
1.7.    ������ LPOSSIND
  ���ଠ�� � ��室�� �����쭮�� POS-����㤮����� (��⠫�).
  ����  ����  ��� ����� ���ᠭ��  ����
  ��易⥫쭮�
  PK,
  FK  LPOSIN_NO Character 50  ����� ���㬥��
  䠪�筮�� ��室�/������
  (��䨪� ���-��� ���㬥��) ��
  PK,
  FK  LOCALCODE Character 20  ���譨� ��� �����쭮��
  POS-����㤮����� (��� ����㤮����� �� ��) ��
    PRICE Numeric 15,8  ���� �����쭮�� POS-
  ����㤮�����  ���
    VAT Numeric 5,2 �㬬� ��� ���
  */

  /*

1.9 ������ LPOSTRSH
  ����  ����  ��� ����� ���ᠭ��  ����
  ��易⥫쭮�
    DATE  Date  8 ��� ���㬥��
  ��ଠ�: "DD.MM.YYYY"  ��
    DTLM  Character 14  ��� � �६�
  ����䨪�樨 ����� � �ଠ� "YYYYMMDD HH:MM" ��
  PK  LPOSTH_NO Character 50  ����� ���㬥��
  ��।��
  (��䨪� ���-��� ���㬥��) ��
    STATUS  Numeric 11  ����� �����
  (2 -'��⨢��',
   9 -'����⨢��') ��
    TOTALSUM  Numeric 20,3  ���� �㬬� ��
  ���㬥��� ��।��  ���
    VAT Numeric 20,3  �㬬� ��� ���
  FK  DOC_TYPE  Numeric 2 �����䨪��� ⨯�
  ��������
  16-��।�� ����㤮����� � ஧����
  17-������ ����㤮����� �� ஧����
    ��
  FK  WAREH_CODE  Character 20  ���譨� ��� ᪫��� (��� ᪫��� ����㤮����� � ���)  ��
  FK  OL_CODE Character 25  ���譨� ��� �࣮���
  ��窨 (��� ��� �� �� ����ਡ����) ��
  FK  MERCH_ID  Numeric 11  �����䨪���
  �࣮���� �।�⠢�⥫� (��� �࣮���� �।�⠢�⥫� �� ���)  ���
  ���ଠ�� � ��।�� �����쭮�� POS-����㤮����� � �� (蠯��)
  */

//lpossv()
  /*
1.10    ������ LPOSTRSD
  ���ଠ�� � ��।�� �����쭮�� POS-����㤮����� � �� (��⠫�).
  ����  ����  ��� ����� ���ᠭ��  ����
  ��易⥫쭮�
  PK,
  FK  LPOSTH_NO �haracter 50  ����� ���㬥��
  ��।��
  (��䨪� ���-��� ���㬥��) ��
  PK,
  FK  LOCALCODE �haracter 20  ���譨� ��� �����쭮��
  POS-����㤮����� (��� ����㤮����� �� ��) ��
    PRICE Numeric 15,8  ���� �����쭮�� POS-
  ����㤮�����  ���
    VAT Numeric 5,2 �㬬� ��� ���
    ACCPRICE  Numeric 15,8  ��⭠� 業� ⮢��   ���
    TSCON_NO  Character 50  ����� �����஭����
  �������  ��
    TSCONSD Date  8 ��� ��砫�
  �����஭���� ������� ��
    TSCONED Date  8 ��� ����砭��
  �����஭���� ������� ��
  */


  USE tmpTT ALIAS tmp_ktt NEW EXCLUSIVE
  ZAP
  DBAPPEND()

  SELE  LPOSARCH
  ORDSETFOCUS(0)
  GO TOP
  DO WHILE !EOF()
    tmestor:=VAL(_FIELD->ol_code)
    sele etm
    IF netseek('t1','tmestor')
      ali_etm:="etm"
    ELSE
      sele tmesto
      IF  netseek('t1','tmestor')
        ali_etm:="tmesto"
      ELSE
        IF !EMPTY(tmestor)
          outlog(__FILE__,__LINE__,"!netseek",tmestor,"LPOSARCH",LPOSARCH->(RECNO()))
        ENDIF
        SELE  LPOSARCH
        SKIP
        LOOP
      ENDIF

    ENDIF
      /*
       PK      OL_Code Character       25      ��� ��࣮��� �窨    ��� �� � ���.   ��
      */
      LPOSARCH->OL_Code:=STR((ali_etm)->Kgp,7)+"-"+STR((ali_etm)->Kpl,7)

      IF !OUTLETS->(DBSEEK(LPOSARCH->OL_Code))
        tmp_ktt->(DBAPPEND());        tmp_ktt->Kgp:=(ali_etm)->Kgp;        tmp_ktt->Kpl:=(ali_etm)->Kpl
        cAlias:=ALIAS();         tmp_ktt->(Outlets(RECNO()),@aMessErr) ;        SELECT (cAlias)

        IF !OUTLETS->(DBSEEK(LPOSARCH->OL_Code))
          outlog(__FILE__,__LINE__,"!OUTLETS->(DBSEEK(LPOSARCH->OL_Code))",LPOSARCH->OL_Code)
        ENDIF
      ENDIF

    SELE  LPOSARCH
    SKIP
  ENDDO
    alias_1:=ALIAS()
    sele (alias_1); copy to (alias_1)

  SELE  LPOSSINH
    alias_1:=ALIAS()
    sele (alias_1); copy to (alias_1)

  SELE LPOSSIND
    alias_1:=ALIAS()
    sele (alias_1); copy to (alias_1)

  SELE   LPOSTRSH
  ORDSETFOCUS(0)
  GO TOP
  DO WHILE !EOF()
    tmestor:=VAL(_FIELD->ol_code)

    sele etm
    IF netseek('t1','tmestor')
      ali_etm:="etm"
    ELSE
      sele tmesto
      IF  netseek('t1','tmestor')
        ali_etm:="tmesto"
      ELSE
        outlog(__FILE__,__LINE__,"!netseek",tmestor,"LPOSTRSH",LPOSTRSH->(RECNO()))
        SELE LPOSTRSH
        SKIP
        LOOP

      ENDIF

    ENDIF

      /*
       PK      OL_Code Character       25      ��� ��࣮��� �窨    ��� �� � ���.   ��
      */
      LPOSTRSH->OL_Code:=STR((ali_etm)->Kgp,7)+"-"+STR((ali_etm)->Kpl,7)

      IF !OUTLETS->(DBSEEK(LPOSTRSH->OL_Code))
        tmp_ktt->(DBGOTOP());        tmp_ktt->Kgp:=(ali_etm)->Kgp;        tmp_ktt->Kpl:=(ali_etm)->Kpl
        cAlias:=ALIAS();         tmp_ktt->(Outlets(RECNO()),@aMessErr) ;        SELECT (cAlias)

        IF !OUTLETS->(DBSEEK(LPOSTRSH->OL_Code))
          outlog(__FILE__,__LINE__,"!OUTLETS->(DBSEEK(LPOSTRSH->OL_Code))",LPOSTRSH->OL_Code)
        ENDIF
      ENDIF

      If !empty(FieldPos('MERCH_CODE'))
        _FIELD->MERCH_CODE:=allt(str(LPOSTRSH->MERCH_Id))
      EndIf

    SELE LPOSTRSH
    SKIP
  ENDDO
    alias_1:=ALIAS()
    sele (alias_1); copy to (alias_1)

  SELE LPOSTRSD
    alias_1:=ALIAS()
    sele (alias_1); copy to (alias_1)


  SELE LOCALPOS
    alias_1:=ALIAS()
  DBGOTOP()
  DO WHILE !EOF()
      /*
              DTLM    Character       14      ��� � �६� ����䨪�樨 �����..
      ��ଠ�: "YYYYMMDD HH:MM"        ��

      */
      _FIELD->DTLM := DTLM()
      /*
              Status  Numeric 11      ����� (2 - '��⨢��', 9 - '����⨢��')
      �� 㬮�砭�� - 2        ��
      */
      // _FIELD->Status := 2 l:182 �ய�ᠭ�, �� �㦭�
    DBSKIP()
  ENDDO
  sele (alias_1); copy to (alias_1)
  use

  sele lposarch
    alias_1:=ALIAS()
  DBGOTOP()
  DO WHILE !EOF()
      /*
              DTLM    Character       14      ��� � �६� ����䨪�樨 �����..
      ��ଠ�: "YYYYMMDD HH:MM"        ��

      */
      _FIELD->DTLM := DTLM()
    DBSKIP()
  ENDDO
  sele (alias_1); copy to (alias_1)
  use

  sele lpossind
  use

  sele lpossinh
    alias_1:=ALIAS()
  DBGOTOP()
  DO WHILE !EOF()
      /*
              DTLM    Character       14      ��� � �६� ����䨪�樨 �����..
      ��ଠ�: "YYYYMMDD HH:MM"        ��

      */
      _FIELD->DTLM := DTLM()
      /*
              Status  Numeric 11      ����� (2 - '��⨢��', 9 - '����⨢��')
      �� 㬮�砭�� - 2        ��
      */
      _FIELD->Status := 2
    DBSKIP()
  ENDDO
  sele (alias_1); copy to (alias_1)
  use

  sele lpostrsd
    alias_1:=ALIAS()
  sele (alias_1); copy to (alias_1)
  use

  sele lpostrsh
    alias_1:=ALIAS()
  sele (alias_1); copy to (alias_1)
  use
ENDIF //lPos

   SELE  Outlets
   alias_1:=ALIAS()
   sele (alias_1); copy to (""+alias_1)

  SELE DirBlock
  _FIELD->Blocked:=NO
  _FIELD->App:="Clvrt Lodis Stop"
  #ifdef __CLIP__
  _FIELD->DTLM := DTOC(DATE(),"yyyymmdd")+' '+SUBSTR(TIME(),1,5)
  #endif
  outlog(__FILE__,__LINE__,"Clvrt Lodis Stop")
  CLOSE DirBlock

      FILEDELETE(cPth_Plt_tmp+"\"+"*.cdx")
  IF lZap
    #ifdef __CLIP__
      cLogSysCmd:=""
      cRunSysCmd:=""
      cRunZip:="/usr/bin/zip"

          cFileNameArc:=cPth_Plt_tmp+"\"+"ob"+;
          SUBSTR(DTOS(dtEndr),3)+;
          ".zip"


      cFileList:=cPth_Plt_tmp+"\"+"*.DBF"
      cRunSysCmd:=ATREPL('\',cRunZip+" -j "+cFileNameArc+" "+cFileList,"/")

      cRunSysCmd:=ATREPL('j:',cRunSysCmd,set("J:"))


      SYSCMD(cRunSysCmd,"",@cLogSysCmd)

      outlog(3,__FILE__,__LINE__,cRunSysCmd) //,cLogSysCmd

    #endif
  ENDIF
#ifdef __CLIP__
    IF LEN(aMessErr) > 1
      cMessErr:=""
      AEVAL(aMessErr,{|cElem|cMessErr += cElem })
      // "lhupalenko@meta.ua,
      //SendingJafa("l.gupalenko@ukr.net,lista@bk.ru",{{ "","Error Obolon-Lodis"+" "+DTOC(DATE(),"YYYYMMDD")}},;
      SendingJafa("l.gupalenko@ukr.net",;
      {{ "","Error Obolon-Lodis"+" "+DTOC(DATE(),"YYYYMMDD")}},;
      cMessErr,;
      232)

    ENDIF
#endif

  //cPath_Pilot:=gcPath_ew+"obolon\cus2swe"  //"j:\lodis\obolon\cus2swe"
  //cPth_Plt_tmp:=gcPath_ew+"obolon\cus2swe.tmp" //cPath_Pilot+"\tmp"
  outlog(__FILE__,__LINE__,"cSend=",cSend)
  cFileNameArc:=cPth_Plt_tmp+"\"+"ob"+;
  SUBSTR(DTOS(dtEndr),3)+;
  ".zip"
  cFileArcNew:=cPath_Pilot+"\"+"ob"+;
  SUBSTR(DTOS(dtEndr),3)+;
  ".zip"

  FOR i:=nMaxSelect TO 250
    IF !EMPTY(ALIAS(i))
      //outlog(__FILE__,__LINE__,ALIAS(i),i)
      CLOSE (i)
    ENDIF
  NEXT i

  DO CASE
  CASE cSend = "One"
    AADD(aFileListZip,{cFileNameArc,cFileArcNew})
    OblnSend(aFileListZip,cPth_Plt_tmp,cPath_Pilot)
  CASE cSend = "Full"

    AADD(aFileListZip,{cFileNameArc,cFileArcNew})
    FOR i:=1 TO LEN(aFileListZip)
      //����஢����
      COPY FILE (aFileListZip[i,1]) TO (aFileListZip[i,2])
    NEXT i
    OblnSend(aFileListZip,cPth_Plt_tmp,cPath_Pilot)

  OTHERWISE
    AADD(aFileListZip,{cFileNameArc,cFileArcNew})
  ENDCASE



  RETURN (NIL)

/****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  10-29-14 * 09:40:43pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION DTLM(dDTLM,cTime)
  DEFAULT dDTLM TO DATE()
  DEFAULT cTime TO SecToTime(TimeToSec(TIME()) + 60*45*0)
  #ifdef __CLIP__
  cDTLM:=DTOC(dDTLM,"yyyymmdd")+' '+SUBSTR(cTime,1,8)
  #endif
  RETURN (cDTLM)




/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  10-20-14 * 01:44:08pm
 ����������......... append - ���⮥ ���������
 add - ⮫쪮 䠩� ��ࢮ�� ��娢�
 add � p3 - 㭨��쭮� ���祭��� ����, p4 - ���� ���� 㭨���쭮�� ����.����
 (������� ⮫쪮 㭨����� ���祭��)
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION OblnSend(aFileListZip, cPth_Plt_tmp, cPath_Pilot)
  LOCAL i, k
  LOCAL cCmd, cLogSysCmd
  aFileSend:={;
    {'INISTOCK','add','Wareh_Code+LOCALCODE', {||Wareh_Code+LOCALCODE} },; // init
    {'LOCALPOS','add'},;
    {'LOCLPROD','add','LOCALCODE', {||LOCALCODE} },;
    {'OLDEBTS','add','OL_Code+str(debt,12,2)',{||OL_Code+str(debt,12,2)}},; // add
    {'OLDEBDET','add','OL_Code+comment',{||OL_Code+comment}},; // add
    {'OLLICENS','add'},; // init
    {'OLPFORM','add','OL_Code',{||OL_Code}},;
    {'OUTLETS','add','OL_Code',{||OL_Code}},;
    {'PRLIST','add','str(PayForm_ID)+LocalCode',{||str(PayForm_ID)+LocalCode}},;
    {'ARDEBDET','append'},;
    {'ARDEBTS','append'},;
    {'ARSTOCK','append'},;
    {'LPOSARCH','append'},;
    {'LPOSSIND','append'},;
    {'LPOSSINH','append'},;
    {'LPOSTRSD','append'},;
    {'LPOSTRSH','append'},;
    {'SALINH','append'},;
    {'SALINLD','append'},;
    {'SALOUTH','append'},;
    {'SALOUTLD','append'}}


  // ���� �ᯠ���뢠�� � ��� ������ cus2swe
  OblnUnZip(aFileListZip[1,1],cPath_Pilot)
  // ���뢠�� ���

  If LEN(aFileListZip) > 1

    set translate path off
    For k:=1 To LEN(aFileSend)
      USE (cPath_Pilot+"\"+aFileSend[k,1]+'.DBF') ALIAS (aFileSend[k,1]) NEW Exclusive
      If aFileSend[k,2]='add' .and. len(aFileSend[k])>2
        // ᮧ����� ������
        SELE (aFileSend[k,1])
        ordcreate(,,aFileSend[k,3],)
      EndIf
    Next

    // ��६ ��娢� � 2-��
    For i:=2 To LEN(aFileListZip)
      // �ᯠ����� �� �६����
      OblnUnZip(aFileListZip[i,1],cPth_Plt_tmp)
      For k:=1 To LEN(aFileSend)
        // ������ �� ���������
        If aFileSend[k,2]='append' // .or. aFileSend[k,2]='add'
          SELE (aFileSend[k,1])
          APPEND FROM (cPth_Plt_tmp+"\"+aFileSend[k,1]+'.DBF')

        Elseif aFileSend[k,2]='add' .and. len(aFileSend[k])>2

          // ����� ������ ��� ����������
          USE (cPth_Plt_tmp+"\"+aFileSend[k,1]+'.DBF') ;
          ALIAS (aFileSend[k,1]+'_1') NEW

          // ��� � ��筨���
          dbSetRelat(aFileSend[k,1], aFileSend[k,4]) //, aFileSend[k,3])
          // ����஢���� ��, ������ ��� -> tmpadd
          copy to tmpadd for (aFileSend[k,1])->(!found())
          // copy to tmp!add for (aFileSend[k,1])->(found())

          CLOSE (aFileSend[k,1]+'_1')

          SELE (aFileSend[k,1])
          APPEND FROM tmpadd

        EndIf
      Next
    Next i
    // ����뢠��
    For k:=1 To LEN(aFileSend)
      SELE  (aFileSend[k,1])
      If FieldPos('DTLM')#0
        repl all _FIELD->DTLM with DTLM()
      EndIf
      CLOSE (aFileSend[k,1])
    Next
    set translate path on
  EndIf

  // ����� ��।�� ���
  cCmd:='CUR_PWD=`pwd`; cd /m1/upgrade2/lodis/obolon/cus2swe; ';
  +'./put-ftp.sh;  cd $CUR_PWD'
  cLogSysCmd:=''
  SYSCMD(cCmd,"",@cLogSysCmd)
  outlog(__FILE__,__LINE__,cCmd)

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  05-07-14 * 09:44:25am
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
STATIC FUNCTION Outlets(nRecStart,aMessErr)
 LOCAL cAlias:=ALIAS()
 IF ISNIL(nRecStart)
  DBGOTOP()
 ELSE
  DBGOTO(nRecStart)
 ENDIF
 DO WHILE !EOF()
   kplr:=tmp_ktt->kpl
   kgpr:=tmp_ktt->kgp
   kln->(netseek('t1','kgpr'))
   IF Outlets->(DBSEEK(STR(tmp_ktt->kgp,7)+"-"+STR(tmp_ktt->kpl,7)))
     DBSKIP(); LOOP
   ENDIF
   SELE  Outlets
   DBAPPEND()
   /*
  PK      OL_ID   Numeric 20      �����䨪��� ��࣮��� �窨 .
  ��������� ���祭���=0.  ��ᢠ������� � SWED, ��᫥ ��ࢮ�� ������ ��. ��
   */
   _FIELD->OL_ID:=0
   /*
    PK      OL_Code Character       25      ��� ��࣮��� �窨    ��� �� � ���.   ��
   */
   _FIELD->OL_Code:=STR(tmp_ktt->kgp,7)+"-"+STR(tmp_ktt->kpl,7)
   /*
        Name    Character       255     �ਤ��᪮� �������� ��࣮��� �窨 .   ��
   */
   cNgp:=allt(kln->nkl)
   cNpl:=(kln->(netseek('t1','tmp_ktt->kpl')),  allt(kln->nkl))
   nNN:=kln->NN
   nKkl1:=kln->kkl1
   cDeliv_Addr:=allt(kln->adr)

   _FIELD->Name := cNpl + "-" + cNgp


   kln->(netseek('t1','kgpr'))
   /*
        Trade_Name      Character       255     �������� ��࣮��� �窨 ��
   */
   _FIELD->Trade_Name := allt(kln->nkl)
   /*
        Director        Character       50      ��४�� ��࣮��� �窨 .
    �� 㬮�砭�� '-' - �� ��।������.     ��
   */
   _FIELD->Director := "-"
   /*
        Address Character       255     ���� ��࣮��� �窨 .  ��
   */
   _FIELD->Address := cDeliv_Addr // (��. ���� KPL)
   /*
        Deliv_Addr      Character       255     ���� ���⠢��.         ��
   */
   _FIELD->Deliv_Addr := allt(getfield("t1","kln->knasp","knasp","nnasp"));
                        +" "+allt(kln->adr) // ����. ����
   /*
        Telephone       Character       20      ����. ⥫�䮭 ��࣮��� �窨 .
    �� 㬮�砭�� '-' - �� ��।������.     ��
   */
   _FIELD->Telephone := "-"
   /*
        Fax     Character       20      ���� ��࣮��� �窨 .
    �� 㬮�砭�� '-' - �� ��।������.     ��
   */
   _FIELD->Fax := "-"
   /*
            EMail   Character       50      �����஭�� ����
    � ��襬 ��砥 ���������� ������⢮� ���� ����窨 ��� ������ ���     ��
   */
   _FIELD->EMail := STR(kdopl("027",tmp_ktt->kpl))
   /*
        Accountant      Character       50      ��壠��� ��࣮��� �窨 � ��襬 ��砥 ���������� ����� ��� � ����஢�� ������� � ᮮ⢥�����饬 ��䨪ᮬ:
    �- ���
    � - ���ᮭ
    � - �����
    ���ਬ�� �12345 ��
   */
   _FIELD->Accountant := "C"+"18005" +"_"+CHARREM(" ",_FIELD->OL_Code)
   /*
          Acc_Phone       Character       20      ����䮭 ��壠��� ��࣮��� �窨 .
  �� 㬮�砭�� '-' - �� ��।������.     ��
   */
   _FIELD->Acc_Phone := "-"
   /*
          M_Manager       Character       50      � �裡 � �ॡ������� �� ������� ����室��� ����� ��������� � ����䥩� ������ ��� ���������� ���㦠�� ����� � ����� ��� ��� �࣮��� �祪.
          �� - ��� 1-2-� ���筠�. �᫨ ��� �� ����� ����� ���, �
  ���� ᫥��� ��������� ���祭��� 0.     ��
   */
   _FIELD->M_Manager := "0"
   /*
        MM_Phone        Character       20      ����䮭 ⮢�஢���.
   �� 㬮�砭�� '-' - �� ��।������.     ��
   */
   _FIELD->MM_Phone := "-"
   /*
          P_Manager       Character       50      ��ᯥ���� ��࣮��� �窨 .
  �� 㬮�砭�� '-' - �� ��।������.     ��
   */
   _FIELD->P_Manager := "-"
   /*
        Open_Time       Character       5       �६� ������ ��࣮��� �窨 � �ଠ� 'hh:mm'. �� 㬮�砭�� '08:00'.  ��
   */
   _FIELD->Open_Time := "08:00"
   /*
        Close_Time      Character       5       �६� ������� ��࣮��� �窨 � �ଠ� 'hh:mm'. �� 㬮�砭�� '20:00'.  ��
   */
   _FIELD->Close_Time := "20:00"
   /*
        Break_From      Character       5       �६� ��砫� ����뢠 � �ଠ� 'hh:mm'.
   �� 㬮�砭�� '13:00'.   ��
   */
   _FIELD->Break_From := "13:00"
   /*
          Break_To        Character       5       �६� �����砭�� ����뢠 � �ଠ� 'hh:mm'.
  �� 㬮�砭�� '14:00'.   ��
   */
   _FIELD->Break_To := "14:00"
   /*
          ZKPO    Character       20      ��� 򄐏�.
  �� 㬮�砭�� '-' - �� ��।������.     ��
   */
   _FIELD->ZKPO := LTRIM(STR(nKkl1))  //LTRIM(STR(nNN)) //  01-19-18 10:25pm
   /*
          IPN     Character       20      ��� ���.
  �� 㬮�砭�� '-' - �� ��।������.     ��
   */
   _FIELD->IPN := LTRIM(STR(nNN)) //"-"  LTRIM(STR(nKkl1)) //  01-19-18 10:25pm
   /*
          VATN    Character       20      ����� ���⥫�騪� ���
  �� 㬮�砭�� '-' - �� ��।������.     ��
   */
   _FIELD->VATN := "-"
   /*
          RR      Character       20      �\�.
  �� 㬮�砭�� '-' - �� ��।������.     ��
   */
   _FIELD->RR := "-"
   /*
          BankCode        Character       20      ��� �����.
  �� 㬮�砭�� '-' - �� ��।������.     ��
   */
   _FIELD->BankCode := "-"
   /*
          BankName        Character       50      �������� �����.
  �� 㬮�砭�� '-' - �� ��।������.     ��
   */
   _FIELD->BankName := "-"
   /*
          BankAddr        Character       50      ���� �����.
  �� 㬮�砭�� '-' - �� ��।������.     ��
   */
   _FIELD->BankAddr := "-"
   /*
          DTLM    Character       14      ��� � �६� ����䨪�樨 �����. ��ଠ�: "YYYYMMDD HH:MM"       ��
   */
  #ifdef __CLIP__
  _FIELD->DTLM := DTOC(DATE(),"yyyymmdd")+' '+SUBSTR(TIME(),1,5)
  #endif
   /*
          CONTR_NUM       Character       50      ����� �������  ���
   */
    nDogNum:=getfield('t1','kplr','klndog','NDog')
   _FIELD->CONTR_NUM:=IIF(EMPTY(nDogNum),"-","SL-"+allt(STR(nDogNum)))

   /*
          CONTR_DATE      Date    8       ��� ��砫� ����⢨� �������.
  �᫨ ��� ������ - ��������� ���祭��� 01.01.1899.       ���
   */
  #ifdef __CLIP__
    dtDogBr:=getfield('t1','kplr','klndog','dtDogB')
   _FIELD->CONTR_DATE := IIF(EMPTY(dtDogBr),CTOD("01.01.1899","DD.MM.YYYY"),dtDogBr)
  #endif
   /*
          CNTR_DT_F       Date    8       ��� ����砭�� ����⢨�  �������
  �᫨ ��� ������ - ��������� ���祭��� 01.01.1900.       ���
   */
  #ifdef __CLIP__
    dtDogEr:=getfield('t1','kplr','klndog','dtDogE')
   _FIELD->CNTR_DT_F := IIF(EMPTY(dtDogEr),CTOD("01.01.1900","DD.MM.YYYY"),dtDogEr)

  #endif
   /*
          Status  Numeric 11      ����� ��   (2 - '��⨢���',   9 - '����⨢��� (�������))     ��
   */
   _FIELD->Status:=2
   /*
          PComp_Code      Character       25      ���譨� ��� �ਤ��᪮�� ���.
  ���祭�� ���㦠�� �������筮 ��� � � 䠩� ParComp.dbf  ���
   */
   _FIELD->PComp_Code:=STR(tmp_ktt->kpl,7)
    If !empty(FieldPos('PComp_id'))
      _FIELD->PComp_id:=_FIELD->PComp_Code
    EndIf
   /*
          Lic_Usage       Numeric 5       �롮� ����஫�
  ��業��� (0 - ��  �ᯮ�짮����,   1- �  �।�०������, 2-  � ����⮬)
  ��������� - 1   ��
   */
   _FIELD->Lic_Usage := 1
    /*
  FK      Owner_ID        Numeric 11      �����䨪��� �������� ��࣮��� �窨 .
  ��� ��, ����� ������� � 䠩��� �ᯮ�� Merchand.dbf, ���� Merch_id           ��
    */
    nIdLod:=getfield('t1','tmp_ktt->kta','s_tag','idlod')
    DO WHILE .T.
      IF nIdLod < 5200000
        nIdLodOld:=nIdLod
        nIdLod:=getfield('t1','nIdLod','s_tag','idlod')
        IF nIdLodOld = nIdLod .OR. nIdLod = 0
          nIdLod:=9990000+tmp_ktt->kta //9990

          IF getfield('t1','tmp_ktt->kta','s_tag','DeviceId') > 0 //ࠡ�稩 ��
            IF ASCAN(aMessErr,"�� ���� ��� ��'-' "+STR(tmp_ktt->kta))=0
              AADD(aMessErr,"�� ���� ��� ��'-' "+STR(tmp_ktt->kta)+;
              " ��� �� "+_FIELD->OL_Code+;
              CHR(10)+CHR(13))
            ENDIF
          ENDIF

          EXIT
        ENDIF
      ELSE
        EXIT
      ENDIF
    ENDDO
    /*
    IF nIdLod < 5200000
      nIdLod:=getfield('t1','nIdLod','s_tag','idlod')
    ENDIF
    */
   _FIELD->Owner_ID := nIdLod
    /*
    */
    If !empty(FieldPos('MERCH_CODE'))
       ktar   := s_tag->(__dbLocate({|| _FIELD->idlod = nIdLod }), _FIELD->kod)
      //_FIELD->MERCH_CODE:=allt(str(tmp_ktt->kta))
      _FIELD->MERCH_CODE:=allt(str(ktar))

    EndIf

    SELE tmp_ktt

     IF ISNIL(nRecStart)
        DO WHILE kplr = tmp_ktt->kpl .and. kgpr = tmp_ktt->kgp
          DBSKIP()
        ENDDO
     ELSE
       EXIT
     ENDIF

  ENDDO
  /*
  FK      SubType_ID      Numeric 11      �����䨪��� ���⨯� ��࣮��� �窨 .
  �� 㬮�砭�� 0 -�� ��।������.
  ����⥫쭮 �।�ᬮ���� � ����䥩� ������ ���� �㤠 ����� �㤥� ���⠢��� �᫮��� ���祭�� ���� ���⨯� �࣮��� �窨      ��
  FK      Area_ID Numeric 11      �����䨪��� ࠩ��� � ���஬ ��室���� �࣮��� �窠.
  �� 㬮�砭�� 0 - �� ��।������. ����⥫쭮 �।�ᬮ���� � ����䥩� ������ ���� �㤠 ����� �㤥� ���⠢��� �᫮��� ���祭�� ���� ࠩ���(��த�) � ���஬� �ਭ������� ���.  ��
          DC_ALLOW        Numeric 3       �ਧ��� ������ ����ਡ����᪮��  業��
  0,�᫨ �� ��।������. ���
          OLDISTCENT      Character       25      ����ਡ����᪨�
  業�� (��� ��) ��⠢��� �� ����������. ���
          OLDISTSHAR      Numeric (7, 3)  ������ ��� �
  ����ਡ�樨   ��⠢��� �� ����������.        ���
          DC_DELIVER      Logical 1       ���⠢�� � ��  0, �� �������祭�.    ���
          DC_PAYER        Logical 1       ���⭨� ��   0, �᫨ �� ��।������.        ���
  */

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  08-08-14 * 09:08:03am
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION OblnOrdZap(lAppend)
  DEFAULT lAppend TO .F.
  cPath_Order:=gcPath_ew+"obolon\swe2cus"  //"j:\lodis\obolon\cus2swe"


  #ifdef __CLIP__
    set translate path off
  #endif

  OblnDirBlock(cPath_Order,"Clvrt Lodis Start Order")

  USE (cPath_Order+"\"+"PAYMENTS.DBF") ALIAS pnm NEW EXCLUSIVE
  ZAP
  If lAppend
    append from PAYMENTS.DBF
  EndIf
  CLOSE

  USE (cPath_Order+"\"+"OLORDERH.DBF") ALIAS OrdH NEW EXCLUSIVE
  ZAP
  If lAppend
    append from olorderh.dbf
  EndIf
  CLOSE

  USE (cPath_Order+"\"+"OLORDERD.DBF") ALIAS OrdD NEW EXCLUSIVE
  ZAP
  If lAppend
    append from olorderd.dbf
  EndIf
  CLOSE

  #ifdef __CLIP__
    set translate path on
  #endif

  SELE DirBlock
  _FIELD->Blocked:=NO
  _FIELD->App:="Clvrt Lodis Stop"
  #ifdef __CLIP__
  _FIELD->DTLM := DTOC(DATE(),"yyyymmdd")+' '+SUBSTR(TIME(),1,5)
  #endif
  CLOSE DirBlock

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  07-09-14 * 01:11:51pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION ObolonOrder()
  LOCAL lerase:=.T., lDelFile:=.T.,lCreTtn0_4Zdn
  LOCAL cDosParam, nKta, nPosS
  LOCAL nCntRec, nZenNew

  IF !lerase_lrs(lerase)
    outlog(3,__FILE__,__LINE__,'//� ᫥���騩 ࠧ')
    RETURN
  ENDIF


  tzvk_crt()
  luse('lphtdoc')
  luse('lrs1')
  luse('lrs2')

  netuse('cskl')
  netuse('etm')
  netuse('stagtm')
  netuse('s_tag')
  netuse('ctov')

  netuse('mkcros')


  cPath_Order:=gcPath_ew+"obolon\swe2cus"  //"j:\lodis\obolon\cus2swe"

      FILEDELETE("cPath_Order\*.cdx")

  #ifdef __CLIP__
    set translate path off
  #endif

  OblnDirBlock(cPath_Order,"Clvrt Lodis Start Order") //�᫨ �஡����, � QUIT
  //outlog(__FILE__,__LINE__,cPath_Order)

  USE (cPath_Order+"\"+"PAYMENTS.DBF") ALIAS pnm NEW READONLY

  USE (cPath_Order+"\"+"OLORDERH.DBF") ALIAS OrdH NEW READONLY

  USE (cPath_Order+"\"+"OLORDERD.DBF") ALIAS OrdD NEW READONLY


  #ifdef __CLIP__
    set translate path on
  #endif
  //SELE pnm
  //INDEX ON Order_No TO t1

  SELE OrdH
  INDEX ON Merch_Id TO OrdH

  SELE OrdD
  INDEX ON Order_No TO OrdD

  cDosParam:=UPPER(DosParam())
  //cgSk241_Merch:=

  nKta:=kta_DosParam(cDosParam,'/kta=',3)
  nOrdN:=kta_DosParam(cDosParam,'/ordn=',12)


  If !Empty(nKta)
    // ���ᨬ ��� �⮣� ���
    Ktar:=nKta
    nMerch_Id:=getfield('t1','Ktar','s_tag','idlod')

    SELE OrdH
    DBSeek(nMerch_Id)
    copy to OrdH while nMerch_Id = Merch_Id ;
      for  Order_Date = Date() // -2
    close OrdH
    use OrdH new

    sele pnm
    copy to pnm for Pay_Date = Date() // -2
    close pnm
    use pnm new

  EndIf

  //ktar   := s_tag->(__dbLocate({|| _FIELD->idlod = OrdH->Merch_Id }), _FIELD->kod)

  SELE OrdH
  DBGOTOP()

  DO WHILE !EOF()
    If !Empty(nOrdN)
      If OrdH->Order_No # nOrdN
        skip;       loop
      EndIf
    EndIf
    If Empty(nKta)
      ktar   := s_tag->(__dbLocate({|| _FIELD->idlod = OrdH->Merch_Id }), _FIELD->kod)
      IF .T. .AND. IIF(EMPTY(nKta),.F.,s_tag->kod # nKta)
        skip;       loop
      ENDIF
    EndIf

    kopr   := VAL(OrdH->Op_Code)
    kopir  := kopr

    IF OrdH->IsReturn = 1
      vor=1  //������
      kopr=108
      // kopir  - ��⠭���� �०��� ��� �������
      // !!  �-�� ����⥫쭮� Qty
    ELSE
      vor:=9 // ॠ������
    ENDIF

    //�஢�ઠ �� �ਭ���������� ��� ������� ᪫���
    Sklr   := 888
    DO CASE
    CASE allt(OrdH->Wareh_Code)="999"
      SkVzr := 232
       Sklr := 232
      If kopir=169
        kopr   := 107
        Sklr := 263 // �ࠪ 169
      EndIf
    CASE allt(OrdH->Wareh_Code)="997"
      SkVzr := 700
      Sklr := 700
      If kopir=169
        kopr   := 107
        Sklr := 705 // �ࠪ 169
      EndIf

    CASE allt(OrdH->Wareh_Code)=="1" ;
      .OR. allt(OrdH->Wareh_Code)="232"
      SkVzr := 232
      Sklr := 232

    CASE allt(OrdH->Wareh_Code)="238" // ���
      SkVzr := 232
      Sklr := 238

    CASE allt(OrdH->Wareh_Code)="704"
      SkVzr := 700
      Sklr := 704

    CASE  allt(OrdH->Wareh_Code)="1000";
      .OR. allt(OrdH->Wareh_Code)="1001"
      SkVzr := 232
      If kopir=169
        Sklr := 263 // �ࠪ 169
      Else
        Sklr := 262 // �ࠪ
      EndIf
      //Sklr := 232
    CASE allt(OrdH->Wareh_Code)="703"
      SkVzr := 700
      Sklr := 703

    CASE allt(OrdH->Wareh_Code)=="2"
      SkVzr := 700
      Sklr := 700

    CASE  allt(OrdH->Wareh_Code)="7000";
      .OR. allt(OrdH->Wareh_Code)="7001"
      SkVzr := 700
      If kopir=169
        Sklr := 705 // �ࠪ 169
      Else
        Sklr := 704 // �ࠪ
      EndIf
      //Sklr := 700
    ENDCASE

    IF !cSkl->(check_skl(Sklr))
      skip
      LOOP
    ENDIF
    // �����஢�� ��ࠡ�⪨ �-⮢ �믨ᠭ��� � ��ਮ� � ⥪�饬 � ����� �����
    If BOM(OrdH->Order_Date) == BOM(gdTd) ;
      .or. BOM(OrdH->Order_Date) == BOM(addmonth(gdTd,-1))
      // ��!
    ELSE
      skip
      loop
    EndIf

    lrs1->(DBGoBottom())
    ttnr:=lrs1->ttn
    ttnr:=ttnr+1


     DtRor:=if(empty(OrdH->Exec_Date),date(),OrdH->Exec_Date) //��� ���⠢��

     TimeCrtFrmr := DTOC(OrdH->Order_Date,'YYYY-MM-DD')+"T"+"00:00:00"
     TimeCrtr  := DTOC(STOD(left(OrdH->DTLM,8)),'YYYY-MM-DD');
     +"T"+substr(OrdH->DTLM,10)
     OrdH->DTLM
     DocIDr    := RTRIM(STR(OrdH->Order_No)) //+"."+allt(OrdH->Wareh_Code)

     Commentr  := win2lin(OrdH->Comment) //OrdH->Comment //
                   // outlog(__FILE__,__LINE__,OrdH->Comment,'OrdH->Comment')
                   // outlog(__FILE__,__LINE__,Commentr,'Commentr')
     Sumr      := OrdH->Vat_sum

     // _FIELD->OL_Code:=STR(tmp_ktt->kgp,7)+"-"+STR(tmp_ktt->kpl,7)
     //kplr   := VAL(RIGHT(allt(OrdH->OL_Code),7))
     //kgpr   := VAL(LEFT(allt(OrdH->OL_Code),7))

    nPosS:=AT('-',OrdH->Ol_code)
    kgpr := VAL(LEFT(OrdH->Ol_code,nPosS-1))
    kplr := VAL(SUBSTR(LTRIM(OrdH->Ol_code), nPosS+1))

     ttncr  := 1 // �㦭� ���� �� ���? (0,1)

     DO CASE
     CASE .F. //kopr = 160
       ttncr  := 0
     ENDCASE

     IF OrdD->(DBSEEK(OrdH->Order_No))

       sele lrs1

       netadd()
       netrepl('DtRo',{DtRor})

       if at('�=',Commentr) # 0 // ������� �� ����� �����
         netrepl('ztxt',{Commentr})
       else
         netrepl('npv',{Commentr})
       endif

       netrepl('TimeCrtFrm,TimeCrt,DocGUID,Sdv',;
               {TimeCrtFrmr,TimeCrtr,DocIDr,Sumr})
       netrepl('Skl,ttn,vo,kop,kopi,kpl,kgp,kta,ddc,tdc',;
              {Sklr,ttnr,vor,kopr,kopir,kplr,kgpr,ktar,date(),time()})
       netrepl('ttnp,NdVz',{ttncr,SkVzr})

      //�ନ�㥬 蠯��
      OrdD->(DBSEEK(OrdH->Order_No))
      DO WHILE OrdD->Order_No = OrdH->Order_No
        //�ନ�㥬 ��ப�
        ttnr := ttnr
        If OrdH->PayForm_Id = 5200002
          If VAL(OrdD->LocalCode) = 228
            mntovr := 228 // ���� 30�
          Else  // 313
            mntovr := 229 // ���� 50� (219)
          EndIf
        Else
          mntovr := OblMnTov(VAL(OrdD->LocalCode))
        EndIf

        /*
           !!KegaVolOrd
           // <- ���� �� ��ॢ���� �.�. �����뢠�� � �����
        nVolume:=1
        */
        nVolume:=KegaVol('mntovr')
        kvpr   := ABS(OrdD->Qty * nVolume)
        zenr   := OrdD->Price / nVolume

        If allt(OrdH->Wareh_Code) $ '999;997' // ��८業��
          // �믨�뢠���� �� �� ⮢�� � ��� 業���
          If .T. ///kopir=169

            // ����� ⮢��
            sele lrs2
            netadd()
            netrepl('ttn,mntov,kvp,zen',{ttnr,mntovr,kvpr,zenr},)

            // ���� ��ப� ��८業��
            cAddNat:=""
            nZenNew:=AktsSWZen(mntovr, Kgpr, Kplr, DtRor, @cAddNat)
            zenr:=nZenNew

            If !IsNil(nZenNew) // 業� ��� - ���
              sele lrs2
              outlog(3,__FILE__,__LINE__,"zenr,nZenNew",zen,nZenNew)
              netadd()
              netrepl('ttn,mntov,kvp,zen',{ttnr,mntovr,kvpr,zenr},)
            EndIf

            exit // ��६ ���� ��ப� �� �-�

          Else
            If ActSWChk(mntovr, kgpr, kplr, DtRor)
              sele lrs2
              netadd()
              netrepl('ttn,mntov,kvp,zen',{ttnr,mntovr,kvpr,zenr},)
            Else
            EndIf
          EndIf
        else

          If int(Mntovr/10000) > 1 // ⮢�� (�� �� � �� �⥪��)
            Act_MnTov4_MnTov()
            // �ਢ������ ⮢�� � 業� ��� ��樨
            MnTovNotActsr:=0
            cAddNat:=""
            cAddNat:=(cAddNat:="", nZenNew:=AktsSWZen(mntovr, Kgpr, Kplr, DtRor, @cAddNat),cAddNat) //, nMnTovNotActs,cPath_Order)
            //nZenNew:=AktsSWZen(MnTovr,Kgpr,Kplr, DtRor, @cAddNat, @MnTovNotActsr)
            If !empty(nZenNew)
              outlog(3,__FILE__,__LINE__,'zenr,nZenNew,MnTovr,MnTovNotActsr',;
               allt(str(zenr)),allt(str(nZenNew)),allt(str(MnTovr)),allt(str(MnTovNotActsr)))
              outlog(3,__FILE__,__LINE__,'    ',cAddNat)
              //MnTovr:=MnTovNotActsr
              zenr:=nZenNew
            EndIf
          EndIf

          sele lrs2
          netadd()
          netrepl('ttn,mntov,kvp,zen',{ttnr,mntovr,kvpr,zenr},)
        endif

        SELE OrdD
        DBSKIP()
      ENDDO
    ELSE
      outlog(__FILE__,__LINE__,'��� ��ப OrdD->(DBSEEK(OrdH->Order_No))',OrdH->Order_No)
    ENDIF

    If allt(OrdH->Wareh_Code) $ '999;997' // ��८業��

      sele lrs1
      netrepl('nnz', {allt(OrdH->Wareh_Code)}) // ��� ������� ��������
      If kopir=169
        netrepl('npv',{"-169"}) // �� �㦭� ���᪠ ��������
      EndIf

      // �஢�ઠ �� �-�� ��ப
      sele lrs2
      ordsetfocus('t1')
      netseek('t1','ttnr')
      count to nCntRec while  ttnr = ttn
      If nCntRec = 2 //.and. iif(kopir=169,!Empty(nOrdN),.T.)  // ��ଠ�쭮

        sele lrs2
        netseek('t1','ttnr') // ��ࢠ� ��ப� �᭮���� ⮢��
        DBSkip()
        netrepl('ttn', {ttn+1})// ���� ��ப� ���㧪� ��樨

        // �������⥫쭮 �ନ�㥬 蠯�� ��� ��室�
        sele lrs1
        arec:={}; getrec()
        netadd(); putrec()
        netrepl('ttn,vo', {ttn+1,9})
        netrepl('nnz', {''})

        netrepl('kop,kopi', {173,173})
        If kopir=169
          netrepl('kop,kopi', {173,169})
        EndIf

      Else
        If kopir=169
          outlog(__FILE__,__LINE__,'DELE  kopir=169',lrs1->kopi,OrdH->Order_No)
        EndIf
        If .not. nCntRec = 2
          outlog(__FILE__,__LINE__,'DELE �� ��୮� �-�� ��ப ��८業��',OrdH->Order_No, nCntRec)
        EndIf
        sele lrs2
        netseek('t1','ttnr')
        DBEval({||netdel()},,{||ttnr = ttn})
        sele lrs1
        netdel()
      EndIf

    EndIf

    SELE OrdH
    DBSKIP()
  ENDDO

  SELE pnm
  DBGOTOP()
  DO WHILE !EOF()
    ktar   := s_tag->(__dbLocate({|| _FIELD->idlod = pnm->Merch_Id }), _FIELD->kod)
    IF .T. .AND. IIF(EMPTY(nKta),.F.,s_tag->kod # nKta)
      skip;       loop
    ENDIF
    If date() # pnm->Pay_Date
      skip;       loop
    ENDIF

    nPosS:=AT('-',pnm->Ol_code)
    kgpr := VAL(LEFT(pnm->Ol_code,nPosS-1))
    kplr := VAL(SUBSTR(LTRIM(pnm->Ol_code), nPosS+1))

    tzvk_ztxt(kplr,kgpr,;
    win2lin(pnm->Reason),; //pnm->Reason,; //
    0)
    tzvk->dvp:=pnm->Pay_Date

    SELE pnm
    DBSKIP()
  ENDDO
  //sele tzvk
  //browse()


  SELE DirBlock
  _FIELD->Blocked:=NO
  _FIELD->App:="Clvrt Lodis Stop"
  #ifdef __CLIP__
  _FIELD->DTLM := DTOC(DATE(),"yyyymmdd")+' '+SUBSTR(TIME(),1,5)
  #endif
  CLOSE DirBlock


  // ������� ������� �� ������ਥ�
  sele lrs1
  If !empty(nKta)
    copy to ('lrs1'+padl(allt(str(nKta,3)),3,'0'))
  EndIf
  //copy to lrs1_1
  DBGoTop()
  DBEval(;
  {|| tzvk_ztxt(kpl, kgp, ztxt, ttn, ,lrs1->Ddc),;
   _FIELD->ztxt:='' },;
  {|| !empty(ztxt) };
  )

  Ktar:=nKta

  // �஢�ઠ �� ����稥 蠯��
  CreTtn0_4Zdn(.T.) // '/NEWZDN' $ upper(cDosParam))

  sele tzvk
  copy to ('tzvk'+PADL(LTRIM(str(ktar)),3,'0'))
  copy to ('tzvk_lrs')

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  08-08-14 * 09:14:27am
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
STATIC FUNCTION  OblnDirBlock(cPth_Plt, cApp)
  //䠩� �����஢��
  USE (cPth_Plt+"\"+"DIRBLOCK.DBF") ALIAS DirBlock NEW EXCLUSIVE
  IF NETERR()
    copy file (cPth_Plt+"\"+"DIRBLOCK.DBF") to DIRBLOCK.DBF

    USE ("DIRBLOCK.DBF") ALIAS DirBlock NEW READONLY

    outlog(__FILE__ ,__LINE__, _FIELD->Blocked, _FIELD->App, _FIELD->DTLM)
    outlog(__FILE__,__LINE__ ,"NETERR(4) DirBlock")
         set print to clvrt.log ADDI
         ?"Stop NETERR(4) DirBlock" ,  _FIELD->Blocked, _FIELD->App, _FIELD->DTLM
    QUIT
  ELSE
    IF LASTREC()=0
      DBAPPEND()
    ENDIF
    IF _FIELD->Blocked
      IF  allt(_FIELD->App) = cApp
        //��१����, ��諮 ���਩��
        outlog(__FILE__ ,__LINE__, "ReStart",_FIELD->Blocked, _FIELD->App, _FIELD->DTLM,"��१����, ��諮 ���਩��")
      ELSE
        outlog(__FILE__ ,__LINE__, _FIELD->Blocked, _FIELD->App, _FIELD->DTLM)

         set print to clvrt.log ADDI
         ?"Stop Blocked",  _FIELD->Blocked, _FIELD->App, _FIELD->DTLM

        QUIT
      ENDIF
    ELSE
    ENDIF
      SELE DirBlock
      If RLock()
        _FIELD->Blocked:=YES
        _FIELD->App:=cApp

        #ifdef __CLIP__
        _FIELD->DTLM := DTOC(DATE(),"yyyymmdd")+' '+SUBSTR(TIME(),1,5)
        #endif
      else

      EndIf
  ENDIF
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  10-13-14 * 11:43:00am
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
STATIC FUNCTION iMax(cDosParam)
  LOCAL iMax:=1
  DO CASE
  CASE (UPPER("/get-date") $ UPPER(cDosParam))
    iMax:=1
  CASE (UPPER("/no_mkotch") $ UPPER(cDosParam))
    iMax:=1
  CASE (UPPER("/dt") $ UPPER(cDosParam))
    iMax:=1
  ENDCASE
  RETURN (iMax)




    /*
    outlog(3,__FILE__,__LINE__,STR(tmp_ktt->Kgp,7)+"-"+STR(tmp_ktt->Kpl,7))
    tmp_ktt->(GoBottomFilt(STR(tmp_ktt->Kpl)))
    outlog(3,__FILE__,__LINE__,STR(tmp_ktt->Kgp,7)+"-"+STR(tmp_ktt->Kpl,7))
    tmp_ktt->(GoBottomFilt(STR(tmp_ktt->Kpl,7)))
    outlog(3,__FILE__,__LINE__,STR(tmp_ktt->Kgp,7)+"-"+STR(tmp_ktt->Kpl,7))
    */



    #ifdef OB_AKCZIZ
    // �饬 ��樧
    SELECT mkdoc
    nRecNo:=RECNO()
    DO WHILE  nSk = _FIELD->Sk .AND.     nTtn = _FIELD->Ttn
      //  ���� ��� ��� ��樧� �� ��㯯�
      kg_r=int(mntov/10000)
      if !empty(getfield('t1','kg_r','cgrp','nal'))

        (alias_1)->param1 := 2

        exit
      endif
      DBSKIP()
    ENDDO
    DBGoTo(nRecNo)
    #endif

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  02-23-17 * 05:46:04pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
STATIC FUNCTION Wareh_Code(nSk, lNumDoc)
  LOCAL cSk:=allt(STR(nSk))
  DEFAULT lNumDoc TO .F.

  If STR(nSk) $ OB_LIST_BRAK_S
    cSk :=  iif(lNumDoc .and. nSk#262,'O','')
     cSk += allt(STR(262))
     //cSk +=  iif(lNumDoc,'('+allt(STR(nSk))+')','')
  ELSEIF STR(nSk) $ OB_LIST_BRAK_K
    cSk :=  iif(lNumDoc  .and. nSk#704,'O','')
    cSk += allt(STR(704))
    //cSk += iif(lNumDoc,'('+allt(STR(nSk))+')','')
  EndIf
  RETURN (cSk)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  03-16-17 * 01:19:39pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
STATIC FUNCTION nIdLod(cFldSeek, aMessErr, aKta)

    nIdLod:=getfield('t1',cFldSeek,'s_tag','idlod')
    DO WHILE .T.
      IF nIdLod < 5200000
        nIdLodOld:=nIdLod
        //outlog(__FILE__,__LINE__,mkdoc->kta,nIdLod)
        nIdLod:=getfield('t1','nIdLod','s_tag','idlod')
        //outlog(__FILE__,__LINE__,nIdLod)
        IF nIdLodOld = nIdLod .OR. nIdLod = 0
                //5200000

          nIdLod := 9990000 + _FIELD->kta //9990
          IF _FIELD->SK = 700 //᪫�� ����⮯
            nIdLod:= 5200861
          ELSE
            nIdLod:= 5200020
          ENDIF
          If !(_FIELD->Sk = 263)
            AADD(aMessErr,"�� ���� ��� ��'-' "+STR(_FIELD->kta)+;
            " ��� ���(alias:"+alias()+")";
            + DTOS(iif(!empty(FieldPos('DTtn')),_FIELD->DTtn,_FIELD->DOP)) ;
            +" "+ STR(_FIELD->Sk)+" "+STR(_FIELD->Ttn)+;
            CHR(10)+CHR(13))
            AADD(aMessErr,"    ���� ��� (���) ����� �த�� "+STR(nIdLod)+;
            CHR(10)+CHR(13))
          EndIf


          AADD(aKta,_FIELD->kta)  // �� "��⮤���..." ��� ���� ��
          //DBSKIP();      LOOP    // �� ���㦠��

          EXIT
        ENDIF
      ELSE
        EXIT
      ENDIF
    ENDDO
  RETURN (nIdLod)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  06-21-17 * 00:03:26am
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION oblswr()
  // ᮡ��� � ����
  // JoinMkDt(027, STOD('20161101'), EOM(STOD('20161101')))
  //

  netuse('ctov')
  netuse('mkcros')

  use mkdoc027 alias mkdoc new  Exclusive

  If .T.
    repl all _FIELD->Dcl with 0
    DBGoTop()
  Else
    DBGoBottom()
    DBSkip()
  EndIf

  t1:=SECONDS()
  DO WHILE !EOF()

    // ��� ������� �த�樨 � ���������
    mkcrosr:=getfield('t1','mkdoc->mntovt','ctov','mkcros')
    nWeight:=getfield('t1','mkcrosr','mkcros','keg')
    IF nWeight > 10 //����
      nWeight:=nWeight // /10
    ELSE
      nWeight := getfield('t1','mkdoc->mntovt','ctov','vesp')
    ENDIF

    /*
    nWeight := getfield('t1','mkdoc->mntovt','ctov','vesp')
    */

    _FIELD->Dcl := nWeight

    DBSkip()
  ENDDO
  outlog(__FILE__,__LINE__,  t1 - SECONDS())
  //quit

  aSumDcl:={0,0,0, 0,0,0, 0,0,0}
  aSumGrn:={0,0,0, 0,0,0, 0,0,0}
  DBGoTop()
  DO WHILE !EOF()

    If vo != 9 .or. (sk=237 .or. sk=702)
      DBSkip()
      loop
    EndIf


    nSumGrn := round(kvp * ROUND(zen * 1.2,2),2)
    lCase:=.F.
    nGrp:=INT(mntovt/10000)
    Do Case
    Case nGrp = 341 .and. Dcl < 10
      //  ����
      aSumDcl[1] += kvp * dcl
      aSumGrn[1] += nSumGrn
      lCase:=.T.
    Case nGrp = 330 .and. Dcl < 10
      // ��� �������
      aSumDcl[2] += kvp * dcl
      aSumGrn[2] += nSumGrn
      lCase:=.T.
    Case nGrp = 329 .and. Dcl < 10
      // ��� ����
      aSumDcl[3] += kvp * dcl
      aSumGrn[3] += nSumGrn
      lCase:=.T.
    Case nGrp = 340 .and. Dcl < 10 ;
      .and. !(str(mkdoc->mntovt) $ OB_LIST_SIDR)
      // ᫠� �������
      aSumDcl[4] += kvp * dcl
      aSumGrn[4] += nSumGrn
      lCase:=.T.
    Case nGrp = 340 .and. Dcl < 10 ;
      .and. str(mkdoc->mntovt) $ OB_LIST_SIDR
      // ᨤ�
      aSumDcl[5] += kvp * dcl
      aSumGrn[5] += nSumGrn
      lCase:=.T.
    Case nGrp = 340 .and. Dcl > 10 //;      .and. str(mkdoc->mntovt) $ '3400244'
      // ᨤ� ����
      aSumDcl[6] += kvp  //* dcl
      aSumGrn[6] += nSumGrn
      lCase:=.T.
    Case nGrp = 341 .and. Dcl > 10
      //  ���� ����
      aSumDcl[7] += kvp // * dcl
      aSumGrn[7] += nSumGrn
      lCase:=.T.
    Case nGrp = 330 .and. Dcl > 10
      // ��� �������  ����
      aSumDcl[8] += kvp // * dcl
      aSumGrn[8] += nSumGrn
      lCase:=.T.

    EndCase
    if lCase = .T.
      aSumDcl[9] += kvp * iif(Dcl > 10,1,dcl)
      aSumGrn[9] += nSumGrn
    endif
    DBSkip()
  ENDDO



  crtt("Report_M",'f:C1R1 c:c(35) f:C1R2 c:c(15) f:C1R3 c:c(15) f:C1R4 c:c(15) f:C1R5 c:c(15) f:C1R6 c:c(15) f:C1R7 c:c(15) f:C1R8 c:c(15) f:C1R9 c:c(15) f:C1R10 c:c(15)')

    use Report_M ALIAS Report new
    Report->(DBAppend())
    Report->C1R2:="�த�� ����"
    Report->C1R3:="�த�� ���"
    Report->C1R4:="�த�� MIH"
    Report->C1R5:="�த�� ���"
    Report->C1R6:="�த�� �I��"
    Report->C1R7:="�த�� �I��(����)"
    Report->C1R8:="�த�� ����(����)"
    Report->C1R9:="�த�� ���(����)"
    Report->C1R10:="������� �� �i����"

    Report->(DBAppend())
    Report->C1R1:="�த�� ���"
    FOR i:=1 TO 9
      FieldPut(i+1,STR(aSumDcl[i]/10,12,3))
    NEXT

    Report->(DBAppend())
    Report->C1R1:="�த��i �த��i���� � ���"
    FOR i:=1 TO 9
      FieldPut(i+1,STR(aSumGrn[i],12,2))
    NEXT
  RETURN (NIL)
/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  07-07-17 * 01:59:26pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
STATIC FUNCTION Debts(cAl_Deb, cAl_OlDebts)

  DBGOTOP()
  DO WHILE !EOF()

      IF STR((cAl_deb)->Kpl) $ '  20034; 539105; 383053;2298568;5513371; 382533'
        SELECT (cAl_deb) ;        DBSKIP();        LOOP
      ENDIF
      IF (cAl_deb)->Sdp = 0
        SELECT (cAl_deb) ;        DBSKIP();        LOOP
      ENDIF

    SELE (cAl_OlDebts)
    DBAPPEND()
    /*
    FK      OL_Code Character       25      ��� �� � ���, �� ���ன ������ ����.   ��
    */

    _FIELD->OL_Code:=STR((cAl_deb)->Kgp,7)+"-"+STR((cAl_deb)->Kpl,7)

    /*
          Debt    Numeric 19,2    ��騩 ���� ��,  ���祭�� � ��. ��
    */
    _FIELD->Debt := (cAl_deb)->Sdp
    /*
          PayDate Date    8       ��� ��᫥���� ������
    */
    _FIELD->PayDate := IIF(EMPTY(deb_dz->DDK), STOD('20060901'),deb_dz->DDK)
    /*
          CanSale Logical 1       ������, ����� 㪠�뢠��, ࠧ�襭� �� ���㦠�� � ��
       1-ࠧ�襭�   0-�� ࠧ�襭�  ��
    */
    _FIELD->CanSale:=.T.
    /*
            Avg_Amount      Numeric 8,2     �।��� ��ꥬ ⮢�ம���� �� �࣮��� �窥.
          �� 㬮�砭�� -0 ��
    */
    _FIELD->Avg_Amount := 0
    /*
          Details1
          :. Details20    Character       50      ��⠫쭠� ���ଠ�� � �த���� � ������ ��.
          ����� 㪠�뢠�� �������⥫쭮� ⥪�⮢�� ����᭥��� � �����.    ���
    */
    // _FIELD->Details1 := LEFT(allt(">7��:"+LTRIM(STR(d-eb_dz->PDZ,10,2))+" >14��:"+LTRIM(STR(d-eb_dz->PDZ1,10,2))+" >21��:"+LTRIM(STR(d-eb_dz->PDZ3,10,2))), 50)


    // 5200861 // 5200020
    /*
            DTLM    Character       14      ��� � �६� ����䨪�樨 ����� (���㧪� ���ଠ樨). ��ଠ�: "YYYYMMDD HH:MM" ��
    */
    _FIELD->DTLM := DTLM()
    /*
     Status  Numeric 11      ����� (2 - '��⨢��', 9 - '����⨢��')
     ��������� ���祭��� "2",        ��
    */
    //_FIELD->Status := 2

    If !empty(FieldPos('CURR_DELAY'))
      // ����������� ����
      _FIELD->CURR_DELAY:=3
    EndIf
    If !empty(FieldPos('MAXDEBT'))
      // ����� ����������� �㬬� 19.2
      _FIELD->MAXDEBT:=10
    EndIf
    If !empty(FieldPos('MAXDELAY'))
      // ����窠 ����
      klpr:=(cAl_deb)->Kpl
      _FIELD->MAXDELAY:=getfield('t1','Kplr','klndog','kdopl')
    EndIf

    SELE (cAl_deb)
    DBSkip()
  ENDDO
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  07-07-17 * 02:10:08pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
STATIC FUNCTION DebDet(cAl_skdoc, cAl_OlDebDet,dDateDeb,aMessErr, aKta)
  LOCAL nQTY
  DBGOTOP()
  DO WHILE !EOF()
      IF STR((cAl_skdoc)->Kpl) $ '  20034; 539105; 383053;2298568;5513371; 382533'
        SELECT (cAl_skdoc) ;        DBSKIP();        LOOP
      ENDIF
      IF (cAl_skdoc)->Sdp = 0
        SELECT (cAl_skdoc) ;        DBSKIP();        LOOP
      ENDIF

    SELE (cAl_OlDebDet)
   alias_1:=ALIAS()
    DBAPPEND() //�஢�ઠ �� �㡫�   STR(mkkplkgp->Kgp,7)+"-"+STR(mkkplkgp->Kpl,7)
    /*
    FK      OL_Code Character       25      ��� �� � ���, �� ���ன ������ ����.   ��
    */

    _FIELD->OL_Code:=STR((cAl_skdoc)->Kgp,7)+"-"+STR((cAl_skdoc)->Kpl,7) //

    /*
    FK      DATE    Date    8       ��� ������������� �����.  ��� ���㬥�� ��
                                    ���஬� ������ ����. ��
    */
    _FIELD->DATE := (cAl_skdoc)->DOP
    /*
    FK      COMMENT Character       50      �������਩ � �����.
                  ������� ����� ��室��� ��������� �� ���ன ������ ���� �१
                   "��� � ����⮩" 㪠���� ������⢮ ���� ����窨 �����.
                  (��: "12345; -5" (���� �㤥� ����祭 �१ 5����, "12335; 2"
                  ���� 㦥 2 ��_� ����祭)       ��
    */
    dDtOpl:=(cAl_skdoc)->(IIF(EMPTY(DtOpl), DOP+14,DtOpl))

    _FIELD->COMMENT :=  ;
    (cAl_skdoc)->(allt(STR(SK))+"_"+allt(STR(TTN)));
    +';'+ STR(dDateDeb-dDtOpl,3);
    +";"+ "��� ���:"+DTOC(dDtOpl)

    /*
            DEBT    Numeric 16,2    ���� �� �� ���㬥���. ������� ���
            ���㬥�� (� ��.),             �� ���஬� ������ ����. ��
    */
    _FIELD->DEBT := (cAl_skdoc)->Sdp
    /*
            DebTypCode      Character       20      ��� ������������:
                         100 - ���� (�� ����祭��)
                         105 - ���� (����祭��)

                         101 - �த��� (�� ����祭��)
                         103 - �த���  (����祭��)

                         102 - ��� ��� ��� (�� ����祭��)
                         106 - ��� ��� ��� (����祭��)       ��
    */
    DO CASE
    CASE STR((cAl_skdoc)->KOP,3) $ '170;105'
        If dDtOpl <  dDateDeb
          _FIELD->DebTypCode := "106"
        Else
          _FIELD->DebTypCode := "102"
        EndIf
        nQTY:=(cAl_skdoc)->Kvp
    OTHERWISE
      IF (cAl_skdoc)->NN = 0 .or. (cAl_skdoc)->KOP = 169 // �-�� ���� ����窨
        _FIELD->DebTypCode := "101"
      ELSE
        If dDtOpl <  dDateDeb
          _FIELD->DebTypCode := "103"
        Else
          _FIELD->DebTypCode := "101"
        EndIf
      ENDIF
      nQTY:=0
    ENDCASE
    /*
            INVOICE_NO      Character       58      �����䨪���
                    ������ (� � ���� invoice_no ������ ���� ����ᠭ �����
                    ���㬥�� �த���, �����   ᮧ��� ��� ���������
                    �������������)   ���
    */
    _FIELD->INVOICE_NO:=(cAl_skdoc)->(allt(STR(SK))+"_"+allt(STR(TTN))) //+":"+STR(KOP)+":���"

    /*   MERCH_ID        Numeric 11      �����䨪��� �࣮���� �।�⠢�⥫� � ����� SWE       ��*/
    //_FIELD->MERCH_ID := skdoc->(nIdLod('skdoc->kta', @aMessErr, aKta))
    _FIELD->MERCH_ID := (cAl_skdoc)->(nIdLod(cAl_skdoc+'->kta', @aMessErr, aKta))
    If !empty(FieldPos('MERCH_CODE'))
      _FIELD->MERCH_CODE:=allt(str((cAl_skdoc)->Kta))
    EndIf

    /*
            QTY     Numeric 14,3    ������⢮ ⮢�� (���� qty ����� �� ��������� ��� ���� ��������� ��� 0)      ���
    */
    _FIELD->QTY := nQTY
    /*
            DTLM    Character       14      ��� � �६� ����䨪�樨 ����� (���㧪� ���ଠ樨). ��ଠ�: "YYYYMMDD HH:MM" ��
    */
   // _FIELD->DTLM := DTLM()
    /*
     Status  Numeric 11      ����� (2 - '��⨢��', 9 - '����⨢��')
     ��������� ���祭��� "2",        ��
    */
   // _FIELD->Status := 2

    sele (cAl_skdoc)
    DBSKIP()
  ENDDO
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  07-07-17 * 02:22:32pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
STATIC FUNCTION DebDetKeg(ali_etm, cAl_OlDebDet,dDateDeb)

  DBGOTOP()
  i:=0
  DO WHILE !EOF()

    SELE (cAl_OlDebDet)
   alias_1:=ALIAS()
    DBAPPEND() //�஢�ઠ �� �㡫�   STR(mkkplkgp->Kgp,7)+"-"+STR(mkkplkgp->Kpl,7)
    /*
    FK      OL_Code Character       25      ��� �� � ���, �� ���ன ������ ����.   ��
    */
   _FIELD->OL_Code:=STR((ali_etm)->Kgp,7)+"-"+STR((ali_etm)->Kpl,7)

    /*
    FK      DATE    Date    8       ��� ������������� �����.  ��� ���㬥�� ��
                                    ���஬� ������ ����. ��
    */
    _FIELD->DATE := dDateDeb //dDt //DATE()
    /*
    FK      COMMENT Character       50      �������਩ � �����.
                  ������� ����� ��室��� ��������� �� ���ன ������ ���� �१
                   "��� � ����⮩" 㪠���� ������⢮ ���� ����窨 �����.
                  (��: "12345; -5" (���� �㤥� ����祭 �१ 5����, "12335; 2"
                  ���� 㦥 2 ��_� ����祭)       ��
    */
    dDtOpl:=DATE()+21
    _FIELD->COMMENT := ;
    "��� ���:"+DTOC(dDtOpl);
    +";"+STR(DATE()-dDtOpl,3)

    /*
            DEBT    Numeric 16,2    ���� �� �� ���㬥���. ������� ���
            ���㬥�� (� ��.),             �� ���஬� ������ ����. ��
    */

      nZen:=(ali_etm)->Opt
      IF EMPTY(nZen)
        nZen:=1000
      ENDIF

    _FIELD->DEBT := (ali_etm)->Osf*nZen

    /*
            DebTypCode      Character       20      ��� ������������:
                         100- ���� (�� ����祭��)
                         101- �த��� (�� ����祭��)
                         102 - ��� ��� ��� (�� ����祭��)
                         103 - �த���  (����祭��)
                         105 - ���� (����祭��)
                         106 - ��� ��� ��� (����祭��)       ��
    */
      _FIELD->DebTypCode := "100"+STR((ali_etm)->Keg/10,1)
    /*
            INVOICE_NO      Character       58      �����䨪���
                    ������ (� � ���� invoice_no ������ ���� ����ᠭ �����
                    ���㬥�� �த���, �����   ᮧ��� ��� ���������
                    �������������)   ���
    */
    _FIELD->INVOICE_NO:=(ali_etm)->(STR(MNTOV))+":"+_FIELD->OL_Code
    /*
            QTY     Numeric 14,3    ������⢮ ⮢�� (���� qty ����� �� ��������� ��� ���� ��������� ��� 0)      ���
    */
    _FIELD->QTY := (ali_etm)->Osf

    /*   MERCH_ID        Numeric 11      �����䨪��� �࣮���� �।�⠢�⥫� � ����� SWE       ��*/
    _FIELD->MERCH_ID := iif(left(getfield('t1','KegO->kpl','kpl','cRmSk'),1)='1',;
            5200020,;
            5200861;
  )
    If !empty(FieldPos('MERCH_CODE'))
      _FIELD->MERCH_CODE:=_FIELD->MERCH_ID
      //allt(str((cAl_skdoc)->Kta))
    EndIf

    /*
            DTLM    Character       14      ��� � �६� ����䨪�樨 ����� (���㧪� ���ଠ樨). ��ଠ�: "YYYYMMDD HH:MM" ��
    */
    _FIELD->DTLM := DTLM()
    /*
     Status  Numeric 11      ����� (2 - '��⨢��', 9 - '����⨢��')
     ��������� ���祭��� "2",        ��
    */
    _FIELD->Status := 2

    sele (ali_etm)
    DBSKIP()
  ENDDO
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  07-26-17 * 04:03:30pm
 ����������......... �뢮� ����� ��� �� skdoc
 ���������..........
 �����. ��������....
 ����������.........
 */
STATIC FUNCTION DebDetKeg30(ali_etm, cAl_OlDebDet,dDateDeb,aMessErr, aKta)
  DBGOTOP()
  i:=0
  DO WHILE !EOF()

    SELE (cAl_OlDebDet)
   alias_1:=ALIAS()
    DBAPPEND() //�஢�ઠ �� �㡫�   STR(mkkplkgp->Kgp,7)+"-"+STR(mkkplkgp->Kpl,7)
    /*
    FK      OL_Code Character       25      ��� �� � ���, �� ���ன ������ ����.   ��
    */
   _FIELD->OL_Code:=STR((ali_etm)->Kgp,7)+"-"+STR((ali_etm)->Kpl,7)

    /*
    FK      DATE    Date    8       ��� ������������� �����.  ��� ���㬥�� ��
                                    ���஬� ������ ����. ��
    */
    _FIELD->DATE := dDateDeb //dDt //DATE()
    /*
    FK      COMMENT Character       50      �������਩ � �����.
                  ������� ����� ��室��� ��������� �� ���ன ������ ���� �१
                   "��� � ����⮩" 㪠���� ������⢮ ���� ����窨 �����.
                  (��: "12345; -5" (���� �㤥� ����祭 �१ 5����, "12335; 2"
                  ���� 㦥 2 ��_� ����祭)       ��
    */
    dDtOpl:=DATE()+21
    _FIELD->COMMENT := ;
    (ali_etm)->(allt(STR(SK))+"_"+allt(STR(TTN)));
    +';'+ STR(dDateDeb-dDtOpl,3);
    +";"+ "��� ���:"+DTOC(dDtOpl)

    /*
            DEBT    Numeric 16,2    ���� �� �� ���㬥���. ������� ���
            ���㬥�� (� ��.),             �� ���஬� ������ ����. ��
    */

    _FIELD->DEBT := (ali_etm)->Sdp

    /*
            DebTypCode      Character       20      ��� ������������:
                         100- ���� (�� ����祭��)
                         101- �த��� (�� ����祭��)
                         102 - ��� ��� ��� (�� ����祭��)
                         103 - �த���  (����祭��)
                         105 - ���� (����祭��)
                         106 - ��� ��� ��� (����祭��)       ��
    */
      _FIELD->DebTypCode := "100"+STR((ali_etm)->Keg/10,1)
    /*
            INVOICE_NO      Character       58      �����䨪���
                    ������ (� � ���� invoice_no ������ ���� ����ᠭ �����
                    ���㬥�� �த���, �����   ᮧ��� ��� ���������
                    �������������)   ���
    */
    _FIELD->INVOICE_NO:= (ali_etm)->(allt(STR(SK))+"_"+allt(STR(TTN)))
    /*
            QTY     Numeric 14,3    ������⢮ ⮢�� (���� qty ����� �� ��������� ��� ���� ��������� ��� 0)      ���
    */
    _FIELD->QTY := (ali_etm)->kvp

    /*   MERCH_ID        Numeric 11      �����䨪��� �࣮���� �।�⠢�⥫� � ����� SWE       ��*/
    _FIELD->MERCH_ID := (ali_etm)->(nIdLod(ali_etm+'->kta', @aMessErr, aKta))

    If !empty(FieldPos('MERCH_CODE'))
      _FIELD->MERCH_CODE:=allt(str((ali_etm)->Kta))
    EndIf

    /*
            DTLM    Character       14      ��� � �६� ����䨪�樨 ����� (���㧪� ���ଠ樨). ��ଠ�: "YYYYMMDD HH:MM" ��
    */
    // _FIELD->DTLM := DTLM()
    /*
     Status  Numeric 11      ����� (2 - '��⨢��', 9 - '����⨢��')
     ��������� ���祭��� "2",        ��
    */
    // _FIELD->Status := 2

    sele (ali_etm)
    DBSKIP()
  ENDDO
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  08-14-17 * 12:46:59pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION TPokOrder(cDosParam,bSeekSk,kopr, vor)
  LOCAL lerase:=.T., lSkip
  LOCAL nKpl, nKtl1, nKtl2, lKtl2:=.f.
  LOCAL nMnTov1, nMnTov2
  LOCAL SkVzr
  #define nCntRecMaxLRs1 500
  #define nCntRecMaxLRs2 9998
  DEFAULT bSeekSk TO {||ent=gnEnt.and.TPstPok = 2}, kopr TO 108, vor TO 1

  nKpl:=kta_DosParam(cDosParam,'/kpl=',7)
  nMnTov:=kta_DosParam(cDosParam,'/mntov=',7)
  nMnTov2:=kta_DosParam(cDosParam,'/mntov2=',7)
  //If Upper('Ktl2=0') $ cDosParam
  SkVzr:=0

  If Upper('Ktl2=0') $ cDosParam
    lKtl2:=.t.
  EndIf
  outlog(__FILE__,__LINE__,gnEnt,nKpl,nMnTov,nMnTov2,lKtl2,'gnEnt,nKpl,nMnTov,nMnTov2,lKtl2')
  IF !lerase_lrs(lerase)
    //� ᫥���騩 ࠧ
    RETURN
  ENDIF
  If file('lrs1_del.dbf')
    ERASE lrs1_del.dbf
  EndIf

  luse('lrs1')
  luse('lrs2')

  // ������ ᪫�� ��� ���㯠⥫��
  netuse('cskl')
  netuse('etm')
  netuse('tmesto')
  netuse('ctov')
  netuse('mkcros')


  sele cskl
  __dbLocate(bSeekSk)

  if found()
    If cskl->TPsTPok = 2;  // �⪫�� ��ࠏ���
          .or. cskl->TPsTPok = 1
      SkVzr:=sk
    EndIf
    SkTarar:=sk
    pathr=gcPath_d+allt(path)
    netuse('tov','Tov',,1)
    set orde to tag t1 // skl + ktl
    netuse('TovM','TovM',,1)
    set orde to tag t1 // skl + ktl

    sele TovM
    kplr:=nKpl
    If !Empty(nKpl)
       if netseek('t1','kplr')
       else
         outlog(__FILE__,__LINE__,'Kpl=',nKpl,'�� ������ TovM')
         Return nil
       EndIf
      bWhile:={|| TovM->Skl = kplr }
    else
      DBGoTop()
      bWhile:={|| .not. eof() }
    EndIf

    // ����� tovM=0, � �� ktl - ������஢���, � ��� ��������
    sele TovM
    Do While  eval(bWhile)
      If kplr # TovM->Skl // ᬥ�� ���⥫�騪�
        If !Empty(lrs1->(LastRec()))
          // 㯠����� ���㬥�⮢
          LRsPack()
          sele lrs1; Pack
          sele lrs2; Pack
        EndIf

        If lrs1->(LastRec()) >= nCntRecMaxLRs1
          exit
        EndIf
      EndIf

      sele TovM
      kplr := TovM->Skl
      nKpl := kplr
      outlog(3,__FILE__,__LINE__,TovM->Skl,TovM->MnTov,'TovM->Skl,TovM->MnTov')
      If int(TovM->MnTov/10000) = 0 // ��
      else
        skip; loop
      EndIf

      Do Case
      Case nMnTov = 9999999
        // ��६ ��
      Case Empty(nMnTov)
        // ��६ ��
      Case !Empty(nMnTov)
        If nMnTov = TovM->MnTov
          // ��६
        else
          skip; loop
        EndIf
      EndCase

      // outlog(__FILE__,__LINE__)
      lSkip:=.F.
      Do Case
      Case Empty(nMnTov) .and. Empty(nMnTov2)
        If cskl->TPsTPok = 2;  // �⪫�� ��ࠏ���
          .or. cskl->TPsTPok = 1
          If tovM->osf # 0 // �ய㪠�� �� �㫥�� (�㫥�� ��ࠡ��뢠��)
            lSkip:=.t.
          EndIf
        Else // ����� ᪫��
          // ��६ ��
          If tovM->MnTov > 316 // ����� ���� �ய�᪠��
            lSkip:=.t.
          EndIf
        EndIf

        If lSkip
          dbskip(); loop
        EndIf
      Case Empty(nMnTov2)
        if nMnTov = 9999999
          // ������ �� ���� த�⥫�
          nMnTov2:=getfield('t1','TovM->MnTov','ctov','MnTovT')
          If Empty(nMnTov2)
            outlog(__FILE__,__LINE__,'empty MnTovT',TovM->Skl,TovM->MnTov, kplr,'TovM->Skl,TovM->MnTov, kplr')
            skip; loop
          else
            outlog(3,__FILE__,__LINE__,'த�⥫�',nMnTov2,'nMnTov2')
            If nMnTov2 = TovM->MnTov // ᠬ ᥡ� த�⥫�
              If cskl->TPsTPok = 0 // ��� ᪫��� �ࠪ
                nMnTov2:=0
              EndIf
            EndIf
          EndIf

        else
          If tovM->osf = 0
            //
          else

            Do Case
            Case Empty(nMnTov)
              // ��६ ��
            Case !Empty(nMnTov)
              // ���� ������� ᢥ�� �� ���� ���  skip; loop
            EndCase

          EndIf
        endif
      Case !Empty(nMnTov2)
        // 㪠��� ��ன ���, �.�. �஢�ન �� ������ - ��४����
      EndCase

      /*    // �ਧ��� ����
      mkcrosr:=getfield('t1','TovM->MnTovT','ctov','mkcros')
      if (getfield('t1','mkcrosr','mkcros','keg')) < 30
        // skip; loop
      EndIf
      */
      outlog(3,__FILE__,__LINE__,TovM->Skl,TovM->MnTov, kplr,'TovM->Skl,TovM->MnTov, kplr')

      sele Tov
      set orde to tag t5 // skl + ktl
      if netseek('t5','tovM->Skl,tovM->MnTov')
        // ᮧ���� 蠯��        // NNNNNNNN-NNNN-NNNN-NNNN-NNNNNNNNNNNN

        sele Tov
        Do While tovM->Skl = tov->Skl .and. tovM->MnTov = tov->MnTov
          If Tov->osf = 0
            Tov->(DBSkip())
            loop
          EndIf
          If cskl->TPsTPok = 2; // �⪫�� ��ࠏ���
            .or. cskl->TPsTPok = 1
            //
          else
            //
          endif

          If lrs2->(LastRec())>nCntRecMaxLRs2 // �ய�᪠�� �����
            Tov->(DBSkip())
            loop
          EndIf
          // ���� ��� ᮧ���� ��ப� 蠯��
          sele lrs1
          locate for kpl = kplr
          If !found()
            Tov->(LRs1_Add(str(nKpl,7)+';'+XTOC(nMnTov)+';'+XTOC(nMnTov2)+';'+time()+uuid(),;
             263, SkVzr, kopr, vor))
          EndIf

          nKtl1:=Tov->Ktl
          nMnTov1:=Tov->MnTov

          If Empty(nMnTov2)
            // ᮧ���� ��ப�
            outlog(3,__FILE__,__LINE__,'ᮧ���� ��ப�', Tov->MnTov, Tov->Ktl,tov->osf,'Tov->MnTov, Tov->Ktl, tov->osf')
            LRs2_Add(nMnTov1, Tov->osf, nKtl1,0, .f.)

          else // !Empty(nMnTov2) // ��७�� �� ���� ����
            MnTov2r:=nMnTov2
            //outlog(__FILE__,__LINE__, tov->(RecNo()), tov->osf,'tov->(RecNo()), tov->osf')
            // nRecTov := tov->(RecNo())
            nKtl2 := getfield('t5','tovM->Skl,MnTov2r','tov','ktl')

            If Empty(nKtl2) // ��ॡ�᪠ �� த�⥫�
              outlog(__FILE__,__LINE__,'ᮧ���� ��ப�',TovM->Skl, Tov->MnTov, Tov->Ktl, tov->osf,'TovM->Skl,Tov->MnTov, Tov->Ktl, tov->osf')
              outlog(__FILE__,__LINE__,'empty nKtl2',MnTov2r,'MnTov2r')

              If !(lKtl2) // /Ktl2=0 �� ������� � ��ࠬ����, � �� �㤥� 㤠����.
                lrs2->(DBDelete())
                Tov->(DBSkip())
                sele Tov
                loop
              EndIf

              //
            EndIf

            If nKtl1 # nKtl2
              outlog(3,__FILE__,__LINE__,'ᮧ���� ��ப�', Tov->MnTov, Tov->Ktl,tov->osf,'Tov->MnTov, Tov->Ktl, tov->osf')
              LRs2_Add(nMnTov1, Tov->osf, nKtl1,0, .f.)

              outlog(3,__FILE__,__LINE__,'������஢����', nMnTov2, nKtl2, Tov->MnTov, tov->osf,'nMnTov2, nKtl2, Tov->MnTov, tov->osf')
              // ������ ���� ���⮪� ��㣨� ���
              LRs2_Add(nMnTov2, Tov->osf, nKtl2, Tov->MnTov, .T.) // ������஢����
            EndIf

          EndIf
          sele Tov
          DBSkip()
        EndDo
        // ����� �� �㫥��� ���⮪, � ��� � ��࠭��
        If Empty(nMnTov2) // ��� ��७��
          If cskl->TPsTPok = 2 ;// �⪫�� ��ࠏ���
            .or. cskl->TPsTPok = 1

            If !(tovM->osf = 0)
              LRs2->kvp -= tovM->osf
            EndIf
          Else // ����� ᪫��
            //
          EndIf
        EndIf
      else
        outlog(3,__FILE__,__LINE__," !netseek('t5','tovM->Skl,tovM->MnTov') ")
      endif

      nMnTov:=kta_DosParam(cDosParam,'/mntov=',7)
      nMnTov2:=kta_DosParam(cDosParam,'/mntov2=',7)
      sele TovM
      If !Empty(nKpl)
        DBSkip() //exit
      else
        DBSkip()
      endif
    enddo

  endif

  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  10-20-14 * 09:12:58pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
STATIC FUNCTION KegaVol(cFieldSeek)
  LOCAL nVolume
    mkcrosr:=getfield('t1',cFieldSeek,'ctov','mkcros')
    nWeight:=getfield('t1','mkcrosr','mkcros','keg')
    IF nWeight > 10 //����
      nVolume:=nWeight
    ELSE
      nVolume:=1
    ENDIF
    IF (INT((&cFieldSeek) /10000)=0) //����� �� (����)
      nVolume:=1
    ENDIF
    /*
    If &cFieldSeek = 3410747
    outlog(__FILE__,__LINE__,&cFieldSeek,;
    mkcrosr,;
    nWeight,nVolume;
  )
    EndIf
    */
  RETURN (nVolume)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  09-26-17 * 11:25:29am
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
STATIC FUNCTION OblMnTov(nMnTov)
  Do Case
  Case nMnTov = 109
    nMnTov:=224
  Case nMnTov = 146
    nMnTov:=223
  Case nMnTov = 219
    nMnTov:=229
  EndCase
  RETURN (nMnTov)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  11-16-17 * 01:43:17pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION LRs1_Add(cDocId, Sklr, SkVzr, kopr, vor)
  DEFAULT kopr TO 108,;
  vor to 1,;  //Iif(osf>0 , 1, 9)   //������ - 1 �த��� - 9
  Sklr TO 263, SkVzr to 234

  // Sklr := 263 // �ࠪ 169
  //SkVzr := 234
  kopir := kopr// 160
  ktar := 999
  ttncr := 0 // �㦭� ���� �� ���? (0 - �� ��� � ��� ,1-�� �⤥�쭮� ���)

  DtRor:=Date() //��� ���⠢��
  TimeCrtFrmr:= DTOS(date())+" "+"00:00:00"
  TimeCrtr  := TimeCrtFrmr
  DocIDr    := cDocId //str(TovM->MnTovT,7) + str(TovM->Skl,7)
  Commentr  := '' // -169
  Sumr      := 0

  kgpr := KegKgp()
  kplr := kplr

  if at('�=',Commentr) # 0 // ������� �� ����� �����
    netrepl('ztxt',{Commentr})
  else
    netrepl('npv',{Commentr})
  endif

  lrs1->(DBGoBottom())
  ttnr:=lrs1->ttn
  If .T. .or. ttnr = 0 // ���� ���
    ttnr:=ttnr+1
    sele lrs1
    netadd()
  EndIf

  sele lrs1

  netrepl('dop',{date()})
  netrepl('DtRo',{DtRor})

  netrepl('TimeCrtFrm,TimeCrt,DocGUID,Sdv',{TimeCrtFrmr,TimeCrtr,DocIDr,Sumr})

  netrepl('Skl,ttn,vo,kop,kopi,kpl,kgp,kta,ddc,tdc',;
        {Sklr,ttnr,vor,kopr,kopir,kplr,kgpr,ktar,date(),time()})
  netrepl('ttnp,NdVz',{ttncr,SkVzr})

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  11-16-17 * 01:50:44pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION LRs2_Add(nMnTov, kvpr, nKtl, nMnTovP,lInvert)
  LOCAL nPreRec
  DEFAULT lInvert  TO .F.,  nMnTovP to 0
  ttnr := lrs1->ttn

  mntovr := nMnTov
  ktlr   := nKtl

  // kvpr   := Tov->osf
  If abs(kvpr) >= 100000
    kvpr   := 99999 * Iif(kvpr > 0, 1, (-1))
  EndIf
  kvpr   := kvpr * Iif(lInvert,(-1),1)
  zenr   := Tov->Opt
  sele lrs2
  nPreRec:=RecNo() // ������ ���筨�
  locate for ttn  = ttnr  .and. MnTov = MnTovr .and. ktl = ktlr
  If !found()
    netadd()
  EndIf
  // ��ࢠ� �ᥤ� �������� � ��࠭�稢����� �-��
  // ���� (�㤠), ����� �㬬�஢�����, �஢��塞
  If ABS(kvp + kvpr) >= 100000
    //DBSkip(-1)
    DBGoTo(nPreRec)
    DBDelete()
  EndIf
  // ᤥ���� ���४��, ����� ����訢 �ᥣ��, � ����� ���㫨�
    netrepl('ttn,MnTov,ktl,MnTovP,zen',{ttnr,mntovr,ktlr,nMnTovP,zenr},)
    //outlog(__FILE__,__LINE__,ABS(kvp + kvpr) > 100000,ABS(kvp + kvpr), 100000)
    //outlog(__FILE__,__LINE__,kvp + kvpr,kvp, kvpr)
    netrepl('kvp',{kvp + kvpr})

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  03-26-18 * 09:12:57am
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Autopfakt(l_mnr,l_gnSk)

  MenSkl(gnSk)

  netuse('cskl')

  netuse('tcen')
  netuse('ctov')
  netuse('tovm')
  netuse('tov')

  netuse('soper')
  netuse('pr1')
  netuse('pr2')
  netuse('pr3')
    outlog(__FILE__,__LINE__,mnr,pathr)

  gnD0k1=1 // ��室�

  sele pr1

  if netseek('t2','mnr')
    gnVo := pr1->Vo // 1 - ������ �� ���㯠⥫�� 6-������
    rcPr1r:=RECNO()

    Pr1ToMemVar()

    Autor=getfield('t1','gnD0k1,gnVu,gnVo,qr','soper','auto')
    if !inikop(gnD0k1,gnVu,gnVo,qr)
      outlog(__FILE__,__LINE__,gnD0k1,gnVu,gnVo,qr,'!inikop 4 gnD0k1,gnVu,gnVo,qr')
      RETURN (NIL)
    endif
    // ���樠������ ���ᮢ �� SOPER  // �����祭��
    if Autor#0
        store Skar   to gnSkt,Sktr
        store Sklar  to gnSklt,Skltr
        store mSklar to gnMSklt,mSkltr
        store nSklar to gnNSklt,nSkltr
    else
        store 0 to gnSkt,Sktr
        store 0 to gnSklt,Skltr
        store 0 to gnMSklt,mSkltr
        store '' to gnNSklt,nSkltr
    endif

    outlog(__FILE__,__LINE__,Autor,Skar,  Sklar, mSklar, nSklar,'Autor,Skar,  Sklar, mSklar, nSklar')
    prNppr:=0 // �ਧ��� ����⢨� � �-⮬
    pfakt()
    outlog(__FILE__,__LINE__,'ok',mnr,pathr)
  EndIf
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  04-11-18 * 08:44:20pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
STATIC FUNCTION LRsPack()

  sele lrs2
  if netseek('t1','lrs1->ttn')
    dele for kvp = 0 while ttn = lrs1->ttn // ����� ���� ��᫥����⥫쭮

    netseek('t1','lrs1->ttn')
    locate for !deleted() while ttn = lrs1->ttn
    // ������ �� 㤠�����
    If !found() // �� 㤠����

      SaveLrs14del()
      lrs1->(DBDelete())

    endif
  else
    SaveLrs14del()
    lrs1->(DBDelete())
  endif

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  04-13-18 * 09:51:58am
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
STATIC FUNCTION SaveLrs14del()
  // ��࠭�� 蠯�� �-�
  sele lrs1
  copy to tmp_del next 1
  If !file('lrs1_del.dbf')
    copy stru to lrs1_del
    use lrs1_del.dbf new
  EndIf
  sele lrs1_del
  append from tmp_del
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  04-13-18 * 09:06:13am
 ����������.........  ��� �� ������� ���⪮� � �� ����⥫��.
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION TestSumQ_TPok(lCheck,bSeekSk)
  STATIC nSumQ:={0,0}
  LOCAL nSumQ1:={0,0}, l_pathr:=pathr

  netuse('cskl')
  DEFAULT bSeekSk TO {||ent=gnEnt.and.TPsTPok = 2}, lCheck TO .f.
  sele cskl
  __dbLocate(bSeekSk)
  If Found()
    pathr=gcPath_d+allt(path)
    netuse('tov','_Tov',,1)
    set orde to tag t1 // skl + ktl
    netuse('TovM','_TovM',,1)
    set orde to tag t1 // skl + ktl
    If Empty(select('_Tov'))
      outlog(__FILE__,__LINE__,"Empty(select('_Tov'))")
      quit
    EndIf

    sele _Tov
    sum osf to nSumQ1[1]
    sele _TovM
    sum osf to nSumQ1[2]
    outlog(__FILE__,__LINE__,'Q1 Tov TovM',nSumQ1)
    outlog(__FILE__,__LINE__,'Sub_Q1 Tov TovM',nSumQ1[1]-nSumQ1[2])
    If lCheck
      outlog(__FILE__,__LINE__,'Q Tov TovM',nSumQ)
      outlog(__FILE__,__LINE__,'Check Sub_Q Tov1 Tov',nSumQ1[1]-nSumQ[1])
      outlog(__FILE__,__LINE__,'Check Sub_Q TovM1 TovM',nSumQ1[2]-nSumQ[2])
    EndIf
    // ������ � ��⨪
    nSumQ:=ACLONE(nSumQ1)

    nuse('_tov')
    nuse('_tovM')
  EndIf
  pathr:=l_pathr
  RETURN (NIL)



/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  07-22-18 * 08:24:24pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
STATIC FUNCTION OblnUnZip(cFileZip,cPath_Pilot)

    LOCAL cRunUnZip:="/usr/bin/unzip"
    LOCAL cFileNameArc:=cFileZip
    LOCAL cLogSysCmd:=""
    LOCAL cCmd:=cRunUnZip+" -o "+ cFileNameArc + " " + "-d "+cPath_Pilot

     cRunSysCmd:=ATREPL('\',cCmd,"/")
     cRunSysCmd:=ATREPL('j:',cRunSysCmd,set("J:"))
  #ifdef __CLIP__
    SYSCMD(cRunSysCmd,"",@cLogSysCmd)
    outlog(__FILE__,__LINE__,cCmd)
    IF !EMPTY(cLogSysCmd)
      //qOUT(__FILE__,__LINE__,cCmd,cLogSysCmd,cCmd)
    ENDIF
  #endif
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  10-20-14 * 01:44:08pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION OblnSendOne(dtEndr,cPth_Plt_tmp,cPath_Pilot)
  //��� ��娢� � ��⥬
          cFileNameArc:=cPth_Plt_tmp+"\"+"ob"+;
          SUBSTR(DTOS(dtEndr),3)+;
          ".zip"
          cFileArcNew:=cPath_Pilot+"\"+"ob"+;
          SUBSTR(DTOS(dtEndr),3)+;
          ".zip"
  //�ᯠ�����
     cRunUnZip:="/usr/bin/unzip"

     cLogSysCmd:=""

     cCmd:=cRunUnZip+" -o "+ cFileNameArc + " "+;
     "-d "+cPath_Pilot

      cRunSysCmd:=ATREPL('\',cCmd,"/")

      cRunSysCmd:=ATREPL('j:',cRunSysCmd,set("J:"))


     #ifdef __CLIP__
     SYSCMD(cRunSysCmd,"",@cLogSysCmd)
     outlog(__FILE__,__LINE__,cRunSysCmd)
     IF !EMPTY(cLogSysCmd)
       //qOUT(__FILE__,__LINE__,cLogSysCmd,cRunSysCmd)
       //qOUT(__FILE__,__LINE__,cRunSysCmd)
     ENDIF
     #endif

  //����஢����
  copy file (cFileNameArc) to (cFileArcNew)

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  11-06-18 * 02:47:00pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION lod2swe2xml(cPth_Plt_lpos)

  use lod2swe new

  set console off
  set print on
  set print to (cPth_Plt_lpos+'\pos.xml') //pos.xml

  ??'<?xml version="1.0" encoding="windows-1251"?>'
  ?'<objects>'

  Do While !eof()
    ?'  <obj>'
    ?'    <custid>'+allt(str(custid))+'</custid>'
    ?'    <posid>'+allt(str(posid)) +'</posid>'

    If empty(olcode)
       ?'    <olcode/>'
    Else
       ?'    <olcode>'+allt(olcode) +'</olcode>'
    EndIf

    If empty(wh)
       ?'    <wh/>'
    Else
       ?'    <wh>'+allt(str(wh)) +'</wh>'
    EndIf

    ?'    <technicalcondition>'+allt(str(technicalc))+'</technicalcondition>'

    If technicalc = 8 // १��
      ?'     <reasonrepair/>'
    Else
      If !Empty(allt(comment))
        ?'   <reasonrepair>'+XmlCharTran(allt(comment))+'</reasonrepair>'
      else
        ?'   <reasonrepair/>'
      EndIf
    EndIf

    If empty(tsconno)
       ?'   <tsconno/>'
       ?'   <tsconsd/>'
    Else
       ?'   <tsconno>'+allt(tsconno) +'</tsconno>'
       ?'   <tsconsd>'+cdbDTLM(tsconsd,'00:00:00')+'</tsconsd>'
    EndIf

    If technicalc = 8 // १��
      dDt:=STOD(left(comment,10))
      If empty(dDt)
        dDt:=date()+10
      EndIf
      ?'    <reservdate>'+cdbDTLM(dDt,'00:00:00')+'</reservdate>'
    Else
      ?'    <reservdate/>'
    EndIf



    If empty(DocType)
       ?'   <doctype/>'
    Else
       ?'   <doctype>'+allt(str(DocType))+'</doctype>'
    EndIf

    ?'    <dtlm>'+cdbDTLM(date(),time())+'</dtlm>'
    ?'  </obj>'
    DBSkip()
  EndDo
  ?'</objects>'
  ?
  set print to
  set print off


  set console off
  set print on
  set print to (cPth_Plt_lpos+'\pos.sql')

  sele lod2swe
  DBGoTop()
  Do While !eof()
    ?? 'INSERT INTO SalesWeb.DBO.vIncoming_POS' +;
    " (POS_id";
    + iif(!empty(olcode),(", Ol_code"), "");
    + ", WH_id";
    + ", Tech_cond";
    + iif(!empty(tsconno),(", Doc_no"), "");
    + iif(!empty(tsconno),(", Doc_date"), "");
    + ", Doc_type)" +;
    " VALUES (";
    + ""   + allt(str(posid));
    + iif(!empty(olcode), (", " + "'" + allt(olcode) + "'"), "");
    + ", " + allt(str(wh));
    + ", " + allt(str(technicalc));
    + iif(!empty(tsconno),(", " + "'" + allt(tsconno) + "'"), "");
    + iif(!empty(tsconno),(", " + "'" + DTOC(tsconsd,"YYYY-MM-DD") + "'"), "");
    + ", " + allt(str(DocType));
    + ')'
    ??";"
    ?
    DBSkip()
  EndDo

  set print to
  set print off

  close

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  07-14-20 * 01:53:29pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION PosObolonRead(cPath, cFile)
  PosXmlRead(cPath, cFile)
  PosSalesWebRead(cPath, cFile)
  RETURN ( NIL )

STATIC FUNCTION PosXmlRead(cPath, cFile)
  LOCAL nError, cRezult
  LOCAL Ret:=TRUE
  LOCAL i:=0, bRezult:={|cRezult|;
        cRezult:= FTOKENNEXT(), cRezult:=StrTran(cRezult,CHR(13)+CHR(10),''),;
        allt(left(cRezult,AT('</',cRezult)-1));
      }
  LOCAL cCmd, cLogSysCmd

  // ����� �ਥ�� ���
  cCmd:='CUR_PWD=`pwd`; cd /m1/upgrade2/lodis/arnd; ';
  +'./get-ftp-POS.sh;  cd $CUR_PWD'
  cLogSysCmd:=''
  SYSCMD(cCmd,"",@cLogSysCmd)
  outlog(__FILE__,__LINE__,cCmd)


  use (cPath+'\'+'pos_swe') new Exclusive
  zap


  nError := FTOKENINIT(cPath+'\pos\output\'+cFile, '>', 1)
  IF (!(nError < 0))
    WHILE (!FTOKENEND())
      cRezult:= FTOKENNEXT();  cRezult:=StrTran(cRezult,CHR(13)+CHR(10),'')
      Do Case
      Case '<'+'obj' $ cRezult .and. len(allt(cRezult)) < 5
        // ����� ��ப� ������
        //outlog(__FILE__,__LINE__,'// ����� ��ப� ������)
        DBAppend()
        loop

      case '<'+'Invent_No' $ cRezult
        cRezult:=EVAL(bRezult)
        repl INV   with val(cRezult)

      case '<'+'Serial_No' $ cRezult
        cRezult:=EVAL(bRezult)
        repl SERIAL with cRezult

      case '<'+'POS_Name' $ cRezult
        cRezult:=EVAL(bRezult)
        repl POS_NAME with translate_charset("cp1251",host_charset(),cRezult)

      case '<'+'POSType_ID' $ cRezult
        cRezult:=EVAL(bRezult)
        repl POSTPID  with val(cRezult)

      case '<'+'Name' $ cRezult
        cRezult:=EVAL(bRezult)
        repl NAME     with  translate_charset("cp1251",host_charset(),cRezult)

      case '<'+'YearProduction' $ cRezult
        cRezult:=EVAL(bRezult)
        repl YEARP    with  cRezult

      case '<'+'Cust_id' $ cRezult
        cRezult:=EVAL(bRezult)
        repl CUST_ID  with val(cRezult)

      case '<'+'ManufacturerId' $ cRezult
        cRezult:=EVAL(bRezult)
        repl POSMANUF with val(cRezult)

      case '<'+'TechnicalCondition' $ cRezult
        cRezult:=EVAL(bRezult)
        repl TECHCOND with val(cRezult)

      case '<'+'POS_ID' $ cRezult
        cRezult:=EVAL(bRezult)
        repl POS_ID   with val(cRezult)
      Case '/<obj' $ cRezult
        // ����� ��ப� ������
      EndCase

      // outlog(__FILE__,__LINE__,cRezult)

      If (++i) > 40
        //exit
      EndIf

    ENDDO
  ELSE
    Ret:=FALSE
  ENDIF

  FTOKENCLOS()

  close pos_swe

  RETURN Ret


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  11-23-18 * 12:56:06pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION ActSW_idAct(cPath_Order)
  LOCAL cLogSysCmd:=cSysCmd:=""
  LOCAL nError, i, cRezult, cData, lRet
  DEFAULT cPath_Order TO gcPath_ew+"obolon\swe2cus"

  filedelete("a_idAct.*")
  cSysCmd+="wget "+;
          "-O a_idact.txt "+;
          "http://10.0.1.113/sql/SWE_Actions.php"

  SYSCMD(cSysCmd,"",@cLogSysCmd)
  outlog(3,__FILE__,__LINE__,cSysCmd)
  outlog(3,__FILE__,__LINE__,cLogSysCmd)

  use (cPath_Order+'\a_idAct') alias a_idAct new Shared ReadOnly
  copy stru to a_idAct
  close a_idAct

  use ('.'+'\a_idAct') alias a_idAct new

  i:=0
  nError := FTOKENINIT('a_idact.txt', CHR(10), 1)
  IF (!(nError < 0))
    WHILE (!FTOKENEND())
      cRezult:= FTOKENNEXT()

      nPos:=AT('=> ',cRezult) + 3 //len('=> ') = 3
      cData:=alltrim(substr(cRezult,nPos))
      cData:=translate_charset("cp1251",host_charset(),cData)

      Do Case
      Case 'Array' $ cRezult
        DBAppend()
      Case '[UPL_id]' $ cRezult
        //=> 5175
        _FIELD->A_ID := VAL(cData) //       ��᫮        5          0
      Case '[NameAction]' $ cRezult
        // => � ����������� �3048/୮
        _FIELD->ANAME:=cData        //������       40
      Case '[BeginDate]' $ cRezult
        // => 2018-10-01
        _FIELD->ABEG:=CTOD(cData,'YYYY-MM-DD')    //    ���         8
      Case '[EndDate]' $ cRezult
        // => 2018-12-31
        _FIELD->AEND:=CTOD(cData,'YYYY-MM-DD')        //���         8
      Case '[TypeCode]' $ cRezult
        //  => 1
        _FIELD->ATYPE := VAL(cData)      // ��᫮        1          0
      Case '[ActionType]' $ cRezult
       //  => �����������
       _FIELD->ATNAME:=cData     //������       20
      Case '[Info]' $ cRezult
       // => �������  �������� �������� 1_95
       _FIELD->NAT:=cData         //������       80
      Case '[Qty_sht]' $ cRezult
        _FIELD->Qty_sht := VAL(cData)
      Case '[Expiry_date]' $ cRezult
        _FIELD->Dt_Expiry := CTOD(cData,'YYYY-MM-DD')
      ENDCASE



      //outlog(__FILE__,__LINE__,cRezult)
      //If (++i) > 40
      //  exit
      //EndIf

    ENDDO
  ELSE
    lRet:=FALSE
  ENDIF

  FTOKENCLOS()
  sele a_idAct
  index on str(a_id,5) tag t1
  close a_idAct

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  11-23-18 * 02:07:02pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION ActSW_prod(cPath_Order)
  LOCAL cLogSysCmd:=cSysCmd:=""
  LOCAL nError, i, cRezult, cData, lRet
  DEFAULT cPath_Order TO gcPath_ew+"obolon\swe2cus"

  filedelete("a_prod.*")
  cSysCmd+="wget "+;
          "-O a_prod.txt "+;
          "http://10.0.1.113/sql/SWE_Actions_Products.php"

  SYSCMD(cSysCmd,"",@cLogSysCmd)
  outlog(3,__FILE__,__LINE__,cSysCmd)
  outlog(3,__FILE__,__LINE__,cLogSysCmd)

  use (cPath_Order+'\a_prod') alias a_prod  new Shared ReadOnly
  copy stru to a_prod
  close a_prod

  use ('.'+'\a_prod') alias a_prod new

  i:=0
  nError := FTOKENINIT('a_prod.txt', CHR(10), 1)
  IF (!(nError < 0))
    WHILE (!FTOKENEND())
      cRezult:= FTOKENNEXT()

      nPos:=AT('=> ',cRezult) + 3 //len('=> ') = 3
      cData:=alltrim(substr(cRezult,nPos))
      cData:=translate_charset("cp1251",host_charset(),cData)

      Do Case
      Case 'Array' $ cRezult
        DBAppend()
      Case '[UPL_id]' $ cRezult    //=> 5175
        _FIELD->A_ID := VAL(cData) //       ��᫮        5          0
      Case '[localproductCode]' $ cRezult  //        => 3410918
        _FIELD->MNTOV := VAL(cData)       //��᫮        7          0
      Case '[localproductname]' $ cRezult  //        => 3410918
        _FIELD->NAT     := cData //������       80
      Case '[product_id]' $ cRezult //     => 21089
        _FIELD->P_ID := VAL(cData) //       ��᫮        6          0
      Case '[ProductName]' $ cRezult // => ���� "�����쪥 ஧�����" 1.95� ���
        _FIELD->PNAME   := cData //������       80
      Case '[Volume_L]' $ cRezult  //  => 1.95
        _FIELD->VOL     := VAL(cData) //��᫮        8          3
      Case '[Price]' $ cRezult  //    => 26.3
        _FIELD->PRICE   := VAL(cData) //��᫮        10         2
      Case '[Price_Char]' $ cRezult //   => 26.30
        _FIELD->PRICE_C := VAL(cData) //��᫮        10         2
      Case '[Price_L]' $ cRezult  //    => 26.3
        _FIELD->PRICE_L   := VAL(cData) //��᫮        10         2
      ENDCASE

      //outlog(__FILE__,__LINE__,cRezult)
      //If (++i) > 40
      //  exit
      //EndIf

    ENDDO
  ELSE
    lRet:=FALSE
  ENDIF

  FTOKENCLOS()
  sele a_prod
  index on str(mntov,7)+str(a_id,5) tag t1
  index on str(a_id,5) tag t2
  close a_prod

  RETURN (NIL)



/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  11-23-18 * 02:33:28pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION ActSW_TT(cPath_Order)
  LOCAL cLogSysCmd:=cSysCmd:=""
  LOCAL nError, i, cRezult, cData, lRet
  LOCAL aReadData
  DEFAULT cPath_Order TO gcPath_ew+"obolon\swe2cus"

  filedelete("a_tt.*")
  cSysCmd+="wget "+;
          "-O a_tt.txt "+;
          "http://10.0.1.113/sql/SWE_Actions_Outlets.php"

  SYSCMD(cSysCmd,"",@cLogSysCmd)
  outlog(3,__FILE__,__LINE__,cSysCmd)
  outlog(3,__FILE__,__LINE__,cLogSysCmd)

  aReadData:={;
    {'UPL_id'  , 'A_ID'   , {|cData|VAL(cData)} },;
    {'Ol_id'   , 'OL_id'  , {|cData|VAL(cData)} },;
    {'ol_code' , 'OL_Code', {|cData|cData}      };
             }
    //{'OL_id'   , 'OL_id'  , {|cData|VAL(cData)} },;
    //{'OL_Code', 'OL_Code', {|cData|cData}      };


  use (cPath_Order+'\a_TT') alias a_TT new Shared ReadOnly
  copy stru to a_TT
  close a_TT

  use ('.'+'\a_TT') alias a_TT new

  i:=0
  nError := FTOKENINIT('a_TT.txt', CHR(10), 1)
  IF (!(nError < 0))
    WHILE (!FTOKENEND())
      cRezult:= FTOKENNEXT()

      nPos:=AT('=> ',cRezult) + 3 //len('=> ') = 3
      cData:=alltrim(substr(cRezult,nPos))
      cData:=translate_charset("cp1251",host_charset(),cData)


      If 'Array' $ cRezult
        DBAppend()
      Else
        nPos:=ASCAN(aReadData,{|aElem| '['+upper(aElem[1])+']'  $ upper(cRezult) })
        If !EMPTY(nPos)
          FieldPut(FieldPos(aReadData[nPos,2]),EVAL(aReadData[nPos,3],cData))
        EndIf
      EndIf

      /*
      Do Case
      Case 'Array' $ cRezult
        DBAppend()
      Case '[UPL_id]' $ cRezult    //=> 5175
        _FIELD->A_ID := VAL(cData) //       ��᫮        5          0
      Case '[OL_id]' $ cRezult    //=> 5175
        _FIELD->OL_id := VAL(cData) //       ��᫮        5          0
      Case '[OL_Code]' $ cRezult // =>
        _FIELD->OL_Code  := cData //������       80
      ENDCASE
      */

    ENDDO
  ELSE
    lRet:=FALSE
  ENDIF

  FTOKENCLOS()

  sele a_TT
  index on ol_code+str(a_id,5) tag t1
  index on str(a_id,5) tag t2

  close a_TT

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  11-26-18 * 11:34:31am
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION OblnActSW()

  ActSW_idAct()
  ActSW_prod()
  ActSW_tt()


  cPath_Order:=gcPath_ew+"obolon\swe2cus"  //"j:\lodis\obolon\cus2swe"
  #ifdef __CLIP__
    set translate path off
  #endif

  OblnDirBlock(cPath_Order,"Clvrt Lodis Start Order")

  NoCopy4EmpDbf({'a_idact','add','str(a_id,5)', {|| str(_FIELD->a_id,5)}},'./',cPath_Order)
  NoCopy4EmpDbf({'a_prod' ,'add','str(mntov,7)+str(a_id,5)',{|| str(mntov,7)+str(a_id,5) }},'./',cPath_Order)
  NoCopy4EmpDbf({'a_tt'   ,'add','ol_code+str(a_id,5)',{|| ol_code+str(a_id,5) }},'./',cPath_Order)
  /*
  NoCopy4EmpDbf(cPath_Order,'a_idact')
  NoCopy4EmpDbf(cPath_Order,'a_prod')
  NoCopy4EmpDbf(cPath_Order,'a_tt')
  */

  #ifdef __CLIP__
    set translate path on
  #endif
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  12-03-18 * 12:56:20pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION OblnPayments(dDt,cPath_Order)
  LOCAL cLogSysCmd:=cSysCmd:=""
  LOCAL nError, i, cRezult, cData, lRet
  LOCAL aReadData
  DEFAULT dDt TO Date()

  DEFAULT cPath_Order TO gcPath_ew+"obolon\swe2cus"
  cSysCmd+="wget "+;
          "-O _payments.txt "+;
          "http://10.0.1.113/sql/SWE_Payments.php?date="+DTOC(dDt,'yyyy-mm-dd')

  SYSCMD(cSysCmd,"",@cLogSysCmd)
  outlog(3,__FILE__,__LINE__,cSysCmd)
  outlog(3,__FILE__,__LINE__,cLogSysCmd)

  aReadData:={;
  { 'OL_Code', 'OL_CODE', {|cData|cData} },;
  { 'Merch_id', 'Merch_id', {|cData|VAL(cData)} },;
  { 'TotalSum', 'Total_Sum', {|cData|VAL(cData)} },;
  { 'PaymentNo', 'Payment_No', {|cData|val(cData)} },;
  { 'PaymentDate', 'document', {|cData|cData} },;
  { 'reason', 'reason', {|cData|cData} };
             }


  #ifdef __CLIP__
    set translate path off
  #endif

  // OblnDirBlock(cPath_Order,"Clvrt Lodis Start Order")
  if !file('PAYMENTS.DBF')
    USE (cPath_Order+"\"+"PAYMENTS.DBF") ALIAS pnm ;
    new Shared ReadOnly
    copy stru to PAYMENTS.DBF
    close pnm
  else
    USE ('.'+"\"+"PAYMENTS.DBF") ALIAS pnm new Exclusive
    ZAP
    close pnm
  endif


  USE ('.'+"\"+"PAYMENTS.DBF") ALIAS pnm new

  #ifdef __CLIP__
    set translate path on
  #endif

  i:=0
  nError := FTOKENINIT('_payments.txt', CHR(10), 1)
  IF (!(nError < 0))
    WHILE (!FTOKENEND())
      cRezult:= FTOKENNEXT()

      nPos:=AT('=> ',cRezult) + 3 //len('=> ') = 3
      cData:=alltrim(substr(cRezult,nPos))
      cData:=translate_charset("cp1251",host_charset(),cData)

      If 'Array' $ cRezult
        DBAppend()
        repl Pay_date with date()
      Else
        nPos:=ASCAN(aReadData,{|aElem| '['+aElem[1]+']'  $ cRezult })
        If !EMPTY(nPos)
          FieldPut(FieldPos(aReadData[nPos,2]),EVAL(aReadData[nPos,3],cData))
        EndIf
      EndIf

    ENDDO
  ELSE
    lRet:=FALSE
  ENDIF

  FTOKENCLOS()

  close pnm

  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  12-03-18 * 08:47:32pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION OblnOrders(dDt,cPath_Order)

  LOCAL cLogSysCmd:=cSysCmd:=""
  LOCAL nError, i, cRezult, cData, lRet
  LOCAL aReadData
  DEFAULT dDt TO Date()

  DEFAULT cPath_Order TO gcPath_ew+"obolon\swe2cus"
  cSysCmd+="wget "+;
          "-O _orders.txt "+;
          "http://10.0.1.113/sql/SWE_orders.php?date="+DTOC(dDt,'yyyy-mm-dd')

  SYSCMD(cSysCmd,"",@cLogSysCmd)
  outlog(3,__FILE__,__LINE__,cSysCmd)
  outlog(3,__FILE__,__LINE__,cLogSysCmd)

  aReadData:={;
  { '��������', 'order_no', {|cData|val(cData)}},;
  { '��⠄��', 'order_date', {|cData|CTOD(cData,'YYYY-MM-DD')}},; // ???????????????�ଠ�
  { '�६�', 'dtlm', {|cData| DTLM(order_date,cData)}},; //  ----------------------
  { '�����', 'merch_id', {|cData|val(cData)}},; //
  { '������', 'ol_code', {|cData|cData}},; //
  { '�����࣮���', 'op_code', {|cData|cData}},; //
  { '���������', 'wareh_code', {|cData|cData}},; //
  { '�����⥣�ਨ���', 'payform_id', {|cData|val(cData)}},; //
  { '�⮂�����', 'isreturn', {|cData|val(cData)}},; //
  { '�������਩', 'comment', {|cData|cData}},; //
  { 'OrderExecutionDate', 'exec_date', {|cData|CTOD(cData,'YYYY-MM-DD')}},; //  ???????????????�ଠ�
  ;//{ '����ࠣ���', '', {| cData|cData}},; //  -------------------
  { '���ᄮ�⠢��', 'deliv_addr', {|cData|cData}}; //
  ;//{ '���������', '', {|cData|cData}},; //  ------------------------
                        }


  #ifdef __CLIP__
    set translate path off
  #endif

  // OblnDirBlock(cPath_Order,"Clvrt Lodis Start Order")

  USE (cPath_Order+"\"+"OLORDERH.DBF") ALIAS OrdH ;
  new Shared ReadOnly
  copy stru to tmp_OrdH
  close OrdH

  USE ('.'+"\"+"tmp_OrdH") ALIAS OrdH new

  #ifdef __CLIP__
    set translate path on
  #endif

  nError := FTOKENINIT('_orders.txt', CHR(10), 1)
  IF (!(nError < 0))
    WHILE (!FTOKENEND())
      cRezult:= FTOKENNEXT()
      cRezult:=translate_charset("cp1251",host_charset(),cRezult)

      nPos:=AT('=> ',cRezult) + 3 //len('=> ') = 3
      cData:=alltrim(substr(cRezult,nPos))
      //cData:=translate_charset("cp1251",host_charset(),cData)
      //OUTLOG(__FILE__,__LINE__,cData,cRezult)
      //LOOP


      If 'Array' $ cRezult
        DBAppend()
      Else
        nPos:=ASCAN(aReadData,{|aElem| '['+aElem[1]+']'  $ cRezult })
        If !EMPTY(nPos)
          FieldPut(FieldPos(aReadData[nPos,2]),EVAL(aReadData[nPos,3],cData))
        EndIf
      EndIf

    ENDDO
  ELSE
    lRet:=FALSE
  ENDIF

  FTOKENCLOS()

  sele OrdH
  index on order_no to OrdH1 uniq
  copy to olorderh.dbf

  close OrdH


  // ��⥫� ���
  aReadData:={;
   { '��������', 'order_no', {|cData|VAL(cData)}};
  ,{ '��������', 'localcode', {|cData|cData}};
  ,{ '������⢮', 'qty', {|cData|VAL(cData)}};
  ,{ '����', 'price', {|cData|VAL(cData)}};
           }

  #ifdef __CLIP__
    set translate path off
  #endif

  // OblnDirBlock(cPath_Order,"Clvrt Lodis Start Order")

  USE (cPath_Order+"\"+"OLORDERD.DBF") ALIAS OrdD ;
  new Shared ReadOnly
  copy stru to tmp_OrdD
  close OrdD

  USE ('.'+"\"+"tmp_OrdD") ALIAS OrdD new

  #ifdef __CLIP__
    set translate path on
  #endif

  nError := FTOKENINIT('_orders.txt', CHR(10), 1)
  IF (!(nError < 0))
    WHILE (!FTOKENEND())
      cRezult:= FTOKENNEXT()
      cRezult:=translate_charset("cp1251",host_charset(),cRezult)

      nPos:=AT('=> ',cRezult) + 3 //len('=> ') = 3
      cData:=alltrim(substr(cRezult,nPos))
      //cData:=translate_charset("cp1251",host_charset(),cData)
      //OUTLOG(__FILE__,__LINE__,cData,cRezult)
      //LOOP


      If 'Array' $ cRezult
        DBAppend()
      Else
        nPos:=ASCAN(aReadData,{|aElem| '['+aElem[1]+']'  $ cRezult })
        If !EMPTY(nPos)
          FieldPut(FieldPos(aReadData[nPos,2]),EVAL(aReadData[nPos,3],cData))
        EndIf
      EndIf

    ENDDO
  ELSE
    lRet:=FALSE
  ENDIF

  FTOKENCLOS()

  sele OrdD
  copy to olorderd.dbf

  close OrdD

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  04-29-19 * 07:56:17pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
STATIC FUNCTION NoCopy4EmpDbf(aElemFileSend,cPth_Plt_tmp,cPath_Order)
  LOCAL cDbf,  cSetRela2,  bSetRela2
  LOCAL lErr:=.F.

  cDbf:=aElemFileSend[1]
  cSetRela2:=aElemFileSend[3]
  bSetRela2:=aElemFileSend[4]

  outlog(3,__FILE__,__LINE__,cPath_Order+'\' + cDbf + '.dbf',file(cPath_Order+'\' + cDbf + '.dbf'))

  If .T. //!file(cPath_Order+'\' + cDbf + '.dbf')
    use (cDbf) new //a_idact.dbf
    If !Empty(LastRec())
      close
      copy file (cDbf+'.dbf') to (cPath_Order+'\' + cDbf + '.dbf')
      copy file (cDbf+'.cdx') to (cPath_Order+'\' + cDbf + '.cdx')
    else
      close
      lErr:=.T.
    endif
  Else

    USE (cPath_Order+"\" + cDbf + '.dbf') ALIAS (cDbf) NEW Exclusive
    ordsetfocus('t1')
    FieldPut(1,FieldGet(1)) // ��� ����������
    // ����� ������ ��� ����������
    USE (cPth_Plt_tmp+"\" + cDbf + '.dbf') ALIAS (cDbf+'_1') NEW
    // ��� � ��筨���
    dbSetRelat(cDbf, bSetRela2) //, aFileSend[k,3])
    // ����஢���� ��, ������ ��� -> tmpadd
    copy to ('_'+cDbf) for (cDbf)->(!found())
    // copy to tmp!add for (aFileSend[k,1])->(found())

    CLOSE (cDbf+'_1')

    SELE (cDbf)
    APPEND FROM ('_'+cDbf)

    CLOSE (cDbf)

  EndIf

  If lErr
    // ᮮ�饭�� � ���⮩ ����
      //cMessErr:="��� ������ ��� ⠡���� "+(cPath_Order+'\'+cDbf+'.dbf');
      cMessErr:="��� ������ ��� ⠡���� "+cDbf+'.dbf';
      +" "+DTOC(DATE(),"YYYYMMDD")+"-"+TIME()
       SendingJafa(;
       "l.gupalenko@ukr.net,lista@bk.ru",;
       {{ '',;
        translate_charset(host_charset(),"utf-8",;
        cMessErr);
        }},;
      cMessErr+chr(10)+chr(13)+'����� �� ���������.',;
      228)

  EndIf
  RETURN (NIL)

/*
  */
FUNCTION SbArOst2Swe(cPth_Plt_lpos,dReport)
  DEFAULT dReport TO date()

  filedelete('t2'+".*")
  filedelete('sbar_t1'+".*")
  filedelete('sbar_t2'+".*")

  sele 0
  use sbarost alias sbar
  index on PosTpId to sbar_t1
  index on inp to sbar_t2
  set index to sbar_t1, sbar_t2


  sele 0
  use (cPth_Plt_lpos+'\l2s_str') alias l2s_str

  sele 0
  use (cPth_Plt_lpos+'\pos_swe') alias swe Exclusive
  copy stru to (cPth_Plt_lpos+'\pos!swe')

  sele l2s_str
  copy stru to lod2swe
  use

  sele 0
  use lod2swe alias lsw Exclusive
  index on str(PosId,7) to t2

  sele 0
  use (cPth_Plt_lpos+'\pos!swe') alias !swe

  //ᯨ᮪, �� ��� ���
  sele swe
  go top
  while (!eof())
    Pos_Idr=pos_id
    PosTpIdr=allt(str(pos_id,7))
    invr=allt(str(inv))

    // ���㤮����� � �����
    sele sbar
    set order to 1
    seek PosTpIdr // ������⢥���� ����७��
    If found()

      whr := 2029 // - ���
      If "-� " $ sbar->Nat
        whr := 7732 // - ����⮯
      EndIf

      while (allt(PosTpId) == PosTpIdr)
        if (sk=242 .and. osf>0)
          //outlog(__FILE__, __LINE__,'Techr',Techr)
          Techr:=val(allt(sbar->PosTehCo))
          Cusr=52
          //Techr=2

          DocTyper:=0
          TTr := ''
          Ttnr := ''
          Dater := blank(date())
          /*
          If ArDt = dReport
            DocTyper := 1
          EndIf
          */
          TTr := str(kgp,7)+"-"+str(kpl,7)
          Ttnr := '18005-'+alltrim(str(ArTtn))
          Dater := ArDt
          DocTyper:=1

          // १�������� ��
          sele lsw
          appe blank
          repl CustId with Cusr,  ;
           ;//PosId with swe->PosTpId,   ;  // Pos_Idr ; val(allt(SbAr->PosTpId))
           PosId with val(allt(SbAr->PosTpId)),   ;// Pos_Idr, ;
           olcode with TTr,       ;
           TechnicalC with Techr, ;
           DocType with DocTyper, ;
           tsconno with Ttnr,     ;
           tsconsd with Dater,;
           comment with SbAr->comment,;
           dtlm with str(SbAr->mntov)
           sele lsw
           repl wh with whr

          If PosId = 79125
            outlog(3,__FILE__,__LINE__,"PosId,RecNo(),PosTpIdr,sbar->(RecNo())",PosId,RecNo(),PosTpIdr,sbar->(RecNo()))
          EndIf

        endif

        sele sbar
        skip
      enddo
    Else
      // ��� ������ � �����
      sele swe
      copy to tmp1 next 1
      sele !swe
      append from tmp1

    EndIf

    sele swe
    skip
  enddo

  sele !swe
  appe blank

  /*************** */
  //ᯨ᮪, �� ��� ���
  sele swe
  go top
  while (!eof())
    Pos_Idr=pos_id
    PosTpIdr=allt(str(pos_id,7))
    invr=allt(str(inv))

    sele sbar
    set order to 1
    seek PosTpIdr // ���� ࠧ ���������
    if (found())

      whr := 2029 // - ���
      If "-� " $ sbar->Nat
        whr := 7732 // - ����⮯
      EndIf

      if (sk=243 .and. osf>0)
        Techr:=val(allt(sbar->PosTehCo))
        do case
          case Techr=3
            TTr := str(kgp,7)+"-"+str(kpl,7)
            Ttnr := '18005-'+alltrim(str(ArTtn))
            Dater := ArDt
            DocTyper := 2
            Reasonr := 'TO'
            //ReservDr := ctod(str(comment,10))  //?
          case Techr=8 //rezerv
            TTr := ''
            Ttnr := ''
            Dater := CTOD('  .  .  ') //?
            DocTyper := 3
            Techr := 1
            if empty(comment)
              ReservDr := date()+10
            else
              ReservDr := ctod(str(comment,8))  //?
            endif
            Reasonr := ''  //?
          otherwise
            TTr := ''
            Ttnr := ''
            Dater := CTOD('  .  .  ') //?
            DocTyper := 3
            Reasonr := ''  //?
            //ReservDr := ctod(str(comment,10))  //?
        endcase
        /*
        DocTyper:=0
        TTr := ''
        Ttnr := ''
        Dater := blank(date())
        If ArDt = dReport
          DocTyper := 2
          TTr := str(kgp,7)+"-"+str(kpl,7)
          Ttnr := '18005-'+alltrim(str(ArTtn))
          Dater := ArDt

        EndIf
          //TTr := str(kgp,7)+"-"+str(kpl,7)
          //Ttnr := '18005-'+alltrim(str(ArTtn))
          //Dater := ArDt
        */
        sele lsw
        seek str(Pos_Idr,7)
        if (!found())
          Cusr=52
          //Techr=1
          //TTr=''  //?
          sele lsw
          appe blank
          repl CustId with Cusr, ;
           ;//PosId with swe->PosTpId,   ;// Pos_Idr, ; val(allt(SbAr->PosTpId))
           TechnicalC with Techr, ;
           PosId with val(allt(SbAr->PosTpId)),   ;// Pos_Idr, ;
           TechnicalC with Techr,;
           DocType with DocTyper, ;
           tsconno with Ttnr,     ;
           tsconsd with Dater,;
           comment with SbAr->comment,;
           dtlm with str(SbAr->mntov),;
           Reason with Reasonr,;
           olcode with TTr
           //ReservD with ReservDr,;
           sele lsw
           repl wh with whr
          If PosId = 79125
            outlog(3,__FILE__,__LINE__,"PosId,RecNo()",PosId,RecNo())
          EndIf
        endif

      endif
    else
       sele sbar
       set order to 2
       seek invr
       if !found()

          sele lsw
          Cusr=52
          Techr=11
          TTr=''
          Ttnr=''
          DocTyper := 3
          Dater := CTOD('  .  .  ')
          dtlmr := str(SbAr->mntov)
          Reasonr := Reason

          sele lsw
          appe blank
          repl CustId with Cusr, ;
               TechnicalC with Techr, ;
               PosId with Pos_Idr, ;
               TechnicalC with Techr,;
               DocType with DocTyper, ;
               tsconno with Ttnr,     ;
               tsconsd with Dater,;
               comment with '',;
               dtlm with dtlmr,;
               Reason with Reasonr,;
               olcode with TTr
          sele lsw
          repl wh with whr
          If PosId = 79125
            outlog(3,__FILE__,__LINE__,"PosId,RecNo()",PosId,RecNo())
          EndIf
      else
        // ��� ������ � �����
        sele swe
        copy to tmp1 next 1
        sele !swe
        append from tmp1
      endif

    endif

    sele swe
    skip
  enddo

  /*
  whr := 2029
  sele lsw
  repl all wh with whr
  */


  sele sbar; use
  sele lsw; use
  sele swe; use
  sele !swe; use

  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  08-22-19 * 06:01:40pm
 ����������......... �������� ��६����� MnTovr � ���筮�� ⮢�� �� MnTov
                     ��樮����
 ���������.......... MnTovr, kplr, kgpr DtRor - ������ ���� ��।����� ��ॢ맮��� �-�
                     MnTovr - �� ������ ���� ��樮���
 �����. ��������.... ��������� MnTovr
 ����������.........
 */
FUNCTION Act_MnTov4_MnTov()
  //para MnTovr, kplr, kgpr
  // ������� ᯨ᮪ ������
  LOCAL nPos, aMnTov, lRet
  aMnTov:={}
  AADD(aMnTov,MnTovr)
  IF .T.
    MnTovTr=getfield('t1','mntovr','ctov','MnTovT') // த�⥫�
    nBarCode=getfield('t1','MnTovTr','ctov','bar')
    If !empty(nBarCode)
      sele ctov
      ordsetfocus('t4')
      netseek('t4','nBarCode')
      Do While nBarCode = Bar
        If Empty(ascan(aMnTov,MnTov))
          AADD(aMnTov,MnTov)
        EndIf
        DBSkip()
      EndDo
    EndIf
  ENDIF
    outlog(3,__FILE__,__LINE__,'MnTovr,nBarCode',MnTovr,nBarCode)
    outlog(3,__FILE__,__LINE__,'aMnTov', aMnTov)

  aAktcTov:={}
  For k:=1 To LEN(aMnTov)
    mntovr=aMnTov[k]
    A_Idr:=0
    ANamer:=""
    A_Nat:=""
    ATyper:=0
    If ActSWChk(mntovr, kgpr, kplr, DtRor, .F. , @A_Idr, @ANamer, @ATyper,@A_Nat)
      outlog(3,__FILE__,__LINE__,'  // ��諨 ��� ,A_Idr,ANamer,ATyper',A_Idr,allt(ANamer),ATyper)
      outlog(3,__FILE__,__LINE__,'  // Nat', A_Nat)

      If "5+1" $ A_Nat
        outlog(3,__FILE__,__LINE__,'  // 5+1 -> ������ �믨����� ����� ⮢��')
        loop
      EndIf

      nPos:=AT('/',ANamer)
      If Atyper=3
        nPos:=0
      EndIf
      outlog(3,__FILE__,__LINE__,"  nPos:=AT('/',ANamer)",nPos)

      If EMPTY(nPos)
        outlog(3,__FILE__,__LINE__,'  // ��諨 ���� ��� "/" ',allt(str(mntovr)),A_Idr,ANamer)
        // �஢�ઠ �� 㭨���쭮��� ��権
        If Empty(aAktcTov) ;
          .or. (nPos:=AScan(aAktcTov,{|aElem| A_Idr = aElem[3] }),;
          Empty(nPos);
        )
          AADD(aAktcTov,{;
            mntovr;
          , getfield('t1','mntovr','ctov','NaT');
          , A_Idr;
          , ANamer;
          , ATyper})
          outlog(3,__FILE__,__LINE__,'  //AADD(aAktcTov ',ATAIL(aAktcTov))
        EndIf
      Else
        //
        cTypeAktc:=SUBSTR(ANamer,nPos,2)
        outlog(3,__FILE__,__LINE__,"  cTypeAktc:=SUBSTR(ANamer,nPos,2)",cTypeAktc)

        cTov_nat:=getfield('t1','mntovr','ctov','NaT')
        outlog(3,__FILE__,__LINE__,"  mntovr,cTov_nat",mntovr,cTov_nat)

        If cTypeAktc $ cTov_nat
          outlog(3,__FILE__,__LINE__,'  // ��諨 ���� ',mntovr,cTypeAktc,A_Idr,ANamer)
          AADD(aAktcTov,{mntovr,getfield('t1','mntovr','ctov','NaT'),A_Idr, ANamer, ATyper})
        EndIf
      EndIf

      //exit
    Else
    EndIf
  Next k

  If empty(aAktcTov) // ��� ���. ⮢��
    // �஢�ਬ �⮡� �� �믨ᠬ� ��� ⮢��.
    mntovr:=0 // ��� ���筮�� ⮢��
    nPos:=AScan(aMnTov,{|nMnTov| mntovr:=nMnTov, .not. ('���' $ UPPER(getfield('t1','mntovr','ctov','NaT'))) })
    If !Empty(nPos)
      mntovr:=aMnTov[nPos] // ����� ⮢��
    EndIf
    outlog(3,__FILE__,__LINE__,'  // ��� ���.⮢',mntovr)
    lRet:=.F.
  else

    If len(aAktcTov) = 1 // ���� ���
      nPos=99999
      /*
      // ������ ���  � "/"
      Do Case
      Case aAktcTov[1, 5] = 3 //AType
        nPos=AScan(aAktcTov,{|aElem| ('/' $ aElem[4]) })
      Case aAktcTov[1, 5] = 2 // ���� ��� "/"
        nPos=99999
        If "��०���" $ aAktcTov[1, 4] //AName
          nPos:=0 // ����� ⮢��
        EndIf
      OtherWise
        nPos=AScan(aAktcTov,{|aElem| ('/' $ aElem[4]) })
      EndCase
      */
      If "��०���" $ aAktcTov[1, 4] //AName
        nPos:=0 // ����� ⮢��
      EndIf

      If Empty(nPos) // ��� "/" ����
        mntovr:=0 // ��� ���筮�� ⮢��
        nPos:=AScan(aMnTov,{|nMnTov| mntovr:=nMnTov, .not. ('���' $ UPPER(getfield('t1','mntovr','ctov','NaT'))) })
        mntovr:=0 // ��� ���筮�� ⮢��
        If !Empty(nPos)
          mntovr:=aMnTov[nPos] // ����� ⮢��
        EndIf
        outlog(3,__FILE__,__LINE__,'  // MnTov not. ���',mntovr,nPos)
      Else
        mntovr:=aAktcTov[1,1]
        outlog(3,__FILE__,__LINE__,'  // ���.⮢ ���� ���',mntovr)
      EndIf
      lRet:=.T.
    Else // ����� 1-��

      outlog(3,__FILE__,__LINE__,'  // ���.⮢ > 1-��',mntovr)
      AEVAL(aAktcTov,{|aElem| outlog(3,__FILE__,__LINE__, aElem) })

      nPos=AScan(aAktcTov,{|aElem| .not. ('/' $ aElem[4]) })
      outlog(3,__FILE__,__LINE__,nPos,'aAktcTov .not. ᫥�')
      If Empty(nPos)
        mntovr:=0 // ��� ���筮�� ⮢��
        nPos:=AScan(aMnTov,{|nMnTov| mntovr:=nMnTov, .not. ('���' $ UPPER(getfield('t1','mntovr','ctov','NaT'))) })
        mntovr:=0 // ��� ���筮�� ⮢��
        If !Empty(nPos)
          mntovr:=aMnTov[nPos] // ����� ⮢��
        EndIf
        outlog(3,__FILE__,__LINE__,nPos,'  MnTov not. ���',mntovr)
        lRet:=.F.

      Else
        mntovr:=aAktcTov[nPos,1]
        lRet:=.T.
      EndIf
      outlog(3,__FILE__,__LINE__,'  // ���.⮢ > 1-��',mntovr)

    EndIf

  EndIf

  outlog(3,__FILE__,__LINE__,'=End')
  Return  lRet

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  11-27-18 * 05:01:35pm
 ����������.........
 ���������.......... lRetNotAct - �� ������� �᫨ ⮢�� �� ����
 �����. ��������....
 ����������.........
 */
STATIC FUNCTION ActSWChk(nl_MnTov,nl_Kgp,nl_Kpl, dDate, lRetNotAct, nA_Id, cAName, nAType, cA_Nat,cPath_Order)
  LOCAL lRet:=.F., aMess:={''}, lAkc
  DEFAULT lRetNotAct TO .T.
    outlog(3,__FILE__,__LINE__,'nl_MnTov,nl_Kgp,nl_Kpl',allt(str(nl_MnTov)),nl_Kgp,allt(str(nl_Kpl)))

  //lRet:=.T.
  //RETURN (lRet)
  DEFAULT cPath_Order TO gcPath_ew+"obolon\swe2cus"
  outlog(3,__FILE__,__LINE__,"gcPath_ew",gcPath_ew,"obolon\swe2cus")
  OpenDbSW4Zen(cPath_Order)

  lAkc:=.F.
  sele a_prod
  ordsetfocus('t1')
  If DBSEEK(str(nl_MnTov,7)) // ⮢�� ���� � ᯨ᪥ ��権
    if '���' $ UPPER(a_prod->Nat)
      lAkc:=.T.
      outlog(3,__FILE__,__LINE__, "  // ⮢�� ��� - '���' $ UPPER(a_prod->Nat)")
    else
      lRet:=lRetNotAct
      If lRet
        outlog(3,__FILE__,__LINE__, "  //⮢�� �� ��� ����� ��ࠡ��뢠�� ��८業��")
      Else
        outlog(3,__FILE__,__LINE__, "  //⮢�� �� ��� !('���' $ a_prod->Nat)")
      EndIf
      RETURN (lRet) //
    Endif
  else
    outlog(3,__FILE__,__LINE__, " ��� ⮢�� � ᯨ᪥ ��権")
  Endif

    //.and. ('���' $ UPPER(a_prod->Nat).)
  If lAkc
    sele a_tt
    cOl_code:=ltrim(STR(nl_kgp,7)+"-"+STR(nl_kpl,7)) // 㤠���� ���騥 �஡���
    If DBSeek(cOl_code)
      // �� ᯨ᮪ c ���. ���ﬨ
      DO WHILE ol_code = cOl_code
        // ���� ��� ��樨
        nA_Id:=a_tt->A_Id

        sele a_idAct // ⠡��� ��権, � ������ ������ ��
        If DBSeek(str(nA_id,5))
          cAName:=a_idAct->AName
          cA_Nat:=a_idAct->Nat
          nAType:=a_idAct->AType

          //If iif(dDate = DATE(),.T.,dDate >= ABeg)  .AND. dDate <= AEnd
          If dDate >= ABeg .AND. dDate <= AEnd

            sele a_prod
            ordsetfocus('t1')
            If DBSEEK(str(nl_MnTov,7)+str(nA_id,5)) // ⮢�� ���� � ᯨ᪥ ��権

              lRet:=.T.
              exit
            Else
              AADD(aMess,__LINE__;
              +' AKC=>TT ��� 4 ����� � �-樨 a_id='+str(nA_Id,5);
            )
            EndIf
          Else

            If dDate = DATE()
              AADD(aMess,__LINE__;
              +' AKC=>�-�� �� � �ப�� a_id='+str(nA_Id,5);
              +' '+DTOC(ABeg)+' '+DTOC(AEnd);
              +' '+DTOC(dDate))
            Else
              AADD(aMess,__LINE__;
              +' AKC=>�-�� �� � �ப�� a_id='+str(nA_Id,5);
              +' '+DTOC(ABeg);
              +' '+DTOC(AEnd)+' '+DTOC(dDate))
            EndIf
          EndIf
        Else
          AADD(aMess,__LINE__;
          +' AKC=>�-樨 ��� a_id='+str(nA_Id,5))
        EndIf

        sele a_tt
        DBSkip()
      ENDDO
    ELSE
      AADD(aMess,__LINE__ ;
      +' !!!AKC=>�-権 ��� ��� ��',cOl_code)

    ENDIF
  ELSE
    lRet:=lRetNotAct
  ENDIF

  If !lRet .and. len(aMess) > 1
    sele a_prod
    ordsetfocus('t1')
    DBSEEK(str(nl_MnTov,7)) // ⮢�� ���� � ᯨ᪥ ��権
    outlog(3,__FILE__,__LINE__,'Error AKC=>TT',str(nl_MnTov,7)+' '+a_prod->Nat)
    outlog(3,__FILE__,__LINE__,'  '+DTOC(dDate) +' '+cOl_code)
    //outlog(3,__FILE__,__LINE__,' ',aMess)
    AEval(aMess,{|cMess| outlog(3,__FILE__,__LINE__, "  "+cMess) },2)
    outlog(3,__FILE__,__LINE__, "")
  EndIf
  RETURN (lRet)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  07-14-20 * 01:58:51pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
STATIC FUNCTION PosSalesWebRead(cPath, cFile)

  LOCAL cLogSysCmd:=cSysCmd:=""
  LOCAL nError, i, cRezult, cData, lRet
  LOCAL aReadData

  cSysCmd+="wget "+;
          "-O _posout.txt "+;
          "http://10.0.1.113/sql/SWE_prPOS_POSout.php"

  SYSCMD(cSysCmd,"",@cLogSysCmd)
  outlog(3,__FILE__,__LINE__,cSysCmd)
  outlog(3,__FILE__,__LINE__,cLogSysCmd)
  //  { 'Name', 'NAME', {|cData| translate_charset("cp1251",host_charset(),cData)}},;
  //  { 'POS_Name', 'POS_NAME', {|cData| translate_charset("cp1251",host_charset(),cData)}},;

  aReadData:={;
  { 'Invent_No', 'INV', {|cData| val(cData)}},;
  { 'Serial_No', 'SERIAL', {|cData| cData}},;
  { 'POS_Name', 'POS_NAME', {|cData| cData}},;
  { 'POSType_ID', 'POSTPID', {|cData| val(cData)}},; //
  { 'Name', 'NAME', {|cData| cData}},;
  { 'YearProduction', 'YEARP', {|cData| cData}},; //
  { 'Cust_id', 'CUST_ID', {|cData| val(cData)}},; //
  { 'ManufacturerId', 'POSMANUF', {|cData| val(cData)}},; //
  { 'TechnicalCondition', 'TECHCOND', {|cData| val(cData)}},; //
  { 'POS_ID', 'POS_ID', {|cData| val(cData)}},; //
  { 'POSDocDate', 'POSDocDate', {|cData| CTOD(cData,'YYYY-MM-DD')}};
       }

  use (cPath+'\'+'pos_swe') new Exclusive
  copy stru to (cPath+'\'+'pos_swe2')
  use
  use (cPath+'\'+'pos_swe2') new Exclusive

  RezultPhp2Dbf('_posout.txt',aReadData)

  close pos_swe2

  use (cPath+'\'+'pos_swe') alias pos_swe new Exclusive
  nSec:=SECONDS()
  Do While nSec+600 > SECONDS()
    If !neterr()
      sele pos_swe
      zap
      append from (cPath+'\'+'pos_swe2')
      exit
    EndIf
    outlog(__FILE__,__LINE__,"inkey(30)",'neterr("pos_swe")=0',cPath)
    #ifdef __CLIP__
      sleep(30)
    #else
      inkey(30)
    #endif
  EndDo
  If !empty(select("pos_swe"))
    close pos_swe
  EndIf


  RETURN ( NIL )


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  07-14-20 * 03:45:30pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
STATIC FUNCTION RezultPhp2Dbf(cFile,aReadData)
  LOCAL nError, cRezult, cData, nFldPos
  LOCAL lRet
  lRet := TRUE
  nError := FTOKENINIT(cFile, CHR(10), 1)
  IF (!(nError < 0))
    WHILE (!FTOKENEND())
      cRezult:= FTOKENNEXT()
      cRezult:=translate_charset("cp1251",host_charset(),cRezult)

      nPos:=AT('=> ',cRezult) + 3
      cData:=alltrim(substr(cRezult,nPos))

      If 'Array' $ cRezult
        DBAppend()
      Else
        nPos:=ASCAN(aReadData,{|aElem| '['+upper(aElem[1])+']' $ upper(cRezult) })
        If !EMPTY(nPos)
          nFldPos := FieldPos(aReadData[nPos,2])
          If !Empty(nFldPos)
            FieldPut(nFldPos,EVAL(aReadData[nPos,3],cData))
          EndIf
        EndIf
      EndIf

    ENDDO
  ELSE
    lRet:=FALSE
  ENDIF

  FTOKENCLOS()
  RETURN ( lRet )


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  07-17-20 * 09:54:23am
 ����������.........
 ���������..........
 �����. ��������.... ��⠢�� ������
 ����������.........
 */
FUNCTION lod2swe2sql(cPth_Plt_lpos)
  LOCAL cLogSysCmd:=cSysCmd:=""
  LOCAL cDataSql, aSqlCmd, i, t1
  If .t.

    copy file (cPth_Plt_lpos+'\pos.sql') to ('pos.sql')
    cLogSysCmd:=cSysCmd:=""

    cSysCmd+='./SWE_sendPos.bat'

    t1:=SECONDS()
    outlog(__FILE__,__LINE__,filesize('pos.sql'),cSysCmd)
    SYSCMD(cSysCmd,"",@cLogSysCmd)
    outlog(__FILE__,__LINE__,t1-SECONDS(),cLogSysCmd)

  Else
    cDataSql := memoread(cPth_Plt_lpos+'\pos.sql')
    cDataSql := CHARREM(CHR(10),cDataSql)
    cDataSql := CHARREM(CHR(13),cDataSql)

    aSqlCmd := split(cDataSql,';')
    For i:=1 To len(aSqlCmd)
      If !empty(aSqlCmd[i])
        cLogSysCmd:=cSysCmd:=""
        cSysCmd+='wget '+;
                '-O _inspos.log '+;
                'http://10.0.1.113/sql/SWE_vIncoming_POS.php?sql=' + ;
                '"' + aSqlCmd[i] + '"'

        SYSCMD(cSysCmd,"",@cLogSysCmd)
        outlog(3,__FILE__,__LINE__,cSysCmd)
        outlog(3,__FILE__,__LINE__,cLogSysCmd)
      EndIf

    Next i
  EndIf


  RETURN ( NIL )

static Function LocalPosStatus()
  // 9 - ���� ��� ��, ������ ��� � ��娢����⪮�

  If !Empty(select("LPOSARCH"))
    SELE LPOSARCH
    OrdSetFocus('t3')
    SELE LOCALPOS
      /*
              Status  Numeric 11      ����� (2 - '��⨢��', 9 - '����⨢��')
      �� 㬮�砭�� - 2        ��
      */
    DBEval({||_FIELD->Status:=Iif(LPOSARCH->(DBSeek(LOCALPOS->LocalCode)),2,9)})

    close LOCALPOS
    close LPOSSIND
    close LPOSSINH
    close LPOSTRSD
    close LPOSTRSH
    close LPOSARCH
  EndIf
  Return ( Nil )
