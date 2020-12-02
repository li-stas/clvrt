#include "common.ch"
#include "inkey.ch"
* Остатки на нач
if gnArm#0
   skr=gnSk
   ktr=gnKt
endif
if gnScOut=0
   clea
   aqstr=1
   aqst:={"Просмотр","Коррекция"}
   aqstr:=alert(" ",aqst)
   if lastkey()=K_ESC
      retu
   endif
else
   aqstr=2
endif
netuse('nei')
pathr=path_tr
netuse('rs1',,,1)
netuse('rs2',,,1)
netuse('rs3',,,1)
netuse('rso1',,,1)
netuse('tov',,,1)
netuse('pr1',,,1)
set orde to tag t2
netuse('pr2',,,1)
netuse('pr3',,,1)
pathr=path_pr
prpmr=1
if netfile('tov',1)
   nuse('tovp')
   nuse('rs1p')
   nuse('rs2p')
   nuse('rs3p')
   nuse('pr1p')
   nuse('pr2p')
   nuse('pr3p')

   netuse('tov','tovp',,1)
   netuse('rs1','rs1p',,1)
   netuse('rs2','rs2p',,1)
   netuse('rs3','rs3p',,1)
   netuse('pr1','pr1p',,1)
   set orde to tag t2
   go top
   netuse('pr2','pr2p',,1)
   netuse('pr3','pr3p',,1)
else
   prpmr=0
endif

set prin to ('nost'+alltrim(str(skr,3))+'.txt')
set prin on

if prpmr=1
   ?'PR1P->PR1'
   sele pr1p
   go top
   do while !eof()
      sele pr1p
      mnr=mn
      ndr=nd
      przr=prz
      kopr=kop
*      if przr=0
*         skip
*         loop
*      endif
      sele pr1
      if netseek('t2','mnr')
         if przr=1
            sele pr3
            if netseek('t1','mnr')
               do while mn=mnr
                  netdel()
                  skip
               endd
            endif
            sele pr2
            if netseek('t1','mnr')
               do while mn=mnr
                  netdel()
                  skip
               endd
            endif
            sele pr1
            netdel()
            ?str(ndr,6)+' '+str(mnr,6)+' '+str(przr,1)+' Удален'
         endif
      else
         if przr=0
            sele pr2p
            if netseek('t1','mnr')
               if aqstr=2
                  if gnScOut=0
                     arestr=1
                     arest:={"Пропустить","Восстановить"}
                     arestr:=alert('Приход '+str(ndr,6)+' '+str(kopr,3),arest)
                  else
                     arestr=1
                  endif
                  if arestr=2
                     sele pr1p
                     arec:={}
                     getrec()
                     sele pr1
                     netadd()
                     putrec()
                     sele pr2p
                     if netseek('t1','mnr')
                        do while mn=mnr
                           arec:={}
                           getrec()
                           sele pr2
                           netadd()
                           putrec()
                           sele pr2p
                          skip
                        endd
                     endif
                     sele pr3p
                     if netseek('t1','mnr')
                        do while mn=mnr
                           arec:={}
                           getrec()
                           sele pr3
                           netadd()
                           putrec()
                           sele pr3p
                           skip
                        endd
                     endif
                  endif
               endif
            endif
         endif
      endif
      sele pr1p
      skip
   endd
   ?'RS1P->RS1'
   sele rs1p
   go top
   do while !eof()
      ttnr=ttn
      kopr=kop
      przr=prz
      docguidr=docguid
      if prz=1
         sele rs1
         if netseek('t1','ttnr')
            sele rs3
            if netseek('t1','ttnr')
               do while ttn=ttnr
                  netdel()
                  skip
               endd
            endif
            sele rs2
            if netseek('t1','ttnr')
               do while ttn=ttnr
                  netdel()
                  skip
               endd
            endif
            sele rs1
            netdel()
            ?str(ttnr,6)+' '+str(przr,1)+' Удалена'
         endif
         sele rs1p
         skip
         loop
      endif
      sele rs1p
      kopr=kop
      sdvr=sdv
      sele rs2p
      if !netseek('t1','ttnr')
         sele rs1p
         skip
         loop
      endif
      sele rso1
      prrsor=0
      if netseek('t2','ttnr')
         prrsor=1
*         sele rs1p
*         skip
*         loop
      endif
      dpir=''
      if !empty(docguidr)
         ttn_r=getfield('t2','docguidr','rs1','ttn')
         if ttn_r#0.and.ttnr#ttn_r
            dpir=' '+str(ttn_r,6)
         endif
      endif
      sele rs1
      if !netseek('t1','ttnr')
         ?str(ttnr,6)+' '+str(kopr,3)+' '+str(sdvr,10,2)+' '+docguidr+' '+dpir
         if prrsor=1
            ?str(ttnr,6)+' Изменялся в текущем'
         endif
         if aqstr=2
            if gnScOut=0
               arestr=1
               arest:={"Пропустить","Восстановить"}
               arestr:=alert('Расход '+str(ttnr,6)+' '+str(kopr,3),arest)
            else
               arestr=1
            endif
            if arestr=2
               sele rs1p
               arec:={}
               getrec()
               sele rs1
               netadd()
               putrec()
               sele rs2p
               if netseek('t1','ttnr')
                  do while ttn=ttnr
                     arec:={}
                     getrec()
                     sele rs2
                     netadd()
                     putrec()
                     sele rs2p
                     skip
                  endd
               endif
               sele rs3p
               if netseek('t1','ttnr')
                  do while ttn=ttnr
                     arec:={}
                     getrec()
                     sele rs3
                     netadd()
                     putrec()
                     sele rs3p
                     skip
                  endd
               endif
            endif
         endif
      endif
      sele rs1p
      skip
   endd
   ?'TOVP - >TOV'
   sele tovp
   set orde to
   go top
   do while !eof()
      natr=nat
      ktlr=ktl
      mntovr=mntov
      sklr=skl
      osfr=round(osf,3)
      optr=ROUND(opt,3)
      if otv=1.and.optr=0
         optr=0.01
      endif
      ksertr=ksert
      kukachr=kukach
      dizgr=dizg
      drlzr=drlz
      cenbbr=cenbb
      cenbtr=cenbt
      krstatr=krstat
      sele tov
      if netseek('t1','sklr,ktlr')
         if mntov#mntovr
            ?str(sklr,7)+' '+str(ktlr,9)+' П '+str(mntovr,7)+' Т '+str(mntov,7)+' товар'
            if aqstr=2
               sele tov
               netrepl('mntov','mntovr')
            endif
         endif
*         if !(gnEnt=21.and.gnTpstpok=2.and.bom(gdTd)=ctod('01.09.2007'))
*         if !((gnEnt=21.or.gnEnt=20).and.gnTpstpok#0.and.bom(gdTd)=bom(gdNPrd))
*         if !(gnTpstpok#0.and.bom(gdTd)=bom(gdNPrd))
         if bom(gdTd)#bom(gdNPrd)
            if ROUND(osn,3)#osfr
               ?str(sklr,7)+' '+str(ktlr,9)+' П '+str(osfr,10,3)+' Т '+str(osn,10,3)+' остаток'
               if aqstr=2
                  sele tov
                  netrepl('osn','osfr')
               endif
            endif
            if osfr=0.and.ROUND(osn,3)#0
               ?str(sklr,7)+' '+str(ktlr,9)+' П '+str(osfr,10,3)+' Т '+str(osn,10,3)+'  остаток 0'
               if aqstr=2
                  sele tov
                  netrepl('osn','0')
               endif
            endif
         endif
         if empty(nat)
            netrepl('nat','natr')
         endif

         if nat#natr
            ?str(sklr,7)+' '+str(ktlr,9)+' П '+subs(natr,1,20)+' Т '+subs(nat,1,20)+ ' наим'
         endif
*         if osfr#0.and.roun(opt,3)#optr
         if roun(opt,3)#optr
            ?str(sklr,7)+' '+str(ktlr,9)+' П '+str(optr,10,3)+' Т '+str(opt,10,3)+ ' цена'
            if aqstr=2
               sele tov
               netrepl('opt','optr')
            endif
         endif
         if ksert<ksertr.or.kukach<kukachr
            ?str(sklr,7)+' '+str(ktlr,9)+' П '+str(ksertr,6)+' '+str(kukachr,6)+' Т '+str(ksert,6)+' '+str(kukach,6)+' серт/кач.'
            if aqstr=2
               sele tov
               netrepl('ksert,kukach','ksertr,kukachr')
            endif
         endif
         if drlz#drlzr
            netrepl('drlz','drlzr')
         endif
         if dizg#dizgr
            netrepl('dizg','dizgr')
         endif
         if cenbb#cenbbr.and.cenbbr#0
            netrepl('cenbb','cenbbr')
         endif
         if cenbt#cenbtr.and.cenbtr#0
            netrepl('cenbt','cenbtr')
         endif
         if gnEnt=21.and.gnArnd=3.and.krstat=0.and.krstat#krstatr
            ?str(sklr,7)+' '+str(ktlr,9)+' KRSTAT '+str(krstat,4)+' -> '+str(krstatr,4)
            netrepl('krstat','krstatr')
         endif
      else
         if osfr#0
            if bom(gdTd)#bom(gdNPrd)
               ?str(sklr,7)+' '+str(ktlr,9)+' нет в текущем'
            endif
            if aqstr=2
               if bom(gdTd)#bom(gdNPrd)
                  sele tovp
                  arec:={}
                  getrec()
                  sele tov
                  netadd()
                  putrec()
                  netrepl('osn,osv,osf,osfm,osvo','osfr,0,0,0,0')
               endif
            endif
         endif
      endif
      sele tovp
      skip
   endd
   ?'TOV->TOVP'
   sele tovp
   set orde to tag t1
   sele tov
   set orde to
   go top
   do while !eof()
      if otv=1
         skip
         loop
      endif
      sklr=skl
      ktlr=ktl
      prmnr=prmn
      prmn_r=prmn
      dppr=dpp
      osnr=osn
      if osn=0.and.gnMskl=0
         optr=round(opt,3)
         sele pr2
         if prmnr#0
            if netseek('t1','prmnr,ktlr')
               zenr=round(zen,3)
               if optr#zenr
                  ?str(sklr,7)+' '+str(ktlr,9)+' opt '+str(optr,10,3)+' zen '+str(zenr,10,3)+' '+str(prmnr,6)
                  if aqstr=2
                     sele tov
                     netrepl('opt','zenr')
                  endif
               endif
            else
               prmnr=0
            endif
         endif
         sele pr2
         if prmnr=0
            set orde to tag t2
            if netseek('t2','ktlr')
               do while ktl=ktlr
                  mnr=mn
                  vor=getfield('t2','mnr','pr1','vo')
                  kopr=getfield('t2','mnr','pr1','kop')
                  zenr=round(zen,3)
                  if (vor=9.or.vor=6.and.((kopr=168.or.kopr=185).and.(gnEnt=14.or.gnEnt=15.or.gnEnt=17).or.kopr=120.and.gnEnt=16)).and.optr#zenr
                     ?str(sklr,7)+' '+str(ktlr,9)+' opt '+str(optr,10,3)+' zen '+str(zenr,10,3)+' '+str(mnr,6)
                     if aqstr=2
                        sele tov
                        netrepl('opt','zenr')
                     endif
                  endif
                  sele pr2
                  skip
               endd
            else
               if prmn_r#0
                  if year(dppr)=year(gdTd).and.month(dppr)=month(gdTd)
                     sele pr1
                     if !netseek('t2','prmn_r')
                        ?'Не найден приход  '+str(prmn_r,6)+' '+str(sklr,7)+' '+str(ktlr,9)+' '+dtoc(dppr)
                        prmnr=0
                     endif
                  else
                     prmnr=0
                  endif
               else
                  if empty(dppr)
                     sele tov
                     skip
                     loop
                  endif
                  if !(year(dppr)=year(gdTd).and.month(dppr)=month(gdTd))
                     sele tov
                     skip
                     loop
                  endif
                  ?'Не найден приход c '+str(ktlr,9)+' '+dtoc(dppr)
               endif
            endif
         endif
         sele tov
         skip
         loop
      endif
      if osnr#0
         sele tovp
         if !netseek('t1','sklr,ktlr')
            ?str(sklr,7)+str(ktlr,9)+' нет в прошлом'
            if aqstr=2
               sele tov
               netrepl('osn','0')
            endif
         endif
      endif
      sele tov
      skip
   endd
   sele tov
   set orde to tag t1
   sele rs1p
   if fieldpos('nkkl')#0
      sele rs1
      if fieldpos('nkkl')#0
         go top
         do while !eof()
            ttnr=ttn
            przr=prz
            if nkkl=0
               kopr=kop
               nkklr=getfield('t1','ttnr','rs1p','nkkl')
               if nkklr#0
                  sele rs1
                  if nkkl=0
                     netrepl('nkkl','nkklr')
                     ?str(ttnr,6)+' '+str(kopr,3)+' rs1->nkkl'
                  endif
               endif
            endif
            ddcr=ddc
            ddc_r=getfield('t1','ttnr','rs1p','ddc')
            if !empty(ddc_r).and.ddcr#ddc_r
               sele rs1
               netrepl('ddc','ddc_r')
               ?str(ttnr,6)+' '+dtoc(ddcr)+' '+dtoc(ddc_r)
            endif
            sele rs1
            skip
         endd
      else
         wmess('Структура RS1',1)
      endif
   else
      wmess('Структура RS1P',1)
   endif
   nuse('tov')
   nuse('tovp')
   nuse('rs1p')
   nuse('rs2p')
   nuse('rs3p')
   nuse('pr1p')
   nuse('pr2p')
   nuse('pr3p')
else
   sele tov
   go top
   do while !eof()
      netrepl('osn','0')
      skip
   endd
endif
nuse()
if gnScOut=0
   set prin off
   set prin to
   if gnOut=2
      set prin to txt.txt
   endif
endif
wmess('Проверка закончена',0)

**************
func adoc()
**************
clea
set prin to adoc.txt
set prin on
aqstr=1
aqst:={"Просмотр","Коррекция"}
aqstr:=alert(" ",aqst)
if lastkey()=K_ESC
   retu
endif
netuse('pr1')
netuse('pr2')
netuse('tov')
netuse('tovm')
netuse('ctov')
sele pr1
do while !eof()
   if entp=0
      sele pr1
      skip
      loop
   endif
   mnr=mn
   entpr=entp
   skspr=sksp
   sklspr=sklsp
   amnpr=amnp
   sele menent
   locate for ent=entpr
   commr=comm
   if commr=0
      pather=gcPath_ini+alltrim(nent)+'\'
      pathcr=gcPath_ini+'comm\'
      netuse('cskl','ecskl')
   else
      pather=gcPath_ini+alltrim(nent)+'\'+alltrim(nent)+'\'
      pathcr=gcPath_ini+alltrim(nent)+'\comm\'
      pathr=pathcr
      netuse('cskl','ecskl',,1)
   endif
   sele ecskl
   locate for sk=skspr
   pathr=pather+gcDir_g+gcDir_d+alltrim(path)
   netuse('tov','tovs',,1)
   sele pr2
   if netseek('t1','mnr')
      do while mn=mnr
         ktlr=ktl
         ktlmr=ktlm
         mntovr=mntov
         sele tov
         if netseek('t1','gnSkl,ktlr')
            natr=nat
            osnr=osn
            osvr=osv
            osfr=osf
            osvor=osvo
            osfor=osfo
         else
            natr=''
            osnr=0
            osvr=0
            osfr=0
            osvor=0
            osfor=0
         endif
         sele tovs
         if netseek('t1','sklspr,ktlmr')
            mntovsr=mntov
            natsr=nat
         endif
         if alltrim(natr)#alltrim(natsr)
            ?str(gnSkl,7)+' '+str(ktlr,9)+' t '+str(mntovr,7)+' '+alltrim(natr)
            ?str(sklspr,7)+' '+str(ktlmr,9)+' s '+str(mntovsr,7)+' '+alltrim(natsr)
            if aqstr=2
               sele tovs
               arec:={}
               getrec()
               sele tov
               reclock()
               putrec()
               netrepl('mntov,ktl,skl,osn,osv,osf,osvo,osfo','mntovr,ktlr,gnSkl,osnr,osvr,osfr,osvor,osfor')
               natr=nat
               sele tovm
               if netseek('t1','gnSkl,mntovr')
                  reclock()
                  putrec()
                  netrepl('mntov,ktl','mntovr,0')
               endif
               sele ctov
               if netseek('t1','mntovr')
                  reclock()
                  putrec()
                  netrepl('mntov,ktl,skl,osn,osv,osf,osfo,osvo','mntovr,0,0,0,0,0,0,0')
               endif
            endif
         endif
         sele tovm
         if netseek('t1','gnSkl,mntovr')
            natmr=nat
            if alltrim(natr)#alltrim(natmr)
               ?str(gnSkl,7)+' '+str(ktlr,9)+' tov '+str(mntovr,7)+' '+alltrim(natr)
               ?str(gnSkl,7)+' '+str(ktlr,9)+' tovm '+str(mntovr,7)+' '+alltrim(natmr)
               if aqstr=2
                  sele tov
                  arec:={}
                  getrec()
                  sele tovm
                  reclock()
                  putrec()
                  netrepl('mntov,ktl','mntovr,0')
                  sele ctov
                  if netseek('t1','mntovr')
                     reclock()
                     putrec()
                     netrepl('mntov,ktl,skl,osn,osv,osf,osfo,osvo','mntovr,0,0,0,0,0,0,0')
                  endif
               endif
            endif
         else
            ?str(gnSkl,7)+' '+str(mntovr)+' не найден в target'
         endif

         sele ctov
         if netseek('t1','mntovr')
            natcr=nat
            if alltrim(natr)#alltrim(natcr)
                ?str(ktlr,9)+' tov  '+str(mntovr,7)+' '+alltrim(natr)
                ?str(ktlr,9)+' ctov '+str(mntovr,7)+' '+alltrim(natcr)
                if aqstr=2
                   sele tov
                   arec:={}
                   getrec()
                   sele ctov
                   reclock()
                   putrec()
                   netrepl('mntov','mntovr')
               endif
            endif
         else
            ?+str(mntovr)+' не найден в target'
         endif
         sele pr2
         skip
      endd
   endif
   nuse('tovs')
   nuse('ecskl')
   sele pr1
   skip
endd
nuse()
if gnScOut=0
   set prin off
   set prin to
   if gnOut=2
      set prin to txt.txt
   endif
endif
wmess('Выполните коррекцию тек.остатков',0)

**************
func ostprd()
**************
clea
crtt('ttskl','f:skl c:n(7) f:mntov c:n(7)')
sele 0
use ttskl excl
inde on str(skl,7)+str(mntov,7) tag t1
store gdTd to dt1r,dt2r
store 0 to mntov_rr,ktl_rr,skl_rr
cldeb=setcolor('w/b,n/w')
wdeb=wopen(9,20,15,60)
wbox(1)
mtovr=0
do while .t.
   @ 0,1 say 'Период c' get dt1r
   @ 0,col()+1 say 'по' get dt2r
   @ 1,1 say 'Склад ' get skl_rr pict '9999999'
   @ 2,1 say 'Товар ' get mntov_rr pict '9999999'
   @ 3,1 say 'КодТов ' get ktl_rr pict '999999999'
   read
   @ 4,1 prom 'Выполнить'
   @ 4,col()+1 prom 'Отмена'
   menu to mtovr
   if lastkey()=K_ESC
      exit
   endif
   if mtovr=1
      exit
   endif
endd
wclose(wdeb)
setcolor(cldeb)

if mtovr=1
   set prin to nfostp.txt
   set prin on
   for yyr=year(dt1r) to year(dt2r)
       pathgr=gcPath_e+'g'+str(yyr,4)+'\'
       do case
          case year(dt1r)=year(dt2r)
               mm1r=month(dt1r)
               mm2r=month(dt2r)
          case yyr=year(dt1r)
               mm1r=month(dt1r)
               mm2r=12
          case yyr=year(dt2r)
               mm1r=1
               mm2r=month(dt2r)
          othe
               mm1r=1
               mm2r=12
       endc
       for mmr=mm1r to mm2r
           pathmr=pathgr+'m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'
           pathtr=pathmr+gcDir_t
           dtr=ctod('01.'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'.'+str(yyr,4))
           dtpr=addmonth(dtr,-1)
           pathpr=gcPath_e+'g'+str(year(dtpr),4)+'\'+'m'+iif(month(dtpr)<10,'0'+str(month(dtpr),1),str(month(dtpr),2))+'\'+gcDir_t
           pathr=pathtr
           if !netfile('tov',1)
              loop
           endif
           pathr=pathpr
           if !netfile('tov',1)
               loop
           endif
           pathr=pathtr
           ?pathr
           netuse('tov','tovt',,1)
           netuse('tovm',,,1)
           netuse('rs1',,,1)
           netuse('rs2',,,1)
           netuse('pr1',,,1)
           netuse('pr2',,,1)
           pathr=pathpr
           netuse('tov','tovp',,1)
           sele ttskl
           zap
           ?'TOV'
           sele tovp
           if gnMskl=0
              sklr=gnSkl
              do case
                 case ktl_rr#0
                      set orde to tag t1
                      if netseek('t1','skl_rr,ktl_rr')
                         do while skl=skl_rr.and.ktl=ktl_rr
                            tovosn()
                            sele tovp
                            skip
                         endd
                      endif
                 case mntov_rr#0.and.ktl_rr=0
                      set orde to tag t5
                      if netseek('t5','skl_rr,mntov_rr')
                         do while skl=skl_rr.and.mntov=mntov_rr
                            tovosn()
                            sele tovp
                            skip
                         endd
                      endif
                 case mntov_rr=0.and.ktl_rr=0
                      go top
                      do while !eof()
                         tovosn()
                         sele tovp
                         skip
                      endd
              endc
           else
              if skl_rr=0
                 do case
                    case ktl_rr#0
                         set orde to tag t4
                         if netseek('t1','ktl_rr')
                            do while ktl=ktl_rr
                               tovosn()
                               sele tovp
                               skip
                            endd
                         endif
                    case mntov_rr#0.and.ktl_rr=0
                         go top
                         do while !eof()
                            if mntov#mntov_rr
                               skip
                               loop
                            endif
                            tovosn()
                            sele tovp
                            skip
                         endd
                    case mntov_rr=0.and.ktl_rr=0
                         go top
                         do while !eof()
                            tovosn()
                            sele tovp
                            skip
                         endd
                 endc
              else
                 do case
                    case ktl_rr#0
                         set orde to tag t1
                         if netseek('t1','skl_rr,ktl_rr')
                            do while skl=skl_rr.and.ktl=ktl_rr
                               tovosn()
                               sele tovp
                               skip
                            endd
                         endif
                    case mntov_rr#0.and.ktl_rr=0
                         set orde to tag t5
                         if netseek('t5','skl_rr,mntov_rr')
                            do while skl=skl_rr.and.mntov=mntov_rr
                               tovosn()
                               sele tovp
                               skip
                            endd
                         endif
                    case mntov_rr=0.and.ktl_rr=0
                         set orde to tag t1
                         if netseek('t1','skl_rr')
                            do while skl=skl_rr
                               tovosn()
                               sele tovp
                               skip
                            endd
                         endif
                 endc
              endif
           endif
           ?'TOVM'
           sele ttskl
           go top
           do while !eof()
              sklr=skl
              mntovr=mntov
              sele tovt
              set orde to tag t5
              osnr=0
              osfr=0
              if netseek('t5','sklr,mntovr')
                 do while skl=sklr.and.mntov=mntovr
                    osnr=osnr+osn
                    osfr=osfr+osf
                    sele tovt
                    skip
                 endd
              endif
              sele tovm
              if netseek('t1','sklr,mntovr')
                 if osn#osnr
                    ?str(sklr,7)+' OSN '+str(mntovr,7)+' '+str(osn,10,3)+'->'+str(osnr,10,3)
                    netrepl('osn','osnr')
                 endif
                 if osf#osfr
                    ?str(sklr,7)+' OSF '+str(mntovr,7)+' '+str(osf,10,3)+'->'+str(osfr,10,3)
                    netrepl('osf','osfr')
                 endif
              endif
              sele ttskl
              skip
           endd
           nuse('tovt')
           nuse('tovm')
           nuse('rs1')
           nuse('rs2')
           nuse('pr1')
           nuse('pr2')
           nuse('tovp')
       next
   next
   set prin off
   set prin to txt.txt
endif
nuse('ttskl')
erase ttskl.dbf
erase ttskl.cdx
wmess('Проверка закончена',0)
retu .t.

func tovosn()
arec:={}
getrec()
skl_r=skl
mntov_r=mntov
ktl_r=ktl
osfr=osf
sele ttskl
if !netseek('t1','skl_r,mntov_r')
   appe blank
   repl skl with skl_r,;
        mntov with mntov_r
endif
sele tovt
if !netseek('t1','skl_r,ktl_r')
   netadd()
   putrec()
endif
osnr=osn
if osnr#osfr
   ?str(skl_r,7)+' OSN '+str(ktl_r,9)+' '+str(osnr,10,3)+'->'+str(osfr,10,3)
   netrepl('osn','osfr')
   osnr=osn
endif
rsr=0
sele rs2
set orde to tag t6
if netseek('t6','ktl_r')
   do while ktl=ktl_r
      ttnr=ttn
      sele rs1
      if netseek('t1','ttnr')
         if skl#skl_r
            sele rs2
            skip
            loop
         endif
         if prz#1
            sele rs2
            skip
            loop
         endif
         sele rs2
         rsr=rsr+kvp
      endif
      sele rs2
      skip
   endd
endif
prr=0
sele pr2
set orde to tag t6
if netseek('t6','ktl_r')
   do while ktl=ktl_r
      mnr=mn
      sele pr1
      if netseek('t2','mnr')
         if skl#skl_r
            sele pr2
            skip
            loop
         endif
         if prz#1
            sele pr2
            skip
            loop
         endif
         sele pr2
         prr=prr+kf
      endif
      sele pr2
      skip
   endd
endif
sele tovt
osfr=osnr+prr-rsr
if osf#osfr
   ?str(skl_r,7)+' OSF '+str(ktl_r,9)+' '+str(osf,10,3)+'->'+str(osfr,10,3)
   netrepl('osf','osfr')
endif
sele tovp
retu .t.

