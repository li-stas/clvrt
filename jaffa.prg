#include 'directry.ch'
#include 'common.ch'

#translate  NTRIM(< v1 >) => LTRIM(STR(< v1 >))
#define _T ";" //CHR(9)
//#define JF_SKIPMNTOV (mntovt >= 10^6)
#define JF_SKIPMNTOV (int(MnTovT/10000)>2)
STATIC lTATT:=.T.

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  05-12-14 * 03:33:43pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION djaffa()
  LOCAL lJoin:=.F., nNmOst
  if .T.
    dtBegr:=dtEndr:=DATE()

    IF (UPPER("/get-date") $ UPPER(DosParam()))
      IF DAY(DATE())<7
        dtBegr:=BOM(ADDMONTH(date(),-1))
        dtEndr:=EOM(ADDMONTH(date(),-1))
      ELSE
        dtBegr:=BOM(date())
        dtEndr:=EOM(date())
      ENDIF

      clvrt_get_date(@dtBegr,@dtEndr,;
      "Подготовка отчета JAFFA данных за месяц",;
      "(даты могут быть любыми отчетного месяца)",;
      {|a1,a2| a1<=a2 .and. (BOM(a1)=BOM(a2)) };
    )

      IF LASTKEY()=13
        set device to print
        set print to clvrt.log ADDI

        gdTd:=BOM(dtBegr)
        dtBegr:=BOM(dtBegr)
        dtEndr:=EOM(dtEndr)
        cLineDateSet := ;
        '/gdTd' +DTOS(gdTd) + ;
        ' /dtBeg'+DTOS(dtBegr) + ;
        ' /dtEnd'+DTOS(dtEndr)

        cLineOsfonDateSet := ;
        '/gdTd' +DTOS(gdTd) + ;
        ' /dtBeg'+DTOS(dtBegr) + ;
        ' /dtEnd'+DTOS(dtBegr)

        set console off
        set print on
        set print to app_jaffa.exe

        ??'#!/bin/sh'
        ?'umask 002'
        ?
        ?'APP_CLVRT="/usr/bin/app_clvrt"'
        ?'$APP_CLVRT /jafa /support \'
        ?cLineDateSet
        ?

        ?'$APP_CLVRT /-jafa  /osfon /no_mkotch \'
        ?cLineOsfonDateSet
        ?

        ?'$APP_CLVRT /-jafa  /no_mkotch \'
        ?cLineDateSet
        ?
        ?'$APP_CLVRT  /RptJafa \'
        ?cLineDateSet
        ?
        ?'exit 0'
        set print to
        set print off

         cLogSysCmd:=""
         SYSCMD("cat ./app_jaffa.exe| tr -d '\r'>app_jaffa.sh","",@cLogSysCmd)
         cLogSysCmd:=""
         SYSCMD("chmod +x ./app_jaffa.sh","",@cLogSysCmd)

         QUIT

      ELSE
        ERRORLEVEL(1)
        RETURN
      ENDIF
    ELSE
      lJoin:=(UPPER("/join") $ UPPER(DosParam()))

      // передача всего месяца
      IF UPPER("/FlMn") $ cDosParam
        gdTd:=BOM(DATE())
        dtBegr:=BOM(DATE())
        IF UPPER("/osfon") $ cDosParam
          dtEndr:=BOM(DATE())
        ELSE
          dtEndr:=DATE() //EOM(DATE())
        ENDIF
      ENDIF

      IF UPPER("/dtBeg") $ cDosParam ;
        .OR. UPPER("/FlMn") $ cDosParam

        Dt_Beg_End(cDosParam,.T.,@dtBegr,@dtEndr)

        IF !(UPPER("/no_mkotch") $ UPPER(DosParam()))
          FOR dMkDt:=dtBegr TO dtEndr
            Do Case
            Case dMkDt=BOM(dMkDt)
              // 0 - по ост прошл дня
              // 1 - остаток факт OSN минус Выписанный (для старта)
              // 2 - по ост прошл дня с корр прих kop=211
              // 3 - ??? остаток факт OSN
              nNmOst:=2
              If UPPER("/OsFoN") $ cDosParam
                nNmOst:=kta_DosParam(cDosParam,'/OsFoN=',1,{1,{0,1,2}})
              EndIf
              mkotchd(dMkDt,102,  nNmOst, .F.) // 'No_executed_order')
            OtherWise
              // 0 - по ост прошл дня
              // 2 - по ост прошл дня с корр прих kop=211
              nNmOst:=2
              If UPPER("/OsTD") $ cDosParam
                nNmOst:=kta_DosParam(cDosParam,'/OsTD=',1,{0,{0,2}})
              EndIf
              mkotchd(dMkDt,102,  nNmOst, .F.) // 'No_executed_order')

            EndCase
          NEXT
          quit
        ENDIF

      ELSE

        dtBegr:=date()-1
        dtEndr:=date()-1

        If .F. // 08-07-18 11:23am - не передаем
          DO CASE
          CASE dtEndr = EOM(dtEndr) // последний день месяца
            dtBegr:=BOM(dtEndr)     // начинем с начала месяца
            lJoin:=.T.

          CASE DOW(dtEndr) = 1      // отчет за воскресенье
            dtBegr:=dtEndr-6        // с понедельника
            lJoin:=.T.

          ENDCASE
        EndIf
        // объединненное не предаем         lJoin:=.F.

      ENDIF
    ENDIF

    IF !(UPPER("/no_mkotch") $ UPPER(DosParam()))
      //mkotchn_Range(102,@dtBegr,@dtEndr,cDosParam)
      //mkkplkgp(102,nil)
      //
      //mkotchn(dtBegr,102,NIL,1,dtEndr) //,{||.T.}) //1 все склады
      mkkplkgp(102,nil)

      IF dtEndr=BOM(dtEndr)  .AND. UPPER("/osfon") $ cDosParam
        mkotchd(dtEndr,102,2,'No_executed_order')
      ELSE
        mkotchd(dtEndr,102,(NIL,2),'No_executed_order')
      ENDIF

      outlog(__FILE__,__LINE__,"/jafa","mkotchn_Range(102",dtBegr,dtEndr,cDosParam)
      IF .T. .OR.  dtEndr = EOM(dtEndr) .OR. (UPPER("/sbarost") $ UPPER(DosParam()))
        // последний день месяца
        sbarost(102)
      ENDIF
      DELETEFILE("mkpr.*")
      DELETEFILE("mkrs.*")
      DELETEFILE("mkost.*")

    ENDIF

  else
    dtEndr:=date()-1
  endif


  //сбокра на период расхода и приход в одни файл.
  //остаток последний
  IF lJoin
    JoinMkDt(102,dtBegr, dtEndr)
    dt_Begr:=dtEndr
    dt_Endr:=dtEndr
  ELSE
    dt_Begr:=dtBegr
    dt_Endr:=dtEndr
    //dtEndr :=dtBegr
  ENDIF

     netuse('cskl');   set index to
     netuse('s_tag')
     netuse('kgp')
     netuse('kgpcat')
     netuse('krn')
     netuse('knasp')
     netuse('kln')
     netuse('mkeepe')
     netuse('klnnac')
     netuse('klndog')
     netuse('sv','svjafa')


   aRmDep:=List_aRmDep()

    IF !(UPPER("/osfon") $ UPPER(DosParam()))
      // 10-02-17 03:57pm отключили F
      IF .T. .AND.  DOW(dtEndr) = 1 ; //отчет за воскресенье
        .OR. (dtEndr = EOM(dtEndr) .AND. dtBegr = BOM(dtEndr)) // месяц
        // J afaReport(-1,NIL,lJoin,dtEndr,"real.prodresurs@mail.ru,lista@bk.ru,spr.jaffa@gmail.com")
      ENDIF
    ENDIF

  FOR dMkDt:=dt_Begr TO dt_Endr
    IF .NOT. lJoin
      mkdt(dMkDt,102)
    ENDIF

     netuse('cskl');   set index to
     netuse('s_tag')
     netuse('kgp')
     netuse('kgpcat')
     netuse('krn')
     netuse('kulc')
     netuse('knasp')
     netuse('kln')
     netuse('ctov')
     netuse('mkeepe')
     netuse('klnnac')
     netuse('klndog')
     netuse('sv','svjafa')

     IF UPPER("/support") $ UPPER(DosParam())
       JafaSpod2D(dMkDt,'lista@bk.ru) // ,hellen@pradata.com')
       //return

       FOR i:=1 TO LEN(aRmDep)
         exit
         //outlog(__FILE__,__LINE__,aRmDep[i])
         JafaReport(aRmDep[i],NIL,lJoin,dMkDt,"lista@bk.ru")
         //JafaXmlReport(aRmDep[i],NIL,lJoin,dMkDt,"lista@bk.ru")
       NEXT i

       //JafaReport(-1,NIL,lJoin,dMkDt,"lista@bk.ru")
     ELSE

      IF dMkDt = BOM(dMkDt) //первый день месяца передаем, остатки на нач. мес
        FOR i:=1 TO LEN(aRmDep)
          //outlog(__FILE__,__LINE__,aRmDep[i])
          JafaReport(aRmDep[i],"/osfon",lJoin,dMkDt,"distrsales@vitmark.com,lista@bk.ru,spr.jaffa@gmail.com")
        NEXT i
      ENDIF

      FOR i:=1 TO LEN(aRmDep)
        outlog(3,__FILE__,__LINE__,aRmDep[i])
        JafaReport(aRmDep[i],NIL,lJoin,dMkDt,"distrsales@vitmark.com,lista@bk.ru,spr.jaffa@gmail.com")
      NEXT i

      If !Empty(SELECT('mkdoc'))
        CLOSE mkdoc
      EndIf

      If dt_Begr = dt_Endr // за одни день
        If dMkDt <= (date()-1) // систаема не принимает данные сего дня и будущие.
          JafaSpod2D(dMkDt,'lista@bk.ru') // +',hellen@pradata.com') //
        EndIf
      EndIf

    ENDIF

   NEXT dMkDt

   nuse('krn')
   nuse('knasp')
   nuse('kgpcat')
   nuse('kgp')
   nuse('s_tag')
   nuse('kln')
   nuse('ctov')
   nuse('cskl')
   nuse('svjafa')

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  05-27-14 * 11:25:29am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION JoinMkDt(nMk,dtBegr, dtEndr)
  LOCAL cMk:= PADL(ALLTRIM(STR(nMk)),3,'0')

  //сбокра на период расхода и приход в одни файл.
  FOR dMkDt:=dtBegr TO dtEndr
    mkdt(dMkDt,nMk)
    IF dMkDt=dtBegr
       USE ("mkpr"+cMk) NEW
       COPY STRU TO ("TmpIm"+cMk)
       CLOSE ("mkpr"+cMk)
       USE ("TmpIm"+cMk) NEW

       USE  ("mkdoc"+cMk) NEW
       COPY STRU TO ("TmpEx"+cMk)
       CLOSE ("mkdoc"+cMk)
       USE ("TmpEx"+cMk) NEW

       USE  ("mktov"+cMk) NEW
       COPY STRU TO ("TmpOs"+cMk)
       CLOSE ("mktov"+cMk)
       USE ("TmpOs"+cMk) NEW

    ENDIF
    SELE ("TmpIm"+cMk)
    APPEND FROM ("mkpr"+cMk)
    SELE ("TmpEx"+cMk)
    APPEND FROM ("mkdoc"+cMk)
    SELE ("TmpOs"+cMk)
    APPEND FROM ("mktov"+cMk)
  NEXT
  CLOSE ("TmpIm"+cMk)
  CLOSE ("TmpEx"+cMk)
  CLOSE ("TmpOs"+cMk)

  USE ("mkpr"+cMk) NEW EXCLUSIVE
  ZAP
    APPEND FROM ("TmpIm"+cMk)
  CLOSE ("mkpr"+cMk)

  USE ("mkdoc"+cMk) NEW EXCLUSIVE
  ZAP
    APPEND FROM ("TmpEx"+cMk)
  CLOSE ("mkdoc"+cMk)
  USE ("mktov"+cMk) NEW EXCLUSIVE
  ZAP
    APPEND FROM ("TmpOs"+cMk)
  CLOSE ("mktov"+cMk)
  RETURN (NIL)




/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  04-26-18 * 02:39:05pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION JafaSpod2D(dMkDt,cListEmail)
  // LOCAL cListNoSaleSk:="254 256 255 "+STR(ngMerch_Sk241,3)
  // LOCAL cListNoSaleSk:="254;256;255;"+STR(ngMerch_Sk241,3)
  LOCAL cListNoSaleSk:="256;255;"+STR(ngMerch_Sk241,3)
  JafaDataConv4Spod2D(dMkDt,cListNoSaleSk)

  Jafa2CsvSpod2D(dMkDt,cListNoSaleSk,cListEmail)

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  09-07-18 * 09:32:10am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION Jafa2CsvSpod2D(dMkDt,cListNoSaleSk,cListEmail)
  LOCAL nVat:=20
  LOCAL n_Sk, nQt, dDt, cIdDistr_Ot, cIdDistr_2
  LOCAL aId, i, k, m, a_nKvp
  LOCAL cMark:='102', cFilePef:='vitmark'
  LOCAL lUpLoad, adMkDt // массив дат отчета
  LOCAL aAliasClose:={}
  LOCAL aListMnTov

  If select('kln')=0
    // для закрытия
    netuse('kln');    aadd(aAliasClose,'kln')
    netuse('kgp');    aadd(aAliasClose,'kgp')
    netuse('kgpcat'); aadd(aAliasClose,'kgpcat')
    netuse('krn');    aadd(aAliasClose,'krn')
    netuse('kulc');   aadd(aAliasClose,'kulc')
    netuse('knasp');  aadd(aAliasClose,'knasp')
    netuse('s_tag');  aadd(aAliasClose,'s_tag')
    netuse('ctov');   aadd(aAliasClose,'ctov')
  EndIf


  If IsArray(dMkDt)
    adMkDt:=ACLONE(dMkDt)
    dMkDt:=dMkDt[1]
  Else
    adMkDt:={dMkDt,dMkDt}
  EndIf

  set("PRINTER_CHARSET","cp1251")
  //set("PRINTER_CHARSET","koi8-u")
  SET DATE FORMAT "DD.MM.YYYY" //"yyyy-mm-dd"
  SET CENTURY ON

// оборота продукции delivery.csv
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO delivery.csv
  i:=0
    cLine:=;
    'id дистрибьютора'+_T+;
    'Код клиента ERP'+_T+;
    'Дата'+_T+;
    'Код продукта дистрибьютора'+_T+;
    'Количество'+_T+;
    'Сумма отгрузки'+_T+;
    'Код ТА'+_T+;
    'Номер расходной накладной'+_T+;
    'Номер заказа 2R'
    QQOUT(cLine); i++

  sele mkDeliv
  DBGoTop()
  Do While !mkDeliv->(eof())
    nZen:=;
    IIF(mkDeliv->KOp=177, 0, mkDeliv->zen) //zenn - расчетаная, zen- c ТТН

    cLine:=;
        IdDistrJaffa(_FIELD->Sk)+_T+; //Код дистрибьютора в системе SPOT 2D
        KodDistrJaffa(mkDeliv->kpl,mkDeliv->kgp)+_T+; // код клиента
        dtoc(mkDeliv->dttn)+_T+; // дата отгрузки
        ltrim(str(mkDeliv->mntovt))+_T+;  //Код SKU в системе дистрибьютора
        LTRIM(str(mkDeliv->kvp))+_T+; ///  Размер отгрузки в штуках
        LTRIM(str(;
               mkDeliv->kvp * round(nZen * 1.2,2),;
                     15,2))+_T+;//Стоимость единицы в грн (с НДС)
        PADL(LTRIM(STR(mkDeliv->kta)),4,"0")+_T+; // Код ТА в системе дистрибьютора
        LTRIM(str(mkDeliv->ttn,6))+_T+; // номер ТТН
        IIF(empty(mkDeliv->DocGuId),GUID_KPK("F",ALLTRIM(LTRIM(STR(mkDeliv->SK))+PADL(LTRIM(STR(mkDeliv->TTN)),7,"0"))),mkDeliv->DocGuId)


    iif(i=0,QQOUT(cLine),QOUT(cLine)); i++
    mkDeliv->(DBSkip())
  EndDo

  If .T. .AND.  (i < 2 .or. dMkDt # date()-1)

    sele kta
    locate for kta=0
    If !found()
      DBAppend()
      repl sk with 228
      DBAppend()
      repl sk with 400

    EndIf

    // однин заголовок или в отчете нет последней даты
    mkTov->(DBGoTop())
    aId:={'50','51'}
    For k:=1 To 2
      cTTn:=aId[k]+DTOS(date()-1)
      cOrd:=aId[k]+DTOS(date()-1)
      a_nKvp:={1,-1}
      For m:=1 To LEN(a_nKvp)
        nKvp:=a_nKvp[m]
        cLine:=;
          aId[k]+_T+; //Код дистрибьютора в системе SPOT 2D
          KodDistrJaffa(20034,22012)+_T+; // код клиента
          dtoc(date()-1)+_T+; // дата отгрузки
          ltrim(str(mkTov->mntovt))+_T+;  //Код SKU в системе дистрибьютора
          LTRIM(str(nKvp,2))+_T+; ///  Размер отгрузки в штуках
          LTRIM(str(;
                 nKvp * round(mkTov->cenPr * 1.2,2),;
                       15,2))+_T+;//Стоимость единицы в грн (с НДС)
          PADL(LTRIM(STR(0,1)),4,"0")+_T+; // Код ТА в системе дистрибьютора
          cTTn + _T+; // номер ТТН
          cOrd
        iif(i=0,QQOUT(cLine),QOUT(cLine)); i++
      next m
    next k
  EndIf
  QOUT('')

  SET PRINT TO
  SET PRINT OFF


// остатки продукции stocks.csv
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO stocks.csv
  i:=0
    cLine:=;
    'id дистрибьютора'+_T+;
    'Дата'+_T+;
    'Код продукта дистрибьютора'+_T+;
    'Количество'
  QQOUT(cLine); i++ ;

  aListMnTov := {}
  Aadd(aListMnTov,"0000000"+"20200601")
  sele mkTov // остатки под дням
  DBGoTop()
  Do While !mkTov->(eof())
    If OsfO < 0
      mkTov->(DBSkip())
      loop
    EndIf

    nQt:=mktov->osfo
    dDt:=mktov->Dt
    If dMkDt = BOM(dMkDt) // первое число
      If UPPER("/osfon") $ UPPER(DosParam())
        // nQt:=mktov->osfon
        // dDt:=dMkDt-1
      EndIf

    EndIf

    sele mkTov // остатки под дням

    cIdDistrJaffa := IdDistrJaffa(_FIELD->Sk)
    Do Case
    Case cIdDistrJaffa = '51'
      cLineStocks(@i, cIdDistrJaffa, nQt, dDt)

    Case cIdDistrJaffa = '50'
      // первым должен выводится этот склад
      If Empty(ASCAN(aListMnTov,str(_FIELD->MnTov)+DTOS(dDt)))
        Aadd(aListMnTov,str(_FIELD->MnTov)+DTOS(dDt))
        cLineStocks(@i, cIdDistrJaffa, nQt, dDt)
      EndIf

    Case cIdDistrJaffa = '122'
      cLineStocks(@i, cIdDistrJaffa, nQt, dDt)

      If Empty(ASCAN(aListMnTov,str(_FIELD->MnTov)+DTOS(dDt)))
        Aadd(aListMnTov,str(_FIELD->MnTov)+DTOS(dDt))

        cIdDistrJaffa := '50'

        mkTov->(;
        nRecNo:=RecNo(),DBGoBottom(),DBSkip(-1),;
        nQt := mktov->osfo,;
        DBGoTo(nRecNo);
        )

        cLineStocks(@i, cIdDistrJaffa, nQt, dDt)
      EndIf

    EndCase

    mkTov->(DBSkip())
  EndDo

  If .T. .AND.  (i < 2 .or. dMkDt # date()-1)
    // однин заголовок или в отчете нет последней даты
    mkTov->(DBGoTop())
    aId:={'50','51','122'}
    For k:=1 To 2
      cLine:=;
          aId[k]+_T+;//Код дистрибьютора в системе SPOT 2D
          dtoc(date()-1)+_T+;
          allt(str(mkTov->MnTov))+_T+;
          allt(str(0))

      iif(i=0,QQOUT(cLine),QOUT(cLine)); i++
    next k
  endif

  //QOUT('')
  SET PRINT TO
  SET PRINT OFF

  // close mkTov - поже закроем

// приход дистрибьютора receive.csv
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO receive.csv
  i:=0
    cLine:=;
    'id дистрибьютора'+_T+;
    'Дата'+_T+;
    'Код продукта дистрибьютора'+_T+;
    'Количество'+_T+;
    'Номер накладной'
    QQOUT(cLine); i++
  sele mkReceiv
  DBGoTop()
  Do While !mkReceiv ->(eof())

    cLine:=;
        IdDistrJaffa(_FIELD->Sk)+_T+; //Код дистрибьютора в системе SPOT 2D
        dtoc(mkReceiv->dttn)+_T+; // дата прихода
        ltrim(str(mkReceiv->mntovt))+_T+;  //Код SKU в системе дистрибьютора
        LTRIM(str(mkReceiv->kvp))+_T+; ///  Размер отгрузки в штуках
        LTRIM(str(mkReceiv->ttn,6)) // номер ТТН


    iif(i=0,QQOUT(cLine),QOUT(cLine)); i++
    mkReceiv ->(DBSkip())
  EndDo

  If .T. .AND.  (i < 2 .or. dMkDt # date()-1)
    // однин заголовок или в отчете нет последней даты
    mkTov->(DBGoTop())
    aId:={'50','51','122'}
    For k:=1 To 2
      a_nKvp:={1,-1}
      For m:=1 To LEN(a_nKvp)
        nKvp:=a_nKvp[m]
        cTTn:=aId[k]+DTOS(date()-1)
        cLine:=;
          aId[k]+_T+; //Код дистрибьютора в системе SPOT 2D
            dtoc(date()-1)+_T+; // дата прихода
            ltrim(str(mkTov->mntovt))+_T+;  //Код SKU в системе дистрибьютора
            LTRIM(str(nKvp,2))+_T+; ///  Размер отгрузки в штуках
            cTTn // номер ТТН
        iif(i=0,QQOUT(cLine),QOUT(cLine)); i++
      Next m
    next
  EndIf

  QOUT('')
  SET PRINT TO
  SET PRINT OFF

// Описание файла с другими операциями cancellations.csv
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cancellations.csv
  i:=0
    cLine:=;
    'id дистрибьютора'+_T+;
    'Дата'+_T+;
    'Код продукта дистрибьютора'+_T+;
    'Количество'+_T+;
    'Номер документа'
    QQOUT(cLine); i++

  sele mkCance
  DBGoTop()
  Do While !mkCance->(eof())
    cLine:=;
        IdDistrJaffa(_FIELD->Sk)+_T+; //Код дистрибьютора в системе SPOT 2D
        dtoc(mkCance->dttn)+_T+; // дата прихода
        ltrim(str(mkCance->mntovt))+_T+;  //Код SKU в системе дистрибьютора
        LTRIM(str(mkCance->kvp))+_T+; ///  Размер отгрузки в штуках
        LTRIM(str(mkCance->ttn,6)) // номер ТТН

    iif(i=0,QQOUT(cLine),QOUT(cLine)); i++
    mkCance->(DBSkip())
  EndDo

  If i >= 2 // есть данные, то добавим ДЕНЬ и 50 (достаточно этого)
    mkTov->(DBGoTop())
    aId:={'50'} //,'51'}
    For k:=1 To len(aId)
      a_nKvp:={1,-1}
      For m:=1 To LEN(a_nKvp)
        nKvp:=a_nKvp[m]
        cTTn:=aId[k]+DTOS(date()-1)+'C'

        cLine:=;
            aId[k]+_T+; //Код дистрибьютора в системе SPOT 2D
            dtoc(date()-1)+_T+; // дата прихода
            ltrim(str(mkTov->mntovt))+_T+;  //Код SKU в системе дистрибьютора
            LTRIM(str(nKvp))+_T+; ///  Размер отгрузки в штуках
            cTTn // номер ТТН

        iif(i=0,QQOUT(cLine),QOUT(cLine)); i++
      Next m
    Next k
  EndIf

  QOUT('')
  SET PRINT TO
  SET PRINT OFF

// перемещений между филиалами дистрибьютора movements.csv
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO movements.csv
  i:=0
    cLine:=;
    'id дистрибьютора от'+_T+;
    'id дистрибьютора к'+_T+;
    'Дата'+_T+;
    'Код продукта дистрибьютора'+_T+;
    'Количество'+_T+;
    'Номер документа'
        QQOUT(cLine) ; i++

  sele mkMoveM
  DBGoTop()
  Do While !mkMoveM->(eof())
    cIdDistr_Ot:=IdDistrJaffa(_FIELD->Sk)
    cIdDistr_2 :='51'
    If cIdDistr_Ot='51'
      cIdDistr_2:='50'
    EndIf

    cLine:=;
    cIdDistr_Ot+_T+; //Код дистрибьютора в системе SPOT 2D, с которого перемещается товар
    cIdDistr_2+_T+; //Код дистрибьютора в системе SPOT 2D, на которiй перемещается товар
    dtoc(mkMoveM->dttn)+_T+; // дата прихода
    ltrim(str(mkMoveM->mntovt))+_T+;  //Код SKU в системе дистрибьютора
    LTRIM(str(mkMoveM->kvp))+_T+; ///  Размер отгрузки в штуках
    LTRIM(str(mkMoveM->ttn,6)) // номер ТТН

    iif(i=0,QQOUT(cLine),QOUT(cLine)); i++

    mkMoveM->(DBSkip())
  EndDo

  If i >= 2 // есть данные, то добавим ДЕНЬ отрицательные нельзя
    mkTov->(DBGoTop())
    aId:={'50','51'}
    For k:=1 To len(aId)
      cIdDistr_Ot:=aId[k]
      cIdDistr_2 :='51'
      If cIdDistr_Ot='51'
        cIdDistr_2:='50'
      EndIf
      a_nKvp:={1} //,1}
      For m:=1 To LEN(a_nKvp)
        nKvp:=a_nKvp[m]
        cTTn:=aId[k]+DTOS(date()-1)+'M'

        cLine:=;
        cIdDistr_Ot+_T+; //Код дистрибьютора в системе SPOT 2D, с которого перемещается товар
        cIdDistr_2+_T+; //Код дистрибьютора в системе SPOT 2D, на которiй перемещается товар
        dtoc(date()-1)+_T+; // дата прихода
        ltrim(str(mkTov->mntovt))+_T+;  //Код SKU в системе дистрибьютора
        LTRIM(str(nKvp))+_T+; ///  Размер отгрузки в штуках
        cTTn // номер ТТН

        iif(i=0,QQOUT(cLine),QOUT(cLine)); i++
      Next m
    Next k
  EndIf

  QOUT('')
  SET PRINT TO
  SET PRINT OFF


// файла с торговiми точками ttoptions.csv
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO ttoptions.csv
    i:=0
    cLine:=;
    'id дистрибьютора'+_T+;
    'Код клиента ERP'+_T+;
    'Название клиента'+_T+;
    'Название клиента (сокращенное)'+_T+;
    'Адрес клиента'+_T+; //    Индекс, Страна, Область, Населенный пункт, Улица, номер дома
    'Фактический адрес клиента'+_T+;
    'Название ТТ'+_T+;
    'Адрес ТТ'+_T+; //    142400, Казахстан, Актюбинская обл, г Ногинск, ул Соборная, д 12    "Самовывоз" или адрес склада.
    'Улица'+_T+;
    'Дом'+_T+;
    'Район'+_T+; //    Район торговой точки
    'Код ЕДРПОУ'+_T+;
    'Тип ТТ'+_T+;
    'Канал продвижения'+_T+;
    'Код ТА'
        QQOUT(cLine); i++

  aId:={'50','51'}
  For k:=1 To Iif(lTATT,1,2) //2
    sele kplkgp
    DBGoTop()
    Do While !kplkgp->(eof())
      sele kplkgp
      If lTATT
        cIdDistr_Ot:=IdDistrJaffa(_FIELD->Sk)
      Else
        // для цикла когда точки повторяются.
        cIdDistr_Ot:=aId[k] //Код дистрибьютора в системе SPOT 2D
      EndIf

      cLine:=;
      cIdDistr_Ot+_T+; //Код дистрибьютора в системе SPOT 2D
      KodDistrJaffa(kplkgp->kpl,kplkgp->kgp) // код клиента

      kln->(netseek('t1','kplkgp->kpl'))
      If EMPTY(kplkgp->Npl)
        sele kplkgp
        repl kplkgp->Npl with kln->NKl, OKPO with kln->kkl1  // Код ЕДРПОУ
      EndIf

      cLine+=''+_T+allt(kplkgp->Npl) // Название клиента
      cLine+=iif(Right(cLine,1)=_T,'Клиент '+'без Названия','')
      cLine+=''+_T+allt(kplkgp->Npl) // Название клиента (сокращенное)
      cLine+=iif(Right(cLine,1)=_T,'Клиент '+'без Названия','')

      nKlkgp_Okpo:=kln->kkl1  // Код ЕДРПОУ
      // Юридический адрес клиента (контрагента).
      cLine+=''+_T+Iif(!empty(kln->adr),allt(kln->adr),'Юр.адрес не заведен')
      // Фактический адрес клиента
      cLine+=''+_T+Iif(!empty(kln->adr),allt(kln->adr),'Юр.адрес не заведен')



      kln->(netseek('t1','kplkgp->kgp'))
      If EMPTY(kplkgp->NGp)
        sele kplkgp
        repl kplkgp->NGp with kln->NKl  // getfield('t1','kplkgp->kgp','kgp','NGrPol')
      EndIf
      cLine+=''+_T+allt(kplkgp->NPl)+' '+allt(kplkgp->NGp) // Название ТТ
      cLine+=iif(Right(cLine,1)=' ','ТТ '+'без Названия','')

      cAdr:=allt(kln->adr)
      cLine+=''+_T+Iif(!empty(cAdr),allt(cAdr),'Самовывоз')// Адрес ТТ
      // Улица - после Точки идет начало улицы и заканчивается Запятой
      cUlc:=allt(substr(cAdr, at('.',cAdr)+1, at(',',cAdr) - (at('.',cAdr)+1)))
      // Дом - в адрсе, после запятой
      cDom:=allt(substr(cAdr,at(',',cAdr)+1))     //49

      //cLine+=''+_T+allt(getfield("t1","kln->kulc","kulc","nulc")) // 'Улица'
      cLine+=''+_T+cUlc // 'Улица'
      cLine+=iif(Right(cLine,1)=_T,'Безимянная','')

      cLine+=''+_T+cDom// 'Дом'
      cLine+=iif(Right(cLine,1)=_T,'49/','')

      cLine+=''+_T+allt(getfield("t1","kln->krn","krn","nrn")) //'Район

      cLine+=''+_T+LTRIM(STR(nKlkgp_Okpo))  // Код ЕДРПОУ

      // Тип ТТ* String (256 Необходимо выгружать тип ТТ:
      // ключевая / не ключевая
      if !empty(getfield('t1','kplkgp->kgp','kgp','prtt102'))
        cLine+=''+_T+'ключевая'
      else
        cLine+=''+_T+'не ключевая'
      endif

      // Канал продвижения
      kgpcatr:=getfield("t1","kplkgp->kgp","kgp","kgpcat")
      nkgpcatr:=getfield("t1","kgpcatr","kgpcat","nkgpcat")
      cLine+=''+_T+'' // left(allt(nkgpcatr),1)+lower(substr(allt(nkgpcatr),2))


      // код ТА
      cLine+=''+_T+ PADL(LTRIM(STR(kta)),4,"0")


      iif(i=0,QQOUT(cLine),QOUT(cLine)); i++
      kplkgp->(DBSkip())
    EndDo
  Next i

  QOUT('')
  SET PRINT TO
  SET PRINT OFF

// торговых агентов ta.csv
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO ta.csv
    i:=0
  //  https://help.salesforce.com/articleView?id=000336272&language=en_US&type=1&mode=1
  // не открывается в Эксель, нельзая чтобы файл начинался с ID!
    cLine:=;
    'id дистрибьютора'+_T+;
    'Код ТА'+_T+;
    'Имя ТА'+_T+;
    'Тип ТА'
      QQOUT(cLine) ; i++
  aId:={'50','51'}
  For k:=1 To Iif(lTATT,1,2) //2 1- цикл отключен
    sele kta
    DBGoTop()
    Do While !kta->(eof())
      sele kta
      If lTATT
        cIdDistr_Ot:=IdDistrJaffa(_FIELD->Sk)
      Else
        // для цикла когда точки повторяются.
        cIdDistr_Ot:=aId[k] //Код дистрибьютора в системе SPOT 2D
      EndIf
      cLine:=;
      cIdDistr_Ot+_T+;
      PADL(LTRIM(STR(kta->kta)),4,"0")+_T+;
      Iif(kta->kta=0,;
      'Пинчук В.П.',;
      getfield('t1','kta->kta','s_tag','fio');
    )

      If str(getfield('t1','kta->kta','s_tag','ktas'),3) $ '; 31;505'
        cLine+=''+_T+'1'
      Else
        cLine+=''+_T+'0'
      EndIf

      iif(i=0,QQOUT(cLine),QOUT(cLine)); i++
      kta->(DBSkip())
    EndDo
  Next i

  QOUT('')
  SET PRINT TO
  SET PRINT OFF


// файла продуктов sku.csv
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO sku.csv
    i:=0
    cLine:=;
    'id дистрибьютора'+_T+;
    'Код продукта дистрибьютора'+_T+;
    'Название продукта'+_T+;
    'Штрихкод'+_T+;
    'Код продукта производителя'+_T+;
    'ID единицы измерения продукта'
    QQOUT(cLine);    i++

  //aId:={'50','51'}
  aListMnTov := {}
  Aadd(aListMnTov,"0000000" + "20200601")
  dDt:=STOD("20200601")
  For k:=1 To 1 // один проход тк выводим всЕ

    sele mkSku
    DBGoTop()
    Do While !eof()
      cIdDistrJaffa := IdDistrJaffa(_FIELD->Sk)

      Do Case
      Case cIdDistrJaffa = '51'
        cLineSku(@i, cIdDistrJaffa)

      Case cIdDistrJaffa = '50'
        If Empty(ASCAN(aListMnTov,str(_FIELD->MnTov)+DTOS(dDt)))
          Aadd(aListMnTov,str(_FIELD->MnTov)+DTOS(dDt))
        //If Empty(ASCAN(aListMnTov,_FIELD->MnTov))
          //Aadd(aListMnTov,_FIELD->MnTov)
          cLineSku(@i, cIdDistrJaffa)
        EndIf

      Case cIdDistrJaffa = '122'
        cLineSku(@i, cIdDistrJaffa)

        If Empty(ASCAN(aListMnTov,str(_FIELD->MnTov)+DTOS(dDt)))
          Aadd(aListMnTov,str(_FIELD->MnTov)+DTOS(dDt))
        //If Empty(ASCAN(aListMnTov,_FIELD->MnTov))
          //Aadd(aListMnTov,_FIELD->MnTov)
          cIdDistrJaffa := '50'
          cLineSku(@i, cIdDistrJaffa)
        EndIf

      EndCase

      DBSkip()
    EndDo
  Next k

  // QOUT('') будет еще холодильники
  SET PRINT TO
  SET PRINT OFF

  // есть ли чего грузить? Проверка по mkTov
  lUpLoad:=(i # 0)

  // close mkTov


  //////////////////// 2R
  use sbarost new
    set index to
    index on ktl to tmpktl
    total on ktl to tmpktl
    use tmpktl new

  USE (gcPath_ew+"deb\accord_deb") ALIAS skdoc NEW SHARED READONLY
  SET ORDER TO TAG t1

  SkuAddXol() // добавим холодиьники

  aId:={'50','51'}
  For k:=1 To 2
    outlog(__FILE__,__LINE__,aId[k])
    Spod2R(cMark,cFilePef,aId[k])
  next k

  close sbarost
  close tmpktl
  close skdoc


  close mkDeliv
  close mkReceiv
  close mkCance
  close mkMoveM

  close mkSku
  close mkTov

  close kplkgp
  close kta
  If !Empty(aAliasClose)
    AEval(aAliasClose,{|cAlias|(cAlias)->(DBCloseArea())})
  EndIf


  If .t. //lUpLoad
    cLogSysCmd:=""
    cRunZip:="/usr/bin/zip"
    If adMkDt[1] = adMkDt[2]
      cFileNameArc:="jd"+SUBSTR(DTOS(dMkDt),3)+".zip"
    Else
      cFileNameArc:="j0"+SUBSTR(DTOS(dtBegr),3)+'-'+SUBSTR(DTOS(dtEndr),3)+".zip"
    EndIf



    cFileList:='ttoptions.csv ta.csv stocks.csv delivery.csv sku.csv';
      +' receive.csv cancellations.csv movements.csv'

    SYSCMD(cRunZip+" "+cFileNameArc+" "+ cFileList;
      +" ; ./Sum.bat "+"50","",@cLogSysCmd)

    //qout(__FILE__,__LINE__,cLogSysCmd)

    SendingJafa(cListEmail,{{ cFileNameArc,cMark+"_"+str(228,3)+" "+cFilePef+"__ProdResSumy"+" "+DTOC(dMkDt,"YYYYMMDD")}},"./",228)
  EndIf



  /*
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO delivery.csv
  sele mkDeliv
  DBGoTop()
  i:=0
  Do While !mkDeliv->(eof())

    iif(i=0,QQOUT(cLine),QOUT(cLine)); i++
    mkDeliv->(DBSkip())
  EndDo
  SET PRINT TO
  SET PRINT OFF
  */

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  05-23-18 * 02:57:32pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION IdDistrJaffa(n_Sk)
 LOCAL id:=allt(str(n_Sk,3))
 If n_Sk >= 200
   cskl->(__dblocate({|| cskl->Sk = n_Sk  }))
   Do Case
   Case cskl->Rm=0
    If n_Sk = 254
     id:='122'
    Else
     id:='50'
    EndIf
   Case cskl->Rm=4
     id:='51'
   OtherWise
     id:='-50'
   EndCase
  EndIf
  RETURN (id)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  05-23-18 * 03:04:26pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION KodDistrJaffa(kpl,kgp)
  RETURN (padl(allt(str(kpl,7)),7,'0')+'#'+ padl(allt(str(kgp,7)),7,'0'))


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-18-18 * 11:51:29am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION JafaDataConv4Spod2D(dMkDt,cListNoSaleSk)
  LOCAL nPr102, nRs102, nReceiv, nDeliv, nCance, n1OsFo, n2OsFo, dMkDt1

  USE (gcPath_ew+"deb\accord_deb") ALIAS skdoc NEW SHARED READONLY
  copy to tmpskdoc for skdoc->Nap=4 .and. skdoc->ktan > 0
  close skdoc

  // удалим скады не нужные
  use mktov102 new
  COPY TO mktov FOR !(STR(_FIELD->Sk,3) $ cListNoSaleSk) ;
  ;//.and. OsfO >= 0 ;
  .and. left(NaT,1)#'*' .and. JF_SKIPMNTOV

  // товар для заглушек
  locate   FOR !(STR(_FIELD->Sk,3) $ cListNoSaleSk) ;
  .and. left(NaT,1)#'*' .and. JF_SKIPMNTOV
  nMntovT:=MntovT

  CLOSE mktov102

  USE mkpr102 NEW
  filedelete('mkPr.*')
  COPY TO mkPr FOR !(STR(_FIELD->Sk,3) $ cListNoSaleSk) ;
   .and. left(NaT,1)#'*' ;
   .and. JF_SKIPMNTOV
  copy stru to tmp_PlGp
  copy stru to tmp_Kta
  CLOSE mkpr102

  USE mkdoc102 NEW
  COPY TO mkRs FOR !(STR(_FIELD->Sk,3) $ cListNoSaleSk) ;
   .and. left(NaT,1)#'*' ;
   .and. JF_SKIPMNTOV
  close mkdoc102


  use mkpr alias mkPr  new Exclusive
  dele for kvp=0 ; pack
  sum kvp to nPr102
  INDEX ON STR(KPL)+STR(KGP) to tmpPr102
    TOTAL ON STR(KPL)+STR(KGP) ;//пара плательщик, получатель
    FIELD Kvp TO tmpPr102
  INDEX ON STR(KTA) to tmpPrKta
    TOTAL ON STR(KTA) ;// Тогр Агент
    FIELD Kvp TO tmpPrKTA

  use mkRs alias mkRs new  Exclusive
  dele for kvp=0 ; pack
  sum kvp to nRs102
  INDEX ON STR(KPL)+STR(KGP) to tmpRs102
    TOTAL ON STR(KPL)+STR(KGP) ;//пара плательщик, получатель
    FIELD Kvp TO tmpRs102
  INDEX ON STR(KTA) to tmpRsKta
    TOTAL ON STR(KTA) ;// Тогр Агент
    FIELD Kvp TO tmpRsKTA


  //перенесем ВОЗВРАТ vo=1 & Продажи
  sele mkpr
  copy stru to mkDeliv
  copy to mk_Vzr for vo=1
  dele for vo=1 ;  pack
  use mk_Vzr new Exclusive
  repl all kvp with kvp*(-1)
  close mk_Vzr

  sele mkRs
  copy to mkRsDlv for vo=9 .and. !(str(sk,3)$'254;')
  dele for vo=9 .and. !(str(sk,3)$'254;') ;  pack

  // продажи доставка
  use mkDeliv new
  append from mk_Vzr
  append from mkRsDlv
  copy to tmpDeliv

  // приход от производителя/возврат произв
  sele mkpr
  copy stru to mkReceiv
  copy to mkPrPro for vo=9 // прямой приход
  dele for vo=9 ;  pack

  sele mkRs
  copy to mkRsPro for kop=154 .and. vo=1 //возврат произв
  dele for kop=154 .and. vo=1  ;  pack
  use mkRsPro new Exclusive
  repl all kvp with kvp*(-1)
  close mkRsPro

  use mkReceiv new
  append from mkPrPro
  append from mkRsPro


  // перемещение между сладами
  sele mkpr
  copy stru to mkMoveM
  copy stru to mkPrMove
  dele for vo=6 .and. kop=188; pack

  sele mkRs
  copy to mkRsMove for vo=6 .and. kop=188
  dele for vo=6 .and. kop=188  ;  pack
  use mkMoveM new
  append from mkPrMove // пустой
  append from mkRsMove


  // прочие
  sele mkpr
  copy stru to mkcance
  repl all kvp with kvp*(-1)
  close mkpr

  sele mkRs
  close mkRs


  use mkcance new Exclusive
  append from mkpr
  append from mkrs
  /* 08-14-18 10:04am
  Другие операции - данные из файла cancellations;
  - списание/недостача выгружаются со знаком Минус
  - операция излишек - со знаком Плюс
  */
  repl all kvp with kvp*(-1) // 08-14-18 10:04am
  //nMnTov
  //outlog(__FILE__,__LINE__,IsArray(dMkDt),dMkDt)
  If IsArray(dMkDt)
    sele mkcance
    DBGoTop()
    IF !eof()
      copy to tmpcance next 1
      //adMkDt:=ACLONE(dMkDt)
      FOR dDt:=dMkDt[1] TO dMkDt[2]
        LOCATE FOR dTtn = dDt
        IF !found()
          append from tmpcance
          DBGoBottom()
          repl dTtn WITH dDt, ttn WITH VAL("-"+Right(DTOS(dDt),5)),;
          MnTov WITH nMnTovT, MnTovT WITH nMnTovT,;
          kvp WITH 1
          append from tmpcance
          DBGoBottom()
          repl dTtn WITH dDt, ttn WITH VAL("-"+Right(DTOS(dDt),5)),;
          MnTov WITH nMnTovT, MnTovT WITH nMnTovT,;
          kvp WITH -1

        ENDIF

      NEXT dDt
    ENDIF

  ENDIF


  use tmp_PlGp new
  If lTATT
    APPEND FROM mkkplkgp //добавим точки с ВСЕ от Джафы
    APPEND FROM tmpDeliv
    append from sbarost   // append from - из оборудования
    append from tmpskdoc      // append from - из дебиторки
  Else
    APPEND FROM mkkplkgp //добавим точки с ВСЕ от Джафы
    append from tmpPr102
    append from tmpRs102
    append from sbarost   // append from - из оборудования
    append from tmpskdoc      // append from - из дебиторки
  EndIf
  FileDelete('tmpPlGp.*')
  INDEX ON STR(KPl)+STR(KGp)+STR(Sk) to tmpPlGp
    TOTAL ON STR(KPl)+STR(KGp) ;//пара плательщик, получатель
    FIELD Kvp TO tmpPlGp
  close tmp_PlGp

  use tmp_Kta new
  If lTATT
    /*Файл ta должен содержать только тех торговых представителей,
    по которым были продажи продукции производителя за период,
    указанный в файле delivery.
    */
    APPEND FROM tmpDeliv
  Else
    APPEND FROM mkkplkgp //добавим точки с ВСЕ от Джафы
    append from tmpPrKta
    append from tmpRsKta
    append from sbarost   // append from - из оборудования
    append from tmpskdoc      // append from - из дебиторки
  EndIf

  INDEX ON STR(KTA)+STR(Sk) to tmpKta
    TOTAL ON STR(KTA) ;// Тогр Агент
    ; //for kta#0 ;
    FIELD Kvp TO tmpKTA
    TOTAL ON STR(KTA)+STR(Sk) ;// Тогр Агент
    ; //for kta#0 ;
    FIELD Kvp TO tmpKTAsk
  close tmp_Kta

  use tmpKTA alias kta new

  use tmpPlGp alias KPlKGp new Exclusive // пара плательщик, получатель
  INDEX ON STR(KPl)+STR(KGp) TAG t1

  // товара
  use mktov new Exclusive
  repl all sk with val(IdDistrJaffa(sk))
  index on str(sk)+str(mntovt,7) to mksku
  total on str(sk)+str(mntovt,7) to mksku ;
    field osn, osfo, osfon

  use mksku alias mksku new

  sele mksku // список про-ции
  sele mktov // остатки по дням
  index on DTOS(dt) to mktov-dt


  // test sum
  sele mkReceiv
  sum kvp to nReceiv

  sele mkDeliv
  sum kvp to nDeliv

  sele mkCance
  sum kvp to nCance

  sele mkMoveM


  outlog(3,__FILE__,__LINE__, (nPr102 - nRs102),'// приход и продажи' )
  outlog(3,__FILE__,__LINE__, (nReceiv - (nDeliv - nCance)), '// разложенные на Приход, Продажи и Прочие')
  outlog(3,__FILE__,__LINE__, ;
  (nPr102 - nRs102) - (nReceiv - (nDeliv - nCance)),'// разница')

  // тест
  If IsArray(dMkDt) .and. dMkDt[1]+1 <= dMkDt[2] // хотя бы два дня
    dMkDt1:=dMkDt[1]+1
    // остаток первогод дня
    sele mktov // остатки по дням
    DBSeek(DTOS(dMkDt1))
    sum osfo to n1OsFo while dMkDt1 = dt

    DBSeek(DTOS(dMkDt[2]))
    sum osfo to n2OsFo while dMkDt[2] = dt

    sele mkReceiv
    sum kvp to nReceiv for DTtn > dMkDt1

    sele mkDeliv
    sum kvp to nDeliv for DTtn > dMkDt1

    sele mkCance
    sum kvp to nCance for DTtn > dMkDt1

    // ост.Н + приход и прочие_операции - продажи
    n1OsFo := n1OsFo + (nReceiv + nCance) - nDeliv
    outlog(3,__FILE__,__LINE__, n1OsFo + (nReceiv + nCance) - nDeliv)
    outlog(3,__FILE__,__LINE__, n2OsFo, n1OsFo,  n2OsFo - n1OsFo)

  EndIf

  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-18-18 * 12:31:40pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION RptJafaSpod2D(cDosParam)
  LOCAL cFile,  _h,  cLine,  lConv,  lYesNo,  nRow
  // LOCAL cListNoSaleSk:="254 256 255 "+STR(ngMerch_Sk241,3)
  LOCAL cListNoSaleSk:="256 255 "+STR(ngMerch_Sk241,3)
  LOCAL lRun:=.T.
  LOCAL cListEmail


  dtBegr:=dtEndr:=date()
  Do Case
  Case UPPER("/FlMn") $ cDosParam
    gdTd:=BOM(DATE())
    dtBegr:=BOM(DATE())
    dtEndr:=Date() //EOM(DATE())
  Case UPPER("/dtBeg") $ cDosParam
    Dt_Beg_End(cDosParam,.T.,@dtBegr,@dtEndr)
  OtherWise
    lRun:=.F.
  EndCase

  IF lRun
    netuse('knasp')
    IF !(UPPER("/no_mkotch") $ UPPER(DosParam()))
      JoinMkDt(102,dtBegr, dtEndr)
    ENDIF
    netuse('cskl')
    //JdMkDt,afaDataConv4Spod2D(cListNoSaleSk)
    cListEmail:='lista@bk.ru'

    JafaSpod2D({dtBegr,dtEndr},cListEmail)

    If !Empty(select('mktov'))
      sele mktov;   close
    EndIf
    use mkDeliv new Exclusive
    use mkReceiv new Exclusive
    use mktov new Exclusive



    sele mkDeliv
    index on dtos(DTtn)+str(kpl,7)+str(kgp,7)+str(MnTov,7) to tmpDeliv

    total on dtos(DTtn)+str(kpl,7)+str(kgp,7)+str(MnTov,7) to tmpDeliv;
     field kvp;
     for JF_SKIPMNTOV
    use tmpDeliv alias Deliv new

    sele mkReceiv
    index on dtos(DTtn)+str(MnTov,7) to tmpRecv
    total on dtos(DTtn)+str(MnTov,7) to tmpRecv;
     field kvp;
     for JF_SKIPMNTOV
    use tmpRecv alias Recv  new

    sele mktov
    index on dtos(DT)+str(MnTovT,7) to tmpTov
    total on dtos(DT)+str(MnTovT,7) to tmpTov;
     field OsFo ;
     for JF_SKIPMNTOV

    use tmpTov alias Ost new


    ///////////////////  продажи

    lConv:= .T. //.T. //NEED_OEM2ANSI ковертарция
    lYesNo:= .F.

    cFile:='Deliv'+".xls"
    cLine:=;
    'Дата;Название клиента;Код клиента;Название продукта;Код продукта'+;
    ';Количество проданных и возвращенных единиц;Сумма продажи без НДС'+;
    ';Сумма продажи с НДС'
    nRow:=0

    _h:=XlsHeadCREATE(cFile,cLine,lConv,lYesNo,@nRow)

    sele Deliv
    Do While !Deliv->(eof())
      i:=0
      // Дата
      cCell := DTOC(DTTN,"yyyy-mm-dd")+' '+TDC
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
      // Код клиента;
      cCell := KodDistrJaffa(kpl,kgp)
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
      // ;Название клиента;
      cCell := allt(npl)+' '+allt(ngp)
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
      // Название продукта;
      cCell := allt(nat)
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
      // Код продукта'+;
      cCell := str(MnTov)
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
      // ';Количество проданных и возвращенных единиц;
      cCell := kvp
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
      // Сумма продажи без НДС'+;
      cCell := round(kvp * zen,2)
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
      // ';Сумма продажи с НДС'
      cCell := round(kvp * round(zen * 1.2,2),2)
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
      nRow++
      Deliv->(DBSkip())
    EndDo

    XlsCLOSE_XLSEOF(_h)

    ///////////////////  приходы

    lConv:= .T. //.T. //NEED_OEM2ANSI ковертарция
    lYesNo:= .F.

    cFile:='Recv'+".xls"
    cLine:=;
    'Дата прихода;Название продукта;Код продукта;Приход, шт'+;
    ';Приход, в деньгах без НДС;Приход, в деньгах с НДС'

    nRow:=0
    _h:=XlsHeadCREATE(cFile,cLine,lConv,lYesNo,@nRow)

    sele Recv
    Do While !Recv->(eof())
      i:=0
      //'Дата прихода
      cCell := DTOC(DTTN,"yyyy-mm-dd")+' '+TDC
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
      //;Название продукта
      cCell := allt(nat)
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
      //;Код продукта
      cCell := str(MnTov)
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
      //;Приход, шт'+;
      cCell := kvp
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
      //;Приход, в деньгах без НДС'
      cCell := round(kvp * zen,2)
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
      //';Приход, в деньгах с НДС
      cCell := round(kvp * round(zen * 1.2,2),2)
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
      nRow++
      Recv->(DBSkip())
    EndDo
    XlsCLOSE_XLSEOF(_h)

    /////////////////// остатки
    lConv:= .T. //.T. //NEED_OEM2ANSI ковертарция
    lYesNo:= .F.

    cFile:='stocks'+".xls"
    cLine:=;
    'Дата остатка;Название продукта;Код продукта;Остаток, шт'+;
    ';Сумма остатка в закупочных ценах без НДС'+;
    ';Сумма остатка в закупочных ценах с НДС'
    nRow:=0
    _h:=XlsHeadCREATE(cFile,cLine,lConv,lYesNo,@nRow)

    sele Ost
    Do While !Ost->(eof())
      i:=0
      // 'Дата остатка
      cCell := DTOC(DT,"yyyy-mm-dd")+' '+Tm
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
      // ;Название продукта
      cCell := allt(nat)
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
      // ;Код продукта
      cCell := str(MnTov)
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
      //;Остаток, шт'+;
      cCell := osfo
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
      // ';Сумма остатка в закупочных ценах без НДС'
      cCell := round(osfo * CenPr,2)
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
      // ';Сумма остатка в закупочных ценах с НДС'+;
      cCell := round(osfo * round(CenPr * 1.2,2),2)
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
      i:=0
      nRow++
      Ost->(DBSkip())
    EndDo
    XlsCLOSE_XLSEOF(_h)

  cMark:='102'
  cFilePef:='J0'

  cRunZip:="/usr/bin/zip"
  cLogSysCmd:=""

  cFileNameArc:="j0"+SUBSTR(DTOS(dtBegr),3)+'-'+SUBSTR(DTOS(dtEndr),3)+".zip"

  cFileList:='stocks.xls recv.xls deliv.xls'

  SYSCMD(cRunZip+" "+cFileNameArc+" "+ cFileList,"",@cLogSysCmd)

  //qout(__FILE__,__LINE__,cLogSysCmd)

  SendingJafa('lista@bk.ru,spot2d@pradata.com',; // ,hellen@pradata.com
  {{ cFileNameArc,;
  cMark+"_";
  +"_ProdResSumy";
  +" "+cFilePef;
  +""+DTOC(dtBegr,"YYYYMMDD");
  +"-"+DTOC(dtEndr,"YYYYMMDD")}},"./",228)

  endif
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-18-18 * 02:23:27pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION XlsHeadCREATE(cFile,cLine,lConv,lYesNo,nRow)
  LOCAL nCount, i, nI
  LOCAL _h, cCell


  _h:=FCREATE(cFile)
  FWRITE(_h, CHR(9)+CHR(8)+I2Bin(8)+;
    I2Bin(0)+I2Bin(16)+L2Bin(0);
      )

  nCount := NUMTOKEN(cLine, ";", 1)
  FOR nI := 1 TO nCount
    cNmCol:=TOKEN(cLine, ";", nI, 1)
    i:=nI

    // Для многострочных заголовков вставляется line break
    cCell:=StrTran(cNmCol, ';', CHR(10))
    WriteCell(_h, cCell, i-1, nRow, 0, lConv, lYesNo)

  NEXT nI
  nRow++
  RETURN (_h)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-18-18 * 03:24:13pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION XlsCLOSE_XLSEOF(_h)
  FWRITE(_h, I2Bin(10)+I2Bin(0))  //XLSEOF
  FCLOSE(_h)
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  07-05-18 * 04:20:12pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION Spod2R(cMark,cFilePef,cIdDistr)
  LOCAL i, cLine, aId, cIdDistrJaffa
  LOCAL nRec, nTTN, aListMnTov

  LOCAL cLogSysCmd:=""
  LOCAL cRunZip:="/usr/bin/zip"
  LOCAL cDosParam:=upper(DosParam())

  aListMnTov := {}
  Aadd(aListMnTov,0000000)

  // при переодических отчетах не выгружаем
  If (UPPER("/dtBeg") $ cDosParam .or. UPPER("/FlMn") $ cDosParam)
    Return nil
  EndIf
  outlog(__FILE__,__LINE__,DosParam(),UPPER("/FlMn") $ DosParam())


  // close sbarost
  // close tmpktl

  sele mkTov

// файла прайсов prices.csv
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO prices.csv
    i:=0
    cLine:=;
    'id дистрибьютора'+_T+;
    'Price_Name'+_T+;
    'SKU_Code'+_T+;
    'Price'+_T+;
    'Ident'
     //   QQOUT(cLine); i++


    sele mkTov
    DBGoTop()
    Do While !mkTov->(eof())
      Iif(mkTov->MnTov=5070445 .and. cIdDistr = '50',outlog(3,__FILE__,__LINE__,"=5070445"),)

      if getfield('t1','mkTov->MnTov','ctov','Merch') = 0
        mkTov->(DBSkip())
        loop
      endif
      Iif(mkTov->MnTov=5070445 .and. cIdDistr = '50',outlog(3,__FILE__,__LINE__,"5070445"),)

      cIdDistrJaffa:=IdDistrJaffa(mkTov->Sk)

      If cIdDistr = '50' // основной слад
        Iif(mkTov->MnTov=5070445 .and. cIdDistr = '50',outlog(3,__FILE__,__LINE__,"5070445"),)
        if cIdDistrJaffa $ '122; 50' // склад СОХ или основной(50)
           cIdDistrJaffa := '50'
        else
          mkTov->(DBSkip())
          loop
        EndIf
        Iif(mkTov->MnTov=5070445 .and. cIdDistr = '50',outlog(3,__FILE__,__LINE__,"5070445"),)

        // проверяем по стиску, чтобы не повторялись
        If Empty(ASCAN(aListMnTov,mkTov->MnTov))
          Aadd(aListMnTov,mkTov->MnTov)
        Else
          mkTov->(DBSkip())
          loop
        EndIf
      EndIf
      Iif(mkTov->MnTov=5070445 .and. cIdDistr = '50',outlog(3,__FILE__,__LINE__,"5070445"),)

      If cIdDistrJaffa = cIdDistr
        //cLine:=;
        Iif(mkTov->MnTov=5070445 .and. cIdDistr = '50',outlog(3,__FILE__,__LINE__,"5070445"),)
        //  aId[k]+_T+; //Код дистрибьютора в системе SPOT 2D
        cLine:=;
         cIdDistrJaffa+_T+;  //IdDistrJaffa(mkTov->Sk)+_T+; //Код дистрибьютора в системе SPOT 2D
         'Общий'+_T+;
            allt(str(mkTov->MnTov))+_T+;
            allt(str(round(mkTov->CenPr * 1.20,2)))+_T+;
            allt(str(1))

        iif(i=0,QQOUT(cLine),QOUT(cLine)); i++
      endif
      mkTov->(DBSkip())
    EndDo

  QOUT('')
  SET PRINT TO
  SET PRINT OFF



  ////  файла привязки прайсов к клиентам price2shops.csv
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO price2shops.csv
    i:=0
    cLine:=;
    'id дистрибьютора'+_T+;
    'Код клиента ERP'+_T+;
    'Empty'+_T+;
    'Price_Name'
    //     QQOUT(cLine); i++

  QOUT('')
  SET PRINT TO
  SET PRINT OFF


// файла дебиторской задолженности debts.csv
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO debts.csv
    i:=0
    cLine:=;
    'id дистрибьютора'+_T+;
    'Код клиента ERP'+_T+;
    'Invoice_Code'+_T+;
    'Invoice_Date'+_T+;
    'Payment_Date'+_T+;
    'Form'+_T+;
    'Invoice_Sum'+_T+;
    'Debt'+_T+;
    'Over_debt'+_T+;
    'Worker_Code'+_T+;
    'Invoice_Days'
     //QQOUT(cLine); i++

    /*
    ID дистрибьютора StringВаш Код в системе Spot
    Код клиента ERP           StringУникальный код связки кода клиента (контрагента) и кода торговой точки (точки доставки).
    Детально описание см. в файле ttoptions.csv
    Invoice_CodeStringНомер накладной
    Invoice_DateDD.MM.YYYYДата накладной (отгрузки) - формат даты ДД.ММ.ГГГГ
    Payment_Date DD.MM.YYYYДата оплаты - формат даты ДД.ММ.ГГГГ
    Form Integer
    Invoice_Sum String Сумма по накладной, в деньгах
    Debt Float Задолженность, в деньгах
    Over_debt FloatПросроченная задолженность в деньгах
    Worker_Code StringКод сотрудника из Вашей учетной системы     по которому числится данная накладная
    Invoice_Days IntegerКол-во дней просрочки, в днях просрочки
    */

  sele skdoc
  set rela to STR(KPl)+STR(KGp) INTO KplKGp
  set filt to skdoc->Nap=4 .and. skdoc->ktan > 0 .and. KplKGp->(FOUND())

  DBGoTop()
  DO WHILE skdoc->(!EOF())
    cIdDistrJaffa:=IdDistrJaffa(skdoc->Sk)
    If cIdDistrJaffa = cIdDistr ;
     .and. skdoc->Nap=4 .and. skdoc->ktan > 0

      SELE skdoc
      nRec:=RECNO()
      nTTN:=TTN
      sum Sdp to nSdp WHILE nTTN = TTN
      DBGOTO(nRec)
      //Дата оплаты,Дата оплаты,Date,Строка (дд.мм.гггг),*,
      DtOplr:=IIF(EMPTY(skdoc->DtOpl),skdoc->DOP,skdoc->DtOpl)


      cLine:=;
        IdDistrJaffa(skdoc->Sk)+_T+; //Код дистрибьютора в системе SPOT 2D
        KodDistrJaffa(skdoc->kpl,skdoc->kgp)+_T+; // код клиента
        LTRIM(str(skdoc->ttn,6))+_T+; // номер ТТН
        dtoc(skdoc->dop)+_T+; // дата
        dtoc(DtOplr)+_T+; // дата оплаты
        str(iif(skdoc->kop=169,1,2),1)+_T+; //Форма оплаты:     1-наличная форма      2-безналичная форма
        allt(str(skdoc->sdv))+_T+; // Сумма по накладной
        allt(str(nSdp))+_T+; // Задолженность
        allt(iif(DtOplr-date() >= 0,str(0,1),str(nSdp)))+_T+; // Задолженность
        PADL(LTRIM(STR(skdoc->kta)),4,"0")+_T+; // Код сотрудника из Вашей учетной системы     по которому числится данная накладная
        allt(str(DtOplr-date(),5,0)) // Кол-во дней просрочки
      iif(i=0,QQOUT(cLine),QOUT(cLine)); i++

      sele skdoc
      DO WHILE nTTN = TTN
        DBSkip()
      ENDDO
      loop

    ENDIF
    skdoc->(DBSKIP())
  ENDDO
  QOUT('')
  SET PRINT TO
  SET PRINT OFF


// файла торгового оборудования form_matrix.csv
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO form_matrix.csv
    i:=0
    cLine:=;
    'id дистрибьютора'+_T+;
    'Код клиента ERP'+_T+;
    'Код продукта дистрибьютора'
    //   QQOUT(cLine) ;    i++

    sele tmpktl
    set rela to STR(KPl)+STR(KGp) INTO KplKGp
    /*04-03-20 12:21pm отключил фильтрацию KplKGp->(FOUND())
    set filt to "ХОЛ" $ UPPER(tmpktl->nat) .and. KplKGp->(FOUND())
    */
    set filt to "ХОЛ" $ UPPER(tmpktl->nat)

    DBGoTop()
    Do While !tmpktl->(eof())
      cIdDistrJaffa:=IdDistrJaffa(tmpktl->Sk)
      If cIdDistrJaffa = cIdDistr

        cLine:=;
            IdDistrJaffa(tmpktl->Sk)+_T+; //Код дистрибьютора в системе SPOT 2D
            KodDistrJaffa(tmpktl->kpl,tmpktl->kgp)+_T+; // код клиента
            allt(str(tmpktl->ktl));

        iif(i=0,QQOUT(cLine),QOUT(cLine)); i++

      EndIf
      tmpktl->(DBSkip())
    EndDo

  QOUT('')
  SET PRINT TO
  SET PRINT OFF

    cFileNameArc:="jr"+SUBSTR(DTOS(dMkDt),3)+cIdDistr+".zip"


    cFileList:='prices.csv price2shops.csv debts.csv form_matrix.csv'

    SYSCMD(cRunZip+" "+cFileNameArc+" "+ cFileList;
    +" ; ./PutSpd2r"+cIdDistr+".bat","",@cLogSysCmd)

    //qout(__FILE__,__LINE__,cLogSysCmd)
    //,support_2r@pradata.com
    SendingJafa('lista@bk.ru',{{ cFileNameArc,;
    cMark;
    ;//+"_"+str(228,3);
    +"_ProdResSumy";
    +" "+cFilePef;
    +DTOC(dMkDt,"YYYYMMDD")}},"./",228)

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  07-16-18 * 11:32:15am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION SkuAddXol()
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO sku.csv addi // добавление
  i:=1

    sele tmpktl
    set filt to "ХОЛ" $ UPPER(tmpktl->nat)

    DBGoTop()
    Do While !tmpktl->(eof())

      cLine:=;
          IdDistrJaffa(tmpktl->Sk)+_T+; //Код дистрибьютора в системе SPOT 2D
          allt(str(tmpktl->ktl))+_T+;
          _FIELD->nat+_T+;
          allt(str(tmpktl->ktl))+_T+;
          allt(str(tmpktl->ktl))+_T+;
          allt(str(1))

      iif(i=0,QQOUT(cLine),QOUT(cLine)); i++
      tmpktl->(DBSkip())
    EndDo

  QOUT('')
  SET PRINT TO
  SET PRINT OFF

  RETURN (NIL)





/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  05-07-18 * 10:37:04am
 НАЗНАЧЕНИЕ......... находит остатки выкупленные крансные,
        формируюет закрыте из и формирует запрос (протокол) на выкуп
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION JaffaRedOstOrder(cDosParam,bSeekSk,kopr, vor)
  LOCAL lerase:=.T. // LOCAL kplr
  LOCAL nkpl, lKtl2:=.f.
  LOCAL SkVzr
  LOCAL nMnTov,nMnTov2, nOsVO

  DEFAULT bSeekSk TO {||ent=gnEnt.and. sk=228 }, kopr TO 169, vor TO 9

  If Upper('Ktl2=0') $ cDosParam
    lKtl2:=.t.
  EndIf

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

  sele cskl
  __dbLocate(bSeekSk)
  IF !FOUND()
    outlog(__FILE__,__LINE__,'нет склада')
    RETURN (NIL)
  ENDIF

  pathr=gcPath_d+allt(path)
  netuse('tov','Tov',,1)
  netuse('TovM','TovM',,1)



  sele Tov
  ordsetfocus('t2')
  If !netseek('t2','cskl->Skl,507')
    outlog(__FILE__,__LINE__,cskl->Skl,507,'cskl->Skl,507')
    RETURN (NIL)
  EndIf

  Do While Tov->skl = cskl->Skl .and. Tov->kg = 507

    sklr:=cskl->Skl
    MnTovr:=Tov->MnTov
    ktl_r:=Tov->ktl

    sele TovM
    If !netseek('t1','sklr,MnTovr',,,1)
      outlog(__FILE__,__LINE__,'не найдено sklr,MnTovr',sklr,MnTovr)
      sele Tov ;     DBSkip() ;      loop
    EndIf

    /*
    sele TovM
    If otv = 1 // связана с ответ хранением
      outlog(__FILE__,__LINE__)
      sele Tov ;      DBSkip();      loop
    EndIf
    */

    sele Tov
    If osv >= 0
      outlog(3,__FILE__,__LINE__,'osv >= 0 ->Skip')
      sele Tov ;      DBSkip();      loop
    EndIf

    If osv < 0 .and. otv = 1 // не берем КТЛ звязанные со складом ОТВ
      outlog(3,__FILE__,__LINE__,'osv < 0 .and. otv = 1 ->Skip не берем КТЛ звязанные со складом ОТВ')
      sele Tov ;      DBSkip();      loop
    EndIf

    post_r=post
    MnTovr=MnTov

    rcPr2o1r:=RecNo()
    sele Tov
    ordsetfocus('t5')

    // получение остатка с ОТВ.ХР
    netseek('t5','sklr,MnTovr')
    sum OsVO to nOsVO for otv = 1 while sklr = skl .and. MnTovr = MnTov

    If nOsVO <= 0
      outlog(__FILE__,__LINE__,ktl_r,'nOsVO <= 0')
      sele Tov ; loop
    EndIf

    // возврат
    sele Tov
    ordsetfocus('t2')
    DBGoTo(rcPr2o1r)

    // провека этого КТЛ наличия в Протоколе
    rcPr2o1r:=0
    SeekRecNo4ProtSale(@rcPr2o1r,post_r, ktl_r)

    If rcPr2o1r = 0 // найдено в протоколе
      outlog(__FILE__,__LINE__,ktl_r)
      sele Tov ;      DBSkip();      loop
    EndIf

    sele Tov
    outlog(__FILE__,__LINE__,'  ',str(ktl,9),osv, nat)

    kplr:=nkpl:=0
    SkVzr:=0
    nMnTov:=nMnTov2:=0


    nMnTov:=nMnTov2:=MnTovr
    // найти или создать строку шапки
    sele lrs1
    locate for kpl = kplr
    If !found()
      Tov->(LRs1_Add(str(nKpl,7)+'-'+XTOC(nMnTov)+'-'+XTOC(nMnTov2)+'-'+time()+uuid(),;
        228, SkVzr, kopr, vor))
    EndIf

      // обнулим КТЛ красный
      LRs2_Add(MnTovr, Tov->osv, ktl_r, 0, .F.)
      // возмет или остатка или отв.хран
      LRs2_Add(MnTovr, Tov->osv, 0, 0, .t.)

    If lKtl2 //  Ktl2=0
      // LRs2_Add(MnTovr, Tov->osv, 0, 0, .t.)
    Else
      // LRs2_Add(MnTovr, Tov->osv, ktl_r, 0, .F.)
    EndIf


    sele Tov
    DBSkip()
  EndDo


  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-13-18 * 02:59:38pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION JaffaOrders(cDosParam)
  LOCAL lerase:=.T., lDelFile:=.T.
  LOCAL nKta, nPosS
  LOCAL cL
  LOCAL oD, oOrder, oRs2,oPmnt
  LOCAL cTypeOrd, aTypeOrd, i, j

  IF !lerase_lrs(lerase)
    outlog(3,__FILE__,__LINE__,'//в следующий раз')
    RETURN
  ENDIF

  nKta:=kta_DosParam(cDosParam,'/kta=',3)


  tzvk_crt()
  luse('lphtdoc')
  luse('lrs1')
  luse('lrs2')

  netuse('cskl')
  netuse('kgp')


  cL := memoread('import.json')
  cL := CHARREM(CHR(10),cL)

  oD:=JsonDecode(cL)
  aTypeOrd:={ 'orders', 'returns' }

  For j:=1 To Iif((UPPER("/all_skl") $ UPPER(cDosParam)),2,1)

    cTypeOrd:=aTypeOrd[j]

    If cTypeOrd $ oD['data']

      For i:=1 To LEN(oD['data'][cTypeOrd])

        oOrder:=oD['data'][cTypeOrd][i]
        //outlog(3,__FILE__,__LINE__,oOrder['id'])
        //outlog(3,__FILE__,__LINE__,oOrder['peopleCode'])

        ktar:=VAL(oOrder['peopleCode'])
        If !Empty(nKta) // пропуск не выбранного ТА
          If ktar # nKta
            outlog(3,__FILE__,__LINE__,'// пропуск не выбранного ТА',ktar , nKta)
            loop
          EndIf
        EndIf

        nPosS:=AT('#',oOrder['clientCode'])
        kplr := VAL(LEFT(oOrder['clientCode'],nPosS-1))
        kgpr := VAL(SUBSTR(LTRIM(oOrder['clientCode']), nPosS+1))
        outlog(3,__FILE__,__LINE__,'  ',kgpr,kplr)

        Sklr   := 888
        IF .NOT. (UPPER("/all_skl") $ UPPER(cDosParam))
          IF !cSkl->(check_skl(@Sklr,kgpr))
            LOOP
          ENDIF
        ELSE
          cSkl->(check_skl(@Sklr,kgpr))
        ENDIF

        kopir  := 169
        vor:=9 // реализация
        If  cTypeOrd = 'returns'
          kopr := 108
          vor:=1 // реализация
          DtRor := CTOD(oOrder["date"],'YYYY-MM-DD') + 1
          DocIDr    := '2RT_'+allt(str(oOrder['id']))
          nVal:= 0
        Else // заявка
          kopr := 169
          If !Empty(oOrder["IdentOperationCode"])
            kopr   := VAL(oOrder["IdentOperationCode"])
            kopir  := kopr
          EndIf
          DtRor := CTOD(oOrder["ExpectedDeliveryDate"],'YYYY-MM-DD') //дата доставки
          DocIDr    := oOrder['code']
          // сертификат
          nVal:=0 // VAL(oOrder["IdentCertificate"])

        EndIf

        TimeCrtFrmr:= DTOS(DtRor)+" "+"00:00:00"
        TimeCrtr  := ''
        Commentr  := Iif(empty(oOrder["comment"]),'',oOrder["comment"])

        Sumr:=0

        lrs1->(DBGoBottom())
        ttnr:=lrs1->ttn
        ttnr:=ttnr+1

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


        //вторая позиция 4 сертификатов
        serr:=lrs1->ser
        serr:=STUFF(serr,2,1,IIF(nVal=0," ","1"))
        sele lrs1
        netrepl('ser',{serr})

        netrepl('RndSdv',{2}) // округление

        netrepl('spd',{1}) //признак обработки
        // ниже должно переприсвоится в 0 - это значить обратотан

        // outlog(__FILE__,__LINE__,oOrder['id'],oOrder['code'])
        // outlog(__FILE__,__LINE__,'  ',oOrder['date'])
        // outlog(__FILE__,__LINE__,'  ',oOrder['clientCode'])
        // outlog(__FILE__,__LINE__,'  ',oOrder['peopleCode'])
        // outlog(__FILE__,__LINE__,'  ',oOrder["IdentCertificate"])
        // outlog(__FILE__,__LINE__,'  ',oOrder["IdentOperationCode"])
        // outlog(__FILE__,__LINE__,'  ',oOrder["ExpectedDeliveryDate"])
        // outlog(__FILE__,__LINE__,'  ',oOrder["comment"])

        If "products" $ oOrder
          outlog(4,__FILE__,__LINE__,'  ',"  ","products")
          oRs2:=oOrder["products"]
          For k:=1 To len(oRs2)

             outlog(4,__FILE__,__LINE__;
             ,'  ',"  ",oRs2[k]['code'],oRs2[k]['quantity'])

             mntovr:=val(oRs2[k]['code'])

             kvpr:=oRs2[k]['quantity']
             If !ISNUM(kvpr)
               kvpr:=val(oRs2[k]['quantity'])
             EndIf
             zenr:=0

             sele lrs2
             netadd()
             netrepl('ttn,mntov,kvp,zen',{ttnr,mntovr,kvpr,zenr},)

          Next k

          sele lrs1
          netrepl('spd',{0}) //признак обработки

        EndIf
      Next
    EndIf

  Next j

    outlog(__FILE__,__LINE__,'moneys' $ oD['data'],"'moneys' $ oD['data']")
  If 'moneys' $ oD['data']

    outlog(3,__FILE__,__LINE__,'// перечень д-тов забора денег')
    outlog(3,__FILE__,__LINE__,'  ',LEN(oD['data']['moneys']))
    For i:=1 To LEN(oD['data']['moneys'])

      oPmnt:=oD['data']['moneys'][i]
      outlog(3,__FILE__,__LINE__,oPmnt)
      //outlog(__FILE__,__LINE__,oPmnt['peopleCode'],VAL(oPmnt['peopleCode']))

      ktar:=VAL(oPmnt['peopleCode'])
      If !Empty(nKta) // пропуск не выбранного ТА
        If ktar # nKta
          outlog(3,__FILE__,__LINE__,'// пропуск не выбранного ТА',ktar , nKta)
          loop
        EndIf
      EndIf

      nPosS:=AT('#',oPmnt['clientCode'])
      kplr := VAL(LEFT(oPmnt['clientCode'],nPosS-1))
      kgpr := VAL(SUBSTR(LTRIM(oPmnt['clientCode']), nPosS+1))


      If !Empty(nKta) // пропуск не выбранного ТА
        If !EMPTY(oPmnt['PaymentID']) .and. !EMPTY(val(oPmnt['PaymentID'])) ;
          .and. !Empty(oPmnt['sum']) .and. !Empty(val(oPmnt['sum']))

          Commentr  := 'т='+oPmnt['PaymentID']+' c='+oPmnt['sum']+' н=102'
        EndIf
      else
        Commentr  := ''
        Commentr  +=' т='+allt(oPmnt['PaymentID'])
        Commentr  +=' c='+allt(oPmnt['sum'])
        Commentr  +=' к='+'2R__'+allt(str(oPmnt['id']))
      endif
    outlog(__FILE__,__LINE__,kplr,kgpr,  Commentr,    0,'kplr,kgpr,  Commentr,    0')

      tzvk_ztxt(kplr,kgpr,  Commentr,    0)
      /*
      outlog(__FILE__,__LINE__,     oD['data']['moneys'][i]['id'])
      outlog(__FILE__,__LINE__,'  ',oD['data']['moneys'][i]['date'])
      outlog(__FILE__,__LINE__,'  ',oD['data']['moneys'][i]['peopleCode'])
      outlog(__FILE__,__LINE__,'  ',oD['data']['moneys'][i]['clientCode'])
      outlog(__FILE__,__LINE__,'  ',oD['data']['moneys'][i]['sum'])
      outlog(__FILE__,__LINE__,'  ',oD['data']['moneys'][i]['PaymentID'])
      */
    Next

  EndIf

  If !empty(nKta)
    // добавим задания из коментриев
    sele lrs1
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

    SELE tzvk
    copy to ('tzvk'+PADL(LTRIM(str(ktar)),3,'0'))
    copy to ('tzvk_lrs')
  EndIf

  close tzvk
  close ('lphtdoc')
  close ('lrs1')
  close ('lrs2')
  nuse()

  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  05-18-20 * 06:01:03pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION cLineSku(i, cIdDistrJaffa)
  cLine:=;
      cIdDistrJaffa + _T + ; //Код дистрибьютора в системе SPOT 2D
      allt(str(_FIELD->MnTov)) + _T +;
      _FIELD->nat+_T+;
      str(_FIELD->bar)+_T+;
      str(_FIELD->bar)+_T+;
      allt(str(1))

  iif(i=0,QQOUT(cLine),QOUT(cLine)); i++
  RETURN ( NIL )


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  05-19-20 * 09:20:28am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION cLineStocks(i, cIdDistrJaffa, nQt, dDt)
  cLine:=;
      cIdDistrJaffa + _T + ; //Код дистрибьютора в системе SPOT 2D
      dtoc(dDt) + _T + ;
      allt(str(mkTov->MnTov)) + _T + ;
      allt(str(nQt))

  iif(i=0,QQOUT(cLine),QOUT(cLine)); i++
  RETURN ( NIL )
