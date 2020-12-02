#include 'directry.ch'
#include 'common.ch'

#translate  NTRIM(< v1 >) => LTRIM(STR(< v1 >))

FUNCTION EdinOrders(cDosParam, cPath_Order)
  LOCAL lerase:=.T.
  LOCAL aFiles, aFile, aFiles01
  LOCAL aMessErr, cMessErr
  DEFAULT cPath_Order TO gcPath_ew+"edin\order\inbox"

  aMessErr:={}

  IF !lerase_lrs(lerase)
    outlog(3,__FILE__,__LINE__,'//в следующий раз')
    RETURN
  ENDIF

  luse('lphtdoc')
  luse('lrs1')
  luse('lrs2')

  netuse('cskl')
  netuse('kgp')
  netuse('kln')
  netuse('etm')
  netuse('stagtm')
  netuse('ctov')


  // чтени файлов из каталога

  aFiles01:=Directory(cPath_Order+'\'+'*.xml')
  aFiles := ASort(aFiles01,,,{|x, y| x[1] < y[1]})

  for i:=1 to LEN(aFiles) //aFile in aFiles
    aFile := aFiles[i]
    If  "retann" $ aFile[1] .or. aFile[3] < STOD("20200305") ;
       .or. "desadv" $ aFile[1]
      loop
    EndIf

    outlog(3,__FILE__,__LINE__,aFile)
    oOrder:=EdinData(cPath_Order+'\' + aFile[1])


    If CTOD(oOrder["DATE"],'YYYY-MM-DD') < STOD("20200308")
      loop
    EndIf


    edinAttr := allt(oOrder["TYPEDOC"])
    If edinAttr = "RETANN"
      outlog(3,__FILE__,__LINE__,' ',edinAttr)
    EndIf



    aMessErr:={}
    AADD(aMessErr, CRLF)

    edinAttr := allt(oOrder["BUYER"])
    kplr := gln2kkl(edinAttr)
    If kplr = 0
      outlog(3,__FILE__,__LINE__,'  ','"kplr":0 ','"BUYER:"',edinAttr)
    EndIf

    edinAttr := allt(oOrder["DELIVERYPLACE"])
    kgpr := gln2kkl(edinAttr)
    If kgpr = 0
      outlog(3,__FILE__,__LINE__,'  ','"kgpr":0 ','"DELIVERYPLACE:"',edinAttr)
    EndIf

    If kplr = 0 .or. kgpr = 0
      loop
    EndIf


    Sklr   := 888
    IF .NOT. (UPPER("/all_skl") $ UPPER(cDosParam))
      IF !cSkl->(check_skl(@Sklr,kgpr))
        LOOP
      ENDIF
    ELSE
      cSkl->(check_skl(@Sklr,kgpr))
    ENDIF
    outlog(3,__FILE__,__LINE__,'  Sklr',Sklr)

    vor:=9
    kopr:=160
    kopir:=kopr
    // ТА точка?
    ktar=agtm(nil, kplr, kgpr)
    outlog(3,__FILE__,__LINE__,'  ktar',ktar)

    DtRor := CTOD(oOrder["DELIVERYDATE"],'YYYY-MM-DD') //дата доставки
    DocIDr    := oOrder['NUMBER']
    nVal:=0 // сертификат

    ttncr := 1 // нужны доки на тару? (0,1)
    SkVzr := Sklr

    TimeCrtFrmr:= oOrder["DATE"]+"T"+"00:00:00"
    TimeCrtr  := oOrder["DATE"]+"T"+"00:00:00"
    Commentr  := ""
    Sumr:=0



    lrs1->(DBGoBottom())
    ttnr:=lrs1->ttn
    ttnr:=ttnr+1

    sele lrs1
    netadd()
    netrepl('DtRo',{DtRor})
    netrepl('DeviceGuId',{aFile[1]})

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

    //вторая позиция 4 сертификатов
    serr:=lrs1->ser
    serr:=STUFF(serr,2,1,IIF(nVal=0," ","1"))
    sele lrs1
    netrepl('ser',{serr})

    netrepl('RndSdv',{2}) // округление
    netrepl('spd',{1}) //признак обработки

    for oPosAtttr in oOrder:products
      //outlog(__FILE__,__LINE__,"oPosAtttr", oPosAtttr )
      Barr:=val(oPosAtttr["PRODUCT"])
      MnTovr:=getfield('t4','Barr','ctov','MnTovT')
      If Empty(MnTovr)
        MnTovr:=getfield('t4','Barr','ctov','MnTov')
      EndIf

      kvpr:=val(oPosAtttr["ORDEREDQUANTITY"])
                          // <ORDEREDQUANTITY>
      zenr:=0

      sele lrs2
      netadd()
      netrepl('ttn,mntov,kvp,zen',{ttnr,mntovr,kvpr,zenr},)

      If Empty(MnTovr)
        If len(aMessErr) = 1
           AADD(aMessErr,;
           "Заявка от " + oOrder["DATE"] + " #" + allt(oOrder['NUMBER']) + CRLF)
           AADD(aMessErr,;
           "Грузополучатель: "+ allt(getfield('t1','kgpr','kln','nkl')) + CRLF)
           AADD(aMessErr,;
           "Плательщик     : "+ allt(getfield('t1','kplr','kln','nkl')) + CRLF + CRLF)
           AADD(aMessErr,;
           "Продукция не обработана: нет штрихкода(ШК) в справочнике"+CRLF)
        EndIf
        AADD(aMessErr,;
        CRLF;
        +"ПозN:"+PADL(oPosAtttr["POSITIONNUMBER"],3);
        +" ШК:"+oPosAtttr["PRODUCT"];
        +" К-во:"+oPosAtttr["ORDEREDQUANTITY"]+CRLF)
        AADD(aMessErr,space(9)+oPosAtttr["DESCRIPTION"]+CRLF)

        netrepl('MnTovr,svp',{-1, val(oPosAtttr["PRODUCT"])},)
        netdel()
        outlog(3,__FILE__,__LINE__,'  DELE 4 Barr',Barr)

      EndIf


    next

    If len(aMessErr) > 1
      cMessErr := ""
      AEVAL(aMessErr, {|cElem|cMessErr += cElem})
      sele lrs1
      netrepl("mess01", {cMessErr})
      //repl mess01 with cMessErr
    EndIf
    sele lrs1
    netrepl('spd',{0}) //признак обработки

  next

  close ('lphtdoc')
  close ('lrs1')
  close ('lrs2')
  nuse()

  RETURN (NIL)


/*****************************************************************
  
  FUNCTION:
  АВТОР..ДАТА..........С. Литовка  02-27-20 04:20pm
  НАЗНАЧЕНИЕ.........
  ПАРАМЕТРЫ..........
  ВОЗВР. ЗНАЧЕНИЕ....
  ПРИМЕЧАНИЯ.........
  */
static function EdinData(file)
  local oHtml, oOrder
  local classname
  DEFAULT file TO "in_order.xml"

  classname:="lrs1"

  oHtml := _data_parse(file)
  if (!empty(oHtml:error))
    outlog("Parse error", oHtml:error)
    return
  endif

  //outlog(__FILE__,__LINE__,oHtml)

  oOrder := _data_trans(oHtml, classname)

  //outlog(4,__FILE__,__LINE__, ret)
  /*
  outlog(4,__FILE__,__LINE__, oOrder["DATE"])
  outlog(4,__FILE__,__LINE__, oOrder["SENDER"])
  outlog(4,__FILE__,__LINE__, oOrder:products)

  for oPosAtttr in oOrder:products
    outlog(4,__FILE__,__LINE__, oPosAtttr)
    outlog(4,__FILE__,__LINE__, oPosAtttr["DESCRIPTION"])
    outlog(4,__FILE__,__LINE__, oPosAtttr["PRODUCT"])
    outlog(4,__FILE__,__LINE__, oPosAtttr["ORDEREDQUANTITY"])
  NEXT
  */
  return (oOrder)

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
  local attrName, attrData, attrName4Skip
  local oOrder, nPos

  nPos:=1
  oOrder:=map()
  //oOrder:head := map()
  oOrder:products := map()

  while (!oHtml:empty())

    oTag:=oHtml:get()
    outlog(4,__FILE__,__LINE__,oTag)
    //loop

    if (empty(oTag))
      loop
    endif

    oTag:tagName:=lower(alltrim(oTag:tagName))

    // тип документа
    If oTag:tagName = "?xml"

      while (!oHtml:empty())
        oTag:=oHtml:get() //следующий
        If valtype(oTag)=="O"
          exit
        EndIf
      enddo

      AADD(aHead, {"TYPEDOC", oTag:tagName})
      attrName := upper("TYPEDOC")
      oOrder[attrName] := oTag:tagName
    EndIf

    if ("action" == oTag:tagName .or. "/action" == oTag:tagName) //не нужен тег
      loop
    endif
    if ("order" == oTag:tagName .or. "/order" == oTag:tagName) //не нужен тег
      loop
    endif
    if ("head" == oTag:tagName .or. "/head" == oTag:tagName) //не нужен тег
      loop
    endif
    if ("characteristic" == oTag:tagName .or. "/characteristic" == oTag:tagName ) //не нужен тег
      loop
    endif

    if (oTag:tagName == "number") //"documentname")
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

      loop
    endif

    If (oTag:tagName == "/position")
      AADD(aProducts, aPosAttr)
      oOrder:products[padl(allt(str(nPos++,3)),3,"0")]:=oPosAttr

      aPosAttr:={}
      oPosAttr:=map()
      loop
    EndIf

    If lOpenHead

      attrName:=oTag:tagName

      if (attrName = "head") //не нужен тег
        loop
      endif

      oTag:=oHtml:get()   // II следующий
      attrData :=oTag     //знчение

      // пробежимся пока не найдем закрывающий тег
      SkipWhileNotTagClose(@oHtml)

      if (attrName = "number")
        attrData := translate_charset("utf-8", host_charset(), attrData)

      endif

      AADD(aHead, {attrName, attrData})

      attrName := upper(attrName)
      oOrder[attrName]:=attrData
      outlog(4,__FILE__,__LINE__, attrName, attrData)
    EndIf

    If lOpenLine
      attrName:=oTag:tagName
      If Right(attrName,1)="/" //типа <atrr/> - нет данных
        loop
      EndIf

      oTag:=oHtml:get()   // II следующий
      If valtype(oTag)=="O"
        loop
      EndIf
      attrData :=oTag     //знчение


      // пробежимся пока не найдем закрывающий тег
      SkipWhileNotTagClose(@oHtml,@oTag)

      if (attrName = "description")
        attrData := translate_charset("utf-8", host_charset(), attrData)
        //attrData:=STRTRAN(attrData, 'ж', chr(247))
        attrData:=STRTRAN(attrData, chr(166), "i")
      endif
      AADD(aPosAttr, {attrName, attrData})

      attrName := upper(attrName)
      oPosAttr[attrName]:=attrData

      outlog(4,__FILE__,__LINE__, attrName, attrData)

    EndIf

  enddo

  outlog(4,__FILE__,__LINE__, aHead)
  AADD(ret, aProducts)
  /*
  outlog(4,__FILE__,__LINE__, ret)
  outlog(4,__FILE__,__LINE__, oOrder["DATE"])
  outlog(4,__FILE__,__LINE__, oOrder)
  */
  return (oOrder)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  02-27-20 * 06:11:43pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
static FUNCTION SkipWhileNotTagClose(oHtml,oTag)
  LOCAL attrName4Skip
  Do While !oHtml:empty() //.t.
    oTag:=oHtml:get()
    //outlog(__FILE__,__LINE__,oTag)
    if (empty(oTag))
      loop
    endif
    If Right(oTag,1)="/" //типа <atrr/> - нет данных
      loop
    EndIf
    attrName4Skip:=oTag:tagName
    if left(attrName4Skip,1) = "/" //  следующий - закрывающий
      exit
    endif
  EndDo
  RETURN ( NIL )

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  02-27-20 * 08:22:44pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
static Function gln2kkl(_edinAttr)
  local kplr
  local oErrBlk:=ERRORBLOCK({|x|Break(x)})
  Private edinAttr:=allt(_edinAttr)

  Begin Sequence
    kplr := getfield('t6','edinAttr','kln','kkl')
  Recover Using error
    sele kln
    Locate  For edinAttr == allt(ns2)
    outlog(__FILE__,__LINE__,edinAttr,found())
    kplr := kkl
  End Sequence
  ERRORBLOCK(oErrBlk)

  Return ( kplr )
