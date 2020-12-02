// Отчет по маркодержателю ОСТАТКИ и РЕАЛИЗАЦИЮ и ПРИХОД
/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-13-17 * 03:18:26pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
  FUNCTION MkOtchN()
    RETURN (NIL)
 */

#include 'common.ch'
para p1, p2, p3, p4, p5
// p1 - дата1
// p2 - код маркодержателя
// p3 - пересоздавать (умолчанию) или нет базы
// p4 - обрабатывать все склады (0 или 1)
// p5 - дата2
DEFAULT p4 to 0
mntov_rrr=0
if (ISARRAY(p1))
  dt1_r:=dt2_r:=p1[ 1 ]
  if (LEN(p1)>1)
    dt2_r:=p1[ 2 ]
  endif

else
  dt1_r:=p1
  if (!empty(p5))
    dt2_r:=p5
  else
    dt2_r:=dt1_r
  endif

endif

if (gnArm=25)
  scdt_r=setcolor('gr+/b,n/w')
  wdt_r=wopen(8, 20, 13, 60)
  wbox(1)
  @ 0, 1 say 'Период с' get dt1_r
  @ 0, col()+1 say 'по' get dt2_r
  @ 1, 1 say 'Обработать все склады' get p4 PICT "9" RANGE 0, 1
  @ 2, 1 say 'MNTOV' get mntov_rrr pict '9999999'
  read
  wclose(wdt_r)
  setcolor(scdt_r)
  if (lastkey()=27)
    return
  endif

endif

mkeep_r=p2
do case
case (mkeep_r=102)
  izg_r=2248008
otherwise
  izg_r=0
endcase

do case
case (mkeep_r<10)
  cmkeepr='00'+str(mkeep_r, 1)
case (mkeep_r<100)
  cmkeepr='0'+str(mkeep_r, 2)
otherwise
  cmkeepr=str(mkeep_r, 3)
endcase

flr='mkdoc'+cmkeepr
fler='mkdoe'+cmkeepr
if (p3=nil .OR. p3)       //.OR. !FILE(flr+".dbf")
  if (FILE(flr+".cdx"))
    ERASE (flr+".cdx")
  endif

  crtt(flr, 'f:vo c:n(2) f:kgp c:n(7) f:kpl c:n(7) f:okpo c:n(10) f:apl c:c(40) f:ngp c:c(40) f:npl c:c(40) f:agp c:c(40) f:DocGUID c:c(36) f:sk c:n(3) f:ttn c:n(6) f:kop c:n(3) f:dttn c:d(10) f:mntov c:n(7) f:mntovt c:n(7) f:bar c:n(13) f:ktl c:n(9) f:nat c:c(60)  f:zen c:n(10,3) f:zen_n_but c:n(10,3)  f:kvp c:n(11,3)  f:kta c:n(3) f:ddc c:d(10) f:tdc c:c(8) f:nnz c:c(9) f:dcl c:n(15,3) f:mkid c:c(20) f:nmkid c:c(90) f:tceno c:n(2) f:zeno c:n(10,3) f:tcenn c:n(2) f:ZenN c:n(10,3) f:d0k1 c:n(1) f:prz c:n(1) f:nnasp c:c(40) f:nrn c:c(40)')
  if (FILE(fler+".cdx"))
    ERASE (fler+".cdx")
  endif

  crtt(fler, 'f:vo c:n(2) f:kgp c:n(7) f:kpl c:n(7) f:okpo c:n(10) f:apl c:c(40) f:ngp c:c(40) f:npl c:c(40) f:agp c:c(40) f:DocGUID c:c(36) f:sk c:n(3) f:ttn c:n(6) f:kop c:n(3) f:dttn c:d(10) f:mntov c:n(7) f:mntovt c:n(7) f:bar c:n(13) f:ktl c:n(9) f:nat c:c(60)  f:zen c:n(10,3) f:zen_n_but c:n(10,3)  f:kvp c:n(11,3)  f:kta c:n(3) f:ddc c:d(10) f:tdc c:c(8) f:nnz c:c(9) f:dcl c:n(15,3) f:mkid c:c(20) f:nmkid c:c(90) f:tceno c:n(2) f:zeno c:n(10,3) f:tcenn c:n(2) f:ZenN c:n(10,3) f:d0k1 c:n(1) f:prz c:n(1) f:nnasp c:c(40) f:nrn c:c(40)')
endif

sele 0
use (flr) alias mkdoc
sele 0
use (fler) alias mkdoe

flr='mkpr'+cmkeepr
if (select('mkpr')#0)
  sele mkpr
  CLOSE
endif

fler='mkpe'+cmkeepr
if (select('mkpre')#0)
  sele mkpre
  CLOSE
endif

if (p3=nil .OR. p3)       //.OR. !FILE(flr+".dbf")
  if (FILE(flr+".cdx"))
    ERASE (flr+".cdx")
  endif

  crtt(flr, 'f:vo c:n(2) f:kgp c:n(7) f:kpl c:n(7) f:okpo c:n(10) f:ngp c:c(40) f:npl c:c(40) f:agp c:c(40) f:DocGUID c:c(36) f:sk c:n(3) f:ttn c:n(6) f:kop c:n(3) f:dttn c:d(10) f:mntov c:n(7) f:mntovt c:n(7)  f:bar c:n(13) f:ktl c:n(9) f:nat c:c(60)  f:zen c:n(10,3) f:zen_n_but c:n(10,3)  f:kvp c:n(11,3) f:apl c:c(40) f:kta c:n(3) f:ddc c:d(10) f:tdc c:c(8) f:nnz c:c(9) f:dcl c:n(15,3) f:mkid c:c(20) f:nmkid c:c(90) f:d0k1 c:n(1) f:nnasp c:c(40) f:nrn c:c(40)')
  if (FILE(fler+".cdx"))
    ERASE (fler+".cdx")
  endif

  crtt(fler, 'f:vo c:n(2) f:kgp c:n(7) f:kpl c:n(7) f:okpo c:n(10) f:ngp c:c(40) f:npl c:c(40) f:agp c:c(40) f:DocGUID c:c(36) f:sk c:n(3) f:ttn c:n(6) f:kop c:n(3) f:dttn c:d(10) f:mntov c:n(7) f:mntovt c:n(7)  f:bar c:n(13) f:ktl c:n(9) f:nat c:c(60)  f:zen c:n(10,3) f:zen_n_but c:n(10,3)  f:kvp c:n(11,3) f:apl c:c(40) f:kta c:n(3) f:ddc c:d(10) f:tdc c:c(8) f:nnz c:c(9) f:dcl c:n(15,3) f:mkid c:c(20) f:nmkid c:c(90) f:d0k1 c:n(1) f:nnasp c:c(40) f:nrn c:c(40)')
endif

sele 0
use (flr) alias mkpr
sele 0
use (fler) alias mkpe

flr='mktov'+cmkeepr
if (p3=nil .OR. p3)       //.OR. !FILE(flr+".dbf")
  if (FILE(flr+".cdx"))
    ERASE (flr+".cdx")
  endif

  crtt(flr, 'f:sk c:n(3) f:nsk c:c(30) f:mntov c:n(7) f:mntovt c:n(7) f:bar c:n(13) f:nat c:c(60) f:nei c:c(4) f:opt c:n(10,3) f:cenpr c:n(10,3) f:pr_n_but c:n(10,3)  f:upak c:n(10,3) f:osfo c:n(12,3) f:osfo_upak c:n(8) f:osv c:n(12,3) f:osv_upak c:n(8) f:dt c:d(10) f:tm c:c(8) f:dcl c:n(15,3) f:mkid c:c(20) f:nmkid c:c(90) f:osfos c:n(12,3) f:osn c:n(12,3) f:osf c:n(12,3) f:osfon c:n(12,3)')
endif

sele 0
use (flr) alias mktov excl
inde on str(sk, 3)+str(mntov, 7) tag t1
inde on str(sk, 3)+str(mntovt, 7) tag t2

netuse('etm')
netuse('kps')

if (gnArm=25)             // SERV
                            // Открытые таблицы :mkeep,mkeepe,mkeepg,ctov,cgrp,kln,brand
else
  netuse('mkeep')
  netuse('mkeepe')
  netuse('kln')
  netuse('ctov')
  netuse('mkeepg')
  netuse('cgrp')
  netuse('brand')
  netuse('mkcros')
  netuse('klnnac')
  netuse('tcen')
  netuse('krntm')
  netuse('rntm')
  netuse('nasptm')
  netuse('kgptm')
  netuse('kgp')
endif

netuse('knasp')
netuse('krn')
netuse('cskl')

sele cskl
go top
while (!eof())
  if (!(ent=gnEnt.and. IIF(EMPTY(p4), (rasc=1.or.rasc=2.or.sk=254), .T.)))
    skip
    loop
  endif

  //   if mkeep_r=102
  //      if sk=254
  //         skip
  //         loop
  //      endif
  //   endif
  sklr=skl
  msklr=mskl
  if (gnArm=25)           // serv
    pathr:=gcPath_d+alltrim(path)
    path129r=gcPath_m129+alltrim(path)
    path139r=gcPath_m139+alltrim(path)
    path151r=gcPath_m151+alltrim(path)
    path177r=gcPath_m177+alltrim(path)
    path169r=gcPath_m169+alltrim(path)
  else
    PathYYMMr:='g'+str(year(dt1_r), 4)+'\m'+iif(month(dt1_r)<10, '0'+str(month(dt1_r), 1), str(month(dt1_r), 2))+'\'
    pathr=gcPath_e+PathYYMMr+alltrim(path)
    path129r=gcPath_129+PathYYMMr+alltrim(path)
    path139r=gcPath_139+PathYYMMr+alltrim(path)
    path151r=gcPath_151+PathYYMMr+alltrim(path)
    path177r=gcPath_177+PathYYMMr+alltrim(path)
    path169r=gcPath_169+PathYYMMr+alltrim(path)
  endif

  if (!netfile('tov', 1))
    skip
    loop
  endif

  netuse('tov',,, 1)
  if (msklr=0)
    if (!netseek('t6', 'sklr,mkeep_r'))
      nuse('tov')
      sele cskl
      skip
      loop
    endif

  else
    locate for mkeep = mkeep_r
    if (!found())
      nuse('tov')
      sele cskl
      skip
      loop
    endif

  endif

  sele cskl
  skr=sk
  skmnr=sk
  nskmnr=nskl
  nskr=nskl
  rmr=rm
  do case
  case (gnEnt=20)
    do case
    case (rmr=0)
      kkl_r=gnKKL_c
    case (rmr=3)
      kkl_r=3000000
    case (rmr=4)
      kkl_r=4000000
    case (rmr=5)
      kkl_r=5000000
    case (rmr=6)
      kkl_r=6000000
    endcase

  case (gnEnt=20)
    kkl_r=9000000
  otherwise
    kkl_r=0
  endcase

  netuse('rs1',,, 1)
  netuse('rs2',,, 1)
  netuse('pr1',,, 1)
  netuse('pr2',,, 1)

  // Расход
  cListMKeep:='102;119; 92;126; 41;'// для этих разварачиваем ВНК
  sele rs1
  while (!eof())
    if (str(mkeep_r, 3)$cListMKeep)
      if (DocDeCode())
        sele rs1
        skip
        loop
      endif

    endif

    sele rs1
    dopr=iif(empty(dop), dot, dop)
    if (empty(dopr))
      skip
      loop
    else
      if (!(dopr>=dt1_r.and.dopr<=dt2_r))
        cAlDocr='mkdoe'
      else
        if (vo=9.or.vo=1.or.vo=5)
          cAlDocr='mkdoc'
        else
          cAlDocr='mkdoe'
        endif

      endif

    endif

    sele rs1
    DocGUIDr:=DocGUID
    ttnr=ttn
    ktar=kta
    kopr=kop
    vor=vo
    kpv_r=kpv
    przr=prz
    sklr=skl
    if (vor=9)
      dttnr=dop
    else
      if (prz=1)
        dttnr=dot
      else
        dttnr=dop
      endif

    endif

    if (empty(dttnr))
      dttnr=dop
    endif

    sele rs2
    prDocr=0
    if (netseek('t1', 'ttnr'))
      while (ttn=ttnr)
        ktlr=ktl
        otvr=getfield('t1', 'sklr,ktlr', 'tov', 'otv')
        if (otvr=1)
          skip
          loop
        endif

        mntovr=mntov
        kg_r=int(mntovr/10000)
        if (mntovr=3340170)
          skip
          loop
        endif

        if (mntov_rrr#0)
          if (mntovr#mntov_rrr)
            skip
            loop
          endif

        endif

        mntovtr:=getfield('t1', 'mntovr', 'ctov', 'mntovt')
        if (EMPTY(mntovtr))
          mntovtr=mntovr
        endif

        mntovcr:=getfield('t1', 'mntovr', 'ctov', 'mntovc')
        if (EMPTY(mntovcr))
          mntovcr=mntovr
        endif

        zenr:=zen

        //если у клиента по этому "p2 - код маркодержателя"
        // "изготовитель" - ТЦ=3, то из карточки берем VIP-3
        //  иначе берем Базовую
        if (.T.)
        else
        endif

        /*
        sele tov
        netseek('t1','sklr,ktlr')
        */
        sele ctov
        netseek('t1', 'mntovr')
        barr:=getfield('t1', 'mntovcr', 'ctov', 'bar')
        if (empty(barr))
          barr:=getfield('t1', 'mntovtr', 'ctov', 'bar')
        endif

        mkeep_rr=mkeep
        keipr=keip
        vespr=vesp          //getfield('t1','mntovr','ctov','vesp')
        keir=kei
        mkcrosr=mkcros
        mkidr=getfield('t1', 'mkcrosr', 'mkcros', 'mkid')
        nmkidr=getfield('t1', 'mkcrosr', 'mkcros', 'nmkid')

        // CenPr  -  цена прайса с бутылкой
        // cen08  -  цена без бутылки
        Pr_Butr:= CenPr - IIF(EMPTY(c08), CenPr, c08)

        /*
        cen08r=getfield('t1','mntovtr','ctov','c08')
        Pr_N_Butr:=round(cen08r*kfcr,3) //цена без бутылки
        CenPrr=getfield('t1','mntovtr','ctov','CenPr')
        CenPrr:=round(CenPrr*kfcr,3)  //цена прайсовая c бутылкой
        */

        if (mkeep_rr#mkeep_r)
          sele rs2
          skip
          loop
        else
          mntovr=mntov
          natr=nat
          osfor=osfo
          osnr=osn
          osfr=osf
          neir=nei
          if (empty(neir))
            neir='шт'
          endif

          if (kei=800.and.kg=334)
            neir='шт'
            kfcr=upak
          else
            kfcr=1
          endif

          zen_n_butr=round((zenr-Pr_Butr)*kfcr, 3)
          zenr=round(zenr*kfcr, 3)

          if (prDocr=0)
            prDocr=1

            sele rs1
            ddcr=ddc
            tdcr=tdc
            if (vor=6)
              kplr=kkl_r
              do case
              case (skt=300)
                kgpr=3000000
              case (skt=400)
                kgpr=4000000
              case (skt=500)
                kgpr=5000000
              case (skt=600)
                kgpr=6000000
              otherwise
                kgpr=gnKKL_c
              endcase

            else
              kplr=nkkl
              kgpr=kpv
            endif

            sele kln
            netseek('t1', 'kplr',,, 1)
            if (vor#6)
              okpor=kkl1
              if (EMPTY(okpor))
                kplr:=20034
                netseek('t1', 'kplr',,, 1)
                okpor=kkl1
              endif

            else
              okpor=gnKln_c
            endif

            nplr=nkl
            aplr=adr
            netseek('t1', 'kgpr',,, 1)
            ngpr=nkl
            agpr=adr
          endif

        endif

        tcennr:=0
        if (mkeep_r=102)
          tcenor=dftcen(kplr, kgpr, mntovr)
          if (tcenor=0)
            tcenor=2
          endif

          czenor=alltrim(getfield('t1', 'tcenor', 'tcen', 'zen'))
          zenor=getfield('t1', 'mntovr', 'ctov', czenor)
          do case
          case (tcenor=2)
            tcennr=5
          case (tcenor=3)
            tcennr=17
          case (tcenor=4)
            tcennr=5
          case (tcenor=5)
            tcennr=5
          case (tcenor=16)
            tcennr=16
          case (tcenor=17)
            tcennr=17
          otherwise
            tcennr=5
          endcase

          if (tcennr=99)  // не определен
            ZenNr=getfield('t1', 'mntovtr', 'ctov', 'cenpr')// прайс
          else
            cZenNr=alltrim(getfield('t1', 'tcennr', 'tcen', 'zen'))
            ZenNr=getfield('t1', 'mntovtr', 'ctov', cZenNr)
          endif

        else
          do case
          case (mkeep_r=92)//.and.int(mntovr/10000)=320
            tcenor=0
            zenor=0
            tcennr=2
            ZenNr=getfield('t1', 'mntovr', 'ctov', 'cenpr')
          case (mkeep_r=126)
            tcenor=0
            zenor=0
            tcennr=0
            ZenCRMr:=getfield('t1', 'mntovr', 'ctov', 'c12')
            ZenNr=Iif(zenr<=ZenCRMr .or. ZenCRMr=0, zenr, ZenCRMr)
          otherwise
            tcenor=0
            zenor=0
            tcennr=0
            ZenNr=0
          endcase

        endif

        if (prDocr=1)
          sele rs2
          kvpr=kvp/kfcr
          if (int(mntovr/10000)>1)
            dclr=ROUND(round(kvp*vespr, 3)/15, 3)
          else
            dclr=0
          endif

          sele (cAlDocr)
          netadd()
          netrepl('bar,vo,kgp,kpl,okpo,ngp,npl,agp,DocGUID,sk,ttn,dttn,mntov,mntovt,ktl,nat,zen,zen_n_but,kvp,apl,kta,ddc,tdc,kop,dcl,mkid,nmkid,tceno,zeno,tcenn,ZenN,prz',                                ;
                   'barr,vor,kgpr,kplr,okpor,ngpr,nplr,agpr,DocGUIDr,skr,ttnr,dttnr,mntovr,mntovtr,ktlr,natr,zenr,zen_n_butr,kvpr,aplr,ktar,ddcr,tdcr,kopr,dclr,mkidr,nmkidr,tcenor,zenor,tcennr,ZenNr,przr' ;
               )
        endif

        sele rs2
        skip
      enddo

    endif

    sele rs1
    skip
  enddo

  // Приход
  sele pr1
  while (!eof())

    if (prz=0)
      skip
      loop
    endif

    dopr=dpr

    if (vo=9)             // От поставщика
      cAlDocr='mkpe'
    else
      if (!(dopr>=dt1_r.and.dopr<=dt2_r))
        cAlDocr='mkpe'
      else
        cAlDocr='mkpr'
      endif

    endif

    sele pr1
    DocGUIDr:=''
    ttnr=mn
    dttnr=dpr
    ktar=kta
    kopr=kop
    vor=vo
    sele pr2
    prDocr=0
    if (netseek('t1', 'ttnr'))
      while (mn=ttnr)
        ktlr=ktl
        mntovr=mntov
        if (mntov_rrr#0)
          if (mntovr#mntov_rrr)
            skip
            loop
          endif

        endif

        mntovtr:=getfield('t1', 'mntovr', 'ctov', 'mntovt')
        if (EMPTY(mntovtr))
          mntovtr=mntovr
        endif

        mntovcr:=getfield('t1', 'mntovr', 'ctov', 'mntovc')
        if (EMPTY(mntovcr))
          mntovcr=mntovr
        endif

        zenr:=zen

        //если у клиента по этому "p2 - код маркодержателя"
        // "изготовитель" - ТЦ=3, то из карточки берем VIP-3
        //  иначе берем Базовую
        if (.T.)
        else
        endif

        /*
        sele tov
        netseek('t1','sklr,ktlr')
        */
        sele ctov
        netseek('t1', 'mntovr')
        barr:=getfield('t1', 'mntovcr', 'ctov', 'bar')
        if (empty(barr))
          barr:=getfield('t1', 'mntovtr', 'ctov', 'bar')
        endif

        mkeep_rr=mkeep
        keipr=keip
        vespr=vesp          //getfield('t1','mntovr','ctov','vesp')
        keir=kei
        mkcrosr=mkcros
        mkidr=getfield('t1', 'mkcrosr', 'mkcros', 'mkid')
        nmkidr=getfield('t1', 'mkcrosr', 'mkcros', 'nmkid')

        // CenPr  -  цена прайса с бутылкой
        // cen08  -  цена без бутылки
        Pr_Butr:= CenPr - IIF(EMPTY(c08), CenPr, c08)

        /*
        cen08r=getfield('t1','mntovtr','ctov','c08')
        Pr_N_Butr:=round(cen08r*kfcr,3) //цена без бутылки
        CenPrr=getfield('t1','mntovtr','ctov','CenPr')
        CenPrr:=round(CenPrr*kfcr,3)  //цена прайсовая c бутылкой
        */

        if (mkeep_rr#mkeep_r)
          sele pr2
          skip
          loop
        else
          mntovr=mntov
          natr=nat
          osfor=osfo
          osfr=osf
          osnr=osn
          neir=nei
          if (empty(neir))
            neir='шт'
          endif

          if (kei=800.and.kg=334)
            neir='шт'
            kfcr=upak
          else
            kfcr=1
          endif

          zen_n_butr=round((zenr-Pr_Butr)*kfcr, 3)
          zenr=round(zenr*kfcr, 3)

          if (prDocr=0)
            prDocr=1

            sele pr1
            ddcr=ddc
            tdcr=tdc
            if (vor#6)
              kplr=kps
              kgpr=getfield('t2', 'kplr', 'etm', 'kgp')
              if (kgpr=0)
                kgpr=kplr
              endif

            else
              kgpr=kkl_r
              do case
              case (sks=300)
                kplr=3000000
              case (sks=400)
                kplr=4000000
              case (sks=500)
                kplr=5000000
              case (sks=600)
                kplr=6000000
              otherwise
                kplr=gnKKL_c
              endcase

            endif

            sele kln
            netseek('t1', 'kplr')
            if (vor#6)
              okpor=kkl1
            else
              okpor=gnKln_c
            endif

            nplr=nkl
            aplr=adr
            netseek('t1', 'kgpr')
            ngpr=nkl
            agpr=adr
          endif

        endif

        if (prDocr=1)
          sele pr2
          kvpr=kf/kfcr
          if (int(mntovr/10000)>1)
            dclr=ROUND(round(kf*vespr, 3)/15, 3)
          else
            dclr=0
          endif

          sele (cAlDocr)
          netadd()
          netrepl('bar,vo,kgp,kpl,okpo,ngp,npl,agp,DocGUID,sk,ttn,dttn,mntov,mntovt,ktl,nat,zen,zen_n_but,kvp,apl,kta,ddc,tdc,kop,dcl,mkid,nmkid,d0k1',                        ;
                   'barr,vor,kgpr,kplr,okpor,ngpr,nplr,agpr,DocGUIDr,skr,ttnr,dttnr,mntovr,mntovtr,ktlr,natr,zenr,zen_n_butr,kvpr,aplr,ktar,ddcr,tdcr,kopr,dclr,mkidr,nmkidr,1' ;
               )
        endif

        sele pr2
        skip
      enddo

    endif

    sele pr1
    skip
  enddo

  // Товар
  sele tov
  set orde to tag t1
  go top
  while (!eof())
    if (mkeep#mkeep_r)
      skip
      loop
    endif

    if (otv=1)
      skip
      loop
    endif

    mntovr=mntov
    if (mntov_rrr#0)
      if (mntovr#mntov_rrr)
        skip
        loop
      endif

    endif

    ktlr=ktl
    mntovtr=mntovt
    mntovcr=getfield('t1', 'mntovr', 'ctov', 'mntovc')
    if (mntovcr=0)
      mntovcr=mntov
    endif

    postr=post
    if (EMPTY(mntovtr))
      mntovtr=mntovr
    endif

    barr=getfield('t1', 'mntovcr', 'ctov', 'bar')
    if (empty(barr))
      barr=getfield('t1', 'mntovtr', 'ctov', 'bar')
    endif

    mkcrosr=getfield('t1', 'mntovr', 'ctov', 'mkcros')
    mkidr=getfield('t1', 'mkcrosr', 'mkcros', 'mkid')
    nmkidr=getfield('t1', 'mkcrosr', 'mkcros', 'nmkid')
    natr=nat
    neir=nei
    upakr:=IIF(upak=0, 1, upak)
    vespr=vesp
    osvr=osv

    if (empty(neir))
      neir='шт'
    endif

    if (kei=800.and.kg=334)
      neir='шт'
      kfcr=upak
    else
      kfcr=1
    endif

    optr=round(opt*kfcr, 3)//цен оптовая

    cen08r=getfield('t1', 'mntovtr', 'ctov', 'c08')
    Pr_N_Butr:=round(cen08r*kfcr, 3)//цена без бутылки

    CenPrr=getfield('t1', 'mntovtr', 'ctov', 'CenPr')
    CenPrr:=round(CenPrr*kfcr, 3)//цена прайсовая c бутылкой
    osfo_r=osfo
    osn_r=osn
    osf_r=osf
    osfor=osfo/kfcr

    if (int(mntovr/10000)>1)
      dclr=ROUND(round(osfo_r*vespr, 3)/15, 3)
    else
      dclr=0
    endif

    sele mktov
    ordsetfocus('t2')
    seek str(skr, 3)+str(mntovtr, 7)
    if (!foun())
      netadd()
      netrepl('bar,sk,nsk,mntov,mntovt,nat,nei,upak,osfo,osv,dt,tm,dcl,mkid,nmkid,osn,osf',                         ;
               'barr,skr,nskr,mntovr,mntovtr,natr,neir,upakr,osfor,osvr,date(),time(),dclr,mkidr,nmkidr,osn_r,osf_r' ;
           )
      netrepl('pr_n_but,cenpr', 'pr_n_butr,cenprr')
    else
      netrepl('osfo,osv,dcl,osn,osf', 'osfo+osfor,osv+osvr,dcl+dclr,osn+osn_r,osf+osf_r')
    endif

    netrepl('osfo_upak,osv_upak', 'ROUND(osfo/upakr,0),ROUND(osv/upakr,0)')
    if (int(mntovr/10000)>1)
      if (postr#0)
        if (netseek('t1', 'postr', 'kps'))
          sele mktov
          netrepl('opt', 'optr')
        endif

      endif

    else
      netrepl('opt', 'optr')
    endif

    skr=skmnr
    nskr=nskmnr
    sele tov
    skip
  enddo

  nuse('rs1')
  nuse('rs2')
  nuse('pr1')
  nuse('pr2')
  nuse('tov')
  sele cskl
  skip
enddo

sele mktov
repl all osfos with osfo

sele mkdoe
go top
while (!eof())
  skr=sk
  mntovtr=mntovt
  kvpr=kvp
  dclr=dcl
  kopr=kop
  przr=prz

  if (kopr=188.and.przr=0)
    sele mktov
    set orde to tag t2
    seek str(skr, 3)+str(mntovtr, 7)
    if (foun())
      repl osfo with osfo+kvpr, ;
       dcl with dcl+dclr
    endif

  else
    if (dttn>dt2_r)
      sele mktov
      set orde to tag t2
      seek str(skr, 3)+str(mntovtr, 7)
      if (foun())
        repl osfo with osfo+kvpr, ;
         dcl with dcl+dclr
      endif

    endif

  endif

  sele mkdoe
  skip
enddo

sele mktov
repl all osfo_upak with osfo/upak

// Расчет osfon
sele mktov
go top
while (!eof())
  skr=sk
  mntovtr=mntovt
  osnr=osn
  sele mkdoc
  sum kvp to rsdr for mntovt=mntovtr.and.dttn<dt2_r.and.sk=skr
  sele mkdoe
  sum kvp to rsder for mntovt=mntovtr.and.dttn<dt2_r.and.sk=skr
  sele mkpr
  sum kvp to prr for mntovt=mntovtr.and.dttn<dt2_r.and.sk=skr
  sele mkpe
  sum kvp to prer for mntovt=mntovtr.and.dttn<dt2_r.and.sk=skr
  osfonr=osnr+prr+prer-rsdr-rsder
  sele mktov
  repl osfon with osfonr
  skip
enddo

if (gnArm=25)             // SERV
                            //  Открытые таблицы :mkeep,mkeepe,mkeepg,ctov,cgrp,kln,brand
  nuse('cskl')
else
  nuse('')
endif

sele mkdoc
go top
while (!eof())
  kgpr=kgp
  knaspr=getfield('t1', 'kgpr', 'kln', 'knasp')
  nnaspr=getfield('t1', 'knaspr', 'knasp', 'nnasp')
  krnr=getfield('t1', 'kgpr', 'kln', 'krn')
  nrnr=getfield('t1', 'krnr', 'krn', 'nrn')
  sele mkdoc
  netrepl('nnasp,nrn', 'nnaspr,nrnr')
  sele mkdoc
  skip
enddo

sele mkdoe
go top
while (!eof())
  kgpr=kgp
  knaspr=getfield('t1', 'kgpr', 'kln', 'knasp')
  nnaspr=getfield('t1', 'knaspr', 'knasp', 'nnasp')
  krnr=getfield('t1', 'kgpr', 'kln', 'krn')
  nrnr=getfield('t1', 'krnr', 'krn', 'nrn')
  sele mkdoe
  netrepl('nnasp,nrn', 'nnaspr,nrnr')
  sele mkdoe
  skip
enddo

sele mkpr
go top
while (!eof())
  kgpr=kgp
  knaspr=getfield('t1', 'kgpr', 'kln', 'knasp')
  nnaspr=getfield('t1', 'knaspr', 'knasp', 'nnasp')
  krnr=getfield('t1', 'kgpr', 'kln', 'krn')
  nrnr=getfield('t1', 'krnr', 'krn', 'nrn')
  sele mkpr
  netrepl('nnasp,nrn', 'nnaspr,nrnr')
  sele mkpr
  skip
enddo

sele mkpe
go top
while (!eof())
  kgpr=kgp
  knaspr=getfield('t1', 'kgpr', 'kln', 'knasp')
  nnaspr=getfield('t1', 'knaspr', 'knasp', 'nnasp')
  krnr=getfield('t1', 'kgpr', 'kln', 'krn')
  nrnr=getfield('t1', 'krnr', 'krn', 'nrn')
  sele mkpe
  netrepl('nnasp,nrn', 'nnaspr,nrnr')
  sele mkpe
  skip
enddo

nuse('mkdoc')
nuse('mkdoe')
nuse('mkpr')
nuse('mkpe')
nuse('mktov')

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  08-09-18 * 03:13:53pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
function DocDeCode()
  local lSkip:=.F., nKolPos
  nKolPos :=rs1->KolPos

  do case
  case (str(rs1->pr129, 1)$'2;3')
    DeCodeDoc(rs1->ttn, nKolPos, path129r)
    lSkip:=.T.
  case (str(rs1->pr139, 1)$'2;3')
    DeCodeDoc(rs1->ttn, nKolPos, path139r)
    lSkip:=.T.
  case (str(rs1->pr169, 1)$'2;3')
    DeCodeDoc(rs1->ttn, nKolPos, path169r)
    lSkip:=.T.
  case (str(rs1->pr177, 1)$'2;3')
    DeCodeDoc(rs1->ttn, nKolPos, path177r)
    lSkip:=.T.
  case (gnEnt=21.and.ttnt=999999)
    DeCodeDoc(rs1->ttn, nKolPos, path151r)
    lSkip:=.T.
  endcase

  return (lSkip)

/***************** */
function DeCodeDoc(nTtn, nKolPos, cPath)
  /***************** */
  ttn_r=nTtn                //p1
  pathr=cPath +'t'+alltrim(str(ttn_r, 6))+'\'
  if (netfile('rs1', 1) .and. !EMPTY(nKolPos))
    netuse('rs1', 'rs1177',, 1)
    netuse('rs2', 'rs2177',, 1)
    sele rs1177
    go top
    while (!eof())
      sele rs1177
      prz177r=prz
      dopr=dop
      if (empty(dopr))
        skip
        loop
      else
        if (!(dopr>=dt1_r.and.dopr<=dt2_r))
          cAlDocr='mkdoe'
        else
          if (vo=9.or.vo=1.or.vo=5)
            cAlDocr='mkdoc'
          else
            cAlDocr='mkdoe'
          endif

        endif

      endif

      sele rs1177
      DocGUIDr:=DocGUID
      ttnr=ttn
      ktar=kta
      kopr=kop
      vor=vo
      kpv_r=kpv
      //      przr=prz
      sklr=skl
      if (vor=9)
        dttnr=dop
      else
        if (prz=1)
          dttnr=dot
        else
          dttnr=dop
        endif

      endif

      if (empty(dttnr))
        dttnr=dop
      endif

      sele rs2177
      prDocr=0
      if (netseek('t1', 'ttnr'))
        while (ttn=ttnr)
          ktlr=ktl
          otvr=getfield('t1', 'sklr,ktlr', 'tov', 'otv')
          if (otvr=1)
            skip
            loop
          endif

          mntovr=mntov
          kg_r=int(mntovr/10000)
          if (mntovr=3340170)
            skip
            loop
          endif

          if (mntov_rrr#0)
            if (mntovr#mntov_rrr)
              skip
              loop
            endif

          endif

          mntovtr:=getfield('t1', 'mntovr', 'ctov', 'mntovt')
          if (EMPTY(mntovtr))
            mntovtr=mntovr
          endif

          mntovcr:=getfield('t1', 'mntovr', 'ctov', 'mntovc')
          if (EMPTY(mntovcr))
            mntovcr=mntovr
          endif

          zenr:=zen

          //если у клиента по этому "p2 - код маркодержателя"
          // "изготовитель" - ТЦ=3, то из карточки берем VIP-3
          //  иначе берем Базовую
          if (.T.)
          else
          endif

          /*
          sele tov
          netseek('t1','sklr,ktlr')
          */
          sele ctov
          netseek('t1', 'mntovr')
          barr:=getfield('t1', 'mntovcr', 'ctov', 'bar')
          if (empty(barr))
            barr:=getfield('t1', 'mntovtr', 'ctov', 'bar')
          endif

          mkeep_rr=mkeep
          keipr=keip
          vespr=vesp        //getfield('t1','mntovr','ctov','vesp')
          keir=kei
          mkcrosr=mkcros
          mkidr=getfield('t1', 'mkcrosr', 'mkcros', 'mkid')
          nmkidr=getfield('t1', 'mkcrosr', 'mkcros', 'nmkid')

          // CenPr  -  цена прайса с бутылкой
          // cen08  -  цена без бутылки
          Pr_Butr:= CenPr - IIF(EMPTY(c08), CenPr, c08)

          /*
          cen08r=getfield('t1','mntovtr','ctov','c08')
          Pr_N_Butr:=round(cen08r*kfcr,3) //цена без бутылки
          CenPrr=getfield('t1','mntovtr','ctov','CenPr')
          CenPrr:=round(CenPrr*kfcr,3)  //цена прайсовая c бутылкой
          */

          if (mkeep_rr#mkeep_r)
            sele rs2177
            skip
            loop
          else
            mntovr=mntov
            natr=nat
            osfor=osfo
            osnr=osn
            osfr=osf
            neir=nei
            if (empty(neir))
              neir='шт'
            endif

            if (kei=800.and.kg=334)
              neir='шт'
              kfcr=upak
            else
              kfcr=1
            endif

            zen_n_butr=round((zenr-Pr_Butr)*kfcr, 3)
            zenr=round(zenr*kfcr, 3)

            if (prDocr=0)
              prDocr=1

              sele rs1177
              ddcr=ddc
              tdcr=tdc
              if (vor=6)
                kplr=kkl_r
                do case
                case (skt=300)
                  kgpr=3000000
                case (skt=400)
                  kgpr=4000000
                case (skt=500)
                  kgpr=5000000
                case (skt=600)
                  kgpr=6000000
                otherwise
                  kgpr=gnKKL_c
                endcase

              else
                kplr=nkkl
                kgpr=kpv
              endif

              sele kln
              netseek('t1', 'kplr',,, 1)
              if (vor#6)
                okpor=kkl1
                if (EMPTY(okpor))
                  kplr:=20034
                  netseek('t1', 'kplr',,, 1)
                  okpor=kkl1
                endif

              else
                okpor=gnKln_c
              endif

              nplr=nkl
              aplr=adr
              netseek('t1', 'kgpr',,, 1)
              ngpr=nkl
              agpr=adr
            endif

          endif

          tcennr:=0
          if (mkeep_r=102)
            tcenor=dftcen(kplr, kgpr, mntovr)
            if (tcenor=0)
              tcenor=2
            endif

            czenor=alltrim(getfield('t1', 'tcenor', 'tcen', 'zen'))
            zenor=getfield('t1', 'mntovr', 'ctov', czenor)
            do case
            case (tcenor=2)
              tcennr=5
            case (tcenor=3)
              tcennr=17
            case (tcenor=4)
              tcennr=5
            case (tcenor=5)
              tcennr=5
            case (tcenor=16)
              tcennr=16
            case (tcenor=17)
              tcennr=17
            otherwise
              tcennr=5
            endcase

            if (tcennr=99)// не определен
              ZenNr=getfield('t1', 'mntovtr', 'ctov', 'cenpr')// прайс
            else
              cZenNr=alltrim(getfield('t1', 'tcennr', 'tcen', 'zen'))
              ZenNr=getfield('t1', 'mntovtr', 'ctov', cZenNr)
            endif

          else
            do case
            case (mkeep_r=92)//.and.int(mntovr/10000)=320
              tcenor=0
              zenor=0
              tcennr=2
              ZenNr=getfield('t1', 'mntovr', 'ctov', 'cenpr')
            case (mkeep_r=126)
              tcenor=0
              zenor=0
              tcennr=0
              ZenCRMr:=getfield('t1', 'mntovr', 'ctov', 'c12')
              ZenNr=Iif(zenr<=ZenCRMr .or. ZenCRMr=0, zenr, ZenCRMr)
            otherwise
              tcenor=0
              zenor=0
              tcennr=0
              ZenNr=0
            endcase

          endif

          if (prDocr=1)
            sele rs2177
            kvpr=kvp/kfcr
            if (int(mntovr/10000)>1)
              dclr=ROUND(round(kvp*vespr, 3)/15, 3)
            else
              dclr=0
            endif

            sele (cAlDocr)
            netadd()
            netrepl('bar,vo,kgp,kpl,okpo,ngp,npl,agp,DocGUID,sk,ttn,dttn,mntov,mntovt,ktl,nat,zen,zen_n_but,kvp,apl,kta,ddc,tdc,kop,dcl,mkid,nmkid,tceno,zeno,tcenn,ZenN,prz',                                   ;
                     'barr,vor,kgpr,kplr,okpor,ngpr,nplr,agpr,DocGUIDr,skr,ttnr,dttnr,mntovr,mntovtr,ktlr,natr,zenr,zen_n_butr,kvpr,aplr,ktar,ddcr,tdcr,kopr,dclr,mkidr,nmkidr,tcenor,zenor,tcennr,ZenNr,prz177r' ;
                 )
          endif

          sele rs2177
          skip
        enddo

      endif

      sele rs1177
      skip
    enddo

    nuse('rs1177')
    nuse('rs2177')
  endif

  return (.t.)

