* Автоматы по таре и внутреннему перемещению
***************
func pprha(p1)
***************
prdelr=0
if p1=1
   if amnr#0
      sele ('rs1'+prer)
      if netseek('t1','amnr')
         if !(amn=mnr.and.sks=skr)
            amnr=0
         endif
      endif
   endif
   if amnr=0
      sele cskl
      netseek('t1','sktr')
      reclock()
      ttnr=ttn
      if ttn<999999
         netrepl('ttn','ttn+1')
      else
         netrepl('ttn','1')
      endif
   else
      ttnr=amnr
   endif
else
   ttnr=amnr
   sele ('rs1'+prer)
   if netseek('t1','amnr')
      if !(amn=mnr.and.sks=skr)
         retu .f.
      endif
   endif
endif

*** Данные из pr1 , записать в rs1 *******************
If p1 = 1  // Формирование
   SELE pr1
   netrepl('amn,skt,sklt','ttnr,sktr,skltr')
   sklr=skl
   mnr=mn
   kpsr=kps
   dprr=dpr
   tprr=tpr
   dvpr=dvp
   sdvr=sdv
   kopr=kop
   rmskr=rmsk
   sele ('rs1'+prer)
   NetAdd()
   netrepl('ttn,ddc,tdc,dvp,kop,prz,sdv,skl,kpl,sks,skls,amn,pst,kto,dot,tot,rmsk,nkkl',;
           'ttnr,date(),time(),dvpr,kopr,1,sdvr,skltr,gnKkl_c,skr,sklr,mnr,pstr,gnKto,dprr,tprr,rmskr,gnKkl_c')
else      //Удаление p1=2
   SELE ('Rs1'+prer)
   set orde to tag t1
   if netseek('t1','ttnr')
      prdelr=1
      do while ttn=ttnr
         netdel()
         skip
         if eof()
            exit
         endif
      endd
   endif
endi

*** Данные с pr3 , записать в rs3 ********************
if p1=1
   SELE pr3
   netseek('t1','mnr')
   do whil mn=mnr
      if !(ksz=18.or.ksz=19)
         skip
         loop
      endif
      if ksz=18
         if !(prkstr=1.and.prstr=0)
            skip
            loop
         endif
      endif
      if ksz=19
         if !(prktr=1.and.prtr=0)
            skip
            loop
         endif
      endif
      kszr=ksz
      ssfr=ssf
      sele ('rs3'+prer)
      NetAdd()
      netrepl('ttn,ksz,ssf','ttnr,kszr,ssfr')
      SELE pr3
      skip
   enddo
else
   SELE ('Rs3'+prer)
   If netseek('t1','ttnr')
      Do while ttn=ttnr
         netdel()
         skip
      Enddo
   Endif
endif

*** Данные с pr2 , записать в rs2 ********************
if p1=1
   SELE pr2
   netseek('t1','mnr')
   do whil mn=mnr
      mntovr=mntov
      prktlr=0
      ktlr=ktl
      ktlpr=ktlr
      pptr=0
      mntovpr=mntovr
      kg_r=int(ktlr/1000000)
      izgr=izg
      if !(kg_r=0.or.kg_r=1)
         skip
         loop
      endif
      if kg_r=0.and.prtr=1
         skip
         loop
       endif
       if kg_r=1.and.prstr=1
          skip
          loop
       endif
       kfr=kf
       sfr=sf
       optr=zen
       zenr=zen
       if zenr=0
          skip
          loop
       endif
       sele ('sgrp'+prer)
       if !netseek('t1','kg_r')
          sele sgrp
          if netseek('t1','kg_r')
             arec:={}
             getrec()
             sele ('sgrp'+prer)
             netadd()
             putrec()
          endif
      endif
      *** Коpекция остатков **************************************
      SELE tov
      if netseek('t1','sklr,ktlr')
         arec:={}
         getrec()  && gather(fox)
         SELE ('tov'+prer)
         if !netseek('t1','skltr,ktlr')
            netadd()
            putrec()
            netrepl('skl,osn,osv,osf,osfm,osvo,osfo','skltr,0,0,0,0,0,0')
         else
            netrepl('osv,osf,osfo','osv-kfr,osf-kfr,osfo-kfr')
         endif
         if dpo<dprr
            netrepl('dpo','dprr')
         endif
         sele ('tovm'+prer)
         if !netseek('t1','skltr,mntovr')
            netadd()
            putrec()
            netrepl('skl,ktl,osn,osv,osf,osfo','skltr,0,0,-kfr,-kfr,-kfr')
         else
            netrepl('osv,osf,osfo','osv-kfr,osf-kfr,osfo-kfr')
         endif
         if dpo<dprr
            netrepl('dpo','dprr')
         endif
      endif
      * Расход
      sele ('rs2'+prer)
      if !netseek('t1','ttnr,ktlr')
         netadd()
         netrepl('ttn,mntov,ktlp,ppt,ktl,kf,kvp,sf,svp,zen,izg,prosfo',;
                 'ttnr,mntovr,ktlr,pptr,ktlr,kfr,kfr,sfr,sfr,zenr,izgr,1')
      else
         netrepl('kf,kvp,sf,svp',;
                 'kf+kfr,kvp+kfr,sf+sfr,svp+sfr')
      endif
      sele pr2
      skip
   endd
else && Удаление
   SELE ('Rs2'+prer)
   If netseek('t1','ttnr')
      do while ttn=ttnr
         mntovr=mntov
         ktlr=ktl
         kfr=kf
         netdel()
         SELE ('tov'+prer)
         if netseek('t1','skltr,ktlr')
            netrepl('osv,osf,osfo','osv+kfr,osf+kfr,osfo+kfr')
         endif
         sele ('tovm'+prer)
         if netseek('t1','skltr,mntovr')
            netrepl('osv,osf,osfo','osv+kfr,osf+kfr,osfo+kfr')
         endif
         SELE ('Rs2'+prer)
         skip
      enddo
   EndIf
endif
if p1=2
   if prdelr=0
      retu .f.
   else
      retu .t.
   endif
else
   retu .t.
endif
******************
func rprha(p1)
******************
prdelr=0
if p1=1
   if amnr#0
      sele ('pr1'+prer)
      set orde to tag t2
      if netseek('t2','amnr')
         if !(amn=ttnr.and.sks=skr)
            amnr=0
         endif
      endif
   endif
   if amnr=0
      sele cskl
      netseek('t1','sktr')
      reclock()
      mnr=mn
      if mn<999999
         netrepl('mn','mn+1')
      else
         netrepl('mn','1')
      endif
   else
      mnr=amnr
   endif
else
   mnr=amnr
   sele ('pr1'+prer)
   set orde to tag t2
   if netseek('t2','amnr')
      if !(amn=ttnr.and.sks=skr)
         retu .f.
      endif
   endif
endif

*** Данные из rs1 , записать в pr1 *******************
If p1 = 1  // Формирование
   SELE rs1
   netrepl('amn,skt,sklt','mnr,sktr,skltr')
   sklr=skl
   ttnr=ttn
   kplr=kpl
   dotr=dot
   totr=tot
   dvpr=dvp
   sdvr=sdv
   kopr=kop
   rmskr=rmsk
   pstr=pst
   sele ('pr1'+prer)
   NetAdd()
   netrepl('nd,mn,ddc,tdc,dvp,kop,prz,sdv,skl,kps,sks,skls,amn,pst,kto,dpr,tpr,rmsk',;
           'mnr,mnr,date(),time(),dvpr,kopr,1,sdvr,skltr,kplr,skr,sklr,ttnr,pstr,gnKto,dotr,totr,rmskr')
else      //Удаление p1=2
   SELE ('pr1'+prer)
   set orde to tag t2
   if netseek('t2','mnr')
      prdelr=1
      do while mn=mnr
         netdel()
         skip
         if eof()
            exit
         endif
      endd
   endif
endi

*** Данные с rs3 , записать в pr3 ********************
if p1=1
   SELE rs3
   netseek('t1','ttnr')
   do whil ttn=ttnr
      if !(ksz=18.or.ksz=19)
         skip
         loop
      endif
      if ksz=18
         if !(prkstr=1.and.prstr=0)
            skip
            loop
         endif
      endif
      if ksz=19
         if !(prktr=1.and.prtr=0)
            skip
            loop
         endif
      endif
      kszr=ksz
      ssfr=ssf
      sele ('pr3'+prer)
      NetAdd()
      netrepl('mn,ksz,ssf','mnr,kszr,ssfr')
      SELE rs3
      skip
   enddo
else
   SELE ('pr3'+prer)
   If netseek('t1','mnr')
      Do while mn=mnr
         netdel()
         skip
      Enddo
   Endif
endif

*** Данные с rs2 , записать в pr2 ********************
if p1=1
   SELE rs2
   netseek('t1','ttnr')
   do whil ttn=ttnr
      mntovr=mntov
      prktlr=0
      ktlr=ktl
      ktlpr=ktlr
      pptr=0
      mntovpr=mntovr
      izgr=izg
      kg_r=int(ktlr/1000000)
      if !(kg_r=0.or.kg_r=1)
         skip
         loop
      endif
      if kg_r=0.and.prtr=1
         skip
         loop
       endif
       if kg_r=1.and.prstr=1
          skip
          loop
       endif
       kfr=kvp
       sfr=svp
       zenr=zen
       if zenr=0
          skip
          loop
       endif
       sele ('sgrp'+prer)
       if !netseek('t1','kg_r')
          sele sgrp
          if netseek('t1','kg_r')
             arec:={}
             getrec()
             sele ('sgrp'+prer)
             netadd()
             putrec()
          endif
      endif
      *** Коpекция остатков **************************************
      SELE tov
      if netseek('t1','sklr,ktlr')
         arec:={}
         getrec()  && gather(fox)
         SELE ('tov'+prer)
         if !netseek('t1','skltr,ktlr')
            netadd()
            putrec()
            netrepl('skl,osn,osv,osf,osfm,osvo,osfo','skltr,0,0,0,0,0,0')
         endif
         netrepl('osv,osf,osfo','osv+kfr,osf+kfr,osfo+kfr')
         if dpp<dotr
            netrepl('dpp','dotr')
         endif
         sele ('tovm'+prer)
         if !netseek('t1','skltr,mntovr')
            netadd()
            putrec()
            netrepl('skl,ktl,osn','skltr,0,0')
         endif
         netrepl('osv,osf,osfo','osv+kfr,osf+kfr,osfo+kfr')
         if dpp<dotr
            netrepl('dpp','dotr')
         endif
      endif
      * Приход
      sele ('pr2'+prer)
      if !netseek('t1','mnr,ktlr')
         netadd()
         netrepl('mn,mntov,ktlp,ppt,ktl,kf,sf,zen,izg',;
                 'mnr,mntovr,ktlr,pptr,ktlr,kfr,sfr,zenr,izgr')
      else
         netrepl('kf,sf',;
                 'kf+kfr,sf+sfr')
      endif
      sele rs2
      skip
   endd
else && Удаление
   SELE ('pr2'+prer)
   If netseek('t1','mnr')
      do while mn=mnr
         mntovr=mntov
         ktlr=ktl
         kfr=kf
         netdel()
         SELE ('tov'+prer)
         if netseek('t1','skltr,ktlr')
            netrepl('osv,osf,osfo','osv-kfr,osf-kfr,osfo-kfr')
         endif
         sele ('tovm'+prer)
         if netseek('t1','skltr,mntovr')
            netrepl('osv,osf,osfo','osv-kfr,osf-kfr,osfo-kfr')
         endif
         SELE ('pr2'+prer)
         skip
      enddo
   EndIf
endif
if p1=2
   if prdelr=0
      retu .f.
   else
      retu .t.
   endif
else
   retu .t.
endif
