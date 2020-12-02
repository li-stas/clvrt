#include "Common.ch"

#define KPL_DZ iif(date()<stod('20270401'),10,0) // порог задолжености взаиморасчетах
#define KPL_DZ9 iif(date()<stod('20170709'),0,nSumDZ_9) // проверка долга по всем напр
#define KPL_NCNTDAY3  3 // технические дни
#define KPL_NCNTDAY9  21 // (3+6) к-во дней для блок Пл-ка по ВСЕМ напр.
#define KPL_NCNTYEAR3 365*3  // документы 3 летней давности не берем
#define KPL_TZVK_KGP  .T.  // задание с учетом Гр.Пол
#define KPL_LSKOP139  "129;139;170;188"  // задание с учетом Гр.Пол

#define KPL_DZ_ROUND 1 // округление задолжености взаиморасчетах 1- до 10

***************
function skpk()
  ***************
  LOCAL dDtTmLog, lAccDeb, n1:=0
  LOCAL cLsKop139:=KPL_LSKOP139 //кода операций возврата и списания
  DIRMAKE("crm-log")
  // SET DATE FORMAT "yyyy-mm-dd"
  dDtTmLog:=""//DTOC(DATE())+"T"+CHARREPL(":", TIME(), "-")

  set print to ("crm-log\ttn_"+dDtTmLog+".log") ADDI
  set prin on
  set cons off
  netuse('cskl')
  netuse('dclr')
  netuse('tara')
  netuse('cgrp')
  netuse('kln')
  netuse('kpl')
  netuse('kgp')
  netuse('kgptm')
  netuse('krntm')
  netuse('nasptm')
  netuse('rntm')
  netuse('mkeep')
  netuse('mkeepe')
  netuse('brand')
  netuse('TCen')
  netuse('klnnac')
  netuse('brnac')
  netuse('mnnac')
  netuse('ctov')
  netuse('mkcros')
  netuse('tmesto')
  netuse('stagtm')
  netuse('etm')
  netuse('s_tag')
  netuse('dokko')
  netuse('klndog')
  netuse('nap')
  netuse('naptm')
  netuse('kplnap')
  netuse('ktanap')
  netuse('kps')
  netuse('kplbon')
  netuse('klnlic')
  netuse('phtdoc')


  netuse('dkkln')
  If file(gcPath_ew+"deb\accord_deb"+".dbf")
    USE (gcPath_ew+"deb\accord_deb") ALIAS skdoc NEW SHARED READONLY
    SET ORDER TO TAG t1
    lAccDeb:=.T.
  EndIf
  USE (gcPath_ew+"deb\deb") ALIAS deb NEW SHARED READONLY
  SET ORDER TO TAG t1


  lindx('lphtdoc','phtdoc')
  luse('lphtdoc')
  lindx('lrs1','rs1')
  luse('lrs1')
  lindx('lrs2','rs2')
  luse('lrs2')

  store '' to coptr,cboptr,cxoptr,cuchr,cotpr,cdopr,cxotpr
  store 0 to doguslr
  skpkr=0

  store 0 to onofr,opbzenr,opxzenr,;
             oTCenpr,oTCenbr,oTCenxr,;
             odecpr,odecbr,odecxr
  store 1 to prdecr,prdec_fr

  sele setup
  locate for ent=gnEnt
  if foun()
     if fieldpos('skpk')#0
        reclock()
        if skpk=0
            repl skpk with 1
        endif
        skpkr=skpk
        netrepl('skpk',{skpk+1})
     endif
  endif
  ***************************************
  dirskpkr='s'+allt(str(skpkr,10))
  if gnEnt=20.and..f.

     if dirchange(dirskpkr)#0
        dirmake(dirskpkr)
     endif
     dirchange(gcPath_l)

     sele lrs1
     copy to (dirskpkr+'/lrs1b.dbf')
     sele lrs2
     copy to (dirskpkr+'/lrs2b.dbf')
  endif
  ****************************************
  // сохраниение фото 02-17-17 12:49am
  sele lphtdoc
  If !EMPTY(LastRec())
    lCdb:=.t.

    #ifdef __CLIP__
      set translate path off
    #endif
    // проверка Ид в осн. табл-це

    sele lphtdoc
    DBGoTop()
    Do While !eof()

      //outlog(__FILE__,__LINE__,lphtdoc->DocGuId, gcPath_e)
      // поиск в Заявках ТТ
      sele lrs1
      locate for DocGuId = lphtdoc->DocGuId
      If !found()
        // поиск в rs1
        skr=gnEntrm2skl(0)
        PathSkr:=allt(getfield('t1','skr','cskl','path'))
        Pathr=gcPath_d + PathSkr
        netuse('rs1',,,1)
        OrdSetFocus('t2')
        if !DBSeek(lphtdoc->DocGuId)
          use
          // в прошлом месяце
          dtpr=addmonth(gdTd,-1)
          Pathr=gcPath_e + pathYYYYMM(dtpr)+ '\' + PathSkr
          if netfile('rs1',1)
            netuse('rs1',,,1)
            OrdSetFocus('t2')
            DBSeek(lphtdoc->DocGuId)
           endif
        endif

      endif

      If found()
        ktar=kta
        kgpr=iif(alias()='RS1',kpv,kgp) // может быть перевернута шапка
        ddcr=ddc
        TimeCrtr=TimeCrt
        If alias()='RS1'
          use
        EndIf

        cPrefDirKta:=Iif(gnEnt=20,'k','p')
        cDir_kta:=cPrefDirKta+IIF(lCdb,"cdb","")+PADL(LTRIM(STR(ktar,3)), 3, "0")
        cOldFileName := cDir_kta + '\' + allt(lphtdoc->FileName)
        // прорвекра на передачу ФОТО
        If !FILE(cOldFileName)
          outlog(__FILE__,__LINE__,'нет jpg', cOldFileName)
          sele lphtdoc;  dbDelete();  DBSkip()
          loop
        EndIf

        // проверка на повторную выгрузку Фото
        sele phtdoc
        OrdSetFocus('t2') // по фото
        If DBSeek(lphtdoc->PhotGuId)
          outlog(__FILE__,__LINE__,'уже есть lphtdoc->PhotGuId', lphtdoc->PhotGuId)
          DELETEFILE(cOldFileName)
          sele lphtdoc;  dbDelete();  DBSkip()
          loop
        EndIf

        // формируем новое имя файла
        sele lphtdoc
        mkeepr:=val(allt(Comment))
        if (mkeepr > 999)
           mkeepr:= 999
        endif
        mkeepr:=iif(mkeepr=0,'000',padl(ltrim(str(mkeepr,3)),3,'0'))
        cNewFileName := padl(allt(str(kgpr,7)),7,'0')+'-'+mkeepr+'-'+DTOS(ddcr)

        // проверка на повторную закгрузк Фото
        sele lphtdoc
        nRec:=RecNo()
        OrdSetFocus('t3') // по имени
        i:=1;   cSuf:=''
        Do While DBSeek(cNewFileName + cSuf)
          cSuf := '(' + ltrim(str(i++)) + ')'
        EndDo

        sele phtdoc
        OrdSetFocus('t3') // по имени
        Do While DBSeek(cNewFileName  + cSuf)
          cSuf := '(' + ltrim(str(i++)) + ')'
        EndDo

        // получил суфикс для файла
        cNewFileName += cSuf

        sele lphtdoc
        OrdSetFocus('t1')
        goto nRec

        // проверка валидности фото
        // фото должно быть сделано после закрытия в течнии 20 мин.
        lValidPhoto:=.t.
        dTimeCrt:=Kpk_DateTime(TimeCrtr)
        Do Case
        Case lphtdoc->DtPhot # dTimeCrt  // даты не совпадают
          lValidPhoto:=.F.
        Case TimeToSec(lphtdoc->TmPhot) - TimeToSec(RIGHT(TimeCrtr,8)) ;
              > 20 * (60*60) // больше 20 мин
          lValidPhoto:=.F.
        EndCase
        If !lValidPhoto
          cNewFileName += '-@'
        EndIf

        cNewFileName := cNewFileName + '.jpg'

        nCpBt := FileCopy(cOldFileName, ;
                    gcPath_e+'photodoc'+'\'+ cNewFileName)

        If nCpBt > 0
          nCpBt := DELETEFILE(cOldFileName)
          lphtdoc->FileName := cNewFileName
        else
          // ошибка копировнаия
          sele lphtdoc;  dbDelete()
        EndIf
      else
        // не найден док-т
        sele lphtdoc;  dbDelete()
        outlog(__FILE__,__LINE__,'не найден lphot rs1',lphtdoc->DocGuId, gcPath_e)

      EndIf
      sele lphtdoc
      skip
    EndDo

    // копировние файлов
    copy to tmpphtdc
    sele phtdoc
    append from tmpphtdc

    #ifdef __CLIP__
      set translate path on
    #endif
  else
    If alias()='RS1'
      use
    EndIf
  EndIf

  #ifdef __CLIP__
     outlog(__FILE__,__LINE__,"* Проверка ")
  #endif
  ///               * Проверка              ////////////
  sele lrs2
  set orde to tag t1
  sele lrs1
  set orde to tag t1
  go top
  ttn_rr=0
  do while !eof()
    // валидность заявки
      //outlog(__FILE__,__LINE__,RecNo(),date(),TIME(),"skl",skl,'TTH',lrs1->ttn,"DocGuid",DocGuid)
    netrepl('kps',{0})
    vo_rr:=vo
    kop_rr:=kop
    kplr:=kpl
    ttn_rr:=ttn

    if lrs1->spd = 1 // док не обработан полностью
      sele lrs1
      netrepl('kps',{999999})
      outlog(__FILE__,__LINE__,"DocGuId",lrs1->DocGuId,'lrs1->spd = 1 // док не обработан полностью TTN=999999')
      skip
      loop
    endif

    If at(upper('-т'),upper(npv)) # 0 // удалить товарую часть
      outlog(__FILE__,__LINE__,'// удалить товарую часть')
      sele lrs2
      set orde to tag t1
      netseek('t1','ttn_rr')
      delete while ttn=ttn_rr
      sele lrs1
      netrepl('npv',{' '})
    EndIf

    // проверка на к-во строк
    sele lrs2
    set orde to tag t1
    netseek('t1','ttn_rr')
    count to KolPosr while ttn=ttn_rr

    sele lrs1
    netrepl('KolPos',{KolPosr})
    If KolPosr > 80
      If vo_rr=9 .or. (vo_rr=6 .and. kop_rr=188) // продажа
        sele lrs1
        netrepl('kps',{999999})
        outlog(__FILE__,__LINE__,"DocGuId",lrs1->DocGuId,'KolPosr > 80 TTN=999999')
        skip
        loop
      Else // возрат - приход
        // может больше 80-ти
      EndIf
    EndIf

    if kop=174
      sele lrs2
      set orde to tag t1
      if netseek('t1','ttn_rr')
        mkeepr=0
        do while ttn=ttn_rr
          MnTovr=MnTov
          if int(MnTovr/10000)<2 //0 || 1 тара и стекло
            skip
            loop
          endif
          mkeep_r:=getfield('t1','MnTovr','ctov','mkeep')
          if mkeep_r=0
            mkeepr=0
            exit
          endif
          if mkeepr=0
            mkeepr=mkeep_r
          else
            if mkeepr#mkeep_r
              mkeepr=0
              exit
            endif
          endif
          sele lrs2
          skip
        enddo
        if mkeepr=0
          sele lrs1
          netrepl('kps',{999999})
          outlog(__FILE__,__LINE__,'kop=174 mkeepr=0 TTN=999999')
          skip
          loop
        else
          if !netseek('t1','kplr,mkeepr','kplbon')
            sele lrs1
            netrepl('kps',{999999})
            outlog(__FILE__,__LINE__,'kop=174 ' ;
            + "!netseek('t1','kplr,mkeepr','kplbon')" ;
            + ' TTN=999999')
            skip
            loop
          endif
        endif
      endif
    endif

    sele lrs1
    if vo_rr=9 .or. (vo_rr=6 .and. kop_rr=188)
      if kop=0
          netrepl('kop',{160})
      endif
      if kopi=0
        netrepl('kopi',{kop})
      endif
    else

      If allt(nnz) $ '999;997' // переоценка
        // официанлынй возрат
        If empty(npv) // нет указания на возратную накладную
          SkVzr:=NdVz
          TtnVzr:=KvpVzr:=0
          npvr:=TtnVzrLast(SkVzr,@TtnVzr,@KvpVzr)
          If !Empty(KvpVzr)
            // заменим к-во по возврату
            sele lrs2
            netseek('t1','ttn_rr')
            KvpVzr:=MIN(KvpVzr,kvp)
            netrepl('kvp',{KvpVzr})
            // заменим к-во по выписке Акции ТТН+1
            sele lrs2
            netseek('t1','ttn_rr+1')
            netrepl('kvp',{KvpVzr})
            sele lrs1
            netrepl('npv',{npvr})
          else
            outlog(__FILE__,__LINE__,'DELE Переоценка удалена нет ТТН_ВЗ',allt(lrs1->DocGuId))
            sele lrs2
            netseek('t1','ttn_rr')
            netdel()
            sele lrs2
            netseek('t1','ttn_rr+1')
            netdel()
          EndIf
        else // переоценка по 169 без накладной, по цена продажи сейчас
          //SkVzr:=NdVz
          //TtnVzr:=KvpVzr:=0
          //npvr:=TtnVzr169Last(SkVzr,@TtnVzr,@KvpVzr)
          //
          // берем текущию цену из прайса по договорным условиям
          sele lrs1
          nkklr=kpl
          kpvr=kgp

          kopr=169 // нужно воостановить цену по этому коду
          qr=mod(kopr,100)
          vor=9

          sele lrs2
          netseek('t1','ttn_rr')
          // инициализация переменных
          MnTovr=MnTov
          MnTovTr=getfield('t1','MnTovr','ctov','MnTovT')


          sele cskl
          netseek('t1','lrs1->NdVz') //склад возврата
          Pathr=gcPath_d+allt(path)
          netuse('soper',,,1)
          TCenr=getfield('t1','0,1,vor,qr','soper','TCen')
          CZenr=allt(getfield('t1','TCenr','TCen','zen'))
          ZenPr=getfield('t1','MnTovTr','ctov',CZenr)

          mkeepr=getfield('t1','MnTovTr','ctov','mkeep')
          Izgr=getfield('t1','MnTovTr','ctov','Izg')
          ZenPr=getfield('t1','MnTovTr','ctov',CZenr)

          discountr:=kkl_discount(kplr,Izgr,MnTovTr)*(-1)

          outlog(3,__FILE__,__LINE__,"ZenPr,discountr",ZenPr,discountr)
          sele lrs2
          netrepl("Zen",{round(ZenPr - (ZenPr / 100 * discountr),3)})

          /*
          //    в однин документ (нужно еще ниже исправлять)
          // сворачиваем в одну
          sele lrs1
          netseek('t1','ttn_rr+1') // DBSkip(+1) // продажа
          netdel()
          sele lrs2
          netseek('t1','ttn_rr+1') // DBSkip(+1) // продажа
          netrepl("ttn,kvp",{ttn_rr,kvp*(-1)})  // перенос в переоценку
          sele lrs1
          netseek('t1','ttn_rr')
          */

        EndIf
      EndIf

      // npv - какой товар возврат, если пусто то тара
      sele lrs1
      if empty(npv)  // Тара
        sele lrs1
        if kop=0
          netrepl('kop,vo',{108,1})
        endif
        netrepl('bprz',{1}) // bprz признак тары
      else
        TtnVzr_r := val(allt(npv))
        if TtnVzr_r > 999999 //.or. TtnVzr_r = 0
          // Товар ТТН ошибка
          outlog(__FILE__,__LINE__,"DocGuId",lrs1->DocGuId,'val(allt(npv)) >999999 || =0 TTN ВЗР=',TtnVzr_r)
          sele lrs1
          netrepl('kps',{999999})
          skip
          loop
        else // нормальная ТТН
          If kopi=169  // не оборатабываем
            If allt(nnz) $ '999;997'
              netrepl('bprz,kop,vo',{2,107,1}) // bprz признак Товар без валидации
            Else
              netrepl('bprz,kop,vo',{2,108,1}) // bprz признак Товар без валидации
            EndIf
          Else
            If allt(nnz) $ '999;997'
               netrepl('bprz,kop,vo',{0,107,1}) // bprz признак Товар
            Else
              netrepl('bprz,kop,vo',{0,108,1}) // bprz признак Товар без валидации
            EndIf
          EndIf
        endif
      endif
    endif
    //      netrepl('kps','0')
    if gnEnt=20.and.gnEntRm=0
      sele mkeep
      if fieldpos('BlkMk')#0
           BlkMk_r=0
           sele lrs2
           set orde to tag t1
           if netseek('t1','ttn_rr')
              do while ttn=ttn_rr
                 MnTovr=MnTov
                 if int(MnTovr/10000)<2
                    skip
                    loop
                 endif
                 mkeep_r=getfield('t1','MnTovr','ctov','mkeep')
                 BlkMk_r=getfield('t1','mkeep_r','mkeep','BlkMk')
                 if BlkMk_r=1 // Блокировка выписки всего
                    exit
                 endif
                 sele lrs2
                 skip
                 if ttn#ttn_rr
                    exit
                 endif
              enddo
              if BlkMk_r=1
                sele lrs1
                netrepl('kps',{999999})
                outlog(__FILE__,__LINE__,'BlkMk_r=1 TTN=999999 mkeep_r',mkeep_r)
                skip
                loop
              endif
           endif
        endif
     endif

     sele lrs1
     if gnEnt=20
        if empty(skl)
           skr=228
        else
           skr=skl
        endi
     endif
     if gnEnt=21
        if empty(skl)
           skr=232
        else
           skr=skl
        endi
     endif
     sele cskl
     //if (__dblocate({|| sk == skr }), found())
     if !netseek('t1','skr')
      #ifdef __CLIP__
        outlog(__FILE__,__LINE__,"Нет склада в CSKL","skr",skr)
      #endif
      sele lrs1
      netrepl('kps',{999999})
      skip
      loop
     else
        if ent#gnEnt
            #ifdef __CLIP__
              outlog(__FILE__,__LINE__,;
              "Склад не этого препр","ent",ent,"gnEnt",gnEnt,"skl",skl,"skr",skr)
              outlog(__FILE__,__LINE__,"kta:",lrs1->kta,"skl:",lrs1->skl)
            #endif
            #ifdef __CLIP__
              set translate path off
            #endif
          cFileNameXml:="To1C.xml"
          ktar:=lrs1->kta
          cPrefDirKta:=Iif(gnEnt=20,;
                            'k','p')
          cDir_kta:="-"+cPrefDirKta+PADL(LTRIM(STR(ktar,3)), 3, "0")
          DIRMAKE(cDir_kta)
          dDtTmLog:=DTOS(DATE())+"T"+CHARREPL(":", TIME(), "-")
          #ifdef __CLIP__
              COPY FILE (cDir_kta+'\'+cFileNameXml) TO (cDir_kta+'\'+"To1C-"+dDtTmLog+".xml")
              COPY FILE ('.\'+cFileNameXml) TO (cDir_kta+'\'+"To1C-"+dDtTmLog+".xml")
              COPY FILE lrs1.dbf TO (cDir_kta+'\'+"lrs1-"+dDtTmLog+".dbf")
          #endif
          #ifdef __CLIP__
              set translate path on
          #endif
          sele lrs1
          netrepl('kps',{999999})
          skip
          loop
        endif
     endif

     sele cskl
     gnRasc=rasc
     sele lrs1
     sklr=skl
     kgpr=kgp
     DocGuid_r:=DocGuid
     DocGuid0_r:=DocGuid0(DocGuid)
     bprzr=bprz
     if vo_rr=9 .or. (vo_rr=6 .and. kop_rr=188)
        if skr=ngMerch_Sk241 //мерч склад
           sklr=kgpr
           if sklr=0
              sele lrs1
              netrepl('kps',{999999})
              skip
              loop
           endif
        endif
     endif

     /////// проверка на DocGuid  прошлого месяца
     dtpr=addmonth(gdTd,-1)
     ypr=year(dtpr);   mpr=month(dtpr)
     sele cskl
     pathpr=gcPath_e + pathYYYYMM(dtpr)+ '\' + allt(path)
     Pathr=pathpr
     gnKt=kt
     if netfile('rs1',1)
        netuse('rs1','rs1p',,1)
        netuse('pr1','pr1p',,1)
        Ttnr=0
        if vo_rr=9 .or. (vo_rr=6 .and. kop_rr=188)
           Ttnr:=getfield('t2','DocGuid_r','rs1p','ttn')
        else
           Ttnr:=getfield('t5','DocGuid_r','pr1p','mn')
        endif
        nuse('rs1p')
        nuse('pr1p')
        if Ttnr#0
          sele lrs1
          netrepl('kps',{Ttnr})
        endif
     endif
     ////////////////////////////////////////////////
     /////// проверка на DocGuid  текущего месяца
     sele cskl
     Pathr=gcPath_d+allt(path)
     nuse('rs1');  nuse('pr1')
     netuse('rs1',,,1)
     netuse('pr1',,,1)
     Ttnr=0
     if vo_rr=9 .or. (vo_rr=6 .and. kop_rr=188)
       Ttnr:=getfield('t2','DocGuid_r','rs1','ttn')
     else
       Ttnr:=getfield('t5','DocGuid_r','pr1','mn')
     endif
     nuse('rs1')
     nuse('pr1')
     if Ttnr#0
       sele lrs1
       netrepl('kps',{Ttnr})
     endif
     sele lrs1
     skip
     if eof()
       exit
     endif
  enddo

  // copy to tlrs1
   //quit
  // Разделение акции,БСО,168

  ttn_rrr=ttn_rr  // Последняя заявка в lrs1
  ttn_rr=ttn_rr+1 // счетчик ttn для lrs1

  crtt('tPrAkc','f:prAkc c:n(2) f:kol c:n(3)')
  sele 0
  use tPrAkc excl

  #ifdef __CLIP__
     outlog(__FILE__,__LINE__,"* Разделение акции,БСО,168")
  #endif

  sele lrs1
  go top
  do while !eof()
    if kps#0
      skip ;        loop
    endif
    if vo#9
      skip ;        loop
    endif
    if bprz#0
      skip  ;        loop
    endif
    if prAkc#0
      skip   ;        loop
    endif
    if kop=168
      skip    ;        loop
    endif
    RcLrs1r=recn()
    ttn_r=ttn
    kop_r=kop
    store 0 to kol_r,kola_r,kbso_r,knbso_r
    sele tPrAkc
    zap
    appe blank
    sele lrs2
    set orde to tag t1
    if netseek('t1','ttn_r')
      do while ttn=ttn_r
          MnTov_r=MnTov
          akc_r=getfield('t1','MnTov_r','ctov','akc')

          kg_r=int(MnTov_r/10000)
          lic_r=getfield('t1','kg_r','cgrp','lic')
          if lic_r=0
            knbso_r=knbso_r+1
          else
            kbso_r=kbso_r+1
          endif
          netrepl('izg,tn',{akc_r,lic_r})

          sele tPrAkc
          locate for prAkc=akc_r
          if !foun()
            appe blank
            repl prAkc with akc_r
          endif
          repl kol with kol+1
          sele lrs2
          skip
          if ttn#ttn_r
            exit
          endif
      enddo
    endif

     sele tPrAkc
     go top
     do while !eof()
       prAkcr=prAkc
       sele lrs1
       go RcLrs1r
       netrepl('DocId',{ttn_r})
       if prAkcr=0
         if gnEnt=20
           if kop_r=126
             netrepl('kop,kopi',{160,kop_r})
           endif
         endif
         if gnEnt=21
           netrepl('kopi',{kop_r})
         endif
         if gnEnt=20.and.kop_r=169 //.and.gnEntrm=0
           pr168r=0 // Признак 340 в документе 169
           sele lrs2
           set orde to tag t1
           if netseek('t1','ttn_r')
             do while ttn=ttn_r
               if tn#0
                 pr168r=1
                 exit
               endif
               sele lrs2
               skip
               if ttn#ttn_r
                 exit
               endif
             enddo
           endif
           if pr168r=1
             sele lrs1
             arec:={}; getrec()
             netadd(); putrec()
             DocGuid_r=''
             netrepl('TIMECRT,TIMECRTFRM,gpslat,gpslon',{'','','',''},1)
             netrepl('ttn,DocGuid,prAkc,kop,kopi',{ttn_rr,DocGuid_r,0,168,168})
             sele lrs2
             set orde to tag t1
             if netseek('t1','ttn_r')
               do while ttn=ttn_r
                 rcLrs2r=recn()
                 if tn#0
                   arec:={}; getrec()
                   netadd(); putrec()
                   netrepl('ttn',{ttn_rr})
                   go rcLrs2r
                   netdel()
                 endif
                 sele lrs2
                 skip
                 if ttn#ttn_r
                   exit
                 endif
               enddo
             endif
             ttn_rr=ttn_rr+1
           endif
         endif
      else
        arec:={}; getrec()
        netadd(); putrec()
        DocGuid_r=''
        netrepl('TIMECRT,TIMECRTFRM,GPSLAT,GPSLON',{'','','',''},1)
        netrepl('ttn,DocGuid,prAkc',{ttn_rr,DocGuid_r,prAkcr})
        if gnEnt=20
          netrepl('kop,kopi',{177,177})
        endif
        if gnEnt=21
          netrepl('kopi',{177})
        endif
        sele lrs2
        set orde to tag t1
        if netseek('t1','ttn_r')
          do while ttn=ttn_r
            rcLrs2r=recn()
            if izg#0
              if izg=prAkcr
                arec:={}
                getrec()
                if prAkcr#3 // Переместить акцийный товар в другую ТТН
                  netadd(); putrec()
                  netrepl('ttn',{ttn_rr})
                  go rcLrs2r
                  netdel()
                else // prAkcr=3 // 4+2 Добавить акцийный товар в другую ТТН
                  kvpr=int(kvp/4)
                  if kvpr>=1
                    netadd(); putrec()
                    netrepl('ttn,kvp',{ttn_rr,kvpr*2})
                  endif
                  go rcLrs2r
                endif
              endif
            endif
            sele lrs2
            skip
            if ttn#ttn_r
              exit
            Endif
          enddo
        endif
        ttn_rr=ttn_rr+1
      endif
      sele tPrAkc
      skip
      if eof()
        exit
      endif
    enddo

    sele lrs1
    go RcLrs1r
    skip
    if eof()
        exit
    endif
  enddo
  sele lrs1;   skip -1
  #ifdef __CLIP__
    outlog(__FILE__,__LINE__,RecNo(),date(),TIME(),"skl",skl,'TTH',lrs1->ttn,"DocGuid",DocGuid)
  #endif
  sele tPrAkc
  use
  erase tPrAkc.dbf

  if gnEntRm=0 // для основного пр-тия .and. gnEnt=20 off 02-05-18 04:26pm
    tMkKop("169",cLsKop139+iif(gnEnt=21,';169',''))
  endif

  if gnEnt=20
    tMkKop("129",cLsKop139) //cKop:="129"

    sele cskl
    Pathr=gcPath_d+allt(path)
    netuse('rs1')
    netuse('rs2')
    rs1->(ordsetfocus('t1'))
    sele rs2
    set rela to str(ttn,6) into rs1
    rs2->(ordsetfocus('t4'))

    tMkKop("139",cLsKop139)

    nuse('rs1')
    nuse('rs2')

  endif

  //quit

  ///
  // * Формирование документов
  ///
  iCntRun:=1
  nKtaDo:=0
  #ifdef __CLIP__
     outlog(__FILE__,__LINE__,"* Формирование документов")
  #endif
  // wait
  ****************************************
  if gnEnt=20.and..f.
     sele lrs1
     copy to (dirskpkr+'/lrs1e.dbf')
     sele lrs2
     copy to (dirskpkr+'/lrs2e.dbf')
  endif
  ****************************************
  sele lrs1
  go top
  //wait
  do while !eof()
    DBCOMMITALL()
     sele lrs1
     RcLrs1r=recn()
      if kop=129.or.kop=139
      //wait
      endif
     IF gnEnt=21
       outlog(__FILE__,__LINE__,RecNo(),"kps",kps,date(),TIME())
       outlog(__FILE__,__LINE__,"skl",skl,'TTH',lrs1->ttn ,"DocGuid",DocGuid)
     ENDIF
     if kps # 0 //// уже есть или неправильная заявка
       skip
       loop
     endif
     IF (++iCntRun) > 2 .and. gnEnt=21
       //EXIT
       //outlog(__FILE__,__LINE__,iCntRun)
     ENDIF

     /// обработка по одному ТА
     IF nKtaDo = 0
       nKtaDo:=kta
          #ifdef __CLIP__
           outlog(__FILE__,__LINE__,"KTA",nKtaDo)
          #endif
     ELSEIF nKtaDo # kta
        // skip ;        loop
     ENDIF
     ////////////////////////
      kplr=kpl
      kgpr=kgp
      cdpp_r=subs(timecrtfrm,1,10)
      cdppr=subs(cdpp_r,9,2)+'.'+subs(cdpp_r,6,2)+'.'+subs(cdpp_r,1,4)
      dppr=ctod(cdppr)

     if vo=9 .or. (vo=6 .and. kop=188)  // Продажа || переброска
       sele etm
       if netseek('t2','kplr,kgpr')
         netrepl('dpp',{dppr})
       endif
       sele lrs1
       if gnEnt=20.and.kop=169.and.mk169=0
         Vo9Nof()
       endif
       sele lrs1
       go RcLrs1r
       #ifdef __CLIP__
       outlog(__FILE__,__LINE__,LTRIM(STR(++n1)),"ТТН - Товарный документ",RecNo(),date(),TIME(),"sk",skr,"skl",sklr,'TTH',lrs1->ttn,"DocGuid",DocGuid)
       #endif
       vo9(lAccDeb,cLsKop139)
     else     // Возврат
       vo1(lrs1->bprz)  // 1 тара 0 - товар 2- товар без валидации
     endif
     sele lrs1
     go RcLrs1r
     skip
     if eof()
        exit
     endif
  enddo
  nuse()
  If !empty(select("skdoc"))
     close skdoc
  EndIf
  set prin off
  set print to
  set cons on
     outlog(__FILE__,__LINE__,"!!закончили",n1)
  return .t.

*********************
Static Function Rs2tvi(kolr,nl_ktl)
  *********************
  local kvpr,nZenNew
  kgr=int(MnTovr/10000)


  ZenPr=getfield('t1','MnTovTr','ctov',CZenr)
  izgr:=getfield("t1","MnTovTr","ctov","izg")

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
     zenr=ZenPr*(1+nacr/100)
  else
     zenr=ZenPr
  endif

  KolAkcr=getfield('t1','MnTovr','ctov','kolakc')
  if KolAkcr#0
     ZenAk(MnTovr,kolr)
  endif

  sele tov
  MnTovr=MnTov

  sele tovm
  set orde to tag t1
  if netseek('t1','sklr,MnTovr',,,1)
     reclock()
     rctovm_r=recn()
     sele tov
     reclock()
     rctov_r=recn()
     otvr=otv
     if otvr=1
        otv_r=2
     else
        otv_r=0
     endif
     osv_r=osv
     osvo_r=osvo
     post_r=post
     kpsr=post
     ktl_r=ktl
     ktlp_r=ktl
     MnTov_r=MnTov
     MnTovP_r=MnTov
     prboxr=at('ящ',nat)
     rcPr2o1r=0
     amnp_r=0

     // регизтарици протокола продаж
     if otvr=1 .and. nl_ktl=0 // нет указния КТЛ
       /********************************/
       //      blkotv()
       SeekRecNo4ProtSale(@rcPr2o1r, post_r, ktl_r)
       /********************************/
     endif

     sele tov
     if skr=ngMerch_Sk241 //мерч склад
        osvr:=kolr
        osvor:=0
     else
        if otvr=0
           osvr:=osv
           osvor:=0
        else
           osvr:=0
           osvor:=osvo
           if fieldpos('minosvo')#0
              osvor:=osvor-minosvo
           endif
        endif
     endif
     optr=opt
     izgr=izg
     k1tr=k1t
     upakr=upak
     store 0 to osv_r,osvo_r

     if nl_ktl=0 // нет указния КТЛ
       if otvr=0
         if osvr>0
           if osvr<kolr
             kvp_r=osvr
             kolr=kolr-osvr
           else // osvr>=kolr
             kvp_r=kolr
             kolr=0
           endif
           osv_r=osv-kvp_r
           osvo_r=0
         else
           return kolr
         endif
       else
         if osvor>0
           if osvor<kolr
             kvp_r=osvor
             kolr=kolr-osvor
           else // osvor>=kolr
             kvp_r=kolr
             kolr=0
           endif
           osvo_r=osvo-kvp_r
           osv_r=0
          else
            return kolr
          endif
       endif
     else // указ-ние КТЛ
       kvp_r := kolr
       osv_r -= kolr  // а может и уваличивать для подвержнеия
     endif
     ktlr=ktl
     netrepl('osv,osvo',{osv_r,osvo_r})

     sele tovm
     if skr=ngMerch_Sk241 //мерч склад
        osvr=kolr
        osvor=0
     else
        osvr=osv
        osvor=osvo
     endif
     if otvr=0
        osv_r=osvr-kvp_r
        osvo_r=osvor
     else
        osvo_r=osvor-kvp_r
        osv_r=osvr
     endif
     netrepl('osv,osvo',{osv_r,osvo_r})

     nooptr=getfield('t1','MnTovr','ctov','noopt')

     sele rs2
     if !netseek('t3','Ttnr,ktlr,0,ktlr')
        netadd()
        netrepl('ttn,MnTovP,MnTov,zen,bzen,izg,ZenP,bZenP,ktl,ktlp,prZenP,prbZenP,pzen,pbzen,otv,amnp,tn',;
                {Ttnr,MnTovr,MnTovr,zenr,zenr,izgr,ZenPr,ZenPr,ktlr,ktlr,nacr,nacr,nacr,nacr,otv_r,amnp_r,nooptr})
        if fieldpos('DocId')#0
           if DocId_r#0
              netrepl('DocId',{DocIdr})
           else
              netrepl('DocId',{0})
           endif
        endif
        if fieldpos('TCenp')#0
           netrepl('TCenp',{TCenr})
        endif
  //      netrepl('atnac',{kolakcr})
        sele rs2
        srr=roun(kvp_r*optr,2)
        svpr=roun(kvp_r*zenr,2)
        netrepl('sr,svp,kvp',{sr+srr,svp+svpr,kvp+kvp_r})
        sele rs2m
        if !netseek('t3','Ttnr,MnTovr,0,MnTovr')
           netadd()
           netrepl('ttn,MnTovP,MnTov,zen,bzen,izg,ZenP,bZenP,ktl,ktlp,prZenP,prbZenP,pzen,pbzen',;
                   {Ttnr,MnTovr,MnTovr,zenr,zenr,izgr,ZenPr,ZenPr,0,0,nacr,nacr,nacr,nacr})
           netrepl('kvp,sr,svp',{kvp+kvp_r,sr+srr,svp+svpr})
           if fieldpos('DocId')#0
              if DocId_r#0
                 netrepl('DocId',{DocIdr})
              else
                 netrepl('DocId',{0})
              endif
           endif
        else
           netrepl('kvp,sr,svp',{kvp+kvp_r,sr+srr,svp+svpr})
        endif
        sele lrs2
        netrepl('kvpo',{kvpo+kvp_r})
        sele rs2kpk
        netrepl('kvpo',{kvpo+kvp_r})
        if select('pr2')#0
           if rcPr2o1r#0
              sele pr2
              go rcPr2o1r
           endif
        endif
        sele rs2
        crprotp()
        k1t_r=0
        if int(k1tr/1000000)=1 // Первая привязана стеклотара
           sele tov
           if netseek('t1','sklr,k1tr',,,1)
              m1tr=MnTov
              sele tovm
              if netseek('t1','sklr,m1tr',,,1)
                 reclock()
                 sele tov
                 reclock()
                 if osv>=kvp_r
                    opttr=opt
                    k1t_r=k1t // код тары привязки
                    if gnEnt=21
                       if prboxr#0.and.k1t_r=0
                          #ifdef __CLIP__
                             outlog(__FILE__,__LINE__,Ttnr,ktlr,k1tr,k1t_r,"Нет ящ в стекле в TOV")
                          #endif
                       endif
                    endif
                    ZenPtr=getfield('t1','m1tr','ctov',CZenr)
                    netrepl('osv',{osv-kvp_r})
                    sele tovm
                    netrepl('osv',{osv-kvp_r})
                    sele rs2
                    if !netseek('t3',{Ttnr,ktlr,1,k1tr})
                       netadd()
                       netrepl('ttn,MnTovP,MnTov,zen,bzen,izg,ZenP,bZenP,ktl,ktlp,prZenP,prbZenP,pzen,pbzen,ppt',;
                               {Ttnr,MnTovr,m1tr,ZenPtr,ZenPtr,izgr,ZenPtr,ZenPtr,k1tr,ktlr,0,0,0,0,1})
                       if fieldpos('DocId')#0
                          if DocId_r#0
                             netrepl('DocId',{DocIdr})
                          else
                             netrepl('DocId',{0})
                          endif
                       endif
                       if fieldpos('TCenp')#0
                          netrepl('TCenp',{TCenr})
                       endif
                    endif
                    srr=roun(kvp_r*opttr,2)
                    svpr=roun(kvp_r*ZenPtr,2)
                    netrepl('sr,svp,kvp',{sr+srr,svp+svpr,kvp+kvp_r})
                    sele rs2m
                    if !netseek('t3','Ttnr,MnTovr,1,m1tr')
                       netadd()
                       netrepl('ttn,MnTovP,MnTov,zen,bzen,izg,ZenP,bZenP,ktl,ktlp,prZenP,prbZenP,pzen,pbzen,ppt',;
                               {Ttnr,MnTovr,m1tr,ZenPtr,ZenPtr,izgr,ZenPtr,ZenPtr,0,0,0,0,0,0,1})
                       netrepl('sr,svp,kvp',{sr+srr,svp+svpr,kvp+kvp_r})
                       if fieldpos('DocId')#0
                          if DocId_r#0
                             netrepl('DocId',{DocIdr})
                          else
                             netrepl('DocId',{0})
                          endif
                       endif
                    else
                       netrepl('kvp',{kvp+kvp_r})
                       netrepl('sr,svp,kvp',{sr+srr,svp+svpr,kvp+kvp_r})
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
                          outlog(__FILE__,__LINE__,Ttnr,m1t_r,"Нет в TOVM")
                       #endif
                    endif
                 endif
              endif

              if k1t_r#0
                 pTarAr=1
              endif
           endif
        else // Первая привязана тара
           if k1tr#0
              k1t_r=k1tr
              pTarAr=1
           endif
        endif
        if k1t_r#0.and.upakr#0 // Вычисление кол-ва и привязка ящиков
           kvp_rr=ceiling(kvp_r/upakr)
           if gnEnt=21.and.upakr=0
              #ifdef __CLIP__
                outlog(__FILE__,__LINE__,Ttnr,ktlr,kvp_r,"/",upakr,"К-во ящиков")
              #endif
           endif
           sele tov
           if netseek('t1','sklr,k1t_r',,,1)
              m1t_r=MnTov
              if gnEnt=21
                if m1t_r=0
                   #ifdef __CLIP__
                     outlog(__FILE__,__LINE__,Ttnr,ktlr,k1t_r,m1t_r,"Нет привязки m1t TOV")
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
                    ZenPtr=getfield('t1','m1t_r','ctov',CZenr)
                    netrepl('osv',{osv-kvp_rr})
                    sele tovm
                    netrepl('osv',{osv-kvp_rr})
                    sele rs2
                    if !netseek('t3','Ttnr,ktlr,1,k1t_r')
                       netadd()
                       netrepl('ttn,MnTovP,MnTov,zen,bzen,izg,ZenP,bZenP,ktl,ktlp,prZenP,prbZenP,pzen,pbzen,ppt',;
                               {Ttnr,MnTovr,m1t_r,ZenPtr,ZenPtr,izgr,ZenPtr,ZenPtr,k1t_r,ktlr,0,0,0,0,1})
                       if fieldpos('DocId')#0
                          if DocId_r#0
                             netrepl('DocId',{DocIdr})
                          else
                             netrepl('DocId',{0})
                          endif
                       endif
                       if fieldpos('TCenp')#0
                          netrepl('TCenp',{TCenr})
                       endif
                    endif
                    srr=roun(kvp_rr*opttr,2)
                    svpr=roun(kvp_rr*ZenPtr,2)
                    netrepl('sr,svp,kvp',{sr+srr,svp+svpr,kvp+kvp_rr})
                    sele rs2m
                    if !netseek('t3','Ttnr,MnTovr,1,m1t_r')
                       netadd()
                       netrepl('ttn,MnTovP,MnTov,zen,bzen,izg,ZenP,bZenP,ktl,ktlp,prZenP,prbZenP,pzen,pbzen,ppt',;
                               {Ttnr,MnTovr,m1t_r,ZenPtr,ZenPtr,izgr,ZenPtr,ZenPtr,0,0,0,0,0,0,1})
                       netrepl('sr,svp,kvp',{sr+srr,svp+svpr,kvp+kvp_rr})
                       if fieldpos('DocId')#0
                          if DocId_r#0
                             netrepl('DocId',{DocIdr})
                          else
                             netrepl('DocId',{0})
                          endif
                       endif
                    else
                       netrepl('sr,svp,kvp',{sr+srr,svp+svpr,kvp+kvp_rr})
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
                          outlog(__FILE__,__LINE__,Ttnr,m1t_r,"Нет в TOVM")
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
    if MnTovr=3410099
      #ifdef __CLIP__
        outlog(__FILE__,__LINE__,"seek tovm T1 ERR",sklr,MnTovr)
      #endif
    endif
  endif
  return kolr

*************
static Function Vo9(lAccDeb,cLsKop139)
  ************
  LOCAL pSdv, nSum, nCntRec
  ttn_r=ttn
  DocGuid_r=DocGuid
  ttnc_r=ttnp
  kgpr=kgp
  pr61r=val(subs(ser,1,1))
  pr46r=val(subs(ser,2,1))
  DocIdr=DocId // lrs1
  ztxtr:=allt(ztxt)  // lrs1

  RcLrs1r=recn()

  if empty(skl)
     skr=228
  else
     skr=skl
  endi

  if skr=ngMerch_Sk241 //мерч склад
    sklr=kgpr
  else

    if lrs1->spd = 1
       ?'TTH',lrs1->ttn,'// lrs1->spd=1 признак cAID="REPORT" - НЕ обратотан'
    endif
  endif

  nuse('rs1')
  nuse('rs2')
  nuse('rs3')
  nuse('rs2m')
  nuse('soper')
  nuse('tov')
  nuse('tovm')
  nuse('rs1kpk')
  nuse('rs2kpk')

  sele cskl
  netseek('t1','skr')
  Pathr=gcPath_d+allt(path)
  gnKt=kt
  if skr#ngMerch_Sk241
    sklr=skl
  endif
  netuse('tov',,,1)
  netuse('tovm',,,1)
  netuse('sgrp',,,1)
  netuse('rs1',,,1)
  netuse('rs2',,,1)
  netuse('rs3',,,1)
  netuse('rs2m',,,1)
  netuse('soper',,,1)
  netuse('rs1kpk',,,1)
  netuse('rs2kpk',,,1)

  if skr # ngMerch_Sk241 ; //.and. gnEnt#21
    .and. !(STR(lrs1->kop) $ cLsKop139);
    .and. file('tzvk_lrs.dbf')

    // .and. !EMPTY(ztxtr)
    // получить по плательщику ЗДН

    // готовится при формировании ЗАЯВКИ
    // есть Задания ПКО по Плат-ку  и ГрПол-лю ?
    use tzvk_lrs new Exclusive
    set filt to dvp = date()
    sele tzvk_lrs
    locate for tzvk_lrs->kpl = lrs1->Kpl ;
    .and. iif(KPL_TZVK_KGP,tzvk_lrs->kgp = lrs1->Kgp,.T.)


    If found() .and. isWr4curTtn()      // есть задания
      // поиск введенных заданий в БД      // получим список задания
      tzvk_crt()
      sele rs1
      DBEval(;
      {||tzvk_ztxt(rs1->nkkl,rs1->kpv,rs1->ztxt,rs1->ttn)},;
      {||rs1->dvp = date() .and. !empty(ztxt) ;
      .and. rs1->nkkl = lrs1->Kpl ;
        }; //.and. iif(KPL_TZVK_KGP,rs1->kpv = lrs1->Kgp,.T.)
    )

      If !EMPTY(tzvk->(LastRec()))
        // строка с заданиями отличиями
        sele tzvk_lrs
        DBGoTop()
        Do While !eof()
          If tzvk_lrs->kpl = lrs1->Kpl ;
            .and. iif(KPL_TZVK_KGP,tzvk_lrs->kgp = lrs1->Kgp,.T.)

            sele tzvk    // такая ТТН есть?
            locate for tzvk->ttn = tzvk_lrs->ttn
            If !found()
              sele tzvk_lrs
              ztxtr+=;
              +'т='+LTRIM(STR(TTN)); // номер ТТН
              +'с='+LTRIM(STR(sdv,12,2)); // сумма забора
              +'н='+LTRIM(STR(NAP)); // направление
              +'к='+LTRIM(STR(sk))+' '+DTOS(dop)+';' // коментарий
            EndIf
            sele tzvk_lrs
            dbdelete()
          EndIf
          sele tzvk_lrs
          DBSkip()
        enddo
      else
        sele tzvk_lrs
        DBGoTop()
        Do While !eof()
          If tzvk_lrs->kpl = lrs1->Kpl ;
            .and. iif(KPL_TZVK_KGP,tzvk_lrs->kgp = lrs1->Kgp,.T.)
              sele tzvk_lrs
              ztxtr+=;
              +'т='+LTRIM(STR(TTN)); // номер ТТН
              +'с='+LTRIM(STR(sdv,12,2)); // сумма забора
              +'н='+LTRIM(STR(NAP)); // направление
              +'к='+LTRIM(STR(sk))+' '+DTOS(dop)+';' // коментарий
            dbdelete()
          EndIf
          sele tzvk_lrs
          DBSkip()
        enddo

      EndIf

      sele tzvk; use

    EndIf
    sele tzvk_lrs; use

  endif
  // пустые шапки докумнты и нет задания
  If 'TZVK' $ lrs1->DocGuid .and. EMPTY(ztxtr)
    return .t.
  EndIf

  TtnCor=0
  Ttnr=0 //!!
  TtnPr=0
  TtnCr=0
  store 0 to rcTtnPr,rcTtnCr

  sele cskl
  msklr=mskl
  if msklr=0
    sklr=skl
  endif


  If lrs2->(ordsetfocus('t1'),netseek('t1','ttn_r'), ;
    nCntRec:=0, dbeval({||++nCntRec},,{||ttn=ttn_r}),;
    nCntRec) = 0
    // outlog(__FILE__,__LINE__,"  Нет строк в заявке",lrs1->Ttn,lrs1->DocGuid)
    // return .t.
  EndIf

  NextNumTtn()

  #ifdef __CLIP__
       outlog(__FILE__,__LINE__,"  +Шапка ТТН",Ttnr)
  #endif

  TtnPr=Ttnr
  TtnCr=0

  sele lrs1

  arec:={}; getrec()
  DocGuid_r:=DocGuid
  DocId_r:=DocId // lrs1
  arec[FieldPos("ttn")]:=Ttnr
  arec[FieldPos("DocGuid")]:=""

  sele rs1
  netadd()
       outlog(__FILE__,__LINE__,"    ТТН RecNo",RecNo())
  putrec()
       outlog(__FILE__,__LINE__,"    putrec()")

  netrepl('ttn, skl,    ddc,   dvp,pst,ttnc,ttnp,  rmsk, dtmod, tmmod,sert,prkpk,prdec',;
          {Ttnr,sklr,date(),date(),  1,   0,   0,gnRmSk,date(),time(),   0,1,1},1)
  //netrepl('prkpk,prdec',{1,1},1)
       outlog(__FILE__,__LINE__,"    netrepl")
  if skr=ngMerch_Sk241 //мерч склад
     netrepl('dop,prz,dot',{date(),1,date()},1)
  endif
  If "-169" $ lrs1->npv // переоценка
     netrepl('dop,top',{date(),time()},1)
  EndIf

  //netrepl('DocGuid',{DocGuid_r},1)
  rcTtnPr=recn()
  #ifdef __CLIP__
       outlog(__FILE__,__LINE__,"  -Шапка ТТН",ttn)
  #endif
  sele lrs1
  netrepl('kps',{Ttnr})
  /*
  #ifdef __CLIP__
    if Ttnr=60
       erase lrs160.dbf
       copy to lrs160
    endi
  #endif
  */
  // Запись заявки
  #ifdef __CLIP__
       outlog(__FILE__,__LINE__,"  +Запись заявки lrs2",;
       lrs2->(ordsetfocus('t1'),netseek('t1','ttn_r'), ;
       nCntRec:=0, dbeval({||++nCntRec},,{||ttn=ttn_r}),;
       nCntRec);
     )
  #endif
  sele rs1kpk
  if ttn_r<=ttn_rrr
    rs1->(aRecRs1:={},getrec("aRecRs1"))
    netadd()
    putrec("aRecRs1")

    nnzr=str(ttn,6)
    netrepl('ttn,skpk,nnz,ddc,tdc,sdv,sdvm,sdvt',;
           {Ttnr,skpkr,nnzr,date(),time(),0,0,0})
    netrepl('prdec',{1},1)
    netrepl('DocGuid,ztxt',{DocGuid_r,ztxtr},1)
  else
    sele lrs1
    locate for DocId=DocIdr.and.ttn#ttn_r
    Ttnr=kps
    go RcLrs1r
  endif

  sele lrs2
  set orde to tag t1
  if netseek('t1','ttn_r')
    do while ttn=ttn_r
      MnTovr=MnTov
      sele lrs2
      kvpor=kvpo
      arec:={};  getrec()
      sele rs2kpk
      set orde to tag t1
      if !netseek('t1','Ttnr,skpkr,MnTovr')
        netadd()
        putrec()
        netrepl('ttn,skpk',{Ttnr,skpkr})
      endif
      netrepl('kvpo',{kvpo+kvpor})
      sele lrs2
      skip
      if ttn#ttn_r
        exit
      endif
    enddo
    arec:={}
  endif
  #ifdef __CLIP__
    outlog(__FILE__,__LINE__,"  -записали заявку rs2kpk",;
       rs2kpk->(ordsetfocus('t1'),netseek('t1','Ttnr'), ;
       nCntRec:=0, dbeval({||++nCntRec},,{||ttn=Ttnr}),;
       nCntRec);
      )
  #endif

  #ifdef __CLIP__
       outlog(__FILE__,__LINE__,"  +код операции, цены")
  #endif
  sele rs1
  DtRor=DtRo
  DocIdr=Ttnr
  Ttnr=ttn
  vor=vo
  kopr=kop
  kopir=kopi
  kplr=kpl
  if kopir=0
     kopir=kopr
     netrepl('kopi',{kopir},1)
  endif
  if kopr=kopir
     kop_r=kopr
  else
     kop_r=kopir
  endif
  qr=mod(kop_r,100)
  RndSdvr=getfield('t1','0,1,vor,qr','soper','RndSdv')
  if skr=ngMerch_Sk241 //мерч склад
     TCenr=2
     sktr=0
     mskltr=0
     CZenr='cenpr' // allt(getfield('t1','TCenr','TCen','zen'))
     skltr=0
  else
     TCenr=getfield('t1','0,1,vor,qr','soper','TCen')
     sktr=getfield('t1','0,1,vor,qr','soper','ska')
     mskltr=getfield('t1','sktr','cskl','mskl')
     CZenr=allt(getfield('t1','TCenr','TCen','zen'))
     if mskltr=0
        skltr=getfield('t1','sktr','cskl','skl')
     else
        skltr=kplr
     endif
  endif
  #ifdef __CLIP__
       outlog(__FILE__,__LINE__,"  -код операции, цены")
  #endif

  #ifdef __CLIP__
       outlog(__FILE__,__LINE__,"  +kpl,kgp")
  #endif

  kgpr=kgp
  nkklr=kplr
  kpvr=kgpr
  tmestor=getfield('t2','nkklr,kpvr','etm','tmesto')
  if tmestor=0
     tmestor=getfield('t2','nkklr,kpvr','tmesto','tmesto')
  endif
  netrepl('nkkl,kpv,skt,sklt,tmesto,RndSdv',{nkklr,kpvr,sktr,skltr,tmestor,RndSdvr},1)
  if DocId_r#0
     netrepl('DocId',{DocIdr},1)
  else
     netrepl('DocId',{0},1)
  endif
  if kopr=169
     netrepl('kpl,kgp',{20034,20034},1)
     kplr=20034
     kgpr=20034
     if getfield('t1','nkklr','kln','kkl1')=0
        nkklr=20034
        netrepl('nkkl',{nkklr},1)
     endif
  endif
  if kopr=168
     kplr=getfield('t1','0,1,vor,qr','soper','kpl')
     kgpr=getfield('t1','0,1,vor,qr','soper','kkl')
     netrepl('kpl,kgp',{kplr,kgpr},1)
  endif
  if nkklr=0
     netrepl('nkkl',{kpl},1)
  endif
  if kpv=0
     netrepl('kpv',{kgp},1)
  endif
  ktar=kta
  ktasr=ktas
  if ktar#0.and.ktasr=0
     ktasr=getfield('t1','ktar','s_tag','ktas')
     netrepl('ktas',{ktasr},1)
  endif
  napr=0
  if ktar#0
    napr=getfield('t1','ktar','ktanap','nap')
    if napr=0
      if ktasr#0
        napr=getfield('t1','ktasr','ktanap','nap')
      endif
    endif
  endif
  if fieldpos('nap')#0
    netrepl('nap',{napr},1)
  endif
  doguslr=0
  sele kpl
  netseek('t1','nKklr')
  if pr61r=1
      prksz61r=prksz61
      smksz61r=smksz61
  else
     prksz61r=0
     smksz61r=0
  endif
  //  Признак наличия договорных условий
  if empty(dtnace).or.dtnace<gdTd
      doguslr=0
  else
     doguslr=1
  endif
  sele rs1
  if skr=ngMerch_Sk241 //мерч склад
     netrepl('dop',{date()})
  endif

  netrepl('DocGuid,ztxt',{DocGuid_r,ztxtr},1)

  sele lRs1
  If !empty(lrs1->(FieldPos("Mess01")))
    If !Empty(lrs1->Mess01)
     SendingJafa("lista@bk.ru,lodis-sumy@ukr.net",{{ "","Error in Order Obolon-Lodis"+" "+DTOC(DATE(),"YYYYMMDD")}},;
     "Счет-фактура от " + DTOC(date(),"YYYY-MM-DD");
     + " #" + str(ttnr,6) + CRLF;
     + lrs1->Mess01,;
     232)
    else
      /*
      netrepl("mess01", {"Значения DocGuid_r=" + DocGuid_r + CRLF + "Значение ztxtr="+ztxtr+ CRLF})
      SendingJafa("lista@bk.ru",{{ "","Error Obolon-Lodis"+" "+DTOC(DATE(),"YYYYMMDD")}},;
      lrs1->Mess01,;
      232)
      */
    EndIf
  EndIf

  #ifdef __CLIP__
       outlog(__FILE__,__LINE__,"  -kpl,kgp")
  #endif
  #ifdef __CLIP__
       outlog(__FILE__,__LINE__,"  +chkmkkgp(MnTovr,kgpr)")
  #endif
  pTarAr=0
  sele lrs2
  set orde to tag t1
  if netseek('t1','ttn_r')
     do while ttn=ttn_r
        sele lrs2
        MnTovr=MnTov
        ktl_lrs2_r=ktl // задан в заявке КТЛ
        If ktl_lrs2_r=0 // для тарного склад авто заявки
          if int(MnTovr/10000)<2
             sele lrs2;  skip;  loop
          endif
        EndIf
        if !ChkMkKgp(MnTovr,kgpr)
           sele lrs2; skip;  loop
        endif
        if gnEnt=20.and.kopr=169.and.int(MnTovr/10000)=340
           sele lrs2; skip;  loop
        endif
        if gnEnt=20.and.(kopr=129.or.kopr=139).and.izg=0
           sele lrs2;  skip;   loop
        endif
        sele rs2kpk
        set orde to tag t1
        netseek('t1','DocIdr,skpkr,MnTovr')
        sele lrs2
        kvpr=kvp
        VKolr=kvpr
        MnTovTr=getfield('t1','MnTovr','ctov','MnTovT')
        if MnTovTr=0
          MnTovTr=MnTovr
        endif
        MinOsvr=getfield('t1','MnTovTr','ctov','minosv')

        if skr=ngMerch_Sk241; //мерч склад
          .or. "-169" $ lrs1->npv // переоценка

          ktl_r=lrs2->ktl
          If empty(ktl_r)
            ktl_r=MnTovr*100
          EndIf

          sele tovm
          if !netseek('t1','sklr,MnTovr',,,1)
            sele ctov
            if netseek('t1','MnTovr')
              arec:={};  getrec()
              sele tovm
              netadd();  putrec()
              netrepl('skl',{sklr})
            endif
          endif

          sele tov
          if !netseek('t1','sklr,ktl_r')
            sele ctov
            if netseek('t1','MnTovr')
              arec:={}; getrec()
              sele tov
              netadd(); putrec()
              opt_r=0.01
              netrepl('skl,ktl,opt',{sklr,ktl_r,opt_r})
            endif
          endif
        endif

        //if skr#ngMerch_Sk241
        if !(skr=ngMerch_Sk241; //мерч склад
           .or. "-169" $ lrs1->npv; // переоценка
           )
           if MinOsvr#0 // задано мин остаток на складе
              osv_rr=0
              sele tov
              set orde to tag t10
              if netseek('t10','sklr,MnTovTr')
                // получение остатка с учетом блокировка КПК
                 do while skl=sklr.and.MnTovT=MnTovTr
                    if fieldpos('BlkKpk')#0.and.BlkKpk#0
                      skip; loop
                    endif
                    if (otv=0.and.osv<=0).or.otv=1 //.and.osvo<=0
                       skip ; loop
                    endif
                    osv_rr=osv_rr+osv
                    sele tov
                    skip
                    if !(skl=sklr.and.MnTovT=MnTovTr)
                       exit
                    endif
                 enddo
              endif
              // проверка на возможность снятия с учетом мин ос-ка
              if osv_rr - MinOsvr<=0
                VKolr=0
              else
                if osv_rr-MinOsvr-VKolr<=0
                  VKolr=osv_rr-MinOsvr
                endif
              endif

           endif
        endif

        if VKolr>0
           sele tov
           set orde to tag t10
           if netseek('t10','sklr,MnTovTr')
            do while skl=sklr.and.MnTovT=MnTovTr
             // для тарного склад авто заявки
              If ktl_lrs2_r#0 .and. ktl_lrs2_r#tov->ktl
                // задана КТЛ(партия) и стоим на записи не =
                skip; loop
              endif
              rc_tovr=recn()
              If ktl_lrs2_r=0
                mkeep_r=getfield('t1','MnTovTr','ctov','mkeep')
                pr169_r=0
                if fieldpos('pr169')#0
                  pr169_r=getfield('t1','MnTovTr','ctov','pr169')
                endif
                if gnRasc=1.and.vor=9.and.kopr#169
                  if pr169_r=1
                      skip; loop
                  endif
                endif
                BlkMk_r=getfield('t1','mkeep_r','mkeep','BlkMk')
                rc_tovr=recn()
                if fieldpos('BlkKpk')#0.and.BlkKpk#0
                  skip; loop
                endif

                //if skr#ngMerch_Sk241
                if !(skr=ngMerch_Sk241; //мерч склад
                   .or. "-169" $ lrs1->npv; // переоценка
                   )
                  if BlkMk_r=1                        // Блокировка выписки всего
                    skip; loop
                  endif
                  if otv=0.and.osv<=0
                    skip; loop
                  endif
                  if otv=0.and.BlkMk_r=2.and.gnEntRm=0 // Блокировка выписки с выкупленных остатков
                    skip; loop
                  endif
                  if otv=1.and.BlkMk_r=3.and.gnEntRm=0 // Блокировка выписки с остатков отв хр
                    skip; loop
                  endif
                  if otv=1.and.osvo<=0
                    skip; loop
                  endif
                endif
              EndIf
              MnTovr=MnTov
              k1tr=k1t
              VKolr:=Rs2tvi(VKolr,ktl_lrs2_r)
              if VKolr<=0
                exit
              endif

              sele tov
              set orde to tag t10
              go rc_tovr
              skip
              if !(skl=sklr.and.MnTovT=MnTovTr)
                exit
              endif
            enddo
          else
             If ktl_lrs2_r=0
               #ifdef __CLIP__
                 //outlog(__FILE__,__LINE__,"seek tov T7 ERR",sklr,MnTovTr)
                 outlog(__FILE__,__LINE__,"seek tov T10 ERR",sklr,MnTovTr)
               #endif
             else
               //
             EndIf
          endif
        else // к-во отрицательно
          sele tov
          netseek('t1','sklr,ktl_lrs2_r')
          Rs2tvi(VKolr,ktl_lrs2_r)
        endif
        sele lrs2
        skip
        if ttn#ttn_r
           exit
        endif
     enddo
  endif

  //все прошло пишем документ
  sele rs1
  go rcTtnPr
  //netrepl('DocGuid',{DocGuid_r},1)
  #ifdef __CLIP__
       outlog(__FILE__,__LINE__,"  -chkmkkgp(MnTovr,kgpr)")
  #endif

  #ifdef __CLIP__
       outlog(__FILE__,__LINE__,"  +Тара в род. докум")
  #endif

  if rs1->DocId#0.and.(gnEnt=20.and.(rs1->kop=177.or.rs1->kop=168);
                      .or.gnEnt=21.and.rs1->kopi=177.and.rs1->kop#177)
     ttn_r=DocId
     kpsr=ttn
     if netseek('t1','ttn_r')
        netrepl('kps',{kpsr})
     endif
  endif
  sele rs1
  go rcTtnPr
  pTarAr=ttnc_r
  if gnEnt=20
     if kop=177
        akc_r=1
     else
        akc_r=0
     endif
  endif
  if gnEnt=21
     if kopi=177
        akc_r=1
     else
        akc_r=0
     endif
  endif
  sele rs2
  prTarr=0 // Признак наличия тары в родительском документе
  prBsor=0 // Признак наличия БСО
  set orde to tag t1
  if netseek('t1','TtnPr')
     do while ttn=TtnPr
        MnTov_r=MnTov
        if int(MnTov/10000)=0
           prTarr=1
        endif
        if int(MnTov/10000)>1
           kg_r=int(MnTov_r/10000)
           lic_r=getfield('t1','kg_r','cgrp','lic')
           if lic_r#0
              prBsor=1
           endif
        endif
        sele rs2
        skip
        if ttn#TtnPr
           exit
        endif
     enddo
  endif
  #ifdef __CLIP__
       outlog(__FILE__,__LINE__,"  -Тара в род. докум")
  #endif

  #ifdef __CLIP__
       outlog(__FILE__,__LINE__,"  +Фин. контрль")
  #endif

  nRet:=0
  sele rs1
  go rcTtnPr
  //
  kplr=Kpl;     kgpr=Kgp
  if prBsor#0.and.kop#169
    netrepl('bso','1',1)
    // лицензия просрочена ?
    if !(rs1->kop=169.or.rs1->kop=151)
      dolr:=klnlic->(DtLic(kplr, kgpr, 2)) // 2 - лицензия алкоголь

      if rs1->kop#168.and.dolr<date()
          nRet:=-111 // лицензия просрочена
      endif
    endif
    sele rs1

  endif

  IF nRet = 0
    //найти ТМ принадлежит ТА
    nRet:=-555
    IF kplr=20034 .AND. kgpr=20034
      etm->(netseek('t2','nkklr,kpvr'))
    ELSE
      etm->(netseek('t2','kplr,kgpr'))
    ENDIF
    //вычислилть "торг.место " - ТМ kplr     kgpr -
    #ifdef __CLIP__
       outlog(3,__FILE__,__LINE__,kplr,kgpr,etm->tmesto,nkklr,kpvr)
    #endif

    //найти ТМ принадлежит ТА
    stagtm->(ordsetfocus("t2"))
    stagtm->(netseek('t2','etm->tmesto'))
    #ifdef __CLIP__
       outlog(3,__FILE__,__LINE__,etm->tmesto,stagtm->Kta,stagtm->(FOUND()))
    #endif
    if etm->tmesto#0
      DO WHILE etm->tmesto = stagtm->tmesto
        #ifdef __CLIP__
          outlog(3,__FILE__,__LINE__,etm->tmesto, stagtm->tmesto,stagtm->Kta, rs1->Kta)
        #endif
        //проверить ТМ принадлежит ТА
        IF stagtm->Kta = rs1->Kta
          nRet:=0
          exit
        ENDIF
        stagtm->(DBSKIP())

      enddo
    endif
   #ifdef __CLIP__
     outlog(3,__FILE__,__LINE__,nRet)
   #endif

  ENDIF

  // ********************** ФИНКОТРОЛЬ *******************

  If (!(STR(rs1->kop) $ cLsKop139) .and. gnEnt=20) ;
     .or. (!(STR(rs1->kop) $ cLsKop139) .and. gnEnt=21)

    IF !EMPTY(lAccDeb)
      If nRet = 0
        nRet:=FirstChk_FinCtrl(nRet)
      EndIf
      nRet:=KtoFp_Post(nRet)

      If nRet<0
        netrepl('KtoFp,dfp,tfp',{nRet,BLANK(Date()),''},1)
      Else
        netrepl('KtoFp,dfp,tfp',{nRet,date(),time()},1)
      EndIf
    EndIf

  ElseIf (gnEnt=21, .F.) //откл. такой расчет
    IF !EMPTY(lAccDeb)
      outlog(__FILE__,__LINE__,lAccDeb,'lAccDeb',;
      gcPath_ew,'gcPath_ew')
    ENDIF
    // прошли проверку Лицензий и Наличие ТТ
    If nRet = 0
      // проверить карту покупателя
      nRet:=KtoFp_Lev1(nRet)
      outlog(__FILE__,__LINE__,nRet)
    endif
    If nRet = 0
      // расчеты есть
      Do Case
      Case round(;
        (dkkln->DN - dkkln->KN) + (dkkln->DB - dkkln->KR),2;
                ) > KPL_DZ
        // если есть ДЗ, то вычислить к-во дней просрочки + дней = ДнПр
        kdoplr:=getfield('t1','rs1->nkkl','klndog','kdopl')
        kdoplr:=Iif(kdoplr = 0, 7, kdoplr) + 3
        outlog(3,__FILE__,__LINE__,kdoplr,'kdoplr')
        // найти запись в ДЕБ
        If deb->(dbseek(str(rs1->nkkl,7)))

          // суммировать от 1 до 40
          nStartDt:=1; nSum:=0
          FOR i:=nStartDt to 40
            pSdv:=deb->(FieldPos('sdv'+padl(ltrim(str(i,3)),3,'0')))
            If pSdv = 0
              loop
            EndIf
            nSum += deb->(FieldGet(pSdv))
          NEXT i
          outlog(3,__FILE__,__LINE__,'1-40',nSum,'S=0, долг > 40 дней')
          // есть = 0 , а ДЗ есть, то -903 - долг больше 40 дней
          If nSum = 0
            nRet:=-940
          else
            // суммировать от  ДнПр до 40
            nStartDt:=kdoplr
            If nStartDt > 40 // задана отрочка больше 40 дней
              nSum:=999999
              outlog(3,__FILE__,__LINE__,str(nStartDt,2)+'-40',nSum,'S#0, задана отрочка больше 40 дней')
            Else
              nSum:=0
            EndIf
            FOR i:=nStartDt to 40
              //nSum += deb->(FieldGet(FieldPos('sdv'+padl(ltrim(str(i,3)),3,'0'))))
              pSdv:=deb->(FieldPos('sdv'+padl(ltrim(str(i,3)),3,'0')))
              If pSdv = 0
                loop
              EndIf
              nSum += deb->(FieldGet(pSdv))
            NEXT i
            outlog(3,__FILE__,__LINE__,str(nStartDt,2)+'-40',nSum,'S#0, долг больше дней договора+3дня')
            // если сумма  != 0, блок -901
            If nSum = 0
              nRet:=901
            Else
              nRet:=-903
            EndIf
          EndIf

        else
          nRet:=901
        EndIf

      OtherWise
        nRet:=901 //ok!!
      EndCase

    endif
    nRet:=KtoFp_Post(nRet)

    If nRet<0
      netrepl('KtoFp,dfp,tfp',{nRet,BLANK(Date()),''},1)
    Else
      netrepl('KtoFp,dfp,tfp',{nRet,date(),time()},1)
    EndIf

  EndIf


   #ifdef __CLIP__
        outlog(__FILE__,__LINE__,"  -Фин.контроль",nRet)
   #endif

   #ifdef __CLIP__
        outlog(__FILE__,__LINE__,"  +Тарный документ prTarr=1.and.(pTarAr=1.or.akc_r=1",prTarr,pTarAr,akc_r)
   #endif

   if prTarr=1.and.(pTarAr=1.or.akc_r=1)
      // Тарный документ
      NewNomTttn()

     #ifdef __CLIP__
          outlog(__FILE__,__LINE__,"    +Шапка")
     #endif

      sele rs1
      go rcTtnPr
      kplr=nkkl
      kgpr=kpv
      arec:={};  getrec()
      rs1->(netunlock())
      netadd()
        outlog(__FILE__,__LINE__,"    ТТН RecNo",RecNo(),TtnCr)
      putrec(,'ttn')
        outlog(__FILE__,__LINE__,"    putrec()")
      netrepl('ttn,kop,ttnp,kpl,kgp,ttnc,rmsk,dtmod,tmmod,DocGuid,bso,ztxt,mk169',;
               {TtnCr,170,TtnPr,kplr,kgpr,0,gnRmSk,date(),time(),"",0,"",0},1)
      DBCommit(); DBSkip(0)
        outlog(__FILE__,__LINE__,"    netrepl")
      rcTtnCr=recn()
      go rcTtnPr
      netrepl('ttnc,ttnp',{TtnCr,0},1)
   #ifdef __CLIP__
        outlog(__FILE__,__LINE__,"    -Шапка")
   #endif
   #ifdef __CLIP__
        outlog(__FILE__,__LINE__,"    +Тара строки")
   #endif
      sele rs2
      if netseek('t1','TtnPr')
         do while ttn=TtnPr
            rcrs2pr=recn()
            if int(MnTov/10000)#0
               skip; loop
            endif
            if kvp=0
               skip; loop
            endif
            ktlr=ktl
            MnTovr=MnTov
            MnTovPr=MnTovP
            pptr=ppt
            kvpr=kvp
            srr=sr
            svpr=svp
            arec:={}
            getrec()
            sele rs2
            if !netseek('t3','TtnCr,ktlr,0,ktlr')
              netadd()
              putrec()
              netrepl('ttn,ppt,MnTovP,ktlp',{TtnCr,0,MnTovr,ktlr})
            else
              netrepl('kvp,sr,svp',{kvp+kvpr,sr+srr,svp+svpr})
            endif
            sele rs2m
            if !netseek('t3','TtnCr,MnTovr,0,MnTovr')
               netadd()
               putrec()
               netrepl('ttn,ppt,MnTovP,ktlp,ktl',{TtnCr,0,MnTovr,0,0})
            else
               netrepl('kvp,sr,svp',{kvp+kvpr,sr+srr,svp+svpr})
            endif
            sele rs2m
            if netseek('t3','TtnPr,MnTovPr,pptr,MnTovr')
               netrepl('kvp,sr,svp',{kvp-kvpr,sr-srr,svp-svpr})
            endif
            sele rs2
            go rcrs2pr
            netdel()
            skip
            if ttn#TtnPr
               exit
            endif
         enddo
      endif
     rs1->(netunlock())
     rs2->(netunlock())
     rs2m->(netunlock())
     #ifdef __CLIP__
       outlog(__FILE__,__LINE__,"    -Тара строки")
     #endif
   endif
   #ifdef __CLIP__
        outlog(__FILE__,__LINE__,"  -Тарный документ")
   #endif

   #ifdef __CLIP__
        outlog(__FILE__,__LINE__,"  +Перерасчет основного")
   #endif
   if gnEnt=21
     #ifdef __CLIP__
          outlog(__FILE__,__LINE__,"    +bso")
     #endif
      sele rs1
      go rcTtnPr
      Ttnr=ttn
      bso_r=0
      if kop#169
         sele rs2
         set orde to tag t1
         if netseek('t1','Ttnr')
            do while ttn=Ttnr
               if int(MnTov/10000)<2
                  skip
                  loop
               endif
               if int(MnTov/10000)=340.or.int(MnTov/10000)=341
                  bso_r=1
                  exit
               endif
               skip
               if ttn#Ttnr
                  exit
               endif
            enddo
         endif
      endif
      sele rs1
      go rcTtnPr
      netrepl('bso',{bso_r},1)
      outlog(__FILE__,__LINE__,"    -bso")
   else
    /*
    *      sele rs1
    *      go rcTtnPr
    *      Ttnr=ttn
    *      bso_r=1
    *      sele rs2
    *      if netseek('t1','Ttnr')
    *         do while ttn=Ttnr
    *            if int(MnTov/10000)<2
    *               skip
    *               loop
    *            endif
    *            if int(MnTov/10000)#340
    *               bso_r=0
    *               exit
    *            endif
    *            skip
    *         enddo
    *      endif
    *      sele rs1
    *      go rcTtnPr
    *      netrepl('bso','bso_r',1)
    */
   endif

   if skr#ngMerch_Sk241 //мерч склад
     #ifdef __CLIP__
          outlog(__FILE__,__LINE__,"    +sdv,sdvm,sdvt // Перерасчет основного")
     #endif
      // Перерасчет основного
      sele rs1
      go rcTtnPr

      // пересчет по ценам 169
      kop126r=0
      if gnEnt=21 .and. kopr=126
        netrepl('kop',{169},1)
        kop126r=126
        kopr=169
      endif

      DocPereRs()
      // возрат кода операции
      sele rs1
      go rcTtnPr
      if gnEnt=21 .and. kop126r=126
        netrepl('kop',{126},1)
        kopr=126
      endif


      netunlock()
      TtnCr=ttnc
      sdvr=sdv
      sdvmr=sdvm
      sdvtr=sdvt

      If rs1->kop=169 .and. !(sdvr < 50000) //sdv50000
        nRet:=-333 //sdv50000
        netrepl('KtoFp,dfp,tfp',{nRet,BLANK(Date()),''},1)
        outlog(__FILE__,__LINE__,"    Фин.контроль //sdv50000", nRet)
      EndIf

      sele rs1kpk
      if netseek('t1','DocIdr,skpkr')
         netrepl("sdv,sdvm,sdvt",{sdv+sdvr,sdvm+sdvmr,sdvt+sdvtr})
      endif

      #ifdef __CLIP__
        sele rs1
        outlog(__FILE__,__LINE__,"    -sdv,sdvm,sdvt    rs1->",sdv,sdvm,sdvt)
        sele rs1kpk
        outlog(__FILE__,__LINE__,"    -sdv,sdvm,sdvt rs1kpk->",sdv,sdvm,sdvt)
      #endif
      if TtnCr#0
         #ifdef __CLIP__
              outlog(__FILE__,__LINE__,"    +Перерасчет тарного")
         #endif
         // Перерасчет тарного
         sele rs1
         go rcTtnPr
         kopr=kop
         go rcTtnCr
         #ifdef __CLIP__
              outlog(__FILE__,__LINE__,"    netrepl('kopi',{kopr})")
         #endif
         netrepl('kopi',{kopr},1)
         #ifdef __CLIP__
              outlog(__FILE__,__LINE__,"    DocTPereRs()")
         #endif
         DocTPereRs()
         #ifdef __CLIP__
              outlog(__FILE__,__LINE__,"    -Перерасчет тарного")
         #endif
         netunlock()
      endif
   endif
   #ifdef __CLIP__
        outlog(__FILE__,__LINE__,"  -Перерасчет основного")
   #endif

   nuse('rs1')
   nuse('rs2')
   nuse('rs3')
   nuse('rs2m')
   nuse('soper')
   nuse('tov')
   nuse('tovm')
   nuse('rs1kpk')
   nuse('rs2kpk')
  sele lrs1
  go RcLrs1r
  nnzr=str(TtnPr,6)
  netrepl('nnz,ttnc',{nnzr,TtnCr})
  arec:={}
  #ifdef __CLIP__
      outlog(__FILE__,__LINE__,"  VO9 выход")
  #endif
  return .t.


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  07-02-16 * 09:53:49pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
  p1 - 1 тара  // Признак тары  0 - торар
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION vo1(p1)
  LOCAL lExit, lc_gnD0k1
  prTr := p1 // Признак тары
  lc_gnD0k1:=gnD0k1
  gnD0k1:=1 // приходы

  nnz_r=str(ttn,6)
  ttn_r=ttn
  DocGuid_r=DocGuid
  kpsr=kpl
  kzgr=kgp
  vo_r:=vo    //1
  kop_r:=kop  // 108
  kta_r=kta
  ttnvz_r=val(allt(npv))
  skvz_r=skr
  If !Empty(allt(npv)) .and. Empty(ttnvz_r)
    // 'Err->ТТН ВЗР'
    outlog(__FILE__, __LINE__,'Err->ТТН ВЗР=0', "skr", skr,"kop_r", kop_r, "prTr", prTr)
    return .t.
  EndIf

  RcLrs1r=recn()

  if empty(skl)
    skr=228
  else
    skr=skl
  endif
  SkVzr:=NdVz //
  If Empty(SkVzr)
    SkVzr:=Skr //источник от куда барать инфу по ТТН
  EndIf

  nuse('pr1')
  nuse('pr2')
  nuse('pr3')
  nuse('soper')
  nuse('tov')
  nuse('tovm')
  nuse('pr1kpk')
  nuse('pr2kpk')

  /////// пути доступа с Складу источнику
  sele cskl
  netseek('t1','SkVzr')
  SkVrPathr=gcPath_d+allt(path) // полный путь
  gnKt=kt
  DirSkVzr=allt(path) // пусть склада

  sele cskl
  netseek('t1','skr')
  Pathr=gcPath_d+allt(path)
  gnKt=kt
  DirSkr=allt(path)
  //////

  netuse('pr1',,,1)
  netuse('pr2',,,1)
  netuse('pr3',,,1)
  netuse('soper',,,1)
  netuse('tov',,,1)
  netuse('tovm',,,1)
  netuse('pr1kpk',,,1)
  netuse('pr2kpk',,,1)
  sele lrs1

  // Товарный документ

  sele cskl
  msklr=mskl
  if msklr=0
    sklr=skl
  endif
  ////////////// номер ПА
  sele cskl
  reclock()
  mnr=mn
  do while .t.
    if netseek('t2','mnr','pr1')
      sele cskl
      if mn<999999
        netrepl('mn',{mn+1},1)
      else
        netrepl('mn',{1},1)
      endif
      mnr=mn
    else
      sele cskl
      if mn<999999
        netrepl('mn',{mn+1})
      else
        netrepl('mn',{1})
      endif
      exit
    endif
  enddo
  /////////////////////////////
  outlog(__FILE__,__LINE__,prTr,'ТТН ВЗР',ttnvz_r,"mnr", mnr,"skr", skr,"SkVzr", SkVzr,"kop_r", kop_r)

  sele pr1
  netadd()
  rcpr1r=recn()
  netrepl('mn,nd,skl,vo,kop,ddc,tdc,dvp,kps,kzg,rmsk,dtmod,tmmod,DocGuid,nnz,kta,ttnvz,SkVz',;
          {mnr,mnr,sklr,vo_r,kop_r,date(),time(),date(),kpsr,kzgr,gnRmSk,date(),time(),DocGuid_r,nnz_r,kta_r,ttnvz_r,SkVzr})
  arec:={}
  getrec()

  sele lrs1
  netrepl('kps',{mnr})
  // Запись заявки
  sele pr1kpk
  netadd()
  rcpr1kpkr=recn()
  putrec()
  netrepl('skpk',{skpkr})

  // перенос Заявки в ЗаявкиКПК
  sele lrs2
  set orde to tag t1
  if netseek('t1','ttn_r')
    do while ttn=ttn_r
      MnTovr:=MnTov
      kfr:=kvp
      ktlr:=ktl
      zenr:=zen

      sele pr2kpk
      netadd()
      netrepl('mn,skpk,MnTov,MnTovP,ktl,kf',{mnr,skpkr,MnTovr,lrs2->MnTovP,ktlr,kfr})
      netrepl("zen",{zenr})
      sele lrs2
      skip
      if ttn#ttn_r
        exit
      endif
    enddo
  endif

  // Формирование PR2
  if prTr=0 // возварат товара
    // Поиск ТТН
    lExit:=.F.
    for yyr=year(gdTd) to 2006 step -1
      do case
      case yyr=year(gdTd)
          mm1r=month(gdTd)
          mm2r=1
      case yyr=2006
          mm1r=12
          mm2r=9
      othe
          mm1r=12
          mm2r=1
      endcase
      for mmr=mm1r to mm2r step -1
        cDtVzr='01.'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'.'+subs(str(yyr,4),3,2)
        DtVzr=ctod(cDtVzr)
        Pathr=gcPath_e + pathYYYYMM(DtVzr) + '\' + DirSkVzr // путь склад источника
            //outlog(__FILE__,__LINE__,'  проверка',Pathr)
        if netfile('rs1',1)
          netuse('rs1','rs1vz',,1)
          if netseek('t1','ttnvz_r')
            lExit:=.T.
            outlog(3,__FILE__,__LINE__,'     найдена',Pathr)
            kpsr=kpl
            kzgr=kgp
            DtVzr=dot

            sele pr1
            netrepl('kps,kzg',{kpsr,kzgr})
            netrepl('skvz,dtvz',{SkVzr,DtVzr})

            netuse('rs2','rs2vz',,1)
            set orde to tag t2
            netuse('tov','tovvz',,1)

            sele pr2kpk
            set orde to tag t1
            if netseek('t1','mnr,skpkr')
              do while mn=mnr.and.skpk=skpkr
                MnTovr=MnTov
                if int(MnTovr/10000)<2 // Только товар
                  outlog(3,__FILE__,__LINE__,'  !тара',MnTovr)
                  sele pr2kpk; skip
                  loop
                endif

                sele ctov
                netseek('t1','MnTovr','ctov')
                MnTovTr=MnTovT // родитель
                  //outlog(__FILE__,__LINE__,'  MnTovTr',MnTovTr)
                if fieldpos('evz')#0
                  evzr = evz
                  if evzr#1
                    outlog(3,__FILE__,__LINE__,'  !MnTovr,ctov->evz',MnTovr,evzr)
                    sele pr2kpk; skip
                    loop
                  endif
                endif
                // массив дочек по родителю
                aMnTov:={}
                If Empty(MnTovTr) // родитель не определен
                  AADD(aMnTov, MnTovr)
                Else
                  sele ctov
                  ordsetfocus('t10')
                  netseek('t10','MnTovTr','ctov')
                  DBEval({|| AADD(aMnTov, MnTov)},,{|| MnTovTr = MnTovT })
                  netseek('t10','MnTovTr','ctov')
                EndIf
                  //outlog(__FILE__,__LINE__,'  list',aMnTov)

                sele pr2kpk
                kf_r=kf
                kfor=0
                sele rs2vz
                set orde to tag t2
                lSeekMnTov:=.F.
                For i:=1 To LEN(aMnTov)
                  MnTovr:=aMnTov[i]
                  if netseek('t2','ttnvz_r,MnTovr')
                    lSeekMnTov:=.T.
                    do while ttn=ttnvz_r.and.MnTov=MnTovr
                      if kvp<=kf_r
                        kfr=kvp
                        kf_r=kf_r-kfr
                      else
                        kfr=kf_r
                        kf_r=0
                      endif
                      if kfr#0
                        ktlr=ktl
                        ozenr=zen
                        sele pr2
                        if !netseek('t1','mnr,ktlr')
                          netadd()
                          netrepl('mn,ktl,ktlp,MnTov,MnTovP',{mnr,ktlr,ktlr,MnTovr,MnTovr})
                        endif
                        netrepl('kf',{kf+kfr})
                        kfor=kfor+kfr
                        sele tov
                        if !netseek('t1','sklr,ktlr')
                          sele tovvz
                          if netseek('t1','sklr,ktlr')
                            arec:={}; getrec()
                            sele tov
                            netadd()
                            putrec()
                            netrepl('osn,osf,osv,osfo',{0,0,0,0})
                          endif
                        endif
                        zenr=opt
                        sele pr2
                        netrepl('zen,ozen',{zenr,ozenr})
                        sfr=roun(kf*zen,2)
                        netrepl('sf,sr',{sfr,sfr})
                      endif
                      if kf_r=0
                        exit
                      endif
                      sele rs2vz
                      skip
                      if !(ttn=ttnvz_r.and.MnTov=MnTovr)
                          exit
                      endif
                    enddo
                  endif
                  if kf_r=0
                    exit
                  endif
                Next i

                If !lSeekMnTov
                  outlog(__FILE__,__LINE__,'  !MnTov MnTovT',pr2kpk->MnTov,MnTovTr,aMnTov)
                  outlog(__FILE__,__LINE__,'  ',ctov->Nat)
                else
                  if kf_r#0
                    outlog(__FILE__,__LINE__,' kf_r(ост)#pr2kpk->kf',kf_r,pr2kpk->kf,pr2kpk->MnTov,MnTovTr,aMnTov)
                  endif
                EndIf

                sele pr2kpk
                netrepl('kfo',{kfor})
                skip
              enddo
            endif
            nuse('rs2vz')
            nuse('tovvz')
          endif // найдена ТТН
          nuse('rs1vz')
        endif
      next mmr
      If lExit // ттн найдена
        exit
      EndIf
    next yyr
  else  // Только тара или товар без валидации
    sele pr2kpk
    set orde to tag t1
    if netseek('t1','mnr,skpkr')
      do while mn=mnr.and.skpk=skpkr
        MnTovr=MnTov
        if ((prTr=1 .and. int(MnTovr/10000)>1); // Только тара (ввели товар)
          .or. (prTr=2 .and. int(MnTovr/10000)<2)) // Только товар (ввели тару)
          outlog(__FILE__,__LINE__,'prTr',prTr,'MnTovr',MnTovr,'в возврат Тары-1 ввели Товар или в возврат Товар-2 ввели тару')
          sele pr2kpk
          skip ;     loop
        endif
        sele ctov
        if fieldpos('evz')#0 // Есть VоZрат
          evzr=getfield('t1','MnTovr','ctov','evz')
          if evzr#1
            outlog(__FILE__,__LINE__,'  !MnTovr,ctov,evz',MnTovr,evzr)
            sele pr2kpk
            skip ;  loop
          endif
        endif

        sele pr2kpk
        ktlr=ktl
        kfr=kf
        kfor=0
        if kfr#0
          MnTovr=MnTov

          sele tov
          set orde to tag t5

          If netseek('t5','sklr,MnTovr')
            If ktlr=0 .or. ktlr<0
            Else
              locate for ktlr=ktl While skl=sklr.and.MnTov=MnTovr
              outlog(__FILE__,__LINE__,ktlr, sklr,MnTovr,'ktlr, sklr,MnTovr')
            EndIf
          else
            // !netseek('t5','sklr,MnTovr') // нет в тек. меяце
          EndIf

          if found() // найдена карточка // найден товар или (товара и КТЛ)
            outlog(__FILE__,__LINE__,'// найдена карточка')
            If ktlr=0
              tov->(SeekTovOpt_eq_CenPr()) // строка товар без наценки
            endif
          else // не найден  товар или (товара и КТЛ)

            outlog(__FILE__,__LINE__,'sklr,MnTovr',sklr,MnTovr,'!found() тек. меяце')

            lSeekMnTov := .F.
            lSeekMnTov := SeekMnTovInSk(DirSkVzr)
            // If !lSeekMnTov
               // lSeekMnTov:=SeekMnTovInSk(DirSkr)
            // EndIf

            If !lSeekMnTov
              outlog(__FILE__,__LINE__,'sklr,MnTovr',sklr,MnTovr,'DirSkVzr нет в периоде')
              sele pr2kpk
              skip
              loop
            EndIf
          endif

          sele tov
          ktlr=ktl
          zenr=opt
          ozenr=opt
          If !empty(pr2kpk->Zen)
            ozenr=pr2kpk->Zen
          EndIf

          If Empty(ktlr)
            outlog(__FILE__,__LINE__,'mn,!!!ktl=0!!!,ktlp,MnTov,MnTovP',mnr,ktlr,ktlr,MnTovr,MnTovr)
          Else

            // не найдено или переоценка - не добавляем
            sele pr2
            set orde to tag t1
            if !netseek('t1','mnr,ktlr')
              netadd()
              netrepl('mn,ktl,ktlp,MnTov,MnTovP',{mnr,ktlr,ktlr,MnTovr,MnTovr})
            endif
            netrepl('kf',{kf+kfr})
            kfor=kfor+kfr
            netrepl('zen,ozen',{zenr,ozenr})
            sfr=roun(kf*zen,2)
            netrepl('sf,sr',{sfr,sfr})

            sele pr2kpk
            netrepl('kfo',{kfor})

            if pr1kpk->TtnVz = -169 // возрат или пероценка
              // подставим ктл
              lrs2->(netseek('t1','ttn_r+1'))
              lrs2->(netrepl("ktl",{ktlr}))
            endif

          EndIf
        endif

        sele pr2kpk
        skip
        if !(mn=mnr.and.skpk=skpkr)
           exit
        endif
      enddo
    endif
  endif

  sele pr1
  go rcpr1r
  mnr=mn
  ndr=nd
  vor=vo
  kopr=kop
  kpsr=kps
  ktar=kta
  qr=mod(kopr,100)
  //RndSdvr=getfield('t1','0,1,vor,qr','soper','RndSdv')
  TCenr=getfield('t1','1,1,vor,qr','soper','TCen')
  sktr=getfield('t1','1,1,vor,qr','soper','ska')
  mskltr=getfield('t1','sktr','cskl','mskl')
  CZenr=allt(getfield('t1','TCenr','TCen','zen'))
  if mskltr=0
    skltr=getfield('t1','sktr','cskl','skl')
  else
    skltr=kpsr
  endif
  kzgr=kzg
  netrepl('skt,sklt',{sktr,skltr},1)

  ktar=kta
  ktasr=ktas
  if ktar#0.and.ktasr=0
    ktasr=getfield('t1','ktar','s_tag','ktas')
    netrepl('ktas',{ktasr},1)
  endif
  napr=0
  if ktar#0
    napr=getfield('t1','ktar','ktanap','nap')
    if napr=0
        if ktasr#0
          napr=getfield('t1','ktasr','ktanap','nap')
        endif
    endif
  endif
  if fieldpos('nap')#0
    netrepl('nap',{napr},1)
  endif

  // Перерасчет основного
  sele pr1
  go rcpr1r
  PrPere()

  sele pr1
  go rcpr1r
  sdvr=sdv

  sele pr1kpk
  go rcpr1kpkr
  netrepl('sdv',{sdvr})

  nuse('pr1')
  nuse('pr2')
  nuse('pr3')
  nuse('soper')
  nuse('tov')
  nuse('tovm')
  nuse('pr1kpk')
  nuse('pr2kpk')

  gnD0k1:=lc_gnD0k1

  return .t.

*************
static Function vo9nof()
  *************
  skr=gnEntrm2skl(skl)

  do case
  case skr=228
    skr=259
  case skr=400
    skr=403
  othe
    return .t.
  endc
  ttn_r=ttn
  DocGuid_r=DocGuid
  ttnc_r=ttnp
  kgpr=kgp
  pr61r=val(subs(ser,1,1))
  pr46r=val(subs(ser,2,1))
  DocIdr=DocId // lrs1
  RcLrs1r=recn()
  nuse('rs1')
  nuse('rs2')
  nuse('rs3')
  nuse('rs2m')
  nuse('soper')
  nuse('tov')
  nuse('tovm')
  nuse('rs1kpk')
  nuse('rs2kpk')
  sele cskl
  if netseek('t1','skr')
     Pathr=gcPath_d+allt(path)
     sklr=skl
  else
     return .t.
  endif
  netuse('rs1',,,1)
  netuse('rs2',,,1)
  netuse('rs3',,,1)
  netuse('rs2m',,,1)
  netuse('soper',,,1)
  netuse('tov',,,1)
  netuse('tovm',,,1)
  netuse('rs1kpk',,,1)
  netuse('rs2kpk',,,1)
  prcrdocr=0 // Признак создания документа
  sele lrs2
  set orde to tag t1
  if netseek('t1','ttn_r')
     do while ttn=ttn_r
        MnTovr=MnTov
        MnTovTr=getfield('t1','MnTovr','ctov','MnTovT')
        if MnTovTr=0
           MnTovTr=MnTovr
        endif
        sele tov
        set orde to tag t10
        if netseek('t10','sklr,MnTovTr')
           do while skl=sklr.and.MnTovT=MnTovTr
              if osv#0
                 prcrdocr=1
                 exit
              endif
              sele tov
              skip
              if !(skl=sklr.and.MnTovT=MnTovTr)
                 exit
              endif
           enddo
        endif
        if prcrdocr=1
           exit
        endif
        sele lrs2
        skip
        if ttn#ttn_r
           exit
        endif
     enddo
  endif

  if prcrdocr=0
     nuse('rs1')
     nuse('rs2')
     nuse('rs3')
     nuse('rs2m')
     nuse('soper')
     nuse('tov')
     nuse('tovm')
     nuse('rs1kpk')
     nuse('rs2kpk')
     return .t.
  endif

  sele tov
  set orde to tag t1

  sele lrs1
  arec:={}
  getrec()
  TtnCor=0
  Ttnr=0 //!!
  TtnPr=0
  TtnCr=0
  store 0 to rcTtnPr,rcTtnCr
  DocId_r=DocId // lrs1
  // Товарный документ

  sele cskl
  reclock()
  Ttnr=ttn
  do while .t.
     if netseek('t1','Ttnr','rs1')
        sele cskl
        if ttn<999999
           netrepl('ttn',{ttn+1},1)
        else
           netrepl('ttn',{1},1)
        endif
        Ttnr=ttn
     else
        sele cskl
        if ttn<999999
           netrepl('ttn',{ttn+1})
        else
           netrepl('ttn',{1})
        endif
        exit
     endif
  enddo

  TtnPr=Ttnr
  TtnCr=0
  sele rs1
  netadd()
  putrec()
  netrepl('ttn,skl,ddc,dvp,pst,ttnp,ttnc,rmsk,dtmod,tmmod,sert',{Ttnr,sklr,date(),date(),1,0,0,gnRmSk,date(),time(),0},1)
  netrepl('prkpk',{1},1)
  netrepl('prdec',{1},1)
  rcTtnPr=recn()
  sele lrs1
  netrepl('kps',{Ttnr})

  // Запись заявки
  sele rs1kpk
  if ttn_r<=ttn_rrr
     netadd()
     putrec()
     nnzr=str(ttn,6)
     netrepl('ttn,skpk,nnz,ddc,tdc,sdv,sdvm,sdvt',{Ttnr,skpkr,nnzr,date(),time(),0,0,0})
     netrepl('prdec',{1},1)
  else
     sele lrs1
     locate for DocId=DocIdr.and.ttn#ttn_r
     Ttnr=kps
     go RcLrs1r
  endif

  sele lrs2
  set orde to tag t1
  if netseek('t1','ttn_r')
     do while ttn=ttn_r
        MnTovr=MnTov
        kvpor=kvpo
        arec:={}
        getrec()
        sele rs2kpk
        if !netseek('t1','Ttnr,skpkr,MnTovr')
           netadd()
           putrec()
           netrepl('ttn,skpk',{Ttnr,skpkr})
        endif
        netrepl('kvpo',{kvpo+kvpor})
        sele lrs2
        skip
        if ttn#ttn_r
           exit
        endif
     enddo
  endif

  sele rs1
  DocIdr=Ttnr
  Ttnr=ttn
  vor=vo
  kopr=kop
  kopir=kopi
  kplr=kpl
  if kopir=0
     kopir=kopr
     netrepl('kopi',{kopir},1)
  endif
  /*
  *  if kopr=kopir
  *     kop_r=kopr
  *  else
  *     kop_r=kopir
  *  endif
  */
  kop_r=kopr
  qr=mod(kop_r,100)
  RndSdvr=getfield('t1','0,1,vor,qr','soper','RndSdv')
  TCenr=getfield('t1','0,1,vor,qr','soper','TCen')
  sktr=getfield('t1','0,1,vor,qr','soper','ska')
  mskltr=getfield('t1','sktr','cskl','mskl')
  CZenr=allt(getfield('t1','TCenr','TCen','zen'))
  if mskltr=0
     skltr=getfield('t1','sktr','cskl','skl')
  else
     skltr=kplr
  endif
  kgpr=kgp
  nkklr=kplr
  kpvr=kgpr //kpvr=kpv
  tmestor=getfield('t2','nkklr,kpvr','etm','tmesto')
  if tmestor=0
     tmestor=getfield('t2','nkklr,kpvr','tmesto','tmesto')
  endif
  netrepl('nkkl,kpv,skt,sklt,tmesto,RndSdv',{nkklr,kpvr,sktr,skltr,tmestor,RndSdvr},1)
  if DocId_r#0
     netrepl('DocId',{DocIdr},1)
  else
     netrepl('DocId',{0},1)
  endif
  if kopr=169
     netrepl('kpl,kgp',{20034,20034},1)
     kplr=20034
     kgpr=20034
     if getfield('t1','nkklr','kln','kkl1')=0
        nkklr=20034
        netrepl('nkkl',{nkklr},1)
     endif
  endif
  if kopr=168
     kplr=getfield('t1','0,1,vor,qr','soper','kpl')
     kgpr=getfield('t1','0,1,vor,qr','soper','kkl')
     netrepl('kpl,kgp',{kplr,kgpr},1)
  endif
  if nkklr=0
     netrepl('nkkl',{kpl},1)
  endif
  if kpv=0
     netrepl('kpv',{kgp},1)
  endif
  ktar=kta
  ktasr=ktas
  if ktar#0.and.ktasr=0
     ktasr=getfield('t1','ktar','s_tag','ktas')
     netrepl('ktas',{ktasr},1)
  endif
  napr=0
  if ktar#0
     napr=getfield('t1','ktar','ktanap','nap')
     if napr=0
        if ktasr#0
           napr=getfield('t1','ktasr','ktanap','nap')
        endif
     endif
  endif
  if fieldpos('nap')#0
     netrepl('nap',{napr},1)
  endif
  doguslr=0
  sele kpl
  netseek('t1','nKklr')
  if pr61r=1
     prksz61r=prksz61
     smksz61r=smksz61
  else
     prksz61r=0
     smksz61r=0
  endif
  // Признак наличия договорных условий
  if empty(dtnace).or.dtnace<gdTd
     doguslr=0
  else
     doguslr=1
  endif
  sele rs1
  pTarAr=0
  sele lrs2
  set orde to tag t1
  if netseek('t1','ttn_r')
     do while ttn=ttn_r
        sele lrs2
        MnTovr=MnTov
        if int(MnTovr/10000)<2
           sele lrs2
           skip
           loop
        endif
        if !chkmkkgp(MnTovr,kgpr)
           sele lrs2
           skip
           loop
        endif
        if gnEnt=20.and.kopr=169.and.int(MnTovr/10000)=340
           sele lrs2
           skip
           loop
        endif
        sele rs2kpk
        netseek('t1','DocIdr,skpkr,MnTovr')
        sele lrs2
        kvpr=kvp
        VKolr=kvpr
        MnTovTr=getfield('t1','MnTovr','ctov','MnTovT')
        if MnTovTr=0
           MnTovTr=MnTovr
        endif
        MinOsvr=getfield('t1','MnTovTr','ctov','minosv')
        if MinOsvr#0
           osv_rr=0
           sele tov
           set orde to tag t10
           if netseek('t10','sklr,MnTovTr')
              do while skl=sklr.and.MnTovT=MnTovTr
                 if fieldpos('BlkKpk')#0.and.BlkKpk#0
                   skip;                       loop
                 endif
                 if (otv=0.and.osv<=0).or.(otv=1.and.osvo<=0)
                    skip
                    loop
                 endif
                 osv_rr=osv_rr+osv
                 sele tov
                 skip
                 if !(skl=sklr.and.MnTovT=MnTovTr)
                    exit
                 endif
              enddo
           endif
           if osv_rr-MinOsvr<=0
              VKolr=0
           else
              if osv_rr-MinOsvr-VKolr<=0
                 VKolr=osv_rr-MinOsvr
              endif
           endif
        endif
        if VKolr>0
           sele tov
           set orde to tag t10
           if netseek('t10','sklr,MnTovTr')
              do while skl=sklr.and.MnTovT=MnTovTr
                 mkeep_r=getfield('t1','MnTovTr','ctov','mkeep')
                 BlkMk_r=getfield('t1','mkeep_r','mkeep','BlkMk')
                 rc_tovr=recn()
                 if fieldpos('BlkKpk')#0.and.BlkKpk#0
                   skip;                       loop
                 endif
                 if otv=0.and.osv<=0
                    skip;                    loop
                 endif
                 if otv=0.and.BlkMk_r=2.and.gnEntRm=0 // Блокировка выписки с выкупленных остатков
                    skip;                    loop
                 endif
                 if otv=1.and.BlkMk_r=3.and.gnEntRm=0 // Блокировка выписки с остатков отв хр
                    skip ;                    loop
                 endif
                 if otv=1.and.osvo<=0
                    skip;                    loop
                 endif
                 MnTovr=MnTov
                 k1tr=k1t
                 VKolr=rs2tvi(VKolr)
                 if VKolr<=0
                    exit
                 endif
                 sele tov
                 set orde to tag t10
                 go rc_tovr
                 skip
                 if !(skl=sklr.and.MnTovT=MnTovTr)
                    exit
                 endif
              enddo
           else
              #ifdef __CLIP__
                 outlog(__FILE__,__LINE__,"seek tov T10 ERR",sklr,MnTovTr)
              #endif
           endif
        endif
        sele lrs2
        netrepl('kvp,kvpo',{kvp-kvpo,0})
        skip
        if ttn#ttn_r
           exit
        endif
     enddo
  endif
  sele rs1
  go rcTtnPr
  if rs1->DocId#0.and.;
    (  gnEnt=20.and.(rs1->kop=177.or.rs1->kop=168);
    .or.gnEnt=21.and.rs1->kopi=177.and.rs1->kop#177)
     ttn_r=DocId
     kpsr=ttn
     if netseek('t1','ttn_r')
        netrepl('kps',{kpsr})
     endif
  endif
  sele rs1
  go rcTtnPr
  pTarAr=ttnc_r
  if gnEnt=20
     if kop=177
        akc_r=1
     else
        akc_r=0
     endif
  endif
  if gnEnt=21
     if kopi=177
        akc_r=1
     else
        akc_r=0
     endif
  endif
  sele rs2
  prTarr=0 // Признак наличия тары в родительском документе
  prBsor=0 // Признак наличия БСО
  if netseek('t1','TtnPr')
     do while ttn=TtnPr
        MnTov_r=MnTov
        if int(MnTov/10000)=0
           prTarr=1
        endif
        if int(MnTov/10000)>1
           kg_r=int(MnTov_r/10000)
           lic_r=getfield('t1','kg_r','cgrp','lic')
           if lic_r#0
              prBsor=1
           endif
        endif
        sele rs2
        skip
        if ttn#TtnPr
           exit
             endif
     enddo
  endif

  nRet:=901
  sele rs1
  go rcTtnPr
  netrepl('KtoFp,dfp,tfp',{nRet,date(),time()},1)
  if prTarr=1.and.(pTarAr=1.or.akc_r=1).and..f.
     // Тарный документ
     sele cskl
     reclock()
     TtnCr=ttn
     if TtnCr=TtnPr
        if ttn<999999
           netrepl('ttn',{ttn+1})
        else
           netrepl('ttn',{1})
        endif
        TtnCr=ttn
     endif

     sele cskl
     reclock()
     TtnCr=ttn
     do while .t.
        if netseek('t1','TtnCr','rs1')
           sele cskl
           if ttn<999999
              netrepl('ttn',{ttn+1},1)
           else
              netrepl('ttn',{1},1)
           endif
           TtnCr=ttn
        else
           sele cskl
           if ttn<999999
              netrepl('ttn',{ttn+1})
           else
              netrepl('ttn',{1})
           endif
           exit
        endif
     enddo

     sele rs1
     go rcTtnPr
     kplr=nkkl
     kgpr=kpv
     arec:={}
     getrec()
     netadd()
     putrec(,'ttn')
     netrepl('ttn,kop,ttnp,kpl,kgp,ttnc,rmsk,dtmod,tmmod,DocGuid,bso',{TtnCr,170,TtnPr,kplr,kgpr,0,gnRmSk,date(),time(),"",0},1)
     rcTtnCr=recn()
     go rcTtnPr
     netrepl('ttnc,ttnp',{TtnCr,0},1)
     sele rs2
     set orde to tag t1
     if netseek('t1','TtnPr')
        do while ttn=TtnPr
           rcrs2pr=recn()
           if int(MnTov/10000)#0
              skip
              loop
           endif
           if kvp=0
              skip
              loop
           endif
           ktlr=ktl
           MnTovr=MnTov
           MnTovPr=MnTovP
           pptr=ppt
           kvpr=kvp
           srr=sr
           svpr=svp
           arec:={}
           getrec()
           sele rs2
           if !netseek('t3','TtnCr,ktlr,0,ktlr')
              netadd()
              putrec()
              netrepl('ttn,ppt,MnTovP,ktlp',{TtnCr,0,MnTovr,ktlr})
           else
              netrepl('kvp,sr,svp',{kvp+kvpr,sr+srr,svp+svpr})
           endif
           sele rs2m
           if !netseek('t3','TtnCr,MnTovr,0,MnTovr')
              netadd()
              putrec()
              netrepl('ttn,ppt,MnTovP,ktlp,ktl',{TtnCr,0,MnTovr,0,0})
           else
              netrepl('kvp,sr,svp',{kvp+kvpr,sr+srr,svp+svpr})
           endif
           sele rs2m
           if netseek('t3','TtnPr,MnTovPr,pptr,MnTovr')
              netrepl('kvp,sr,svp',{kvp-kvpr,sr-srr,svp-svpr})
           endif
           sele rs2
           go rcrs2pr
           netdel()
           skip
           if ttn#TtnPr
              exit
           endif
        enddo
     endif
  endif
  if skr#ngMerch_Sk241 //мерч склад
     // Перерасчет основного
     sele rs1;     go rcTtnPr

     DocPereRs()
     sele rs1;     go rcTtnPr

     TtnCr=ttnc
     sdvr=sdv
     sdvmr=sdvm
     sdvtr=sdvt
     sele rs1kpk
     if netseek('t1','DocIdr,skpkr')
        netrepl('sdv,sdvm,sdvt',{sdv+sdvr,sdvm+sdvmr,sdvt+sdvtr})
     endif
     if TtnCr#0.and..f.
       // Перерасчет тарного
       sele rs1
       go rcTtnPr
       kopr=kop
       go rcTtnCr
       netrepl('kopi',{kopr})
       DocTPereRs()
     endif
  endif
  nuse('rs1')
  nuse('rs2')
  nuse('rs3')
  nuse('rs2m')
  nuse('soper')
  nuse('tov')
  nuse('tovm')
  nuse('rs1kpk')
  nuse('rs2kpk')
  sele lrs1
  go RcLrs1r
  nnzr=str(TtnPr,6)
  netrepl('nnz,ttnc',{nnzr,TtnCr})
  return .t.


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-28-16 * 02:26:41pm
 НАЗНАЧЕНИЕ.........
     * Разделение kop=129 для mkeep.pr129=1
     * Разделение kop=139 для mkeep.pr139=1
     * Разделение kop=169 для mkeep.pr169=1
     *     ttn_rrr=ttn_rr  // Последняя заявка в lrs1
     *     ttn_rr=ttn_rr+1 // счетчик ttn для lrs1
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION tMkKop(cKop,cLsKop139)
  LOCAL nRet, cktar
  // к-во строк товара пропущенных и не попалших для дока "свертка"
  //  для 21-го пре-тия, пропущенны=0 должно быть
  LOCAL nCntSkip

  If file('tmk.dbf');    erase tmk.dbf;  EndIf
  crtt('tmk','f:mkeep c:n(6) f:ttn c:n(6) f:KtoFp c:n(4)')

  use tmk new excl
  sele lrs1
  go bott
  ttn_rr=ttn+1
  sele lrs1
  go top
  do while !eof() // просморе всех доков с указанным КОП.
    if kop # VAL(cKop) //129
        skip ;           loop
    endif
    if 0 # FIELDGET(FIELDPOS("mk"+cKop))  //mk129
        skip ; loop
    endif
    if kps#0
        skip ; loop
    endif
    if bprz#0
        skip ; loop
    endif

    IF cKop $ cLsKop139 //"129;139"
      netrepl('dfp',{BLANK(Date())})
    ENDIF

    RcLrs1r=recn()
    ttn_r=ttn
    KtoFpr:=KtoFp
    DocGuid_r:=DocGuid
    sele tmk; zap

    sele lrs2; set orde to tag t1
    if netseek('t1','ttn_r')
      nCntSkip:=0
      outlog(3,__FILE__,__LINE__,'ttn_r,cKop,cLsKop139',ttn_r,cKop,cLsKop139)
      do while ttn=ttn_r
        MnTovr=MnTov
        kvpr:=kvp
        // вычил маркодержателя
        mkeepr:=getfield('t1','MnTovr','ctov','mkeep')
            outlog(3,__FILE__,__LINE__,'выч маркодержателя',mkeepr,MnTovr,'mkeepr,MnTovr')
        if mkeepr # 0
          outlog(3,__FILE__,__LINE__," разрешено ли проводить код операции", 'pr'+cKop)
          prXXXr=getfield('t1','mkeepr','mkeep', 'pr'+cKop)//'pr129')
            outlog(3,__FILE__,__LINE__,prXXXr,'pr'+cKop,mkeepr,'prXXXr,'+'pr'+cKop+',mkeepr')
          if prXXXr # 0 .and. BrandCodeList(cKop,cLsKop139)
            outlog(3,__FILE__,__LINE__,' проверка')
            //  проверка 69 МКД на списание. В продажах на послед. два месяца
            // данные берутся в выгрузке для
            do case
            case mkeepr = 69 .and. cKop = '139'
              outlog(3,__FILE__,__LINE__, "If 69 139", lrs1->kgp, lrs2->MnTov)
              cktar:=PADL(LTRIM(STR(lrs1->kta,3)), 3, "0")
              cAls:='k'+cKtar+'sale'
              If select(cAls) = 0
                cDir := posdel(gcPath_l, ,3) + 'put'
                outlog(3,__FILE__,__LINE__,cDir,cDir+'\'+cAls+'.dbf',file(cDir+'\'+cAls+'.dbf'),file(cDir+'/'+cAls+'.dbf'))
                If file(cDir+'\'+cAls+'.dbf')
                  use (cDir+'\'+cAls) alias (cAls) NEW
                EndIf
              EndIf
              If !(select(cAls) = 0)
                select (cAls)
                //поиск ГП, товара и Отгрузки товар в течении 21-го дня
                LOCATE FOR lrs1->kgp = kgp .and. lrs2->MnTov = MnTov ;
                .and. (date()+1) - dop < 21
                If FOUND()
                  KtoFpr := (-69)
                  mkeepr := (-69)
                  kvpr := kvpr/1000*1000 // для учета повторной заявки на списание
                  outlog(__FILE__,__LINE__,"да    ", "Отг тов 21-го дня",dop,ttn,kvpr)
                else
                  // поиск выписанного 139
                  sele rs2
                  If netseek('t4','MnTovr')

                    sele rs2
                    LOCATE FOR  rs1->kop = 139 .and. lrs1->kgp = rs1->kpv ;
                    .and. rs1->dvp < date() ; // не за сегоднишнию дату
                    .and. (date()+1) - rs1->dvp < 21 ; // 21 день..
                    WHILE MnTovr = MnTov

                    If found()
                      KtoFpr := (-68)
                      mkeepr := (-69)
                      kvpr := kvpr/1000*1000 // для учета повторной заявки на списание
                      outlog(3,__FILE__,__LINE__,"да  вып", "139 21-го",rs1->dvp,rs1->ttn,kvpr)
                    else
                      outlog(3,__FILE__,__LINE__,"нет вып", "139 21-го")
                    EndIf
                  Else
                    outlog(3,__FILE__,__LINE__,"нет товара", "netseek('t4','MnTovr')")
                  EndIf
                  If mkeepr > 0
                    outlog(3,__FILE__,__LINE__,"все ОК!", "Отг тов 21-го дня",MnTov)
                    KtoFpr := 901
                  EndIf

                EndIf
              Else
                // вручную подверждение
              EndIf
            case cKop = '139' // для других МД покажим чз минус МД
              outlog(3,__FILE__,__LINE__, "cKop = '139' для других МД")
              KtoFpr := (-1) * mkeepr
            case cKop = '169'
              // вне зависмости от МК в одни документ
              outlog(3,__FILE__,__LINE__, "cKop = '169'")
              mkeepr := -169
            Endcase

            // запомним по МД номер ТТН во врем.базе новые шапки
            sele tmk
            locate for mkeep == mkeepr
            if !foun()
              appe blank
              repl mkeep with mkeepr, ttn with ttn_rr, KtoFp with KtoFpr
              ttn_rr:=ttn_rr+1
            endif
            // запишем МД в строку для того, чтобы понять какой ном.ТТН
            sele lrs2
            netrepl('izg,kvp',{mkeepr,kvpr})
          else
            nCntSkip++
          endif
        else
          nCntSkip++
        endif
        sele lrs2
        skip
        if ttn#ttn_r
          exit
        endif
      enddo

      Do Case
      Case gnEnt=20
        //  обрабатываем все
        nCntSkip:=0
      Case gnEnt=21 .and. nCntSkip # 0
        // для Лодиса, пропущенные строки товара
      EndCase
      nCntSkip:=0
      outlog(3,__FILE__,__LINE__,' nCntSkip',nCntSkip)

      // созданем новые документы
      If nCntSkip = 0
        sele tmk
        go top
        do while !eof()
          ttnXXX_r:=ttn
          mkeepr:=mkeep
          KtoFpr:=KtoFp

          If tmk->(LastRec())=1 // всю накладную передвинули
            sele lrs1
            DocGuid_r:=DocGuid
            netrepl('DocGuid', {''}) // обнулим
          EndIf

          // новая шапка
          sele lrs1
          arec:={}; getrec()
          netadd(); putrec()
          netrepl('TimeCrt,TimeCrtFrm,GpsLat,GpsLon',{'','','',''},1)
          netrepl('ttn,DocGuid,mk'+cKop,{ttnXXX_r,DocGuid_r,ABS(mkeepr)})

          netrepl('KtoFp,dfp,tfp',{KtoFpr,BLANK(date()),''})
          Do Case
          Case mkeepr = 69
            netrepl('KtoFp,dfp,tfp',{KtoFpr,date(),time()})
          Case mkeepr = -69 //.and. KtoFpr = 0
            netrepl('KtoFp,dfp,tfp',{KtoFpr,BLANK(date()),''})
          EndCase

          // смотрим старые номера ТТН
          sele lrs2
          set orde to tag t1
          if netseek('t1','ttn_r')
            do while ttn=ttn_r
              rcLrs2r=recn()
              if izg#mkeepr
                skip; loop
              endif
              arec:={}; getrec()
              netadd(); putrec()
              netrepl('ttn',{ttnXXX_r})
              netrepl('izg',{ ABS(izg) })
              go rcLrs2r
              netdel()
              sele lrs2
              skip
              if ttn#ttn_r
                exit
              endif
            enddo
          endif
          sele tmk
          skip
          if eof();exit;endif
        enddo
      EndIf
    endif

    sele lrs1
    go RcLrs1r
    skip
    if eof();exit;endif
  enddo
  sele tmk
  use
  //erase tmk.dbf
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  01-16-17 * 03:09:34pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION tzvk_chsk()
  LOCAL rcLrs2r, nRet
  tzvk_crt()

  // получим список задания
  sele rs1
  DBEval(;
  {||tzvk_ztxt(rs1->nkkl,rs1->kpv,rs1->ztxt,rs1->ttn)},;
  {||rs1->dvp = date() .and. !empty(ztxt)};
  )

  sele rs1
  DBGoTop()
  DO WHILE !EOF()
    // тек дата
    If rs1->dvp = date()
    else
      DBSkip()
      loop
    EndIf
    // проведен
    If rs1->KtoFp = -901 .and. !(STR(rs1->kop) $ KPL_LSKOP139) //cLsKop139)
      outlog(3,__FILE__,__LINE__,rs1->ttn,'rs1->ttn')
      nRet:=0
      nRet:=FirstChk_FinCtrl(nRet)
      sele rs1
      If nRet<0
        netrepl('KtoFp,dfp,tfp',{nRet,BLANK(Date()),''},1)
      Else
        netrepl('KtoFp,dfp,tfp',{nRet,date(),time()},1)
      EndIf
      DBSkip() // за два прохода
      loop
    EndIf

    // без фин. контроля по финансам
    If ((empty(rs1->dfp),.t.) ;
      .and. (rs1->KtoFp < -900  .or. rs1->KtoFp = -777 .or. rs1->KtoFp = -222))
    else
      DBSkip()
      loop
    EndIf
    outlog(__FILE__,__LINE__,rs1->ttn, rs1->nkkl, rs1->Kpv)

    If rs1->kop = 169 .or. rs1->kop = 168
      //outlog(__FILE__,__LINE__, "kop 169 не проверяется")
      #ifdef __CLIP__
      oKgp:=List_Kgp2Kpl(rs1->Kpv,rs1->Nap)
      nRet:=-901 // пустой список
      //по каждому Плат(kpl) просчитать ФинКонтр
      For z in oKgp
        rs1_nkkl := z:kpl
        if dkkln->(netseek("t1","rs1_nkkl,361001"))
          nRet:=Dz_FinCtrl(z:kpl, z:kgp, z:Nap, rs1->KtoFp, KPL_DZ)
        else
          nRet:=901 //ok!!
        endif
        if nRet < 0
          outlog(__FILE__,__LINE__,"kop=169", z:kgp, z:kpl,z:nap, "nRet:=",nRet)
          exit
        else
          //outlog(__FILE__,__LINE__,"kop=169", z:kgp, z:kpl,z:nap, "nRet:=",nRet)
        endif
      Next
      if nRet >= 0 // oKgp - пустой те нет Долгов оп этой ТТ
        nRet:=901 //ok!!
      elseif nRet = -901
        nRet:=901 //ok!!
        // outlog(__FILE__,__LINE__,"kop=169 список пуст", rs1->Kpv,rs1->Nap,'901')
      endif
      #endif
    ELSE

      nRet:=Dz_FinCtrl(rs1->nkkl, rs1->Kpv, rs1->Nap, rs1->KtoFp, KPL_DZ)

    ENDIF

    If EMPTY(rs1->DocId) .or. rs1->DocId = rs1->Ttn
      nRet:=KtoFp_Post(nRet)
    ELSE
      // берем из связанного д-та
      nRet:=getfield('t1','rs1->DocId','rs1','KtoFp')
    EndIf

    // запись данных
    sele rs1
    if .t.
      If nRet <= 0
        netrepl('KtoFp,dfp,tfp',{nRet,BLANK(Date()),''},1)
      Else
        netrepl('KtoFp,dfp,tfp',{nRet,date(),time()},1)
      EndIf
    EndIf

    sele rs1
    DBSkip()
  enddo
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  01-17-17 * 10:41:39am
 НАЗНАЧЕНИЕ......... Деб. задол проверка
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION Dz_FinCtrl(nlKpl, nlKgp, nlNap, nRetOld, nMinDz)
  LOCAL nDz,  nRet, nSumZdn,  nSumNap
  // наличие карты покупателя
  Kplr:=nlKpl

  If dkkln->(netseek("t1","Kplr,361001"))

    // просчет суммы Задания по плательщику
    sele tzvk
    SUM sdv TO nSumZdn FOR nlKpl = tzvk->kpl

    //сумма долга из Кар.покуп
    nDz:= round((dkkln->DN - dkkln->KN) + (dkkln->DB - dkkln->KR),2)

    IF nSumZdn = 0 ;// ЗДН нет
      .and. nDz > nMinDz
      If nRetOld = -903 //.or. nRetOld = -901
        nRetOld:=-933
      EndIf
      outlog(__FILE__,__LINE__,' ',nRetOld,nSumZdn,'nSumZdn',nDz,'nDz',nMinDz,'nMinDz')
      RETURN (nRetOld)
    ENDIF

    outlog(__FILE__,__LINE__,'  nSumZdn',nSumZdn)

    Do Case
    // сумма_долга - cумма_задания > 0
    Case nDz - nSumZdn > nMinDz
      // сумма ЗДН по Напр
      sele tzvk
      SUM sdv TO nSumNap ;
      FOR nlKpl = tzvk->kpl .and. nlNap = tzvk->Nap
      outlog(__FILE__,__LINE__,'  nSumNap Nap',nSumNap,rs1->Nap)

      sele rs1
      nRet:=skdoc->(Acrd_FinCtrl(nlKpl,nlNap,nMinDz,nSumZdn,nSumNap))
      If nRet > 0
        outlog(__FILE__,__LINE__,'  Ok! Acrd_FinCtrl', nRet)
      EndIf
    OtherWise
      // сумма долга меньше чем задание или =
      nRet:=901 //ok!!
      If nRet > 0
        outlog(__FILE__,__LINE__,'  Ok! nDz - nSumZdn > KPL_DZ', nDz, nSumZdn,nDz-nSumZdn, KPL_DZ)
      EndIf
    EndCase
  ELSE
    // нет карты по  361001
    nRet:=901 //ok!!
  ENDIF
  RETURN (nRet)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  01-17-17 * 10:23:55am
 НАЗНАЧЕНИЕ......... получить список Плат(kpl)  по ТоргТочк (kgp)
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION List_Kgp2Kpl(nlKgp,nlNap)
  kgpr := nlKgp
  #ifdef __CLIP__
  skdoc->(OrdSetFocus("t2"))
  oKgp:=map()
  IF skdoc->(netseek("t2","kgpr"))
    //
    DO WHILE skdoc->Kgp = nlKgp
      Key := str(nlKgp)
      If Key $ oKgp
      Else
        oKgp[Key]     := map()
        oKgp[Key]:kpl := skdoc->Kpl
        oKgp[Key]:kgp := nlKgp
        oKgp[Key]:nap := nlNap
      EndIf
      skdoc->(DBSkip())
    enddo
  ENDIF
  #endif
  RETURN (oKgp)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  03-09-10 * 10:46:18am
 НАЗНАЧЕНИЕ......... nMinDz - минимальна деб.задол
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION Acrd_FinCtrl(nlKpl,nlNap,nMinDz,nSumZdn,nSumNap)
  #define ACRD_CHSK_SUM
  LOCAL nCntDay3 := KPL_NCNTDAY3  // 3 // технические дни
  LOCAL nCntDay9 := KPL_NCNTDAY9  // 21 // (3+6)
  LOCAL nCntYear3:= KPL_NCNTYEAR3 // 365*3  // документы 3 летней давности не берем
  LOCAL lZdn:=NO
  IF !ISNIL(nSumZdn)
    lZdn:=YES
  ENDIF
  DEFAULT nSumNap TO 0
  DEFAULT nSumZdn TO 0
  Kplr:=nlKpl
  Napr:=nlNap
  nSumDZ_9:=999999
  nSumDZ_3:=999999

  Ordsetfocus("t1")
  IF netseek("t1","Kplr")
    nRec:=RECNO()

    //проверка по клиенту на скорк оплаты по всем направлениям
    #ifdef ACRD_CHSK_SUM

      SUM Sdp TO nSumDZ_9 WHILE Kpl == nlKpl ;
      FOR (d1d2:= date() - DtOpl,(d1d2 > nCntDay9 .and. d1d2 < nCntYear3))

      outlog(__FILE__,__LINE__,' 21 nSumDZ_9 -= nSumZdn',nSumDZ_9,nSumZdn,nSumDZ_9 -= nSumZdn)

      // отключение проверки по всем направления
      nSumDZ_9 := KPL_DZ9

      IF nSumZdn # 0
         nSumDZ_9 -= nSumZdn
      ENDIF
    #else
      locate while Kpl == nlKpl ;
      for (d1d2:= date() - DtOpl,(d1d2 > nCntDay9 .and. d1d2 < nCntYear3))
      If !found()
        nSumDZ_9:=0
      EndIf
    #endif

    If nSumDZ_9 <= nMinDz // но долг есть
      DBGoTo(nRec)

      #ifdef ACRD_CHSK_SUM
        SUM Sdp TO nSumDZ_3 ;
        WHILE Kpl == nlKpl ;
        FOR (d1d2:= date() - DtOpl,(d1d2 > nCntDay3  .and. d1d2 < nCntYear3)) ;
        .and. Nap = nlNap

        outlog(__FILE__,__LINE__,' 3 nSumDZ_3 -= nSumNap', nlNap, nSumDZ_3,;
        nSumNap,nSumDZ_3 - nSumNap)
        If nSumNap # 0
          // уменьшаем ДЗ
          nSumDZ_3 -= nSumNap
        EndIf
      #else
        //проверка по клиенту на скорк оплаты по направлению
        locate while Kpl == nlKpl ;
        FOR (d1d2:= date() - DtOpl,(d1d2 > nCntDay3 .and. d1d2 < nCntYear3)) ;
        .and. Nap = nlNap
        If !found()
          nSumDZ_3:=0
        EndIf
      #endif

      If nSumDZ_3 <= nMinDz
        Return (901)
      Else
        //outlog(__FILE__,__LINE__,Kplr,"найден клиент! Напр.:",Napr,"DtOpl > 3")
        Return iif(lZdn,(-933),(-903))
      EndIf

    else
      //outlog(__FILE__,__LINE__,Kplr,"найден клиент!", "DtOpl > (3+6)")
      Return (-900 + (-nCntDay9))
    EndIf
  ELSE
    //outlog(__FILE__,__LINE__,Kplr,"Не найден клиент")
    RETURN (-999)
  ENDIF

  RETURN (-999)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  01-20-17 * 02:26:22pm
 НАЗНАЧЕНИЕ......... // поверим можно ли писать в данную ТТН
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION isWr4curTtn()
  LOCAL nSel:=SELECT()
  LOCAL lRet:=YES
  LOCAL kplr, kopr, nCntRec

  sele lrs2
  count to nCntRec for ttn = lrs1->ttn
  If EMPTY(nCntRec)  // строк НЕТ
    sele lrs1
    nRec:=RecNo(); kplr := kpl;  kopr := kop
    DBSkip()
    Do While !eof()
      If kplr = kpl .and.  kopr = kop
        sele lrs2
        count to nCntRec for ttn = lrs1->ttn
        If !EMPTY(nCntRec) // строк ЕСТЬ в другой ТТН с тем же КОП
          lRet:=NO // дальше есть, писать нельзя
          exit
        EndIf

      EndIf
      sele lrs1
      DBSkip()
    enddo
    sele lrs1
    dbGoto(nRec)
  EndIf
  SELECT (nSel)
  RETURN (lRet)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  01-26-17 * 04:44:43pm
 НАЗНАЧЕНИЕ......... определить ГУИД без кода склада (чз точку)
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION DocGuid0(cDocGuid)
  LOCAL nPos
  IF gnEnt = 21
    nPos:=AT('.',cDocGuid)
    If !EMPTY(nPos)
      cDocGuid:=padr(left(cDocGuid,nPos-1),len(cDocGuid),' ')
    EndIf
  ENDIF
  RETURN (cDocGuid)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  02-19-17 * 09:24:35am
 НАЗНАЧЕНИЕ......... определение остновного склада по Удаленности gnEntRm
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION gnEntrm2skl(nSkl)
  if gnEntRm=0
     if empty(nSkl)
        skr=228
     else
        skr=skl
     endi
  else
     if empty(nSkl)
        skr=400
     else
        skr=skl
     endi
  endif
  RETURN (skr)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  03-02-17 * 01:18:42pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION KtoFp_Lev1(nRet)
  DO CASE
  CASE rs1->Sdv = 0 .AND. !EMPTY(rs1->ztxt)
    // док пустой и есть Задание ЗДН
    nRet := 901
  CASE dkkln->(netseek('t1','rs1->nkkl,361001'))
    // есть расчеты
    nRet:=0
  OTHERWISE
    // расчетов нет
    nRet:=901
  ENDCASE

  if nRet = 0
    // не регистрирован груз.получ
    if !netseek('t1','rs1->kpv','kgp')
      nRet:=-33
    EndIf
  EndIf
  RETURN (nRet)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  03-02-17 * 01:55:15pm
 НАЗНАЧЕНИЕ.........   проверка договоро и КОП прошла
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION KtoFp_Post(nRet)
  If nRet = 901 // расчеты есть
    if .not. dog(rs1->nkkl,rs1->kop) // .and. nRet = 901
      nRet:=-777 // нет договора
    endif
  EndIf

  if nRet = 901
    codelistr=getfield('t1','rs1->nkkl','kpl','codelist')
    if !empty(codelistr)
      ckopr=str(rs1->kop,3)
      if at(ckopr,codelistr)=0
          //wmess('Недопустимый код операции',2)
        nRet:=-222 //
      endif
    endif
  endif
  RETURN (nRet)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  03-20-17 * 11:14:33pm
 НАЗНАЧЕНИЕ......... первичная проверка на ФинКонторль
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION FirstChk_FinCtrl(nRet)
    nRet := KtoFp_Lev1(nRet)
    If nRet = 0
      If STR(rs1->kop) $ '169;168'

        #ifdef __CLIP__
        oKgp:=List_Kgp2Kpl(rs1->Kpv,rs1->Nap)
        //по каждому Плат(kpl) просчитать ФинКонтр
        For z in oKgp
          rs1_nkkl := z:kpl
          if dkkln->(netseek("t1","rs1_nkkl,361001"))
            Do Case
            Case round(;
              (dkkln->DN - dkkln->KN) + (dkkln->DB - dkkln->KR),2;
                    ) > KPL_DZ
              nRet:=skdoc->(Acrd_FinCtrl(z:kpl,z:Nap,KPL_DZ))
            OtherWise
              if nRet >= 0
                nRet:=901 //ok!!
              endif
            EndCase
          else
            if nRet >= 0
              nRet:=901 //ok!!
            endif
          endif

          if nRet < 0
            outlog(__FILE__,__LINE__,"kop=169",z:kgp,z:kpl,z:nap,"nRet:=",nRet)
            exit
          endif
        Next
        if nRet >= 0 // oKgp - пустой те нет Долгов оп этой ТТ
          nRet:=901 //ok!!
        endif

        #endif

      else

        if nRet = 0
          Do Case
          Case round(;
            (dkkln->DN - dkkln->KN) + (dkkln->DB - dkkln->KR),2;
                    ) > KPL_DZ
            nRet:=skdoc->(Acrd_FinCtrl(rs1->nkkl,rs1->Nap,KPL_DZ))
          OtherWise
            nRet:=901 //ok!!
          EndCase
        endif

        nRet := KtoFp_Post(nRet)

      EndIf

    EndIf
  RETURN (nRet)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  04-04-17 * 01:53:13pm
 НАЗНАЧЕНИЕ......... создает пустые шапки под ЗДН
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION CreTtn0_4Zdn(lCreTtn0_4Zdn)
  sele tzvk
  DBGoTop()
  Do While !eof()
    If Iif(lCreTtn0_4Zdn,.F., ttn2 # 0) //.F. //
      DBSkip(); loop
    EndIf
    sele lrs1
    locate for vo = 9 .and. kpl = tzvk->kpl .and.  kgp = tzvk->kgp
    ttnr:=ttn
    If Iif(lCreTtn0_4Zdn,.T.,!FOUND()) // .T. //
      locate for vo = 9
      If FOUND()
        aRec:={}; GetRec()

        // получение след номера
        lrs1->(DBGoBottom())
        ttnr:=lrs1->ttn
        ttnr:=ttnr+1

        // запись пустой шапки
        sele lrs1
        DBAppend()
        PutRec()
        _FIELD->ttn := ttnr
        _FIELD->kop := 160
        _FIELD->kopi:= 160
        _FIELD->sdv := 0
        _FIELD->kpl := tzvk->kpl
        _FIELD->kgp := tzvk->kgp
        _FIELD->DocGUID := 'TZVK-'+DTOS(date())+'T'+SecToTime(TimeToSec(),.T.)
        _FIELD->ddc := date()
        _FIELD->tdc := time()
        _FIELD->DtRo := date()

        sele tzvk
        netrepl('ttn2',{ttnr})

      EndIf
    else
      sele tzvk
      netrepl('ttn2',{ttnr})
    EndIf

    sele tzvk
    DBSkip()
  EndDo

  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  08-07-17 * 11:38:27am
 НАЗНАЧЕНИЕ......... найти строчку без наценки
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION SeekTovOpt_eq_CenPr()
  LOCAL nRecTov
  set orde to tag t5

  //  найти строчку без наценки
  /*
  nRecTov:=RecNo()
  locate for Opt = CenPr While skl = sklr .and. MnTov = MnTovr
  If !found()
    DBGoTo(nRecTov)
  EndIf
  */

  // последний !!!
  GoBottomFilt(NetKeySeek('t5','sklr,MnTovr'))

  RETURN (NIL)



/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  11-14-17 * 04:26:25pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION SeekMnTovInSk(DirSkVzr)
  LOCAL ln_sklr, ln_MnTovr

  ln_sklr := sklr
  ln_MnTovr := MnTovr

  // перебор месяцев где есть товар
  lSeekMnTov:=.F.
  DtVzr=BOM(gdTd);  dEnd:=STOD('20060901')
  Do While DtVzr >= dEnd

    Pathr=gcPath_e + pathYYYYMM(DtVzr) + "\" + DirSkVzr // путь склад источника
    outlog(3,__FILE__,__LINE__,'  проверка',Pathr)
    if netfile('tov',1)
      netuse('tov','TovVz',,1)
      set orde to tag t5

      // смена склада
      If ktlr#0 .or. 'tpst' $ Pathr .or. 'tpok' $ Pathr
        outlog(3,__FILE__,__LINE__,'sklr,MnTovr,ktlr',str(sklr,7),MnTovr,ktlr)
        // тк СкладТараПок
        sklr := kplr
        /*
        If .F. .and. !Empty(pr2kpk->MnTovP) // есть переброска с кода на код
          MnTovr := pr2kpk->MnTovP
        EndIf
        */
        //outlog(__FILE__,__LINE__,sklr,MnTovr,ktlr,'sklr,MnTovr,ktlr')
      Else
        //
      EndIf

      sele TovVz
      If netseek('t5','sklr,MnTovr')
        If ktlr=0
        Else
          locate for ktlr=ktl While skl=sklr.and.MnTov=MnTovr
        EndIf
      else
        //
      EndIf

      if found() // найден товар или (товара и КТЛ)

        If ktlr=0
          TovVz->(SeekTovOpt_eq_CenPr()) // строка товар без наценки
        endif

        pSlk:=TovVz->(FieldPos('skl'))
        pMnTov:=TovVz->(FieldPos('MnTov'))

        arec:={}; getrec()
        nuse('tovvz')

        aRec[pSlk] := ln_sklr
        aRec[pMnTov] := ln_MnTovr

        sele tov
        netadd()
        putrec()
        netrepl('osn,osf,osv,osfo',{0,0,0,0})

        lSeekMnTov:=.T.
        exit
      endif
      nuse('tovvz')
    endif

    DtVzr:=ADDMONTH(DtVzr,-1)
  EndDo

  // восстановим
  sklr := ln_sklr
  MnTovr := ln_MnTovr

  RETURN (lSeekMnTov)



/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  05-07-18 * 11:33:49am
 НАЗНАЧЕНИЕ......... поиска строки протокола продаж
 ПАРАМЕТРЫ.......... post_r,  mnotv_r,ktl_r  - private
 ВОЗВР. ЗНАЧЕНИЕ.... найдено = 0 , не найдено lastrecno()
 ПРИМЕЧАНИЯ.........
 */
FUNCTION SeekRecNo4ProtSale(rcPr2o1r,post_r, ktl_r)
  netuse('pr1')
  mnotv_r=0
  sele pr1
  if netseek('t3','2,post_r')
      amnp_r=mn // Протокол продаж
  endif
  sele pr1
  if netseek('t3','1,post_r')
      mnotv_r=mn
  endif
  netuse('pr2')
  sele pr2
  if !netseek('t1','mnotv_r,ktl_r')
      rcPr2o1r=recn()
  endif
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  07-31-18 * 04:22:06pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION NewNomTttn()
  sele cskl
  reclock()
  TtnCr=ttn
  if TtnCr=TtnPr
      if ttn<999999
        netrepl('ttn',{ttn+1})
      else
        netrepl('ttn',{1})
      endif
      TtnCr=ttn
  endif

  do while .t.
      if netseek('t1','TtnCr','rs1')
        sele cskl
        if ttn<999999
            netrepl('ttn',{ttn+1},1)
        else
            netrepl('ttn',{1},1)
        endif
        TtnCr=ttn
      else
        sele cskl
        if ttn<999999
            netrepl('ttn',{ttn+1})
        else
            netrepl('ttn',{1})
        endif
        exit
      endif
  enddo
  RETURN (NIL)



/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  08-01-19 * 11:18:00am
 НАЗНАЧЕНИЕ.........  поиск ТТН с товара последней продажи
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION TtnVzrLast(nSkVz, nTtnVz, nKvpVz, lFirst)
  LOCAL nRecCnt, aList_MMYY, aListTtn
  LOCAL nCntMonth4Last:=7 // глубина поиска  Последней Накл
  LOCAL nCntMonth4First:=4 // глубина поиска Первой Накл
  LOCAL i
  DEFAULT lFirst TO .F.

  sele lrs1
  ttn_r = ttn
  // проверить одна строка
  sele lrs2
  set orde to tag t1
  netseek('t1','ttn_r')
  count to nRecCnt while ttn=ttn_r

  If nRecCnt = 1
    //список дат поиска
    aList_MMYY:=aList_MMYY(lFirst, nCntMonth4Last, nCntMonth4First)

    // проверить Это Товар
    sele lrs2
    netseek('t1','ttn_r')
    MnTovr:=MnTov
    outlog(3,__FILE__,__LINE__,'MnTovr,kvp,kpl,kgp',MnTovr,kvp,lrs1->kpl,lrs1->kgp)

    if int(MnTovr/10000)<2 // Тара или СтекТара
    else // товар

      // вычислили Родителя
      MnTovTr=getfield('t1','MnTovr','ctov','MnTovT')
      if MnTovTr=0
          MnTovTr=MnTovr
      endif
      // список товара, который может быть отпущен
      cLstMnTov:=''
      sele ctov
      ordsetfocus('t10') // по Родителю
      netseek('t10','MnTovTr')
      DBEVAL({|| cLstMnTov += (str(MnTov,7)+';') },,{||MnTovT = MnTovTr})
      outlog(3,__FILE__,__LINE__,'  cLstMnTov',cLstMnTov)

      /*
      // Поиск ТТН_последне по Коду_Товара в Cкладе_возрата
      dBeg:=BOM(Date()) ;  dBeg:=ADDMONTH(dBeg,1)
      dEnd:=ADDMONTH(dBeg,-7) //BOM(STOD('20160801'))
      While (dBeg:=ADDMONTH(dBeg,-1),dBeg) >= dEnd */
      i:=0
      While .t.

        If ((++i) > LEN(aList_MMYY))
          exit
        EndIf
        dBeg:=aList_MMYY[i]
        OUTLOG(3,__FILE__,__LINE__,"i,aList_MMYY[i],dBeg",i,aList_MMYY[i],dBeg,dBeg=aList_MMYY[i])

        sele cskl; DBGoTop()
        while !eof()
          /////////// увловие выбора склада
          if !(rasc=1.and.ent=gnEnt) // нужно то Пред-тие и Продажи идут
            skip;   loop
          endif
          //   пропускаем склады 169 - 263;705'
          if str(Sk,3)$'263;705' // склады 169 брака
            skip;   loop
          endif
          If .not. sk = nSkVz
            skip;   loop
          EndIf
          ///////////////////////

          pathr:=gcPath_e + pathYYYYMM(dBeg) + '\' + allt(path)
          skr=sk

          If netfile('rs1',1)
            netuse('rs1','rs1vz',,1)
            netuse('rs2','rs2vz',,1)
            outlog(3,__FILE__,__LINE__,'  pathr',pathr)

            sele rs1vz
            ordsetfocus('t1')
            set filt to vo=9 .and. str(kop,3) $ '160;161' ;
              .and. kpl = lrs1->kpl .and. kgp = lrs1->kgp
            If eof()
              nuse('rs2vz')
              nuse('rs1vz')

              sele cskl
              skip
              loop
            EndIf

            // список всех ТТН
            aListTtn:={}
            rs1vz->(DBEval({||AADD(aListTtn, {rs1vz->ttn, RecNo()})})) // прямая сортировка
            outlog(3,__FILE__,__LINE__,"aListTtn",aListTtn)
            If !lFirst // обратный порядок
              ASORT(aListTtn,,,{|x, y| x[1] > y[1]} )
              outlog(3,__FILE__,__LINE__,"aListTtn",aListTtn)
            endif

            For m:=1 To len(aListTtn)
              sele rs1vz
              DBGoTo(aListTtn[m, 2])

              KvpVz(@nTtnVz, @nKvpVz)
              If !empty(nKvpVz) // нашли количество
                exit
              EndIf

            Next m

            nuse('rs2vz')
            nuse('rs1vz')
          endif

          If !empty(nKvpVz) // нашли количество
            exit
          EndIf

          sele cskl
          skip
        enddo

        If !empty(nKvpVz) // нашли количество
          exit
        EndIf

      enddo
    endif

  EndIf
  If empty(nTtnVz)
    outlog(3,__FILE__,__LINE__,'  TtnVz - нет')
  EndIf
  RETURN (Iif(empty(nTtnVz),'',str(nTtnVz)))


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  02-05-20 * 04:49:40pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION TtnVzr169Last(nSkVz, nTtnVz, nKvpVz, nZen)
  LOCAL nRecCnt

  sele lrs1
  ttn_r = ttn
  // проверить одна строка
  sele lrs2
  set orde to tag t1
  netseek('t1','ttn_r')
  count to nRecCnt while ttn=ttn_r

  If nRecCnt = 1
    // проверить Это Товар
    sele lrs2
    netseek('t1','ttn_r')
    MnTovr:=MnTov
    outlog(3,__FILE__,__LINE__,'MnTovr,kvp,kpl,kgp',MnTovr,kvp,lrs1->kpl,lrs1->kgp)

    if int(MnTovr/10000)<2 // Тара или СтекТара
    else // товар

      // вычислили Родителя
      MnTovTr=getfield('t1','MnTovr','ctov','MnTovT')
      if MnTovTr=0
          MnTovTr=MnTovr
      endif
      // список товара, который может быть отпущен
      cLstMnTov:=''
      sele ctov
      ordsetfocus('t10') // по Родителю
      netseek('t10','MnTovTr')
      DBEVAL({|| cLstMnTov += (str(MnTov,7)+';') },,{||MnTovT = MnTovTr})
      outlog(3,__FILE__,__LINE__,'  cLstMnTov',cLstMnTov)

      // Поиск ТТН_последне по Коду_Товара в Cкладе_возрата
      dBeg:=BOM(Date()) ;  dBeg:=ADDMONTH(dBeg,1)
      dEnd:=ADDMONTH(dBeg,-3) //BOM(STOD('20160801'))
      While (dBeg:=ADDMONTH(dBeg,-1),dBeg) >= dEnd
        sele cskl; DBGoTop()
        while !eof()
          /////////// увловие выбора склада
          if !(rasc=1.and.ent=gnEnt) // нужно то Пред-тие и Продажи идут
            skip;   loop
          endif
          //   пропускаем склады 169 - 263;705'
          if str(Sk,3)$'263;705' // склады 169 брака
            skip;   loop
          endif
          If .not. sk = nSkVz
            skip;   loop
          EndIf
          ///////////////////////

          pathr:=gcPath_e + pathYYYYMM(dBeg) + '\' + allt(cskl->path)
          skr=sk
          path_Sklr:=pathr

          If netfile('rs1',1)
            netuse('rs1','rs1vz',,1)
            netuse('rs2','rs2vz',,1)
            outlog(3,__FILE__,__LINE__,'  pathr',pathr)

            sele rs1vz
            ordsetfocus('t1')
            set filt to vo=9 .and. str(kop,3) $ '169' ;
              .and. nkkl = lrs1->kpl .and. kpv = lrs1->kgp
            DBGoTop()
            If eof()
              nuse('rs2vz')
              nuse('rs1vz')

              sele cskl
              skip
              loop
            EndIf
            sele rs1vz
            nRecEnd:=RECNO() // последняя запись
            DBGoBottom()
            Do While .t.
              nuse('rs2vz')
              If rs1vz->pr169=1.and.rs1vz->ttn169#0
                //из ТТН169
                path169r:=gcPath_169+pathYYYYMM(dBeg) + '\' + allt(cskl->path)
                pathr:=path169r +'t'+allt(str(ttn_r, 6))+'\'
                outlog(3,__FILE__,__LINE__,'  rs2vz_pathr',pathr)
              else
                pathr:=path_Sklr
                outlog(3,__FILE__,__LINE__,'  rs2vz_pathr',pathr)
              EndIf
              netuse('rs2','rs2vz',,1)

              //
              // поиск товара
              sele rs2vz
              ordsetfocus('t1')
              if netseek('t1','rs1vz->ttn')

                SUM Kvp TO nKvpVz FOR str(MnTov,7) $ cLstMnTov ;
                WHILE ttn = rs1vz->ttn

                If !empty(nKvpVz)
                  nTtnVz:=rs1vz->ttn
                  outlog(3,__FILE__,__LINE__,'  nKvpVz,nTtnVz',nKvpVz,nTtnVz)
                EndIf

              endif

              If !empty(nKvpVz) // нашли количество
                exit
              EndIf

              sele rs1vz
              If nRecEnd = RECNO()
                exit
              EndIf
              sele rs1vz
              DBSkip(-1)
            EndDo

            nuse('rs2vz')
            nuse('rs1vz')
          endif

          If !empty(nKvpVz) // нашли количество
            exit
          EndIf

          sele cskl
          skip
        enddo

        If !empty(nKvpVz) // нашли количество
          exit
        EndIf

      enddo
    endif

  EndIf
  If empty(nTtnVz)
    outlog(3,__FILE__,__LINE__,'  TtnVz - нет')
  EndIf
  RETURN (Iif(empty(nTtnVz),'',str(nTtnVz)))

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  02-22-20 * 08:30:13am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
  nCntMonth4Last - мах к-во переиодов просмотра   (поиск последней накл)
  nCntMonth4First - к-во периода для поиска первой накл.
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION aList_MMYY(lFirst, nCntMonth4Last, nCntMonth4First)
  LOCAL dBeg, dEnd
  LOCAL aList_MMYY
  aList_MMYY:={}
  //nCntMonth4Last:=7
  //nCntMonth4First:=4
  dBeg:=BOM(Date())
  dBeg:=ADDMONTH(dBeg,1)
  dEnd:=ADDMONTH(dBeg,nCntMonth4Last*(-1)) //BOM(STOD('20160801'))
  While (dBeg:=ADDMONTH(dBeg,-1),dBeg) >= dEnd
    AADD(aList_MMYY,dBeg)
  enddo
  outlog(3,__FILE__,__LINE__,aList_MMYY)
  If lFirst
    aList_MMYY:=ASORT(aList_MMYY,1,nCntMonth4First)
    ASIZE(aList_MMYY,nCntMonth4First)
    outlog(3,__FILE__,__LINE__,aList_MMYY)
  EndIf
  RETURN (aList_MMYY)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  02-25-20 * 05:22:08pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION KvpVz(nTtnVz, nKvpVz)
  // поиск товара
  sele rs2vz
  ordsetfocus('t1')
  if netseek('t1','rs1vz->ttn')

    SUM Kvp TO nKvpVz FOR str(MnTov,7) $ cLstMnTov ;
    WHILE ttn = rs1vz->ttn

    If !empty(nKvpVz)
      nTtnVz:=rs1vz->ttn
      outlog(3,__FILE__,__LINE__,'  nTtnVz,nKvpVz',nTtnVz,nKvpVz)
    EndIf

  endif
  RETURN (NIL)


            /*
            sele rs1vz
            DBGoTop()
            nRecEnd:=RECNO() // последняя запись
            DBGoBottom()
            Do While .t.

              nKvpVz:=KvpVz()

              If !empty(nKvpVz) // нашли количество
                exit
              EndIf

              sele rs1vz
              If nRecEnd = RECNO()
                exit
              EndIf
              sele rs1vz
              DBSkip(-1)
            EndDo       */
