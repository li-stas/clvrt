// Автоматы по таре и внутреннему перемещению
Pathr=gcPath_tt
if !netfile('rs1',1)
   wmess('Нет баз для автомата '+Pathr,0)
   outlog(__FILE__,__LINE__)
   return
endif
sele pr2
if !netseek('t1','mnr')
   wmess("!netseek('t1','mnr') "+str(mnr,6)+' '+Pathr,0)
   outlog(__FILE__,__LINE__)
   return
endif
sele pr1
netseek('t1','ndr')
pstr=pst
mnr=mn
ttnr=amn
sktr=skt
skltr=sklt
if fieldpos('rmsk')#0
   rmskr=rmsk
else
   rmskr=0
endif
store 0 to prTr,prStr // Признак НДС на тару\ст.тару
store 0 to prKTr,prKStr // Призн налич т\ст в док (18,19,pr2)

// outlog(__FILE__,__LINE__,Sktr,SkVzr)
// Определение формирования автомата по таре
// разные слады Возвра и Передачи
if mode=1.and.autor=2.and.Sktr#SkVzr
   sele pr2
   if netseek('t1','mnr')
      do while mn=mnr.and.int(ktl/1000000)<2
           if int(ktl/1000000)=0 // тара
              if kf#0
                 prKTr=1
              endif
           endif
           if int(ktl/1000000)=1 // ст.тара
              if kf#0
                 prKStr=1
              endif
           endif
         skip
      enddo
   endif
   if getfield('t1','mnr,19','pr3','ssf')#0 // Есть тара
      prKTr=1
   else
      prKTr=0
   endif
   if prKTr=1
      if getfield('t1','mnr,12','pr3','ssf')#0
         prTr=1 // Не возвратная тара
      endif
   endif
   if getfield('t1','mnr,18','pr3','ssf')#0 // Есть стеклотара
      prKStr=1
   else
      prKStr=0
   endif
   if prKStr=1.and.pstr=1
      prStr=1 // Не возвратная стеклотара
   endif

   prFDocr=0 // Признак формирования документа
   do case
    case prKTr=1.and.prTr=0
          prFDocr=1
    case prKStr=1.and.prStr=0
          prFDocr=1
   endcase
   if prFDocr=0
     outlog(__FILE__,__LINE__,prKTr,prTr,'prKTr,prTr')
     outlog(__FILE__,__LINE__,prKSTr,prSTr,'prKTr,prTr')
     return
   endif
endif

netUse('tov')
netuse('sgrp')
Pathr=gcPath_tt
netUse('rs1',,,1)

if mode=1
   sele cskl
   netseek('t1','sktr')
   Reclock()
   ttnr=ttn
   sele rs1
   do while netseek('t1','ttnr')
      ttnr=ttnr+1
   endd
   sele cskl
   netrepl('ttn','ttnr+1')
   netunlock()
endif

netUse('rs2',,,1)
netUse('rs3',,,1)
netUse('tov','tovt',,1)

if gnCtov=1
   netUse('tovm','tovmt',,1)
endif
netuse('sgrp','sgrpt',,1)
if mskltr=1
   netuse('sgrpe','sgrpet',,1)
endif

// *** Данные из pr1 , записать в rs1 *******************
If mode = 1  // Формирование
   SELE pr1
   if netseek('t1','ndr')
      netrepl('amn','ttnr',1)
      sklr=skl
      ndr=nd
      mnr=mn
      kpsr=kps
      dprr=dpr
      kopr=kop
      vor=vo
      sktr=skt
      skltr=sklt
      dvpr=dvp
      pstr=pst
      if autor=2.or.(autor=1.and.gnCtov=3) // Учет возвратной тары
         sele Rs1
         NetAdd()
         netrepl('ttn,ddc,tdc,dvp,kop,prz,sdv,skl,kpl,sks,skls,amn,pst,kto,dot,tot,vo',;
                 'ttnr,date(),time(),dvpr,kopr,1,sdvr,skltr,gnKkl_c,gnSk,sklr,mnr,pstr,gnKto,dprr,tprr,vor')
       else  // autor=2,3 Внутренний автомат
          sele Rs1
          NetAdd()
          netrepl('ttn,ddc,tdc,dvp,vo,kop,prz,sdv,skl,kpl,sks,skls,amn,pst,kto,dot,tot',;
                  'ttnr,date(),time(),dvpr,vor,koppr,1,sdvr,skltr,gnKkl_c,gnSk,sklr,mnr,pstr,ktor,dprr,tprr')
       endif
  //       if fieldpos('rmsk')#0
  //          netrepl('rmsk','gnRmsk')
  //      endif
       if fieldpos('dtmod')#0
          netrepl('dtmod,tmmod','date(),time()')
       endif
   endi
else      //Удаление mode <> 1
   sele Rs1
   if netseek('t1','ttnr')
      netdel()
   endif
endi

// *** Данные с pr3 , записать в rs3 ********************
if mode=1
   SELE pr3
   netseek('t1','mnr')
   do whil mn=mnr
      if autor=2
         if !(ksz=18.or.ksz=19)
            skip;            loop
         endif
         if ksz=18
            if !(prKStr=1.and.prStr=0)
               skip;               loop
            endif
         endif
         if ksz=19
            if !(prKTr=1.and.prTr=0)
               skip ;               loop
            endif
         endif
      endif
      sele rs3
      NetAdd()
      Replace ttn with ttnr,ksz with pr3->ksz,ssf with pr3->ssf
      SELE pr3
      skip
   enddo
else // delete
   sele Rs3
   If netseek('t1','ttnr')
      Do while ttn=ttnr
         netdel()
         skip
      Enddo
   Endif
endif

// *** Данные с pr2 , записать в rs2 ********************
if mode=1
   sele pr2
   netseek('t1','mnr')
   do while mn=mnr
      mntovr:=mntov
      prKtlr:=0
      ktlr:=ktl

      if autor=2
         KtlPr:=ktlr
         pptr:=0
      else
         KtlPr:=ktlp
         pptr:=ppt
      endif

      if ktlr=ktlpr
         mntovpr=mntovr
      else
         mntovpr=getfield('t1','sklr,ktlpr','tov','mntov')
      endif

      kg_r=int(ktlr/1000000)
      if autor=2
         if !(kg_r=0.or.kg_r=1)
            skip;            loop
         endif
         if kg_r=0.and.prTr=1
            skip;            loop
         endif
         if kg_r=1.and.prStr=1
            skip ;            loop
         endif
      endif
      kfr=kf
      sfr=sf
      optr=zen
      zenr=zen
      if zenr=0
         skip ;         loop
      endif
      sele sgrpt
      if !netseek('t1','kg_r')
         sele sgrp
         if netseek('t1','kg_r')
            arec:={}
            getrec()
            sele sgrpt
            netadd()
            putrec()
         endif
      endif
      if mskltr=1
         sele sgrpet
         if !netseek('t1','skltr,kg_r')
            netadd()
            netrepl('skl,kg','skltr,kg_r')
         endif
      endif
      // *** Коpекция остатков **************************************
      SELE tov
      if netseek('t1','sklr,ktlr')
         arec:={}
         getrec()  // gather(fox)
         natr=upper(nat)
         nat_r=nat
         post_r=post
         opt_r=opt
         mntov_r=mntov
         prmn_r=prmn
         post_r=post
         upakp_r=upak
         izg_r=izg
      endif

      ktlnr=0
      if gnCtov=1
         sele tovmt
         if netseek('t1','skltr,mntovr')
            reclock()
         endif
      endif

      sele tovt
      if netseek('t1','skltr,ktlr')
        ktlnr=ktlr
        If !(upper('TPok') $  upper(gcPath_tt) ;// для тары пок. не проверяем
            .or. upper('TPst') $  upper(gcPath_tt); // для тары пост. не проверяем
            )
          if !(nat=nat_r.and.post=post_r.and.opt=opt_r.and.prmn=prmn_r)
             ktlnr=0
          endif
        EndIf
      else
         netadd()
         putrec()
         netrepl('skl,mntov,ktl,osn,osv,osf,osfm,osvo','skltr,mntovr,ktlr,0,0,0,0,0')
         if gnCtov=3
            sele ctovk
            if netseek('t1','ktlr')
               netrepl('cnt','cnt+1')
            endif
         endif
         ktlnr=ktlr
      endif

      if ktlnr=0
         if gnCtov=1
            sele cgrp
            if !netseek('t1','kg_r')
               sele sgrp
               if netseek('t1','kg_r')
                  ngr_r=ngr
                  sele cgrp
                  netadd()
                  netrepl('kgr,ngr','kg_r,ngr_r')
                  reclock()
               endif
               CMaxKtlr=0
            else
               CMaxKtlr=ktl
            endif
         endif

         sele sgrp
         netseek('t1','kg_r')
         SMaxKtls=ktl
         sele sgrpt
         netseek('t1','kg_r')
         reclock()
         if SMaxKtls>ktl
            netrepl('ktl','SMaxKtls',1)
         endif
         SMaxKtlr=ktl
         if gnCtov=1
            if SMaxKtlr>CMaxKtlr
               sele cgrp
               netrepl('ktl','SMaxKtlr',1)
            endif
            if SMaxKtlr<CMaxKtlr
               sele sgrp
               netrepl('ktl','CMaxKtlr',1)
            endif
         endif

         sele sgrpt
         ktlr=ktl
         netrepl('ktl','ktl+1')
         if gnCtov=1
            sele cgrp
            netrepl('ktl','ktl+1')
         endif

         sele tovt
         netadd()
         putrec()
         netrepl('skl,mntov,ktl,osn,osv,osf,osfm,osvo','skltr,mntovr,ktlr,0,-kfr,-kfr,0,0')
         if gnCtov=3
            sele ctovk
            if netseek('t1','ktlr')
               netrepl('cnt','cnt+1')
            endif
         endif

      else
         sele tovt
         netrepl('osv,osf','osv-kfr,osf-kfr')
      endif

      if dpo<dprr
         netrepl('dpo','dprr')
      endif
      if gnCtov=1
         sele tovmt
         if !netseek('t1','skltr,mntovr')
            netadd()
            putrec()
            netrepl('skl,kg,mntov,ktl,osn,osv,osf,osfm,osvo','skltr,int(mntovr/10000),mntovr,0,0,-kfr,-kfr,0,0')
         else
            netrepl('kg,osv,osf','int(mntovr/10000),osv-kfr,osf-kfr')
         endif
         if dpo<dprr
            netrepl('dpo','dprr')
         endif
      endif

      if mskltr#0
         sele sgrpet
         if !netseek('t1','skltr,kg_r')
            netadd()
            netrepl('skl,kg','skltr,kg_r')
         endif
      endif
      // Расход
      sele rs2
      set orde to tag t3
      if !netseek('t3','ttnr,ktlpr,pptr,ktlr')
         netadd()
         netrepl('ttn,mntov,ktlp,ppt,ktl,kf,kvp,sf,svp,zen,prosfo,izg',;
                 'ttnr,mntovr,ktlpr,pptr,ktlr,kfr,kfr,sfr,sfr,zenr,1,izg_r')
      else
         netrepl('kf,kvp,sf,svp',;
                 'kf+kfr,kvp+kfr,sf+sfr,svp+sfr')
      endif
    sele pr2
    skip
  enddo
else // Удаление
   SELE Rs2
   If netseek('t1','ttnr')
      do while ttn=ttnr
         mntovr=mntov
         ktlr=ktl
         kfr=kf
         netdel()
         SELE tovt
         if netseek('t1','skltr,ktlr')
            netrepl('osv,osf','osv+kfr,osf+kfr')
         endif
         if gnCtov=1
            sele tovmt
            if netseek('t1','skltr,mntovr')
               netrepl('kg,osv,osf','int(mntovr/10000),osv+kfr,osf+kfr')
            endif
         endif
         SELE Rs2
         skip
      enddo
   EndIf
endif
unlock all
nuse('rs1')
nuse('rs2')
nuse('rs3')
nuse('tovt')
nuse('tovmt')
nuse('sgrpt')
nuse('sgrpet')
return
