#include 'common.ch'
#define MKO_PRDEC_TTH ((str(pr129,1)$'2;3' .OR. str(pr139,1)$'2;3'  .or. str(pr169,1)$'2;3' .OR. str(pr177,1)$'2;3') .or. (gnEnt=21.and.ttnt=999999))

/* Отчет по маркодержателю на день ОСТАТКИ и РЕАЛИЗАЦИЮ и ПРИХОД и Корреция остатки дня */
para p1, p2, p3, lNo_executed_order
/* p1 - дата
 * p2 - код маркодержателя
 * p3 - признак расчета ост на начало дня
       prOsNr
   0 - перенос "ост прошл дня"
   2 - по "ост прошл дня".
       "Рачет остатка" = Факт нач.мес. + (док.прих-док.расх)
       "ост прошл дня" - "Рачет остатка" ->  +- корр прих kop=211

   1 - по "остатку факт.нач.месяца" - "отгруженное"  ;

   3 - остаток с факт ;

   lNo_executed_order - расчет "не выполненых заявок"

 */
private DirOstr, DirMkr, DirYYr, DirMMr, PathDDr, PathYYMMr
DEFAULT lNo_executed_order TO NO
// outlog(__FILE__,__LINE__,procname(1),procline(1),p1, p2, p3, lNo_executed_order)

netuse('etm')
netuse('cskl')
netuse('ctov')
netuse('klnnac')
netuse('mkeep')
netuse('mkeepe')
netuse('kln')
netuse('mkeepg')
netuse('cgrp')
netuse('brand')
netuse('mkcros')
netuse('s_tag')

if (empty(p1))
  dtr=gdTd
else
  dtr=p1
endif

if (empty(p2))
  mkeepr=0
else
  mkeepr=p2
endif

if (empty(p3))
  prOsNr=0
else
  prOsNr=p3
endif


if (gnArm#0)
  scdt_r=setcolor('gr+/b,n/w')
  wdt_r=wopen(8, 20, 13, 60)
  wbox(1)
  @ 0, 1 say 'Дата     ' get dtr
  @ 1, 1 say 'Маркодерж' get mkeepr pict '999'
  @ 2, 1 say 'Ост на нач' get prOsNr pict '9'
  read
  wclose(wdt_r)
  setcolor(scdt_r)
  if (lastkey()=27)
    return
  endif

endif

if (mkeepr=0)
  return
endif

 outlog(3,__FILE__,__LINE__,'prOsNr',prOsNr,'dtr',dtr)

// Пути к директориям месяца
PathYYMMr:='g'+str(year(dtr), 4)+'\m'+iif(month(dtr)<10, '0'+str(month(dtr), 1), str(month(dtr), 2))+'\'
path129dr=gcPath_129+PathYYMMr
path139dr=gcPath_139+PathYYMMr
path169dr=gcPath_169+PathYYMMr
path177dr=gcPath_177+PathYYMMr
path151dr=gcPath_151+PathYYMMr

PathDr=gcPath_e+PathYYMMr


cMKeepr:=padl(ltrim(str(mkeepr, 3)), 3, '0')
PathDDr := PathOstDD(cMKeepr, dtr)

if (gnArm#0.and.file(PathDDr+'mkost.dbf'))
  aotbr=1
  aotb={ 'Нет', 'Да' }
  aotbr=alert('Перезаписать?', aotb)
  if (lastkey()=27.or.aotbr#2)
    return
  endif

endif

// Создание директорий
if (dirchange(DirOstr)#0)
  dirmake(DirOstr)
endif
dirchange(gcPath_l)

if (dirchange(DirMkr)#0)
  dirmake(DirMkr)
endif
dirchange(gcPath_l)

if (dirchange(DirYYr)#0)
  dirmake(DirYYr)
endif
dirchange(gcPath_l)

if (dirchange(DirMMr)#0)
  dirmake(DirMMr)
endif
dirchange(gcPath_l)

// созданем каталоги дней
PathSvOstr=DirMMr+'\'
for i=1 to 31
  dirddr=DirMMr+'\d'+iif(i<10, '0'+str(i, 1), str(i, 2))
  if (dirchange(dirddr)#0)
    dirmake(dirddr)
  endif
  dirchange(gcPath_l)

next

dirchange(gcPath_l)
if (FILE(PathSvOstr+'svost.cdx'))
  ERASE (PathSvOstr+'svost.cdx')
endif

if (!file(PathSvOstr+'svost.dbf') .OR. BOM(p1) = p1)
  sele dbft
  copy stru to stmp exte
  sele 0
  use stmp excl
  zap
  appe blank
  repl field_name with 'sk', ;
   field_type with 'n',      ;
   field_len with 3
  appe blank
  repl field_name with 'MnTov', ;
   field_type with 'n',         ;
   field_len with 7
  appe blank
  repl field_name with 'dt', ;
   field_type with 'd',      ;
   field_len with 8
  for i=1 to 31
    appe blank
    repl field_name with 'osn'+alltrim(str(i, 2)), ;
     field_type with 'n',                              ;
     field_len with 12,                                ;
     field_dec with 3
    appe blank
    repl field_name with 'osk'+alltrim(str(i, 2)), ;
     field_type with 'n',                              ;
     field_len with 12,                                ;
     field_dec with 3
  endfor

  CLOSE
  create (PathSvOstr+'svost') from stmp
  CLOSE
  sele 0
  use (PathSvOstr+'svost') excl
  inde on str(sk, 3)+str(MnTov, 7) tag t1
  CLOSE
  erase stmp.dbf
else
  sele 0
  use (PathSvOstr+'svost') excl
  inde on str(sk, 3)+str(MnTov, 7) tag t1
  CLOSE
endif

// Расходы
if (select('mkrs')#0)
  sele mkrs
  CLOSE
endif

filedelete('mkrs'+'.*')
crtt('mkrs', 'f:sk c:n(3) f:dop c:d(10) f:ttn c:n(7) f:vo c:n(2) f:kop c:n(3) f:kpl c:n(7) f:kgp c:n(7) f:kta c:n(4) f:MnTov c:n(7) f:kvp c:n(11,3) f:zen c:n(10,3) f:tcen c:n(2) f:DocGuId c:c(36) f:kvpp c:n(11,3)')

use mkrs excl new
inde on str(sk, 3)+str(ttn, 7)+str(MnTov, 7) tag t1
copy stru to mkrso

// Приходы
if (select('mkpr')#0)
  sele mkpr
  CLOSE
endif

filedelete('mkpr'+'.*')
crtt('mkpr', 'f:sk c:n(3) f:dpr c:d(10) f:nd c:n(7) f:mn c:n(7) f:vo c:n(2) f:kop c:n(3) f:kps c:n(7) f:kzg c:n(7) f:kta c:n(4) f:MnTov c:n(7) f:kf c:n(10,3) f:zen c:n(10,3) f:DocGuId c:c(36) f:kfp c:n(10,3) f:TtnPst c:c(40) f:DTtnPst c:d(10)')

use mkpr excl new
inde on str(sk, 3)+str(mn, 7)+str(MnTov, 7) tag t1
copy stru to mkprc
copy stru to mkpro
sele 0
use mkprc excl
inde on str(sk, 3)+str(mn, 7)+str(MnTov, 7) tag t1

// Остатки
if (select('mkost')#0)
  sele mkost
  CLOSE
endif

crtt('mkost', 'f:sk c:n(3) f:MnTov c:n(7) f:OsFoNd c:n(12,3) f:OsFoNdF c:n(12,3) f:pr c:n(12,3) f:rs c:n(12,3) f:osfotd c:n(12,3)')
use mkost new excl
inde on str(sk, 3)+str(MnTov, 7) tag t1

if (prOsNr=1 .or. prOsNr=3) // фактический
  dtPdr=dtr-1
  PathSvOstr=gcPath_ew+'ost\mk'+cMKeepr+'\g'+str(year(dtpdr), 4)+'\m'+iif(month(dtpdr)<10, '0'+str(month(dtpdr), 1), str(month(dtpdr), 2))+'\'

  if (file(PathSvOstr+'svost.dbf'))

    use (PathSvOstr+'svost') new excl
    If neterr()
      outlog(__FILE__,__LINE__,neterr(),"use (PathSvOstr+'svost') excl")
      return
    EndIf
    inde on str(sk, 3)+str(MnTov, 7) tag t1
    set orde to tag t1

    cOstr='osk'+alltrim(str(day(dtpdr), 2)); pOstr:=FieldPos(cOstr)

    SvOst2MkOst(pOstr,dtr) // просто список товара

    sele svost
    CLOSE

    OsFoNd(prOsNr) // по tov OsFoNd & OsFoKd & корр. расх и прих

    OsFoNd2MkOst() // заполнеие OsFoNd & OsFoNdF

  else // ! (file(PathSvOstr+'svost.dbf'))

    OsFoNd()

    OsFoNd2MkOst()

  endif

  sele OsFoNd
  CLOSE
else  // prOsNr#1 ()

  if (prOsNr=2)
    OsFoNd() // OsFoNd - заполнили
  endif

  dtPdr=dtr-1
  PathSvOstr=gcPath_ew+'ost\mk'+cMKeepr+'\g'+str(year(dtpdr), 4)+'\m'+iif(month(dtpdr)<10, '0'+str(month(dtpdr), 1), str(month(dtpdr), 2))+'\'
  if (file(PathSvOstr+'svost.dbf'))
    // erase (PathSvOstr+'svost.cdx')
    use (PathSvOstr+'SvOst') new excl
    If neterr()
      outlog(__FILE__,__LINE__,neterr(),"neterr() -> use (PathSvOstr+'SvOst') new excl")
      return
    EndIf
    If lastrec()=0
      outlog(__FILE__,__LINE__,"нет данных по остаткам",PathSvOstr)
      outlog(__FILE__,__LINE__,'просчтать данные в 1-го числа')
      return
    EndIf
    inde on str(sk, 3)+str(MnTov, 7) tag t1
    set orde to tag t1
    cOstr='osk'+alltrim(str(day(dtpdr), 2)); pOstr:=FieldPos(cOstr)

      skr=sk
      cMnr='mn'+str(skr, 3)+'r'
      // outlog(__FILE__,__LINE__,cMnr,skr,'cMnr,skr',PathSvOstr,dtpdr,lastrec())
      &cMnr=0

    SvOst2MkOst(pOstr,dtr) // заполняем из перд.дня OsFoNd

    sele svost
    CLOSE

    // корреция 211 кодом
    if (prOsNr=2)
      CorrectKop211()
    endif

  endif

endif

if (select('mkprc')#0)
  sele mkprc
  CLOSE
endif

sele cskl
go top
while (!eof())
  if (gnEnt=20)
    if (mkeepr=102)
      cListSaleSk:="228;400;254;259;403;246;401"
    else
      cListSaleSk:="228;400"
    endif
    if (!(str(Sk, 3) $ cListSaleSk))
      skip
      loop
    endif
  endif

  if (gnEnt=21)
    cListSaleSk:="232;700;237;238;702;703;262;263;704;705"
    if (!(str(Sk, 3) $ cListSaleSk))
      skip
      loop
    endif

  endif

  pathr=pathdr+alltrim(path)
  path129r=path129dr+alltrim(path)
  path139r=path139dr+alltrim(path)
  path151r=path151dr+alltrim(path)
  path169r=path169dr+alltrim(path)
  path177r=path177dr+alltrim(path)

  skr=sk
  sklr=skl
  nskr=nskl
  rmr=rm
  if (!netfile('tov', 1))
    skip
    loop
  endif

  netuse('tov',,, 1)
  if (skr=237.or.skr=702)
    locate for mkeep=mkeepr
    if (!found())
      nuse('tov')
      sele cskl
      skip
      loop
    endif

  else
    if (!netseek('t6', 'sklr,mkeepr'))
      nuse('tov')
      sele cskl
      skip
      loop
    endif

  endif

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

  case (gnEnt=21)
    kkl_r=9000000
  otherwise
    kkl_r=0
  endcase

  netuse('rs1',,, 1)
  netuse('rs2',,, 1)
  netuse('pr1',,, 1)
  netuse('pr2',,, 1)

  // Товар
  sele tov
  go top
  while (!eof())
    if (otv=1)
      skip
      loop
    endif

    MnTovr=MnTov
    if (gnEnt=21)
      If Skip_Sk_MnTov(skr,MnTovr)
        skip;        loop
      EndIf

    else
      if (int(MnTovr/10000)<2)
        skip;        loop
      endif

    endif

    sele ctov
    if (netseek('t1', 'MnTovr'))
      if (mkeep#mkeepr)
        sele tov
        skip
        loop
      endif

      if (MnTovT#0)
        MnTovr=MnTovT
      endif

      sele mkost
      if (!netseek('t1', 'skr,MnTovr'))
        sele mkost
        appe blank
        repl sk with skr,  ;
         MnTov with MnTovr
      endif

    endif

    sele tov
    skip
  enddo

  //////////////////////////// Расход /////////////////////////////
  sele rs1
  while (!eof())

    if (skr=237 .or.  skr=702)
      if (prz=0)
        skip;        loop
      endif

      If Skip4Dop(Dtr)
        skip;        loop
      EndIf

    else

      if (iif(empty(dop),dot,dop) = dtr .or. MKO_PRDEC_TTH) // pr177=2 .or. pr169=2
        // добавляем
      else
        If empty(lNo_executed_order) // не нужно добавлять "не выполненые заявки"
          skip;       loop
        else // добавить "не выполненые заявки"
          If empty(dop) .and. !empty(DocGuId) .and. vo=9 ;
            .and. (DtRo>=dtr-3 .and.  DtRo<=dtr+1)
            //
          else
            skip;       loop
          EndIf
        endif
      endif

      If TtnDeCode()
        sele rs1
        skip;        loop
      EndIf

    endif


    sklr=skl
    dopr:=Iif(empty(dop),dtr,dop)
    ttnr=ttn
    vor=vo
    kopr=kop
    ktar=kta
    DocGuIdr=DocGuId
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
      if (nkkl#0)
        kplr=nkkl
      else
        kplr=kpl
      endif

      if (kpv#0)
        kgpr=kpv
      else
        kgpr=kgp
      endif

    endif

    sele rs2
    if (netseek('t1', 'ttnr'))
      while (ttn=ttnr)
        ktlr=ktl
        Otvr=getfield('t1', 'sklr,ktlr', 'tov', 'otv')
        if (Otvr=1)
          sele rs2
          skip
          loop
        endif

        MnTovr=MnTov
        if (gnEnt=21)
          If Skip_Sk_MnTov(skr,MnTovr)
            skip;        loop
          EndIf

        else
          if (int(MnTovr/10000)<2)
            skip;            loop
          endif

        endif

        MnTovTr=getfield('t1', 'MnTovr', 'ctov', 'MnTovT')
        if (!empty(MnTovTr))
          MnTovr=MnTovTr
        endif

        sele mkost
        if (!netseek('t1', 'skr,MnTovr'))
          sele rs2
          skip
          loop
        endif

        sele rs2
        kvppr:=Iif(empty(rs1->dop) .and. rs1->vo=9,-1,0)
        kvpr=kvp
        zenr=zen
        sele mkrs
        if .not. netseek('t1', 'skr,ttnr,MnTovr')
          netadd()
          netrepl('sk,dop,ttn,vo,kop,kpl,kgp,kta,MnTov,zen,DocGuId,kvpp',           ;
                   {skr,dopr,ttnr,vor,kopr,kplr,kgpr,ktar,MnTovr,zenr,DocGuIdr,kvppr} ;
               )
        endif

        netrepl('kvp', {kvp+kvpr})
        sele mkost
        repl rs with rs+kvpr
        sele rs2
        skip
      enddo

    endif

    sele rs1
    skip
  enddo

  //////////////////////////// Приход  ////////////////////////////
  sele pr1
  while (!eof())
    // корректирующие документы тары
    if (skr=263 .and. kta=999 .and. vo=1 .and. kop=108)
      skip
      loop
    endif

    if (prz=0)
      skip
      loop
    endif

    dprr=dpr
    if (dprr#dtr)
      skip
      loop
    endif

    ndr=nd
    mnr=mn
    vor=vo
    kopr=kop
    kpsr=kps
    kzgr=kzg
    ktar=kta
    DocGuIdr=DocGuId
    TtnPstr=TtnPst
    DTtnPstr=DTtnPst
    if (vor=6)
      kzgr=kkl_r
      do case
      case (sks=300)
        kpsr=3000000
      case (sks=400)
        kpsr=4000000
      case (sks=500)
        kpsr=5000000
      case (sks=600)
        kpsr=6000000
      otherwise
        kpsr=gnKKL_c
      endcase

    endif

    sele pr2
    if (netseek('t1', 'mnr'))
      while (mn=mnr)
        MnTovr=MnTov
        if (gnEnt=21)
          If Skip_Sk_MnTov(skr,MnTovr)
            skip;        loop
          EndIf

        else
          if (int(MnTovr/10000)<2)
            skip
            loop
          endif

        endif

        MnTovTr=getfield('t1', 'MnTovr', 'ctov', 'MnTovT')
        if (!empty(MnTovTr))
          MnTovr=MnTovTr
        endif

        sele mkost
        if (!netseek('t1', 'skr,MnTovr'))
          sele pr2
          skip
          loop
        endif

        sele pr2
        if (str(kopr, 3) $ "108;107")
          zenr=ozen
          if (zenr=0)
            zenr=zen
          endif

        else
          zenr=zen
        endif

        kfr=kf
        sele mkpr
        if (!netseek('t1', 'skr,mnr,MnTovr'))
          netadd()
          netrepl('sk,dpr,nd,mn,vo,kop,kps,kzg,kta,MnTov,zen,DocGuId,TtnPst,DTtnPst',              ;
                   {skr,dprr,ndr,mnr,vor,kopr,kpsr,kzgr,ktar,MnTovr,zenr,DocGuIdr,TtnPstr,DTtnPstr} ;
               )
        endif

        netrepl('kf', {kf+kfr})
        sele mkost
        repl pr with pr+kfr
        sele pr2
        skip
      enddo

    endif

    sele pr1
    skip
  enddo

  nuse('tov')
  nuse('rs1')
  nuse('rs2')
  nuse('pr1')
  nuse('pr2')
  sele cskl
  skip
enddo

if (prOsNr=2)
  sele mkpr
  appe from mkprc
endif

PathSvOstr=gcPath_ew+'ost\mk'+cMKeepr+'\g'+str(year(dtr), 4)+'\m'+iif(month(dtr)<10, '0'+str(month(dtr), 1), str(month(dtr), 2))+'\'
if (file(PathSvOstr+'svost.dbf'))
  use (PathSvOstr+'svost') new excl
  If neterr()
    outlog(__FILE__,__LINE__,"use (PathSvOstr+'svost') new excl -> neterr()",PathSvOstr,neterr())
    quit
  EndIf
  set orde to tag t1
  cOsnr='osn'+alltrim(str(day(dtr), 2)); pOsnr:=FieldPos(cOsnr)
  cOskr='osk'+alltrim(str(day(dtr), 2)); pOskr:=FieldPos(cOskr)
endif

sele mkost
go top
while (!eof())
  skr=sk
  MnTovr=MnTov
  if (gnEnt=21)
    If Skip_Sk_MnTov(skr,MnTovr)
      skip;        loop
    EndIf

  else
    if (int(MnTovr/10000)<2)
      skip
      loop
    endif

  endif

  repl osfotd with OsFoNd+pr-rs
  skip
enddo

sele mkost
go top
while (!eof())
  skr=sk
  MnTovr=MnTov
  if (gnEnt=21)
    If Skip_Sk_MnTov(skr,MnTovr)
      skip;        loop
    EndIf

  else
    if (int(MnTovr/10000)<2)
      skip
      loop
    endif

  endif

  OsFoNdr=OsFoNd
  osfotdr=osfotd
  if (select('svost')#0)
    sele svost
    seek str(skr, 3)+str(MnTovr, 7)
    if (!found())
      appe blank
      repl sk with skr,  MnTov with MnTovr
    endif

    //repl &cOsnr with OsFoNdr,   &cOskr with osfotdr
    FieldPut(pOsNr, OsFoNdr)
    FieldPut(pOsKr, OsfoTdr)

    if (empty(dt))
      repl dt with dtr
    endif

  endif

  sele mkost
  skip
enddo

if (gnArm=25)             // SERV
else
  nuse('')
endif

sele mkrs
if (!file(PathDDr+'mkrs.dbf'))
  copy to (PathDDr+'mkrs')
else
  #ifdef __CLIP__
      copy to (PathDDr+'mkrs')
  #else
      crmkrs()
  #endif
endif

sele mkpr
if (!file(PathDDr+'mkpr.dbf'))
  copy to (PathDDr+'mkpr')
else
  #ifdef __CLIP__
      copy to (PathDDr+'mkpr')
  #else
      crmkpr()
  #endif
endif

sele mkost
copy to (PathDDr+'mkost')

do case
case (mkeepr=102)
endcase

nuse('mkrs')
nuse('mkpr')
nuse('mkprc')
nuse('mkost')
nuse('svost')

sele 0
use (PathDDr+'mkrs') excl
inde on str(sk, 3)+str(ttn, 7)+str(MnTov, 7) tag t1
CLOSE

sele 0
use (PathDDr+'mkpr') excl
inde on str(sk, 3)+str(mn, 7)+str(MnTov, 7) tag t1
CLOSE

sele 0
use (PathDDr+'mkost') excl
inde on str(sk, 3)+str(MnTov, 7) tag t1
CLOSE

/****************** */
function vmkost(p1)
  /****************** */
  nmkeep_r=alltrim(nmkeepr)
  cMKeepr:=padl(ltrim(str(mkeepr, 3)), 3, '0')

  PathSvOstr=gcPath_ew+'ost\mk'+cMKeepr+'\g'+str(year(gdTd), 4)+'\m'+iif(month(gdTd)<10, '0'+str(month(gdTd), 1), str(month(gdTd), 2))+'\'

  if (file(PathSvOstr+'svost.dbf'))
    sele 0
    use (PathSvOstr+'svost') excl
    set orde to tag t1
    go top
    rcsvostr=recn()
    fldnomr=1
    vidr=1
    while (.t.)
      sele svost
      go rcsvostr
      rcsvostr=slce('svost', 1, 1, 18,, "e:sk h:'Скл' c:n(3) e:MnTov h:'Код' c:n(7) e:getfield('t1','svost->MnTov','ctov','nat') h:'Наименование' c:c(40) e:ost1 h:'01' c:n(10,3) e:ost2 h:'02' c:n(10,3) e:ost3 h:'03' c:n(10,3) e:ost4 h:'04' c:n(10,3) e:ost5 h:'05' c:n(10,3) e:ost6 h:'06' c:n(10,3) e:ost7 h:'07' c:n(10,3) e:ost8 h:'08' c:n(10,3) e:ost9 h:'09' c:n(10,3) e:ost10 h:'10' c:n(10,3) e:ost11 h:'11' c:n(10,3) e:ost12 h:'12' c:n(10,3) e:ost13 h:'13' c:n(10,3) e:ost14 h:'14' c:n(10,3) e:ost15 h:'15' c:n(10,3) e:ost16 h:'16' c:n(10,3) e:ost17 h:'17' c:n(10,3) e:ost18 h:'18' c:n(10,3) e:ost19 h:'19' c:n(10,3) e:ost20 h:'20' c:n(10,3) e:ost21 h:'21' c:n(10,3) e:ost22 h:'22' c:n(10,3) e:ost23 h:'23' c:n(10,3) e:ost24 h:'24' c:n(10,3) e:ost25 h:'25' c:n(10,3) e:ost26 h:'26' c:n(10,3) e:ost27 h:'27' c:n(10,3) e:ost28 h:'28' c:n(10,3) e:ost29 h:'29' c:n(10,3) e:ost30 h:'30' c:n(10,3) e:ost31 h:'31' c:n(10,3)",,,,,,, 'Остатки по дням уе '+nmkeep_r, 1, 2)
      if (lastkey()=27)
        exit
      endif

      go rcsvostr
      skr=sk
      MnTovr=MnTov
      do case
      case (lastkey()=19) // Left
        fldnomr=fldnomr-1
        if (fldnomr=0)
          fldnomr=1
        endif

      case (lastkey()=4)  // Right
        fldnomr=fldnomr+1
      endcase

    enddo

    nuse('svost')
  endif

  return (.t.)


/************** */
function sale()
  /************** */
  if (select('sale')#0)
    sele sale
    CLOSE
  endif

  crtt(PathDDr+'sale', "f:edrpou c:c(10) f:ttid c:c(7) f:chanel c:c(20) f:bar c:c(13) f:date c:c(10) f:cnt c:c(10) f:price c:c(10) f:summa c:c(12) f:summavat c:c(12) f:forwarder c:c(20) f:taid c:c(10) f:svid c:c(4) f:orderid c:c(10) f:saleid c:c(10) f:delay c:c(10) f:summadisc c:c(12)")
  sele 0
  use (PathDDr+'sale') excl
  inde on saleid+bar tag t1

  sele mkrs
  go top
  while (!eof())
    if (vo#9)
      skip
      loop
    endif

    MnTovr=MnTov
    if (gnEnt=21)
      if (int(MnTovr/10000)=1)
        skip
        loop
      endif

    else
      if (int(MnTovr/10000)<2)
        skip
        loop
      endif

    endif

    kplr=kpl
    kgpr=kgp
    kkl1=getfield('t1', 'kplr', 'kln', 'kkl1')
    edrpour=str(kkl1, 10)
    tmestor=getfield('t2', 'kplr,kgpr', 'etm', 'tmesto')
    ttidr=str(tmestor, 7)
    chanelr=''
    bar_r=getfield('t1', 'MnTovr', 'ctov', 'bar')
    barr=str(bar_r, 13)
    dater=dtoc(dop)
    kvpr=kvp
    cntr=str(kvpr, 10, 3)
    zenr=zen
    pricer=str(zenr, 10, 3)
    forwarderr=''
    taidr=''
    ktasr=getfield('t1', 'ktar', 's_tag', 'ktas')
    svidr=str(ktasr, 4)
    orderidr=''
    saleidr=str(sk, 3)+'0'+strtran(str(ttn, 6), ' ', '0')
    delayr=''
    summadiscr=''
    sele sale
    if (!found())
      appe blank
      repl edrpou with edrpour,   ;
       ttid with ttidr,           ;
       chanel with chanelr,       ;
       bar with barr,             ;
       date with dater,           ;
       price with pricer,         ;
       forwarder with forwarderr, ;
       taid with taidr,           ;
       svid with svidr,           ;
       orderid with orderidr,     ;
       saleid with saleidr,       ;
       delay with delayr,         ;
       summadisc with summadiscr
    endif

    kvp_r=val(cnt)
    kvpr=kvp_r+kvpr
    cntr=str(kvpr, 10, 3)
    zenr=val(price)
    smr=roun(kvpr*zenr, 2)
    summar=str(smr, 12, 2)
    smndsr=roun(smr/5, 2)
    summavatr=str(smndsr, 12, 2)
    repl cnt with cntr,      ;
     summa with summar,      ;
     summavat with summavatr
    sele mkrs
    skip
  enddo

  /* Возвраты от покупателя */
  sele mkpr
  go top
  while (!eof())
    if (kop#108)
      skip
      loop
    endif

    MnTovr=MnTov
    if (gnEnt=21)
      if (int(MnTovr/10000)=1)
        skip
        loop
      endif

    else
      if (int(MnTovr/10000)<2)
        skip
        loop
      endif

    endif

    kpsr=kps
    kzgr=kzg
    kkl1=getfield('t1', 'kpsr', 'kln', 'kkl1')
    edrpour=str(kkl1, 10)
    tmestor=getfield('t2', 'kplr,kzgr', 'etm', 'tmesto')
    ttidr=str(tmestor, 7)
    chanelr=''
    bar_r=getfield('t1', 'MnTovr', 'ctov', 'bar')
    barr=str(bar_r, 13)
    dater=dtoc(dpr)
    kfr=-kf
    cntr=str(kfr, 10, 3)
    zenr=zen
    pricer=str(zenr, 10, 3)
    forwarderr=''
    taidr=''
    ktasr=getfield('t1', 'ktar', 's_tag', 'ktas')
    svidr=str(ktasr, 4)
    orderidr=''
    saleidr=str(sk, 3)+'1'+strtran(str(mn, 6), ' ', '0')
    delayr=''
    summadiscr=''
    sele sale
    if (!found())
      appe blank
      repl edrpou with edrpour,   ;
       ttid with ttidr,           ;
       chanel with chanelr,       ;
       bar with barr,             ;
       date with dater,           ;
       price with pricer,         ;
       forwarder with forwarderr, ;
       taid with taidr,           ;
       svid with svidr,           ;
       orderid with orderidr,     ;
       saleid with saleidr,       ;
       delay with delayr,         ;
       summadisc with summadiscr
    endif

    kf_r=val(cnt)
    kfr=kf_r+kfr
    cntr=str(kfr, 10, 3)
    zenr=val(price)
    smr=roun(kfr*zenr, 2)
    summar=str(smr, 12, 2)
    smndsr=roun(smr/5, 2)
    summavatr=str(smndsr, 12, 2)
    repl cnt with cntr,      ;
     summa with summar,      ;
     summavat with summavatr
    sele mkrs
    skip
  enddo

  sele sale
  CLOSE
  return (.t.)

/************** */
function rest()
  /************** */
  if (select('rest')#0)
    sele rest
    CLOSE
  endif

  crtt(PathDDr+'rest', "f:date c:c(10) f:whid c:c(1) f:bar c:c(13) f:cnt c:c(12)")
  sele 0
  use (PathDDr+'rest') excl
  inde on date+whid+bar tag t1

  cdtr=dtoc(dtr)
  cdt1r=dtoc(dtr+1)
  sele mkost
  go top
  while (!eof())
    skr=sk
    MnTovr=MnTov
    if (gnEnt=21)
      If Skip_Sk_MnTov(skr,MnTovr)
        skip;        loop
      EndIf

    else
      if (int(MnTovr/10000)<2)
        skip
        loop
      endif

    endif

    barr=getfield('t1', 'MnTovr', 'ctov', 'bar')
    barr=str(barr, 13)
    osnr=OsFoNd
    oskr=osfotd
    if (skr=228.or.skr=400)
      whidr='1'
    else
      whidr='2'
    endif

    sele rest
    seek dtos(dtr)+whidr+barr
    if (!found())
      appe blank
      repl date with cdtr, ;
       whid with whidr,    ;
       bar with barr
    endif

    cntr=val(cnt)
    cntr=str(cntr+osnr, 12, 3)
    repl cnt with cntr

    seek dtos(dtr+1)+whidr+barr
    if (!found())
      appe blank
      repl date with cdt1r, ;
       whid with whidr,     ;
       bar with barr
    endif

    cntr=val(cnt)
    cntr=str(cntr+oskr, 12, 3)
    repl cnt with cntr
    sele mkost
    skip
  enddo

  sele rest
  CLOSE
  return (.t.)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  08-03-18 * 03:46:38pm
 НАЗНАЧЕНИЕ.........
 OsFoNd - начало дня
 osfokd - конец дня
 - 1. Заполнение из ТОВ  OsFoNd  osfokd
 дни, что больше пропускаем, дни, что меньше уменьшае Нд и Кд,
 а то что = уменьшаем Кд
   2. коррекция расходом
   3. коррекция приходом
 ПАРАМЕТРЫ.......... dtr - дата отчета
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
static function OsFoNd(prOsNr)
  LOCAL pFld_Ost, cFld_Ost

  cFld_Ost := 'OsN' // факт. начало
  If Empty(prOsNr) .or. prOsNr#3
    //
  else // = 3
    If dtr = EOM(dtr)
      cFld_Ost := 'OsF' // факт. конец
    EndIf
  endif

  if (select("OsFoNd") # 0)
    close OsFoNd
  endif

  // создали остатки НачаДня
  crtt('OsFoNd', 'f:sk c:n(3) f:MnTov c:n(7) f:OsFoNd c:n(12,3) f:osfokd c:n(12,3)')
  sele 0
  use OsFoNd excl
  inde on str(sk, 3)+str(MnTov, 7) tag t1

  sele cskl
  go top
  while (!eof())
    if (gnEnt=20)
      if (!(sk=228.or.sk=400.or.sk=254.or.sk=259.or.sk=403))
        skip
        loop
      endif

    endif

    if (gnEnt=21)
      //if !(sk=232.or.sk=700.or.sk=703.or.sk=237.or.sk=702.or.sk=238.or.sk=262)
      cListSaleSk:="232 700 237 238 702 703 262 263 704 705"
      if (!(str(Sk, 3) $ cListSaleSk))
        skip
        loop
      endif

    endif

    pathr=pathdr+alltrim(path)
    path129r=path129dr+alltrim(path)
    path139r=path139dr+alltrim(path)
    path169r=path169dr+alltrim(path)
    path151r=path151dr+alltrim(path)
    path177r=path177dr+alltrim(path)

    skr=sk
    sklr=skl
    if (!netfile('tov', 1))
      skip
      loop
    endif

    netuse('tov',,, 1)
    if (skr=237.or.skr=702)
      locate for mkeep=mkeepr
      if (!found())
        nuse('tov')
        sele cskl
        skip
        loop
      endif

    else
      if (!netseek('t6', 'sklr,mkeepr'))
        nuse('tov')
        sele cskl
        skip
        loop
      endif

    endif

    //  будем читать OSN - факт. начало
    sele tov
    pFld_Ost:=FieldPos(cFld_Ost)

    netuse('rs1',,, 1)
    netuse('rs2',,, 1)
    netuse('pr1',,, 1)
    netuse('pr2',,, 1)

    //  Товар
    sele tov
    go top
    while (!eof())
      if (otv=1)
        skip
        loop
      endif

      MnTovr=MnTov
      if (gnEnt=21)
        If Skip_Sk_MnTov(skr,MnTovr)
          skip;        loop
        EndIf

      else
        if (int(MnTovr/10000)<2)
          skip
          loop
        endif

      endif

      osnr:=FieldGet(pFld_Ost) //osn

      sele ctov
      if (netseek('t1', 'MnTovr'))
        if (mkeep#mkeepr)
          sele tov
          skip
          loop
        endif

        if (MnTovT#0)
          MnTovr=MnTovT
        endif

        sele OsFoNd
        if (!netseek('t1', 'skr,MnTovr'))
          appe blank
          repl sk with skr,  ;
           MnTov with MnTovr
        endif

        repl OsFoNd with OsFoNd+osnr, ; // начало дня
             osfokd with osfokd+osnr // конец дня
      endif

      sele tov
      skip
    enddo

    // вычисление остатка "с уч.вып" по "факт остатку нач.месяца"
    If Empty(prOsNr) .or. prOsNr#3

      use mkrso new
      use mkpro new

      // Расход
      sele rs1
      while (!eof())
        // склад брак пропускаем и в нем тару
        If skr = 263 .and. (int(MnTovr/10000)<1) // тара
          skip;        loop
        EndIf

        if (skr=237.or.skr=702)
          if (prz=0)
            skip; loop
          endif

        else

          if TtnDeCodeN()
            sele rs1
            skip
            loop
          endif

        endif

        dopr=iif(empty(dop),dot,dop) // dop
        // пропустаем расход с датой отгр >  даты отчета
        if (dopr>dtr .or. empty(dopr))
          skip
          loop
        endif

        ttnr=ttn

        sele rs2
        if (netseek('t1', 'ttnr'))
          while (ttn=ttnr)
            ktlr=ktl
            Otvr=getfield('t1', 'sklr,ktlr', 'tov', 'otv')
            if (Otvr=1)
              sele rs2
              skip
              loop
            endif

            MnTovr=MnTov
            if (gnEnt=21)
              If Skip_Sk_MnTov(skr,MnTovr)
                skip;        loop
              EndIf

            else
              if (int(MnTovr/10000)<2)
                skip
                loop
              endif

            endif

            MnTovTr=getfield('t1', 'MnTovr', 'ctov', 'MnTovT')
            if (!empty(MnTovTr))
              MnTovr=MnTovTr
            endif


            sele rs2
            kvpr=kvp
            sele OsFoNd
            seek str(skr, 3)+str(MnTovr, 7)
            if (found())

              SaveRecRsUpdate('rs1','rs2',MnTovr,skr)

              sele OsFoNd
              if (dopr<dtr)
                // коррекция и начала и конца дня
                repl OsFoNd with OsFoNd-kvpr, ;
                 osfokd with osfokd-kvpr
              else // dopr=dtr
                // коррекция конца дня
                repl osfokd with osfokd-kvpr
              endif

            endif

            sele rs2
            skip
          enddo

        endif

        sele rs1
        skip
      enddo

      ///   Приход
      sele pr1
      while (!eof())
        if (prz=0)
          skip
          loop
        endif

        dprr=dpr
        if (dprr>dtr)
          skip
          loop
        endif

        mnr=mn
        sele pr2
        if (netseek('t1', 'mnr'))
          while (mn=mnr)
            MnTovr=MnTov
            if (gnEnt=21)
              If Skip_Sk_MnTov(skr,MnTovr)
                skip;        loop
              EndIf

            else
              if (int(MnTovr/10000)<2)
                skip
                loop
              endif

            endif


            sele pr2
            kfr=kf
            MnTovTr=getfield('t1', 'MnTovr', 'ctov', 'MnTovT')
            if (!empty(MnTovTr))
              MnTovr=MnTovTr
            endif

            sele OsFoNd
            seek str(skr, 3)+str(MnTovr, 7)
            if (found())

              SaveRecPrUpdate('Pr1','Pr2',MnTovr,skr)

              sele OsFoNd
              if (dprr<dtr)
                // коррекция и начала и конца дня
                repl OsFoNd with OsFoNd+kfr, ;
                 osfokd with osfokd+kfr
              else
                // коррекция конца дня
                repl osfokd with osfokd+kfr
              endif

            endif

            sele pr2
            skip
          enddo

        endif

        sele pr1
        skip
      enddo

      nuse('tov')
      nuse('rs1')
      nuse('rs2')
      nuse('pr1')
      nuse('pr2')

      sele mkrso
      copy to (PathDDr+'mkrso')
      close mkrso
      sele mkpro
      copy to (PathDDr+'mkpro')
      close  mkpro

    EndIf
    sele cskl
    skip
  enddo

  return (.t.)


/****************** */
function mkdt(p1, p2, lCrtt_Only)
  /* p1 dt
   * p2 mkeep
   ******************
   */
  if (!empty(p1))
    dtr=p1
  else
    dtr=gdTd
  endif

  if (!empty(p1))
    mkeepr=p2
  else
    mkeepr=0
  endif

  select 0
  nMaxSelect:=SELECT()

  if (gnArm#0)
    scdt_r=setcolor('gr+/b,n/w')
    wdt_r=wopen(8, 20, 13, 60)
    wbox(1)
    @ 0, 1 say 'Дата     ' get dtr
    @ 1, 1 say 'Маркодерж' get mkeepr pict '999'
    read
    wclose(wdt_r)
    setcolor(scdt_r)
    if (lastkey()=27)
      return
    endif

  endif

  cMKeepr:=padl(ltrim(str(mkeepr, 3)), 3, '0')

  DirOstr=gcPath_ew+'ost'
  DirMkr=gcPath_ew+'ost\mk'+cMKeepr
  DirYYr=DirMkr+'\g'+str(year(dtr), 4)
  DirMMr=DirYYr+'\m'+iif(month(dtr)<10, '0'+str(month(dtr), 1), str(month(dtr), 2))
  PathDDr=DirMMr+'\d'+iif(day(dtr)<10, '0'+str(day(dtr), 1), str(day(dtr), 2))+'\'
  if (!file(PathDDr+'mkost.dbf'))
    wmess('Нет данных', 2)
    return (.t.)
  endif

  netuse('ctov')
  netuse('cskl')
  netuse('kln')
  netuse('knasp')
  netuse('krn')

  flr='mkdoc'+cMKeepr
  fler='mkdoe'+cMKeepr
  if (select('mkdoc')#0)
    sele mkdoc
    CLOSE
  endif

  erase (flr+".dbf")
  erase (flr+".cdx")
  crtt(flr, 'f:vo c:n(2) f:kgp c:n(7) f:kpl c:n(7) f:okpo c:n(10) f:ngp c:c(40) f:npl c:c(40) f:agp c:c(40) f:DocGuId c:c(36) f:sk c:n(3) f:ttn c:n(6) f:kop c:n(3) f:dttn c:d(10) f:MnTov c:n(7) f:MnTovT c:n(7) f:bar c:n(13) f:ktl c:n(9) f:nat c:c(60)  f:zen c:n(10,3) f:zen_n_but c:n(10,3)  f:kvp c:n(11,3) f:apl c:c(40) f:kta c:n(3) f:ddc c:d(10) f:tdc c:c(8) f:nnz c:c(9) f:dcl c:n(15,3) f:mkid c:c(20) f:nmkid c:c(90) f:tceno c:n(2) f:zeno c:n(10,3) f:tcenn c:n(2) f:zenn c:n(10,3) f:d0k1 c:n(1) f:prz c:n(1) f:TtnPst c:c(40) f:DTtnPst c:d(10) f:nnasp c:c(40) f:nrn c:c(40)')
  sele 0
  use (flr) alias mkdoc

  flr='mkpr'+cMKeepr
  if (select('mkpr')#0)
    sele mkpr
    CLOSE
  endif

  erase (flr+".dbf")
  erase (flr+".cdx")
  crtt(flr, 'f:vo c:n(2) f:kgp c:n(7) f:kpl c:n(7) f:okpo c:n(10) f:ngp c:c(40) f:npl c:c(40) f:agp c:c(40) f:DocGuId c:c(36) f:sk c:n(3) f:ttn c:n(6) f:kop c:n(3) f:dttn c:d(10) f:MnTov c:n(7) f:MnTovT c:n(7)  f:bar c:n(13) f:ktl c:n(9) f:nat c:c(60)  f:zen c:n(10,3) f:zen_n_but c:n(10,3)  f:kvp c:n(11,3) f:apl c:c(40) f:kta c:n(3) f:ddc c:d(10) f:tdc c:c(8) f:nnz c:c(9) f:dcl c:n(15,3) f:mkid c:c(20) f:nmkid c:c(90) f:d0k1 c:n(1) f:TtnPst c:c(40) f:DTtnPst c:d(10) f:nnasp c:c(40) f:nrn c:c(40)')

  sele 0
  use (flr) alias mkpr

  flr='mktov'+cMKeepr
  if (select('mktov')#0)
    sele mkpr
    CLOSE
  endif

  erase (flr+".dbf")
  erase (flr+".cdx")
  crtt(flr, 'f:sk c:n(3) f:nsk c:c(30) f:MnTov c:n(7) f:MnTovT c:n(7) f:bar c:n(13) f:nat c:c(60) f:nei c:c(4) f:opt c:n(10,3) f:cenpr c:n(10,3) f:pr_n_but c:n(10,3)  f:upak c:n(10,3) f:osfo c:n(12,3) f:osfo_upak c:n(8) f:osv c:n(12,3) f:osv_upak c:n(8) f:dt c:d(10) f:tm c:c(8) f:dcl c:n(15,3) f:mkid c:c(20) f:nmkid c:c(90) f:osfos c:n(12,3) f:osn c:n(12,3) f:osf c:n(12,3) f:osfon c:n(12,3)')

  if (!EMPTY(lCrtt_Only))
    for i:=nMaxSelect to 250
      if (!EMPTY(ALIAS(i)))
        close (i)
      endif

    next

    return
  endif

  sele 0
  use (flr) alias mktov excl
  inde on str(sk, 3)+str(MnTov, 7) tag t1
  inde on str(sk, 3)+str(MnTovT, 7) tag t2
  sele 0
  use (PathDDr+'mkost')
  sele 0
  use (PathDDr+'mkpr') alias mkprd
  sele 0
  use  (PathDDr+'mkrs') alias mkrsd

  sele mkrsd
  go top
  while (!eof())
    vor=vo
    kgpr=kgp
    kplr=kpl
    skr=sk
    ttnr=ttn
    kopr=kop
    dttnr=dop
    MnTovr=MnTov
    if (gnEnt=21)
      If Skip_Sk_MnTov(skr,MnTovr)
        skip;        loop
      EndIf

      if (int(MnTovr/10000)=251.and.!(MnTovr=2510203.or.MnTovr=2510207.or.MnTovr=2510190.or.MnTovr=2510157))
        skip
        loop
      endif

    endif

    MnTovTr=MnTov
    zenr=zen
    kvpr=kvp
    ktar=kta
    if (fieldpos('DocGuId')#0)
      DocGuIdr=DocGuId
    else
      DocGuIdr=''
    endif

    sele ctov
    netseek('t1', 'MnTovr')
    barr=bar
    natr=nat
    Pr_Butr:= CenPr - IIF(EMPTY(c08), CenPr, c08)

    zen_n_butr=round((zenr-Pr_Butr), 3)

    sele kln
    netseek('t1', 'kplr')
    okpor=kkl1
    nplr=nkl
    aplr=adr
    netseek('t1', 'kgpr')
    ngpr=nkl
    agpr=adr

    sele mkdoc
    appe blank
    netrepl('vo,kgp,kpl,sk,ttn,kop,dttn,MnTov,MnTovT,zen,kvp,kta,bar,nat,zen_n_but,okpo,npl,apl,ngp,agp,DocGuId',                     ;
             {vor,kgpr,kplr,skr,ttnr,kopr,dttnr,MnTovr,MnTovTr,zenr,kvpr,ktar,barr,natr,zen_n_butr,okpor,nplr,aplr,ngpr,agpr,DocGuIdr} ;
         )
    knaspr=getfield('t1', 'kgpr', 'kln', 'knasp')
    nnaspr=getfield('t1', 'knaspr', 'knasp', 'nnasp')
    krnr=getfield('t1', 'kgpr', 'kln', 'krn')
    nrnr=getfield('t1', 'krnr', 'krn', 'nrn')
    sele mkdoc
    netrepl('nnasp,nrn', {nnaspr,nrnr})
    sele mkrsd
    skip
  enddo

  sele mkprd
  go top
  while (!eof())
    vor=vo
    kgpr=kzg
    kplr=kps
    skr=sk
    ttnr=mn
    kopr=kop
    dttnr=dpr
    MnTovr=MnTov
    if (fieldpos('TtnPst')#0)
      TtnPstr=TtnPst
      DTtnPstr=DTtnPst
    else
      TtnPstr=''
      DTtnPstr=ctod('')
    endif

    if (gnEnt=21)

      If Skip_Sk_MnTov(skr,MnTovr)
        skip;        loop
      EndIf

      if (int(MnTovr/10000)=251.and.!(MnTovr=2510203.or.MnTovr=2510207.or.MnTovr=2510190.or.MnTovr=2510157))
        skip
        loop
      endif

    else
      if (int(MnTovr/10000)<2)
        skip
        loop
      endif

    endif

    MnTovTr=MnTov
    zenr=zen
    kvpr=kf
    ktar=kta
    DocGuIdr=''
    if (fieldpos('DocGuId')#0)
      DocGuIdr=DocGuId
    endif

    sele ctov
    netseek('t1', 'MnTovr')
    barr=bar
    natr=nat
    Pr_Butr:= CenPr - IIF(EMPTY(c08), CenPr, c08)

    zen_n_butr=round((zenr-Pr_Butr), 3)

    sele kln
    netseek('t1', 'kplr')
    okpor=kkl1
    nplr=nkl
    aplr=adr
    netseek('t1', 'kgpr')
    ngpr=nkl
    agpr=adr

    sele mkpr
    appe blank
    netrepl('vo,kgp,kpl,sk,ttn,kop,dttn,MnTov,MnTovT,zen,kvp,kta,bar,nat,zen_n_but,okpo,npl,apl,ngp,agp,DocGuId,d0k1,TtnPst,DTtnPst',                    ;
             {vor,kgpr,kplr,skr,ttnr,kopr,dttnr,MnTovr,MnTovTr,zenr,kvpr,ktar,barr,natr,zen_n_butr,okpor,nplr,aplr,ngpr,agpr,DocGuIdr,1,TtnPstr,DTtnPstr} ;
         )

    knaspr=getfield('t1', 'kgpr', 'kln', 'knasp')
    nnaspr=getfield('t1', 'knaspr', 'knasp', 'nnasp')
    krnr=getfield('t1', 'kgpr', 'kln', 'krn')
    nrnr=getfield('t1', 'krnr', 'krn', 'nrn')
    sele mkpr
    netrepl('nnasp,nrn', {nnaspr,nrnr})

    sele mkprd
    skip
  enddo

  sele mkost
  go top
  while (!eof())
    skr=sk
    nskr=getfield('t1', 'skr', 'cskl', 'nskl')
    MnTovr=MnTov
    if (gnEnt=21)
      If Skip_Sk_MnTov(skr,MnTovr)
        skip;        loop
      EndIf

      if (int(MnTovr/10000)=251.and.!(MnTovr=2510203.or.MnTovr=2510207.or.MnTovr=2510190.or.MnTovr=2510157))
        skip
        loop
      endif

    else
      if (int(MnTovr/10000)<2)
        skip
        loop
      endif

    endif

    MnTovTr=MnTov
    osfonr=OsFoNd
    osfor=osfotd

    sele ctov
    ordsetfocus('t1')
    if netseek('t1', 'MnTovr')
      If empty(nat) // востановлнное наименование
        outlog(__FILE__,__LINE__,'ctov',MnTovr,'востановлнное наименование')
        ordsetfocus('t10')
        netseek('t10', 'MnTovr')
        locate for !empty(nat) while MnTov = MnTovr
        natr='(' + str(MnTovr,6) + ')' + allt(nat)
      else
        natr=nat
      EndIf
      //
    else
      outlog(__FILE__,__LINE__,'ctov',MnTovr,'!netseek')
      locate for MnTov=MnTovr
    endif

      barr=bar
      natr=nat
      neir=nei
      cenprr=cenpr
      upakr=upak
      Pr_N_Butr:=c08          //цена без бутылки

    sele mktov
    appe blank
    netrepl('sk,nsk,MnTov,MnTovT,osfon,osfo,bar,nat,nei,cenpr,upak,Pr_N_But,dt',             ;
             {skr,nskr,MnTovr,MnTovTr,osfonr,osfor,barr,natr,neir,cenprr,upakr,Pr_N_Butr,dtr} ;
         )

    sele mkost
    skip
  enddo

  sele mkost
  CLOSE
  sele mkprd
  CLOSE
  sele mkrsd
  CLOSE
  sele mkdoc
  CLOSE
  sele mkpr
  CLOSE
  sele mktov
  CLOSE
  nuse()
  return (.t.)

/**************** */
function crmkrs()
  /**************** */
  sele 0
  use (PathDDr+'mkrs') alias mkrso excl
  inde on str(sk, 3)+str(ttn, 7)+str(MnTov, 7) tag t1
  sele mkrs
  go top
  while (!eof())
    skr=sk
    ttnr=ttn
    MnTovr=MnTov
    arec:={}
    getrec()
    sele mkrso
    if (!netseek('t1', 'skr,ttnr,MnTovr'))
      netadd()
    endif

    putrec()
    sele mkrs
    skip
  enddo

  sele mkrso
  go top
  while (!eof())
    skr=sk
    ttnr=ttn
    MnTovr=MnTov
    if (!netseek('t1', 'skr,ttnr,MnTovr', 'mkrs'))
      netrepl('kvp', {0})
    endif

    sele mkrso
    skip
  enddo

  sele mkrso
  CLOSE
  return (.t.)

/************** */
function crmkpr()
  /************** */
  sele 0
  use (PathDDr+'mkpr') alias mkpro excl
  inde on str(sk, 3)+str(mn, 7)+str(MnTov, 7) tag t1
  sele mkpr
  go top
  while (!eof())
    skr=sk
    mnr=mn
    MnTovr=MnTov
    arec:={}
    getrec()
    sele mkpro
    if (!netseek('t1', 'skr,mnr,MnTovr'))
      netadd()
    endif

    putrec()
    sele mkpr
    skip
  enddo

  sele mkpro
  go top
  while (!eof())
    skr=sk
    mnr=mn
    MnTovr=MnTov
    if (!netseek('t1', 'skr,mnr,MnTovr', 'mkpr'))
      netrepl('kf', {0})
    endif

    sele mkpro
    skip
  enddo

  sele mkpro
  CLOSE
  return (.t.)

/*************** */
function crjost()
  /*************** */
  clea
  set prin to crjost.txt
  set prin on
  netuse('ctov')
  mkeepr=0
  scdt_r=setcolor('gr+/b,n/w')
  wdt_r=wopen(8, 20, 13, 60)
  wbox(1)
  @ 1, 1 say 'Маркодерж' get mkeepr pict '999'
  read
  wclose(wdt_r)
  setcolor(scdt_r)
  if (lastkey()=27)
    return (.t.)
  endif

  clea

  cMKeepr:=padl(ltrim(str(mkeepr, 3)), 3, '0')

  pathostr=gcPath_ew+'ost\'
  pathmkr=pathostr+'mk'+cMKeepr+'\'

  for yyr=2014 to year(date())
    pathyyr=pathmkr+'g'+str(yyr, 4)+'\'
    for mmr=1 to 12
      pathmmr=pathyyr+'m'+iif(mmr<10, '0'+str(mmr, 1), str(mmr, 2))+'\'
      if (file(pathmmr+'svost.dbf'))
        sele 0
        use (pathmmr+'svost.dbf') excl
        set orde to tag t1
        go top
        while (!eof())
          skr=sk
          MnTovr=MnTov
          mkeep_r=getfield('t1', 'MnTovr', 'ctov', 'mkeep')
          if (mkeep_r#mkeepr)
            ?pathmmr+' '+str(skr, 3)+' '+str(MnTovr, 7)+' SVOST DEL'
            dele
          endif

          sele svost
          skip
        enddo

        for ddr=1 to 31
          PathDDr=pathmmr+'d'+iif(ddr<10, '0'+str(ddr, 1), str(ddr, 2))+'\'
          if (file(PathDDr+'mkost.dbf'))
            sele 0
            use (PathDDr+'mkost.dbf') excl
            while (!eof())
              skr=sk
              MnTovr=MnTov
              sele svost
              seek str(skr, 3)+str(MnTovr, 7)
              if (!found())
                ?PathDDr+' '+str(skr, 3)+' '+str(MnTovr, 7)+' MKOST DEL'
                sele mkost
                dele
              endif

              sele mkost
              skip
            enddo

            sele mkost
            CLOSE
          endif

          if (file(PathDDr+'mkpr.dbf'))
            sele 0
            use (PathDDr+'mkpr.dbf') excl
            while (!eof())
              skr=sk
              mnr=mn
              MnTovr=MnTov
              sele svost
              seek str(skr, 3)+str(MnTovr, 7)
              if (!found())
                ?PathDDr+' '+str(skr, 3)+' '+str(mnr, 6)+' '+str(MnTovr, 7)+' MKPR DEL'
                sele mkpr
                dele
              endif

              sele mkpr
              skip
            enddo

            sele mkpr
            CLOSE
          endif

          if (file(PathDDr+'mkrs.dbf'))
            sele 0
            use (PathDDr+'mkrs.dbf') excl
            while (!eof())
              skr=sk
              ttnr=ttn
              MnTovr=MnTov
              sele svost
              seek str(skr, 3)+str(MnTovr, 7)
              if (!found())
                ?PathDDr+' '+str(skr, 3)+' '+str(ttnr, 6)+' '+str(MnTovr, 7)+' MKRS DEL'
                sele mkrs
                dele
              endif

              sele mkrs
              skip
            enddo

            sele mkrs
            CLOSE
          endif

        next

        sele svost
        CLOSE
      endif

    next

  next

  nuse()
  set prin off
  set prin to
  return (.t.)





/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  07-05-17 * 08:45:39pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
function PathOstDD(cMKeepr, dtr)
  DirOstr=gcPath_ew+'ost'
  DirMkr=gcPath_ew+'ost\mk'+cMKeepr
  DirYYr=DirMkr+'\g'+str(year(dtr), 4)
  DirMMr=DirYYr+'\m'+iif(month(dtr)<10, '0'+str(month(dtr), 1), str(month(dtr), 2))
  PathDDr=DirMMr+'\d'+iif(day(dtr)<10, '0'+str(day(dtr), 1), str(day(dtr), 2))+'\'
  return (PathDDr)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  04-09-18 * 09:08:28pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION Skip_Sk_MnTov(skr,MnTovr)
  LOCAL lskip:=.f.
  Do Case
  Case skr=263 .and. (int(MnTovr/10000)<=1) // тара и стелотара
    lskip:=.T.
  Case (int(MnTovr/10000)=1) //стелотара
    // lskip:=.T. //05-25-18 10:17am Вкл.
  EndCase
  RETURN (lskip)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  08-04-18 * 09:10:51am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION CorrectKop211()
  sele mkost
  go top
  while (!eof())
    skr=sk
    MnTovr=MnTov
    OsFoNdr=OsFoNd      // прошлый день
    zenr=getfield('t1', 'MnTovr', 'ctov', 'opt')

    If Skip_Sk_MnTov(skr,MnTovr)
      skip;        loop
    EndIf


    sele OsFoNd // расчетный остаток чз начало месяца
    seek str(skr, 3)+str(MnTovr, 7)
    OsFoNdFr=0
    if (found())
      OsFoNdFr=OsFoNd
      if (OsFoNdFr#OsFoNdr)

        // разница
        kfr=OsFoNdFr-OsFoNdr

        if (&cMnr=0) // получим номер документа
          sele cskl
          if (netseek('t1', 'skr'))
            reclock()
            &cMnr=mn
            netrepl('mn', {mn+1})
          endif

        endif

        sele mkprc
        seek str(&cMnr, 6)+str(MnTovr, 7)
        if (!found())
          appe blank
          repl sk with skr,   ;
            mn with &cMnr,     ;
            nd with &cMnr,     ;
            kop with 211,      ;
            dpr with dtr,      ;
            vo with 6,         ;
            kps with gnKKL_c,  ;
            kzg with gnKKL_c,  ;
            MnTov with MnTovr, ;
            zen with zenr
        endif

        repl kf with kf+kfr
        sele mkost
        repl pr with pr+kfr
      endif

    endif

    sele mkost
    repl OsFoNdF with OsFoNdFr
    skip
  enddo
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  08-04-18 * 01:15:47pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION SaveRecRsUpdate(Rs1,Rs2,MnTovr,skr)
  If .F. .AND. dtr=bom(dtr) .AND. SELECT(rs1)#0
    // строки измения остатка
    sele (rs1)
    copy to tmp_rs1 next 1
    sele mkrso
    append from tmp_rs1
    repl MnTov with MnTovr, kvp with (rs2)->kvp, sk with skr,;
    zen with iif(dopr<dtr,1,-1)
  EndIf
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  08-04-18 * 10:45:44pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION SaveRecPrUpdate(Pr1,Pr2,MnTovr,skr)
  // строки измения остатка
  If .F. .AND. dtr=bom(dtr) .and. SELECT(pr1)#0
    sele (pr1)
    copy to tmp_pr1 next 1
    sele mkpro
    append from tmp_pr1
    repl MnTov with MnTovr, kf with (pr2)->kf, sk with skr
  EndIf
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  08-05-18 * 09:32:49am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION TtnDeCodeN()
  LOCAL lSkip:=.F., nKolPos
  nKolPos:=rs1->KolPos

  Do Case
  Case (str(rs1->pr129,1)$'2;3')
    DeCodeTtnN(rs1->ttn, nKolPos, path129r)
    lSkip:=.T.
  Case (str(rs1->pr139,1)$'2;3')
    DeCodeTtnN(rs1->ttn, nKolPos, path139r)
    lSkip:=.T.
  Case (str(rs1->pr169,1)$'2;3')
    DeCodeTtnN(rs1->ttn, nKolPos, path169r)
    // dc 169n(rs1->ttn)
    lSkip:=.T.
  Case  (str(rs1->pr177,1)$'2;3')
    DeCodeTtnN(rs1->ttn, nKolPos, path177r)
    // d c177n(rs1->ttn)
    lSkip:=.T.
  case (gnEnt=21.and.ttnt=999999)
    DeCodeTtnN(rs1->ttn, nKolPos, path151r)
    // dc 151n(rs1->ttn)
    lSkip:=.T.
  EndCase
  RETURN (lSkip)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  08-05-18 * 11:03:50am
 НАЗНАЧЕНИЕ......... разворот свернутых ТТН
 ПАРАМЕТРЫ.......... nKolPos - может быть пустым, тк удалили.
    те расшифровки не нужно
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC function DeCodeTtnN(nTtn, nKolPos, cPath)
  ttn_r=nTtn //p1
  pathr=cPath + 't'+alltrim(str(ttn_r, 6))+'\'
  if (netfile('rs1', 1) .and.  !EMPTY(nKolPos))
    netuse('rs1', 'rs1_177',, 1)
    netuse('rs2', 'rs2_177',, 1)
    sele rs1_177
    go top
    while (!eof())
      dopr=iif(empty(dop),dot,dop) //dop
      if (dopr > dtr  .or. empty(dopr))
        skip
        loop
      endif

      ttnr=ttn
      sele rs2_177
      if (netseek('t1', 'ttnr'))
        while (ttn=ttnr)
          ktlr=ktl
          Otvr=getfield('t1', 'sklr,ktlr', 'tov', 'otv')
          if (Otvr=1)
            sele rs2_177
            skip
            loop
          endif

          MnTovr=MnTov
          if (gnEnt=21)
            if (int(MnTovr/10000)=1)
              skip
              loop
            endif

          else
            if (int(MnTovr/10000)<2)
              skip
              loop
            endif

          endif

          MnTovTr=getfield('t1', 'MnTovr', 'ctov', 'MnTovT')
          if (!empty(MnTovTr))
            MnTovr=MnTovTr
          endif

          kvpr=kvp
          sele OsFoNd
          seek str(skr, 3)+str(MnTovr, 7)
          if (found())
            SaveRecRsUpdate('rs1_177','rs2_177',MnTovr,skr)
            sele OsFoNd
            if (dopr<dtr)
              repl OsFoNd with OsFoNd-kvpr, ;
               osfokd with osfokd-kvpr
            else
              repl osfokd with osfokd-kvpr
            endif

          endif

          sele rs2_177
          skip
        enddo

      endif

      sele rs1_177
      skip
    enddo

    nuse('rs1_177')
    nuse('rs2_177')
  endif

  return (.t.)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  08-05-18 * 11:25:38am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC function TtnDecode()
  LOCAL lSkip:=.F., nKolPos
  nKolPos:=rs1->KolPos

  Do Case
  Case (str(rs1->pr129,1)$'2;3')
    DeCodeTtn(rs1->ttn, nKolPos, path129r)
    lSkip:=.T.
  Case (str(rs1->pr139,1)$'2;3')
    DeCodeTtn(rs1->ttn, nKolPos, path139r)
    lSkip:=.T.
  Case (str(rs1->pr169,1)$'2;3')
    //dc169(rs1->ttn)
    DeCodeTtn(rs1->ttn, nKolPos, path169r)
    // dc169n(rs1->ttn)
    lSkip:=.T.
  Case  (str(rs1->pr177,1)$'2;3')
    //dc177(rs1->ttn)
    DeCodeTtn(rs1->ttn, nKolPos, path177r)
    // dc177n(rs1->ttn)
    lSkip:=.T.
  case (gnEnt=21.and.ttnt=999999)
    //dc151(rs1->ttn)
    DeCodeTtn(rs1->ttn, nKolPos, path151r)
    // dc151n(rs1->ttn)
    lSkip:=.T.
  EndCase
  RETURN (lSkip)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  08-05-18 * 11:34:09am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC function DeCodeTtn(nTtn, nKolPos, cPath)
  ttn_r=nTtn //p1
  pathr=cPath +'t'+alltrim(str(ttn_r, 6))+'\' //  pathr=path177r+'t'+alltrim(str(ttn_r, 6))+'\'
  if (netfile('rs1', 1) .and.  !EMPTY(nKolPos))
    netuse('rs1', 'rs1_177',, 1)
    netuse('rs2', 'rs2_177',, 1)
    sele rs1_177
    go top
    while (!eof())
      dopr=iif(empty(dop),dot,dop) // dop
      if (dopr#dtr)
        skip
        loop
      endif

      sklr=skl
      dtotr=dtot
      ttnr=ttn
      vor=vo
      kopr=kop
      ktar=kta
      DocGuIdr=DocGuId
      sele rs1_177
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
        if (nkkl#0)
          kplr=nkkl
        else
          kplr=kpl
        endif

        if (kpv#0)
          kgpr=kpv
        else
          kgpr=kgp
        endif

      endif

      sele rs2_177
      if (netseek('t1', 'ttnr'))
        while (ttn=ttnr)
          ktlr=ktl
          Otvr=getfield('t1', 'sklr,ktlr', 'tov', 'otv')
          if (Otvr=1)
            sele rs2_177
            skip
            loop
          endif

          MnTovr=MnTov
          if (gnEnt=21)
            if (int(MnTovr/10000)=1)
              skip
              loop
            endif

          else
            if (int(MnTovr/10000)<2)
              skip
              loop
            endif

          endif

          MnTovTr=getfield('t1', 'MnTovr', 'ctov', 'MnTovT')
          if (!empty(MnTovTr))
            MnTovr=MnTovTr
          endif

          sele mkost
          if (!netseek('t1', 'skr,MnTovr'))
            sele rs2_177
            skip
            loop
          endif

          sele rs2_177
          kvpr=kvp
          zenr=zen
          sele mkrs
          if (!netseek('t1', 'skr,ttnr,MnTovr'))
            netadd()
            netrepl('sk,dop,ttn,vo,kop,kpl,kgp,kta,MnTov,zen,DocGuId',           ;
                     {skr,dopr,ttnr,vor,kopr,kplr,kgpr,ktar,MnTovr,zenr,DocGuIdr} ;
                 )
          endif

          netrepl('kvp', {kvp+kvpr})
          sele mkost
          repl rs with rs+kvpr
          sele rs2_177
          skip
        enddo

      endif

      sele rs1_177
      skip
    enddo

    nuse('rs1_177')
    nuse('rs2_177')
  endif

  return (.t.)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  08-06-18 * 11:30:50pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION OsFoNd2MkOst()

  // перенос с mkost
  sele OsFoNd
  go top
  while (!eof())
    skr=sk
    MnTovr=MnTov
    if (gnEnt=21)
      If Skip_Sk_MnTov(skr,MnTovr)
        skip;        loop
      EndIf

    else
      if (int(MnTovr/10000)<2)
        skip
        loop
      endif

    endif

    OsFoNdr=OsFoNd
    sele mkost
    seek str(skr, 3)+str(MnTovr, 7)
    if (!found())
      appe blank
      repl sk with skr, MnTov with MnTovr
    endif

    repl OsFoNd  with OsFoNdr, ;
         OsFoNdF with OsFoNdr
    sele OsFoNd
    skip
  enddo
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  08-06-18 * 11:59:51pm
 НАЗНАЧЕНИЕ......... заполнеие  mkost  СКЛАД и ТОВАР
 из сводной таблицы остатков
 ПАРАМЕТРЫ.......... pOstr - ссылка на поле откуда брать остатки
 если пусто, то не заполняем
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION SvOst2MkOst(pOstr,dtr)
  sele svost
  go top
  while (!eof())
    skr=sk
    If BOM(dtr-1) # BOM(dtr) // переход с месяца на месяц
      If svost->(FieldGet(pOstr)) = 0
        skip;        loop
      EndIf
    EndIf
    /*
    cMnr='mn'+str(skr, 3)+'r'
    &cMnr=0
    */
    MnTovr=MnTov
    if (gnEnt=21)
      If Skip_Sk_MnTov(skr,MnTovr)
        skip;        loop
      EndIf

    else
      if (int(MnTovr/10000)<2)
        skip;        loop
      endif

    endif

    //ostr:=FieldGet(pOstr) //&cOstr
    sele mkost
    appe blank
    repl sk with skr,          MnTov with MnTovr
    If !EMPTY(pOstr)
      repl OsFoNd with svost->(FieldGet(pOstr))
    EndIf
    sele svost
    skip
  enddo
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  08-07-18 * 02:58:46pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION Skip4Dop(dtr)
  LOCAL lSkip:=.F.
  Do Case
  Case empty(dop) // пуста дата Отрг
    If dot # dtr // анализируем Дату Потв
      lSkip:=.T.
    EndIf
  Case (dop#dtr)
    lSkip:=.T.
  EndCase
  RETURN (lSkip)
