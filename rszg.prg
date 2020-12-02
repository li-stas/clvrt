#include 'common.ch'

STATIC CrmDocId

FUNCTION Xml2Rs1(cDir,cFile,aKop,n_Skl,lerase)
  LOCAL cAID, cVal, nVal, kta_agsk, nPos_AKop
  LOCAL aPriceType2Kop, nPriceType
  DEFAULT lerase TO .T.


  aPriceType2Kop:=PriceType2Kop("kop") //152


    // ����㧪� �த�� (���)

  if select('lrs1')#0
     sele lrs1
     use
  endif
  if select('lrs2')#0
     sele lrs2
     use
  endif

  If lerase
    erase lrs1.dbf
    erase lrs1.cdx
    erase lrs2.dbf
    erase lrs2.cdx
    lcrtt('lrs1','rs1')
    lindx('lrs1','rs1')
    lcrtt('lrs2','rs2')
    lindx('lrs2','rs2')
  EndIf


  luse('lrs1')
  luse('lrs2')
  cDelim=CHR(13) + CHR(10)

  hzvr:=fopen(cDir+'/'+cFile)

  store 0 to pragr,prDocr
  ttnr=0
  do while !feof(hzvr)
     aaa=FReadLn(hzvr, 1,600, cDelim)
      do case
      case subs(aaa,1,10)='<AgentPlus'
        //��� ��
            pragr=1

            kta_agsk:=ID_Elem_Read_Num('AgentID',aaa,'B')
            //kta_agsk:=ALLTRIM(STR(kta_agsk)) //�� ���� ��
            kta_agsk:=PADL(LTRIM(STR(kta_agsk,6)), 6, "0")

            ktar:=VAL(LEFT(kta_agsk,3)) //�� ���� ��
            n_Skl:=VAL(RIGHT(kta_agsk,3)) //228 �� ��᫥���� �����
            IF empty(ktar) .or. empty(n_Skl)
            outlog(__FILE__,__LINE__,"!!ERROR!! empty(ktar)",cDir,cFile,n_Skl,lerase)
            ENDIF

      case subs(aaa,1,6)='<Query' .AND. !EMPTY(s_tag->(FIELDPOS("Ref_Price")))
        nQTyper:=VAL(Elem_Read('QType',aaa))
        IF "/PARAM" $ UPPER(DosParam())
          DO CASE
          CASE nQTyper = 1 //1 �������� ���⪨
            IF STR(s_tag->Ref_Price,1) $ "7,8" .AND. s_tag->Dt_Price = DATE()
            ELSE
              s_tag->(netrepl("Ref_Price",{1}))
            ENDIF

          CASE nQTyper = 2 //2 �������� �����������
            s_tag->(netrepl("Doc_Debt",{1}))

          CASE nQTyper = 3 //3 �������� ����� �த��
            s_tag->(netrepl("Ref_Sales",{1}))

          CASE nQTyper = 4 //4 �������� ��������
            IF STR(s_tag->Ref_Routes,1) $ "7,8" .AND. s_tag->Dt_Routes = DATE()
            ELSE
              s_tag->(netrepl("Ref_Routes",{1}))
            ENDIF
          ENDCASE
        ENDIF
      case subs(aaa,1,10)='</AgentPlus'
        pragr=0
        prDocr=0
        prOrder=0
      case subs(aaa,1,4)='<Doc'
        DocType_Ok:=.F.
        prDocr=1
        DO CASE
        CASE subs(aaa,15,5)='Merch'
          DocType_Ok:=.T.
          Sklr:=ngMerch_Sk241
          kopr:=160
          kopir:=kopr

        CASE subs(aaa,15,5)='Order'
          DocType_Ok:=IIF(VAL(Elem_Read('DocState',aaa))=1,;//�஢����?
          .T.,;//ࠡ�⠥� �����
          .F.;// �������� ���� �஢����
        )

          Sklr:=VAL(RIGHT(kta_agsk,3)) //228

          //��� ����樨
          colr=at('PmntType',aaa)
          ckopr=subs(aaa,colr+len('PmntType')+2,3)
          kopr=val(ckopr)
          IF kopr<=32
            //�.�. ���� ���祭�� � 3-�� �����
            nPos_AKop:=ASCAN(aKop,{|aElem| aElem[3]= kopr })
            IF EMPTY(nPos_AKop)
  //                   outlog(__FILE__,__LINE__,"�� ������ ��� ����樨, �ਭ�� 169",kopr,nPos_AKop,aKop)
              kopr:=169
            ELSE
              kopr:=aKop[nPos_AKop,1]
            ENDIF
            /*
            kopr:=aKop[kopr,1]
            */
          ENDIF


        nPriceType:=VAL(Elem_Read('PriceType',aaa))
        IF nPriceType = 0
          nPriceType:=1
        ENDIF
        #ifdef __CLIP__
  //              outlog(__FILE__,__LINE__,nPriceType)
        #endif
        kopir:=IIF(nPriceType = 1,;//�᭮���� 業�
        kopr,;
        aPriceType2Kop[nPriceType];
      )
        #ifdef __CLIP__
  //              outlog(__FILE__,__LINE__,nPriceType,kopir,aPriceType2Kop)
        #endif

        ENDCASE

        if DocType_Ok

          kplr:=ID_Elem_Read_Num('ClientID',aaa,'C')

          kgpr:=ID_Elem_Read_Num('TPointID',aaa,'C')

          IF EMPTY(kplr) .OR. EMPTY(kgpr)
            DocType_Ok:=.F. //�������� ����� ���⠢�� ४������
          ENDIF

        endif

        if DocType_Ok

          prOrder:=1
          TimeCrtFrmr:=Elem_Read('TimeCrtForm',aaa)
          TimeCrtr:=Elem_Read('TimeCrt',aaa)
          DocIDr:=Elem_Read('DocID',aaa)
          Sumr:=VAL(Elem_Read('Sum',aaa))
          Commentr:=Elem_Read('Comment',aaa)
          #ifdef __CLIP__
              Commentr := translate_charset("cp1251",host_charset(),Commentr)
          #endif

          DtRor:=Kpk_DateTime(Elem_Read('TimeDlv',aaa))

          sele lrs1
          DBGoBottom()
          ttnr:=lrs1->ttn
          ttnr=ttnr+1
          netadd()

          netrepl('DtRo',{DtRor})

          if at('�=',Commentr) # 0 // ������� �� ����� �����
            netrepl('ztxt',{Commentr})
          else
            netrepl('npv',{Commentr})
          endif
          netrepl('TimeCrtFrm,TimeCrt,DocGUID,Sdv',{TimeCrtFrmr,TimeCrtr,DocIDr,Sumr})

          netrepl('Skl,ttn,vo,kop,kopi,kpl,kgp,kta,ddc,tdc',;
                  {Sklr,ttnr,9,kopr,kopir,kplr,kgpr,ktar,date(),time()})

          netrepl('spd',{1}) //�ਧ��� ��ࠡ�⪨ cAID="REPORT"
          // ���� ������ ��९�᢮���� � 0 - �� ������ ����⠭

        else
          prOrder=0
        endif
      case subs(aaa,1,5)='</Doc'
        sele lrs1
        netrepl('spd',{0}) //�ਧ��� ��ࠡ�⪨ cAID="REPORT"
        prDocr=0
        if prOrder=1
          prOrder=0
          //ttnr=ttnr+1
        endif
      case subs(aaa,1,5)='<Attr'
        IF DocType_Ok // ��ࠡ��뢠�� �᫨ ���㬥�� !!�஢����!! DocState',aaa))=1
          cAID:=Elem_Read('AID',aaa)
          DO CASE
          CASE cAID="DOSTAVKA"

            cVal:=Elem_Read('Val',aaa)
            nVal:=VAL(cVal)

            DO CASE
            CASE nVal=1 //KPK_ᠬ��뢮�
              pvtr:=1

            CASE nVal=2 //KPK_�������� ���⠢��
              pvtr:=0 //��஧����

            CASE nVal=3 //KPK_��筠� ���⠢��
              pvtr:=0 //��஧����

            ENDCASE
            sele lrs1
            netrepl('pvt',{pvtr})

          CASE cAID="TRASP"
            cVal:=Elem_Read('Val',aaa)
            nVal:=VAL(cVal)

            //��ࢠ� ������ 4 ��ᯮ��
            serr:=lrs1->ser
            serr:=STUFF(serr,1,1,IIF(nVal=0," ","1"))
            sele lrs1
            netrepl('ser',{serr})

          CASE cAID="SERTIF"
            cVal:=Elem_Read('Val',aaa)
            nVal:=VAL(cVal)

            //���� ������ 4 ���䨪�⮢
            serr:=lrs1->ser
            //serr:=STUFF(serr,1,1,IIF(nVal=0," ","1"))
            serr:=STUFF(serr,2,1,IIF(nVal=0," ","1"))
            sele lrs1
            netrepl('ser',{serr})

            //sertr:=nVal
            //sele lrs1
            //netrepl('sert','sertr')

          CASE cAID="REPORT" // �㦭� ���� �� ���? (0,1)
            cVal:=Elem_Read('Val',aaa)
            nVal:=VAL(cVal)

            ttncr:=nVal
            sele lrs1
            netrepl('ttnp',{ttncr})

            netrepl('spd',{0}) //�ਧ��� ��ࠡ�⪨ cAID="REPORT"

          ENDCASE
          if prOrder=1
          endif
        ENDIF
      case subs(aaa,1,5)='<Line'
        if prOrder=1

          mntovr:=ID_Elem_Read_Num('GdsID',aaa,'A')

          colr=at('Amnt',aaa)+len('Amnt')+2
          ckvpr=''
          for i=colr to len(aaa)
              bbb=subs(aaa,i,1)
              if bbb='"'
                  exit
              else
                  ckvpr=ckvpr+bbb
              endif
          next
          kvpr=val(ckvpr)

          colr=at('Price',aaa)+len('Price')+2
          czenr=''
          for i=colr to len(aaa)
              bbb=subs(aaa,i,1)
              if bbb='"'
                  exit
              else
                  czenr=czenr+bbb
              endif
          next
          zenr=val(czenr)

          sele lrs2
          netadd()
          netrepl('ttn,mntov,kvp,zen',{ttnr,mntovr,kvpr,zenr},)
        endif
      endcase
  endd
  fclose(hzvr)
  //clea
  nuse('lrs1')
  nuse('lrs2')
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  12-21-15 * 01:08:05pm
 ����������.........  ����㧪� �த�� (���)
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION XmlCDB2Rs1(cDir,cFile,aKop,n_Skl,lerase)
  LOCAL kta_agsk, lDelFile, nErrCode
  LOCAL nPos_AKop, aPriceType2Kop, cTypePrice
  LOCAL lCONSTANTS
  LOCAL nVes
  LOCAL aMessErr:={}

  DEFAULT lerase TO .T.

  aPriceType2Kop:=PriceType2Kop("kop") //152


  if select('lPhtDoc')#0
     sele lPhtDoc
     use
  endif

  if select('tzvk')#0
     sele tzvk
     use
  endif
  if select('lrs1')#0
     sele lrs1
     use
  endif
  if select('lrs2')#0
     sele lrs2
     use
  endif

  If lerase
    lDelFile:=.T.
    IF lDelFile .AND. (nErrCode:=DELETEFILE("lphtdoc.dbf"),nErrCode) = -5
      OUTLOG(__FILE__,__LINE__,'DELETEFILE("lphtdoc.dbf"),nErrCode',nErrCode)
    ENDIF
    IF lDelFile .AND. (nErrCode:=DELETEFILE("tzvk.dbf"),nErrCode) = -5
      OUTLOG(__FILE__,__LINE__,'DELETEFILE("tzvk.dbf"),nErrCode',nErrCode)
    ENDIF
    IF lDelFile .AND. (nErrCode:=DELETEFILE("tzvk.cdx"),nErrCode) = -5
      OUTLOG(__FILE__,__LINE__,'DELETEFILE("tzvk.cdx"),nErrCode',nErrCode)
    ENDIF
    IF lDelFile .AND. (nErrCode:=DELETEFILE("lrs1.dbf"),nErrCode) = -5
      OUTLOG(__FILE__,__LINE__,'DELETEFILE("lrs1.dbf"),nErrCode',nErrCode)
    ENDIF
    IF lDelFile .AND. (nErrCode:=DELETEFILE("lrs1.cdx"),nErrCode) = -5
      OUTLOG(__FILE__,__LINE__,'DELETEFILE("lrs1.cdx"),nErrCode',nErrCode)
    ENDIF
    IF lDelFile .AND. (nErrCode:=DELETEFILE("lrs2.dbf"),nErrCode) = -5
      OUTLOG(__FILE__,__LINE__,'DELETEFILE("lrs2.cdx"),nErrCode',nErrCode)
    ENDIF
    IF lDelFile .AND. (nErrCode:=DELETEFILE("lrs2.cdx"),nErrCode) = -5
      OUTLOG(__FILE__,__LINE__,'DELETEFILE("lrs2.cdx"),nErrCode',nErrCode)
    ENDIF
    IF lDelFile
      tzvk_crt()
      /*
      netuse('phtdoc')
      outlog(__FILE__,__LINE__,select('phtdoc'))
      nuse('phtdoc')
      */
      lcrtt('lphtdoc','phtdoc')
      lindx('lphtdoc','phtdoc')
      lcrtt('lrs1','rs1')
      lindx('lrs1','rs1')
      lcrtt('lrs2','rs2')
      lindx('lrs2','rs2')
    ELSE
      RETURN
    ENDIF
  EndIf

  if select('tzvk')#0
  else
    tzvk_crt()
  endif
  luse('lphtdoc')
  luse('lrs1')
  luse('lrs2')
  cDelim:= CHR(10) //CHR(13) +

  hzvr:=fopen(cDir+'/'+cFile)

  ttnr:=0
  lCONSTANTS:=NO
  lZakaz:=NO
  lMerch:=NO
  lTable:=NO
  lPrKaOrd:=NO // ��� ��室 ���� �थ�
  lPhtDoc:=NO
  lPict:=NO

  do while !feof(hzvr)
    aaa=FReadLn(hzvr, 1,1600, cDelim)

    DO CASE
    CASE '<DATA' $ aaa
        nVer:=VAL(Elem_Read('PLATFORMVERSION',aaa))
        //outlog(__FILE__,__LINE__,nVer,'PLATFORMVERSION')
    CASE '<CONSTANTS>' $ aaa
        lCONSTANTS:=YES
    CASE lCONSTANTS ;
    .AND. '<ITEM GUID="CF41BA05-A4EE-4492-9A2C-C96394C4864A"'$aaa
        nQTyper:=VAL(Elem_Read('Value',aaa))
        IF "/PARAM" $ UPPER(DosParam())
          //CASE nQTyper = 5 //5 �������� ���
          FOR i:=IIF(nQTyper = 5,1,nQTyper) TO IIF(nQTyper = 5,4,nQTyper)
            //outlog(__FILE__,__LINE__,i, nQTyper)
            DO CASE
            CASE i = 1  //1 �������� ���⪨
              IF STR(s_tag->Ref_Price,1) $ "7,8" .AND. s_tag->Dt_Price = DATE()
              ELSE
                s_tag->(netrepl("Ref_Price",{1}))
              ENDIF

            CASE i = 2 //2 �������� �����������
              s_tag->(netrepl("Doc_Debt",{1}))

            CASE i = 3 //3 �������� ����� �த��
              s_tag->(netrepl("Ref_Sales",{1}))

            CASE i = 4 //4 �������� ��������
              IF STR(s_tag->Ref_Routes,1) $ "7,8" .AND. s_tag->Dt_Routes = DATE()
              ELSE
                s_tag->(netrepl("Ref_Routes",{1}))
              ENDIF

            ENDCASE
          NEXT i
        ENDIF
    CASE lCONSTANTS ;
    .AND. '<ITEM GUID="79C698DB-3C55-465E-ACFE-4741ACDD5655"'$aaa
        //��� ��
            kta_agsk:=ID_Elem_Read_Num('Value',aaa,'B')
            kta_agsk:=PADL(LTRIM(STR(kta_agsk,6)), 6, "0")

            ktar:=VAL(LEFT(kta_agsk,3)) //�� ���� ��
            n_Skl:=VAL(RIGHT(kta_agsk,3)) //228 �� ��᫥���� �����
            IF empty(ktar) .or. empty(n_Skl)
            outlog(__FILE__,__LINE__,"!!ERROR!! empty(ktar)",cDir,cFile,n_Skl,lerase)
            ENDIF
    CASE '</CONSTANTS>' $ aaa
      lCONSTANTS:=NO

    // ���㬥��� ��
    CASE !lPhtDoc .and.'CATALOG GUID="05EA7926-FEBB-4D82-97FC-19294DD5DD29">' $ aaa
      lPhtDoc:=YES
    CASE lPhtDoc .and. '<ITEM ' $ aaa
      sele lPhtDoc
      DBAppend()
      _FIELD->GuId := Elem_Read('GUID',aaa) // ���  ��⠫��� � ��
      _FIELD->DocGuid := Elem_Read('A01',aaa) // ��� ������
      _FIELD->PhotGuId := Elem_Read('A04',aaa) // ��� ���
      _FIELD->DtPhot := Kpk_DateTime(Elem_Read('A05',aaa)) // ��� �६�
      _FIELD->TmPhot := RIGHT(Elem_Read('A05',aaa),8) // �६�
    CASE lPhtDoc .and. '</CATALOG>' $ aaa
       lPhtDoc:=NO

    // ���⨭��  ���㬥�⠬
    CASE !lPict .and. '<PICTURES>' $ aaa
      lPict:=YES
      sele lPhtDoc
      ordsetfocus('t2')
    CASE lPict .and. '<ITEM' $ aaa
      cPhotGuId:= Elem_Read('GUID',aaa)
      sele lPhtDoc
      DBSeek(cPhotGuId)
      //locate for cPhotGuId = PhotGuId
      _FIELD->FileName:=Elem_Read('FileName',aaa)
      _FIELD->Comment:=translate_charset("cp1251",host_charset(),Elem_Read('Description',aaa))

    CASE lPict .and. '</PICTURES>' $ aaa
      lPict:=NO

    CASE !lZakaz .AND. '<DOCUMENT GUID="E01E1F5C-D6E4-46E8-B923-3758B0D79BDE">' $ aaa
      //����� ��砫�
      lZakaz:=YES
      lTable:=NO
    CASE lZakaz .AND. '</DOCUMENT>' $ aaa
      //����� �����稫�
      lZakaz:=NO
      lTable:=NO
    CASE lZakaz ;
    .AND. .NOT. lTable ;
    .AND. ('<ITEM ' $ aaa) // 蠯��, �� ����� ���� ����� .AND. .NOT. ('/>' $ aaa))
    // .AND. ('<ITEM ' $ aaa) .AND. .NOT. ('/>' $ aaa)) - ⮫쪮 蠯��, ⮢�� ���
      //蠯�� ������
      //�஢����?
      DocType_Ok:=IIF(VAL(Elem_Read('IsPost',aaa))=1,;
                      .T.,;//ࠡ�⠥� �����
                      .F.;// �������� ���� �஢����
                    )
        DocIDr:=Elem_Read('GUID',aaa)

      IF DocType_Ok
        //᪫��
        Sklr:=VAL(RIGHT(kta_agsk,3)) //228
        //��� ����樨
        kopr:=VAL(RIGHT(Elem_Read('A019',aaa),3))
        If kopr < 100
          kopr:=169
        EndIf

        //⨯ 業�
        cTypePrice:=Elem_Read('A07',aaa)
        // cTypePrice ���� PriceType2Kop("guid_price")
        // kopir:=aPriceType2Kop[nPriceType]
        kopir:=kopr //�᭮���� 業�
      ELSE
                  //    .F.;// �������� ���� �஢����

      ENDIF

      IF DocType_Ok
        kplr:=ID_Elem_Read_Num('A03',aaa,'C')

        kgpr:=ID_Elem_Read_Num('A04',aaa,'C')

        IF EMPTY(kplr) .OR. EMPTY(kgpr)
          DocType_Ok:=.F. //�������� ����� ���⠢�� ४������
          //OUTLOG(__FILE__,__LINE__,"DocIDr",DocIDr)
        ENDIF
      ENDIF

      IF DocType_Ok

        GpsLatr:=Elem_Read('A014',aaa)
        GpsLonr:=Elem_Read('A015',aaa)
        DeviceGUIDr:=GpsLonr+';'+GpsLatr
        IF !EMPTY(VAL(GpsLatr))
          GpsLatr:=DDMM2DDDD(GpsLatr)           //���
          GpsLonr:=DDMM2DDDD(GpsLonr)           //������
        ENDIF

        TimeCrtFrmr:=Elem_Read('A017',aaa) //��砫�
        TimeCrtr:=Elem_Read('A018',aaa) //����砭��
        DocIDr:=Elem_Read('GUID',aaa)
        Sumr:=VAL(Elem_Read('A08',aaa))
        Commentr:=Elem_Read('A011',aaa)
        #ifdef __CLIP__
            Commentr := translate_charset("cp1251",host_charset(),Commentr)
        #endif

        DtRor:=Kpk_DateTime(Elem_Read('A010',aaa)) // ��� ���⠢��
        // QOUT('<CATALOG GUID="E4623B4E-2F19-47AB-B158-EE0E021D3911" KILLALL="1"
        // Comment="��ࠢ�筨�.���넮�⠢��">')
        pvtr:=iif('84D92255'$Elem_Read('A020',aaa), 0, 1)
        nVes:=round(VAL(Elem_Read('A09',aaa)),3)
        /*          IF ktar = 475
          outlog(__FILE__,__LINE__,nVes)
        ENDIF*/

        sele lrs1
        DBGoBottom()
        ttnr:=lrs1->ttn
        ttnr=ttnr+1
        netadd()
        netrepl('DtRo,pvt',{DtRor,pvtr})

        if at('�=',Commentr) # 0 // ������� �� ����� �����
          netrepl('ztxt',{Commentr})
        else
          netrepl('npv',{Commentr})
        endif
        netrepl('TimeCrtFrm,TimeCrt,DocGUID,Sdv',{TimeCrtFrmr,TimeCrtr,DocIDr,Sumr})

        netrepl('Skl,ttn,vo,kop,kopi,kpl,kgp,kta,ddc,tdc,GpsLat,GpsLon, DeviceGUID',;
                {Sklr,ttnr,9,kopr,kopir,kplr,kgpr,ktar,date(),time(),GpsLatr,GpsLonr,DeviceGUIDr})

        netrepl('RndSdv',{2}) // ���㣫����


        IF ('<ITEM ' $ aaa .AND. .NOT. ('/>' $ aaa)) // ⮫쪮 蠯��, ⮢�� ���
          netrepl('spd',{1}) //�ਧ��� ��ࠡ�⪨
          // ���� ������ ��९�᢮���� � 0 - �� ������ ����⠭

          //���⠫� 蠯��, ���� ⠫���� � ⮢�஬
          lTable:=YES
        ELSE
          //⮫쪮 蠯��, ⮢�� ���
          lTable:=NO
        ENDIF
      ELSE
        lTable:=NO
      ENDIF

    CASE lZakaz ;
    .AND. lTable ;
    .AND. '<ITEM ' $ aaa
    IF DocType_Ok
      mntovr:=ID_Elem_Read_Num('A01',aaa,'A')
      kvpr:=VAL(Elem_Read('A04',aaa))
      //zenr:= ;// ��� ᪨���
      //val(Elem_Read('A05',aaa))
      zenr:= ; // � ᪨����
      (val(Elem_Read('A06',aaa)) - val(Elem_Read('A012',aaa)))/kvpr
      nVes := ROUND(nVes - ROUND(IIF(nVer>=2.57,1,kvpr) * VAL(Elem_Read('A08',aaa)), 3), 3)

        /*          IF ktar = 475
          outlog(__FILE__,__LINE__,nVes,kvpr * VAL(Elem_Read('A08',aaa)),kvpr , VAL(Elem_Read('A08',aaa)))
        ENDIF          */

      sele lrs2
      netadd()
      netrepl('ttn,mntov,kvp,zen',{ttnr,mntovr,kvpr,zenr},)
    ENDIF


    CASE lZakaz ;
    .AND. lTable ;
    .AND. '</TABLE>' $ aaa
    //�����稫��� ⠫���筠� ����
        sele lrs1
        netrepl('spd',{0}) //�ਧ��� ��ࠡ�⪨
        IF !EMPTY(ROUND(nVes,3))
          OUTLOG(__FILE__,__LINE__,"!EMPTY(nVes)",nVes,"DocIDr",DocIDr)
          AADD(aMessErr,CHR(10)+CHR(13))
          AADD(aMessErr,"!EMPTY(nVes) nVes="+str(nVes,7,3)+" DocIDr "+DocIDr+CHR(10)+CHR(13))
          AADD(aMessErr,"�� "+STR(ktar)+CHR(10)+CHR(13))
        ENDIF
      lTable:=NO
      DocType_Ok := NO

    CASE !lMerch .AND. '<DOCUMENT GUID="61DEE5FE-D0A8-4842-A6AF-A8D33F298845">' $ aaa
      //���� ��砫�
      lMerch:=YES
    CASE lMerch .AND. '</DOCUMENT>' $ aaa
      //���� �����稫�
      lMerch:=NO
    CASE lMerch ;
    .AND. .NOT. lTable ;
    .AND. ('<ITEM ' $ aaa .AND. .NOT. ('/>' $ aaa))
      //蠯�� ������
              //DocType_Ok:=.T.
      DocType_Ok:=IIF(VAL(Elem_Read('IsPost',aaa))=1,;
                      .T.,;//ࠡ�⠥� �����
                      .T.;// �������� ���� �஢����
                    )

      IF DocType_Ok
        Sklr:=ngMerch_Sk241
        kopr:=160
        kopir:=kopr
      ELSE
        DocType_Ok:=.F. //�������� ����� ���⠢�� ४������
      ENDIF

      IF DocType_Ok
        kplr:=ID_Elem_Read_Num('A02',aaa,'C')

        kgpr:=ID_Elem_Read_Num('A03',aaa,'C')

        IF EMPTY(kplr) .OR. EMPTY(kgpr)
          DocType_Ok:=.F. //�������� ����� ���⠢�� ४������

        ENDIF
      ENDIF

      IF DocType_Ok
        GpsLatr:=Elem_Read('A09',aaa)
        GpsLonr:=Elem_Read('A010',aaa)
        DeviceGUIDr:=GpsLatr+','+GpsLonr
        IF !EMPTY(VAL(GpsLatr))
          GpsLatr:=DDMM2DDDD(GpsLatr) //���
          GpsLonr:=DDMM2DDDD(GpsLonr) //������
        ENDIF

        TimeCrtFrmr:=Elem_Read('A013',aaa) //��砫�
        TimeCrtr:=Elem_Read('A014',aaa) //����砭��
        DocIDr:=Elem_Read('GUID',aaa)
        Sumr:=VAL(Elem_Read('A06',aaa))
        Commentr:=Elem_Read('A07',aaa)
        #ifdef __CLIP__
            Commentr := translate_charset("cp1251",host_charset(),Commentr)
        #endif

        DtRor:=Kpk_DateTime(Elem_Read('DT',aaa))

        sele lrs1
        DBGoBottom()
        ttnr:=lrs1->ttn
        ttnr=ttnr+1
        netadd()
        netrepl('DtRo',{DtRor})
        if at('�=',Commentr) # 0 // ������� �� ����� �����
          netrepl('ztxt',{Commentr})
        else
          netrepl('npv',{Commentr})
        endif
        netrepl('TimeCrtFrm,TimeCrt,DocGUID,Sdv',{TimeCrtFrmr,TimeCrtr,DocIDr,Sumr})
        netrepl('Skl,ttn,vo,kop,kopi,kpl,kgp,kta,ddc,tdc,GpsLat,GpsLon, DeviceGUID',;
                {Sklr,ttnr,9,kopr,kopir,kplr,kgpr,ktar,date(),time(),GpsLatr,GpsLonr, DeviceGUIDr})

        netrepl('spd',{1}) //�ਧ��� ��ࠡ�⪨ cAID="REPORT"
        // ���� ������ ��९�᢮���� � 0 - �� ������ ����⠭

        //���⠫� 蠯��, ���� ⠫���� � ⮢�஬
        lTable:=YES
      ELSE
        lTable:=YSE
      ENDIF

    CASE lMerch ;
    .AND. lTable ;
    .AND. '<ITEM ' $ aaa
    IF DocType_Ok
      mntovr:=ID_Elem_Read_Num('A01',aaa,'A')
      kvpr:=VAL(Elem_Read('A04',aaa))
      zenr:= ;// ��� ᪨���
      val(Elem_Read('A05',aaa))

      sele lrs2
      netadd()
      netrepl('ttn,mntov,kvp,zen',{ttnr,mntovr,kvpr,zenr},)
    ENDIF


    CASE lMerch ;
    .AND. lTable ;
    .AND. '</TABLE>' $ aaa
    //�����稫��� ⠫���筠� ����
      lTable:=NO
      DocType_Ok := NO

    CASE !lPrKaOrd .AND. '<DOCUMENT GUID="749BE2E0-9B00-4D7B-9D4D-88CA53327511">' $ aaa
      //��� ��砫�
      lPrKaOrd:=YES
    CASE lPrKaOrd .AND. '</DOCUMENT>' $ aaa
      //��� �����稫�
      lPrKaOrd:=NO
    CASE lPrKaOrd ;// ���
        .AND. '<ITEM ' $ aaa
      DocType_Ok:=IIF(VAL(Elem_Read('IsPost',aaa))=1,;
                      .T.,;//ࠡ�⠥� �����
                      .F.;// �������� ���� �஢����
                    )

      IF DocType_Ok
        DtRor:=Kpk_DateTime(Elem_Read('dt',aaa))
        kplr:=ID_Elem_Read_Num('A02',aaa,'C')
        kgpr:=ID_Elem_Read_Num('A03',aaa,'C')
        Sumr:=VAL(Elem_Read('A07',aaa))
        Commentr:=Elem_Read('A06',aaa)
        // NNNNNNNN-NNNN-NNNN-NNNN-NNNNNNNNNNNN
        DokOsn:=Elem_Read('A09',aaa) // ��� ��⭮�����
        dopr:=STOD(LEFT(DokOsn,8))
        nPos:=15
        napr:= val(SUBSTR(DokOsn, nPos, AT('F',SUBSTR(DokOsn,nPos))-1))
        nPos:= 20
        skl_r:= val(SUBSTR(DokOsn, nPos, AT('F',SUBSTR(DokOsn,nPos))-1))
        nPos:= 25
        ttnr:= val(SUBSTR(DokOsn, nPos, AT('F',SUBSTR(DokOsn,nPos))-1))

        If skl_r > 1000 .or. year(dopr)<2006
          outlog(__FILE__,__LINE__,DokOsn,  kplr,  DtRor,  kgpr,  skl_r, ttnr,;
               dopr,        sumr,        Commentr,        napr    )
        else
          sele tzvk
          appe blank
          repl ;
          dvp with DtRor,;
          kpl with kplr,;
          kgp with kgpr,;
          sk  with skl_r,;
          ttn with ttnr,;
          dop with dopr,;
          sdv with sumr,;
          kom with Commentr,;
          nap with napr
        EndIf
      endif

    endcase
  enddo
  fclose(hzvr)

  // ������� ������� �� ������ਥ�
  sele lrs1
  DBGoTop()
  DBEval(;
  {|| tzvk_ztxt(kpl, kgp, ztxt, ttn,,lrs1->Ddc),;
   _FIELD->ztxt:='' },;
  {|| !empty(ztxt) };
  )

  CreTtn0_4Zdn(.T.) // '/NEWZDN' $ upper(cDosParam))

  sele tzvk
  copy to ('tzvk'+PADL(LTRIM(str(ktar)),3,'0'))
  copy to ('tzvk_lrs')
  /*
  DBGOTOP()
  DO WHILE !EOF()
    kplr:=kpl
    i:=0
    cLine:=''
    DO WHILE kplr = kpl
      cLine += ;
      +'�='+LTRIM(STR(TTN)); // ����� ���
      +'�='+LTRIM(STR(sdv,12,2)); // �㬬� �����
      +'�='+LTRIM(STR(NAP)); // ���ࠢ�����
      +'�='+LTRIM(STR(sk))+' '+DTOS(dop)+' '+ALLTRIM(kom) // ������਩
      DBSKIP()
    ENDDO

    sele lrs1
    locate for kplr = kpl
    IF FOUND()
      // ���� �������
      //netrepl('spd',{1}) //�ਧ��� ��ࠡ�⪨
      netrepl('ztxt,spd',{cLine,0})
    ENDIF

    sele tzvk
  ENDDO
  */
  sele tzvk
  use

  sele lrs1
  If !empty(nKta)
    copy to ('lrs1'+padl(allt(str(nKta,3)),3,'0'))
  EndIf
  use
  nuse('lrs2')

  #ifdef __CLIP__
    IF !EMPTY(aMessErr)
      cMessErr:=""
      AEVAL(aMessErr,{|cElem|cMessErr += cElem })
      //SendingJafa("r eal.prodresurs@mail.ru,lista@bk.ru",{{ "","Error Olejna-ProdResSumy"+" "+DTOC(DATE(),"YYYYMMDD")}},;
      SendingJafa("lista@bk.ru",{{ "","Error ToC1CDB-ProdResSumy"+" "+DTOC(DATE(),"YYYYMMDD")+TIME()}},;
      cMessErr,;
      228)

    ENDIF
  #endif
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  12-19-06 * 12:21:44pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION ID_Elem_Read_Num(cElem,aaa,cPref)
  LOCAL colr, cktar, ktar
  colr:=at(cElem+'=',aaa)
  cktar:=subs(aaa,colr+len(cElem)+2,36)
  colr:=at(cPref,cktar)
  cktar:=subs(cktar,colr+1)
  ktar:=val(cktar)
  RETURN (ktar)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  12-19-06 * 12:39:01pm
 ����������......... �⥭�� ������� ���祭�� ������
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION Elem_Read(cElem, aaa)
  LOCAL nPosRight
  nPosLeft:=AT(cElem+'=', aaa)+(LEN(cElem)+2) //�ࠢ�� ������ ������

  nPosRight:=AT('" ', SUBSTR(aaa,nPosLeft))

  IF nPosRight = 0
    nPosRight:=AT('">', SUBSTR(aaa,nPosLeft))
  ENDIF
  IF nPosRight = 0
    nPosRight:=AT('"/', SUBSTR(aaa,nPosLeft))
  ENDIF

  cElem:=SUBSTR(aaa, nPosLeft, nPosRight-1)

  RETURN (cElem)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  12-25-06 * 07:37:26pm
 ����������.........
 ���������..........
 �����. ��������....
 ����������......... TimeDlv="2006-12-26 16-44-23"
 */
FUNCTION Kpk_DateTime(cTimeCrt)
  LOCAL dDateCrt
  dDateCrt:=STUFF(LEFT(cTimeCrt,10),5,1,"")
  dDateCrt:=STUFF(dDateCrt,7,1,"")
  dDateCrt:=STOD(LEFT(dDateCrt,8))
  RETURN (dDateCrt)


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ���쭨�  12-20-06 * 11:54:59am
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION fromkpk_merch()
  LOCAL dDtTmLog
     skpk()
  retu .t.


*********************
func rs2mkins(p1)
*********************
local kolr
  // p1 ���-��
kolr=p1
kvpr=0
kgr=int(mntovr/10000)
zenpr=getfield('t1','mntovr','ctov',czenr)
izgr:=getfield("t1","mntovr","ctov","izg")
sele klnnac
nacr=0
if netseek('t1','nkklr,izgr,999')
   nacr=nac
endif
if nacr=0
   if netseek('t1','nkklr,izgr,999')
      nacr=nac
   endif
endif
if nacr#0
   zenr=zenpr*(1+nacr/100)
else
   zenr=zenpr
endif

if skr=ngMerch_Sk241 //���� ᪫��
   ktl_r=mntovr*100
   sele tovm
   if !netseek('t1','sklr,mntovr',,,1)
      sele ctov
      if netseek('t1','mntovr')
         arec:={}
         getrec()
         sele tovm
         netadd()
         putrec()
         netrepl('skl','sklr')
      endif
   endif
   sele tov
   if !netseek('t1','sklr,ktl_r')
      sele ctov
      if netseek('t1','mntovr')
         arec:={}
         getrec()
         sele tov
         netadd()
         putrec()
         opt_r=0.01
         netrepl('skl,ktl,opt','sklr,ktl_r,opt_r')
      endif
   endif
endif

sele tovm
if netseek('t1','sklr,mntovr',,,1)
   reclock()
   if skr=ngMerch_Sk241 //���� ᪫��
      kvpr=kolr
      kolr=0
      netrepl('osv','osv-kvpr',1)
      sele tov
      if netseek('t1','sklr,ktl_r')
         netrepl('osv','osv-kvpr',1)
      endif
      sele rs2m
      if !netseek('t3','ttnr,mntovr,0,mntovr')
         netadd()
         netrepl('ttn,mntovp,mntov,zen,izg,zenp','ttnr,mntovr,mntovr,zenr,izgr,zenpr')
      endif
      svpr=roun(kvpr*zenr,2)
      netrepl('svp,kvp','svp+svpr,kvp+kvpr')
      sele rs2
      if !netseek('t3','ttnr,ktl_r,0,ktl_r')
         netadd()
         netrepl('ttn,mntovp,mntov,zen,bzen,izg,zenp,bzenp,ktl,ktlp,przenp,prbzenp,pzen,pbzen',;
                 'ttnr,mntovr,mntovr,zenr,zenr,izgr,zenpr,zenpr,ktl_r,ktl_r,nacr,nacr,nacr,nacr')
      endif
      svpr=roun(kvpr*zenr,2)
      netrepl('svp,kvp','svp+svpr,kvp+kvpr')
      sele lrs2
      netrepl('kvpo','kvpo+kvpr')
   else
      sele tov
      set orde to tag t5
      if netseek('t5','sklr,mntovr')
          do while skl=sklr.and.mntov=mntovr
             if osv<=0
                sele tov
                skip
                loop
             endif
             reclock()
             osvr=osv
             optr=opt
             izgr=izg
             k1tr=k1t
             upakr=upak
             rctov_r=recn()
             if osvr<kolr
                kvp_r=osvr
                kolr=kolr-osvr
             else && osvr>=kvpr
                kvp_r=kolr
                kolr=0
             endif
             ktlr=ktl
             netrepl('osv','osv-kvp_r')
             sele tovm
             netrepl('osv','osv-kvp_r',1)
             sele rs2
             if !netseek('t3','ttnr,ktlr,0,ktlr')
                netadd()
                netrepl('ttn,mntovp,mntov,zen,bzen,izg,zenp,bzenp,ktl,ktlp,przenp,prbzenp,pzen,pbzen',;
                        'ttnr,mntovr,mntovr,zenr,zenr,izgr,zenpr,zenpr,ktlr,ktlr,nacr,nacr,nacr,nacr')
             endif
             srr=roun(kvp_r*optr,2)
             svpr=roun(kvp_r*zenr,2)
             netrepl('sr,svp,kvp','sr+srr,svp+svpr,kvp+kvp_r')
             sele rs2m
             if !netseek('t3','ttnr,mntovr,0,mntovr')
                netadd()
                netrepl('ttn,mntovp,mntov,zen,bzen,izg,zenp,bzenp,ktl,ktlp,przenp,prbzenp,pzen,pbzen',;
                        'ttnr,mntovr,mntovr,zenr,zenr,izgr,zenpr,zenpr,0,0,nacr,nacr,nacr,nacr')
                netrepl('kvp,sr,svp','kvp+kvp_r,sr+srr,svp+svpr')
             else
                netrepl('kvp,sr,svp','kvp+kvp_r,sr+srr,svp+svpr')
             endif
             sele lrs2
             netrepl('kvpo','kvpo+kvp_r')
             k1t_r=0
             if int(k1tr/1000000)=1
                sele tov
                if netseek('t1','sklr,k1tr')
                   if osv>=kvp_r
                      m1tr=mntov
                      opttr=opt
                      k1t_r=k1t
                      zenptr=getfield('t1','m1tr','ctov',czenr)
                      netrepl('osv','osv-kvp_r')
                      sele tovm
                      rctovm_r=recn()
                      if netseek('t1','sklr,m1tr',,,1)
                         netrepl('osv','osv-kvp_r')
                      endif
                      go rctovm_r
                      sele rs2
                      if !netseek('t3','ttnr,ktlr,1,k1tr')
                         netadd()
                         netrepl('ttn,mntovp,mntov,zen,bzen,izg,zenp,bzenp,ktl,ktlp,przenp,prbzenp,pzen,pbzen,ppt',;
                                 'ttnr,mntovr,m1tr,zenptr,zenptr,izgr,zenptr,zenptr,k1tr,ktlr,0,0,0,0,1')
                      endif
                      srr=roun(kvp_r*opttr,2)
                      svpr=roun(kvp_r*zenptr,2)
                      netrepl('sr,svp,kvp','sr+srr,svp+svpr,kvp+kvp_r')
                      sele rs2m
                      if !netseek('t3','ttnr,mntovr,1,m1tr')
                         netadd()
                         netrepl('ttn,mntovp,mntov,zen,bzen,izg,zenp,bzenp,ktl,ktlp,przenp,prbzenp,pzen,pbzen,ppt',;
                                 'ttnr,mntovr,m1tr,zenptr,zenptr,izgr,zenptr,zenptr,0,0,0,0,0,0,1')
                         netrepl('sr,svp,kvp','sr+srr,svp+svpr,kvp+kvp_r')
                      else
                         netrepl('kvp','kvp+kvp_r')
                         netrepl('sr,svp,kvp','sr+srr,svp+svpr,kvp+kvp_r')
                      endif
                   endif
                endif
                if k1t_r#0
                   ptarar=1
                endif
                sele tov
                go rctov_r
             else
                if k1tr#0
                   k1t_r=k1tr
                   ptarar=1
                endif
             endif
             if k1t_r#0.and.upakr#0
                kvp_rr=ceiling(kvp_r/upakr)
                sele tov
                if netseek('t1','sklr,k1t_r')
                   if osv>=kvp_rr
                      m1t_r=mntov
                      opttr=opt
                      zenptr=getfield('t1','m1t_r','ctov',czenr)
                      netrepl('osv','osv-kvp_rr')
                      sele tovm
                      rctovm_r=recn()
                      if netseek('t1','sklr,m1t_r',,,1)
                         netrepl('osv','osv-kvp_rr')
                      endif
                      go rctovm_r
                      sele rs2
                      if !netseek('t3','ttnr,ktlr,1,k1t_r')
                         netadd()
                         netrepl('ttn,mntovp,mntov,zen,bzen,izg,zenp,bzenp,ktl,ktlp,przenp,prbzenp,pzen,pbzen,ppt',;
                                  'ttnr,mntovr,m1t_r,zenptr,zenptr,izgr,zenptr,zenptr,k1t_r,ktlr,0,0,0,0,1')
                      endif
                      srr=roun(kvp_rr*opttr,2)
                      svpr=roun(kvp_rr*zenptr,2)
                      netrepl('sr,svp,kvp','sr+srr,svp+svpr,kvp+kvp_rr')
                      sele rs2m
                      if !netseek('t3','ttnr,mntovr,1,m1t_r')
                         netadd()
                         netrepl('ttn,mntovp,mntov,zen,bzen,izg,zenp,bzenp,ktl,ktlp,przenp,prbzenp,pzen,pbzen,ppt',;
                                 'ttnr,mntovr,m1t_r,zenptr,zenptr,izgr,zenptr,zenptr,0,0,0,0,0,0,1')
                         netrepl('sr,svp,kvp','sr+srr,svp+svpr,kvp+kvp_rr')
                      else
                         netrepl('sr,svp,kvp','sr+srr,svp+svpr,kvp+kvp_rr')
                      endif
                   endif
                endif
                sele tov
               go rctov_r
             endif
             if kolr=0
                exit
             endif
             sele tov
             skip
         endd
      endif
   endif
   sele tovm
   netunlock()
else
  #ifdef __CLIP__
      //qout(__FILE__,__LINE__,'�� ������ � TOVM ��� N',lrs2->ttn,str(mntovr,7),"�-��",lrs2->kvp, ALLTRIM(getfield('t1','mntovr','ctov','nat')))
      //qout("DocGUID",lrs1->DocGUID,lrs1->TimeCrt,lrs1->TimeCrtFrm)
      //qout("")
   #endif
endif
retu kolr

*********************
func rs2tovi(p1)
*********************
local kvpr,kolr
  // p1 ���-��
kolr=p1
kgr=int(mntovr/10000)
zenpr=getfield('t1','mntovr','ctov',czenr)
izgr:=getfield("t1","mntovr","ctov","izg")
sele klnnac
nacr=0
if netseek('t1','nkklr,izgr,999')
   nacr=nac
endif
if nacr=0
   if netseek('t1','nkklr,izgr,999')
      nacr=nac
   endif
endif
if nacr#0
   zenr=zenpr*(1+nacr/100)
else
   zenr=zenpr
endif
sele tov
mntovr=mntov
sele tovm
if netseek('t1','sklr,mntovr',,,1)
   reclock()
   rctovm_r=recn()
   sele tov
   reclock()
   rctov_r=recn()
   prboxr=at('��',nat)
   if osv>0
      osvr=osv
      optr=opt
      izgr=izg
      k1tr=k1t
      upakr=upak
      if osvr<kolr
         kvp_r=osvr
         kolr=kolr-osvr
      else && osvr>=kolr
         kvp_r=kolr
         kolr=0
      endif
      ktlr=ktl
      netrepl('osv','osv-kvp_r')
      sele tovm
      netrepl('osv','osv-kvp_r')
      sele rs2
      if !netseek('t3','ttnr,ktlr,0,ktlr')
         netadd()
         netrepl('ttn,mntovp,mntov,zen,bzen,izg,zenp,bzenp,ktl,ktlp,przenp,prbzenp,pzen,pbzen',;
                 'ttnr,mntovr,mntovr,zenr,zenr,izgr,zenpr,zenpr,ktlr,ktlr,nacr,nacr,nacr,nacr')
      endif
      srr=roun(kvp_r*optr,2)
      svpr=roun(kvp_r*zenr,2)
      netrepl('sr,svp,kvp','sr+srr,svp+svpr,kvp+kvp_r')
      sele rs2m
      if !netseek('t3','ttnr,mntovr,0,mntovr')
         netadd()
         netrepl('ttn,mntovp,mntov,zen,bzen,izg,zenp,bzenp,ktl,ktlp,przenp,prbzenp,pzen,pbzen',;
                 'ttnr,mntovr,mntovr,zenr,zenr,izgr,zenpr,zenpr,0,0,nacr,nacr,nacr,nacr')
         netrepl('kvp,sr,svp','kvp+kvp_r,sr+srr,svp+svpr')
      else
         netrepl('kvp,sr,svp','kvp+kvp_r,sr+srr,svp+svpr')
      endif
      sele lrs2
      netrepl('kvpo','kvpo+kvp_r')
      sele rs2kpk
      netrepl('kvpo','kvpo+kvp_r')
      k1t_r=0
      if int(k1tr/1000000)=1 && ��ࢠ� �ਢ易�� �⥪����
         sele tov
         if netseek('t1','sklr,k1tr',,,1)
            m1tr=mntov
            sele tovm
            if netseek('t1','sklr,m1tr',,,1)
               reclock()
               sele tov
               reclock()
               if osv>=kvp_r
                  opttr=opt
                  k1t_r=k1t
                  if gnEnt=21
                     if prboxr#0.and.k1t_r=0
                        #ifdef __CLIP__
                           outlog(__FILE__,__LINE__,ttnr,ktlr,k1tr,k1t_r,"��� �� � �⥪�� � TOV")
                        #endif
                     endif
                  endif
                  zenptr=getfield('t1','m1tr','ctov',czenr)
                  netrepl('osv','osv-kvp_r')
                  sele tovm
                  netrepl('osv','osv-kvp_r')
                  sele rs2
                  if !netseek('t3','ttnr,ktlr,1,k1tr')
                     netadd()
                     netrepl('ttn,mntovp,mntov,zen,bzen,izg,zenp,bzenp,ktl,ktlp,przenp,prbzenp,pzen,pbzen,ppt',;
                             'ttnr,mntovr,m1tr,zenptr,zenptr,izgr,zenptr,zenptr,k1tr,ktlr,0,0,0,0,1')
                  endif
                  srr=roun(kvp_r*opttr,2)
                  svpr=roun(kvp_r*zenptr,2)
                  netrepl('sr,svp,kvp','sr+srr,svp+svpr,kvp+kvp_r')
                  sele rs2m
                  if !netseek('t3','ttnr,mntovr,1,m1tr')
                     netadd()
                     netrepl('ttn,mntovp,mntov,zen,bzen,izg,zenp,bzenp,ktl,ktlp,przenp,prbzenp,pzen,pbzen,ppt',;
                             'ttnr,mntovr,m1tr,zenptr,zenptr,izgr,zenptr,zenptr,0,0,0,0,0,0,1')
                     netrepl('sr,svp,kvp','sr+srr,svp+svpr,kvp+kvp_r')
                  else
                     netrepl('kvp','kvp+kvp_r')
                     netrepl('sr,svp,kvp','sr+srr,svp+svpr,kvp+kvp_r')
                  endif
               endif
               sele tov
               netunlock()
               sele tovm
               netunlock()
            else
               if gnEnt=21
                  if m1t_r=0
                     #ifdef __CLIP__
                        outlog(__FILE__,__LINE__,ttnr,m1t_r,"��� � TOVM")
                     #endif
                  endif
               endif
            endif
            if k1t_r#0
               ptarar=1
            endif
         endif
      else && ��ࢠ� �ਢ易�� ��
         if k1tr#0
            k1t_r=k1tr
            ptarar=1
         endif
      endif
      if k1t_r#0.and.upakr#0 && ���᫥��� ���-�� � �ਢ離� �騪��
         kvp_rr=ceiling(kvp_r/upakr)
         if gnEnt=21.and.upakr=0
            #ifdef __CLIP__
              outlog(__FILE__,__LINE__,ttnr,ktlr,kvp_r,"/",upakr,"�-�� �騪��")
            #endif
         endif
         sele tov
         if netseek('t1','sklr,k1t_r',,,1)
            m1t_r=mntov
            if gnEnt=21
              if m1t_r=0
                 #ifdef __CLIP__
                   outlog(__FILE__,__LINE__,ttnr,ktlr,k1t_r,m1t_r,"��� �ਢ離� m1t TOV")
                 #endif
              endif
            endif
            sele tovm
            if netseek('t1','sklr,m1t_r',,,1)
               reclock()
               sele tov
               reclock()
               if osv>=kvp_rr
                  opttr=opt
                  zenptr=getfield('t1','m1t_r','ctov',czenr)
                  netrepl('osv','osv-kvp_rr')
                  sele tovm
                  netrepl('osv','osv-kvp_rr')
                  sele rs2
                  if !netseek('t3','ttnr,ktlr,1,k1t_r')
                     netadd()
                     netrepl('ttn,mntovp,mntov,zen,bzen,izg,zenp,bzenp,ktl,ktlp,przenp,prbzenp,pzen,pbzen,ppt',;
                             'ttnr,mntovr,m1t_r,zenptr,zenptr,izgr,zenptr,zenptr,k1t_r,ktlr,0,0,0,0,1')
                  endif
                  srr=roun(kvp_rr*opttr,2)
                  svpr=roun(kvp_rr*zenptr,2)
                  netrepl('sr,svp,kvp','sr+srr,svp+svpr,kvp+kvp_rr')
                  sele rs2m
                  if !netseek('t3','ttnr,mntovr,1,m1t_r')
                     netadd()
                     netrepl('ttn,mntovp,mntov,zen,bzen,izg,zenp,bzenp,ktl,ktlp,przenp,prbzenp,pzen,pbzen,ppt',;
                             'ttnr,mntovr,m1t_r,zenptr,zenptr,izgr,zenptr,zenptr,0,0,0,0,0,0,1')
                     netrepl('sr,svp,kvp','sr+srr,svp+svpr,kvp+kvp_rr')
                  else
                     netrepl('sr,svp,kvp','sr+srr,svp+svpr,kvp+kvp_rr')
                  endif
               endif
               sele tov
               netunlock()
               sele tovm
               netunlock()
            else
               if gnEnt=21
                  if m1t_r=0
                     #ifdef __CLIP__
                        outlog(__FILE__,__LINE__,ttnr,m1t_r,"��� � TOVM")
                     #endif
                  endif
               endif
            endif
         endif
      endif
   endif
   sele tov
   go rctov_r
   netunlock()
   sele tovm
   go rctovm_r
   netunlock()
else
if mntovr=3410099
#ifdef __CLIP__
   outlog(__FILE__,__LINE__,"seek tovm T1 ERR",sklr,mntovr)
#endif
endif
endif
retu kolr


/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  11-18-07 * 10:46:50am
 ����������......... �஢�ઠ �� ����� ᪫�� ������ ���� ���
                     �஢������ ���⥫�騪
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION check_skl(Sklr,kgpr)
  LOCAL aSkl //, oSkl

  If gnEnt = 20
    aSkl:={;
    {0,228},{1,228},{2,228},;
    {3,300},;
    {4,400},;
    {5,500},;
    {6,600};
    }
  Else
    aSkl:={;
    {0,232},{1,232},{2,232},;
    {4,700},;
    }
  EndIf

  IF !EMPTY(kgpr)
    IF kgp->(netseek('t1','kgpr'))
      nPos:=ASCAN(aSkl,{|aElem|aElem[1]=kgp->rm})
      IF !EMPTY(nPos)
        sklr:=aSkl[nPos,2]
      ENDIF
    ELSE
      RETURN (.F.)  //tochka net tablizhe
    ENDIF
  ENDIF
  /*
  oSkl:=map()
  oSkl:rm0:=228
  oSkl:rm3:=300
  oSkl:rm4:=400
  oSkl:rm5:=500
  oSkl:rm6:=600
  */
  //sele cSkl
  locate for sk=Sklr //��� ᪫���
  IF gnEntRm=0 .AND. cSkl->Rm#0
    //   LOOP
    RETURN (.F.)
  ENDIF
  IF gnEntRm=1 .AND. cSkl->Rm#1
  //     LOOP
    RETURN (.F.)
  ENDIF
  RETURN (.T.)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  04-24-17 * 11:22:54am
 ����������.........
  � ���� ��ப� ����� �������஢��� ��᪮�쪮 ������ ����䨪�樨 (-M):
  exiv2 -M"add Iptc.Application2.Byline  ���� 007"
  -M"add Iptc.Application2.Keywords ᮪� Jaffa ��祭쪨"
  0020034-000-20170317\(1\).jpg
  ��࠭�祭� ������ ��������� ��ப�.

  ��� �ᯮ�짮���� �⤥�쭨� 䠩� � ���������:
  exiv2 -m cmd.txt file.jpeg
  ��樨 -m � -M  ����� �������஢��� � ����� �������, �ᯮ���� ����ﭭ.� �����
  ������ �� 䠩�� � ��६���.�.
  � cmd.txt ������� ��������� �����筮, ����� �ᯮ�짮���� ������ਨ:
  # �� ��������� ��ப� �.� ��६ � �� � ����窠�:
 ���������.......... ��� 䠩��
 �����. ��������....
 ����������.........
 */
FUNCTION Iptc_Foto(cNmFl)
  LOCAL dBeg,  dEnd, lSeekTtn
  LOCAL bPathDos2Linux, cPath, cFileNameNew, cFileName
  LOCAL cCmdSysCmd,cLogSysCmd

  netuse('sv','svjafa')
  netuse('stagtm')
  netuse('cskl')
  netuse('kln')
  netuse('kgp')
  netuse('etm')
  netuse('krn')
  netuse('knasp')
  netuse('mkeep')
  netuse('s_tag')

  netuse('phtdoc')

  set("PRINTER_CHARSET","cp1251")
  //set("PRINTER_CHARSET","koi8-u")
  SET DATE FORMAT "DD.MM.YYYY" //"yyyy-mm-dd"
  SET CENTURY ON

  i:=1
  sele phtdoc
  DBGoTop()
  Do While !eof()


    If phtdoc->Saved
      skip; loop
    EndIf


    // �� ����� 䠩�� ���� DocGuid ���
    lSeekTtn:=.F.

    // ��ॡ�� ��ਮ���
    dBeg=BOM(gDtd);  dEnd:=STOD('20170101') //STOD('20060901')
    Do While dBeg >= dEnd
      sele cskl
      DBGoTop()
      Do While !eof()
        if !(ent=gnEnt)
          sele cskl; skip;loop
        endif
        Pathr=gcPath_e + pathYYYYMM(dBeg) + "\" + alltrim(path)
        //outlog(__FILE__,__LINE__,Pathr)
        if !netfile('rs1',1)
          sele cskl; skip; loop
        endif
        // DocGuid �� ��� DtPhot ������ rs1

        netuse('rs1',,,1)
        OrdSetFocus('t2')
        if DBSeek(phtdoc->DocGuId)
          lSeekTtn:=.T.
          exit
        endif
        close rs1

        sele cskl
        DBSkip()
      EndDo
      If lSeekTtn
        exit
      EndIf
      dBeg:=ADDMONTH(dBeg,-1)
    EndDo

    If lSeekTtn
      // outlog(__FILE__,__LINE__,Pathr)
      // outlog(__FILE__,__LINE__,phtdoc->DocGuId)
      // �����(��� ��), �����ᮣ�.���� (��� ��)
      // �����(��� ��)
      sele rs1
      ktar=kta
      ktasr:=getfield('t1','ktar','s_tag','ksv')  // ktasr=ktas
      ktanr=agtm(rs1->ktas, rs1->nkkl,rs1->kpv) // ktan=agtm(rs1->ktas, rs1->kpl, rs1->kgp);

      // ���
      nktar:=getfield('t1','ktar','s_tag','fio')
      nktasr:=getfield('t1','ktasr','svjafa','nsv') // nktasr:=getfield('t1','ktasr','s_tag','fio')
      nktan:=getfield('t1','ktanr','s_tag','fio')

      // �����
       //    ����.��, �, ��த, �-�
      ngp:=getfield('t1','rs1->kpv','kgp','ngrpol')
      kln->(netseek("t1",'rs1->kpv'))
      // �����,�����,District,��ப�,*,
      cDistrict:=getfield("t1","kln->krn","krn","nrn")
      // ��ᥫ���� �㭪� (��த),��ᥫ���� �㭪� (��த),City,��ப�,*,
      cCity:=getfield("t1","kln->knasp","knasp","nnasp")

      // �����(����.����)
      // nkplr:=getfield('t1','rs1->nkkl','kln','nkl')

      // ���� Comment - ���� ᨬ���� ���(��������) �᫨ ����, � ����
      // � ����� ������਩
      mkeepr:=val(phtdoc->Comment)
      mkeepr:=IIf(mkeepr=0,102,mkeepr)
      nmkeepr=getfield("t1","mkeepr","mkeep","nmkeep")


      cFileName:= alltrim(phtdoc->FileName)+'.tmp'
      SET CONSOLE OFF
      SET PRINT ON
      SET PRINT TO (cFileName)
      outlog(__FILE__,__LINE__,cFileName)

      ??'# ���� (�����) � ��� ���  S32  �� ���� 007'
      ?'add Iptc.Application2.Byline'
      ??lower(' '+'�'+ltrim(str(ktar,4))+'.'+alltrim(nktar))

      ?'# ��������� ���� S32 �㯥ࠣ���'
      ?'add Iptc.Application2.BylineTitle'
      ??lower(' '+'�'+ltrim(str(ktasr,4))+'.'+alltrim(nktasr))

      ?'# �ᯮ�������, ���� S64 ������� �����ᨭ - ��'
      ?'add Iptc.Application2.CountryName'
      ??lower(' '+alltrim(ngp)+'.'+str(rs1->kpv,7))

      //?'# �ᯮ�������, ���� S32 ���� - 㫨�, ��� - ��'
      //?'add Iptc.Application2.SubLocation'
      //?''

      ?'# ��த, ���. �㭪�  S32'
      ?'add Iptc.Application2.City'
      ??lower(' '+alltrim(cCity))

      ?'# �������, ࠩ��  S32 ���쪨� ࠩ��'
      ?'add Iptc.Application2.ProvinceState'
      ??lower(' '+alltrim(cDistrict))

      // ?'# ���⥫�騪�'
      // ?'add Iptc.Application2.Source S32'
      // ?''
      ?'# �७� (������? ���� ����� ���) S128'
      ?'add Iptc.Application2.Copyright'
      ??lower(' '+'��'+ltrim(str(mkeepr,3))+'.'+alltrim(nmkeepr))

      cComment:=alltrim(substr(phtdoc->Comment,3+1))
      If !Empty(cComment)

        ?'#- ���祢� ᫮��, �� S128 ᨬ�����,'
        ?'#- add Iptc.Application2.Contact' //S64 ᮪� Jaffa ��祭쪨 ������਩'


        ?'# ������, �� S32 ᨬ�����,'
        ?'add Iptc.Application2.Credit' //S32 ᮪� Jaffa ��祭쪨 ������਩'
        ??lower(' '+left(alltrim(cComment),32))

        ?'#- ���窨�, �� S32 ᨬ�����,'
        ?'#- add Iptc.Application2.Sourse' //S32 ᮪� Jaffa ��祭쪨 ������਩'

      EndIf

      SET PRINT TO
      SET PRINT OFF
      SET CONSOLE ON

      close rs1

      // 㡥६ ^M
      cFileName:=STRTRAN(cFileName,')','\)')
      cFileName:=STRTRAN(cFileName,'(','\(')
      cCmdSysCmd:="cat ./";
         +cFileName ; //"app_jaffa.exe";
         +"| tr -d '\r'>";
         +left(cFileName,len(cFileName)-3)+"iptc";
         +" ; rm ./"+cFileName
         cLogSysCmd:=""
         SYSCMD(cCmdSysCmd,"",@cLogSysCmd)
      //outlog(__FILE__,__LINE__, cCmdSysCmd, cLogSysCmd)
      //����訬 ����

      cFileNameNew:=STRTRAN(phtdoc->FileName,')','\)')
      cFileNameNew:=STRTRAN(cFileNameNew,'(','\(')
      bPathDos2Linux:={|cPath|set(upper(left(cPath,1))+":")+STRTRAN(substr(cPath,3),'\',"/") }
      cPath:=EVAL(bPathDos2Linux,gcPath_e+"photodoc")
      //quit
      // �஢�ઠ �� ������ ����
      cCmdSysCmd:="exiv2 -pi";
      +" "+cPath+"/"+alltrim(cFileNameNew);
      +""
      cLogSysCmd:=""
      SYSCMD(cCmdSysCmd,"",@cLogSysCmd)
      //outlog(__FILE__,__LINE__, 'No Iptc data'$ cLogSysCmd,cCmdSysCmd, cLogSysCmd)
      If 'No Iptc data'$ cLogSysCmd
        cCmdSysCmd:="exiv2 -k -m";
        +" "+left(cFileName,len(cFileName)-3)+"iptc";
        +" "+cPath+"/"+alltrim(cFileNameNew);
        +""

        cLogSysCmd:=""
        SYSCMD(cCmdSysCmd,"",@cLogSysCmd)
        outlog(__FILE__,__LINE__, cCmdSysCmd, cLogSysCmd)
      Else
        cCmdSysCmd:="rm ./";
           +left(cFileName,len(cFileName)-3)+"iptc";
           +""
           cLogSysCmd:=""
           SYSCMD(cCmdSysCmd,"",@cLogSysCmd)
        outlog(__FILE__,__LINE__, cCmdSysCmd, cLogSysCmd)
      EndIf
      sele phtdoc
      netrepl('saved',{.t.})


    EndIf
    If ++i > 2000
      exit
    EndIf


    sele phtdoc
    DBSkip()
  EndDo

  nuse('phtdoc')
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  06-21-17 * 00:01:15am
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION  bank361email()
  LOCAL cFlMess, dDt
  LOCAL cListEMail:=;
  "zvada.aleksandr11@gmail.com, alex-mas82@ukr.net,"+;
  "sumyprodresurs@gmail.com,lista@bk.ru"
  //elenavitmark@ukr.net, 12-02-20 03:00pm
  if gnEnt=21
    cListEMail:='vadim_5@rambler.ru,lista@bk.ru,vadimkaluzhnij@gmail.com'
  endif

  // ��  -3 ���, � ⠪ -1
  dDt:= date() - Iif(DOW(date())=2,3,1)  //STOD('20170608') //DATE()
  dtBegr:=dtEndr:=date()

  IF UPPER("/dtBeg") $ cDosParam
    Dt_Beg_End(cDosParam,.T.,@dtBegr,@dtEndr)
  ELSE
    cDosParam += ' /DTBEG'+DTOS(dDt)+' /CLVRT' // ����� �� �ᯨ᭨�
    Dt_Beg_End(cDosParam,.T.,@dtBegr,@dtEndr)
  ENDIF

  dDt:=dtBegr

  cFlMn:=RIGHT(DTOS(dDt),6)+'op'

  If file(cFlMn+'.dbf')
    ERASE (cFlMn+'.dbf')
  endif
  outlog(__FILE__,__LINE__,"dtBegr,cDosParam",dtBegr,cDosParam)
  outlog(__FILE__,__LINE__,DOW(date()))

  netuse('DokZ')
  netuse('DokS')
  netuse('DokK')
  ordsetfocus('t1')

  DO WHILE .T.
    outlog(__FILE__,__LINE__,dDt)
    // ������ MN ���
    sele DokZ
    LOCATE for dDt = Ddc
    Do While FOUND()
      sele DokS
      ordsetfocus('t1') // mn

      If netseek('t1','DokZ->mn') // ��諨 ����
        lSeek:=.F.
        Do While DokZ->mn = DokS->mn
          // �஢�ਬ �� ����稥 �஢���� 311 361
          sele DokK
          if netseek('t1','DokS->mn,DokS->rnd')
            lSeek:=.F.
            Do While DokS->mn = DokK->mn .and. DokS->rnd = DokK->rnd
              // �஢�ਬ ������ �஢����
              If (STR(INT(bs_d/10^3),3) $ '311' .AND. bs_k=361001)
                lSeek:=.T.
                exit
              EndIf
              DokK->(DBSkip())
            EndDo
          endif

          If lSeek // ��諨 ����᫥���
            sele DokS
            copy to tmp1 next 1
            If !file(cFlMn+'.dbf')
              copy stru to (cFlMn)
              use (cFlMn) ALIAS opl new Exclusive
            EndIf
            sele opl
            append from tmp1
          EndIf

          DokS->(DBSkip())
        EndDo
      EndIf

      sele DokZ
      CONTINUE
    EndDo
    If Empty(Select('opl'))
      dDt--
      If BOM(gdTd) # BOM(dDt)
        exit // ��室 �� ⥪�饣� ��२����
      EndIf
    else
      exit
    Endif
  ENDDO


  nuse('dokz')
  nuse('doks')
  nuse('dokk')

  netuse('kln')
  netuse('knasp')
  netuse('opfh')


  cFlMess:='op_mess'+'.txt'
  set("PRINTER_CHARSET","koi8-u")
  set console off
  set print on

  Do Case
  Case Empty(Select('opl'))
    ?? Replicate('=',40)
    ? '����� �ணࠬ�� � ��ࠬ��ࠬ�'
    ? "dtBegr,cDosParam", dtBegr, cDosParam
    ?
    ? '!!! ������ ��� !!!'

  Case file(cFlMn+'.txt') .and. UPPER("/CLVRT") $ cDosParam
    // ���� 䠩� � ����� ��⮬��
    ?? Replicate('=',40)
    ? '����� �ணࠬ�� � ��ࠬ��ࠬ�'
    ? "dtBegr,cDosParam", dtBegr, cDosParam
    ?
    ? '!!! ����� 㦥 ���㦥�� !!!'
  OtherWise
    cFlMess:=cFlMn+'.txt'
    set print to (cFlMess)

    If !Empty(Select('opl'))

      sele opl
      DBGoTop()
      Do While !eof()
        kklr := opl->kkl

        knaspr=getfield('t1','kklr','kln','knasp')
        nnaspr=getfield('t1','knaspr','knasp','nnasp')
        nkler=getfield('t1','kklr','kln','nkle')
        opfhr=getfield('t1','kklr','kln','opfh')
        nsopfhr=getfield('t1','opfhr','opfh','nsopfh')
        nklr=alltrim(nnaspr)+' '+alltrim(nsopfhr)+' '+alltrim(nkler)
        nklr=upper(nklr)



        ??Replicate('=',40)
        ? DDC, '��', cNPlp, ssd, kkl
        ?'�����祭��:',BOsn
        ?'���⥫�騪:',nklr
        ?
        ?
        DBSkip()
      EndDo
      close opl
    ELSE
    EndIf

    set print to
    set print off
  EndCase



  nuse('kln')
  nuse('knasp')
  nuse('opfh')

  // quit

  cMessErr:=memoread(cFlMess)

  SendingJafa(cListEMail, {{ "","���⥦� ("+str(gnEnt,3);
  +") "+gcName_c+' '+DTOC(dDt,"YYYYMMDD")}},;
  cMessErr,;
  228)
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 �����..����..........�. ��⮢��  06-21-17 * 00:05:07am
 ����������.........
 ���������..........
 �����. ��������....
 ����������.........
 */
FUNCTION kop139_69()
  /*
  ��୨஢���� �த�� � ��� � ��� 139 � �⮏�⢥न� - 69 ��� 68
  */
  skr=228

  netuse('cskl')

  sele cskl
  netseek('t1','skr')
  pathr=gcPath_d+alltrim(path)
  gnKt=kt
  dirskr=alltrim(path)


  netuse('ctov')
  netuse('rs1')
  set order to 't1'
  netuse('rs2')

  sele rs2
  set rela to str(ttn,6) into rs1
  ordsetfocus('t2')
  count to t1 ;
  for rs1->kop=139 .and. (rs1->ktofp = -69 .or. rs1->ktofp = -68)
  outlog(__FILE__,__LINE__,'befo', t1, time())

  sele rs2
  set rela to
  ordsetfocus('t2')

  sele rs1
  DBGOTOP()
  Do While !eof()
    If (str(rs1->ttn,6) $ '254787 ') ;
      .or. rs1->kop=139 .and. (rs1->ktofp = -69 .or. rs1->ktofp = -68) ;
      .and. empty(rs1->dfp)
      ttnr:=rs1->ttn
      sele rs2
      If netseek('t2','ttnr')
        Do While ttnr = rs2->ttn
          mntovr:=rs2->mntov
          If kvp > 0
            mkeepr:=getfield('t1','mntovr','ctov','mkeep')
            If .T. .AND. mkeepr # 69 // T - �஢�ઠ 69
              outlog(__FILE__,__LINE__,'mkeepr # 69 ttn=',ttnr)
              sele rs2
              DBSkip()
              loop
            EndIf
            // �஢�ઠ �� �㡫� ��ப� '-'
            sele rs2
            nRec:=RecNo()
            locate for kvp < 0 ;
              while ttnr = rs1->ttn .and. mntovr = rs2->mntov
            If !found()
              DBGoTo(nRec)
              // ᤥ���� ��ப� � ����ᮬ
              arec:={}; getrec()
              netadd(); putrec()
              //arec[FieldPos('kvp')] *= -1
              netrepl('kvp',{kvp * (-1) })
            EndIf

            DBGoTo(nRec)
          EndIf
          DBSkip()
        EndDo

      EndIf
    EndIf
    sele rs1
    DBSkip()
  EndDo

  sele rs2
  set rela to str(ttn,6) into rs1
  ordsetfocus('t2')
  count to t1 ;
  for rs1->kop=139 .and. (rs1->ktofp = -69 .or. rs1->ktofp = -68)
  outlog(__FILE__,__LINE__,'afte', t1, time())

  sele rs2
  copy to t1;
  field  kvp, ttn, mntov ;
  for rs1->kop=139 .and. (rs1->ktofp = -69 .or. rs1->ktofp = -68)

    //foxsele()
  RETURN (NIL)
