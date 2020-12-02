* Складские проводки
*******************
func prprv(mode)
*******************
local rt_rr
lfldr=''
rt_rr=0
sele pr1
kklr=kps
ndr=nd
mnpr=mn
kopr=kop
vor=vo
pr1ndsr=getfield('t1','kklr','kpl','pr1nds')
if kopr#110
   pr1ndsr=0
endif
if mode=2 // Удалить
   sele dokk
   set orde to tag t12
   if netseek('t12','0,0,skr,ndr,mnpr')
      mdall('уд')
      do while mn=0.and.rnd=0.and.sk=skr.and.mnp=mnr.and.!eof()
         if prc.or.bs_d=0.or.bs_k=0
            netdel()
            skip
            loop
         endif
         rt_rr=1
         sele dokk
         docmod('уд',1)
         msk(0,0)
         sele dokk
         netdel()
         skip
      endd
   endif
endif
if mode=1 // Добавить
   if select('lldokk')#0
      sele lldokk
      zap
   else
      erase lldokk.dbf
      if file('cldokk.dbf')
         rename cldokk.dbf to lldokk.dbf
         sele 0
         use lldokk excl
         zap
      else
         sele dokk
         copy stru to lldokk
         sele 0
         use lldokk excl
      endif
   endif
   sele pr1
   ktar=kta
   ktasr=ktas
   if ktasr=0
      if ktar#0
         ktas_r=getfield('t1','ktar','s_tag','ktas')
         if ktasr#ktas_r
            netrepl('ktas','ktas_r',1)
            ktasr=ktas
         endif
      endif
   endif
   sele pr1
   kklr=kps
   ddkr=dpr
   ndr=nd
   mnpr=mn
   sklr=skl
   rnr=nd
   kopr=kop
   ktor=kto
   vur=gnVu
   vor=vo
   rmskr=rmsk
   if fieldpos('nndsvz')#0
      nndsvzr=nndsvz
      dnnvzr=dnnvz
   else
      nndsvzr=0
      dnnvzr=ctod('')
   endif
   dtmodr=dtmod
   tmmodr=tmmod
   nndsr=nnds
   qr=mod(kopr,100)
   sele soper
   if !netseek('t1','gnD0k1,vur,vor,qr')
      wmess('НЕ найдена операция '+str(kopr,3),3)
      retu .t.
   endif
   ndstr=getfield('t1','mnr,12','pr3','ssf')
   for gin=1 to 20
       sele soper
       gins=ltrim(str(gin,2))
       kszr = SOPer->DSZ&gins  //sOPER
       if kszr=90
          loop
       endif
       if kszr=0
          loop
       endif
       bs_kr=soper->DKR&gins
       bs_dr=soper->DDB&gins
       if kszr=19.and.ndstr=0.and.vor=1.and.bs_kr=361001.and.gnEnt>19
          bs_kr=361002
       endif
       dokkmskr=soper->PRZ&gins
       if kszr>9.and.kszr<100
          SELE pr3
          if netseek('t1','mnr,kszr')
             do while mn=mnr.and.ksz=kszr
                bs_sr=SSF
                if bs_sr=0
                   skip
                   loop
                endif
                sele lldokk
                appe blank
                rclldokkr=recn()
                go rclldokkr
                netrepl('rn,kkl,mnp,sk,rmsk','rnr,kklr,mnpr,skr,rmskr',1,1)
                netrepl('bs_d,bs_k,bs_s,ddk','bs_dr,bs_kr,bs_sr,ddkr',1,1)
                if int(bs_dr/1000)=361.or.int(bs_kr/1000)=361
                   netrepl('kta,ktas','ktar,ktasr',1,1)
                endif
                if bs_dr=641002.and.bs_kr=704101.or.bs_kr=641002.or.bs_dr=641002.and.bs_kr=643001
                   netrepl('nnds,nndsvz,dnnvz','nndsr,nndsvzr,dnnvzr',1,1)
                endif
                netrepl('ksz,vo,skl,ddc,tdc ',;
                        'kszr,vor,sklr,pr1->dpr,pr1->tpr',1,1)
                netrepl('kop,kg','kopr,ktor',1,1)
                netrepl('dtmod,tmmod','dtmodr,tmmodr',1,1)
                netrepl('dokkmsk','dokkmskr',,1)
                sele pr3
                skip
             enddo
          else
          endif
       endif
   next
   sele lldokk

   prmdaddr=0
   prmdcorr=0
   prmddelr=0
   sele lldokk
   if recc()#0
      go top
      skr=sk
      rnr=rn
      mnpr=mnp
      sele dokk
      if !netseek('t13','skr,rnr,mnpr')
         prmdaddr=1
      endif
   endif
   sele lldokk
   go top
   do while !eof()
      arec:={}
      getrec()
      skr=sk
      rnr=rn
      mnpr=mnp
      bs_dr=bs_d
      bs_kr=bs_k
      kszr=ksz
      sele dokk
      if netseek('t13','skr,rnr,mnpr,bs_dr,bs_kr,kszr')
         rcdokkr=recn()
         skip
         do while sk=skr.and.rn=rnr.and.mnp=mnpr.and.bs_d=bs_dr.and.bs_k=bs_kr.and.ksz=kszr
            netdel()
            skip
         endd
         go rcdokkr
         arec1:={}
         getrec('arec1')
         if prmdaddr=0
            prupdtr=0
            for iput=1 to len(arec)
                if !(field(iput)='BS_D';
                 .or.field(iput)='BS_K';
                 .or.field(iput)='BS_S';
                 .or.field(iput)='DDK';
                 .or.field(iput)='DOP';
                 .or.field(iput)='KOP';
                 .or.field(iput)='KKL';
                 .or.field(iput)='KTA';
                 .or.field(iput)='NKKL';
                 .or.field(iput)='NAP';
                 .or.field(iput)='NNDSVZ';
                 .or.field(iput)='DNNVZ';
                 .or.field(iput)='KTAS')
                   loop
                endif
                if arec[iput]#arec1[iput]
                   prupdtr=1
                   prmdcorr=1
                   lfldr=field(iput)
                   exit
                endif
            next
         endif
         prupdtr=0
         for iput=1 to len(arec)
             if field(iput)='DDC'.or.field(iput)='TDC'.or.field(iput)='KTOBLK';
                .or.field(iput)='DTMOD'.or.field(iput)='TMMOD'
                loop
             endif
             if !(field(iput)='BS_S'.or.field(iput)='KOP'.or.field(iput)='KKL'.or.field(iput)='NNDS';
                .or.field(iput)='KTAS'.or.field(iput)='KTA'.or.field(iput)='BS_D'.or.field(iput)='NNDSVZ'.or.field(iput)='DNNVZ';
                .or.field(iput)='BS_K'.or.field(iput)='KGP'.or.field(iput)='DDK'.or.field(iput)='NAP')
                loop
             endif
             if arec[iput]#arec1[iput]
                prupdtr=1
                exit
             endif
         next
         if prupdtr=1
            docmod(field(iput),1)
            msk(0,0)
            reclock()
            ddcr=ddc
            tdcr=tdc
            putrec()
            netrepl('ddc,tdc','ddcr,tdcr')
            msk(1,0)
         endif
         if prupdtr=2
            docmod('ДОБ',1)
         endif
      else
         prmdallr=1
         netadd()
         putrec()
         netrepl('ddc,tdc','date(),time()')
         docmod('доб',1)
         msk(1,0)
         if gnScOut=0
            @ 24,col()+1 say str(kszr,2)
         endif
         rt_rr=1
      endif
      sele lldokk
      skip
   endd
   if prmdaddr=1.or.prmdcorr=1
      sele lldokk
      go top
      skr=sk
      rnr=rn
      mnpr=mnp
      sele dokk
      if netseek('t13','skr,rnr,mnpr')
         if prmdaddr=1
            mdall('доб')
         else
            if !empty(lfldr)
               mdall(lfldr)
            else
               mdall('корр')
            endif
         endif
      endif
   endif
   sele dokk
   set orde to tag t13
   if netseek('t13','skr,rnr,mnpr')
      do while sk=skr.and.rn=rnr.and.mnp=mnpr
         skr=sk
         rnr=rn
         mnpr=mnp
         bs_dr=bs_d
         bs_kr=bs_k
         kszr=ksz
         sele lldokk
         locate for sk=skr.and.rn=rnr.and.mnp=mnpr.and.bs_d=bs_dr;
                    .and.bs_k=bs_kr.and.ksz=kszr
         if !foun()
            docmod('уд',1)
            if prmdaddr=0.and.prmdcorr=0.and.prmddelr=0
               sele dokk
               mdall('уд корр')
               prmddelr=1
            endif
            sele dokk
            msk(0,0)
            netdel()
         endif
         sele dokk
         skip
      endd
   endif
endif
if rt_rr=0
   retu .f.
else
   retu .t.
endif

*********************
func rsprv(mode,p2)
*********************
* Проводки для подтвержденного/отгруженного
* mode=1 - новые получить
* mode=2 - удалить
* p2 0-dokk;1-dokko
local rt_rr
lfldr=''
rt_rr=0
prpo_r=p2

sele rs1
ttnr=ttn
kklr=kpl
kgpr=kgp
nkklr=nkkl
kpvr=kpv
sklr=skl
ktar=kta
ktasr=ktas
dopr=dop
napr=nap
nndsr=nnds
pr1ndsr=getfield('t1','kklr','kpl','pr1nds')
if ktasr=0
   if ktar#0
      ktas_r=getfield('t1','ktar','s_tag','ktas')
      if ktasr#ktas_r
         netrepl('ktas','ktas_r',1)
         ktasr=ktas
      endif
   endif
endif
tmestor=tmesto
tmesto_r=getfield('t2','nkklr,kpvr','tmesto','tmesto')
if tmestor#tmesto_r
   netrepl('tmesto','tmesto_r',1)
   tmestor=tmesto
endif
vor=vo
if vor=5.or.vor=7.or.vor=8.or.vor=4
   sklr=kgpr
endif
if vor=5
   kklr=gnKkl_c
endif
if fieldpos('nndskt')#0
   nndsvzr=nndskt
   dnnvzr=dnnkt
else
   nndsvzr=0
   dnnvzr=ctod('')
endif
if mode=2 // Удалить
   if prpo_r=0
      sele dokk
   else
      sele dokko
   endif
   set orde to tag t12
   if netseek('t12','0,0,skr,ttnr,0')
      do while mn=0.and.rnd=0.and.sk=skr.and.rn=ttnr.and.mnp=0.and.!eof()
         if prc.or.bs_d=0.or.bs_k=0
            netdel()
            skip
            loop
         endif
         if prpo_r=0
            docmod('уд',1)
            sele dokk
            msk(0,0)
         else
            docmod('уд')
            sele dokko
            msk(0,1)
         endif
         if prpo_r=0
            sele dokk
         else
            sele dokko
         endif
         netdel()
         rt_rr=1
         skip
      endd
   endif
endif
if mode=1 // Добавить
   if select('lldokk')#0
      sele lldokk
      zap
   else
      erase lldokk.dbf
      if file('cldokk.dbf')
         rename cldokk.dbf to lldokk.dbf
         sele 0
         use lldokk excl
         zap
      else
         sele dokk
         copy stru to lldokk
         sele 0
         use lldokk excl
      endif
   endif
   sele rs1
   ttnr=ttn
   ndstr=getfield('t1','ttnr,12','rs3','ssf')
   vor=vo
   sklr=skl
   nndsr=nnds
   if vor=5.or.vor=7.or.vor=8.or.vor=4
      sklr=kgpr
   endif
   kklr=kpl
   if vor=5
      kklr=gnKkl_c
   endif
   ktar=kta
   ktasr=ktas
   napr=nap
   if ktasr=0
      if ktar#0
         ktas_r=getfield('t1','ktar','s_tag','ktas')
         if ktasr#ktas_r
            netrepl('ktas','ktas_r',1)
            ktasr=ktas
         endif
      endif
   endif
   kplr=kplr
   kgpr=kgpr
   tmestor=tmesto
   tmesto_r=getfield('t2','nkklr,kpvr','tmesto','tmesto')
   if tmestor#tmesto_r
      netrepl('tmesto','tmesto_r',1)
      tmestor=tmesto
   endif
   nkklr=nkkl
   kpvr=kpv
   if prpo_r=0
      ddkr=dot
   else
      ddkr=dop
   endif
   dopr=dop
   rnr=ttnr
   mnpr=0
   kopr=kop
   rmskr=rmsk
   qr=mod(kopr,100)
   ktor=kto
   vur=gnVu
   ztr=kon
   dtmodr=dtmod
   tmmodr=tmmod
   if fieldpos('DtOpl')#0
      DtOplr=DtOpl
   else
      DtOplr=ctod('')
   endif
   if fieldpos('nndskt')#0
      nndsvzr=nndskt
      dnnvzr=dnnkt
   else
      nndsvzr=0
      dnnvzr=ctod('')
   endif
   sele soper
   if !netseek('t1','0,vur,vor,qr')
      wmess('НЕ найдена операция '+str(kopr,3)+' !!!',3)
      retu .f.
   endif
   prnnr=prnn
   for gin=1 to 20
       sele soper
       gins=ltrim(str(gin,2))
       kszr=dsz&gins
       if kszr=90
          loop
       endif
       if kszr=0
          loop
       endif
       dokkmskr=prz&gins
       if vor=5.and.ddb&gins=440000
          bs_dr=kplr
       else
          bs_dr=ddb&gins
          if kszr=19.and.ndstr=0.and.vor=9.and.gnEnt>19
             bs_dr=361002
          endif
       endif
       bs_kr=dkr&gins
       if kszr>9.and.kszr<100
          sele rs3
          netseek('t1','ttnr,kszr')
          do while ttn=ttnr.and.ksz=kszr
             bs_sr=ssf
             if bs_sr=0
                skip
                loop
             endif
             sele lldokk
             if prpo_r=0.or.int(bs_dr/1000)=361.or.int(bs_kr/1000)=361
                netAdd()
                netrepl('rn,kkl,mnp,sk,rmsk','rnr,kklr,mnpr,skr,rmskr',1)
                netrepl('bs_d,bs_k,bs_s,ddk','bs_dr,bs_kr,bs_sr,ddkr',1)
                if int(bs_dr/1000)=361.or.int(bs_kr/1000)=361
                   netrepl('kta,ktas,dop,nap','ktar,ktasr,dopr,napr',1)
                endif
                netrepl('ksz,vo,skl','kszr,vor,sklr',1)
*                if int(bs_dr)=641002.and.bs_kr=704101.or.bs_kr=641002
*                   netrepl('nnds','nndsr',1)
*                endif
                if bs_dr=641002.and.bs_kr=704101.or.bs_kr=641002.or.bs_dr=641002.and.bs_kr=643001
                   netrepl('nnds,nndsvz,dnnvz','nndsr,nndsvzr,dnnvzr',1,1)
                endif
                if prpo_r=0
                   netrepl('ddc,tdc ','rs1->dot,rs1->tot',1)
                else
                   netrepl('ddc,tdc ','rs1->dop,rs1->top',1)
                endif
                netrepl('kop,kg,kgp,nkkl','kopr,ktor,kpvr,nkklr',1)
                netrepl('dtmod,tmmod','dtmodr,tmmodr',1)
                if fieldpos('DtOpl')#0
                   netrepl('DtOpl','DtOplr',1)
                endif
                netrepl('dokkmsk','dokkmskr')
             endif
             sele rs3
             skip
          enddo
       endif
   next
   prmdaddr=0
   prmdcorr=0
   prmddelr=0
   sele lldokk
   if recc()#0
      go top
      skr=sk
      rnr=rn
      mnpr=mnp
      if prpo_r=0
         sele dokk
      else
         sele dokko
      endif
      if !netseek('t13','skr,rnr,mnpr')
         prmdaddr=1
      endif
   endif
   sele lldokk
   go top
   do while !eof()
      arec:={}
      getrec()
      skr=sk
      rnr=rn
      mnpr=mnp
      bs_dr=bs_d
      bs_kr=bs_k
      kszr=ksz
      if prpo_r=0
         sele dokk
      else
         sele dokko
      endif
      if netseek('t13','skr,rnr,mnpr,bs_dr,bs_kr,kszr')
         rcdokkr=recn()
         skip
         do while sk=skr.and.rn=rnr.and.mnp=mnpr.and.bs_d=bs_dr.and.bs_k=bs_kr.and.ksz=kszr
            if prpo_r=0
               docmod('уд',1)
            else
               docmod('уд',0)
            endif
            mdall('уд корр')
            netdel()
            skip
         endd
         go rcdokkr
         arec1:={}
         getrec('arec1')
         if prmdaddr=0
            prupdtr=0
            for iput=1 to len(arec)
                if !(field(iput)='BS_D';
                 .or.field(iput)='BS_K';
                 .or.field(iput)='BS_S';
                 .or.field(iput)='DDK';
                 .or.field(iput)='DOP';
                 .or.field(iput)='KOP';
                 .or.field(iput)='KKL';
                 .or.field(iput)='KTA';
                 .or.field(iput)='NKKL';
                 .or.field(iput)='NAP';
                 .or.field(iput)='DTOPL';
                 .or.field(iput)='KTAS')
                   loop
                endif
                if arec[iput]#arec1[iput]
                   prupdtr=1
                   prmdcorr=1
                   lfldr=field(iput)
                   exit
                endif
            next
         endif
         prupdtr=0
         for iput=1 to len(arec)
             if field(iput)='DDC'.or.field(iput)='TDC'.or.field(iput)='KTOBLK';
                .or.field(iput)='DTMOD'.or.field(iput)='TMMOD'
                loop
             endif
             if !(field(iput)='BS_S'.or.field(iput)='KOP'.or.field(iput)='KKL'.or.field(iput)='NNDS';
                .or.field(iput)='KTAS'.or.field(iput)='KTA'.or.field(iput)='BS_D';
                .or.field(iput)='BS_K'.or.field(iput)='KGP'.or.field(iput)='DDK'.or.field(iput)='NAP'.or.field(iput)='DTOPL')
                loop
             endif
             if arec[iput]#arec1[iput]
                prupdtr=1
                exit
             endif
         next
         if prupdtr=1
            if prpo_r=0
               docmod(field(iput),1)
               msk(0,0)
            else
               docmod(field(iput))
               msk(0,1)
            endif
            reclock()
            ddcr=ddc
            tdcr=tdc
            putrec()
            netrepl('ddc,tdc','ddcr,tdcr')
            if prpo_r=0
               msk(1,0)
            else
               msk(1,1)
            endif
         endif
         if prupdtr=2
            docmod('ДОБ',1)
         endif
      else
         if prpo_r=0
            sele dokk
            netadd()
            putrec()
            netrepl('ddc,tdc','date(),time()')
            docmod('доб',1)
            msk(1,0)
            rt_rr=1
         else
            sele dokko
            netadd()
            putrec()
            netrepl('ddc,tdc','date(),time()')
            docmod('доб')
            msk(1,1)
            rt_rr=1
         endif
         if gnScOut=0
            @ 24,col()+1 say str(kszr,2)
         endif
      endif
      sele lldokk
      skip
   endd

   if prmdaddr=1.or.prmdcorr=1
      sele lldokk
      go top
      skr=sk
      rnr=rn
      mnpr=mnp
      if prpo_r=0
         sele dokk
      else
         sele dokko
      endif
      if netseek('t13','skr,rnr,mnpr')
         if prmdaddr=1
            mdall('доб')
         else
            if !empty(lfldr)
               mdall(lfldr)
            else
               mdall('корр')
            endif
         endif
      endif
   endif

   if prpo_r=0
      sele dokk
   else
      sele dokko
   endif
   set orde to tag t13
   if netseek('t13','skr,rnr,mnpr')
      do while sk=skr.and.rn=rnr.and.mnp=mnpr
         skr=sk
         rnr=rn
         mnpr=mnp
         bs_dr=bs_d
         bs_kr=bs_k
         kszr=ksz
         sele lldokk
         locate for sk=skr.and.rn=rnr.and.mnp=mnpr.and.bs_d=bs_dr;
                    .and.bs_k=bs_kr.and.ksz=kszr
         if !foun()
            if prpo_r=0
               docmod('уд',1)
               if prmdaddr=0.and.prmdcorr=0.and.prmddelr=0
                  sele dokk
                  mdall('уд корр')
                  prmddelr=1
               endif
               sele dokk
               msk(0,0)
            else
               docmod('уд')
               if prmdaddr=0.and.prmdcorr=0.and.prmddelr=0
                  sele dokko
                  mdall('уд корр')
                  prmddelr=1
               endif
               sele dokko
               msk(0,1)
            endif
            netdel()
         endif
         if prpo_r=0
            sele dokk
         else
            sele dokko
         endif
         skip
      endd
   endif
endif
if rt_rr=0
   retu .f.
else
   retu .t.
endif


