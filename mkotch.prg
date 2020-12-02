/* Отчет по маркодержателю ОСТАТКИ и РЕАЛИЗАЦИЮ */
#include 'common.ch'
para p1, p2, p3, p4, p5, p6
/* p1 - дата1
 * p2 - код маркодержателя
 * p3 - пересоздавать (умолчанию) или нет базы
 * p4 - обрабатывать все склады (0 или 1 - все)
 * p5 - дата2
 * p6 - блок кода обратобки вида операций
 */
local bForDocRS1
DEFAULT p4 to 0, p6 to { || vo == 9 .and. kop # 196 }
bForDocRs1 := p6

if (ISARRAY(p1))
  dt1_r:=dt2_r:=p1[ 1 ]
  if (LEN(p1)>1)
    dt2_r:=p1[ 2 ]
  endif

else
  dt1_r:=p1
  if (!empty(p5))
  else
    dt2_r:=dt1_r
  endif

endif

if (gnArm=25)
  scdt_r=setcolor('gr+/b,n/w')
  wdt_r=wopen(8, 20, 12, 60)
  wbox(1)
  @ 0, 1 say 'Период с' get dt1_r
  @ 0, col()+1 say 'по' get dt2_r
  @ 1, 1 say 'Обработать все склады' get p4 PICT "9" RANGE 0, 1
  read
  wclose(wdt_r)
  setcolor(scdt_r)
  if (lastkey()=27)
    return
  endif

endif

mkeep_r=p2
do case
case (mkeep_r<10)
  cmkeepr='00'+str(mkeep_r, 1)
case (mkeep_r<100)
  cmkeepr='0'+str(mkeep_r, 2)
otherwise
  cmkeepr=str(mkeep_r, 3)
endcase

flr='mkdoc'+cmkeepr
if (p3=nil .OR. p3)       //.OR. !FILE(flr+".dbf")
  crtt(flr, 'f:vo c:n(2) f:kgp c:n(7) f:kpl c:n(7) f:okpo c:n(10) f:ngp c:c(40) f:npl c:c(40) f:agp c:c(40) f:DocGUID c:c(36) f:sk c:n(3) f:ttn c:n(6) f:kop c:n(3) f:dttn c:d(10) f:mntov c:n(7) f:mntovt c:n(7) f:bar c:n(13) f:ktl c:n(9) f:nat c:c(60)  f:zen c:n(10,3) f:zen_n_but c:n(10,3)  f:kvp c:n(11,3) f:apl c:c(40) f:kta c:n(3) f:ddc c:d(10) f:tdc c:c(8) f:nnz c:c(9) f:dcl c:n(10,3) f:mkid c:c(20) f:nmkid c:c(90)')
endif

sele 0
use (flr) alias mkdoc

flr='mktov'+cmkeepr
if (p3=nil .OR. p3)       //.OR. !FILE(flr+".dbf")
  crtt(flr, 'f:sk c:n(3) f:nsk c:c(30) f:mntov c:n(7) f:mntovt c:n(7) f:bar c:n(13) f:nat c:c(60) f:nei c:c(4) f:opt c:n(10,3) f:cenpr c:n(10,3) f:pr_n_but c:n(10,3)  f:upak c:n(10,3) f:osfo c:n(12,3) f:osfo_upak c:n(6) f:osv c:n(12,3) f:osv_upak c:n(6) f:dt c:d(10) f:tm c:c(8) f:dcl c:n(10,3) f:mkid c:c(20) f:nmkid c:c(90)')
endif

sele 0
use (flr) alias mktov excl
inde on str(sk, 3)+str(mntov, 7) tag t1
inde on str(sk, 3)+str(mntovt, 7) tag t2

if (gnArm=25)             // SERV
/* Открытые таблицы :mkeep,mkeepe,mkeepg,ctov,cgrp,kln,brand */
else
  netuse('mkeep')
  netuse('mkeepe')
  netuse('kln')
  netuse('ctov')
  netuse('mkeepg')
  netuse('cgrp')
  netuse('brand')
  netuse('mkcros')
endif

netuse('cskl')

sele cskl
go top
while (!eof())
  if (!(ent=gnEnt.and. IIF(EMPTY(p4), rasc=1, .T.)))
    skip
    loop
  endif

  pathr:=gcPath_d+alltrim(path)
  if (!netfile('tov', 1))
    skip
    loop
  endif

  sklr=skl
  netuse('tov',,, 1)
  locate for mkeep = mkeep_r
  if (!found())           //!netseek('t6','sklr,mkeep_r')
    nuse('tov')
    sele cskl
    skip
    loop
  endif

  sele cskl
  skr=sk
  nskr=nskl
  netuse('rs1',,, 1)
  netuse('rs2',,, 1)
  sele rs1
  while (!eof())

    if (.not.(eval(bForDocRs1)))
      skip
      loop
    endif

    if (empty(dop))
      skip
      loop
    endif

    dopr=dop
    if (!(dopr>=dt1_r.and.dopr<=dt2_r))
      skip
      loop
    endif

    sele rs1
    DocGUIDr:=DocGUID
    ttnr=ttn
    ktar=kta
    kopr=kop
    sele rs2
    prdocr=0
    if (netseek('t1', 'ttnr'))
      while (ttn=ttnr)
        ktlr=ktl
        mntovr=mntov
        mntovtr:=getfield('t1', 'mntovr', 'ctov', 'mntovt')
        if (EMPTY(mntovtr))
          mntovtr=mntovr
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
        barr:=bar
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

          if (prdocr=0)
            prdocr=1

            sele rs1
            ddcr=ddc
            tdcr=tdc
            kplr=nkkl
            kgpr=kpv
            dttnr=dop
            vor=vo

            sele kln
            netseek('t1', 'kplr')
            okpor=kkl1
            nplr=nkl
            aplr=adr
            netseek('t1', 'kgpr')
            ngpr=nkl
            agpr=adr

          endif

        endif

        if (prdocr=1)
          sele rs2
          kvpr=kvp/kfcr
          if (int(mntovr/10000)>1)
            dclr=ROUND(round(kvp*vespr, 3)/10, 3)
          else
            dclr=0
          endif

          sele mkdoc
          netadd()
          netrepl('bar,vo ,kgp ,kpl ,okpo,ngp,npl,agp,DocGUID,sk,ttn,dttn,mntov,mntovt,ktl,nat,zen,zen_n_but,kvp,apl,kta,ddc,tdc,kop,dcl,mkid,nmkid',                        ;
                   'barr,vor,kgpr,kplr,okpor,ngpr,nplr,agpr,DocGUIDr,skr,ttnr,dttnr,mntovr,mntovtr,ktlr,natr,zenr,zen_n_butr,kvpr,aplr,ktar,ddcr,tdcr,kopr,dclr,mkidr,nmkidr' ;
               )
        endif

        sele rs2
        skip
      enddo

    endif

    sele rs1
    skip
  enddo

  sele tov
  go top
  while (!eof())
    if (mkeep#mkeep_r)
      skip
      loop
    endif

    mntovr=mntov
    mntovtr=mntovt
    if (EMPTY(mntovtr))
      mntovtr=mntovr
    endif

    barr:=bar
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

    osfor=osfo/kfcr

    if (int(mntovr/10000)>1)
      dclr=ROUND(round(osfo*vespr, 3)/10, 3)
    else
      dclr=0
    endif

    sele mktov
    //ordsetfocus('t1')
    //seek str(skr,3)+str(mntovr,7)
    ordsetfocus('t2')
    seek str(skr, 3)+str(mntovtr, 7)
    if (!foun())
      netadd()
      netrepl('bar,sk,nsk,mntov,mntovt,nat,nei,upak,osfo,osv,dt,tm,dcl,mkid,nmkid',                     ;
               'barr,skr,nskr,mntovr,mntovtr,natr,neir,upakr,osfor,osvr,date(),time(),dclr,mkidr,nmkidr' ;
           )
      netrepl('opt,pr_n_but,cenpr', 'optr,pr_n_butr,cenprr')
    else
      netrepl('osfo,osv,dcl', 'osfo+osfor,osv+osvr,dcl+dclr')
    endif

    netrepl('osfo_upak,osv_upak', 'ROUND(osfo/upakr,0),ROUND(osv/upakr,0)')

    sele tov
    skip
  enddo

  nuse('rs1')
  nuse('rs2')
  nuse('tov')
  sele cskl
  skip
enddo

if (gnArm=25)             // SERV
  /* Открытые таблицы :mkeep,mkeepe,mkeepg,ctov,cgrp,kln,brand */
  nuse('cskl')
else
  nuse('')
endif

nuse('mkdoc')
nuse('mktov')

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........Ю. Цыбульник  07-04-07 * 10:53:25am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
  * p1 mkeep
  * p2 nil - новая; 1 - mod
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
function mkkplkgp(p1, p2)
  netuse('stagm')
  netuse('s_tag')
  netuse('stagtm')
  netuse('etm')
  netuse('kgpcat')
  if (p2=nil)
    if (select('mkkplkgp')=0)
    else
      close mkkplkgp
    endif

    crtt('mkkplkgp', 'f:kpl c:n(7) f:kgp c:n(7) f:kta c:n(3) f:sk c:n(3)  f:nact c:n(1) f:cat c:n(2) f:dpp c:d(2) f:ncat c:c(30)')
  endif

  if (select('mkkplkgp')=0)
    sele 0
    use mkkplkgp excl
    inde on str(kgp, 7)+str(kpl, 7) tag t1
  endif

  sele stagm
  go top
  while (!eof())
    if (mkeep#p1)
      skip
      loop
    endif

    ktar=kta
    uvolr=getfield('t1', 'ktar', 's_tag', 'uvol')
    if (uvolr=1)
      sele stagm
      skip
      loop
    endif
    skr=getfield('t1', 'ktar', 's_tag', 'AgSk')

    ktasr=getfield('t1', 'ktar', 's_tag', 'ktas')
    if (ktar=ktasr)
      sele s_tag
      go top
      while (!eof())
        if (ktas#ktasr)
          skip
          loop
        endif

        ktar=kod
        uvolr=getfield('t1', 'ktar', 's_tag', 'uvol')
        if (uvolr=1)
          sele s_tag
          skip
          loop
        endif

        sele stagtm
        if (netseek('t1', 'ktar'))
          while (kta=ktar)
            tmestor=tmesto
            sele etm
            if (netseek('t1', 'tmestor'))
              kgpr=kgp
              kplr=kpl
            else
              sele stagtm
              skip
              loop
            endif

            sele mkkplkgp
            if (!netseek('t1', 'kgpr,kplr'))
              netadd()
              netrepl('kgp,kpl,kta,sk', {kgpr,kplr,ktar,skr})
            endif

            sele stagtm
            skip
          enddo

        endif

        sele s_tag
        skip
      enddo

    else
      sele stagtm
      if (netseek('t1', 'ktar'))
        while (kta=ktar)
          tmestor=tmesto
          sele etm
          if (netseek('t1', 'tmestor'))
            kgpr=kgp
            kplr=kpl
          else
            sele stagtm
            skip
            loop
          endif

          sele mkkplkgp
          if (!netseek('t1', 'kgpr,kplr'))
            netadd()
            netrepl('kgp,kpl,kta,sk', {kgpr,kplr,ktar,skr})
          endif

          sele stagtm
          skip
        enddo

      endif

    endif

    sele stagm
    skip
  enddo

  sele mkkplkgp
  go top
  while (!eof())
    kplr=kpl
    kgpr=kgp
    sele etm
    if (netseek('t2', 'kplr,kgpr'))
      catr=cat
      dppr=dpp
      nactr=nact
      ncatr=getfield('t1', 'catr', 'kgpcat', 'nkgpcat')
      sele mkkplkgp
      netrepl('cat,ncat,dpp,nact', 'catr,ncatr,dppr,nactr')
    endif

    sele mkkplkgp
    skip
  enddo

  nuse('stagm')
  nuse('s_tag')
  nuse('stagtm')
  nuse('etm')
  nuse('kgpcat')
  close mkkplkgp
  return (.t.)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  09-25-20 * 06:03:07pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
Function nikolaPrice()
  Local nKm, cHm

  nKm := 999

  use m_wares alias wrs new Exclusive
  zap
  //nError := FTOKENINIT("nikola0csv.txt", CHR(13)+CHR(10), 2)
  nError := FTOKENINIT("nikola01.txt", CHR(13)+CHR(10), 2)
  IF (!(nError < 0))
    cRezult := FTOKENNEXT()
    WHILE (!FTOKENEND())
      cRezult := FTOKENNEXT()
      aRez := split(cRezult,chr(9))

      aRez[2] := CharOne(aRez[2])
      If Left(aRez[2],1) = '"'
        aRez[2] := Substr(aRez[2],2)
      EndIf
      If Right(aRez[2],1) = '"'
        aRez[2] := Substr(aRez[2], 1, len(aRez[2]) - 1)
      EndIf
      aRez[2] := allt(aRez[2])

      If val(aRez[1]) # 0
        nKm := val(aRez[1]) * 10000
      else
        nKm += 1
      EndIf

      cKm := padl(allt(str(nKm,7)),7,"0")

      sele wrs
      DBAppend()
      _Field->km := cKm
      _Field->Hm := translate_charset("cp1251", host_charset(), aRez[2])
      _Field->PriceR :=  Iif(empty(aRez[3]),1,0)
      _Field->KEi :=  '796'
      _Field->Ei  :=  'шт.'


      //outlog(__FILE__,__LINE__, _Field->km, _Field->Hm )

    ENDDO
  ELSE
    Ret:=FALSE
  ENDIF

  FTOKENCLOS()
  //quit

  sele wrs
  DBGoTop()
  Do While !eof()

    If _Field->PriceR = 1
      cHm := allt(_Field->Hm)
      //outlog(__FILE__,__LINE__,cHm)
      DBSkip()
      //outlog(__FILE__,__LINE__,_Field->PriceR,len(allt(_Field->Hm)),_Field->Hm)
        Do While _Field->PriceR = 0;
           .and. (len(allt(_Field->Hm)) < 27 .or. 'ручка' $ _Field->Hm  )
          If Left(_Field->Hm,1) = "-"
            _Field->Hm := cHm
          Else
            _Field->Hm := cHm + " " + allt(_Field->Hm)
          EndIf
          DBSkip()
        EndDo
        loop
    Else
      //
    EndIf

    DBSkip()
  EndDo

  dele for _Field->PriceR = 1
  pack


  close wrs
  Return ( Nil )

