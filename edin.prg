#include 'directry.ch'
#include 'common.ch'

#translate  NTRIM(< v1 >) => LTRIM(STR(< v1 >))

FUNCTION EdinOrders(cDosParam, cPath_Order)
  LOCAL lerase:=.T.
  LOCAL aFiles, aFile, aFiles01
  LOCAL cBar, j
  LOCAL aMessErr, cMessErr
  DEFAULT cPath_Order TO gcPath_ew+"edin\order\inbox"

  aMessErr:={}

  IF !lerase_lrs(lerase)
    outlog(3,__FILE__,__LINE__,'//� ᫥���騩 ࠧ')
    RETURN
  ENDIF

  luse('lphtdoc')
  luse('lrs1')
  luse('lrs2')

  netuse('cskl')
  netuse('kgp')
  netuse('kln')
  netuse('etm')
  netuse('s_tag')
  netuse('stagtm')
  netuse('stagm')
  netuse('ctov')


  // �⥭� 䠩��� �� ��⠫���

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
    // �� �窠?
    ktar := AgTm(nil, kplr, kgpr)
    outlog(3,__FILE__,__LINE__,'  ktar',ktar)

    DtRor := CTOD(oOrder["DELIVERYDATE"],'YYYY-MM-DD') //��� ���⠢��
    DocIDr    := oOrder['NUMBER']
    nVal:=0 // ���䨪��

    ttncr := 1 // �㦭� ���� �� ���? (0,1)
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

    //���� ������ 4 ���䨪�⮢
    serr:=lrs1->ser
    serr:=STUFF(serr,2,1,IIF(nVal=0," ","1"))
    sele lrs1
    netrepl('ser',{serr})

    netrepl('RndSdv',{2}) // ���㣫����
    netrepl('spd',{1}) //�ਧ��� ��ࠡ�⪨

    // ⮢�ୠ� ����
    mkeepr := 0
    for oPosAtttr in oOrder:products
      //outlog(__FILE__,__LINE__,"oPosAtttr", oPosAtttr )
      /*
      If !("WPRODUCTIDBUYER" $ oPosAtttr)
          outlog(3,__FILE__,__LINE__,' !("WPRODUCTIDBUYER" $ oPosAtttr)')
      EndIf
      */

      MnTovr:=0

      If "PRODUCTIDBUYER" $ oPosAtttr
        MnTovr := val(oPosAtttr["PRODUCTIDBUYER"])
        MnTovr := getfield('t1','MnTovr','ctov','MnTovT')
      EndIf
      If Empty(MnTovr)
        cBar := oPosAtttr["PRODUCT"]
        Barr := val(cBar)
        If len(cBar) > 7 //��
          MnTovr := getfield('t4','Barr','ctov','MnTovT')
          If Empty(MnTovr)
            MnTovr :=getfield('t4','Barr','ctov','MnTov')
          EndIf
        Else
          MnTovr := Barr
        EndIf

      EndIf


      kvpr:=val(oPosAtttr["ORDEREDQUANTITY"])
                          // <ORDEREDQUANTITY>
      zenr:=0

      sele lrs2
      netadd()
      netrepl('ttn,mntov,kvp,zen',{ttnr,mntovr,kvpr,zenr},)

      If Empty(MnTovr)

        len_aMessErr_eq_1(oOrder, @aMessErr)

        AADD(aMessErr,;
        "�த��� �� ��ࠡ�⠭�: ��� ���媮��(��) � �ࠢ�筨��"+CRLF)
        AADD(aMessErr,;
        CRLF;
        +"���N:"+PADL(oPosAtttr["POSITIONNUMBER"],3);
        +" ��:"+oPosAtttr["PRODUCT"];
        +" �-��:"+oPosAtttr["ORDEREDQUANTITY"]+CRLF)
        AADD(aMessErr,space(9)+oPosAtttr["DESCRIPTION"]+CRLF)

        netrepl('MnTovr,svp',{-1, val(oPosAtttr["PRODUCT"])},)
        netdel()
        outlog(3,__FILE__,__LINE__,'  DELE 4 Barr',Barr)
      else
        If Empty(mkeepr)
          mkeepr:=getfield('t1','MnTovr','ctov','mkeep')
        EndIf

      EndIf


    next

    If !Empty(mkeepr) // ���⠭ ��� ���� ⮢��

      //kta_mkeepr:=AgTmMKeep(kplr, kgpr, mkeepr)
      //AgTmMKeep(kplr, kgpr, mkeepr)

      aListKta := {0}
      nTMesto := 0
      ktar=agtm(nil, kplr, kgpr, @aListKta, @nTMesto)
      kta_mkeepr:=0

      outlog(3,__FILE__,__LINE__, "mkeepr nTMesto", mkeepr, nTMesto)
      outlog(3,__FILE__,__LINE__, "aListKta", aListKta)
      If len(aListKta) = 1 // ��� ��
        // ��祣� �� ������ � 㦥 �ய�ᠭ (࠭�� ��諨)
      else
        for j:=2 to len(aListKta)
          ktar := aListKta[j]
          uvolr := getfield('t1','ktar','s_tag','uvol')
          If uvolr = 0 // �����

            If !Empty(getfield('t1','ktar,mkeepr','sTagM','kta'))
              //��諨 �� � �������
              kta_mkeepr := ktar
              exit
            Else
              //���� �� �㯥�������� KtaSr
              ktaSr := getfield('t1','ktar','s_tag','KtaS')
              If !Empty(getfield('t1','ktaSr,mkeepr','sTagM','Kta'))
                kta_mkeepr := ktar
                exit
              EndIf
            EndIf

          EndIf
        next j
        outlog(3,__FILE__,__LINE__,'  kta_mkeepr',kta_mkeepr, len(aMessErr))
        If Empty(kta_mkeepr) // �� ��諨 �ਢ離� �� � �������
          len_aMessErr_eq_1(oOrder, @aMessErr)
          AADD(aMessErr,;
          "��� ⮢�஢ � ��મ��ঠ⥫��:"+ allt(str(mkeepr));
           + " ���஢� ����� (��) - �� ������"+CRLF)
        EndIf
      EndIf

    EndIf

    If len(aMessErr) > 1
      cMessErr := ""
      AEVAL(aMessErr, {|cElem|cMessErr += cElem})
      sele lrs1
      netrepl("mess01", {cMessErr})
      //repl mess01 with cMessErr
    EndIf
    sele lrs1
    netrepl('spd',{0}) //�ਧ��� ��ࠡ�⪨
    If !Empty(kta_mkeepr) // �� ��諨 �ਢ離� �� � �������
      outlog(3,__FILE__,__LINE__,'  kta_mkeepr',kta_mkeepr)
      netrepl('kta',{kta_mkeepr}) //�ਧ��� ��ࠡ�⪨
    EndIf

  next

  close ('lphtdoc')
  close ('lrs1')
  close ('lrs2')
  nuse()

  RETURN (NIL)


/*****************************************************************
  
  FUNCTION:
  �����..����..........�. ��⮢��  02-27-20 04:20pm
  ����������.........
  ���������..........
  �����. ��������....
  ����������.........
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

    // ⨯ ���㬥��
    If oTag:tagName = "?xml"

      while (!oHtml:empty())
        oTag:=oHtml:get() //᫥���騩
        If valtype(oTag)=="O"
          exit
        EndIf
      enddo

      AADD(aHead, {"TYPEDOC", oTag:tagName})
      attrName := upper("TYPEDOC")
      oOrder[attrName] := oTag:tagName
    EndIf

    if ("action" == oTag:tagName .or. "/action" == oTag:tagName) //�� �㦥� ⥣
      loop
    endif
    if ("order" == oTag:tagName .or. "/order" == oTag:tagName) //�� �㦥� ⥣
      loop
    endif
    if ("head" == oTag:tagName .or. "/head" == oTag:tagName) //�� �㦥� ⥣
      loop
    endif
    if ("characteristic" == oTag:tagName .or. "/characteristic" == oTag:tagName ) //�� �㦥� ⥣
      loop
    endif

    if (oTag:tagName == "number") //"documentname")
      lOpenHead:=.T.
    endif

    if (oTag:tagName == "position")
      if (lOpenHead)
        AADD(ret, aHead) // �������� 蠯��
        aProducts:={} // ���ᨢ ��� �த�樨
        oProducts:=map() // ��ꥪ� ��� �த�樨
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

      if (attrName = "head") //�� �㦥� ⥣
        loop
      endif

      oTag:=oHtml:get()   // II ᫥���騩
      attrData :=oTag     //��祭��

      // �஡������ ���� �� ������ ����뢠�騩 ⥣
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
      If Right(attrName,1)="/" //⨯� <atrr/> - ��� ������
        loop
      EndIf

      oTag:=oHtml:get()   // II ᫥���騩
      If valtype(oTag)=="O"
        loop
      EndIf
      attrData :=oTag     //��祭��


      // �஡������ ���� �� ������ ����뢠�騩 ⥣
      SkipWhileNotTagClose(@oHtml,@oTag)

      if (attrName = "description")
        attrData := translate_charset("utf-8", host_charset(), attrData)
        //attrData:=STRTRAN(attrData, '�', chr(247))
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
 �����..����..........�. ��⮢��  02-27-20 * 06:11:43pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
static FUNCTION SkipWhileNotTagClose(oHtml,oTag)
  LOCAL attrName4Skip
  Do While !oHtml:empty() //.t.
    oTag:=oHtml:get()
    //outlog(__FILE__,__LINE__,oTag)
    if (empty(oTag))
      loop
    endif
    If Right(oTag,1)="/" //⨯� <atrr/> - ��� ������
      loop
    EndIf
    attrName4Skip:=oTag:tagName
    if left(attrName4Skip,1) = "/" //  ᫥���騩 - ����뢠�騩
      exit
    endif
  EndDo
  RETURN ( NIL )

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  02-27-20 * 08:22:44pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
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

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  01-14-21 * 03:43:41pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
STATIC FUNCTION len_aMessErr_eq_1(oOrder, aMessErr)
  If len(aMessErr) = 1
      AADD(aMessErr,;
      "��� �� " + oOrder["DATE"] + " #" + allt(oOrder['NUMBER']) + CRLF)
      AADD(aMessErr,;
      "��㧮�����⥫�: "+ allt(getfield('t1','kgpr','kln','nkl')) + CRLF)
      AADD(aMessErr,;
      "���⥫�騪     : "+ allt(getfield('t1','kplr','kln','nkl')) + CRLF + CRLF)
  EndIf
  RETURN ( NIL )
