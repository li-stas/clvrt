* Корр DOKK.KTA
if gnScOut=0
   clea
   aqstr=1
   aqst:={"Просмотр","Коррекция"}
   aqstr:=alert("aaa",aqst)
   if lastkey()=27
      retu
   endif
else
   aqstr=2
endif

set prin to dokk.txt
set prin on
set cons off
?' SK'+' '+'  RN  '+' '+'  MNP '
netuse('s_tag')
netuse('cskl')
netuse('dokk')
netuse('operb')
netuse('dkkln')
netuse('dknap')
netuse('dkklns')
netuse('dkklna')
netuse('kpl')
*netuse('zdoc')
netuse('bs')
n_nnn=1
n_nn=0
sele dokk
set orde to tag t12
n_nnnn=recc()
go top
sk_rr=0
if gnScout=0
   @ 1,60 say str(n_nnnn,10)
endif
do while !eof()
   sele dokk
   set prin off
   if gnScout=0
      if n_nn=1000
         n_nnn=n_nnn+1000
         @ 2,60 say str(n_nnn,10)
         n_nn=0
      endif
      set prin on
      n_nn=n_nn+1
   endif
   if prc.or.bs_d=0.or.bs_k=0
      netdel()
      skip
      loop
   endif
   skr=sk
   mnr=mn
   rnr=rn
   skr=sk
   rndr=rnd
   mnpr=mnp
   kszr=ksz
   kopr=kop
   bs_dr=bs_d
   bs_kr=bs_k
   kklr=kkl
   ktar=kta
   ktasr=ktas
   tmestor=tmesto
   dokkmskr=dokkmsk
   rmskr=rmsk
   dtmodr=dtmod
   tmmodr=tmmod
   sele dokk
   if mnr=0 // Склад
      if skr=0
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' '+str(bs_s,10,2)+' '+str(bs_d,6)+' '+str(bs_k,6)+' Удален sk=0'
         if aqstr=2
            netdel()
         endif
         skip
         loop
      endif
      if skr#sk_rr
         path_r=getfield('t1','skr','cskl','path')
         pathr=gcPath_d+alltrim(path_r)
         if !netfile('tov',1)
            sele dokk
            do while mn=0.and.rnd=0.and.sk=skr
               ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' '+str(bs_s,10,2)+' '+str(bs_d,6)+' '+str(bs_k,6)+' Удален нет склада'
               if aqstr=2
                  netdel()
               endif
               skip
               loop
            endd
            loop
         else
            nuse('rs1')
            nuse('rs3')
            nuse('pr1')
            nuse('pr3')
            nuse('soper')
            netuse('rs1','','',1)
            netuse('rs3','','',1)
            netuse('pr1','','',1)
            netuse('pr3','','',1)
            netuse('soper','','',1)
            sk_rr=skr
         endif
      endif
      if mnpr=0 // Расход
         d0k1r=0
         sele rs1
         if netseek('t1','rnr')
            przr=prz
            rmsk_r=rmsk
            kplr=kpl
            kkldocr=kplr
            ktar=kta
            ktasr=ktas
            tmestor=tmesto
            kopr_r=kop
            vor=vo
            nkklr=nkkl
            if fieldpos('nap')#0
               napr=nap
            else
               napr=0
            endif
            ssfr=getfield('t1','rnr,kszr','rs3','ssf')
         else
            sele dokk
            ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' '+str(bs_s,10,2)+' '+str(bs_d,6)+' '+str(bs_k,6)+' Удален нет докум'
            if aqstr=2
               netdel()
            endif
            skip
            loop
         endif
      else // Приход
         d0k1r=1
         sele pr1
         if netseek('t2','mnpr')
            przr=prz
            rmsk_r=rmsk
            ktar=kta
            ktasr=ktas
            tmestor=0
            kopr_r=kop
            kpsr=kps
            kkldocr=kpsr
            vor=vo
            ssfr=getfield('t1','mnpr,kszr','pr3','ssf')
            nkklr=0
            if fieldpos('nap')#0
               napr=nap
            else
               napr=0
            endif
         else
            sele dokk
            ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' '+str(bs_s,10,2)+' '+str(bs_d,6)+' '+str(bs_k,6)+' Удален нет докум'
            if aqstr=2
               netdel()
            endif
            skip
            loop
         endif
      endif
      sele dokk
      if vor#5.and.kklr#kkldocr
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' '+str(bs_s,10,2)+' '+str(bs_d,6)+' '+str(bs_k,6)+' Удален kkl#kkldoc'
         sele dokk
         if aqstr=2
            netdel()
         endif
         skip
         loop
      endif
      if przr=0
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' '+str(bs_s,10,2)+' '+str(bs_d,6)+' '+str(bs_k,6)+' Удален prz=0'
         if aqstr=2
            netdel()
         endif
         skip
         loop
      endif
      if ssfr=0
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' '+str(bs_s,10,2)+' '+str(bs_d,6)+' '+str(bs_k,6)+' Удален ssf=0'
         if aqstr=2
            netdel()
         endif
         skip
         loop
      endif
      if round(ssfr,2)#round(bs_s,2)
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' '+str(ksz,2)+' '+str(bs_s,10,2)+' '+str(ssfr,10,2)+' '+str(bs_d,6)+' '+str(bs_k,6)+' ssf#bs_s'
      endif
      if kopr#kopr_r
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' '+str(bs_s,10,2)+' '+str(bs_d,6)+' '+str(bs_k,6)+' Удален kop#kop'
         if aqstr=2
            netdel()
         endif
         skip
         loop
      endif
      sele dokk
      if rmskr#rmsk_r
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' '+str(bs_s,10,2)+' '+str(bs_d,6)+' '+str(bs_k,6)+' rmsk'
         if aqstr=2
            netrepl('rmsk','rmsk_r')
         endif
      endif
      if (int(bs_d/1000)=361.or.int(bs_k/1000)=361).and.kta#ktar
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' KTA '+str(kta,4)+' '+str(ktar,4)
         if aqstr=2
            netrepl('kta','ktar')
         endif
      endif
      if (int(bs_d/1000)=361.or.int(bs_k/1000)=361).and.ktas#ktasr
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' KTAS '+str(ktas,4)+' '+str(ktasr,4)
         if aqstr=2
            netrepl('ktas','ktasr')
         endif
      endif
      if (int(bs_d/1000)=361.or.int(bs_k/1000)=361).and.tmesto#tmestor
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' TMESTO '+str(tmesto,7)+' '+str(tmestor,7)
         if aqstr=2
            netrepl('tmesto','tmestor')
         endif
      endif
      if (int(bs_d/1000)=361.or.int(bs_k/1000)=361).and.nap#napr
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' NAP '+str(nap,4)+' '+str(napr,4)
         if aqstr=2
            netrepl('nap','napr')
         endif
      endif
      qr=mod(kopr,100)
      dokkmskr=space(6)
      sele soper
      if netseek('t1','d0k1r,1,vor,qr')
         prfndr=0
         for i=1 to 20
             cdszr='dsz'+alltrim(str(i,2))
             cddbr='ddb'+alltrim(str(i,2))
             cdkrr='dkr'+alltrim(str(i,2))
             bs_drr=&cddbr
             bs_krr=&cdkrr
             if &cddbr=440000.and.vor=5
                 bs_drr=kplr
             endif
             if d0k1r=0.and.kszr=19
                if vor=9.and.gnEnt>19
                   ssf_rr=getfield('t1','rnr,12','rs3','ssf')
                   if ssf_rr=0
                      bs_drr=361002
                      sele dokk
                      netrepl('bs_d','bs_drr')
                      bs_dr=bs_d
                   endif
                endif
             endif
             if d0k1r=1.and.kszr=19
                if vor=1.and.gnEnt>19
                   ssf_rr=getfield('t1','rnr,12','pr3','ssf')
                   if ssf_rr=0
                      bs_krr=361002
                      sele dokk
                      netrepl('bs_k','bs_krr')
                      bs_kr=bs_k
                   endif
                endif
             endif
             sele soper
             if &cdszr=kszr.and.bs_drr=bs_dr.and.bs_krr=bs_kr
                cprz='prz'+alltrim(str(i,2))
                dokkmskr=&cprz
                prfndr=1
                exit
             endif
         next
      endif
      sele dokk
      if prfndr=0
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' Нет проводок в складе Удален'
         if aqstr=2
             netdel()
         endif
         skip
         loop
      endif
      if dokkmsk#dokkmskr
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' DOKKMSK '+dokkmsk+' '+dokkmskr
         if aqstr=2
            netrepl('dokkmsk','dokkmskr')
         endif
      endif
      sele dokk
      if (int(bs_d/1000)=361.or.int(bs_k/1000)=361).and.nkkl#nkklr
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' NKKL '+str(nkkl,7)+' '+str(nkklr,7)
         if aqstr=2
            netrepl('nkkl','nkklr')
         endif
      endif
   else // Бухгалтерия
      if gnArm=2
         if gnEntrm=1
            if rmskr#9
               if rmsk=0.and.bs_o=301001
                  ?str(mn,6)+' '+str(rnd,6)+' '+str(rnr,6)+' Касса Сумы удален '
                  if aqstr=2
                     netdel()
                  endif
                  skip
                  loop
               endif
               if rmsk=0.and.(bs_d=301001.or.bs_k=301001)
                  ?str(mn,6)+' '+str(rnd,6)+' '+str(rnr,6)+' Касса Сумы удален '
                  if aqstr=2
                     netdel()
                  endif
                  skip
                  loop
               endif
               if rmsk=0.and.bs_o=gnRmbs
                  netrepl('rmsk','gnRmsk')
               endif
               if rmsk#0.and.rmsk#gnRmsk
                  ?str(mn,6)+' '+str(rnd,6)+' '+str(rnr,6)+' '+str(rmsk,1)+' Чужая проводка удален '
                  if aqstr=2
                     netdel()
                  endif
                  skip
                  loop
               endif
            endif
         endif
      endif
      dokkmskr=getfield('t1','kopr','operb','mask')
      if dokkmsk#dokkmskr
         ?str(mn,6)+' '+str(rnd,6)+' '+str(rn,6)+' '+' DOKKMSK корр '+dokkmsk+' '+dokkmskr
         if aqstr=2
            netrepl('dokkmsk','dokkmskr')
         endif
      endif
      if empty(dtmod)
         netrepl('dtmod,tmmod','ddc,tdc')
      endif
      if dokkttn#0
         if fieldpos('dokksk')#0
            if dokksk=0
               sk_rrr=sk
               netrepl('dokksk','sk_rrr')
            endif
         endif
      endif
   endif
   sele dokk
   skip
   if mnr#0
      do while mn=mnr.and.rnd=rndr.and.rn=rnr
         ?str(mnr,6)+' '+str(rndr,6)+' '+str(rnr,6)+' '+dtoc(ddk)+' Двойник '+str(recn(),10)
*         #ifndef __CLIP__
         if aqstr=2
            netdel()
         endif
*         #endif
         skip
      endd
   endif
endd
nuse()
set cons on
set prin off
set prin to txt.txt

******************
func dokktest()
******************
clea
netuse('dokk')
netuse('speng')

cldokk=setcolor('gr+/b,n/w')
wdokk=wopen(10,20,15,60)
wbox(1)
store gdTd to dtr
store 0 to bsr,prskr
store time() to tmr
do while .t.
   @ 0,1 say 'Дата печ гл книги' get dtr
   @ 1,1 say 'Вр   печ гл книги' get tmr
   @ 2,1 say 'Счет             ' get bsr pict '999999'
   @ 2,col()+1 say '0-Все'
   @ 3,1 say 'Признак          ' get prskr pict '9'
   @ 3,col()+1 say '0-Все;1─Бух;2-Скл'
   read
   if lastkey()=27
      wclose('wdokk')
      setcolor('cldokk')
      nuse()
      retu .t.
   endif
   if lastkey()=13
      exit
   endif
endd
wclose('wdokk')
setcolor('cldokk')

sele dokk
go top
rcdokkr=recn()
forr='.t..and.ddc>=dtr.and.!prc.and.!(bs_d=99.or.bs_k=99).and.iif(ddc=dtr,tdc>tmr,.t.)'
if bsr#0
   forr=forr+'.and.(bs_d=bsr.or.bs_k=bsr)'
endif
if prskr#0
   do case
      case prskr=1
           forr=forr+'.and.mn#0'
      case prskr=2
           forr=forr+'.and.mn=0'

   endc
endif
do while .t.
   sele dokk
   go rcdokkr
   rcdokkr=slcf('dokk',1,,18,,"e:sk h:'Скл' c:n(3) e:rn h:'Док' c:n(6) e:ddk h:'Дата Док' c:d(10) e:bs_d h:'Дб' c:n(6) e:bs_k h:'Кр' c:n(6) e:bs_s h:'Сумма' c:n(10,2) e:ddc h:'Дата пров' c:d(10) e:tdc h:'Время' c:c(8) e:getfield('t1','dokk->kg','speng','fio') h:'Кто' c:c(15)",,,,,forr,,'Тест')
   if lastkey()=27
      exit
   endif
endd
nuse()
retu .t.
*****************
func chkdokko(p1)
*****************
* p1 - ttn пока не работает
if !empty(p1)
   ttn_rr=p1
else
   ttn_rr=0
endif
if gnScOut=0
   clea
endif
set prin to dokko.txt
set prin on
netuse('bs')
netuse('dokk')
netuse('dokko')
netuse('dkkln')
netuse('dknap')
netuse('dkklns')
netuse('dkklna')
netuse('tmesto')
netuse('s_tag')
netuse('cskl')
netuse('moddoc')
netuse('mdall')
netuse('kpl')
* Проверить документы
sele dokko
set orde to tag t12
if ttn_rr=0
   go top
   sk_r=0
   do while !eof()
      if mn#0
         skip
         loop
      endif
      skr=sk
      ttnr=rn
      if skr=0
         sele dokko
         netdel()
         if gnScOut=0
            ?str(skr,3)+' '+str(ttnr,6)+' '+'уд. sk=0'+' '+str(skr,3)
         endif
         skip
         loop
      endif
      if skr#sk_r
         sele cskl
         locate for sk=skr
         pathr=gcPath_d+alltrim(path)
         if !netfile('rs1',1)
            sele dokko
            netdel()
            if gnScOut=0
               ?str(skr,3)+' '+str(ttnr,6)+' '+'уд. нет складa'+' '+str(skr,3)
            endif
            skip
            loop
         endif
         nuse('rs1')
         netuse('rs1',,,1)
         sk_r=skr
      endif
      sele rs1
      if !netseek('t1','ttnr')
         if gnScOut=0
            sele dokko
            netdel()
            ?str(skr,3)+' '+str(ttnr,6)+' '+'уд. нет в складе'+' '+str(skr,3)
         endif
      else
         if prz=1
            sele dokko
            netdel()
            if gnScOut=0
               ?str(skr,3)+' '+str(ttnr,6)+' '+'уд. prz=1'+' '+str(skr,3)
            endif
         else
            if empty(dop)
               sele dokko
               netdel()
               if gnScOut=0
                  ?str(skr,3)+' '+str(ttnr,6)+' '+'уд. empty(dop)'+' '+str(skr,3)
               endif
            endif
         endif
      endif
      sele dokko
      skip
   endd
   nuse('rs1')
endif
* Перестроить проводки
sele cskl
go top
do while !eof()
   if ent#gnEnt
      skip
      loop
   endif
   if rasc=0
      skip
      loop
   endif
   pathr=gcPath_d+alltrim(path)
   if !netfile('rs1',1)
      sele cskl
      skip
      loop
   endif
   if gnScOut=0
      ?pathr
   endif
   skr=sk
   netuse('rs1',,,1)
   netuse('rs3',,,1)
   netuse('soper',,,1)
   sele rs1
   go top
   do while !eof()
      ttnr=ttn
      ttn_r=ttnr
      przr=prz
      if przr=1
         sele rs1
         skip
         loop
      endif
      dopr=dop
      if empty(dopr)
         sele rs1
         skip
         loop
      endif
      vur=gnVu
      vor=vo
      d0k1r=0
      kop_r=mod(kop,100)
      kplr=kpl
      kgpr=kgp
      nkklr=nkkl
      kpvr=kpv
      if pr361(d0k1r,vur,vor,kop_r)=0
         sele rs1
         skip
         loop
      endif
      if gnScOut=0
         ?str(ttnr,6)+' '+str(przr,1)
      endif
      rsprv(1,1)
      sele rs1
      skip
   endd
   nuse('rs1')
   nuse('rs3')
   nuse('soper')
   sele cskl
   skip
endd
nuse()
set prin off
set prin to
set cons on
retu .t.

***************
func chkdokk()
***************
if gnScOut=0
   clea
   aqstr=1
   aqst:={"Просмотр","Коррекция"}
   aqstr:=alert("aaa",aqst)
   if lastkey()=27
      retu
   endif
else
   aqstr=2
endif

set prin to dokk.txt
set prin on
set cons off
?' SK'+' '+'  RN  '+' '+'  MNP '
netuse('s_tag')
netuse('cskl')
netuse('dokk')
netuse('operb')
netuse('kpl')
n_nnn=1
n_nn=0
sele dokk
set orde to tag t6
n_nnnn=recc()
go top
sk_rr=0
if gnScout=0
   @ 1,60 say str(n_nnnn,10)
endif
do while !eof()
   sele dokk
   set prin off
   if gnScout=0
      if n_nn=1000
         n_nnn=n_nnn+1000
         @ 2,60 say str(n_nnn,10)
         n_nn=0
      endif
      set prin on
      n_nn=n_nn+1
   endif
   if prc
      if aqstr=2
         netdel()
      endif
      skip
      loop
   endif
   if bs_d=0.and.bs_k=0
      ?'BS_D=0 and BS_K=0 Удален'
      if aqstr=2
         netdel()
      endif
      skip
      loop
   endif
   skr=sk
   mnr=mn
   rnr=rn
   rndr=rnd
   mnpr=mnp
   kszr=ksz
   kopr=kop
   bs_dr=bs_d
   bs_kr=bs_k
   ktar=kta
   kklr=kkl
   ktasr=ktas
   tmestor=tmesto
   dokar=doka
   dokkmskr=dokkmsk
   rmskr=rmsk
   sele dokk
   if mnr=0 // Склад
      if skr=0
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' Удален'
         if aqstr=2
            netdel()
         endif
         skip
         loop
      endif
      if prindr=1
         path_r=getfield('t1','skr','cskl','path')
         pathr=gcPath_d+alltrim(path_r)
         if !netfile('tov',1)
            sele dokk
            skip
            loop
         endif
         if mnpr=0
            if !netuse('rs1','','',1)
               sele dokk
               skip
               loop
            endif
            netuse('rs3','','',1)
            przr=getfield('t1','rnr','rs1','prz')
            rmsk_r=getfield('t1','rnr','rs1','rmsk')
            kplr=getfield('t1','rnr','rs1','kpl')
            kkldocr=kplr
            ktar=getfield('t1','rnr','rs1','kta')
            ktasr=getfield('t1','rnr','rs1','ktas')
            tmestor=getfield('t1','rnr','rs1','tmesto')
            kopr_r=getfield('t1','rnr','rs1','kop')
            vor=getfield('t1','rnr','rs1','vo')
            nkklr=getfield('t1','rnr','rs1','nkkl')
            ssfr=getfield('t1','dokk->rn,dokk->ksz','rs3','ssf')
            d0k1r=0
         else
            if !netuse('pr1','','',1)
               sele dokk
               skip
               loop
            endif
            netuse('pr3','','',1)
            przr=getfield('t2','mnpr','pr1','prz')
            rmsk_r=getfield('t2','mnpr','pr1','rmsk')
            ktar=getfield('t2','mnpr','pr1','kta')
            ktasr=getfield('t2','mnpr','pr1','ktas')
            tmestor=0
            kopr_r=getfield('t2','mnpr','pr1','kop')
            kpsr=getfield('t2','mnpr','pr1','kps')
            kkldocr=kpsr
            vor=getfield('t2','mnpr','pr1','vo')
            ssfr=getfield('t1','dokk->mnp,dokk->ksz','pr3','ssf')
            nkklr=0
            d0k1r=1
         endif
         netuse('soper','','',1)
      else
         if skr#sk_rr
            nuse('rs1')
            nuse('rs3')
            nuse('pr1')
            nuse('pr3')
            nuse('soper')
            path_r=getfield('t1','skr','cskl','path')
            pathr=gcPath_d+alltrim(path_r)
            if !netfile('tov',1)
               sele dokk
               do while sk=skr
                  skip
               endd
               loop
            endif
            sk_rr=skr
            netuse('rs1','','',1)
            netuse('rs3','','',1)
            netuse('pr1','','',1)
            netuse('pr3','','',1)
            netuse('soper','','',1)
         endif
         if mnpr=0
            przr=getfield('t1','rnr','rs1','prz')
            rmsk_r=getfield('t1','rnr','rs1','rmsk')
            kplr=getfield('t1','rnr','rs1','kpl')
            kkldocr=kplr
            ktar=getfield('t1','rnr','rs1','kta')
            ktasr=getfield('t1','rnr','rs1','ktas')
            tmestor=getfield('t1','rnr','rs1','tmesto')
            kopr_r=getfield('t1','rnr','rs1','kop')
            vor=getfield('t1','rnr','rs1','vo')
            nkklr=getfield('t1','rnr','rs1','nkkl')
            ssfr=getfield('t1','dokk->rn,dokk->ksz','rs3','ssf')
            d0k1r=0
         else
            przr=getfield('t2','mnpr','pr1','prz')
            rmsk_r=getfield('t2','mnpr','pr1','rmsk')
            ktar=getfield('t2','mnpr','pr1','kta')
            ktasr=getfield('t2','mnpr','pr1','ktas')
            tmestor=0
            kopr_r=getfield('t2','mnpr','pr1','kop')
            kpsr=getfield('t2','mnpr','pr1','kps')
            kkldocr=kpsr
            vor=getfield('t2','mnpr','pr1','vo')
            ssfr=getfield('t1','dokk->mnp,dokk->ksz','pr3','ssf')
            nkklr=0
            d0k1r=1
         endif
      endif
      sele dokk
      if vor#5.and.kklr#kkldocr
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' '+str(bs_s,10,2)+' '+str(bs_d,6)+' '+str(bs_k,6)+' Удален kkl#kkldoc'
         if aqstr=2
            netdel()
         endif
         skip
         loop
      endif
      if kopr_r#0
         if przr=0
            ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' '+str(bs_s,10,2)+' '+str(bs_d,6)+' '+str(bs_k,6)+' Удален prz=0'
            if aqstr=2
               netdel()
            endif
            skip
            loop
         endif
      else
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' '+str(bs_s,10,2)+' '+str(bs_d,6)+' '+str(bs_k,6)+' Уд.нет в скл'
         if aqstr=2
            netdel()
         endif
         skip
         loop
      endif
      if ssfr=0
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' '+str(bs_s,10,2)+' '+str(bs_d,6)+' '+str(bs_k,6)+' Удален ssf=0'
         if aqstr=2
            netdel()
         endif
         skip
         loop
      endif
      if round(ssfr,2)#round(bs_s,2)
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' '+str(ksz,2)+' '+str(bs_s,10,2)+' '+str(ssfr,10,2)+' '+str(bs_d,6)+' '+str(bs_k,6)+' ssf#bs_s'
      endif
      if kopr#kopr_r
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' '+str(bs_s,10,2)+' '+str(bs_d,6)+' '+str(bs_k,6)+' Удален kop#kop'
         if aqstr=2
            netdel()
         endif
         skip
         loop
      endif
      sele dokk
      if rmsk#rmsk_r
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' '+str(bs_s,10,2)+' '+str(bs_d,6)+' '+str(bs_k,6)+' rmsk'
         if aqstr=2
            netrepl('rmsk','rmsk_r')
         endif
      endif
      qr=mod(kopr,100)
      dokkmskr=space(6)
      levr=0
      sele soper
      if netseek('t1','d0k1r,1,vor,qr')
         prfndr=0
         for i=1 to 20
             cdszr='dsz'+alltrim(str(i,2))
             cddbr='ddb'+alltrim(str(i,2))
             cdkrr='dkr'+alltrim(str(i,2))
             bs_drr=&cddbr
             bs_krr=&cdkrr
             if &cddbr=440000.and.vor=5
                 bs_drr=kplr
             endif
             if d0k1r=0.and.kszr=19
                if vor=9.and.gnEnt>19
                   ssf_rr=getfield('t1','rnr,12','rs3','ssf')
                   if ssf_rr=0
                      bs_drr=361002
                      sele dokk
                      netrepl('bs_d','bs_drr')
                      bs_dr=bs_d
                   endif
                endif
             endif
             if d0k1r=1.and.kszr=19
                if vor=1.and.gnEnt>19  //.and.year(gdTd)=2006
                   ssf_rr=getfield('t1','rnr,12','pr3','ssf')
                   if ssf_rr=0
                      bs_krr=361002
                      sele dokk
                      netrepl('bs_k','bs_krr')
                      bs_kr=bs_k
                   endif
                endif
             endif
             sele soper
             clevr='lev'+alltrim(str(i,2))
             if &cdszr=kszr.and.bs_drr=bs_dr.and.bs_krr=bs_kr
                cprz='prz'+alltrim(str(i,2))
                dokkmskr=&cprz
                levr=&clevr
                prfndr=1
                exit
             endif
         next
      endif
      sele dokk
      if kta#ktar
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' KTA '+str(kta,4)+' '+str(ktar,4)
         if aqstr=2
            netrepl('kta','ktar')
         endif
      endif
      if ktas#ktasr
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' KTAS '+str(ktas,4)+' '+str(ktasr,4)
         if aqstr=2
            netrepl('ktas','ktasr')
         endif
      endif
      if tmesto#tmestor
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' TMESTO '+str(tmesto,7)+' '+str(tmestor,7)
         if aqstr=2
            netrepl('tmesto','tmestor')
         endif
      endif
      if prfndr=0
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' Нет проводок в складе Удален'
         if aqstr=2
             netdel()
         endif
         skip
         loop
      endif
      if dokkmsk#dokkmskr
         ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' DOKKMSK '+dokkmsk+' '+dokkmskr
         if aqstr=2
            netrepl('dokkmsk','dokkmskr')
         endif
      endif
*      #ifdef __CLIP__
*        if fieldpos('lev')#0
*           if lev#levr
*              ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' LEV '+str(lev,1)+' '+str(levr,1)
*              if aqstr=2
*                 netrepl('lev','levr')
*              endif
*           endif
*        endif
*      #endif
      if fieldpos('nkkl')#0
         if nkkl#nkklr
            ?str(sk,3)+' '+str(rn,6)+' '+str(mnp,6)+' NKKL '+str(nkkl,7)+' '+str(nkklr,7)
            if aqstr=2
               netrepl('nkkl','nkklr')
            endif
         endif
      endif
      if prindr=1
         if mnpr=0
            nuse('rs1')
            nuse('rs3')
         else
            nuse('pr1')
            nuse('pr3')
         endif
         nuse('soper')
      endif
   else // Бухгалтерия
      if gnArm=2
         if gnEntrm=1
            if rmskr#9
               if rmsk=0.and.bs_o=301001
                  netdel()
                  skip
                  loop
               endif
               if rmsk=0.and.(bs_d=301001.or.bs_k=301001)
                  netdel()
                  skip
                  loop
               endif
               if rmsk=0.and.bs_o=gnRmbs
                  netrepl('rmsk','gnRmsk')
               endif
               if rmsk#0.and.rmsk#gnRmsk
                  netdel()
                  skip
                  loop
               endif
            endif
         endif
      endif
      dokkmskr=getfield('t1','kopr','operb','mask')
      if fieldpos('dokkmsk')#0
         if dokkmsk#dokkmskr
            ?str(mn,6)+' '+str(rnd,6)+' '+str(rn,6)+' '+' DOKKMSK '+dokkmsk+' '+dokkmskr
            if aqstr=2
               netrepl('dokkmsk','dokkmskr')
            endif
         endif
         if empty(dtmod)
            netrepl('dtmod,tmmod','ddc,tdc')
         endif
      endif
   endif
   sele dokk
   skip
endd
nuse()
set cons on
set prin off
set prin to txt.txt
retu .t.
