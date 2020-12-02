* Прием на основной склад
para p1
* p1 0 - default;1- архив; 2-файл; 3- сверка

if gnArm#0
   clea
endif

if file(gcPath_in+'cdmg.dbf').and.file(pathminr+'dmg.dbf')
   sele 0
   use (gcPath_in+'cdmg') share
   appe from (pathminr+'dmg.dbf')
   repl rm with srmskr,dtz with date(),tmz with time(),kto with gnKto
*   use
endif

sele 0
use (pathminr+'dmg.dbf')
dtr=dt
kolmodr=kolmod
buhskr=buhsk
use
?'Дней модификации '+str(kolmodr,2)+' Период '+dtoc(dtr)+' '+str(buhskr,1)
dir_gr='g'+str(year(dtr),4)+'\'
dir_dr='m'+iif(month(dtr)<10,'0'+str(month(dtr),1),str(month(dtr),2))+'\'

rmrca0()
sele cdmg
if fieldpos('dto')#0
   repl dto with date(),;
        tmo with time()
endif
use
wmess('Прием окончен',0)
retu .t.

**********************************************************
func rmrca0()
* ПРИЕМ ALL
**********************************************************
sele 0
use (pathminr+'dmg.dbf')
dtr=dt
kolmodr=kolmod
buhskr=buhsk
use

* Копирование файлов RC1=1,2

?'COMM'
pathinr=pathminr+gcDir_c
pathoutr=pathmoutr+gcDir_c
dirr=1
rcfl(0)
commrc0()

?'ENT '
pathinr=pathminr+gcDir_e
pathoutr=pathmoutr+gcDir_e
dirr=4
rcfl(0)
entrc0()


yy1r=year(dtr)
yy2r=year(dtr)


for yy=yy1r to yy2r
    pathinr=pathminr+gcDir_e+'g'+str(yy,4)+'\'
    pathoutr=pathmoutr+gcDir_e+'g'+str(yy,4)+'\'
    ?pathinr
    dirr=7
    rcfl(0)
    do case
       case yy1r=yy2r
            mm1r=month(dtr)
            mm2r=month(dtr)
       case yy=yy1r
            mm1r=month(dtr)
            mm2r=12
       case yy=yy2r
            mm1r=1
            mm2r=month(dtr)
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
        rcfl(0)
        pathinr=pathminr+gcDir_c+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'
        pathoutr=pathmoutr+gcDir_c+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'
        dirinr=pathminr+gcDir_c+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))
        diroutr=pathmoutr+gcDir_c+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))
        if dirchange(dirinr)=0
           if dirchange(diroutr)=0
              ?pathinr
              dirr=9
              rcfl(0)
           endif
        endif
        dirchange(gcPath_l)
        *BANK
        pathinr=pathminr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'+gcDir_b
        pathoutr=pathmoutr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'+gcDir_b
        dirinr=pathminr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\bank'
        diroutr=pathmoutr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\bank'
        if dirchange(dirinr)=0
           if dirchange(diroutr)=0
              ?pathinr
              dirr=2
              rcfl(0)
              pathr=pathmoutr+gcDir_e+dir_gr+dir_dr
              netuse('nnds',,,1)
              netuse('cntm',,,1)
              bankrc0a()
              nuse('nds')
              nuse('cntm')
           endif
        endif
        dirchange(gcPath_l)
        *'GLOB'
        pathinr=pathminr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'+gcDir_gl
        pathoutr=pathmoutr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'+gcDir_gl
        dirinr=pathminr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\glob'
        diroutr=pathmoutr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\glob'
        if dirchange(dirinr)=0
           if dirchange(diroutr)=0
              ?pathinr
              dirr=2
              rcfl(0)
           endif
        endif
        dirchange(gcPath_l)
        *'SKLAD'
        pathr=pathmoutr+gcDir_c
        netuse('kln',,,1)
        netuse('cskl',,,1)
*        netuse('s_tag',,,1)
        netuse('vop',,,1)
        netuse('vo',,,1)
        netuse('dclr',,,1)
        netuse('tmesto',,,1)
        pathr=pathmoutr+gcDir_e
        netuse('tara',,,1)
        netuse('tcen',,,1)
        netuse('moddoc',,,1)
        netuse('mdall',,,1)
        netuse('kpl',,,1)
        netuse('kps',,,1)
        netuse('cgrp',,,1)
        netuse('ctov',,,1)
        netuse('stagm',,,1)
        netuse('s_tag',,,1)
        netuse('nap',,,1)
        netuse('naptm',,,1)
        netuse('kplnap',,,1)
        netuse('ktanap',,,1)
        netuse('nds',,,1)
        netuse('etm',,,1)
        pathr=pathmoutr+gcDir_e+dir_gr+dir_dr+gcDir_b
        netuse('dokk',,,1)
        netuse('dkkln',,,1)
        netuse('dknap',,,1)
        netuse('dokko',,,1)
        netuse('dkklns',,,1)
        netuse('dkklna',,,1)
        netuse('bs',,,1)
        pathr=pathmoutr+gcDir_e+dir_gr+dir_dr
        netuse('nnds',,,1)
        netuse('cntm',,,1)

        sele cskl
        do while !eof()
           if ent#gnEnt
              skip
              loop
           endif
           if tpstpok=0
              skip
              loop
           endif
           if tpstpok=1
              prer='pst'
           else
              prer='pok'
           endif
           pathr=gcPath_d+alltrim(path)
           if !netfile('tov',1)
              sele cskl
              skip
              loop
           endif
           netuse('tov','tov'+prer,,1)
           netuse('soper','soper'+prer,,1)
           netuse('sgrp','sgrp'+prer,,1)
           netuse('tovm','tovm'+prer,,1)
           netuse('pr1','pr1'+prer,,1)
           netuse('pr2','pr2'+prer,,1)
           netuse('pr3','pr3'+prer,,1)
           netuse('rs1','rs1'+prer,,1)
           netuse('rs2','rs2'+prer,,1)
           netuse('rs3','rs3'+prer,,1)
           sele cskl
           skip
           loop
        endd

        sele cskl
        go top
        rccsklar=0
        do while !eof()
           rccsklar=recn()
           if ent#gnEnt
              skip
              loop
           endif
           if arnd#3
              if rm=0
                 skip
                 loop
              endif
              if rm#srmskr
                 skip
                 loop
              endif
           endif
           pathinr=pathminr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'+alltrim(path)
           pathoutr=pathmoutr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'+alltrim(path)
           path_dr=pathmoutr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'
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
           gnSk_rr=gnSk
           gnSk=skr
           ?pathinr
           rcfl(0)
           sele cskl
           skladrc0a()
           gnSk=gnSk_rr
           sele cskl
           go rccsklar
           skip
        endd

        for i_i=1 to 2
            if i_i=1
               prer='pst'
            else
               prer='pok'
            endif
            nuse('soper'+prer)
            nuse('sgrp'+prer)
            nuse('tov'+prer)
            nuse('tovm'+prer)
            nuse('pr1'+prer)
            nuse('pr2'+prer)
            nuse('pr3'+prer)
            nuse('rs1'+prer)
            nuse('rs2'+prer)
            nuse('rs3'+prer)
        next

        nuse('cskl')
        nuse('kln')
        nuse('s_tag')
        nuse('stagm')
        nuse('vop')
        nuse('vo')
        nuse('tara')
        nuse('dclr')
        nuse('tcen')
        nuse('moddoc')
        nuse('mdall')
        nuse('kpl')
        nuse('kps')
        nuse('tovpt')
        nuse('cgrp')
        nuse('dokk')
        nuse('dkkln')
        nuse('dknap')
        nuse('dokko')
        nuse('dkklns')
        nuse('dkklna')
        nuse('nap')
        nuse('naptm')
        nuse('kplnap')
        nuse('ktanap')
        nuse('tmesto')
        nuse('bs')
        nuse('ctov')
        nuse('nds')
        nuse('nnds')
        nuse('cntm')
        nuse('etm')
    next
next
retu .t.


**************
func commrc0()
*
**************
retu .t.

***************************************************
func entrc0()
*
***************************************************

pathr=pathinr
*if netfile('nds',1)
*   netuse('nds','ndsin',,1)
*   pathr=pathoutr
*   netuse('nds',,,1)
*   sele ndsin
*   go top
*   do while !eof()
*      arec:={}
*      getrec()
*      nomndsr=nomnds
*      skr=sk
*      ttnr=ttn
*      d0k1r=d0k1
*      sele nds
*      if netseek('t3','skr,ttnr,d0k1r')
*         if nomnds#nomndsr
*            reclock()
*            putrec()
*            netunlock()
*         endif
*      else
*         if netseek('t1','nomndsr')
*            arec1:={}
*            getrec('arec1')
*            prupdtr=0
*            for i=1 to len(arec)
*                if arec[i]#arec1[i]
*                   prupdtr=1
*                   exit
*                endif
*            next
*            if prupdtr=1
*               reclock()
*               putrec()
*               netunlock()
*            endif
*         else
*            netadd()
*            putrec()
*            netunlock()
*         endif
*      endif
*      sele ndsin
*      skip
*   endd
*   nuse('ndsin')
*   nuse('nds')
*endif

pathr=pathinr
if netfile('moddoc',1)
   netuse('moddoc','in',,1)
   pathr=pathoutr
   netuse('moddoc','out',,1)
   sele in
   go top
   do while !eof()
      arec:={}
      getrec()
      mnr=mn
      rndr=rnd
      rnr=rn
      skr=sk
      mnpr=mnp
      dtmodr=dtmod
      tmmodr=tmmod
      tmmodvzr=tmmodvz
      if fieldpos('rm')#0
         rmr=rm
      else
         rmr=0
      endif
      sele out
      if netseek('t1','mnr,rndr,rnr,skr,mnpr')
         if empty(tmmodvzr)
            if dtmod#dtmodr.or.tmmod#tmmodr
               reclock()
               putrec()
               netunlock()
            endif
         else
            if dtmod#dtmodr.or.tmmodvz#tmmodvzr
               reclock()
               putrec()
               netunlock()
            endif
         endif
      else
         netadd()
         putrec()
         netunlock()
      endif
      if fieldpos('rm')#0
         netrepl('rm','rmr')
      endif
      sele in
      skip
   endd
   nuse('in')
   nuse('out')
endif
pathr=pathinr
if netfile('mdall',1)
   netuse('mdall','in',,1)
   pathr=pathoutr
   netuse('mdall','out',,1)
   sele in
   go top
   do while !eof()
      arec:={}
      getrec()
      mnr=mn
      rndr=rnd
      rnr=rn
      skr=sk
      mnpr=mnp
      dtmodr=dtmod
      tmmodr=tmmod
      tmmodvzr=tmmodvz
      sele out
      if netseek('t1','mnr,rndr,rnr,skr,mnpr')
         if empty(tmmodvzr)
            if dtmod#dtmodr.or.tmmod#tmmodr
               reclock()
               putrec()
               netunlock()
            endif
         else
            if dtmod#dtmodr.or.tmmodvz#tmmodvzr
               reclock()
               putrec()
               netunlock()
            endif
         endif
      else
         netadd()
         putrec()
         netunlock()
      endif
      sele in
      skip
   endd
   nuse('in')
   nuse('out')
endif
retu .t.

**************
func bankrc0a()
*
**************

flrc1('dokz','t2')
flrc1('doks','t4')

pathr=pathoutr
netuse('operb',,,1)
netuse('dkkln',,,1)
netuse('dknap',,,1)
netuse('dkklns',,,1)
netuse('dkklna',,,1)
netuse('bs',,,1)

pathr=pathmoutr+gcDir_e
netuse('moddoc',,,1)
netuse('mdall',,,1)

pathr=pathinr
if netfile('dokk',1)
   netuse('dokk','dokkin',,1)
   set orde to tag t12
   pathr=pathoutr
   netuse('dokk',,,1)
   set orde to tag t12

   sele dokkin
   go top
   do while !eof()
      mnr=mn
      rndr=rnd
      rnr=rn
      kklr=kkl
      skr=sk
      if skr#0
         sele dokk
         if netseek('t12','mnr,rndr,0,rnr')
            netrepl('sk','skr')
         endif
      endif
      sele dokk
      if !netseek('t12','mnr,rndr,skr,rnr')
         sele dokkin
         arec:={}
         getrec()
         sele dokk
         netadd()
         putrec()
         netunlock()
         ddkr=ddk
         docmod('доб',1)
         mdall('доб')
         msk(1,0)
*         maska(dokkout->kop,dokkout->kkl,dokkout->skl,dokkout->bs_s,1)
      else
         prinsr=1
         do while mn=mnr.and.rnd=rndr.and.sk=skr.and.rn=rnr
            if !prc.and.!(bs_d=99.or.bs_k=99)
               prinsr=0
               exit
            endif
            skip
         endd
         if prinsr=1
            sele dokkin
            arec:={}
            getrec()
            sele dokk
            netadd()
            putrec()
            netunlock()
            ddkr=ddk
            docmod('доб',1)
            mdall('доб')
            msk(1,0)
*            maska(dokkout->kop,dokkout->kkl,dokkout->skl,dokkout->bs_s,1)
         else
            sele dokkin
            arec:={}
            getrec()
            sele dokk
            arec1:={}
            getrec('arec1')
            prupdtr=0
            for i=1 to len(arec)
                if arec[i]#arec1[i]
                   prupdtr=1
                   exit
                endif
            next
            if prupdtr=1
               sele dokk
               ddkr=ddk
               msk(0,0)
*               maska(dokkout->kop,dokkout->kkl,dokkout->skl,dokkout->bs_s,0)
               reclock()
               putrec()
               netunlock()
               ddkr=ddk
               docmod('корр',1)
               mdall('корр')
               msk(1,0)
*               maska(dokkout->kop,dokkout->kkl,dokkout->skl,dokkout->bs_s,1)
            endif
         endif
      endif
      sele dokkin
      skip
   endd
   sele dokk
   set orde to tag t7
   if netseek('t7','srmskr')
      do while rmsk=srmskr
         if mn=0
            skip
            loop
         endif
         if prc.or.bs_d=99.or.bs_k=99
            skip
            loop
         endif
         mnr=mn
         rndr=rnd
         rnr=rn
         skr=sk
         kklr=kkl
         rmsk_r=rmsk
         sele dokkin
         if !netseek('t12','mnr,rndr,skr,rnr')
            sele dokk
            ddkr=ddk
            docmod('уд',1)
            mdall('уд')
            msk(0,0)
            netdel()
         endif
         sele dokk
         skip
      endd
   endif
   nuse('dokk')
   nuse('dokkin')
endif
nuse('operb')
nuse('bs')
nuse('dkkln')
nuse('dknap')
nuse('dkklns')
nuse('dkklna')
nuse('moddoc')
nuse('mdall')
retu .t.

**************
func skladrc0a()
*
**************
   path_rr=alltrim(path)
   if !file(pathinr+'trsho14.dbf')
      retu .t.
   endif
   pathr=pathinr
   netuse('pr1','pr1in',,1)
   netuse('pr2','pr2in',,1)
   netuse('pr3','pr3in',,1)
   netuse('rs1','rs1in',,1)
   netuse('rs2','rs2in',,1)
   netuse('rs3','rs3in',,1)

   pathr=pathoutr
   netuse('pr1',,,1)
   set orde to tag t2
   netuse('pr2',,,1)
   netuse('pr3',,,1)
   netuse('rs1',,,1)
   netuse('rs2',,,1)
   netuse('rs3',,,1)
   netuse('tov',,,1)
   netuse('tovm',,,1)
   netuse('soper',,,1)
   netuse('sgrp',,,1)
   * Приход
   ?'Приход'
   if kolmodr=0
      * Проверка на удаленные
      sele pr1
      go top
      do while !eof()
         if rmsk#srmskr
            skip
            loop
         endif
         if sks#0 && Автоматический
            skip
            loop
         endif
         ndr=nd
         mnr=mn
         przr=prz
         sklr=skl
         if !netseek('t2','mnr','pr1in')
            sele pr2
            if netseek('t1','mnr')
               do while mn=mnr
                  ktlr=ktl
                  mntovr=mntov
                  kfr=kf
                  if przr=1
                     sele tov
                     if netseek('t1','sklr,ktlr')
                        netrepl('osv,osf,osfo','osv-kfr,osf-kfr,osfo-kfr')
                     endif
                     sele tovm
                     if netseek('t1','sklr,mntovr')
                        netrepl('osv,osf,osfo','osv-kfr,osf-kfr,osfo-kfr')
                     endif
                  endif
                  sele pr2
                  netdel()
                  skip
               endd
            endif
            sele pr3
            if netseek('t1','mnr')
               do while mn=mnr
                  netdel()
                  skip
               endd
            endif
            sele pr1
            netdel()
            ?'ND '+str(ndr,6)+' MN '+str(mnr,6)+' '+str(rmsk,1)+' '+str(prz,1)+' удален'
         endif
         sele pr1
         skip
      endd
   endif
   sele pr1in
   go top
   do while !eof()
      sklr=skl
      ndr=nd
      mnr=mn
      vor=vo
      przr=prz
      sktr=skt
      skltr=sklt
      sele pr1 &&out
      if !netseek('t2','mnr') && Приход новый
         sele pr3 &&out
         if netseek('t1','mnr')
            do while mn=mnr
               netdel()
               skip
            endd
         endif
         sele pr2 &&out
         if netseek('t1','mnr')
            do while mn=mnr
               netdel()
               skip
            endd
         endif
         sele pr3in
         if netseek('t1','mnr')
            do while mn=mnr
               arec:={}
               getrec()
               sele pr3 &&out
               netadd()
               putrec()
               netunlock()
               sele pr3in
               skip
            endd
         endif
         sele pr2in
         if netseek('t1','mnr')
            do while mn=mnr
               ktlr=ktl
               mntovr=mntov
               kfr=kf
               zenr=zen
               arec:={}
               getrec()
               sele pr2 &&out
               netadd()
               putrec()
               netunlock()
               sele tov &&out
               if netseek('t1','sklr,ktlr')
                  netrepl('osv,osf,osfo','osv+kfr,osf+kfr,osfo+kfr')
               else
                  sele ctov
                  if netseek('t1','mntovr')
                     arec:={}
                     getrec()
                     sele tov
                     netadd()
                     putrec()
                     netrepl('skl,ktl','sklr,ktlr')
                     netrepl('opt,osv,osf,osfo','zenr,kfr,kfr,kfr')
                  endif
               endif
               sele tovm &&out
               if netseek('t1','sklr,mntovr')
                  netrepl('osv,osf,osfo','osv+kfr,osf+kfr,osfo+kfr')
               else
                  sele ctov
                  if netseek('t1','mntovr')
                     arec:={}
                     getrec()
                     sele tovm
                     netadd()
                     putrec()
                     netrepl('skl','sklr')
                     netrepl('osv,osf,osfo','kfr,kfr,kfr')
                  endif
               endif
               sele pr2in
               skip
            endd
         endif
         sele pr1in
         arec:={}
         getrec()
         sele pr1 &&out
         netadd()
         putrec()
         netrepl('amn','0')
      else && Коррекция прихода
         sele pr1 &&out
         chkmnior=.t. && DEFAULT Документы одинаковы
         #ifdef __CLIP__
         #else
            if kolmodr=0
               chkmnior=chkmnio()
            endif
         #endif
         reclock()
         sele pr3 &&out
         if netseek('t1','mnr')
            do while mn=mnr
               netdel()
               skip
            endd
         endif
         sele pr3in
         if netseek('t1','mnr')
            do while mn=mnr
               arec:={}
               getrec()
               sele pr3 &&out
               netadd()
               putrec()
               netunlock()
               sele pr3in
               skip
            endd
         endif
         sele pr2 &&out
         if netseek('t1','mnr')
            do while mn=mnr
               ktlr=ktl
               mntovr=mntov
               kfr=kf
               sele tov &&out
               if netseek('t1','sklr,ktlr')
                  netrepl('osv,osf,osfo','osv-kfr,osf-kfr,osfo-kfr')
               endif
               sele tovm &&out
               if netseek('t1','sklr,mntovr')
                  netrepl('osv,osf,osfo','osv-kfr,osf-kfr,osfo-kfr')
               endif
               sele pr2 &&out
               netdel()
               skip
            endd
         endif
         sele pr2in
         if netseek('t1','mnr')
            do while mn=mnr
               ktlr=ktl
               mntovr=mntov
               kfr=kf
               arec:={}
               getrec()
               sele pr2 &&out
               netadd()
               putrec()
               netunlock()
               sele tov &&out
               if netseek('t1','sklr,ktlr')
                  netrepl('osv,osf,osfo','osv+kfr,osf+kfr,osfo+kfr')
               endif
               sele tovm &&out
               if netseek('t1','sklr,mntovr')
                  netrepl('osv,osf,osfo','osv+kfr,osf+kfr,osfo+kfr')
               endif
               sele pr2in
               skip
            endd
         endif
         sele pr1in
         arec:={}
         getrec()
         sele pr1 &&out
         amnr=amn
         nndsr=nnds
         putrec()
         netrepl('amn,nnds','amnr,nndsr')
      endif
      sele pr1
      kopr=kop
      if kopr=188.or.kopr=189
         prrsa(2)
         prrsa(1)
      endif
      vor=vo
      amnr=amn
      pstr=pst
      sele soper
      locate for d0k1=1.and.vo=vor.and.kop=mod(kopr,100)
      skar=ska
      tpstpokr=getfield('t1','skar','cskl','tpstpok')
      if tpstpokr#0
         if tpstpokr=1
            prer=('pst')
         else
            prer=('pok')
         endif
      endif
      autor=auto
      if autor=2.and.tpstpokr#0
         store 0 to prtr,prstr && Признак НДС на тару\ст.тару
         store 0 to prktr,prkstr && Призн налич т\ст в док (18,19,pr2)
         if !vztara(1)
            if amnr#0
               sele pr1
               if pprha(2)
                  ?str(ndr,6)+' '+str(mnr,6)+' '+str(sktr,3)+' удаление автомата-нет вз.тары'
               endif
               sele pr1
               netrepl('amn','0')
            endif
         else
            sele pr1
            if przr=1
               if !pprha(2)
                  ?str(ndr,6)+' '+str(mnr,6)+' '+str(sktr,3)+' новый автомат'
               else
                  ?str(ndr,6)+' '+str(mnr,6)+' '+str(sktr,3)+' коррекция автомата'
               endif
               sele pr1
               pprha(1)
            endif
         endif
      endif
      runcdocopt(1,mnr)
      sele pr1in
      skip
   endd

   * Расход
   ?'Расход'
   if kolmodr=0
      * Проверка на удаленные
      sele rs1
      go top
      do while !eof()
         if rmsk#srmskr
            skip
            loop
         endif
         ttnr=ttn
         przr=prz
         dopr=dop
         sklr=skl
         if !netseek('t1','ttnr','rs1in')
            sele rs2
            if netseek('t1','ttnr')
               do while ttn=ttnr
                  ktlr=ktl
                  mntovr=mntov
                  kvpr=kvp
                  if przr=1
                     sele tov
                     if netseek('t1','sklr,ktlr')
                        netrepl('osv,osf,osfo','osv+kvpr,osf+kvpr,osfo+kvpr')
                     endif
                     sele tovm
                     if netseek('t1','sklr,mntovr')
                        netrepl('osv,osf,osfo','osv+kvpr,osf+kvpr,osfo+kvpr')
                     endif
                  else
                     if !empty(dopr)
                        sele tov
                        if netseek('t1','sklr,ktlr')
                           netrepl('osv,osfo','osv+kvpr,osfo+kvpr')
                        endif
                        sele tovm
                        if netseek('t1','sklr,mntovr')
                           netrepl('osv,osfo','osv+kvpr,osfo+kvpr')
                        endif
                     else
                        sele tov
                        if netseek('t1','sklr,ktlr')
                           netrepl('osv','osv+kvpr')
                        endif
                        sele tovm
                        if netseek('t1','sklr,mntovr')
                           netrepl('osv','osv+kvpr')
                        endif
                     endif
                  endif
                  sele rs2
                  netdel()
                  skip
               endd
            endif
            sele rs3
            if netseek('t1','ttnr')
               do while ttn=ttnr
                  netdel()
                  skip
               endd
            endif
            sele rs1
            netdel()
            ?'TTN '+str(ttnr,6)+' '+str(rmsk,1)+' '+str(prz,1)+' удален'
         endif
         sele rs1
         skip
      endd
   endif
   sele rs1in
   go top
   do while !eof()
      sklr=skl
      ttnr=ttn
      vor=vo
      przinr=prz
      dopinr=dop
      sktr=skt
      skltr=sklt
      przr=prz
      sele rs1 &&out
      if !netseek('t1','ttnr') && Расход новый
         sele rs3 &&out
         if netseek('t1','ttnr')
            do while ttn=ttnr
               netdel()
               skip
            endd
         endif
         sele rs2 &&out
         if netseek('t1','ttnr')
            do while ttn=ttnr
               netdel()
               skip
            endd
         endif
         sele rs3in
         if netseek('t1','ttnr')
            do while ttn=ttnr
               arec:={}
               getrec()
               sele rs3 &&out
               netadd()
               putrec()
               netunlock()
               sele rs3in
               skip
            endd
         endif
         sele rs2in
         if netseek('t1','ttnr')
            do while ttn=ttnr
               ktlr=ktl
               mntovr=mntov
               kfr=kvp
               arec:={}
               getrec()
               sele rs2 &&out
               netadd()
               putrec()
               netunlock()
               sele tov &&out
               if !netseek('t1','sklr,ktlr')
                  sele ctov
                  if netseek('t1','mntovr')
                     arec:={}
                     getrec()
                     sele tov
                     netadd()
                     putrec()
                     netrepl('skl,ktl','sklr,ktlr')
                  endif
               endif
               if przinr=1
                  netrepl('osv,osf,osfo','osv-kfr,osf-kfr,osfo-kfr')
               else
                  if !empty(dopinr)
                     netrepl('osv,osfo','osv-kfr,osfo-kfr')
                  else
                     netrepl('osv','osv-kfr')
                  endif
               endif
               sele tovm &&out
               if !netseek('t1','sklr,mntovr')
                  sele ctov
                  if netseek('t1','mntovr')
                     arec:={}
                     getrec()
                     sele tov
                     netadd()
                     putrec()
                     netrepl('skl','sklr')
                  endif
               endif
               if przinr=1
                  netrepl('osv,osf,osfo','osv-kfr,osf-kfr,osfo-kfr')
               else
                  if !empty(dopinr)
                     netrepl('osv,osfo','osv-kfr,osfo-kfr')
                  else
                     netrepl('osv','osv-kfr')
                  endif
               endif
               sele rs2in
               skip
            endd
         endif
         sele rs1in
         arec:={}
         getrec()
         sele rs1 &&out
         netadd()
         putrec()
         netrepl('amn','0')
      else && Коррекция расхода
         sele rs1 &&out
         chkttnior=.t. && DEFAULT Документы одинаковы
*         #ifdef __CLIP__
*         #else
*            if kolmodr=0
*               chkttnior=chkttnio()
*            endif
*         #endif
         reclock()
         przoutr=prz
         dopoutr=dop
         sele rs3 &&out
         if netseek('t1','ttnr')
            do while ttn=ttnr
               netdel()
               skip
            endd
         endif
         sele rs3in
         if netseek('t1','ttnr')
            do while ttn=ttnr
               arec:={}
               getrec()
               sele rs3 &&out
               netadd()
               putrec()
               netunlock()
               sele rs3in
               skip
            endd
         endif
         sele rs2 &&out
         if netseek('t1','ttnr')
            do while ttn=ttnr
               ktlr=ktl
               mntovr=mntov
               kfr=kvp
               sele tov &&out
               if !netseek('t1','sklr,ktlr')
                  sele ctov
                  if netseek('t1','mntovr')
                     arec:={}
                     getrec()
                     sele tov
                     netadd()
                     putrec()
                     netrepl('skl,ktl','sklr,ktlr')
                  endif
               endif
               if przoutr=1
                  netrepl('osv,osf,osfo','osv+kfr,osf+kfr,osfo+kfr')
               else
                  if !empty(dopoutr)
                     netrepl('osv,osfo','osv+kfr,osfo+kfr')
                  else
                     netrepl('osv','osv+kfr')
                  endif
               endif
               sele tovm &&out
               if !netseek('t1','sklr,mntovr')
                  sele ctov
                  if netseek('t1','mntovr')
                     arec:={}
                     getrec()
                     sele tovm
                     netadd()
                     putrec()
                     netrepl('skl','sklr')
                  endif
               endif
               if przoutr=1
                  netrepl('osv,osf,osfo','osv+kfr,osf+kfr,osfo+kfr')
               else
                  if !empty(dopoutr)
                     netrepl('osv,osfo','osv+kfr,osfo+kfr')
                  else
                     netrepl('osv','osv+kfr')
                  endif
               endif
               sele rs2 &&out
               netdel()
               skip
            endd
         endif
         sele rs2in
         if netseek('t1','ttnr')
            do while ttn=ttnr
               ktlr=ktl
               mntovr=mntov
               kfr=kvp
               arec:={}
               getrec()
               sele rs2 &&out
               netadd()
               putrec()
               netunlock()
               sele tov &&out
               if netseek('t1','sklr,ktlr')
                  if przinr=1
                     netrepl('osv,osf,osfo','osv-kfr,osf-kfr,osfo-kfr')
                  else
                     if !empty(dopinr)
                        netrepl('osv,osfo','osv-kfr,osfo-kfr')
                     else
                        netrepl('osv','osv-kfr')
                     endif
                  endif
               endif
               sele tovm &&out
               if netseek('t1','sklr,mntovr')
                  if przinr=1
                     netrepl('osv,osf,osfo','osv-kfr,osf-kfr,osfo-kfr')
                  else
                     if !empty(dopinr)
                        netrepl('osv,osfo','osv-kfr,osfo-kfr')
                     else
                        netrepl('osv','osv-kfr')
                     endif
                  endif
               endif
               sele rs2in
               skip
            endd
         endif
         sele rs1in
         arec:={}
         getrec()
         sele rs1 &&out
         amnr=amn
         nndsr=nnds
         putrec()
         netrepl('amn,nnds','amnr,nndsr')
      endif
      kopr=kop
      vor=vo
      if fieldpos('tmcrm')#0
         tmestor=tmesto
         tmcrmr=tmcrm
         sele etm
         if netseek('t1','tmestor')
            netrepl('crm','tmcrmr')
         endif
      endif
      sele rs1
      if vor=6.and.(kopr=188.or.kopr=189).or.vor=10.and.(kopr=183.or.kopr=193)
         rspra(2)
         rspra(1)
      endif
      sele rs1
      vor=vo
      amnr=amn
      pstr=pst
      sele soper
      locate for d0k1=0.and.vo=vor.and.kop=mod(kopr,100)
      skar=ska
      koppr=kopp
      tpstpokr=getfield('t1','skar','cskl','tpstpok')
      if tpstpokr#0
         if tpstpokr=1
            prer=('pst')
         else
            prer=('pok')
         endif
      endif
      autor=auto
      if autor=2.and.tpstpokr#0
         store 0 to prtr,prstr && Признак НДС на тару\ст.тару
         store 0 to prktr,prkstr && Призн налич т\ст в док (18,19,pr2)
         if !vztara(0)
            if amnr#0
               sele rs1
               if rprha(2)
                  ?str(ttnr,6)+' '+str(sktr,3)+' удаление автомата-нет вз.тары'
               endif
               sele rs1
               netrepl('amn','0')
            endif
         else
            if przr=1
               if !rprha(2)
                  ?str(ttnr,6)+' '+str(sktr,3)+' новый автомат'
               else
                  ?str(ttnr,6)+' '+str(sktr,3)+' коррекция автомата'
               endif
               sele rs1
               rprha(1)
            endif
         endif
      endif
      runcdocopt(0,ttnr)
      sele rs1in
      skip
   endd

   nuse('pr1in')
   nuse('pr2in')
   nuse('pr3in')

   nuse('pr1')
   nuse('pr2')
   nuse('pr3')

   nuse('rs1in')
   nuse('rs2in')
   nuse('rs3in')

   nuse('rs1')
   nuse('rs2')
   nuse('rs3')

   nuse('tov')
   nuse('tovm')
   nuse('soper')
   nuse('sgrp')
* Заявки КПК
   if file(pathinr+'rs1kpk.dbf')
      pathr=pathinr
      netuse('rs1kpk','rs1in',,1)
      netuse('rs2kpk','rs2in',,1)
      pathr=pathoutr
      netuse('rs1kpk',,,1)
      netuse('rs2kpk',,,1)
      sele rs1in
      go top
      do while !eof()
         ttnr=ttn
         skpkr=skpk
         sele rs1kpk
         if !netseek('t1','ttnr,skpkr')
            sele rs1in
            arec:={}
            getrec()
            sele rs1kpk
            netadd()
            putrec()
            netunlock()
         endif
         sele rs1in
         skip
      endd
      sele rs2in
      go top
      do while !eof()
         ttnr=ttn
         skpkr=skpk
         sele rs2kpk
         if !netseek('t1','ttnr,skpkr')
            sele rs2in
            arec:={}
            getrec()
            sele rs2kpk
            netadd()
            putrec()
            netunlock()
         endif
         sele rs2in
         skip
      endd
      nuse('rs1in')
      nuse('rs2in')
      nuse('rs1kpk')
      nuse('rs2kpk')
   endif
retu .t.

*************************
func chkttnio()
* Сравнение IN и OUT ТТН
*************************
* RS1
prupdtr=0
sele rs1in
arec:={}
getrec()
sele rs1out
arec1:={}
getrec('arec1')
for i=1 to len(arec)
    if arec[i]#arec1[i]
       prupdtr=1
       exit
    endif
next
if prupdtr=0
   * RS2
   sele rs2in
   if netseek('t1','ttnr')
      do while ttn=ttnr
         ktlr=ktl
         pptr=ppt
         ktlpr=ktlp
         arec:={}
         getrec()
         sele rs2out
         if netseek('t3','ttnr,ktlpr,pptr,ktlr')
            arec1:={}
            getrec()
            for i=1 to len(arec)
                if arec[i]#arec1[i]
                   prupdtr=1
                   exit
                endif
            next
         else
            prupdtr=1
            exit
         endif
         sele rs2in
         skip
      endd
   endif
endif
if prupdtr=0
   * RS3
endif
if prupdtr=1
   retu .f. && Документы НЕ одинаковые
endif
retu .t. && Документы одинаковые

*************************
func chkmnio()
* Сравнение IN и OUT MN
*************************

retu .t. && Документы одинаковые
