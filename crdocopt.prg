/***********************************************************
 * Модуль    : crdocopt.prg
 * Версия    : 0.0
 * Автор     :
 * Дата      : 04/04/19
 * Изменен   :
 * Примечание: Текст обработан утилитой CF версии 2.02
 */

#include "common.ch"
#include "inkey.ch"

/***********************************************************
 * RunCDocOpt() -->
 *   Параметры :
 *   Возвращает:
 */
function RunCDocOpt(p1, p2)
  // p1 - d0k1
  // p2 - (ttn,mn)
  // Комиссия не пересчитывается
  if (!empty(p2))
    d0k1_rr=p1
    doc_rr=p2
  else
    d0k1_rr=9
    doc_rr=999999
  endif

  prvzznr=0

  erase lldokk.dbf
  if (select('dokk')#0)
    sele dokk
    copy stru to cldokk
  endif

  scoutr=gnScout
  if (gnScout=0)
    set prin to crdoc.txt
    set prin on
  endif

  store 0 to d0k1r, kopr, qr, ndsr, pndsr, xndsr, grtcenr, tcenr, ptcenr, xtcenr, nofr, ;
   skar, sklar, msklar, zcr, prnnr, ttor, vpr, autor, okklr, okplr, pbzenr,             ;
   pxzenr, rtcenr, s361r, kpsbbr, prvzznr
  store '' to cuchr, cotpr, cdopr
  vur=1
  vor=0
  store space(40) to NOPr
  store '' to nvur, nvor, nopr, nndsr, npndsr, ntcenr, nptcenr, nsklar, ;
   nokklr, nrtcenr, nttor, nnzr
  store '' to coptr, cboptr, croptr
  store 0 to optr, boptr, roptr, przr

  nnzr:='Чек  '
  if (gnScOut=0)
    if (d0k1_rr=9)
      clea
    endif

  endif

  sklr:=gnSkl
  skr=gnSk
  gcDir_t=alltrim(getfield('t1', 'skr', 'cskl', 'path'))
  rmskr=gnRmsk
  if (d0k1_rr=9)
    ?'Приход'
  endif

  // #ifdef __CLIP__
  // #else
  //   if select('ldoc3')#0
  //      sele ldoc3
  //      use
  //   endif
  //   erase ldoc3.dbf
  //   erase ldoc3.cdx
  //   sele pr3
  //   copy stru to ldoc3
  //   sele 0
  //   use ldoc3 excl
  //   inde on str(mn,6)+str(ksz,2) tag t1
  // #endif
  prCorr=1
  kop_r=999
  kkl_r=9999999
  rmsk_r=99
  if (d0k1_rr=9)
    if (gnScOut=0)
      clkopr=setcolor('gr+/b,n/bg')
      wkopr=wopen(10, 20, 15, 50)
      wbox(1)
      @ 0, 1 say 'Код операции' get kop_r pict '999'
      @ 1, 1 say 'Поставщик   ' get kkl_r pict '9999999'
      @ 2, 1 say '0-Сумы;3-Р;4-К;5-Ш,99-Все'
      @ 3, 1 say 'Удаленные   ' get rmsk_r pict '99'
      read
      if (lastkey()=K_ESC)
        kop_r=0
        kkl_r=0
        rmsk_r=0
      endif

      wclose(wkopr)
      setcolor(clkopr)
    endif

  endif

  if (kop_r=999)
    uslpr1r:='.t.'
  else
    if (kop_r#0)
      uslpr1r:='.t..and.kop=kop_r'
    else
      uslpr1r:='.t..and..f.'
    endif

  endif

  if (kkl_r#9999999)
    uslpr1r:=uslpr1r+'.and.kps=kkl_r'
  endif

  if (rmsk_r=99)
  else
    if (rmsk_r<10)
      uslpr1r:=uslpr1r+'.and.rmsk=rmsk_r'
    endif

  endif

  if (d0k1_rr=1)
    if (doc_rr#999999)
      uslpr1r:=uslpr1r+'.and.mn=doc_rr'
    endif

  endif

  gnD0k1=1
  if (select('pr1')#0)
    sele pr1
    set orde to tag t2
    if (d0k1_rr=9)
      go top
    else
      if (d0k1_rr=1)
        netseek('t2', 'doc_rr')
        if (!foun())
          go bott
          uslpr1r:=uslpr1r+'.and..f.'
        endif

      else
        go bott
        uslpr1r:=uslpr1r+'.and..f.'
      endif

    endif

    bUslpr1r:=&('{||'+Uslpr1r +'}')
    while (!eof())
      if (.not. EVAL(bUslpr1r))//!&uslpr1r
        sele pr1
        skip
        loop
      endif

      if (vo=3)
        sele pr1
        skip
        loop
      endif

      prCorr=1
      if (!reclock(1))
        sele pr1
        skip
        loop
      endif

      sec1r=seconds()
      sdv1r=sdv
      sklr=skl
      dvpr=dvp
      kpsr=kps
      mnr=mn
      ndr=nd
      vor=vo
      kopr=kop
      pr1ndsr=getfield('t1', 'kpsr', 'kpl', 'pr1nds')
      if (kopr#110)
        pr1ndsr=0
      endif

      if (kopr=110.and.vor=1.and.(gnEnt=20.or.gnEnt=21))
        prvzznr=1
      else
        prvzznr=0
      endif

      pstr=pst
      if (fieldpos('pt')#0)
        ptr=pt
      else
        ptr=1
      endif

      prz_rr=prz
      rmskr=rmsk
      ktar=kta
      ktasr=ktas
      dtmodr=dtmod
      tmmodr=tmmod
      if (ktasr=0)
        if (ktar#0)
          ktasr=getfield('t1', 'ktar', 's_tag', 'ktas')
          netrepl('ktas', 'ktasr', 1)
        endif

      endif

      SkVzr=SkVz
      ttnvzr=ttnvz
      dtvzr=dtvz
      if (ttnvzr#0.and.!empty(dtvzr).and.prvzznr=0)
        ChkOptVz()
        prCorr=1
      endif

      sele pr1
      nndsvzr=nndsvz
      dnnvzr=dnnvz

      if (ttnvzr#0)
        ttnvz()
        sele pr1
        netrepl('nndsvz,dnnvz', 'nndsvzr,dnnvzr', 1)
      endif

      prxmlr=0
      sele pr2
      if (netseek('t1', 'mnr').and.prvzznr=0)
        while (mn=mnr)
          ktlr=ktl
          mntovr=mntov
          kfr=kf
          zenr:=zen         //цена в докуметне
          optr:=getfield('t1', 'sklr,ktlr', 'tov', 'opt')//цена в справочнике
          if (roun(zenr-optr, 0)#0)
            if (vor=9)
              sele tov
              if (netseek('t1', 'sklr,ktlr'))
                ? str(mnr, 6)+' '+str(prz_rr, 1)+' tov '+str(ktlr, 9)+' '+str(opt, 10, 3)+' -> '+str(zenr, 10, 3)
                netrepl('opt', 'zenr')
              endif

            else
              sele pr2
              ?str(mnr, 6)+' '+str(prz_rr, 1)+' pr2 '+str(ktlr, 9)+' '+str(zenr, 10, 3)+' -> '+str(optr, 10, 3)
              netrepl('zen', 'optr')
            endif

          endif

          sele pr2
          sfr:=sf           //сумма по документу
          sf_r:=ROUND(kfr*optr, 2)//сумма пересчитанная
          if (ROUND(sfr-sf_r, 0)#0)
            sele pr2
            netrepl('sf', 'sf_r')
            prCorr:=1
          endif

          uktr=getfield('t1', 'mntovr', 'ctov', 'ukt')
          if (!empty(uktr))
            if (kopr=108.or.kopr=110)
              prxmlr=1
            endif

          endif

          sele pr2
          skip
        enddo

      endif

      if (prCorr=1)
        store '' to coptr, cboptr, cuchr, cotpr, cdopr, s361r
        store 0 to onofr, opbzenr, opxzenr, ;
         otcenpr, otcenbr, otcenxr,         ;
         odecpr, odecbr, odecxr
        if (!inikop(gnD0k1, 1, vor, kopr))
          ?str(mnr, 6)+' '+str(kopr, 3)+' Ош. inikop'
          sele pr1
          skip
          loop
        endif

        sele soper
        nofr=nof
        tbl1r='pr1'
        tbl2r='pr2'
        tbl3r='pr3'
        mdocr='mnr'
        fdocr='mn'
        if (prvzznr=0)
          fkolr='kf'
        else
          fkolr='kfttn'
        endif

        fprr='prp'
        ssf12r=getfield('t1', 'mnr,12', 'pr3', 'ssf')
        if (ssf12r#0)
          tarar=0
        else
          tarar=1
        endif

        ptr=tarar
        sele pr1
        if (fieldpos('pt')#0)
          netrepl('pt', 'ptr', 1)
        endif

        ksz90r=getfield('t1', 'mnr,90', 'pr3', 'ssf')
        set cons off
        pere(2)
        set cons on
        ksz90_r=getfield('t1', 'mnr,90', 'pr3', 'ssf')
        ?str(mnr, 6)+' '+str(kopr, 3)+' '+str(rmskr, 1)+' '+str(prz_rr, 1)
        set cons off
        gnScout=1
        if (pr1->prz = 1) //подтвержден
          prprv(1)
        else
          prprv(2)
        endif

        gnScout=scoutr
        set cons on
        sele pr1
        if (roun(sdv1r, 2)#roun(sdv, 2))
          ??str(sdv1r, 12, 2)+' '+str(sdv, 12, 2)
        endif

      endif

      sec2r=seconds()
      ??str((sec2r-sec1r), 10, 3)+' '+dtoc(dvpr)
      sele pr1
      netunlock()
      skip
    enddo

  endif

  if (d0k1_rr=9)
    ?'Расход'
  endif

  prvzznr=0
  prCorr=1
  kop_r=999
  kkl_r=9999999
  rmsk_r=99
  if (d0k1_rr=9)
    if (gnScOut=0)
      clkopr=setcolor('gr+/b,n/bg')
      wkopr=wopen(10, 20, 16, 50)
      wbox(1)
      @ 0, 1 say 'Код операции' get kop_r pict '999'
      @ 1, 1 say 'Плательщик  ' get kkl_r pict '9999999'
      @ 2, 1 say '0-Сумы;3-Р;4-К;5-Ш,99-Все'
      @ 3, 1 say 'Удаленные   ' get rmsk_r pict '99'
      @ 4, 1 say 'ТТН         ' get doc_rr pict '999999'
      read
      if (lastkey()=K_ESC)
        kop_r=0
        kkl_r=0
        rmsk_r=0
        doc_rr=0
      endif

      wclose(wkopr)
      setcolor(clkopr)
    endif

  endif

  if (doc_rr=999999)
    if (kop_r=999)
      uslrs1r:='.t.'
    else
      if (kop_r#0)
        uslrs1r:='.t..and.kop=kop_r'
      else
        uslrs1r:='.t..and..f.'
      endif

    endif

    if (kkl_r#9999999)
      uslrs1r:=uslrs1r+'.and.kpl=kkl_r'
    endif

    if (rmsk_r=99)
    else
      if (rmsk_r<10)
        uslrs1r:=uslrs1r+'.and.rmsk=rmsk_r'
      endif

    endif

  else
    uslrs1r='ttn=doc_rr'
  endif

  gnD0k1=0

  sele rs1
  if (d0k1_rr=9.and.doc_rr=999999)
    go top
  else
    if (d0k1_rr=0)
      netseek('t1', 'doc_rr')
      if (!foun())
        go bott
        uslrs1r:=uslrs1r+'.and..f.'
      endif

    else
      if (doc_rr=999999)
        go bott
        uslrs1r:=uslrs1r+'.and..f.'
      else
        netseek('t1', 'doc_rr')
        if (!foun())
          go bott
          uslrs1r:=uslrs1r+'.and..f.'
        endif

      endif

    endif

  endif

  bUslrs1r:=&('{||'+uslrs1r +'}')
  sec1r=seconds()
  while (!eof())
    if (.not. EVAL(bUslrs1r))//&uslrs1r
      // ??' '+'усл. не выпол '+uslrs1r
      sele rs1
      skip
      loop
    endif

    if (vo=3)
      // ??' '+'vo=3'
      sele rs1
      skip
      loop
    endif

    ?rs1->ttn

    if (!reclock(1))
      ??' '+'!reclock(1)'
      sele rs1
      skip
      loop
    endif

    sec1r=seconds()
    prz_rr=prz
    prz_r=prz
    sklr=skl
    ttnr=ttn
    dvpr=dvp
    dopr=dop
    vor=vo
    kopr=kop
    kopir=kopi
    pstr=pst
    ptr=pt
    prCorr=1
    kplr=kpl
    pr1ndsr=getfield('t1', 'kplr', 'kpl', 'pr1nds')
    kpsbbr=getfield('t1', 'kplr', 'kps', 'prbb')
    nkklr=nkkl
    kgpr=kgp
    ktar=kta
    ktasr=ktas
    tmestor=tmesto
    dtmodr=dtmod
    tmmodr=tmmod
    napr=nap
    if (fieldpos('prdec')#0)
      prdecr=prdec
    else
      prdecr=0
    endif

    pr177r=pr177
    pr169r=pr169
    if (fieldpos('mntov177')#0)
      mntov177r=mntov177
      prc177r=prc177
    else
      mntov177r=0
      prc177r=0
    endif

    if (ktasr=0)
      if (ktar#0)
        ktasr=getfield('t1', 'ktar', 's_tag', 'ktas')
        netrepl('ktas', 'ktasr', 1)
      endif

    endif

    sdv1r=sdv
    rmskr=rmsk
    sele rs2
    if (netseek('t1', 'ttnr'))
      s96r=0
      prxmlr=0
      while (ttn=ttnr)
        ktlr=ktl
        mntovr=mntov
        kvpr=kvp
        zenr=zen
        svpr=svp
        svp_r=ROUND(kvpr*zenr, 2)
        optr=ROUND(sr/kvpr, 3)
        opt_r=getfield('t1', 'sklr,ktlr', 'tov', 'opt')
        srr=sr
        sr_r=ROUND(kvpr*opt_r, 2)
        if (ROUND(srr-sr_r, 2)#0)
          ??str(prz_rr, 1)+' '+str(ktlr, 9)+" srr#sr_r ", ALLTRIM(STR(srr)), ALLTRIM(STR(sr_r))
          sele rs2
          netrepl('sr', 'sr_r')
          prCorr=1
        endif

        if (int(ktlr/1000000)>1)
          s96r=s96r+sr
        endif

        if (ROUND(svpr-svp_r, 2)#0)
          ??str(prz_rr, 1)+' '+str(ktlr, 9)+" svpr#svp", ALLTRIM(STR(svpr)), ALLTRIM(STR(svp_r))
          sele rs2
          netrepl('svp', 'svp_r')
          if (prz_r=1)
            netrepl('sf', 'svp_r')
          endif

          prCorr=1
        endif

        if (prz_r=1)
          netrepl('sf', 'svp_r')
        endif

        uktr=getfield('t1', 'mntovr', 'ctov', 'ukt')
        if (!empty(uktr))
          if (kopr=160.or.kopr=161)
            prxmlr=1
          endif

        endif

        sele rs2
        skip
      enddo

      s96_r=getfield('t1', 'ttnr,96', 'rs3', 'ssf')
      if (ROUND(s96r-s96_r, 2)#0)
        ??str(prz_rr, 1)+" s96r#s96_r", ALLTRIM(STR(s96r)), ALLTRIM(STR(s96_r))
        prCorr=1
      endif

    endif

    if (prCorr=1)
      store '' to coptr, cboptr, cuchr, cotpr, cdopr, s361r
      store 0 to onofr, opbzenr, opxzenr, ;
       otcenpr, otcenbr, otcenxr,         ;
       odecpr, odecbr, odecxr
      if (!inikop(gnD0k1, 1, vor, kopr))
        ?str(ttnr, 6)+' '+str(kopr, 3)+' Ош.inikop'
        sele rs1
        skip
        loop
      endif

      tbl1r='rs1'
      tbl2r='rs2'
      tbl3r='rs3'
      mdocr='ttnr'
      fdocr='ttn'
      fkolr='kvp'
      fprr='pr'
      ssf12r=getfield('t1', 'ttnr,12', 'rs3', 'ssf')
      if (ssf12r#0)
        tarar=0
      else
        tarar=1
      endif

      ptr=tarar
      sele rs1
      netrepl('pt', 'ptr', 1)
      ksz90r=getfield('t1', 'ttnr,90', 'rs3', 'ssf')
      sele rs3
      // Проверка на двойники
      if (netseek('t1', 'ttnr'))
        ksz_r=ksz
        skip
        while (ttn=ttnr)
          if (ksz=ksz_r)
            netdel()
            skip
            loop
          endif

          ksz_r=ksz
          skip
        enddo

      endif

      set cons off
      pere(2)
      set cons on
      ksz90_r=getfield('t1', 'ttnr,90', 'rs3', 'ssf')
      sele rs2
      set orde to tag t1
      if (netseek('t1', 'ttnr'))
        s92r=0
        if (FOUND())
          while (ttn=ttnr)
            s92r=s92r+seu
            skip
          enddo

        endif

        sele rs3
        if (netseek('t1', 'ttnr,92'))
          if (s92r#0)
            netrepl('ssf,ssz', 's92r,s92r')
            if (pbzenr=1)
              netrepl('bssf', 's92r')
            endif

          else
            netdel()
          endif

        else
          if (s92r#0)
            netadd()
            netrepl('ttn,ksz,ssz,ssf', 'ttnr,92,s92r,s92r')
            if (pbzenr=1)
              netrepl('bssf', 's92r')
            endif

          endif

        endif

      endif

      ?str(ttnr, 6)+' '+str(kopr, 3)+' '+str(rmskr, 1)+' '+str(prz_rr, 1)
      set cons off
      gnScout=1
      gnScout=scoutr
      set cons on
      sele rs1
      if (roun(sdv1r, 2)#roun(sdv, 2))
        ??str(sdv1r, 12, 2)+' '+str(sdv, 12, 2)
      endif

    endif

    if (rs1->prz=1)       // Подтвержденный
      sele dokko
      if (netseek('t12', '0,0,skr,ttnr,0'))// Был отгружен
        rsprv(2, 1)       // Снять отгрузку
      endif

      sele dokk
      rsprv(1, 0)         // Подтвердить
    else                    // Неподтвержденный
      sele dokk
      if (netseek('t12', '0,0,skr,ttnr,0'))// Был подтвержден
        rsprv(2, 0)       // Снять подтверждение
      endif

      if (!empty(dopr))
        rsprv(1, 1)       // Отгрузить
      else
        rsprv(2, 1)       // Снять отгрузку
      endif

    endif

    sele rs1
    sec2r=seconds()
    ??str((sec2r-sec1r), 10, 3)+' '+dtoc(dvpr)
    netunlock()
    skip
  enddo

  if (gnScOut=0)
    set prin off
    set prin to
  endif

  if (select('lldokk')#0)
    sele lldokk
    CLOSE
  endif

  erase lldokk.dbf
  //#ifdef __CLIP__
  //#else
  //   sele ldoc3
  //   use
  //   erase ldoc3.dbf
  //   erase ldoc3.cdx
  //#endif
  return (nil)

/*************** */
function ChkOptVz()
  /*************** */
  if (!empty(skvzr))
    cPthSkVz:=alltrim(getfield('t1', 'skvzr', 'cskl', 'path'))
  else
    cPthSkVz:=gcDir_t
  endif

  pathr=gcPath_e + pathYYYYMM(dtvzr) + '\' + cPthSkVz

  if (!netfile('rs1', 1))
    return (.t.)
  else
    netuse('rs1', 'rs1vz',, 1)
    if (!netseek('t1', 'ttnvzr'))
      nuse('rs1vz')
      return (.t.)
    else
      netuse('rs2', 'rs2vz',, 1)
      netuse('tov', 'tovvz',, 1)
      sele pr2
      if (netseek('t1', 'mnr'))
        while (mn=mnr)
          ktlr=ktl
          sele rs2vz
          if (netseek('t1', 'ttnvzr,ktlr'))
            ozenr=zen
            zenr=getfield('t1', 'sklr,ktlr', 'tovvz', 'opt')
            if (zenr#0)
              sele pr2
              if (roun(zen, 3)#roun(zenr, 3))
                ?'PR2 '+' '+str(ndr, 6)+' '+str(mnr, 6)+' '+str(ktlr, 9)+' ZEN '+str(zen, 10, 3)+' -> '+str(zenr, 10, 3)
                netrepl('zen,ozen', 'zenr,ozenr')
                sfr=roun(kf*zen, 2)
                netrepl('sf', 'sfr')
              endif

              sele tov
              if (netseek('t1', 'sklr,ktlr'))
                if (roun(opt, 3)#roun(zenr, 3))
                  ?'TOV '+str(ndr, 6)+' '+str(sklr, 6)+' '+str(ktlr, 9)+' OPT '+str(opt, 10, 3)+' -> '+str(zenr, 10, 3)
                  netrepl('opt', 'zenr')
                endif

              endif

            endif

          endif

          sele pr2
          skip
        enddo

      endif

      nuse('tovvz')
      nuse('rs2vz')
    endif

    nuse('rs1vz')
  endif

  return (.t.)
