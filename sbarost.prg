#include "common.ch"
#include "inkey.ch"
//* Субаренда остатки
PARA p1, cPthCopy
LOCAL nMax, nCurent

  IF ISBLOCK(p1)
    bFor1:=p1
  ELSE
    if !empty(p1)
       mkeep_r=p1
    else
       return
    endif
    /*
    bFor1:={|| mkeep_r  = ;
    (mkeepr:=getfield('t1','mntovr','ctov','mkeep'),;
    IIF(mkeepr = 0,mkeepr:=getfield('t2','izgr','mkeepe','mkeep'),mkeepr));
    }
    */

    bFor1:={|| ;
         mkeep_r  = getfield('t1','mntovr','ctov','mkeep') ;
    .OR. mkeep_r = getfield('t2','izgr','mkeepe','mkeep') ;
    }

  ENDIF

  netuse('tmesto'); netuse('etm')
  netuse('knasp')
     netuse('cskl');   set index to
     netuse('arvid')
     netuse('mkeep')
     netuse('mkeepe')
     netuse('kln')
     netuse('ctov')
     netuse('mkeepg')
     netuse('knasp')
     netuse('kobl')
     netuse('krn')
     netuse('cgrp')
     netuse('brand')
     netuse('mkcros')
     netuse('klnnac')
     netuse('tcen')
     netuse('krntm')
     netuse('rntm')
     netuse('nasptm')
     netuse('kgptm')
     netuse('kgp')
     netuse('posBrk')
     netuse('posBrn')
  netuse('s_tag')

  filedelete('SbArOst'+".*")

  //crea table SbArOst (sk n(3),arnd n(2),nskl c(20),kg n(3),ng c(20),mntov n(7),ktl n(9),kpl n(7),npl c(40),kgp n(7),ngp c(40),nkgpcat c(10),nobl c(20),nrn c(20),nnasp c(20),adrgp c(40),osf n(10,2),opt n(12,3),nat c(60),kta n(4),nkta c(20),post n(7),zn c(40),inp c(40),arvid n(3),narvid c(20),arprim c(40),arsk n(3),arttn n(6),ardt d,arnpp n(4),dpp d,armn n(6),mkeep n(3),nmkeep c(20),sm1 n(10,2),sm2 n(10,2),sm3 n(10,2), dizg d,posid n(10),posbrn n(10),armod c(20),izg n(7),nizg c(40))
    crtt('SbArOst',;
    'f:sk c:n(3) f:arnd c:n(2) f:nskl c:c(20) f:kg c:n(3) f:ng c:c(20)';
  +' f:mntov c:n(7) f:ktl c:n(9) f:okpo c:n(10) f:apl c:c(40)';
  +' f:kpl c:n(7) f:npl c:c(40) f:kgp c:n(7) f:ngp c:c(40) f:agp c:c(40)';
  +' f:skl c:n(7) f:nkgpcat c:c(10)';
  +' f:nobl c:c(20) f:nrn c:c(20) f:nnasp c:c(20) f:adrgp c:c(40)';
  +' f:osf c:n(10,2) f:opt c:n(12,3)';
  +' f:nat c:c(60) f:kta c:n(4) f:nkta c:c(20) f:post c:n(7) f:zn c:c(40)';
  +' f:inp c:c(40) f:arvid c:n(3) f:narvid c:c(20) f:arprim c:c(40)';
  +' f:arsk c:n(3) f:arttn c:n(6) f:ardt c:d(10) f:arnpp c:n(4) f:dpp c:d(10)';
  +' f:armn c:n(6) f:mkeep c:n(3) f:nmkeep c:c(20) f:sm1 c:n(10,2)';
  +' f:sm2 c:n(10,2) f:sm3 c:n(10,2) f:dizg c:d(10) f:posid c:n(10)';
  +' f:posbrn c:n(10) f:nposbrn c:c(20) f:armod c:c(20) f:izg c:n(7) ';
  +' f:nizg c:c(40) f:lising c:n(4) f:d_izg c:d(10) f:d_expl c:d(10) ';
  +' f:d_fpr c:d(10) f:k_vls c:c(40) ';
  +' f:posmanuf c:c(7) f:posreq c:c(5) f:postehco c:c(5) f:postpid c:c(7)';
  +' f:comment c:c(254)';
  )

  //crtt('SbArOst','f:sk c:n(3) f:kgp c:n(7) f:kpl c:n(7) f:okpo c:n(10) f:apl c:c(40) f:ngp c:c(40) f:npl c:c(40) f:agp c:c(40) f:skl c:n(7) f:arnd c:n(1) f:ktl c:n(9) f:nat c:c(60) f:ardt c:d(10)')

  sele 0
  use SbArOst Exclusive


  IF gnScOut = 0
    // вычисление мах значения
    nMax:=0
    sele cskl
    go top
    do while !eof()
       if !(ent=gnEnt.and.arnd#0)
          skip
          loop
       endif
       dirtr=alltrim(path)
       pathr=gcPath_d+dirtr
       if !netfile('tov',1)
          loop
       endif
       skr=sk
       arndr=arnd // 3-sbar,2-ar
       netuse('tov',,,1)
       nMax += LASTREC()
       nuse('tov')
       sele cskl
       skip
    enddo
  ENDIF

  //  init trermo
  IIF(gnScOut = 0, Termo((nCurent:=0),nMax,MaxRow(),4),)

  sele cskl
  go top
  do while !eof()
     if !(ent=gnEnt.and.arnd#0)
        skip
        loop
     endif
     dirtr=alltrim(path)
     pathr=gcPath_d+dirtr
     if !netfile('tov',1)
        loop
     endif
     skr=sk
     arndr=arnd // 3-sbar,2-ar
     NSklr=allt(NSkl)
     netuse('tov',,,1)
     do while !eof()
       IIF(gnScOut = 0, Termo(nCurent++,nMax,MaxRow(),4),)
       mntovr=mntov
       izgr=izg


      if (osf=0)
        sele tov;            skip;            loop
      endif
      IF (!EVAL(bFor1))
          sele tov;  skip;  loop
       ENDIF

        kgpr=0; kplr=0
        sklr=skl
        do case
        case arndr=3 // Субаренда
          tmestor=skl
          sele etm
          if !netseek('t1','tmestor')
            sele tmesto
            netseek('t1','tmestor')
          endif
          kgpr=kgp; kplr=kpl

        case arndr=2  // аренда
          do case
          case skr=301
            kgpr=22014
          case skr=401
            kgpr=22044
          case skr=501
            kgpr=22013
          OtherWise
            kgpr=gnKkl_c
          endcase
          kplr=kgpr
        endcase

        sele tov
          postr=post
          osfr=osf //  остатк
          optr=opt //  цена учета
          natr=nat //  название
          kg_r=kg  //  код группы
          izgr=izg
          ktar0=krstat
          dppr=dpp
          ktlr=ktl

          ktar0=krstat
          ng_r=getfield('t1','kg_r','cgrp','ngr')
          nktar=getfield('t1','ktar0','s_tag','fio')
          nizgr=getfield('t1','izgr','kln','nkl')

          //getfield('t1','mntovr','ctov','postehco')

          mkeepr=getfield('t1','mntovr','ctov','mkeep')
          if mkeepr=0
             mkeepr=getfield('t2','izgr','mkeepe','mkeep')
          endif
          nmkeepr=getfield('t1','mkeepr','mkeep','nmkeep')


        //завод номер
        znr=getfield('t1','mntovr','ctov','zn')
        //инентарный номер
        inpr=getfield('t1','mntovr','ctov','znom')
        dizgr=getfield('t1','mntovr','ctov','dizg')

        arvidr=getfield('t1','mntovr','ctov','arvid')
        arprimr=getfield('t1','mntovr','ctov','arprim')
        arnppr=getfield('t1','mntovr','ctov','arnpp')
        armodr=getfield('t1','mntovr','ctov','armod')

        lisingr:=getfield('t1','mntovr','ctov','lising')
        d_izgr :=getfield('t1','mntovr','ctov','d_izg')
        d_explr:=getfield('t1','mntovr','ctov','d_expl')
        d_fprr :=getfield('t1','mntovr','ctov','d_fpr')
        k_vlsr :=getfield('t1','mntovr','ctov','k_vls')


        posidr=getfield('t1','mntovr','ctov','posid')
        posbrnr=getfield('t1','mntovr','ctov','posbrn')
        postehcor =getfield('t1','mntovr','ctov','postehco')

        posmanufr =getfield('t1','mntovr','ctov','posmanuf')
        posreqr   =getfield('t1','mntovr','ctov','posreq')
        postpidr  =getfield('t1','mntovr','ctov','postpid')
        commentr  =getfield('t1','mntovr','ctov','comment')

        narvidr=getfield('t1','arvidr','arvid','narvid')
        nposBrnr=getfield('t1','posBrnr','posBrn','nposBrn')


        sele kln
        netseek('t1','kplr')
          nplr=kln->nkl
          aplr=kln->adr
          okpor=kln->kkl1
        sele kln
        netseek('t1','kgpr')
          ngpr=kln->nkl
          agpr=kln->adr
            knaspr=kln->knasp
          nnaspr=getfield('t1','knaspr','knasp','nnasp')
            krnr=getfield('t1','knaspr','knasp','krn')
          nrnr=getfield('t1','krnr','krn','nrn')
            koblr=getfield('t1','krnr','krn','kobl')
          noblr=getfield('t1','koblr','kobl','nobl')

        sele SbArOst
        appe blank
        repl ;
        comment with commentr,;
        posid  with posidr,  posbrn with  posbrnr,;
        posmanuf with posmanufr, posreq  with  posreqr ,;
        postehco with  postehcor,  postpid  with  postpidr ,;
        nposbrn with nposbrnr,;
        dpp with dppr,;
        osf with osfr, okpo with okpor,;
        opt with optr, npl with nplr,;
        nat with natr, apl with aplr,;
        kg with kg_r, ng with ng_r,;
        ngp with ngpr, agp with agpr,;
        nnasp with nnaspr, nrn with nrnr, nobl with noblr,;
        skl with sklr, NSkl with NSklr, ;
        arnd with arndr, kgp with kgpr,;
        mntov with mntovr,;
        ktl with ktlr,   kpl with kplr,;
        sk with skr,     kta with ktar0,;
        nkta with nktar,     inp with inpr,;
        arvid with arvidr, narvid with narvidr,;
        arprim with arprimr, arnpp with arnppr, armod with armodr,;
        mkeep with mkeepr,   dizg with dizgr,;
        nmkeep with nmkeepr, izg with izgr,;
        zn with znr,         nizg with nizgr,;
        lising with lisingr,;
        d_izg with  d_izgr,;
        d_expl with d_explr,;
        d_fpr  with d_fprr,;
        k_vls  with k_vlsr


        sele tov
        skip
     enddo
     nuse('tov')
     sele cskl
     skip
  enddo
  IF(gnScOut = 0, Termo(nMax,nMax,MaxRow(),4),)

  sele SbArOst
  go top
  Do While !eof()
    If empty(comment) .or. val(allt(posTehCo)) = 8
      sele SbArOst
      DBSkip()
    EndIf


    commentr:=''
    // параметры
    cSep:=','
    cStr:=ALLT(comment)
    cStr:=CHARREPL('.',cStr,cSep)

    nCnt:=NUMTOKEN(cStr,cSep)
    For i:=1 To nCnt
      If i>1 .and. !empty(Right(allt(commentr),1))
        commentr += '; '
      EndIf
      cStrTok:=token(cStr,cSep,i,1)

      cStrTok:=val(allt(cStrTok))
      // поиск и расшифровка
      sele posbrk
      locate for BreakId = cStrTok
      // накопление
      commentr += allt(NBreak)

    Next

    sele SbArOst
    repl comment with commentr


    sele SbArOst
    DBSkip()
  EndDo


  IF !ISBLOCK(p1)
    sele SbArOst
    index on str(sk) to t1
    // DBGOBOTTOM()
    // DBSKIP()
    nMax:=LASTREC()
    IIF(gnScOut = 0, Termo((nCurent:=0),nMax,MaxRow(),4),)
    do while !eof()
      IIF(gnScOut = 0, Termo(nCurent++,nMax,MaxRow(),4),)
      nRec:=RECNO()
      skr=sk
      ardirr=alltrim(getfield('t1','skr','cskl','path'))

      IIF(gnScOut = 0, (devpos(23, 15), devout(ardirr)),)

      for yyr=year(date()) to 2006 step -1
        IIF(gnScOut = 0, (devpos(23, 0), devout(yyr)),)
           pathgr=gcPath_e+'g'+str(yyr,4)+'\'
           for mmr=12 to 1 step -1
             IIF(gnScOut = 0, (devpos(23, 10), devout(mmr)),)
              pathr=pathgr+'m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'+ardirr

              if !netfile('pr1','1')
                 loop
              endif

              netuse('pr1',,,1)
              netuse('pr2',,,1)

              sele SbArOst
              DBGOTO(nRec) //первая запись склада
              DO WHILE skr = sk
                IF !EMPTY(ardt)
                   DBSKIP(); LOOP
                ENDIF

                ktlr=ktl
                sklr=skl

                sele pr2
                set orde to tag t2
                if netseek('t2','ktlr')
                  do while ktl=ktlr
                      mnr=mn
                      if mnr#0
                        sele pr1
                        if netseek('t2','mnr')
                            if prz=1.and.skl=sklr
                              arSkr=sks
                              arTtnr=amn
                              arDtr=dpr
                              sele SbArOst
                              repl arSk with arSkr,;
                                   ardt with ardtr,;
                                   arTtn with arTtnr
                              exit
                            endif
                        endif
                      endif
                      sele pr2
                      skip
                  enddo
                endif

              sele SbArOst; dbskip()
              ENDDO
              nuse('pr1')
              nuse('pr2')
           next
       next
       sele SbArOst
       //skip
    enddo
    IIF(gnScOut = 0, Termo(nMax,nMax,MaxRow(),4),)
  ENDIF

  if gnEnt=21
    crtt('LodArSb', 'f:npp c:n(4) f:npost c:c(100) f:vtro c:c(10) f:dcid c:n(5) f:dt c:d(10) f:zn c:c(30) f:in c:c(20) f:cen c:n(10,3) f:ntro c:c(60) f:nobl c:c(20) f:nrn c:c(20) f:nnasp c:c(20) f:adr c:c(40) f:nsbarnd c:c(40) f:ndog c:n(6) f:trors c:c(3) f:tronrs c:c(3) f:dizg c:d(10) f:post c:n(7)')
    sele 0
    use LodArSb Exclusive

     nppr=1
     dcidr=18005
     sele SbArOst
     DBGoTop()
     Do While !eof()
          dtr=ardt
          znr=zn
          inr=inp
          cenr=opt
          ntror=nat
          noblr=nobl
          nrnr=nrn
          nnaspr=nnasp
          adrr=adrgp
          dizgr=dizg
          postr=post
          npostr=getfield('t1','postr','kln','nkl')
          do case
          case sk=243
              nsbarndr='Склад Сумы'
          case sk=701
              nsbarndr='Склад Конотоп'
          othe
              nsbarndr=npl
          endcase
          ndogr=arttn
          sele LodArSb
          appe blank
          repl npp with nppr,;
               dcid with dcidr,;
               dt with dtr,;
               zn with znr,;
               in with inr,;
               cen with cenr,;
               ntro with ntror,;
               nobl with noblr,;
               nrn with nrnr,;
               nnasp with nnaspr,;
               adr with adrr,;
               nsbarnd with nsbarndr,;
               ndog with ndogr,;
               dizg with dizgr,;
               post with postr,;
               npost with npostr
        nppr=nppr+1
       sele SbArOst
       DBSkip()
     enddo
     sele LodArSb
     use
    If !empty(cPthCopy)
      filecopy('LodArSb.dbf',cPthCopy+'LodArSb.dbf')
    EndIf
  endif

  sele SbArOst
  //copy to (cPthCopy+'SbArOst')
  use
  If !empty(cPthCopy)
    filecopy('SbArOst.dbf',cPthCopy+'SbArOst.dbf')
  EndIf
  RETURN



******************
func posbrn()
  ******************
  clea
  netuse('posbrn')
  rcposbrnr=recn()
  do while .t.
     sele posbrn
     go rcposbrnr
     foot('INS,DEL,F4','Доб.,Уд.,Корр')
     rcposbrnr=slcf('posbrn',1,1,18,,"e:posbrn h:'Код' c:n(10) e:nposbrn h:'Наименование' c:с(40)",,,1)
     if lastkey()=K_ESC
        exit
     endif
     sele posbrn
     go rcposbrnr
     posbrnr=posbrn
     nposbrnr=nposbrn
     do case
        case lastkey()=K_INS // Добавить
             posbrnins(0)
             sele posbrn
             rcposbrnr=recn()
        case lastkey()=K_F4 // Коррекция
             posbrnins(1)
        case lastkey()=K_DEL // Удалить
             sele posbrn
             netdel()
             skip -1
             if bof()
                go top
                rcposbrnr=recn()
             endif
     endcase
  enddo
  nuse()
  retu .t.

******************
func posbrnins(p1)
  ******************
  if p1=0
     posbrnr=0
     nposbrnr=space(40)
  endif
  scbrinsr=setcolor('gr+/b,n/w')
  wbrinsr=wopen(8,10,11,70)
  wbox(1)
  do while .t.
     @ 0,1 say 'Код бренда  ' get posbrnr pict '9999999999'
     @ 1,1 say 'Наименование'  get nposbrnr
     read
     if lastkey()=K_ESC
        exit
     endif
     sele posbrn
     if p1=0
        if !netseek('t1','posbrnr')
           netadd()
           netrepl('posbrn,nposbrn','posbrnr,nposbrnr')
           rcposbrnr=recn()
        endif
     else
        netrepl('posbrn,nposbrn','posbrnr,nposbrnr')
     endif
     exit
  enddo
  wclose(wbrinsr)
  setcolor(scbrinsr)
  retu .t.

******************
func posid()
  ******************
  clea
  netuse('posid')
  rcposidr=recn()
  do while .t.
     sele posid
     go rcposidr
     foot('INS,DEL,F4','Доб.,Уд.,Корр')
     rcposidr=slcf('posid',1,1,18,,"e:posid h:'Код' c:n(10) e:nposid h:'Наименование' c:с(40)",,,1)
     if lastkey()=K_ESC
        exit
     endif
     sele posid
     go rcposidr
     posidr=posid
     nposidr=nposid
     do case
        case lastkey()=K_INS // Добавить
             posidins(0)
             sele posid
             rcposidr=recn()
        case lastkey()=K_F4 // Коррекция
             posidins(1)
        case lastkey()=K_DEL  // Удалить
             sele posid
             netdel()
             skip -1
             if bof()
                go top
                rcposidr=recn()
             endif
     endcase
  enddo
  nuse()
  retu .t.

******************
func posidins(p1)
  ******************
  if p1=0
     posidr=0
     nposidr=space(40)
  endif
  scbrinsr=setcolor('gr+/b,n/w')
  wbrinsr=wopen(8,10,11,70)
  wbox(1)
  do while .t.
     @ 0,1 say 'POS ID      ' get posidr pict '9999999999'
     @ 1,1 say 'Наименование'  get nposidr
     read
     if lastkey()=K_ESC
        exit
     endif
     sele posid
     if p1=0
        if !netseek('t1','posidr')
           netadd()
           netrepl('posid,nposid','posidr,nposidr')
           rcposidr=recn()
        endif
     else
        netrepl('posid,nposid','posidr,nposidr')
     endif
     exit
  enddo
  wclose(wbrinsr)
  setcolor(scbrinsr)
  retu .t.
