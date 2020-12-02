func slcf(fil,rw,cl,h,w,fld,kod,otb,sv,bwhile,bfor,cle,hd)

* fil       - файл
* rw        -
* cl        -
* h         -
* w         -
* fld       - выводимые поля
* kod       - возвращаемое поле (0 & NIL - recn() ; символьное  - значение поля )
* otb       - отбор
* sv        - 1 - оставить на экране
* bwhile    - do while для базы
* bfor      - for для базы
* cle       - color
* hd        - header

private kodr,filr,otbr,svr,fldr,bwhiler,bforr,rwr,clr,hr,wr,cler
store 0 to filr,rwr,clr,hr,wr,kodr,otbr,svr,colotbr
store '' to fldr,bwhiler,bforr

if cle=nil
   cler='n/w,n/bg'
else
   cler=cle
endif
filr=fil
rwr=rw
clr=cl
hr=h
if hr=nil
   hr=10
endif
wr=w
if wr=nil
   wr=0
endif
fldr=fld
kodr=kod
if kodr=nil
   kodr=0
endif
otbr=otb
if otbr=nil
   otbr=0
endif
svr=sv
if svr=nil
   svr=0
endif
bwhiler=bwhile
if bwhiler=nil
   bwhiler='.t..and.!eof()'
endi
bforr=bfor
if bforr=nil
   bforr='.t.'
endif
******************************************************************************
private afil:={},afil1:={},prarr,afld1:={},afld2:={},afld3:={}
private p1r,p2r,p3r
* prarr      - признак,определяющий действие по достижению top(bottom) массива
* afil       - массив для вывода на экран
* afil1      - массив recn()
* afld1      - выражение
* afld2      - заголовок выражения
* afld3      - характеристики выражения

store 0  to prarr,p1r,p2r,p3r
*store '' to
********************************************************************************
oclr=setcolor('g/n')
save scre to fscre

* Заполнение массивов выражений

bbb=fldr
do while len(bbb)#0
   store '' to expr,zagr,harr
   n=at('e:',bbb)

   bbb=subs(bbb,n+2)
   n=at('h:',bbb)
   expr=alltrim(subs(bbb,1,n-1))
   bbb=subs(bbb,n+2)

   n=at('c:',bbb)
   zagr=alltrim(subs(bbb,1,n-1))
   bbb=subs(bbb,n+2)

   n=at('e:',bbb)
   if n#0
      harr=alltrim(subs(bbb,1,n-1))
      bbb=subs(bbb,n-1)
   else
      harr=alltrim(bbb)
      bbb=''
   endif

   aadd(afld1,expr)
   aadd(afld2,&zagr)
   aadd(afld3,harr)
endd

* Выравнивание полей с наименованиями
for i=1 to len(afld2)
    bbb=subs(afld3[i],3)
    n=at(',',bbb)
    if n#0
       ccc=subs(bbb,1,n-1)
    else
       n=at(')',bbb)
       ccc=subs(bbb,1,n-1)
    endif
    lcr=val(ccc)       && Длина выражения по характеристике
    lnr=len(afld2[i])  && Длина наименования
    do case
       case lcr>lnr
            afld2[i]=center(afld2[i],lcr,.t.)
       case lcr<lnr
            afld2[i]=subs(afld2[i],1,lnr)
    endc
next

nfldr='│'
nfld1r='├'
for i=1 to len(afld2)
    nfldr=nfldr+afld2[i]+'│'
    nfld1r=nfld1r+repl('─',len(afld2[i]))+'┼'
next

if otbr=0
   if !empty(wr)
      nfldr=subs(nfldr,1,len(nfldr)-1)+space(wr-len(nfldr)-1)
      nfld1r=subs(nfld1r,1,len(nfld1r)-1)+repl('─',wr-len(nfld1r)+1)+'┤'
   else
      nfldr=subs(nfldr,1,len(nfldr)-1)+'│'
      nfld1r=subs(nfld1r,1,len(nfld1r)-1)+'┤'
   endif
else
   if !empty(wr)
      nfldr=subs(nfldr,1,len(nfldr)-1)+space(wr-len(nfldr)-1)+'│ │'
      nfld1r=subs(nfld1r,1,len(nfld1r)-1)+repl('─',wr-len(nfld1r)-1)+'┼─┤'
   else
      nfldr=subs(nfldr,1,len(nfldr))+' │'
      nfld1r=subs(nfld1r,1,len(nfld1r))+'─┤'
   endif
endif

if rwr=nil
   rwr=(maxrow()-hr)/2
endif
if clr=nil
   clr=(maxcol()-len(nfldr))/2
   if clr<0
      clr=0
   endif
endif

sele (filr)

exr=0    && Выход из SLCF

sele (filr)

coder=0 && Возвращаемое значение

IF  VALTYPE(bwhiler)="C"
  bwhiler:=&("{||"+bwhiler+"}")
ELSE
  //блок кода
ENDIF
IF  VALTYPE(bforr)="C"
  bforr:=&("{||"+bforr+"}")
ELSE
  //блок кода
ENDIF

do while .t.
   afil={}
   afil1={}
   prarr=0
   rcnr=recn()       && N записи с которой начинается сканирование
   h_rr=0            && Количество просканированных записей
   h_r=0             && Количество отобранных записей
   //save screen to scfil
   scfil:=savescreen(1,1,MAXROW(),MAXCOL())
   mess('Ждите...')
   do while EVAL(bwhiler)
      if eof()
         exit
      endif
      sele (filr)
      h_rr++
      if !(EVAL(bforr))
         skip
         if eof()
            exit
         endif
         loop
      endif
      if eof()
         exit
      endif
      if !empty(kodr)
         coder=&kodr
      else
         coder=recn()
      endif
      fldr=''
      * Вычисление выражения
      for i=1 to len(afld1)
          bbb=afld1[i]
*          ccc=&bbb
          do case
             case subs(afld3[i],1,1)='n'
                  aaa='str('+bbb+','+subs(afld3[i],3)
                  ccc=&aaa
                  if &bbb#0.and.val(ccc)=0
                     af3r=alltrim(afld3[i])
                     chhr=''
                     cmmr=''
                     rzdlr=0
                     for zz=3 to len(af3r)-1
                         if subs(af3r,zz,1)=','
                            rzdlr=1
                            loop
                         endif
                         if rzdlr=0
                            chhr=chhr+subs(af3r,zz,1)
                         else
                            cmmr=cmmr+subs(af3r,zz,1)
                         endif
                     next
                     nhhr=val(chhr)
                     nmmr=val(cmmr)
                     if nmmr>0
                        do while nmmr>-1
                           nmmr=nmmr-1
                           if nmmr>-1
                              aaa_r='str('+bbb+','+alltrim(str(nhhr,3))+','+alltrim(str(nmmr,3))+')'
                           else
                              aaa_r='str('+bbb+','+alltrim(str(nhhr,3))+')'
                           endif
                           ccc_r=&aaa_r
                           if val(ccc_r)#0
                              ccc=ccc_r
                           endif
                        endd
                     endif
                  endif
             case subs(afld3[i],1,1)='c'
                  aaa='subs('+bbb+',1,'+subs(afld3[i],3)
                  ccc=&aaa
             case subs(afld3[i],1,1)='d'
                  ccc=dtoc(&bbb)
             othe
                  ccc=&bbb
          endc
          if len(ccc)>=len(afld2[i])
             fldr=fldr+subs(ccc,1,len(afld2[i]))+'│'
          else
             fldr=fldr+space(len(afld2[i])-len(ccc))+ccc+'│'
          endif
      next
      if !empty(otbr)
         sele sl
         do case
            case valtype(coder)='N'
                 scoder=str(coder,fieldsize(fieldpos('kod')))
            case valtype(coder)='C'
                 scoder=coder
            case valtype(coder)='D'
                 scoder=dtoc(coder)
         endc
         sele sl
         locate for sl->kod=scoder
         if FOUND()
            birdr='√'
         else
            birdr=' '
         endif
         sele (filr)
         if empty(wr)
            colotbr=len(fldr)+1
            fldr=subs(fldr,1,len(fldr))+birdr+'│'
         else
            colotbr=len(fldr)+wr-len(fldr)-1
            fldr=subs(fldr,1,len(fldr)-1)+space(wr-len(fldr)-2)+'│'+birdr+'│'
         endif
      else
         if empty(wr)
            fldr=subs(fldr,1,len(fldr)-1)
         else
            fldr=subs(fldr,1,len(fldr)-1)
         endif
      endif
      aadd(afil,fldr)
      aadd(afil1,coder)
      h_r++
      if h_r>hr-1
         exit
      endif
      skip
   enddo
   //rest screen from scfil
   RESTSCREEN(1,1,MAXROW(),MAXCOL(),scfil)

*   if len(afil)=0
*      oclr=setcolor(oclr)
*      rest scre from fscre
*      retu 0
*   endif
*   ocl3r=setcolor('n/w')
   oclr3r=setcolor(cler)
   if len(afil)=0
      aadd(afil,space(len(nfldr)))
      aadd(afil1,0)
   endif
   if empty(wr)
      teni(rwr,clr,rwr+hr+3,clr+len(nfldr)-1)
      @ rwr,clr,rwr+hr+3,clr+len(nfldr)-1 box frame+space(1)
   else
      if wr<78.and.rwr+hr+3<19
         teni(rwr,clr,rwr+hr+3,wr)
      endif
   endif
   @ rwr,clr,rwr+hr+3,wr box frame+space(1)
   if hd#nil
      if len(nfldr)>=len(hd)
         aa=(len(nfldr)-len(hd))/2
         @ rwr,clr+aa say hd color 'r/w'
      else
         @ rwr,clr say subs(hd,1,len(nfldr))
      endif
   endif
   @ rwr+1,clr say nfldr
   @ rwr+2,clr say nfld1r
   ocl2r=setcolor(cler)
   if empty(wr)
      n_n=achoice(rwr+3,clr+1,rwr+hr+2,clr+len(nfldr)-2,afil,,'oafilf')
   else
      n_n=achoice(rwr+3,clr+1,rwr+hr+2,wr-1,afil,,'oafilf')
   endif
   sele (filr)
   do case
      case prarr=1 && Вверх
           go rcnr
           h_r=0
           do while EVAL(bwhiler)
              skip -1
              if bof()
                 exit
              endif
              if !EVAL(bwhiler)
                 skip
                 exit
              endif
              if !(EVAL(bforr))
                 loop
              endif
              h_r++
              if h_r>hr-2
                 exit
              endif
           enddo
           loop
      case prarr=2 && Вниз
           if len(afil)=hr
              loop
           else
              go rcnr
              loop
           endif
   endc
   oclr=setcolor(oclr)
   if svr=0
      rest scre from fscre
   else
      if p2r#0.and.p3r#0
         @ rwr+p3r+3,clr+1 say afil[p2r] color 'n/bg'
      endif
   endi
   if lastkey()=27
      retu 0
   else
      retu coder
   endif
enddo


func oafilf(p1,p2,p3)
p3r=p3
p2r=p2
p1r=p1

if p1r=1.or.p1r=2
   if p1r=1 && Выход вверх
      prarr=1
   else     && Выход вниз
      prarr=2
   endif
   retu 0
endif
prarr=0

coder=afil1[p2]
if select('sl')#0
   sele sl
   do case
      case valtype(coder)='N'
           scoder=str(coder,fieldsize(fieldpos('kod')))
      case valtype(coder)='C'
           scoder=coder
      case valtype(coder)='D'
           scoder=dtoc(coder)
   endc
endif
do case
   case lastkey()=32.and.otbr=1 && Space
        if subs(afil[p2],colotbr,1)=' '
           afil[p2]=stuff(afil[p2],colotbr,1,'√')
           sele sl
           locate for sl->kod=scoder
           if !FOUND()
              appe blank
              repl sl->kod with scoder
           endif
           sele (filr)
        else
           afil[p2]=stuff(afil[p2],colotbr,1,' ')
           sele sl
           locate for sl->kod=scoder
           if FOUND()
              dele
           endif
           sele (filr)
        endif
        retu 1
   case lastkey()=-39.and.otbr=1 && Все
        for i=1 to h_r
            coder=afil1[i]
            if select('sl')#0
               sele sl
               do case
                  case valtype(coder)='N'
                  scoder=str(coder,fieldsize(fieldpos('kod')))
                  case valtype(coder)='C'
                  scoder=coder
                  case valtype(coder)='D'
                  scoder=dtoc(coder)
               endc
            endif
        if subs(afil[i],colotbr,1)=' '
           afil[i]=stuff(afil[i],colotbr,1,'√')
           sele sl
           locate for sl->kod=scoder
           if !FOUND()
              appe blank
              repl sl->kod with scoder
           endif
           sele (filr)
        else
           afil[i]=stuff(afil[i],colotbr,1,' ')
           sele sl
           locate for sl->kod=scoder
           if FOUND()
              dele
           endif
           sele (filr)
        endif
        next
        go rcnr
        retu 1
   case lastkey()=5 && Up
        retu 2
   case lastkey()=24 && Down
        retu 2
   case lastkey()=19 && Left
*        retu 2
        retu 1
   case lastkey()=4 && Right
*        retu 2
        retu 1
   case lastkey()=1 && Home
        retu 2
   case lastkey()=6 && End
        retu 2
   case lastkey()=18 && PgUp
        retu 2
   case lastkey()=3 &&  PgDn
        retu 2
   case lastkey()=7 &&  Del
        retu 1
   case lastkey()=9 &&  Tab
        retu 1
   case lastkey()=22 &&  Ins
        retu 1
   case lastkey()=13 &&  Enter
        retu 1
   case lastkey()=-1 &&  F2
        retu 1
   case lastkey()=-2 &&  F3
        retu 1
   case lastkey()=-3 &&  F4
        retu 1
   case lastkey()=-4 &&  F5
        retu 1
   case lastkey()=-5 &&  F6
        retu 1
   case lastkey()=-6 &&  F7
        retu 1
   case lastkey()=-7 &&  F8
        retu 1
   case lastkey()=-8 &&  F9
        retu 1
   case lastkey()=-9 &&  F10
        retu 1
   case lastkey()=-31 &&  Alt-F2
        retu 1
   case lastkey()=-32 &&  Alt-F3
        retu 1
   case lastkey()=-33 &&  Alt-F4
        retu 1
   case lastkey()=-34 &&  Alt-F5
        retu 1
   case lastkey()=-35 &&  Alt-F6
        retu 1
   case lastkey()=-36 &&  Alt-F7
        retu 1
   case lastkey()=-37 &&  Alt-F8
        retu 1
   case lastkey()=-38 &&  Alt-F9
        retu 1
   case lastkey()=27 &&  Esc
        retu 0
   case lastkey()>32.and.lastkey()<255
   //case lastkey()>=65.and.lastkey()<=90.or.lastkey()>=97.and.lastkey()<=122.or.lastkey()>=128.and.lastkey()<=175.or.lastkey()>=224.and.lastkey()<=239
        retu 1
other
   retu 2
endc

***************************************
func slce(fil,rw,cl,h,w,fld,kod,otb,sv,bwhile,bfor,cle,hd,fldnom,fldfix)

  * fil       - файл
  * rw        -
  * cl        -
  * h         -
  * w         -
  * fld       - выводимые поля
  * kod       - возвращаемое поле (0 & NIL - recn() ; символьное  - значение поля )
  * otb       - отбор
  * sv        - 1 - оставить на экране
  * bwhile    - do while для базы
  * bfor      - for для базы
  * cle       - color
  * hd        - header
  * fldnom    - N первого поля для вывода
  * fldfix    - к-во фикс полей начиная с 1-го

  private kodr,filr,otbr,svr,fldr,bwhiler,bforr,rwr,clr,hr,wr,cler,fldfixr
  store 0 to filr,rwr,clr,hr,wr,kodr,otbr,svr,colotbr,fldfixr
  store '' to fldr,bwhiler,bforr
  store 1 to iii

  if cle=nil
     cler='n/w,n/bg'
  else
     cler=cle
  endif
  filr=fil
  rwr=rw
  clr=cl
  hr=h
  if hr=nil
     hr=10
  endif
  wr=w
  if wr=nil
     wr=0
  endif
  fldr=fld
  kodr=kod
  if kodr=nil
     kodr=0
  endif
  if fldnomr=0
     fldnomr=fldnom
  endif
  if fldnomr=nil.or.fldnomr=0
     fldnomr=1
     oafr=0
  endif
  fldfixr=fldfix
  if fldfixr=nil
     fldfixr=0
  endif
  otbr=otb
  if otbr=nil
     otbr=0
  endif
  svr=sv
  if svr=nil
     svr=0
  endif
  bwhiler=bwhile
  if bwhiler=nil
     bwhiler='!eof()'
  endi
  bforr=bfor
  if bforr=nil
     bforr='.t.'
  endif
  ******************************************************************************
  private afil:={},afil1:={},prarr,afld1:={},afld2:={},afld3:={}
  private p1r,p2r,p3r
  * prarr      - признак,определяющий действие по достижению top(bottom) массива
  * afil       - массив для вывода на экран
  * afil1      - массив recn()
  * afld1      - выражение
  * afld2      - заголовок выражения
  * afld3      - характеристики выражения

  store 0  to prarr,p1r,p2r,p3r
  *store '' to
  ********************************************************************************
  oclr=setcolor('g/n')
  save scre to fscre

  * Заполнение массивов выражений

  bbb=fldr
  do while len(bbb)#0
     store '' to expr,zagr,harr
     n=at('e:',bbb)

     bbb=subs(bbb,n+2)
     n=at('h:',bbb)
     expr=alltrim(subs(bbb,1,n-1))
     bbb=subs(bbb,n+2)

     n=at('c:',bbb)
     zagr=alltrim(subs(bbb,1,n-1))
     bbb=subs(bbb,n+2)

     n=at('e:',bbb)
     if n#0
        harr=alltrim(subs(bbb,1,n-1))
        bbb=subs(bbb,n-1)
     else
        harr=alltrim(bbb)
        bbb=''
     endif

     aadd(afld1,expr)
     aadd(afld2,&zagr)
     aadd(afld3,harr)
  endd

  * Выравнивание полей с наименованиями
  if fldnomr>len(afld2)
     fldnomr=1 &&len(afld2)
  endif
  for i=iif(fldfixr=0,fldnomr,1) to len(afld2)
      if fldfixr#0.and.i>fldfixr
         if i<fldfixr+fldnomr
            loop
         endif
      endif
      bbb=subs(afld3[i],3)
      n=at(',',bbb)
      if n#0
         ccc=subs(bbb,1,n-1)
      else
         n=at(')',bbb)
         ccc=subs(bbb,1,n-1)
      endif
      lcr=val(ccc)       && Длина выражения по характеристике
      lnr=len(afld2[i])  && Длина наименования
      do case
         case lcr>lnr
              afld2[i]=center(afld2[i],lcr,.t.)
         case lcr<lnr
              afld2[i]=subs(afld2[i],1,lnr)
      endc
  next

  nfldr='│'
  nfld1r='├'
  *for i=fldnomr to len(afld2)
  for i=iif(fldfixr=0,fldnomr,1) to len(afld2)
      if fldfixr#0.and.i>fldfixr
         if i<fldfixr+fldnomr
            loop
         endif
      endif
  *    if fldfixr#0.and.fldnomr#1
  *       if i=fldfixr+1
  *          loop
  *       endif
  *    endif
      nfldr=nfldr+afld2[i]+'│'
      nfld1r=nfld1r+repl('─',len(afld2[i]))+'┼'
  next

  if otbr=0
     if !empty(wr)
        nfldr=subs(nfldr,1,len(nfldr)-1)+space(wr-len(nfldr)-1)
        nfld1r=subs(nfld1r,1,len(nfld1r)-1)+repl('─',wr-len(nfld1r)+1)+'┤'
     else
        nfldr=subs(nfldr,1,len(nfldr)-1)+'│'
        nfld1r=subs(nfld1r,1,len(nfld1r)-1)+'┤'
     endif
  else
     if !empty(wr)
        nfldr=subs(nfldr,1,len(nfldr)-1)+space(wr-len(nfldr)-1)+'│ │'
        nfld1r=subs(nfld1r,1,len(nfld1r)-1)+repl('─',wr-len(nfld1r)-1)+'┼─┤'
     else
        nfldr=subs(nfldr,1,len(nfldr))+' │'
        nfld1r=subs(nfld1r,1,len(nfld1r))+'─┤'
     endif
  endif

  if len(nfldr)>78
    nfldr=subs(nfldr,1,78)+'│'
  endif
  if len(nfld1r)>78
    nfld1r=subs(nfld1r,1,78)+'┤'
  endif

  if rwr=nil
     rwr=(maxrow()-hr)/2
  endif
  if clr=nil
     clr=(maxcol()-len(nfldr))/2
     if clr<0
        clr=0
     endif
  endif

  sele (filr)

  exr=0    && Выход из SLCF

  sele (filr)

  coder=0 && Возвращаемое значение

  IF  VALTYPE(bwhiler)="C"
    bwhiler:=&("{||"+bwhiler+"}")
  ELSE
    //блок кода
  ENDIF
  IF  VALTYPE(bforr)="C"
    bforr:=&("{||"+bforr+"}")
  ELSE
    //блок кода
  ENDIF

  do while .t.
     afil={}
     afil1={}
     prarr=0
     rcnr=recn()       && N записи с которой начинается сканирование
     h_rr=0            && Количество просканированных записей
     h_r=0             && Количество отобранных записей
     //save screen to scfil
     scfil:=savescreen(1,1,MAXROW(),MAXCOL())
     mess('Ждите...')
     do while EVAL(bwhiler)
        sele (filr)
        h_rr++
        if !(EVAL(bforr))
           skip
           if eof()
              exit
           endif
           loop
        endif
        if eof()
           exit
        endif
        if !empty(kodr)
           coder=&kodr
        else
           coder=recn()
        endif
        fldr=''
        * Вычисление выражения
  *      for i=fldnomr to len(afld1)
        for i=iif(fldfixr=0,fldnomr,1) to len(afld1)
            if fldfixr#0.and.i>fldfixr
               if i<fldfixr+fldnomr
                  loop
               endif
            endif
  *          if fldfixr#0.and.fldnomr#1
  *             if i=fldfixr+1
  *                loop
  *             endif
  *          endif
            bbb=afld1[i]
  *          ccc=&bbb
            do case
               case subs(afld3[i],1,1)='n'
                    aaa='str('+bbb+','+subs(afld3[i],3)
                    ccc=&aaa
                    if &bbb#0.and.val(ccc)=0
                       af3r=alltrim(afld3[i])
                       chhr=''
                       cmmr=''
                       rzdlr=0
                       for zz=3 to len(af3r)-1
                           if subs(af3r,zz,1)=','
                              rzdlr=1
                              loop
                           endif
                           if rzdlr=0
                              chhr=chhr+subs(af3r,zz,1)
                           else
                              cmmr=cmmr+subs(af3r,zz,1)
                           endif
                       next
                       nhhr=val(chhr)
                       nmmr=val(cmmr)
                       if nmmr>0
                          do while nmmr>-1
                             nmmr=nmmr-1
                             if nmmr>-1
                                aaa_r='str('+bbb+','+alltrim(str(nhhr,3))+','+alltrim(str(nmmr,3))+')'
                             else
                                aaa_r='str('+bbb+','+alltrim(str(nhhr,3))+')'
                             endif
                             ccc_r=&aaa_r
                             if val(ccc_r)#0
                                ccc=ccc_r
                             endif
                          endd
                       endif
                    endif
                    if val(ccc)=0
                       ccc=space(len(ccc))
                    endif
               case subs(afld3[i],1,1)='c'
                    aaa='subs('+bbb+',1,'+subs(afld3[i],3)
                    ccc=&aaa
               case subs(afld3[i],1,1)='d'
                    ccc=dtoc(&bbb)
               othe
                    ccc=&bbb
            endc
            if len(ccc)>=len(afld2[i])
               fldr=fldr+subs(ccc,1,len(afld2[i]))+'│'
            else
               fldr=fldr+space(len(afld2[i])-len(ccc))+ccc+'│'
            endif
        next
        if !empty(otbr)
           sele sl
           do case
              case valtype(coder)='N'
                   scoder=str(coder,fieldsize(fieldpos('kod')))
              case valtype(coder)='C'
                   scoder=coder
              case valtype(coder)='D'
                   scoder=dtoc(coder)
           endc
           sele sl
           locate for sl->kod=scoder
           if FOUND()
              birdr='√'
           else
              birdr=' '
           endif
           sele (filr)
           if empty(wr)
              colotbr=len(fldr)+1
              fldr=subs(fldr,1,len(fldr))+birdr+'│'
           else
              colotbr=len(fldr)+wr-len(fldr)-1
              fldr=subs(fldr,1,len(fldr)-1)+space(wr-len(fldr)-2)+'│'+birdr+'│'
           endif
        else
           if empty(wr)
              fldr=subs(fldr,1,len(fldr)-1)
           else
              fldr=subs(fldr,1,len(fldr)-1)
           endif
        endif
        if len(fldr)>78
           fldr=subs(fldr,1,78)+'│'
        endif
        aadd(afil,fldr)
        aadd(afil1,coder)
        h_r++
        if h_r>hr-1
           exit
        endif
        skip
     enddo
     //rest screen from scfil
     RESTSCREEN(1,1,MAXROW(),MAXCOL(),scfil)

  *   if len(afil)=0
  *      oclr=setcolor(oclr)
  *      rest scre from fscre
  *      retu 0
  *   endif
  *   ocl3r=setcolor('n/w')
     oclr3r=setcolor(cler)
     if len(afil)=0
        aadd(afil,space(len(nfldr)))
        aadd(afil1,0)
     endif
     if empty(wr)
        teni(rwr,clr,rwr+hr+3,clr+len(nfldr)-1)
        @ rwr,clr,rwr+hr+3,clr+len(nfldr)-1 box frame+space(1)
     else
        if wr<78.and.rwr+hr+3<19
           teni(rwr,clr,rwr+hr+3,wr)
        endif
     endif
     @ rwr,clr,rwr+hr+3,wr box frame+space(1)
     if hd#nil
        if len(nfldr)>=len(hd)
           aa=(len(nfldr)-len(hd))/2
           @ rwr,clr+aa say hd color 'r/w'
        else
           @ rwr,clr say subs(hd,1,len(nfldr))
        endif
     endif
     @ rwr+1,clr say nfldr
     @ rwr+2,clr say nfld1r
     ocl2r=setcolor(cler)
     if empty(wr)
        n_n=achoice(rwr+3,clr+1,rwr+hr+2,clr+len(nfldr)-2,afil,,'oafilf')
     else
        n_n=achoice(rwr+3,clr+1,rwr+hr+2,wr-1,afil,,'oafilf')
     endif
     sele (filr)
     do case
        case prarr=1 && Вверх
             go rcnr
             h_r=0
             do while EVAL(bwhiler)
                skip -1
                if bof()
                   exit
                endif
                if !EVAL(bwhiler)
                   skip
                   exit
                endif
                if !(EVAL(bforr))
                   loop
                endif
                h_r++
                if h_r>hr-2
                   exit
                endif
             enddo
             loop
        case prarr=2 && Вниз
             if len(afil)=hr
                loop
             else
                go rcnr
                loop
             endif
     endc
     oclr=setcolor(oclr)
     if svr=0
        rest scre from fscre
     else
        if p2r#0.and.p3r#0
           @ rwr+p3r+3,clr+1 say afil[p2r] color 'n/bg'
        endif
     endi
     if lastkey()=27
        retu 0
     else
        retu coder
     endif
  enddo
