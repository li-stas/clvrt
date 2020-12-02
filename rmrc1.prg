* Прием на удаленный склад
if gnArm#0
   clea
endif

vsvbr=1

if file(gcPath_in+'cdmg.dbf').and.file(pathminr+'dmg.dbf')
   sele 0
   use (gcPath_in+'cdmg') excl
   appe from (pathminr+'dmg.dbf')
   repl dtz with date(),tmz with time(),kto with gnKto
*   use
endif

sele 0
use (pathminr+'dmg.dbf')
dtr=dt
kolmodr=kolmod
use
?'Дней модификации '+str(kolmodr,2)+' Период '+dtoc(dtr)
dir_gr='g'+str(year(dtr),4)+'\'
dir_dr='m'+iif(month(dtr)<10,'0'+str(month(dtr),1),str(month(dtr),2))+'\'

rmrca1()

sele cdmg
if fieldpos('dto')#0
   repl dto with date(),;
        tmo with time()
endif
use
wmess('Прием окончен',0)
return .t.

*******************
func astrurc1()
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
   pathr=pathinr
   sele 0
   use (pathr+'dbft') alias dbftin
   do while !eof()
      nfr=nf
      sele dbft
      locate for nf=nfr
      if !foun()
         sele dbftin
         arec:={}
         getrec()
         sele dbft
         netadd()
         putrec()
         netunlock()
      else
         sele dbftin
         arec:={}
         getrec()
         sele dbft
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
            sele dbft
            reclock()
            putrec()
            netunlock()
         endif
      endif
      sele dbftin
      skip
   endd
   sele dbftin
   use
endif
if file(pathinr+'dir.dbf')
   pathr=pathinr
   sele 0
   use (pathr+'dir') alias dirin
   do while !eof()
      dirr=dir
      sele dir
      locate for dir=dirr
      if !foun()
         sele dirin
         arec:={}
         getrec()
         sele dir
         netadd()
         putrec()
         netunlock()
      else
         sele dirin
         arec:={}
         getrec()
         sele dir
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
            sele dir
            reclock()
            putrec()
            netunlock()
         endif
      endif
      sele dirin
      skip
   endd
   sele dirin
   use
endif
pathinr=pathminr+gcDir_e
pathoutr=pathmoutr+gcDir_e
if file(pathinr+'prd.dbf')
   pathr=pathinr
   sele 0
   use (pathr+'prd') alias prdin
   do while !eof()
      godr=god
      mesr=mes
      if godr=year(dtr).and.mesr=month(dtr)
         sele prd
         locate for god=godr.and.mes=mesr
         if !foun()
            sele prdin
            arec:={}
            getrec()
            sele prd
            netadd()
            putrec()
            netunlock()
         else
            sele prdin
            arec:={}
            getrec()
            sele prd
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
               sele prd
               reclock()
               putrec()
               netunlock()
            endif
         endif
      endif
      sele prdin
      skip
   endd
   sele prdin
   use
endif
return .t.
************
func klnrc1()
************
pathinr=pathminr+gcDir_c
pathoutr=pathmoutr+gcDir_c
flrc1('kln','t1')
return .t.
************
func kplrc1()
************
pathinr=pathminr+gcDir_e
pathoutr=pathmoutr+gcDir_e
flrc1('kpl','t1')
flrc1('kgp','t1')
flrc1('kgptm','t1')
flrc1('tara','t1')
return .t.
***************
func klnnacrc1()
***************
pathinr=pathminr+gcDir_e
pathoutr=pathmoutr+gcDir_e

flrc1('klnnac','t1')
flrc1('brnac','t1')
flrc1('mnnac','t1')
flrc1('klndog','t1')
flrc1('klnnap','t1')
flrc1('nap','t1')
flrc1('naptm','t1')
flrc1('ktanap','t1')
return .t.
**************
func ctovrc1()
**************
pathinr=pathminr+gcDir_e
pathoutr=pathmoutr+gcDir_e
flrc1('ctov','t1')
return .t.
**************
func spengrc1()
**************
pathinr=pathminr+gcDir_c
pathoutr=pathmoutr+gcDir_c
flrc1('speng','t1')
flrc1('spenge','t1')
return .t.
**************
func stagrc1()
**************
pathinr=pathminr+gcDir_e
pathoutr=pathmoutr+gcDir_e
flrc1('s_tag','t1')
flrc1('stage','t1')
return .t.
***************
func nndsrc1()
***************
return .t.
**************
func bankrc1()
**************
pathinr=pathminr+gcDir_e+dir_gr+dir_dr+gcDir_b
pathoutr=pathmoutr+gcDir_e+dir_gr+dir_dr+gcDir_b
flrc1('dokz','t2')
flrc1('doks','t4')
flrc1('operb','t1')

pathr=pathoutr
netuse('operb',,,1)
netuse('bs',,,1)
netuse('dkkln',,,1)
netuse('dknap',,,1)
netuse('dkklna',,,1)
netuse('dkklns',,,1)

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
      sele dokk
      if !netseek('t12','mnr,rndr,0,rnr')
         sele dokkin
         arec:={}
         getrec()
         sele dokk
         netadd()
         putrec()
         netunlock()
         ddkr=ddk
*         maska(dokkout->kop,dokkout->kkl,dokkout->skl,dokkout->bs_s,1)
         docmod('доб',1)
         mdall('доб')
         msk(1,0)
      else
         prinsr=1
         do while mn=mnr.and.rnd=rndr.and.sk=0.and.rn=rnr
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
   if netseek('t7','0')
      do while rmsk=0
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
         kklr=kkl
         sele dokkin
         if !netseek('t12','mnr,rndr,0,rnr')
            sele dokk
            ddkr=ddk
            docmod('уд',1)
            mdall('уд')
            msk(0,0)
*            maska(dokkout->kop,dokkout->kkl,dokkout->skl,dokkout->bs_s,0)
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
nuse('dkkln')
nuse('dknap')
nuse('dkklns')
nuse('dkklna')
nuse('moddoc')
nuse('mdall')
nuse('bs')
return .t.

*******************
func flrc1(p1,p2)
*******************
* p1 - файл
* p2 - тэг

als_r=p1
tag_r=p2

pathr=pathinr
if !netfile(als_r,1)
   return .t.
endif
netuse(als_r,'in',,1)

ind_r=lowe(indexkey(indexord(tag_r)))
k=1 && К-во элементов Тэга
for ii=1 to len(ind_r)
    if subs(ind_r,ii,1)='+'
       k=k+1
    endif
next
jj=1
ll=1
atag1:={}  && элемент индексного выражения
atag2:={}
atag3:={}
for ii=1 to k && разделение индексного выражения и строки переменных на составляющие
    ar=''
    br=''
    for j=jj to len(ind_r)
        if subs(ind_r,j,1)='+'
           jj=j+1
           exit
         endif
         ar=ar+subs(ind_r,j,1)
    next
    aadd(atag1,ar)
    aadd(atag3,ar)
    aadd(atag2,'')
    if ii=k.and.right(atag1[ii],1)='+'
       atag1[ii]=subs(atag1[ii],1,len(atag1[ii])-1)
    endif
next
for ii=1 to k
    do case
       case at('str(',atag1[ii])#0
            atag3[ii]=stuff(atag1[ii],1,4,"")
            atag3[ii]=subs(atag3[ii],1,len(atag3[ii])-1)
            cntr=0 && счетчик запятых
            buffr=''
            for j=len(atag3[ii]) to 1 step -1
                do case
                   case isdigit(subs(atag3[ii],j,1))
                        if empty(buffr)
                           buffr=atag3[ii]
                        endif
                        atag3[ii]=subs(atag3[ii],1,j-1)
                   case subs(atag3[ii],j,1)=','
                        atag3[ii]=subs(atag3[ii],1,j-1)
                        cntr=cntr+1
                        buffr=''
                        if cntr=2
                           exit
                        endif
                   othe
                        exit
                endc
            next
            if cntr<2.and.!empty(buffr)
               atag3[ii]=buffr
            endif
       case at('dtoc(',atag1[ii])#0 .or. at('dtos(',atag1[ii])#0
            atag3[ii]=stuff(atag1[ii],1,5,"")
            atag3[ii]=subs(atag3[ii],1,len(atag3[ii])-1)
    endc
    atag2[ii]=atag3[ii]+'_r'
    atag1[ii]=strtran(atag1[ii],atag3[ii],atag2[ii],1,1)
next

pathr=pathoutr
netuse(als_r,'out',,1)

sele in
do while !eof()
   sfldr=''
   for i=1 to len(atag2)
       &(atag2[i])=&(atag3[i])
       sfldr=sfldr+atag2[i]+','
   next
   sfldr=subs(sfldr,1,len(sfldr)-1)
   sele out
   if !netseek('t1',sfldr)
      sele in
      arec:={}
      getrec()
      sele out
      netadd()
      putrec()
      netunlock()
   else
      sele in
      arec:={}
      getrec()
      sele out
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
         sele out
         if als_r=='soper'
            ska_r=ska
         endif
         if als_r=='ctov'
            minosv_r=minosv
         endif
         reclock()
         putrec()
         netunlock()
         if als_r=='soper'
            netrepl('ska','ska_r')
         endif
         if als_r=='ctov'
            netrepl('minosv','minosv_r')
         endif
      endif
   endif
   sele in
   skip
endd

nuse('in')
nuse('out')
return .t.

**********************************************************
func rmrca1()
* ПРИЕМ ALL
**********************************************************
sele 0
use (pathminr+'dmg.dbf')
dtr=dt
kolmodr=kolmod
use
?'Дней модификации '+str(kolmodr,2)

?'ASTRU'
astrurc1()

* Копирование файлов RC1=1,2

?'COMM'
pathinr=pathminr+gcDir_c
pathoutr=pathmoutr+gcDir_c
dirr=1
rcfl(1)
commrc1()

?'ENT '
pathinr=pathminr+gcDir_e
pathoutr=pathmoutr+gcDir_e
dirr=4
rcfl(1)
entrc1()


yy1r=year(dtr)
yy2r=year(dtr)

for yy=yy1r to yy2r
    pathinr=pathminr+gcDir_e+'g'+str(yy,4)+'\'
    pathoutr=pathmoutr+gcDir_e+'g'+str(yy,4)+'\'
    pathginr=pathinr
    pathgoutr=pathoutr
    ?pathinr
    dirr=7
    rcfl(1)
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
        pathdinr=pathinr
        pathdoutr=pathoutr
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
        rcfl(1)
        pathinr=pathminr+gcDir_c+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'
        pathoutr=pathmoutr+gcDir_c+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'
        dirinr=pathminr+gcDir_c+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))
        diroutr=pathmoutr+gcDir_c+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))
        if dirchange(dirinr)=0
           if dirchange(diroutr)=0
              ?pathinr
              dirr=9
              rcfl(1)
           endif
        endif
        *BANK
        pathinr=pathminr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'+gcDir_b
        pathoutr=pathmoutr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'+gcDir_b
        dirinr=pathminr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\bank'
        diroutr=pathmoutr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\bank'
        if dirchange(dirinr)=0
           if dirchange(diroutr)=0
              ?pathinr
              dirr=2
              rcfl(1)
              bankrc1a()
           endif
        endif
        *'GLOB'
        pathinr=pathminr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'+gcDir_gl
        pathoutr=pathmoutr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'+gcDir_gl
        dirinr=pathminr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\glob'
        diroutr=pathmoutr+gcDir_e+'g'+str(yy,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\glob'
        if dirchange(dirinr)=0
           if dirchange(diroutr)=0
              ?pathinr
              dirr=2
              rcfl(1)
           endif
        endif
        *'SKLAD'
        pathr=pathmoutr+gcDir_c
        netuse('kln',,,1)
*        netuse('s_tag',,,1)
        netuse('vop',,,1)
        netuse('vo',,,1)
        netuse('dclr',,,1)
        pathr=pathmoutr+gcDir_e
        netuse('tara',,,1)
        netuse('tcen',,,1)
        netuse('moddoc',,,1)
        netuse('mdall',,,1)
        netuse('s_tag',,,1)
        netuse('kpl',,,1)
        netuse('kps',,,1)
        netuse('nap',,,1)
        netuse('naptm',,,1)
        netuse('kplnap',,,1)
        netuse('ktanap',,,1)
        netuse('cgrp',,,1)
        netuse('nds',,,1)
        pathr=pathmoutr+gcDir_e+dir_gr+dir_dr+gcDir_b
        netuse('dokk',,,1)
        netuse('dokko',,,1)
        netuse('dkkln',,,1)
        netuse('dknap',,,1)
        netuse('dkklna',,,1)
        netuse('dkklns',,,1)
        netuse('bs',,,1)
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
*           if rm#1 &&srmskr
*              skip
*              loop
*           endif
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
              dirmake(diroutr)
*              sele cskl
*              skip
*              loop
           endif
           dirchange(gcPath_l)
           dirr=3
           skr=sk
           gnSk_rr=gnSk
           gnSk=skr
           ?pathinr
           rcfl(1)
           sele cskl
           skladrc1a()
           gnSk=gnSk_rr
           sele cskl
           skip
        endd
        nuse('cskl')
        nuse('kln')
        nuse('s_tag')
        nuse('vop')
        nuse('vo')
        nuse('tara')
        nuse('dclr')
        nuse('tcen')
        nuse('moddoc')
        nuse('mdall')
        nuse('kpl')
        nuse('kps')
        nuse('cgrp')
        nuse('nds')
        nuse('dokk')
        nuse('dokko')
        nuse('dkkln')
        nuse('dknap')
        nuse('dkklns')
        nuse('dkklna')
        nuse('bs')
        nuse('nap')
        nuse('naptm')
        nuse('kplnap')
        nuse('ktanap')
    next
next
dirchange(gcPath_l)
return .t.

**************
func rcfl(p1)
**************
* p1 0-gnEntrm=0;1-gnEntrm=1
sele dbft
go top
do while !eof()
   ind_r=''
   if dir#dirr
      skip
      loop
   endif
   if p1=0
      rcr=rc0
   else
      rcr=rc1
   endif
   if !(rcr=1.or.rcr=2)
      skip
      loop
   endif
   rcdbft_r=recn()
   mtr=alltrim(mt)

   als_r=alltrim(als)
   pathr=pathinr
   if !netfile(als_r,1)
      skip
      loop
   endif
   netuse(als_r,'in',,1)
   if !empty(mtr)
      ind_r=lowe(indexkey(indexord(mtr)))
   endif
   if !empty(ind_r)
      k=1 && К-во элементов Тэга
      for ii=1 to len(ind_r)
          if subs(ind_r,ii,1)='+'
             k=k+1
          endif
      next
      jj=1
      ll=1
      atag1:={}  && элемент индексного выражения
      atag2:={}
      atag3:={}
      for ii=1 to k && разделение индексного выражения и строки переменных на составляющие
         ar=''
         br=''
         for j=jj to len(ind_r)
            if subs(ind_r,j,1)='+'
               jj=j+1
               exit
            endif
            ar=ar+subs(ind_r,j,1)
         next
         aadd(atag1,ar)
         aadd(atag3,ar)
         aadd(atag2,'')
         if ii=k.and.right(atag1[ii],1)='+'
            atag1[ii]=subs(atag1[ii],1,len(atag1[ii])-1)
         endif
      next
      for ii=1 to k
        do case
           case at('str(',atag1[ii])#0
                atag3[ii]=stuff(atag1[ii],1,4,"")
                atag3[ii]=subs(atag3[ii],1,len(atag3[ii])-1)
                cntr=0 && счетчик запятых
                buffr=''
                for j=len(atag3[ii]) to 1 step -1
                    do case
                       case isdigit(subs(atag3[ii],j,1))
                            if empty(buffr)
                               buffr=atag3[ii]
                            endif
                            atag3[ii]=subs(atag3[ii],1,j-1)
                       case subs(atag3[ii],j,1)=','
                            atag3[ii]=subs(atag3[ii],1,j-1)
                            cntr=cntr+1
                            buffr=''
                            if cntr=2
                               exit
                            endif
                       othe
                            exit
                    endc
                next
                if cntr<2.and.!empty(buffr)
                   atag3[ii]=buffr
                endif
           case at('dtoc(',atag1[ii])#0 .or. at('dtos(',atag1[ii])#0
                atag3[ii]=stuff(atag1[ii],1,5,"")
                atag3[ii]=subs(atag3[ii],1,len(atag3[ii])-1)
        endc
        atag2[ii]=atag3[ii]+'_r'
        atag1[ii]=strtran(atag1[ii],atag3[ii],atag2[ii],1,1)
      next
   endif

   pathr=pathoutr
   netuse(als_r,'out',,1)
   rccoutr=recc()

   sele in
   do while !eof()
      if !empty(ind_r)
         sfldr=''
         for i=1 to len(atag2)
             &(atag2[i])=&(atag3[i])
             sfldr=sfldr+atag2[i]+','
         next
         sfldr=subs(sfldr,1,len(sfldr)-1)
         sele out
         if !netseek('t1',sfldr)
            sele in
            arec:={}
            getrec()
            sele out
            netadd()
            putrec()
            netunlock()
         else
            if rcr=1
               sele in
               arec:={}
               getrec()
               sele out
               arec1:={}
               getrec('arec1')
               prupdtr=0
               for i=1 to len(arec)
                   if fieldname(i)='RMSK'
                      loop
                   endif
                   if arec[i]#arec1[i]
                      prupdtr=1
                      exit
                   endif
               next
               if prupdtr=1
                  sele out
                  if als_r=='soper'
                     ska_r=ska
                  endif
                  if als_r=='nnds'
                     dprn_r=dprn
                  endif
                  if als_r=='ctov'
                     minosv_r=minosv
                  endif
                  reclock()
                  putrec()
                  if als_r=='soper'
                     netrepl('ska','ska_r')
                  endif
                  if als_r=='nnds'
                     netrepl('dprn','dprn_r')
                  endif
                  if als_r=='ctov'
                     netrepl('minosv','minosv_r')
                  endif
                  netunlock()
               endif
            endif
         endif
      else
         rcinr=recn()
         arec:={}
         getrec()
         sele out
         if rcinr<=rccoutr
            if rcr=1
               go rcinr
               arec1:={}
               getrec('arec1')
               prupdtr=0
               for i=1 to len(arec)
                   if fieldname(i)='RMSK'
                      loop
                   endif
                   if arec[i]#arec1[i]
                      prupdtr=1
                      exit
                   endif
               next
               if prupdtr=1
                  sele out
                  if als_r=='soper'
                     ska_r=ska
                  endif
                  if als_r=='nnds'
                     dprn_r=dprn
                  endif
                  if als_r=='ctov'
                     minosv_r=minosv
                  endif
                  reclock()
                  putrec()
                  if als_r=='soper'
                     netrepl('ska','ska_r')
                  endif
                  if als_r=='nnds'
                     netrepl('dprn','dprn_r')
                  endif
                  if als_r=='ctov'
                     netrepl('minosv','minosv_r')
                  endif
                  netunlock()
               endif
            endif
         else
            netadd()
            putrec()
            netunlock()
         endif
      endif
      sele in
      skip
   endd
   nuse('in')
   nuse('out')
   sele dbft
   go rcdbft_r
   skip
endd

return .t.

**************
func commrc1()
*
**************
rc1fldel('tmesto')
rc1fldel('spenge')
return .t.

***************************************************
func entrc1()
pathr=pathinr
if netfile('s_tag',1)
   netuse('s_tag','stagin',,1)
   pathr=pathoutr
   netuse('s_tag','stagout',,1)
   sele stagin
   go top
   do while !eof()
      arec:={}
      getrec()
      kodr=kod
      sele stagout
      if !netseek('t1','kodr')
         netadd()
         putrec()
         netunlock()
      else
         arec1:={}
         getrec('arec1')
         deviceidr=deviceid
         ref_pricer=ref_price
         dt_pricer=dt_price
         doc_debtr=doc_debt
         ref_salesr=ref_sales
         dt_salesr=dt_sales
         ref_router=ref_routes
         ref_inir=ref_ini
         dt_inir=dt_ini
         prupdtr=0
         for i=1 to len(arec)
             if field(i)='DEVICEID'.or.;
                field(i)='REF_PRICE'.or.;
                field(i)='DT_PRICE'.or.;
                field(i)='DOC_DEBT'.or.;
                field(i)='REF_SALES'.or.;
                field(i)='DT_SALES'.or.;
                field(i)='REF_ROUTES'.or.;
                field(i)='REF_INI'.or.;
                field(i)='DT_INI'
                loop
             endif
             if arec[i]#arec1[i]
                prupdtr=1
                exit
             endif
         next
         if prupdtr=1
            reclock()
            putrec()
            netrepl('deviceid,ref_price,dt_price,doc_debt,ref_sales,dt_sales,ref_routes,ref_ini,dt_ini',;
            'deviceidr,ref_pricer,dt_pricer,doc_debtr,ref_salesr,dt_salesr,ref_router,ref_inir,dt_inir')
         endif
      endif
      sele stagin
      skip
   endd
endif
nuse('stagin')
nuse('stagout')
*
***************************************************
rc1fldel('klnnac')
rc1fldel('brnac')
rc1fldel('mnnac')
rc1fldel('s_tag')
rc1fldel('stagtm')
rc1fldel('stagm')
rc1fldel('etm')
rc1fldel('kgp')
rc1fldel('kpl')
rc1fldel('kgptm')
rc1fldel('krntm')
rc1fldel('nasptm')
rc1fldel('rntm')
corcen()
return .t.


**************
func bankrc1a()
*
**************
flrc1('dokz','t2')
flrc1('doks','t1')
flrc1('operb','t1')

pathr=pathinr
if netfile('dokk',1)
   netuse('dokk','dokkin',,1)
   pathr=pathoutr
   netuse('dokk','dokkout',,1)

   sele dokkin
   go top
   do while !eof()
      mnr=mn
      rndr=rnd
      rnr=rn
      kklr=kkl
      sele dokkout
      if !netseek('t1','mnr,rndr,kklr,rnr')
         sele dokkin
         arec:={}
         getrec()
         sele dokkout
         netadd()
         putrec()
         netunlock()
      else
         prinsr=1
         do while mn=mnr.and.rnd=rndr.and.kkl=kklr.and.rn=rnr
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
            sele dokkout
            netadd()
            putrec()
            netunlock()
         else
            sele dokkin
            arec:={}
            getrec()
            sele dokkout
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
               sele dokkout
               reclock()
               putrec()
               netunlock()
            endif
         endif
      endif
      sele dokkin
      skip
   endd
   sele dokkout
   set orde to tag t7
   if netseek('t7','0')
      do while rmsk=0
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
         kklr=kkl
         sele dokkin
         if !netseek('t1','mnr,rndr,kklr,rnr')
            sele dokkout
            netdel()
         endif
         sele dokkout
         skip
      endd
   endif
   pathr=pathdinr
   if netfile('nnds',1)
      netind('nnds',1)
      netuse('nnds','ndsin',,1)
      pathr=pathdoutr
      netuse('nnds','ndsout',,1)
      sele ndsout
      go top
      do while !eof()
         mnr=mn
         rndr=rnd
         skr=sk
         rnr=rn
         mnpr=mnp
         nndsr=nnds
         if !netseek('t1','nndsr','ndsin')
            sele dokkout
            set orde to tag t12
            if netseek('t12','mnr,rndr,skr,rnr,mnpr')
               bnndsr=''
               do while mn=mnr.and.rnd=rndr.and.sk=skr.and.rn=rnr.and.mnp=mnpr
                  netrepl('bnnds,nnds','bnndsr,0')
                  sele dokkout
                  skip
               endd
            endif
            sele ndsout
            netdel()
         else
            sele dokkout
            if netseek('t12','mnr,rndr,skr,rnr,mnpr')
               do while mn=mnr.and.rnd=rndr.and.sk=skr.and.rn=rnr.and.mnp=mnpr
                  if bs_d=641002.and.bs_k=704101.or.bs_k=641002
                     netrepl('nnds','nndsr')
                  endif
                  sele dokkout
                  skip
               endd
            endif
         endif
         sele ndsout
         skip
      endd
      nuse('ndsin')
      nuse('ndsout')
   endif
   nuse('dokkout')
   nuse('dokkin')
endif

return .t.

**************
func skladrc1a()
*
**************
netuse('ctov')
netuse('tmesto')
   sele cskl
   path_rr=alltrim(path)
   if !file(pathinr+'tprds01.dbf')
      nuse('ctov')
      return .t.
   endif
   pathr=pathinr
   netuse('pr1','pr1in',,1)
   netuse('pr2','pr2in',,1)
   netuse('pr3','pr3in',,1)
   netuse('rs1','rs1in',,1)
   netuse('rs2','rs2in',,1)
   netuse('rs3','rs3in',,1)
   netuse('tov','tovin',,1)
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
   ?'Приход'
   if kolmodr=0
      * Проверка на удаленные
      sele pr1
      go top
      do while !eof()
         if rmsk=gnRmsk
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
            ?'ND '+str(ndr,6)+' MN '+str(mnr,6)+' '+str(rmsk,1)+' удален'
         endif
         sele pr1
         skip
      endd
   endif

   sele pr1in
   go top
   do while !eof()
      sklr=skl
      mnr=mn
      ndr=nd
      vor=vo
      sele pr1 && out
      if !netseek('t1','ndr') && Приход новый
         sele pr3 && out
         if netseek('t1','mnr')
            do while mn=mnr
               netdel()
               skip
            endd
         endif
         sele pr2 && out
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
               sele pr3 && out
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
               arec:={}
               getrec()
               sele pr2 && out
               netadd()
               putrec()
               netunlock()
               sele tov && out
               if !netseek('t1','sklr,ktlr')
                  sele tovin
                  if netseek('t1','sklr,ktlr')
                     arec:={}
                     getrec()
                     sele tov && out
                     netadd()
                     putrec()
                     netrepl('osn,osv,osf,osfo','0,kfr,kfr,kfr')
                  endif
               else
                  netrepl('osv,osf,osfo','osv+kfr,osf+kfr,osfo+kfr')
               endif
               sele tovm && out
               if !netseek('t1','sklr,mntovr')
                  sele tovin
                  if netseek('t1','sklr,ktlr')
                     arec:={}
                     getrec()
                     sele tovm && out
                     netadd()
                     putrec()
                     netrepl('ktl,osn,osv,osf,osfo','0,0,kfr,kfr,kfr')
                  endif
               else
                  netrepl('osv,osf,osfo','osv+kfr,osf+kfr,osfo+kfr')
               endif
               sele pr2in
               skip
            endd
         endif
         sele pr1in
         arec:={}
         getrec()
         sele pr1 && out
         netadd()
         putrec()
         netrepl('amn','0')
      else && Коррекция прихода
         sele pr1 && out
         reclock()
         mnoutr=mn
         sele pr3 && out
         if mnoutr#mnr
            if netseek('t1','mnoutr')
               do while mn=mnoutr
                  netdel()
                  skip
               endd
            endif
         else
            if netseek('t1','mnr')
               do while mn=mnr
                  netdel()
                  skip
               endd
            endif
         endif
         sele pr3in
         if netseek('t1','mnr')
            do while mn=mnr
               arec:={}
               getrec()
               sele pr3 && out
               netadd()
               putrec()
               netunlock()
               sele pr3in
               skip
            endd
         endif
         sele pr2 && out
         if mnoutr#mnr
            if netseek('t1','mnoutr')
               do while mn=mnoutr
                  ktlr=ktl
                  mntovr=mntov
                  kfr=kf
                  sele tov && out
                  if netseek('t1','sklr,ktlr')
                     netrepl('osv,osf,osfo','osv-kfr,osf-kfr,osfo-kfr')
                     if opt=0
                        sele tovin && out
                        if netseek('t1','sklr,ktlr')
                           optr=opt
                           sele tov
                           netrepl('opt','optr')
                           sele pr2
                           if zen=0
                              netrepl('zen','optr')
                           endif
                        endif
                     endif
                  endif
                  sele tovm && out
                  if netseek('t1','sklr,mntovr')
                     netrepl('osv,osf,osfo','osv-kfr,osf-kfr,osfo-kfr')
                  endif
                  sele pr2 && out
                  netdel()
                  skip
               endd
            endif
         else
            if netseek('t1','mnr')
               do while mn=mnr
                  ktlr=ktl
                  mntovr=mntov
                  kfr=kf
                  sele tov && out
                  if netseek('t1','sklr,ktlr')
                     netrepl('osv,osf,osfo','osv-kfr,osf-kfr,osfo-kfr')
                     if opt=0
                        sele tovin
                        if netseek('t1','sklr,ktlr')
                           optr=opt
                           sele tov
                           netrepl('opt','optr')
                           sele pr2
                           if zen=0
                              netrepl('zen','optr')
                           endif
                        endif
                     endif
                  endif
                  sele tovm && out
                  if netseek('t1','sklr,mntovr')
                     netrepl('osv,osf,osfo','osv-kfr,osf-kfr,osfo-kfr')
                  endif
                  sele pr2 && out
                  netdel()
                  skip
               endd
            endif
         endif
         sele pr2in
         if netseek('t1','mnr')
            do while mn=mnr
               ktlr=ktl
               mntovr=mntov
               kfr=kf
               arec:={}
               getrec()
               sele pr2 && out
               netadd()
               putrec()
               netunlock()
               sele tov && out
               if netseek('t1','sklr,ktlr')
                  netrepl('osv,osf,osfo','osv+kfr,osf+kfr,osfo+kfr')
               else
                  sele tovin
                  if netseek('t1','sklr,ktlr')
                     arec:={}
                     getrec()
                     sele tov && out
                     netadd()
                     putrec()
                     netrepl('osn,osv,osf,osfo','0,kfr,kfr,kfr')
                  endif
               endif
               sele tovm && out
               if netseek('t1','sklr,mntovr')
                  netrepl('osv,osf,osfo','osv+kfr,osf+kfr,osfo+kfr')
               else
                  sele tovin
                  if netseek('t1','sklr,ktlr')
                     arec:={}
                     getrec()
                     sele tovm && out
                     netadd()
                     putrec()
                     netrepl('ktl,osn,osv,osf,osfo','0,0,kfr,kfr,kfr')
                  endif
               endif
               sele pr2in
               skip
            endd
         endif
         sele pr1in
         arec:={}
         getrec()
         sele pr1 && out
         amnr=amn
         putrec()
         netrepl('amn','amnr')
      endif
      runcdocopt(1,mnr)
      sele pr1in
      skip
   endd
   ?'Расход'
   if kolmodr=0
      * Проверка на удаленные
      sele rs1
      do while !eof()
         if rmsk=gnRmsk
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
            ?'TTN '+str(ttnr,6)+' '+str(rmsk,1)+' удален'
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
      sele rs1 && out
      if !netseek('t1','ttnr') && Расход новый
         sele rs3 && out
         if netseek('t1','ttnr')
            do while ttn=ttnr
               netdel()
               skip
            endd
         endif
         sele rs2 && out
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
               sele rs3 && out
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
               sele rs2 && out
               netadd()
               putrec()
               netunlock()
               sele tov && out
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
               sele tovm && out
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
         sele rs1 && out
         netadd()
         putrec()
         netrepl('amn','0')
      else && Коррекция расхода
         sele rs1 && out
         reclock()
         przoutr=prz
         dopoutr=dop
         sele rs3 && out
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
               sele rs3 && out
               netadd()
               putrec()
               netunlock()
               sele rs3in
               skip
            endd
         endif
         sele rs2 && out
         if netseek('t1','ttnr')
            do while ttn=ttnr
               ktlr=ktl
               mntovr=mntov
               kfr=kvp
               sele tov && out
               if netseek('t1','sklr,ktlr')
                  if przoutr=1
                     netrepl('osv,osf,osfo','osv+kfr,osf+kfr,osfo+kfr')
                  else
                     if !empty(dopoutr)
                        netrepl('osv,osfo','osv+kfr,osfo+kfr')
                     else
                        netrepl('osv','osv+kfr')
                     endif
                  endif
               endif
               sele tovm && out
               if netseek('t1','sklr,mntovr')
                  if przoutr=1
                     netrepl('osv,osf,osfo','osv+kfr,osf+kfr,osfo+kfr')
                  else
                     if !empty(dopoutr)
                        netrepl('osv,osfo','osv+kfr,osfo+kfr')
                     else
                        netrepl('osv','osv+kfr')
                     endif
                  endif
               endif
               sele rs2 && out
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
               sele rs2 && out
               netadd()
               putrec()
               netunlock()
               sele tov && out
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
               sele tovm && out
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
         sele rs1 && out
         amnr=amn
         putrec()
         netrepl('amn','amnr')
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

   nuse('tovin')
   nuse('tov')
   nuse('tovm')
   nuse('soper')
   nuse('sgrp')
nuse('ctov')
nuse('tmesto')
return .t.

**************
func rc1fldel(p1)
**************
* p1 - алиас
sele dbft
locate for alltrim(als)==p1
if !(rc1=1.or.rc1=2)
   return .t.
endif
mtr=alltrim(mt)
if empty(mtr)
   return .t.
endif
als_r=alltrim(als)
pathr=pathinr
if !netfile(als_r,1)
   return .t.
endif
netuse(als_r,'in',,1)
if !empty(mtr)
   ind_r=lowe(indexkey(indexord(mtr)))
endif
if !empty(ind_r)
   k=1 && К-во элементов Тэга
   for ii=1 to len(ind_r)
       if subs(ind_r,ii,1)='+'
          k=k+1
       endif
   next
   jj=1
   ll=1
   atag1:={}  && элемент индексного выражения
   atag2:={}
   atag3:={}
   for ii=1 to k && разделение индексного выражения и строки переменных на составляющие
       ar=''
       br=''
       for j=jj to len(ind_r)
           if subs(ind_r,j,1)='+'
              jj=j+1
              exit
           endif
           ar=ar+subs(ind_r,j,1)
       next
       aadd(atag1,ar)
       aadd(atag3,ar)
       aadd(atag2,'')
       if ii=k.and.right(atag1[ii],1)='+'
          atag1[ii]=subs(atag1[ii],1,len(atag1[ii])-1)
       endif
   next
   for ii=1 to k
       do case
         case at('str(',atag1[ii])#0
              atag3[ii]=stuff(atag1[ii],1,4,"")
              atag3[ii]=subs(atag3[ii],1,len(atag3[ii])-1)
              cntr=0 && счетчик запятых
              buffr=''
              for j=len(atag3[ii]) to 1 step -1
                  do case
                     case isdigit(subs(atag3[ii],j,1))
                          if empty(buffr)
                             buffr=atag3[ii]
                          endif
                          atag3[ii]=subs(atag3[ii],1,j-1)
                     case subs(atag3[ii],j,1)=','
                          atag3[ii]=subs(atag3[ii],1,j-1)
                          cntr=cntr+1
                          buffr=''
                          if cntr=2
                             exit
                          endif
                     othe
                          exit
                  endc
              next
              if cntr<2.and.!empty(buffr)
                 atag3[ii]=buffr
              endif
         case at('dtoc(',atag1[ii])#0 .or. at('dtos(',atag1[ii])#0
              atag3[ii]=stuff(atag1[ii],1,5,"")
              atag3[ii]=subs(atag3[ii],1,len(atag3[ii])-1)
      endc
      atag2[ii]=atag3[ii]+'_r'
      atag1[ii]=strtran(atag1[ii],atag3[ii],atag2[ii],1,1)
   next
endif

pathr=pathoutr
netuse(als_r,'out',,1)
rccoutr=recc()

sele out
do while !eof()
   if !empty(ind_r)
      sfldr=''
      for i=1 to len(atag2)
          &(atag2[i])=&(atag3[i])
          sfldr=sfldr+atag2[i]+','
      next
      sfldr=subs(sfldr,1,len(sfldr)-1)
      sele in
      if !netseek('t1',sfldr)
         sele out
         netdel()
         skip
         loop
      endif
   endif
   sele out
   skip
endd
nuse('in')
nuse('out')
return .t.

**************
func corcen()
**************
pathr=pathmoutr+gcDir_e
netuse('ctov')
netuse('cskl')
go top
do while !eof()
   if ctov#1
      skip
      loop
   endif
   if ent#gnEnt
      skip
      loop
   endif
   if rasc#1
      skip
      loop
   endif
   pathr=gcPath_d+alltrim(path)
   if !netfile('tov',1)
      sele cskl
      skip
      loop
   endif
   netuse('tov',,,1)
   netuse('tovm',,,1)
   sele tov
   go top
   do while !eof()
      mntovr=mntov
      sele ctov
      if netseek('t1','mntovr')
         mntovtr=mntovt
         mntovcr=mntovc
         mkeepr=mkeep
         cenprr=cenpr
         rozprr=rozpr
         izgr=izg
         sele tov
         netrepl('mntovt,mntovc,izg,mkeep,cenpr,rozpr','mntovtr,mntovcr,izgr,mkeepr,cenprr,rozprr')
      endif
      sele tov
      skip
   endd
   sele tovm
   go top
   do while !eof()
      mntovr=mntov
      sele ctov
      if netseek('t1','mntovr')
         mntovtr=mntovt
         mntovcr=mntovc
         cenprr=cenpr
         rozprr=rozpr
         sele tovm
         netrepl('mntovt,mntovc,izg,mkeep,cenpr,rozpr','mntovtr,mntovcr,izgr,mkeepr,cenprr,rozprr')
      endif
      sele tovm
      skip
   endd
   nuse('tov')
   nuse('tovm')
   sele cskl
   skip
endd
nuse('cskl')
nuse('ctov')
return .t.

