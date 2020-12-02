#include "common.ch"
#include "set.ch"
#include "inkey.ch"

#define OB_IN_VATCALCMOD  0
/*
0 - VatCalcMod=0, Price - без_НДС
1 - VatCalcMod=1, Price - с_НДС
2 - VatCalcMod=1, Price - без_НДС
*/
#define OB_OUT_VATCALCMOD 0
#define OB_LIST_BRAK_S '262;263' // склады брака Сумы
#define OB_LIST_BRAK_K '704;705' // склады брака Конотоп
#define OB_LIST_SIDR '3400249 3400248 3400243' // кода сидра

  STATIC aMessErr


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  03-16-14 * 09:48:18am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 1 cDosParam
 2 dDt дата
 3  cSend
 4   aFileListZip
 5    lNo_deb - не просчитывать д-ку
 6     lNo_executed_order - добавлять "не выполненые заказы"
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION pilot2_obolon(cDosParam, dDt, cSend, aFileListZip, lNo_deb, lNo_executed_order)
  LOCAL cMkeep, aKta
  LOCAL lTmp_kpl:=.F. //справочник Плат и ТТ по огрузке(.T.) или общий по МаркДер.
  LOCAL aFlDir, aStruDbf, cFile, nPos, nRec
  LOCAL i, lZap, cCOX_Sl_list, cListSaleSk, aMessErr
  LOCAL nSdp_Deb, nSdp_SkDoc
  LOCAL nSumKop211p:=0,  nSumKop211n:=0
  LOCAL nQKop211p:=0,  nQKop211n:=0
  LOCAL lJoin, nNmOst
  LOCAL cRunUnZip:="/usr/bin/unzip"


  DEFAULT cSend TO "One"; //dDt TO date()
  , lNo_deb TO .f. ; // f - просчет
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
      "Подготовка отчета ОБОЛОНЬ данных за период.",;
      "имя файла архива ol_<дата1>-<дата2>.zip",;
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

        /// пересчет данных в цикле
        IF !(UPPER("/no_mkotch") $ UPPER(cDosParam))
          FOR dMkDt:=dtBegr TO dtEndr
            Do Case
            Case dMkDt=BOM(dMkDt)
              // 0 - по ост прошл дня
              // 1 - остаток факт OSN минус Выписанный (для старта)
              // 2 - по ост прошл дня с корр прих kop=211
              // 3 - ??? остаток факт OSN
              nNmOst:=2
              If UPPER("/OsFoN") $ cDosParam
                nNmOst:=kta_DosParam(cDosParam,'/OsFoN=',1,{2,{0,1,2}})
              EndIf

              mkotchd(dMkDt,027, nNmOst, lNo_executed_order)

            OtherWise
              // 0 - по ост прошл дня
              // 2 - по ост прошл дня с корр прих kop=211
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
          // конец просчета
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
      SbArOst2Swe(cPth_Plt_lpos) // предварительно считаный pos.xml & ->pos_swe.dbf
      lod2swe2xml(cPth_Plt_lpos)

      //copy file pos.xml to (cPth_Plt_lpos+'\pos.xml')

      // запуск передачи ФТП
      cCmd:='CUR_PWD=`pwd`; cd /m1/upgrade2/lodis/arnd; ';
      +'./put-ftp-POS.sh;  cd $CUR_PWD'
      cLogSysCmd:=''
      SYSCMD(cCmd,"",@cLogSysCmd)
      outlog(__FILE__,__LINE__,cCmd)

    endif
  ENDIF


  // для получения данных последней оплаты
  USE (gcPath_ew+"deb\deb") ALIAS deb_dz NEW SHARED READONLY
  SET ORDER TO TAG t1

    If file('tmpskdoc.cdx'); erase ('tmpskdoc.cdx');    EndIf
    Crtt_SkDoc('tmpskdoc','f:keg c:n(3) f:kvp c:n(10,3)')
    use tmpskdoc alias skdoc NEW EXCLUSIVE

    // текущая задолженость
    append from (gcPath_ew+"deb\skdoc.dbf") ;
        for !(str(kpl,7) $ '  20034; 539105; 383053;2298568;5513371; 382533') ; // кроме ЗаводОболонь, ЗаводОхтырка

    // добавим кеги/тару
    If file(gcPath_ew+"deb\S361002\"+'tpdoc.dbf')
      append from (gcPath_ew+"deb\S361002\"+'tpdoc.dbf') ;
        for !(str(kpl,7) $ '  20034; 539105; 383053;2298568;5513371; 382533') ; // кроме ЗаводОболонь, ЗаводОхтырка
        all
    EndIf

    INDEX ON STR(KPL)+STR(KGP) TAG "kpl_kgp"
      TOTAL ON STR(KPL)+STR(KGP) ;//пара плательщик, получатель
      for !(str(kpl,7) $ '  20034; 539105; 383053;2298568;5513371; 382533') ; // кроме ЗаводОболонь, ЗаводОхтырка
      FIELD Sdp TO tmpdeb
    close skdoc

    use tmpskdoc alias skdoc NEW EXCLUSIVE
    use tmpdeb alias deb NEW EXCLUSIVE

    // sele skdoc; sum Sdp to nSdp_skdoc
    // sele deb;  sum Sdp to nSdp_deb
    // outlog(__FILE__, __LINE__, nSdp_skdoc - nSdp_deb)

    // долг архивный, может не сопадать с текущим
    mkeepr:=27
    cMKeepr:=padl(ltrim(str(mkeepr,3)),3,'0')
    PathDDr := PathOstDD(cMKeepr,dtEndr)
    If file(PathDDr+'skdoc.dbf')

      If file('tmp_trs2.cdx'); erase ('tmp_trs2.cdx');    EndIf
      Crtt_SkDoc('tmp_trs2','f:keg c:n(3) f:kvp c:n(10,3)')
      use tmp_trs2 alias trs2 NEW EXCLUSIVE

      // добавили товара
      append from (PathDDr+'skdoc.dbf') ;
        for !(str(kpl,7) $ '  20034; 539105; 383053;2298568;5513371; 382533') ; // кроме ЗаводОболонь, ЗаводОхтырка
        all
      // добавим кеги/тару
      If file(PathDDr+'tpdoc.dbf')
        append from (PathDDr+'tpdoc.dbf') ;
        for !(str(kpl,7) $ '  20034; 539105; 383053;2298568;5513371; 382533') ; // кроме ЗаводОболонь, ЗаводОхтырка
        all
      EndIf

      INDEX ON STR(KPL)+STR(KGP) TAG "kpl_kgp"
        TOTAL ON STR(KPL)+STR(KGP) ;//пара плательщик, получатель
        for !(str(kpl,7) $ '  20034; 539105; 383053;2298568;5513371; 382533') ; // кроме ЗаводОболонь, ЗаводОхтырка
        FIELD Sdp TO tmp_pdeb
      close trs2

    Else
      outlog(__FILE__,__LINE__,'!file(skdok) архив',PathDDr)
      // берем текущию задолженость
      copy file tmpskdoc.dbf to tmp_trs2.dbf
      copy file tmpdeb.dbf to tmp_pdeb.dbf
    EndIf

    // архивная задолженость
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

      //перенесем ВОЗВРАТ vo=1 // NEW!!!-> оставим в приходе -и ПЕРЕСОРТИЦУ (кориктировка) vo=6 & kop=111
      sele mkpr
      copy to mkprv01 for vo=1 //NEW!!!-> оставим в приходе.or. (vo=6 .and. kop=111)
      dele for vo=1 //NEW!!! оставим в приходе.or. (vo=6 .and. kop=111)
      pack
      use mkprv01 new Exclusive
      repl all kvp with kvp*(-1)
      close mkprv01

      sele mkdoc
      append from mkprv01

      test_doc_sk(232,dtEndr)
      //добавить докумен для удаления записей
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

      //добавить докумен для удаления записей
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
  // файлы дирекотрия
  /*
  aFlDir:=Directory(cPth_Plt_tmp+"\"+"*.DBF")
  aFlDir:={}
  For i:=1 To len(aFlDir)
    // пропустим
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
        // фактически это ZAP
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

  // юридически лица
  USE (cPth_Plt_tmp+"\"+"PARCOMP.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF
  // торговые точки
  USE (cPth_Plt_tmp+"\"+"OUTLETS.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF
  index on ol_code to t1
  // информация о лицензиях
  USE (cPth_Plt_tmp+"\"+"OLLICENS.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF

  //остаки товара на сладе
  USE (cPth_Plt_tmp+"\"+"INISTOCK.DBF") NEW EXCLUSIVE
  //IF lZap; ZAP ;ENDIF
  //IF iMax(cDosParam)=1 //не готовим остатки для обновлений 1 обновление
    ZAP
  //ENDIF

  //остаки товара на конец дня
  USE (cPth_Plt_tmp+"\"+"ARSTOCK.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF
  //цены продукции
  USE (cPth_Plt_tmp+"\"+"PRLIST.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF

  //фактически продажи - шапки
  USE (cPth_Plt_tmp+"\"+"SALOUTH.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF
  //фактически продажи - детали
  USE (cPth_Plt_tmp+"\"+"SALOUTLD.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF

  // приход - шапка
  USE (cPth_Plt_tmp+"\"+"SALINH.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF
  // приход - детали
  USE (cPth_Plt_tmp+"\"+"SALINLD.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF

  // долги торговой точки
  USE (cPth_Plt_tmp+"\"+"OLDEBTS.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF
  // долги торговой точки детали
  USE (cPth_Plt_tmp+"\"+"OLDEBDET.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF

  // долги торговой точки
  USE (cPth_Plt_tmp+"\"+"ARDEBTS.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF
  // долги торговой точки детали
  USE (cPth_Plt_tmp+"\"+"ARDEBDET.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF


  //привяка форм оплаты к торговой точке
  USE (cPth_Plt_tmp+"\"+"OLPFORM.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF

  //привязка локальной продукции
  USE (cPth_Plt_tmp+"\"+"LOCLPROD.DBF") NEW EXCLUSIVE
  IF lZap; ZAP ;ENDIF

  //ПОС оборудование
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
  //торговые  представители
  USE (cPth_Plt_tmp+"\"+"MERCHAND.DBF") NEW EXCLUSIVE
  ZAP
  // заказы - шапка
  USE (cPth_Plt_tmp+"\"+"OLORDERH.DBF") NEW EXCLUSIVE
  ZAP
  // заказы - детали
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

    //////// ОСТАТКИ ПО ТОВАРМ ////////
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

    //суммирование Осн и СОХ складов Сумы и Конотопа
    USE tmpmktov NEW EXCLUSIVE
    REPL Sk WITH 262 FOR str(Sk) $ OB_LIST_BRAK_S  // брак
    REPL Sk WITH 704 FOR str(Sk) $ OB_LIST_BRAK_K  // брак Конт

    REPL Sk WITH 1 FOR Sk=232 .OR. Sk=237
    REPL Sk WITH 2 FOR Sk=700 .OR. Sk=702
    INDEX ON STR(SK)+STR(MnTovT) TAG "sk"

    TOTAL ON STR(SK)+STR(MnTovT) TO tmpsumtv FIELD OsFo for sk=1 .or. sk=2
    TOTAL ON STR(SK)+STR(MnTovT) TO tmp262 FIELD OsFo for sk=262 // брак Сум
    TOTAL ON STR(SK)+STR(MnTovT) TO tmp704 FIELD OsFo for sk=704 // брак Конт

    CLOSE tmpmktov


    USE ("mktov"+".dbf") ALIAS mktov NEW EXCLUSIVE
    append from tmpsumtv //суммирование Осн и СОХ складов Сумы и Конотопа

    dele for str(sk) $ OB_LIST_BRAK_S
    append from tmp262

    dele for str(sk) $ OB_LIST_BRAK_K
    append from tmp704
    pack

    /*  !!!! остатки по Дате 1. Удаляются все 2. Грузятся из ДБФ
    //добавить остаток виртуальный для удаления периода...
      //добавить остаток для удаления записей
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


    cMkeep:="" //скорировано и обратано
    ////////// ДОКУМЕНТЫ ПРИХОД //////////////////
    IF FILE("mkpr"+".cdx")
      ERASE ("mkpr"+".cdx")
    ENDIF
    USE ("mkpr"+".dbf") ALIAS mkpr NEW EXCLUSIVE
    INDEX ON STR(sk)+STR(ttn) TAG "sk_ttn"
    INDEX ON STR(KPL)+STR(KGP) TAG "kpl_kgp"

    ORDSETFOCUS("kpl_kgp")
      TOTAL ON STR(KPL)+STR(KGP) ;//пара плательщик, получатель
      FOR .NOT. (mkkplkgp->(ORDSETFOCUS("kpl_kgp"),DBSEEK(STR(mkpr->KPL)+STR(mkpr->KGP)))) ;
         TO tmp_kttp

      TOTAL ON STR(KPL) ;
      FOR .NOT. (mkkplkgp->(ORDSETFOCUS("kpl_kgp"),DBSEEK(STR(mkpr->KPL)+STR(mkpr->KGP)))) ;
        TO tmp_kplp

    ORDSETFOCUS("sk_ttn")
    TOTAL ON STR(sk)+STR(ttn) FIELD dcl FOR !(LTRIM(STR(Sk)) $ cCOX_Sl_list) TO sk_ttnp
    //////////////////////////////////////////////


    ////////// ДОКУМЕНТЫ РАСХОД //////////////////
    IF FILE("mkdoc"+".cdx")
      ERASE ("mkdoc"+".cdx")
    ENDIF
    USE ("mkdoc"+".dbf") ALIAS mkdoc NEW EXCLUSIVE
    INDEX ON STR(sk)+STR(ttn) TAG "sk_ttn"
    INDEX ON STR(KPL)+STR(KGP) TAG "kpl_kgp"
    INDEX ON DocGuid TAG "DocGuid"

    ORDSETFOCUS("kpl_kgp")
      TOTAL ON STR(KPL)+STR(KGP) ;//пара плательщик, получатель
    FOR .NOT. (mkkplkgp->(ORDSETFOCUS("kpl_kgp"),DBSEEK(STR(mkdoc->KPL)+STR(mkdoc->KGP)))) ;
        TO tmp_ktte

      TOTAL ON STR(KPL)  ;
    FOR .NOT. (mkkplkgp->(ORDSETFOCUS("kpl_kgp"),DBSEEK(STR(mkdoc->KPL)+STR(mkdoc->KGP)))) ;
      TO tmp_kple
    //////////////

    ////////// ДОКУМЕНТЫ Д-К //////////////////
    SELE skdoc
    INDEX ON STR(KPL)+STR(KGP) TAG "kpl_kgp"

        IF FILE("tmp_kttd"+".cdx")
          ERASE ("tmp_kttd"+".cdx")
        ENDIF
      ORDSETFOCUS("kpl_kgp")
        TOTAL ON STR(KPL)+STR(KGP) ;//пара плательщик, получатель
      FOR .NOT. (mkkplkgp->(ORDSETFOCUS("kpl_kgp"),DBSEEK(STR(skdoc->KPL)+STR(skdoc->KGP)))) ;
        .and. KPL # 20034 ;
         TO tmp_kttd

    SELE trs2
    INDEX ON STR(KPL)+STR(KGP) TAG "kpl_kgp"
        IF FILE("tmp_ktta"+".cdx")
          ERASE ("tmp_ktta"+".cdx")
        ENDIF
      ORDSETFOCUS("kpl_kgp")
        TOTAL ON STR(KPL)+STR(KGP) ;//пара плательщик, получатель
      FOR .NOT. (mkkplkgp->(ORDSETFOCUS("kpl_kgp"),DBSEEK(STR(trs2->KPL)+STR(trs2->KGP)))) ;
        .and. KPL # 20034 ;
         TO tmp_ktta


    //////////////

   ////////// ДОКУМЕНТЫ Д-К Тара //////////////////
   //USE (gcPath_ew+"deb\kegtov") ALIAS kegtov NEW SHARED READONLY
   USE (gcPath_ew+"deb\kegkpl") ALIAS kegkpl NEW SHARED //READONLY
   //INDEX ON STR(kpl)+STR(mntov) TAG "kpl_tov"
   INDEX ON STR(kpl)+STR(KGP)+STR(mntovt) TAG "kpl_tov"

   // свернули остаток
   TOTAL ON STR(kpl)+STR(KGP)+STR(mntovt) FIELD Osf TO tmpKegO1
   CLOSE kegkpl

   // получение точек по Кегам
   USE tmpKegO1 NEW
   INDEX ON STR(kpl)+STR(KGP) TO tmpKegO1

      TOTAL ON STR(KPL)+STR(KGP)  ;
    FOR .NOT. (mkkplkgp->(ORDSETFOCUS("kpl_kgp"),DBSEEK(STR(tmpKegO1->KPL)+STR(tmpKegO1->KGP)))) ;
      .AND. Osf <> 0 ;
      TO tmp_kplt

   // нет шапки в skdoc
      TOTAL ON STR(KPL)+STR(KGP)  ;
    FOR .NOT. (skdoc->(ORDSETFOCUS("kpl_kgp"),DBSEEK(STR(tmpKegO1->KPL)+STR(tmpKegO1->KGP)))) ;
      .AND. Osf <> 0 ;
      TO tmp_skdt


   sele tmpKegO1
   COPY TO tmpKegO2 // FOR Osf <> 0

   USE tmpKegO2 NEW
   COPY TO tmpKegO FOR Osf <> 0 // только положительные
   CLOSE



   //////////////


    SELE mkdoc
    ORDSETFOCUS("sk_ttn")
    TOTAL ON STR(sk)+STR(ttn) FIELD dcl FOR !(LTRIM(STR(Sk)) $ cCOX_Sl_list) TO sk_ttn
    //////////////////////////////

    USE tmp_ktt NEW
      //основная часть из mkkplkgp уже есть
      append from tmp_kttp //пары с прихода
      append from tmp_ktte //пара с расхода
      append from tmp_kttd //пары с Д-Т
      append from tmp_ktta //пары с архива Д-Т
      append from tmp_kplt //плательщик из склада ТАРА
    INDEX ON STR(KPL)+STR(KGP) TAG "kpl_kgp" UNIQ
    INDEX ON STR(KGP) TAG "kgp" UNIQ

  /*
2.1.    Импорт информации о юридических лицах (файл ParComp)
  Информацию нужно выгружать из УСД из справочника КОНТРАГЕНТЫ или аналогичного.
  Для обмена данными важным есть выгрузка уникального кода КОНТРАГЕНТА
  (поле Pcomp_Code) и его название (PC_Name). На эти данные будут ссылаться
  Торговые Точки.
  */

  SELE tmp_ktt
  ORDSETFOCUS("kpl_kgp")

  DBGOTOP()
  DO WHILE !EOF()
    kplr:=tmp_ktt->kpl
    kln->(netseek('t1','kplr'))
    SELE  PARCOMP
    alias_1:=ALIAS()
    DBAPPEND() //проверка на дубляж STR(tmp_ktt->kpl,25)
    /*
    Ключ    Поле    Тип     Длина   Описание        Поле обязательное
    PK      PComp_Code      Character       25      Внешний код
    юридического лица.
    Заполнять уникальным кодом Контрагента из УСД.  Да
    */
  _FIELD->PComp_Code:=STR(tmp_ktt->kpl,25)
  /*
          PC_Name Character       50      Название юридического лица
  По умолчанию '-'.       Да
  */
  _FIELD->PC_Name := kln->nkl //
  /*
          DTLM    Character       14      Дата и время модификации записи..
  Формат: "YYYYMMDD HH:MM"        Да

  */
  _FIELD->DTLM := DTLM()
  /*
          Status  Numeric 11      Статус (2 - 'активный', 9 - 'неактивный')
  По умолчанию - 2        Да
  */
  _FIELD->Status := 2

   sele tmp_ktt
   DO WHILE kplr = tmp_ktt->kpl
     DBSKIP()
   ENDDO
 ENDDO
 sele (alias_1); copy to (""+alias_1)

  /*
          PC_Addr Character       80      Адрес юридического лица
  По умолчанию '-'.       Нет
          PC_Zkpo Character       20      код ЗКПО юридического лица
  По умолчанию '-'.       Нет
          PC_Tax_Num      Character       20      Регистрационный
  Номер
  По умолчанию '-'.       Нет
          PC_Vat_Num      Character       20      Номер плательщика
  НДС
  По умолчанию '-'.       Нет
          PC_B_Name       Character       80      Название банка
  По умолчанию '-'.       Нет
          PC_B_MFO        Character       20      код МФО банка
  По умолчанию '-'.       Нет
          PC_B_Acc        Character       20      Номер банк_вського рахунку
  По умолчанию '-'.       Нет
          PC_Direct       Character       50      Директор юридического лица
  По умолчанию '-'.       Нет
          PC_Phone        Character       20      Конт. телефон юридического лица.
  По умолчанию '-'.       Нет
          PC_Fax  Character       20      Факс юридического лица
  По умолчанию '-'.       Нет
          PC_EMail        Character       50      Електронна адреса юридического лица
  По умолчанию '-'.       Нет
          PC_Account      Character       50      Бухгалтер юридического лица
  По умолчанию '-'.       Нет
          PC_Acc_Ph       Character       20      Телефон бухгалтера юридического лица
  По умолчанию '-'.       Нет
          PC_MManag       Character       50      Товаровед юридического лица.
  По умолчанию '-'.       Нет
          PC_MM_Ph        Character       20      Телефон товароведа
  По умолчанию '-'.       Нет
          PC_PManag       Character       50      Менеджер по закупкам юридического лица
  По умолчанию '-'.       Нет
  */


  /*
2.2.    Импорт информации о Торговых Точках (файл Outlets)
  Импорт информации о Торговой Точке-Точке доставки.
  Информацию нужно выгружать из УСД из соответствующего справочника, в котором хранятся данные о Точках Доставки\Торговых Точках.
  Для начала нужно осуществить сопоставление кодов Торговых Представителей в SalesWorks и УСД.
  Описано в п.2.5.1
  Ключ    Поле    Тип     Длина   Описание        Поле обязательное
  */
 SELE tmp_ktt
   ORDSETFOCUS("kpl_kgp")

 Outlets(,@aMessErr)

  //close tmp_ktt


  /*
2.3.    Импорт информации о лицензиях Таблица OLLICENS
  Необходимо заполнять таблицу OLLICENS следующими данными
  Ключ    Поле    Тип     Довжина         Опис    Поле обов'язкове
  */
  SELE tmp_ktt
  DBGOTOP()
  IF !(UPPER("/init") $ UPPER(cDosParam))
    //не готовим
    DBGOBOTTOM()
    DBSKIP()
    alias_1:="OlLicens"
  ENDIF
  DO WHILE !EOF()

    kplr:= tmp_ktt->kpl
    kgpr:= tmp_ktt->kgp
    dolr:= klnlic->(DtLic(kplr, kgpr, 2)) // 2 - лицензия алкоголь
    If empty(dolr) .or. date() - dolr > 180
      klnlic->(DBGoBottom())
      klnlic->(DBSkip())

      //ни чего не показываем
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
   DBAPPEND() //проверка на дубляж STR(tmp_ktt->kgp,7)+"-"+STR(tmp_ktt->kpl,7)
   /*
  PK      OL_CODE         Character       25      Код ТТ  Так
   */
   _FIELD->OL_Code:=STR(tmp_ktt->kgp,7)+"-"+STR(tmp_ktt->kpl,7)
   /*
  PK      LT_ID   Numeric         5       _дентиф_катор типу л_ценз_ї  Внашем случае выгружаем значение = 1 (Лицензия на САН)  Так
   */
  _FIELD->LT_ID := 1
   /*
          NUMBER  Character       20      Номер л_ценз_ї  Так
   */
   _FIELD->NUMBER := iif(empty(dolr) .or. (date() - dolr) > 180,;
   "empty(dolr).or.date()-dolr>180)",;
   allt(serlicr)+ltrim(str(numlicr));
 )

   /*
          STARTDATE       Date    8       Початок д_ї     Так
   */
   _FIELD->STARTDATE :=dnlr
   /*
          ENDDATE         Date    8       К_нець д_ї      Так
   */
   _FIELD->ENDDATE := dolr
   /*
          DTLM    Character       14      Дата _ час модиф_кац_ї запису   Так
    */
  _FIELD->DTLM := DTLM()
    /*
          Status  Numeric         11      Статус (2 - "активний?, 9 - "неактивний?)       Так
    */
    _FIELD->Status := 2

    SELE tmp_ktt
    DBSKIP()
  ENDDO
 sele (alias_1); copy to (""+alias_1)

  /*
2.4.    Импорт информации об остатках товара на складе (файл IniStock)
  Импорт информации о _ТЕКУЩИХ_ОСТАТКАХ_ продукции на складах дистрибьютора,
  нужно выгружать остатки по Основному складу так и по
  складам Филиалов(если есть такие).
    Ключ    Поле    Тип     Длина   Описание        Поле обязательное
  */

  SELECT mktov
  ORDSETFOCUS("sk")
  DBGOTOP()
  IF !(UPPER("/init") $ UPPER(cDosParam) .or. dtEndr=date()+1)
    //не готовим
    DBGOBOTTOM()
    DBSKIP()
    alias_1:="IniStock"
  ENDIF
  DO WHILE !EOF()
    //mntovt>=10000 .and. mntovt<=10^6  - стеклотара
    IF  !(MnTovT/10000=1) ; // 000 0000 0 000000
      .OR. INT(MnTovT/10000) = 250.0 ;
      .OR. !(STR(Sk,3) $ cListSaleSk)
      //DBSKIP();      LOOP
    ENDIF
    IF INT(mntovt/10000) = 250.0
      DBSKIP();      LOOP
    ENDIF
    If getfield('t1','mktov->mntovt','ctov','merch') = 0 // для КПК
      // DBSKIP();      LOOP
    EndIf


   SELE  IniStock
   alias_1:=ALIAS()
   DBAPPEND() //проверка на дубляж   Sk + MnTovT
     /*
      PK      Wareh_Code      Character       20      Внешний код склада  Код склада из УСД       Да
    */
      _FIELD->Wareh_Code := ALLT(STR(mktov->Sk))
     /*
      PK      ProdCode  Character       20      Оставляем пустым (null) Да
    */
    _FIELD->ProdCode:="0"
     /*
      PK      LocalCode       Character       20      Локальный код продукции Да
    */
    _FIELD->LocalCode:=allt(STR(mktov->MnTovT))
     /*
      PK      LOT_ID  Character       20      Идентификатор партии товара   Не заполнять если не используется партийный учет остатков       Да
    */
    _FIELD->LOT_ID:="0"
     /*
              STOCK   Numeric 14,3    Остаток товара, шт.
              Обязательно выгружать "нулевой остаток"     Да
    */

    nVolume:=KegaVol('mktov->mntovt')
    /*
           !!KegaVolOrd
    nVolume:=1 // <- кегу не переводим т.е. показываем в Литрах
    */

    _FIELD->STOCK:=mktov->OsFo / nVolume
     /*
              DTLM    Character       14      Дата и время модификации записи.   Формат: "YYYYMMDD HH:MM"        Да
    */
  _FIELD->DTLM := DTLM()
    /*
            Status  Numeric 11      Статус товара (2 - 'активный', 9 - 'неактивный' Да
    */
   _FIELD->Status := 2

    SELECT mktov
    DBSKIP()
  ENDDO
 sele (alias_1); copy to (""+alias_1)

  /*
2.5.    Импорт информации о архивных остатках (файл ArStock)
  Необходимо выгружать таким образом чтобы остатки выгружались на КОНЕЦ дня
  (то есть с учетом всех движений по товару за открытый период отчетности в УС)
  Обязательно выгружать остатки по Основному складу и по
  складам Филиалов (если есть такие).
  Ключ    Поле    Тип     Длина   Описание        Поле обязательное
  */
  SELECT mktov
  ORDSETFOCUS("sk")

  iMax:=iMax(cDosParam)

  FOR i:=1 TO iMax // требование выгружать остатки на перед...
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
        PK      Wareh_Code      Character       20      Внешний код склада  Код склада из УСД       Да
      */
        _FIELD->Wareh_Code :=allt(STR(mktov->Sk))
       /*
        PK      LocalCode       Character       20      Локальный код продукции Да
      */
      _FIELD->LocalCode:=allt(STR(mktov->MnTovT))
       /*
        PK      LOT_ID  Character       20      Идентификатор партии товара   Не заполнять если не используется партийный учет остатков       Да
      */
      _FIELD->LOT_ID:="0"
       /*
                STOCK   Numeric 14,3    Остаток товара, шт. Обязательно выгружать "нулевой остаток"     Да
      */
     nVolume:=KegaVol('mktov->mntovt')

      _FIELD->STOCK:=mktov->OsFo / nVolume
      /*
      PK      DATE    Date    8       Дата среза остатков.   Формат:   "DD.MM.YYYY"    Да
      */
      _FIELD->DATE:=mktov->DT+(i-1)
       /*
                DTLM    Character       14      Дата и время модификации записи.   Формат: "YYYYMMDD HH:MM"        Да
      */
    _FIELD->DTLM := DTLM()


      SELECT mktov
      DBSKIP()
    ENDDO
  NEXT
 sele (alias_1); copy to (""+alias_1)

  /*
2.6.    Импорт информации о ценах продукции (файл PrList)
  Перед выгрузкой информации в файл, нужно сначала сопоставить коды Форм Оплаты\Категорий Цен в УСД, описано в п.2.5.4
  Значение кодов Форм Оплаты, можно получить с DBF-файла- Payforms.dbf.
  Ключ    Поле    Тип     Длина   Описание        Поле обязательное
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
      DBAPPEND() //проверка на дубляж  allt(STR(mktov->MnTovT))
      /*
      FK      PayForm_ID      Numeric 11      Идентификатор формы оплаты.  Код Категории Цены      Да
      */
      _FIELD->PayForm_ID := aPayForm[i] //5200000 //факт:  5200001 - отсрочка
      /*
      FK      Code  Сharacter       20      Не заполняется  Да
      */
      _FIELD->Code:="" //STR(_FIELD->PayForm_ID)
      /*
      PK, FK  LocalCode   Character       20      Код локальной продукции Да
      */
      _FIELD->LocalCode:=allt(STR(mktov->MnTovT))
      /*
            Price   Numeric 15,8    Цена без НДС\с НДС      Да
      */
       nVolume:=KegaVol('mktov->mntovt')

      NDSr:=round((100+gnNDS)/100,2) //  НДС  1.20  20%
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
                DTLM    Character       14      Дата и время модификации записи.   Формат: "YYYYMMDD HH:MM"        Да
      */
    _FIELD->DTLM := DTLM()
      /*
              Status  Numeric 11      Статус товара (2 - 'активный', 9 - 'неактивный' Да
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
2.7.    Импорт информации о фактических продажах - Шапки (файл SalOutH)
  Фактические продажи- это документы о фактически отгруженных (со склада дистрибьютора) накладных в\от ТТ.
  Информацию нужно выгружать в файлы SalOutH.dbf (шапка) и SalOutLD.dbf (детали)
  В файлы нужно выгружать информацию о :
  -       продажи в ТТ,
  -       возвраты от ТТ,
  -       перемещение между складами дистрибьютора, перемещение на филиалы,(указывать склад из которого перемещается товар)
  -       Корректировка (если есть такие документы)
  -       Списание (если есть такие документы)
  Ключ    Поле    Тип     Длина   Описание        Поле обязательное
  */
  aKta:={}
  AADD(aKta,1000)

  // проверка на переоцеку, т.е. для "заказа" с vo=1, должен быть
  // vo=9 тогда это "переоценка"
  /*
  брак169 Конотоп 705 -> 700 Лод?с Конотоп
  брак169 Суми 263 ->232 Лод?с Суми
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
        If found() // переоцека
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
      nDoc_type := 2 //  расход покупателям,
    CASE vor= 4
      nDoc_type := 4
    CASE vor= 1
      nDoc_type := 3 //  2 - возврат поставщику,
    //CASE vor= 6
    //  nDoc_type := 5 //  (5 - коррекция
    OTHERWISE
      nDoc_type := 99 //  6 - списание товара
        AADD(aMessErr,"Не верный код Код операции'-' для VO="+STR(mkdoc->vo)+;
        " KOP="+STR(mkdoc->kop)+;
        "для ТТН(mkdoc) "+DTOS(mkdoc->DTtn) +" "+STR(mkdoc->Sk)+' '+STR(mkdoc->Ttn)+;
        CHR(10)+CHR(13);
        +"Параметры вызова програмы: ";
        + cDosParam ;
        + CHR(10)+CHR(13))

    ENDCASE

    /*
  PK, FK  Merch_ID        Numeric 11      Идентификатор торгового представителя
    код ТП, можно получить с Merchand.dbf     для всех типов движения кроме типа 2 и 3 заполнять значением 0           Да
    */
    nIdLod:=mkdoc->(nIdLod('mkdoc->kta', @aMessErr, @aKta))

    SELE SalOutH
   alias_1:=ALIAS()
    DBAPPEND()
    _FIELD->Merch_ID:=IIF(mkdoc->kta=0 .OR. .NOT.(LTRIM(STR(nDoc_type))$"2 3") ,0,nIdLod) //5200000+mkdoc->kta)
    /*
  PK      Date    Date    8       Дата отгрузки товара,   Дата накладной  Да
    */
    _FIELD->Date := dtEndr //11-06-17 12:30pm mkdoc->DTtn

    /*
  PK, FK  Ol_Code Character       25      Код Торговой точки в УСД
          для всех типов движения кроме типа 2 и 3 заполнять значением 0  Да
    */
   _FIELD->OL_Code:=STR(mkdoc->Kgp)+"-"+STR(mkdoc->Kpl)

    /*
  PK, FK  Order_No        Numeric 20      Код документа Заказ, сформированного в SalesWorks.
      0 - если Заказ сформирован не через SalesWorks  Да
    */
    cDocGuId:="0"
    IF LEFT(LTRIM(mkdoc->DocGuId),2)="52"
      cDocGuId:=LTRIM(mkdoc->DocGuId)
    ELSE
      //cDocGuId:=IIF(empty(mkdoc->DocGuId),GUID_KPK("F",PADL(LTRIM(STR(mkdoc->Sk)),3,"0")+PADL(LTRIM(STR(mkdoc->TTN)),7,"0"))),mkdoc->DocGuId)
    ENDIF
    _FIELD->Order_No := cDocGuId

    /*
  PK      Invoice_No      Character       58      Номер документа в УСД.
     Номер должен быть уникальным, при необходимости для обеспечения уникальности, нужно к коду документу добавить префикс с
     указанием года и месяца: YYYYMM Да
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
          Status  Numeric 11      Статус документа (0 - 'неопределенный', 1 - 'отгружено', 2 - 'получено', 3 - 'частично оплачено', 4 - 'полностью оплачено', 9 - 'удалено')      Да
    */
  _FIELD->Status := IIF(mkdoc->TTN<0,9,2)

    /*
          DateTo  Date    8       Дата до которой необходимо оплатить накладную согласно отсрочке оплаты ТТ       Да
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
      //param1 2 - есть акцизный товар, 1 - нет акцизного товар
      param1  - форма оплаты (нал или без.нал)
    */
    (alias_1)->param1 := IIF(mkdoc->KOP=169,2,1)

    sele (alias_1)
    /*
          VatCalcMod      Numeric 11
          Цена товара с НДС - для значения SALOUTH. VatCalcMod = 1.
          Цена товара без НДС - для значения SALOUTH. VatCalcMod = 0      Да
    */

    IF OB_OUT_VATCALCMOD = 0
      _FIELD->VatCalcMod :=  0 //IIF(mkdoc->Kop=170,1,0)
    ELSE
      _FIELD->VatCalcMod :=  1 //IIF(mkdoc->Kop=170,1,0)
    ENDIF

    /*
          DTLM    Character       14      Дата и время модификации записи.   Формат: "YYYYMMDD HH:MM"        Да
    */

    _FIELD->DTLM := DTLM()
    /*
    FK      Doc_Type        Numeric 2       тип Документа
    2       Продажа (+)     saloutH
    3       Возврат из розницы (-)  salOutH
    */

    _FIELD->Doc_Type := nDoc_type

    /*
  PK      Wareh_Code      Character       20      Внешний код склада  Код склада из УСД (соответствует кодам складов в СВЕ) с которого была произведена продажа       Да
    */
    _FIELD->Wareh_Code := Wareh_Code(mkdoc->Sk)



    SELECT mkdoc
    DO WHILE  nSk = _FIELD->Sk .AND.     nTtn = _FIELD->Ttn
      DBSKIP()
    ENDDO
  ENDDO
 sele (alias_1); copy to (""+alias_1)
  /*
          Param1  Numeric 11      Заполнять - 0   Да
          PrintCheck      Logical 1       Заполнять - 0   Да
          PrintOrder      Logical 1       Заполнять - 0   Да
          PrnChkOnly      Logical 1       Заполнять - 0   Да
  PK      Wareh_Code      Character       20      Внешний код склада
  Код склада из УСД (соответствует кодам складов в СВЕ) с которого
  была произведена продажа       Да
  */


  /*
2.8.    Импорт информации о фактических продажах - Детали (файл SalOutlD)
  Информация о фактических продажах (фактура).
  Ключ    Поле    Тип     Длина   Описание        Поле обязательное
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
    If getfield('t1','mkdoc->mntovt','ctov','merch') = 0 // для КПК
      // DBSKIP();      LOOP
    EndIf

    IF ASCAN(aKta,mkdoc->kta) # 0
      DBSKIP();      LOOP
    ENDIF


    SELE SalOutlD
   alias_1:=ALIAS()
    DBAPPEND()
    /*
          VAT     Numeric 5,2     Ставка НДС в %  Да
    */
    _FIELD->VAT := IIF(mkdoc->(INT(MnTovT/10000)=0),0,20)// тара 0%,т.к. возвратная.
    /*
    PK, FK  LocalCode       Character       20      Код локальной продукции.
    */
    _FIELD->LocalCode:=allt(STR(mkdoc->MnTovT))
    /*
    PK      Price   Numeric 15,8
    Цена товара с НДС - для значения SALOUTH. VatCalcMod = 1.          Да
    Цена товара без НДС - для значения SALOUTH. VatCalcMod = 0.           Да
    */
    nVolume:=KegaVol('mkdoc->mntovt')

    nPriceSale:=;
       IIF(mkdoc->KOP=177, 0.01, mkdoc->zen) //zenn - расчетаная, zen- c ТТН

    nKoef:=1.0
    If mkdoc->KOP=169
      // код операции 169 нал.,
      kg_r:=int(mkdoc->MnTovT/10000)
      //KolAkcr:=getfield('t1','mntovr','ctov','kolakc')
      if !empty(getfield('t1','kg_r','cgrp','nal'))
        // акциз  то цену + 5% (*1.05)
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
          Qty     Numeric 14,3    Количество отгруженного товара.          Да
    */
    _FIELD->Qty := mkdoc->kvp / nVolume

    /*
    PK, FK  Invoice_No      Character       58      Номер накладной (должен быть уникальным).
    Номера документов для разных типов движения (накладных) не должны пересекаться, чтобы исключить их задвоение.
    Рекомендуется включить в номер накладной уникальный индекс для каждого типа накладных.
    В случае, если в учетной системе происходит обнуление нумерации накладных (например в начале года), добавлять к номеру накладной уникальный идентификатор (напр. "2012_", т.е. год+символ "_"
    Значение не должно равняться "0".       Да
    */
    _FIELD->Invoice_No := DTOS(mkdoc->DTtn)+"-"+;
                          PADL(LTRIM(Wareh_Code(mkdoc->Sk,.T.)),4,"0")+"-"+;
                          PADL(LTRIM(STR(mkdoc->TTN)),6,"0")
    //_FIELD->Invoice_No := PADL(LTRIM(STR(mkdoc->Sk)),3,"0")+PADL(LTRIM(STR(mkdoc->TTN)),6,"0")
    //STR(mkdoc->Sk)+STR(mkdoc->Ttn)

    /*
    PK      Lot_id  Character       20      Номер партии.
    Значение "0", если не ведется.  Да
    */
    _FIELD->Lot_id := "0"
    /*
          DTLM    Character       14      Дата и время модификации записи. Формат: "YYYYMMDD HH:MM"       Да
    */
  _FIELD->DTLM := DTLM()

    /*
          Status  Numeric 11      Статус документа (0 - 'неопределенный',

          1 - 'отгружено', 2 - 'получено', 3 - 'частично оплачено',
          4 - 'полностью оплачено', 9 - 'удалено')      Да
    */
  _FIELD->Status := IIF(mkdoc->TTN<0,9,2)

    /*
          Order_No        Numeric 20      Идентификатор заказа.
     Заполнять значением идентификатора заказа, в случае если заказ поступил из SalesWorks (Order_No).       Да
    cDocGuId:=IIF(empty(mkdoc->DocGuId),GUID_KPK("F",allt(LTRIM(STR(mkdoc->SK))+PADL(LTRIM(STR(mkdoc->TTN)),7,"0"))),mkdoc->DocGuId)
    _FIELD->Order_No := VAL(RIGHT(cDocGuId,20))
    */

    /*
          AccPrice        Numeric 15,8    Учетная цена товара
            Заполнять значением "0" Да
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
2.9.    Импорт информации о приходах - Шапка (файл SalInH)
  Шапки приходов.
  В файлы нужно выгружать информацию о:
  -       Приходы от Производителя на Основной склад (ОС),
  -       Возвраты Производителя с Основного склада (ОС),
  -       Перемещения (указывать склад на какой перемещается товар)
  Ключ    Поле    Тип     Длина   Описание        Поле обязательное
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
    PK      Date    Date    8       Дата прихода товара на Склад    Да
    */
    _FIELD->Date := mkpr->DTtn
    /*
    PK      Invoice_No      Character       58      Номер накладной         Да
    */
    _FIELD->Invoice_No := DTOS(mkpr->DTtn)+"-"+;
                          PADL(LTRIM(Wareh_Code(mkpr->Sk,.T.)),4,"0")+"-"+;
                          PADL(LTRIM(STR(mkpr->TTN)),6,"0")
    //_FIELD->Invoice_No :=  PADL(LTRIM(STR(mkpr->Sk)),3,"0")+PADL(LTRIM(STR(mkpr->TTN)),6,"0")
    //STR(mkpr->Sk)+STR(mkpr->Ttn)
    /*
            Status  Numeric 11      Статус (2 - 'активный', 9 - 'неактивный')       Да
    */
    _FIELD->Status := IIF(mkpr->TTN<0,9,2)
    /*
    VatCalcMod      Numeric 11
    Цена товара с НДС - для значения SALINH. VatCalcMod = 1.
    Цена товара без НДС - для значения SALINH. VatCalcMod = 0      Да
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
            DTLM    Character       14      Дата и время модификации записи.  Формат: "YYYYMMDD HH:MM"        Да
    */
    _FIELD->DTLM := DTLM()
    /*
    FK      Doc_Type        Numeric 2       тип документа
    1       Приход (+)      salInH
    2
    3
    5 !//4       Списание (+)    salinH
    5       Корректировка (+/-)     salInH
    Знаки "+" и "-" ставятся не в этом поле а в таблице деталей в поле QTY  Да
    6       Перемещение на филиал (+)       salInH
    7       Перемещение с филиала (-)       salInH
    8       Снятие с СОХ (-)        salInH
    9       Возврат производителю (-)       salInH
    Знаки "+" и "-" ставятся не в этом поле а в таблице деталей в поле QTY  Да
    */
    vor := mkpr->vo
    DO CASE
    CASE vor= 5
      nDoc_type := 5//4 //  (списание
    CASE vor=6 .and. mkpr->kop=111
      nDoc_type := 5 //  (5 - коррекция +/-
    CASE vor= 1 ;  // возврат производителю
     .or. (vor=9 .and. (mkpr->sk=237 .or. mkpr->sk=702) .and. mkpr->kvp<0) // списание с СОХ
      nDoc_type := 9 // - возврат производителю и списание с СОХ(-)
      mkpr->ttnpst:=iif(empty(mkpr->ttnpst),RIGHT(_FIELD->Invoice_No,6),mkpr->ttnpst)
    CASE vor= 9
      nDoc_type := 1 // - приход от поставщика,
      mkpr->ttnpst:=iif(empty(mkpr->ttnpst),RIGHT(_FIELD->Invoice_No,6),mkpr->ttnpst)
      //mkpr->ttnpst:= // должны вводить руками_FIELD->Invoice_No
    CASE vor= 6 .and. mkpr->kvp>0 //6 Перемещение на филиал (+)       salInH
      nDoc_type := 6
    CASE vor= 6 .and. mkpr->kvp<0 //7 Перемещение с филиала (-)       salInH
      nDoc_type := 7
    OTHERWISE
      nDoc_type := 99 //  ??
      AADD(aMessErr,"Не верный код Код операции'-' для VO="+STR(mkpr->vo)+;
      " KOP="+STR(mkpr->kop)+;
      "для ПА(mkpr) "+DTOS(mkpr->DTtn) +STR(mkpr->Sk)+STR(mkpr->Ttn)+;
      CHR(10)+CHR(13))

    ENDCASE

    _FIELD->Doc_Type := nDoc_type
    /*
    PK      Wareh_Code      Character       20      Внешний код склада
      Код склада из УСД (соответствует коду в СВЕ) по которому били движения товара   Да
    */
    cWareh_Code:=Wareh_Code(mkpr->Sk)
    // товар Брак набраный в основных склах перетянуть в скл. Браки
    If str(mkpr->Sk,3) $ '232;700' .and. mkpr->Kop = 108 .and. !Empty(mkpr->DocGuId)
      // певести в склады брака
      If mkpr->Sk = 232
        cWareh_Code:=Wareh_Code(262)
      Else
        cWareh_Code:=Wareh_Code(704)
      EndIf
    EndIf
    _FIELD->Wareh_Code := cWareh_Code

    /*
            CUSTDOC_NO      Character       58      Номер документа продажи ГО      Нет
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
      +" Оцените К-ВО коррекций по kop=211 ";
      + STR(nQKop211p,10,3)+' и ';
      + STR(nQKop211n,10,3);
      +CHR(10)+CHR(13))

      AADD(aMessErr,SPACE(8);
      +" Оцените СУММЫ коррекций по kop=211 ";
      + STR(nSumKop211p,10,2)+' и ';
      + STR(nSumKop211n,10,2);
      +CHR(10)+CHR(13))

      AADD(aMessErr,SPACE(8);
      +"Возможно нужен ПЕРЕСЧЕТ данных и повторная ВЫГРУЗКА";
      +CHR(10)+CHR(13))
  EndIf


 sele (alias_1); copy to (""+alias_1)

  /*
2.10.   Импорт информации о приходах товара - Детали (файл SalInLD)
  Детали приходов
  Ключ    Поле    Тип     Длина   Описание        Поле обязательное
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
    If getfield('t1','mkpr->mntovt','ctov','merch') = 0 // для КПК
      // DBSKIP();      LOOP
    EndIf
    SELE SalInLD
   alias_1:=ALIAS()
    DBAPPEND()
    /*
           VAT     Numeric 5,2     Ставка НДС в %  Да
    */
    _FIELD->VAT := IIF(mkpr->(INT(MnTovT/10000)=0),0,20)// тара 0%,т.к. возвратная.

    /*
    PK, FK  LocalCode       Character       20      Код локальной продукции Да
    */
    _FIELD->LocalCode:=allt(STR(mkpr->MnTovT))
    /*
    PK      Price   Numeric 15,8
    Цена товара с НДС - для значения SALINH. VatCalcMod = 1.
    Цена товара без НДС - для значения SALINH. VatCalcMod = 0.      Да
    */
     nVolume:=KegaVol('mkpr->mntovt')

    nPriceSale:= mkpr->zen //zenn - расчетаная, zen- c ТТН

    DO CASE
    CASE OB_IN_VATCALCMOD = 0
      _FIELD->Price := nPriceSale  * nVolume
    CASE OB_IN_VATCALCMOD = 1
      _FIELD->Price := nPriceSale * 1.2  * nVolume
    CASE OB_IN_VATCALCMOD = 2
      _FIELD->Price := nPriceSale * nVolume
    ENDCASE

    /*
            Qty     Numeric 14,3    Количество полученного товара.
            Со знаком "+". Но 10   Возврат производителю (-)       salinH
            Да
    */
    _FIELD->Qty := mkpr->kvp / nVolume

    /*
    PK, FK  Invoice_No      Character       58
    Номер приходной накладной в учетной системе Дистрибьютора.
    Заполнять соответствующим значением из SALINH.  Да
    */
    _FIELD->Invoice_No := DTOS(mkpr->DTtn)+"-"+;
                          PADL(LTRIM(Wareh_Code(mkpr->Sk,.T.)),4,"0")+"-"+;
                          PADL(LTRIM(STR(mkpr->TTN)),6,"0")
    //_FIELD->Invoice_No := PADL(LTRIM(STR(mkpr->Sk)),3,"0")+PADL(LTRIM(STR(mkpr->TTN)),6,"0")
    //STR(mkpr->Sk)+STR(mkpr->Ttn)

    /*
    PK      Lot_id  Character       20      Номер партии    Да
    */
    _FIELD->LOT_ID:="0"
    /*
            DTLM    Character       14      Дата и время модификации записи (выгрузки информации). Формат: "YYYYMMDD HH:MM" Да
    */
    _FIELD->DTLM := DTLM()
    /*
     Status  Numeric 11      Статус (2 - 'активный', 9 - 'неактивный')
     Заполнять значением "2",        Да
    */
    _FIELD->Status := IIF(mkpr->TTN<0,9,2)

    SELECT mkpr
    //DO WHILE  nSk = _FIELD->Sk .AND.     nTtn = _FIELD->Ttn
      DBSKIP()
    //ENDDO
  ENDDO
 sele (alias_1); copy to (""+alias_1)

 //зачистка доков
 //   SELE SalInH
 //   DELE FOR SalInLD->(__dbLocate({|| SalInH->Invoice_No = _FIELD->Invoice_No }), .not. found())


  /*
  2.11.   Информация о значении поля Doc_Type для разных типов документов, также указано для которых DBF- файлов.
  Значения поля Doc_Type для разных типов документов, касается файлов SalOutH та SalInH
  Doc_type        Название ТД     Таблица (DBF)   Описание
  1       Приход (+)      salInH  склад куда идет приход
  2       Продажа (+)     saloutH склад откуда идет продажа
  3       Возврат из розницы (-)  saloutH склад куда идет возврат
  4       Списание (+)    saloutH склад откуда идет списание
  5       Корректировка (+/-)     saloutH склад где происх корректир.
  6       Перемещение на филиал (+)       salInH  склад куда идет перемещение
  7       Перемещение с филиала (-)       salInH  склад откуда идет перемещение
  8       Снятие с СОХ (-)        salInH  склад откуда идет снятие
  9       Возврат производителю (-)       salInH  склад откуда идет возврат
  */

  /*
2.12.   Импорт информации о долгах Торговых Точек (файл OlDebts)
  Общая информация о долгах торговых точек, нужно выгружать долги ТТ только по продукции Оболонь.
  В полях Деталей можно указывать дополнительную информацию.
  Ключ    Поле    Тип     Длина   Описание        Поле обязательное
  */

  // текущие долги
  SELE OlDebts
  alias_1:=ALIAS()

  SELE deb
  #ifdef DEB_KEGO
    append from tmp_skdt // добавили не достающие ТТ
  #endif
  SET RELA TO STR(Kpl,7) INTO deb_dz

  SELE deb
  Debts('deb','OlDebts')

  sele (alias_1); copy to (""+alias_1)
  repl all _FIELD->Status with 2
  ///////////////// ////////////////////

  ////// архивные долги
  sele ArDebts
  alias_1:=ALIAS()

  SELE pdeb
  // append from tmp_???? // добавить точки из долгов тары
  SET RELA TO STR(Kpl,7) INTO deb_dz
  SELE pdeb
  Debts('pdeb','ArDebts')

  sele (alias_1); copy to (""+alias_1)
  repl all DebtDate WITH dtEndr //dDt //date()
  ////////////////////////////////////////////

  IF !(UPPER("/init") $ UPPER(cDosParam))
    //не готовим
    alias_1:="OlDebts"
    sele (alias_1)
    ZAP
  ENDIF


  // outlog(__FILE__,__LINE__, dDt,  dtEndr,  dtBegr)

  /*
2.13.   Импорт информации о деталях долгов Торговой Точки (файл OlDebDet)
  Детальная информация о долгах торговых точек.
  Нужно выгружать информацию о накладных по которым есть долг,
  по товарам Лукас.
  Ключ    Поле    Тип     Длина   Описание        Поле обязательное
  */

  alias_1:='OlDebDet'

  sele skdoc // все точки добалены в tmp_ktt
  SET RELA TO STR(KPL,7) INTO tmp_ktt, STR(Kpl,7) INTO deb

  sele skdoc
  set filt to keg < 30
  DebDet('skdoc','OlDebDet',date(),aMessErr, aKta)

  ///////  КЕГИ //////

  #ifdef DEB_KEGO
    USE tmpKegO ALIAS KegO NEW
    ali_etm:=ALIAS()
    DebDetKeg('KegO','OlDebDet',date(),aMessErr, aKta)
  #else
    sele skdoc
    set filt to keg >= 30
    DebDetKeg30('skdoc','OlDebDet',date(),aMessErr, aKta)
  #endif
    // оставим для истории
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
    //не готовим
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
2.14    Информация о привязке форм оплаты к ТТ (olpform)
  */

  SELE tmp_ktt
  DBGOTOP()
  DO WHILE !EOF()

   SELE  olpform
   alias_1:=ALIAS()
   DBAPPEND() //проверка на дубляж  STR(tmp_ktt->kgp,7)+"-"+STR(tmp_ktt->kpl,7)
   /*
  PK      OL_CODE         Character       25      Код ТТ  Так
   */
   _FIELD->OL_Code:=STR(tmp_ktt->kgp,7)+"-"+STR(tmp_ktt->kpl,7)

    /*
    FK      PayForm_ID      Numeric 11      Идентификатор формы оплаты.  Код Категории Цены      Да
    */
    _FIELD->PayForm_ID:=5200000 //факт:  5200001 - отсрочка

    If !empty(FieldPos('PayF_CODE'))
      _FIELD->PayF_CODE:='1' // c20
    EndIf

   /*
          DTLM    Character       14      Дата _ час модиф_кац_ї запису   Так
    */
  _FIELD->DTLM := DTLM()
    /*
          Status  Numeric         11      Статус (2 - "активний?, 9 - "неактивний?)       Так
    */
    _FIELD->Status := 2

    SELE tmp_ktt
    DBSKIP()
  ENDDO
 sele (alias_1); copy to (""+alias_1)


 close tmp_ktt


   //return (NIL)
  /*
2.15.   Таблица  LOCLPROD (структура таблицы остается неизменной, ничего не менять)
  Импорт информации о локальной продукции и ее привязках к глобальной кодировке произ
  водителя.Для учета продукции в учетной системе Дистрибьютора должен существовать
  справочник НОМЕНКЛАТУРА.
  В случае когда в справочнике НОМЕНКЛАТУРА Учетной системы Дистрибьютора
  присутствует реквизит уникальный код продукции производителя (Глобальный код),
  должно соблюдаться условие привязки Глобальных кодов к Локальным кодам как "один-к-одному".
  В случае невозможности поддержания уникального Глобального кода в
  учётной системе Дистрибьютора, соответствие продуктов может поддерживаться ключевым
  пользователем непосредственно в системе SalesWorks.

  Необходимо:
  реализовать выгрузку данных в таблицу следующего формата.

  Ключ    Поле    Тип     Длина   Описание        Поле обязательное
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
    PK      LocalCode       Character       20      Локальный код продукции из учетной системы Дистрибьютора        Да
    */
   _FIELD->LocalCode :=allt(STR(mktov->MnTovT))
    /*
          Name    Character       50      Название продукции      Да
    */
    _FIELD->Name := IIF(EMPTY(mktov->Nat),"Name LocalCode "+allt(STR(mktov->MnTovT)),mktov->Nat)
    /*
          ShortName       Character       25      Краткое название продукции      Да
    */
    _FIELD->ShortName := mktov->Nat

    /*
          Weight  Numeric 11,5    Вес единицы продукции   Да
    */
    mkcrosr:=getfield('t1','mktov->mntovt','ctov','mkcros')
    nWeight:=getfield('t1','mkcrosr','mkcros','keg')
    IF nWeight > 10 //кега
      nWeight:=nWeight/10
    ELSE
      nWeight := getfield('t1','mktov->mntovt','ctov','vesp')
    ENDIF

    _FIELD->Weight := nWeight
    /*
          Pack_Qty        Numeric 14,3    Количество единиц продукции в коробке   Да
    */
    _FIELD->Pack_Qty := 1
    /*
          IsMix   Logical 1       Флажок, который указывает, является ли продукт миксом, сделанным Дистрибьютором Да
    */
    _FIELD->IsMix := .F.
    /*
            DTLM    Character       14      Дата и время модификации записи..
    Формат: "YYYYMMDD HH:MM"        Да

    */
    _FIELD->DTLM := DTLM()
    /*
            Status  Numeric 11      Статус (2 - 'активный', 9 - 'неактивный')
    По умолчанию - 2        Да
    */
    _FIELD->Status := 2

    SELE mktov
    DBSKIP()
  ENDDO
  sele (alias_1); copy to (""+alias_1)
  close mktov

  //QUIT
  /*
  FK      Code    Character       20      Глобальной код производителя продукции (если известен).
  Если неизвестен или микс (смотка) - оставлять пустым.   Да
  */
  /*
  2.16.   Таблица  LPRODDET (структура таблицы остается неизменной, ничего не менять)
  Импорт детальной информации о миксах (смотках) Дистрибьютора и их привязках
  к локальной кодировке Дистрибьютора.

  Необходимо:
  реализовать выгрузку данных в таблицу следующего формата.
  Ключ    Поле    Тип     Длина   Описание        Поле обязательное
  PK, FK  LocalCode       Character       20      Локальный код продукции из учетной системы Дистрибьютора        Да
  PK, FK  CompCode        Character       20      Локальный код компонента микса (смотки).        Да
          CompQTY Numeric 14,3    Количество компонента микса(смотки).    Да
          Percentage      Numeric 6,2     Заполнять значением кратным количеству компонентов микса в процентном соотношении то есть если компонент микса 1 то значение 100 если 2 то по 50 на каждого и тд.       Да
          Status  Numeric 11      Статус товара (2 - 'активный', 9 - 'неактивный' Да
          DTLM    Character       14      Дата и время модификации записи в формате "YYYYMMDD HH:MM"      Да
  */
  /*

  2.17.   Экспорт информации  о Заказах -Шапка (файл OlOrderH)-обязательно
  Шапка документа.
  При создании документу в УСД, обязательно нужно сохранять Order_No, для того чтобы позднее это значение выгружать в файл SalOutH.dbf
  Ключ    Поле    Тип     Длина   Описание        Поле обязательное
  PK      Order_No        Numeric 20      Идентификатор документа (номер заказа в SWE)    Да
  FK      OL_Code Character       25      Код ТТ в УСД    Да
  FK      OL_ID   Numeric 20      Идентификатор Торговой точки в SWE      Да
          Order_Date      Date    8       Время и дата создания
  документа       Да
          Exec_Date       Date    8       Желательная дата выполнения заказа      Да
  FK      PayForm_ID      Numeric 11      Идентификатор формы оплаты.
  Значение из Справочника Форм Оплаты Настольного модуля, аналогично как в файле PayForms.dbf     Да
          Resp_Pers       Character       50      Ответственное лицо (торговый представитель)     Да
          Amount  Numeric 19,5    Сумма документа с
  учетом скидки   Да
          Discount        Numeric 5,2     Скидка в процентах,%    Да
  FK      MERCH_ID        Numeric 11      Идентификатор торгового представителя в кодах SWE       Да
          Deliv_Addr      Character       255     Адрес доставки в ТТ     Да
          DOUBLED Logical 1       Специальный атрибут
  повторного экспорта
  документа
  0-документ еще не експортировался
  1-документ уже был експортирован        Да
          COMMENT Character       100     Комментарии к заказу
  Желательно комментарии из этого поля выгружать в печатную форму накладной, чтобы экспедиторы при доставке могли принимать во внимание эти комментарии.  Да
          Op_Code Character       20      Идентификатор типа операции (условий оплаты).
  Тип операции задается в настольном модуле в справочнике Типы операций. Для каждого дистрибутора настроится индивидуально. Пр.:(1-нал., 2-безнал, 3-отстрочка)  Да
          DTLM    Character       14      Дата и время модификации записи в SalesWorks. Заполняется текущей датой выполнения операции экспорта. Формат: "YYYYMMDD HH:MM"  Да
          TranspCost      Numeric 9,2     Транспортные расходы
  с НДС
  Не обрабатывать Да
          VatCalcMod      Numeric 11      Режим расчета цен:
  0-цены без НДС
  1-цены с НДС    Да
          VAT_SUM Numeric 19,5    Сумма НДС
          ProxSeries      Character       10      Серия доверенности
  Не обрабатывать Нет
          ProxNumber      Character       20      Номер доверенности
  Не обрабатывать Нет
          ProxDate        Date    8       Дата доверенности
  Не обрабатывать Нет
          Wareh_Code      Character       20      Внешний код склада      Да
          ISRETURN        Numeric 1       Флаг отвечает за поддержку
  отрицательного количества продукции при документе Заказ-Возврат.
  при импорте возвратов в УС следует учитывать что обычный заказ в OLORDERH.DBF имеет признак ISRETURN=0, а возврат будет иметь признак
  ISRETURN=1. Таким образом обычные заказы можно будет отличить от возвратов
          Да
          TaxFactNo       Character       40      Номер налоговой
  накладной
  Не обрабатывать Нет
          Route_id        Numeric 20      Идентификатор
  маршрутов       Нет
          DC_ALLOW        Numeric 3       Признак наличия ДЦ
  Не обрабатывать Нет
          OLDISTCENT      Character       25      Дистрибьюторский
  центр (Код ДЦ)
  Не обрабатывать Нет
          OLDISTSHAR      Numeric (7, 3)  Удельный вес дистрибуции
  Не обрабатывать Нет
          DC_DELIVER      Logical 1       Доставка в ДЦ
  Не обрабатывать Нет
          DC_PAYER        Logical 1       Плательщик ДЦ
  Не обрабатывать Нет
  */
  /*
  2.18.   Экспорт информации о Заказах - Детали (файл OlOrderD) - обязательно
  Фактура Заказа.
  Ключ    Поле    Тип     Длина   Описание        Поле обязательное
  FK      Order_No        Numeric 20      Идентификатор документа (номер заказа в SWE)    Да
  FK      Code    Сharacter       20      Код товара в кодах Оболони      Да
          Price   Numeric 12,5    Цена товара     Да
          Qty     Numeric 15,3    Количество товара       Да
          IsReturn        Numeric 11      Флаг, который
  указывает, является ли
  тара возвратной Да
          RDiscount       Numeric 5,2     Значение
  попозиционной скидки в процентах,%      Да
          BasePrice       Numeric 15,8    Базовая цена товара без
  НДС     Да
          LOCALCODE       Сharacter       20      Локальная кодировка ТМЦ Нет
          VAT     Numeric 5,2     НДС в процентах,%       Да
  */
  /*
  2.19.   Экспорт информации о Торговых Представителях (файл Merchand) - при необходимости
  Информация о торговых агентах: код агента, ФИО, серийный номер КПК.
  Этот файл нужно обрабатывать если планируется автоматическая привязка кодов Торговых Представителей в УСД.
  Ключ    Поле    Тип     Длина   Описание        Поле обязательное
  PK      Merch_ID        Numeric 11      Идентификатор торгового агента  Да
          Merch_Name      Character       50      Название торгового агента       Да
          DevSer_No       Character       255     Серийный номер КПК      Да
          Status  Numeric 11      Статус ТП (2 - 'активный', 9 - 'неактивный'     Да
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
1.4.    Таблица LOCALPOS
  Информация о локальном POS-оборудовании.

  Ключ  Поле  Тип Длина Описание  Поле
  обязательное
  PK  LOCALCODE Character 20  Внешний код (Код УС) локального
  POS-оборудования  Да
    NAME  Character 50  Название локального
  POS-оборудования (Берется из УС Дистрибьютора)  Да
  FK  POST_ID Numeric 11  Тип POS-оборудования (Код типа оборудования из СВЕ - справочник POS -оборудования)  Да
  FK  POSB_ID Numeric 11  Бренд POS-Оборудования оборудования (Код брэнда оборудования из СВЕ - справочник POS -оборудования) Да
    SERIAL_NO Character 50  Серийный номер
  локального POS-оборудования Нет
    INVENT_NO Character 50  Инвентарный номер
  локального POS- оборудования  Да
    DATE  Date  8 Дата введения в эксплуатацию локального POS- оборудования, если даты в УС нет, заполнять значением 1945.05.09
  ДА
    CONTR_NO  Character 50  Номер двухстороннего
  договора  Да
    CONTR_SD  Date  8 Дата начала действия
  двухстороннего договора Да
    CONTR_ED  Date  8 Дата завершения
  действия двухстороннего договора  Нет
    PRICE Numeric 15,8  Цена без НДС  Нет
    Status  Numeric 11  Статус записи 2 -'активный'
    Да
    DTLM  Character 14  Дата и время
  модификации записи в формате "YYYYMMDD HH:MM" Да
    COMMENTS1 Character 254 Комментарий1  Нет
    ...
    COMMENTS9 Character 254 Комментарий9  Нет


  Особенности импорта информации о архивных остатках локального POS-оборудования
  Реализована возможность импорта архивных остатков локального POS-оборудования, таблицы импорта LPOSARCH.DBF.

  Данные импортируются в таблицы tblLocalPOSArchivedStocks и
  tblLocalPOSArchivedStocksDetails соответственно. При этом формируется по
  одной записи в таблице tblLocalPOSArchivedStocks на каждую группу значений
  WAREH_CODE, OL_CODE и STOCKDATE (W_id, Ol_id и StockDate).
  */

//lpos2d()
  /*
1.5.    Таблица LPOSARCH
  Информация о архивных остатках локального POS-оборудования.


  Ключ  Поле  Тип Длина Описание  Поле
  обязательное
  PK,
  FK  WAREH_CODE  Character 20
  Внешний код склада (Код склада оборудования в СВЕ)  Нет
  PK,
  FK  OL_CODE Character 25  Внешний код торговой
  Точки (Код ТРТ в УС)  Нет
  PK,
  FK  LOCALCODE Character 20  Внешний код локального
  POS-оборудования  Да
    STOCKDATE Date  8 Дата архивирования
  Остатков  Да
    INSTDATE  Date  8 Дата установки
  оборудования  Нет
    DTLM  Character 14  Дата и время
  модификации записи в формате "YYYYMMDD HH:MM" Да
    TSIDNUM Character 50  Номер трехстороннего
  договора
  ДА
    TSIDSDAT  Date  8 Дата начала трехстороннего договора трехстороннего договора ДА
    TSIDEDAT  Date  8 Дата окончания
  трехстороннего договора ДА
  */

//lpos3d()
  /*
1.6.  Таблица LPOSSINH
  Информация о приходах локального POS-оборудования (шапка).
  Ключ  Поле  Тип Длина Описание  Поле
  обязательное
    DATE  Date  8 Дата прихода/возврата
  локального POS-
  оборудования  Да
  PK  LPOSIN_NO Character 50  Номер документа
  фактического прихода/возврата
  (Префикс ГОД-ТИП документа) Да
    TOTALSUM  Numeric 19,5  Общая сумма по
  документу Нет
    VAT Numeric 19,5  Сумма НДС Нет
  FK  DOC_TYPE  Numeric 2 Идентификатор типа
  Движения:
  11-Приход оборудования от поставщика
  12-Возврат оборудования поставщику
  13-Корректировка по оборудованию (+) (когда кол-во увеличивается)
  14-Перемещение оборудования на филиал
  15-Перемещение оборудования с филиала
  18-Корректировка по оборудованию (-) - (когда кол-во уменьшается)
    Да
  FK  WAREH_CODE  Character 20  Внешний код склада (Код склада оборудования в СВЕ)  Да
    INVOICE_NO  Character 58  Номер приходной
  накладной поставщика  Нет
    STATUS  Numeric 11  Статус записи
  (2 -'активный',
   9 -'неактивный') Да
    DTLM  Character 14  Дата и время
  модификации записи в формате "YYYYMMDD HH:MM" Да
  */

//lpospr()
   /*
1.7.    Таблица LPOSSIND
  Информация о приходах локального POS-оборудования (детали).
  Ключ  Поле  Тип Длина Описание  Поле
  обязательное
  PK,
  FK  LPOSIN_NO Character 50  Номер документа
  фактичного прихода/возврата
  (Префикс ГОД-ТИП документа) Да
  PK,
  FK  LOCALCODE Character 20  Внешний код локального
  POS-оборудования (Код оборудования из УС) Да
    PRICE Numeric 15,8  Цена локального POS-
  оборудования  Нет
    VAT Numeric 5,2 Сумма НДС Нет
  */

  /*

1.9 Таблица LPOSTRSH
  Ключ  Поле  Тип Длина Описание  Поле
  обязательное
    DATE  Date  8 Дата документа
  Формат: "DD.MM.YYYY"  Да
    DTLM  Character 14  Дата и время
  модификации записи в формате "YYYYMMDD HH:MM" Да
  PK  LPOSTH_NO Character 50  Номер документа
  Передачи
  (Префикс ГОД-ТИП документа) Да
    STATUS  Numeric 11  Статус записи
  (2 -'активный',
   9 -'неактивный') Да
    TOTALSUM  Numeric 20,3  Общая сумма по
  документу передачи  Нет
    VAT Numeric 20,3  Сумма НДС Нет
  FK  DOC_TYPE  Numeric 2 Идентификатор типа
  Движения
  16-Передача оборудования в розницу
  17-Возврат оборудования из розницы
    Да
  FK  WAREH_CODE  Character 20  Внешний код склада (Код склада оборудования в СВЕ)  Да
  FK  OL_CODE Character 25  Внешний код торговой
  Точки (Код ТРТ из УС дистрибьютора) Да
  FK  MERCH_ID  Numeric 11  Идентификатор
  торгового представителя (Код торгового представителя из СВЕ)  Нет
  Информация о передаче локального POS-оборудования в ТТ (шапка)
  */

//lpossv()
  /*
1.10    Таблица LPOSTRSD
  Информация о передаче локального POS-оборудования в ТТ (детали).
  Ключ  Поле  Тип Длина Описание  Поле
  обязательное
  PK,
  FK  LPOSTH_NO Сharacter 50  Номер документа
  Передачи
  (Префикс ГОД-ТИП документа) Да
  PK,
  FK  LOCALCODE Сharacter 20  Внешний код локального
  POS-оборудования (Код оборудования из УС) Да
    PRICE Numeric 15,8  Цена локального POS-
  оборудования  Нет
    VAT Numeric 5,2 Сумма НДС Нет
    ACCPRICE  Numeric 15,8  Учетная цена товара   Нет
    TSCON_NO  Character 50  Номер трехстороннего
  договора  Да
    TSCONSD Date  8 Дата начала
  трехстороннего договора Да
    TSCONED Date  8 Дата окончания
  трехстороннего договора Да
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
       PK      OL_Code Character       25      Код Торговой точки    Код ТТ в УСД.   Да
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
       PK      OL_Code Character       25      Код Торговой точки    Код ТТ в УСД.   Да
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
              DTLM    Character       14      Дата и время модификации записи..
      Формат: "YYYYMMDD HH:MM"        Да

      */
      _FIELD->DTLM := DTLM()
      /*
              Status  Numeric 11      Статус (2 - 'активный', 9 - 'неактивный')
      По умолчанию - 2        Да
      */
      // _FIELD->Status := 2 l:182 прописано, что нужно
    DBSKIP()
  ENDDO
  sele (alias_1); copy to (alias_1)
  use

  sele lposarch
    alias_1:=ALIAS()
  DBGOTOP()
  DO WHILE !EOF()
      /*
              DTLM    Character       14      Дата и время модификации записи..
      Формат: "YYYYMMDD HH:MM"        Да

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
              DTLM    Character       14      Дата и время модификации записи..
      Формат: "YYYYMMDD HH:MM"        Да

      */
      _FIELD->DTLM := DTLM()
      /*
              Status  Numeric 11      Статус (2 - 'активный', 9 - 'неактивный')
      По умолчанию - 2        Да
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
      //копирование
      COPY FILE (aFileListZip[i,1]) TO (aFileListZip[i,2])
    NEXT i
    OblnSend(aFileListZip,cPth_Plt_tmp,cPath_Pilot)

  OTHERWISE
    AADD(aFileListZip,{cFileNameArc,cFileArcNew})
  ENDCASE



  RETURN (NIL)

/****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  10-29-14 * 09:40:43pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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
 АВТОР..ДАТА..........С. Литовка  10-20-14 * 01:44:08pm
 НАЗНАЧЕНИЕ......... append - простое добавлени
 add - только файл первого архива
 add и p3 - уникаьное ключенове поле, p4 - блок кода уникального ключ.поля
 (добаляет только уникальные значения)
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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


  // первый распаковываем в дир обмена cus2swe
  OblnUnZip(aFileListZip[1,1],cPath_Pilot)
  // открываем ДБФ

  If LEN(aFileListZip) > 1

    set translate path off
    For k:=1 To LEN(aFileSend)
      USE (cPath_Pilot+"\"+aFileSend[k,1]+'.DBF') ALIAS (aFileSend[k,1]) NEW Exclusive
      If aFileSend[k,2]='add' .and. len(aFileSend[k])>2
        // созднаие индекса
        SELE (aFileSend[k,1])
        ordcreate(,,aFileSend[k,3],)
      EndIf
    Next

    // берем архивы со 2-го
    For i:=2 To LEN(aFileListZip)
      // распаковка во временный
      OblnUnZip(aFileListZip[i,1],cPth_Plt_tmp)
      For k:=1 To LEN(aFileSend)
        // анализ на добаление
        If aFileSend[k,2]='append' // .or. aFileSend[k,2]='add'
          SELE (aFileSend[k,1])
          APPEND FROM (cPth_Plt_tmp+"\"+aFileSend[k,1]+'.DBF')

        Elseif aFileSend[k,2]='add' .and. len(aFileSend[k])>2

          // открыти данных для добавления
          USE (cPth_Plt_tmp+"\"+aFileSend[k,1]+'.DBF') ;
          ALIAS (aFileSend[k,1]+'_1') NEW

          // связь с иточнимом
          dbSetRelat(aFileSend[k,1], aFileSend[k,4]) //, aFileSend[k,3])
          // копирование тех, которых нет -> tmpadd
          copy to tmpadd for (aFileSend[k,1])->(!found())
          // copy to tmp!add for (aFileSend[k,1])->(found())

          CLOSE (aFileSend[k,1]+'_1')

          SELE (aFileSend[k,1])
          APPEND FROM tmpadd

        EndIf
      Next
    Next i
    // закрываем
    For k:=1 To LEN(aFileSend)
      SELE  (aFileSend[k,1])
      If FieldPos('DTLM')#0
        repl all _FIELD->DTLM with DTLM()
      EndIf
      CLOSE (aFileSend[k,1])
    Next
    set translate path on
  EndIf

  // запуск передачи ФТП
  cCmd:='CUR_PWD=`pwd`; cd /m1/upgrade2/lodis/obolon/cus2swe; ';
  +'./put-ftp.sh;  cd $CUR_PWD'
  cLogSysCmd:=''
  SYSCMD(cCmd,"",@cLogSysCmd)
  outlog(__FILE__,__LINE__,cCmd)

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  05-07-14 * 09:44:25am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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
  PK      OL_ID   Numeric 20      Идентификатор Торговой точки .
  Заполнять значением=0.  Присваивается в SWED, после первого импорта ТТ. Да
   */
   _FIELD->OL_ID:=0
   /*
    PK      OL_Code Character       25      Код Торговой точки    Код ТТ в УСД.   Да
   */
   _FIELD->OL_Code:=STR(tmp_ktt->kgp,7)+"-"+STR(tmp_ktt->kpl,7)
   /*
        Name    Character       255     Юридическое название Торговой точки .   Да
   */
   cNgp:=allt(kln->nkl)
   cNpl:=(kln->(netseek('t1','tmp_ktt->kpl')),  allt(kln->nkl))
   nNN:=kln->NN
   nKkl1:=kln->kkl1
   cDeliv_Addr:=allt(kln->adr)

   _FIELD->Name := cNpl + "-" + cNgp


   kln->(netseek('t1','kgpr'))
   /*
        Trade_Name      Character       255     Название Торговой точки Да
   */
   _FIELD->Trade_Name := allt(kln->nkl)
   /*
        Director        Character       50      Директор Торговой точки .
    По умолчанию '-' - не определенный.     Да
   */
   _FIELD->Director := "-"
   /*
        Address Character       255     Адрес Торговой точки .  Да
   */
   _FIELD->Address := cDeliv_Addr // (Юр. адрес KPL)
   /*
        Deliv_Addr      Character       255     Адрес доставки.         Да
   */
   _FIELD->Deliv_Addr := allt(getfield("t1","kln->knasp","knasp","nnasp"));
                        +" "+allt(kln->adr) // Факт. адрес
   /*
        Telephone       Character       20      Конт. телефон Торговой точки .
    По умолчанию '-' - не определенный.     Да
   */
   _FIELD->Telephone := "-"
   /*
        Fax     Character       20      Факс Торговой точки .
    По умолчанию '-' - не определенный.     Да
   */
   _FIELD->Fax := "-"
   /*
            EMail   Character       50      Электронный адрес
    В нашем случае заполняется количеством дней отсрочки для данной ТРТ     Да
   */
   _FIELD->EMail := STR(kdopl("027",tmp_ktt->kpl))
   /*
        Accountant      Character       50      Бухгалтер Торговой точки В нашем случае заполняется кодом ТРТ в кодировке оболони с соответствующем префиксом:
    К- Крым
    Х - Херсон
    О - Одесса
    Например К12345 Да
   */
   _FIELD->Accountant := "C"+"18005" +"_"+CHARREM(" ",_FIELD->OL_Code)
   /*
          Acc_Phone       Character       20      Телефон бухгалтера Торговой точки .
  По умолчанию '-' - не определенный.     Да
   */
   _FIELD->Acc_Phone := "-"
   /*
          M_Manager       Character       50      в связи с требованием ГО оболонь необходимо внести изменения в интерфейс обмена для возможности выгружать данные о лимите КЕГ для торговых точек.
          Это - цифра 1-2-х значная. Если ТРТ не имеет лимита КЕГ, то
  поле следует заполнять значением 0.     Да
   */
   _FIELD->M_Manager := "0"
   /*
        MM_Phone        Character       20      Телефон товароведа.
   По умолчанию '-' - не определенный.     Да
   */
   _FIELD->MM_Phone := "-"
   /*
          P_Manager       Character       50      Экспедитор Торговой точки .
  По умолчанию '-' - не определенный.     Да
   */
   _FIELD->P_Manager := "-"
   /*
        Open_Time       Character       5       Время открытия Торговой точки в формате 'hh:mm'. По умолчанию '08:00'.  Да
   */
   _FIELD->Open_Time := "08:00"
   /*
        Close_Time      Character       5       Время закрытия Торговой точки в формате 'hh:mm'. По умолчанию '20:00'.  Да
   */
   _FIELD->Close_Time := "20:00"
   /*
        Break_From      Character       5       Время начала перерыва в формате 'hh:mm'.
   По умолчанию '13:00'.   Да
   */
   _FIELD->Break_From := "13:00"
   /*
          Break_To        Character       5       Время оконччания перерыва в формате 'hh:mm'.
  По умолчанию '14:00'.   Да
   */
   _FIELD->Break_To := "14:00"
   /*
          ZKPO    Character       20      код ЄДРПО.
  По умолчанию '-' - не определенный.     Да
   */
   _FIELD->ZKPO := LTRIM(STR(nKkl1))  //LTRIM(STR(nNN)) //  01-19-18 10:25pm
   /*
          IPN     Character       20      код ИНН.
  По умолчанию '-' - не определенный.     Да
   */
   _FIELD->IPN := LTRIM(STR(nNN)) //"-"  LTRIM(STR(nKkl1)) //  01-19-18 10:25pm
   /*
          VATN    Character       20      Номер плательщика НДС
  По умолчанию '-' - не определенный.     Да
   */
   _FIELD->VATN := "-"
   /*
          RR      Character       20      Р\с.
  По умолчанию '-' - не определенный.     Да
   */
   _FIELD->RR := "-"
   /*
          BankCode        Character       20      Код банка.
  По умолчанию '-' - не определенный.     Да
   */
   _FIELD->BankCode := "-"
   /*
          BankName        Character       50      Название банка.
  По умолчанию '-' - не определенный.     Да
   */
   _FIELD->BankName := "-"
   /*
          BankAddr        Character       50      Адрес банка.
  По умолчанию '-' - не определенный.     Да
   */
   _FIELD->BankAddr := "-"
   /*
          DTLM    Character       14      Дата и время модификации записи. Формат: "YYYYMMDD HH:MM"       Да
   */
  #ifdef __CLIP__
  _FIELD->DTLM := DTOC(DATE(),"yyyymmdd")+' '+SUBSTR(TIME(),1,5)
  #endif
   /*
          CONTR_NUM       Character       50      Номер договора  Нет
   */
    nDogNum:=getfield('t1','kplr','klndog','NDog')
   _FIELD->CONTR_NUM:=IIF(EMPTY(nDogNum),"-","SL-"+allt(STR(nDogNum)))

   /*
          CONTR_DATE      Date    8       Дата начала действия договора.
  Если нет данных - заполнять значением 01.01.1899.       Нет
   */
  #ifdef __CLIP__
    dtDogBr:=getfield('t1','kplr','klndog','dtDogB')
   _FIELD->CONTR_DATE := IIF(EMPTY(dtDogBr),CTOD("01.01.1899","DD.MM.YYYY"),dtDogBr)
  #endif
   /*
          CNTR_DT_F       Date    8       Дата окончания действия  договора
  Если нет данных - заполнять значением 01.01.1900.       Нет
   */
  #ifdef __CLIP__
    dtDogEr:=getfield('t1','kplr','klndog','dtDogE')
   _FIELD->CNTR_DT_F := IIF(EMPTY(dtDogEr),CTOD("01.01.1900","DD.MM.YYYY"),dtDogEr)

  #endif
   /*
          Status  Numeric 11      Статус ТТ   (2 - 'активная',   9 - 'неактивная (закрытая))     Да
   */
   _FIELD->Status:=2
   /*
          PComp_Code      Character       25      Внешний код юридического лица.
  Значение выгружать аналогично как и в файл ParComp.dbf  Нет
   */
   _FIELD->PComp_Code:=STR(tmp_ktt->kpl,7)
    If !empty(FieldPos('PComp_id'))
      _FIELD->PComp_id:=_FIELD->PComp_Code
    EndIf
   /*
          Lic_Usage       Numeric 5       Выбор контроля
  лицензий (0 - не  использовать,   1- с  предупреждением, 2-  с запретом)
  Заполнять - 1   Да
   */
   _FIELD->Lic_Usage := 1
    /*
  FK      Owner_ID        Numeric 11      Идентификатор владельца Торговой точки .
  Код ТП, можно получить в файлах экспорта Merchand.dbf, поле Merch_id           Да
    */
    nIdLod:=getfield('t1','tmp_ktt->kta','s_tag','idlod')
    DO WHILE .T.
      IF nIdLod < 5200000
        nIdLodOld:=nIdLod
        nIdLod:=getfield('t1','nIdLod','s_tag','idlod')
        IF nIdLodOld = nIdLod .OR. nIdLod = 0
          nIdLod:=9990000+tmp_ktt->kta //9990

          IF getfield('t1','tmp_ktt->kta','s_tag','DeviceId') > 0 //рабочий ТА
            IF ASCAN(aMessErr,"Не верный код ТА'-' "+STR(tmp_ktt->kta))=0
              AADD(aMessErr,"Не верный код ТА'-' "+STR(tmp_ktt->kta)+;
              " для ТТ "+_FIELD->OL_Code+;
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
  FK      SubType_ID      Numeric 11      Идентификатор подтипа Торговой точки .
  По умолчанию 0 -не определенный.
  Желательно предусмотреть в интерфейсе обмена поле куда можно будет поставить числовое значение кода подтипа торговой точки      Да
  FK      Area_ID Numeric 11      Идентификатор района в котором находится торговая точка.
  По умолчанию 0 - не определенный. Желательно предусмотреть в интерфейсе обмена поле куда можно будет поставить числовое значение кода района(города) к которому принадлежит ТРТ.  Да
          DC_ALLOW        Numeric 3       Признак наличия Дистрибьюторского  центра
  0,если не определенный. Нет
          OLDISTCENT      Character       25      Дистрибьюторский
  центр (Код ДЦ) Оставить не заполненным. Нет
          OLDISTSHAR      Numeric (7, 3)  Удельный вес в
  дистрибуции   Оставить не заполненным.        Нет
          DC_DELIVER      Logical 1       Доставка в ДЦ  0, якщо невизначено.    Нет
          DC_PAYER        Logical 1       Платник ДЦ   0, если не определенный.        Нет
  */

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  08-08-14 * 09:08:03am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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
 АВТОР..ДАТА..........С. Литовка  07-09-14 * 01:11:51pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION ObolonOrder()
  LOCAL lerase:=.T., lDelFile:=.T.,lCreTtn0_4Zdn
  LOCAL cDosParam, nKta, nPosS
  LOCAL nCntRec, nZenNew

  IF !lerase_lrs(lerase)
    outlog(3,__FILE__,__LINE__,'//в следующий раз')
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

  OblnDirBlock(cPath_Order,"Clvrt Lodis Start Order") //если проблема, то QUIT
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
    // выкусим для этого КТА
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
      vor=1  //возврат
      kopr=108
      // kopir  - останется прежним для анализа
      // !!  к-во отрицательное Qty
    ELSE
      vor:=9 // реализация
    ENDIF

    //проверка на принадлежность заявки данному складу
    Sklr   := 888
    DO CASE
    CASE allt(OrdH->Wareh_Code)="999"
      SkVzr := 232
       Sklr := 232
      If kopir=169
        kopr   := 107
        Sklr := 263 // Брак 169
      EndIf
    CASE allt(OrdH->Wareh_Code)="997"
      SkVzr := 700
      Sklr := 700
      If kopir=169
        kopr   := 107
        Sklr := 705 // Брак 169
      EndIf

    CASE allt(OrdH->Wareh_Code)=="1" ;
      .OR. allt(OrdH->Wareh_Code)="232"
      SkVzr := 232
      Sklr := 232

    CASE allt(OrdH->Wareh_Code)="238" // тарный
      SkVzr := 232
      Sklr := 238

    CASE allt(OrdH->Wareh_Code)="704"
      SkVzr := 700
      Sklr := 704

    CASE  allt(OrdH->Wareh_Code)="1000";
      .OR. allt(OrdH->Wareh_Code)="1001"
      SkVzr := 232
      If kopir=169
        Sklr := 263 // Брак 169
      Else
        Sklr := 262 // Брак
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
        Sklr := 705 // Брак 169
      Else
        Sklr := 704 // Брак
      EndIf
      //Sklr := 700
    ENDCASE

    IF !cSkl->(check_skl(Sklr))
      skip
      LOOP
    ENDIF
    // блокировка обработки д-тов выписанных в период в текущем и месяц назад
    If BOM(OrdH->Order_Date) == BOM(gdTd) ;
      .or. BOM(OrdH->Order_Date) == BOM(addmonth(gdTd,-1))
      // ок!
    ELSE
      skip
      loop
    EndIf

    lrs1->(DBGoBottom())
    ttnr:=lrs1->ttn
    ttnr:=ttnr+1


     DtRor:=if(empty(OrdH->Exec_Date),date(),OrdH->Exec_Date) //дата доставки

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

     ttncr  := 1 // нужны доки на тару? (0,1)

     DO CASE
     CASE .F. //kopr = 160
       ttncr  := 0
     ENDCASE

     IF OrdD->(DBSEEK(OrdH->Order_No))

       sele lrs1

       netadd()
       netrepl('DtRo',{DtRor})

       if at('т=',Commentr) # 0 // задание на забор денег
         netrepl('ztxt',{Commentr})
       else
         netrepl('npv',{Commentr})
       endif

       netrepl('TimeCrtFrm,TimeCrt,DocGUID,Sdv',;
               {TimeCrtFrmr,TimeCrtr,DocIDr,Sumr})
       netrepl('Skl,ttn,vo,kop,kopi,kpl,kgp,kta,ddc,tdc',;
              {Sklr,ttnr,vor,kopr,kopir,kplr,kgpr,ktar,date(),time()})
       netrepl('ttnp,NdVz',{ttncr,SkVzr})

      //формируем шапку
      OrdD->(DBSEEK(OrdH->Order_No))
      DO WHILE OrdD->Order_No = OrdH->Order_No
        //формируем строки
        ttnr := ttnr
        If OrdH->PayForm_Id = 5200002
          If VAL(OrdD->LocalCode) = 228
            mntovr := 228 // кега 30л
          Else  // 313
            mntovr := 229 // кега 50л (219)
          EndIf
        Else
          mntovr := OblMnTov(VAL(OrdD->LocalCode))
        EndIf

        /*
           !!KegaVolOrd
           // <- кегу не переводим т.е. показываем в Литрах
        nVolume:=1
        */
        nVolume:=KegaVol('mntovr')
        kvpr   := ABS(OrdD->Qty * nVolume)
        zenr   := OrdD->Price / nVolume

        If allt(OrdH->Wareh_Code) $ '999;997' // переоценка
          // выписывается тот же товар с АКЦ ценами
          If .T. ///kopir=169

            // обычный товар
            sele lrs2
            netadd()
            netrepl('ttn,mntov,kvp,zen',{ttnr,mntovr,kvpr,zenr},)

            // вторая строка переоценка
            cAddNat:=""
            nZenNew:=AktsSWZen(mntovr, Kgpr, Kplr, DtRor, @cAddNat)
            zenr:=nZenNew

            If !IsNil(nZenNew) // цены Акц - НЕТ
              sele lrs2
              outlog(3,__FILE__,__LINE__,"zenr,nZenNew",zen,nZenNew)
              netadd()
              netrepl('ttn,mntov,kvp,zen',{ttnr,mntovr,kvpr,zenr},)
            EndIf

            exit // берем одну строку из д-та

          Else
            If ActSWChk(mntovr, kgpr, kplr, DtRor)
              sele lrs2
              netadd()
              netrepl('ttn,mntov,kvp,zen',{ttnr,mntovr,kvpr,zenr},)
            Else
            EndIf
          EndIf
        else

          If int(Mntovr/10000) > 1 // товар (не тара и не стекло)
            Act_MnTov4_MnTov()
            // приведение товара к цене без акции
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
      outlog(__FILE__,__LINE__,'Нет строк OrdD->(DBSEEK(OrdH->Order_No))',OrdH->Order_No)
    ENDIF

    If allt(OrdH->Wareh_Code) $ '999;997' // переоценка

      sele lrs1
      netrepl('nnz', {allt(OrdH->Wareh_Code)}) // для анализа ТТНВозрата
      If kopir=169
        netrepl('npv',{"-169"}) // не нужно поиска ТТНВозрата
      EndIf

      // проверка на к-во строк
      sele lrs2
      ordsetfocus('t1')
      netseek('t1','ttnr')
      count to nCntRec while  ttnr = ttn
      If nCntRec = 2 //.and. iif(kopir=169,!Empty(nOrdN),.T.)  // нормально

        sele lrs2
        netseek('t1','ttnr') // первая строка основной товар
        DBSkip()
        netrepl('ttn', {ttn+1})// вторая строка открузка Акции

        // дополнительно формируем шапку для расхода
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
          outlog(__FILE__,__LINE__,'DELE Не верное к-во строк Переоценка',OrdH->Order_No, nCntRec)
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


  // добавим задания из коментриев
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

  // проверка на наличие шапок
  CreTtn0_4Zdn(.T.) // '/NEWZDN' $ upper(cDosParam))

  sele tzvk
  copy to ('tzvk'+PADL(LTRIM(str(ktar)),3,'0'))
  copy to ('tzvk_lrs')

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  08-08-14 * 09:14:27am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION  OblnDirBlock(cPth_Plt, cApp)
  //файл блокировок
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
        //перезапуск, вышло аварийно
        outlog(__FILE__ ,__LINE__, "ReStart",_FIELD->Blocked, _FIELD->App, _FIELD->DTLM,"перезапуск, вышло аварийно")
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
 АВТОР..ДАТА..........С. Литовка  10-13-14 * 11:43:00am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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
    // ищем Акциз
    SELECT mkdoc
    nRecNo:=RECNO()
    DO WHILE  nSk = _FIELD->Sk .AND.     nTtn = _FIELD->Ttn
      //  есть или нет Акциза на группу
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
 АВТОР..ДАТА..........С. Литовка  02-23-17 * 05:46:04pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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
 АВТОР..ДАТА..........С. Литовка  03-16-17 * 01:19:39pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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
          IF _FIELD->SK = 700 //склад Конотоп
            nIdLod:= 5200861
          ELSE
            nIdLod:= 5200020
          ENDIF
          If !(_FIELD->Sk = 263)
            AADD(aMessErr,"Не верный код ТА'-' "+STR(_FIELD->kta)+;
            " для ТТН(alias:"+alias()+")";
            + DTOS(iif(!empty(FieldPos('DTtn')),_FIELD->DTtn,_FIELD->DOP)) ;
            +" "+ STR(_FIELD->Sk)+" "+STR(_FIELD->Ttn)+;
            CHR(10)+CHR(13))
            AADD(aMessErr,"    взят код (СВЕ) прямых продаж "+STR(nIdLod)+;
            CHR(10)+CHR(13))
          EndIf


          AADD(aKta,_FIELD->kta)  // по "Методике..." нет кода ТА
          //DBSKIP();      LOOP    // не выгружаем

          EXIT
        ENDIF
      ELSE
        EXIT
      ENDIF
    ENDDO
  RETURN (nIdLod)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-21-17 * 00:03:26am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION oblswr()
  // собрать в кучу
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

    // Вес единицы продукции в декалитрах
    mkcrosr:=getfield('t1','mkdoc->mntovt','ctov','mkcros')
    nWeight:=getfield('t1','mkcrosr','mkcros','keg')
    IF nWeight > 10 //кега
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
      //  пиво
      aSumDcl[1] += kvp * dcl
      aSumGrn[1] += nSumGrn
      lCase:=.T.
    Case nGrp = 330 .and. Dcl < 10
      // без алкогол
      aSumDcl[2] += kvp * dcl
      aSumGrn[2] += nSumGrn
      lCase:=.T.
    Case nGrp = 329 .and. Dcl < 10
      // мин вода
      aSumDcl[3] += kvp * dcl
      aSumGrn[3] += nSumGrn
      lCase:=.T.
    Case nGrp = 340 .and. Dcl < 10 ;
      .and. !(str(mkdoc->mntovt) $ OB_LIST_SIDR)
      // слаб алкогол
      aSumDcl[4] += kvp * dcl
      aSumGrn[4] += nSumGrn
      lCase:=.T.
    Case nGrp = 340 .and. Dcl < 10 ;
      .and. str(mkdoc->mntovt) $ OB_LIST_SIDR
      // сидр
      aSumDcl[5] += kvp * dcl
      aSumGrn[5] += nSumGrn
      lCase:=.T.
    Case nGrp = 340 .and. Dcl > 10 //;      .and. str(mkdoc->mntovt) $ '3400244'
      // сидр кега
      aSumDcl[6] += kvp  //* dcl
      aSumGrn[6] += nSumGrn
      lCase:=.T.
    Case nGrp = 341 .and. Dcl > 10
      //  пиво кега
      aSumDcl[7] += kvp // * dcl
      aSumGrn[7] += nSumGrn
      lCase:=.T.
    Case nGrp = 330 .and. Dcl > 10
      // без алкогол  кега
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
    Report->C1R2:="Продаж пиво"
    Report->C1R3:="Продаж БАН"
    Report->C1R4:="Продаж MIH"
    Report->C1R5:="Продаж САН"
    Report->C1R6:="Продаж СIДР"
    Report->C1R7:="Продаж СIДР(кеги)"
    Report->C1R8:="Продаж пиво(кеги)"
    Report->C1R9:="Продаж БАН(кеги)"
    Report->C1R10:="Загалом за мiсяць"

    Report->(DBAppend())
    Report->C1R1:="Продаж ДАЛ"
    FOR i:=1 TO 9
      FieldPut(i+1,STR(aSumDcl[i]/10,12,3))
    NEXT

    Report->(DBAppend())
    Report->C1R1:="Продажi продукцiїГРН з ПДВ"
    FOR i:=1 TO 9
      FieldPut(i+1,STR(aSumGrn[i],12,2))
    NEXT
  RETURN (NIL)
/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  07-07-17 * 01:59:26pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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
    FK      OL_Code Character       25      Код ТТ в УСД, по которой возник долг.   Да
    */

    _FIELD->OL_Code:=STR((cAl_deb)->Kgp,7)+"-"+STR((cAl_deb)->Kpl,7)

    /*
          Debt    Numeric 19,2    Общий долг ТТ,  значение в грн. Да
    */
    _FIELD->Debt := (cAl_deb)->Sdp
    /*
          PayDate Date    8       Дата последней оплаты
    */
    _FIELD->PayDate := IIF(EMPTY(deb_dz->DDK), STOD('20060901'),deb_dz->DDK)
    /*
          CanSale Logical 1       Флажок, который указывает, разрешено ли отгружать в ТТ
       1-разрешено   0-не разрешено  Да
    */
    _FIELD->CanSale:=.T.
    /*
            Avg_Amount      Numeric 8,2     Средний объем товарооборота по торговой точке.
          По умолчанию -0 Да
    */
    _FIELD->Avg_Amount := 0
    /*
          Details1
          :. Details20    Character       50      Детальная информация о продажах и оплатах ТТ.
          Можно указывать дополнительное текстовое объяснение к долгу.    Нет
    */
    // _FIELD->Details1 := LEFT(allt(">7дн:"+LTRIM(STR(d-eb_dz->PDZ,10,2))+" >14дн:"+LTRIM(STR(d-eb_dz->PDZ1,10,2))+" >21дн:"+LTRIM(STR(d-eb_dz->PDZ3,10,2))), 50)


    // 5200861 // 5200020
    /*
            DTLM    Character       14      Дата и время модификации записи (выгрузки информации). Формат: "YYYYMMDD HH:MM" Да
    */
    _FIELD->DTLM := DTLM()
    /*
     Status  Numeric 11      Статус (2 - 'активный', 9 - 'неактивный')
     Заполнять значением "2",        Да
    */
    //_FIELD->Status := 2

    If !empty(FieldPos('CURR_DELAY'))
      // задоленость дней
      _FIELD->CURR_DELAY:=3
    EndIf
    If !empty(FieldPos('MAXDEBT'))
      // лимит задолжености сумма 19.2
      _FIELD->MAXDEBT:=10
    EndIf
    If !empty(FieldPos('MAXDELAY'))
      // отсрочка дней
      klpr:=(cAl_deb)->Kpl
      _FIELD->MAXDELAY:=getfield('t1','Kplr','klndog','kdopl')
    EndIf

    SELE (cAl_deb)
    DBSkip()
  ENDDO
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  07-07-17 * 02:10:08pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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
    DBAPPEND() //проверка на дубляж   STR(mkkplkgp->Kgp,7)+"-"+STR(mkkplkgp->Kpl,7)
    /*
    FK      OL_Code Character       25      Код ТТ в УСД, по которой возник долг.   Да
    */

    _FIELD->OL_Code:=STR((cAl_skdoc)->Kgp,7)+"-"+STR((cAl_skdoc)->Kpl,7) //

    /*
    FK      DATE    Date    8       Дата возникновения долга.  Дата документа по
                                    которому возник долг. Да
    */
    _FIELD->DATE := (cAl_skdoc)->DOP
    /*
    FK      COMMENT Character       50      Комментарий к долгу.
                  Указать номер расходной накладной по которой возник долг через
                   "точку с запятой" указать количество дней просрочки долга.
                  (Пр: "12345; -5" (долг будет просрочен через 5дней, "12335; 2"
                  долг уже 2 дн_я просрочен)       Да
    */
    dDtOpl:=(cAl_skdoc)->(IIF(EMPTY(DtOpl), DOP+14,DtOpl))

    _FIELD->COMMENT :=  ;
    (cAl_skdoc)->(allt(STR(SK))+"_"+allt(STR(TTN)));
    +';'+ STR(dDateDeb-dDtOpl,3);
    +";"+ "Дата опл:"+DTOC(dDtOpl)

    /*
            DEBT    Numeric 16,2    Долг ТТ по документу. Указать суму
            документа (в грн.),             по которому возник долг. Да
    */
    _FIELD->DEBT := (cAl_skdoc)->Sdp
    /*
            DebTypCode      Character       20      Тип задолженности:
                         100 - Кеги (не просроченный)
                         105 - Кеги (просроченный)

                         101 - Продукция (не просроченный)
                         103 - Продукция  (просроченный)

                         102 - Тара без кег (не просроченный)
                         106 - Тара без кег (просроченный)       Да
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
      IF (cAl_skdoc)->NN = 0 .or. (cAl_skdoc)->KOP = 169 // к-во дней просрочки
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
            INVOICE_NO      Character       58      Идентификатор
                    Инвойса (а в поле invoice_no должен быть записан номер
                    документа продажи, который   создал эту дебиторскую
                    задолженность)   Нет
    */
    _FIELD->INVOICE_NO:=(cAl_skdoc)->(allt(STR(SK))+"_"+allt(STR(TTN))) //+":"+STR(KOP)+":КОП"

    /*   MERCH_ID        Numeric 11      Идентификатор торгового представителя в кодах SWE       Да*/
    //_FIELD->MERCH_ID := skdoc->(nIdLod('skdoc->kta', @aMessErr, aKta))
    _FIELD->MERCH_ID := (cAl_skdoc)->(nIdLod(cAl_skdoc+'->kta', @aMessErr, aKta))
    If !empty(FieldPos('MERCH_CODE'))
      _FIELD->MERCH_CODE:=allt(str((cAl_skdoc)->Kta))
    EndIf

    /*
            QTY     Numeric 14,3    Количество товара (поле qty можно не заполнять или просто заполнить его 0)      Нет
    */
    _FIELD->QTY := nQTY
    /*
            DTLM    Character       14      Дата и время модификации записи (выгрузки информации). Формат: "YYYYMMDD HH:MM" Да
    */
   // _FIELD->DTLM := DTLM()
    /*
     Status  Numeric 11      Статус (2 - 'активный', 9 - 'неактивный')
     Заполнять значением "2",        Да
    */
   // _FIELD->Status := 2

    sele (cAl_skdoc)
    DBSKIP()
  ENDDO
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  07-07-17 * 02:22:32pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION DebDetKeg(ali_etm, cAl_OlDebDet,dDateDeb)

  DBGOTOP()
  i:=0
  DO WHILE !EOF()

    SELE (cAl_OlDebDet)
   alias_1:=ALIAS()
    DBAPPEND() //проверка на дубляж   STR(mkkplkgp->Kgp,7)+"-"+STR(mkkplkgp->Kpl,7)
    /*
    FK      OL_Code Character       25      Код ТТ в УСД, по которой возник долг.   Да
    */
   _FIELD->OL_Code:=STR((ali_etm)->Kgp,7)+"-"+STR((ali_etm)->Kpl,7)

    /*
    FK      DATE    Date    8       Дата возникновения долга.  Дата документа по
                                    которому возник долг. Да
    */
    _FIELD->DATE := dDateDeb //dDt //DATE()
    /*
    FK      COMMENT Character       50      Комментарий к долгу.
                  Указать номер расходной накладной по которой возник долг через
                   "точку с запятой" указать количество дней просрочки долга.
                  (Пр: "12345; -5" (долг будет просрочен через 5дней, "12335; 2"
                  долг уже 2 дн_я просрочен)       Да
    */
    dDtOpl:=DATE()+21
    _FIELD->COMMENT := ;
    "Дата опл:"+DTOC(dDtOpl);
    +";"+STR(DATE()-dDtOpl,3)

    /*
            DEBT    Numeric 16,2    Долг ТТ по документу. Указать суму
            документа (в грн.),             по которому возник долг. Да
    */

      nZen:=(ali_etm)->Opt
      IF EMPTY(nZen)
        nZen:=1000
      ENDIF

    _FIELD->DEBT := (ali_etm)->Osf*nZen

    /*
            DebTypCode      Character       20      Тип задолженности:
                         100- Кеги (не просроченный)
                         101- Продукция (не просроченный)
                         102 - Тара без кег (не просроченный)
                         103 - Продукция  (просроченный)
                         105 - Кеги (просроченный)
                         106 - Тара без кег (просроченный)       Да
    */
      _FIELD->DebTypCode := "100"+STR((ali_etm)->Keg/10,1)
    /*
            INVOICE_NO      Character       58      Идентификатор
                    Инвойса (а в поле invoice_no должен быть записан номер
                    документа продажи, который   создал эту дебиторскую
                    задолженность)   Нет
    */
    _FIELD->INVOICE_NO:=(ali_etm)->(STR(MNTOV))+":"+_FIELD->OL_Code
    /*
            QTY     Numeric 14,3    Количество товара (поле qty можно не заполнять или просто заполнить его 0)      Нет
    */
    _FIELD->QTY := (ali_etm)->Osf

    /*   MERCH_ID        Numeric 11      Идентификатор торгового представителя в кодах SWE       Да*/
    _FIELD->MERCH_ID := iif(left(getfield('t1','KegO->kpl','kpl','cRmSk'),1)='1',;
            5200020,;
            5200861;
  )
    If !empty(FieldPos('MERCH_CODE'))
      _FIELD->MERCH_CODE:=_FIELD->MERCH_ID
      //allt(str((cAl_skdoc)->Kta))
    EndIf

    /*
            DTLM    Character       14      Дата и время модификации записи (выгрузки информации). Формат: "YYYYMMDD HH:MM" Да
    */
    _FIELD->DTLM := DTLM()
    /*
     Status  Numeric 11      Статус (2 - 'активный', 9 - 'неактивный')
     Заполнять значением "2",        Да
    */
    _FIELD->Status := 2

    sele (ali_etm)
    DBSKIP()
  ENDDO
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  07-26-17 * 04:03:30pm
 НАЗНАЧЕНИЕ......... вывод долга тары из skdoc
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION DebDetKeg30(ali_etm, cAl_OlDebDet,dDateDeb,aMessErr, aKta)
  DBGOTOP()
  i:=0
  DO WHILE !EOF()

    SELE (cAl_OlDebDet)
   alias_1:=ALIAS()
    DBAPPEND() //проверка на дубляж   STR(mkkplkgp->Kgp,7)+"-"+STR(mkkplkgp->Kpl,7)
    /*
    FK      OL_Code Character       25      Код ТТ в УСД, по которой возник долг.   Да
    */
   _FIELD->OL_Code:=STR((ali_etm)->Kgp,7)+"-"+STR((ali_etm)->Kpl,7)

    /*
    FK      DATE    Date    8       Дата возникновения долга.  Дата документа по
                                    которому возник долг. Да
    */
    _FIELD->DATE := dDateDeb //dDt //DATE()
    /*
    FK      COMMENT Character       50      Комментарий к долгу.
                  Указать номер расходной накладной по которой возник долг через
                   "точку с запятой" указать количество дней просрочки долга.
                  (Пр: "12345; -5" (долг будет просрочен через 5дней, "12335; 2"
                  долг уже 2 дн_я просрочен)       Да
    */
    dDtOpl:=DATE()+21
    _FIELD->COMMENT := ;
    (ali_etm)->(allt(STR(SK))+"_"+allt(STR(TTN)));
    +';'+ STR(dDateDeb-dDtOpl,3);
    +";"+ "Дата опл:"+DTOC(dDtOpl)

    /*
            DEBT    Numeric 16,2    Долг ТТ по документу. Указать суму
            документа (в грн.),             по которому возник долг. Да
    */

    _FIELD->DEBT := (ali_etm)->Sdp

    /*
            DebTypCode      Character       20      Тип задолженности:
                         100- Кеги (не просроченный)
                         101- Продукция (не просроченный)
                         102 - Тара без кег (не просроченный)
                         103 - Продукция  (просроченный)
                         105 - Кеги (просроченный)
                         106 - Тара без кег (просроченный)       Да
    */
      _FIELD->DebTypCode := "100"+STR((ali_etm)->Keg/10,1)
    /*
            INVOICE_NO      Character       58      Идентификатор
                    Инвойса (а в поле invoice_no должен быть записан номер
                    документа продажи, который   создал эту дебиторскую
                    задолженность)   Нет
    */
    _FIELD->INVOICE_NO:= (ali_etm)->(allt(STR(SK))+"_"+allt(STR(TTN)))
    /*
            QTY     Numeric 14,3    Количество товара (поле qty можно не заполнять или просто заполнить его 0)      Нет
    */
    _FIELD->QTY := (ali_etm)->kvp

    /*   MERCH_ID        Numeric 11      Идентификатор торгового представителя в кодах SWE       Да*/
    _FIELD->MERCH_ID := (ali_etm)->(nIdLod(ali_etm+'->kta', @aMessErr, aKta))

    If !empty(FieldPos('MERCH_CODE'))
      _FIELD->MERCH_CODE:=allt(str((ali_etm)->Kta))
    EndIf

    /*
            DTLM    Character       14      Дата и время модификации записи (выгрузки информации). Формат: "YYYYMMDD HH:MM" Да
    */
    // _FIELD->DTLM := DTLM()
    /*
     Status  Numeric 11      Статус (2 - 'активный', 9 - 'неактивный')
     Заполнять значением "2",        Да
    */
    // _FIELD->Status := 2

    sele (ali_etm)
    DBSKIP()
  ENDDO
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  08-14-17 * 12:46:59pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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
    //в следующий раз
    RETURN
  ENDIF
  If file('lrs1_del.dbf')
    ERASE lrs1_del.dbf
  EndIf

  luse('lrs1')
  luse('lrs2')

  // открыть склад тары покупателей
  netuse('cskl')
  netuse('etm')
  netuse('tmesto')
  netuse('ctov')
  netuse('mkcros')


  sele cskl
  __dbLocate(bSeekSk)

  if found()
    If cskl->TPsTPok = 2;  // стклад ТараПоку
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
         outlog(__FILE__,__LINE__,'Kpl=',nKpl,'не найден TovM')
         Return nil
       EndIf
      bWhile:={|| TovM->Skl = kplr }
    else
      DBGoTop()
      bWhile:={|| .not. eof() }
    EndIf

    // задача tovM=0, то все ktl - инвертировать, те они обнулятся
    sele TovM
    Do While  eval(bWhile)
      If kplr # TovM->Skl // смена плательщика
        If !Empty(lrs1->(LastRec()))
          // упаковка документов
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
      If int(TovM->MnTov/10000) = 0 // тара
      else
        skip; loop
      EndIf

      Do Case
      Case nMnTov = 9999999
        // берем всЕ
      Case Empty(nMnTov)
        // берем всЕ
      Case !Empty(nMnTov)
        If nMnTov = TovM->MnTov
          // берем
        else
          skip; loop
        EndIf
      EndCase

      // outlog(__FILE__,__LINE__)
      lSkip:=.F.
      Do Case
      Case Empty(nMnTov) .and. Empty(nMnTov2)
        If cskl->TPsTPok = 2;  // стклад ТараПоку
          .or. cskl->TPsTPok = 1
          If tovM->osf # 0 // пропукаем не Нулевый (нулевые обрабатываем)
            lSkip:=.t.
          EndIf
        Else // обычный склад
          // берем все
          If tovM->MnTov > 316 // какие кода пропускать
            lSkip:=.t.
          EndIf
        EndIf

        If lSkip
          dbskip(); loop
        EndIf
      Case Empty(nMnTov2)
        if nMnTov = 9999999
          // найдем по СТОВ родителя
          nMnTov2:=getfield('t1','TovM->MnTov','ctov','MnTovT')
          If Empty(nMnTov2)
            outlog(__FILE__,__LINE__,'empty MnTovT',TovM->Skl,TovM->MnTov, kplr,'TovM->Skl,TovM->MnTov, kplr')
            skip; loop
          else
            outlog(3,__FILE__,__LINE__,'родитель',nMnTov2,'nMnTov2')
            If nMnTov2 = TovM->MnTov // сам себе родитель
              If cskl->TPsTPok = 0 // для склада брак
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
              // берем всЕ
            Case !Empty(nMnTov)
              // есть желение свести на один КТЛ  skip; loop
            EndCase

          EndIf
        endif
      Case !Empty(nMnTov2)
        // указан второй код, т.е. проверки не делаем - перекидка
      EndCase

      /*    // признак кеги
      mkcrosr:=getfield('t1','TovM->MnTovT','ctov','mkcros')
      if (getfield('t1','mkcrosr','mkcros','keg')) < 30
        // skip; loop
      EndIf
      */
      outlog(3,__FILE__,__LINE__,TovM->Skl,TovM->MnTov, kplr,'TovM->Skl,TovM->MnTov, kplr')

      sele Tov
      set orde to tag t5 // skl + ktl
      if netseek('t5','tovM->Skl,tovM->MnTov')
        // создать шапку        // NNNNNNNN-NNNN-NNNN-NNNN-NNNNNNNNNNNN

        sele Tov
        Do While tovM->Skl = tov->Skl .and. tovM->MnTov = tov->MnTov
          If Tov->osf = 0
            Tov->(DBSkip())
            loop
          EndIf
          If cskl->TPsTPok = 2; // стклад ТараПоку
            .or. cskl->TPsTPok = 1
            //
          else
            //
          endif

          If lrs2->(LastRec())>nCntRecMaxLRs2 // пропускаем больше
            Tov->(DBSkip())
            loop
          EndIf
          // найти или создать строку шапки
          sele lrs1
          locate for kpl = kplr
          If !found()
            Tov->(LRs1_Add(str(nKpl,7)+';'+XTOC(nMnTov)+';'+XTOC(nMnTov2)+';'+time()+uuid(),;
             263, SkVzr, kopr, vor))
          EndIf

          nKtl1:=Tov->Ktl
          nMnTov1:=Tov->MnTov

          If Empty(nMnTov2)
            // создать строки
            outlog(3,__FILE__,__LINE__,'создать строки', Tov->MnTov, Tov->Ktl,tov->osf,'Tov->MnTov, Tov->Ktl, tov->osf')
            LRs2_Add(nMnTov1, Tov->osf, nKtl1,0, .f.)

          else // !Empty(nMnTov2) // перенос на новый кода
            MnTov2r:=nMnTov2
            //outlog(__FILE__,__LINE__, tov->(RecNo()), tov->osf,'tov->(RecNo()), tov->osf')
            // nRecTov := tov->(RecNo())
            nKtl2 := getfield('t5','tovM->Skl,MnTov2r','tov','ktl')

            If Empty(nKtl2) // переброска на родителя
              outlog(__FILE__,__LINE__,'создать строки',TovM->Skl, Tov->MnTov, Tov->Ktl, tov->osf,'TovM->Skl,Tov->MnTov, Tov->Ktl, tov->osf')
              outlog(__FILE__,__LINE__,'empty nKtl2',MnTov2r,'MnTov2r')

              If !(lKtl2) // /Ktl2=0 при задании в параметрах, то не будет удалять.
                lrs2->(DBDelete())
                Tov->(DBSkip())
                sele Tov
                loop
              EndIf

              //
            EndIf

            If nKtl1 # nKtl2
              outlog(3,__FILE__,__LINE__,'создать строки', Tov->MnTov, Tov->Ktl,tov->osf,'Tov->MnTov, Tov->Ktl, tov->osf')
              LRs2_Add(nMnTov1, Tov->osf, nKtl1,0, .f.)

              outlog(3,__FILE__,__LINE__,'инвертирование', nMnTov2, nKtl2, Tov->MnTov, tov->osf,'nMnTov2, nKtl2, Tov->MnTov, tov->osf')
              // найдем любую картоку другим КТЛ
              LRs2_Add(nMnTov2, Tov->osf, nKtl2, Tov->MnTov, .T.) // инвертирование
            EndIf

          EndIf
          sele Tov
          DBSkip()
        EndDo
        // когда не нулевой остаток, то его и сохраним
        If Empty(nMnTov2) // без переноса
          If cskl->TPsTPok = 2 ;// стклад ТараПоку
            .or. cskl->TPsTPok = 1

            If !(tovM->osf = 0)
              LRs2->kvp -= tovM->osf
            EndIf
          Else // обычный склад
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
 АВТОР..ДАТА..........С. Литовка  10-20-14 * 09:12:58pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION KegaVol(cFieldSeek)
  LOCAL nVolume
    mkcrosr:=getfield('t1',cFieldSeek,'ctov','mkcros')
    nWeight:=getfield('t1','mkcrosr','mkcros','keg')
    IF nWeight > 10 //кега
      nVolume:=nWeight
    ELSE
      nVolume:=1
    ENDIF
    IF (INT((&cFieldSeek) /10000)=0) //пустая тара (кеги)
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
 АВТОР..ДАТА..........С. Литовка  09-26-17 * 11:25:29am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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
 АВТОР..ДАТА..........С. Литовка  11-16-17 * 01:43:17pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION LRs1_Add(cDocId, Sklr, SkVzr, kopr, vor)
  DEFAULT kopr TO 108,;
  vor to 1,;  //Iif(osf>0 , 1, 9)   //возврат - 1 продажа - 9
  Sklr TO 263, SkVzr to 234

  // Sklr := 263 // брак 169
  //SkVzr := 234
  kopir := kopr// 160
  ktar := 999
  ttncr := 0 // нужны доки на тару? (0 - тара вкл в ТТН ,1-тара отдельной ТТН)

  DtRor:=Date() //дата доставки
  TimeCrtFrmr:= DTOS(date())+" "+"00:00:00"
  TimeCrtr  := TimeCrtFrmr
  DocIDr    := cDocId //str(TovM->MnTovT,7) + str(TovM->Skl,7)
  Commentr  := '' // -169
  Sumr      := 0

  kgpr := KegKgp()
  kplr := kplr

  if at('т=',Commentr) # 0 // задание на забор денег
    netrepl('ztxt',{Commentr})
  else
    netrepl('npv',{Commentr})
  endif

  lrs1->(DBGoBottom())
  ttnr:=lrs1->ttn
  If .T. .or. ttnr = 0 // одна ТТН
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
 АВТОР..ДАТА..........С. Литовка  11-16-17 * 01:50:44pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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
  nPreRec:=RecNo() // запись источник
  locate for ttn  = ttnr  .and. MnTov = MnTovr .and. ktl = ktlr
  If !found()
    netadd()
  EndIf
  // первая вседа запишится тк ограничивается к-во
  // вторая (куда), может суммироваться, проверяем
  If ABS(kvp + kvpr) >= 100000
    //DBSkip(-1)
    DBGoTo(nPreRec)
    DBDelete()
  EndIf
  // сделаем коррекцию, Первую запишив всегда, а Вторую обнулим
    netrepl('ttn,MnTov,ktl,MnTovP,zen',{ttnr,mntovr,ktlr,nMnTovP,zenr},)
    //outlog(__FILE__,__LINE__,ABS(kvp + kvpr) > 100000,ABS(kvp + kvpr), 100000)
    //outlog(__FILE__,__LINE__,kvp + kvpr,kvp, kvpr)
    netrepl('kvp',{kvp + kvpr})

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  03-26-18 * 09:12:57am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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

  gnD0k1=1 // приходы

  sele pr1

  if netseek('t2','mnr')
    gnVo := pr1->Vo // 1 - Возврат от покупателей 6-пересорт
    rcPr1r:=RECNO()

    Pr1ToMemVar()

    Autor=getfield('t1','gnD0k1,gnVu,gnVo,qr','soper','auto')
    if !inikop(gnD0k1,gnVu,gnVo,qr)
      outlog(__FILE__,__LINE__,gnD0k1,gnVu,gnVo,qr,'!inikop 4 gnD0k1,gnVu,gnVo,qr')
      RETURN (NIL)
    endif
    // Инициализация адресов по SOPER  // Назначение
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
    prNppr:=0 // признак действия с д-том
    pfakt()
    outlog(__FILE__,__LINE__,'ok',mnr,pathr)
  EndIf
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  04-11-18 * 08:44:20pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION LRsPack()

  sele lrs2
  if netseek('t1','lrs1->ttn')
    dele for kvp = 0 while ttn = lrs1->ttn // записи идут последовательно

    netseek('t1','lrs1->ttn')
    locate for !deleted() while ttn = lrs1->ttn
    // найдем не удаленные
    If !found() // все удалены

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
 АВТОР..ДАТА..........С. Литовка  04-13-18 * 09:51:58am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION SaveLrs14del()
  // сохраним шапки д-та
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
 АВТОР..ДАТА..........С. Литовка  04-13-18 * 09:06:13am
 НАЗНАЧЕНИЕ.........  тест на измение остатков в таре покуптелей.
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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
    // запись в статик
    nSumQ:=ACLONE(nSumQ1)

    nuse('_tov')
    nuse('_tovM')
  EndIf
  pathr:=l_pathr
  RETURN (NIL)



/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  07-22-18 * 08:24:24pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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
 АВТОР..ДАТА..........С. Литовка  10-20-14 * 01:44:08pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION OblnSendOne(dtEndr,cPth_Plt_tmp,cPath_Pilot)
  //имя архива с путем
          cFileNameArc:=cPth_Plt_tmp+"\"+"ob"+;
          SUBSTR(DTOS(dtEndr),3)+;
          ".zip"
          cFileArcNew:=cPath_Pilot+"\"+"ob"+;
          SUBSTR(DTOS(dtEndr),3)+;
          ".zip"
  //распаковка
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

  //копирование
  copy file (cFileNameArc) to (cFileArcNew)

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  11-06-18 * 02:47:00pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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

    If technicalc = 8 // резерв
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

    If technicalc = 8 // резерв
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
 АВТОР..ДАТА..........С. Литовка  07-14-20 * 01:53:29pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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

  // запуск приема ФТП
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
        // новая строка данных
        //outlog(__FILE__,__LINE__,'// новая строка данных)
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
        // конец строки данных
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
 АВТОР..ДАТА..........С. Литовка  11-23-18 * 12:56:06pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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
        _FIELD->A_ID := VAL(cData) //       Число        5          0
      Case '[NameAction]' $ cRezult
        // => юЙЖЁЪ МЮЖЁНМЮКЭМЮ ╧3048/рно
        _FIELD->ANAME:=cData        //Символ       40
      Case '[BeginDate]' $ cRezult
        // => 2018-10-01
        _FIELD->ABEG:=CTOD(cData,'YYYY-MM-DD')    //    Дата         8
      Case '[EndDate]' $ cRezult
        // => 2018-12-31
        _FIELD->AEND:=CTOD(cData,'YYYY-MM-DD')        //Дата         8
      Case '[TypeCode]' $ cRezult
        //  => 1
        _FIELD->ATYPE := VAL(cData)      // Число        1          0
      Case '[ActionType]' $ cRezult
       //  => МЮЖЁНМЮКЭМЮ
       _FIELD->ATNAME:=cData     //Символ       20
      Case '[Info]' $ cRezult
       // => нАНКНМЭ  йХ№БЯЭЙЕ пНГКХБМЕ 1_95
       _FIELD->NAT:=cData         //Символ       80
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
 АВТОР..ДАТА..........С. Литовка  11-23-18 * 02:07:02pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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
        _FIELD->A_ID := VAL(cData) //       Число        5          0
      Case '[localproductCode]' $ cRezult  //        => 3410918
        _FIELD->MNTOV := VAL(cData)       //Число        7          0
      Case '[localproductname]' $ cRezult  //        => 3410918
        _FIELD->NAT     := cData //Символ       80
      Case '[product_id]' $ cRezult //     => 21089
        _FIELD->P_ID := VAL(cData) //       Число        6          0
      Case '[ProductName]' $ cRezult // => Пиво "Київське розливне" 1.95л ПЕТ
        _FIELD->PNAME   := cData //Символ       80
      Case '[Volume_L]' $ cRezult  //  => 1.95
        _FIELD->VOL     := VAL(cData) //Число        8          3
      Case '[Price]' $ cRezult  //    => 26.3
        _FIELD->PRICE   := VAL(cData) //Число        10         2
      Case '[Price_Char]' $ cRezult //   => 26.30
        _FIELD->PRICE_C := VAL(cData) //Число        10         2
      Case '[Price_L]' $ cRezult  //    => 26.3
        _FIELD->PRICE_L   := VAL(cData) //Число        10         2
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
 АВТОР..ДАТА..........С. Литовка  11-23-18 * 02:33:28pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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
        _FIELD->A_ID := VAL(cData) //       Число        5          0
      Case '[OL_id]' $ cRezult    //=> 5175
        _FIELD->OL_id := VAL(cData) //       Число        5          0
      Case '[OL_Code]' $ cRezult // =>
        _FIELD->OL_Code  := cData //Символ       80
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
 АВТОР..ДАТА..........С. Литовка  11-26-18 * 11:34:31am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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
 АВТОР..ДАТА..........С. Литовка  12-03-18 * 12:56:20pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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
 АВТОР..ДАТА..........С. Литовка  12-03-18 * 08:47:32pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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
  { 'НомерДок', 'order_no', {|cData|val(cData)}},;
  { 'ДатаДок', 'order_date', {|cData|CTOD(cData,'YYYY-MM-DD')}},; // ???????????????формат
  { 'ВремяДок', 'dtlm', {|cData| DTLM(order_date,cData)}},; //  ----------------------
  { 'КодТЗ', 'merch_id', {|cData|val(cData)}},; //
  { 'КодТРТ', 'ol_code', {|cData|cData}},; //
  { 'ВидТорговли', 'op_code', {|cData|cData}},; //
  { 'КодСклада', 'wareh_code', {|cData|cData}},; //
  { 'КодКатегорииЦен', 'payform_id', {|cData|val(cData)}},; //
  { 'ЭтоВозврат', 'isreturn', {|cData|val(cData)}},; //
  { 'Комментарий', 'comment', {|cData|cData}},; //
  { 'OrderExecutionDate', 'exec_date', {|cData|CTOD(cData,'YYYY-MM-DD')}},; //  ???????????????формат
  ;//{ 'Контрагент', '', {| cData|cData}},; //  -------------------
  { 'АдресДоставки', 'deliv_addr', {|cData|cData}}; //
  ;//{ 'КодЕДРПОУ', '', {|cData|cData}},; //  ------------------------
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


  // детели заявки
  aReadData:={;
   { 'НомерДок', 'order_no', {|cData|VAL(cData)}};
  ,{ 'КодТовара', 'localcode', {|cData|cData}};
  ,{ 'Количество', 'qty', {|cData|VAL(cData)}};
  ,{ 'Цена', 'price', {|cData|VAL(cData)}};
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
 АВТОР..ДАТА..........С. Литовка  04-29-19 * 07:56:17pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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
    FieldPut(1,FieldGet(1)) // для обновления
    // открыти данных для добавления
    USE (cPth_Plt_tmp+"\" + cDbf + '.dbf') ALIAS (cDbf+'_1') NEW
    // связь с иточнимом
    dbSetRelat(cDbf, bSetRela2) //, aFileSend[k,3])
    // копирование тех, которых нет -> tmpadd
    copy to ('_'+cDbf) for (cDbf)->(!found())
    // copy to tmp!add for (aFileSend[k,1])->(found())

    CLOSE (cDbf+'_1')

    SELE (cDbf)
    APPEND FROM ('_'+cDbf)

    CLOSE (cDbf)

  EndIf

  If lErr
    // сообщение о пустой базе
      //cMessErr:="Нет данных для таблицы "+(cPath_Order+'\'+cDbf+'.dbf');
      cMessErr:="Нет данных для таблицы "+cDbf+'.dbf';
      +" "+DTOC(DATE(),"YYYYMMDD")+"-"+TIME()
       SendingJafa(;
       "l.gupalenko@ukr.net,lista@bk.ru",;
       {{ '',;
        translate_charset(host_charset(),"utf-8",;
        cMessErr);
        }},;
      cMessErr+chr(10)+chr(13)+'Данные не обновлены.',;
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

  //список, что дал СВЕ
  sele swe
  go top
  while (!eof())
    Pos_Idr=pos_id
    PosTpIdr=allt(str(pos_id,7))
    invr=allt(str(inv))

    // обрудование у Лодиса
    sele sbar
    set order to 1
    seek PosTpIdr // множественное повторение
    If found()

      whr := 2029 // - сумы
      If "-К " $ sbar->Nat
        whr := 7732 // - конотоп
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

          // резльтирующая БД
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
      // нет данных в Лодисе
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
  //список, что дал СВЕ
  sele swe
  go top
  while (!eof())
    Pos_Idr=pos_id
    PosTpIdr=allt(str(pos_id,7))
    invr=allt(str(inv))

    sele sbar
    set order to 1
    seek PosTpIdr // одни раз повторяется
    if (found())

      whr := 2029 // - сумы
      If "-К " $ sbar->Nat
        whr := 7732 // - конотоп
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
        // нет данных в Лодисе
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
 АВТОР..ДАТА..........С. Литовка  08-22-19 * 06:01:40pm
 НАЗНАЧЕНИЕ......... обновляет переменную MnTovr с обычного товара на MnTov
                     акционную
 ПАРАМЕТРЫ.......... MnTovr, kplr, kgpr DtRor - должные быть определены перевызовом ф-ци
                     MnTovr - не должен быть Акционным
 ВОЗВР. ЗНАЧЕНИЕ.... измененный MnTovr
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Act_MnTov4_MnTov()
  //para MnTovr, kplr, kgpr
  // получить список БарКод
  LOCAL nPos, aMnTov, lRet
  aMnTov:={}
  AADD(aMnTov,MnTovr)
  IF .T.
    MnTovTr=getfield('t1','mntovr','ctov','MnTovT') // родитель
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
      outlog(3,__FILE__,__LINE__,'  // нашли акц ,A_Idr,ANamer,ATyper',A_Idr,allt(ANamer),ATyper)
      outlog(3,__FILE__,__LINE__,'  // Nat', A_Nat)

      If "5+1" $ A_Nat
        outlog(3,__FILE__,__LINE__,'  // 5+1 -> должен выписаться обычный товар')
        loop
      EndIf

      nPos:=AT('/',ANamer)
      If Atyper=3
        nPos:=0
      EndIf
      outlog(3,__FILE__,__LINE__,"  nPos:=AT('/',ANamer)",nPos)

      If EMPTY(nPos)
        outlog(3,__FILE__,__LINE__,'  // нашли акцию без "/" ',allt(str(mntovr)),A_Idr,ANamer)
        // проверка на уникальность акций
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
          outlog(3,__FILE__,__LINE__,'  // нашли акцию ',mntovr,cTypeAktc,A_Idr,ANamer)
          AADD(aAktcTov,{mntovr,getfield('t1','mntovr','ctov','NaT'),A_Idr, ANamer, ATyper})
        EndIf
      EndIf

      //exit
    Else
    EndIf
  Next k

  If empty(aAktcTov) // нет Акц. товар
    // проверим чтобы не выписами Акц товар.
    mntovr:=0 // нет обычного товара
    nPos:=AScan(aMnTov,{|nMnTov| mntovr:=nMnTov, .not. ('АКЦ' $ UPPER(getfield('t1','mntovr','ctov','NaT'))) })
    If !Empty(nPos)
      mntovr:=aMnTov[nPos] // обычный товар
    EndIf
    outlog(3,__FILE__,__LINE__,'  // нет Акц.тов',mntovr)
    lRet:=.F.
  else

    If len(aAktcTov) = 1 // один код
      nPos=99999
      /*
      // найдем Акц  с "/"
      Do Case
      Case aAktcTov[1, 5] = 3 //AType
        nPos=AScan(aAktcTov,{|aElem| ('/' $ aElem[4]) })
      Case aAktcTov[1, 5] = 2 // Акция без "/"
        nPos=99999
        If "мережева" $ aAktcTov[1, 4] //AName
          nPos:=0 // обычный товар
        EndIf
      OtherWise
        nPos=AScan(aAktcTov,{|aElem| ('/' $ aElem[4]) })
      EndCase
      */
      If "мережева" $ aAktcTov[1, 4] //AName
        nPos:=0 // обычный товар
      EndIf

      If Empty(nPos) // без "/" Акция
        mntovr:=0 // нет обычного товара
        nPos:=AScan(aMnTov,{|nMnTov| mntovr:=nMnTov, .not. ('АКЦ' $ UPPER(getfield('t1','mntovr','ctov','NaT'))) })
        mntovr:=0 // нет обычного товара
        If !Empty(nPos)
          mntovr:=aMnTov[nPos] // обычный товар
        EndIf
        outlog(3,__FILE__,__LINE__,'  // MnTov not. АКЦ',mntovr,nPos)
      Else
        mntovr:=aAktcTov[1,1]
        outlog(3,__FILE__,__LINE__,'  // Акц.тов один код',mntovr)
      EndIf
      lRet:=.T.
    Else // больше 1-го

      outlog(3,__FILE__,__LINE__,'  // Акц.тов > 1-го',mntovr)
      AEVAL(aAktcTov,{|aElem| outlog(3,__FILE__,__LINE__, aElem) })

      nPos=AScan(aAktcTov,{|aElem| .not. ('/' $ aElem[4]) })
      outlog(3,__FILE__,__LINE__,nPos,'aAktcTov .not. слеш')
      If Empty(nPos)
        mntovr:=0 // нет обычного товара
        nPos:=AScan(aMnTov,{|nMnTov| mntovr:=nMnTov, .not. ('АКЦ' $ UPPER(getfield('t1','mntovr','ctov','NaT'))) })
        mntovr:=0 // нет обычного товара
        If !Empty(nPos)
          mntovr:=aMnTov[nPos] // обычный товар
        EndIf
        outlog(3,__FILE__,__LINE__,nPos,'  MnTov not. АКЦ',mntovr)
        lRet:=.F.

      Else
        mntovr:=aAktcTov[nPos,1]
        lRet:=.T.
      EndIf
      outlog(3,__FILE__,__LINE__,'  // Акц.тов > 1-го',mntovr)

    EndIf

  EndIf

  outlog(3,__FILE__,__LINE__,'=End')
  Return  lRet

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  11-27-18 * 05:01:35pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ.......... lRetNotAct - что возращать если товар НЕ Акция
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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
  If DBSEEK(str(nl_MnTov,7)) // товар есть в списке акций
    if 'АКЦ' $ UPPER(a_prod->Nat)
      lAkc:=.T.
      outlog(3,__FILE__,__LINE__, "  // товар Акц - 'АКЦ' $ UPPER(a_prod->Nat)")
    else
      lRet:=lRetNotAct
      If lRet
        outlog(3,__FILE__,__LINE__, "  //товар не Акц можно обрабатывать Переоценка")
      Else
        outlog(3,__FILE__,__LINE__, "  //товар не Акц !('АКЦ' $ a_prod->Nat)")
      EndIf
      RETURN (lRet) //
    Endif
  else
    outlog(3,__FILE__,__LINE__, " НЕТ товара в списке акций")
  Endif

    //.and. ('АКЦ' $ UPPER(a_prod->Nat).)
  If lAkc
    sele a_tt
    cOl_code:=ltrim(STR(nl_kgp,7)+"-"+STR(nl_kpl,7)) // удалены выдущие пробелы
    If DBSeek(cOl_code)
      // ТТ список c Ном. Акциями
      DO WHILE ol_code = cOl_code
        // поиск Ном акции
        nA_Id:=a_tt->A_Id

        sele a_idAct // таблица Акций, в которых участвует ТТ
        If DBSeek(str(nA_id,5))
          cAName:=a_idAct->AName
          cA_Nat:=a_idAct->Nat
          nAType:=a_idAct->AType

          //If iif(dDate = DATE(),.T.,dDate >= ABeg)  .AND. dDate <= AEnd
          If dDate >= ABeg .AND. dDate <= AEnd

            sele a_prod
            ordsetfocus('t1')
            If DBSEEK(str(nl_MnTov,7)+str(nA_id,5)) // товар есть в списке акций

              lRet:=.T.
              exit
            Else
              AADD(aMess,__LINE__;
              +' AKC=>TT нет 4 Товара в а-ции a_id='+str(nA_Id,5);
            )
            EndIf
          Else

            If dDate = DATE()
              AADD(aMess,__LINE__;
              +' AKC=>а-ция не в сроках a_id='+str(nA_Id,5);
              +' '+DTOC(ABeg)+' '+DTOC(AEnd);
              +' '+DTOC(dDate))
            Else
              AADD(aMess,__LINE__;
              +' AKC=>а-ция не в сроках a_id='+str(nA_Id,5);
              +' '+DTOC(ABeg);
              +' '+DTOC(AEnd)+' '+DTOC(dDate))
            EndIf
          EndIf
        Else
          AADD(aMess,__LINE__;
          +' AKC=>а-ции нет a_id='+str(nA_Id,5))
        EndIf

        sele a_tt
        DBSkip()
      ENDDO
    ELSE
      AADD(aMess,__LINE__ ;
      +' !!!AKC=>а-ций нет для ТТ',cOl_code)

    ENDIF
  ELSE
    lRet:=lRetNotAct
  ENDIF

  If !lRet .and. len(aMess) > 1
    sele a_prod
    ordsetfocus('t1')
    DBSEEK(str(nl_MnTov,7)) // товар есть в списке акций
    outlog(3,__FILE__,__LINE__,'Error AKC=>TT',str(nl_MnTov,7)+' '+a_prod->Nat)
    outlog(3,__FILE__,__LINE__,'  '+DTOC(dDate) +' '+cOl_code)
    //outlog(3,__FILE__,__LINE__,' ',aMess)
    AEval(aMess,{|cMess| outlog(3,__FILE__,__LINE__, "  "+cMess) },2)
    outlog(3,__FILE__,__LINE__, "")
  EndIf
  RETURN (lRet)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  07-14-20 * 01:58:51pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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
 АВТОР..ДАТА..........С. Литовка  07-14-20 * 03:45:30pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
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
 АВТОР..ДАТА..........С. Литовка  07-17-20 * 09:54:23am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ.... вставка данных
 ПРИМЕЧАНИЯ.........
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
  // 9 - стату для тех, которых нет в АрхивеОстатков

  If !Empty(select("LPOSARCH"))
    SELE LPOSARCH
    OrdSetFocus('t3')
    SELE LOCALPOS
      /*
              Status  Numeric 11      Статус (2 - 'активный', 9 - 'неактивный')
      По умолчанию - 2        Да
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
