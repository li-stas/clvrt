#include "common.ch"
#include "inkey.ch"
* Текущие Цены
if ctov_r#1
   retu
endif

clea
aqstr=1
aqst:={"Просмотр","Коррекция"}
aqstr:=alert(" ",aqst)

if lastkey()=K_ESC
   retu
endif

pathr=path_tr
netuse('tov',,,1)
netuse('tovm',,,1)
netuse('ctov')
netuse('tcen')

set prin to scen.txt
set prin on

?' TOV '
sele tov
go top
do while !eof()
   sklr=skl
   natr=subs(nat,1,30)
   ktlr=ktl
   sklr=skl
   mntovr=mntov
   prktl_r=0
   sele ctov
   netseek('t1','mntovr')
   if foun()
      mntovtr=mntovt
      mntovcr=mntovc
      sele tcen
      go top
      do while !eof()
         sele tcen
         if ent#gnEnt //.or.alltrim(zen)='opt'
            sele tcen
            skip
            loop
         endif
         czenr=zen
         tt=alltrim(zen)+'r'
         tt1=alltrim(zen)
         sele ctov
         &tt=&tt1
         sele tov
         if &tt1#&tt
            if prktl_r=0
               ?str(sklr,7)+' '+str(ktlr,9)+' '+natr
               prktl_r=1
            endif
            ?czenr+' CTOV '+str(&tt,10,3)+' TOV '+str(&tt1,10,3)
            if aqstr=2
               sele tov
               netrepl(tt1,tt)
            endif
         else
*            ?str(sklr,7)+' '+str(ktlr,9)+' '+natr+' Ok'
         endif
         sele tovm
         if netseek('t1','sklr,mntovr')
            if aqstr=2
               netrepl(tt1,tt)
            endif
         endif
         sele tcen
         skip
      endd
      sele tov
      if mntovt#mntovtr.or.mntovc#mntovcr
         netrepl('mntovt,mntovc','mntovtr,mntovcr')
         ?'TOV '+str(ktlr,9)+' '+'родители'
      endif
      sele tovm
      if netseek('t1','sklr,mntovr')
         if mntovt#mntovtr.or.mntovc#mntovcr
            netrepl('mntovt,mntovc','mntovtr,mntovcr')
            ?'TOVM '+str(mntovr,7)+' '+'родители'
         endif
      endif
   endif
   sele tov
   skip
endd
nuse()
set prin off
set prin to
if gnOut=2
   set prin to txt.txt
endif
wmess('Проверка закончена',0)

func cortm()
* Коррекция tmesto,ktas,kta
clea
netuse('tmesto')
netuse('rs1')
netuse('pr1')
netuse('pr2')
netuse('rs2')
netuse('soper')
netuse('stagm')
netuse('s_tag')
netuse('cskl')
netuse('ctov')
vur=1
d0k1r=0
sele rs1
do while !eof()
   vor=vo
   kopr=mod(kop,100)
   pr361r=pr361(d0k1r,vur,vor,kopr)
   if pr361r=0
      sele rs1
      skip
      loop
   endif
   ktar=kta
   if ktar=0
      skip
      loop
   endif
   ktasr=ktas
   ttnr=ttn
   if ktasr=0
      cktasr=schkktas(d0k1r,gnSk,ttnr)
      ktas_r=val(subs(cktasr,1,4))
      kta_r=val(subs(cktasr,5,4))
      if ktasr#ktas_r.or.ktar#kta_r
         sele rs1
         ?str(ttn,6)+' '+str(kop,3)+' '+str(kta,4)+' -> '+str(kta_r,4)+' '+str(ktas,4)+' -> '+str(ktas_r,4)
         netrepl('kta,ktas','kta_r,ktas_r')
         ktasr=ktas_r
         ktar=kta_r
      endif
   endif
   nkklr=nkkl
   kpvr=kpv
   tmestor=getfield('t2','nkklr,kpvr','tmesto','tmesto')
   if tmestor#0.and.rs1->tmesto#tmestor
      sele rs1
      ?str(ttn,6)+' '+str(kta,4)+' '+str(tmesto,7)+' -> '+str(tmestor,7)
      netrepl('tmesto','tmestor')
   endif
   sele rs1
   skip
endd
d0k1r=1
sele pr1
do while !eof()
   vor=vo
   kopr=mod(kop,100)
   pr361r=pr361(d0k1r,vur,vor,kopr)
   if pr361r=0
      sele rs1
      skip
      loop
   endif
   ktar=kta
   if ktar=0
      sele pr1
      skip
      loop
   endif
   mnr=mn
   ktasr=ktas
   if ktasr=0
      cktasr=schkktas(d0k1r,gnSk,mnr)
      ktas_r=val(subs(cktasr,1,4))
      kta_r=val(subs(cktasr,5,4))
      if ktasr#ktas_r.or.ktar#kta_r
         sele pr1
         ?str(nd,6)+' '+str(mn,6)+' '+str(kop,3)+' '+str(kta,4)+' -> '+str(kta_r,4)+' '+str(ktas,4)+' -> '+str(ktas_r,4)
         netrepl('kta,ktas','kta_r,ktas_r')
         ktasr=ktas_r
         ktar=kta_r
      endif
   endif
   sele pr1
   skip
endd
nuse()
retu .t.
**************
func md361()
**************
clea
set prin to md361.txt
set prin on
netuse('speng')
netuse('moddoc')
for_r='.t.'
forr=for_r
sele moddoc
set orde to tag t1
go top
rcmoddocr=recn()
fldnomr=1
do while .t.
   sele moddoc
   go rcmoddocr
   foot('F3,F4','Фильтр,Корр przp')
   if fieldpos('dtmodvz')=0
      rcmoddocr=slce('moddoc',1,1,18,,"e:mn h:'MN' c:n(6) e:rnd h:'RND' c:n(6) e:rn h:'RN' c:n(6) e:mnp h:'MNP' c:n(6) e:sk h:'SK' c:n(3) e:dtmod h:'Дата' c:d(10) e:tmmod h:'Время' c:c(8) e:subs(dtos(prd),3,4) h:'PRD' c:c(4) e:fld h:'Операция' c:c(10) e:przp h:'П' c:n(1) e:kto h:'KTO' c:n(4) e:getfield('t1','moddoc->kto','speng','fio') h:'ФИО' c:c(15)",,,1,,forr,,'Модифицированные документы')
   else
      rcmoddocr=slce('moddoc',1,1,18,,"e:mn h:'MN' c:n(6) e:rnd h:'RND' c:n(6) e:rn h:'RN' c:n(6) e:mnp h:'MNP' c:n(6) e:sk h:'SK' c:n(3) e:dtmod h:'Дата' c:d(10) e:tmmod h:'Время' c:c(8) e:subs(dtos(prd),3,4) h:'PRD' c:c(4) e:fld h:'Операция' c:c(10) e:przp h:'П' c:n(1) e:kto h:'KTO' c:n(4) e:getfield('t1','moddoc->kto','speng','fio') h:'ФИО' c:c(15) e:dtmodvz h:'ДатаВ' c:d(10) e:tmmodvz h:'ВремяВ' c:c(8)",,,1,,forr,,'Модифицированные документы')
   endif
   if lastkey()=K_ESC
      exit
   endif
   sele moddoc
   go rcmoddocr
   mnr=mn
   rndr=rnd
   rnr=rn
   skr=sk
   mnpr=mnp
   przpr=przp
   prdr=prd
   do case
      case lastkey()=19 // Left
           fldnomr=fldnomr-1
           if fldnomr=0
              fldnomr=1
           endif
      case lastkey()=4 // Right
           fldnomr=fldnomr+1
      case lastkey()=K_F2.and.gnAdm=1
           sele moddoc
           go top
           do while !eof()
              if empty(fld)
                 netdel()
              endif
              sele moddoc
              skip
           enddo
           sele moddoc
           go top
           rcmoddocr=recn()
      case lastkey()=K_F3
           cldokk=setcolor('gr+/b,n/w')
           wdokk=wopen(10,20,14,60)
           wbox(1)
           store date() to dtr
           store 0 to bhskr,ntprdr
           @ 0,1 say 'Дата модиф>= '  get dtr
           @ 1,1 say 'Бух-Ск       '  get bhskr pict '9'
           @ 2,1 say 'Не тек период'  get ntprdr pict '9'
           read
           wclose('wdokk')
           setcolor('cldokk')
           if lastkey()=K_ENTER
              if !empty(dtr)
                 forr=for_r+'.and.dtmod>=dtr'
              else
                 forr=for_r
              endif
              do case
                 case bhskr=0
                      forr=forr
                 case bhskr=1
                      forr=forr+'.and.mn=0'
                 case bhskr=2
                      forr=forr+'.and.mn#0'
              endc
              if ntprdr=1
                 forr=for_r+'.and.prd<bom(date())'
              endif
              sele moddoc
              go top
              rcmoddocr=recn()
           endif
*      case lastkey()=7.and.gnAdm=1. // DEL
*           netdel()
*           skip -1
*           if bof()
*              go top
*           endif
*           rcmoddocr=recn()
      case lastkey()=K_F4 // Коррекция
           crmd361()
   endc
endd
nuse()
set prin off
set prin to
retu .t.

***************
func crmd361()
***************
if gnArm=0
   set prin to md361.txt
   set prin on
   netuse('moddoc')
endif
crtt('tprd','f:prd c:d(10)')
sele 0
use tprd
sele moddoc
set orde to tag t1
do while mn=0
   prdr=prd
   sele tprd
   locate for prd=prdr
   if !foun()
      appe blank
      repl prd with prdr
   endif
   sele moddoc
   skip
endd
sele moddoc
go top
do while mn=0
   mnr=mn
   rndr=rnd
   rnr=rn
   skr=sk
   mnpr=mnp
   przpr=przp
   przp_rr=przp
   prdr=prd
   cyyr=str(year(prdr),4)
   cmmr=iif(month(prdr)<10,'0'+str(month(prdr),1),str(month(prdr),2))
   pathr=gcPath_e+'g'+cyyr+'\m'+cmmr+'\bank\'
   cpalsr='p'+cyyr+cmmr
   coalsr='o'+cyyr+cmmr
   if select(cpalsr)=0
      netuse('dokk',cpalsr,,1)
      netuse('dokko',coalsr,,1)
   endif
   przp_r=9
   if przpr=1
      sele (cpalsr)
      if !netseek('t12','mnr,rndr,skr,rnr,mnpr')
         sele (coalsr)
         if netseek('t12','mnr,rndr,skr,rnr,mnpr')
            przp_r=0
         endif
      endif
   else
      sele (coalsr)
      if !netseek('t12','mnr,rndr,skr,rnr,mnpr')
         sele (cpalsr)
         if netseek('t12','mnr,rndr,skr,rnr,mnpr')
            przp_r=1
         endif
      endif
   endif
   if przp_r#9
      przpr=przp_r
   endif
   sele moddoc
   if przp_rr#przpr
      ?str(mnr,6)+' '+str(rndr,6)+' '+str(skr,3)+' '+str(rnr,6)+' '+str(mnpr,6)+' '+dtoc(prdr)+' '+str(przp_rr,1)+'->'+str(przpr,1)
      netrepl('przp','przpr')
   endif
   skip
endd
sele tprd
go top
do while !eof()
   prdr=prd
   cyyr=str(year(prdr),4)
   cmmr=iif(month(prdr)<10,'0'+str(month(prdr),1),str(month(prdr),2))
   cpalsr='p'+cyyr+cmmr
   coalsr='o'+cyyr+cmmr
   if select(cpalsr)#0
      nuse(cpalsr)
   endif
   if select(coalsr)#0
      nuse(coalsr)
   endif
   sele tprd
   skip
endd
use
erase tprd.dbf
if gnArm=0
   set prin to md361.txt
   set prin on
   nuse('moddoc')
else
   sele moddoc
   go rcmoddocr
endif
retu .t.


**************
func mdglkn()
**************
clea
netuse('cskl')
netuse('speng')
cldokk=setcolor('gr+/b,n/w')
wdokk=wopen(10,20,15,60)
wbox(1)
store gdTd to dtr
store 0 to bsr,prdocr
store time() to tmr
do while .t.
   @ 0,1 say 'Дата печ гл книги' get dtr
   @ 1,1 say 'Вр   печ гл книги' get tmr
   @ 2,1 say '0-Все;1-Под;2-НеП' get prdocr
   @ 3,1 say 'Счет             ' get bsr pict '999999'
   read
   if lastkey()=K_ESC
      wclose('wdokk')
      setcolor('cldokk')
      nuse()
      retu .t.
   endif
   if lastkey()=K_ENTER
      exit
   endif
endd
wclose('wdokk')
setcolor('cldokk')
forr='dtmod>=dtr.and.iif(dtmod=dtr,tmmod>=tmr,.t.)'
do case
   case prdocr=1
        forr=forr+'.and.prz=1'
   case prdocr=2
        forr=forr+'.and.prz=0'
endc
crtt('tmoddoc','f:sk c:n(3) f:d0k1 c:n(1) f:doc c:n(6) f:mn c:n(6) f:vo c:n(2) f:kop c:n(3) f:dtmod c:d(10) f:tmmod c:c(8) f:rmsk c:n(1)')
sele 0
use tmoddoc excl
inde on str(sk,3)+str(doc,6) tag t1
sele cskl
do while !eof()
   if ent#gnEnt
      skip
      loop
   endif
   skr=sk
   pathr=gcPath_d+alltrim(path)
   if !netfile('tov',1)
      skip
      loop
   endif
   mess(pathr)
   netuse('soper',,,1)
   netuse('pr1',,,1)
   netuse('rs1',,,1)
   sele pr1
   do while !eof()
      if !&(forr)
         skip
         loop
      endif
      d0k1r=1
      vur=1
      vor=vo
      kop_rr=kop
      rmskr=rmsk
      if bsr#0
         kopr=mod(kop,100)
         if !prskbs(bsr,d0k1r,vur,vor,kopr)
            sele pr1
            skip
            loop
         endif
      endif
      docr=nd
      mnr=mn
      dtmodr=dtmod
      tmmodr=tmmod
      sele tmoddoc
      appe blank
      repl sk with skr,;
           doc with docr,;
           mn with mnr,;
           dtmod with dtmodr,;
           tmmod with tmmodr,;
           vo with vor,;
           kop with kop_rr,;
           d0k1 with d0k1r,;
           rmsk with rmskr
      sele pr1
      skip
   endd
   sele rs1
   do while !eof()
      if !&(forr)
         skip
         loop
      endif
      d0k1r=0
      vur=1
      vor=vo
      kop_rr=kop
      rmskr=rmsk
      if bsr#0
         kopr=mod(kop,100)
         if !prskbs(bsr,d0k1r,vur,vor,kopr)
            sele rs1
            skip
            loop
         endif
      endif
      docr=ttn
      mnr=ttn
      dtmodr=dtmod
      tmmodr=tmmod
      sele tmoddoc
      appe blank
      repl sk with skr,;
           doc with docr,;
           mn with mnr,;
           dtmod with dtmodr,;
           tmmod with tmmodr,;
           vo with vor,;
           kop with kop_rr,;
           d0k1 with d0k1r,;
           rmsk with rmskr
      sele rs1
      skip
   endd
   nuse('soper')
   nuse('pr1')
   nuse('rs1')
   sele cskl
   skip
endd
clea
sele tmoddoc
go top
rcmoddocr=slcf('tmoddoc',,,,,"e:sk h:'СКЛ' c:n(3) e:d0k1 h:'Т' c:n(1) e:doc h:'Док' c:n(6) e:mn h:'MN' c:n(6) e:vo h:'VO' c:n(2) e:kop h:'КОП' c:n(3) e:dtmod h:'Дата' c:d(10) e:tmmod h:'Время' c:c(8) e:rmsk h:'RM' c:n(1)",,,,,,,,'Модифицированные документы')

nuse()
sele tmoddoc
use
retu .t.
**************
func dvid()
**************
if gnAdm#1
   retu .t.
endif
clea
crtt('dvid','f:docguid c:c(36) f:ttn c:n(6) f:ddc c:d(10) f:sdv c:n(12,2) f:cnt c:n(1)')
sele 0
use dvid excl
inde on docguid tag t1
set prin to dvid.txt
set prin on
docguid_r=''
netuse('cskl')
if gnRmsk=0
   forr='ent=gnEnt.and.rasc=1.and.rm=0'
else
   forr='ent=gnEnt.and.rasc=1.and.rm=1'
endif
sele cskl
go top
do while !eof()
   if !&(forr)
      skip
      loop
   endif
   pathtr=gcPath_d+alltrim(path)
   dtpr=addmonth(gdTd,-1)
   pathpr=gcPath_e+'g'+str(year(dtpr),4)+'\m'+padl(alltrim(str(month(dtpr),2)),2,0)+'\'+alltrim(path)
   pathr=pathtr
   if !netfile('rs1',1)
      sele cskl
      skip
      loop
   endif
   pathr=pathpr
   if !netfile('rs1',1)
      sele cskl
      skip
      loop
   endif
   pathr=pathtr
   mess(pathr)
   netuse('rs1',,,1)
   netuse('rs2',,,1)
   netuse('rs3',,,1)
   pathr=pathpr
   netuse('rs1','rs1p',,1)
   sele rs1
   go top
   do while !eof()
      if empty(docguid)
         skip
         loop
      endif
      docguidr=docguid
      ddcr=ddc
      ttnr=ttn
      sele rs1p
      if netseek('t2','docguidr')
         ddc_r=ddc
         if ddc_r=ddcr.and..f. // RECALL
            sele rs2
            if !netseek('t1','ttnr')
               prrs2r=0
               ?docguidr+' '+str(rs1p->ttn,6)+' '+dtoc(rs1p->ddc)+' '+str(rs1->ttn,6)+' '+dtoc(rs1->ddc)
               sele rs1
               ttnr=ttn
               set dele off
               sele rs3
               if netseek('t1','ttnr')
                  do while ttn=ttnr
                     reclock()
                     recall
                     netunlock()
                     sele rs3
                     skip
                  endd
               endif
               sele rs2
               if netseek('t1','ttnr')
                  do while ttn=ttnr
                     reclock()
                     recall
                     netunlock()
                     prrs2r=1
                     sele rs2
                     skip
                  endd
               endif
               if prrs2r=1
                  ??' RECALL'
               endif
               set dele on
            endif
         else
            prrs2r=0
            ?docguidr+' '+str(rs1p->ttn,6)+' '+dtoc(rs1p->ddc)+' '+str(rs1->ttn,6)+' '+dtoc(rs1->ddc)
            sele rs1
            ttnr=ttn
            sele rs3
            if netseek('t1','ttnr')
               do while ttn=ttnr
                  netdel()
                  sele rs3
                  skip
               endd
            endif
            sele rs2
            if netseek('t1','ttnr')
               do while ttn=ttnr
                  netdel()
                  prrs2r=1
                  sele rs2
                  skip
               endd
            endif
            if prrs2r=1
               ??' DEL'
            endif
         endif
      endif

      sele rs1
      skip
   endd
   sele rs1
   set orde to tag t2
   go top
   do while !eof()
      if empty(docguid)
         skip
         loop
      endif
      docguidr=docguid
      ttnr=ttn
      ddcr=ddc
      sdvr=sdv
      sele dvid
      seek docguidr
      if !foun()
         appe blank
         repl docguid with docguidr,;
              ttn with ttnr,;
              ddc with ddcr,;
              sdv with sdvr
      else
         repl cnt with 1
         appe blank
         repl docguid with docguidr,;
              ttn with ttnr,;
              ddc with ddcr,;
              sdv with sdvr,;
              cnt with 1
      endif
      rcrs1r=recn()
      sele rs1
      skip
   endd
   sele dvid
   dele all for cnt=0
   pack
   nuse('rs1')
   nuse('rs2')
   nuse('rs3')
   nuse('rs1p')
   sele cskl
   skip
endd
nuse('')
nuse('dvid')
wmess('Проверка закончена',0)
set prin off
set prin to txt.txt
retu .t.
