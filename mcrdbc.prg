* Корр БД
* Коррекция структур и индексация таблиц за период
**************
func crdbc()
**************
if gnArm#0
   clea
endif   
set prin to mcrdbc.txt
set prin on
store gdTd to dt1r,dt2r
clr=setcolor('gr+/b,n/bg')
wr=wopen(8,20,11,60)
wbox(1)
@ 0,1 say 'Период с ' get dt1r
@ 0,col()+1 say ' по ' get dt2r
read
wbox(1)
wclose(wr)
setcolor(clr)

if lastkey()=27.or.empty(dt1r).or.empty(dt2r).or.dt2r<dt1r
   retu .t.
endif

if lastkey()=13
   crdbcprd(3)
endif
set prin off
set prin to
retu .t.

****************
func crdbcprd(p1)
****************
if !empty(p1)
   nstopr=p1
else   
   nstopr=0
endif
sele dbft
copy to ldbft
sele 0
use ldbft excl

if nstopr#3
   *ENT
   pathr=gcPath_e 
   ?pathr
   sele ldbft
   go top
   do while !eof()
      if dir#4
         sele ldbft
         skip
         loop
      endif
      alsr=alltrim(als)
      crtbl(alsr,nstopr)
      sele ldbft
      skip
   endd
else
   nstopr=0   
endif   


netuse('cskl')
for yyr=year(dt1r) to year(dt2r)
    pathgr=gcPath_e+'g'+str(yyr,4)+'\' 
    pathr=pathgr
    * Год
    ?pathgr
    sele ldbft
    go top
    do while !eof()
       if dir#7
          sele ldbft
          skip
          loop
       endif
       alsr=alltrim(als)
       crtbl(alsr,nstopr)
       sele ldbft
       skip
    endd
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
        pathr=pathmr
        * Месяц
        ?pathmr
        sele ldbft
        go top
        do while !eof()
           if dir#5
              sele ldbft
              skip
              loop
           endif
           alsr=alltrim(als)
           crtbl(alsr,nstopr)
           sele ldbft
           skip
        endd
        pathbr=pathmr+'bank\'
        pathr=pathbr
        ?pathbr
        * Бухгалтерия
        sele ldbft
        go top
        do while !eof()
           if dir#2
              sele ldbft
              skip
              loop
           endif
           alsr=alltrim(als)
           crtbl(alsr,nstopr)
           sele ldbft
           skip
        endd
        * Склады
        sele cskl
        go top
        do while !eof()
           if ent#gnEnt
              sele cskl
              skip
              loop 
           endif
           pathr=pathmr+alltrim(path)
           ?pathr
           sele ldbft
           go top
           do while !eof()
              if dir#3
                 sele ldbft
                 skip
                 loop
              endif
              alsr=alltrim(als)
              crtbl(alsr,nstopr)
              sele ldbft
              skip 
           endd
           sele cskl
           skip
        enddo
    next
next
sele ldbft
use
erase ldbft
nuse()
retu .t.

******************
func crtbl(p1,p2)
* Определен pathr
******************
local als_rr
if !empty(p2)
   nstop_r=p2
else
   nstop_r=0
endif
als_rr=p1
*?pathr+als_rr
if !netfile(als_rr,1)
*   ?pathr+als_rr+' '+'Нет файла'
   retu .f.
endif
if als_rr='ctovo'.or.als_rr='nds'.or.als_rr='prd'
*   ??' не проверяется'
   retu .f.
endif
if nstop_r=0
   * Проверка структуры
   crtt('tals',"f:als c:c(6) f:npp c:n(1) f:sals c:c(6)")
   sele 0
   use tals excl
   sele dbft
   locate for alltrim(als)==als_rr
   if foun()
      fnamer=alltrim(fname) 
      dopr=alltrim(dop)
      if empty(parent)
         sele tals
         appe blank
         repl als with als_rr,npp with 1
         if !empty(dopr)
            sele tals
            appe blank
            repl als with dopr,npp with 2
         endif   
      else
         parentr=alltrim(parent)
         dopr=alltrim(dop)   
         if !empty(dopr)
            sele tals
            appe blank
            repl als with dopr,npp with 3
         endif   
         sele dbft
         locate for alltrim(als)==parentr
         if foun()
            dopr=alltrim(dop)
            sele tals
            appe blank
            repl als with parentr,npp with 1
            if !empty(dopr)
               sele tals
               appe blank
               repl als with dopr,npp with 2
            endif   
         endif
      endif
   else
      sele tals
      use
      erase tals.dbf
      ?als_rr+' '+'Нет в DBFT'
      retu .f.
   endif

   sele tals
   inde on str(npp,1) tag t1
   go top
   nn=1
   do while !eof()
      alsr=alltrim(als)
      nnr=nn
      if file(gcPath_a+alsr+'.dbf')
         sele 0
         use (gcPath_a+alsr) shared
         if select('stmp'+str(nnr,1))#0
            sele ('stmp'+str(nnr,1))
            use
         endif
         erase ('stmp'+str(nnr,1)+'.dbf')
         sele (alsr)
         copy stru to ('stmp'+str(nnr,1)) exte
         use
         sele tals 
         repl sals with 'stmp'+str(nnr,1)
         nn=nn+1   
      endif   
      sele tals
      skip
   endd
   sele tals
   go top
   do while !eof()
      salsr=alltrim(sals)
      if npp=1
         sele 0
         use (salsr)
         sals_r=salsr
      else
         sele (sals_r)   
         appe from (salsr)
      endif
      sele tals
      skip
   endd
   sele (sals_r)   
   use
   sele tals
   use
   erase tals.dbf
   create ltbl from (sals_r)
   flcr=fcount()
   netuse(als_rr,'rtbl',,1)
   frcr=fcount()
   prcrsr=0
   if flcr#frcr
      ?als_rr+' '+'Разное к-во полей'
      prcrsr=1
   else
      sele ltbl
      copy stru to sltbl exte
      sele 0
      use sltbl
      sele rtbl
      copy stru to srtbl exte
      sele 0
      use srtbl
      sele sltbl
      go top
      do while !eof()
         rcr=recn()
         fnr=field_name
         ftr=field_type
         flr=field_len
         fdr=field_dec
         sele srtbl
         go rcr
         if field_name#fnr.or.field_type#ftr.or.field_len#flr.or.field_dec#fdr
            prcrsr=1
            exit
         endif
         sele sltbl
         skip 
      endd
      sele srtbl
      use 
      sele sltbl
      use 
      erase srtbl.dbf
      erase sltbl.dbf
   endif
   
   if prcrsr=1
      ?als_rr+' '+'Несовпадение структур'
      sele rtbl
      use
      sele ltbl
      appe from (pathr+fnamer+'.dbf')
      copy to (pathr+fnamer+'.dbf')
      use
   else
      sele rtbl
      use
      sele ltbl
      use
   endif
endif   
* Индексация
if nstop_r=0
   if netind(als_rr,1)
      retu .t.
   else
      ?als_rr+' '+'Не удалось проиндексировать'
      retu .f.
   endif   
else
   nuse(als_rr)
   netuse(als_rr,,,1)
   netcind(als_rr,1)
   nuse(als_rr)
*   ?als_rr
endif   

**************
func indxst()
*************
set prin to indxst.txt
set prin on
if gnArm#0
   clea
endif   
store gdTd to dt1r,dt2r
crdbcprd()
set prin off
set prin to txt.txt
retu .t.

**************
func indxcm()
*************
*store gdTd to dt1r,dt2r
set prin to indxcm.txt
set prin on
if gnArm#0
   clea
endif   
sele dbft
copy to ldbft for dir=1
sele 0
use ldbft excl
pathr=gcPath_c 
?pathr
sele ldbft
go top
do while !eof()
   alsr=alltrim(als)
   if alsr='dbft'.or.alsr='dir'.or.alsr='setup'.or.alsr='cntcm'
      skip
      loop
   endif
   if select(alsr)#0
      skip
      loop
   endif
*   ?alsr
*   set cons off
   crtbl(alsr)
*   set cons on
   sele ldbft
   skip
endd
sele ldbft
use
erase ldbft.dbf
set prin off
set prin to txt.txt
retu .t.

**************
func indxnst()
*************
store gdTd to dt1r,dt2r
set prin to indxnst.txt
set prin on
if gnArm#0
   clea
endif   
crdbcprd(1)
set prin off
set prin to txt.txt
retu .t.

****************
func indxcmnst()
****************
*store gdTd to dt1r,dt2r
set prin to indxcmnst.txt
set prin on
if gnArm#0
   clea
endif   
sele dbft
copy to ldbft for dir=1
sele 0
use ldbft excl
pathr=gcPath_c 
?pathr
sele ldbft
go top
*wait
do while !eof()
   alsr=alltrim(als)
   if alsr='dbft'.or.alsr='dir'.or.alsr='setup'.or.alsr='cntcm'
      skip
      loop
   endif
   ?alsr
   crtbl(alsr,1)
   sele ldbft
   skip
endd
sele ldbft
use
erase ldbft.dbf
set prin off
set prin to txt.txt
retu .t.

***************
func sindxns()
***************
set prin to sindxns.txt
set prin on
clea
sele dbft
copy to ldbft for dir=3
sele 0
use ldbft excl
pathr=gcPath_t 
sele ldbft
go top
*wait
do while !eof()
   alsr=alltrim(als)
   ?alsr
   crtbl(alsr,1)
   sele ldbft
   skip
endd
sele ldbft
use
erase ldbft.dbf
set prin off
set prin to txt.txt
retu .t.