/*****************************************************************
 
PROCEDURE: PPC
 АВТОР..ДАТА..........С. Литовка  12-21-06 * 01:00:42pm
 НАЗНАЧЕНИЕ......... подготовка и передача данных
 ПАРАМЕТРЫ..........
 ПРИМЕЧАНИЯ.........
 */
//#command netrepl(<p1>,<p2>[,<p3>[,<p4>]]) =>;
//net_repl(<p1>,{p2},[<p3>],[<p4>])
#include "common.ch"
#define LF CHR(10)
#define przp_0 .T. //.T. - только официал .F. -  по отгруженным

  //clea
  PARAMETER aKop
  LOCAL cLogSysCmd, cRunZip, cRunUnZip
  LOCAL cFileNameArc
  LOCAL nRef_Sales, nRef_Price,nDoc_Debt,nRef_Routes
  LOCAL cDir_kta, cPrefDirKta
  LOCAL dDtTmLog, lCdb, lFullUp
  LOCAL cDosParam, nKta
  dDtTmLog:=""
  lFullUp:=.F.

  set print to ("crm-log\get_"+dDtTmLog+".log") ADDI

  cRunZip:="/usr/bin/zip"
  cRunUnZip:="/usr/bin/unzip"
  cDirShared:="/home/itk/copy_scp_saha"
  cPrefDirKta:=Iif(gnEnt=20,;
                   'k','p')


  netuse('cskl')
  netuse('cgrp')
  netuse('mkeep')
  netuse('stagm')
  netuse('kln')
  netuse('kpl')
  netuse('kgp')
  netuse('kgpcat')
  netuse('klnnac')
  netuse('klndog')
  netuse('klnlic')
  netuse('phtdoc')
  //netuse('kplkgp')

  //netuse('stag t')
  netuse('etm')
  netuse('stagtm')

  netuse('s_tag')
  //netuse('tmesto')
  netuse('ctov')

  //обновим КодТоргового и Его ТоргТочки


  ktasr=457 //супервизор
  ktar=602 //ТА
  cDosParam:=UPPER(DosParam())
  //cgSk241_Merch:=
  IF UPPER("/kta=") $ cDosParam
    nKta:=VAL(SUBSTR(cDosParam,AT("/KTA=",cDosParam)+LEN("/KTA="),3))
  ELSE
    nKta:=NIL
  ENDIF


  dDt:=date()-7
  //STOD("20061210")//date()

  dShDateBg := dDt-(7*3)
  dShDateEnd := dDt      //+(7*1)

  sele s_tag
  go top
  do while .T. .AND. !eof()
    IF .T. .AND. IIF(EMPTY(nKta),.F.,kod # nKta)
      skip;      loop
    ENDIF
    if ent # gnEnt .OR. EMPTY(DeviceId) .OR. uvol = 1
      skip ;      loop
    endif


    IF .NOT. (UPPER("/crm_all_skl") $ UPPER(DosParam()))
      IF !cSkl->(check_skl(s_tag->AgSk))
        //outlog(__FILE__,__LINE__,s_tag->AgSk,kod)
        skip
        LOOP
      ENDIF
        //outlog(__FILE__,__LINE__,'!!!!',s_tag->AgSk,kod)
    ENDIF

    ktasr:=ktas //супервизор
    ktar:=kod //ТА

    lCdb:=((s_tag->DeviceId = 2) ;
          .OR. (UPPER("/DevId=2") $ cDosParam)) ;
          .OR. DeviceId = 888 ;
          .OR. (! EMPTY(DeviceId) .and. UPPER("/DevId=888") $ cDosParam)

      cFile:="k"+PADL(LTRIM(STR(ktar,3)), 3, "0") +"ost"+".dbf"
      /*
         outlog(__FILE__,__LINE__,"'ktar','stagtm')",ktar)
         outlog(__FILE__,__LINE__,;
     cFile,;
     FILE(cFile),;
     !FILE(cFile),;
     !(s_tag->DeviceId = 999 .OR. s_tag->DeviceId = 888),;
     '!FILE("k"+PADL(LTRIM(STR(ktar,3)), 3, "0") +"ost"+".dbf")',;
     "!(s_tag->DeviceId = 999 .OR. s_tag->DeviceId = 888)";
      )
      */
    // удалив файлы  k???os.dbf вкл инициализацию
    IF !FILE("k"+PADL(LTRIM(STR(ktar,3)), 3, "0") +"ost"+".dbf") ;
      .AND. !(s_tag->DeviceId = 999 .OR. s_tag->DeviceId = 888)
      //данных нет и нет инициализации
      If .T.
        IF DeviceId = 1
          s_tag->(netrepl("DeviceId ",{999}))
        ELSEIF DeviceId = 2
          s_tag->(netrepl("DeviceId ",{888}))
        ENDIF
      EndIf
    ENDIF

    IF DeviceId = 999 ;
      .or. DeviceId = 888 ;
      .or. (! EMPTY(DeviceId) .and. UPPER("/DevId=999") $ cDosParam) ;
      .or. (! EMPTY(DeviceId) .and. UPPER("/DevId=888") $ cDosParam)
      // обновить цены
      // обновить цены & остатки и делаем пока не заберут
      s_tag->(netrepl("Ref_Price,Dt_Price",{7,DATE()-10}))

      //4 Обновить маршруты, клиентов
      s_tag->(netrepl("Ref_Routes,Dt_Routes",{7,DATE()-10}))

      //2 Обновить взаиморасчеты
      s_tag->(netrepl("Doc_Debt",{1}))

      //3 Обновить историю продаж
      s_tag->(netrepl("Ref_Sales",{1}))

      // ? Обновить инициализацию
      s_tag->(netrepl("Ref_Ini",{1}))
      lFullUp:=.T.
    ENDIF
    /*
    IF STR(s_tag->Ref_Price,1) $ "1" .AND. s_tag->Dt_Price # DATE()
      s_tag->(netrepl("Ref_Price,Dt_Price",{7,DATE()-10}))
    ENDIF

    IF STR(s_tag->Ref_Routes,1) $ "1" .AND. s_tag->Dt_Routes # DATE()
      // обновить  и делаем пока не заберут
      s_tag->(netrepl("Ref_Routes,Dt_Routes",{7,DATE()-10}))
    ENDIF
    */

    FILEDELETE("*.txt")
    FILEDELETE("*.dat")

    //AgSk //код склада, которым работает ТА

    if !netseek('t1','ktar','stagtm')
      #ifdef __CLIP__
          //qout(__FILE__,__LINE__,"!netseek('t1','ktar','stagtm')",!netseek('t1','ktar','stagtm'),ktar)
      #endif
      skip
      loop
    endif

    //?fio
    ///////////////////// проверка на то как передались пред данные ///////////

    cFileNameArc:="From1C"+".zip"
    //созданем рабочий каталог
    cDir_kta:=cPrefDirKta+IIF(lCdb,"cdb","")+PADL(LTRIM(STR(ktar,3)), 3, "0")
    DIRMAKE(cDir_kta)

  #ifdef __CLIP__
    set translate path off
  #endif
    IF FILE(cDir_kta+'\'+cFileNameArc)
      ERASE (cDir_kta+'\'+cFileNameArc)
    ENDIF
  #ifdef __CLIP__
    set translate path on
  #endif

    //принимаем файл для анализа
    Get_Ftp(cPrefDirKta+IIF(lCdb,"cdb",""),ktar,cDirShared,cFileNameArc)

#ifdef __CLIP__
    set translate path off
#endif
     //outlog(__FILE__,__LINE__,cDir_kta+'\'+cFileNameArc,FILE(cDir_kta+'\'+cFileNameArc))
    // файл с выгрузкой нет - забрали
    IF .T. .AND. !FILE(cDir_kta+'\'+cFileNameArc)

      //1 Обновить остатки
      IF STR(s_tag->Ref_Price,1) $ "2,8"
        //пытались передать и передали т.к. нет файл т.е. его забрали
        s_tag->(netrepl("Ref_Price",{0}))
      ENDIF

      //4 Обновить маршруты, клиентов
      IF STR(s_tag->Ref_Routes,1) $ "2,8" //пытались передать
        //пытались передать и передали т.к. нет т.е. его забрали
        s_tag->(netrepl("Ref_Routes",{0}))
      ENDIF

      //2 Обновить взаиморасчеты
      IF s_tag->Doc_Debt=2 //пытались передать
        s_tag->(netrepl("Doc_Debt",{0}))
      ENDIF

      //3 Обновить историю продаж
      IF s_tag->Ref_Sales=2 //пытались передать
        s_tag->(netrepl("Ref_Sales",{0}))
      ENDIF

      // ? Обновить инициализацию
      IF s_tag->Ref_Ini=2 //пытались передать
        s_tag->(netrepl("Ref_Ini",{0}))
      ENDIF

    ELSE //файл есть!!!
      IF lFullUp
        IF STR(s_tag->Ref_Price,1) $ "8" .AND. s_tag->Dt_Price#DATE()
          //передавли и файл есть, т.е его не забрали повторим процедуру
          // обновить цены
          s_tag->(netrepl("Ref_Price,Dt_Price",{7,DATE()-10}))
        ENDIF

        //4 Обновить маршруты, клиентов
        IF STR(s_tag->Ref_Routes) $ "8" .AND. s_tag->Dt_Routes#DATE()
          //передавли и файл есть, т.е его не забрали повторим процедуру
          s_tag->(netrepl("Ref_Routes,Dt_Routes",{7,DATE()-10}))
        ENDIF
      ELSE
        //ждем пока заберут
        sele s_tag
        skip
        LOOP
      ENDIF

    ENDIF

#ifdef __CLIP__
     set translate path on
#endif

     ///////////////////// END проверка на то как передались пред данные ///////////

     /////////////////////// подготовка данных для передачи //////////////

      IF STR(s_tag->Ref_Price,1) $  " 1 7"
        //создаем базы
        kta_ost(;
        s_tag->Ref_Price  + ;
        s_tag->Ref_Routes + ;
        s_tag->Ref_Sales,;
        ktar,ktasr)
      ELSE
        // просто используем
        kta_ost(,ktar,ktasr,1)
      ENDIF

        //outlog(__FILE__,__LINE__,s_tag->Ref_Routes,s_tag->Ref_Sales,IIF(s_tag->Dt_Routes#DATE(),1,0))
      cktar:=PADL(LTRIM(STR(ktar,3)), 3, "0")
      IF STR(s_tag->Ref_Routes) $ "7" .OR. .NOT. FILE('k'+cktar+'pcen.dbf')
        //создаем базы
        kta_kln(;
        s_tag->Ref_Routes + ;
        s_tag->Ref_Sales + ;
        IIF(s_tag->Dt_Routes#DATE() .OR. .NOT. FILE('k'+cktar+'pcen.dbf'),1,0),;
        ktar)
      ELSE
        // просто используем
        kta_kln(,ktar,1)
      ENDIF


      IF s_tag->Ref_Sales = 1 //пытались передать
        kta_sales(s_tag->Ref_Sales,ktar,ktasr, dShDateBg, dShDateEnd)
        kta_sales(s_tag->Ref_Sales,ktar,ktasr, dShDateBg, dShDateEnd,.T.)//мерч
      ENDIF

      PlSl_TA(ktar)

      rs1_Confirm(ktar,ktasr, dShDateBg, dShDateEnd)

     /////////////////////// END подготовка данных для передачи //////////////
     IF  lCDB
       cdb_load(ktar,s_tag->AgSk,s_tag->fio,dShDateBg, dShDateEnd,aKop,;
       s_tag->Ref_Price,s_tag->Doc_Debt,s_tag->Ref_Sales,;
       s_tag->Ref_Routes,s_tag->Ref_Ini)

     ELSE
       kpk_load(ktar,s_tag->AgSk,s_tag->fio,dShDateBg, dShDateEnd,aKop,;
       s_tag->Ref_Price,s_tag->Doc_Debt,s_tag->Ref_Sales,;
       s_tag->Ref_Routes,s_tag->Ref_Ini)
     ENDIF


      //1 Обновить остатки
        IF STR(s_tag->Ref_Price,1) $ "7,8" //передать
          s_tag->(netrepl("Ref_Price,Dt_Price",{8,DATE()}))
        ENDIF

      //4 Обновить маршруты, клиентов
        IF STR(s_tag->Ref_Routes,1) $ "7,8" //передать
          //kta_kln(s_tag->Ref_Routes,ktar)
          s_tag->(netrepl("Ref_Routes,Dt_Routes",{8,DATE()}))
        ENDIF


      //1 Обновить остатки
        IF STR(s_tag->Ref_Price,1) $ "1,2" //передать
          s_tag->(netrepl("Ref_Price,Dt_Price",{2,DATE()}))
        ENDIF

      //4 Обновить маршруты, клиентов
        IF STR(s_tag->Ref_Routes,1) $ "1,2" //передать
          //kta_kln(s_tag->Ref_Routes,ktar)
          s_tag->(netrepl("Ref_Routes,Dt_Routes",{2,DATE()}))
        ENDIF

      //2 Обновить взаиморасчеты
        IF STR(s_tag->Doc_Debt,1) $ "1,2" //передать
          s_tag->(netrepl("Doc_Debt,Dt_Debt",{2,DATE()}))
          //Doc_Debt()
        ENDIF
      //3 Обновить историю продаж
        IF STR(s_tag->Ref_Sales,1) $ "1,2" //передать
          s_tag->(netrepl("Ref_Sales,Dt_Sales",{2,DATE()}))
        ENDIF


        // ? Обновить инициализацию
        IF STR(s_tag->Ref_Ini,1) $ "1,2" // передать
          s_tag->(netrepl("Ref_Ini,Dt_Ini",{2,DATE()}))
        ENDIF

        IF (lCDb)
           cLogSysCmd:=""
           #ifdef __CLIP__
                SYSCMD(;
                "iconv -f CP1251 -t UTF8 fromcdb.dat -o FromCDB.xml","",@cLogSysCmd)
           #endif
          //пакуем
           cFileNameArc:="From1C.zip"
           cLogSysCmd:=""
           #ifdef __CLIP__
                SYSCMD("rm -f From1C.zip ; "+cRunZip+" "+cFileNameArc+" "+;
                "FromCDB.xml","",@cLogSysCmd)
           #endif
        ELSE
          //пакуем
           cFileNameArc:="From1C.zip"
           cLogSysCmd:=""
           #ifdef __CLIP__
              IF STR(s_tag->Ref_Price,1) $ "7,8" //передать
                SYSCMD("rm -f From1C.zip ; "+cRunZip+" "+cFileNameArc+" "+;
                "from1c.dat config.reg","",@cLogSysCmd)
              ELSE
                SYSCMD("rm -f From1C.zip ; "+cRunZip+" "+cFileNameArc+" "+;
                "from1c.dat","",@cLogSysCmd)
              ENDIF


           #endif
        ENDIF
     //end пакуем

     //передаем
  Put_Ftp(cPrefDirKta+IIF(lCdb,"cdb",""),ktar,cDirShared)
     //
     //exit
#ifdef __CLIP__
              //outlog(__FILE__,__LINE__,dDateCrt,ttn,"vo",vo,"sdv",sdv,"kpv",kpv,TPoints->(DBSEEK(rs1->kpv)),dDateCrt)
#endif
     IF s_tag->DeviceId = 999
       s_tag->(netrepl("DeviceId ",{1}))
     ELSEIF s_tag->DeviceId = 888
       s_tag->(netrepl("DeviceId ",{2}))
     ENDIF
     sele s_tag
     skip
     //exit
  endd
  set print to

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-16-06 * 05:20:38pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION ppc_get(aKop)
  LOCAL cLogSysCmd, cRunZip, cRunUnZip
  //LOCAL c FileNameArc:="From1C.zip" //"To1C.zip "
  LOCAL cFileNameFtp:="To1C.zip"
  LOCAL cFileNameArc:="To1C.zip"
  LOCAL cFileNameXml:="To1C.xml"
  LOCAL cFileXml:="To1C.xml"
  LOCAL cFileXmlCDB:="ToCDB.xml"
  LOCAL dDtTmLog, cPrefDirKta
  LOCAL n_Skl
  LOCAL lerase:=.T.

  dDtTmLog:=""

  set print to ("crm-log\get_"+dDtTmLog+".log") ADDI

  cDirName:=DIRNAME()

  cRunZip:="/usr/bin/zip"
  cRunUnZip:="/usr/bin/unzip"
  cDirShared:="/home/itk/copy_scp_saha"
  cPrefDirKta:=Iif(gnEnt=20,;
                   'k','p')

  IF !lerase_lrs(lerase)
    //в следующий раз
    RETURN
  ENDIF


  lcrtt('lphtdoc','phtdoc')
  lindx('lphtdoc','phtdoc')
  lcrtt('lrs1','rs1')
  lindx('lrs1','rs1')
  lcrtt('lrs2','rs2')
  lindx('lrs2','rs2')

  netuse('cskl')
  netuse('etm')
  netuse('stagtm')
  netuse('s_tag')

  ktasr=457 //супервизор
  ktar=602 //ТА
  cDosParam:=UPPER(DosParam())
  //cgSk241_Merch:=
  IF UPPER("/kta=") $ cDosParam
    nKta:=VAL(SUBSTR(cDosParam,AT("/KTA=",cDosParam)+LEN("/KTA="),3))
  ELSE
    nKta:=NIL
  ENDIF

 //принимаем данные
  sele s_tag
  go top
  do while !eof()
    sele s_tag
    IF .T. .AND. IIF(EMPTY(nKta),.F.,kod # nKta)
      skip
      loop
    ENDIF
    if !(s_tag->ent = gnEnt .and. !EMPTY(DeviceId) .and. uvol = 0)
      skip
      loop
    endif

    IF .NOT. (UPPER("/crm_all_skl") $ UPPER(DosParam()))
#ifdef __CLIP__
      IF !cSkl->(check_skl(s_tag->AgSk))
        //outlog(__FILE__,__LINE__,s_tag->AgSk,kod)
        skip
        LOOP
      ENDIF
#endif
        //outlog(__FILE__,__LINE__,'!!!!',s_tag->AgSk,kod)
    ENDIF

    ktasr:=ktas //супервизор
    ktar:=kod //ТА
    //outlog(__FILE__,__LINE__,date(),ktar,ktasr)


     ktar=kod
     if !netseek('t1','ktar','stagtm')
        skip
        loop
     endif
     nRec_s_tag:=s_tag->(RECNO())

     //создадим рабочий каталог
     lCdb:=(;
     (s_tag->DeviceId = 2) ;
     .OR. (UPPER("/DevId=2") $ cDosParam);
     .OR. (s_tag->DeviceId = 888) ;
   )

     cDir_kta:=cPrefDirKta+IIF(lCdb,"cdb","")+PADL(LTRIM(STR(ktar,3)), 3, "0")
     DIRMAKE(cDir_kta)

     //outlog(__FILE__,__LINE__,lCDB,cDir_kta)

     //принимаем
     Get_Ftp(cPrefDirKta+IIF(lCdb,"cdb",""),ktar,cDirShared,cFileNameFtp)
     //
     cFileNameXml:=IIF(lCdb,cFileXmlcdb,cFileXml)
     //outlog(__FILE__,__LINE__,cFileNameXml,cDir_kta)
     //удалим cFileNameXml
     cLogSysCmd:=""
     cCmd:="rm -f ./"+ cDir_kta +"/"+cFileNameXml
     //outlog(__FILE__,__LINE__,cCmd)

     #ifdef __CLIP__
        SYSCMD(cCmd,"",@cLogSysCmd)
     IF !EMPTY(cLogSysCmd)
       qOUT(__FILE__,__LINE__,cLogSysCmd,cCmd)
     ENDIF
     #endif

     //распакуем XML
     cLogSysCmd:=""
     cCmd:=cRunUnZip+" -o"+" ./"+ cDir_kta +"/"+cFileNameArc+" "+;
     "-d ./"+cDir_kta
     //outlog(__FILE__,__LINE__,cCmd)
#ifdef __CLIP__
     SYSCMD(cCmd,"",@cLogSysCmd)
     IF !EMPTY(cLogSysCmd)
       qOUT(__FILE__,__LINE__,cLogSysCmd,cCmd)
     ENDIF
#endif
     //end распакуем
        IF (lCDb)
           cLogSysCmd:=""
           cCmd:="iconv -c -f UTF16 -t CP1251"+;
                 " ./"+ cDir_kta +"/"+cFileNameXml+;
           " -o"+" ./"+ cDir_kta +"/"+LOWER(cFileNameXml)

           #ifdef __CLIP__
             SYSCMD(cCmd,"",@cLogSysCmd)
             IF !EMPTY(cLogSysCmd)
               qOUT(__FILE__,__LINE__,cLogSysCmd,cCmd)
             ENDIF
           #endif
       ENDIF

#ifdef __CLIP__
     set translate path off
#endif

     //outlog(__FILE__,__LINE__,FILE(cDir_kta+'\'+cFileNameXml),(cDir_kta+'\'+cFileNameXml))

     IF FILE(cDir_kta+'\'+cFileNameXml)
       // outlog(__FILE__,__LINE__,lCDB)

       // распаковка картинок
       // outlog(__FILE__,__LINE__,cDir_kta +"\"+'PhotosToCDB.zip',file(cDir_kta +"\"+'PhotosToCDB.zip'))
       If FILE(cDir_kta +"\"+'PhotosToCDB.zip')
         cLogSysCmd:=""
         cCmd:=cRunUnZip+" -o"+" ./"+ cDir_kta +"/"+'PhotosToCDB.zip'+" "+;
         "-d ./"+cDir_kta
         //outlog(__FILE__,__LINE__,cCmd)
    #ifdef __CLIP__
         SYSCMD(cCmd,"",@cLogSysCmd)
         IF !EMPTY(cLogSysCmd)
           qOUT(__FILE__,__LINE__,cLogSysCmd,cCmd)
         ENDIF
    #endif
        EndIf

      IF lCdb
         XmlCdb2Rs1(cDir_kta,LOWER(cFileNameXml),aKop,@n_Skl, .F.) // без удал lrs
      ELSE
         Xml2Rs1(cDir_kta,cFileNameXml,aKop,@n_Skl, .F.) // без удал lrs
      ENDIF


       #ifdef __CLIP__
               set translate path on
       #endif

       //c удаляем приятый файл

       sk_r:=n_skl // n_skl cm. line 477

       netuse('cskl')
       locate for sk_r = sk ;  entr:= ent
       //entr:=getfield('t1','sk_r','cskl','ent')
       nuse('cskl')

       if entr # gnEnt
         outlog(__FILE__,__LINE__,"склада не того пр-тия",entr,gnEnt,cPrefDirKta)
       else
         IF val(ltrim(left(time(),2)))>21
           Get_Ftp(cPrefDirKta+IIF(lCdb,"cdb",""),ktar,cDirShared,cFileNameFtp, .T.)
         EndIf
       EndIf
       //
     ENDIF

#ifdef __CLIP__
     set translate path on
#endif
     netuse('cskl')
     netuse('etm')
     netuse('stagtm')
     netuse('s_tag')
     DBGoTo(nRec_s_tag)

     sele s_tag
     skip
  endd
  //fromkpk()
  set print to

  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  01-18-07 10:13am
 НАЗНАЧЕНИЕ......... получени торговых точек по ТА
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION kta_kln(nRun,ktar,lCrtt)
  LOCAL cktar
     cktar:=PADL(LTRIM(STR(ktar,3)), 3, "0")

  IF EMPTY(lCrtt)
     cktar:=PADL(LTRIM(STR(ktar,3)), 3, "0")
     USE ("k"+cktar+"ost") ALIAS price_full NEW EXCLUSIVE
     USE ("k"+cktar+"ot") ALIAS price NEW EXCLUSIVE

    // Точки,плательщики
    crtt('tempt',;
    'f:kgp c:n(7)  f:kpl c:n(7) f:okpo c:n(10) f:ngp c:c(50) '+;
    'f:npl c:c(50) f:agp c:c(50) f:RouteTime c:c(7) f:kgpcat c:n(2) '+;
    'f:apl c:c(50) f:telPl c:c(50) f:telGp c:c(50) '+;
    'f:ndog c:n(6) f:dtdogb c:d(10) f:dogpl c:d(10) '+;
    'f:discount c:n(6,2) '+;
    'f:dnl c:d(10) f:dol c:d(10) f:serlic c:c(4) f:numlic c:n(12) f:lic c:n(1) '+;
    'f:codelist c:c(128) f:pricetypes c:c(128) f:gpslat c:c(10) f:gpslon c:c(10) ')

    crtt('tempcenp','f:kpl c:n(7) f:mntov c:n(7) f:mntovt c:n(7) f:cenpr c:n(12,3) f:discount c:n(6,2)')

    /*
    IF !FILE('tempcenp'+'.dbf')
      crtt('tempcenp','f:kpl c:n(7) f:mntov c:n(7) f:cenpr c:n(12,3) f:discount c:n(6,2)')
    ENDIF
    IF !FILE('tempcenp'+'.cdx')
      use tempcenp EXCLUSIVE NEW
      INDEX ON DELETED() TAG t1
      CLOSE
    ENDIF

    sele 0
    use tempcenp EXCLUSIVE
    SET INDEX TO tempcenp
    DELETE ALL
    //INDEX ON DELETED() TAG t1
    */
    sele 0
    use tempcenp EXCLUSIVE

    sele 0
    use tempt EXCLUSIVE

    IF !EMPTY(nRun) .OR. .NOT. FILE('k'+cktar+'pcen.dbf')
      sele stagtm
      if netseek('t1','ktar')
        i:=0
        sele stagtm
        do while kta=ktar
          tmestor:=tmesto
          sele etm
          IF netseek('t1','tmestor')

            kgpr:=kgp //торг точка
            kplr:=kpl // плательщик(клиент)

            //маршут
            (i++,i:=IIF(i>6,1,i))
            i:=7 //что без маршута на Воскр
            RouteTimer:=IIF(EMPTY(stagtm->wmsk),STUFF(SPACE(7),i,1,"1"),stagtm->wmsk)  //!!
            // end  маршут //

            // данные по (плательщику) клиенту
            sele kln
            IF netseek('t1','kplr')
              okpor=kkl1
              nplr=nkl
              aplr=adr
              telPlr=tlf
            ELSE
              okpor=kplr
              nplr='Нет в справ. '+STR(kplr)
              aplr=STR(kplr)
              telPlr=STR(kplr)
            ENDIF

            sele kpl
            netseek('t1','kplr')
            codelistr:=codelist
            IF EMPTY(codelist)
              codelistr:="169,161,160,129,139"
            ENDIF

            //договор
            NDogr=getfield('t1','kplr','klndog','NDog')
            dtDogBr=getfield('t1','kplr','klndog','dtDogB')
            dogPlr=getfield('t1','kplr','klndog','dtDogE')
            IF (IIF(gnEnt=21,dogPlr < DATE(),.F.)) .OR. ;  //,.F.<-отключено, просроченный договор
               kplr=20034

              codelistr:="169,129,139" // 169 - он 4-тый в списке!

              /*
              #ifdef DEBUG
                outlog(__FILE__,__LINE__,ktar,kgpr,kplr,dogPlr,"//просроченный договор")
              #endif
                sele stagtm
                DBSkip()
                LOOP
              */
            ENDIF
            //end  = данные по (плательщику) клиенту //

            ////         персональные цены     //
            lPersonalPrice:=.F. //персональные цены
            lDiscountFist:=.F.  //первый признак не нулевай скидки
            nDiscountFist:=0    //заначение первой  не нулевой скидки

            sele price
            DBGOTOP()
            DO WHILE !EOF()
              discountr:=kkl_discount(kplr,price->Izg,price->MnTov)*(-1)
              IF !lDiscountFist
                IF discountr # 0 //есть скидка
                  lDiscountFist:=.T.
                  nDiscountFist:=discountr
                ENDIF
              ELSE //следующие значение скидки
                IF ROUND(discountr-nDiscountFist,2)#0
                  //разные скидки в по одному клиенту
                  lPersonalPrice:=.T.
                  EXIT
                ENDIF
              ENDIF
              sele price
              DBSKIP()
            ENDDO

            IF lPersonalPrice
              //формирование индивидуалный не нулеый цен
              sele price
              DBGOTOP()
              DO WHILE !EOF()
                discountr:=kkl_discount(kplr,price->Izg,price->MnTov)*(-1)
                IF !EMPTY(discountr)
                  sele tempcenp
                  netadd(1)
                  netrepl("kPl,mntov,mntovt",{kPlr,price->mntov,price->mntovt})
                  netrepl("discount",{discountr})
                  //netrepl("cenp",{cenpr})
                ENDIF
                sele price
                DBSKIP()
              ENDDO
              discountr:=999
            ELSE // нулевая или одна
              discountr:=kkl_discount(kplr,price->Izg,price->MnTov)*(-1)
            ENDIF
            //end   персональные цены     //

            // данные по торговой точке //
            sele kln
            IF netseek('t1','kgpr')
              ngpr=nkl
              agpr=adr
              telGpr=tlf
              //dolr:=klnlic->(DtLic(kplr, kgpr, 2,2499404)) // 2 - лицензия алкоголь
              dolr:=klnlic->(DtLic(kplr, kgpr, 2)) // 2 - лицензия алкоголь
              If empty(dolr) .or. date() - dolr > 180
                klnlic->(DBGoBottom())
                klnlic->(DBSkip())
              EndIf

              /*if kplr=2499404
                outlog(__FILE__,__LINE__,empty(dolr),  date() - dolr,dolr,kgpr)
                outlog(__FILE__,__LINE__,klnlic->dnl,klnlic->dol,klnlic->(eof()))
              endif */

              dnlr:=klnlic->dnl
              dolr:=klnlic->dol
              serlicr:=klnlic->serlic
              numlicr:=klnlic->numlic
              licr:=klnlic->lic
              gpslatr := gpslat
              gpslonr := gpslon
            ELSE
              ngpr='Нет в справ.'+STR(kgpr)
              agpr=STR(kgpr)
              telGpr=STR(kgpr)
            ENDIF

            sele kgp
            netseek('t1','kgpr')
            kgpcatr=kgpcat

            //end  данные по торговой точке //

            // добавление в таблицу
            sele tempt
            netadd()
            netrepl("kGp,kPl,nGp,aGp,telGp,RouteTime,okpo,nPl,aPl,telPl,dogPl,discount",{kGpr,kPlr,nGpr,aGpr,telGpr,RouteTimer,okpor,nPlr,aPlr,telPlr,dogPlr,discountr})
            netrepl("codelist",{codelistr})
            netrepl("kgpcat",{kgpcatr})
            netrepl("NDog,dtDogB",{NDogr,dtDogBr})
            netrepl("dnl,dol, serlic,numlic,lic",{dnlr,dolr,serlicr,numlicr,licr})
            netrepl(' gpslat,gpslon',{ gpslatr,gpslonr})
                        //end добавление в таблицу

          endif

          sele stagtm
          skip
        enddo
      endif
    ENDIF
    sele tempt
    copy to ('k'+cktar+'firm.dbf')
    use

    sele tempcenp
    copy to ('k'+cktar+'pcen.dbf') for !DELETED()
    use
    CLOSE price
    CLOSE price_full

  ELSE
  ENDIF

    IF FILE("k"+cktar+"firm"+".cdx")
      ERASE ("k"+cktar+"firm"+".cdx")
    ENDIF
    USE ("k"+cktar+"firm") ALIAS TPoints NEW EXCLUSIVE
    INDEX ON kgp TAG kgp
    CLOSE

  RETURN

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-27-06 * 03:25:26pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION kkl_discount(nKpl,nIzg,nMnTov)
  LOCAL nSelect
  LOCAL nPrZenPr

  nPrZenPr:=0
  nSelect:=SELECT()

  nKklr:=nKpl
  Izgr:=nIzg
  kgrr:=int(nMnTov/10^(7-3)) //0000000

  sele klnnac
  IF !NetSeek('t1','nKklr,izgr')   //нет такого изготовителя
    nPrZenPr=0
  ELSE            //изготовитель такой есть!!!
    sele klnnac
    IF !NetSeek("t1", "nKklr, Izgr, 999")
      nPrZenPr=0
    else
      nPrZenPr=nac
    endif
    if nPrZenPr=0
      if netseek("t1", "nKklr, Izgr, kgrr")
        nPrZenPr=nac
      endif
    endif
  ENDIF

  SELECT (nSelect)

  RETURN (nPrZenPr)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-10-06 * 10:13:05am
 НАЗНАЧЕНИЕ......... получение остатков по ТА
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION kta_ost(nRun,ktar,ktasr, lCrtt)
  LOCAL cKtar
  LOCAL lNext

  //#define DEBUG

  cktar:=PADL(LTRIM(STR(ktar,3)), 3, "0")

  IF EMPTY(lCrtt)
    cktar:=PADL(LTRIM(STR(ktar,3)), 3, "0")

    //crea table tmp006 (sk n(3),mntov n(7),mkeep n(3),nat c(40),nei c(5),osv n(12,3),cenpr n(12,3))
    crtt('tmp006','f:sk c:n(3) f:mntov c:n(7) f:mntovt c:n(7) f:izg c:n(7) f:mkeep c:n(3) f:nmkeep c:c(20) f:nat c:c(40) f:nei c:c(5) f:upak c:n(10,3) f:osv c:n(12,3) f:cenpr c:n(12,3) f:cenps c:n(12,3) f:c29 c:n(12,3) f:merch c:n(1,0) f:ves c:n(10,3) f:proplist c:c(128)')
    use tmp006 new EXCLUSIVE

    IF !EMPTY(nRun)
      sele cskl
      DBGOTOP()
      DO WHILE !EOF()
        IF ent#gnEnt .OR. !(rasc=1.or.rasc=2) .OR.;
        IIF(gnEntrm=0, rm#0, rm#1)
          skip;        loop
        ENDIF

        skr=sk
        sklr=skl

        pathr=gcPath_d+alltrim(path)
        if !netfile('tovm','1')
          skip;        loop
        endif

        netuse('tovm',,,1)

        sele ctov
        DBGOTOP()
        DO WHILE !EOF()
          mkeepr=mkeep

          lNext:=.F.
          DO CASE
          CASE Merch = 0
            lNext:=.T.
          CASE !(netseek('t1','ktar','stagm')) //не нашел ТА-МаркоД.
            //ищем по СУППЕРУ
            IF !(netseek('t1','ktasr,mkeepr','stagm')) //не нашел по СУППЕРУ
              lNext:=.T.
            ENDIF
          CASE !(netseek('t1','ktar,mkeepr','stagm')) //не нашел по ТА
            lNext:=.T.
          ENDCASE

          IF lNext
            #ifdef DEBUG
            outlog(__FILE__,__LINE__,"netseek('t1','ktasr,mkeepr','stagm')", ktasr,mkeepr)
            outlog(__FILE__,__LINE__,Merch,mntov,nat,"Merch,mntov,nat")
            #endif
            sele ctov
            DBSKIP();  LOOP
          ENDIF


          mntovr=mntov
          mntovtr=mntovt

          sele tovm
          IF !netseek("t1","sklr,mntovr",,,1)
            #ifdef DEBUG
            outlog(__FILE__,__LINE__,'tovm->(netseek("t1","sklr,mntovr"))',"not found",ctov->mntov,ctov->nat)
            #endif
          ENDIF

          PropListr:=ctov->nam

          vesr:=ctov->ves
          merchr:=ctov->merch
          izgr=ctov->izg
          nmkeepr=getfield("t1","mkeepr","mkeep","nmkeep")
          neir=ctov->nei
          natr=ctov->nat

          osvr=tovm->osv+tovm->osvo

          CenPsr:=ROUND(ctov->CenPs * ((gnNds/100)+1), 2) //цена втч НДС
          CenPrr:=ROUND(ctov->CenPr * ((gnNds/100)+1), 2) //цена втч НДС
          c29r:=ROUND(ctov->c29 * ((gnNds/100)+1), 2) //цена втч НДС

          upakr:=IIF(ctov->upak=0,1,ctov->upak)

          sele tmp006
          locate for mntovr=mntov
          //locate for mntovtr=mntovt
          IF !FOUND()
            netadd()
          ELSE
            osvr+=tmp006->osv
          ENDIF
          netrepl('sk,mntov,mntovt,izg,mkeep,nmkeep,nat,nei,upak,osv,cenpr,CenPs,c29,merch,ves,PropList',;
                  'skr,mntovr,mntovtr,izgr,mkeepr,nmkeepr,natr,neir,upakr,osvr,cenprr,CenPsr,c29r,merchr,vesr,PropListr')

          sele ctov
          DBSKIP()
        ENDDO

        nuse('tovm')
        SELE cskl
        DBSKIP()
      ENDDO
    ENDIF

    sele tmp006
    INDEX ON STR(mntovt) TAG mntovt
    TOTAL ON STR(mntovt) FIELDS osv TO tmp006ot
    INDEX ON STR(mkeep)+Nat TAG nat
    //CLOSE ("k"+cktar+"ost")
    COPY TO ("k"+cktar+"ost.dbf")
    CLOSE tmp006
    ERASE tmp006.cdx

    USE tmp006ot NEW
    INDEX ON STR(mkeep)+Nat TAG nat
    COPY TO ("k"+cktar+"ot.dbf")
    CLOSE tmp006ot
    ERASE tmp006ot.cdx

  ELSE
  ENDIF

    USE ("k"+cktar+"ost") ALIAS price NEW EXCLUSIVE
    IF FILE("k"+cktar+"ost"+".cdx")
      ERASE ("k"+cktar+"ost"+".cdx")
    ENDIF
    INDEX ON mntov TAG mntov
    CLOSE

    IF FILE("k"+cktar+"ot"+".dbf")
      USE ("k"+cktar+"ot") ALIAS price NEW EXCLUSIVE
      IF FILE("k"+cktar+"ot"+".cdx")
        ERASE ("k"+cktar+"ot"+".cdx")
      ENDIF
      INDEX ON mntov TAG mntov
      CLOSE
    ELSE
      kta_ost(1,ktar,ktasr, NIL)
    ENDIF


  RETURN NIL

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-10-06 * 02:11:37pm
 НАЗНАЧЕНИЕ......... продажи
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION kta_sales(nRun, ktar, ktasr, dShDateBg, dShDateEnd, lMerch)
  LOCAL cktar:=PADL(LTRIM(STR(ktar,3)), 3, "0")
  LOCAL bSkipSkl, cFileDbf, dCurDate, bSkip_gdTd

  //DEFAULT dShDateEnd TO date()-1
  //DEFAULT dShDateBg TO dShDateEnd-(7*4)
  dShDateEnd:=LastMonday(dShDateEnd)+7-2
  dSHDATEBG:=LastMonday(dSHDATEBG)
  #ifdef __CLIP__
  DEFAULT lMerch TO .F.
  IF lMerch
    //bSkipSkl:={ || !(STR(sk) $ "241 ") }//список мерч складов
    bSkipSkl:={ || !(sk == ngMerch_Sk241) }//мерч склад
    cFileDbf:=('k'+cktar+'mrch.dbf')
  ELSE
    bSkipSkl:={||;
              ent#gnEnt .OR. rasc#1 .OR.;
              IIF(gnEntrm=0, rm#0, rm#1);
               }
    cFileDbf:=('k'+cktar+'sale.dbf')
  ENDIF
  #endif

  USE ("k"+cktar+"ost") ALIAS price NEW EXCLUSIVE
  SET ORDER TO TAG mntov

  USE ("k"+cktar+"firm") ALIAS TPoints NEW EXCLUSIVE
  SET ORDER TO TAG kgp

  if select('temps')#0
     sele temps
     use
  endif
  erase temps.dbf
  crtt('temps','f:sk c:n(3) f:ttn c:n(6) f:kta c:n(4) f:sdv c:n(10,2) f:kop  c:n(3) f:kpl c:n(7) f:kgp c:n(7) f:prz c:n(1) f:dop c:d(10) f:mntov c:n(7) f:mntovt c:n(7) f:ktl c:n(9) f:kvp c:n(10,3) f:zen c:n(10,3) f:svp c:n(10,2)')
  sele 0
  use temps

  IF !EMPTY(nRun)

    dt2r=gdTd
    dt1r=addmonth(gdTd,-1)
    for yyr=year(dt1r) to year(dt2r)
      do case
          case year(dt1r)=year(dt2r)
              mm1r=month(dt1r)
              mm2r=month(dt2r)
          case yyr=year(dt1r)
              mm1r=month(dt1r)
              mm2r=12
          case yyr=year(dt2r)
              mm1r=1
              mm2r=month(dt2r)
          othe
              mm1r=1
              mm2r=12
      endc
      for mmr=mm1r to mm2r
          dCurDate:=STOD(str(yyr,4)+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+"01")
          path_dr=gcPath_e+'g'+str(yyr,4)+'\m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'
          sele cskl
          go top
          do while !eof()

            IF EVAL(bSkipSkl)
              skip;        loop
            ENDIF

            pathr=path_dr+alltrim(path)

            if !netfile('tovm',1)
                sele cskl
                skip
                loop
            endif

            skr=sk
            netuse('rs1','rs1','',1)
            netuse('rs2','rs2','',1)

            // список свернутых ВНК
            sele rs1
            copy field ttn, kop, KolPos, pr129,pr139,pr169,pr177,ttnt, text ;
              for !EMPTY(rs1->KolPos)  ;
                .and.(;
                rs1->(pr129+pr139+pr169+pr177 = 2) ;
                .or. (gnEnt=21 .and. rs1->ttnt=999999) ;// kop=151
                   ) ;
              to tempUcPt
            use tempUcPt new alias PathTtnUc Exclusive
            //пути к свернутым до-кам
            repl all text with ;
            PathTtnUc(PathTtnUc->Ttn,cskl->path,dCurDate,PathTtnUc->Kop,gcPath_ew)
            // путь обычный склад
            DBAppend()
            repl text with pathr
            copy to ('tmp'+allt(str(skr,3))+str(mmr,2))

            close rs1
            close rs2

            sele  PathTtnUc
            DBGoTop()
            Do While !eof()
              pathr:= allt(PathTtnUc->text)

              if (netfile('rs1', 1))
                netuse('rs1','rs1','',1)
                netuse('rs2','rs2','',1)

                IF lMerch
                  bSkip_gdTd:={|| BOM(dCurDate)#BOM(dop) }
                ELSE
                  bSkip_gdTd:={||IIF(BOM(dCurDate)=BOM(gdTd), .F., prz#1)}
                ENDIF

                sele rs1
                DBGOTOP()
                DO WHILE !EOF()
                  // Iif(ttn=468696,outlog(__FILE__,__LINE__, 'ttn=468696'),)
                  dopr=iif(empty(dop),dot,dop) //dop
                  IF EVAL(bSkip_gdTd);
                    .or. vo#9 .or. EMPTY(dopr) ;
                    .or. !(dopr >= dShDateBg .AND. dopr <= dShDateEnd) ;//период анализа
                    .or. rs1->(pr129+pr139+pr169+pr177 = 2) ; // пропуск свернутых
                    .or. !TPoints->(DBSEEK(rs1->kpv))

                    //док не нужен
                    skip; loop
                  ENDIF
                  //outlog(__FILE__,__LINE__, ttn)
                  // Iif(ttn=468696,outlog(__FILE__,__LINE__, 'ttn=468696'),)

                  //данные из шапки
                  ttnr=ttn
                  ktar:=kta
                  kplr=nkkl
                  kgpr=kpv
                  kopr=kopi
                  przr=prz
                  dopr=dop
                  sdvr=sdv

                  sele rs2
                  IF netseek('t1','ttnr')
                    DO WHILE ttnr=ttn
                      mntovr=mntov
                      IF price->(DBSEEK(mntovr)) //!! должно быть в прайсах постоянно
                        mntovr=mntov
                        mntovtr=price->mntovt
                        ktlr=ktl
                        kvpr=kvp
                        zenr=zen
                        svpr=svp
                        sele temps
                        netadd()
                        netrepl('sk,ttn,kta,kpl,kgp,kop,prz,dop,sdv,mntov,mntovt,ktl,kvp,zen,svp',;
                                'skr,ttnr,ktar,kplr,kgpr,kopr,przr,dopr,sdvr,mntovr,mntovtr,ktlr,kvpr,zenr,svpr')

                      ENDIF
                      sele rs2
                      skip

                    ENDDO
                  ENDIF
                  sele rs1
                  SKIP
                ENDDO

                nuse('rs1')
                nuse('rs2')
              endif
              sele  PathTtnUc
              DBSkip()
            EndDo
            close PathTtnUc
            //

            sele cskl
            skip
          endd
      next
    next
  ENDIF
  sele temps
  index on STR(KGP)+STR(MNTOV)+DTOS(dop) TAG KgpMnTov
  //use
  copy to (cFileDbf)
  use
  ERASE temps.cdx

  CLOSE price
  CLOSE TPoints

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-13-06 * 10:59:50am
 НАЗНАЧЕНИЕ......... состояние документы
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ......... с .... даты до текущей даты
 */
FUNCTION rs1_Confirm(ktar,ktasr, dShDateBg, dShDateEnd)
  LOCAL cktar:=PADL(LTRIM(STR(ktar,3)), 3, "0")
  LOCAL cTimeCrt

  dShDateEnd:=DATE()
  dShDateBg:=dShDateEnd-14

  USE ("k"+cktar+"firm") ALIAS TPoints NEW EXCLUSIVE
  SET ORDER TO TAG kgp

  crtt('temps','f:sk c:n(3) f:ttn c:n(6) f:kpl c:n(7) f:kgp c:n(7) f:kta c:n(4) f:dfp c:d(10) f:dsp c:d(10) f:dtot c:d(10) f:prz c:n(1) f:dop c:d(10)  f:DocGUID c:c(36)') //f:dot c:d(10)
  sele 0
  use temps

  dt2r=gdTd
  dt1r=addmonth(gdTd,-1)
  for yyr=year(dt1r) to year(dt2r)
      do case
         case year(dt1r)=year(dt2r)
              mm1r=month(dt1r)
              mm2r=month(dt2r)
         case yyr=year(dt1r)
              mm1r=month(dt1r)
              mm2r=12
         case yyr=year(dt2r)
              mm1r=1
              mm2r=month(dt2r)
         othe
              mm1r=1
              mm2r=12
      endc
      for mmr=mm1r to mm2r
          path_dr=gcPath_e+'g'+str(yyr,4)+'\m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'
          sele cskl
          go top
          do while !eof()

             IF ent#gnEnt .OR. ;
                ;//rasc#1 .OR.;
              IIF(gnEntrm=0, rm#0, rm#1)
                skip;        loop
             ENDIF

            pathr=path_dr+alltrim(path)
            if !netfile('tovm',1)
               sele cskl
               skip
               loop
            endif
            skr=sk
            netuse('rs1','','',1)
            sele rs1
            DBGoTop()
            do while !eof()

              cTimeCrt:=TimeCrt
              dDateCrt:=STUFF(LEFT(cTimeCrt,10),5,1,"")
              dDateCrt:=STUFF(dDateCrt,7,1,"")
              dDateCrt:=STOD(LEFT(dDateCrt,8))

              /*IF ttn=30711
     #ifdef __CLIP__
              outlog(__FILE__,__LINE__,dDateCrt,ttn,"vo",vo,"sdv",sdv,"kpv",kpv,TPoints->(DBSEEK(rs1->kpv)),dDateCrt)
    #endif
              endif
              */

              IF vo#9 .OR. ;//sdv=0 .or. ;
                kta#ktar .OR. ; //для этого торгового агета
                .F. .or. ;//!TPoints->(DBSEEK(rs1->kpv)) .or. ; //есть точка для этого агента
                ;//период анализа
                .not. (dDateCrt >= dShDateBg .AND. dDateCrt <= dShDateEnd)
                skip
                loop
              endif


               ttnr    :=ttn
               DocGUIDr:=DocGUID
               kplr    :=kpl
               kgpr    :=kgp
               ktar    :=kta
               dopr    := dop
               dotr    := dot
               przr    := prz
               dfpr    := dfp
               dspr    := dsp
               dtotr   := dtot

               sele temps

               netadd()
               netrepl('sk,ttn,DocGUID,kpl,kgp,kta,dop,prz,dfp,dsp,dtot',; //dot,
                        'skr,ttnr,DocGUIDr,kplr,kgpr,ktar,dopr,przr,dfpr,dspr,dtotr') //dotr,

               sele rs1
               skip
            endd
            nuse('rs1')
            nuse('rs2')
            sele cskl
            skip
          endd
      next
  next
  sele temps
  copy to ('k'+cktar+'cnfr.dbf')
  use
  erase  temps.dbf
  CLOSE TPoints

  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-15-06 // 03:54:57pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Put_Ftp(cPrefDirKta,ktar,cDirShared)
  LOCAL hdr
  LOCAL cktar:=PADL(LTRIM(STR(ktar,3)), 3, "0")
  // Удаление файлов
  erase files.txt
  //erase hosts.txt

  // Создание файлов
  hdr:=fcreate('files.txt')
     fwrite(hdr,'l2r '+"./From1C.zip "+ "./" + cPrefDirKta+cktar +"/.")
  fclose(hdr)

  hdr=fcreate('hosts.txt')
     fwrite(hdr,'10.0.1.101')
  fclose(hdr)

  hdr=fcreate('commands.txt')
     fwrite(hdr,'/bin/mkdir -p '+ cPrefDirKta+cktar)
  fclose(hdr)

  #ifdef __CLIP__
   cLogSysCmd:=""
   cCmd:=;
   "rm -f "         +cDirShared+"/From1C.zip; "+;
   "cp ./From1C.zip "+cDirShared+"/From1C.zip"
   SYSCMD(cCmd,"",@cLogSysCmd)
   IF !EMPTY(cLogSysCmd)
     qOUT(__FILE__,__LINE__,cLogSysCmd,cCmd)
   ENDIF


   cLogSysCmd:=""
   cCmd:=;
   "rm -f "         +cDirShared+"/files.txt; "+;
   "cp ./files.txt "+cDirShared+"/files.txt"
   SYSCMD(cCmd,"",@cLogSysCmd)
   IF !EMPTY(cLogSysCmd)
     qOUT(__FILE__,__LINE__,cLogSysCmd,cCmd)
   ENDIF

   cLogSysCmd:=""
   cCmd:=;
   "rm -f "         +cDirShared+"/hosts.txt; "+;
   "cp ./hosts.txt "+cDirShared+"/hosts.txt"
   //SYSCMD(cCmd,"",@cLogSysCmd)
   IF !EMPTY(cLogSysCmd)
     qOUT(__FILE__,__LINE__,cLogSysCmd,cCmd)
   ENDIF

   cLogSysCmd:=""
   cCmd:=;
   "rm -f "         +cDirShared+"/commands.txt; "+;
   "cp ./commands.txt "+cDirShared+"/commands.txt"
   SYSCMD(cCmd,"",@cLogSysCmd)
   IF !EMPTY(cLogSysCmd)
     qOUT(__FILE__,__LINE__,cLogSysCmd,cCmd)
   ENDIF

   cLogSysCmd:=""
   cCmd:="/usr/bin/super scp_saha_ftp"
   SYSCMD(cCmd,"",@cLogSysCmd)
   IF !EMPTY(cLogSysCmd)
     qOUT(__FILE__,__LINE__,cLogSysCmd,cCmd)
   ENDIF
  #endif

  retu .t.

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-16-06 * 04:36:56pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Get_Ftp(cPrefDirKta, ktar, cDirShared, cFile, lErase)
  LOCAL hdr
  LOCAL cktar:=PADL(LTRIM(STR(ktar,3)), 3, "0")

  // Удаление файлов
  erase files.txt
  //erase hosts.txt

  // Создание файлов
  hdr:=fcreate('files.txt')
  IF !EMPTY(lErase)
     fwrite(hdr,'#')
  ELSE
     fwrite(hdr,'r2l '+"./" + cPrefDirKta+cktar +"/"+ cFile +" "+ ".")
  ENDIF
  fclose(hdr)

  hdr=fcreate('hosts.txt')
     fwrite(hdr,'10.0.1.101')
  fclose(hdr)

  hdr=fcreate('commands.txt')
  IF !EMPTY(lErase)
     fwrite(hdr,'rm -f '+"./" + cPrefDirKta+cktar +"/"+ cFile)
  ELSE
     fwrite(hdr,'#')
  ENDIF
  fclose(hdr)


  #ifdef __CLIP__
   cLogSysCmd:=""
   cCmd:=;
   "rm -f "         +cDirShared+"/files.txt; "+;
   "cp ./files.txt "+cDirShared+"/files.txt"
   SYSCMD(cCmd,"",@cLogSysCmd)
   IF !EMPTY(cLogSysCmd)
     qOUT(__FILE__,__LINE__,cLogSysCmd,cCmd)
   ENDIF

   cLogSysCmd:=""
   cCmd:=;
   "rm -f "         +cDirShared+"/hosts.txt; "+;
   "cp ./hosts.txt "+cDirShared+"/hosts.txt"
   //SYSCMD(cCmd,"",@cLogSysCmd)
   IF !EMPTY(cLogSysCmd)
     qOUT(__FILE__,__LINE__,cLogSysCmd,cCmd)
   ENDIF

   cLogSysCmd:=""
   cCmd:=;
   "rm -f "         +cDirShared+"/commands.txt; "+;
   "cp ./commands.txt "+cDirShared+"/commands.txt"
   SYSCMD(cCmd,"",@cLogSysCmd)
   IF !EMPTY(cLogSysCmd)
     qOUT(__FILE__,__LINE__,cLogSysCmd,cCmd)
   ENDIF

   cLogSysCmd:=""
   cCmd:=;
   "rm -f "+"./"+cPrefDirKta+cktar+"/"+cFile+"; "+;
   "rm -f "+cDirShared+"/"+cFile
   SYSCMD(cCmd,"",@cLogSysCmd)
   IF !EMPTY(cLogSysCmd)
     qOUT(__FILE__,__LINE__,cLogSysCmd,cCmd)
   ENDIF


   cLogSysCmd:=""
   cCmd:="/usr/bin/super scp_saha_ftp"
   SYSCMD(cCmd,"",@cLogSysCmd)
   IF !EMPTY(cLogSysCmd)
     qOUT(__FILE__,__LINE__,REPLICATE("#",40))
     qOUT(__FILE__,__LINE__,cLogSysCmd,cCmd)
   ENDIF

   cLogSysCmd:=""
   cCmd:=;
   "rm -f "+"./"+cPrefDirKta+cktar+"/"+cFile+"; "+;
   "cp "+cDirShared+"/"+cFile+" ./"+cPrefDirKta+cktar+"/"+cFile+"; "+;
   "rm -f "+cDirShared+"/"+cFile
   SYSCMD(cCmd,"",@cLogSysCmd)
   IF !EMPTY(cLogSysCmd)
     qOUT(__FILE__,__LINE__,cLogSysCmd,cCmd)
   ENDIF
  #endif

  retu .t.


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-10-06 * 10:11:08am
 НАЗНАЧЕНИЕ......... получени торговых точек по ТА
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION kta_kln_alias_kplkgp(nRun,ktar)
  LOCAL cktar:=PADL(LTRIM(STR(ktar,3)), 3, "0")

  USE ("k"+cktar+"ost") ALIAS price NEW EXCLUSIVE

  // Точки,плательщики
  //crtt('tempt','f:kgp c:n(7) f:ngp c:c(30) f:kpl c:n(7) f:npl c:c(30)')
  crtt('tempt','f:kgp c:n(7) f:kpl c:n(7) f:okpo c:n(10) f:ngp c:c(50) f:npl c:c(50) f:agp c:c(50) f:RouteTime c:c(7) f:apl c:c(50) f:telPl c:c(50) f:telGp c:c(50) f:dogpl c:d(10) f:discount c:n(6,2)')
  crtt('tempcenp','f:kpl c:n(7) f:mntov c:n(7) f:mntovt c:n(7) f:cenpr c:n(12,3) f:discount c:n(6,2)')

  sele 0
  use tempcenp
  sele 0
  use tempt

  IF !EMPTY(nRun)
    sele stagt
    if netseek('t1','ktar')
       i:=0
       do while kta=ktar

          kgpr=kgp
          kplr=getfield('t4','ktar,kgpr','kplkgp','kpl')
          IF EMPTY(kplr)
            sele stagt
            skip
          ENDIF

          (i++,i:=IIF(i>6,1,i))
          i:=7 //что без маршута на Воскр
          RouteTimer:=IIF(EMPTY(wmsk),STUFF(SPACE(7),i,1,"1"),wmsk)  //!!

          sele kln
          netseek('t1','kplr')
          okpor=kkl1
          nplr=nkl
          aplr=adr
          telPlr=tlf
          //договор
          dogPlr=getfield('t1','kplr','klndog','dtDogE')



          lPersonalPrice:=.F. //персональные цены
          lDiscountFist:=.F.  //первый признак не нулевай скидки
          nDiscountFist:=0    //заначение первой  не нулевой скидки

          sele price
          DBGOTOP()
          DO WHILE !EOF()
            discountr:=kkl_discount(kplr,price->Izg,price->MnTov)*(-1)
            IF !lDiscountFist
              IF discountr # 0 //есть скидка
                lDiscountFist:=.T.
                nDiscountFist:=discountr
              ENDIF
            ELSE //следующие значение скидки
              IF ROUND(discountr-nDiscountFist,2)#0
                //разные скидки в по одному клиенту
                lPersonalPrice:=.T.
                EXIT
              ENDIF
            ENDIF
            sele price
            DBSKIP()
          ENDDO

          IF lPersonalPrice
            //формирование индивидуалный не нулеый цен
            sele price
            DBGOTOP()
            DO WHILE !EOF()
              discountr:=kkl_discount(kplr,price->Izg,price->MnTov)*(-1)
              IF !EMPTY(discountr)
                sele tempcenp
                netadd()
                netrepl("kPl,mntov,mntovt",{kPlr,price->mntov,price->mntovt})
                netrepl("discount",{discountr})
                //netrepl("cenp",{cenpr})
              ENDIF
              sele price
              DBSKIP()
            ENDDO
            discountr:=999
          ELSE // нулевая или одна
            discountr:=kkl_discount(kplr,price->Izg,price->MnTov)*(-1)
          ENDIF



          sele kln
          netseek('t1','kgpr')

          ngpr=nkl
          agpr=adr
          telGpr=tlf

          sele tempt
          netadd()
          netrepl("kGp,kPl,nGp,aGp,telGp,RouteTime,okpo,nPl,aPl,telPl,dogPl,discount",{kGpr,kPlr,nGpr,aGpr,telGpr,RouteTimer,okpor,nPlr,aPlr,telPlr,dogPlr,discountr})

          sele stagt
          skip
       endd
    endif
  ENDIF
  sele tempt
  copy to ('k'+cktar+'firm.dbf')
  use

  sele tempcenp
  copy to ('k'+cktar+'pcen.dbf')
  use


  USE ("k"+cktar+"firm") ALIAS TPoints NEW EXCLUSIVE
  IF FILE("k"+cktar+"firm"+".cdx")
    ERASE ("k"+cktar+"firm"+".cdx")
  ENDIF
  INDEX ON kgp TAG kgp
  CLOSE

  CLOSE price
  CLOSE price_full

  RETURN

/*****************************************************************
 */
/*****************************************************************
 */

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  09-04-08 * 09:16:17am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Accord_Rs1(dShDateBg, dShDateEnd,cAliasDokk,aKop,  d_Ddk, cTypeDocPP)
  LOCAL nPos_AKop
  LOCAL nRecNo, n_Sk, n_Rn, n_Sdv, nBs_S, nSum
  LOCAL d_odate, dTtnDt, d_oper_date, nKop, cCode, cNmCode

  nSum:=0

   netuse('cskl')
   netuse('rmsk')
   netuse('kln')
   netuse('knasp')
   netuse('opfh')
   netuse('s_tag')
   netuse('nap')
   netuse('ktanap')

   netuse('etm')

  SET DATE FORMAT "dd.mm.yyyy"
  SET CENTURY ON
  //╦╠┴╙╙╔╞╔╦┴╘╧╥ ╘╧╥╧╟╧╫┘╚ ╘╧▐┼╦

  set console off
  set print on
  set print to jornel_shipment.xml
  qqout('<?xml version="1.0" encoding="'+local_charset()+'"?>')
   qout('<root>')

  dt1r:=dShDateBg
  dt2r:=dShDateEnd
  FOR yyr=year(dt1r) to year(dt2r)
      DO CASE
      CASE year(dt1r)=year(dt2r)
        mm1r=month(dt1r)
        mm2r=month(dt2r)
      CASE yyr=year(dt1r)
        mm1r=month(dt1r)
        mm2r=12
      CASE yyr=year(dt2r)
        mm1r=1
        mm2r=month(dt2r)
      OTHE
        mm1r=1
        m2r=12
      ENDC
      for mmr=mm1r to mm2r

        path_dr=gcPath_e+'g'+str(yyr,4)+'\m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'
        pathr=path_dr+"bank\"

        if !netfile('dokk',1)
          loop
        endif

        netuse('operb','','',1)
        If EMPTY(cAliasDokk)
          netuse('dokk','','',1)
        else
          sele (cAliasDokk)
        EndIf
        ordsetfocus("t13")

              IF !FILE("ship.dbf")
                DBCREATE("ship.dbf",{;
                {"SUMMA","N",10,2},;
                {"ND", "C",6,2};
                })
              ELSE
              ENDIF
                USE ship EXCLUSIVE NEW
                ZAP



        sele dokk
        DBGoTop()
        do while !eof()

          n_Sk:=skr:=dokk->sk
          n_Rn:=dokk->rn
          n_Sdv:=0

          LOCATE ;
          FOR bs_d=361001 .AND. mn=0 .AND. mnp=0 ;
          WHILE n_Sk=dokk->sk .AND. n_Rn=dokk->rn

          //отгрузка
          IF found()

            pathr=path_dr+ALLTRIM(getfield("t1","dokk->sk","cskl","path"))

            if netfile('rs1',1)

              netuse('rs1','','',1)

              sele rs1
              IF netseek("t1","dokk->rn") .AND. ;
                ;//(dop >= dShDateBg .AND. dop <= dShDateEnd) .AND. ;
                (dokk->ddk >= dShDateBg .AND. dokk->ddk <= dShDateEnd) .AND. ;
                .T.

                nRecNo:=dokk->(RECNO())
                sele dokk
                SUM BS_S TO nBs_S ;
                FOR bs_d=361001 .AND. mn=0 .AND. mnp=0 ;
                WHILE n_Sk=dokk->sk .AND. n_Rn=dokk->rn

                nSum += nBs_S

                /*
                IF nBs_S#rs1->sdv
                  dokk->(DBGOTO(nRecNo))
                  outlog(__FILE__,__LINE__,nBs_S,rs1->sdv,nBs_S-rs1->sdv,dokk->sk,dokk->rn)
                  dokk->(DBGOTO(nRecNo))
                  //DBEVAL({||outlog(Bs_D,bs_K,Bs_S)},{||.T.},{||n_Sk=dokk->sk .AND. n_Rn=dokk->rn})

                    //outlog(__FILE__,__LINE__,n_Sk=dokk->sk, n_Rn=dokk->rn)
                  DO WHILE n_Sk=dokk->sk .AND. n_Rn=dokk->rn
                    outlog(__FILE__,__LINE__,Bs_D,bs_K,Bs_S)
                    skip
                  ENDDO
                  outlog(__FILE__,__LINE__)
                ENDIF
                */
                dokk->(DBGOTO(nRecNo))

                ship->(DBAPPEND())
                ship->Summa:=nBs_S
                ship->Nd:=LTRIM(STR(rs1->ttn))

                #ifdef __CLIP__
                  If nBs_S<0
                    s:=[error create jornel_shipment.xml Summa < 0 ]+STR(nBs_S)+" TTN "+LTRIM(STR(rs1->ttn))
                    ?s
                    outlog(s)
                  EndIf
                #endif

                sele rs1
                qout('   <jornel_shipment>')

                DEFAULT d_ddk TO dokk->ddk//rs1->dop

                d_odate:= d_ddk
                qout('      <odate>'+DTOC(d_odate)+'</odate>')
                //qout('      <odate>'+DTOC(rs1->dop) + 'T00:00:00'+'</odate>')
                //<!--Дата отгрузки-->

                n_sdv:=nBs_S //rs1->sdv
                qout('      <summa>'+ LTRIM(STR(n_sdv)) +'</summa>')
                //<!--Сумма отгрузки-->

                dTtnDt:=rs1->dop //rs1->ddc //от какой даты накладная
                qout('      <number_order>'+;
                LTRIM(STR(rs1->ttn))+;  // номер ТТН
                "_"+LEFT(DTOC(dTtnDt),6)+RIGHT(DTOC(dTtnDt),2)+; // дата ТТН
                '</number_order>')
                //<!--номер документа-->

                d_oper_date:=rs1->dop //дата отгрузки
                qout('      <oper_date>'+DTOC(d_oper_date)+'</oper_date>')
                //<!--дата документа-->


                //<!--  Код операции-->
                nKop:=dokk->kop
                KopCode(aKop,nKop,@cCode,@cNmCode)
                qout('      <type_payment'+;
                ' name="'+cNmCode+'"'+;
                ' code="'+cCode+'"'+;//<!--Код операции-->
                '>'+;
                cCode+'</type_payment>')
                //<!--Код операции-->
                //outlog(__FILE__,__LINE__,nKop,STR(nKop),PADL(LTRIM(STR(nKop)),3,"0"),nPos_AKop)


                //<!-- Инкогнито  Код операции-->
                nKop:= rs1->kopi
                KopCode(aKop,nKop,@cCode,@cNmCode)
                //ч.з. поиск значения в 3-ем элементе
                qout('      <type_paymenti'+;
                ' name="'+cNmCode+'"'+;
                ' code="'+cCode+'"'+;//<!--Код операции-->
                '>'+;
                cCode+'</type_paymenti>')
                //<!-- Инкогнито  Код операции-->



                //<!--ИНН покупателя-->
                kln->(netseek('t1','dokk->kkl'))
                //kln->(netseek('t1','rs1->kpl'))


                knasp->(netseek('t1','kln->knasp'))
                opfh->(netseek('t1','kln->opfh'))

                nklr:=ATREPL('"',ALLTRIM(kln->nkl),"'")
                nklr  :=ATREPL('\',ALLTRIM(nklr),"/")
                nklr  :=SUBSTR(nklr,AT(" ",nklr)+1)
                nklr  :=IIF(LEFT(nklr,1)="'",SUBSTR(nklr,2),nklr)
                nnaspr:=ATREPL('"',ALLTRIM(knasp->nnasp),"'")
                nnaspr:=ATREPL('\',ALLTRIM(nnaspr),"/")

                adrr  :=ATREPL('"',ALLTRIM(kln->adr),"'")
                adrr  :=ATREPL('\',ALLTRIM(adrr),"/")

                tlfr:=ATREPL('"',ALLTRIM(kln->tlf),"'")

                qout('      <customers'+;
                ' state-form="'+ALLTRIM(opfh->nsopfh)+'"'+;
                ' fullname="'+ALLTRIM(opfh->nsopfh)+" "+ALLTRIM(nklr)+'"' +;//"ООО Рога и копыта"
                ' name="'+ALLTRIM(nklr)+'"' +;//"ООО Рога и копыта"
                ' post_city="'+ALLTRIM(nnaspr)+'"'+ ; //Ижевск
                ' post_street="'+ALLTRIM(adrr)+'"'+ ; //Ижевск
                ' phone="'+ALLTRIM(tlfr)+'"'+ ; //Ижевск
                ' egrpu="'+LTRIM(STR(kln->kkl1))+'"'+ ; //ИНН покупателя
                ' inn_code="'+LTRIM(STR(kln->kkl))+'"'+ ; //код покупателя
                '>'+LTRIM(STR(kln->kkl))+; //183456789321</customers>')
                '</customers>')
                //<!--ИНН покупателя-->



                /////////   <!- Инкогнито -ИНН покупателя-->  //////
                kln->(netseek('t1','dokk->nKkl'))
                //kln->(netseek('t1','rs1->nKkl'))

                knasp->(netseek('t1','kln->knasp'))
                opfh->(netseek('t1','kln->opfh'))
                nklr:=ATREPL('"',ALLTRIM(kln->nkl),"'")
                nklr  :=ATREPL('\',ALLTRIM(nklr),"/")
                nklr  :=SUBSTR(nklr,AT(" ",nklr)+1)
                nklr  :=IIF(LEFT(nklr,1)="'",SUBSTR(nklr,2),nklr)
                nnaspr:=ATREPL('"',ALLTRIM(knasp->nnasp),"'")
                nnaspr:=ATREPL('\',ALLTRIM(nnaspr),"/")

                adrr  :=ATREPL('"',ALLTRIM(kln->adr),"'")
                adrr  :=ATREPL('\',ALLTRIM(adrr),"/")

                tlfr:=ATREPL('"',ALLTRIM(kln->tlf),"'")

                qout('      <customersi'+;
                ' state-form="'+ALLTRIM(opfh->nsopfh)+'"'+;
                ' fullname="'+ALLTRIM(opfh->nsopfh)+" "+ALLTRIM(nklr)+'"' +;//"ООО Рога и копыта"
                ' name="'+ALLTRIM(nklr)+'"' +;//"ООО Рога и копыта"
                ' post_city="'+ALLTRIM(nnaspr)+'"'+ ; //Ижевск
                ' post_street="'+ALLTRIM(adrr)+'"'+ ; //Ижевск
                ' phone="'+ALLTRIM(tlfr)+'"'+ ; //Ижевск
                ' egrpu="'+LTRIM(STR(kln->kkl1))+'"'+ ; //ИНН покупателя
                ' inn_code="'+LTRIM(STR(kln->kkl))+'"'+ ; //код покупателя
                '>'+LTRIM(STR(kln->kkl))+; //183456789321</customers>')
                '</customersi>')
                //////  end <!-- Инкогнито  ИНН покупателя-->




                /*
                etm->(netseek('t1','rs1->tmesto'))
                qout('      <trade_point name="'+;
                ALLTRIM(etm->ntmesto)+'">'+;//Фиг его знает
                PADR(LTRIM(STR(rs1->tmesto)),7,"0")+'</trade_point>')
                //PADR(LTRIM(STR(rs1->kgp)),7,"0")+'</trade_point>')
                */
                //-  Код торговой точки  -
                kln->(netseek('t1','rs1->kgp'))
                nklr:=ATREPL('"',ALLTRIM(kln->nkl),"'")
                nklr  :=ATREPL('\',ALLTRIM(nklr),"/")
                qout('      <trade_point'+;
                ' name="'+ALLTRIM(nklr)+'"'+;//Фиг его знает
                ' code="'+LTRIM(STR(rs1->kgp))+'"'+;//Код торговой точки
                '>'+;
                LTRIM(STR(rs1->kgp))+'</trade_point>')
                //<!-- Код торговой точки-->

                //-  Инкогнито  Код торговой точки  -
                kln->(netseek('t1','rs1->kpv'))
                nklr:=ATREPL('"',ALLTRIM(kln->nkl),"'")
                nklr  :=ATREPL('\',ALLTRIM(nklr),"/")
                qout('      <trade_pointi'+;
                ' name="'+ALLTRIM(nklr)+'"'+;//Фиг его знает
                ' code="'+LTRIM(STR(rs1->kpv))+'"'+;//Код торговой точки
                '>'+;
                LTRIM(STR(rs1->kpv))+'</trade_pointi>')
                //<!-- Инкогнито  Код торговой точки-->


                s_tag->(netseek('t1','rs1->ktas'))
                ktanap->(netseek('t1','rs1->ktas')) //ktanap->nap
                nap->(netseek('t1','ktanap->nap')) //nap->nnap
                qout('      <superviser'+;
                ;//' name="'+ALLTRIM(s_tag->fio)+'"'+;//Суперпиво
                ;//' code="'+PADL(LTRIM(STR(rs1->ktas)),4,"0")+'"'+;//Суперпиво
                ' name="'+ALLTRIM(nap->nnap)+'"'+;//Суперпиво
                ' code="'+PADL(LTRIM(STR(ktanap->nap)),4,"0")+'"'+;//Суперпиво
                '>'+;
                PADL(LTRIM(STR(ktanap->nap)),4,"0")+'</superviser>')
                //<!--Код супервайзера-->



                s_tag->(netseek('t1','rs1->kta'))
                qout('      <commerc_agent'+;
                ' name="'+ALLTRIM(s_tag->fio)+'"'+;//Наливайко Н.Н.
                ' code="'+PADL(LTRIM(STR(rs1->kta)),4,"0")+'"'+;//<!--Код комерческого агента-->
                '>'+;
                PADL(LTRIM(STR(rs1->kta)),4,"0")+'</commerc_agent>')
                //<!--Код комерческого агента-->

                rmskr:=gnEnt*10+rs1->rmsk
                IF rs1->rmsk = 0 // основное предприятие
                  setup->(__dbLocate({|| setup->Ent = gnEnt }))
                  nrmskr:=setup->uss
                ELSE
                  rmsk->(__dbLocate({|| rmsk->rmsk = rs1->rmsk }))
                  nrmskr:=rmsk->nrmsk
                ENDIF

                qout('      <department'+;
                ' name="'+ALLTRIM(nrmskr)+'"'+;//Второй
                ' code="'+PADL(LTRIM(STR(rmskr)),3,"0")+'"'+;//<!--Код филиала-->
                '>'+;
                PADL(LTRIM(STR(rmskr)),3,"0")+;
                '</department>')
                //<!--Код филиала-->

                //код тогр направ принимаем по СуперВизору
                s_tag->(netseek('t1','rs1->ktas'))
                qout('      <trade_way'+;
                ' name="'+ALLTRIM(s_tag->fio)+'"'+;//Пиво
                ' code="'+PADL(LTRIM(STR(rs1->ktas)),4,"0")+'"'+;//<!--Код торгового направления-->
                '>'+;
                PADL(LTRIM(STR(rs1->ktas)),4,"0")+'</trade_way>')
                //<!--Код торгового направления-->


                IF EMPTY(DtOpl)
                  DtOplr:=dop+14
                ELSEIF DtOpl = dTtnDt
                  DtOplr:=dop+14
                ELSE
                  DtOplr:=DtOpl
                ENDIF
                qout('      <due_date>' + DTOC(DtOplr)+'</due_date>') //01.03.2008
                //qout('      <due_date>' + DTOC(DtOplr) + 'T00:00:00'+'</due_date>') //01.03.2008
                //<!--Срок оплаты-->

                kln->(netseek('t1','rs1->kpl'))
                qout('      <ukeyj_shipment>'+;
                PADL(LTRIM(STR(dokk->mn,6)),6,"0")+;
                PADL(LTRIM(STR(dokk->rnd,6)),6,"0")+;
                PADL(LTRIM(STR(dokk->sk,3)),3,"0")+;
                PADL(LTRIM(STR(dokk->rn,6)),6,"0")+;
                PADL(LTRIM(STR(dokk->mnp,6)),6,"0")+;//номер документа
                '</ukeyj_shipment>')
                /*
                <!--
                    Значение <ukeyj_shipment> формируется из
                    даты отгрузки+
                    инн покупателя+
                    номер документа+
                    код склада+
                    код торового направления

                    Портянка формируется за день по всем документам или только по тем
                    документам, которые нужно перепровести.
                -->
                */

                qout('  </jornel_shipment>')
                #ifdef __CLIP__
                  IF EMPTY(ktanap->nap)
                    If kln->kkl = 20034 .or. YEAR(dTtnDt) < 2010
                      outlog(__FILE__,__LINE__,"e_rror <superviser (ktanap->nap) НЕ.ОПР ",rmskr,dokk->sk,rs1->ttn,dTtnDt)
                    Else
                      outlog(__FILE__,__LINE__,"error <superviser (ktanap->nap) НЕ.ОПР ",rmskr,dokk->sk,rs1->ttn,dTtnDt)
                    EndIf
                  ENDIF
                #endif


              ELSE
                //outlog(__FILE__,__LINE__,'проводки есть,нет д-та в складе',dokk->sk,dokk->rn)
              ENDIF
              nuse('rs1')
            endif

          endif

          sele dokk
          DO WHILE n_Sk=dokk->sk .AND. n_Rn=dokk->rn
            sele dokk
            skip
          ENDDO
          sele dokk
        endd

        //////// удаленные ////////
        sele dokk
        set filt to bs_d=0 .and. bs_k=0 .and. bs_s=0 .and. ;
                  (dokk->ddk >= dShDateBg .AND. dokk->ddk <= dShDateEnd) .AND.;
                    mn=0 .AND. mnp=0
        dokk->(DBGOTOP())
        DO WHILE dokk->(!EOF())
          out_xml_shipment(aKop,dShDateBg)
          dokk->(DBSKIP())
        ENDDO
        sele dokk
        set filt to
        dokk->(DBGOTOP())
        //////////////////////////////

        nuse('operb')
        If EMPTY(cAliasDokk)
          nuse('dokk')
        EndIf




        sele ship
        sum  summa to sum_ship
        IF !ISNIL(nSum)  .AND. !EMPTY(nSum)
          qout('    <totsum>'+ALLTRIM(TRANSFORM(nSum,"999 999 999.99"))+'</totsum>')
          qout('    <totsum>'+ALLTRIM(TRANSFORM(sum_ship,"999 999 999.99"))+'</totsum>')
        ENDIF
        close ship
      next
  next

  qout('</root>')

  set print to
  set print off
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  03-04-09 * 11:46:56am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION KopCode(aKop,nKop,cCode,cNmCode)
  LOCAL nPos_AKop
  PRIVATE Kopr
  //ч.з. поиск значения в 3-ем элементе
  If nKop > 1000
    kopr:=nKop/10
    cCode:=PADL(LTRIM(STR(nKop)),4,"0")
  Else
    kopr:=nKop
    cCode:=PADL(LTRIM(STR(nKop)),3,"0")
  EndIf


  nPos_AKop:=ASCAN(aKop,{|aElem| aElem[1]= kopr })

  IF nPos_AKop=0
    IF operb->(netseek('t1','kopr'))
      cNmCode:="-"+ALLTRIM(operb->nop)
    ELSE
      cNmCode:="-Код операции"
    ENDIF
  ELSE
    cNmCode:=SUBSTR(aKop[nPos_AKop,2],4)
  ENDIF

  cNmCode:=cCode+cNmCode

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  03-17-08 10:12am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Accord_Dokk(dShDateBg, dShDateEnd,cAliasDokk, d_ddk,cTypeDocPP, cNameJornel, lABS, nMult, bFor, n_Sum)
  LOCAL n_Sdv, nSum
  LOCAL n_mn, n_rnd, nRecNo, nBs_S
  LOCAL lout

  lout:=.F.

  DEFAULT lABS TO .F., nMult TO 1
   netuse('cskl')
   netuse('rmsk')
   netuse('kln')
   netuse('knasp')
   netuse('opfh')
   netuse('s_tag')
   netuse('nap')
   netuse('ktanap')

  SET DATE FORMAT "dd.mm.yyyy"
  SET CENTURY ON
  //╦╠┴╙╙╔╞╔╦┴╘╧╥ ╘╧╥╧╟╧╫┘╚ ╘╧▐┼╦

  set console off
  set print on
  set print to (cNameJornel)
  qqout('<?xml version="1.0" encoding="'+local_charset()+'"?>')
   qout('<root>')

  dt1r:=dShDateBg
  dt2r:=dShDateEnd
  FOR yyr=year(dt1r) to year(dt2r)
      DO CASE
      CASE year(dt1r)=year(dt2r)
        mm1r=month(dt1r)
        mm2r=month(dt2r)
      CASE yyr=year(dt1r)
        mm1r=month(dt1r)
        mm2r=12
      CASE yyr=year(dt2r)
        mm1r=1
        mm2r=month(dt2r)
      OTHE
        mm1r=1
        m2r=12
      ENDC
      for mmr=mm1r to mm2r
        path_dr=gcPath_e+'g'+str(yyr,4)+'\m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'
        pathr=path_dr+"bank\"

        if !netfile('dokk',1)
          loop
        endif

        netuse('operb','','',1)
        If EMPTY(cAliasDokk)
          netuse('dokk','','',1)
        else
          sele (cAliasDokk)
        EndIf
        ordsetfocus('t1')
        IF nMult=0

          SUM bs_s TO n_Sdv ;
          FOR EVAL(bFor) .AND. ;
             (ddk >= dShDateBg .AND. ddk <= dShDateEnd) //, .T.)

          qout('      <summa>'+ LTRIM(STR(n_Sdv))+" "+cNameJornel +'</summa>')

          SUM bs_s TO n_Sdv ;
          FOR EVAL(bFor) .AND. ;
             (BOM(ddk) >= BOM(dShDateBg) .AND. ddk <= dShDateEnd) //, .T.)
          qout('      <summao>'+ LTRIM(STR(n_Sdv))+" "+cNameJornel +'</summao>')
          IF !ISNIL(n_Sum)
            qout('      <summa_sub>'+ LTRIM(STR(n_Sum-n_Sdv))+" "+cNameJornel +'</summa_sub>')
          ENDIF

        ELSE
          nSum:=0
          DBGoTop()
          do while !eof()

            IF ;//период анализа
              (!EMPTY(dokk->bs_s) .OR. .T.) .AND. ; //emp_sum
               EVAL(bFor) .AND. ;
               (ddk >= dShDateBg .AND. ddk <= dShDateEnd) //, .T.)
                //          kkl
                IF .F. //kkl=20034
                  n_mn  :=dokk->mn
                  n_rnd :=dokk->rnd
                  nRecNo :=dokk->(RECNO())

                  sele dokk
                  SUM BS_S TO nBs_S ;
                  WHILE n_mn=dokk->mn .AND. n_rnd=dokk->rnd
                  dokk->(DBSKIP(-1))
                  //dokk->(DBGOTO(nRecNo))
                  out_xml_payment(nBs_s,lABS,nMult, dokk->NPlp, NIL, d_Ddk, cTypeDocPP)

                ELSE

                  nBs_S:=dokk->bs_s
                  DO CASE
                  CASE nBs_S >= 0 .AND. ;
                     lABS = .F. .AND. nMult = 1
                    out_xml_payment(nBs_s,lABS,nMult, dokk->NPlp, dokk->dokkttn, d_ddk, cTypeDocPP)

                  CASE nBs_S < 0  .AND. ;//оплата отрицательна - это реализация
                     lABS = .F. .AND. nMult = 1
                     IF .F. // <- ничего не делаем
                       IF !FILE("cor_db.dbf")
                          nRecNo:=dokk->(RECNO())
                          sele dokk
                          COPY TO cor_db NEXT 1
                          USE cor_db NEW
                       ELSE
                         IF EMPTY(SELECT("cor_db.dbf"))
                           USE cor_db NEW
                         ENDIF
                         nRecNo:=dokk->(RECNO())
                         sele dokk
                         COPY TO _cor_db  NEXT 1
                         SELE cor_db
                         APPEND FROM _cor_db
                       ENDIF
                     ENDIF

                  OTHERWISE
                    out_xml_payment(nBs_s,lABS,nMult, dokk->NPlp, dokk->dokkttn, d_ddk, cTypeDocPP)
                    lout:=.t.
                  ENDCASE

                ENDIF


              //IF lABS
                nSum+=nBs_S
                //nSum+=ABS(dokk->bs_s)*nMult
              //ENDIF

            endif


            sele dokk
            skip
          endd
        ENDIF

        nuse('operb')
        If EMPTY(cAliasDokk)
          nuse('dokk')
        EndIf
        IF !ISNIL(nSum)  .AND. !EMPTY(nSum) .and. lOut //
          qout('    <totsum>'+ALLTRIM(TRANSFORM(nSum,"999 999 999.99"))+'</totsum>')
        ENDIF
      next
  next

  qout('</root>')
  IF !EMPTY(SELECT("cor_db.dbf"))
    CLOSE cor_db
  ENDIF

  set print to
  set print off
  RETURN (n_Sdv)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  09-05-08 * 01:49:22pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Accord_CorrDB(dShDateBg, dShDateEnd,cAliasDokk, aKop, d_ddk, cTypeDocPP, cNameJornel, lABS, nMult, bFor)
  LOCAL n_mn, n_rnd, nRecNo, nBs_S
  LOCAL n_sk, n_rn
  DEFAULT lABS TO .F., nMult TO 1
   netuse('cskl')
   netuse('rmsk')
   netuse('kln')
   netuse('knasp')
   netuse('opfh')
   netuse('s_tag')
   netuse('nap')
   netuse('ktanap')

  SET DATE FORMAT "dd.mm.yyyy"
  SET CENTURY ON
  //╦╠┴╙╙╔╞╔╦┴╘╧╥ ╘╧╥╧╟╧╫┘╚ ╘╧▐┼╦

  set console off
  set print on
  set print to (cNameJornel)
  qqout('<?xml version="1.0" encoding="'+local_charset()+'"?>')
   qout('<root>')

  dt1r:=dShDateBg
  dt2r:=dShDateEnd
  FOR yyr=year(dt1r) to year(dt2r)
      DO CASE
      CASE year(dt1r)=year(dt2r)
        mm1r=month(dt1r)
        mm2r=month(dt2r)
      CASE yyr=year(dt1r)
        mm1r=month(dt1r)
        mm2r=12
      CASE yyr=year(dt2r)
        mm1r=1
        mm2r=month(dt2r)
      OTHE
        mm1r=1
        m2r=12
      ENDC
      for mmr=mm1r to mm2r
        path_dr=gcPath_e+'g'+str(yyr,4)+'\m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'
        pathr=path_dr+"bank\"

        if !netfile('dokk',1)
          loop
        endif

        netuse('operb','','',1)
        If EMPTY(cAliasDokk)
          netuse('dokk','','',1)
        else
          sele (cAliasDokk)
        EndIf
        ordsetfocus("t13")
        DBGoTop()
        do while !eof()

          IF ;//период анализа
             EVAL(bFor) .AND. ;
             (ddk >= dShDateBg .AND. ddk <= dShDateEnd) //, .T.)

            /*
            n_mn  :=dokk->mn
            n_rnd :=dokk->rnd
            nRecNo :=dokk->(RECNO())
            nBs_S:=0

            sele dokk
            SUM BS_S TO nBs_S ;
            WHILE n_mn=dokk->mn .AND. n_rnd=dokk->rnd
            dokk->(DBSKIP(-1))
            */
            nBs_S:=_FIELD->bs_s

            out_xml_payment(nBs_S,.T.,-1, _FIELD->NPlp, _FIELD->dokkttn, d_Ddk, cTypeDocPP)
            //o ut_xml_shipment(aKop, d_Ddk, cTypeDocPP)

          endif
          sele dokk
          skip
        enddo

        If EMPTY(cAliasDokk)
          nuse('dokk')
        EndIf

        IF FILE("cor_db.dbf")

          If !EMPTY(SELECT('dokk'))
            CLOSE dokk
          EndIf

          USE cor_db ALIAS dokk NEW  EXCLUSIVE
          DO WHILE !EOF()

            n_sk  :=dokk->sk
            n_rn :=dokk->rn
            nRecNo :=dokk->(RECNO())
            nBs_S:=0

            sele dokk
            SUM BS_S TO nBs_S ;
            WHILE n_sk=dokk->sk .AND. n_rn=dokk->rn
            dokk->(DBSKIP(-1))
            //nBs_S:=_FIELD->bs_s

            out_xml_payment(nBs_S,.T.,-1, _FIELD->NPlp, _FIELD->dokkttn, d_ddk, cTypeDocPP);

            sele dokk
            skip

          ENDDO
          CLOSE dokk

          If EMPTY(cAliasDokk)
            netuse('dokk','','',1)
            ordsetfocus('t4')
          else
            use tmpdokk Alias dokk new Exclusive
            ordsetfocus('t4')
          EndIf


        ENDIF

        nuse('operb')
      next
  next

  qout('</root>')

  set print to
  set print off
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  10-30-08 * 08:59:42pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION out_xml_shipment(aKop, d_ddk)
  LOCAL nPos_AKop, rs1_kop
  DEFAULT d_ddk TO ddk
  qout('   <jornel_shipment>')

  //////// <!--Дата отгрузки-->
  qout('      <odate>'+DTOC(ddk)+'</odate>')
  //qout('      <odate>'+DTOC(rs1->dop) + 'T00:00:00'+'</odate>')
  //<!--Дата отгрузки-->

  //////// <!--Сумма отгрузки-->
  qout('      <summa>'+ LTRIM(STR(ABS(Bs_S))) +'</summa>')
  //<!--Сумма отгрузки-->

  //////// <!--номер документа-->
  qout('      <number_order>'+'-'+RIGHT(DTOS(ddk),5)+'</number_order>')
  //<!--номер документа-->

  d_oper_date:=ddk //дата отгрузки
  qout('      <oper_date>'+DTOC(d_oper_date)+'</oper_date>')
  //<!--дата документа-->


  /////////  <!--Код операции-->
  //ч.з. поиск значения в 3-ем элементе
  rs1_kop:= 160//rs1->kop
  nPos_AKop:=ASCAN(aKop,{|aElem| aElem[1]= rs1_kop })
  qout('      <type_payment'+;
  ' name="'+IIF(nPos_AKop=0,PADL(LTRIM(STR(rs1_kop)),3,"0")+"-Код операции",aKop[nPos_AKop,2])+'"'+;
  ' code="'+PADL(LTRIM(STR(rs1_kop)),3,"0")+'"'+;//<!--Код операции-->
  '>'+;
  PADL(LTRIM(STR(rs1_kop)),3,"0")+'</type_payment>')
  //<!--Код операции-->

  /////////  <!--Код операции-->
  //ч.з. поиск значения в 3-ем элементе
  rs1_kop:= 160//rs1->kop
  nPos_AKop:=ASCAN(aKop,{|aElem| aElem[1]= rs1_kop })
  qout('      <type_paymenti'+;
  ' name="'+IIF(nPos_AKop=0,PADL(LTRIM(STR(rs1_kop)),3,"0")+"-Код операции",aKop[nPos_AKop,2])+'"'+;
  ' code="'+PADL(LTRIM(STR(rs1_kop)),3,"0")+'"'+;//<!--Код операции-->
  '>'+;
  PADL(LTRIM(STR(rs1_kop)),3,"0")+'</type_paymenti>')
  //<!--Код операции-->


  /////////   <!--ИНН покупателя-->  //////
  kln->(netseek('t1','dokk->Kkl'))
  knasp->(netseek('t1','kln->knasp'))
  opfh->(netseek('t1','kln->opfh'))
  nklr:=ATREPL('"',ALLTRIM(kln->nkl),"'")
  nklr  :=ATREPL('\',ALLTRIM(nklr),"/")
  nklr  :=SUBSTR(nklr,AT(" ",nklr)+1)
  nklr  :=IIF(LEFT(nklr,1)="'",SUBSTR(nklr,2),nklr)
  nnaspr:=ATREPL('"',ALLTRIM(knasp->nnasp),"'")
  nnaspr:=ATREPL('\',ALLTRIM(nnaspr),"/")

  adrr  :=ATREPL('"',ALLTRIM(kln->adr),"'")
  adrr  :=ATREPL('\',ALLTRIM(adrr),"/")

  tlfr:=ATREPL('"',ALLTRIM(kln->tlf),"'")

  qout('      <customers'+;
  ' state-form="'+ALLTRIM(opfh->nsopfh)+'"'+;
  ' fullname="'+ALLTRIM(opfh->nsopfh)+" "+ALLTRIM(nklr)+'"' +;//"ООО Рога и копыта"
  ' name="'+ALLTRIM(nklr)+'"' +;//"ООО Рога и копыта"
  ' post_city="'+ALLTRIM(nnaspr)+'"'+ ; //Ижевск
  ' post_street="'+ALLTRIM(adrr)+'"'+ ; //Ижевск
  ' phone="'+ALLTRIM(tlfr)+'"'+ ; //Ижевск
  ' egrpu="'+LTRIM(STR(kln->kkl1))+'"'+ ; //ИНН покупателя
  ' inn_code="'+LTRIM(STR(kln->kkl))+'"'+ ; //код покупателя
  '>'+LTRIM(STR(kln->kkl))+; //183456789321</customers>')
  '</customers>')
  //////  end <!--ИНН покупателя-->

  /////////   <!--ИНН покупателя-->  //////
  kln->(netseek('t1','dokk->Kkl'))
  knasp->(netseek('t1','kln->knasp'))
  opfh->(netseek('t1','kln->opfh'))
  nklr:=ATREPL('"',ALLTRIM(kln->nkl),"'")
  nklr  :=ATREPL('\',ALLTRIM(nklr),"/")
  nklr  :=SUBSTR(nklr,AT(" ",nklr)+1)
  nklr  :=IIF(LEFT(nklr,1)="'",SUBSTR(nklr,2),nklr)
  nnaspr:=ATREPL('"',ALLTRIM(knasp->nnasp),"'")
  nnaspr:=ATREPL('\',ALLTRIM(nnaspr),"/")

  adrr  :=ATREPL('"',ALLTRIM(kln->adr),"'")
  adrr  :=ATREPL('\',ALLTRIM(adrr),"/")

  tlfr:=ATREPL('"',ALLTRIM(kln->tlf),"'")

  qout('      <customersi'+;
  ' state-form="'+ALLTRIM(opfh->nsopfh)+'"'+;
  ' fullname="'+ALLTRIM(opfh->nsopfh)+" "+ALLTRIM(nklr)+'"' +;//"ООО Рога и копыта"
  ' name="'+ALLTRIM(nklr)+'"' +;//"ООО Рога и копыта"
  ' post_city="'+ALLTRIM(nnaspr)+'"'+ ; //Ижевск
  ' post_street="'+ALLTRIM(adrr)+'"'+ ; //Ижевск
  ' phone="'+ALLTRIM(tlfr)+'"'+ ; //Ижевск
  ' egrpu="'+LTRIM(STR(kln->kkl1))+'"'+ ; //ИНН покупателя
  ' inn_code="'+LTRIM(STR(kln->kkl))+'"'+ ; //код покупателя
  '>'+LTRIM(STR(kln->kkl))+; //183456789321</customers>')
  '</customersi>')
  //////  end <!--ИНН покупателя-->



  //////// <!--Код торговой точки-->
  kln->(netseek('t1','dokk->Kkl'))
  nklr:=ATREPL('"',ALLTRIM(kln->nkl),"'")
  nklr  :=ATREPL('\',ALLTRIM(nklr),"/")
  qout('      <trade_point'+;
  ' name="'+ALLTRIM(nklr)+'"'+;//Фиг его знает
  ' code="'+LTRIM(STR(dokk->Kkl))+'"'+;//Код торговой точки
  '>'+;
  LTRIM(STR(dokk->Kkl))+'</trade_point>')
  // end <!--Код торговой точки-->

  //////// <!--Код торговой точки-->
  kln->(netseek('t1','dokk->Kkl'))
  nklr:=ATREPL('"',ALLTRIM(kln->nkl),"'")
  nklr  :=ATREPL('\',ALLTRIM(nklr),"/")
  qout('      <trade_pointi'+;
  ' name="'+ALLTRIM(nklr)+'"'+;//Фиг его знает
  ' code="'+LTRIM(STR(dokk->Kkl))+'"'+;//Код торговой точки
  '>'+;
  LTRIM(STR(dokk->Kkl))+'</trade_pointi>')
  // end <!--Код торговой точки-->




  //////// <!--Код супервайзера-->
  qout('      <superviser'+;
  ' name="'+"КОРРЕКЦИЯ ОТГРУЗКИ"+'"'+;//Суперпиво
  ' code="'+PADL(LTRIM(STR(-777)),4,"0")+'"'+;//Суперпиво
  '>'+;
  PADL(LTRIM(STR(-777)),4,"0")+'</superviser>')
  //<!--Код супервайзера-->

  ////////  <!--Код комерческого агента-->
  qout('      <commerc_agent'+;
  ' name="'+"КОРРЕКЦИЯ ОТГРУЗКИ"+'"'+;//Наливайко Н.Н.
  ' code="'+PADL(LTRIM(STR(-777)),4,"0")+'"'+;//<!--Код комерческого агента-->
  '>'+;
  PADL(LTRIM(STR(-777)),4,"0")+'</commerc_agent>')
  //<!--Код комерческого агента-->


  //////////   <!--Код филиала-->
  rs1_rmsk:=0 //rs1->rmsk
  rmskr:=gnEnt*10+ rs1_rmsk
  IF rs1_rmsk = 0 // основное предприятие
    setup->(__dbLocate({|| setup->Ent = gnEnt }))
    nrmskr:=setup->uss
  ELSE
    rmsk->(__dbLocate({|| rmsk->rmsk = rs1->rmsk }))
    nrmskr:=rmsk->nrmsk
  ENDIF

  qout('      <department'+;
  ' name="'+ALLTRIM(nrmskr)+'"'+;//Второй
  ' code="'+PADL(LTRIM(STR(rmskr)),3,"0")+'"'+;//<!--Код филиала-->
  '>'+;
  PADL(LTRIM(STR(rmskr)),3,"0")+;
  '</department>')
  //<!--Код филиала-->

  ////////// <!--Код торгового направления-->
  //код тогр направ принимаем по СуперВизору
  qout('      <trade_way'+;
  ' name="'+"КОРРЕКЦИЯ ОТГРУЗКИ"+'"'+;//Пиво
  ' code="'+PADL(LTRIM(STR(-777)),4,"0")+'"'+;//<!--Код торгового направления-->
  '>'+;
  PADL(LTRIM(STR(-777)),4,"0")+'</trade_way>')
  //<!--Код торгового направления-->


  /////////< !--Срок оплаты-->
  DtOplr:=BOM(ddk)+7
  qout('      <due_date>' + DTOC(DtOplr)+'</due_date>') //01.03.2008
  //qout('      <due_date>' + DTOC(DtOplr) + 'T00:00:00'+'</due_date>') //01.03.2008
  //<!--Срок оплаты-->

  /*
  qout('      <ukeyj_shipment>'+;
  ;//2008020118345678932112302002
  LTRIM(STR(dokk->Kkl,6))+;//номер документа
  PADL(LTRIM(STR(-77)),3,"0")+;//код склада
  RIGHT(DTOS(ddk),8)+;//даты отгрузки
  ;//PADL(LTRIM(STR(kln->kkl1)),10,"0")+;//инн покупателя
  ;////код тогр направ принимаем по СуперВизору
  ;//(;
  ;//s_tag->(netseek('t1','rs1->ktas')),;
  ;//PADL(LTRIM(STR(rs1->ktas)),4,"0");//код торового направления
  ;//)+;
  '</ukeyj_shipment>')
  */
  qout('      <ukeyj_shipment>'+;
  ;//2008020118345678932112302002
  PADL(LTRIM(STR(dokk->mn,6)),6,"0")+;
  PADL(LTRIM(STR(dokk->rnd,6)),6,"0")+;
  PADL(LTRIM(STR(dokk->sk,3)),3,"0")+;
  PADL(LTRIM(STR(dokk->rn,6)),6,"0")+;
  PADL(LTRIM(STR(dokk->mnp,6)),6,"0")+;//номер документа
  '</ukeyj_shipment>')



  qout('  </jornel_shipment>')

  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  09-04-08 * 04:45:23pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Accord_Pr1(dShDateBg, dShDateEnd,cAliasDokk,aKop,d_Ddk, cTypeDocPP)
  LOCAL nPos_AKop
  LOCAL nRecNo, n_Sk, n_Rn, n_Sdv, nSum

   netuse('cskl')
   netuse('rmsk')
   netuse('kln')
   netuse('knasp')
   netuse('opfh')
   netuse('s_tag')
   netuse('nap')
   netuse('ktanap')

   netuse('etm')


  SET DATE FORMAT "dd.mm.yyyy"
  SET CENTURY ON
  //╦╠┴╙╙╔╞╔╦┴╘╧╥ ╘╧╥╧╟╧╫┘╚ ╘╧▐┼╦

  set console off
  set print on
  set print to jornel_return.xml
  qqout('<?xml version="1.0" encoding="'+local_charset()+'"?>')
   qout('<root>')

  dt1r:=dShDateBg
  dt2r:=dShDateEnd
  FOR yyr=year(dt1r) to year(dt2r)
      DO CASE
      CASE year(dt1r)=year(dt2r)
        mm1r=month(dt1r)
        mm2r=month(dt2r)
      CASE yyr=year(dt1r)
        mm1r=month(dt1r)
        mm2r=12
      CASE yyr=year(dt2r)
        mm1r=1
        mm2r=month(dt2r)
      OTHE
        mm1r=1
        m2r=12
      ENDC
      for mmr=mm1r to mm2r

        path_dr=gcPath_e+'g'+str(yyr,4)+'\m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'
        pathr=path_dr+"bank\"

        if !netfile('dokk',1)
          loop
        endif

        netuse('operb','','',1)
        If EMPTY(cAliasDokk)
          netuse('dokk','','',1)
        else
          sele (cAliasDokk)
        EndIf
        ordsetfocus("t13")

        nSum:=0
        sele dokk
        //set filt to bs_k=361001 .AND. mn=0 .AND. mnp#0
        DBGoTop()
        do while !eof()

          n_Sk:=skr:=dokk->sk
          n_Rn:=dokk->rn
          n_Sdv:=0

          //отгрузка
          LOCATE FOR bs_k=361001 .AND. mn=0 .AND. mnp#0 ;
          WHILE n_Sk=dokk->sk .AND. n_Rn=dokk->rn

          IF found()

            pathr=path_dr+ALLTRIM(getfield("t1","dokk->sk","cskl","path"))
            netuse('pr1','','',1)

            sele pr1
            //outlog(__FILE__,__LINE__,netseek("t1","dokk->rn"),dpr,dokk->rn,pathr)
            IF netseek("t1","dokk->rn") .AND. ;
              ;//(dpr >= dShDateBg .AND. dpr <= dShDateEnd) .AND. ;
              (dokk->ddk >= dShDateBg .AND. dokk->ddk <= dShDateEnd) .AND. ;
              .T.

              nRecNo:=dokk->(RECNO())
              sele dokk
              SUM bs_s TO n_Sdv ;
              FOR bs_k=361001 .AND. mn=0 .AND. mnp#0 ;
              WHILE n_Sk=dokk->sk .AND. n_Rn=dokk->rn
              dokk->(DBGOTO(nRecNo))

              dokkttnr:=-1
              dokkskr:=-1
              IF EMPTY(dokk->dokkttn)
                dokkttnr:=pr1->ttnvz
              ELSE
                //dokkttnr:=0
              ENDIF

              IF !EMPTY(pr1->(FieldPos("skvz")))
                IF EMPTY(dokk->dokksk)
                  dokkskr:=pr1->skvz
                ELSE
                  dokkskr:=0
                ENDIF
              ELSE
                dokkskr:=0
              ENDIF

              IF EMPTY(dokkskr)
                dokkskr:=dokk->sk
              ENDIF

              IF dokkttnr # -1
                dokk->(netrepl("dokkttn,dokksk","dokkttnr,dokkskr"))
              ENDIF


              IF ;
                n_Sdv>0 .AND. ; //приход только положительный
                (!EMPTY(n_Sdv) .OR. .T.) .AND. ;//emp_sum
                .T.
                out_xml_payment(n_Sdv,NIL,NIL,dokk->rn,dokk->rn,d_Ddk,cTypeDocPP)
                nSum+=n_Sdv

              ELSEIF n_Sdv<0 //приход отрицательный это реализация

               IF !FILE("cor_db.dbf")
                  nRecNo:=dokk->(RECNO())
                  sele dokk
                  COPY TO cor_db ;
                  FOR bs_k=361001 .AND. mn=0 .AND. mnp#0 ;
                  WHILE n_Sk=dokk->sk .AND. n_Rn=dokk->rn
                  USE cor_db NEW
               ELSE
                  IF EMPTY(SELECT("cor_db.dbf"))
                    USE cor_db NEW
                  ENDIF
                  nRecNo:=dokk->(RECNO())
                  sele dokk
                  COPY TO _cor_db ;
                  FOR bs_k=361001 .AND. mn=0 .AND. mnp#0 ;
                  WHILE n_Sk=dokk->sk .AND. n_Rn=dokk->rn
                  SELE cor_db
                  APPEND FROM _cor_db
               ENDIF

               dokk->(DBGOTO(nRecNo))
              ENDIF

            ENDIF
            nuse('pr1')

          endif

          sele dokk
          DO WHILE n_Sk=dokk->sk .AND. n_Rn=dokk->rn
            sele dokk
            skip
          ENDDO
          sele dokk
        endd
        nuse('operb')
        IF !ISNIL(nSum) .AND. !EMPTY(nSum)
          qout('    <totsum>'+ALLTRIM(TRANSFORM(nSum,"999 999 999.99"))+'</totsum>')
        ENDIF
        If EMPTY(cAliasDokk)
          nuse('dokk')
        EndIf
      next
  next

  qout('</root>')

  set print to
  set print off

  IF !EMPTY(SELECT("cor_db.dbf"))
    CLOSE cor_db
  ENDIF

  RETURN (NIL)




/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-05-08 * 08:11:36am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Accord_ost(dOtch,aKop)
  LOCAL nBs_S
  LOCAL rs1_kop

  netuse('dkkln')

   netuse('cskl')
   netuse('rmsk')
   netuse('kln')
   netuse('kpl')
   netuse('knasp')
   netuse('opfh')


  SET DATE FORMAT "dd.mm.yyyy"
  SET CENTURY ON
  //╦╠┴╙╙╔╞╔╦┴╘╧╥ ╘╧╥╧╟╧╫┘╚ ╘╧▐┼╦

  set console off
  set print on
  set print to jornel_shipment.xml
  qqout('<?xml version="1.0" encoding="'+local_charset()+'"?>')
  qout('<root>')

  dkkln->(DBGOTOP())
  DO WHILE dkkln->(!EOF())
    nBs_S:=dkkln->DN - dkkln->KN //+ dkkln->DB - dkkln->KR
    lMake:=.F.

    //nBs_S:=-1*nBs_S

    IF !EMPTY(ROUND(nBs_S, 2))
      DO CASE
      CASE  dkkln->BS = 361001

        IF nBs_S<0
          #ifdef __CLIP__
          //outlog(__FILE__,__LINE__,"Предоплата ",nBs_S,dkkln->Kkl,dkkln->DN, dkkln->KN)
          #endif
          dkkln->(DBSKIP())
          LOOP
        ELSEIF EMPTY(ROUND(nBs_S, 2))
          dkkln->(DBSKIP())
          LOOP
        ENDIF
        lMake:=.T.

      ENDCASE
      IF lMake
        qout('   <jornel_shipment>')

        //////// <!--Дата отгрузки-->
        qout('      <odate>'+DTOC(EOM(ADDMONTH(dOtch,-1)))+'</odate>')
        //qout('      <odate>'+DTOC(rs1->dop) + 'T00:00:00'+'</odate>')
        //<!--Дата отгрузки-->

        //////// <!--Сумма отгрузки-->
        qout('      <summa>'+ LTRIM(STR(nBs_S)) +'</summa>')
        //<!--Сумма отгрузки-->

        //////// <!--номер документа-->
        qout('      <number_order>'+'-'+RIGHT(DTOS(EOM(ADDMONTH(dOtch,-1))),5)+'</number_order>')
        //<!--номер документа-->

        qout('      <oper_date>'+DTOC(EOM(ADDMONTH(dOtch,-1)))+'</oper_date>')
        //<!--дата документа-->

        /////////  <!--Код операции-->
        //ч.з. поиск значения в 3-ем элементе
        rs1_kop:= 160//rs1->kop
        nPos_AKop:=ASCAN(aKop,{|aElem| aElem[1]= rs1_kop })
        qout('      <type_payment'+;
        ' name="'+IIF(nPos_AKop=0,PADL(LTRIM(STR(rs1_kop)),3,"0")+"-Код операции",aKop[nPos_AKop,2])+'"'+;
        ' code="'+PADL(LTRIM(STR(rs1_kop)),3,"0")+'"'+;//<!--Код операции-->
        '>'+;
        PADL(LTRIM(STR(rs1_kop)),3,"0")+'</type_payment>')
        //<!--Код операции-->

        /////////  <!--Код операции-->
        //ч.з. поиск значения в 3-ем элементе
        rs1_kop:= 160//rs1->kop
        nPos_AKop:=ASCAN(aKop,{|aElem| aElem[1]= rs1_kop })
        qout('      <type_paymenti'+;
        ' name="'+IIF(nPos_AKop=0,PADL(LTRIM(STR(rs1_kop)),3,"0")+"-Код операции",aKop[nPos_AKop,2])+'"'+;
        ' code="'+PADL(LTRIM(STR(rs1_kop)),3,"0")+'"'+;//<!--Код операции-->
        '>'+;
        PADL(LTRIM(STR(rs1_kop)),3,"0")+'</type_paymenti>')
        //<!--Код операции-->


        /////////   <!--ИНН покупателя-->  //////
        kln->(netseek('t1','dkkln->Kkl'))
        knasp->(netseek('t1','kln->knasp'))
        opfh->(netseek('t1','kln->opfh'))
        nklr:=ATREPL('"',ALLTRIM(kln->nkl),"'")
        nklr  :=ATREPL('\',ALLTRIM(nklr),"/")
        nklr  :=SUBSTR(nklr,AT(" ",nklr)+1)
        nklr  :=IIF(LEFT(nklr,1)="'",SUBSTR(nklr,2),nklr)
        nnaspr:=ATREPL('"',ALLTRIM(knasp->nnasp),"'")
        nnaspr:=ATREPL('\',ALLTRIM(nnaspr),"/")

        adrr  :=ATREPL('"',ALLTRIM(kln->adr),"'")
        adrr  :=ATREPL('\',ALLTRIM(adrr),"/")

        tlfr:=ATREPL('"',ALLTRIM(kln->tlf),"'")

        qout('      <customers'+;
        ' state-form="'+ALLTRIM(opfh->nsopfh)+'"'+;
        ' fullname="'+ALLTRIM(opfh->nsopfh)+" "+ALLTRIM(nklr)+'"' +;//"ООО Рога и копыта"
        ' name="'+ALLTRIM(nklr)+'"' +;//"ООО Рога и копыта"
        ' post_city="'+ALLTRIM(nnaspr)+'"'+ ; //Ижевск
        ' post_street="'+ALLTRIM(adrr)+'"'+ ; //Ижевск
        ' phone="'+ALLTRIM(tlfr)+'"'+ ; //Ижевск
        ' egrpu="'+LTRIM(STR(kln->kkl1))+'"'+ ; //ИНН покупателя
        ' inn_code="'+LTRIM(STR(kln->kkl))+'"'+ ; //код покупателя
        '>'+LTRIM(STR(kln->kkl))+; //183456789321</customers>')
        '</customers>')
        //////  end <!--ИНН покупателя-->

        /////////   <!- Инкогнито -ИНН покупателя-->  //////
        kln->(netseek('t1','dkkln->Kkl'))
        knasp->(netseek('t1','kln->knasp'))
        opfh->(netseek('t1','kln->opfh'))
        nklr:=ATREPL('"',ALLTRIM(kln->nkl),"'")
        nklr  :=ATREPL('\',ALLTRIM(nklr),"/")
        nklr  :=SUBSTR(nklr,AT(" ",nklr)+1)
        nklr  :=IIF(LEFT(nklr,1)="'",SUBSTR(nklr,2),nklr)
        nnaspr:=ATREPL('"',ALLTRIM(knasp->nnasp),"'")
        nnaspr:=ATREPL('\',ALLTRIM(nnaspr),"/")

        adrr  :=ATREPL('"',ALLTRIM(kln->adr),"'")
        adrr  :=ATREPL('\',ALLTRIM(adrr),"/")

        tlfr:=ATREPL('"',ALLTRIM(kln->tlf),"'")

        qout('      <customersi'+;
        ' state-form="'+ALLTRIM(opfh->nsopfh)+'"'+;
        ' fullname="'+ALLTRIM(opfh->nsopfh)+" "+ALLTRIM(nklr)+'"' +;//"ООО Рога и копыта"
        ' name="'+ALLTRIM(nklr)+'"' +;//"ООО Рога и копыта"
        ' post_city="'+ALLTRIM(nnaspr)+'"'+ ; //Ижевск
        ' post_street="'+ALLTRIM(adrr)+'"'+ ; //Ижевск
        ' phone="'+ALLTRIM(tlfr)+'"'+ ; //Ижевск
        ' egrpu="'+LTRIM(STR(kln->kkl1))+'"'+ ; //ИНН покупателя
        ' inn_code="'+LTRIM(STR(kln->kkl))+'"'+ ; //код покупателя
        '>'+LTRIM(STR(kln->kkl))+; //183456789321</customers>')
        '</customersi>')
        //////  end <!-- Инкогнито  ИНН покупателя-->


        //////// <!--Код торговой точки-->
        kln->(netseek('t1','dkkln->Kkl'))
        nklr:=ATREPL('"',ALLTRIM(kln->nkl),"'")
        nklr  :=ATREPL('\',ALLTRIM(nklr),"/")
        qout('      <trade_point'+;
        ' name="'+ALLTRIM(nklr)+'"'+;//Фиг его знает
        ' code="'+LTRIM(STR(dkkln->Kkl))+'"'+;//Код торговой точки
        '>'+;
        LTRIM(STR(dkkln->Kkl))+'</trade_point>')
        // end <!--Код торговой точки-->

        //////// <!-- Инкогнито Код торговой точки-->
        kln->(netseek('t1','dkkln->Kkl'))
        nklr:=ATREPL('"',ALLTRIM(kln->nkl),"'")
        nklr  :=ATREPL('\',ALLTRIM(nklr),"/")
        qout('      <trade_pointi'+;
        ' name="'+ALLTRIM(nklr)+'"'+;//Фиг его знает
        ' code="'+LTRIM(STR(dkkln->Kkl))+'"'+;//Код торговой точки
        '>'+;
        LTRIM(STR(dkkln->Kkl))+'</trade_pointi>')
        // end <!-- Инкогнито Код торговой точки-->


        DO CASE
        CASE .T.
          ////// <!--Код супервайзера-->
          qout('      <superviser'+;
          ' name="'+"НЕ.ОПР."+'"'+;//Суперпиво
          ' code="'+PADL(LTRIM(STR(0)),4,"0")+'"'+;//Суперпиво
          '>'+;
          PADL(LTRIM(STR(0)),4,"0")+'</superviser>')
          //<!--Код супервайзера-->
        CASE .F.
          //////// <!--Код супервайзера-->
          qout('      <superviser'+;
          ' name="'+"НАЧАЛЬНЫЙ ОСТАТОК"+'"'+;//Суперпиво
          ' code="'+PADL(LTRIM(STR(-999)),4,"0")+'"'+;//Суперпиво
          '>'+;
          PADL(LTRIM(STR(-999)),4,"0")+'</superviser>')
          //<!--Код супервайзера-->
        ENDCASE

        //klpkgp->(neetseek('t1','dkkln->Kkl'))
        DO CASE
        CASE .T.
          //////   <!--Код комерческого агента-->
          qout('      <commerc_agent'+;
          ' name="'+"НЕ.ОПР."+'"'+;//Наливайко Н.Н.
          ' code="'+PADL(LTRIM(STR(0)),4,"0")+'"'+;//<!--Код комерческого агента-->
          '>'+;
          PADL(LTRIM(STR(0)),4,"0")+'</commerc_agent>')
          //<!--Код комерческого агента-->
        CASE .F.
          ////////  <!--Код комерческого агента-->
          qout('      <commerc_agent'+;
          ' name="'+"НАЧАЛЬНЫЙ ОСТАТОК"+'"'+;//Наливайко Н.Н.
          ' code="'+PADL(LTRIM(STR(-999)),4,"0")+'"'+;//<!--Код комерческого агента-->
          '>'+;
          PADL(LTRIM(STR(-999)),4,"0")+'</commerc_agent>')
          //<!--Код комерческого агента-->
        ENDCASE


        //////////   <!--Код филиала-->
        /*
        rs1_rmsk:=0 //rs1->rmsk
        rmskr:=gnEnt*10+ rs1_rmsk
        IF rs1_rmsk = 0 // основное предприятие
          setup->(__dbLocate({|| setup->Ent = gnEnt }))
          nrmskr:=setup->uss
        ELSE
          rmsk->(__dbLocate({|| rmsk->rmsk = rs1_rmsk }))
          nrmskr:=rmsk->nrmsk
        ENDIF
        */


        //вычислям по маска клиета, к корому относится филиал
        kpl->(netseek('t1','dkkln->Kkl'))
        crmskr:=kpl->crmsk
        DO CASE
        CASE !EMPTY(SUBSTR(crmskr,1,2))
          //сумы
          rs1_rmsk:=0
        CASE SUBSTR(crmskr,3,1)="1"
          //ромны
          rs1_rmsk:=3
        CASE SUBSTR(crmskr,4,1)="1"
          //конотоп
          rs1_rmsk:=4
        CASE SUBSTR(crmskr,5,1)="1"
          //шостак
          rs1_rmsk:=5
        CASE SUBSTR(crmskr,6,1)="1"
          //ахтирка
          rs1_rmsk:=6
        ENDCASE

        rmskr:=gnEnt*10+ rs1_rmsk
        IF rs1_rmsk = 0 // основное предприятие
          setup->(__dbLocate({|| setup->Ent = gnEnt }))
          nrmskr:=setup->uss
        ELSE
          rmsk->(__dbLocate({|| rmsk->rmsk = rs1_rmsk }))
          nrmskr:=rmsk->nrmsk
        ENDIF


        qout('      <department'+;
        ' name="'+ALLTRIM(nrmskr)+'"'+;//Второй
        ' code="'+PADL(LTRIM(STR(rmskr)),3,"0")+'"'+;//<!--Код филиала-->
        '>'+;
        PADL(LTRIM(STR(rmskr)),3,"0")+;
        '</department>')
        //<!--Код филиала-->

        ////////// <!--Код торгового направления-->
        //код тогр направ принимаем по СуперВизору
        qout('      <trade_way'+;
        ' name="'+"НАЧАЛЬНЫЙ ОСТАТОК"+'"'+;//Пиво
        ' code="'+PADL(LTRIM(STR(-999)),4,"0")+'"'+;//<!--Код торгового направления-->
        '>'+;
        PADL(LTRIM(STR(-999)),4,"0")+'</trade_way>')
        //<!--Код торгового направления-->


        /////////< !--Срок оплаты-->
        DtOplr:=BOM(dOtch)+14
        qout('      <due_date>' + DTOC(DtOplr)+'</due_date>') //01.03.2008
        //qout('      <due_date>' + DTOC(DtOplr) + 'T00:00:00'+'</due_date>') //01.03.2008
        //<!--Срок оплаты-->

        qout('      <ukeyj_shipment>'+;
        ;//2008020118345678932112302002
        LTRIM(STR(dkkln->Kkl))+;//номер документа
        PADL(LTRIM(STR(-99)),3,"0")+;//код склада
        RIGHT(DTOS(EOM(ADDMONTH(dOtch,-1))),8)+;//даты отгрузки
        ;//PADL(LTRIM(STR(kln->kkl1)),10,"0")+;//инн покупателя
        ;////код тогр направ принимаем по СуперВизору
        ;//(;
        ;//s_tag->(netseek('t1','rs1->ktas')),;
        ;//PADL(LTRIM(STR(rs1->ktas)),4,"0");//код торового направления
        ;//)+;
        '</ukeyj_shipment>')

        qout('  </jornel_shipment>')

      ENDIF
    ENDIF
    dkkln->(DBSKIP())
  ENDDO



  qout('</root>')

  set print to
  set print off


  set console off
  set print on
  set print to jornel_payment.xml
  qqout('<?xml version="1.0" encoding="'+local_charset()+'"?>')
  qout('<root>')

  dkkln->(DBGOTOP())
  DO WHILE dkkln->(!EOF())
    nBs_S:=dkkln->DN - dkkln->KN //+ dkkln->DB - dkkln->KR
    lMake:=.F.

    IF !EMPTY(ROUND(nBs_S, 2))
      DO CASE
      CASE  dkkln->BS = 361001

        IF nBs_S > 0
          dkkln->(DBSKIP())
          LOOP
        ELSEIF EMPTY(ROUND(nBs_S, 2))
          dkkln->(DBSKIP())
          LOOP
        ENDIF
        lMake:=.T.

      ENDCASE

      nBs_S:=-1*nBs_S
      IF lMake
        qout('   <jornel_payment>')

        qout('      <odate>'+DTOC(EOM(ADDMONTH(dOtch,-1)))+'</odate>')
        //qout('      <odate>'+DTOC(ddk) + 'T00:00:00'+'</odate>')
        //<!--Дата отгрузки-->

        qout('      <summa>'+ LTRIM(STR(nBs_S)) +'</summa>')
        //<!--Сумма отгрузки-->

        qout('      <number_paym>'+'-'+RIGHT(DTOS(EOM(ADDMONTH(dOtch,-1))),5)+'</number_paym>')
        //<!-- Номер плат поручения-->

        qout('      <typedocpp>'+"ОСТ"+'</typedocpp>')

        kln->(netseek('t1','dkkln->kkl'))
        knasp->(netseek('t1','kln->knasp'))
        opfh->(netseek('t1','kln->opfh'))
        nklr:=ATREPL('"',ALLTRIM(kln->nkl),"'")
        nklr  :=ATREPL('\',ALLTRIM(nklr),"/")
        nklr  :=SUBSTR(nklr,AT(" ",nklr)+1)
        nklr  :=IIF(LEFT(nklr,1)="'",SUBSTR(nklr,2),nklr)
        nnaspr:=ATREPL('"',ALLTRIM(knasp->nnasp),"'")
        nnaspr:=ATREPL('\',ALLTRIM(nnaspr),"/")

        adrr  :=ATREPL('"',ALLTRIM(kln->adr),"'")
        adrr  :=ATREPL('\',ALLTRIM(adrr),"/")
        //adrr  :=IIF(RIGHT(adrr,1)='\',ATREPL('\',ALLTRIM(adrr),"\_"),adrr)

        tlfr:=ATREPL('"',ALLTRIM(kln->tlf),"'")

        qout('      <customers'+;
        ' state-form="'+ALLTRIM(opfh->nsopfh)+'"'+;
        ' fullname="'+ALLTRIM(opfh->nsopfh)+" "+ALLTRIM(nklr)+'"' +;//"ООО Рога и копыта"
        ' name="'+ALLTRIM(nklr)+'"' +;//"ООО Рога и копыта"
        ' post_city="'+ALLTRIM(nnaspr)+'"'+ ; //Ижевск
        ' post_street="'+ALLTRIM(adrr)+'"'+ ; //Ижевск
        ' phone="'+ALLTRIM(tlfr)+'"'+ ; //Ижевск
        ' egrpu="'+LTRIM(STR(kln->kkl1))+'"'+ ; //ИНН покупателя
        ' inn_code="'+LTRIM(STR(kln->kkl))+'"'+ ; //код покупателя
        '>'+LTRIM(STR(kln->kkl))+; //183456789321</customers>')
        '</customers>')
        //<!--ИНН покупателя-->


        ////// <!--Код супервайзера-->
        qout('      <superviser'+;
        ' name="'+"НЕ.ОПР."+'"'+;//Суперпиво
        ' code="'+PADL(LTRIM(STR(0)),4,"0")+'"'+;//Суперпиво
        '>'+;
        PADL(LTRIM(STR(0)),4,"0")+'</superviser>')
        //<!--Код супервайзера-->

        //////   <!--Код комерческого агента-->
        qout('      <commerc_agent'+;
        ' name="'+"НЕ.ОПР."+'"'+;//Наливайко Н.Н.
        ' code="'+PADL(LTRIM(STR(0)),4,"0")+'"'+;//<!--Код комерческого агента-->
        '>'+;
        PADL(LTRIM(STR(0)),4,"0")+'</commerc_agent>')
        //<!--Код комерческого агента-->

        //////  <!--Код филиала-->
        rs1_rmsk:=0 //rs1->rmsk
        rmskr:=gnEnt*10+ rs1_rmsk
        IF rs1_rmsk = 0 // основное предприятие
          setup->(__dbLocate({|| setup->Ent = gnEnt }))
          nrmskr:=setup->uss
        ELSE
          rmsk->(__dbLocate({|| rmsk->rmsk = rs1->rmsk }))
          nrmskr:=rmsk->nrmsk
        ENDIF

        //////  <!--Код филиала-->
        qout('      <department'+;
        ' name="'+ALLTRIM(nrmskr)+'"'+;//Второй
        ' code="'+PADL(LTRIM(STR(rmskr)),3,"0")+'"'+;//<!--Код филиала-->
        '>'+;
        PADL(LTRIM(STR(rmskr)),3,"0")+;
        '</department>')
        //<!--Код филиала-->

        //<!-- номер документа закрытия -->
        qout('      <number_order>'+""+'</number_order>')
        //<!-- номер документа закрытия -->

        qout('      <ukeyj_shipment>'+;
        ;//2008020118345678932112302002
        ;//ukeyj_sh PADL(LTRIM(STR(dokk->ttn)),6,"0")+;//номер документа
        ;//ukeyj_sh PADL(LTRIM(STR(cskl->sk)),3,"0")+;//код склада
        ;//ukeyj_sh RIGHT(DTOS(dokk->dop),8)+;//даты отгрузки
        ;//PADL(LTRIM(STR(kln->kkl1)),10,"0")+;//инн покупателя
        ;////код тогр направ принимаем по СуперВизору
        ;//(;
        ;//s_tag->(netseek('t1','rs1->ktas')),;
        ;//PADL(LTRIM(STR(rs1->ktas)),4,"0");//код торового направления
        ;//)+;
        '</ukeyj_shipment>')

        ////// <!--Код торгового направления-->
        //код тогр направ принимаем по СуперВизору
        qout('      <trade_way'+;
        ' name="'+"НЕ.ОПР."+'"'+;//Пиво
        ' code="'+PADL(LTRIM(STR(0)),4,"0")+'"'+;//<!--Код торгового направления-->
        '>'+;
        PADL(LTRIM(STR(0)),4,"0")+'</trade_way>')
        //<!--Код торгового направления-->


        //////  <!--Дата регистарции-->
        qout('      <regdate>'+DTOC(EOM(ADDMONTH(dOtch,-1)))+'</regdate>')
        //qout('      <regdate>'+DTOC(ddc) + 'T00:00:00'+'</regdate>')
        //<!--Дата регистарции-->

            //<ukeyj_payment>20080201 183456789 64412403 003</ukeyj_payment>
        qout('      <ukeyj_payment>'+;
        ;//                  20080201 183456789 32112302 002
        ;//DTOS(dokk->ddk)+;//даты регистрации проводки
        ;//PADL(LTRIM(STR(kln->kkl1)),10,"0")+;//инн покупателя
        ;//PADL(LTRIM(STR(dokk->rmsk)),3,"0")+;//код склада
        PADL(LTRIM(STR(0,6)),9,"0")+;
        PADL(LTRIM(STR(dkkln->Kkl)),7,"0")+;//номер документа
        PADL(LTRIM(STR(-99)),3,"0")+;//код склада
        RIGHT(DTOS(EOM(ADDMONTH(dOtch,-1))),8)+;//даты отгрузки
        ;////код тогр направ принимаем по СуперВизору
        ;//(;
        ;//s_tag->(netseek('t1','dokk->ktas')),;
        ;//PADL(LTRIM(STR(dokk->ktas)),4,"0");//код торового направления
        ;//)+;
        '</ukeyj_payment>')

        qout('  </jornel_payment>')
      ENDIF

    ENDIF
    dkkln->(DBSKIP())
  ENDDO

  qout('</root>')

  set print to
  set print off

  Accord_empty_xml()

  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  09-04-08 * 03:41:33pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION out_xml_payment(n_Sdv,lABS, nMult, n_NPlp, xShipment, d_Ddk, cTypeDocPP)
  LOCAL n_Sk
  LOCAL rs1_kop,  nPos_AKop, nopr

  DEFAULT d_Ddk TO ddk, cTypeDocPP TO "ПП"


  DEFAULT n_Sdv TO bs_s, n_NPlp TO NPlp, lABS TO .F.
  IF lABS
    n_Sdv:=ABS(n_Sdv)*nMult
  ENDIF
  qout('   <jornel_payment>')

  /////// <!--Дата отгрузки-->
  qout('      <odate>'+DTOC(d_ddk)+'</odate>')
  //qout('      <odate>'+DTOC(ddk) + 'T00:00:00'+'</odate>')
  //<!--Дата отгрузки-->

  //////  <!--Сумма отгрузки-->
  qout('      <summa>'+ LTRIM(STR(n_Sdv)) +'</summa>')
  //<!--Сумма отгрузки-->

  //////  <!-- Номер плат поручения-->
  qout('      <number_paym>'+LTRIM(STR(n_NPlp))+'</number_paym>')
  //<!-- Номер плат поручения-->

  cTypeDocPP:=Iif(ischar(cTypeDocPP),cTypeDocPP,eval(cTypeDocPP))
  qout('      <typedocpp>'+LEFT(ALLTRIM(cTypeDocPP),4)+'</typedocpp>')


  /////////  <!--Код операции-->
  //ч.з. поиск значения в 3-ем элементе
  rs1_kop:=dokk->kop
  nPos_AKop:=0 //ASCAN(aKop,{|aElem| aElem[1]= rs1_kop })
  nopr:=""
  DO CASE
  CASE nPos_AKop=0
    IF operb->(netseek('t1','dokk->kop'))
      nopr:=ALLTRIM(operb->nop)
    ELSE
      nopr:=PADL(LTRIM(STR(rs1_kop)),3,"0")+"-Код операции"
    ENDIF
  CASE nPos_AKop#0
    nopr:=aKop[nPos_AKop,2]
  ENDCASE
  qout('      <type_payment'+;
  ' name="'+nopr+'"'+;
  ' code="'+PADL(LTRIM(STR(rs1_kop)),3,"0")+'"'+;//<!--Код операции-->
  '>'+;
  PADL(LTRIM(STR(rs1_kop)),3,"0")+'</type_payment>')
  //<!--Код операции-->


  ////// <!--ИНН покупателя-->
  kln->(netseek('t1','dokk->kkl'))
  knasp->(netseek('t1','kln->knasp'))
  opfh->(netseek('t1','kln->opfh'))
  nklr:=ATREPL('"',ALLTRIM(kln->nkl),"'")
  nklr  :=ATREPL('\',ALLTRIM(nklr),"/")
  nklr  :=SUBSTR(nklr,AT(" ",nklr)+1)
  nklr  :=IIF(LEFT(nklr,1)="'",SUBSTR(nklr,2),nklr)
  nnaspr:=ATREPL('"',ALLTRIM(knasp->nnasp),"'")
  nnaspr:=ATREPL('\',ALLTRIM(nnaspr),"/")

  adrr  :=ATREPL('"',ALLTRIM(kln->adr),"'")
  adrr  :=ATREPL('\',ALLTRIM(adrr),"/")

  tlfr:=ATREPL('"',ALLTRIM(kln->tlf),"'")

  qout('      <customers'+;
  ' state-form="'+ALLTRIM(opfh->nsopfh)+'"'+;
  ' fullname="'+ALLTRIM(opfh->nsopfh)+" "+ALLTRIM(nklr)+'"' +;//"ООО Рога и копыта"
  ' name="'+ALLTRIM(nklr)+'"' +;//"ООО Рога и копыта"
  ' post_city="'+ALLTRIM(nnaspr)+'"'+ ; //Ижевск
  ' post_street="'+ALLTRIM(adrr)+'"'+ ; //Ижевск
  ' phone="'+ALLTRIM(tlfr)+'"'+ ; //Ижевск
  ' egrpu="'+LTRIM(STR(kln->kkl1))+'"'+ ; //ИНН покупателя
  ' inn_code="'+LTRIM(STR(kln->kkl))+'"'+ ; //код покупателя
  '>'+LTRIM(STR(kln->kkl))+; //183456789321</customers>')
  '</customers>')
  //<!--ИНН покупателя-->

  DO CASE
  CASE .F.
    //////// <!--Код супервайзера-->
    qout('      <superviser'+;
    ' name="'+""+'"'+;//Суперпиво
    ' code="'+""+'"'+;//Суперпиво
    '>'+;
    ""+'</superviser>')
    //<!--Код супервайзера-->

  CASE .T.
    IF EMPTY(dokk->nap) .or. dokk->kkl=20034
      IF cTypeDocPP="ВЗРТ"
        ////////  <!--Код супервайзера-->
        s_tag->(netseek('t1','dokk->ktas'))
        ktanap->(netseek('t1','dokk->ktas')) //ktanap->nap

        nap->(netseek('t1','ktanap->nap')) //nap->nnap
        qout('      <superviser'+;
        ' name="'+ALLTRIM(nap->nnap)+'"'+;//Суперпиво
        ' code="'+PADL(LTRIM(STR(ktanap->nap)),4,"0")+'"'+;//Суперпиво
        '>'+;
        PADL(LTRIM(STR(ktanap->nap)),4,"0")+'</superviser>')
        //<!--Код супервайзера-->
      ELSE
        //////// <!--Код супервайзера-->
        qout('      <superviser'+;
        ' name="'+"НЕ.ОПР."+'"'+;//Суперпиво
        ' code="'+PADL(LTRIM(STR(000)),4,"0")+'"'+;//Суперпиво
        '>'+;
        PADL(LTRIM(STR(000)),4,"0")+'</superviser>')
        //<!--Код супервайзера-->
      ENDIF
    ELSE
      ////////  <!--Код супервайзера-->
      nap->(netseek('t1','dokk->nap')) //nap->nnap
      qout('      <superviser'+;
      ' name="'+ALLTRIM(nap->nnap)+'"'+;//Суперпиво
      ' code="'+PADL(LTRIM(STR(nap->nap)),4,"0")+'"'+;//Суперпиво
      '>'+;
      PADL(LTRIM(STR(nap->nap)),4,"0")+'</superviser>')
      //<!--Код супервайзера-->
    ENDIF

  CASE .F.
    //////// <!--Код супервайзера-->
    qout('      <superviser'+;
    ' name="'+"НАЧАЛЬНЫЙ ОСТАТОК"+'"'+;//Суперпиво
    ' code="'+PADL(LTRIM(STR(-999)),4,"0")+'"'+;//Суперпиво
    '>'+;
    PADL(LTRIM(STR(-999)),4,"0")+'</superviser>')
    //<!--Код супервайзера-->

  CASE .F.

    ////////  <!--Код супервайзера-->
    s_tag->(netseek('t1','dokk->ktas'))
    ktanap->(netseek('t1','dokk->ktas')) //ktanap->nap

    nap->(netseek('t1','ktanap->nap')) //nap->nnap
    qout('      <superviser'+;
    ' name="'+ALLTRIM(nap->nnap)+'"'+;//Суперпиво
    ' code="'+PADL(LTRIM(STR(ktanap->nap)),4,"0")+'"'+;//Суперпиво
    '>'+;
    PADL(LTRIM(STR(ktanap->nap)),4,"0")+'</superviser>')
    //<!--Код супервайзера-->


    ////////  <!--Код супервайзера-->
    /*
    s_tag->(netseek('t1','dokk->ktas'))
    fior:=IIF(EMPTY(s_tag->fio),"НЕ.ОПР.",s_tag->fio)
    qout('      <superviser'+;
    ' name="'+ALLTRIM(fior)+'"'+;//Суперпиво
    ' code="'+PADL(LTRIM(STR(dokk->ktas)),4,"0")+'"'+;//<!--Код супервайзера-->
    '>'+;
    PADL(LTRIM(STR(dokk->ktas)),4,"0")+'</superviser>')
    //<!--Код супервайзера-->
    */
  ENDCASE

  ///////  <!--Код комерческого агента-->
  s_tag->(netseek('t1','dokk->kta'))
  fior:=IIF(EMPTY(s_tag->fio),"НЕ.ОПР.",s_tag->fio)
  qout('      <commerc_agent'+;
  ' name="'+ALLTRIM(fior)+'"'+;//Наливайко Н.Н.
  ' code="'+PADL(LTRIM(STR(dokk->kta)),4,"0")+'"'+;//<!--Код комерческого агента-->
  '>'+;
  PADL(LTRIM(STR(dokk->kta)),4,"0")+'</commerc_agent>')
  //<!--Код комерческого агента-->

  ////////   <!--Код филиала-->
  rmskr:=gnEnt*10+dokk->rmsk
  IF dokk->rmsk = 0 // основное предприятие
    setup->(__dbLocate({|| setup->Ent = gnEnt }))
    nrmskr:=setup->uss
  ELSE
    rmsk->(__dbLocate({|| rmsk->rmsk = dokk->rmsk }))
    nrmskr:=rmsk->nrmsk
  ENDIF

  qout('      <department'+;
  ' name="'+ALLTRIM(nrmskr)+'"'+;//Второй
  ' code="'+PADL(LTRIM(STR(rmskr)),3,"0")+'"'+;//<!--Код филиала-->
  '>'+;
  PADL(LTRIM(STR(rmskr)),3,"0")+;
  '</department>')
  //<!--Код филиала-->

  ////// <!-- номер документа закрытия -->
  qout('      <number_order>'+""+'</number_order>')
  //<!-- номер документа закрытия -->

  n_Sk:=IIF(!EMPTY(dokk->dokksk),dokk->dokksk,dokk->sk)

  IF EMPTY(xShipment)
    n_dokkttn:=0
  ELSE
    n_dokkttn:=dokk->dokkttn
  ENDIF

  qout('      <ukeyj_shipment>'+;
  IIF(!EMPTY(n_dokkttn),;
      (;
        ;//PADL(LTRIM(STR(dokk->dokkttn)),6,"0")+;//номер документа
        ;//PADL(LTRIM(STR(n_Sk)),3,"0")+;//код склада
        ;//(;
        ;// ddcr:=GetDataField(n_Sk,"rs1","_rs1","t1","dokk->dokkttn","rs1->ddc"),;
        ;// IIF(EMPTY(ddcr),"00000000",RIGHT(DTOS(ddcr),8));//dop - даты отгрузки
        ;//);
        PADL(LTRIM(STR(0,6)),6,"0")+;
        PADL(LTRIM(STR(0,6)),6,"0")+;
        PADL(LTRIM(STR(n_Sk,3)),3,"0")+;
        PADL(LTRIM(STR(dokk->dokkttn,6)),6,"0")+;
        PADL(LTRIM(STR(0,6)),6,"0");//номер документа
    ),;
      "")+;
  '</ukeyj_shipment>')



  /*
  rmsk->(__dbLocate({|| rmsk->rmsk = dokk->rmsk }))
  qout('      <department name="'+;
  ALLTRIM(rmsk->nrmsk)+'">'+; //Второй
  PADL(LTRIM(STR(dokk->rmsk)),3,"0")+;
  '</department>')
  //<!--Код склада-->
  */

  ////////  <!--Код торгового направления-->
  //код тогр направ принимаем по СуперВизору
  s_tag->(netseek('t1','dokk->ktas'))
  fior:=IIF(EMPTY(s_tag->fio),"НЕ.ОПР.",s_tag->fio)
  qout('      <trade_way'+;
  ' name="'+ALLTRIM(fior)+'"'+;//Пиво
  ' code="'+PADL(LTRIM(STR(dokk->ktas)),4,"0")+'"'+;//<!--Код торгового направления-->
  '>'+;
  PADL(LTRIM(STR(dokk->ktas)),4,"0")+'</trade_way>')
  //<!--Код торгового направления-->

  ////// <!--Дата регистарции-->
  qout('      <regdate>'+DTOC(ddc)+'</regdate>')
  //qout('      <regdate>'+DTOC(ddc) + 'T00:00:00'+'</regdate>')
  //<!--Дата регистарции-->

      //<ukeyj_payment>20080201 183456789 64412403 003</ukeyj_payment>
  qout('      <ukeyj_payment>'+;
  ;//                  20080201 183456789 32112302 002
  ;//DTOS(dokk->ddk)+;//даты регистрации проводки
  ;//PADL(LTRIM(STR(kln->kkl1)),10,"0")+;//инн покупателя
  ;//PADL(LTRIM(STR(dokk->rmsk)),3,"0")+;//код склада
  PADL(LTRIM(STR(dokk->mn,6)),6,"0")+;
  PADL(LTRIM(STR(dokk->rnd,6)),6,"0")+;
  PADL(LTRIM(STR(dokk->sk,3)),3,"0")+;
  PADL(LTRIM(STR(dokk->rn,6)),6,"0")+;
  PADL(LTRIM(STR(dokk->mnp,6)),6,"0")+;//номер документа
  ;////код тогр направ принимаем по СуперВизору
  ;//(;
  ;//s_tag->(netseek('t1','dokk->ktas')),;
  ;//PADL(LTRIM(STR(dokk->ktas)),4,"0");//код торового направления
  ;//)+;
  '</ukeyj_payment>')

  qout('  </jornel_payment>')
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-06-08 * 07:39:56pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION local_charset()
  RETURN (set("PRINTER_CHARSET"))


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-10-08 * 02:22:27pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Accord_VztDoc(aKop)

  lcrtt("tmpmdoc","moddoc")
  lcrtt("tmpdel","dokk")

  use tmpdel new


  netuse('moddoc')
  ordsetfocus("t1")
  netuse('dokko') //,'','',1)
  ordsetfocus("t12")
  total on &(indexkey(0))  to tmpdokk ;
  for (bs_d=361001 .or. bs_k=361001) .and.;
              moddoc->(DBSeek(;
              dokko->(&(moddoc->(indexkey(0))));
             )) .and. ;
    (!EMPTY(moddoc->DtModVz))

  close dokko
  close moddoc

  sele tmpdel
  append from tmpdokk
  close tmpdel

  use tmpmdoc new Exclusive
  append from tmpdokk
  If !EMPTY(LASTREC())
    repl all prd with BOM(gdtd)
    close tmpmdoc

    ModDoc(aKop,.F.,gdtd)
  else
    close tmpmdoc
  EndIf


  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-10-08 * 02:15:11pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Accord_ModDoc(aKop)
  LOCAL n_Kkl, lDele, cRmSk, nKkl_Def
  LOCAL dDtStart, nTmStart, cTmStart, cTTStart, cDtStart, aDtStart
  LOCAL cIndKey, cKeyWhile, cNetKeySeek
  LOCAL hdr

  cDtStart:="20090201"

  lcrtt("tmpdel","dokk")

  netuse('kln')
    kln->(__dbLocate({||!EMPTY(kln->kkl1) .and. len(LTRIM(STR(kln->kkl1)))>=10}))
    nKkl_Def:=kln->kkl
  nuse('kln')
  use tmpdel new
  netuse("moddoc")
  //netuse('cskl')
  netuse('rmsk')
  copy to tmp_rmsk for rmsk->ent=gnEnt
  use tmp_rmsk alias _rmsk

  DBAppend()
  repl Ent with gnEnt,;
   nrmsk with (;
      setup->(__dbLocate({|| setup->Ent = gnEnt })),;
      setup->uss;
           )


  //определить с какой даты и времени начать работать
  //(кой датой и временем закончить работать)

  iniFile:="acold_DtTm.ini"
  IF FILE(iniFile)

    oIni_DtTm:=iniFileNew(iniFile)
    oIni_DtTm:load()

    //dDtStart:=oIni_DtTm:getValue("accord","date") //,dDtStart)
    //nTmStart:=oIni_DtTm:getValue("accord","time") //,nTmStart)

    IF !EMPTY(oIni_DtTm:error)
      s:=[Error loading ini file:]+toString(iniFile)+":"+oIni_DtTm:error
      ?s
      outlog(s)
      RETURN
    ENDIF

  ELSE

    dDtStart:=STOD(cDtStart) //последние дата и время обработки
    //nTmStart:=86399.00
    nTmStart:=0.00
    oIni_DtTm:=iniFileNew() //"accord_DtTm.ini")

    _rmsk->(DBGoTop())
    Do While !_rmsk->(eof())
        cRmSk:=padl(alltrim(str(_rmsk->rmsk)),len(_rmsk->rmsk),'0')
        dDtStart:=oIni_DtTm:setValue("accord"+cRmSk,"date",dDtStart)
        nTmStart:=oIni_DtTm:setValue("accord"+cRmSk,"time",nTmStart)
        cTTStart:=oIni_DtTm:setValue("accord"+cRmSk,"thmc",SecToTime(nTmStart))
                  oIni_DtTm:setValue("accord"+cRmSk,"nrmsk",_rmsk->nrmsk)
      _rmsk->(DBSkip())
    EndDo

    //dDtStart:=oIni_DtTm:setValue("accord","date",dDtStart)
    //nTmStart:=oIni_DtTm:setValue("accord","time",nTmStart)


    oIni_DtTm:save(iniFile)


    IF !EMPTY(oIni_DtTm:error)
      s:=[Error loading ini file:]+toString(iniFile)+":"+oIni_DtTm:error
      ?s
      outlog(s)
      RETURN
    ENDIF

  ENDIF


  iniFile:="acold_DtTm_new.ini"
  oIni_DtTm_new:=iniFileNew() //"accord_DtTm.ini")

  sele moddoc
  ordsetfocus("t3")
  copy stru to tmpmdoc
  use tmpmdoc new Exclusive

  aDtStart := {STOD(cDtStart)}
  _rmsk->(DBGoTop())
  Do While !_rmsk->(eof())
      cRmSk:=padl(alltrim(str(_rmsk->rmsk)),len(_rmsk->rmsk),'0')

      dDtStart:=oIni_DtTm:getValue("accord"+cRmSk,"date") //,dDtStart)
      nTmStart:=oIni_DtTm:getValue("accord"+cRmSk,"time") //,nTmStart)
      If dDtStart = NIL .OR. nTmStart = NIL
        dDtStart:=STOD(cDtStart) //последние дата и время обработки
        nTmStart:=0.00
      EndIf

      IF aDtStart[1] < dDtStart
        aDtStart[1]:=dDtStart
      ENDIF

      //index on DTOS(dtmodvz)+tmmodvz to tmp1

      //outlog(__FILE__,__LINE__,cRmSk,DTOS(dDtStart),nTmStart)
      nTmStart:=nTmStart+0.01
      IF nTmStart>86399
        nTmStart-=86399
        dDtStart++
      ENDIF


      //cTmStart:=LTRIM(STR(nTmStart,8,2))
      cTmStart:=STR(nTmStart,8,2)
      //outlog(__FILE__,__LINE__,_rmsk->rmsk,'  ',DTOS(dDtStart),nTmStart)
      sele moddoc
      DBSEEK(DTOS(dDtStart)+cTmStart,.T.) //найдем ближнию дату и время
      //outlog(__FILE__,__LINE__,'  ',DTOS(DtModVz),TmModVz)

      IF !EOF()

        LOCATE FOR _rmsk->rmsk = moddoc->(mddokk('rmsk')) REST // найдем нужный склад

        IF FOUND()
          copy to tmpsmdoc rest for ;
          _rmsk->rmsk = moddoc->(mddokk('rmsk')) .and. ;
          prd >= STOD("20080601") .and.;
          Iif(przp=0,BOM(gdTd)=BOM(prd),.T.) .and. ;
          !(;
          ALLTRIM(moddoc->fld)="ID_DOKK" ;
          ;//.OR. ;
          ;//ALLTRIM(moddoc->fld)="DOKKSK" .OR. ;
          ;//ALLTRIM(moddoc->fld)="KTAS"  ;
        )
          copy file ('tmpsmdoc.dbf') to ('tmps'+cRmSk+".dbf")
          use tmpsmdoc new

          DBGOBOTTOM()
          IF VAL(cRmSk)#0 //для филиалов
            DO WHILE !BOF()
              IF .T. // tmpsmdoc->rm # 0 <- данные берутся с филиалов

                dDtStart:=tmpsmdoc->DtModVz //последние дата и время обработки
                cTmStart:=tmpsmdoc->TmModVz
                nTmStart:=val(ltrim(cTmStart))

                EXIT
              ENDIF
              DBSKIP(-1)
            ENDDO
            IF BOF() //все пересчитано на основном
              //записываем тоже время
              dDtStart:=oIni_DtTm:getValue("accord"+cRmSk,"date") //,dDtStart)
              nTmStart:=oIni_DtTm:getValue("accord"+cRmSk,"time") //,nTmStart)
            ENDIF
          ELSE

            dDtStart:=tmpsmdoc->DtModVz //последние дата и время обработки
            cTmStart:=tmpsmdoc->TmModVz
            nTmStart:=val(ltrim(cTmStart))

          ENDIF

          close tmpsmdoc

          sele tmpmdoc
          append from tmpsmdoc

        ELSE
          //записываем тоже время
          dDtStart:=oIni_DtTm:getValue("accord"+cRmSk,"date") //,dDtStart)
          nTmStart:=oIni_DtTm:getValue("accord"+cRmSk,"time") //,nTmStart)

        ENDIF
      ELSE
          //записываем тоже время
          dDtStart:=oIni_DtTm:getValue("accord"+cRmSk,"date") //,dDtStart)
          nTmStart:=oIni_DtTm:getValue("accord"+cRmSk,"time") //,nTmStart)

      ENDIF

      dDtStart:=oIni_DtTm_new:setValue("accord"+cRmSk,"date",dDtStart)
      nTmStart:=oIni_DtTm_new:setValue("accord"+cRmSk,"time",nTmStart)
      cTTStart:=oIni_DtTm_new:setValue("accord"+cRmSk,"thmc",SecToTime(nTmStart))
                oIni_DtTm_new:setValue("accord"+cRmSk,"nrmsk",_rmsk->nrmsk)

    _rmsk->(DBSkip())
  EndDo

  close moddoc
  close_mddokk()

  oIni_DtTm_new:save(iniFile)
  IF !EMPTY(oIni_DtTm_new:error)
    s:=[Error loading ini file:]+toString(iniFile)+":"+oIni_DtTm_new:error
    ?s
    outlog(s)
    RETURN
  ENDIF


  sele tmpmdoc
  IF !EOF()
    netuse('cskl')
    tmpmdoc->(DBGoTop())
    Do While tmpmdoc->(!eof())
      lDele:=.F.
      //If !(tmpmdoc->mn=0 .and. tmpmdoc->rnd=0) // бух. проводка
      If tmpmdoc->mn # 0 // бух. проводка

        If alltrim(tmpmdoc->fld)="уд"
          lDele:=.T.
        else

          lDele:=EnableDokk(361001)

        EndIf

      Else // (tmpdel->mn=0 .and. rnd=0) складские

        If tmpmdoc->mnp # 0 //сладские приход

          If alltrim(tmpmdoc->fld)="уд"
            lDele:=.T.
          else

            lDele:=EnableDokk(361001)

          EndIf

        Else //сладские расход
          If przp_0 //официал
            if tmpmdoc->przp = 0 // с д-та снято "подверждение"
              lDele:=.T.
            else // д-т может быть переведен на тарный счет 361002
              lDele:=EnableDokk(361001)
            endif
          Else

            yyr:=YEAR(tmpmdoc->prd)
            mmr:=MONTH(tmpmdoc->prd)
            path_dr=gcPath_e+'g'+str(yyr,4)+'\m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'
            pathr=path_dr+"bank\"

            if netfile('dokko',1)
              netuse('dokko','','',1)
              if .not. netseek("t12","tmpmdoc->mn,tmpmdoc->rnd,tmpmdoc->sk,tmpmdoc->rn,tmpmdoc->mnp")
                lDele:=.T.
              else

                ordsetfocus('t12')
                cKeyWhile:=NetKeySeek("t12","tmpmdoc->mn,tmpmdoc->rnd,tmpmdoc->sk,tmpmdoc->rn,tmpmdoc->mnp")
                //outlog(__FILE__,__LINE__,cKeyWhile)

                locate for bs_d=361001 .or. bs_k=361001;
                while (;
                  cNetKeySeek := NetKeySeek("t12","dokko->mn,dokko->rnd,dokko->sk,dokko->rn,dokko->mnp"),;
                  cKeyWhile = cNetKeySeek;
                )

                If !Found() //проводки есть да не про нашу честь
                  lDele:=.T.
                EndIf

              endif
              nuse('dokko')
            else
              lDele:=.T.
            endif

          EndIf

        EndIf

      EndIf

      If  lDele

        sele tmpmdoc
        copy to tmp1 next 1
        sele tmpdel
        append from tmp1

        yyr:=YEAR(tmpmdoc->prd)
        mmr:=MONTH(tmpmdoc->prd)
        path_dr=gcPath_e+'g'+str(yyr,4)+'\m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'
        pathr=path_dr+"bank\"

        nKop:=160
        n_Kkl:=nKkl_Def

        //IF !(tmpmdoc->mn=0 .and. tmpmdoc->rnd=0) // бух. проводка
        IF tmpmdoc->mn # 0 // бух. проводка

          if netfile('dokz',1)
            netuse('dokz','','',1)

            tmpdel->ddk:=getfield('t2','tmpmdoc->mn','dokz','ddc')

            If Empty(tmpdel->ddk)
              #ifdef __CLIP__
                outlog(__FILE__,__LINE__,"e_rror ",;
                tmpmdoc->mn,"Empty(tmpdel->ddk)"," for ",'mn')
              #endif
              tmpdel->ddk:=tmpmdoc->prd
            EndIf
            nuse('dokz')

          else
            #ifdef __CLIP__
              outlog(__FILE__,__LINE__,"e_rror ",;
              tmpmdoc->mn,"Empty(tmpdel->ddk)"," for ",'mn')
            #endif
            tmpdel->ddk:=tmpmdoc->prd
          endif

        ELSE // (tmpdel->mn=0 .and. rnd=0) складские

          tmpdel->ddk:=;
          GetDataField(;
          tmpmdoc->Sk,'rs1','_rs1','t1','tmpmdoc->rn','_rs1->dot';
            )

          nKop:=;
          GetDataField(;
          tmpmdoc->Sk,'rs1','_rs1','t1','tmpmdoc->rn','_rs1->kop';
            )

          If nKop = 169

            n_Kkl:=;
            GetDataField(;
            tmpmdoc->Sk,'rs1','_rs1','t1','tmpmdoc->rn','_rs1->nkkl';
              )
          else

            n_Kkl:=;
            GetDataField(;
            tmpmdoc->Sk,'rs1','_rs1','t1','tmpmdoc->rn','_rs1->kpl';
              )

          EndIf
          If nKop=0
            nKop := 160
          EndIf
          If n_Kkl=0
            n_Kkl:=nKkl_Def
          EndIf

          If Empty(tmpdel->ddk) .or. bom(tmpmdoc->prd)#bom(tmpdel->ddk)
            #ifdef __CLIP__
              outlog(__FILE__,__LINE__,"e_rror ",;
              tmpmdoc->Sk,tmpmdoc->rn,;
              "Empty(tmpdel->ddk)"," for ",'Sk,rn')
            #endif
            tmpdel->ddk:=tmpmdoc->prd
          EndIf

        ENDIF

        tmpdel->ddc := tmpdel->ddk
        tmpdel->Kkl := n_Kkl
        tmpdel->kop := nKop
        tmpdel->bs_s:=0

      EndIf
      sele tmpmdoc
      tmpmdoc->(DBSkip())
    EndDo

    close tmpmdoc
    close tmpdel
    nuse('cskl')

  ELSE

    //обнулим файл
    hdr:=fcreate('load_full.sh')
    fclose(hdr)

    RETURN NIL

  ENDIF

  ModDoc(aKop, NIL, NIL, NIL, aDtStart)

  RETURN (NIL)


/*****************************************************************
 
 FUNCTION: EnableDokk()
 АВТОР..ДАТА..........С. Литовка  02-21-09 * 08:48:54pm
 НАЗНАЧЕНИЕ......... проверка на удаление проводок и
                      если есть, то долны быть 361001
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC Function EnableDokk()
  LOCAL lDele:=.F.

  yyr:=YEAR(tmpmdoc->prd)
  mmr:=MONTH(tmpmdoc->prd)
  path_dr=gcPath_e+'g'+str(yyr,4)+'\m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'
  pathr=path_dr+"bank\"

  if netfile('dokk',1)
    netuse('dokk','','',1)
    ordsetfocus('t12')
    if .not. netseek("t12","tmpmdoc->mn,tmpmdoc->rnd,tmpmdoc->sk,tmpmdoc->rn,tmpmdoc->mnp")
      lDele:=.T.
    else

      ordsetfocus('t12')
      cKeyWhile:=NetKeySeek("t12","tmpmdoc->mn,tmpmdoc->rnd,tmpmdoc->sk,tmpmdoc->rn,tmpmdoc->mnp")
      //outlog(__FILE__,__LINE__,cKeyWhile)

      locate for bs_d=361001 .or. bs_k=361001;
                while (;
                  cNetKeySeek := NetKeySeek("t12","dokk->mn,dokk->rnd,dokk->sk,dokk->rn,dokk->mnp"),;
                  cKeyWhile = cNetKeySeek;
                )

      If !Found() //проводки есть да не про нашу честь
        lDele:=.T.
      EndIf

    endif
    nuse('dokk')
  else
    lDele:=.T.
  endif
  Return (lDele)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-03-08 * 10:33:26am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION ModDoc(aKop, lModDoc,dDtStart, nTmStart, aDtStart)
  LOCAL n_Kkl, cNmDir, iniFile, cCurDirUnix
  LOCAL aLineRun, hdr
  LOCAL cLogSysCmd, cCmnt
  LOCAL nReportYear:=2020

  DEFAULT lModDoc TO YES
  aLineRun:={}

  lcrtt("tmpdokk","dokk")
  lindx("tmpdokk","dokk")


  IF FILE("tmpmdoc.cdx")
    ERASE ("tmpmdoc.cdx")
  ENDIF

  USE tmpmdoc ALIAS moddoc NEW
  IF lModDoc
  ENDIF
  INDEX ON prd TAG t1


  sele moddoc
  moddoc->(DBGOTOP())
  DO WHILE !EOF()

    prdr:= moddoc->prd
    yyr:=YEAR(moddoc->prd)
    mmr:=MONTH(moddoc->prd)
    path_dr=gcPath_e+'g'+str(yyr,4)+'\m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'
    pathr=path_dr+"bank\"

    if !netfile('dokk',1)
      sele moddoc
      skip
      loop
    endif
    netuse('dokk','','',1)
    netuse('dokko','','',1)


    DO WHILE  prdr = moddoc->prd

      IF EMPTY(SELECT("tmpdokk"))

        use ("tmpdokk.dbf") ALIAS tmpdokk NEW EXCLUSIVE
        zap
        close

        luse("tmpdokk")

      ENDIF

      mnr := moddoc->mn
      rndr:= moddoc->rnd
      skr := moddoc->sk
      rnr := moddoc->rn
      mnpr:= moddoc->mnp

      IF moddoc->Przp = 1
        sele dokk
      ELSE
        IF przp_0 .and. lModDoc // официал
          //на удаление, и проводки нулевые добалены
          sele moddoc
          DBSKIP()
          LOOP
        ELSE
          sele dokko
        ENDIF
      ENDIF
      ordsetfocus("t12")

      if netseek("t12","mnr,rndr,skr,rnr,mnpr")
        copy to tmp1 while  mn = moddoc->mn .AND. ;
                            rnd = moddoc->rnd .AND. ;
                            sk = moddoc->sk   .AND. ;
                            rn  = moddoc->rn  .AND. ;
                            mnp = moddoc->mnp

        If lower(alias())=='dokko'
          //востановление нормального состояния д-ка
          use tmp1 new Exclusive
          repl all kkl with nKkl for kop = 169
          repl all kop with kop*10
          close tmp1
        EndIf

        sele tmpdokk
        append from tmp1
      else

  #ifdef __CLIP__
       /*
        outlog(__FILE__,__LINE__,;
        moddoc->Przp,moddoc->fld,moddoc->(RECNO()),;
        'netseek("t12","mnr,rndr,skr,rnr,mnpr")-->NO')
        DO CASE
        CASE mn#0 // проводка бух учета, а какая
          // - оплтат             // - отгрузка
          outlog(__FILE__,__LINE__,"    mn#0 // проводка бух учета, а какая")
        CASE mn=0 .AND. mnp # 0 //проход товар
          // - оплтата             // - отгрузка
          outlog(__FILE__,__LINE__,"    mn=0 .AND. mnp # 0 //проход товар")
        CASE mn=0 .AND. mnp = 0 //расход
          // - всегда положительна
          outlog(__FILE__,__LINE__,"    mn=0 .AND. mnp = 0 //расход")
        ENDCASE
        */
  #endif

      endif

      sele moddoc
      DBSKIP()
      //str(mn,6)+str(rnd,6)+str(sk,3)+str(rn,6)+str(mnp,6) //+str(nprov,3)
    ENDDO
    close dokko
    close dokk

  ENDDO

  close tmpdokk
  //quit
  //outlog(__FILE__,__LINE__, dDtStart, nTmStart)




  cCurDirUnix:="."
  AADD(aLineRun,"#!/bin/sh")
  AADD(aLineRun,"export err_o=0")
  AADD(aLineRun,"")
  //cCurDirUnix:=SET(DISKNAME()+":")+DIRNAME()
  // outlog(__FILE__,SET(DISKNAME()))

  use tmpdokk Alias dokk new Exclusive
  IF lModDoc
    append from tmpdel
  ENDIF
  IF lModDoc
    dDtStart:=NIL
  ENDIF
  ordsetfocus('t4')
  total on dtos(ddk) to tmpddk //получим список дней

  use tmpddk new
  DO WHILE tmpddk->(!EOF())
    CreateAccordXml(tmpddk->ddk,tmpddk->ddk,"dokk",aKop,dDtStart,aDtStart)

    cNmDir:="xml"+RIGHT(DTOS(tmpddk->ddk),6)
    If YEAR(tmpddk->ddk) # nReportYear
      cCmnt:="#"
    else
      cCmnt:=""
    EndIf
    AADD(aLineRun,cCmnt+"cd "+cCurDirUnix+"\"+cNmDir+" ; .\load.sh ; cd ..")
    AADD(aLineRun,cCmnt+"err=`/bin/cat "+cCurDirUnix+"\"+cNmDir +"\load_data1.log "+ "|grep error |wc -l`")
    AADD(aLineRun,cCmnt+"err_o=$[$err_o+$err]")
    AADD(aLineRun,cCmnt+"")

    tmpddk->(DBSKIP())
  ENDDO

  close tmpddk
  close dokk

  close moddoc
  nuse()
  /*
  проверить отработала без ошибки, тогда запаковать
  */
  AADD(aLineRun,"")
  AADD(aLineRun,"echo $err_o >_err")
  AADD(aLineRun,"")
  AADD(aLineRun,"if [ $err_o = 0 ] ; then")
  AADD(aLineRun,"  ./tgz-arc.sh")
  IF lModDoc
    AADD(aLineRun,lower("  /bin/cp ./acold_DtTm_new.ini ./acold_DtTm.ini"))
  ENDIF
  AADD(aLineRun,"fi")
  AADD(aLineRun,"")


  hdr:=fcreate('load_full.sh')
      AEVAL(aLineRun,;
      {|cElem|fwrite(hdr,(ATREPL('\',RTRIM(cElem),"/"))+LF)};
    )
  fclose(hdr)
  #ifdef __CLIP__
    cLogSysCmd:=""
    //SYSCMD("wget -i rd_anb.wget -o rn_anb.wget.log","",@cLogSysCmd)
    //outlog(__LINE__,cSysCmd)
    SYSCMD("/bin/chmod +x "+'./load_full.sh',"",@cLogSysCmd)
    outlog(__FILE__,__LINE__,cLogSysCmd)
  #endif


  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-05-08 * 07:04:53pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION CreateAccordXml(dBeg,dEnd,cAliasDokk,aKop,d_Ddk,aDtStart)
  LOCAL dOtch, cDirXml
  LOCAL nSumDB, nSumKR
  LOCAL file, oHtml, oMeta
  LOCAL lErr
  lErr:=.F.
  dOtch:=dBeg
  #ifdef __CLIP__
      outlog(__FILE__,__LINE__,"Отчет:", dOtch, d_ddk)
  #endif
  IF FILE("cor_db.dbf")
    IF !EMPTY(SELECT("cor_db.dbf"))
      CLOSE cor_db
    ENDIF
    ERASE ("cor_db.dbf")
  ENDIF

  //cAliasDokk:=NIL

  nSumDB:=Accord_Dokk(dBeg,dEnd,cAliasDokk,d_Ddk,,"jornel_"+DTOS(dOtch)+"DB"+".xml",.F.,0,;
  ;//оплата по банку и КА
  {|| bs_d=361001 };
  ;//
)
  nSumKR:=Accord_Dokk(dBeg,dEnd,cAliasDokk,d_Ddk,,"jornel_"+DTOS(dOtch)+"KR"+".xml",.F.,0,;
  ;//оплата по банку и КА
  {|| bs_k=361001 },;
  nSumDB;
  ;//
)

  cLogSysCmd:=""
  #ifdef __CLIP__
  if (UPPER("/itogo") $ cDosParam)
    cSysCmd :=""
    cSysCmd+="wget "+;
           "-O _b4.xml "+;
           "'http://localhost/cgi-bin/aquarum/balance4?;;"+;
           "beg_date="+DTOC(bom(dBeg),"dd.mm.yyyy")+;//"01.03.2012"
           ";"+;
           "end_date="+DTOC(dEnd,"dd.mm.yyyy")+; //"31.03.2012"
           ";"+;
           "balance=004;itogo=true;"+;
           ;//"ACC01=ACC0"+LTRIM(STR(YEAR(dBeg)-1907))+;// 105 year
           "ACC01=ACC01"+PADL(alltrim(NTOC(YEAR(dBeg)-2007,16)),2,'0')+;
           "'"
           /*
           ""
           */
          //outlog(__FILE__,__LINE__,cSysCmd)

    SYSCMD(cSysCmd,"",@cLogSysCmd)

        file:="_b4.xml"
        oHtml := _data_parse(file)
        if !empty(oHtml:error)
            outlog(__FILE__,__LINE__,"Parse error",oHtml:error)
            return
        endif
        oMeta := _data_trans_balance(oHtml)
        If round((VAL(oMeta:A500:ok_summa) - VAL(oMeta:A500:od_summa))-(nSumDB-nSumKR),2)=0
          //outlog(__FILE__,__LINE__,dEnd,"  OK!!!")
        Else
          lErr:=.T.
          outlog(__FILE__,__LINE__,dEnd,"ERROR", round((VAL(oMeta:A500:ok_summa) - VAL(oMeta:A500:od_summa))-(nSumDB-nSumKR),2))
          outlog(__FILE__,__LINE__, " "+oMeta:A500:ok_summa, " "+oMeta:A500:od_summa)
          outlog(__FILE__,__LINE__, nSumDB, nSumKR)


          SendingJafa("lista@bk.ru",{{ "","Error AccordProdResSumy"+" "+DTOC(dEnd,"YYYYMMDD")}},;
          DTOC(dEnd)+" ERROR "+str(round((VAL(oMeta:A500:ok_summa) - VAL(oMeta:A500:od_summa))-(nSumDB-nSumKR),2)),;
          228)

        EndIf

    cDirXml:="xml"+RIGHT(DTOS(dOtch),6)
    DIRMAKE(cDirXml)
    SYSCMD("cp ./jor* ./"+cDirXml+"/","",@cLogSysCmd)
    SYSCMD("rm -f ./jor*","",@cLogSysCmd)

  EndIf

  #endif


  if !(UPPER("/itogo") $ cDosParam) .or.  ;
    ((UPPER("/itogo") $ cDosParam) .AND. lErr)

    Accord_PR1(dBeg,dEnd,cAliasDokk,aKop,d_Ddk,"ВЗРТ") //,@a-SumAccord)

    Accord_RS1(dBeg,dEnd,cAliasDokk,aKop,d_Ddk) //,@a-SumAccord)

    Accord_Dokk(dBeg,dEnd,cAliasDokk,d_Ddk,{||IIF((STR(INT(bs_d/10^3),3)$"301"),"КЧ","ПП")},"jornel_payment.xml",.F.,1,;
    ;//оплата по банку и КА
    {|| mn#0 .AND.(STR(INT(bs_d/10^3),3)$"301 311" .AND. bs_k=361001)};
    ;//
  )


    // КРОМЕ оплаты по банку и КА - НАТУРАЛЬНАЯ ОПЛАТ абсолютное значение
    Accord_Dokk(dBeg,dEnd,cAliasDokk,d_Ddk,"БСКР","jornel_paycork.xml",.T.,1,;
    {|| (mn#0 .AND.;
        (;
          (.NOT.(STR(INT(bs_d/10^3),3)$"301 311") .AND. bs_k=361001 .AND. dokk->bs_s>0) .OR.;
          (bs_d=361001 .AND. .NOT.(STR(INT(bs_k/10^3),3)$"301 311") .AND. dokk->bs_s<0) .OR.;
          ; /////////// удаленные ////////
          (bs_d=0 .AND. bs_k=0 .AND. bs_s=0);
          ; /////////////////////////////////
      )) .or.;
          ; ///////////  ANY удаленные ////////
          (bs_d=0 .AND. bs_k=0 .AND. bs_s=0);
          ; /////////////////////////////////
    };
    ;//
  )

    // КРОМЕ оплаты по банку и КА - ОТГРУЗКА ТОВАРА абсолютное значение
    Accord_CorrDB(dBeg,dEnd,cAliasDokk,aKop,d_Ddk,"БСДБ","jornel_paycord.xml",.T.,-1,;
    {|| ;
      ;// (;
      ;//   mn=0 .AND. ;
      ;//   (;
      ;//    (.NOT.(STR(INT(bs_d/10^3),3)$"301 311") .AND. bs_k=361001 .AND. dokk->bs_s<0);
      ;// );
      ;//);
      ;//.OR.;
      (;
        mn#0 .AND.;
        (;
          (;
            (bs_d=361001 .AND. .NOT.(STR(INT(bs_k/10^3),3)$"301 311") .AND. dokk->bs_s>0) .OR.;
            (.NOT.(STR(INT(bs_d/10^3),3)$"301 311") .AND. bs_k=361001 .AND. dokk->bs_s<0);
        ) .OR. ;
          (;
            (bs_d=361001 .AND. (STR(INT(bs_k/10^3),3)$"301 311") .AND. dokk->bs_s>0) .OR.;
            ((STR(INT(bs_d/10^3),3)$"301 311") .AND. bs_k=361001 .AND. dokk->bs_s<0);
        );
      );
    );
    };
    ;//
  )



    cDirXml:="xml"+RIGHT(DTOS(dOtch),6)
    DIRMAKE(cDirXml)
    //FileDelete(cDirXml+'\*.log')

    cLogSysCmd:=""
    #ifdef __CLIP__
    SYSCMD("rm -f ./"+cDirXml+"/"+"*.log","",@cLogSysCmd)
    //outlog(__FILE__,__LINE__,cLogSysCmd)
    SYSCMD("cp ./jor* ./"+cDirXml+"/","",@cLogSysCmd)
    //outlog(__FILE__,__LINE__,cLogSysCmd)

    IF aDtStart = NIL
      IF dOtch = EOM(dOtch)
        SYSCMD("cp ./load_eom.sh ./"+cDirXml+"/load.sh","",@cLogSysCmd)
      ELSE
        SYSCMD("cp ./load.sh ./"+cDirXml+"/","",@cLogSysCmd)
      ENDIF
    ELSE
      //outlog(__LINE__,dOtch , aDtStart[1])
      If dOtch < aDtStart[1]
        SYSCMD("cp ./load_p2sh.sh ./"+cDirXml+"/load.sh","",@cLogSysCmd)

      Else
        SYSCMD("cp ./load.sh ./"+cDirXml+"/","",@cLogSysCmd)

      EndIf
    ENDIF

    //SYSCMD("cp -s ./load_data1 ./xml"+RIGHT(DTOS(dOtch),6)+"/load_data1","",@cLogSysCmd)
    //outlog(__FILE__,__LINE__,cLogSysCmd)
    SYSCMD("rm -f ./jor*","",@cLogSysCmd)
    #endif
    If ((UPPER("/itogo") $ cDosParam) .AND. lErr)
      outlog(__FILE__,__LINE__,'((UPPER("/itogo") $ cDosParam) .AND. lErr)')
      QUIT
    EndIf
  EndIf


  /*

  cLogSysCmd:=""
  SYSCMD("./load.sh","",@cLogSysCmd)
  #endif
  set print to clvrt.log ADDI
  //outlog(__FILE__,__LINE__,cLogSysCmd)
  qout(__FILE__,__LINE__,cLogSysCmd)
  */

  RETURN (NIL)

/*---------------------------------------------------------------*/
static function _data_parse(xmlFile)
        local hFile, oHtml
        local lSet := set(_SET_TRANSLATE_PATH,.f.)

        oHtml := htmlParserNew()
        hFile := fopen(xmlFile,0)
        set(_SET_TRANSLATE_PATH,lSet)
        if hFile < 0
                oHtml:error := [Error open file:]+xmlFile+":"+ferrorstr()
                return oHtml
        endif
        do while !fileeof(hFile)
                oHtml:put(freadstr(hFile,20))
        enddo
        fclose(hFile)
        oHtml:end()
return oHtml

*****************************
static function _data_trans_balance(oHtml)
        local oTag,oMeta
        local tagname:=""
        local oData, cAccount

        oMeta:=map()

        do while !oHtml:empty()
                oTag:=oHtml:get()
                //outlog(__LINE__,__FILE__,oTag)
                if empty(oTag)
                        loop
                endif
                if empty(oTag)
                        CDATA += "&\n"
                        loop
                endif
                if valtype(oTag)=="C"
                        CDATA += oTag
                        loop
                endif
                if valtype(oTag)=="O" .and. oTag:classname=="HTML_TAG"
                else
                        loop
                endif
                if oTag:tagname=="!" .or. left(oTag:tagname,1) == "?"
                        loop
                endif
                if oTag:tagname=="ROOT"
                        loop
                endif
                if oTag:tagname == "ITEM"
                  do while .t.
                    oTag:=oHtml:get()

                    //outlog(__LINE__,__FILE__,oTag)
                    if (!empty(oTag) .and. oTag:tagname == "OBJECT")
                        do while .t.
                            oTag:=oHtml:get()
                            //outlog(__LINE__,__FILE__,oTag)
                            if oTag:tagname == "ACCOUNT"
                                oTag:=oHtml:get() //┌╬┴▐┼╬╔
                                //outlog(__FILE__,__LINE__,oTag,val(oTag), str(val(oTag)))
                                cAccount:="A"+str(val(oTag))
                                oMeta[cAccount]:=map()
                                oTag:=oHtml:get() // ┌┴╦╥┘╠╔ ╘┼╟
                                loop
                            endif
                            if (!empty(oTag) .and. oTag:tagname == "/OBJECT")
                                exit
                            endif
                            tagname := upper(oTag:tagname)
                            oTag:=oHtml:get()
                            //outlog(__FILE__,__LINE__,tagname,oTag)
                            oMeta[cAccount][tagname]:=oTag
                            oTag:=oHtml:get()

                        enddo
                    endif
                    if (!empty(oTag) .and. oTag:tagname == "/ITEM")
                       exit
                    endif
                  enddo
                endif

                exit
        enddo
        //outlog(__FILE__,__LINE__,oMeta)
        //outlog(__FILE__,__LINE__, oMeta:A500:od_summa, oMeta:A500:ok_summa)
return oMeta


     /*
     //обновим КодТоргового и Его ТоргТочки
     sele stagtm
     IF netseek('t1','ktar','stagtm')
      DO WHILE ktar = kta
        tmestor:=tmesto
        kgpr:=getfield('t1','tmestor','etm','kgp')
        IF !netseek('t1','ktar,kgpr','stagt')
          sele stagt
          netadd()
          netrepl('kta,kgp','ktar,kgpr')
        ENDIF
        sele stagtm
        DBSKIP()
      ENDDO

     ENDIF
    */


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  03-16-08 * 10:54:30pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION _Accord_Rs1(dShDateBg, dShDateEnd,cAliasDokk,aKop)
  LOCAL nPos_AKop
   netuse('cskl')
   netuse('rmsk')
   netuse('kln')
   netuse('knasp')
   netuse('opfh')
   netuse('s_tag')

   netuse('etm')

  SET DATE FORMAT "dd.mm.yyyy"
  SET CENTURY ON
  //╦╠┴╙╙╔╞╔╦┴╘╧╥ ╘╧╥╧╟╧╫┘╚ ╘╧▐┼╦

  set console off
  set print on
  set print to jornel_shipment.xml
  qqout('<?xml version="1.0" encoding="'+local_charset()+'"?>')
   qout('<root>')

  dt1r:=dShDateBg
  dt2r:=dShDateEnd
  FOR yyr=year(dt1r) to year(dt2r)
    DO CASE
    CASE year(dt1r)=year(dt2r)
      mm1r=month(dt1r)
      mm2r=month(dt2r)
    CASE yyr=year(dt1r)
      mm1r=month(dt1r)
      mm2r=12
    CASE yyr=year(dt2r)
      mm1r=1
      mm2r=month(dt2r)
    OTHE
      mm1r=1
      m2r=12
    ENDC
    for mmr=mm1r to mm2r
      path_dr=gcPath_e+'g'+str(yyr,4)+'\m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'
      sele cskl
      go top
      do while !eof()

        IF ent#gnEnt .OR. ;
          rasc#1
          skip;        loop
        ENDIF

        pathr=path_dr+alltrim(path)
        if !netfile('tovm',1)
            sele cskl
            skip
            loop
        endif
        skr=sk
        netuse('rs1','','',1)

        sele rs1
        DBGoTop()
        do while !eof()

          IF vo=9 .and. ;//sdv=0 .or. ;
            ;//период анализа
            (dop >= dShDateBg .AND. dop <= dShDateEnd)

            qout('   <jornel_shipment>')

            qout('      <odate>'+DTOC(rs1->dop)+'</odate>')
            //qout('      <odate>'+DTOC(rs1->dop) + 'T00:00:00'+'</odate>')
            //<!--Дата отгрузки-->

            qout('      <summa>'+ LTRIM(STR(rs1->sdv)) +'</summa>')
            //<!--Сумма отгрузки-->

            qout('      <number_order>'+LTRIM(STR(rs1->ttn))+'</number_order>')
            //<!--номер документа-->

            //ч.з. поиск значения в 3-ем элементе
            nPos_AKop:=ASCAN(aKop,{|aElem| aElem[1]= rs1->kop })
            qout('      <type_payment'+;
            ' name="'+IIF(nPos_AKop=0,PADL(LTRIM(STR(rs1->kop)),3,"0")+"-Код операции",aKop[nPos_AKop,2])+'"'+;
            ' code="'+PADL(LTRIM(STR(rs1->kop)),3,"0")+'"'+;//<!--Код операции-->
            '>'+;
            PADL(LTRIM(STR(rs1->kop)),3,"0")+'</type_payment>')
            //<!--Код операции-->


            kln->(netseek('t1','rs1->kpl'))
            knasp->(netseek('t1','kln->knasp'))
            opfh->(netseek('t1','kln->opfh'))
            nklr:=ATREPL('"',ALLTRIM(kln->nkl),"'")
            nklr  :=ATREPL('\',ALLTRIM(nklr),"/")
            nklr  :=SUBSTR(nklr,AT(" ",nklr)+1)
            nklr  :=IIF(LEFT(nklr,1)="'",SUBSTR(nklr,2),nklr)
            nnaspr:=ATREPL('"',ALLTRIM(knasp->nnasp),"'")
            nnaspr:=ATREPL('\',ALLTRIM(nnaspr),"/")

            adrr  :=ATREPL('"',ALLTRIM(kln->adr),"'")
            adrr  :=ATREPL('\',ALLTRIM(adrr),"/")

            tlfr:=ATREPL('"',ALLTRIM(kln->tlf),"'")



            qout('      <customers'+;
            ' state-form="'+ALLTRIM(opfh->nsopfh)+'"'+;
            ' fullname="'+ALLTRIM(opfh->nsopfh)+" "+ALLTRIM(nklr)+'"' +;//"ООО Рога и копыта"
            ' name="'+ALLTRIM(nklr)+'"' +;//"ООО Рога и копыта"
            ' post_city="'+ALLTRIM(nnaspr)+'"'+ ; //Ижевск
            ' post_street="'+ALLTRIM(adrr)+'"'+ ; //Ижевск
            ' phone="'+ALLTRIM(tlfr)+'"'+ ; //Ижевск
            ' egrpu="'+LTRIM(STR(kln->kkl1))+'"'+ ; //ИНН покупателя
            ' inn_code="'+LTRIM(STR(kln->kkl))+'"'+ ; //код покупателя
            '>'+LTRIM(STR(kln->kkl))+; //183456789321</customers>')
            '</customers>')
            //<!--ИНН покупателя-->

            /*
            etm->(netseek('t1','rs1->tmesto'))
            qout('      <trade_point name="'+;
            ALLTRIM(etm->ntmesto)+'">'+;//Фиг его знает
            PADR(LTRIM(STR(rs1->tmesto)),7,"0")+'</trade_point>')
            //PADR(LTRIM(STR(rs1->kgp)),7,"0")+'</trade_point>')
            */

            kln->(netseek('t1','rs1->kgp'))
            nklr:=ATREPL('"',ALLTRIM(kln->nkl),"'")
            nklr  :=ATREPL('\',ALLTRIM(nklr),"/")
            qout('      <trade_point'+;
            ' name="'+ALLTRIM(nklr)+'"'+;//Фиг его знает
            ' code="'+LTRIM(STR(rs1->kgp))+'"'+;//Код торговой точки
            '>'+;
            LTRIM(STR(rs1->kgp))+'</trade_point>')
            //<!--Код торговой точки-->

            s_tag->(netseek('t1','rs1->ktas'))
            qout('      <superviser'+;
            ' name="'+ALLTRIM(s_tag->fio)+'"'+;//Суперпиво
            ' code="'+PADL(LTRIM(STR(rs1->ktas)),4,"0")+'"'+;//Суперпиво
            '>'+;
            PADL(LTRIM(STR(rs1->ktas)),4,"0")+'</superviser>')
            //<!--Код супервайзера-->

            s_tag->(netseek('t1','rs1->kta'))
            qout('      <commerc_agent'+;
            ' name="'+ALLTRIM(s_tag->fio)+'"'+;//Наливайко Н.Н.
            ' code="'+PADL(LTRIM(STR(rs1->kta)),4,"0")+'"'+;//<!--Код комерческого агента-->
            '>'+;
            PADL(LTRIM(STR(rs1->kta)),4,"0")+'</commerc_agent>')
            //<!--Код комерческого агента-->

            rmskr:=gnEnt*10+rs1->rmsk
            IF rs1->rmsk = 0 // основное предприятие
              setup->(__dbLocate({|| setup->Ent = gnEnt }))
              nrmskr:=setup->uss
            ELSE
              rmsk->(__dbLocate({|| rmsk->rmsk = rs1->rmsk }))
              nrmskr:=rmsk->nrmsk
            ENDIF

            qout('      <department'+;
            ' name="'+ALLTRIM(nrmskr)+'"'+;//Второй
            ' code="'+PADL(LTRIM(STR(rmskr)),3,"0")+'"'+;//<!--Код филиала-->
            '>'+;
            PADL(LTRIM(STR(rmskr)),3,"0")+;
            '</department>')
            //<!--Код филиала-->

            //код тогр направ принимаем по СуперВизору
            s_tag->(netseek('t1','rs1->ktas'))
            qout('      <trade_way'+;
            ' name="'+ALLTRIM(s_tag->fio)+'"'+;//Пиво
            ' code="'+PADL(LTRIM(STR(rs1->ktas)),4,"0")+'"'+;//<!--Код торгового направления-->
            '>'+;
            PADL(LTRIM(STR(rs1->ktas)),4,"0")+'</trade_way>')
            //<!--Код торгового направления-->


            IF EMPTY(DtOpl)
              DtOplr:=dop+14
            ELSEIF DtOpl = dTtnDt
              DtOplr:=dop+14
            ELSE
              DtOplr:=DtOpl
            ENDIF

            qout('      <due_date>' + DTOC(DtOplr)+'</due_date>') //01.03.2008
            //qout('      <due_date>' + DTOC(DtOplr) + 'T00:00:00'+'</due_date>') //01.03.2008
            //<!--Срок оплаты-->

            kln->(netseek('t1','rs1->kpl'))
            qout('      <ukeyj_shipment>'+;
            ;//2008020118345678932112302002
            ;//
            ;//PADL(LTRIM(STR(rs1->ttn)),6,"0")+;//номер документа
            ;//PADL(LTRIM(STR(cskl->sk)),3,"0")+;//код склада
            ;//RIGHT(DTOS(rs1->ddc),8)+;//dop даты отгрузки ddc-создан
            ;//
            PADL(LTRIM(STR(dokk->mn,6)),6,"0")+;
            PADL(LTRIM(STR(dokk->rnd,6)),6,"0")+;
            PADL(LTRIM(STR(dokk->sk,3)),3,"0")+;
            PADL(LTRIM(STR(dokk->rn,6)),6,"0")+;
            PADL(LTRIM(STR(dokk->mnp,6)),6,"0")+;//номер документа
            ;//PADL(LTRIM(STR(kln->kkl1)),10,"0")+;//инн покупателя
            ;////код тогр направ принимаем по СуперВизору
            ;//(;
            ;//s_tag->(netseek('t1','rs1->ktas')),;
            ;//PADL(LTRIM(STR(rs1->ktas)),4,"0");//код торового направления
            ;//)+;
            '</ukeyj_shipment>')
            /*
            <!--
                Значение <ukeyj_shipment> формируется из
                даты отгрузки+
                инн покупателя+
                номер документа+
                код склада+
                код торового направления

                Портянка формируется за день по всем документам или только по тем
                документам, которые нужно перепровести.
            -->
            */

            qout('  </jornel_shipment>')
          endif

          sele rs1
          skip
        endd
        nuse('rs1')
        sele cskl
        skip
      endd
    next
  next

  qout('</root>')

  set print to
  set print off

  nuse('kln')
  nuse('knasp')
  nuse('s_tag')
  nuse('etm')
  nuse('cskl')

  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-06-08 * 07:54:51pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION  Accord_empty_xml()

  set console off
  set print on
  set print to jornel_paycord.xml
  qqout('<?xml version="1.0" encoding="'+local_charset()+'"?>')
  qout('<root>')
  qout('</root>')
  set print to
  set print off

  set console off
  set print on
  set print to jornel_paycork.xml
  qqout('<?xml version="1.0" encoding="'+local_charset()+'"?>')
  qout('<root>')
  qout('</root>')
  set print to
  set print off

  set console off
  set print on
  set print to jornel_return.xml
  qqout('<?xml version="1.0" encoding="'+local_charset()+'"?>')
  qout('<root>')
  qout('</root>')
  set print to
  set print off

  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  02-23-09 * 02:15:52pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION rd_accord_kln(nKln)

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION: GetDataField(nSk,cDataBase,cSeek,cRetField)
 АВТОР..ДАТА..........С. Литовка  06-05-08 * 01:19:13pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION GetDataField(nSk,cDataBase,cAlias,cTag,cSeek,cRetField)
  LOCAL xVal
  LOCAL nSele
  //outlog(__FILE__,__LINE__,nSk,cDataBase,cTag,cSeek,cRetField,ISCHAR(cRetField),ISBLOCK(cRetField))
  nSele:=SELECT()

  sele cskl
  __dblocate({||sk=nSk})
  pathr:=gcPath_d+ALLTRIM(path)
  netuse(cDataBase,cAlias,,1)
  //xVal:=getfield(cTag,cSeek,cDataBase,cRetField)

  netseek(cTag,cSeek)
  DO CASE
  CASE ISCHAR(cRetField)
    xVal:=(&cRetField)

  CASE ISBLOCK(cRetField)
    xVal:=EVAL(cRetField)

    //outlog(__FILE__,__LINE__,alias(),select(),ttn,tmpmdoc->rn)
    /*
    dopr:=BLANK(date())
    Do While ttn=tmpmdoc->rn
      outlog(rso1->dop)
      if !empty(rso1->dop)
        dopr:=rso1->dop
      else
        //nil
      endif
      DBSkip()
    EndDo
    xVal:=dopr
    */

  ENDCASE

  nuse(cAlias)

  SELECT (nSele)
  RETURN (xVal)



/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  05-08-16 * 02:21:38pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION listGetKpk(cDosParam)
  LOCAL cSetPrnFl, cLogSysCmd, cCmd
  LOCAL nPosCmdBeg, nPosCmdEnd
  PRIVATE ktasr, ktar

     netuse('cskl')
     netuse('etm')
     netuse('stagtm')
     netuse('s_tag')

  cDosParam+=" "
  cKeyCmd:="/cmd="
  nLenCmd:=LEN(cKeyCmd)
  nPosCmdBeg:=AT(UPPER(cKeyCmd),cDosParam)+1
  nPosCmdEnd:=AT(" ",SUBSTR(cDosParam,nPosCmdBeg))
  cCmd:=LEFT(SUBSTR(cDosParam,nPosCmdBeg+nLenCmd-1),nPosCmdEnd-1)

  //outlog(__FILE__,__LINE__,cDosParam)
  //outlog(__FILE__,__LINE__,cCmd,nPosCmdBeg, nPosCmdEnd)

  cSetPrnFl:=SET(_SET_PRINTFILE,"app_glst.exe")

  ??'#!/bin/sh'
  ?'umask 002'
  ?'APP_CLVRT="/usr/local/sbin/app_clvrt"'
  ?

  sele s_tag
  go top
  do while !eof()
    sele s_tag
    if !(s_tag->ent = gnEnt .and. !EMPTY(DeviceId) .and. uvol = 0)
      skip
      loop
    endif

    IF .NOT. (UPPER("/crm_all_skl") $ UPPER(DosParam()))
      IF !cSkl->(check_skl(s_tag->AgSk))
        skip
        LOOP
      ENDIF
    ENDIF

    ktasr:=ktas //супервизор
    ktar:=kod //ТА


    ktar=kod
    if !netseek('t1','ktar','stagtm')
      skip
      loop
    endif
    ?'$APP_CLVRT ';
    + cCmd ;// +'/kpk_get';
    + ' /kta=' +PADL(LTRIM(STR(ktar,3)), 3, "0");
    + ' ;$APP_CLVRT ';
    + '/kpk_lrs';
    + ' ;if [ $? -ne 0 ] ; then  $APP_CLVRT /indxnst ; fi'
    sele s_tag
    skip
  enddo
  If gnEnt=20 .or. gnEnt=21
    ?
    ?'$APP_CLVRT '+'/tzvk' //  проверка Дебиторки с Заданием
  EndIf
  ?
  ?"exit 0"
     nuse('cskl')
     nuse('etm')
     nuse('stagtm')
     nuse('s_tag')

  SET(_SET_PRINTFILE,cSetPrnFl,.t.)

   cLogSysCmd:=""
   SYSCMD("cat ./app_glst.exe| tr -d '\r'>app_glst.sh","",@cLogSysCmd)
   cLogSysCmd:=""
   SYSCMD("chmod +x ./app_glst.sh","",@cLogSysCmd)

  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  02-06-17 * 03:56:16pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION PlSl_TA(ktar)
  LOCAL cktar:=PADL(LTRIM(STR(ktar,3)), 3, "0")
  LOCAL cGuid_plsl
  crtt('tempplsl',;
   'f:nplsl c:c(50) f:nplslta c:c(50) f:fio_ta c:c(50)';
   +' f:kta c:n(4) f:plan c:n(5) f:fakt c:n(5)';
   +' f:gplsl c:c(36) f:gplslta c:c(36)';
    )
  USE tempplsl NEW EXCLUSIVE

  If file(gcPath_ew+"plsl\ttt.dbf")
   append from  (gcPath_ew+"plsl\ttt.dbf") for ktar = kta
  EndIf

  If empty(LastRec())
    //{'План продаж',ktar,'Общий объем',   9000,  1000,  11, , }
    DBAppend()
    //{'План продаж',ktar,'Общий объем',   9000,  1000,  11, , }
    _FIELD->nplsl :=  'План продаж'
    _FIELD->nplslta := 'Общий объем'
    _FIELD->plan := 9000
    _FIELD->fakt := 1000
    _FIELD->kta := ktar
  EndIf
  cGuid_plsl := uuid()
  dbeval({|| _FIELD->gPlsl:=cGuid_plsl, _FIELD->gPlslTa:=uuid() })
  sele tempplsl
  copy to ('k'+cktar+'plsl.dbf')
  use

  RETURN (NIL)

/*
  //формируем пусты ХМЛ для удаления
  use tmpdel Alias dokk new Exclusive
    netuse('cskl')
    netuse('rmsk')
    netuse('kln')
    netuse('knasp')
    netuse('opfh')
    netuse('s_tag')
    netuse('etm')

    netuse('operb')


  SET DATE FORMAT "dd.mm.yyyy"
  SET CENTURY ON

  set console off
  set print on
  set print to ("jornel_shipment.xml")
  qqout('<?xml version="1.0" encoding="'+local_charset()+'"?>')
    qout('<root>')

  kln->(__dbLocate({||!EMPTY(kln->kkl1) .and. len(LTRIM(STR(kln->kkl1)))>=10}))
  n_Kkl:=kln->kkl


  sele dokk
  dokk->(DBGOTOP())
  DO WHILE dokk->(!EOF())
    out_xml_shipment(aKop,dDtStart)
    dokk->(DBSKIP())
  ENDDO

  qout('</root>')
  set print to
  set print off



  set console off
  set print on
  set print to ("jornel_payment.xml")
  qqout('<?xml version="1.0" encoding="'+local_charset()+'"?>')
    qout('<root>')

  sele dokk
  dokk->(DBGOTOP())
  DO WHILE dokk->(!EOF())
    out_xml_payment(0,.T., 1, VAL(DTOS(dokk->ddk))*(-1), NIL,dDtStart)
    dokk->(DBSKIP())
  ENDDO

  qout('</root>')
  set print to
  set print off

  Accord_empty_xml()

    nuse('cskl')
    nuse('rmsk')
    nuse('kln')
    nuse('knasp')
    nuse('opfh')
    nuse('s_tag')


  close dokk

  cNmDir:="xml4del"
  DIRMAKE(cNmDir)

  cLogSysCmd:=""
  #ifdef __CLIP__
  SYSCMD("cp ./jor* ./"+cNmDir+"/","",@cLogSysCmd)
  SYSCMD("cp ./load.sh ./"+cNmDir+"/","",@cLogSysCmd)
  //SYSCMD("cp -s ./load_data1 ./xml"+RIGHT(DTOS(dOtch),6)+"/","",@cLogSysCmd)
  SYSCMD("rm -f ./jor*","",@cLogSysCmd)
  #endif
  AADD(aLineRun,"cd "+cCurDirUnix+"\"+cNmDir+" ; load.sh ; cd ..")
  AADD(aLineRun,"err=`cat "+cCurDirUnix+"\"+cNmDir +"\load_data1.log "+ "|grep error |wc -l`")
  AADD(aLineRun,"err_o=$[$err_o+$err]")
  AADD(aLineRun,"")

  //outlog()

  //return nil
*/

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-21-17 * 00:11:10am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION koz()
  DO CASE
  CASE .T.
    /*
    outlog(__FILE__,__LINE__,timetosec("08:54:16"),sectotime(23843.73),,sectotime(val("23843.73")))
    tt:=time()
    ss:=seconds()
    outlog(__FILE__,__LINE__,tt,sectotime(ss),ss,timetosec(tt))
    quit
    */
    netuse('dokk')
    netuse('moddoc')
    netuse('mdall')

    NoMd() //проводки в ДОКК должны быть в МОДДОК - добавляет
    CrModDoc() //корретировка периода проводки бухгалтерской

    netuse('dokk')
    netuse('moddoc')
    netuse('mdall')


    #ifdef TMPS4
    use tmps4 new
    Do While !eof()
      sele moddoc
      locate for ;
                PADL(LTRIM(STR(moddoc->mn,6)),6,"0")+;
                PADL(LTRIM(STR(moddoc->rnd,6)),6,"0")+;
                PADL(LTRIM(STR(moddoc->sk,3)),3,"0")+;
                PADL(LTRIM(STR(moddoc->rn,6)),6,"0")+;
                PADL(LTRIM(STR(moddoc->mnp,6)),6,"0") = ;
                PADL(LTRIM(STR(tmps4->mn,6)),6,"0")+;
                PADL(LTRIM(STR(tmps4->rnd,6)),6,"0")+;
                PADL(LTRIM(STR(tmps4->sk,3)),3,"0")+;
                PADL(LTRIM(STR(tmps4->rn,6)),6,"0")+;
                PADL(LTRIM(STR(tmps4->mnp,6)),6,"0")
      If found()
        rrec:={}
        tmps4->(getrec("rrec"))
        If reclock()
          putrec("rrec")
          outlog(__LINE__,"repl",;
                  PADL(LTRIM(STR(tmps4->mn,6)),6,"0")+;
                  PADL(LTRIM(STR(tmps4->rnd,6)),6,"0")+;
                  PADL(LTRIM(STR(tmps4->sk,3)),3,"0")+;
                  PADL(LTRIM(STR(tmps4->rn,6)),6,"0")+;
                  PADL(LTRIM(STR(tmps4->mnp,6)),6,"0") ;
        )

        EndIf
      Else
        rrec:=tmps4->(dbread())
        DBAppend(,rrec)
        outlog(__LINE__,"add_",;
                PADL(LTRIM(STR(tmps4->mn,6)),6,"0")+;
                PADL(LTRIM(STR(tmps4->rnd,6)),6,"0")+;
                PADL(LTRIM(STR(tmps4->sk,3)),3,"0")+;
                PADL(LTRIM(STR(tmps4->rn,6)),6,"0")+;
                PADL(LTRIM(STR(tmps4->mnp,6)),6,"0") ;
      )
      EndIf



      sele tmps4
      DBSkip()
    EndDo
    quit
    #endif
    outlog(__FILE__,__LINE__,gdTd)


    iniFile:="acold_DtTm.ini"
    IF FILE(iniFile)

      oIni_DtTm:=iniFileNew(iniFile)
      oIni_DtTm:load()

      //dDtStart:=oIni_DtTm:getValue("accord","date") //,dDtStart)
      //cTmStart:=oIni_DtTm:getValue("accord","time") //,cTmStart)

      IF !EMPTY(oIni_DtTm:error)
        s:=[Error loading ini file:]+toString(iniFile)+":"+oIni_DtTm:error
        ?s
        outlog(s)
        RETURN
      ENDIF

      // cRmSk:="0"
      //dDtStart:=oIni_DtTm:getValue("accord"+cRmSk,"date")
      //outlog(__FILE__,__LINE__,dDtStart,oIni_DtTm:getValue("accord"+cRmSk,"time"))
      /*
      sele moddoc
      DBEVAL(;
        {||;
          ;//netrepl("rm","mddokk('rmsk')"),;
          outlog(__FILE__,__LINE__,moddoc->(mddokk('rmsk')),moddoc->rm,moddoc->mn,moddoc->rnd,moddoc->sk,moddoc->rn,moddoc->mnp);
        },;
        {||;
          (moddoc->(mddokk('rmsk'))) # moddoc->rm;
        };
          )

        quit
      */


      sele moddoc
      DBEVAL(;
      {||;
      n_rmsk:=moddoc->(mddokk('rmsk')),;
      cRmSk:=padl(alltrim(str(n_rmsk)),len(n_rmsk),'0'),;
      ;//outlog(__FILE__,__LINE__,n_rmsk,cRmSk),;
      dDtStart:=oIni_DtTm:getValue("accord"+cRmSk,"date"),;
      ;//outlog(__FILE__,__LINE__,dDtStart,oIni_DtTm:getValue("accord"+cRmSk,"time")),;
      cTmStart:=oIni_DtTm:getValue("accord"+cRmSk,"time")+0.01,;
      IIF(cTmStart>86399,(cTmStart-=86399, dDtStart++),NIL),;
      outlog(__FILE__,__LINE__,"AT(':',TmModVz)#0", dDtStart, cTmStart),;
      outlog(__FILE__,__LINE__,"                 ", DtModVz,TmModVz),;
      netrepl("DtModVz,TmModVz","dDtStart, STR(cTmStart,8,2)"),;
      NIL;
      },;
      {|| AT(":",TmModVz) # 0 })

      close_mddokk()

    ENDIF



    sele dokk
    i:=0
    DBEVAL(;
    {||;
    ;//netrepl("przp,prd","1,BOM(gdTd)"),;
    outlog('error dokk-> not moddok',dokk->mn,dokk->rnd,dokk->sk,dokk->rn,dokk->mnp,++i);
    },;
    {|| (dokk->bs_d=361001 .or. dokk->bs_k=361001) .and. ;
     BOM(gdTd)=BOM(moddoc->prd) .and. przp=1 .and. ;
    .not. moddoc->(netseek("t1","dokk->mn,dokk->rnd,dokk->sk,dokk->rn,dokk->mnp"));
     })

    /*
    i:=0
    sele moddoc
    DBEVAL(;
    {||;
    ;//netrepl("przp,prd","1,BOM(gdTd)"),;
    outlog('moddok=уд, dokk->found',sk,rn,dokk->ddk,++i);
    },;
    {||;
    dokk->(netseek("t12","moddoc->mn,moddoc->rnd,moddoc->sk,moddoc->rn,moddoc->mnp")) .and.;
    (alltrim(moddoc->fld)="уд");
     })
     */
    i:=0
    sele moddoc
    DBEVAL(;
    {||;
    netrepl("przp","0"),;
    outlog('moddok przp=1 -> not dokk',przp,sk,rn,dokk->ddk,++i);
    },;
    {||;
     BOM(gdTd)=BOM(prd) .and. przp=1 .and. ;
     (moddoc->mn=0 .and. moddoc->rnd=0 .and. moddoc->mnp=0) .and. ;//складские расход
    !(dokk->(netseek("t12","moddoc->mn,moddoc->rnd,moddoc->sk,moddoc->rn,moddoc->mnp")));
     })



    i:=0
    sele moddoc
    DBEVAL(;
    {||;
    netrepl("przp,prd","1,BOM(gdTd)"),;
    outlog(__FILE__,__LINE__,'przp=0 moddok->dokk',przp,sk,rn,dokk->ddk,++i),;
    n_rmsk:=moddoc->(mddokk('rmsk')),;
    cRmSk:=padl(alltrim(str(n_rmsk)),len(n_rmsk),'0'),;
    ;//outlog(__FILE__,__LINE__,n_rmsk,cRmSk),;
    dDtStart:=oIni_DtTm:getValue("accord"+cRmSk,"date"),;
    ;//outlog(__FILE__,__LINE__,dDtStart,oIni_DtTm:getValue("accord"+cRmSk,"time")),;
    nTmStart:=oIni_DtTm:getValue("accord"+cRmSk,"time")+0.01,;
    IIF(nTmStart>86399,(nTmStart-=86399, dDtStart++),NIL),;
    outlog(__FILE__,__LINE__,"  new", dDtStart, nTmStart),;
    outlog(__FILE__,__LINE__,"  old", DtModVz,TmModVz),;
    netrepl("DtModVz,TmModVz","dDtStart, STR(nTmStart,8,2)"),;
    NIL;
    },;
    {||;
    dokk->(netseek("t12","moddoc->mn,moddoc->rnd,moddoc->sk,moddoc->rn,moddoc->mnp")) .and.;
    (przp=0);
     })

    i:=0
    sele moddoc
    DBEVAL(;
    {||;
    netrepl("przp,prd","1,BOM(gdTd)"),;
    outlog(__FILE__,__LINE__,'#BOM(prd) moddok->dokk',przp,sk,rn,dokk->ddk,++i);
    },;
    {||;
    dokk->(netseek("t12","moddoc->mn,moddoc->rnd,moddoc->sk,moddoc->rn,moddoc->mnp")) .and.;
    (BOM(gdTd)#BOM(prd));
     })


    sele moddoc
    DBEVAL(;
    {||;
    cSec:=STR(TimeToSec(TmMod),8,2),;
    outlog(__FILE__,__LINE__,"przp=1 .and. empty(DtModVz)",;
    DtMod,TmMod,DtModVz,cSec),;
    netrepl("DtModVz,TmModVz","DtMod,cSec");
    },;
    {|| przp=1 .and. empty(DtModVz) })





    nuse('moddoc')
    nuse('mdall')
    nuse('dokk')


  CASE .F.
    //mkkplkgp(19,nil)
    //mkkplkgp(58,1)
    netuse('kln')
    netuse('etm')
    netuse('stagtm')
    netuse('kpl')
    netuse('kgp')

    //чистим плательщиков предприятия
    sele kpl
    DBGoTop()
    DO WHILE !EOF()
      kplr:=kpl
      opfhr=getfield('t1','kplr','kln','opfh')
      IF opfhr=0
        netdel()
      ENDIF
      DBSKIP()
    ENDDO

    //чистим грузополучетели предприятия
    sele kgp
    DBGoTop()
    DO WHILE !EOF()
      kgpr:=kgp
      opfhr=getfield('t1','kgpr','kln','opfh')
      IF opfhr>0
      ENDIF
      DBSKIP()
    ENDDO

    //удаляем не правильно формированные ТТ
    sele etm
    DBGoTop()
    DO WHILE !EOF()
      kgpr:=kgp
      kplr:=kpl

      sele kgp
      LOCATE FOR kgpr = kgp
      IF !FOUND() .OR. DELETE()
        sele etm
        netdel()
      ELSE
        sele kpl
        LOCATE FOR kplr = kpl
        IF !FOUND() .OR. DELETE()
          sele etm
          netdel()
        ELSE
          IF kplr = kgpr
            sele etm
            netdel()
          ENDIF
        ENDIF

      ENDIF

      sele etm
      DBSKIP()
    ENDDO

    sele stagtm
    DBGoTop()
    DO WHILE !EOF()
      tmestor:=tmesto

      sele etm
      LOCATE FOR tmestor = tmesto
      IF !FOUND() .OR. DELETE()
        sele stagtm
        netdel()
      ENDIF

      sele stagtm
      DBSKIP()
    ENDDO


    nuse('kln')
    nuse('etm')
    nuse('stagtm')
    nuse('kpl')
    nuse('kgp')

    /*
    FOR i:=BOM(gdTd) TO EOM(gdTd)
      mkotch(i,1,.F.)
    NEXT
    */
  ENDCASE
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-21-17 * 00:13:33am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION  rd_631()
  nCPU:=1
  n_Kta:=NIL

  set date format "yyyymmdd"

  netuse('etm')
  netuse('stagtm')

   netuse('s_tag')
   netuse('nap')
   netuse('ktanap')
   netuse('kln')
   netuse('kpl')
   netuse('krn')
   netuse('knasp')
   netuse('kgp')
   netuse('kgpnet')



  if !(UPPER("/copy_deb") $ cDosParam)

    USE (gcPath_ew+"deb\skdoc") ALIAS skdoc NEW SHARED
    copy stru exten to tmp0
    copy stru exten to tmp1
    close
    use tmp0  new excl
    zap
    appe blank
    repl field_name with 'ddk',;
         field_type with 'd',;
         field_len with 8,;
         field_dec with 0
    appe blank
    repl field_name with 'bs_s',;
         field_type with 'n',;
         field_len with 10,;
         field_dec with 2
    appe blank
    repl field_name with 'bs_tp',;
         field_type with 'c',;
         field_len with 4,;
         field_dec with 0
    appe blank
    repl field_name with 'nplp',;
         field_type with 'n',;
         field_len with 6,;
         field_dec with 0
    appe blank
    repl field_name with 'splp',;
         field_type with 'n',;
         field_len with 10,;
         field_dec with 2
    appe blank
    repl field_name with 'DtOpl_tp',;
         field_type with 'c',;
         field_len with 2,;
         field_dec with 0
    appe blank
    repl field_name with 'DtOpl_ttn',;
         field_type with 'd',;
         field_len with 8,;
         field_dec with 0
    appe blank
    repl field_name with 'DtOpl_raz',;
         field_type with 'n',;
         field_len with 4,;
         field_dec with 0

    append from tmp1
    close
    create tmpskdoc from tmp0
    close
    create tmprdand from tmp0
    close


    IF UPPER("/dtBeg") $ cDosParam
      dtEndr:=dtBegr:=date()
      Dt_Beg_End(cDosParam,.T.,@dtBegr,@dtEndr)
    ELSE
      dtBegr:=dtEndr:=date()
    ENDIF

    IF UPPER("/kta=") $ cDosParam

      n_Kta:=VAL(SUBSTR(cDosParam,AT("/KTA=",cDosParam)+LEN("/KTA="),3))

      Ktar:=n_Kta
      sele stagtm
      if !netseek('t1','ktar','stagtm')
        quit
      endif

      ktasr:=getfield('t1','ktar','s_tag','ktas')
      ktanap->(netseek('t1','ktasr')) //ktanap->nap
      napr:=ktanap->nap

      aTMesto:={}
      sele stagtm
      do while kta=ktar
        tmestor:=tmesto
        sele etm
        IF netseek('t1','tmestor')
          aadd(aTMesto,{ kgp, kpl })
        ENDIF
        sele stagtm
        skip
      enddo

    ENDIF

    use tmpskdoc alias skdoc new exclu

    //use k354firm alias firm new
    //bKpl:={||firm->kpl}

    netuse("dkkln","firm")
    bKpl:={||firm->kkl}
    i:=0

    if !(UPPER("/nowget") $ cDosParam)

      //hdr:=fcreate('rd_anb.wget')
      hdr:=ARRAY(nCPU)
      for i:=1 to nCPU
        hdr[i]:=fcreate('rd_rpt6-3'+padl(ltrim(str(i,2,0)),2,"0")+'.wget')
      next i

      filedelete('rd_rpt6-3?c*')

      cHost:="localhost"
      nPort:=10000


      i:=nCPU
      firm->(DBGoTop())

      Do While !firm->(eof())

        i++; i:=Iif(i>nCPU,1,i)

        nKpl:=EVAL(bKpl)

        If n_Kta != NIL
          If ascan(aTMesto,{|x| x[2] = nKpl }) = 0
            firm->(DBSkip())
            loop
          EndIf
        EndIf


        do while .T.
          If !(str(nkpl) $ "  20034 ") //.or. nkpl < 20594)
            #ifdef __CLIP__
            cWGet:=;
              'http://'+cHost+'/cgi-bin/aquarum/rd_rpt6-3?customers='+;
              ltrim(str(nKpl))+;
              Iif(EMPTY(dtBegr),'',';beg_date='+DTOC(dtBegr,"dd.mm.yyyy"))+;
              Iif(EMPTY(dtEndr),'',';end_date='+DTOC(dtEndr,"dd.mm.yyyy"))+;
              ';an_value=2'+;
              LF
           fwrite(hdr[i],cWGet)
           #endif
            exit
          else
            exit //20034 off
            for mDt:=dtBegr to dtEndr
                #ifdef __CLIP__
                cWGet:=;
                  'http://'+cHost+'/cgi-bin/aquarum/rd_rpt6-3?customers='+;
                  ltrim(str(nKpl))+;
                  Iif(EMPTY(dtBegr),'',';beg_date='+DTOC(mDt,"dd.mm.yyyy"))+;
                  Iif(EMPTY(dtEndr),'',';end_date='+DTOC(mDt,"dd.mm.yyyy"))+;
                  ';an_value=2'+;
                  LF
               fwrite(hdr[i],cWGet)
               #endif
            next
            exit
          EndIf
        EndDo

          sele firm
          Do While nKpl = EVAL(bKpl)
            firm->(DBSkip())
          EndDo
        //Enddo

        If --nPort = 0
          exit
        EndIf

      EndDo

      for i:=1 to nCPU
        fclose(hdr[i])
      next i


      cLogSysCmd:=""
      cSysCmd:=""

      for i:=1 to nCPU
        cSysCmd+="wget "+;
        "--tries=3 --timeout=900 "+;
        "-i rd_rpt6-3"+padl(ltrim(str(i,2,0)),2,"0")+".wget "+;
        "-o rn_rpt6-3"+padl(ltrim(str(i,2,0)),2,"0")+".wget.log "+;
        "& "
      next i
      cSysCmd+="wait"

      #ifdef __CLIP__
        //SYSCMD("wget -i rd_anb.wget -o rn_anb.wget.log","",@cLogSysCmd)
        //outlog(__LINE__,cSysCmd)
        SYSCMD(cSysCmd,"",@cLogSysCmd)
        //outlog(__LINE__,cLogSysCmd)
      #endif

    endif

    dtBeg_r:=dtBegr
    dtEnd_r:=dtEndr


    firm->(DBGoTop())
    Do While .T. .AND. !firm->(eof())

      nKpl:=EVAL(bKpl)

      If n_Kta != NIL
        If ascan(aTMesto,{|x| x[2] = nKpl }) = 0
          firm->(DBSkip())
          loop
        EndIf
      EndIf


      #ifdef __CLIP__
      do while .t.
        If !(str(nkpl) $ "  20034 ")
          hdr:=fopen(;
          'rd_rpt6-3?customers='+ltrim(str(nKpl))+;
              Iif(EMPTY(dtBegr),'',';beg_date='+DTOC(dtBegr,"dd.mm.yyyy"))+;
              Iif(EMPTY(dtEndr),'',';end_date='+DTOC(dtEndr,"dd.mm.yyyy"))+;
              ';an_value=2'+;
              "";
        )
          If hdr < 0
            outlog(__FILE__,__LINE__,"нет файла ",;
            'rd_rpt6-3?customers='+ltrim(str(nKpl))+;
              Iif(EMPTY(dtBegr),'',';beg_date='+DTOC(dtBegr,"dd.mm.yyyy"))+;
              Iif(EMPTY(dtEndr),'',';end_date='+DTOC(dtEndr,"dd.mm.yyyy"))+;
              ';an_value=2'+;
              "";
          )
            //Do While nKpl = EVAL(bKpl)
              //firm->(DBSkip())
            //EndDo
            exit
          endif
        else
          exit  //20034 off
          for mDt:=dtBeg_r to dtEnd_r
            hdr:=fopen(;
            'rd_rpt6-3?customers='+ltrim(str(nKpl))+;
                Iif(EMPTY(dtBegr),'',';beg_date='+DTOC(mdt,"dd.mm.yyyy"))+;
                Iif(EMPTY(dtEndr),'',';end_date='+DTOC(mdt,"dd.mm.yyyy"))+;
                ';an_value=2'+;
                "";
          )
            If hdr < 0
              outlog(__FILE__,__LINE__,"нет файла ",;
              'rd_rpt6-3?customers='+ltrim(str(nKpl))+;
                Iif(EMPTY(dtBegr),'',';beg_date='+DTOC(mdt,"dd.mm.yyyy"))+;
                Iif(EMPTY(dtEndr),'',';end_date='+DTOC(mdt,"dd.mm.yyyy"))+;
                ';an_value=2'+;
                "";
            )
              loop
            endif
          next
        EndIf


          lBody:=.F.
          aLine:={}

          do while !feof(hdr)
            cLine:=FReadLn(hdr, 1,600, LF)

            IF !lBody
              DO CASE
              CASE 'Err'$ cLine .OR. "Content-type"$ cLine .or. 'err'$ cLine
                exit
              CASE '<body>' $ cLine
                lBody:=.T.
              ENDCASE
            ELSE
              IF CHR(26) $ cLine
                exit
              ELSE
                If !("Content-type"$ cLine .or. 'err'$ cLine)
                  AADD(aLine, cLine)
                else
                  //outlog(__LINE__,"Content-type"$ cLine, 'err'$ cLine)
                  exit
                EndIf
              ENDIF
            ENDIF
          enddo
          fclose(hdr)

          IF !EMPTY(aLine)
            For i:=1 To len(aLine)
              aLn:=split(aLine[i],chr(9)) //',')

              Use tmprdand alias rd_and Exclusive new
              zap
              DBAppend()

              for l:=1 to fcount()
                Do Case
                Case valtype(FieldGet(l))="C"
                  aLn[l]:=aLn[l]
                Case valtype(FieldGet(l))="N"
                  aLn[l]:=val(ltrim(aLn[l]))
                Case valtype(FieldGet(l))="D"
                  aLn[l]:=stod(aLn[l])
                Case valtype(FieldGet(l))="L"
                  aLn[l]:=(aLn[l]="T")
                EndCase
                FieldPut(l,aLn[l])
              next

              If n_Kta != NIL
                // грузополучатель должен быть у ТА
                If ascan(aTMesto,{|x| x[1] = Kgp }) = 0
                  zap
                else
                  //проверим Торг Напр с какой выписна НКЛ
                  If ktas < 10
                    If napr != ktas
                      zap
                    EndIf
                  else

                    ktanap->(netseek('t1','rd_and->ktas')) //ktanap->nap
                    If napr != ktanap->nap
                      zap
                    EndIf

                    If rd_and->ktas != ktasr
                      zap
                    EndIf



                  EndIf

                EndIf
              EndIf

              close rd_and
              sele skdoc
              Append from tmprdand for sdp # 0

             Next

          ENDIF
        If !(str(nkpl) $ "  20034 ")
          exit
        else
          exit  //20034 off
          dtBeg_r++
          if dtBeg_r > dtEnd_r
            exit
          endif
        endif
      enddo
      #endif
      sele firm
      Do While nKpl = EVAL(bKpl)
        firm->(DBSkip())
      EndDo

    EndDo
  else
    use tmpskdoc alias skdoc new exclu
  endif

  //close rd_and
  acc361(dtBegr,dtEndr,"tmprdand",.F.)
  sele skdoc
  Append from tmprdand

  sele skdoc
  UpDateSkDoc()

  index on str(kpl)+dtos(DtOpl) to tempskdo

  If n_Kta != NIL
     copy to ("accord_deb"+padl(ltrim(str(Ktar)),3,"0")+".dbf")
    If file(("accord_deb"+padl(ltrim(str(Ktar)),3,"0")+".cdx"))
      Erase ("accord_deb"+padl(ltrim(str(Ktar)),3,"0")+".cdx")
    EndIf
     use ("accord_deb"+padl(ltrim(str(Ktar)),3,"0")) new
     index on str(kpl,7)+dtos(DtOpl) tag t1
  else

    If file("accord_deb.dbf")
      nSec:=SECONDS()
      Do While nSec+600 > SECONDS()
        use accord_deb.dbf new Exclusive

        if .not. neterr()
          set index to
          If file("accord_deb.cdx")
            Erase ("accord_deb.cdx")
          EndIf
          zap
          close accord_deb
          sele skdoc
          copy to accord_deb.dbf
          exit
        endif

        outlog(__FILE__,__LINE__,"inkey(30)",'neterr("accord_deb.dbf")=0')
        #ifdef __CLIP__
          sleep(30)
        #else
          inkey(30)
        #endif

      EndDo
    else
      copy to accord_deb.dbf
    EndIf

    use ("accord_deb") new
    index on str(kpl,7)+str(ktan) tag t1
    index on str(kgp,7)+str(ktan) tag t2
    index on str(kpl,7)+str(kgp,7) tag t3

  endif
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-21-17 * 00:15:42am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION  rd_anb()
  /********************************
  *   /nowget - без выборки с сервера
  *   /copy_deb - копирование, когда занята база
  *   /kta
  *   /dtBeg
  */
  nCPU:=1
  n_Kta:=NIL
  PathDebr=gcPath_ew+'deb\'

  set date format "yyyymmdd"

  netuse('etm')
  netuse('stagtm')

   netuse('s_tag')
   netuse('nap')
   netuse('ktanap')
   netuse('kln')
   netuse('kpl')
   netuse('krn')
   netuse('knasp')
   netuse('kgp')
   netuse('kgpnet')

  if !(UPPER("/copy_deb") $ cDosParam)
    USE (gcPath_ew+"deb\skdoc") ALIAS skdoc NEW SHARED

    //SET ORDER TO TAG t1
    //copy to t1  delimited with chr(9) next 5
    copy stru to tmpskdoc
    copy stru to tmprdand
    close

    IF UPPER("/dtBeg") $ cDosParam
      dtEndr:=dtBegr:=date()
      Dt_Beg_End(cDosParam,.T.,@dtBegr,@dtEndr)
      dtEndr:=dtBegr
    ELSE
      dtBegr:=dtEndr:=NIL
    ENDIF

    IF UPPER("/kta=") $ cDosParam

      n_Kta:=VAL(SUBSTR(cDosParam,AT("/KTA=",cDosParam)+LEN("/KTA="),3))

      Ktar:=n_Kta
      sele stagtm
      if !netseek('t1','ktar','stagtm')
        quit
      endif

      ktasr:=getfield('t1','ktar','s_tag','ktas')
      ktanap->(netseek('t1','ktasr')) //ktanap->nap
      napr:=ktanap->nap

      aTMesto:={}
      sele stagtm
      do while kta=ktar
        tmestor:=tmesto
        sele etm
        IF netseek('t1','tmestor')
          aadd(aTMesto,{ kgp, kpl })
        ENDIF
        sele stagtm
        skip
      enddo

    ENDIF

    use tmpskdoc alias skdoc new exclu

    //use k354firm alias firm new
    //bKpl:={||firm->kpl}

    netuse("dkkln","firm")
    bKpl:={||firm->kkl}
    i:=0

    if !(UPPER("/nowget") $ cDosParam)

      //hdr:=fcreate('rd_anb.wget')
      hdr:=ARRAY(nCPU)
      for i:=1 to nCPU
        hdr[i]:=fcreate('rd_anb'+padl(ltrim(str(i,2,0)),2,"0")+'.wget')
      next i

      filedelete('rd_anb?c*')

      cHost:="localhost"
      nPort:=10000

      i:=nCPU
      firm->(DBGoTop())
      Do While !firm->(eof())

        i++; i:=Iif(i>nCPU,1,i)

        nKpl:=EVAL(bKpl)

        If n_Kta != NIL
          If ascan(aTMesto,{|x| x[2] = nKpl }) = 0
            firm->(DBSkip())
            loop
          EndIf
        EndIf


        If !(str(nkpl) $ "  20034 ") //.or. nkpl < 20594)
          #ifdef __CLIP__
          cWGet:=;
            'http://'+cHost+'/cgi-bin/aquarum/rd_anb?customers='+;
            ltrim(str(nKpl))+;
            Iif(EMPTY(dtBegr),'',';date='+DTOC(dtBegr,"dd.mm.yyyy"))+;
            LF
         fwrite(hdr[i],cWGet)
         #endif
        EndIf


        sele firm
        Do While nKpl = EVAL(bKpl)
          firm->(DBSkip())
        EndDo

        If --nPort = 0
          exit
        EndIf

      EndDo

      for i:=1 to nCPU
        fclose(hdr[i])
      next i

      cLogSysCmd:=""
      cSysCmd:=""

      for i:=1 to nCPU
        cSysCmd+="wget "+;
        "--tries=3 --timeout=900 "+;
        "-i rd_anb"+padl(ltrim(str(i,2,0)),2,"0")+".wget "+;
        "-o rn_anb"+padl(ltrim(str(i,2,0)),2,"0")+".wget.log "+;
        "& "
      next i
      cSysCmd+="wait"

      #ifdef __CLIP__
        //SYSCMD("wget -i rd_anb.wget -o rn_anb.wget.log","",@cLogSysCmd)
        //outlog(__LINE__,cSysCmd)
        SYSCMD(cSysCmd,"",@cLogSysCmd)
        //outlog(__LINE__,cLogSysCmd)
      #endif

    endif

    firm->(DBGoTop())
    Do While .T. .AND. !firm->(eof())

      nKpl:=EVAL(bKpl)

      If n_Kta != NIL
        If ascan(aTMesto,{|x| x[2] = nKpl }) = 0
          firm->(DBSkip())
          loop
        EndIf
      EndIf



      If !(str(nkpl) $ "  20034 ")
        #ifdef __CLIP__
        hdr:=fopen(;
        'rd_anb?customers='+ltrim(str(nKpl))+;
            Iif(EMPTY(dtBegr),'',';date='+DTOC(dtBegr,"dd.mm.yyyy"))+;
            "";
      )
        If hdr < 0
          outlog(__FILE__,__LINE__,"нет файла ",;
          'rd_anb?customers='+ltrim(str(nKpl))+;
            Iif(EMPTY(dtBegr),'',';date='+DTOC(dtBegr,"dd.mm.yyyy"))+;
            "";
        )
          Do While nKpl = EVAL(bKpl)
            firm->(DBSkip())
          EndDo
          loop
        EndIf

        lBody:=.F.
        aLine:={}

        do while !feof(hdr)
          cLine:=FReadLn(hdr, 1,600, LF)

          IF !lBody
            DO CASE
            CASE 'Err'$ cLine .OR. "Content-type"$ cLine .or. 'err'$ cLine
              exit
            CASE '<body>' $ cLine
              lBody:=.T.
            ENDCASE
          ELSE
            IF CHR(26) $ cLine
              exit
            ELSE
              If !("Content-type"$ cLine .or. 'err'$ cLine)
                AADD(aLine, cLine)
              else
                //outlog(__LINE__,"Content-type"$ cLine, 'err'$ cLine)
                exit
              EndIf
            ENDIF
          ENDIF
        endd
        fclose(hdr)

        IF !EMPTY(aLine)
          For i:=1 To len(aLine)
            aLn:=split(aLine[i],chr(9)) //',')

            Use tmprdand alias rd_and Exclusive new
            zap
            DBAppend()
            nEnd:=fcount()
            nEnd:=IIF(nEnd>LEN(aLn),LEN(aLn),nEnd)

            for l:=1 to nEnd
              Do Case
              Case valtype(FieldGet(l))="C"
                aLn[l]:=aLn[l]
              Case valtype(FieldGet(l))="N"
                aLn[l]:=val(ltrim(aLn[l]))
              Case valtype(FieldGet(l))="D"
                aLn[l]:=stod(aLn[l])
              Case valtype(FieldGet(l))="L"
                aLn[l]:=(aLn[l]="T")
              EndCase
              FieldPut(l,aLn[l])
            next

            If n_Kta != NIL
              // грузополучатель должен быть у ТА
              If ascan(aTMesto,{|x| x[1] = Kgp }) = 0
                zap
              else
                //проверим Торг Напр с какой выписна НКЛ
                If ktas < 10
                  If napr != ktas
                    zap
                  EndIf
                else

                  ktanap->(netseek('t1','rd_and->ktas')) //ktanap->nap
                  If napr != ktanap->nap
                    zap
                  EndIf

                  If rd_and->ktas != ktasr
                    zap
                  EndIf



                EndIf

              EndIf
            EndIf

            close rd_and
            sele skdoc
            Append from tmprdand

           Next

        ENDIF
      #endif
      EndIf

      sele firm
      Do While nKpl = EVAL(bKpl)
        firm->(DBSkip())
      EndDo

    EndDo
  else
    use tmpskdoc alias skdoc new exclu
  endif

  sele skdoc
  UpDateSkDoc()
  append from (PathDebr+'SkDoc126.dbf')

  index on str(kpl)+dtos(DtOpl) to tempskdo

  If n_Kta != NIL
     copy to ("accord_deb"+padl(ltrim(str(Ktar)),3,"0")+".dbf")
    If file(("accord_deb"+padl(ltrim(str(Ktar)),3,"0")+".cdx"))
      Erase ("accord_deb"+padl(ltrim(str(Ktar)),3,"0")+".cdx")
    EndIf
     use ("accord_deb"+padl(ltrim(str(Ktar)),3,"0")) new
     index on str(kpl,7)+dtos(DtOpl) tag t1
  else

    If file("accord_deb.dbf")
      nSec:=SECONDS()
      Do While nSec+600 > SECONDS()
        use accord_deb.dbf new Exclusive

        if .not. neterr()
          set index to
          If file("accord_deb.cdx")
            Erase ("accord_deb.cdx")
          EndIf
          zap
          close accord_deb
          sele skdoc
          copy to accord_deb.dbf for sdp#0
          exit
        endif

        outlog(__FILE__,__LINE__,"inkey(30)",'neterr("accord_deb.dbf")=0')
        #ifdef __CLIP__
          sleep(30)
        #else
          inkey(30)
        #endif

      EndDo
    else
      copy to accord_deb.dbf for sdp#0
    EndIf

    use ("accord_deb") new
    index on str(kpl,7)+str(ktan) tag t1
    index on str(kgp,7)+str(ktan) tag t2
    index on str(kpl,7)+str(kgp,7) tag t3


  endif

  /*

  //код торгового места
  sele skdoc
  DBGoTop()
  Do While !oef()

    ktar:=kta
    ktasr:=ktas
    kgpr:=kgp
    kplr:=kpl

    tmestor:=getfield("t2","kplr,kgpr","etm","tmesto")

    sele stagtm
    set order to tag t2
    If  netseek("t2","tmestor")
      Do While tmestor = tmesto

        ktas_r:=getfield('t1','stagtm->kta','s_tag','ktas')

        if ktas_r = ktasr
           repl ktan with stagtm->kta
           ktasr:=getfield('t1','ktar','s_tag','ktas')
           repl nktan with s_tag->nkta
           exit
        endif

        DBSkip()
      EndDo
    else
    EndIf
    DBSkip()
  EndDo


  sele skdoc
  repl all ktan  with
  etm->(netseek)
  kgp, kpl

  */


  /*
  firm->(DBGoTop())
  Do While !firm->(eof())

    lAdd:=.T.
    If Empty(Select('rd_and'))
      Use tmprdand alias rd_and Exclusive new
    EndIf
    zap

    nKpl:=EVAL(bKpl)

    If !(str(nkpl) $ "  20034 ")

      cLogSysCmd:=""
      #ifdef __CLIP__
        outlog(__FILE__,__LINE__,'"super rd_anb "+str(nKpl)',nKpl,++i)
        //SYSCMD("super rd_anb "+str(nKpl),"",@cLogSysCmd)
        //Cgi_Bin_get('GET //cgi-bin/aquarum/rd_anb?customers='+ltrim(str(nKpl))+' HTTP/1.1')

        cHost:="localhost"
        nPort:=80

        Cgi_Bin_get(cHost, nPort,;
        'GET /cgi-bin/aquarum/rd_anb?customers='+;
        ltrim(str(nKpl))+; //'2313325'+;
        ' HTTP/1.0'+CR+LF+;
        "HOST: "+cHost+CR+LF+;
        CR+LF;
       )
      #endif

      sele rd_and
      append from rd_anb_c.txt delimited // with blank //chr(9)
      DBGoTop()
      Do Case
      Case kpl=0
        outlog(__FILE__,__LINE__,'kpl=0',nKpl)
        lAdd:=.F.
      //Case
      EndCase
      close rd_and

      If lAdd
        sele skdoc
        append from tmprdand
      EndIf

    EndIf

    Do While nKpl = EVAL(bKpl)
      firm->(DBSkip())
    EndDo

  EndDo
  */
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  07-05-17 * 12:24:14pm
 НАЗНАЧЕНИЕ......... обновление реквизитов
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION UpDateSkDoc(cSkDoc, dCurDt)
  DEFAULT cSkDoc TO 'skdoc', dCurDt TO Date()
  repl all ;
   ktan with  agtm((cSkDoc)->ktas, (cSkDoc)->kpl, (cSkDoc)->kgp);
  ,nKtaN with  getfield('t1',cSkDoc+'->ktan','s_tag','fio');
  ,nKtaS with  iif(Empty(nKtaS),getfield('t1',cSkDoc+'->ktas','s_tag','fio'),nKtaS);
  ,nap with iif(Empty(nap),getfield('t1', cSkDoc+'->ktas','KtaNap','nap'),nap);
  ,nNap with getfield('t1', cSkDoc+'->nap', 'nap', 'nnap');
  ,DtOpl with  IIF(EMPTY(DtOpl),DOP,DtOpl);
  ,dpd with DtOpl - dCurDt;
  ,NN with iif(empty(dpd),iif((DtOpl - dCurDt)>100,99,(DtOpl - dCurDt)),NN) ;
  ,npl with iif(.F.,npl,getfield('t1',cSkDoc+'->kpl','kln','nkl')); // .F. - all обновлять
  ,nkkl with  getfield('t1',cSkDoc+'->kpl','kpl','tzdoc');
  ,ngp with iif(!empty((cSkDoc)->kgp),getfield('t1',cSkDoc+'->kgp','kgp','NGrpol'),ngp);
  ,nnet with (knetr:=getfield('t1',cSkDoc+'->kgp','kgp','knet'),;
               getfield('t1','knetr','kgpnet','nnet')) ;
  ,agp with   (kln->(netseek('t1',cSkDoc+'->kgp')),;
          alltrim(kln->adr)+' '+;//Физическое местонахождение
          alltrim(getfield("t1","kln->knasp","knasp","nnasp"))+" "+; //Город
          alltrim(getfield("t1","kln->krn","krn","nrn"));       //Район
      )

  RETURN (NIL)

