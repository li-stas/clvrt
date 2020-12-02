#include "common.ch"
#include "inkey.ch"
// gprZenr,gprBZenr,gprXZenr   - max % на группу
// iprZenr,iprBZenr,iprXZenr   - max % на изготовителя
// tprZenr,tprBZenr,tprXZenr   -     % на товар
// smsbzenr           - сумма скидки по 2-й цене
// smbzenr            - сумма по 2-й цене
// smsxzenr           - сумма скидки по 3-й цене
// smxzenr            - сумма по 3-й цене
aPcenr=0
if przr=0
   if (gnAdm=1.or.gnCenr=1)
      aPcen={'Прайс2','Документ2','Прайс3','Документ3'}
      aPcenr=alert('Пересчитать цены?',aPcen)
      if lastkey()=K_ESC
         retu
      endif
      if aPcenr=1.or.aPcenr=2
         prDecr=2
      else
         prDecr=0
      endif
   else // prDecr из документа
      do case
         case prDecr=1.or.prDecr=2
              aPcenr=2
         case prDecr=0
              aPcenr=4
      endc
      if prDecr=1
         aPcenr=2
      else
         aPcenr=4
      endif
   endif
endif


if select('psgr')#0
   sele psgr
   use
endif
erase psgr.dbf
erase psgr.cdx

crtt('psgr','f:kg c:n(3) f:ng c:c(20) f:pzen c:n(7,2) f:prZenp c:n(7,2) f:sMZen c:n(10,2) f:sMZenp c:n(10,2) f:smszen c:n(10,2) f:pbzen c:n(7,2) f:prBZenp c:n(7,2) f:smbzen c:n(10,2) f:smbzenp c:n(10,2) f:smsbzen c:n(10,2)')
sele 0
use psgr
index on str(kg,3) tag t1

if select('pizg')#0
   sele pizg
   use
endif
erase pizg.dbf
erase pizg.cdx
crtt('pizg','f:izg c:n(7) f:nizg c:c(20) f:pzen c:n(7,2) f:prZenp c:n(7,2) f:sMZen c:n(10,2) f:sMZenp c:n(10,2) f:smszen c:n(10,2) f:pbzen c:n(7,2) f:prBZenp c:n(7,2) f:smbzen c:n(10,2) f:smbzenp c:n(10,2) f:smsbzen c:n(10,2)')
sele 0
use pizg
index on str(izg,7) tag t1


if prdp()
   sele rs3
   if netseek('t1','ttnr,49')
      netdel()
   endif
   if kplr=20034
      tarar=0
   else
      ssf12r=getfield('t1','ttnr,12','rs3','ssf')
      if ssf12r#0
         tarar=0
      else
         tarar=1
      endif
   endif
   if aPcenr#0
       if aPcenr=1.or.aPcenr=3
         rs2pzen(1)
      else
         rs2pzen(2)
      endif
   endif

   if przr=0
      rso(21)
   endif
endif

do while .t.
   sele psgr
   zap
   sele rs2
   set orde to tag t1
   netseek('t1','ttnr')
   do while ttn=ttnr
      ktlr=ktl
      kgrr=int(ktlr/1000000)
      if kgrr<=1
         skip
         loop
      endif
      prZenr=pzen
      prZenpr=prZenp
      sMZenr=roun(kvp*zen,2)
      if (ndsr=2.or.ndsr=3.or.ndsr=5)
         sMZenpr=roun(kvp*zenp,2)
      else
         sMZenpr=roun(kvp*zenp*(1+gnNds/100),2)
      endif
      if bzen=0
         bzenr=zenr
         prBZenr=prZenr
         bzenpr=zenpr
         prBZenpr=prZenpr
         netrepl('bzen,pbzen,bzenp,prBZenp','bzenr,prBZenr,bzenpr,prBZenpr')
      endif
      if xzen=0
         xzenr=getfield('t1','sklr,ktlr','tov','opt')
         xzenpr=xzenr
         if int(ktlr/1000000)=350
            prXZenr=0 //gnPret
            prXZenpr=0 //prXZenr
         else
            if int(ktlr/1000000)>1
               prXZenr=0 //gnPre
               prXZenpr=0 //prXZenr
            else
               prXZenr=0
               prXZenpr=0
            endif
         endif
         if (ndsr=2.or.ndsr=3.or.ndsr=5)
            xzenr=ROUND(xzenpr*(prXZenr+100)/100,2)
         else
            xzenr=ROUND(xzenpr*(1+gnNds/100)*(prXZenr+100)/100,2)
         endif
         sele rs2
         netrepl('xzen,pxzen,xzenp,prXZenp','xzenr,prXZenr,xzenpr,prXZenpr')
      endif
      prBZenr=pbzen
      prBZenpr=prBZenp
      smbzenr=roun(kvp*bzen,2)
      if (ndsr=2.or.ndsr=3.or.ndsr=5)
         smbzenpr=roun(kvp*bzenp,2)
      else
         smbzenpr=roun(kvp*bzenp*(1+gnNds/100),2)
      endif

      ngrr=getfield('t1','kgrr','sgrp','ngr')

      sele psgr
      seek str(kgrr,3)
      if !FOUND()
         appe blank
         repl kg with kgrr,ng with ngrr,;
              pzen with prZenr,prZenp with prZenpr,sMZen with sMZenr,sMZenp with sMZenpr,smszen with sMZenr-sMZenpr,;
              pbzen with prBZenr,prBZenp with prBZenpr,smbzen with smbzenr,smbzenp with smbzenpr,smsbzen with smbzenr-smbzenpr
      else
         if abs(prZenr)>abs(pzen)
            repl pzen with prZenr
         endif
         if abs(prBZenr)>abs(pbzen)
            repl pbzen with prBZenr
         endif
         repl sMZen with sMZen+sMZenr,sMZenp with sMZenp+sMZenpr,smszen with smszen+sMZenr-sMZenpr,;
              smbzen with smbzen+smbzenr,smbzenp with smbzenp+smbzenpr,smsbzen with smsbzen+smbzenr-smbzenpr
      endif
      sele rs2
      skip
   enddo

   sele psgr
   go top
   sele psgr
   foot('F4,ENTER','Коррекция,Изготовитель')
   do case
      case pbzenr=0 //.and.pxzenr=0
           rckgrr=slcf('psgr',8,,,,"e:kg h:'КОД' c:n(3) e:ng h:'Наименов. группы' c:с(20) e:pzen h:'% цены' c:n(6,2) e:prZenp h:'% дог.ц' c:n(6,2)",,,1,,,,'НА ГРУППУ')
      case pbzenr=1 //.and.pxzenr=0
           rckgrr=slcf('psgr',8,,,,"e:kg h:'КОД' c:n(3) e:ng h:'Наименов. группы' c:с(20) e:pzen h:'% 1 цены' c:n(6,2) e:prZenp h:'% 1 дог.ц' c:n(6,2) e:pbzen h:'% 2 цены' c:n(6,2) e:prBZenp h:'% 2 дог.ц' c:n(6,2)",,,1,,,,'НА ГРУППУ')
   endc
   if lastkey()=K_ESC
      exit
   endif
   sele psgr
   go rckgrr
   kgrr=kg
   gprZenr=pzen
   gprZenpr=prZenp
   gsMZenr=sMZen
   gsMZenpr=sMZenp
   gsmszenr=smszen   // Сумма1 скидки суммой
   gprBZenr=pbzen
   gprBZenpr=prBZenp
   gsmbzenr=smbzen
   gsmbzenpr=smbzenp
   gsmsbzenr=smsbzen // Сумма2 скидки суммой
   do case
      case lastkey()=K_F4.and.przr=0
           clttnr=setcolor('gr+/b,n/bg')
           wttnr=wopen(10,14,15,60)
           wbox(1)
           @ 0,1 say '%  изменения 1-й цены  ' get gprZenr pict '999.99' //VALID GETACTIVE():varGet()>=gprZenpr
           @ 0,col()+1 say str(gsmszenr,10,2)
           if pbzenr=1
              if gnCenr=0
                 @ 1,1 say '%  изменения 2-й цены  ' get gprBZenr pict '999.99' //VALID GETACTIVE():varGet()>=gprBZenpr
              else
                 @ 1,1 say '%  изменения 2-й цены  ' get gprBZenr pict '999.99'  // VALID GETACTIVE():varGet()>=gprBZenpr
              endif
              @ 1,col()+1 say str(gsmsbzenr,10,2)
           endif
           read
           if pbzenr=1.and.gprBZenr=0
              @ 1,32 get gsmsbzenr pict '9999999.99' VALID prBZen(1)
              read
           endif
           wclose(wttnr)
           setcolor(clttnr)
           if lastkey()=K_ESC.or.!prdp()
              loop
           endif
           sele rs2
           if netseek('t1','ttnr')
              do while ttn=ttnr
                 ktlr=ktl
                 mntovr=mntov
                 if int(ktlr/1000000)#kgrr
                    skip
                    loop
                 endif
                 zenr=zen
                 zenpr=zenp
                 bzenr=bzen
                 bzenpr=bzenp
                 xzenr=xzen
                 xzenpr=xzenp
                 prZenr=gprZenr
                 prZenpr=prZenp
                 prBZenr=gprBZenr
                 prBZenpr=prBZenp
                 sele tov
                 if netseek('t1','sklr,ktlr')
                    zen(1)
                 endif
                 sele rs2
                 kvpr=kvp
                 svpr=roun(kvpr*zenr,2)
                 netrepl('svp,zen,pzen,bzen,pbzen',;
                         'svpr,zenr,prZenr,bzenr,prBZenr')
                 skip
              endd
           endif
      case lastkey()=K_ENTER
           do while .t.
              sele pizg
              zap
              sele rs2
              netseek('t1','ttnr')
              do while ttn=ttnr
                 if int(ktl/1000000)=kgrr
                    izgr=izg
                    nizgr=getfield('t1','izgr','kln','nkl')
                    prZenr=pzen
                    prZenpr=prZenp
                    sMZenr=roun(kvp*zen,2)
                    if (ndsr=2.or.ndsr=3.or.ndsr=5)
                       sMZenpr=roun(kvp*zenp,2)
                    else
                       sMZenpr=roun(kvp*zenp*(1+gnNds/100),2)
                    endif
                    prBZenr=pbzen
                    prBZenpr=prBZenp
                    smbzenr=roun(kvp*bzen,2)
                    if (ndsr=2.or.ndsr=3.or.ndsr=5)
                       smbzenpr=roun(kvp*bzenp,2)
                    else
                       smbzenpr=roun(kvp*bzenp*(1+gnNds/100),2)
                    endif
                    sele pizg
                    seek str(izgr,7)
                    if !FOUND()
                       appe blank
                       repl izg with izgr,nizg with nizgr,;
                            pzen with prZenr,prZenp with prZenpr,sMZen with sMZenr,sMZenp with sMZenpr,smszen with sMZenr-sMZenpr,;
                            pbzen with prBZenr,prBZenp with prBZenpr,smbzen with smbzenr,smbzenp with smbzenpr,smsbzen with smbzenr-smbzenpr
                    else
                       if abs(prZenr)>abs(pzen)
                          repl pzen with prZenr
                       endif
                       if abs(prBZenr)>abs(pbzen)
                          repl pbzen with prBZenr
                       endif
                       repl sMZen with sMZen+sMZenr,sMZenp with sMZenp+sMZenpr,smszen with smszen+sMZenr-sMZenpr,;
                            smbzen with smbzen+smbzenr,smbzenp with smbzenp+smbzenpr,smsbzen with smsbzen+smbzenr-smbzenpr
                    endif
                 endif
                 sele rs2
                 skip
              enddo
              foot('F4','Коррекция')
              sele pizg
              go top
              do case
                 case pbzenr=0 //.and.pxzenr=0
                      rcizgr=slcf('pizg',10,,8,,"e:izg h:'КОД' c:n(7) e:nizg h:'Наименов. изгот.' c:с(20) e:pzen h:'% цены' c:n(6,2) e:prZenp h:'% дог.ц' c:n(6,2)",,,,,,,,'НА ИЗГОТОВИТЕЛЯ')
                 case pbzenr=1 //.and.pxzenr=0
                      rcizgr=slcf('pizg',10,,8,,"e:izg h:'КОД' c:n(7) e:nizg h:'Наименов. изгот.' c:с(20) e:pzen h:'% 1 цены' c:n(6,2) e:prZenp h:'% 1 дог.ц' c:n(6,2) e:pbzen h:'% 2 цены' c:n(6,2) e:prBZenp h:'% 2 дог.ц' c:n(6,2)",,,,,,,'НА ИЗГОТОВИТЕЛЯ')
              endc
              if lastkey()=K_ESC
                 exit
              endif
              sele pizg
              go rcizgr
              izgr=izg
              iprZenr=pzen
              iprZenpr=prZenp
              isMZenr=sMZen
              isMZenpr=sMZenp
              ismszenr=smszen   // Сумма1 скидки суммой
              iprBZenr=pbzen
              iprBZenpr=prBZenp
              ismbzenr=smbzen
              ismbzenpr=smbzenp
              ismsbzenr=smsbzen // Сумма2 скидки суммой
              do case
                 case lastkey()=K_F4.and.przr=0
                      clttnr=setcolor('gr+/b,n/bg')
                      wttnr=wopen(10,14,15,60)
                      wbox(1)
                      @ 0,1 say '%  изменения 1-й цены  ' get iprZenr pict '999.99' VALID GETACTIVE():varGet()>=iprZenpr
                      @ 0,col()+1 say str(ismszenr,10,2)
                      if pbzenr=1
                         @ 1,1 say '%  изменения 2-й цены  ' get iprBZenr pict '999.99' VALID GETACTIVE():varGet()>=iprBZenpr
                         @ 1,col()+1 say str(ismsbzenr,10,2)
                      endif
                      read
                      if pbzenr=1.and.iprBZenr=0
                         @ 1,32 get ismsbzenr pict '9999999.99' VALID prBZen(2)
                         read
                      endif
                      wclose(wttnr)
                      setcolor(clttnr)
                      if lastkey()=K_ESC.or.!prdp()
                         loop
                      endif
                      sele rs2
                      if netseek('t1','ttnr')
                         do while ttn=ttnr
                            ktlr=ktl
                            mntovr=mntov
                            if int(ktlr/1000000)#kgrr.and.izg#izgr
                               skip
                               loop
                            endif
                            zenr=zen
                            zenpr=zenp
                            bzenr=bzen
                            bzenpr=bzenp
                            xzenr=xzen
                            xzenpr=xzenp
                            prZenr=iprZenr
                            prZenpr=prZenp
                            prBZenr=iprBZenr
                            prBZenpr=prBZenp
                            sele tov
                            if netseek('t1','sklr,ktlr')
                               zen(1)
                            endif
                            sele rs2
                            kvpr=kvp
                            svpr=roun(kvpr*zenr,2)
                            netrepl('svp,zen,pzen,bzen,pbzen',;
                                    'svpr,zenr,prZenr,bzenr,prBZenr')
                            skip
                         endd
                      endif
              endc
           enddo
   endc
enddo
if select('psgr')#0
   sele psgr
   use
endif
erase psgr.dbf
erase psgr.cdx

if select('pizg')#0
   sele pizg
   use
endif
erase pizg.dbf
erase pizg.cdx

sele rs2
set order to tag t3

*********************
// Функции
*********************

func prBZen(p1)
if p1=1 // На группу
   sele psgr
   ngprBZenr=((gsmsbzenr+gsmbzenpr)/gsmbzenpr-1)*100
   if ngprBZenr<gprBZenpr
      wmess('Низзя!!!',1)
      retu .f.
   endif
   gprBZenr=ngprBZenr
   netrepl('pbzen','gprBZenr')
else    // На изготовителя
   sele pizg
   niprBZenr=((ismsbzenr+ismbzenpr)/ismbzenpr-1)*100
   if niprBZenr<iprBZenpr
      wmess('Низзя!!!',1)
      retu .f.
   endif
   iprBZenr=niprBZenr
   netrepl('pbzen','iprBZenr')
endif
retu .t.
*****************
func prXZen(p1)
*****************
if p1=1 // На группу
   sele psgr
   gprXZenr=((gsmsxzenr+gsmxzenpr)/gsmxzenpr-1)*100
   netrepl('pxzen','gprXZenr')
else    // На изготовителя
   sele pizg
   iprXZenr=((ismsxzenr+ismxzenpr)/ismxzenpr-1)*100
   netrepl('pxzen','iprXZenr')
endif
retu .t.

*******************************************************
func rs2prc(p1)
// p1=1 текущие прайсовые цены ,договорные скидки
// p1=2 прайсовые цены по документу,скидки по документу
*******************************************************
if gnKt=1
   retu .t.
endif
pckopr=0
store 0 to pctcenr,pcptcenr,pcxtcenr,pcnofr,pcpbzenr,pcpxzenr
store '' to pccoptr,pccboptr,pccxoptr
sele rs2
set orde to tag t1
if netseek('t1','ttnr')
   do while ttn=ttnr
      ktlr=ktl
      ktlpr=ktlp
      pptr=ppt
      mntovr=mntov
      kvpr=kvp
      KolAkcr=getfield('t1','mntovr','ctov','KolAkc')
      if KolAkcr#0
         if kvpr>=KolAkcr
            sele rs2
            skip
            loop
         endif
      endif
      if fieldpos('mntovp')#0
         mntovpr=mntovp
      endif
      if mntovpr=0
         if ktlr=ktlpr
            mntovpr=mntovr
         else
            mntovpr=getfield('t1','sklr,ktlpr','tov','mntov')
         endif
      endif
      if ktlr=1
         netdel()
         skip
         loop
      endif
      kvpr=kvp
      svp_r=svp
      if fieldpos('bsvp')#0
         bsvp_r=bsvp
         xsvp_r=xsvp
      else
         bsvp_r=0
         xsvp_r=0
      endif
      sr_r=sr
      if kvpr=0
         netdel()
         skip
         loop
      endif
      zenr=zen
      prZenr=pzen
      zenpr=zenp
      prZenpr=prZenp
      bzenr=bzen
      prBZenpr=prBZenp
      prBZenr=pbzen
      bzenpr=bzenp
      xzenr=xzen
      prXZenr=pxzen
      xzenpr=xzenp
      prXZenpr=prXZenp
      if fieldpos('MZen')#0
         MZenr=MZen
      else
         MZenr=0
      endif
      if fieldpos('tcenp')#0
         rcenpr=tcenp
      else
         rtcenpr=0
      endif
      sele tov
      if netseek('t1','sklr,ktlr')
         if p1=1
            zen()
         else
            zen(1)
         endif

         sele tov
         optr=opt
         MZenr=c24

         sele rs2
         srr=roun(optr*kvp,2)
         svpr=roun(zenr*kvp,2)
         bsvpr=roun(bzenr*kvp,2)
         xsvpr=roun(xzenr*kvp,2)
         netrepl('svp,sr,zen,pzen,bzen,pbzen,zenp,prZenp,bzenp,prBZenp,xzen,pxzen,xzenp,prXZenp',;
                 'svpr,srr,zenr,prZenr,bzenr,prBZenr,zenpr,prZenpr,bzenpr,prBZenpr,xzenr,prXZenr,xzenpr,prXZenpr')
         if fieldpos('bsvp')#0
            netrepl('bsvp,xsvp','bsvpr,xsvpr')
         endif
         if fieldpos('tcenp')#0
            netrepl('tcenp','rtcenpr')
         endif
         if fieldpos('MZen')#0
            if round(MZen,3)#round(MZenr,3)
               netrepl('MZen','MZenr')
            endif
         endif
         if fieldpos('mntovp')#0
            mntovpr=mntovp
         endif
         if mntovpr=0
            if ktlr=ktlpr
               mntovpr=mntovr
            else
               mntovpr=getfield('t1','sklr,ktlpr','tov','mntov')
            endif
         endif
         if gnCtov=1
            sele rs2m
            if netseek('t3','ttnr,mntovpr,pptr,mntovr')
               netrepl('svp,sr,zenp,prZenp,bzenp,prBZenp,xzenp,prXZenp',;
                       'svp-svp_r+svpr,sr-sr_r+srr,zenpr,prZenpr,bzenpr,prBZenpr,xzenpr,prXZenpr')
               if fieldpos('bsvp')#0
                  netrepl('bsvp,xsvp','bsvp-bsvp_r+bsvpr,xsvp-xsvp_r+xsvpr')
               endif
               if fieldpos('MZen')#0
                  if round(MZen,3)#round(MZenr,3)
                     netrepl('MZen','MZenr')
                  endif
               endif
               zenmr=zenr
               prZenmr=prZenr
               bzenmr=bzenr
               prBZenmr=prBZenr
               xzenmr=xzenr
               prXZenmr=prXZenr
               if otv>1
                  if (ndsr=2.or.ndsr=3.or.ndsr=5)
                     zenmr=ROUND(svp/kvp,2)
                  else
                     zenmr=ROUND(svp/kvp,2)
                  endif
                  prZenmr=roun((zenmr/zenpr-1)*100,2)
                  if fieldpos('bsvp')#0
                     if (pndsr=2.or.pndsr=3.or.pndsr=5)
                        bzenmr=ROUND(bsvp/kvp,2)
                     else
                        bzenmr=ROUND(bsvp/kvp,2)
                     endif
                     if (xndsr=2.or.xndsr=3.or.xndsr=5)
                        xzenmr=ROUND(xsvp/kvp,2)
                     else
                        xzenmr=ROUND(xsvp/kvp,2)
                     endif
                     prBZenmr=roun((bzenmr/bzenpr-1)*100,2)
                     prXZenmr=roun((xzenmr/xzenpr-1)*100,2)
                  endif
               endif
               netrepl('zen,pzen,bzen,pbzen,xzen,pxzen',;
                          'zenmr,prZenmr,bzenmr,prBZenmr,xzenmr,prXZenmr')
            endif
         endif
      endif
      sele rs2
      skip
   endd
endif
sele rs1
if fieldpos('prDec')#0
   netrepl('prDec','prDecr')
endif
if p1=1.and.aPcenr#3
   sele rs1
   if kopi#177
      netrepl('kopi','kopr',1)
   endif
endif

if p1=1
   if gnScOut=0
      @ 2,14 say str(rs1->kop,3)+'('+str(rs1->kopi,3)+')'+' '+nopr
   endif
   if kopir#177
      kopir=kopr
   endif
   nds_fr=ndsr
   pnds_fr=pndsr
   xnds_fr=xndsr
   kop_fr=kopr
   nKkl_fr=nKkl
   if fieldpos('prDec')#0
      prDec_fr=prDec
   else
      prDec_fr=0
   endif
   nof_fr=nofr
endif
retu .t.

***************************************************************
func zen(p1,p2,p3)  // Цены
// p1 0 - по текущему прайсу; 1 - коррекция по прайсу документа
// p2 - ktl
// p3 - mntov
***************************************************************

local ktl_rr,mntov_rr


if !empty(p2)
   ktl_rr=ktlr
   ktlr=p2
endif

if !empty(p3)
   mntov_rr=mntovr
   mntovr=p3
endif

store 0 to rcmntovr,rcmntovtr
if gnCtov#1
   sele tov
   mntovtr=0
else
   sele ctov
   if !netseek('t1','mntovr')
      wmess('Не найден в CTOV',3)
      quit
   else
      mntovtr=mntovt
      rcmntovr=recn()
      if mntovtr=0
         mntovtr=mntovr
         rcmntovtr=rcmntovr
      else
         if !netseek('t1','mntovtr')
            mntovtr=mntovr
            rcmntovtr=rcmntovr
         else
            rcmntovtr=recn()
         endif
      endif
      go rcmntovr
   endif
endif

izgr=izg
mkeepr=mkeep
brandr=brand
kgr_r=int(mntovr/10000)

if fieldpos('blksk')#0
   blkskr=blksk
else
   blkskr=0
endif

if gnVo=9.and.kopir#177
   sele klnnac
   if fieldpos('tcen')=0
      viptcenr=0
   else
      viptcenr=getfield('t1','nkklr,izgr,kgr_r','klnnac','tcen')
      if viptcenr=0
         viptcenr=getfield('t1','nkklr,izgr,999','klnnac','tcen')
      endif
   endif
   if viptcenr=0
      kgptcenr=0
      kgpnacr=0
      kgpnac1r=0
      sele kgptm
      if netseek('t1','kpvr,mkeepr')
         kgptcenr=tcen
         kgpnacr=nac
         kgpnac1r=nac
      endif
      if kgptcenr=0
         knaspr=getfield('t1','kpvr','kln','knasp')
         kgpcatr=getfield('t1','kpvr','kgp','kgpcat')
         if knaspr#0
            sele nasptm
            if kgpcatr#0
               if netseek('t2','knaspr,kgpcatr,mkeepr')
                  kgptcenr=tcen
                  kgpnacr=nac
                  kgpnac1r=nac
               endif
            endif
            if kgptcenr=0
               if netseek('t2','knaspr,0,mkeepr')
                  kgptcenr=tcen
                  kgpnacr=nac
                  kgpnac1r=nac
               endif
            endif
         endif
      endif
      if kgptcenr=0
         krnr=getfield('t1','kpvr','kln','krn')
         kgpcatr=getfield('t1','kpvr','kgp','kgpcat')
         if krnr#0
            sele rntm
            if kgpcatr#0
               if netseek('t2','krnr,kgpcatr,mkeepr')
                  kgptcenr=tcen
                  kgpnacr=nac
                  kgpnac1r=nac
               endif
            endif
            if kgptcenr=0
               sele krntm
               if netseek('t1','krnr,mkeepr')
                  kgptcenr=tcen
                  kgpnacr=nac
                  kgpnac1r=nac
               endif
            endif
         endif
      endif
      if kgptcenr#0
         viptcenr=kgptcenr
      endif
   endif
else
   viptcenr=0
endif

if gnCtov=1
   sele ctov
else
   sele tov
endif

if viptcenr#0
   cvipoptr=alltrim(getfield('t1','viptcenr','tcen','zen'))
   if gnEnt=21
      vipzenr=getfield('t1','mntovtr','ctov',cvipoptr)
      cenprr=getfield('t1','mntovtr','ctov','cenpr')
   else
      vipzenr=&cvipoptr //cvipzenr
      cenprr=cenpr
   endif
   rtcenpr=viptcenr
else
   rtcenpr=tcenr
endif

if empty(p1).or.nKklr#nKkl_fr.and.corsh=1.or.prDecr#prDec_fr
   if aPcenr#3
      if kopr=191
         if viptcenr=0
            zenr  =roun(cenprr*(1+gnNds/100),2)
         else
            zenr  =roun(vipzenr*(1+gnNds/100),2)
         endif
         zenpr =cenprr
      else
         if viptcenr=0
            if coptr#'opt'
               if gnEnt=21
                  zenr=getfield('t1','mntovtr','ctov',coptr)
               else
                  zenr  =&coptr
               endif
            else
               zenr  =tov->&coptr
            endif
            zenpr =zenr
         else
            if cvipoptr#'opt'
               if gnEnt=21
                  zenr=getfield('t1','mntovtr','ctov',cvipoptr)
               else
                  zenr  =&cvipoptr
               endif
            else
               zenr  =tov->&cvipoptr
            endif
            zenpr =zenr
         endif
      endif
      if nofr=1
         bzenr =zenr
         bzenpr=zenpr
         if int(ktlr/1000000)>1
            xzenr=tov->opt
            xzenpr=xzenr
         else
            if zenr=0
               xzenr=zenr
               xzenpr=zenpr
            else
               xzenr=tov->opt
               xzenpr=xzenr
            endif
         endif
      else
         if pbzenr=1
            if cboptr#'opt'
               if gnEnt=21
                  bzenr=getfield('t1','mntovtr','ctov',cboptr)
               else
                  bzenr =&cboptr
               endif
            else
               bzenr =tov->&cboptr
            endif
            bzenpr=bzenr
         else
            bzenr=zenr
            bzenpr=zenpr
         endif
         if pxzenr=1
            if cxoptr#'opt'
               if gnEnt=21
                  xzenr=getfield('t1','mntovtr','ctov',cxoptr)
               else
                  xzenr=&cxoptr
               endif
            else
               xzenr=tov->&cxoptr
            endif
            xzenpr=xzenr
         else
            xzenr=tov->opt
            xzenpr=xzenr
         endif
      endif
   else    // Выбор прайса
      if pckopr=191
         if vipzenr=0
            zenr  =roun(cenprr*(1+gnNds/100),2)
         else
            zenr  =roun(vipzenr*(1+gnNds/100),2)
         endif
         zenpr =cenpr
      else
         if vipzenr=0
            if pccoptr#'opt'
               if gnEnt=21
                  zenr=getfield('t1','mntovtr','ctov',pccoptr)
               else
                  zenr  =&pccoptr
               endif
            else
               zenr  =tov->&pccoptr
            endif
         else
            if cvipoptr#'opt'
               if gnEnt=21
                  zenr=getfield('t1','mntovtr','ctov',cvipoptr)
               else
                  zenr  =&cvipoptr
               endif
            else
               zenr  =tov->&cvipoptr
            endif
         endif
         zenpr =zenr
      endif
      if pcnofr=1
         bzenr =zenr
         bzenpr=zenpr
         if int(ktlr/1000000)>1
            xzenr=tov->opt
            xzenpr=xzenr
         else
            if zenr=0
               xzenr=zenr
               xzenpr=zenpr
            else
               xzenr=tov->opt
               xzenpr=xzenr
            endif
         endif
      else
         if pcpbzenr=1
            if gnEnt=21
               bzenr=getfield('t1','mntovtr','ctov',pccboptr)
            else
               bzenr =&pccboptr
            endif
            bzenpr=bzenr
         else
            bzenr=zenr
            bzenpr=zenpr
         endif
         if pcpxzenr=1
            if gnEnt=21
               xzenr=getfield('t1','mntovtr','ctov',pccxoptr)
            else
               xzenr=&pccxoptr
            endif
            xzenpr=xzenr
         else
            xzenr=tov->opt
            xzenpr=xzenr
         endif
      endif
   endif
else
   // Из документа
   if nofr=1
      bzenpr=zenpr
      if int(ktlr/1000000)>1
         xzenpr=tov->opt
      else
         xzenpr=zenpr
      endif
   endif
endif

// Договорные скидки
store 0 to nprZenpr,nprBZenpr,nprXZenpr,MinZen1r
kgrr=int(ktlr/1000000)
if doguslr=1.and.kopir#177.and.(blkskr=0.or.blkskr=1.and.viptcenr#0)
   if brandr#0
      if kgrr>1
         if select('mnnac')#0
            sele mnnac
            if netseek('t1','nkklr,brandr,mntovr')
               nprZenpr=nac
               nprBZenpr=Nac1
               MinZen1r=MinZen1
            endif
         endif
         if nprZenpr=0
            store 0 to nprZenpr,nprBZenpr,nprXZenpr,MinZen1r
            sele brnac
            if netseek('t1','nkklr,mkeepr,brandr')
               nprZenpr=nac
               nprBZenpr=Nac1
               MinZen1r=MinZen1
            endif
         endif
      endif
   endif
   if nprZenpr=0
      store 0 to nprZenpr,nprBZenpr,nprXZenpr,MinZen1r
      if kgrr>1
         sele klnnac
         IF !netseek('t1','nKklr')
            sele mkeepe
            IF netseek('t2','izgr') .AND. !DELETED() //ДА!!!!!!!!!!!!
               nprZenpr=0
               nprBZenpr=0
               MinZen1r=0
            ELSE               //нет - по  //общий процент
               sele kpl
               if netseek('t1','nKKLr')
                  nprZenpr=nac
                  nprBZenpr=nac1
                  MinZen1r=0
               endif
            ENDIF
         ELSE
            sele mkeepe
            IF NetSeek('t2','izgr').AND. !DELETED() //ДА!!!!!!!!!!!!
               sele klnnac
               IF !NetSeek('t1','nKklr,izgr')   //нет такого изготовителя
                  nprZenpr=0
                  nprBZenpr=0
                  MinZen1r=0
                  viptcenr=0
               ELSE            //изготовитель такой есть!!!
                  sele klnnac
                  IF !NetSeek("T1", "nKklr, Izgr, 999")
//                     wmess('Проблемы с таблицей Условий, должна быть группа 999', 3)
                     nprZenpr=0
                     nprBZenpr=0
                     MinZen1r=0
                  else
                     nprZenpr=nac
                     nprBZenpr=nac1
                     MinZen1r=MinZen1
                  endif
                  if nprZenpr=0
                     if netseek("T1", "nKklr, Izgr, kgrr")
                        nprZenpr=nac
                     endif
                  endif
                  if nprBZenpr=0
                     if netseek("T1", "nKklr, Izgr, kgrr")
                        nprBZenpr=nac1
                        MinZen1r=MinZen1
                     endif
                  endif
               ENDIF
            ELSE               // не маркодержатель в klnnac
               sele kpl
               if netseek('t1','nKKLr')
                  nprZenpr=nac
                  nprBZenpr=nac1
                  MinZen1r=0
               endif
            ENDIF
         ENDIF
      ENDIF // kgrr>1
   endif  // nprZenpr=0(brand)
endif

// Если есть наценка по грузополучателю
if gnVo=9.and.kopir#177.and.kgrr>1.and.blkskr=0
   if viptcenr=0
      if nprZenpr=0
         nprZenpr=kgpnacr
      endif
      if nprBZenpr=0
         nprBZenpr=kgpnac1r
      endif
   endif
endif


******************************************************
// Условия автоматического пересчета цен
******************************************************
if empty(p1).or.nKklr#nKkl_fr.and.corsh=1.and.kopir#177.and.blkskr=0.or.prDecr#prDec_fr
   if gnVo=9.or.gnVo=2
      prZenr=nprZenpr
      prZenpr=nprZenpr
   else
      if kopr=186 // Комиссия
         prZenr=1
         prZenpr=1
      else
         prZenr=0
         prZenpr=0
      endif
   endif
   if gnVo=9.or.gnVo=2
      prBZenr=nprBZenpr
      prBZenpr=nprBZenpr
   else
      prBZenr=0 //nprBZenpr
      prBZenpr=0 //nprBZenpr
   endif
   if gnVo=9.or.gnVo=2
      if nofr=1.or.pxzenr=0
         if int(ktlr/1000000)=350
            prXZenr=0 //gnPret
            prXZenpr=0 //gnPret
         else
            if int(ktlr/1000000)>1
               prXZenr=0 //gnPre
               prXZenpr=0 //gnPre
            else
               prXZenr=0
               prXZenpr=0
            endif
         endif
      else
         prXZenr=nprXZenpr
         prXZenpr=nprXZenpr
      endif
   else
      prXZenr=0
      prXZenpr=0
   endif
endif
********************************************************

// Расчет новых цен
if nofr=1
   if (ndsr=2.or.ndsr=3.or.ndsr=5)
      zenr=ROUND(zenpr*(prZenr+100)/100,2)
      bzenr=ROUND(bzenpr*(prBZenr+100)/100,2)
      xzenr=ROUND(xzenpr*(prXZenr+100)/100,2)
   else
      zenr=ROUND(zenpr*(1+gnNds/100)*(prZenr+100)/100,2)
      bzenr=ROUND(bzenpr*(1+gnNds/100)*(prBZenr+100)/100,2)
      xzenr=ROUND(xzenpr*(1+gnNds/100)*(prXZenr+100)/100,2)
      if zenr=0.and.int(ktlr/1000000)>1
         zenr=0.01
      endif
      if bzenr=0.and.int(ktlr/1000000)>1
         bzenr=0.01
      endif
      if xzenr=0.and.int(ktlr/1000000)>1
         xzenr=0.01
      endif
   endif
else
   if (ndsr=2.or.ndsr=3.or.ndsr=5)
      zenr=ROUND(zenpr*(prZenr+100)/100,2)
   else
      if kopr=191
         zenr=ROUND(zenpr*(1+gnNds/100)*(prZenr+100)/100,2)
      else
         zenr=ROUND(zenpr*(prZenr+100)/100,2)
      endif
      if zenr=0.and.int(ktlr/1000000)>1
         zenr=0.01
      endif
   endif
//   if pbzenr=1
      if (pndsr=2.or.pndsr=3.or.pndsr=5)
         bzenr=ROUND(bzenpr*(prBZenr+100)/100,2)
      else
         if kopr=191
            bzenr=ROUND(bzenpr*(1+gnNds/100)*(prBZenr+100)/100,2)
         else
            bzenr=ROUND(bzenpr*(prBZenr+100)/100,2)
         endif
      endif
      if bzenr=0.and.int(ktlr/1000000)>1
         bzenr=0.01
      endif
//   endif
//   if pxzenr=1
      if (xndsr=2.or.xndsr=3.or.xndsr=5)
         xzenr=ROUND(xzenpr*(prXZenr+100)/100,2)
      else
         if kopr=191
            xzenr=ROUND(xzenpr*(1+gnNds/100)*(prXZenr+100)/100,2)
         else
            xzenr=ROUND(xzenpr*(prXZenr+100)/100,2)
         endif
      endif
      if xzenr=0.and.int(ktlr/1000000)>1
         xzenr=0.01
      endif
//   endif
endif

// Проверка 1-й цены на минимальную и входную
if gnCtov=1
   sele ctov
else
   sele tov
endif

if empty(p1).or.nKklr#nKkl_fr.and.corsh=1.or.prDecr#prDec_fr
   MZenr=c24
else
   if MZenr=0
      MZenr=c24
   endif
endif
optr=tov->opt
if fieldpos('noopt')#0
   nooptr=noopt
else
   nooptr=0
endif
MZen_rr=MZenr
opt_rr=optr

//нормализируем цену минимальную
IF !(ndsr=5.or.ndsr=3.or.ndsr=2)
   MZenr=round(MZenr*(1+gnNds/100),2)
ENDIF
//нормализируем цену закупочную
IF !(ndsr=5.or.ndsr=3.or.ndsr=2)
   optr:=round(optr*(1+gnNds/100), 2)
ENDIF

// sele kln
// if netseek('t1','nKKLr')
//   ChkNZenr=ChkNZen
// else
//   ChkNZenr=.f.
// endif


prMZenr=getfield('t1','nkklr','kpl','prMZen')

if gnEnt=20
   if (empty(p1).or.nKklr#nKkl_fr.and.corsh=1.or.prDecr#prDec_fr).and.int(ktlr/1000000)>1
      if gnVo=9.or.gnVo=2
         IF IIF(prMZenr=0,EMPTY(MZenr),.T.)
//            IF zenr<optr.and.(gnEnt#20.or.gnEnt=20.and.!(mkeepr=92.or.mkeepr=25.or.mkeepr=85)) //меньше получилось
            IF zenr<optr //меньше получилось
               if nooptr=0
                  zenr:=optr
               endif
            ENDIF
         ELSE
//            IF zenr<MZenr.and.(gnEnt#20.or.gnEnt=20.and.!(mkeepr=92.or.mkeepr=25.or.mkeepr=85))  //меньше получилось
            IF zenr<MZenr  //меньше получилось
               if nooptr=0
                  zenr:=MZenr
               endif
            ENDIF
         ENDIF
//         if MZenr#0.and.MinZen1r=0.and.nofr=1.and.(gnEnt#20.or.gnEnt=20.and.!(mkeepr=92.or.mkeepr=25.or.mkeepr=85))
         if MZenr#0.and.MinZen1r=0.and.nofr=1
            if bzenr<MZenr
               if nooptr=0
                  bzenr=MZenr
               endif
            endif
         endif
//         if MinZen1r=1.and.nofr=1.and.(gnEnt#20.or.gnEnt=20.and.!(mkeepr=92.or.mkeepr=25.or.mkeepr=85))
         if MinZen1r=1.and.nofr=1
            if bzenr<optr
               bzenr=optr
            endif
         endif
      else
//         IF zenr<optr.and.(gnEnt#20.or.gnEnt=20.and.!(mkeepr=92.or.mkeepr=25.or.mkeepr=85))
         IF zenr<optr
            if nooptr=0
               zenr:=optr
            endif
         ENDIF
//         IF bzenr<optr.and.nofr=1.and.(gnEnt#20.or.gnEnt=20.and.!(mkeepr=92.or.mkeepr=25.or.mkeepr=85))
         IF bzenr<optr.and.nofr=1
            if nooptr=0
               bzenr:=optr
            endif
         ENDIF
      endif
   endif
else
   if (empty(p1).or.nKklr#nKkl_fr.and.corsh=1.or.prDecr#prDec_fr).and.int(ktlr/1000000)>1
      if gnVo=9.or.gnVo=2
         IF IIF(prMZenr=1,EMPTY(MZenr),.T.)
//            IF zenr<optr.and.(gnEnt#20.or.gnEnt=20.and.!(mkeepr=92.or.mkeepr=25.or.mkeepr=85)) //меньше получилось
            IF zenr<optr //меньше получилось
               if nooptr=0
                  zenr:=optr
               endif
            ENDIF
         ELSE
//            IF zenr<MZenr.and.(gnEnt#20.or.gnEnt=20.and.!(mkeepr=92.or.mkeepr=25.or.mkeepr=85))  //меньше получилось
            IF zenr<MZenr  //меньше получилось
               if nooptr=0
                  zenr:=MZenr
               endif
            ENDIF
         ENDIF
//         if MZenr#0.and.MinZen1r=0.and.nofr=1.and.(gnEnt#20.or.gnEnt=20.and.!(mkeepr=92.or.mkeepr=25.or.mkeepr=85))
         if MZenr#0.and.MinZen1r=0.and.nofr=1
            if bzenr<MZenr
               if nooptr=0
                  bzenr=MZenr
               endif
            endif
         endif
//         if MinZen1r=1.and.nofr=1.and.(gnEnt#20.or.gnEnt=20.and.!(mkeepr=92.or.mkeepr=25.or.mkeepr=85))
         if MinZen1r=1.and.nofr=1
            if bzenr<optr
               if nooptr=0
                  bzenr=optr
               endif
            endif
         endif
      else
//         IF zenr<optr.and.(gnEnt#20.or.gnEnt=20.and.!(mkeepr=92.or.mkeepr=25.or.mkeepr=85))
         IF zenr<optr
            if nooptr=0
               zenr:=optr
            endif
         ENDIF
//         IF bzenr<optr.and.nofr=1.and.(gnEnt#20.or.gnEnt=20.and.!(mkeepr=92.or.mkeepr=25.or.mkeepr=85))
         IF bzenr<optr.and.nofr=1
            if nooptr=0
               bzenr:=optr
            endif
         ENDIF
      endif
   endif
endif


// Проверка на индикатив
// Индикатив(без НДС)
if gnVo=9.or.gnVo=2
   sele tov
   vespr=vesp
   keipr=keip
   if gnCtov=1
      sele cgrp
      if netseek('t1','int(ktlr/1000000)').and.vespr#0.and.keipr#0
         grkeir=grkei
      else
         grkeir=0
      endif
      if grkeir=keipr.and.grkeir#0
         indloptr=indlopt
         indlrozr=indlroz
         indloptr=ROUND(indloptr*vespr,3)
         indlrozr=ROUND(indlrozr*vespr,3)
      else
         indloptr=0
         indlrozr=0
      endif
   else
      indloptr=0
      indlrozr=0
   endif

   if kopr=191 // Розница
      if indlrozr#0
         if zenr<roun(indlrozr*(1+gnNds/100),2)
            zenr=roun(indlrozr*(1+gnNds/100),2)
         endif
         if nofr=1
            if bzenr<roun(indlrozr*(1+gnNds/100),2)
               bzenr=roun(indlrozr*(1+gnNds/100),2)
            endif
            if xzenr<roun(indlrozr*(1+gnNds/100),2)
               xzenr=roun(indlrozr*(1+gnNds/100),2)
            endif
         endif
      endif
   else        // Опт
      if indloptr#0
         if zenr<indloptr
            zenr=indloptr
         endif
         if nofr=1
            if bzenr<indloptr
               bzenr=indloptr
            endif
            if xzenr<indloptr
               xzenr=indloptr
            endif
         endif
      endif
   endif

   // Проверка 2-й цены на 1-ю

   if bzenr>zenr.and.nofr=1
      bzenr=zenr
      prBZenr=prZenr
   endif

   // Проверка 2-й цены на 3-ю
   if bzenr<xzenr.and.nofr=1
//      bzenr=xzenr
//      prBZenr=prXZenr
   endif
endif
if int(ktlr/1000000)<2
   if zenr=0
      bzenr=0
      xzenr=0
   endif
endif
sele rs2

RpZen(0)
ktlr=ktl_rr
MZenr=MZen_rr
optr=opt_rr
retu

******************
func chkzen1(p1)
******************
local ktl_rrr
if gnKt=1
   retu .t.
endif
if !empty(p1)
   ktl_rrr=ktlr
   ktlr=p1
endif
// if zenr<nzenr
//   if gnCenr=0.and.gnAdm=0
//      wmess('Низзя!!!',1)
//      retu .f.
//   else
      rpzen(1)
ktlr=ktl_rrr
      retu .t.
//   endif
// else
//   rpzen(1)
//   retu .t.
// endif
// retu .t.
*******************
func chkzenm1(p1)
*******************
if gnKt=1
   retu .t.
endif
// local mntov_rrr
// if !empty(p1)
//   mntov_rrr=mntovr
//   mntovr=p1
// endif
// rpzen(1)
// mntovr=mntov_rrr
retu .t.

func rpzen(p1)
// Расчет реального процента наценки
if nofr=1
   if (ndsr=2.or.ndsr=3.or.ndsr=5)
      if p1=0.or.p1=1
         if int(ktlr/1000000)<2.and.zenr=0
            prZenr=0
         else
            if zenpr#0
               if zenr#0
                  prZenr=roun((zenr/zenpr-1)*100,2)
               else
                  prZenr=0
               endif
            else
               prZenr=0
            endif
         endif
      endif
      if p1=0.or.p1=2
         if int(ktlr/1000000)<2.and.bzenr=0
            prBZenr=0
         else
            if bzenpr#0
               if bzenr#0
                  prBZenr=roun((bzenr/bzenpr-1)*100,2)
               else
                  prBZenr=0
               endif
            else
               prBZenr=0
            endif
         endif
      endif
      if p1=0.or.p1=3
         if int(ktlr/1000000)<2.and.xzenr=0
            prXZenr=0
         else
            if xzenpr#0
               if xzenr#0
                  prXZenr=roun((xzenr/xzenpr-1)*100,2)
               else
                  prXZenr=0
               endif
            else
               prXZenr=0
            endif
         endif
      endif
   else
      if p1=0.or.p1=1
         if int(ktlr/1000000)<2.and.zenr=0
            prZenr=0
         else
            if zenpr#0
//               prZenr=roun((zenr/(zenpr*(1+gnNds/100))-1)*100,2)
               prZenr=roun((zenr/(roun(zenpr*(1+gnNds/100),2))-1)*100,2)
            else
               prZenr=0
            endif
         endif
      endif
      if p1=0.or.p1=2
         if int(ktlr/1000000)<2.and.bzenr=0
            prBZenr=0
         else
            if bzenpr#0
//               prBZenr=roun((bzenr/(bzenpr*(1+gnNds/100))-1)*100,2)
               prBZenr=roun((bzenr/(roun(bzenpr*(1+gnNds/100),2))-1)*100,2)
            else
               prBZenr=0
            endif
         endif
      endif
      if p1=0.or.p1=3
         if int(ktlr/1000000)<2.and.xzenr=0
            prXZenr=0
         else
            if xzenpr#0
//               prXZenr=roun((xzenr/(xzenpr*(1+gnNds/100))-1)*100,2)
               prXZenr=roun((xzenr/(roun(xzenpr*(1+gnNds/100),2))-1)*100,2)
            else
               prXZenr=0
            endif
         endif
      endif
   endif
else
   if (ndsr=2.or.ndsr=3.or.ndsr=5)
      if p1=0.or.p1=1
         if int(ktlr/1000000)<2.and.zenr=0
            prZenr=0
         else
            if zenpr#0
               prZenr=roun((zenr/zenpr-1)*100,2)
               if prZenr>999.99
                  prZenr=999.99
               endif
            else
               prZenr=0
            endif
         endif
      endif
      if p1=0.or.p1=2
         if int(ktlr/1000000)<2.and.bzenr=0
            prBZenr=0
         else
            if bzenpr#0
               prBZenr=roun((bzenr/bzenpr-1)*100,2)
               if prBZenr>999.99
                  prBZenr=999.99
               endif
            else
               prBZenr=0
            endif
        endif
      endif
      if p1=0.or.p1=3
         if int(ktlr/1000000)<2.and.xzenr=0
            prXZenr=0
         else
            if xzenpr#0
               prXZenr=roun((xzenr/xzenpr-1)*100,2)
               if prXZenr>999.99
                  prXZenr=999.99
               endif
            else
               prXZenr=0
            endif
         endif
      endif
   else
      if p1=0.or.p1=1
         if int(ktlr/1000000)<2.and.zenr=0
            prZenr=0
         else
            if zenpr#0
               if kopr=191
//                  prZenr=roun((zenr/(zenpr*(1+gnNds/100))-1)*100,2)
                   prZenr=roun((zenr/(roun(zenpr*(1+gnNds/100),2))-1)*100,2)
                   if prZenr>999.99
                      prZenr=999.99
                   endif
               else
                   prZenr=roun((zenr/zenpr-1)*100,2)
                   if prZenr>999.99
                      prZenr=999.99
                   endif
               endif
            else
               prZenr=0
            endif
         endif
      endif
      if p1=0.or.p1=2
         if int(ktlr/1000000)<2.and.bzenr=0
            prBZenr=0
         else
            if bzenpr#0
               if kopr=191
//                  prBZenr=roun((bzenr/(bzenpr*(1+gnNds/100))-1)*100,2)
                  prBZenr=roun((bzenr/(roun(bzenpr*(1+gnNds/100),2))-1)*100,2)
                  if prBZenr>999.99
                     prBZenr=999.99
                  endif
               else
                   prBZenr=roun((bzenr/bzenpr-1)*100,2)
                  if prBZenr>999.99
                     prBZenr=999.99
                  endif
               endif
            else
               prBZenr=0
            endif
        endif
      endif
      if p1=0.or.p1=3
         if int(ktlr/1000000)<2.and.xzenr=0
            prXZenr=0
         else
            if xzenpr#0
               if kopr=191
//                  prXZenr=roun((xzenr/(xzenpr*(1+gnNds/100))-1)*100,2)
                  prXZenr=roun((xzenr/(roun(xzenpr*(1+gnNds/100),2))-1)*100,2)
                  if prXZenr>999.99
                     prXZenr=999.99
                  endif
               else
                  prXZenr=roun((xzenr/xzenpr-1)*100,2)
                  if prXZenr>999.99
                     prXZenr=999.99
                  endif
               endif
            else
               prXZenr=0
            endif
         endif
      endif
   endif
endif

retu .t.
****************
func chkzen2()
***************
if gnKt=1
   retu .t.
endif

if bzenr<xzenr.and.nofr=1
   if gnCenr=0.and.gnAdm=0
       wmess('Низзя!!!',1)
       retu .f.
   else
       rpzen(2)
       retu .t.
   endif
else
   rpzen(2)
   retu .t.
endif
retu .t.
***************
func chkzen3()
***************
if gnKt=1
   retu .t.
endif
if xzenr<optr.and.nofr=1
   if gnCenr=0.and.gnAdm=0
//       wmess('Низзя!!!',1)
//       retu .f.
   else
       rpzen(3)
       retu .t.
   endif
else
   rpzen(3)
   retu .t.
endif
retu .t.

****************
func chkzenm2()
****************
if gnKt=1
   retu .t.
endif

if bzenmr<xzenmr.and.nofr=1
   if gnCenr=0.and.gnAdm=0
//       wmess('Низзя!!!',1)
//       retu .f.
   else
//       rpzen(2)
       retu .t.
   endif
else
//   rpzen(2)
   retu .t.
endif
retu .t.

func chkzenm3()
if gnKt=1
   retu .t.
endif
retu .t.


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  04-10-17 * 01:41:46pm
 НАЗНАЧЕНИЕ......... ввод цены по акции на Количество
 ПАРАМЕТРЫ..........  // p1 mntov   // p2 kol
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION ZenAk(p1,p2)
  local kol_rr, nZenRoz:=0
  mntov_rr=p1
  kol_rr=p2

  if kol_rr#0
     mntovt_rr=getfield('t1','mntov_rr','ctov','mntovt')
     KolAkc_rr=getfield('t1','mntov_rr','ctov','KolAkc')
     if KolAkc_rr # 0
        if kol_rr >= KolAkc_rr
           if gnEnt=21
             ZenAkr=getfield('t1','mntov_rr','ctov','c14')

             If kopr = 169 // розница
               nZenRoz:=0
               kg_r:=int(mntovt_rr/10000)
               if !empty(getfield('t1','kg_r','cgrp','nal'))
                 // акциз
                 nZenRoz:=getfield('t1','mntov_rr','ctov','RozPr')
               endif
               If nZenRoz # 0
                 ZenAkr := nZenRoz
               EndIf
             Else
              // для других операция

             EndIf
           else
             ZenAkr=getfield('t1','mntovt_rr','ctov','c14')

           endif
           if ZenAkr#0
              zenr=round(ZenAkr,2)
              zenpr=zenr
              bzenr=zenr
              bzenpr=zenr
           endif
        endif
     endif
  endif
  retu .t.
