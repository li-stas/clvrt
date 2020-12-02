/***********************************************************
 * Модуль    : slavut.prg
 * Версия    : 0.0
 * Автор     :
 * Дата      : 02/25/20
 * Изменен   :
 * Примечание: Текст обработан утилитой CF версии 2.02
 */

#include "common.ch"
#define EMAIL_CRMEXC_042
#define LF CHR(10)
#define CR CHR(13)
//#define DEB_SKDOC

function slavu(cMkeep, dDt, aFiles, cNameFileTest)
  local cLogSysCmd, cRunZip
  local oSmtp, lError, lOk, lZip
  local cSmtpTo, cSmtpServ
  local cFileNameArc, cFileList
  local cCOX_Sl_list
  local Pr_Butr, zenr

  DEFAULT aFiles to {                                           ;
                      "tareost.xml",                             ;
                      "taremoex.xml",                            ;
                      "ons.xml",                                 ;
                      "ware.xml", "ktt.xml",                     ;
                      "opk.xml", "ord_stat.xml", "bad_addr.xml", ;
                      "saldo.xml"                                ;
                   }

  SET DATE FORMAT "yyyy-mm-dd"
  SET CENTURY on

  cRunZip:="/usr/bin/zip"
  cFileNameArc:="sl"+DTOS(dDt)+".zip"

  //cSmtpFrom:="spresurs_adm@ukrpost.ua" //"pro@agrarnik.sumy.ua"//"spresurs_adm@ukrpost.ua" //"pro@agrarnik.sumy.ua"
  //cSmtpFrom:="CrmExc_042@bbhua.com"
  //cSmtpFrom:="spresurs_adm@ukrpost.ua"

#ifdef EMAIL_CRMEXC_042
    cSmtpServ:="mailx.slavutich.com"
    cSmtpFrom:="CrmExc_042@bbhua.com"// for mailx.slavutich.com
#else
    cSmtpServ:="kbmxas.bbhua.com"
    cSmtpFrom:="pro@agrarnik.sumy.ua"// for kbmxas.bbhua.com
#endif

  if (UPPER("/support") $ UPPER(DosParam()))
    //cSmtpTo:="support.sales@BBHUA.com"
    cSmtpFrom:="spresurs_real@ukrpost.ua"// for mailx.slavutich.com
    cSmtpServ:="10.0.1.113"              //"mail.ukrpost.ua" //"10.1.1.101"
                                         //cSmtpServ:="relay.ukrpost.ua"
    cSmtpTo:="lista@bk.ru"
  else
    cSmtpTo:="DataExchange.XML@BBHUA.com"
  //cSmtpTo:="CrmExc_042@bbhua.com"
  endif

  if (!(UPPER("/repite-zip") $ UPPER(DosParam()))                                                  ;
       .OR. (UPPER("/repite-zip") $ UPPER(DosParam()) .AND. UPPER("/test") $ UPPER(DosParam())) ;
    )

    if (ISCHAR(aFiles))
      aFiles:={aFiles}
    endif

    AADD(aFiles, cNameFileTest)

    cFileList:=""
    AEVAL(aFiles, {| cElem |cFileList+=cElem+" "})
    cFileList:=ALLTRIM(cFileList)

    cCOX_Sl_list:=       ;
     "240 302 402 502 "+   ;//СОХ
     "229 230"              //тара поставщиков, тара покупателей

    /*"saha@agrarnik.sumy.ua" */
    /*"saha@agrarnik.sumy.ua" */
                            //"lista@bk.ru"

    netuse('klndog')

#ifdef DEB_SKDOC
      use (gcPath_ew+"deb\skdoc") ALIAS skdoc NEW SHARED
#else
      use (gcPath_ew+"deb\accord_deb") ALIAS skdoc NEW SHARED READONLY

      //подготовка агрегатированного сальдо клиент и грузопол
      SET ORDER to TAG t3
      TOTAL on str(kpl, 7)+str(kgp, 7) field sdp to AccDebAgg ;
       for nap = 2 .OR. nap = 556

      SELE skdoc
      SET ORDER to TAG t1

      use AccDebAgg NEW EXCLUSIVE
      REPL kgp WITH 20034 for EMPTY(kgp)
      REPL kpl WITH 20034 for EMPTY(kpl)

#endif
    use (gcPath_ew+"deb\deb") ALIAS deb NEW SHARED
    SET ORDER to TAG t1

    //////// ОСТАТКИ ПО ТОВАРМ ////////
    use ("mktov"+cMkeep+".dbf") ALIAS mktov019 NEW EXCLUSIVE
    if (FILE("mktov"+cMkeep+".cdx"))
      ERASE ("mktov"+cMkeep+".cdx")
    endif

    INDEX on STR(SK)+STR(MnTovT) TAG "sk"
    SET INDEX to
    INDEX on STR(MnTovT) TAG "MnTov" UNIQUE
    //SET INDEX TO

    ORDSETFOCUS("sk")
    //работаем ночью полсе 24-00 уменьшаем дату на один
    //dDt:=mktov019->DT
    //dDt-=1

    REPL ALL mktov019->DT WITH dDt
    //////////////////////////////////////

    ////////// ДОКУМЕНТЫ //////////////////
    use ("mkdoc"+cMkeep+".dbf") ALIAS mkdoc019 NEW EXCLUSIVE
    if (FILE("mkdoc"+cMkeep+".cdx"))
      ERASE ("mkdoc"+cMkeep+".cdx")
    endif

    INDEX on STR(sk)+STR(ttn) TAG "sk_ttn"
    INDEX on STR(KPL)+STR(KGP) TAG "kgp_kpl"

    ORDSETFOCUS("kgp_kpl")
    TOTAL on STR(KPL)+STR(KGP) to tmp_ktt//пара плательщик, получатель
    TOTAL on STR(KPL) to tmp_kpl

    ORDSETFOCUS("sk_ttn")
    TOTAL on STR(sk)+STR(ttn) field dcl for !(LTRIM(STR(Sk)) $ cCOX_Sl_list) to sk_ttn
    //////////////////////////////

    if (LEN(aFiles)>4 .AND. !EMPTY(mkdoc019->(LASTREC())))

      //CheckVolum(dDt,"relay.ukrpost.ua",cSmtpFrom,"sk_ttn.dbf")
      CheckVolum(dDt, "mailx.slavutich.com", cSmtpFrom, "sk_ttn.dbf")

    endif

    if (.F.)
      //получить пару плательщик, получатель
      if (!FILE("mk_ktt.dbf"))
        COPY STRU to mk_ktt.dbf
      endif

      use mk_ktt NEW EXCLUSIVE
      if (FILE("mk_ktt.cdx"))
        ERASE "mk_ktt.cdx"
      endif

      INDEX on STR(KPL)+STR(KGP) TAG "kgp_kpl"

      use tmp_ktt NEW EXCLUSIVE//пара плательщик, получатель
      SET RELA to STR(KPL)+STR(KGP) into mk_ktt
      DELE for mk_ktt->(FOUND())
      PACK
      REPL ALL NPL WITH REPLICATE(ALLTRIM(NPL), 8) for LEN(ALLTRIM(NPL))=1
      REPL ALL NGP WITH REPLICATE(ALLTRIM(NGP), 8) for LEN(ALLTRIM(NGP))=1
      close tmp_ktt

      use tmp_kpl NEW EXCLUSIVE//плательщик
      SET RELA to STR(KPL) into mk_ktt
      DELE for mk_ktt->(FOUND())
      PACK
      REPL ALL NPL WITH REPLICATE(ALLTRIM(NPL), 8) for LEN(ALLTRIM(NPL))=1
      REPL ALL NGP WITH REPLICATE(ALLTRIM(NGP), 8) for LEN(ALLTRIM(NGP))=1
      close tmp_kpl

      SELECT mk_ktt
      APPEND FROM tmp_ktt
      close mk_ktt

      use tmp_kpl NEW EXCLUSIVE
      COPY FIELDS KPL, NPL, APL to k-agent DELIM

    else

      netuse('kln')

      SELE mkdoc019
      //IF !FILE("mk_pl_tt.dbf")
      COPY STRU to mk_pl_tt.dbf
      //ENDIF
      if (!FILE("m_kttkpl.dbf"))
        COPY STRU to m_kttkpl.dbf
      endif

      use mk_pl_tt ALIAS mk_ktt NEW EXCLUSIVE
      APPEND FROM mkkplkgp for !(kgp < 20000 .OR. kpl < 2000)
      //добавляем новые точки из задожености
      if (FILE("AccDebAgg.dbf"))
        while (AccDebAgg->(!EOF()))
          SELE mk_ktt
          LOCATE for AccDebAgg->(STR(KPL)+STR(KGP)) = STR(KPL)+STR(KGP)
          if (!FOUND())
            SELE AccDebAgg; COPY to tmpAccDe next 1
            SELE mk_ktt; APPEND FROM tmpAccDe
          endif

          AccDebAgg->(DBSKIP())
        enddo

      endif

      //

      use mkkplkgp NEW
      SELE mk_ktt

      DBGOTOP()
      while (!EOF())

        kgpr:=IIF(EMPTY(kgp), 20034, kgp)
        kplr:=IIF(EMPTY(kpl), 20034, kpl)

        sele kln
        netseek('t1', 'kplr')
        okpor=kkl1
        nplr=nkl
        aplr=adr
        netseek('t1', 'kgpr')
        ngpr=nkl
        agpr=adr

        sele mk_ktt
        netrepl('kgp,kpl,okpo,ngp,npl,agp',      ;
                 'kgpr,kplr,okpor,ngpr,nplr,agpr' ;
              )

        sele mk_ktt
        SKIP
      enddo

      nuse('kln')

      sele mk_ktt
      REPL ALL NPL WITH REPLICATE(ALLTRIM(NPL), 8) for LEN(ALLTRIM(NPL))=1
      REPL ALL NGP WITH REPLICATE(ALLTRIM(NGP), 8) for LEN(ALLTRIM(NGP))=1

      if (FILE("mk_pl_tt .cdx"))
        ERASE "mk_pl_tt .cdx"
      endif

      sele mk_ktt
      INDEX on STR(KPL)+STR(KGP) TAG "kgp_kpl"

      ////////////////////////////////////////////////////////////
      //новые пары, что ТТН

      use tmp_ktt NEW EXCLUSIVE//пара плательщик, получатель
      SET RELA to STR(KPL)+STR(KGP) into mk_ktt
      DELE for mk_ktt->(FOUND())
      PACK
      REPL ALL NPL WITH REPLICATE(ALLTRIM(NPL), 8) for LEN(ALLTRIM(NPL))=1
      REPL ALL NGP WITH REPLICATE(ALLTRIM(NGP), 8) for LEN(ALLTRIM(NGP))=1
      REPL ALL OKPO WITH 20034 for OKPO=0
      close tmp_ktt
      //добавим
      SELECT mk_ktt
      APPEND FROM tmp_ktt
      COPY to tmp_ttpl
      close mk_ktt
      //////////////////////////////////////////////////////

      //////////////////////////////////////////////////////
      // создадим для хранение с накопление
      use m_kttkpl NEW EXCLUSIVE
      if (FILE("m_kttkpl.cdx"))
        ERASE "m_kttkpl.cdx"
      endif

      INDEX on STR(KPL)+STR(KGP) TAG "kgp_kpl"

      use tmp_ttpl NEW EXCLUSIVE//пара плательщик, получатель
      SET RELA to STR(KPL)+STR(KGP) into m_kttkpl
      DELE for m_kttkpl->(FOUND())
      PACK
      REPL ALL NPL WITH REPLICATE(ALLTRIM(NPL), 8) for LEN(ALLTRIM(NPL))=1
      REPL ALL NGP WITH REPLICATE(ALLTRIM(NGP), 8) for LEN(ALLTRIM(NGP))=1
      REPL ALL OKPO WITH 20034 for OKPO=0

      COPY FIELDS KPL, NPL, APL to k-agent DELIM

      close tmp_ttpl

      SELECT m_kttkpl
      APPEND FROM tmp_ttpl
      close m_kttkpl

      use m_kttkpl ALIAS mk_ktt NEW EXCLUSIVE//c накоплением
                            //USE mk_pl_tt ALIAS mk_ktt NEW EXCLUSIVE //факт, то что в kplkgp + ТТН

    endif

    //mkdoc019->(DBGOTOP())
    //dDt:=mkdoc019->DTTN

    slavu_xml(, cCOX_Sl_list)

    close skdoc
    close deb
    close mkkplkgp
#ifdef DEB_SKDOC
#else
      close AccDebAgg
#endif

    SELECT mktov019
    COPY FIELDS MnTovT, Nat to kod-pro DELIM

    close mk_ktt
    close mktov019

    /*
    mktov019->(DBGOTOP())
    dDt:=mktov019->DT
    #ifdef __CLIP__
       outlog(__FILE__,__LINE__)
    #endif
    */

#ifdef __CLIP__
      outlog(__FILE__, __LINE__, ddt, cFileNameArc, cFileList)
#endif

    cLogSysCmd:=""
#ifdef __CLIP__
      SYSCMD(cRunZip+" "+cFileNameArc+" "+ ;
              cFileList, "", @cLogSysCmd    ;
           )

      set print to clvrt.log ADDI
      //outlog(__FILE__,__LINE__,cLogSysCmd)
      qout(__FILE__, __LINE__, cLogSysCmd)

#endif
    /*
    "ware.xml ktt.xml ons.xml "+;
    "opk.xml ord_stat.xml bad_addr.xml "+;
    "saldo.xml","",@cLogSysCmd)
    */
    //"k-agent.txt kod-pro.txt ktt.xml ons.xml opk.xml","",@cLogSysCmd)

  endif

#ifdef __CLIP__

    oSmtp:=smtp():new(cSmtpServ)
    oSmtp:EOL:= "&\r&\n"
    oSmtp:lf:= CHR(13)+CHR(10)
    oSmtp:timeout := 6000*10//6000 - default

#endif
  if (MySmtpConnect(oSmtp))//oSmtp:connect()

    if (oSmtp:Hello(SUBSTR(cSmtpFrom, AT("@", cSmtpFrom)+1)))

      if (oSmtp:addField("Subject", "042"+";"+DTOC(dDt)+";"+"10"+";"+"ProdResurs"))
        //? oSmtp:error,"oSmtp:addField"
        lOk:=YES

        if (oSmtp:attach(cFileNameArc))
        //
        else
          lOk:=NO
        endif

        if (lOk)          //все приатачили
                            //? oSmtp:error,"oSmtp:attach"
          lOk:=YES
          if (oSmtp:send(cSmtpFrom, cSmtpTo, "body of letter "+cFileNameArc))
          //
          else
            lOk:=NO
          endif

          if (lOk)
            set print to clvrt.log ADDI
            if (UPPER("/saymess") $ UPPER(DosParam()))
              ALERT("== Данные переданы ====oSmtp:send() OK!=======;"+                     ;
                     "Размер:"+TRANSFORM(FILESIZE(cFileNameArc), "@R 999'999'999")+";"+ ;
                     "От:"+cSmtpFrom+";Куда:"+cSmtpTo,, "BG+/B,N/W"                         ;
                  )
            endif

            qout("=====oSmtp:send() OK!=======",                                   ;
                  "Size:", TRANSFORM(FILESIZE(cFileNameArc), "@R 999'999'999"), ;
                  cSmtpFrom, cSmtpTo                                                ;
               )
            //outlog("===============oSmtp:send() OK!=========",cSmtpFrom,cSmtpTo)
            //qout("oSmtp:send() OK!")
            oSmtp:close()
          else
#ifdef __CLIP__
              outlog("Error ", "oSmtp:send()", oSmtp:error)
#endif
            lError:=TRUE
          endif

        else
#ifdef __CLIP__
            outlog("Error ", "oSmtp:attach()", oSmtp:error)
#endif
          lError:=TRUE
        endif

      else
#ifdef __CLIP__
          outlog("Error ", "oSmtp:addField()", oSmtp:error)
#endif
        lError:=TRUE
      endif

    else
#ifdef __CLIP__
        outlog("Error ", "oSmtp:Hello()", oSmtp:error)
#endif
      lError:=TRUE
    endif

  else
#ifdef __CLIP__
      outlog("Error ", "oSmtp:connect()", cSmtpServ, oSmtp:error)
#endif
    lError:=TRUE
  endif

  if (!EMPTY(lError))
    if (UPPER("/saymess") $ UPPER(DosParam()))
      SET COLOR to GR+/R
      ALERT("Ошибка передачи. Повторите!!!"+";От:"+cSmtpFrom+";Куда:"+cSmtpTo+";Сообщение серевера:"+oSmtp:error,, "GR+/R,N/W")
    endif

    //oSmtp:reset()
    oSmtp:close()
  else
  //
  endif

  return

/***********************************************************
 * slavu_xml() -->
 *   Параметры :
 *   Возвращает:
 */
function slavu_xml(cParm, cCOX_Sl_list)
  local nSk, i
  local cNGP, cNPL, cAGP
  local nOper, cSaldoDate
  local nRec, nTTN

  SET DATE FORMAT "yyyy-mm-dd"
  SET CENTURY on
  //╦╠┴╙╙╔╞╔╦┴╘╧╥ ╘╧╥╧╟╧╫┘╚ ╘╧▐┼╦

  set print on
  set print to ons.xml
  set print to
  set print off

  set console off
  set print on
  set print to ktt.xml
  qqout('<?xml version="1.0" encoding="'+local_charset()+'"?>')
  qout('<extdata user="042">')
  qout('  <scheme name="CRMExtClientAddressDef" request="set">')
  qout('    <data>')
  qout('      <s>')
  qout('        <d name="CRMExtClientAddressDef">')
  qout('          <f name="AddressId" type="String"/>')
  qout('          <f name="CompanyId" type="String"/>')
  qout('          <f name="AddressName" type="String"/>')
  qout('          <f name="CompanyName" type="String"/>')
  qout('          <f name="Location" type="String"/>')
  qout('          <f name="TaxCode" type="String"/>')
  qout('        </d>')
  qout('      </s>')
  qout('      <o>')
  qout('        <d name="CRMExtClientAddressDef">')

  //SELECT tmp_ktt
  SELECT mk_ktt

  DBGOTOP()
  while (!EOF())
    cNGP:=ATREPL("&", ALLTRIM(NGP), "&amp;")
    cNPL:=ATREPL("&", ALLTRIM(NPL), "&amp;")
    cAGP:=ATREPL("&", ALLTRIM(AGP), "&amp;")
    qout('          <r>')
    qout('            <f>'+ALLTRIM(STR(KGP))+'</f>')
    qout('            <f>'+ALLTRIM(STR(KPL))+'</f>')
    qout('            <f>'+ALLTRIM(cNGP)+'</f>')
    qout('            <f>'+ALLTRIM(cNPL)+'</f>')
    qout('            <f>'+ALLTRIM(cAGP)+'</f>')
    qout('            <f>'+ALLTRIM(STR(OKPO))+'</f>')
    qout('          </r>')
    DBSKIP()
  enddo

  qout('        </d>')
  qout('      </o>')
  qout('    </data>')
  qout('  </scheme>')
  qout('</extdata>')
  set print to
  set print off

  set print on
  set print to bad_addr.xml
  qqout('<?xml version="1.0" encoding="'+local_charset()+'"?>')
  qout('<extdata user="042">')
  qout('  <scheme name="CRMBanAddress" request="set">')
  qout('    <data>')
  qout('     <s>')
  qout('      <d name="CRMBanAddress">')
  qout('        <f name="CompanyId" type="String"/>')
  qout('        <f name="AddressId" type="String"/>')
  qout('      </d>')
  qout('     </s>')
  qout('      <o>')
  qout('        <d name="CRMBanAddress">')
  SELECT mk_ktt

  i:=0
  m:=0

  DBGOTOP()
  while (!EOF())
    m++
    kgpr:=kgp
    kplr:=kpl
    dogPlr=getfield('t1', 'kplr', 'klndog', 'dtDogE')
    //просроченный договор
    if (dogPlr < DATE() .OR. ;
      mkkplkgp->(__dbLocate({||kgpr=kgp .AND. kplr=kpl}), !FOUND(), .F.);
      )

      qout('          <r>')
      qout('            <f>'+ALLTRIM(STR(KPL))+'</f>')
      qout('            <f>'+ALLTRIM(STR(KGP))+'</f>')
      qout('          </r>')

      i++
    endif

    DBSKIP()
  enddo

  qout('        </d>')
  qout('      </o>')
  qout('    </data>')
  qout('  </scheme>')
  qout('</extdata>')
  set print to
  set print off
  set console on
#ifdef __CLIP__
//outlog(__FILE__,__LINE__,m,i)
#endif
  set print on
  set print to saldo.xml
  qqout('<?xml version="1.0" encoding="'+local_charset()+'"?>')
  qout('<extdata user="042">')
  qout('  <scheme name="CRMSaldoEx" request="set">')
  qout('   <data>')
  qout('    <s>')
  qout('     <d name="CRMSaldoAggregate">')
  qout('      <f name="SaldoDate" type="Date"/>')
  qout('      <f name="CompanyId" type="String"/>')
  qout('      <f name="AddressId" type="String"/>')
  qout('      <f name="ProductId" type="String"/>')
  qout('      <f name="ProductName" type="String"/>')
  qout('      <f name="mCreditLimit" type="Currency"/>')
  qout('      <f name="mCustInvoice" type="Currency"/>')
  qout('      <f name="mCustInvoiceAllow" type="Currency"/>')
  qout('      <f name="mCustInvoiceOverdue" type="Currency"/>')
  qout('      <f name="mCustReturn" type="Currency"/>')
  qout('      <f name="mDebtDocBank" type="Currency"/>')
  qout('      <f name="mDebtDocCash" type="Currency"/>')
  qout('      <f name="mDebtDocCopy" type="Currency"/>')
  qout('      <f name="mReturnableDebt" type="Currency"/>')
  qout('      <f name="mVendInvoice" type="Currency"/>')
  qout('      <f name="mVendReturn" type="Currency"/>')
  qout('      <f name="mCredDoc" type="Currency"/>')
  qout('      <f name="mTotalBalance" type="Currency"/>')
  qout('     </d>')
  qout('     <d name="CRMSaldoDoc">')
  qout('      <f name="CompanyId" type="String"/>')
  qout('      <f name="AddressId" type="String"/>')
  qout('      <f name="ProductId" type="String"/>')
  qout('      <f name="ProductName" type="String"/>')
  qout('      <f name="DocumentNumber" type="String"/>')
  qout('      <f name="DocumentDate" type="Date"/>')
  qout('      <f name="ActionDate" type="Date"/>')
  qout('      <f name="PaymentDate" type="Date"/>')
  qout('      <f name="OverduePeriod" type="Integer"/>')
  qout('      <f name="CustInvoiceSumm" type="Currency"/>')
  qout('      <f name="CustReturnSumm" type="Currency"/>')
  qout('      <f name="PayDocSumm" type="Currency"/>')
  qout('     </d>')
  qout('     <d name="CRMSaldoWare">')
  qout('      <f name="CompanyId" type="String"/>')
  qout('      <f name="AddressId" type="String"/>')
  qout('      <f name="WareId" type="String"/>')
  qout('      <f name="FACode" type="String"/>')
  qout('      <f name="Quantity" type="Currency"/>')
  qout('      <f name="Summ" type="Currency"/>')
  qout('     </d>')
  qout('    </s>')
  qout('    <o>')

  qout('     <d name="CRMSaldoAggregate">')

#ifdef DEB_SKDOC
    SELECT mk_ktt
    SET RELA to STR(Kpl, 7) into deb
#else
    SELECT mk_ktt
    ORDSETFOCUS("kgp_kpl")
    SELECT AccDebAgg
    SET RELA to STR(Kpl)+STR(Kgp) into mk_ktt
#endif
  DBGOTOP()
  while (!EOF())
    if (mk_ktt->(eof()))//.F.
      DBSKIP()
      loop
    endif

    cSaldoDate:=DTOC(DATE())+'T'+TIME()
    cKopr:=kopnmr:=""
    ProductId(kop, @ckopr, @kopnmr)

    qout('      <r>')
    qout('       <f>'+cSaldoDate+'</f>')
    qout('       <f>'+ALLTRIM(STR(KPL))+'</f>')
    qout('       <f>'+ALLTRIM(STR(KGP))+'</f>')
    qout('       <f>'+ cKopr +'</f>')// <f "ProductId"
    qout('       <f>'+ kopnmr +'</f>')// <f "ProductName"
    qout('       <f>0</f>')
    qout('       <f>0</f>')
    qout('       <f>0</f>')
    qout('       <f>0</f>')
    qout('       <f>0</f>')
    qout('       <f>0</f>')
    qout('       <f>0</f>')
    qout('       <f>0</f>')
    qout('       <f>0</f>')
    qout('       <f>0</f>')
    qout('       <f>0</f>')
#ifdef DEB_SKDOC
      nKZ:=deb->KZ
      nDZ:=deb->DZ
#else
      nKZ:=IIF(sdp < 0, ABS(sdp), 0)
      nDZ:=IIF(sdp >= 0, ABS(sdp), 0)
#endif
    qout('       <f>'+ALLTRIM(STR(nKZ,, 2))+'</f>')
    qout('       <f>'+ALLTRIM(STR(nDZ,, 2))+'</f>')
    qout('      </r>')
    DBSKIP()
  enddo

  qout('     </d>')
  qout('          ')
  qout('          ')
  qout('    <d name="CRMSaldoDoc">')

  SELECT mk_ktt
  ORDSETFOCUS("kgp_kpl")
  sele skdoc
  SET RELA to STR(Kpl)+STR(Kgp) into mk_ktt
  DBGoTop()
  while (!EOF())

    if (mk_ktt->(eof()))//.F.
      DBSKIP()
      loop
    endif

#ifdef DEB_SKDOC
      if (.not. (ktas = 556))
        DBSKIP()
        loop
      endif

#else
      if (.not. (nap = 2 .OR. nap = 556))
        DBSKIP()
        loop
      endif

#endif

    nRec:=RECNO()
    nTTN:=TTN
    sum Sdp to nSdp while nTTN = TTN
    DBGOTO(nRec)

    DtOplr:=IIF(EMPTY(DtOpl), DOP, DtOpl)
    cKopr:=kopnmr:=""
    ProductId(kop, @ckopr, @kopnmr)

    qout('      <r>')
    qout('       <f>'+ALLTRIM(STR(KPL))+'</f>')// <f "CompanyId"
    qout('       <f>'+ALLTRIM(STR(KGP))+'</f>')// <f "AddressId"
    qout('       <f>'+ cKopr +'</f>')// <f "ProductId"
    qout('       <f>'+ kopnmr +'</f>')// <f "ProductName"
    qout('       <f>'+ALLTRIM(STR(TTN))+'</f>')// <f "DocumentNumber"
    qout('       <f>'+DTOC(DOP)+'T00:00:00'+'</f>')//<f "DocumentDate"
    qout('       <f>'+DTOC(DOP)+'T00:00:00'+'</f>')//<f "ActionDate"
    qout('       <f>'+DTOC(DtOplr)+'T00:00:00'+'</f>')//<f "PaymentDate"
    qout('       <f>'+LTRIM(STR(date()-DtOplr, 6, 0))+'</f>')//<f "OverduePeriod" - к-во дней просрочки
                            //qout('       <f>'+LTRIM(STR(sdv))+'</f>')       //<f "CustInvoiceSumm"
    qout('       <f>'+LTRIM(STR(nSdp))+'</f>')//<f "CustInvoiceSumm"
    qout('       <f>0</f>')//<f "CustReturnSumm"
    qout('       <f>0</f>')//<f "PayDocSumm" - свободные авасы по баку
    qout('      </r>')

    sele skdoc
    while (nTTN = TTN)
      DBSkip()
    enddo

  enddo

  qout('    </d>')

  qout('    <d name="CRMSaldoWare">')
  qout('    </d>')

  qout('   </o>')
  qout('  </data>')
  qout(' </scheme>')
  qout('</extdata>')

  set print to
  set print off
  set console on

  set print on
  set print to ware.xml
  //╧╙╘┴╘╦╔ ╬┴ ╙╦╠┴─┼ названия товаров на складах
  qqout('<?xml version="1.0" encoding="'+local_charset()+'"?>')
  qout('<extdata user="042">')
  qout('  <scheme name="CRMWareSUP" request="set">')
  qout('    <data>')
  qout('      <s>')
  qout('        <d name="CRMWareSUP">')
  qout('          <f name="WareId" type="String"/>')
  qout('          <f name="WareName" type="String"/>')
  qout('        </d>')
  qout('      </s>')
  qout('      <o>')

  qout('    <d name="CRMWareSUP">')

  SELECT mktov019
  ORDSETFOCUS("MnTov")

  DBGOTOP()
  while (!EOF())
    qout('     <r>')
    qout('       <f>'+ALLTRIM(STR(MnTovT))+'</f>')
    qout('       <f>'+ALLTRIM(Nat)+'</f>')
    qout('     </r>')
    DBSKIP()
  enddo

  qout('      </d>')

  qout('     </o>')
  qout('    </data>')
  qout('  </scheme>')
  qout('</extdata>')
  set print to
  set print off

  set print on
  set print to taremoex.xml
  //outlog(__FILE__,__LINE__,"//движение тары")
  SELECT mkdoc019
  ORDSETFOCUS("sk")
  DBGOTOP()

  qqout('<?xml version="1.0" encoding="'+local_charset()+'"?>')
  qout('<extdata user="042">')
  qout('  <scheme name="CRMTareMotionEx" request="set">')
  qout('    <data>')
  qout('      <s>')
  qout('        <d name="CRMTareMotionParam">')
  qout('          <f name="WorkDate" type="Date"/>')
  qout('          <f name="SkipDelete" type="Integer"/>')
  qout('        </d>')
  qout('        <d name="CRMTareMotionDoc">')
  qout('          <f name="WareHouseId" type="String"/>')
  qout('          <f name="DocumentDate" type="Date"/>')
  qout('          <f name="DocumentNumber" type="String"/>')
  qout('          <f name="Operation" type="Integer"/>')
  qout('          <f name="CompanyId" type="String"/>')
  qout('          <f name="AddressId" type="String"/>')
  qout('          <d name="CRMTareMotionLine">')
  qout('              <f name="WareId" type="String"/>')
  qout('              <f name="IsPurchased" type="Integer"/>')
  qout('              <f name="Quantity" type="Currency"/>')
  qout('              <f name="Price" type="Currency"/>')
  qout('          </d>')
  qout('        </d>')
  qout('      </s>')
  qout('      <o>')

  qout('        <d name="CRMTareMotionParam">')
  qout('          <r>')
  qout('            <f>' + DTOC(DTtn) + 'T00:00:00'+'</f>')
  qout('            <f>' + ALLTRIM(STR(IIF(UPPER("/CrmAdd") $ cDosParam, 1, 0)))+'</f>')
  qout('          </r>')
  qout('        </d>')

  qout('        <d name="CRMTareMotionDoc">')
  SELECT mkdoc019
  ORDSETFOCUS("sk")
  DBGOTOP()
  while (!EOF())
    nSk:=_field->Sk
    nTtn:=_field->Ttn

    if (!(mntov>=10^4 .and. mntov<=10^6))
      DBSKIP()
      loop
    endif

    qout('          <r>')
    qout('            <f>'+ALLTRIM(STR(SK+1000))+'</f>')
    qout('            <f>'+DTOC(DTtn)+'T00:00:00'+'</f>')
    qout('            <f>'+ALLTRIM(STR(TTN))+'</f>')
    qout('            <f>'+"1"+'</f>')
    qout('            <f>'+ALLTRIM(STR(KPL))+'</f>')
    qout('            <f>'+ALLTRIM(STR(KGP))+'</f>')
    qout('          <d name="CRMTareMotionLine">')
    while (nSk = _field->Sk .AND. nTtn = _field->Ttn)
      zenr:=zen             //-Pr_Butr бутылка

      qout('            <r>')
      qout('              <f>'+ALLTRIM(STR(MnTovT))+'</f>')
      qout('              <f>'+"1"+'</f>')
      //qout('              <f>'+ALLTRIM(STR(Kvp,,3))+'</f>')
      qout('              <f>'+ALLTRIM(STR(0,, 3))+'</f>')
      qout('              <f>'+ALLTRIM(STR(ROUND(zenr*(1+(gnNds/100)), 2),, 3))+'</f>')
      qout('            </r>')
      DBSKIP()
    enddo

    qout('          </d>')
    qout('          </r>')

  enddo

  qout('        </d>')

  qout('     </o>')
  qout('    </data>')
  qout('  </scheme>')
  qout('</extdata>')
  set print to
  set print off

  set print on
  set print to ons.xml
  //╧╙╘┴╘╦╔ ╬┴ ╙╦╠┴─┼ остатки на складах
  qqout('<?xml version="1.0" encoding="'+local_charset()+'"?>')
  qout('<extdata user="042">')
  qout('  <scheme name="CRMWhBalanceEx" request="set">')
  qout('    <data>')
  qout('      <s>')
  qout('        <d name="CRMWhBalance">')
  qout('          <f name="WareHouseId" type="String"/>')
  qout('          <f name="DocumentDate" type="Date"/>')
  qout('          <f name="DocumentNumber" type="String"/>')
  //qout('          <f name="PersonId" type="String"/>')
  qout('          <d name="CRMWhBalanceLine">')
  qout('            <f name="WareId" type="String"/>')
  //qout('            <f name="UnitId" type="String"/>')
  qout('            <f name="Quantity" type="Currency"/>')
  qout('          </d>')
  qout('        </d>')
  qout('      </s>')
  qout('      <o>')
  qout('        <d name="CRMWhBalance">')

  SELECT mktov019
  ORDSETFOCUS("sk")
  DBGOTOP()
  while (!EOF())
    nSk:=_field->Sk

    //пропустим склад, если остатки отрицательны
    nRec:=RECNO()
    COUNT to nCnt for OsFo > 0 while nSk = _field->Sk
    if (nCnt = 0 .OR. (LTRIM(STR(nSk)) $ cCOX_Sl_list))
      loop
    endif

    DBGOTO(nRec)

    qout('          <r>')
    qout('            <f>'+ALLTRIM(STR(SK))+'</f>')
    qout('            <f>'+DTOC(Dt)+'T00:00:00'+'</f>')
    qout('            <f>'+"0"+'</f>')
    //qout('            <f>nil</f>')
    qout('            <d name="CRMWhBalanceLine">')

    while (nSk = _field->Sk)
      if (OsFo > 0)       //только положительные
        qout('              <r>')
        qout('                <f>'+ALLTRIM(STR(MnTovT))+'</f>')
        //qout('                <f>'+ALLTRIM(NEi)+'</f>')
        qout('                <f>'+ALLTRIM(STR(OsFo,, 0))+'</f>')
        qout('              </r>')
      endif

      DBSKIP()
    enddo

    qout('            </d>')
    qout('          </r>')
  enddo

  qout('        </d>')
  qout('      </o>')
  qout('    </data>')
  qout('  </scheme>')
  qout('</extdata>')
  set print to
  set print off

  set print on
  set print to tareost.xml
  qqout('<?xml version="1.0" encoding="'+local_charset()+'"?>')
  qout('<extdata user="042">')
  qout('  <scheme name="CRMWhTareBalanceEx" request="set">')
  qout('    <data>')
  qout('      <s>')
  qout('        <d name="CRMWhTareBalance">')
  qout('          <f name="WareHouseId" type="String"/>')
  qout('          <f name="DocumentDate" type="Date"/>')
  qout('          <d name="CRMWhTareBalanceLine">')
  qout('            <f name="WareId" type="String"/>')
  qout('            <f name="QtyOne" type="Currency"/>')
  qout('            <f name="QtyBox" type="Currency"/>')
  qout('            <f name="QtyPalet" type="Currency"/>')
  qout('            <f name="IsPurchased" type="Integer"/>')
  qout('          </d>')
  qout('        </d>')
  qout('      </s>')
  qout('      <o>')
  qout('        <d name="CRMWhTareBalance">')

  SELECT mktov019
  ORDSETFOCUS("sk")
  DBGOTOP()
  while (!EOF())
    nSk:=_field->Sk

    //пропустим склад, если остатки отрицательны
    nRec:=RECNO()
    COUNT to nCnt for OsFo > 0 .AND. INT(MnTovT/(10^4))=0 while nSk = _field->Sk
    if (nCnt = 0 .OR. (LTRIM(STR(nSk)) $ cCOX_Sl_list))
      loop
    endif

    DBGOTO(nRec)

    qout('          <r>')
    qout('            <f>'+ALLTRIM(STR(SK+1000))+'</f>')
    qout('            <f>'+DTOC(Dt)+'T00:00:00'+'</f>')
    qout('            <d name="CRMWhTareBalanceLine">')

    while (nSk = _field->Sk)
      if (OsFo > 0 .AND. INT(MnTovT/(10^4))=0)//только положительные
        qout('              <r>')
        qout('                <f>'+ALLTRIM(STR(MnTovT))+'</f>')
        qout('                <f>'+ALLTRIM(STR(OsFo,, 0))+'</f>')
        qout('                <f>0</f>')
        qout('                <f>0</f>')
        qout('                <f>0</f>')
        qout('              </r>')
      endif

      DBSKIP()
    enddo

    qout('            </d>')
    qout('          </r>')
  enddo

  qout('        </d>')
  qout('      </o>')
  qout('    </data>')
  qout('  </scheme>')
  qout('</extdata>')

  set print to
  set print off

  //╧╘╟╥╒┌╦┴ ╨╥╧─╒╦├╔╔ ╦╠╔┼╬╘┴═ отгрузка продукции клиентам
  if (!EMPTY(mkdoc019->(LASTREC())))
    set print on
    set print to opk.xml
    qqout('<?xml version="1.0" encoding="'+local_charset()+'"?>')
    qout('<extdata user="042">')
    qout('  <scheme name="CRMDespatchEx" request="set">')
    qout('    <data>')
    qout('      <s>')
    qout('        <d name="CRMDespatchParam">')
    qout('          <f name="WorkDate" type="Date"/>')
    qout('          <f name="SkipDelete" type="Integer"/>')
    qout('        </d>')
    qout('        <d name="CRMDespatch">')
    qout('          <f name="CompanyId" type="String"/>')
    qout('          <f name="AddressId" type="String"/>')
    qout('          <f name="CRMOrderNumber" type="String"/>')
    qout('          <f name="DocumentNumber" type="String"/>')
    qout('          <f name="DocumentDate" type="Date"/>')
    qout('          <f name="WareHouseId" type="String"/>')
    qout('          <f name="WareId" type="String"/>')
    qout('          <f name="Price" type="Currency"/>')
    qout('          <f name="Quantity" type="Currency"/>')
    qout('          <f name="Operation" type="Integer"/>')
    qout('        </d>')
    qout('      </s>')
    qout('      <o>')

    aEmptyMnTovT:={}
    AADD(aEmptyMnTovT, 0000000)
    SELECT mktov019
    ORDSETFOCUS("sk")
    SELECT mkdoc019
    SET RELA to STR(sk)+STR(mntovT) into mktov019
    DBGOTOP()

    qout('        <d name="CRMDespatchParam">')
    qout('          <r>')
    qout('            <f>' + DTOC(DTtn) + 'T00:00:00'+'</f>')
    qout('            <f>' + ALLTRIM(STR(IIF(UPPER("/CrmAdd") $ cDosParam, 1, 0)))+'</f>')
    qout('          </r>')
    qout('        </d>')

    qout('        <d name="CRMDespatch">')

    nOper:=1

    DBGOTOP()
    while (!EOF())
      // пропускаем склады СОХ
      //outlog(__FILE__,__LINE__,nSk,LTRIM(STR(nSk)),LTRIM(STR(nSk))$"240 302 402 502")
      if (!(LTRIM(STR(Sk)) $ cCOX_Sl_list))

        //цена бутылки - разница между ценами
        Pr_Butr:=mktov019->CenPr - IIF(EMPTY(mktov019->Pr_N_But), mktov019->CenPr, mktov019->Pr_N_But)
        if (EMPTY(mktov019->Pr_N_But) .AND. EMPTY(ASCAN(aEmptyMnTovT, MnTovT)))
          AADD(aEmptyMnTovT, MnTovT)
#ifdef __CLIP__
            outlog(__FILE__, __LINE__, "EMPTY(mktov019->Pr_N_But)", sk, MnTovT, Nat)
#endif
        endif

        do case
        case vo = 1
           nOper:=2// (-)
        case vo = 5
           nOper:=4// (+/-)
        case vo = 6
           nOper:=3// (+/-)
        otherwise
          nOper:=1               // (+)
        endcase

        //вычитамее цену бутылки
        if (DTtn >= STOD("20120901"))
          zenr:=zen
        else
          zenr:=zen-Pr_Butr
        endif

        qout('          <r>')
        qout('            <f>'+ALLTRIM(STR(KPL))+'</f>')
        qout('            <f>'+ALLTRIM(STR(KGP))+'</f>')
        qout('            <f>'+IIF(EMPTY(DocGUID), 'User.KTA:'+ALLTRIM(STR(Kta)), ALLTRIM(DocGUID))+'</f>')
        qout('            <f>'+ALLTRIM(STR(TTN))+'</f>')
        qout('            <f>'+DTOC(DTtn)+'T00:00:00'+'</f>')
        qout('            <f>'+ALLTRIM(STR(Sk))+'</f>')
        qout('            <f>'+ALLTRIM(STR(MnTovT))+'</f>')
        qout('            <f>'+ALLTRIM(STR(ROUND(zenr*(1+(gnNds/100)), 2),, 3))+'</f>')
        qout('            <f>'+ALLTRIM(STR(Kvp,, 3))+'</f>')
        qout('            <f>'+ALLTRIM(STR(nOper, 2, 0))+'</f>')
        qout('          </r>')
      endif

      DBSKIP()
    enddo

    qout('        </d>')
    qout('      </o>')
    qout('    </data>')
    qout('  </scheme>')
    qout('</extdata>')
    set print to
    set print off
    set console on
  endif

  if (UPPER("/mkdoc019") $ UPPER(DosParam()))
    CRMOrderStatus()
  else                      //готовим по lrs1 -   то что, загрузили в склад
    SELECT mkdoc019
    close
    lRs1_CRMOrdStat()
  endif

  nuse('klndog')

  return (nil)

/***********************************************************
 * local_charset() -->
 *   Параметры :
 *   Возвращает:
 */
static function local_charset()
  return (set("PRINTER_CHARSET"))

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  05-07-07 * 02:52:10pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
function CRMOrderStatus()
  local cNnz
  local cCRMOrderNumber
  if (!EMPTY(mkdoc019->(LASTREC())))
    set print on
    set print to ord_stat.xml
    qqout('<?xml version="1.0" encoding="'+local_charset()+'"?>')
    qout('<extdata user="042">')
    qout('  <scheme name="CRMOrderStatus" request="set">')
    qout('    <data>')
    qout('     <s>')
    qout('      <d name="CRMOrderStatus">')
    qout('        <f name="CRMOrderNumber" type="String"/>')
    qout('        <f name="StatusId" type="String"/>')
    qout('        <f name="Comment" type="String"/>')
    qout('        <f name="HostName" type="String"/>')
    qout('        <f name="OperationTime" type="Date"/>')
    qout('        <f name="UserName" type="String"/>')
    qout('      </d>')
    qout('     </s>')
    qout('      <o>')
    qout('        <d name="CRMOrderStatus">')

    i:=0
    SELECT mkdoc019
    DBGOTOP()
    while (!EOF())
      if (.F.)            //условия пропуска, те которые не изменили статус
        loop
        DBSKIP()
        loop
      endif

      if (EMPTY(Nnz))   //номер ТТН, которой будет присвоино
        cNnz:=ALLTRIM(STR(RECNO()+1000))
      endif

      if (EMPTY(DocGUID))//учетный номер ТТН на КПК
        cCRMOrderNumber:='ZP.'+ALLTRIM(STR(RECNO()+1000))
      else
        cCRMOrderNumber:=ALLTRIM(DocGUID)
        i:=0
      endif

      qout('          <r>')
      //qout('              <f>'+ALLTRIM(DocGUID)+'</f>')
      qout('              <f>'+cCRMOrderNumber+'</f>')
      qout('              <f>'+'Transfered'+'</f>')
      qout('              <f>'+ALLTRIM(cNnz)+' '+DTOC(dDc)+'</f>')
      qout('              <f>'+'Host'+'</f>')
      qout('              <f>'+DTOC(dDc)+'T'+tDc+'</f>')//DTOC(dDc)+'T'+tDc
                            //qout('              <f>'+DTOC(DTtn)+'T00:00:00'+'</f>')//DTOC(dDc)+'T'+tDc
      qout('              <f>'+'User'+'</f>')
      qout('          </r>')
      if (i++)>=10
        exit
      endif

      DBSKIP()
    enddo

    qout('        </d>')
    qout('      </o>')
    qout('    </data>')
    qout('  </scheme>')
    qout('</extdata>')
    set print to
    set print off
    set console on

  endif

  return (nil)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  05-07-07 * 03:09:37pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
function lRs1_CRMOrdStat()

  use lrs1 ALIAS mkdoc019 NEW

  CRMOrderStatus()

  close mkdoc019

  return (nil)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  04-05-08 * 01:10:54pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
static function CheckVolum(dDt, cSmtpServ, cSmtpFrom, cFileNameArc)
  local nCnt4Crm, nCntTotal
  local nDcl4Crm, nDclTotal
  local cLogSysCmd, oSmtp, cData
  local lOk, lError
  local cSmtpTo

  lOk:=YES
  lError:=NO

  use sk_ttn NEW

  COUNT to nCnt4Crm for "SV" $ UPPER(DocGUID) .and. vo=9
  COUNT to nCntTotal for vo=9

  SUM dcl to nDcl4Crm for "SV" $ UPPER(DocGUID) .and. vo=9
  SUM dcl to nDclTotal for vo=9

  close sk_ttn

  cData:=                                                                                        ;
   "      Отчет за "+DTOC(dDt)+CHR(10)+                                                      ;
   CHR(10)+                                                                                    ;
   " Соотношение по к-ву документов - "+LTRIM(STR(nCnt4Crm/nCntTotal*100, 15, 1))+CHR(10)+ ;
   CHR(10)+                                                                                    ;
   " Соотношение по объемам продаж  - "+LTRIM(STR(nDcl4Crm/nDclTotal*100, 15, 1))+CHR(10)+ ;
   CHR(10)+                                                                                    ;
   CHR(10)+                                                                                    ;
   "============================"+CHR(10)+                                                     ;
   "Станислав Литовка"+CHR(10)+                                                                ;
   "Email: lista@bk.ru"+CHR(10)+                                                               ;
   "  Тел:   +38 097 213 77 56"+CHR(10)+                                                       ;
   ""

  if (UPPER("/support") $ UPPER(DosParam()))
    cSmtpTo:="lista@bk.ru"
  else
    //cSmtpTo:="real.prodresurs@mail.ru"
    //cSmtpTo:="emez_maksim@mail.ru"
    //cSmtpTo:="emec-maksim@yandex.ru"
    cSmtpTo:="CrmExc_042@bbhua.com"
  endif

  cLogSysCmd:=""

#ifdef __CLIP__

    oSmtp:=smtp():new(cSmtpServ)
    oSmtp:timeout := 6000*100
    oSmtp:EOL:= "&\r&\n"
    oSmtp:lf:= CHR(13)+CHR(10)
#endif

  if (MySmtpConnect(oSmtp))//oSmtp:connect()

    if (oSmtp:Hello(SUBSTR(cSmtpFrom, AT("@", cSmtpFrom)+1)))
      //IF .T. //oSmtp:Hello(SUBSTR(cSmtpFrom,1,AT("@",cSmtpFrom)-1))

      if (oSmtp:addField("Subject", "042"+";"+DTOC(dDt)+";"+"10"+";"+"ProdResurs"))
        //? oSmtp:error,"oSmtp:addField"
        lOk:=YES
        if (!EMPTY(cFileNameArc))
          if (oSmtp:attach(cFileNameArc))
          //
          else
            lOk:=NO
          endif

        endif

        if (lOk)          //все приатачили
                            //? oSmtp:error,"oSmtp:attach"
          lOk:=YES
          if (oSmtp:send(cSmtpFrom, cSmtpTo, cData))
          //
          else
            lOk:=NO
          endif

          if (lOk)
            qout("oSmtp:send() OK!", cSmtpFrom, cSmtpTo)
#ifdef __CLIP__
//outlog("oSmtp:send() OK!",cSmtpFrom,cSmtpTo)
#endif
            //qout("oSmtp:send() OK!")
            oSmtp:close()
          else
#ifdef __CLIP__
              outlog(oSmtp:error, "oSmtp:send()", cSmtpFrom, cSmtpTo)
#endif
            lError:=TRUE
          endif

        else
#ifdef __CLIP__
            outlog(oSmtp:error, "oSmtp:attach()")
#endif
          lError:=TRUE
        endif

      else
#ifdef __CLIP__
          outlog(oSmtp:error, "oSmtp:addField()")
#endif
        lError:=TRUE
      endif

    else
#ifdef __CLIP__
        outlog(oSmtp:error, "oSmtp:Hello()")
#endif
      lError:=TRUE
    endif

  else
#ifdef __CLIP__
      outlog(oSmtp:error, cSmtpServ, "oSmtp:connect()")
#endif
    lError:=TRUE
  endif

  if (!EMPTY(lError))
    //oSmtp:reset()
    oSmtp:close()
  endif

  return (nil)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-08-11 * 11:25:23am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
static function ProductId(nkop, cKopr, kopnmr)
  nkop:=160
  do case
  case (nkop=161)
    cKopr:="21"
  case (nkop=169)
    cKopr="29"
  otherwise
    cKopr="01"              //безнал 1-19, все что выше нал
  endcase

  kopnmr:=ltrim(str(nkop, 3))+"-код операции"
  return (nil)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-21-17 * 00:19:10am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
function slavutich()

  if (UPPER("/repite-ost") $ UPPER(DosParam()))

    dtBegr:=dtEndr:=DATE()

    if (UPPER("/get-date") $ UPPER(DosParam()))

      clvrt_get_date(@dtBegr, @dtEndr,                                ;
                      "Поторная передача данных за период.",           ;
                      "!!! Передаются ТОЛЬКО подготовленые данные!!!", ;
                      {| a1, a2 | a1<=a2 .and. a2-a1<=4}             ;
                   )

      if (LASTKEY()=13)
        set device to print
        set print to a-sla_rep.exe

        ??"#!/bin/sh"
        ?"umask 002"
        ?'export APP_CLVRT="/usr/bin/app_clvrt /slavutich /repite-ost "'
        ?"$APP_CLVRT"+                    ;
         " /gdTd" +DTOS(BOM(dtBegr))+ ;
         " /dtBeg"+DTOS(dtBegr)+        ;
         " /dtEnd"+DTOS(dtBegr)
        if (dtBegr # dtEndr)
          ?"sleep 3m"
          if (BOM(dtBegr + 1) = BOM(dtEndr))//в одном месяце
            ?"$APP_CLVRT"+                      ;
             " /gdTd" +DTOS(BOM(dtBegr+1))+ ;
             " /dtBeg"+DTOS(dtBegr+1)+        ;
             " /dtEnd"+DTOS(dtEndr)+          ;
             " /CrmAdd"
          else              // разные месяца
            ?"$APP_CLVRT"+                      ;
             " /gdTd" +DTOS(BOM(dtBegr+1))+ ;
             " /dtBeg"+DTOS(dtBegr+1)+        ;
             " /dtEnd"+DTOS(EOM(dtBegr))+   ;
             " /CrmAdd"
            ?"$APP_CLVRT"+                    ;
             " /gdTd" +DTOS(BOM(dtEndr))+ ;
             " /dtBeg"+DTOS(BOM(dtEndr))+ ;
             " /dtEnd"+DTOS(dtEndr)+        ;
             " /CrmAdd"
          endif

        endif

        ?""
        ?"exit 0"
        set print to

        cLogSysCmd:=""
        SYSCMD("cat ./a-sla_rep.exe| tr -d '\r'>a-sla_rep.sh", "", @cLogSysCmd)
        cLogSysCmd:=""
        SYSCMD("chmod +x ./a-sla_rep.sh", "", @cLogSysCmd)

        close all
        cLogSysCmd:=""
        SYSCMD("./a-sla_rep.sh", "", @cLogSysCmd)

      //ERRORLEVEL(2)
      endif

      QUIT

    else
      if (UPPER("/dtBeg") $ cDosParam)
        Dt_Beg_End(cDosParam, .T., @dtBegr, @dtEndr)
      else
        return
      endif

    endif

    for dOtch:=dtBegr to dtEndr

      cPathOst019:=gcPath_ew+"ost\mk"+"019"+                ;
       "\G"+PADL(LTRIM(STR(YEAR(dOtch))), 4, "0")+  ;
       "\M"+PADL(LTRIM(STR(MONTH(dOtch))), 2, "0")+ ;
       "\D"+PADL(LTRIM(STR(DAY(dOtch))), 2, "0")

#ifdef MKOTCHD58
        cPathOst058:=gcPath_ew+"ost\mk"+"058"+                ;
         "\G"+PADL(LTRIM(STR(YEAR(dOtch))), 4, "0")+  ;
         "\M"+PADL(LTRIM(STR(MONTH(dOtch))), 2, "0")+ ;
         "\D"+PADL(LTRIM(STR(DAY(dOtch))), 2, "0")
#endif

      //IF !FILE("mktov019.dbf")
      use (cPathOst019+"\mktov") ALIAS mktov NEW
      copy stru to mktov019
      close
      //ENDIF
      //IF !FILE("mkdoc019.dbf")
      use (cPathOst019+"\mkdoc") ALIAS mkdoc NEW
      copy stru to mkdoc019
      close
      //ENDIF

      use mkdoc019 NEW EXCLUSIVE
      ZAP
      outlog(__FILE__, __LINE__, cPathOst019+"\mkdoc")
      APPEND FROM (cPathOst019+"\mkdoc")
#ifdef MKOTCHD58
        APPEND FROM (cPathOst058+"\mkdoc")
#endif
      close
      use mktov019 NEW EXCLUSIVE
      ZAP
      APPEND FROM (cPathOst019+"\mktov")
#ifdef MKOTCHD58
        APPEND FROM (cPathOst058+"\mktov")
#endif
      close

      use mktov019 NEW
      use mkdoc019 NEW

      test_doc_sk(228, dOtch)
      test_doc_sk(300, dOtch)
      test_doc_sk(400, dOtch)
      test_doc_sk(500, dOtch)

      test_doc_sk(228, dOtch, "бутылка")
      test_doc_sk(300, dOtch, "бутылка")
      test_doc_sk(400, dOtch, "бутылка")
      test_doc_sk(500, dOtch, "бутылка")

      close mktov019
      close mkdoc019

      cNameFileTest:="ts"+RIGHT(DTOS(dOtch), 6)+".xml"
      COPY FILE test.xml to (cNameFileTest)
      aFileList:=nil

      set("PRINTER_CHARSET", "cp866")
      slavu("019", dOtch, @aFileList, cNameFileTest)

      //IF !(aFileList = NIL) //частичная передача данных
      ERASE (cNameFileTest)
      ADEL(aFileList, LEN(aFileList)); ASIZE(aFileList, LEN(aFileList)-1)
      //ENDIF

    next

    return
  endif

  if (UPPER("/repite-zip") $ UPPER(DosParam()))
    slavu("019", DATE()-1, {"opk.xml", "ktt.xml"}, "saldo.xml")
  else

    dtBegr:=dtEndr:=DATE()
    if (UPPER("/get-date") $ UPPER(DosParam()))
    //
    else

      if (UPPER("/dtBeg") $ cDosParam)

        Dt_Beg_End(cDosParam, .T., @dtBegr, @dtEndr)
        aFileList:={"opk.xml", "ktt.xml"}//,"t est.xml"}
        /*
        IF "test.xml" $ aFileList[3]
          COPY FILE test.xml TO (aFileList[3]:="test"+DTOS(dOtch)+" "+CHARREPL(":", TIME(), "-")+".xml",aFileList[3])
        ENDIF
        */

      else
        dtBegr:=date()-1
        dtEndr:=date()-1
        aFileList:=nil
      endif

    endif

    mkkplkgp(19, nil)
    mkkplkgp(58, 1)

#ifdef __CLIP__
      outlog(__FILE__, __LINE__, "Учетные периоды  dtBeg dtEnd ", dtBegr, dtEndr)
#endif
    for dOtch:=dtBegr to dtEndr

      if (!(UPPER("/ost-dt") $ UPPER(DosParam())))
        mkotchn(dOtch, 19, nil, 1, nil)//,{||.T.}) //1 все склады
                                         //
        mkotchn(dOtch, 58, nil, 1, nil)//,{||.T.}) //1 все склады

        use mktov019 NEW EXCLUSIVE
        APPEND FROM mktov058
        close

        if (!file("mkpr019.dbf") .or. !file("mkpr058.dbf"))
          copy stru to mkpr019
          copy stru to mkpr058
        endif

        //приход - расход на -1
        use mkpr019 NEW EXCLUSIVE
        REPL ALL dcl WITH dcl*(-1), kvp WITH kvp*(-1)
        CLOSE
        use mkpr058 NEW EXCLUSIVE
        REPL ALL dcl WITH dcl*(-1), kvp WITH kvp*(-1)
        CLOSE

        use mkdoc019 NEW EXCLUSIVE
        APPEND FROM mkpr019
        APPEND FROM mkdoc058
        APPEND FROM mkpr058
      else
#ifdef __CLIP__
          outlog(__FILE__, __LINE__, 'UPPER("/ost-dt") $ UPPER(DosParam())')
#endif

        mkotchd(dOtch, 19, nil, 1, nil)//,{||.T.}) //1 все склады
                                         //
#ifdef MKOTCHD58
          mkotchd(dOtch, 58, nil, 1, nil)//,{||.T.}) //1 все склады

          use mktov019 NEW EXCLUSIVE
          APPEND FROM mktov058
          close

          use mkdoc019 NEW EXCLUSIVE
          APPEND FROM mkdoc058
#else
          use mkdoc019 NEW EXCLUSIVE
#endif

      endif

      if (!(aFileList = nil))//частичная передача данных
        if (mkdoc019->(EMPTY(LASTREC())))
          close mkdoc019
          loop
        endif

        //COPY FILE test.xml TO (aFileList[3]:="test"+DTOS(dOtch)+" "+CHARREPL(":", TIME(), "-")+".xml",aFileList[3])

      endif

      cNameFileTest:="ts"+RIGHT(DTOS(dOtch), 6)+".xml"
      COPY FILE test.xml to (cNameFileTest)

      close

      cDir:="s"+right(dtos(dOtch), 6)
      if (dirchange(cDir)#0)
        dirmake(cDir)
      endif
      dirchange(gcPath_l)

      copy file mktov019.dbf to (cDir+"\"+"mktov.dbf")
      copy file mktov019.dbf to (cDir+"\"+"mktov019.dbf")
      copy file mkdoc019.dbf to (cDir+"\"+"mkdoc019.dbf")

      if (aFileList = nil)//НЕТ частичной передачи данных

        if (!(UPPER("/ost-dt") $ UPPER(DosParam())))
          OtguzFuture(dOtch, cDir)
        endif

        copy file (cDir+"\"+"mktov019.dbf") to mktov019.dbf
        copy file (cDir+"\"+"mkdoc019.dbf") to mkdoc019.dbf

        use mktov019 NEW
        use mkdoc019 NEW

        test_doc_sk(228, dOtch)
        test_doc_sk(300, dOtch)
        test_doc_sk(400, dOtch)
        test_doc_sk(500, dOtch)

        test_doc_sk(228, dOtch, "бутылка")
        test_doc_sk(300, dOtch, "бутылка")
        test_doc_sk(400, dOtch, "бутылка")
        test_doc_sk(500, dOtch, "бутылка")

        close mktov019
        close mkdoc019

      endif

      set("PRINTER_CHARSET", "cp866")
      slavu("019", dOtch, @aFileList, cNameFileTest)

      //IF !(aFileList = NIL) //частичная передача данных
      ERASE (cNameFileTest)
      ADEL(aFileList, LEN(aFileList)); ASIZE(aFileList, LEN(aFileList)-1)
      //ENDIF

    next

  endif

  return (nil)

#ifdef __CLIP__

  /*****************************************************************
   
   FUNCTION:
   АВТОР..ДАТА..........С. Литовка  04-18-07 * 01:43:18pm
   НАЗНАЧЕНИЕ......... обработка XML Славитича
   ПАРАМЕТРЫ..........
   ВОЗВР. ЗНАЧЕНИЕ....
   ПРИМЕЧАНИЯ.........
   */
  function Xml2Rs1_4CRM(cDir, cFile, aKop)

    local cAID, cVal, nVal, lRet
    /*
    1               ю┴╠╔▐╬┘┼ (┬┼┌ ▐┼╦┴) -       169-ю┴╠.┬┼┌.─╧╦
    2               ю┴╠╔▐╬┘┼ (╙ ▐┼╦╧═)  -       161-ю┴╠.╙.─╧╦
    3               т┼┌╬┴╠╔▐╬┘╩ ╥┴╙▐г╘  -      160-я╘╙╥. ╙ ─╧╦
    4               ю┴╠╔▐╬┘┼ ╙ ╧╘╙╥╧▐╦╧╩  -  126-я╘╙╥. ┬┼┌ ─╧╦
    5               т┼┌╬┴╠╔▐╬┘╩ ╥┴╙▐г╘ ╙ ╧╘╙╥╧▐╦╧╩ - 160-я╘╙╥. ╙ ─╧╦
    */

    if (!FILE(cDir+'/'+cFile))
      return (.F.)
    endif

    netuse('cskl')
    netuse('s_tag')
    netuse('kgp')

    // Загрузка продаж (КПК)
    lcrtt('lrs1', 'rs1')
    lindx('lrs1', 'rs1')
    lcrtt('lrs2', 'rs2')
    lindx('lrs2', 'rs2')
    luse('lrs1')
    luse('lrs2')

    aZ_CRM:=Zak_CRM(cDir, cFile)

    //outlog(__FILE__,__LINE__,LEN(aZ_CRM))
    //outlog(__FILE__,__LINE__,aZ_CRM)

    DIRMAKE("crm-log")
    SET DATE FORMAT "yyyy-mm-dd"
    set print to ("crm-log\crm_"+DTOC(DATE())+"T"+CHARREPL(":", TIME(), "-")+".log") ADDI

    for i:=1 to LEN(aZ_CRM)

      vor:=9                //реализация
                            // на склад возврата код
      if (VAL(aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "WareHouseId") ]) > 999;// код склада
        ;//     .or. "_v" $ (aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "CRMWareHouseId") ])
        )
                            // на склад возврата код
        CrmError(aZ_CRM, "НЕ ЗАРЕГИСТРИРОВАН SKL  -" +                               ;
                  aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "WareHouseId") ] + " CRM:"+ ;
                  (aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "CRMWareHouseId") ])     ;
               )

        //loop
        vor:=1              //возврат

      endif

      /*
      ?
      ?aZ_CRM[i,1, 8]  ,"//номер заказа       " //номер заказа
      ?PosSchArr(aBegSchOrder,"CRMOrderNumber")

      ?aZ_CRM[i,1, 5] ,"//дата и время заказа" //дата и время заказа
      ?PosSchArr(aBegSchOrder,"CreateId")

      ?aZ_CRM[i,1, 7] ,"//дата заказа        " //дата заказа
      ?PosSchArr(aBegSchOrder,"CRMOrderDate")

      ?aZ_CRM[i,1, 4] ,"//код компании       " //код компании
      ?PosSchArr(aBegSchOrder,"CompanyId")

      ?aZ_CRM[i,1, 2] ,"//код клиента        " //код клиента
      ?PosSchArr(aBegSchOrder,"AddressId")

      ?aZ_CRM[i,1,12]," //код склада        "  //код склада
      ?PosSchArr(aBegSchOrder,"WareHouseId")

      ?aZ_CRM[i,1,10] ,"//код агента         " //код агента
      ?PosSchArr(aBegSchOrder,"PersonId")

      ?aZ_CRM[i,3, 2,2] ,"//вид оплаты       " //вид оплаты
      ?aZ_CRM[i,3, 1,2] ,"//коментарий       " //коментарий

      */

      ttnr:=i

      //код ТА

      sele s_tag
      if (FIELDPOS("kta19")#0)
        locate for ALLTRIM(kta19)=ALLTRIM(aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "PersonId") ])//код агента
      else
        locate for kod=99999//такого нет 100%
      endif

      if (FOUND())
        ktar:=s_tag->Kod
        //код склада
        Sklr:=s_tag->AgSk
      else
        CrmError(aZ_CRM, "НЕ ЗАРЕГИСТРИРОВАН ТА  - ПРИНЯТ 556")
        CrmError(aZ_CRM, "НЕ ЗАРЕГИСТРИРОВАН SKL - ПРИНЯТ 000")
        ktar:=556
        Sklr:=s_tag->AgSk   //0
      endif

      //код склада
      if (EMPTY(Sklr))
        Sklr:=VAL(aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "WareHouseId") ])//код склада
        CrmError(aZ_CRM, {"НЕ ЗАРЕГИСТРИРОВАН SKL - ПРИНЯТ по WareHouseId ", Sklr})
      endif

      kgpr:=VAL(aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "AddressId") ])//код клиента
      if (EMPTY(kgpr))
        CrmError(aZ_CRM, "НЕ УКАЗАН КОД ГРУЗ.ПОЛ."+                        ;
                  aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "CRMClientId") ]+ ;
                  " KGP - ПРИНЯТ 20034"                                     ;
               )
        kgpr:=20034
      endif

      if (.NOT. (UPPER("/crm_all_skl") $ UPPER(DosParam())))
        if (!cSkl->(check_skl(@Sklr, kgpr)))
          loop
        endif

      endif

      if (ISARRAY(aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "CRMPayKindId") ]) .OR. ;
           VAL(aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "CRMPayKindId") ]) > 10     ;
        )

        CrmError(aZ_CRM, "НЕ УКАЗАН ВИД ОПЛАТЫ - ПРИНЯТ 160")
        kopr:=160

      else

        kopr:=aKop[ VAL(aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "CRMPayKindId") ]), 1 ]

      endif

      /*
      IF ISARRAY(aZ_CRM[i,3, 2,2]) .OR. VAL(aZ_CRM[i,3, 2,2])>10
        CrmError(aZ_CRM, "НЕ УКАЗАН ВИД ОПЛАТЫ - ПРИНЯТ 160")
        kopr:=160
      ELSE
        kopr:=aKop[ VAL(aZ_CRM[i,3, 2,2]), 1 ]
      ENDIF
      */

      kopir:=kopr

      kplr:=VAL(aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "CompanyId") ])//код компании
      if (EMPTY(kplr))
        CrmError(aZ_CRM, "НЕ УКАЗАН КОД "+                                 ;
                  aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "CRMClientId") ]+ ;
                  " ПЛАТ KPL - ПРИНЯТ 20034"                                ;
               )
        kplr:=20034
      endif

      //outlog(__FILE__,__LINE__,kplr,kgpr)

      TimeCrtFrmr:=aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "CreateId") ]//дата и время заказа
      TimeCrtr :=aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "CreateId") ]//дата и время заказа
      DocIDr :=aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "CRMOrderNumber") ]//номер заказа
      Sumr := 0

      if (ISARRAY(aZ_CRM[ i, 3, 1, 2 ]))//коментарий
        Commentr := ""
      else
  #ifdef __CLIP__
          Commentr := translate_charset("utf-8", host_charset(), aZ_CRM[ i, 3, 1, 2 ])//коментарий
  #endif

        if ("ю."$ Commentr)//"ю.1234567 " признак изменения плательщика
          kplr:=VAL(ALLTRIM(SUBSTR(Commentr, AT("ю.", Commentr)+2, 7)))

          if (EMPTY(kplr))

            //возвращаем назад код плательщика
            //kplr:=VAL(aZ_CRM[i,1, PosSchArr(aBegSchOrder,"CompanyId")]) //код компании

            CrmError(aZ_CRM, "НЕ ВЕРНО УКАЗАН КОД в Commentr "+ ;
                      Commentr+                                  ;
                      " ПЛАТ KPL - ПРИНЯТ "+STR(kplr)          ;
                   )
          endif

        endif

        if ("г."$ Commentr)//"г.1234567 " признак изменения грузополучателя
          kgpr:=VAL(ALLTRIM(SUBSTR(Commentr, AT("г.", Commentr)+2, 7)))

          if (EMPTY(kgpr))

            //возвращаем назад код грузополучателя
            //kgpr:=VAL(aZ_CRM[i,1, PosSchArr(aBegSchOrder,"AddressId")]) //код компании

            CrmError(aZ_CRM, "НЕ ВЕРНО УКАЗАН КОД в Commentr "+ ;
                      Commentr+                                  ;
                      " ПЛАТ KGP - ПРИНЯТ "+STR(kgpr)          ;
                   )
          endif

        endif

      endif

      DtRor :=Kpk_DateTime(aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "CreateId") ])//дата и время заказа

      sele lrs1
      netadd()
      netrepl('DtRo', 'DtRor')

      if (at('т=', Commentr) # 0)// задание на забор денег
        netrepl('ztxt', {Commentr})
      else
        netrepl('npv', {Commentr})
      endif

      netrepl('TimeCrtFrm,TimeCrt,DocGUID,Sdv', {TimeCrtFrmr, TimeCrtr, DocIDr, Sumr})

      netrepl('Skl,ttn,vo,kop,kopi,kpl,kgp,kta,ddc,tdc',              ;
               'Sklr,ttnr,vor,kopr,kopir,kplr,kgpr,ktar,date(),time()' ;
            )

      ttncr:=1              // нужны доки на тару? (0,1)
      sele lrs1
      netrepl('ttnp', 'ttncr')

      aLine:=aZ_CRM[ i, 2 ]
      for m:=1 to LEN(aLine)
        //outlog(__FILE__,__LINE__,len(aline[m]),aline[m])
        /*
        ? "  ",aLine[m,7],"код товара"
        ? PosSchArr(aBegSchLine,"WareId")
        ??"  ",CHARREPL(",",ALLTRIM(aLine[m,4]),"."), "количество"
        ? PosSchArr(aBegSchLine,"Quantity")
        */
        if ("CRM" $ aLine[ m, PosSchArr(aBegSchLine, "WareId") ])
          CrmError(aZ_CRM, "НЕ ЗАРЕГИСТРИРОВАН КОД ТОВАРА "+aLine[ m, PosSchArr(aBegSchLine, "WareId") ]+" к-во "+aLine[ m, PosSchArr(aBegSchLine, "Quantity") ])
        else
          mntovr:=VAL(aLine[ m, PosSchArr(aBegSchLine, "WareId") ])
          kvpr:=VAL(CHARREPL(",", ALLTRIM(aLine[ m, PosSchArr(aBegSchLine, "Quantity") ]), "."))
          zenr:=0

          sele lrs2
          netadd()
          netrepl('ttn,mntov,kvp,zen', 'ttnr,mntovr,kvpr,zenr',)
        endif

      next

    next

    set print to

    nuse('lrs1')
    nuse('lrs2')
    nuse('s_tag')
    nuse('cskl')
    return (nil)

  /*****************************************************************
   
   FUNCTION:
   АВТОР..ДАТА..........С. Литовка  05-07-07 * 12:47:24pm
   НАЗНАЧЕНИЕ.........
   ПАРАМЕТРЫ..........
   ВОЗВР. ЗНАЧЕНИЕ....
   ПРИМЕЧАНИЯ.........
   */
  function CrmError(aZ_CRM, cMess)
    if (EMPTY(CRMDocId) .OR. CRMDocId#aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "CRMOrderNumber") ])
      (qout(""),                                                                                                                                                             ;
                           ;//qout(aZ_CRM[i,1, PosSchArr(aBegSchOrder,"CRMOrderDate")]  ,"//дата заказа  " //дата заказа
        qout(aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "CRMOrderNumber") ], "//номер заказа ", aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "CreateId") ], "//дата и время заказа"), ;
        qout(aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "CompanyId") ], "//код компании ", aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "AddressId") ], "//код клиента        "),     ;
        qout(aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "WareHouseId") ], "//код склада   ", aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "PersonId") ], "//код агента         "),    ;
                           ;//qout(aZ_CRM[i,3, 2,2],"//вид оплаты   ", aZ_CRM[i,3, 1,2] ,"//коментарий         "),;
        qout(aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "CRMPayKindId") ], "//вид оплаты   ",                                                                                     ;
              IIF(ISCHAR(aZ_CRM[ i, 3, 1, 2 ]),                                                                                                                              ;
                   translate_charset("utf-8", host_charset(), aZ_CRM[ i, 3, 1, 2 ]),                                                                                          ;
                   aZ_CRM[ i, 3, 1, 2 ]                                                                                                                                         ;
                ), "//коментарий         "                                                                                                                                     ;
           ),                                                                                                                                                                  ;
        qout("")                                                                                                                                                              ;
     )
      CRMDocId:=aZ_CRM[ i, 1, PosSchArr(aBegSchOrder, "CRMOrderNumber") ]
    endif

    qout(cMess)
    return (nil)

  #include <clip-expat.ch>
    //#define XML_PARSE_QOUT

  /*****************************************************************
   
   FUNCTION:
   АВТОР..ДАТА..........С. Литовка  04-30-07 * 12:11:40pm
   НАЗНАЧЕНИЕ.........
   ПАРАМЕТРЫ..........
   ВОЗВР. ЗНАЧЕНИЕ....
   ПРИМЕЧАНИЯ.........
   */
  function Zak_CRM(cDir, cFile)
    public aBegSchOrder
    public aBegSchLine
    public aBegSchOpt
    local parser, aa
    //PRIVATE lBegData, lBegOrder, lZagDataOrder,;
    //aCRMOrder

    lBegData:=lBegOrder:=lZagDataOrder:=.F.
    lLineOrder:=lLineDataOrder:=.F.
    lOrderOption:=lDataOrderOption:=.F.

    lBegSch:=lBegSchOrder:=lBegSchLine:=lBegSchOpt:=.F.
    aBegSchOrder:={}
    aBegSchLine:= {}
    aBegSchOpt:= {}

    aCRM:={}
    aCRMOrder:={}; aCRM_Zag:={}
    aCRMOrderLine:={}; aCRMDataOrderLine:={}
    aCRMOrderOption:={}; aCRMDataOrderOption:={}

    //CRM outlog(__FILE__,__LINE__)
    parser := xml_ParserCreate()

    //? "parser:",parser
    //CRM outlog(__FILE__,__LINE__, parser)

    aa := 0
    xml_SetUserData(parser, @aa)

    xml_SetParamEntityParsing(parser, XML_PARAM_ENTITY_PARSING_NEVER)

    xml_SetCharacterDataHandler(parser, @myfunc())
    xml_SetElementHandler(parser, @myStartElement(), @myEndElement())
    xml_SetCommentHandler(parser, @myComment())
    xml_SetCdataSectionHandler(parser, @myStartCdata(), @myEndCdata())

    buf:=MEMOREAD(cDir+'/'+cFile)
    buf:=MEMOTRAN(buf, "", "")

    xml_Parse(parser, buf, len(buf), fileeof(cDir+'/'+cFile))

    if (xml_GetErrorCode(parser) <> 0)
      ? "Error in XML (" + alltrim(str(xml_GetErrorCode(parser))) + "): " + xml_ErrorString(parser)
      ?? " at line "+alltrim(str(xml_GetCurrentLineNumber(parser)))
      ?? ", column "+alltrim(str(xml_GetCurrentColumnNumber(parser)))
      aCRM:={}

    else
      xml_ParserFree(parser)

      //outlog(__FILE__,__LINE__, aCRM)
      //outlog(__FILE__,__LINE__,aBegSchOrder)

      ADEL(aBegSchLine, 1)
      ASIZE(aBegSchLine, LEN(aBegSchLine)-1)
      //outlog(__FILE__,__LINE__,aBegSchLine)

      ADEL(aBegSchOpt, 1)
      ASIZE(aBegSchOpt, LEN(aBegSchLine)-1)
      //outlog(__FILE__,__LINE__,aBegSchOpt)

      //outlog(__FILE__,__LINE__,PosSchArr(aBegSchOrder,"WareHouseId"))
      //outlog(__FILE__,__LINE__,PosSchArr(aBegSchLine,"WareHouseId"))

    endif

    /*
    file = fopen(filename)
    do while !fileeof(file)
           buf = filegetstr(file, 1024)
       //? "buf=", buf
       xml_Parse(parser, buf, len(buf), fileeof(file))

       if xml_GetErrorCode(parser) <> 0
           ? "Error in XML (" + alltrim(str(xml_GetErrorCode(parser))) + "): " + xml_ErrorString(parser)
           ?? " at line "+alltrim(str(xml_GetCurrentLineNumber(parser)))
           ?? ", column "+alltrim(str(xml_GetCurrentColumnNumber(parser)))
       endif
    enddo

    fclose(file)
      */

    /*
    xml_ParserFree(parser)
    ? ""
    ? "free"
    ? "Processed time:", seconds()-tm, "sec"

    ?
    */
    return (aCRM)

  /***********************************************************
   * myfunc() -->
   *   Параметры :
   *   Возвращает:
   */
  function myfunc(aa, str, len)
  #ifdef XML_PARSE_QOUT
      ?"St_El_v", replicate("&\t", aa), '"'+str+'"'
  #endif

    if (lZagDataOrder .AND. !EMPTY(ALLTRIM(str)))
      AADD(aCRMOrder, str)
    endif

    if (lLineDataOrder .AND. !EMPTY(ALLTRIM(str)))
      AADD(aCRMDataOrderLine, str)
    endif

    if (lDataOrderOption .AND. !EMPTY(ALLTRIM(str)))
      //AADD(aCRMDataOrderOption,str)
      AADD(aCRMDataOrderOption, ;
            str                  ;
                           ;//translate_charset("utf-8",host_charset(),str);
                           ;//translate_charset("cp866",host_charset(),str);
         )
    endif

    return

  /***********************************************************
   * myStartElement() -->
   *   Параметры :
   *   Возвращает:
   */
  function myStartElement(aa, name, arrAttr)

    if (name="s")         //начались данные схемы
      lBegSch:=.T.
    endif

    do case
    case (lBegSch .AND. !lBegSchOrder .AND. !lBegSchLine .AND. !lBegSchOpt .AND. ;
           name="f"                                                               ;
        )
      lBegSchOrder:=.T.
    case (lBegSch .AND. lBegSchOrder .AND. !lBegSchLine .AND. !lBegSchOpt .AND. ;
           name="d"                                                              ;
        )
      lBegSchOrder:=.F.
      lBegSchLine:=.T.

    case (lBegSch .AND. !lBegSchOrder .AND. lBegSchLine .AND. !lBegSchOpt .AND. ;
           name="d"                                                              ;
        )
      lBegSchLine:=.F.
      lBegSchOpt:=.T.
      aa++
    endcase

    IF name="o" //начались данные
      lBegData:=.T.
    ENDIF

    IF lBegData .AND. name="d"//начались данные шапки заявки
      lBegOrder:=.T.
    ENDIF

    IF lBegData .AND. lBegOrder  .AND.  name="f"
      //начались данные шапки заявки и значения
      lZagDataOrder:=.T.
    ENDIF

      //начались данные СТРОК заявки и значения
    IF lBegData .AND. lBegOrder  .AND. lZagDataOrder .AND.  name="d"

      lZagDataOrder:=.F.
      lBegOrder:=.F.

      lLineOrder:=.T.

      //CRM  outlog(__FILE__,__LINE__,aCRMOrder)
      aCRM_Zag:=ACLONE(aCRMOrder)

    ENDIF

    IF lLineOrder .AND. name="r"
      lLineDataOrder:=.T.
    ENDIF

    IF lOrderOption .AND. name="r"
      lZagDataOrder:=.F.
      lDataOrderOption:=.T.
    ENDIF


  #ifdef XML_PARSE_QOUT
      ?"St_El__", replicate("&\t", aa), "<"+name+">"
  #endif
    for i=1 to len(arrAttr)

      if (lBegSchOrder .AND. !EMPTY(arrAttr[ i ]))
        AADD(aBegSchOrder, arrAttr[ i ])
      endif

      if (lBegSchLine .AND. !EMPTY(arrAttr[ i ]))
        AADD(aBegSchLine, arrAttr[ i ])
      endif

      if (lBegSchOpt .AND. !EMPTY(arrAttr[ i ]))
        AADD(aBegSchOpt, arrAttr[ i ])
      endif

      if (lZagDataOrder .AND. !EMPTY(arrAttr[ i ]))
        AADD(aCRMOrder, arrAttr[ i ])
      endif

      if (lLineDataOrder .AND. !EMPTY(arrAttr[ i ]))
        AADD(aCRMDataOrderLine, arrAttr[ i ])
      endif

      if (lDataOrderOption .AND. !EMPTY(arrAttr[ i ]))
        AADD(aCRMDataOrderOption, arrAttr[ i ])
      endif

  #ifdef XML_PARSE_QOUT
        ? replicate("&\t", aa+1), arrAttr[ i ]
  #endif
    next

    aa++
    return

  /***********************************************************
   * myEndElement() -->
   *   Параметры :
   *   Возвращает:
   */
  function myEndElement(aa, name)

    if (name="s")
      lBegSch:=lBegSchOrder:=lBegSchLine:=lBegSchOpt:=.F.
    endif

    if (lLineOrder .AND. name="r")
      //закрыли значения строк товар
      lLineDataOrder:=.F.
      AADD(aCRMOrderLine, aCRMDataOrderLine)

      //CRM  outlog(__FILE__,__LINE__,aCRMDataOrderLine)
      aCRMDataOrderLine:={}

    endif

    if (lLineOrder .AND. name="d")
      //начались итоги
      lLineOrder:=.F.
      lLineDataOrder:=.F.

      lOrderOption:=.T.

      //CRM outlog(__FILE__,__LINE__,aCRMOrderLine)

    else

      if (lOrderOption .AND. name="r")
        //закрыли значения строк товар
        lDataOrderOption:=.F.
        AADD(aCRMOrderOption, aCRMDataOrderOption)

        aCRMDataOrderOption:={}

      endif

      if (lOrderOption .AND. name="d")
        lOrderOption:=.F.
        lDataOrderOption:=.F.

        //CRM outlog(__FILE__,__LINE__,aCRMOrderOption)

        //начнем с начала

        lBegData:=lBegOrder:=lZagDataOrder:=.F.
        lLineOrder:=lLineDataOrder:=.F.
        lOrderOption:=lDataOrderOption:=.F.

        AADD(aCRM, {aCRM_Zag, aCRMOrderLine, aCRMOrderOption})

        aCRMOrder:={}
        aCRMOrderLine:={}
        aCRMDataOrderLine:={}
        aCRMOrderOption:={}
        aCRMDataOrderOption:={}

        lBegData:=.T.
        lBegOrder:=.T.
        //CRM outlog(__FILE__,__LINE__,"NEW!!!!!!!")

      endif

    endif

  #ifdef XML_PARSE_QOUT
      aa--
      ? replicate("&\t", aa), "</"+ name+">"
  #endif
    return

  /***********************************************************
   * myComment() -->
   *   Параметры :
   *   Возвращает:
   */
  function myComment(aa, data)
  #ifdef XML_PARSE_QOUT
      ? replicate("&\t", aa), "/* "+ data+ "*/"
  #endif
    return

  /***********************************************************
   * myStartCdata() -->
   *   Параметры :
   *   Возвращает:
   */
  function myStartCdata(aa)
  #ifdef XML_PARSE_QOUT
      ? replicate("&\t", aa), "<![CDATA["
      aa++
  #endif
    return

  /***********************************************************
   * myEndCdata() -->
   *   Параметры :
   *   Возвращает:
   */
  function myEndCdata(aa)
  #ifdef XML_PARSE_QOUT
      aa--
      ? replicate("&\t", aa), "]]>"
  #endif
    return

#endif

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  10-03-07 * 03:20:59pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
function PosSchArr(aArr, cName)
  return (CEILING(ASCAN(aArr, {| aElem | LOWER(aElem[ 2 ])=LOWER(cName)})/2))

/**************** */
function kpkarch()
  /**************** */
  return (.t.)
#ifdef __CLIP__
    if (!file('lrs1.dbf'))
      return (.t.)
    endif

    if (!file('lrs2.dbf'))
      return (.t.)
    endif

    skpkr=0
    sele setup
    locate for ent=gnEnt
    if (foun())
      if (fieldpos('skpk')#0)
        reclock()
        if (skpk=0)
          repl skpk with 1
        endif

        skpkr=skpk
        netrepl('skpk', 'skpk+1')
      endif

    endif

    if (select('lrs1')=0)
      luse('lrs1')
    endif

    if (select('lrs2')=0)
      luse('lrs2')
    endif

    sele lrs1
    go top
    while (!eof())
      if (kps#0)          // Уже есть
        skip
        loop
      endif

      if (empty(skl))
        skr=228
      else
        skr=skl
      endif

      sele cskl
      if (!netseek('t1', 'skr'))
        exit
      endif

      sklr=skl
      if (skr=241.or.skr=244)// ngMerch_Sk241 //мерч склад
        sele lrs1
        skip
        loop
      endif

      pathr=gcPath_d+alltrim(path)
      netuse('rs1kpk',,, 1)
      netuse('rs2kpk',,, 1)
      sele lrs1
      ttn_r=ttn
      ddcr=ddc
      tdcr=tdc
      ttnr=val(nnz)
      kpsr=kps
      nnzr=str(ttn_r, 6)
      arec:={}
      getrec()
      if (kpsr=0)
        sele rs1kpk
        netadd()
        putrec()
        netrepl('ttn,nnz,kps,skpk,dtmod,tmmod', 'ttnr,nnzr,kpsr,skpkr,ddcr,tdcr')
        sele lrs2
        if (netseek('t1', 'ttn_r'))
          while (ttn=ttn_r)
            arec:={}
            getrec()
            sele rs2kpk
            netadd()
            putrec()
            netrepl('ttn,skpk', 'ttnr,skpkr')
            sele lrs2
            skip
          enddo

        endif

        nuse('rs1kpk')
        nuse('rs2kpk')
      endif

      sele lrs1
      skip
    enddo

#else
#endif
  return (.t.)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  09-08-16 * 01:52:52pm
 НАЗНАЧЕНИЕ......... перевод из формата DD MM.MMMM 2 DD.DDDDDD
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
function DDMM2DDDD(cGpsNE)
  local nPoi, nDD
  nPoi:=AT('.', cGpsNE)
  nDD:=VAL(SUBSTR(cGpsNE, nPoi-2))/60
  return (STR(VAL(LEFT(cGpsNE, nPoi-3))+nDD, 10, 6))


/*****************************************************************
  
  FUNCTION:
  АВТОР..ДАТА..........С. Литовка  04-13-08 * 08:36:44am
  НАЗНАЧЕНИЕ.........
  ПАРАМЕТРЫ..........
  ВОЗВР. ЗНАЧЕНИЕ....
  ПРИМЕЧАНИЯ.........
  */
function Kpk_billa(file)
  local oHtml, oOrder
  local classname

  classname:="lrs1"

  file:="in_order.xml"

  oHtml := _data_parse(file)
  if (!empty(oHtml:error))
    outlog("Parse error", oHtml:error)
    return
  endif

  //outlog(__FILE__,__LINE__,oHtml)

  oOrder := _data_trans(oHtml, classname)

  //outlog(3,__FILE__,__LINE__, ret)
  outlog(3,__FILE__,__LINE__, oOrder["DATE"])
  outlog(3,__FILE__,__LINE__, oOrder["SENDER"])
  outlog(3,__FILE__,__LINE__, oOrder:products)

  for oPosAtttr in oOrder:products
    outlog(3,__FILE__,__LINE__, oPosAtttr)
    outlog(3,__FILE__,__LINE__, oPosAtttr["DESCRIPTION"])
    outlog(3,__FILE__,__LINE__, oPosAtttr["PRODUCT"])
    outlog(3,__FILE__,__LINE__, oPosAtttr["ORDEREDQUANTITY"])

  NEXT



  return (nil)

/***************************** */
static function _data_parse(xmlFile)
  local hFile, oHtml
  local lSet := set(_SET_TRANSLATE_PATH, .f.)

  oHtml := htmlParserNew()
  hFile := fopen(xmlFile, 0)
  set(_SET_TRANSLATE_PATH, lSet)
  if (hFile < 0)
    oHtml:error := [ Error open file: ]+xmlFile+":"+ferrorstr()
    return (oHtml)
  endif

  while (!fileeof(hFile))
    oHtml:put(freadstr(hFile, 20))
  enddo

  fclose(hFile)
  oHtml:end()
  return (oHtml)


static function _data_trans(oHtml)
  local ret := {}
  local lOpenHead:=.F.
  local lOpenLine:=.F.
  local aHead:={}
  local aPosAttr:={}
  local attrName, attrData
  local oOrder, nPos

  nPos:=1
  oOrder:=map()
  //oOrder:head := map()
  oOrder:products := map()

  while (!oHtml:empty())

    oTag:=oHtml:get()
    //outlog(3,__FILE__,__LINE__,oTag)
    //loop

    if (empty(oTag))
      loop
    endif

    oTag:tagName:=lower(alltrim(oTag:tagName))

    if (oTag:tagName == "documentname")
      lOpenHead:=.T.
    endif

    if (oTag:tagName == "position")
      if (lOpenHead)
        AADD(ret, aHead) // добавили шапку
        aProducts:={} // массив для продукции
        oProducts:=map() // Объект для продукции
      endif

      aPosAttr:={}
      oPosAttr:=map()

      lOpenHead:=.F.
      lOpenLine:=.T.
      oTag:=oHtml:get()   // II следующий
      oTag:=oHtml:get()   // III следующий

      loop // нет данных всЕ =
    endif

    If (oTag:tagName == "/position")
      AADD(aProducts,aPosAttr)
      oOrder:products[padl(allt(str(nPos++,3)),3,"0")]:=oPosAttr

      aPosAttr:={}
      oPosAttr:=map()
      loop
    EndIf

    If lOpenHead
      attrName:=oTag:tagName
      oTag:=oHtml:get()   // II следующий
      attrData :=oTag     //знчение
      oTag:=oHtml:get()   // III следующий - закрывающий

      if (attrName = "number")
        attrData := translate_charset("utf-8", host_charset(), attrData)
      endif

      AADD(aHead, {attrName, attrData})

      attrName := upper(attrName)
      oOrder[attrName]:=attrData
      //outlog(3,__FILE__,__LINE__, attrName, attrData)
    EndIf

    If lOpenLine
      attrName:=oTag:tagName

      oTag:=oHtml:get()   // II следующий
      attrData :=oTag     //знчение
      oTag:=oHtml:get()   // III следующий - закрывающий


      If !(left(attrName,1) = "/")
        if (attrName = "description")
          attrData := translate_charset("utf-8", host_charset(), attrData)
        endif
        AADD(aPosAttr, {attrName, attrData})

        attrName := upper(attrName)
        oPosAttr[attrName]:=attrData

        outlog(3,__FILE__,__LINE__, attrName, attrData)
      EndIf

    EndIf

  enddo

  AADD(ret, aProducts)
  /*
  outlog(3,__FILE__,__LINE__, ret)
  outlog(3,__FILE__,__LINE__, oOrder["DATE"])
  outlog(3,__FILE__,__LINE__, oOrder)
  */
  return (oOrder)


/***************************** */
static function _data_trans01(oHtml)
  local oTag
  local attrName, attrData
  local lOpenHead, lGetNext
  local ret := {}

  local CDATA:=""

  lOpenHead:=.F.
  lOpenLine:=.F.
  aHead:={}
  aLineAttr:={}

  while (!oHtml:empty())

    oTag:=oHtml:get()

    //outlog(__FILE__,__LINE__,oTag)

    if (empty(oTag))
      loop
    endif

    if (empty(oTag))
      CDATA += "&\n"
      loop
    endif

    if (valtype(oTag)=="C")
      CDATA += oTag
      loop
    endif

    if (valtype(oTag)=="O" .and. oTag:classname=="HTML_TAG")
    else
    //loop
    endif

    if (oTag:tagname=="!" .or. left(oTag:tagname, 1) == "?")
      loop
    endif

    if (oTag:tagname=="ROOT" .OR. oTag:tagname=="ORDER")
      loop
    endif

    oTag:tagName:=lower(alltrim(oTag:tagName))

    if (oTag:tagName="documentname")
      lOpenHead:=.T.
    endif

    if (oTag:tagName="position")
      if (lOpenHead)
        AADD(ret, aHead)
      endif

      lOpenHead:=.F.
      lOpenLine:=.T.
    endif

    if (lOpenHead)
      attrName:=oTag:tagName

      oTag:=oHtml:get()   // II следующий
      attrData :=oTag     //знчение
      oTag:=oHtml:get()   // III следующий

      AADD(aHead, {attrName, attrData})
      outlog(__FILE__,__LINE__, attrName, attrData)

    endif

    if (lOpenLine)
      attrName:=oTag:tagName

      oTag:=oHtml:get()   // II следующий
      attrData :=oTag     //знчение
      oTag:=oHtml:get()   // III следующий

      if (attrName = "position")
        loop
      endif

      if (attrName = "/position")
        AADD(ret, aLineAttr)
        outlog(__FILE__,__LINE__,"=======/position=========")
        loop
      endif

      if ("characteristic" $ attrName)
        loop
      endif

      if (attrName = "description")
        attrData := translate_charset("utf-8", host_charset(), attrData)
      endif

      AADD(aLineAttr, {attrName, attrData})
      outlog(__FILE__,__LINE__, attrName, attrData)

    endif
      outlog(__FILE__,__LINE__, ret)
    if (attrName = "/head")
      return ret
    endif

    loop

    if (oTag:tagName="position")
      outlog(__FILE__,__LINE__, aHead)
      quit
      //шапка документа закончилась
      lOpenHead:=.F.
      AADD(ret, aHead)
      oTag:=oHtml:get()   // I
      while (!oHtml:empty())

        attrName:=oTag:tagName
        oTag:=oHtml:get() // II следующий
        attrData :=oTag   //значение
        oTag:=oHtml:get() // III
        AADD(aLineAttr, {attrName, attrData})

        oTag:=oHtml:get() // I
        if (oTag:tagName="/position")
          AADD(ret, {aLineAttr})
          outlog(__FILE__,__LINE__, aLineAttr)
          aLineAttr:={}
        endif

      enddo

    endif

    //outlog(__FILE__,__LINE__,oTag:tagName)
    exit
    loop

    if (closed .and. oTag:tagname == classname)
      count ++
      closed := .f.
      oData := map()
      loop
    endif

    if (!closed .and. oTag:tagname == "/"+classname)
      aadd(ret, oData)
      closed := .t.
      loop
    endif

    if (closed2 .and. !(left(oTag:tagname, 1)=="/"))
      tagname := upper(oTag:tagname)
      closed2 := .f.
      cData := ""
      oData[ tagname ] := map()
      //? tagname,count
      oMeta := oData[ tagname ]
    endif

    if (!closed2 .and. upper(oTag:tagname)=="/"+tagname)
      //? oTag:tagname,tagname,closed2,cData
      //? tagname,count
      closed2 := .t.
      oData[ tagname ]:cData := cData
    //? oTag:tagname, tagname, oData
    endif

    for i in oTag:fields KEYS
      attrName := oTag:hashname(i)
      attrData := oTag:fields[ i ]
      oMeta[ attrName ] := attrData
    next

    loop
    for i=1 to len(oTag:fieldsOrder)//in oTag:fields KEYS
      attrName := oTag:fieldsOrder[ i ]//oTag:hashname(i)
      attrData := oTag:fields[ attrName ]
      aadd(oMeta, {attrName, attrData})
    next

  enddo

  return (ret)
