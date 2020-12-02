#include "common.ch"
#include "set.ch"
#define TEST_IND
//STATIC aNetSeek:={{'','',0}}

* Функции базы данных
***************************************************************************
function netuse(p1,p2,p3,p4)
  ***************************************************************************
  *P1 - 1-й алиас
  *P2 - 2-й алиас
  *P3 - 's'-share,'e'-excl
  *P4 - NIL - Pathr по умолчанию,'1' - Pathr определяется перед netuse()
  LOCAL lRet:=.t.
  MEMVAR pf,i,tr,niir,oclr,p1r,p2r,p3r,p4r
  private pf,i,tr,niir,oclr,p1r,p2r,p3r,p4r
  sele 0
  p1r=p1
  p2r=p2
  p3r=p3
  p4r=p4
  if empty(p3r)
     p3r='s'
  endif
  store '' to t1r,tr,nir,inr,pf,pa
  if !empty(p2r)
     if select(p2r)#0
        sele (p2r)
        if p3r='s'
           retu .t.
        else
           use
           //переоткрытие в режме EXCLUSIVE
        endif
     endif
  else
     if select(p1r)#0
        sele (p1r)
        if p3r='s'
           retu .t.
        else
           use
           //переоткрытие в режме EXCLUSIVE
        endif
     endif
  endif
  sele dbft
  go top
  locate for alltrim(als)==lower(p1r)
  if !FOUND()
     wmess('Файл '+p1r+' не описан в DBFT',2)
     quit
  endif
  if p3r='s'
     reclock()
     repl dtofl with date()
     netunlock()
  endif
  fnamer=alltrim(fname)
  dirr=dir
  parentr=alltrim(parent)
  if empty(P4r) //.or.dirr=1
    sele dir
    locate for dir=dirr
    cpathr=alltrim(ndir)
    pathr=&cpathr
  endif
  sele dbft
  t1r=t1
  Pf=alltrim(PATHR + fnamer)
  pa=pf+'.dbf'
  if !file(pa)
     if file (gcPath_a+p1r+'.dbf')
        copy file (gcPath_a+p1r+'.dbf')  to (pa)
        wmess('Индексация '+p1r,1)
        netind(p1r,1)
     else
        crdbftfl(p1r,p4r)
        netind(p1r,1)
  // *           retu .f.
     endif
     wmess('Нет файла '+pf,2)
  // *     retu .f.
  endif
  pc=pf+'.cdx'
  // *  on error wait wind 'Не удалось открыть '+pf

  if empty(P2r)
     sele 0
     if P3r='s'
        use (pf) alias (p1r) share
     else
        use (pf) alias (p1r) excl
     endif
  else
     sele 0
     if P3r='s'
        use (pf) alias (p2r) share
     else
        use (pf) alias (p2r) excl
     endif
  endif
  if neterr()
     return .f.
  endif
  if empty(P2r)
     sele (p1r)
  else
     sele (p2r)
  endif

  if !empty(indexkey(1)) // 1-й tag списка
      set orde to tag t1
      /*
  *      if p1=='tov'
  *         outlog(__FILE__,__LINE__,alias(),indexkey(1))
  *      endif
  */
  else
     if !empty(t1r).and.file(pc)
         set orde to tag t1 in (pc)
         /*
  *      if p1=='tov'
  *         outlog(__FILE__,__LINE__,alias(),pc)
  *      endif
  */
     endif
  endif


  //on error
  #ifdef TEST_IND
    lRet:=Test_id(.F.)
  #endif
  go top
  retu lRet
*********************************************************
func netind(p1,p2,p3)  // Индексация файла
  *********************************************************
  * p1 алиас
  * p2 1 pathr перед netind
  * p3 без exclusive
  private i,tr,dirr
  sele dbft
  locate for alltrim(als)==p1
  if FOUND()
     fnamer=alltrim(fname)
     dirr=dir
     if empty(p2)
        sele dir
        locate for dir=dirr
        cpathr=alltrim(ndir)
        pathr=&cpathr
     endif
     if select(p1)#0
        sele (p1)
        use
     endif
     erase (pathr+fnamer+'.cdx')
     cp866(p1,1)
     if empty(p3)
        if !netuse(p1,'','e',1)
           retu .f.
        endif
        if p1=='dokk'
           dele all for prc.or.bs_d=0.or.bs_k=0
        endif
        pack
        if p1=='aninf'.or.p1=='aninfl'.or.p1=='doka'
           zap
        endif
     else
        if !netuse(p1,'','',1)
           retu .f.
        endif
     endif
     for i=18 to 1 step -1
         sele dbft
         store '' to tr,inr,nir
         if i<10
            tt='t'+str(i,1)
         else
            tt='t'+str(i,2)
         endif
         if fieldpos(tt)=0
            exit
         endif
         ttt=&tt
         tr=alltrim(ttt)
         if !empty(tr)
            sele (p1)
            do case
               case p1=='prd'
                    inde on &tr tag &tt desc
               case at('dtmod',tr)#0
                    if at('dtmodvz',tr)=0
                       inde on &tr tag &tt desc
                    else
                       inde on &tr tag &tt
                    endif
               othe
                    inde on &tr tag &tt
            endcase
         endif
     endf
     sele (p1)
     use
     retu .t.
  else
     retu .f.
  endif
********************
func netfile(P1,P2)
  ********************
  local pf,pa,i,tr,niir,oclr,oslr,dirr,fnamer,rcdbftr
  *P1 - Алиас
  *P2 - NIL - Pathr по умолчанию,'1' - Pathr определяется перед netfile()
  store '' to t1r,tr,nir,inr,pf,pa
  oslr=select()
  sele dbft
  rcdbftr=recn()
  go top
  locate for alltrim(als)==lower(p1)
  if !FOUND()
      wait 'Файл '+p1+' не описан в DBFT'
      go rcdbftr
      retu .f.
  endif
  fnamer=alltrim(fname)
  dirr=dir
  if P2=nil
        sele dir
        locate for dir=dirr
        pathr=&(alltrim(ndir))
        sele dbft
  endif
  sele dbft
  go rcdbftr
  Pf=alltrim(PATHR + fnamer)
  pa=pf+'.dbf'
  if !file(pa)
     sele (oslr)
     retu .f.
  endif
  sele (oslr)
  retu .t.
**********************
function cp866(p1,p2)
  **********************
  *p1 - алиас
  *p2 - NIL - путь по умолчанию иначе PATHR
  sele dbft
  go top
  locate for alltrim(als)==lower(p1)
  if !FOUND()
     wait 'Файл '+p1+' не описан в DBFT'
     quit
  endif
  fnamer=alltrim(fname)
  dirr=dir
  if P2=nil
     sele dir
     locate for dir=dirr
      pathr=&(alltrim(ndir))
     sele dbft
  endif
  Pf=alltrim(PATHR + fnamer)
  pa=pf+'.dbf'
  buffr=space(128)
  fh=fopen(pa,2)
  if fh=-1
     retu .f.
  endif
  a=fread(fh,@buffr,30)
  a=left(buffr,29)+chr(101)
  fseek(fh,0,0)
  if !fwrite(fh,a)=30
     gg=ferror()
  endif
  fclose(fh)
  retu .t.

*************************
function cp866x(p1,p2)
  *************************
  *p1 - алиас
  *p2 - NIL - путь по умолчанию иначе PATHR

  fnamer=p1

  Pf=alltrim(PATHR + fnamer)
  pa=pf+'.dbf'
  buffr=space(128)
  fh=fopen(pa,2)
  if fh=-1
     retu .f.
  endif
  a=fread(fh,@buffr,30)
  a=left(buffr,29)+chr(101)
  fseek(fh,0,0)
  if !fwrite(fh,a)=30
     gg=ferror()
  endif
  fclose(fh)
  retu .t.
*****************
func nuse(p1,p2)
  *****************
  local ap2:={},i,lalsr
  * p1 - Имя закрываемого файла
  * p2 - Список EXCLUDE
  if p2#nil
     lalsr=''
     for i=1 to len(p2)
         if subs(p2,i,1)=','
            aadd(ap2,lalsr)
            lalsr=''
            loop
         endif
         lalsr=lalsr+subs(p2,i,1)
     next
  endif
  aadd(ap2,lalsr)

  sele dbft
  if p1=nil
     go top
     do while !eof()
        if alltrim(als)=='dbft'.or.alltrim(als)=='dir'.or.alltrim(als)=='setup'.or.alltrim(als)=='cntcm'.or.alltrim(als)=='prd'
           skip
           loop
        endif
        if p2#nil.and.ascan(ap2,alltrim(als))#0
           skip
           loop
        endif
        alsr=alltrim(als)
        if select(alsr)#0
           sele (alsr)
           use
        endif
        sele dbft
        skip
     endd
  else
     if select(p1)#0
        sele (p1)
        use
     endif
  endif
  retu .t.
******************
func nstru(p1,p2)
  ******************
  * Проверка структуры
  local i,tr,niir,oclr,oslr
  *P1 - Алиас
  *P2 - NIL - Pathr по умолчанию,'1' - Pathr определяется перед nstru()
  store '' to t1r,tr,nir,inr,pf,pa
  adop:={}
  oslr=select()

  sele dbft
  locate for alltrim(als)==p1
  fnamer=alltrim(fname)
  alsr=alltrim(als)
  dirr=dir
  dopr=alltrim(dop)
  parentr=alltrim(parent)
  if P2=nil
     sele dir
     locate for dir=dirr
     pathr=&(alltrim(ndir))
     sele dbft
  endif
  Pf=alltrim(PATHR + fnamer)
  pa=pf+'.dbf'
  prcsr=0
  if file(pa)
     dfil_r=p1
     sele dbft
     do while .t.
        locate for alltrim(als)==dfil_r
        if !empty(dop)
           aadd(adop,dop)
        endif
        if !empty(parent)
           dfil_r=alltrim(parent)
        else
           aadd(adop,alltrim(als))
           exit
        endif
     enddo
     for i=1 to len(adop)
         fil_r=alltrim(adop[i])
         sele 0
         use (gcPath_a+fil_r)
         copy to (gcPath_l+'\stemp'+str(i,1)+'.dbf') stru exte
         use
     next

     k=0
     for i=len(adop) to 1 step -1
         fil_r=gcPath_l+'\stemp'+str(i,1)
         if k=0
            sele 0
            use (fil_r) alias stemp
            k=1
         else
            sele stemp
            appe from (fil_r+'.dbf')
            erase (fil_r+'.dbf')
         endif
     next
     k=len(adop)
     if select('main')#0
        sele main
        use
     endif
     sele 0
     use (pf) alias main share //excl
     if neterr()
        sele stemp
        use
        erase (gcPath_l+'\stemp'+str(k,1)+'.dbf')
        return .T. // Не удалось открыть в эксклюзиве (не корректируется)
     endif
     copy stru exte to (gcPath_l+'\main1')
     use
     sele 0
     use main1
     rcc1=recc()
     go top
     sele stemp
     rcc2=recc()
     go top
     if rcc1#rcc2
        prcsr=1
     else
        do while !eof()
           fn_r=field_name
           ft_r=field_type
           fl_r=field_len
           fd_r=field_dec
           rcn_r=recn()
           sele main1
           go rcn_r
           if !(field_name=fn_r.and.field_type=ft_r.and.field_len=fl_r.and.field_dec=fd_r).or.eof()
              prcsr=1
              exit
           endif
           sele stemp
           skip
        endd
     endif
     sele stemp
     use
     erase (gcPath_l+'\stemp'+str(k,1)+'.dbf')
     sele main1
     use
     erase main1.dbf
  endif
  sele (oslr)
  if prcsr=1
     retu .f.
  else
     retu .t.
  endif

**************
func filock()
  **************
   sEC=0
   DO WHILE .T.
      IF FLOCK()
         EXIT
      ELSE
         SEC=(INKEY(0.5), SEC + 0.5)
         IF SEC > 2
            @ MAXROW()-1,0 clea
            SETCOLOR("rg+/n,,,,")
            @ MAXROW()-1,1 say "Файл занят!    Подождите немного !"
            SEC=(INKEY(1), 0)
            SETCOLOR("g/n,gr+/b,,,")
            @ MAXROW()-1,0 clea
         ENDIF
      ENDIF
   ENDDO
  retu nil

********************
func reclock(p1)
  ********************
  local oclr,lck,sclock, cMess
  lck=0
  SEC=0
  DO WHILE .T.
    //     IF dbRLOCK(recno())
    IF dbRLOCK()
      if lck=1
      endif
      if fieldpos('ktoblk')#0.and.gnKto<10000
          repl ktoblk with gnKto
          #ifdef __CLIP__
            dbcommit()
            DBSkip(0)
          #endif
      endif
      retu .t.
    ELSE
      if EMPTY(p1) // p1=nil.or.p1=0
        #ifdef __CLIP__
          SEC=(sleep(0.5), SEC + 0.5)
        #else
          SEC=(INKEY(0.5), SEC + 0.5)  //SEC=(millisec(500), SEC + 0.5)
        #endif
        IF SEC > 10
          if lck=0
            lck=1
          endif
          ktoblkr()
          #ifdef __CLIP__
              SEC=(sleep(1), 0)
          #else
              SEC=(INKEY(1), 0)  //SEC=(millisec(500), SEC + 0.5)
          #endif
        ENDIF
      else
        if lck=1
        endif
        ktoblkr()
        retu .f.
      endif
    ENDIF
  ENDDO
  retu .f.

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  04-04-19 * 02:21:57pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION ktoblkr()
  if fieldpos('ktoblk')=0
    mess("Запись занята!Подождите немного! "+alias())
  else
    ktoblkr=ktoblk
    cMess:=alias() + ";" + LTRIM(STR(recno()));
    +";Запись занята " + str(ktoblkr,4)

    if select('speng')=0
    else
      cMess += " "+alltrim(getfield('t1','ktoblkr','speng','fio'))
    endif
    mess(cMess)
  endif
  RETURN (NIL)

****************
func netadd(p1)
  ****************
  local oclr,oi,pd
  pd=0
  DO WHILE .T.
     if p1#nil
        oi=indexord()
        for i=1 to 18
            if i<10
               tag_r='t'+str(i,1)
            else
               tag_r='t'+str(i,2)
            endif
            set orde to tag (tag_r)
            if upper(indexkey())='DELETED()'
               pd=1
               exit
            endif
        next
        if pd=1
           set dele off
           if !netseek(tag_r,'.T.')
              pd=0
           else
              if deleted()
                 if reclock(1)
                    recall
                    netblank()
                 else
                    pd=0
                 endif
              else
                 pd=0
              endif
           endif
           set dele on
        endif
        set orde to oi
     endif
     if pd=0
        APPEND blank
     endif
     IF NETERR()
       IF gnArm#0
         @ MAXROW()-1,0 clea
         oclr=SETCOLOR("rg+/n,,,,")
         @  MAXROW()-1,5 say "Файл  занят! "+alias()
         INKEY(0.1)
         oclr=SETCOLOR(oclr)
         @ MAXROW()-1,0 clea
       ELSE
         OUTLOG(__FILE__,__LINE__,"Файл  занят! "+alias(),DATE(),TIME())
         INKEY(0.1)
       ENDIF
     ELSE
      /*
  *        #ifdef __CLIP__
  *            IF ALIAS()=="RS1".or.ALIAS()=="TOVM"
  *              if select('tovpt')#0
  *                 tovpt->(DBAPPEND())
  *                 tovpt->Kto:=gnKto
  *                 tovpt->DataUse:=alias()+"-A"
  *                 tovpt->Param:=PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5)+";"+pathr+";"+str(gnSk,3)
  *                 tovpt->Dt:=DATE()
  *                 tovpt->TM:=TIME()
  *                 tovpt->SCNDS:=SECONDS()
  *                 tovpt->RCN:=RECNO()
  *              endif
  *            endif
  *        #endif
  */
        EXIT
     ENDIF
     dbcommit()
  ENDDO
  RETURN NIL

FUNCTION NETAPP(p1,p2)
  LOCAL AA,oclr
  DO WHILE .T.
     appe from (p1) for &p2
     IF NETERR()
        @ MAXROW()-1,0 clea
        oclr=SETCOLOR("rg+/n,,,,")
        @ MAXROW()-1,5 say "Файл "+p1+" занят!   Подождите немного !"
        INKEY(0.1)
        oclr=SETCOLOR(oclr)
        @ MAXROW()-1,0 clea
     ELSE
        EXIT
     ENDIF
  ENDDO
  RETURN AA


**************************************************************
func netseek(tgr,indr,al,plast,eloc, ldebug)  // Поиск по индексу
  **************************************************************
  * tgr  - имя тэга
  * indr - переменные для индексного выражения
  * al   - алиас
  * plast - количество символов последней переменной
  * eloc  - при неудачном seek -> locate
  Local b_lexpr
  local ar,br,indr1,alr,al_r
  local tt,j,jj,l,ll,ii, n, k
  local ntgr,ind_r,cntr,buffr,oldind,lexpr
  local len_indr, len_indr1, len_atag3
  local atag3, atag2,  atag1


  lexpr='.t.' // выражение для lоcate

  oldind=indexord()

  al_r=lower(alias())

  if !empty(al)
     alr=lower(al)
  else
     alr=lower(alias())
  endif
  ntgr=val(subs(tgr,2))
  sele (alr)

  if alr#al_r
     oldind2=indexord()
     oldrcn2=recn()
  endif

  // *  set orde to ntgr
  set orde to tag (tgr)
  // *  indr1=lower(indexkey(indexord(tgr)))
  indr1:=charrem(' ',lowe(indexkey(indexord(tgr))))

  if empty(indr1)
     mess('Тэг '+tgr+' пустой для алиаса '+ALLTRIM(alr),2)
     quit
     retu .f.
  endif
  /*
  ii:=ASCAN(aNetSeek,{|aEl| tgr+indr == aEl[1]  })
  IF EMPTY(ii)
    ind_r:=alltrim(ind_r)
    AADD(aNetSeek,{tgr+indr,ind_r,1})
  ELSE
    aNetSeek[ii,3]++
    ind_r:= aNetSeek[ii,2]
  ENDIF
  */
    n:=1
    zn2r:=0 // Признаки скобок (1 - открыта)
    len_indr:=len(indr)
    for ii=1 to len_indr // Определение переменных для индексного выражения
        do case
           case subs(indr,ii,1)='('
                zn2r++
           case subs(indr,ii,1)=')'
                zn2r--
           case subs(indr,ii,1)=','.and.zn2r=0
                n++
        endcase
    next
    //outlog(__FILE__,__LINE__,'indr',indr)

    k:=1
    len_indr1:=len(indr1)
    for ii=1 to len_indr1 // Определение к-ва элементов Тэга
      if subs(indr1,ii,1)='+'
        k++
      endif
    next
    if k>n
       k=n
    endif
    ll:=0
    len_indr1:=len(indr1)
    for ii=1 to len_indr1
        if subs(indr1,ii,1)='+'
           ll++ //=ll+1
           if ll=k
              exit
           endif
        endif
    next

    indr1:=subs(indr1,1,ii)
    //outlog(__FILE__,__LINE__,'indr1',indr1)

    atag1:={}
    atag2:={}
    atag3:={}
    jj:=1
    ll:=1
    for ii:=1 to k // разделение индексного выражения и строки переменных на составляющие
        ar=''
        br=''
        len_indr1:=len(indr1)
        for j=jj to len_indr1
            if subs(indr1,j,1)='+'
               jj=j+1
               exit
            endif
            ar=ar+subs(indr1,j,1)
        next
        aadd(atag1,ar) // элемент индексного выражения
        aadd(atag3,ar)

        if ii=k.and.right(atag1[ii],1)='+'
           atag1[ii]=subs(atag1[ii],1,len(atag1[ii])-1)
        endif

        zn2r:=0 // Признаки скобок (1 - открыта)
        len_indr:=len(indr)
        for l=ll to len_indr
            do case
               case subs(indr,l,1)='('
                    zn2r++
               case subs(indr,l,1)=')'
                    zn2r--
               case subs(indr,l,1)=','.and.zn2r=0
                    ll=l+1
                    exit
            endcase
            br=br+subs(indr,l,1)
        next
        aadd(atag2,br) // элемент строки переменнных
    next
    // отличия
    for ii:=1 to k
      do case
      case at('str(',atag1[ii])#0
        atag3[ii]=stuff(atag1[ii],1,4,"")
        atag3[ii]=subs(atag3[ii],1,len(atag3[ii])-1)
        cntr=0 // счетчик запятых
        buffr=''
        len_atag3:=len(atag3[ii])
        for j=len_atag3 to 1 step -1
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
          OtherWise
            exit
          endcase
        next
        if cntr<2.and.!empty(buffr)
          atag3[ii]=buffr
        endif
      case at('dtoc(',atag1[ii])#0 .or. at('dtos(',atag1[ii])#0
        atag3[ii]=stuff(atag1[ii],1,5,"")
        atag3[ii]=subs(atag3[ii],1,len(atag3[ii])-1)
      endcase
      if ii=k.and.!empty(plast)
          atag1[ii]='subs('+atag1[ii]+',1,'+plast+')'
      endif
      atag1[ii]=strtran(atag1[ii],atag3[ii],atag2[ii],1,1)
      lexpr=lexpr+'.and.'+atag3[ii]+'='+atag2[ii]
    next
    //outlog(__FILE__,__LINE__,'atag3',atag3)
    //outlog(__FILE__,__LINE__,'atag2',atag2)
    //outlog(__FILE__,__LINE__,'atag1',atag1)

    ind_r=''
    for ii=1 to k
        ind_r=ind_r+atag1[ii]
        if ii#k
           ind_r=ind_r+'+'
        endif
    next
    If !Empty(ldebug)
      outlog(__FILE__,__LINE__,'ind_r',ind_r,&ind_r)
    EndIf


  ind_r:=alltrim(ind_r)

  sele (alr)
  set orde to tag (tgr)
  cind_r := &ind_r
  for ii:=1 to 2
    seek cind_r // &ind_r
    if foun(); exit;  endif
  next

  /*
  *  #ifdef __CLIP__
  *  #else
  *     seek str(999999,6)
  *  #endif
  */
  if FOUND() //.and.!eof()
     if alr#al_r
        sele (alr)
        set order to oldind2
        go oldrcn2
     endif
     if !empty(al_r)
        sele (al_r)
        set order to oldind
     endif
  else
    /*
  *     #ifdef __CLIP__
  *        if alias()=='TOVM'
  *           outlog(__FILE__,__LINE__,date(),alias(),tgr,ind_r,cind_r,PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),"NETSEEK ERR TOVM INDX")
  *        endif
  *        if alias()=='RS1'
  *           outlog(__FILE__,__LINE__,date(),alias(),tgr,ind_r,cind_r,PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),"NETSEEK ERR RS1 INDX")
  *        endif
  *     #endif
  */
     if empty(eloc)
        if alr#al_r
           sele (alr)
           set order to oldind2
           go oldrcn2
        endif
        if !empty(al_r)
           sele (al_r)
           set order to oldind
        endif
        retu .f.
     else
        set orde to
        b_lexpr:=&('{||'+lexpr+'}')
        __dbLocate(b_lexpr)
        //locate for &lexpr
        if foun()
            // *           wmess(lexpr)
           #ifdef __CLIP__
             outlog(__FILE__,__LINE__,date(),alias(),tgr,ind_r,cind_r,recn(),lexpr,PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),"NETSEEK LOCATE OK!")
           #endif
           rcn_r=recn()
           if creci()
              set orde to tag &tgr
              seek &ind_r
              if foun()
                 #ifdef __CLIP__
                    outlog(__FILE__,__LINE__,date(),alias(),tgr,ind_r,cind_r,recn(),lexpr,PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),"NETSEEK OK! AFTER CORR")
                 #endif
              else
                 go rcn_r
              endif
           endif
           if alr#al_r
              sele (alr)
              set order to oldind2
              go oldrcn2
           endif
           if !empty(al_r)
              sele (al_r)
              set order to oldind
           endif
           retu .t.
        else
           if alr#al_r
              sele (alr)
              set order to oldind2
              go oldrcn2
           endif
           if !empty(al_r)
              sele (al_r)
              set order to oldind
           endif
           retu .f.
        endif
     endif
  endif
  retu .t.

Function outanetseek()
  AEVAL(aNetSeek,{|aE|;
  outlog(__FILE__,__LINE__,aE);
  })
  Return (Nil)

********************************************
func netrepl(p1,p2,p3,p4)   // Замена полей
  ********************************************
  * p1 - поля
  * p2 - переменные
  * p3 - без dbrunlock()
  * p4 - без dbcommit()

  local fldbr,flmr, zz, ff, nPosFld,lcfldr, nPosFld_zz
  LOCAL mzzr
  LOCAL bSaveHandler, error
  LOCAL afl1, afl2
  LOCAL aVar1
  LOCAL ii,j,cntr,bbb,ckob,al

  lcfldr=''

  reclock()
  al=lower(alias())

  IF ISCHAR(p2)
    ////////////// переменные или выражения ////////////
    fldbr=strtran(p2,' ')
    afl1={}
    cntr=1
    ckob=0
    for ii=1 to len(fldbr)
        if subs(fldbr,ii,1)='('
           ckob=ckob+1
        endif
        if subs(fldbr,ii,1)=')'
           ckob=ckob-1
        endif
        if subs(fldbr,ii,1)=','.and.ckob=0
           cntr=cntr+1
        endif
    next

    bbb=''
    j=1
    ckob=0
    for ii=1 to len(fldbr)
        if subs(fldbr,ii,1)='('
           ckob=ckob+1
        endif
        if subs(fldbr,ii,1)=')'
           ckob=ckob-1
        endif
        if subs(fldbr,ii,1)=','.and.ckob=0
           aadd(afl1,bbb)
           j=j+1
           bbb=''
        else
           bbb=bbb+subs(fldbr,ii,1)
        endif
    next
    aadd(afl1,bbb)

    ////////// массив значений переменных вычислим ///////
    aVar1:={}
    for ii:=1 to cntr
      ff:=afl1[ii] //переменная
      ff:=&(ff)    //значение переменной   //ff:=EVAL(memvarblock(ff)) //&(ff)    //значение переменной
      AADD(aVar1,ff)
    next
    ////////////////////////////////////////
  ELSE
    //массив значений
    aVar1:=p2
    cntr:=LEN(p2)
  ENDIF


  IF ISCHAR(p1)
    /////////// поля, куда писать //////////////
    afl2={}
    flmr=strtran(p1,' ')
    bbb=''
    j=1
    for ii=1 to len(flmr)
        if subs(flmr,ii,1)=','
           aadd(afl2,bbb)
           j=j+1
           bbb=''
        else
           bbb=bbb+subs(flmr,ii,1)
        endif
    next
    aadd(afl2,bbb)
    ////////////////////////////////////////////
  ELSE
    //массив имен полей замены
    afl2:=p2
  ENDIF

  //////// замена полей на переменные /////////
  for ii:=1 to cntr
      nPosFld=ii

      ff:=aVar1[ii]

      zz:=ALLTRIM(afl2[ii]) //поле таблицы
      nPosFld_zz:=FIELDPOS(zz)
      mzzr:=FIELDGET(nPosFld_zz) //      mzzr=&zz   // значение таблицы

      if !(mzzr == ff)

         #ifdef __CLIP__
            lcfldr=zz
         #else
          /*
            if (alias()=='DOKK'.or.alias()=='DOKKO').and.mn#0
               if zz='bs_d'.or.zz='bs_k'.or.zz='bs_s'.or.zz='kkl'.or.zz='dokksk';
                  .or.zz='dokkttn'.or.zz='kta'.or.zz='ktas'.or.zz='nnds'
                  lcfldr=zz
               endif
            endif
           */
         #endif

         if fieldtype(nPosFld_zz)='N' .and. fielddeci(nPosFld_zz)=0
            //mzzr=&zz //уже присвоили
            if roun(mzzr,0)#roun(ff,0)
              #ifdef __CLIP__
                /*
                if alias()=='DOKK'.and.zz=='nnds'.and.dokk->kkl==3048721.and.(dokk->bs_d=641002.or.dokk->bs_k=641002).and.mzzr#0
                   outlog(__FILE__,__LINE__,date(),time(),PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),mzzr,zz,ff,gnKto,dokk->sk,dokk->rn,dokk->mnp,"NNDS")
                endif
                */
                IF alias()=='TOVM'.and.(field(ii)=='mntov'.or.field(ii)=='skl').or.alias()=='RS1'.and.field(ii)=='ttn'
                   if .f. .and. select('tovpt')#0
                      tovpt->(DBAPPEND())
                      tovpt->Kto:=gnKto
                      tovpt->DataUse:=alias()+"-R"
                      tovpt->Param:=PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5)+";"+pathr+";"+str(gnSk,3)
                      tovpt->Dt:=DATE()
                      tovpt->TM:=TIME()
                      tovpt->SCNDS:=SECONDS()
                      tovpt->RCN:=RECNO()
                      tovpt->Prog:=STR(nPosFld,3)
                      tovpt->FldNm:=FIELDNAME(nPosFld)
                      DO CASE
                         CASE FIELDTYPE(nPosFld)="N"
                              tovpt->Pre_Num:=FIELDGET(nPosFld)
                         CASE FIELDTYPE(nPosFld)="D"
                              tovpt->Pre_Dt:=FIELDGET(nPosFld)
                         CASE FIELDTYPE(nPosFld)="C"
                              tovpt->Pre_Char:=FIELDGET(nPosFld)
                      endcase
                   endif
                ENDIF
              #else
                if alias()=='DOKK'.and.zz=='nnds'.and.dokk->kkl==3048721.and.(dokk->bs_d=641002.or.dokk->bs_k=641002).and.mzzr#0
                  // *wait
                  // *outlog(__FILE__,__LINE__,date(),time(),PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),mzzr,zz,ff,gnKto,dokk->sk,dokk->rn,dokk->mnp,"NNDS")
                endif
              #endif

               //repl &zz with ff
              FIELDPUT(nPosFld_zz,ff)

              if (alias()=='RS2OTV'.or.alias()=='RS2OTV').and.zz=='amnp'.and.otv=2.and.amnp=0
                 outlog(__FILE__,__LINE__,date(),time(),PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),mzzr,zz,ff,gnKto,"AMNP=0")
              endif
               if alias()=='KLN'.and.zz=='nkl'
                  if !empty(mzzr).and.alltrim(mzzr)#alltrim(ff)
                     #ifdef __CLIP__
                     outlog(__FILE__,__LINE__,date(),time(),PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),mzzr,zz,ff,gnKto,"NKLCHNG")
                     #endif
                     if select('klnnkl')=0
                        netuse('klnnkl')
                     endif
                     progr=procname(1)
                     sele klnnkl
                     appe blank
                     repl kto with gnKto,;
                          dt with date(),;
                          tm with time(),;
                          snkl with mzzr,;
                          nnkl with ff,;
                          prog with progr,;
                          arm with gnArm
                     use
                     sele kln
                  endif
               endif
               #ifdef __CLIP__
                /*
                *if alias()=='TOVM'.and.(zz=='mntov'.or.zz=='skl').or.alias()=='RS1'.and.zz=='ttn'
                *outlog(__FILE__,__LINE__,date(),time(),PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),mzzr,zz,ff,"INDX NETREPL")
                *endif
                */
              if alias()=='TOVM'.and.(field(ii)=='mntov'.or.field(ii)=='skl').or.alias()=='RS1'.and.field(ii)=='ttn'
                 if .f. .and. select('tovpt')#0
                    DO CASE
                       CASE FIELDTYPE(nPosFld)="N"
                            tovpt->Post_Num:=FIELDGET(nPosFld)
                       CASE FIELDTYPE(nPosFld)="D"
                            tovpt->Post_Dt:=FIELDGET(nPosFld)
                       CASE FIELDTYPE(nPosFld)="C"
                            tovpt->Post_Char:=FIELDGET(nPosFld)
                    endcase
                 endif
              ENDIF
               #endif
            endif
         else
            //mzzr=&zz
            //repl &zz with ff
            FIELDPUT(nPosFld_zz,ff)

            if alias()=='KLN'.and.zz=='nkl'
               if !empty(mzzr).and.!(alltrim(mzzr)==alltrim(ff))
                  #ifdef __CLIP__
                  outlog(__FILE__,__LINE__,date(),time(),PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),mzzr,zz,ff,gnKto,"NKLCHNG")
                  #endif
                  if select('klnnkl')=0
                     netuse('klnnkl')
                  endif
                  progr=procname(1)
                  sele klnnkl
                  appe blank
                  repl kto with gnKto,;
                       dt with date(),;
                       tm with time(),;
                       snkl with mzzr,;
                       nnkl with ff,;
                       prog with progr,;
                       arm with gnArm
                  use
                  sele kln
               endif
            endif
         endif
         if p4=nil
            #ifdef __CLIP__
              dbcommit()
            #endif
         endif
      endif
  next

  if empty(p4)
    #ifdef __CLIP__
    dbcommit()
    #endif
  endif

  if empty(p3)
    dbunlock()
  endif
  DBSkip(0)

  #ifdef __CLIP__
    IF alias()=='TOVM'.or.alias()=='RS1'
       if .f. .and. select('tovpt')#0
          tovpt->(DBAPPEND())
          tovpt->Kto:=gnKto
          tovpt->DataUse:=alias()+"-R"
          tovpt->Param:=PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5)+";"+pathr+";"+str(gnSk,3)
          tovpt->Dt:=DATE()
          tovpt->TM:=TIME()
          tovpt->SCNDS:=SECONDS()
          tovpt->RCN:=RECNO()
       endif
    ENDIF
  #endif

  retu lcfldr
**************
func netdel()
  **************
  reclock()
  #ifdef __CLIP__
    /*
  *  if lower(alias())=='pr1'.and.gnRmsk=4.and.gnEnt=20
  *     outlog(__FILE__,__LINE__,date(),time(),PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),gnKto,pr1->mn,path_pr,path_tr,"Удаление pr1")
  *  endif
  */
    if lower(alias())=='rs3'.and.gnRmsk=4.and.gnEnt=21.and.rs3->ksz=46
       outlog(__FILE__,__LINE__,date(),time(),PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),gnArm,gnKto,rs1->ttn,"Удаление ksz46")
    endif
    if lower(alias())=='dokz'
       outlog(__FILE__,__LINE__,date(),time(),PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),gnKto,dokz->mn,path_pr,path_tr,"Удаление dokz")
    endif
  #endif
  dele
  netunlock()
  retu .t.

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-16-16 * 11:27:57am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION getfield3(tgr,indr,al,fld,eloc)
  LOCAL aaa1, aaa2
  aaa1:=getfield(tgr,indr,al,fld,eloc)
  //aaa1:=aaa2

  aaa2:=getfield2(tgr,indr,al,fld,eloc)

  IF !(aaa1 == aaa2)
    outlog(__FILE__,__LINE__,aaa1,aaa2,tgr,indr,al,fld,eloc)
  ENDIF

  RETURN (aaa2)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-14-16 * 04:42:33pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION getfield(tgr,indr,al,fld,eloc)
  LOCAL aaa
  LOCAL plast
  LOCAL oldslc,oldind, rcn_r
  LOCAL alr
  LOCAL oldind2, rcn2

  oldslc:=select()
  oldind:=indexord()
  rcn_r:=recno()

  if !empty(al)
     alr:=lower(al)
  else
     alr:=lower(alias())
  endif

  sele (alr)
  if al#nil
     oldind2:=indexord()
     rcn2:=recn()
  endif

  netseek(tgr,indr,al,plast,eloc)

  if fieldpos(fld)#0
     aaa:=FIELDGET(fieldpos(fld))
  else
     aaa=.f.
  endif
  if al#nil
    set orde to oldind2
    go rcn2
    sele (oldslc)
    if !empty(alias())
        set orde to oldind
        go rcn_r
    endif
  else
     set orde to oldind
     go rcn_r
  endif

  RETURN (aaa)


******************************************************
function getfield2(tgr,indr,al,fld,eloc)
  // Поиск по индексу и возврат поля
  ******************************************************
  local aaa, b_lexpr
  * tgr  - имя тэга
  * indr - переменные для индексного выражения
  * al   - алиас
  * fld  - возвращаемое поле
  * eloc  - при неудачном seek -> locate

  priv ar,k,br,indr1,alr,tt,j,jj,l,ll,ii,ntgr,rcn_r,lexpr

  lexpr='.t.' // выражение для lоcate

  oldslc=select()
  oldind=indexord()
  rcn_r=recno()

  if !empty(al)
     alr=lower(al)
  else
     alr=lower(alias())
  endif

  sele (alr)
  if al#nil
     oldind2=indexord()
     rcn2=recn()
  endif

  //set orde to tag &tgr
  set orde to tag (tgr)
  indr1=lowe(indexkey(indexord(tgr)))

  ntgr=val(subs(tgr,2))

  /*
  *sele dbft
  *locate for alltrim(als)==alr
  *if !FOUND()
  *   wmess(alr+' не описана в DBFT',2)
  *endif
  *indr1=alltrim(&tgr) // индексное выражение в dbft
  */
  if empty(indr1)
     wmess('Тэг '+tgr+' пустой '+alr,2)
     retu .f.
  endif

  //sele (alr)
  //set orde to tag &tgr

  n=1
  store 0 to zn2r // Признаки скобок (1 - открыта)
  for ii=1 to len(indr) // Определение переменных для индексного выражения
      do case
         case subs(indr,ii,1)='('
              zn2r++
         case subs(indr,ii,1)=')'
              zn2r--
         case subs(indr,ii,1)=','.and.zn2r=0
              n++
      endcase
  next
  k:=1
  for ii=1 to len(indr1) // Определение к-ва элементов Тэга
    if subs(indr1,ii,1)='+'
      k++
    endif
  next
  if k>n
     k=n
  endif
  ll:=0
  for ii=1 to len(indr1)
      if subs(indr1,ii,1)='+'
         ll++ //=ll+1
         if ll=k
            exit
         endif
      endif
  next

  indr1:=subs(indr1,1,ii)

  atag1:={}
  atag2:={}
  atag3:={}
  jj:=1
  ll:=1
  for ii:=1 to k // разделение индексного выражения и строки переменных на составляющие
      ar=''
      br=''
      for j=jj to len(indr1)
          if subs(indr1,j,1)='+'
             jj=j+1
             exit
          endif
          ar=ar+subs(indr1,j,1)
      next
      aadd(atag1,ar) // элемент индексного выражения
      aadd(atag3,ar)

      if ii=k.and.right(atag1[ii],1)='+'
         atag1[ii]=subs(atag1[ii],1,len(atag1[ii])-1)
      endif

      store 0 to zn2r // Признаки скобок (1 - открыта)
      for l=ll to len(indr)
          do case
             case subs(indr,l,1)='('
                  zn2r++
             case subs(indr,l,1)=')'
                  zn2r--
             case subs(indr,l,1)=','.and.zn2r=0
                  ll=l+1
                  exit
          endcase
          br=br+subs(indr,l,1)
      next
      aadd(atag2,br) // элемент строки переменнных
  next
  // отличия
  for ii:=1 to k
    do case
    case at('str(',atag1[ii])#0
      atag1[ii]=stuff(atag1[ii],1,4,"")
      atag1[ii]=subs(atag1[ii],1,len(atag1[ii])-1)
      ar=''
      if at(')',atag1[ii])#0
        for j=len(atag1[ii]) to 1 step -1
            if subs(atag1[ii],j)=')'
              exit
            endif
        next
        atag1[ii]=subs(atag1[ii],1,j)
      else
        if at(',',atag1[ii])#0
          pz_r=at(',',atag1[ii])
          atag1[ii]=subs(atag1[ii],1,pz_r-1)
        endif
      endif
    case at('dtoc(',atag1[ii])#0 .or. at('dtos(',atag1[ii])#0
      atag1[ii]=stuff(atag1[ii],1,5,"")
      atag1[ii]=subs(atag1[ii],1,len(atag1[ii])-1)
    endcase
  next

  indr_r=''
  for ii=1 to k
      atag3[ii]=strtran(atag3[ii],atag1[ii],atag2[ii],1,1)
      indr_r=indr_r+atag3[ii]+'+'
      lexpr=lexpr+'.and.'+atag1[ii]+'='+atag2[ii]
  next
  indr_r=subs(indr_r,1,len(indr_r)-1)

  sele (alr)
  set orde to tag (tgr)
  cind_r := &indr_r
  for ii:=1 to 2
    seek cind_r // &indr_r
    if foun(); exit;  endif
  next

  *******************************
  if !found() .and. !empty(eloc)
     set orde to
     // loca for &lexpr
     b_lexpr:=&('{||'+lexpr+'}')
     __dbLocate(b_lexpr)
     if foun()
        #ifdef __CLIP__
           outlog(__FILE__,__LINE__,alias(),tgr,indr_r,recn(),fld,"GETFIELD LOCATE OK!")
        #endif
     endif
  endif
  *******************************

  if fieldpos(fld)#0
     //aaa=&fld
     aaa:=FIELDGET(fieldpos(fld))
  else
     aaa=.f.
  endif
  if al#nil
      set orde to oldind2
      go rcn2
      sele (oldslc)
      if !empty(alias())
         set orde to oldind
         go rcn_r
      endif
  else
     set orde to oldind
     go rcn_r
  endif
  retu aaa

***********************************************
func crtt(p1,p2)   // Создание таблицы вручную
  ***********************************************
  local aname:={},atype:={},alen:={},adec:={},fldr,adbf:={},i
  * p1 - Имя
  * p2 - Характеристики (f: - поле;c: - характеристика поля)
  fldr=p2
  do while len(fldr)#0
     bb=at('c:',fldr)
     cc=alltrim(subs(fldr,3,bb-3))
     if empty(cc)
        exit
     endif
     aadd(aname,cc)
     fldr=subs(fldr,bb)
     aa=at('f:',fldr)
     if aa#0
        cc=alltrim(subs(fldr,3,aa-3))
     else
        cc=alltrim(subs(fldr,3))
     endif
     aadd(atype,subs(cc,1,1))
     if subs(cc,1,1)='d'
        aadd(alen,8)
        aadd(adec,0)
     else
        cc=subs(cc,3)
        if at(',',cc)=0
           aadd(alen,val(subs(cc,1,len(cc)-1)))
           aadd(adec,0)
        else
           aadd(alen,val(subs(cc,1,at(',',cc)-1)))
           cc=subs(cc,at(',',cc)+1)
           cc=subs(cc,1,len(cc)-1)
           aadd(adec,val(cc))
        endif
     endif
     fldr=subs(fldr,aa)
  endd
  for i=1 to len(aname)
      aadd(adbf,{UPPER(aname[i]),UPPER(atype[i]),alen[i],adec[i]})
  next
  dbcreate(p1,adbf,rddSetDefault())
  retu .t.

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-21-16 * 06:41:30pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
   p1 имя массива default arec
   arec:={} Объявить массив до первого использования
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION getrec(p1)
  ****************
  local i,vf, p2
  if empty(p1)
    p2:=aRec
  else
    //aadd(&p1,vf)
    p2:=EVAL(memvarblock(p1))
  endif

  for i:=1 to 255
    vf=fieldget(i)
    if vf=nil
      exit
    endif
    aadd(p2,vf)
  next
  retu .t.


****************
func get_rec(p1)
  ****************
  * p1 имя массива default arec
  * arec:={} Объявить массив до первого использования
  local i,vf
  for i:=1 to 255
    vf=fieldget(i)
    if vf=nil
        exit
    endif
    if empty(p1)
      aadd(aRec,vf)
    else
      aadd(&p1,vf)
    endif
  next
  retu .t.

****************************
func putrec(p1,p2,p3,p4,p5)
  ****************************
  * p1 имя массива default arec
  * p2 кроме полей
  * p3 1- без commit
  * p4 - подменить поле
  * p5 - значение для подмены поле
  * кроме полей
  local i,vf,mass, nPosFld, nLen, aMass, aVar, aaa
  if empty(p1)
     mass='aRec'
     aMass:=aRec
  else
     mass:=p1
     aMass:=EVAL(memvarblock(mass)) // &mass
  endif

  aVar:={}
  if !empty(p2)
     aaa=''
     for i:=1 to len(p2)
         if subs(p2,i,1)=','
            aadd(aVar,aaa)
            aaa=''
            loop
         endif
         aaa=aaa+upper(subs(p2,i,1))
     endf
     aadd(aVar,aaa)
  endif

  nLen:=len(aMass)
  nLen:=MIN(FCOUNT(), nLen)

  for i:=1 to nLen
      if ascan(avar,FIELDname(i))#0
         loop
      endif
  //    #ifdef __CLIP__
  //       vf=&mass[i]
  //    #else
      if !empty(p4).and.!empty(p5)
        if upper(p4)=FIELDname(i)
            vf:=p5
        else
            // 1vf=&mass[i]
            vf:=aMass[i]
        endif
      else
        // 1vf=&mass[i]
        vf:=aMass[i]
      endif
  //    #endif
      if vf=nil
         exit
      endif
      nPosFld:=i
      IF FIELDGET(nPosFld) # NIL .AND. !(FIELDGET(nPosFld) == vf)
        /*
  *       #ifdef __CLIP__
  *           if alias()=='TOVM'
  *              do case
  *                 case field(i)='MNTOV'
  *                      outlog(__FILE__,__LINE__,date(),time(),PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),tovm->mntov,field(i),vf,"INDX")
  *                 case field(i)=='SKL'
  *                      outlog(__FILE__,__LINE__,date(),time(),PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),tovm->skl,field(i),vf,"INDX")
  *                 case field(i)=='NAT'
  *                      outlog(__FILE__,__LINE__,date(),time(),PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),tovm->nat,field(i),vf,"INDX")
  *              endcase
  *           endif
  *           if alias()=='RS1'.and.field(i)=='TTN'
  *              outlog(__FILE__,__LINE__,date(),time(),PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),rs1->ttn,field(i),vf,"INDX")
  *           endif
  *       #endif
  *
  *       fieldput(i,vf)
         */
         if fieldtype(i)='N'.and.fielddeci(i)=0
            mzzr=fieldget(i)
            if roun(mzzr,0)#roun(vf,0)
               #ifdef __CLIP__
                if alias()=='TOVM'.and.(field(i)=='mntov'.or.field(i)=='skl').or.alias()=='RS1'.and.field(i)=='ttn'
                   if select('tovpt')#0.and..f.
                      tovpt->(DBAPPEND())
                      tovpt->Kto:=gnKto
                      tovpt->DataUse:=alias()+"-P"
                      tovpt->Param:=PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5)+";"+pathr+";"+str(gnSk,3)
                      tovpt->Dt:=DATE()
                      tovpt->TM:=TIME()
                      tovpt->SCNDS:=SECONDS()
                      tovpt->RCN:=RECNO()
                      tovpt->Prog:=STR(nPosFld,3)
                      tovpt->FldNm:=FIELDNAME(nPosFld)
                      DO CASE
                         CASE FIELDTYPE(nPosFld)="N"
                              tovpt->Pre_Num:=FIELDGET(nPosFld)
                         CASE FIELDTYPE(nPosFld)="D"
                              tovpt->Pre_Dt:=FIELDGET(nPosFld)
                         CASE FIELDTYPE(nPosFld)="C"
                              tovpt->Pre_Char:=FIELDGET(nPosFld)
                      endcase
                   endif
                ENDIF
               #endif
               fieldput(i,vf)
               #ifdef __CLIP__
                /*
                if alias()=='TOVM'.and.(field(i)=='mntov'.or.field(i)=='skl').or.alias()=='RS1'.and.field(i)=='ttn'
                 outlog(__FILE__,__LINE__,date(),time(),PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),mzzr,field(i),ff,"INDX PUTREC")
                 endif
                 */
                if alias()=='TOVM'.and.(field(i)=='mntov'.or.field(i)=='skl').or.alias()=='RS1'.and.field(i)=='ttn'
                   if select('tovpt')#0.and..f.
                      DO CASE
                         CASE FIELDTYPE(nPosFld)="N"
                              tovpt->Post_Num:=FIELDGET(nPosFld)
                         CASE FIELDTYPE(nPosFld)="D"
                              tovpt->Post_Dt:=FIELDGET(nPosFld)
                         CASE FIELDTYPE(nPosFld)="C"
                              tovpt->Post_Char:=FIELDGET(nPosFld)
                      endcase
                   endif
                ENDIF
               #endif
            endif
         else
            fieldput(i,vf)
         endif

         #ifdef __CLIP__
            if empty(p3)
               dbcommit()
            endif
         #endif

      ENDIF
  next
  #ifdef __CLIP__
    if empty(p3)
       dbcommit()
       DBSkip(0)
    endif
  #endif
        #ifdef __CLIP__
           IF alias()=='RS1'
              if rs1->ttn=60.and.!empty(rs1->dvp)
                 outlog(__FILE__,__LINE__,date(),time(),PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2),"TTN=60","putrec")
              endif
           ENDIF
        #endif
  retu .t.

*************************************************
func crddop(p1,p2) // Создание базы с дополнением
  *************************************************
  adop:={}
  dfilr=p1
  for i=1 to 3
      if file('temp'+str(i,1)+'.dbf')
         erase ('temp'+str(i,1)+'.dbf')
      endif
  endf
  sele dbft
  locate for alltrim(als)==dfilr
  dirr=dir
  if empty(p2)
     sele dir
     locate for dir=dirr
     pathr=&(alltrim(ndir))
  endif
  sele dbft
  dfil_r=dfilr
  do while .t.
     locate for alltrim(als)==dfil_r
     aadd(adop,dop)
     if empty(dop)
        parentr=alltrim(als)
        exit
     else
        dfil_r=alltrim(parent)
     endif
  endd
  if !file(Pathr+dfilr+'.dbf')
     stru()
  endif
  retu .t.

**************
func stru()
  **************
  sele dbft
  locate for alltrim(als)==parentr
  fil_p=alltrim(als)
  pathsr=gcPath_a+fil_p
  if file(pathsr+'.dbf')
     sele 0
     use (pathsr) alias parent
     copy stru exte to (gcPath_l+'\temp1')
     use
     for i=1 to len(adop)
         dop_r=alltrim(adop[i])
         pathsr=gcPath_a+dop_r
         if file(pathsr+'.dbf')
            sele 0
            use (pathsr) alias parent
            copy stru exte to (gcPath_l+'\temp'+str(i+1,1))
            use
         endif
     endf
     sele 0
     use temp1
     for i=len(adop) to 1 step -1
         if file('temp'+str(i+1,1)+'.dbf')
            appe from ('temp'+str(i+1,1)+'.dbf')
            erase ('temp'+str(i+1,1)+'.dbf')
         endif
     endf
     use
     crea (Pathr+dfilr) from temp1.dbf
     erase temp1.dbf
  endif
  netuse(dfilr,,'e')
  netind(dfilr)
  nuse(dfilr)
  retu .t.

****************************************
func crdbftfl(p1,p2)
  ****************************************
  * p1 алиас
  * p2 1 - pathr
  erase stmp1.dbf
  erase stmp2.dbf
  erase stmp3.dbf
  sele dbft
  locate for alltrim(als)=p1
  dirr=dir
  paretnr=alltrim(parent)
  dopr=alltrim(dop)
  fnamer=alltrim(fname)
  if !found()
     retu .f.
  else
     if empty(p2)
        sele dir
        locate for dir=dirr
        ndirr=alltrim(ndir)
        pathr=&ndirr
     endif
     if netfile(p1,1)
        retu .f.
     endif
     if empty(parentr)
        if empty(dopr)
           copy file (gcPath_a+p1+'.dbf') to (pathr+fnamer+'.dbf')
           retu .t.
        else
           sele 0
           use (gcPath_a+p1) alias infile
           copy stru to stmp1 exte
           use
           sele 0
           use (gcPath_a+dopr)
           copy stru to stmp2 exte
           use
           sele 0
           use stmp1
           appe from stmp2
           use
           crea (pathr+fnamer) from stmp1
           erase stmp1.dbf
           erase stmp2.dbf
           retu .t.
        endif
     else // !empty(parentr)
        if !empty(dopr)
           sele 0
           use (gcPath_a+dopr)
           copy stru to stmp3 exte
           use
        endif
        sele dbft
        locate for alltrim(als)==parentr
        if !found()
           erase stmp3.dbf
           retu .f.
        endif
        dop_r=alltrim(dop)
        if !empty(parent)
           erase stmp3.dbf
           retu .f.
        else
           sele 0
           use (gcPath_a+parentr) alias infile
           copy stru to stmp1 exte
           use
           if !empty(dop_r)
              sele 0
              use (gcPath_a+dop_r)
              copy stru to stmp2 exte
              use
           endif
           sele 0
           use stmp1
           if file('stmp2.dbf')
              appe from stmp2
           endif
           if file('stmp3.dbf')
              appe from stmp3
           endif
           use
           crea (pathr+fnamer) from stmp1
           erase stmp1.dbf
           erase stmp2.dbf
           erase stmp3.dbf
           retu .t.
        endif
     endif
  endif
  retu .t.

*************************************************************************
func lcrtt(p1,p2,p3)
  * Создание локальной таблицы из зарегистрированной в DBFT,с дополнительными
  * полями,если это необходимо.
  *************************************************************************
  * p1 имя локальной таблицы
  * p2 алиас таблицы-источника
  * p3 дополнительные поля (не обязательно)
  if !empty(p3)
    copy file (gcPath_a+p2+'.dbf') to ('tmp_p2'+'.dbf')
    sele 0
    use tmp_p2 //alias in
    copy stru to temp exte //
    use

    crtt('temp1',p3)
    sele 0
    use temp1
    copy stru to tempd exte //
    use
    erase temp1.dbf

    use temp
    appe from tempd
    use

    erase tempd.dbf
    crea (p1) from temp
    use
    erase temp.dbf
  else
    copy file (gcPath_a+p2+'.dbf') to (p1+'.dbf')
  endif
  retu .t.

*************************************************************************
func lcrtta(p1,p2,p3)
  * Создание локальной таблицы из зарегистрированных в DBFT,с дополнительными
  * полями,если это необходимо.
  *************************************************************************
  * p1 имя локальной таблицы
  * p2 список алиасов таблиц-источников
  * p3 дополнительные поля (не обязательно)
  crtt('lals','f:als c:c(6)')
  sele 0
  use lals
  cspisr=p2
  aaa=''
  for i=1 to len(p2)
      if subs(cspisr,i,1)=','
         sele lals
         appe blank
         repl als with aaa
         aaa=''
         loop
      endif
      aaa=aaa+subs(cspisr,i,1)
  next
  sele lals
  appe blank
  repl als with aaa
  if select('stmp')#0
     sele stmp
     use
  endif
  erase stmp.dbf

  sele lasl
  go top
  do while !eof()
     alsr=alltrim(als)
     sele 0
     use (gcPath_a+alsr) alias in
     copy stru to temp exte
     if select('stmp')=0
        rename temp to stmp
        sele 0
        use stmp
     else
        sele 0
        use temp
        do while !eof()
           field_namer=field_name
           sele stmp
           locate for field_name==field_namer
           if !foun()
              sele temp
              arec:={}
              getrec()
              sele stmp
              appe blank
              putrec()
           endif
           sele temp
           skip
        endd
        sele temp
        use
        erase temp.dbf
     endif
     sele lals
     skip
  endd

  if !empty(p3)
     crtt('temp1',p3)
     sele 0
     use temp1
     copy stru to temp exte
     use
     erase temp1.dbf
     sele 0
     use temp
     do while !eof()
        field_namer=field_name
        sele stmp
        locate for field_name==field_namer
        if !foun()
           sele temp
           arec:={}
           getrec()
           sele stmp
           appe blank
           putrec()
        endif
        sele temp
        skip
     endd
     sele temp
     use
     erase temp.dbf
  endif
  sele stmp
  use
  crea (p1) from stmp
  use
  erase stmp.dbf
  retu .t.
********************************************************************
func lindx(p1,p2,p3)
  * Индексация локальной таблицы по индексам зарегистрированной в DBFT
  * таблицы.Таблица закрывается после индексации
  ********************************************************************
  * p1 имя локальной таблицы
  * p2 алиас источника
  * p3 1 - pathr
  LOCAL cIndexKey,bIndexKey, cNameTag

  if select(p1)#0
     retu .f.
  endif

  sele 0
  if empty(p3)
     use (p1) excl
  else
     use (pathr+p1) excl
  endif

  dbclearindex()
  pack
  sele dbft
  locate for alltrim(als)==p2
  for i:=1 to 18
      sele dbft
      if i<10
         cNameTag='t'+str(i,1)
      else
         cNameTag='t'+str(i,2)
      endif
      if fieldpos(cNameTag)=0
         exit
      endif
      //cIndexKey=alltrim(&cNameTag)
      cIndexKey:=alltrim(FIELDGET(FIELDPOS(cNameTag)))
      if empty(cIndexKey)
         exit
      endif
      sele (p1)
      //inde on &cIndexKey tag &cNameTag
      bIndexKey:=&("{|| "+cIndexKey+" }")
      ordCondSet( ,  ,  ,  ,  ,  , RECNO() ,  ,  ,  ,  ,,,)
      //ordCreate( , bb , kk , {||&kk} ,)
      ordCreate( , cNameTag , cIndexKey , bIndexKey ,)

  next
  sele (p1)
  use
  retu .t.

**********************************************************************
func luse(p1,p2,p3)
  * Открытие локальной таблицы с подключением локальных индексов
  **********************************************************************
  local pf,i,tr,niir,oclr
  * p1 - имя локальной таблицы
  * p2 - алиас
  * p3 - 1 - pathr

  if empty(p3)
     if !file(p1+'.dbf')
        if wselect()=0
           wmess('Нет файла '+p1+'.dbf')
        endif
        retu .f.
     endif
  else
     if !file(pathr+p1+'.dbf')
        if wselect()=0
           wmess('Нет файла '+pathr+p1+'.dbf')
        endif
        retu .f.
     endif
  endif

  if !empty(p2)
     if select(p2)#0
        sele (p2)
        retu .t.
     endi
  else
     if select(p1)#0
        sele (p1)
        retu .t.
     endif
  endif

  if !empty(p2)
     sele 0
     if empty(p3)
        use (p1) alias (p2) excl
     else
        use (pathr+p1) alias (p2) excl
     endif
  else
     sele 0
     if empty(p3)
        use (p1)  excl
     else
        use (pathr+p1)  excl
     endif
  endif
  set orde to tag t1
  go top
  retu .t.

*****************************************************************
func rnrif(p1,p2,p3)
  * Возврат из "развернутой" таблицы символьного индекса наименования
  * поля для указанного  значения
  * Возвращает '', если не найден
  *****************************************************************
  * p1 - Префикс поля
  * p2 - Значение
  * p3 - Длина индекса,если есть

  priv pfr,vfr,lir,cir,i,fnr,prfr

  pfr=p1
  vfr=p2
  lir=p3
  fnr='' // Имя поля
  prfr=0 // Признак существования

  if !empty(lir)
     if lir=1
        lir=0
     else
        if lir>3
           lir=3
        endif
     endif
  endif

  * cir   - Возвращаемый индекс
  cir=''

  for i=1 to 255
      do case
         case empty(lir)
              cir=alltrim(str(i,3))
         case lir=2
              cir=iif(i<10,'0'+str(i,1),str(i,2))
         case lir=3
              cir=iif(i<10,'00'+str(i,1),iif(i<100,'0'+str(i,2),str(i,3)))
      endcase
      fnr=pfr+cir
      if fieldnum(fnr)=0
         cir=''
         exit
      endif
      if &fnr=vfr
         prfr=1
         exit
      endif
  endf
  if prfr=0
     cir=''
  endif
  retu cir

*************************************************************************************************
func rnreif(p1,p2)
  * Возврат свободного символьного индекса наименования поля
  * из "развернутой" таблицы
  * Возвращает '', если все заняты
  *****************************************************************
  * p1 - Префикс поля
  * p2 - Длина индекса,если есть

  priv pfr,vfr,lir,cir,i,fnr,prfr

  pfr=p1
  lir=p2
  fnr='' // Имя поля
  prfr=0 // Признак занятости всех полей


  if !empty(lir)
     if lir=1
        lir=0
     else
        if lir>3
           lir=3
        endif
     endif
  endif

  * cir   - Возвращаемый индекс
  cir=''

  for i=1 to 255
      do case
         case empty(lir)
              cir=alltrim(str(i,3))
         case lir=2
              cir=iif(i<10,'0'+str(i,1),str(i,2))
         case lir=3
              cir=iif(i<10,'00'+str(i,1),iif(i<100,'0'+str(i,2),str(i,3)))
      endcase
      fnr=pfr+cir
      if fieldnum(fnr)=0
         cir=''
         exit
      endif
      vfr=&fnr
      if empty(vfr)
         prfr=1
         exit
      endif
  endf
  retu cir

*************************************************************************************************
func rnnadd(p1,p2,p3,p4,p5,p6)
  * Добавление к "нормальной" таблице записи из "развернутой"
  *********************************************************************************
  * p1 - "Нормальная таблица"
  * p2 - "Развернутая таблица"
  * p3 - Список имен одноименных полей из обеих таблиц
  * p4 - Список имен "развернутых" полей из "нормальной" таблицы
  * p5 - Cписок префиксов имен "развернутых" полей из "развернутой" таблицы
  * p6 - Длина индекса имени "развернуых" полей

  priv cir,i,j,k,lir,cfldr,vfldr,aa
  lir=p6
  afldw:={} // Поля для записи
  afldr:={} // Поля для чтения
  afldv:={} // Значения для записи
  aa=''
  z=1
  for i=1 to len(p3)
      if subs(p3,i,1)=','
         aadd(afldw,aa)
         aadd(afldr,aa)
         aa=''
         z=z+1
         loop
      endif
      aa=aa+subs(p3,i,1)
  next
  aadd(afldw,aa)
  aadd(afldr,aa)
  z=len(afldw)
  aa=''
  for i=1 to len(p4)
      if subs(p4,i,1)=','
         aadd(afldw,aa)
         aa=''
         loop
      endif
      aa=aa+subs(p4,i,1)
  next
  aadd(afldw,aa)
  aa=''
  for i=1 to len(p5)
      if subs(p5,i,1)=','
         aadd(afldr,aa)
         aa=''
         loop
      endif
      aa=aa+subs(p5,i,1)
  next
  aadd(afldr,aa)
  asize(afldv,len(afldw))

  sele (p2)
  for i=1 to z
      cfldr=afldr[i]
      afldv[i]=&cfldr
  next

  if !empty(lir)
     if lir=1
        lir=0
     else
        if lir>3
           lir=3
        endif
     endif
  endif

  cir=''

  for i=1 to 255
      sele (p2)
      do case
         case empty(lir)
              cir=alltrim(str(i,3))
         case lir=2
              cir=iif(i<10,'0'+str(i,1),str(i,2))
         case lir=3
              cir=iif(i<10,'00'+str(i,1),iif(i<100,'0'+str(i,2),str(i,3)))
      endcase
      if fieldnum(afldr[z+1]+cir)=0
         exit
      endif
      for j=z+1 to len(afldr)
          cfldr=afldr[j]+cir
          afldv[j]=&cfldr
      next
      sele (p1)
      appe blank
      for k=1 to len(afldw)
          cfldr=afldw[k]
          repl &cfldr with afldv[k]
      next
  next
  retu .t.
*************************************************************************************************
func rnrupdf(p1,p2,p3,p4,p5,p6)
  * Поиск в "развернутой" таблице поля с указанным значением и запись
  * в поля с найденным индексом указанных значений
  * Если не найдено,запись в поля со свободным индексом
  * Возврат в текущую таблицу
  ******************************************************************************
  * p1 - "развернутая таблица"
  * p2 - префикс поля поиска
  * p3 - значение поиска
  * p4 - список префиксов имен полей для замены
  * p5 - список значений(переменных) для замены
  * p6 - длина индекса

  priv selr,lir,cir,aa

  lir=p6

  if !empty(lir)
     if lir=1
        lir=0
     else
        if lir>3
           lir=3
        endif
     endif
  endif

  selr=select()
  sele (p1)
  reclock()
  cir=rnrif(p2,p3,lir)
  if empty(cir)
     cir=rnreif(p2,lir)
  endif

  afldw:={}
  afldv:={}

  aa=''
  for i=1 to len(p4)
      if subs(p4,i,1)=','
         aadd(afldw,aa)
         aa=''
         loop
      endif
      aa=aa+subs(p4,i,1)
  next
  aadd(afldw,aa)
  aa=''
  for i=1 to len(p5)
      if subs(p5,i,1)=','
         vfldr=&aa
         aadd(afldv,vfldr)
         aa=''
         loop
      endif
      aa=aa+subs(p5,i,1)
  next
  vfldr=&aa
  aadd(afldv,vfldr)

  for i=1 to len(afldw)
      cfldr=afldw[i]+cir
      repl &cfldr with afldv[i]
  next

  sele (selr)
  retu .t.
**********************************************************************
func rnrgetf(p1,p2,p3,p4,p5)
  * Возвращает значение поля  из "развернутой" таблицы
  **********************************************************************
  * p1 - "развернутая" таблица
  * p2 - префикс поиска
  * p3 - значение поиска
  * p4 - префикс возвращаемого поля
  * p5 - длина индекса

  priv selr,cir,vlr,fldr

  selr=select()
  sele (p1)
  cir=rnrif(p2,p3,p5)
  if empty(cir)
     do case
        case valtype(p3)='C'
             vlr=''
        case valtype(p3)='N'
             vlr=0
        case valtype(p3)='D'
             vlr=ctod('')
        othe
             vlr=nil
     endcase
  else
     fldr=p4+cir
     vlr=&fldr
  endif
  sele (selr)
  retu vlr

***********************
func opendir(p1,p2,p3)
  ***********************
  * p1 - dir
  * p2 - path
  * p3 - суффикс
  if empty(p1)
     retu .f.
  endif
  if empty(p2)
     sele dir
     locate for dir=p1
     if !foun()
        wmess(str(p1,1)+' Нет в DIR')
        retu .f.
     endif
     cpathr=alltrim(ndir)
     pathr=&cpathr
  *else
  *   pathr=p2
  endif
  sele dbft
  go top
  do while !eof()
     sele dbft
     if dir#p1
        skip
        loop
     endif
     ffllr=alltrim(als)
     if empty(p3)
        if !netuse(ffllr,,,1)
           sele dbft
           skip
           loop
        endif
     else
        if !netuse(ffllr,ffllr+p3,,1)
           sele dbft
           skip
           loop
        endif
     endif
     sele dbft
     skip
  endd
  retu .t.

***********************
func closedir(p1,p2)
  ***********************
  * p1 - dir
  * p2 - суффикс
  if empty(p1)
     retu .f.
  endif
  sele dbft
  go top
  do while !eof()
     sele dbft
     if dir#p1
        skip
        loop
     endif
     ffllr=alltrim(als)
     if empty(p2)
        nuse(ffllr)
     else
        nuse(ffllr+p2)
     endif
     sele dbft
     skip
  endd
  retu .t.

****************
func netblank()
  ****************
  local i,nfldr
  nfldr:=fcount()
  //reclock()
  for i:=1 to nfldr
    do case
    case FIELDTYPE(i)='C'
      FIELDPUT(i,'')
    case FIELDTYPE(i)='N'
      FIELDPUT(i,0)
    case FIELDTYPE(i)='D'
      FIELDPUT(i,ctod(''))
    case FIELDTYPE(i)='L'
      FIELDPUT(i,.F.)
    endcase
  next
  #ifdef __CLIP__
    dbcommit()
  #endif
  DBSkip(0)
  retu .t.

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  07-06-16 * 09:28:16am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION NetUnlock(cAlias)
  IF EMPTY(cAlias)
    cAlias:=ALIAS()
  ENDIF
  (cAlias)->(;
   dbcommit(),;
   dbrunlock(),;
   dbskip(0);
  )
  RETURN (NIL)

******************
func nettag(p1,p2)
  * p1 алиас
  * p2 имя тэга
  ******************
  local als_rr,rcr_rr,rt_rr
  rt_rr=0
  als_rr=alias()
  if !empty(als_rr)
     rcr_rr=recn()
  endif
  sele (p1)
  if empty(ordkey(p2))
     rt_rr=0
  else
     rt_rr=1
  endif
  if !empty(als_rr)
     sele (als_rr)
     go rcr_rr
  endif
  if rt_rr=0
     retu .f.
  else
     retu .t.
  endif

*****************************
func nsele(p1,p2,p3,p4,p5,p6,p7)
  * Вроде запроса
  * p1 имя таблицы
  * p2 ':als pole1 pole2 ....'
  * p3 индексы
  * p4 поля для индексных выражений
  * p5 индексное выражение
  * p6 while
  * p7 for
  *****************************
  local i,j
  *afv:=array(2,1)
  *afv[1,1]='111'
  *afv[2,1]='222'
  *wait
  crr=p2
  cir=p3
  cifr=p4
  cier=p5
  cwlr=p6
  cfr=p7
  nalsr=''
  nfldr=''
  if select('sstmp')#0
     sele sstmp
     use
  endif
  erase sstmp
  * Таблица полей
  crtt ('efv','f:tbl c:c(6) f:fld c:c(10) f:i c:n(1) f:out c:n(1)')
  sele 0
  use efv
  * Таблица используемых таблиц (FROM)
  crtt ('etbl','f:tbl c:c(6) f:tag c:c(3) f:oldind c:n(3) f:ifld c:c(40) f:iexp c:c(40) f:cwhile c:c(40) f:cfor c:c(40)')
  sele 0
  use etbl
  copy stru to sstmp exte
  sele 0
  use sstmp excl
  zap
  ctblr=''
  cfldr=''
  for i=1 to len(crr)
      if subs(crr,i,1)=':' // новая таблица
         prtblr=1
         if select('stbl')#0
            sele stbl
            use
         endif
         ctblr=''
         loop
      endif
      if prtblr=1
         if subs(crr,i,1)#' '
            ctblr=ctblr+subs(crr,i,1)
         else
            prtblr=0
            sele 0
            use (gcPath_a+ctblr) alias rab
            copy stru to stbl exte
            use
            sele 0
            use stbl
            sele etbl
            appe blank
            repl tbl with ctblr
            loop
         endif
      endif
      if prtblr=0
         if subs(crr,i,1)=' '
            if !empty(cfldr)
               sele stbl
               locate for field_name=upper(cfldr)
               if foun()
                  arec:={}
                  getrec()
                  sele sstmp
                  appe blank
                  putrec()
  *                repl field_name with ctblr+'_'+cfldr
                  sele efv
                  appe blank
                  repl tbl with ctblr,;
                       fld with cfldr,;
                       out with 1
               endif
               cfldr=''
            endif
         else
            cfldr=cfldr+subs(crr,i,1)
         endif
      endif
  next
  if !empty(cfldr)
     sele stbl
     locate for field_name=upper(cfldr)
     if foun()
        arec:={}
        getrec()
        sele sstmp
        appe blank
        putrec()
  *      repl field_name with ctblr+'_'+cfldr
        sele efv
        appe blank
        repl tbl with ctblr,;
             fld with cfldr,;
             out with 1
     endif
     cfldr=''
     sele stbl
     use
     erase stbl
  endif
  sele sstmp
  use
  crea (p1) from sstmp
  erase sstmp
  * Тэги
  tagr=''
  n=1
  for i=1 to len(cir)
      if subs(cir,i,1)=';'
         sele etbl
         go n
         repl tag with tagr
         tagr=''
         n=n+1
         loop
      else
         tagr=tagr+subs(cir,i,1)
      endif
  next
  if !empty(tagr)
     sele etbl
     go n
     repl tag with tagr
  endif

  * Поля для индексов
  ifldr=''
  n=1
  for i=1 to len(cifr)
      if subs(cifr,i,1)=';'
         sele etbl
         go n
         repl ifld with ifldr
         ctblr=alltrim(tbl)
         cfldr=''
         for j=1 to len(ifldr)
             if subs(ifldr,j,1)=','
                sele efv
                locate for tbl=ctblr.and.fld=cfldr
                if !foun()
                   appe blank
                   repl tbl with ctblr,;
                        fld with cfldr,;
                        i with 1
                else
                   repl i with 1
                endif
                cfldr=''
             else
                cfldr=cfldr+subs(ifldr,j,1)
             endif
         next
         if !empty(cfldr)
            sele efv
            locate for tbl=ctblr.and.fld=cfldr
            if !foun()
               appe blank
               repl tbl with ctblr,;
                    fld with cfldr,;
                    i with 1
            else
               repl i with 1
            endif
         endif
         ifldr=''
         n=n+1
         loop
      else
         ifldr=ifldr+subs(cifr,i,1)
      endif
  next
  if !empty(ifldr)
     sele etbl
     go n
     repl ifld with ifldr
     ctblr=alltrim(tbl)
     cfldr=''
     for j=1 to len(ifldr)
         if subs(ifldr,j,1)=','
            sele efv
            locate for tbl=ctblr.and.fld=cfldr
            if !foun()
               appe blank
               repl tbl with ctblr,;
                    fld with cfldr,;
                    i with 1
            else
               repl i with 1
            endif
         else
            cfldr=cfldr+subs(ifldr,j,1)
         endif
     next
     if !empty(cfldr)
        sele efv
        locate for tbl=ctblr.and.fld=cfldr
        if !foun()
           appe blank
           repl tbl with ctblr,;
                fld with cfldr,;
                i with 1
         else
           repl i with 1
        endif
     endif
  endif

  iexpr=''
  n=1
  for i=1 to len(cier)
      if subs(cier,i,1)=';'
         sele etbl
         go n
         repl iexp with iexpr
         iexpr=''
         n=n+1
         loop
      else
         iexpr=iexpr+subs(cier,i,1)
      endif
  next
  if !empty(iexpr)
     sele etbl
     go n
     repl iexp with iexpr
  endif

  cforr=''
  n=1
  for i=1 to len(cfr)
      if subs(cfr,i,1)=';'
         sele etbl
         go n
         repl cfor with cforr
         cforr=''
         n=n+1
         loop
      else
         cforr=cforr+subs(cfr,i,1)
      endif
  next
  if !empty(cforr)
     sele etbl
     go n
     repl cfor with cforr
  endif

  cwhiler=''
  n=1
  for i=1 to len(cwlr)
      if subs(cwlr,i,1)=';'
         sele etbl
         go n
         repl cwhile with cwhiler
         cwhiler=''
         n=n+1
         loop
      else
         cwhiler=cwhiler+subs(cwlr,i,1)
      endif
  next
  if !empty(cwhiler)
     sele etbl
     go n
     repl cwhile with cwhiler
  endif

  * Инициализация таблиц
  sele etbl
  go top
  do while !eof()
     tblr=alltrim(tbl)
     tagr=alltrim(tag)
     sele (tblr)
     oldindr=indexord()
     set orde to tag &tagr
     sele etbl
     repl oldind with oldindr
     sele etbl
     skip
  endd

  * Запрос
  sele etbl
  go top
  do while !eof()
     tblr=alltrim(tbl)
     tagr=alltrim(tag)
     ifldr=alltrim(ifld)
     iexpr=alltrim(iexp)
     cforr=alltrim(cfor)
     cwhiler=alltrim(cwhile)
     sele (tblr)
     if empty(tagr)
        go top
     else
        if empty(cforr)
           go top
        else

        endif
     endif
     sele etbl
     skip
  endd
  retu .t.

*********************************************************
func netcind(p1)   // Корр индексов
  * p1 алиас
  *********************************************************
  local coalsr,coindr,corcnr,ij,ii,ll,n,k,jj,j

  if select(p1)=0
     retu .t.
  endif

  coalsr=lower(alias())
  if !empty(coalsr)
     coindr=indexord()
     corcnr=recn()
  endif

  sele dbft
  locate for alltrim(als)==p1
  if foun()
     for ij=1 to 18
         sele dbft
         cttr='t'+alltrim(str(ij,2))
         tgr=cttr
         ttr=&cttr
         if empty(ttr)
            loop
          endif
          sele (p1)
          if empty(ordkey(tgr))
  //             ?'Нет '+tgr+' '+ttr
             loop
          endif
          indr1=alltrim(ttr)
          indr=indr1
  //        ?tgr+' ' +indr1
          if indr1='deleted()'
             loop
          endif
          n=1
          k=1
          for ii=1 to len(indr1) // Определение к-ва элементов Тэга
              if subs(indr1,ii,1)='+'
                 k=k+1
              endif
          endf
          ll=0
          for ii=1 to len(indr1)
              if subs(indr1,ii,1)='+'
                 ll=ll+1
                 if ll=k
                    exit
                 endif
              endif
          endf
          indr1=subs(indr1,1,ii)
          jj=1
          ll=1
          atag:=array(k,4)
          for ii=1 to k // разделение индексного выражения на составляющие
              ar=''
              for j=jj to len(indr1)
                  if subs(indr1,j,1)='+'
                     jj=j+1
                     exit
                  endif
                  ar=ar+subs(indr1,j,1)
               endf
               atag[ii,1]=ar // элемент индексного выражения
               if ii=k.and.right(atag[ii,1],1)='+'
                  atag[ii,1]=subs(atag[ii,1],1,len(atag[ii,1])-1)
               endif
               br=''
               er=0
               for l=1 to len(ar)
                   do case
                      case subs(ar,l,1)='('
                           br=''
                           er=1
                      case subs(ar,l,1)=')'
                           exit
                      othe
                           br=br+subs(ar,l,1)
                   endcase
               endf
               atag[ii,2]=br       // поле элемента
               atag[ii,3]=type(br) // тип поля элемента
               atag[ii,4]=er       // признак выражения
          endf
          sele (p1)
          set orde to
          go top
          do while !eof()
             ind_r=''
             rcnr=recn()
             jjj=''
             for ii=1 to k
                 if atag[ii,4]=1
                    ind_r=ind_r+&(atag[ii,1])
                 else
                    ind_rr=atag[ii,2]
                    if atag[ii,3]='C'
                       ind_r=ind_r+&ind_rr
                    else
                       ind_r=&ind_rr
                    endif
                 endif
             endf
             set orde to tag &tgr //ij
             seek ind_r
             if !found()
                 seek ind_r
             endif
             if !foun()
              /*
  *              do case
  *                 case valtype(ind_r)='C'
  *                      ?tgr+' '+ind_r+' '+str(rcnr,10)
  *                 case valtype(ind_r)='N'
  *                      ?tgr+' '+str(ind_r,10)+' '+str(rcnr,10)
  *                 case valtype(ind_r)='D'
  *                      ?tgr+' '+dtoc(ind_r)+' '+str(rcnr,10)
  *                 case valtype(ind_r)='L'
  *                      ?tgr+' '+trans(ind_r,'L')+' '+str(rcnr,10)
  *                 othe
  *                      ?tgr+' '+ind_r+' '+str(rcnr,10)
  *              endcase
                 */
                set orde to
                go rcnr
                if creci()
                   set orde to tag &tgr
                   seek ind_r
                   if !foun()
                      ?tgr+' '+ind_r+' FAULT'
                   else
                      ?tgr+' '+ind_r+' Ok'
                   endif
                else
                   ?tgr+' '+ind_r+' '+str(rcnr,10)+' блокирован'
                endif
             endif
             set orde to
             go rcnr
             skip
          endd
     endf
  endif
  if !empty(coalsr)
     sele (coalsr)
     set orde to coindr
     go corcnr
  endif
  retu .t.

**************
func creci()
  **************
  //LOCAL arecir
  if reclock() // 1) задержка
     arecir:={};     getrec('arecir')
     netblank() //  выполнено  dbcommit()

     putrec('arecir')
     netunlock()
     #ifdef __CLIP__
       outlog(__FILE__,__LINE__,date(),alias(),"REC",recn(),PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),"Корр индекса")
     #endif
     retu .t.
  else
     #ifdef __CLIP__
       outlog(__FILE__,__LINE__,date(),alias(),"REC",recn(),reclock(1),"reclock(1)")
     #endif
  endif
  retu .f.
***********************
function dos_to_win(s)
  ***********************
  local i,t :='',c,k
  for i = 1 to len(s)
      c = substr(s,i,1)
      k = asc(c)
      if k < 128
      elseif k < 128 + 3*16
          c = chr(k + 64)
      elseif k < 128 + 6*16
      elseif k < 128 + 7*16
          c = chr(k + 16)
      elseif k = 252
          c = chr(185)
      elseif k = 240
          c = chr(168)
      elseif k = 241
          c = chr(184)
      elseif k = 242
          c = chr(170)
      elseif k = 243
          c = chr(186)
      elseif k = 244
          c = chr(175)
      elseif k = 245
          c = chr(191)
      endif
      t = t + c
  next
  retu t
***********************
function win_to_dos(s)
  ***********************
  local i,t :='',c,k
  for i = 1 to len(s)
      c = substr(s,i,1)
      k = asc(c)
      if k < 128
      elseif k < 128 + 3*16+64
          c = chr(k - 64)
      elseif k < 128 + 6*16
      elseif k < 128 + 7*16+16
          c = chr(k - 16)
      elseif k = 185
          c = chr(252)
      elseif k = 168
          c = chr(240)
      elseif k = 184
          c = chr(241)
      elseif k = 242
          c = chr(170)
      elseif k = 186
          c = chr(243)
      elseif k = 175
          c = chr(244)
      elseif k = 191
          c = chr(245)
      endif
      t = t + c
  next
  retu t
********************
func akoi_to_win(p1)
  ********************
  local bbb,ccc,nnn,sss,i
  bbb=''
  awinkoi:={128,129,130,131,132,133,134,135,136,137,060,139,140,141,142,143,;
            144,145,146,147,148,169,150,151,152,153,154,062,176,157,183,159,;
            160,246,247,074,164,231,166,167,179,169,180,060,172,173,174,183,;
            156,177,073,105,199,181,182,158,163,191,164,062,106,189,190,167,;
            225,226,247,231,228,229,246,250,233,234,235,236,237,238,239,240,;
            242,243,244,245,230,232,227,254,251,253,154,249,248,252,224,241,;
            193,194,215,199,196,197,214,218,201,202,203,204,205,206,207,208,;
            210,211,212,213,198,200,195,222,219,221,223,217,216,220,192,209}

  akoiwin:={128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,;
            144,145,146,147,148,149,150,151,152,153,218,155,176,157,183,159,;
            160,161,162,184,186,165,166,191,168,169,170,171,172,173,174,175,;
            156,177,178,168,170,181,182,175,184,185,186,187,188,189,190,185,;
            254,224,225,246,228,229,244,227,245,232,233,234,235,236,237,238,;
            239,255,240,241,242,243,230,226,252,251,231,248,253,249,247,250,;
            222,192,193,214,196,197,212,195,213,200,201,202,203,204,205,206,;
            207,223,208,209,210,211,198,194,220,219,199,216,221,217,215,218}
  for i=1 to len(p1)
      ccc=asc(subs(p1,i,1))
  *    ccc=alltrim(str(ccc,3))
  *    ccc=padl(ccc,3,'0')
      nnn=ascan(akoiwin,ccc)
      if nnn=0
         bbb=bbb+subs(p1,i,1)
      else
         sss=awinkoi[nnn]
         bbb=bbb+chr(sss)
      endif
  next
  retu bbb

********************
func koi_to_win(p1)
  ********************
  local SKoi,SWin,bbb,i,nnn,ccc,ddd
  SKoi="юЮаАбБцЦдДеЕфФгГхХиИйЙкКлЛмМнНоОпПяЯрРсСтТуУжЖвВьЬыЫзЗшШэЭщЩчЧъЪ"
  SWin="АаБбВвГгДдЕеЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя"
  bbb=''
  for i=1 to len(p1)
      ccc=subs(p1,i,1)
      nnn=at(ccc,SKoi)
      if nnn#0
         ddd=subs(SWin,nnn,1)
      else
         ddd=ccc
      endif
      bbb=bbb+ddd
  next
  retu bbb

/***********************************************************
  * Модуль    : test_ntx.prg
  * Версия    : 0.0
  * Автор     :
  * Дата      : 10/30/99
  * Изменен   :
  * Примечание: Текст обработан утилитой CF версии 2.02
  */

  #define DBOI_ORDERCOUNT 9
  #command WAIT ERROR <c> => MYTONE(1000, 1)         ;
   ; ALERT(<c>, { "Нажмите ESC для продолжения..." }, ;
            "RG+/R" + IF(SETBLINK(), "", "*")        ;
        )

FUNCTION Test_id(lsend)
  // тестирование индексов
  LOCAL x, j, i, Value, xFor, lValueFor//, bIndexKey
  LOCAL lRet:=.T., nRec:=Recno(), nOrd:=OrdSetFocus()
  LOCAL aInd:={}, aNNN:={}, aB:={}, aIndFor:={}, aBFor:={}
  LOCAL cWait_Error
  LOCAL lSetDel:=SET(_SET_DELETED)
  LOCAL nLen_aNNN, nLen_aInd, nCntRep
  //-----------------------------
  IF .T. .AND. (Used())                        // Есть dbf файл
    Set deleted OFF
    IF (Recno() > Reccount())
      Go top
    ENDIF

    IF (lSend = NIL)
      lsend:=.f.
    ENDIF

    Set order TO 0          // Список индесных выражений
                            //ORDSETFOCUS(0)
    i:=0
    WHILE (!EMPTY(ORDNAME(++i)))
      IF (Len(ORDKEY(i)) != 0)
        //bIndexKey:=
        AADD(aInd, ORDKEY(i)); AADD(aB, &("{||"+ORDKEY(i)+"}"))
        AADD(aIndFor, ORDFOR(i))
        AADD(aBFor, &("{||"+IIF(EMPTY(ORDFOR(i)), ".T.", ORDFOR(i))+"}"))
      ELSE
        EXIT
      ENDIF

    ENDDO
    /* FOR i=1 TO DbOrderInfo(DBOI_ORDERCOUNT)
       IF (Len(IndexKey(i)) != 0)
         AADD(aInd, IndexKey(i)); AADD(aB, &("{||"+ORDKEY(0)+"}"))
       ELSE
         EXIT
       ENDIF

     NEXT i
    */
    IF (Len(aInd) = 0 .or. reccount() = 0)// Нет индексов
      SET(_SET_DELETED,lSetDel)
      ORDSETFOCUS(nOrd)
      RETURN lRet
    ENDIF

    // --- Номера записей для проверки ---
    AADD(aNNN, 1)
    IF (Reccount() > 1)
      AADD(aNNN, Reccount())
      IF (Reccount() > 2)
        AADD(aNNN, Int(RANDOM()%(Reccount()-1)) + 1)
        IF (Reccount() > 5)
          AADD(aNNN, Int(RANDOM()%(Reccount()-1)) + 1)
          AADD(aNNN, Int(RANDOM()%(Reccount()-1)) + 1)
        ENDIF

      ENDIF //> 2

    ENDIF                   // > 1

    ASORT(aNNN)           // по порядку номера
    nLen_aInd := Len(aInd)
    FOR i:=1 TO nLen_aInd  // Проверка идексов
      ORDSETFOCUS(i)
      nLen_aNNN:=Len(aNNN)
      FOR j:=1 TO nLen_aNNN
        DbGoTo(aNNN[ j ])
        Value := Eval(aB[ i ])//Значение индексного выражения для этой записи
        lValueFor := Eval(aBFor[ i ])//Значение индексного условного ключа
        IF (lValueFor)
          nCntRep := 1
          DO WHILE .T. //nCntRep > 0
            Seek Value; x:= Eval(aB[ i ])
            xFor:= Eval(aBFor[ i ])
            IF (lValueFor # xFor .OR. (xFor .AND. Value != x))// Ошибка
              cWait_Error:= ;
                 "Файл:"+Alias() + " Индекс N "+Str(i, 2)+";"+ ;
                 "индек.выр:"+ OrdKey(i)+";"+       ;
                 "Надо:"+Substr(XTOC(Value), 1, 60)+";"+     ;
                 "Есть:"+Substr(XTOC(x), 1, 60)+";"+         ;
                 "запись:"+Str(aNNN[ j ], 7)+" "+Str(j,1)+";"+              ;
                 "не соотвествует содержимому файла БД."
              IF (lSend)
                WAIT ERROR cWait_Error
                EXIT
              ELSE
                OUTLOG(__FILE__,__LINE__,nCntRep,cWait_Error)

                DbGoTo(aNNN[ j ])
                creci()

                nCntRep--
                IF nCntRep < 0
                  lRet := .F.
                  ERRORLEVEL(2) //проблема индекса
                  EXIT
                ENDIF
                LOOP
                /*              MESSAGE(08, 02, , ,;
                  { "Файл "+Alias(), "Индекс N "+Str(i, 2),           ;
                    "индексное выражение :", OrdKey(i),                                                 ;
                           "Надо "+Substr(XTOC(Value), 1, 60), ;
                           "Есть "+Substr(XTOC(x), 1, 60),         ;
                           "запись "+Str(aNNN[ j ], 7),                                 ;
                           "не соотвествует содержимому файла БД."                        ;
                         }                                                                ;
                 )*/
              ENDIF           // Send
              // Err
            ELSE
              IF nCntRep # 1
                OUTLOG(__FILE__,__LINE__,nCntRep,"cWait_Error OK!")
              ENDIF
              lRet := .T.
              //ERRORLEVEL(0) // нет проблема индекса
              EXIT
            ENDIF
          ENDDO


        ENDIF

      NEXT j

    NEXT i

    SET(_SET_DELETED,lSetDel)
  ELSE
    lRet := .t.
    RETURN lRet
  ENDIF                     // Used

  ORDSETFOCUS(nOrd); Go nRec
  RETURN (lRet)

/*****************************************************************
 
 FUNCTION: MYTONE
 АВТОР..ДАТА..........С. Литовка  26.03.00 * 20:29:28
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION MYTONE(nHz, nLong)
    IF GETENV("OS_RUN")="UNIX"
        ??CHR(7)
    ELSE
      TONE(nHz, nLong)
      //SOUND(nHz, nLong,.T.)
      //TSOUND(nHz, nLong)
  ENDIF
  RETURN (NIL)

func put_rec(p1,p2,p3,p4,p5)
****************************
  * p1 имя массива default arec
  * p2 кроме полей
  * p3 1- без commit
  * p4 - подменить поле
  * p5 - значение для подмены поле
  * кроме полей
  local i,vf,mass, nPosFld, nLen, aMass, aVar, aaa
  if empty(p1)
     mass='arec'
  else
     mass=p1
  endif
  aMass:=&mass

  aVar:={}
  if !empty(p2)
     aaa=''
     for i:=1 to len(p2)
         if subs(p2,i,1)=','
            aadd(aVar,aaa)
            aaa=''
            loop
         endif
         aaa=aaa+upper(subs(p2,i,1))
     endf
     aadd(aVar,aaa)
  endif

  nLen:=len(aMass)
  nLen:=MIN(FCOUNT(), nLen)

  for i:=1 to nLen
      if ascan(avar,FIELDname(i))#0
         loop
      endif
  //    #ifdef __CLIP__
  //       vf=&mass[i]
  //    #else
         if !empty(p4).and.!empty(p5)
            if upper(p4)=FIELDname(i)
               vf:=p5
            else
               // 1vf=&mass[i]
               vf:=aMass[i]
            endif
         else
            // 1vf=&mass[i]
            vf:=aMass[i]
         endif
  //    #endif
      if vf=nil
         exit
      endif
      nPosFld:=i
      IF FIELDGET(nPosFld) # NIL .AND. !(FIELDGET(nPosFld) == vf)
        /*
  *       #ifdef __CLIP__
  *           if alias()=='TOVM'
  *              do case
  *                 case field(i)='MNTOV'
  *                      outlog(__FILE__,__LINE__,date(),time(),PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),tovm->mntov,field(i),vf,"INDX")
  *                 case field(i)=='SKL'
  *                      outlog(__FILE__,__LINE__,date(),time(),PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),tovm->skl,field(i),vf,"INDX")
  *                 case field(i)=='NAT'
  *                      outlog(__FILE__,__LINE__,date(),time(),PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),tovm->nat,field(i),vf,"INDX")
  *              endcase
  *           endif
  *           if alias()=='RS1'.and.field(i)=='TTN'
  *              outlog(__FILE__,__LINE__,date(),time(),PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),rs1->ttn,field(i),vf,"INDX")
  *           endif
  *       #endif
  *
  *       fieldput(i,vf)
         */
         if fieldtype(i)='N'.and.fielddeci(i)=0
            mzzr=fieldget(i)
            if roun(mzzr,0)#roun(vf,0)
               #ifdef __CLIP__
                if alias()=='TOVM'.and.(field(i)=='mntov'.or.field(i)=='skl').or.alias()=='RS1'.and.field(i)=='ttn'
                   if select('tovpt')#0.and..f.
                      tovpt->(DBAPPEND())
                      tovpt->Kto:=gnKto
                      tovpt->DataUse:=alias()+"-P"
                      tovpt->Param:=PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5)+";"+pathr+";"+str(gnSk,3)
                      tovpt->Dt:=DATE()
                      tovpt->TM:=TIME()
                      tovpt->SCNDS:=SECONDS()
                      tovpt->RCN:=RECNO()
                      tovpt->Prog:=STR(nPosFld,3)
                      tovpt->FldNm:=FIELDNAME(nPosFld)
                      DO CASE
                         CASE FIELDTYPE(nPosFld)="N"
                              tovpt->Pre_Num:=FIELDGET(nPosFld)
                         CASE FIELDTYPE(nPosFld)="D"
                              tovpt->Pre_Dt:=FIELDGET(nPosFld)
                         CASE FIELDTYPE(nPosFld)="C"
                              tovpt->Pre_Char:=FIELDGET(nPosFld)
                      endcase
                   endif
                ENDIF
               #endif

               IF fieldsize(i) # LEN(STR(vf))
                  outlog(__FILE__,__LINE__,"gcPath_a",gcPath_a)
                  outlog(__FILE__,__LINE__,"prs2",prs2->(DBSTRUCT()))
                  outlog(__FILE__,__LINE__,"rs2",rs2->(DBSTRUCT()))
                  outlog(__FILE__,__LINE__,' i ALIAS()',ALIAS(),i, CompArray(prs2->(DBSTRUCT()), rs2->(DBSTRUCT())),aMass)
                  outlog(__FILE__,__LINE__,'fieldName(i)',fieldName(i))
                  outlog(__FILE__,__LINE__,'fieldsize(i)  LEN(STR(vf))',fieldsize(i), LEN(STR(vf)))
               ENDIF
               fieldput(i,vf)

               #ifdef __CLIP__
  *              if alias()=='TOVM'.and.(field(i)=='mntov'.or.field(i)=='skl').or.alias()=='RS1'.and.field(i)=='ttn'
  *               outlog(__FILE__,__LINE__,date(),time(),PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2)+";"+STR(PROCLINE(1),5),mzzr,field(i),ff,"INDX PUTREC")
  *              endif

                if alias()=='TOVM'.and.(field(i)=='mntov'.or.field(i)=='skl').or.alias()=='RS1'.and.field(i)=='ttn'
                   if select('tovpt')#0.and..f.
                      DO CASE
                         CASE FIELDTYPE(nPosFld)="N"
                              tovpt->Post_Num:=FIELDGET(nPosFld)
                         CASE FIELDTYPE(nPosFld)="D"
                              tovpt->Post_Dt:=FIELDGET(nPosFld)
                         CASE FIELDTYPE(nPosFld)="C"
                              tovpt->Post_Char:=FIELDGET(nPosFld)
                      endcase
                   endif
                ENDIF
               #endif
            endif
         else
            fieldput(i,vf)
         endif

         #ifdef __CLIP__
            if empty(p3)
               dbcommit()
            endif
         #endif

      ENDIF
  next
  #ifdef __CLIP__
    if empty(p3)
       dbcommit()
    endif
  #endif
        #ifdef __CLIP__
           IF alias()=='RS1'
              if rs1->ttn=60.and.!empty(rs1->dvp)
                 outlog(__FILE__,__LINE__,date(),time(),PROCNAME(0)+";"+PROCNAME(1)+";"+PROCNAME(2),"TTN=60","putrec")
              endif
           ENDIF
        #endif
  retu .t.

/***************************************************************/
FUNCTION NetKeySeek            // Вычисление ключевого выражение по индексу
   /************************************************************** */
   para tgr, indr, al, plast

   /* tgr  - имя тэга
    * indr - переменные для индексного выражения
    * al   - алиас
    * plast - количество символов последней переменной
    */

   PRIVATE ar, k, br, indr1, alr, al_r, tt, j, jj, l, ll, ii, ntgr, ind_r, cntr, buffr, oldind

   oldind=indexord()

   al_r=alias()

   IF (!empty(al))
      alr=al
   ELSE
      alr=lower(alias())
   ENDIF

   ntgr=val(subs(tgr, 2))
   sele (alr)
   set orde TO tag (tgr)
   //indr1=lower(indexkey(indexord(tgr)))
   indr1:=charrem(' ',lowe(indexkey(indexord(tgr))))


   IF  empty(indr1)
      wmess('Тэг '+tgr+' пустой для алиаса '+ALLTRIM(alr),2)
      quit
      RETURN (.f.)
   ENDIF

   n=1
   store 0 TO zn2r             // Признаки скобок (1 - открыта)
   FOR ii=1 TO len(indr)     // Определение переменных для индексного выражения
      DO CASE
      CASE (subs(indr, ii, 1)='(')
         zn2r=zn2r+1
      CASE (subs(indr, ii, 1)=')')
         zn2r=zn2r-1
      CASE (subs(indr, ii, 1)=','.and.zn2r=0)
         n=n+1
      ENDCASE

   NEXT

   k=1
   FOR ii=1 TO len(indr1)    // Определение к-ва элементов Тэга
      IF (subs(indr1, ii, 1)='+')
         k=k+1
      ENDIF

   NEXT

   IF (k>n)
      k=n
   ENDIF

   ll=0
   FOR ii=1 TO len(indr1)
      IF (subs(indr1, ii, 1)='+')
         ll=ll+1
         IF (ll=k)
            EXIT
         ENDIF

      ENDIF

   NEXT

   indr1=subs(indr1, 1, ii)

   jj=1
   ll=1
   atag1:={}
   atag2:={}
   atag3:={}
   FOR ii=1 TO k               // разделение индексного выражения и строки переменных на составляющие
      ar=''
      br=''
      FOR j=jj TO len(indr1)
         IF (subs(indr1, j, 1)='+')
            jj=j+1
            EXIT
         ENDIF

         ar=ar+subs(indr1, j, 1)
      NEXT

      aadd(atag1, ar)        // элемент индексного выражения
      aadd(atag3, ar)
      IF (ii=k.and.right(atag1[ ii ], 1)='+')
         atag1[ ii ]=subs(atag1[ ii ], 1, len(atag1[ ii ])-1)
      ENDIF

      store 0 TO zn2r          // Признаки скобок (1 - открыта)
      FOR l=ll TO len(indr)
         DO CASE
         CASE (subs(indr, l, 1)='(')
            zn2r=zn2r+1
         CASE (subs(indr, l, 1)=')')
            zn2r=zn2r-1
         CASE (subs(indr, l, 1)=','.and.zn2r=0)
            ll=l+1
            EXIT
         ENDCASE

         br=br+subs(indr, l, 1)
      NEXT

      aadd(atag2, br)        // элемент строки переменнных
   NEXT

   FOR ii=1 TO k
      DO CASE
      CASE (at('str(', atag1[ ii ])#0)
         atag3[ ii ]=stuff(atag1[ ii ], 1, 4, "")
         atag3[ ii ]=subs(atag3[ ii ], 1, len(atag3[ ii ])-1)
         cntr=0                // счетчик запятых
         buffr=''
         FOR j=len(atag3[ ii ]) TO 1 STEP -1
            DO CASE
            CASE (isdigit(subs(atag3[ ii ], j, 1)))
               IF (empty(buffr))
                  buffr=atag3[ ii ]
               ENDIF

               atag3[ ii ]=subs(atag3[ ii ], 1, j-1)
            CASE (subs(atag3[ ii ], j, 1)=',')
               atag3[ ii ]=subs(atag3[ ii ], 1, j-1)
               cntr=cntr+1
               buffr=''
               IF (cntr=2)
                  EXIT
               ENDIF

            OTHERWISE
               EXIT
            ENDCASE

         NEXT

         IF (cntr<2.and.!empty(buffr))
            atag3[ ii ]=buffr
         ENDIF

      CASE (at('dtoc(', atag1[ ii ])#0 .or. at('dtos(', atag1[ ii ])#0)
         atag3[ ii ]=stuff(atag1[ ii ], 1, 5, "")
         atag3[ ii ]=subs(atag3[ ii ], 1, len(atag3[ ii ])-1)
      ENDCASE

      IF (ii=k.and.!empty(plast))
         atag1[ ii ]='subs('+atag1[ ii ]+',1,'+plast+')'
      ENDIF

      /*if at(atag3[ii],atag1[ii],2)=0
       *    atag1[ii]=strt(atag1[ii],atag3[ii],atag2[ii],1,1)
       *  else
       *      atag1[ii]=strt(atag1[ii],atag3[ii],atag2[ii],2,1)
       *    endif
       */
      atag1[ ii ]=strtran(atag1[ ii ], atag3[ ii ], atag2[ ii ], 1, 1)
   NEXT

   ind_r=''
   FOR ii=1 TO k
      ind_r=ind_r+atag1[ ii ]
      IF (ii#k)
         ind_r=ind_r+'+'
      ENDIF

   NEXT

   ind_r=alltrim(ind_r)
   sele (alr)
   cSeekKey:=(&ind_r)
   IF (!empty(al_r))
      sele (al_r)
      set order TO oldind
   ENDIF

   RETURN (cSeekKey)
