* Передача на удаленный склад
if gnArm#0
   clea
endif
vsvbr=1
if gnArm#0
   if gnAdm=1
      avsvb:={"Все","Выборочно"}
      vsvbr:=alert("Режим",avsvb)
      if lastkey()=27
         retu .t.
      endif
   else
      vsvbr=2
   endif
else
   vsvbr=2
endif

if vsvbr=1
   rmsda0()
else
   if gnArm#0
      rmsdv0()
   else
      rmsdv0(1)
   endif
endif
arcout()
wmess('Передача окончена',0)
retu .t.

***********************************************************************
***********************************************************************

func rmsdv0(p1)
* p1 Передача всего выборочного без приходов
crout()
dirchange(gcPath_l)
sele 0
use (gcPath_out+rmdirr+'\dmg')
netrepl('kolmod','1')
use
if select('sl')=0
   sele 0
   use _slct alias sl excl
   zap
endif

crtt('rmvb','f:sk c:n(3) f:nsk c:c(20) f:txt c:c(40)')
sele 0
use rmvb
appe blank
repl sk with 1,nsk with 'XXXXXXXXXX',txt with '/astru,dbft,dir,prd'
appe blank
repl sk with 2,nsk with 'Клиенты',txt with 'kln,kpl,kgp,tara,kgptm,krntm,nasptm,rntm'
appe blank
repl sk with 3,nsk with 'Скидки,Договора',txt with 'klnlic,klnnac,brnac,mnnac,klndog,kplnap'
appe blank
repl sk with 4,nsk with 'Прайсы',txt with 'ctov,upak,kach,nei,grp,grpe,ntov,ntov(x)'
appe blank
repl sk with 5,nsk with 'Пользователи',txt with 'speng,spenge'
appe blank
repl sk with 6,nsk with 'Агенты',txt with 's_tag,s_tage,tmesto,etm,stagtm,stagm,ktanap'
appe blank
repl sk with 7,nsk with 'Банк',txt with 'nnds'
appe blank
repl sk with 8,nsk with 'Поставщики,ТМ',txt with 'kps,kpsmk,kgpcat,mkeep,mkeepe,grbr,brand'
netuse('cskl')
do while !eof()
   if ent#gnEnt
      skip
      loop
   endif
   if rm=0
      skip
      loop
   else
      if rm#srmskr
         skip
         loop
      endif
   endif
   skr=sk
   nskr=alltrim(nskl)
   sele rmvb
   appe blank
   repl sk with skr,nsk with nskr
   sele cskl
   skip
endd
nuse('cskl')

astrusd()

if empty(p1)
   sele rmvb
   go top
   rcrmvbr=recn()
   do while .t.
      sele rmvb
      go rcrmvbr
      rcrmvbr=slcf('rmvb',,,,,"e:sk h:'nom' c:n(3) e:nsk h:'Наименование' c:c(20) e:txt h:'Таблицы' c:c(40)",,1,,,,,'Выбор')
      if lastkey()=27
         exit
      endif
      go rcrmvbr
      skr=sk
      if lastkey()=13
         sele sl
         go top
         do while !eof()
            sele sl
            rcrmvb_r=val(kod)
            sele rmvb
            go rcrmvb_r
            sk_r=sk
            nskr=nsk
            if gnArm#0
               @ 1,1 say str(sk_r,3)+' '+nskr
            endif
            do case
               case sk_r=1 && XXXXXXXXXXXX
               case sk_r=2 && KLN
                    kplsd()
                    klnsd()
               case sk_r=3 && KLNNAC,BRNAC,MNNAC
                    klnnacsd()
               case sk_r=4 && CTOV
                    ctovsd()
               case sk_r=5 && SPENG
                    spengsd()
               case sk_r=6 && S_TAG
                    stagsd()
               case sk_r=7 && Банк
                    banksd()
               case sk_r=8 && Поставщики,ТМ
                    kpssd()
               case sk_r>100 && Приходы
                    skladsd(sk_r)
            endc
            sele sl
            skip
         endd
         exit
      endif
   endd
else
   kplsd()
   klnsd()
   klnnacsd()
   ctovsd()
   spengsd()
   stagsd()
   banksd()
   kpssd()
endif
sele rmvb
use
sele sl
use
retu .t.


*******************
func astrusd()
*******************
pathinr=pathminr+gcDir_a
pathoutr=pathmoutr+gcDir_a
adirect=directory(pathinr+'*.*')
if len(adirect)#0
   for i=1 to len(adirect)
       fl=adirect[i,1]
       fextr=lower(right(fl,3))
       if fextr='dbf'.or.fextr='fpt'
          copy file (pathinr+fl) to (pathoutr+fl)
       endif
   next
endif
pathinr=pathminr+gcDir_c
pathoutr=pathmoutr+gcDir_c
if file(pathinr+'dbft.dbf')
   copy file (pathinr+'dbft.dbf') to (pathoutr+'dbft.dbf')
endif
if file(pathinr+'dir.dbf')
   copy file (pathinr+'dir.dbf') to (pathoutr+'dir.dbf')
endif
pathinr=pathminr+gcDir_e
pathoutr=pathmoutr+gcDir_e
if file(pathinr+'prd.dbf')
   copy file (pathinr+'prd.dbf') to (pathoutr+'prd.dbf')
endif
retu .t.
************
func kplsd()
************
pathoutr=pathmoutr+gcDir_e
netuse('kpl')
copy stru to (pathoutr+'kpl.dbf')
use
netuse('kgp')
copy stru to (pathoutr+'kgp.dbf')
use
netuse('tara')
copy stru to (pathoutr+'tara_kl.dbf')
use
netuse('kgptm')
copy to (pathoutr+'kgptm.dbf') for tcen#0.or.nac#0.or.nac1#0
use
netuse('krntm')
copy to (pathoutr+'krntm.dbf') for tcen#0.or.nac#0.or.nac1#0
use
netuse('nasptm')
copy to (pathoutr+'nasptm.dbf') for tcen#0.or.nac#0.or.nac1#0
use
netuse('rntm')
copy to (pathoutr+'rntm.dbf') for tcen#0.or.nac#0.or.nac1#0
use
pathr=pathoutr
netind('kpl',1)
netuse('kpl','kplout',,1)
netind('kgp',1)
netuse('kgp','kgpout',,1)
netind('tara',1)
netuse('tara','taraout',,1)

netuse('kpl')
netuse('kgp')
netuse('tara')

sele kpl
go top
do while !eof()
   if subs(crmsk,srmskr,1)#'1'
      skip
      loop
   endif
   kplr=kpl
   sele kplout
   if !netseek('t1','kplr')
      sele kpl
      if netseek('t1','kplr')
         arec:={}
         getrec()
         sele kplout
         netadd()
         putrec()
      endif
   endif
   sele kpl
   skip
endd
sele kgp
go top
do while !eof()
   if rm#srmskr
      skip
      loop
   endif
   kgpr=kgp
   sele kgpout
   if !netseek('t1','kgpr')
      sele kgp
      if netseek('t1','kgpr')
         arec:={}
         getrec()
         sele kgpout
         netadd()
         putrec()
      endif
   endif
   sele kgp
   skip
endd
sele tara
go top
do while !eof()
   kklr=kkl
   sele kpl
   if !netseek('t1','kklr')
      sele tara
      skip
      loop
   endif
   if subs(crmsk,srmskr,1)#'1'
      sele tara
      skip
      loop
   endif
   sele taraout
   if !netseek('t1','kklr')
      sele tara
      if netseek('t1','kklr')
         arec:={}
         getrec()
         sele taraout
         netadd()
         putrec()
      endif
   endif
   sele kgp
   skip
endd
nuse('kpl')
nuse('kgp')
nuse('tara')
nuse('kplout')
nuse('kgpout')
nuse('taraout')
retu .t.
************
func klnsd()
************
pathoutr=pathmoutr+gcDir_c
netuse('ctov')
netuse('kln')
copy stru to (pathoutr+'tklns02.dbf')
use
pathr=pathoutr
netind('kln',1)
netuse('kln','klnout',,1)
netuse('kln')
netuse('kpl')
netuse('kgp')
sele kpl
go top
do while !eof()
   if subs(crmsk,srmskr,1)#'1'
      skip
      loop
   endif
   kplr=kpl
   sele klnout
   if !netseek('t1','kplr')
      sele kln
      if netseek('t1','kplr')
         arec:={}
         getrec()
         sele klnout
         netadd()
         putrec()
      endif
   endif
   sele kpl
   skip
endd
sele kgp
go top
do while !eof()
   if rm#srmskr
      skip
      loop
   endif
   kgpr=kgp
   sele klnout
   if !netseek('t1','kgpr')
      sele kln
      if netseek('t1','kgpr')
         arec:={}
         getrec()
         sele klnout
         netadd()
         putrec()
      endif
   endif
   sele kgp
   skip
endd
sele ctov
go top
do while !eof()
   if izg=0
      skip
      loop
   endif
   kklr=izg
   sele klnout
   if !netseek('t1','kklr')
      sele kln
      if netseek('t1','kklr')
         arec:={}
         getrec()
         sele klnout
         netadd()
         putrec()
      endif
   endif
   sele ctov
   skip
endd
sele kln
go top
do while kkl<10000
   kklr=kkl
   sele klnout
   if !netseek('t1','kklr')
      sele kln
      arec:={}
      getrec()
      sele klnout
      netadd()
      putrec()
   endif
   sele kln
   skip
endd
sele kln
if netseek('t1','gnKkl_c')
   arec:={}
   getrec()
   sele klnout
   netadd()
   putrec()
endif
nuse('kln')
nuse('kpl')
nuse('kgp')
nuse('klnout')
nuse('ctov')
retu .t.
***************
func klnnacsd()
***************
netuse('kpl')

*KLNLIC
pathoutr=pathmoutr+gcDir_c
netuse('klnlic')
copy stru to (pathoutr+'klnlic.dbf')
use
pathr=pathoutr
netind('klnlic',1)
netuse('klnlic','licout',,1)
netuse('klnlic')

*KLNNAC
pathoutr=pathmoutr+gcDir_e
netuse('klnnac')
copy stru to (pathoutr+'klnnac.dbf')
use
pathr=pathoutr
netind('klnnac',1)
netuse('klnnac','nacout',,1)
netuse('klnnac')

*KPLNAP
pathoutr=pathmoutr+gcDir_e
netuse('kplnap')
copy stru to (pathoutr+'kplnap.dbf')
use
pathr=pathoutr
netind('kplnap',1)
netuse('kplnap','napout',,1)
netuse('kplnap')

*BRNAC
pathoutr=pathmoutr+gcDir_e
netuse('brnac')
copy stru to (pathoutr+'brnac.dbf')
use
pathr=pathoutr
netind('brnac',1)
netuse('brnac','brout',,1)
netuse('brnac')

*MNNAC
pathoutr=pathmoutr+gcDir_e
netuse('mnnac')
copy stru to (pathoutr+'mnnac.dbf')
use
pathr=pathoutr
netind('mnnac',1)
netuse('mnnac','mnout',,1)
netuse('mnnac')

*KLNDOG
pathoutr=pathmoutr+gcDir_e
netuse('klndog')
copy stru to (pathoutr+'klndog.dbf')
use
pathr=pathoutr
netind('klndog',1)
netuse('klndog','dogout',,1)
netuse('klndog')

sele kpl
do while !eof()
   if subs(crmsk,srmskr,1)#'1'
      skip
      loop
   endif
   kplr=kpl
   sele klnlic
   if netseek('t1','kplr')
      do while kkl=kplr
         arec:={}
         getrec()
         sele licout
         netadd()
         putrec()
         sele klnlic
         skip
      endd
   endif
   sele klnnac
   if netseek('t1','kplr')
      do while kkl=kplr
         arec:={}
         getrec()
         sele nacout
         netadd()
         putrec()
         sele klnnac
         skip
      endd
   endif
   sele brnac
   if netseek('t1','kplr')
      do while kkl=kplr
         arec:={}
         getrec()
         sele brout
         netadd()
         putrec()
         sele brnac
         skip
      endd
   endif
   sele mnnac
   if netseek('t1','kplr')
      do while kkl=kplr
         arec:={}
         getrec()
         sele mnout
         netadd()
         putrec()
         sele mnnac
         skip
      endd
   endif
   sele klndog
   if netseek('t1','kplr')
      do while kkl=kplr
         arec:={}
         getrec()
         sele dogout
         netadd()
         putrec()
         sele klndog
         skip
      endd
   endif
   sele kplnap
   if netseek('t1','kplr')
      do while kpl=kplr
         arec:={}
         getrec()
         sele napout
         netadd()
         putrec()
         sele kplnap
         skip
      endd
   endif
   sele kpl
   skip
endd
nuse('klnnac')
nuse('klnlic')
nuse('klndog')
nuse('kplnnap')
nuse('brnac')
nuse('mnnac')
nuse('licout')
nuse('nacout')
nuse('brout')
nuse('mnout')
nuse('dogout')
nuse('napout')
retu .t.
**************
func ctovsd()
**************
pathinr=pathminr+gcDir_e
pathoutr=pathmoutr+gcDir_e
if file(pathinr+'ctov.dbf')
   copy file (pathinr+'ctov.dbf') to (pathoutr+'ctov.dbf')
endif
if file(pathinr+'ctov.cdx')
   copy file (pathinr+'ctov.cdx') to (pathoutr+'ctov.cdx')
endif
if file(pathinr+'tcen.dbf')
   copy file (pathinr+'tcen.dbf') to (pathoutr+'tcen.dbf')
endif
if file(pathinr+'tcen.cdx')
   copy file (pathinr+'tcen.cdx') to (pathoutr+'tcen.cdx')
endif

pathinr=pathminr+gcDir_c
pathoutr=pathmoutr+gcDir_c
if file(pathinr+'upak.dbf')
   copy file (pathinr+'upak.dbf') to (pathoutr+'upak.dbf')
endif
if file(pathinr+'upak.cdx')
   copy file (pathinr+'upak.cdx') to (pathoutr+'upak.cdx')
endif

if file(pathinr+'kach.dbf')
   copy file (pathinr+'kach.dbf') to (pathoutr+'kach.dbf')
endif
if file(pathinr+'kach.cdx')
   copy file (pathinr+'kach.cdx') to (pathoutr+'kach.cdx')
endif

if file(pathinr+'nei.dbf')
   copy file (pathinr+'nei.dbf') to (pathoutr+'nei.dbf')
endif
if file(pathinr+'nei.cdx')
   copy file (pathinr+'nei.cdx') to (pathoutr+'nei.cdx')
endif

if file(pathinr+'grp.dbf')
   copy file (pathinr+'grp.dbf') to (pathoutr+'grp.dbf')
endif
if file(pathinr+'grp.cdx')
   copy file (pathinr+'grp.cdx') to (pathoutr+'grp.cdx')
endif

if file(pathinr+'grpe.dbf')
   copy file (pathinr+'grpe.dbf') to (pathoutr+'grpe.dbf')
endif
if file(pathinr+'grpe.cdx')
   copy file (pathinr+'grpe.cdx') to (pathoutr+'grpe.cdx')
endif

if file(pathinr+'ntov.dbf')
   copy file (pathinr+'ntov.dbf') to (pathoutr+'ntov.dbf')
endif
if file(pathinr+'ntov.cdx')
   copy file (pathinr+'ntov.cdx') to (pathoutr+'ntov.cdx')
endif

if file(pathinr+'ntovig.dbf')
   copy file (pathinr+'ntovig.dbf') to (pathoutr+'ntovig.dbf')
endif
if file(pathinr+'ntovig.cdx')
   copy file (pathinr+'ntovig.cdx') to (pathoutr+'ntovig.cdx')
endif

if file(pathinr+'ntovim.dbf')
   copy file (pathinr+'ntovim.dbf') to (pathoutr+'ntovim.dbf')
endif
if file(pathinr+'ntovim.cdx')
   copy file (pathinr+'ntovim.cdx') to (pathoutr+'ntovim.cdx')
endif

if file(pathinr+'ntovka.dbf')
   copy file (pathinr+'ntovka.dbf') to (pathoutr+'ntovka.dbf')
endif
if file(pathinr+'ntovka.cdx')
   copy file (pathinr+'ntovka.cdx') to (pathoutr+'ntovka.cdx')
endif

if file(pathinr+'ntovup.dbf')
   copy file (pathinr+'ntovup.dbf') to (pathoutr+'ntovup.dbf')
endif
if file(pathinr+'ntovup.cdx')
   copy file (pathinr+'ntovup.cdx') to (pathoutr+'ntovup.cdx')
endif

retu .t.
**************
func spengsd()
**************
pathinr=pathminr+gcDir_c
pathoutr=pathmoutr+gcDir_c
if file(pathinr+'speng.dbf')
   copy file (pathinr+'speng.dbf') to (pathoutr+'speng.dbf')
endif
if file(pathinr+'speng.cdx')
   copy file (pathinr+'speng.cdx') to (pathoutr+'speng.cdx')
endif
if file(pathinr+'spenge.dbf')
   copy file (pathinr+'spenge.dbf') to (pathoutr+'spenge.dbf')
endif
if file(pathinr+'speng.cdx')
   copy file (pathinr+'spenge.cdx') to (pathoutr+'spenge.cdx')
endif
retu .t.
**************
func stagsd()
**************
pathinr=pathminr+gcDir_c
pathoutr=pathmoutr+gcDir_c
if file(pathinr+'tmesto.dbf')
   copy file (pathinr+'tmesto.dbf') to (pathoutr+'tmesto.dbf')
endif
if file(pathinr+'tmesto.cdx')
   copy file (pathinr+'tmesto.cdx') to (pathoutr+'tmesto.cdx')
endif
pathinr=pathminr+gcDir_e
pathoutr=pathmoutr+gcDir_e
if file(pathinr+'s_tag.dbf')
   copy file (pathinr+'s_tag.dbf') to (pathoutr+'s_tag.dbf')
endif
if file(pathinr+'s_tag.cdx')
   copy file (pathinr+'s_tag.cdx') to (pathoutr+'s_tag.cdx')
endif
if file(pathinr+'s_tage.dbf')
   copy file (pathinr+'s_tage.dbf') to (pathoutr+'s_tage.dbf')
endif
if file(pathinr+'s_tage.cdx')
   copy file (pathinr+'s_tage.cdx') to (pathoutr+'s_tage.cdx')
endif
if file(pathinr+'etm.dbf')
   copy file (pathinr+'etm.dbf') to (pathoutr+'etm.dbf')
endif
if file(pathinr+'etm.cdx')
   copy file (pathinr+'etm.cdx') to (pathoutr+'etm.cdx')
endif
if file(pathinr+'stagtm.dbf')
   copy file (pathinr+'stagtm.dbf') to (pathoutr+'stagtm.dbf')
endif
if file(pathinr+'stagtm.cdx')
   copy file (pathinr+'stagtm.cdx') to (pathoutr+'stagtm.cdx')
endif
if file(pathinr+'stagm.dbf')
   copy file (pathinr+'stagm.dbf') to (pathoutr+'stagm.dbf')
endif
if file(pathinr+'stagtm.cdx')
   copy file (pathinr+'stagm.cdx') to (pathoutr+'stagm.cdx')
endif
if file(pathinr+'nap.dbf')
   copy file (pathinr+'nap.dbf') to (pathoutr+'nap.dbf')
endif
if file(pathinr+'nap.cdx')
   copy file (pathinr+'nap.cdx') to (pathoutr+'nap.cdx')
endif
if file(pathinr+'naptm.dbf')
   copy file (pathinr+'naptm.dbf') to (pathoutr+'naptm.dbf')
endif
if file(pathinr+'nap.cdx')
   copy file (pathinr+'naptm.cdx') to (pathoutr+'naptm.cdx')
endif
if file(pathinr+'ktanap.dbf')
   copy file (pathinr+'ktanap.dbf') to (pathoutr+'ktanap.dbf')
endif
if file(pathinr+'nap.cdx')
   copy file (pathinr+'ktanap.cdx') to (pathoutr+'ktanap.cdx')
endif
retu .t.

**************
func banksd()
**************
pathoutr=pathmoutr+gcDir_e+gcDir_g+gcDir_d+gcDir_b

netuse('kpl')

netuse('dokz')
pathr=pathoutr
copy stru to (pathr+'dok_z.dbf')
use
netind('dokz',1)
netuse('dokz','dokzout',,1)
set orde to tag t2
netuse('dokk')
netuse('dokz')
set orde to tag t2
go top
mn_r=0
do while .t.
   if eof()
      mn_r=0
      exit
   endif
   if mn=0
      skip
      loop
   else
      mn_r=mn
      if netseek('t1','mn_r','dokk')
         exit
      endif
   endif
   sele dokz
   skip
endd
nuse('dokk')
if mn_r=0
   nuse('dokz')
   nuse('kpl')
   nuse('dokzout')
   retu .t.
endif

netuse('doks')
pathr=pathoutr
copy stru to (pathr+'dok_s.dbf')
use
netind('doks',1)
netuse('doks','doksout',,1)
netuse('doks')

netuse('dokk')
pathr=pathoutr
copy stru to (pathr+'dok_k.dbf')
use
netind('dokk',1)
netuse('dokk','dokkout',,1)
netuse('dokk')

netuse('operb')
pathr=pathoutr
copy stru to (pathr+'oper_bs.dbf')
use
netind('operb',1)
netuse('operb','operbout',,1)
netuse('operb')

sele dokk
if netseek('t1','mn_r')
   do while mn#0
      if eof()
         exit
      endif
*      if prc.or.mn=0.or.bs_d=99.or.bs_k=99.or.bs_o=301001.and.gnEnt#21.or.bs_o=702101
      if prc.or.mn=0.or.bs_d=99.or.bs_k=99.or.bs_o=702101
         skip
         loop
      endif
      if kkl=20034
         skip
         loop
      endif
      if bs_d=0.and.bs_k=0
         skip
         loop
      endif
      if rmsk#0
         skip
         loop
      else
         mnr=mn
         bsr=getfield('t2','mnr','dokz','bs')
         sele rmsk
         locate for rmbs=bsr
         if foun()
            rmsk_r=rmsk
            sele dokk
            netrepl('rmsk','rmsk_r')
            skip
            loop
         endif
      endif
      sele dokk
      kklr=kkl
      sele kpl
      if !netseek('t1','kklr')
         sele dokk
         skip
         loop
      else
         if subs(crmsk,srmskr,1)#'1'
            sele dokk
            skip
            loop
         endif
      endif
      sele dokk
      kopr=kop
      sele operbout
      if !netseek('t1','kopr')
         sele operb
         if netseek('t1','kopr')
            arec:={}
            getrec()
            sele operbout
            netadd()
            putrec()
            netunlock()
         endif
      endif
      sele dokk
      mnr=mn
      rndr=rnd
      arec:={}
      getrec()
      sele dokkout
      netadd()
      putrec()
      netunlock()
      sele doksout
      if !netseek('t1','mnr,rndr,kklr')
         sele doks
         if netseek('t1','mnr,rndr,kklr')
            arec:={}
            getrec()
            sele doksout
            netadd()
            putrec()
            netunlock()
         endif
      endif
      sele dokzout
      if !netseek('t2','mnr')
         sele dokz
         if netseek('t2','mnr')
            arec:={}
            getrec()
            sele dokzout
            netadd()
            putrec()
            netunlock()
         endif
      endif
      sele dokk
      skip
   endd
endif
sele operb
go top
do while !eof()
   if db#rmbsr
      skip
      loop
   endif
   arec:={}
   getrec()
   kopr=kop
   sele operbout
   locate for kop=kopr
   if !foun()
      netadd()
      putrec()
   endif
   sele operb
   skip
endd
nuse('dokz')
nuse('doks')
nuse('dokk')
nuse('operb')
nuse('dokzout')
nuse('doksout')
nuse('dokkout')
nuse('operbout')
nuse('kpl')

pathoutr=pathmoutr+gcDir_e+gcDir_g+gcDir_d
netuse('nnds')
copy to (pathoutr+'nnds.dbf') for rm=srmskr
nuse('nnds')
retu .t.
****************
func skladsd(p1)
****************
netuse('cskl')
locate for sk=p1
path_rr=alltrim(path)
pathoutr=pathmoutr+gcDir_e+gcDir_g+gcDir_d+path_rr

pathr=gcPath_d+path_rr
netuse('pr1',,,1)
pathr=pathoutr
copy stru to (pathr+'tprho11.dbf')
use
netind('pr1',1)
netuse('pr1','pr1out',,1)
pathr=gcPath_d+path_rr
netuse('pr1',,,1)

pathr=gcPath_d+path_rr
netuse('pr2',,,1)
pathr=pathoutr
copy stru to (pathr+'tprho12.dbf')
use
netind('pr2',1)
netuse('pr2','pr2out',,1)
pathr=gcPath_d+path_rr
netuse('pr2',,,1)

pathr=gcPath_d+path_rr
netuse('pr3',,,1)
pathr=pathoutr
copy stru to (pathr+'tprho13.dbf')
use
netind('pr3',1)
netuse('pr3','pr3out',,1)
pathr=gcPath_d+path_rr
netuse('pr3',,,1)

pathr=gcPath_d+path_rr
netuse('tov',,,1)
pathr=pathoutr
copy stru to (pathr+'tprds01.dbf')
use
netind('tov',1)
netuse('tov','tovout',,1)
pathr=gcPath_d+path_rr
netuse('tov',,,1)

pathr=gcPath_d+path_rr
netuse('tovm',,,1)
pathr=pathoutr
copy stru to (pathr+'tovm.dbf')
use
netind('tovm',1)
netuse('tovm','tovmout',,1)
pathr=gcPath_d+path_rr
netuse('tovm',,,1)


pathr=gcPath_d+path_rr
netuse('soper',,,1)
pathr=pathoutr
copy stru to (pathr+'oper.dbf')
use
netind('soper',1)
netuse('soper','soperout',,1)
pathr=gcPath_d+path_rr
netuse('soper',,,1)


if select('sl')#0
   sele sl
   use
endif
sele 0
use _slct alias sl excl
zap
sele pr1
go top
rcpr1r=recn()
forr='.t..and.(vo=9.or.kop=188.or.kop=111).and.prz=1.and.rmsk=0'
do while .t.
   sele pr1
   go rcpr1r
   if fieldpos('dtmod')=0
      rcpr1r=slcf('pr1',,,,,"e:nd h:'ND' c:n(6) e:mn h:'MN' c:n(6) e:vo h:'ВО' c:n(2) e:kop h:'КОП' c:n(3) e:prz h:'П' c:n(1) e:dpr h:'Дата' c:d(10) e:sdv h:'Сумма' c:n(12,2)",,1,,,forr,,'Приходы')
   else
      rcpr1r=slcf('pr1',,,,,"e:nd h:'ND' c:n(6) e:mn h:'MN' c:n(6) e:vo h:'ВО' c:n(2) e:kop h:'КОП' c:n(3) e:prz h:'П' c:n(1) e:dpr h:'Дата' c:d(10) e:sdv h:'Сумма' c:n(12,2) e:dtmod h:'ДтМод' c:d(10)",,1,,,forr,,'Приходы')
   endif
   if lastkey()=27
      exit
   endif
   if lastkey()=13
      sele soper
      go top
      do while !eof()
         d0k1r=d0k1
         kopr=kop
         vor=vo
         arec:={}
         getrec()
         sele soperout
         locate for d0k1=d0k1r.and.kop=kopr.and.vo=vor
         if !foun()
            netadd()
            putrec()
            netunlock()
         endif
         sele soper
         skip
      endd
      sele sl
      go top
      do while !eof()
         rcpr1r=val(kod)
         sele pr1
         go rcpr1r
         sklr=skl
         mnr=mn
         kopr=kop
         vor=vo
         sele soper
         locate for d0k1=1.and.kop=mod(kopr,100).and.vo=vor
         if foun()
            arec:={}
            getrec()
            sele soperout
            locate for d0k1=1.and.kop=mod(kopr,100).and.vo=vor
            if !foun()
               netadd()
               putrec()
               netunlock()
            endif
         endif
         sele pr1
         mnr=mn
         arec:={}
         getrec()
         sele pr1out
         if netseek('t2','mnr')
            sele sl
            skip
            loop
         endif
         netadd()
         putrec()
         netunlock()
         sele pr2
         if netseek('t1','mnr')
            do while mn=mnr
               mntovr=mntov
               ktlr=ktl
               arec:={}
               getrec()
               sele pr2out
               netadd()
               putrec()
               netunlock()
               sele tov
               if netseek('t1','sklr,ktlr')
                  arec:={}
                  getrec()
                  sele tovout
                  if !netseek('t1','sklr,ktlr')
                     netadd()
                     putrec()
                     netunlock()
                  endif
               endif
               sele tovm
               if netseek('t1','sklr,mntovr')
                  arec:={}
                  getrec()
                  sele tovmout
                  if !netseek('t1','sklr,mntovr')
                     netadd()
                     putrec()
                     netunlock()
                  endif
               endif
               sele pr2
               skip
            endd
         endif
         sele pr3
         if netseek('t1','mnr')
            do while mn=mnr
               arec:={}
               getrec()
               sele pr3out
               netadd()
               putrec()
               netunlock()
               sele pr3
               skip
            endd
         endif
         sele sl
         skip
      endd
   endif
endd
nuse('pr1')
nuse('pr2')
nuse('pr3')
nuse('tov')
nuse('soper')
nuse('pr1out')
nuse('pr2out')
nuse('pr3out')
nuse('tovout')
nuse('soperout')
nuse('cskl')
retu .t.

*************
func rmsda0()
*************
kolmesr=0
store gdTd to d1r,d2r
crout(d1r,d2r)

* Копирование файлов SD0=4

?'ASTRU'
pathinr=pathminr+gcDir_a
pathoutr=pathmoutr+gcDir_a
adirect=directory(pathinr+'*.*')
if len(adirect)#0
   for i=1 to len(adirect)
       fl=adirect[i,1]
       fextr=lower(right(fl,3))
       if fextr='dbf'.or.fextr='fpt'
          copy file (pathinr+fl) to (pathoutr+fl)
       endif
   next
endif

?'DBFT,DIR'
pathoutr=pathmoutr+gcDir_c
sele dbft
copy to (pathoutr+'dbft.dbf')
sele dir
copy to (pathoutr+'dir.dbf')

?'COMM'
pathinr=pathminr+gcDir_c
pathoutr=pathmoutr+gcDir_c
dirr=1
cpfl()
commsd0()

?'ENT '
pathinr=pathminr+gcDir_e
pathoutr=pathmoutr+gcDir_e
dirr=4
cpfl()
entsd0()

yy1r=year(d1r)
yy2r=year(d2r)

for yy=yy1r to yy2r
    pathinr=pathminr+gcDir_e+'g'+str(yy,4)+'\'
    pathoutr=pathmoutr+gcDir_e+'g'+str(yy,4)+'\'
    ?pathinr
    dirr=7
    cpfl()
    do case
       case yy1r=yy2r
            mm1r=month(d1r)
            mm2r=month(d2r)
       case yy=yy1r
            mm1r=month(d1r)
            mm2r=12
       case yy=yy2r
            mm1r=1
            mm2r=month(d2r)
    endc
    for mm=mm1r to mm2r
        pathinr=pathminr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'
        pathoutr=pathmoutr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'
        diroutr=pathmoutr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))
        dirinr=pathminr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))
        if dirchange(dirinr)#0
           loop
        endif
        if dirchange(diroutr)#0
           loop
        endif
        ?pathinr
        dirr=5
        cpfl()
        pathinr=pathminr+gcDir_c+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'
        pathoutr=pathmoutr+gcDir_c+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'
        dirinr=pathminr+gcDir_c+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))
        diroutr=pathmoutr+gcDir_c+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))
        if dirchange(dirinr)#0
           loop
        endif
        if dirchange(diroutr)#0
           loop
        endif
        ?pathinr
        dirr=9
        cpfl()
        *BANK
        pathinr=pathminr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'+gcDir_b
        pathoutr=pathmoutr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'+gcDir_b
        dirinr=pathminr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\bank'
        diroutr=pathmoutr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\bank'
        if dirchange(dirinr)#0
           loop
        endif
        if dirchange(diroutr)#0
           loop
        endif
        ?pathinr
        dirr=2
        cpfl()
        banksd0()
        *'GLOB'
        pathinr=pathminr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'+gcDir_gl
        pathoutr=pathmoutr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'+gcDir_gl
        diroutr=pathmoutr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\glob'
        if dirchange(diroutr)=0
           dirr=2
           cpfl()
        endif
        ?pathinr
        *'SKLAD'
        netuse('cskl')
        do while !eof()
           if ent#gnEnt
              skip
              loop
           endif
           rm_rr=rm
*           if rm=0
*              skip
*              loop
*           endif
*           if rm#srmskr
*              skip
*              loop
*           endif
           if !(rm_rr=srmskr.or.rm_rr=0)
              skip
              loop
           endif
           pathinr=pathminr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'+alltrim(path)
           pathoutr=pathmoutr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'+alltrim(path)
           dirinr=subs(pathinr,1,len(pathinr)-1)
           diroutr=subs(pathoutr,1,len(pathoutr)-1)
           if dirchange(dirinr)#0
              sele cskl
              skip
              loop
           endif
           if dirchange(diroutr)#0
              sele cskl
              skip
              loop
           endif
           dirchange(gcPath_l)
           dirr=3
           skr=sk
           ?pathinr
           cpfl()
           sele cskl
           if rm_rr#0
              skladsd0()
           else
              skladsd0(1)
           endif
           sele cskl
           skip
        endd
        nuse('cskl')
    next
next
dirchange(gcPath_l)
retu .t.

***************
func cpfl()
**************
sele dbft
go top
do while !eof()
   if dir#dirr
      skip
      loop
   endif
   if sd0#4
      skip
      loop
   endif
   fdr=alltrim(fname)+'.dbf'
   fcr=alltrim(fname)+'.cdx'
   fpr=alltrim(fname)+'.fpt'
   if file(pathinr+fdr)
      copy file (pathinr+fdr) to (pathoutr+fdr)
   endif
   if file(pathinr+fcr).and.dirr#101
      copy file (pathinr+fcr) to (pathoutr+fcr)
   endif
   if file(pathinr+fpr)
      copy file (pathinr+fpr) to (pathoutr+fpr)
   endif
   skip
endd
retu .t.
***********************
func cpkpl(p1,p2,p3,p4)
***********************
* p1 pathoutr
* p2 алиас
* p3 1-kpl;2-kpl,kgp;3-kgp
* p4 tag   default t1
**************
if empty(p4)
   tag_r='t1'
else
   tag_r=p4
endif
do case
   case p3=1
        netuse('kpl')
   case p3=2
        netuse('kpl')
        netuse('kgp')
   case p3=3
        netuse('kgp')
endc
sele dbft
locate for alltrim(als)=p2
ffnr=alltrim(fname)
*******************
netuse(p2,'in')
set orde to tag (tag_r)
copy stru to (p1+ffnr+'.dbf')
pathr=p1
netind(p2,1)
netuse(p2,'out',,1)
set orde to tag (tag_r)
if p3=1.or.p3=2
   sele kpl
   go top
   do while !eof()
      if subs(crmsk,srmskr,1)#'1'
         skip
         loop
      endif
      kklr=kpl
      sele in
      if netseek(tag_r,'kklr')
         do while kkl=kklr
            if fieldpos('rmsk')#0 && nds
               if rmsk#0
                  skip
                  loop
               endif
            endif
            arec:={}
            getrec()
            sele out
            netadd()
            putrec()
            sele in
            skip
         endd
      endif
      sele kpl
      skip
   endd
endif
if p3=2.or.p3=3
   sele kgp
   go top
   do while !eof()
      if rm#srmskr
         skip
         loop
      endif
      kklr=kgp
      sele in
      if netseek(tag_r,'kklr')
         do while kkl=kklr
            arec:={}
            getrec()
            sele out
            netadd()
            putrec()
            sele in
            skip
         endd
      endif
      sele kgp
      skip
   endd
endif
if p2=='kln'
   netuse('ctov')
   go top
   do while !eof()
      if izg=0
         skip
         loop
      endif
      kklr=izg
      sele out
      if !netseek('t1','kklr')
         sele in
         if netseek(tag_r,'kklr')
            arec:={}
            getrec()
            sele out
            netadd()
            putrec()
         endif
      endif
      sele ctov
      skip
   endd
   nuse('ctov')
endif
*******************
nuse('kpl')
nuse('kgp')
nuse('in')
nuse('out')
retu .t.

**************
func commsd0()
* kln,klnlic
**************
pathoutr=pathmoutr+gcDir_c
?'kln'
cpkpl(pathoutr,'kln',2)
?'klnlic'
cpkpl(pathoutr,'klnlic',1)
retu .t.

***************************************************
func entsd0()
* nds,tara,klnnac,klndog,kgpcat,brnac,mnnac,kpl,kgp
***************************************************
pathoutr=pathmoutr+gcDir_e
*?'nds'
*cpkpl(pathoutr,'nds',1,'t2')
?'tara'
cpkpl(pathoutr,'tara',2)
?'klnnac'
cpkpl(pathoutr,'klnnac',2)
?'brnac'
cpkpl(pathoutr,'brnac',2)
?'mnnac'
cpkpl(pathoutr,'mnnac',2)
?'klndog'
cpkpl(pathoutr,'klndog',2)
?'kpl'
netuse('kpl')
copy to (pathoutr+'kpl.dbf') for subs(crmsk,srmskr,1)='1'
use
pathr=pathoutr
netind('kpl',1)
?'kgp'
netuse('kgp')
copy to (pathoutr+'kgp.dbf') for rm=srmskr
use
pathr=pathoutr
netind('kgp',1)
retu .t.

**************
func banksd0()
* dokz,doks,dokk
**************
pathoutr=pathmoutr+gcDir_e+gcDir_g+gcDir_d+gcDir_b

netuse('kpl')

netuse('dokz')
pathr=pathoutr
copy stru to (pathr+'dok_z.dbf')
use
netind('dokz',1)
netuse('dokz','dokzout',,1)
set orde to tag t2

netuse('dokk')
netuse('dokz')
set orde to tag t2
go top
mn_r=0
do while .t.
   if eof()
      mn_r=0
      exit
   endif
   if mn=0
      skip
      loop
   else
      mn_r=mn
      if netseek('t1','mn_r','dokk')
         exit
      endif
   endif
   sele dokz
   skip
endd
nuse('dokk')
if mn_r=0
   nuse('dokz')
   nuse('kpl')
   nuse('dokzout')
   retu .t.
endif

netuse('doks')
pathr=pathoutr
copy stru to (pathr+'dok_s.dbf')
use
netind('doks',1)
netuse('doks','doksout',,1)
netuse('doks')

netuse('dokk')
pathr=pathoutr
copy stru to (pathr+'dok_k.dbf')
use
netind('dokk',1)
netuse('dokk','dokkout',,1)
netuse('dokk')

sele dokk
if netseek('t1','mn_r')
   do while mn#0
      if eof()
         exit
      endif
      if prc.or.mn=0.or.bs_d=99.or.bs_k=99.or.bs_o=301001.or.bs_o=702101
         skip
         loop
      endif
      if rmsk#0
         skip
         loop
      else
         mnr=mn
         bsr=getfield('t2','mnr','dokz','bs')
         sele rmsk
         locate for rmbs=bsr
         if foun()
            rmsk_r=rmsk
            sele dokk
            netrepl('rmsk','rmsk_r')
            skip
            loop
         endif
      endif
      sele dokk
      kklr=kkl
      sele kpl
      if !netseek('t1','kklr')
         sele dokk
         skip
         loop
      else
         if subs(crmsk,srmskr,1)#'1'
            sele dokk
            skip
            loop
         endif
      endif
      sele dokk
      kopr=kop
      mnr=mn
      rndr=rnd
      arec:={}
      getrec()
      sele dokkout
      netadd()
      putrec()
      netunlock()
      sele doksout
      if !netseek('t1','mnr,rndr,kklr')
         sele doks
         if netseek('t1','mnr,rndr,kklr')
            arec:={}
            getrec()
            sele doksout
            netadd()
            putrec()
            netunlock()
         endif
      endif
      sele dokzout
      if !netseek('t2','mnr')
         sele dokz
         if netseek('t2','mnr')
            arec:={}
            getrec()
            sele dokzout
            netadd()
            putrec()
            netunlock()
         endif
      endif
      sele dokk
      skip
   endd
endif

nuse('dokz')
nuse('doks')
nuse('dokk')
nuse('dokzout')
nuse('doksout')
nuse('dokkout')
nuse('kpl')

retu .t.

**************
func skladsd0(p1)
* 0 - данные; 1-структуры
* tov,pr1,pr2,pr3,rs1,rs2,rs3
**************
sele cskl
path_rr=alltrim(path)
pathoutr=pathmoutr+gcDir_e+gcDir_g+gcDir_d+path_rr

pathr=gcPath_d+path_rr
netuse('pr1',,,1)
pathr=pathoutr
copy stru to (pathr+'tprho11.dbf')
use
netind('pr1',1)
netuse('pr1','pr1out',,1)
pathr=gcPath_d+path_rr
netuse('pr1',,,1)

pathr=gcPath_d+path_rr
netuse('pr2',,,1)
pathr=pathoutr
copy stru to (pathr+'tprho12.dbf')
use
netind('pr2',1)
netuse('pr2','pr2out',,1)
pathr=gcPath_d+path_rr
netuse('pr2',,,1)

pathr=gcPath_d+path_rr
netuse('pr3',,,1)
pathr=pathoutr
copy stru to (pathr+'tprho13.dbf')
use
netind('pr3',1)
netuse('pr3','pr3out',,1)
pathr=gcPath_d+path_rr
netuse('pr3',,,1)

pathr=gcPath_d+path_rr
netuse('tov',,,1)
pathr=pathoutr
copy stru to (pathr+'tprds01.dbf')
use
netind('tov',1)
netuse('tov','tovout',,1)
pathr=gcPath_d+path_rr
netuse('tov',,,1)

pathr=gcPath_d+path_rr
netuse('tovm',,,1)
pathr=pathoutr
copy stru to (pathr+'tovm.dbf')
use
netind('tovm',1)
netuse('tovm','tovmout',,1)
pathr=gcPath_d+path_rr
netuse('tovm',,,1)

pathr=gcPath_d+path_rr
netuse('rs1',,,1)
pathr=pathoutr
copy stru to (pathr+'trsho14.dbf')
use
netind('rs1',1)
netuse('rs1','rs1out',,1)
pathr=gcPath_d+path_rr
netuse('rs1',,,1)

pathr=gcPath_d+path_rr
netuse('rs2',,,1)
pathr=pathoutr
copy stru to (pathr+'trsho15.dbf')
use
netind('rs2',1)
netuse('rs2','rs2out',,1)
pathr=gcPath_d+path_rr
netuse('rs2',,,1)

pathr=gcPath_d+path_rr
netuse('rs3',,,1)
pathr=pathoutr
copy stru to (pathr+'trsho16.dbf')
use
netind('rs3',1)
netuse('rs3','rs3out',,1)
pathr=gcPath_d+path_rr
netuse('rs3',,,1)

if empty(p1)
   sele pr1
   go top
   do while !eof()
      if rmsk#0
         skip
         loop
      endif
      if prz#1
         skip
         loop
      endif
      sklr=skl
      mnr=mn
      arec:={}
      getrec()
      sele pr1out
      netadd()
      putrec()
      netunlock()
      sele pr2
      if netseek('t1','mnr')
         do while mn=mnr
            mntovr=mntov
            ktlr=ktl
            arec:={}
            getrec()
            sele pr2out
            netadd()
            putrec()
            netunlock()
            sele tov
            if netseek('t1','sklr,ktlr')
               arec:={}
               getrec()
               sele tovout
               if !netseek('t1','sklr,ktlr')
                  netadd()
                  putrec()
                  netunlock()
               endif
            endif
            sele pr2
            skip
         endd
      endif
      sele pr3
      if netseek('t1','mnr')
         do while mn=mnr
            arec:={}
            getrec()
            sele pr3out
            netadd()
            putrec()
            netunlock()
            sele pr3
            skip
         endd
      endif
      sele pr1
      skip
   endd

   sele rs1
   go top
   do while !eof()
      if rmsk#0
         skip
         loop
      else
         if vo=9
            skip
            loop
         endif
      endif
      sklr=skl
      ttnr=ttn
      arec:={}
      getrec()
      sele rs1out
      netadd()
      putrec()
      netunlock()
      sele rs2
      if netseek('t1','ttnr')
         do while ttn=ttnr
            mntovr=mntov
            ktlr=ktl
            arec:={}
            getrec()
            sele rs2out
            netadd()
            putrec()
            netunlock()
            sele rs2
            skip
         endd
      endif
      sele rs3
      if netseek('t1','ttnr')
         do while ttn=ttnr
            arec:={}
            getrec()
            sele rs3out
            netadd()
            putrec()
            netunlock()
            sele rs3
            skip
         endd
      endif
      sele rs1
      skip
   endd
endif
nuse('pr1')
nuse('pr2')
nuse('pr3')
nuse('tov')
nuse('pr1out')
nuse('pr2out')
nuse('pr3out')
nuse('tovout')
nuse('rs1')
nuse('rs2')
nuse('rs3')
nuse('rs1out')
nuse('rs2out')
nuse('rs3out')
retu .t.

*************
func kpssd()
*************
pathoutr=pathmoutr+gcDir_e
netuse('kps')
copy to (pathoutr+'kps.dbf')
use
netuse('kpsmk')
copy to (pathoutr+'kpsmk.dbf')
use
netuse('kgpcat')
copy to (pathoutr+'kgpcat.dbf')
use
pathoutr=pathmoutr+gcDir_c
netuse('mkeep')
copy to (pathoutr+'mkeep.dbf')
use
netuse('mkeepe')
copy to (pathoutr+'mkeepe.dbf')
use
pathinr=pathminr+gcDir_c
pathoutr=pathmoutr+gcDir_c
netuse('grbr')
copy to (pathoutr+'grbr.dbf')
use
netuse('brand')
copy to (pathoutr+'brand.dbf')
use
retu .t.

