* Складские проводки  
*******************
func prprov(mode)
*******************
sele pr1
kklr=kps
ndr=nd
mnpr=mn
if mode=2 && Удалить
   sele dokk 
   set orde to tag t12
   if netseek('t12','0,0,skr,ndr,mnpr') 
      do while mn=0.and.rnd=0.and.sk=skr.and.mnp=mnr.and.!eof()
         if prc.or.bs_d=0.or.bs_k=0
            netdel()
            skip
            loop  
         endif
         sele dokk
         msk(0,0)   
         sele dokk
         netdel()
         skip
      endd
   endif
endif
if mode=1 && Добавить
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
   qr=mod(kopr,100)
   if !netseek('t1','gnD0k1,vur,vor,qr','soper')
      wmess('НЕ найдена операция '+str(kopr,3),3)
      retu .t.
   endif
   ndstr=getfield('t1','mnr,12','pr3','ssf')
   for gin=1 to 20
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
                sele dokk
                netAdd(1)
                netrepl('rn,kkl,mnp,sk,rmsk','rnr,kklr,mnpr,skr,rmskr',1)
                netrepl('bs_d,bs_k,bs_s,ddk','bs_dr,bs_kr,bs_sr,ddkr',1)
                if int(bs_dr/1000)=361.or.int(bs_kr/1000)=361
                   netrepl('kta,ktas','ktar,ktasr',1) 
                endif
                netrepl('ksz,vo,skl,ddc,tdc ',;
                        'kszr,vor,sklr,pr1->dtmod,pr1->tmmod',1)
                netrepl('kop,kg','kopr,ktor',1)
                netrepl('dokkmsk','dokkmskr')
                if gnScOut=0
                   @ 24,col()+1 say str(kszr,2)
                endif
                sele dokk  
                msk(1,0)   
                sele pr3
                skip
             enddo
          endif     
       endif
   next
endif
retu .t.

*********************
func rsprov(mode,p2)
*********************
* Проводки для подтвержденного/отгруженного
* mode=1 - новые получить
* mode=2 - удалить
* p2 0-dokk;1-dokko
if empty(p2)
   prpo_r=0
else
   prpo_r=1
endif
sele rs1
ttnr=ttn
kklr=kpl
kgpr=kgp
nkklr=nkkl
kpvr=kpv
sklr=skl
ktar=kta
ktasr=ktas
if ktar#0
   ktas_r=getfield('t1','ktar','s_tag','ktas')
   if ktasr#ktas_r
      netrepl('ktas','ktas_r',1)
      ktasr=ktas
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
if mode=2 && Удалить
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
            sele dokk
            msk(0,0)   
         else
            sele dokko
            msk(0,1)   
         endif  
         if prpo_r=0
            sele dokk
         else
            sele dokko
         endif   
         netdel()
         skip
      endd
   endif
endif
if mode=1 && Добавить
   sele rs1
   ttnr=ttn
   ndstr=getfield('t1','ttnr,12','rs3','ssf')
   vor=vo
   sklr=skl
   if vor=5.or.vor=7.or.vor=8.or.vor=4
      sklr=kgpr
   endif
   kklr=kpl
   if vor=5
      kklr=gnKkl_c
   endif
   ktar=kta     
   ktasr=ktas
   if ktar#0
      ktas_r=getfield('t1','ktar','s_tag','ktas')
      if ktasr#ktas_r
         netrepl('ktas','ktas_r',1)  
         ktasr=ktas
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
   ddkr=dot
   dopr=dop
   rnr=ttnr
   mnpr=0
   kopr=kop
   rmskr=rmsk
   qr=mod(kopr,100)
   ktor=kto
   vur=gnVu
   ztr=kon
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
             if prpo_r=0
                sele dokk
             else
                sele dokko
             endif      
             if prpo_r=0.or.int(bs_dr/1000)=361.or.int(bs_kr/1000)=361
                netAdd(1)
                netrepl('rn,kkl,mnp,sk,rmsk','rnr,kklr,mnpr,skr,rmskr',1)
                netrepl('bs_d,bs_k,bs_s,ddk','bs_dr,bs_kr,bs_sr,ddkr',1)
                if int(bs_dr/1000)=361.or.int(bs_kr/1000)=361
                   netrepl('kta,ktas,tmesto','ktar,ktasr,tmestor',1) 
                endif
                netrepl('ksz,vo,skl,ddc,tdc ',;
                        'kszr,vor,sklr,rs1->dtmod,rs1->tmmod',1)
                netrepl('kop,kg,kgp,nkkl','kopr,ktor,kpvr,nkklr',1)
                netrepl('dokkmsk','dokkmskr')
                if gnScOut=0
                   @ 24,col()+1 say str(kszr,2)
                endif
                if prpo_r=0
                   sele dokk
                   msk(1,0)   
                 else
                   sele dokko
                   msk(1,1)   
                endif  
             endif   
             sele rs3
             skip
          enddo
       endif  
   next
endif   
retu .t.

**********************
func mdd(p1,p2,p3,p4)
**********************
* Модиф докум
* p1 sk
* p2 d0k1
* p3 doc
* p4 mn
if select('moddoc')=0
   retu .t.
endif
sk_r=p1
d0k1_r=p2
doc_r=p3
if empty(p4)
  mn_r=0 
else
  mn_r=p4
endif
als_rr=alias()
sele moddoc
if !netseek('t1','sk_r,doc_r')
   netadd()
   netrepl('sk,d0k1,doc,mn','sk_r,d0k1_r,doc_r,mn_r')
endif
netrepl('dtmod,tmmod,kto,prd','date(),time(),gnKto,gdTd')
if !empty(als_rr)
   sele (als_rr)
else
   sele 0   
endif
retu .t.
*******************************
func chkmdd(p1,p2,p3,p4,p5,p6)
*******************************
* Корр dtmod (runcdocopt)
if gnEntrm#0
   retu .t.
endif
* p1 sk
* p2 d0k1
* p3 doc
* p4 mn
* p5 dtmod
* p6 tmmod
if select('moddoc')=0
   retu .t.
endif
sk_r=p1
d0k1_r=p2
doc_r=p3
if empty(p4)
  mn_r=0 
else
  mn_r=p4
endif
dtmod_r=p5
tmmod_r=p6
als_rr=alias()
sele moddoc
if !netseek('t1','sk_r,doc_r')
   netadd()
   netrepl('sk,d0k1,doc,mn','sk_r,d0k1_r,doc_r,mn_r')
endif
if dtmod_r>dtmod
   if gnArm=0
      netrepl('dtmod,tmmod,kto,prd','date(),time(),9999,dtr')
   else 
      netrepl('dtmod,tmmod','date(),time()')
   endif
endif
if !empty(als_rr)
   sele (als_rr)
else
   sele 0   
endif
retu .t.
