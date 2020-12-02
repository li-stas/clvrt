/* RmSd1 Передача c удаленного склада */
para p1, p2
kolmodr=p1
if (p2==nil)
  buhskr=0
else
  buhskr=p2
endif

if (gnArm#0)
  clea
endif

crout()

if (gnArm=1.or.gnEntrm=1.and.gnArm#0)
  clsd1=setcolor('w/b,n/w')
  wsd1=wopen(10, 20, 13, 50)
  wbox(1)
  @ 0, 1 say 'Дней модиф' get kolmodr pict '99'
  @ 1, 1 say 'buhskr    ' get buhskr pict '9'
  read
  wclose(wsd1)
  setcolor(clsd1)
  if (lastkey()=27)
    return
  endif

endif

sele 0
use (gcPath_out+rmdirr+'\dmg') shared
netrepl('kolmod,buhsk', 'kolmodr,buhskr')
CLOSE
lcskr=''
rmsda1()
sele 0
use (gcPath_out+rmdirr+'\dmg') shared
netrepl('csk', 'lcskr')
CLOSE
ArcOut()
wmess('Передача окончена', 0)
return (.t.)

/*********************************************************************** */
function rmsda1()
  /*********************************************************************** */
  do case
  case (buhskr=0)
    banksd1a()
    plgpsd1a()
  /*        ndssd1a()
   *        moddocsd1a()
   */
  case (buhskr=1)
    banksd1a()
  /*        ndssd1a()
   *        moddocsd1a()
   */
  case (buhskr=2)
  endcase

  if (buhskr=0.or.buhskr=2)
    netuse('cskl')
    while (!eof())
      if (ent#gnEnt)
        skip
        loop
      endif

      if (rm=0)
        skip
        loop
      endif

      pathr=gcPath_d+alltrim(path)
      if (!netfile('tov', 1))
        skip
        loop
      endif

      sk_r=sk
      lcskr=lcskr+str(sk_r, 3)+','
      nskr=nskl
      if (gnArm#0)
        @ 1, 1 say subs(nskr, 1, 18)
      endif

      skladsd1a(sk_r)
      sele cskl
      skip
    enddo

    nuse('cskl')
  endif

  return (.t.)

/************** */
function banksd1a()
  /************** */
  if (gnArm#0)
    @ 1, 1 say 'BANK'
  endif

  pathoutr=pathmoutr+gcDir_e+gcDir_g+gcDir_d+gcDir_b

  netuse('dokz')
  pathr=pathoutr
  copy stru to (pathr+'dok_z.dbf')
  CLOSE
  netind('dokz', 1)
  netuse('dokz', 'dokzout',, 1)
  set orde to tag t2
  netuse('dokk')
  netuse('dokz')
  set orde to tag t2
  mn_r=0
  go top
  while (.t.)
    if (eof())
      mn_r=0
      exit
    endif

    if (mn=0)
      skip
      loop
    else
      mn_r=mn
      if (netseek('t1', 'mn_r', 'dokk'))
        exit
      endif

    endif

    sele dokz
    skip
  enddo

  nuse('dokk')
  if (mn_r=0)
    nuse('dokz')
    nuse('dokzout')
    return (.t.)
  endif

  netuse('doks')
  pathr=pathoutr
  copy stru to (pathr+'dok_s.dbf')
  CLOSE
  netind('doks', 1)
  netuse('doks', 'doksout',, 1)
  netuse('doks')

  netuse('dokk')
  pathr=pathoutr
  copy stru to (pathr+'dok_k.dbf')
  CLOSE
  netind('dokk', 1)
  netuse('dokk', 'dokkout',, 1)
  netuse('dokk')

  sele dokk
  if (netseek('t1', 'mn_r'))
    while (mn#0)
      if (eof())
        exit
      endif

      if (prc.or.mn=0.or.bs_d=99.or.bs_k=99)
        skip
        loop
      endif

      if (bs_d=0.and.bs_k=0)
        skip
        loop
      endif

      if (rmsk=0)
        if (bs_o=gnRmbs)
          netrepl('rmsk', 'gnRmsk')
        endif

      endif

      if (rmsk#gnRmsk)
        skip
        loop
      endif

      sele dokk
      kklr=kkl
      mnr=mn
      rndr=rnd
      arec:={}
      getrec()
      sele dokkout
      netadd()
      putrec(,, 1)
      netunlock()
      sele doksout
      if (!netseek('t1', 'mnr,rndr,kklr'))
        sele doks
        if (netseek('t1', 'mnr,rndr,kklr'))
          arec:={}
          getrec()
          sele doksout
          netadd()
          putrec(,, 1)
          netunlock()
        endif

      endif

      sele dokzout
      if (!netseek('t2', 'mnr'))
        sele dokz
        if (netseek('t2', 'mnr'))
          arec:={}
          getrec()
          sele dokzout
          netadd()
          putrec(,, 1)
          netunlock()
        endif

      endif

      sele dokk
      skip
    enddo

  endif

  nuse('dokz')
  nuse('doks')
  nuse('dokk')
  nuse('dokzout')
  nuse('doksout')
  nuse('dokkout')
  return (.t.)

/**************** */
function skladsd1a(p1)
  /**************** */
  sele cskl
  path_rr=alltrim(path)
  pathoutr=pathmoutr+gcDir_e+gcDir_g+gcDir_d+path_rr

  /* Приходы */
  if (gnArm#0)
    @ 1, 20 say 'Приход'
  endif

  rinsr=0
  pathr=gcPath_d+path_rr
  netuse('pr1',,, 1)
  pathr=pathoutr
  copy stru to (pathr+'tprho11.dbf')
  CLOSE
  netind('pr1', 1)
  netuse('pr1', 'pr1out',, 1)
  pathr=gcPath_d+path_rr
  netuse('pr1',,, 1)

  pathr=gcPath_d+path_rr
  netuse('pr2',,, 1)
  pathr=pathoutr
  copy stru to (pathr+'tprho12.dbf')
  CLOSE
  netind('pr2', 1)
  netuse('pr2', 'pr2out',, 1)
  pathr=gcPath_d+path_rr
  netuse('pr2',,, 1)

  pathr=gcPath_d+path_rr
  netuse('pr3',,, 1)
  pathr=pathoutr
  copy stru to (pathr+'tprho13.dbf')
  CLOSE
  netind('pr3', 1)
  netuse('pr3', 'pr3out',, 1)
  pathr=gcPath_d+path_rr
  netuse('pr3',,, 1)

  if (gnArm#0)
    sele pr1
    rccr=recc()
    @ 1, 30 say str(rccr, 10)
  endif

  sele pr1
  if (kolmodr=0)
    set orde to
    whlmodr='!eof()'
  else
    if (!empty(indexkey(indexord('t6'))).and.time()>'00:00:00'.and.time()<'08:00:00')// dtos(dtmod)
      set orde to tag t6
      whlmodr='dtmod>=(date()-kolmodr).and.!eof()'
    else
      whlmodr='!eof()'
    endif

  endif

  go top
  while (&whlmodr)
    if (gnArm#0)
      @ 1, 40 say str(recn(), 10)
    endif

    if (rmsk#gnRmsk)
      skip
      loop
    endif

    if (sks#0)            // Пропуск автоматов
      skip
      loop
    endif

    if (kolmodr#0)
      if (!empty(dtmod))
        if (dtmod<(date()-kolmodr))
          skip
          loop
        endif

      endif

    endif

    rinsr=rinsr+1
    if (gnArm#0)
      @ 1, 50 say str(rinsr, 10)
    endif

    sklr=skl
    mnr=mn
    nndsr=nnds
    sele pr1
    arec:={}
    getrec()
    sele pr1out
    netadd()
    putrec(,, 1)
    netunlock()
    sele pr2
    if (netseek('t1', 'mnr'))
      while (mn=mnr)
        mntovr=mntov
        ktlr=ktl
        arec:={}
        getrec()
        sele pr2out
        netadd()
        putrec(,, 1)
        netunlock()
        sele pr2
        skip
      enddo

    endif

    sele pr3
    if (netseek('t1', 'mnr'))
      while (mn=mnr)
        arec:={}
        getrec()
        sele pr3out
        netadd()
        putrec(,, 1)
        netunlock()
        sele pr3
        skip
      enddo

    endif

    sele pr1
    skip
  enddo

  nuse('pr1')
  nuse('pr2')
  nuse('pr3')
  nuse('pr1out')
  nuse('pr2out')
  nuse('pr3out')

  /* Расходы */
  if (gnArm#0)
    @ 1, 20 say 'Расход'
  endif

  rinsr=0
  pathr=gcPath_d+path_rr
  netuse('rs1',,, 1)
  pathr=pathoutr
  copy stru to (pathr+'trsho14.dbf')
  CLOSE
  netind('rs1', 1)
  netuse('rs1', 'rs1out',, 1)
  pathr=gcPath_d+path_rr
  netuse('rs1',,, 1)

  pathr=gcPath_d+path_rr
  netuse('rs2',,, 1)
  pathr=pathoutr
  copy stru to (pathr+'trsho15.dbf')
  CLOSE
  netind('rs2', 1)
  netuse('rs2', 'rs2out',, 1)
  pathr=gcPath_d+path_rr
  netuse('rs2',,, 1)

  pathr=gcPath_d+path_rr
  netuse('rs3',,, 1)
  pathr=pathoutr
  copy stru to (pathr+'trsho16.dbf')
  CLOSE
  netind('rs3', 1)
  netuse('rs3', 'rs3out',, 1)
  pathr=gcPath_d+path_rr
  netuse('rs3',,, 1)

  if (gnArm#0)
    sele rs1
    rccr=recc()
    @ 1, 30 say str(rccr, 10)
  endif

  sele rs1
  if (kolmodr=0)
    set orde to
    whlmodr='!eof()'
  else
    if (!empty(indexkey(indexord('t6'))).and.time()>'00:00:00'.and.time()<'08:00:00')// dtos(dtmod)
      set orde to tag t6
      whlmodr='dtmod>=(date()-kolmodr).and.!eof()'
    else
      whlmodr='!eof()'
    endif

  endif

  go top
  while (&whlmodr)
    if (gnArm#0)
      @ 1, 40 say str(recn(), 10)
    endif

    if (rmsk#gnRmsk)
      skip
      loop
    endif

    if (sks#0)            // Пропуск автоматов
      skip
      loop
    endif

    if (kolmodr#0)
      if (!empty(dtmod))
        if (dtmod<(date()-kolmodr))
          skip
          loop
        endif

      endif

    endif

    rinsr=rinsr+1
    if (gnArm#0)
      @ 1, 50 say str(rinsr, 10)
    endif

    sklr=skl
    ttnr=ttn
    nndsr=nnds
    sele rs1
    arec:={}
    getrec()
    sele rs1out
    netadd()
    putrec(,, 1)
    netunlock()
    sele rs2
    if (netseek('t1', 'ttnr'))
      while (ttn=ttnr)
        mntovr=mntov
        ktlr=ktl
        arec:={}
        getrec()
        sele rs2out
        netadd()
        putrec(,, 1)
        netunlock()
        sele rs2
        skip
      enddo

    endif

    sele rs3
    if (netseek('t1', 'ttnr'))
      while (ttn=ttnr)
        arec:={}
        getrec()
        sele rs3out
        netadd()
        putrec(,, 1)
        netunlock()
        sele rs3
        skip
      enddo

    endif

    sele rs1
    skip
  enddo

  nuse('rs1')
  nuse('rs2')
  nuse('rs3')
  nuse('rs1out')
  nuse('rs2out')
  nuse('rs3out')

  /* Заявки КПК */
  if (gnArm#0)
    @ 1, 20 say 'Заявки КПК'
  endif

  rinsr=0
  pathr=gcPath_d+path_rr
  netuse('rs1kpk',,, 1)
  pathr=pathoutr
  copy stru to (pathr+'rs1kpk.dbf')
  CLOSE
  netind('rs1kpk', 1)
  netuse('rs1kpk', 'rs1out',, 1)
  pathr=gcPath_d+path_rr
  netuse('rs1kpk',,, 1)

  pathr=gcPath_d+path_rr
  netuse('rs2kpk',,, 1)
  pathr=pathoutr
  copy stru to (pathr+'rs2kpk.dbf')
  CLOSE
  netind('rs2kpk', 1)
  netuse('rs2kpk', 'rs2out',, 1)
  pathr=gcPath_d+path_rr
  netuse('rs2kpk',,, 1)

  sele rs1kpk
  if (kolmodr=0)
    set orde to
    whlmodr='!eof()'
  else
    if (!empty(indexkey(indexord('t2'))).and.time()>'00:00:00'.and.time()<'08:00:00')// dtos(dtmod)
      set orde to tag t2
      whlmodr='dtmod>=(date()-kolmodr).and.!eof()'
    else
      whlmodr='!eof()'
    endif

  endif

  go top
  while (&whlmodr)
    if (gnArm#0)
      @ 1, 40 say str(recn(), 10)
    endif

    if (kolmodr#0)
      if (!empty(dtmod))
        if (dtmod<(date()-kolmodr))
          skip
          loop
        endif

      endif

    endif

    rinsr=rinsr+1
    if (gnArm#0)
      @ 1, 50 say str(rinsr, 10)
    endif

    sklr=skl
    ttnr=ttn
    skpkr=skpk
    sele rs1kpk
    arec:={}
    getrec()
    sele rs1out
    netadd()
    putrec(,, 1)
    netunlock()
    sele rs2kpk
    if (netseek('t1', 'ttnr,skpkr'))
      while (ttn=ttnr.and.skpk=skpkr)
        mntovr=mntov
        ktlr=ktl
        arec:={}
        getrec()
        sele rs2out
        netadd()
        putrec(,, 1)
        netunlock()
        sele rs2kpk
        skip
      enddo

    endif

    sele rs1kpk
    skip
  enddo

  nuse('rs1kpk')
  nuse('rs2kpk')
  nuse('rs1out')
  nuse('rs2out')
  return (.t.)

/*************** */
function ndssd1a()
  /*************** */
  if (gnArm#0)
    @ 1, 1 say 'NDS'
  endif

  pathoutr=pathmoutr+gcDir_e
  netuse('kpl')
  netuse('nds')
  pathr=pathoutr
  copy stru to (pathr+'nds.dbf')
  CLOSE
  netind('nds', 1)
  netuse('nds', 'ndsout',, 1)
  netuse('nds')
  set orde to tag t2
  sele kpl
  go top
  while (!eof())
    kklr=kpl
    sele nds
    if (netseek('t2', 'kklr'))
      while (kkl=kklr)
        if (rmsk=0)
          netrepl('rmsk', 'gnRmsk')
        endif

        if (rmsk=0)
          netdel()
          skip
          loop
        else
          if (rmsk#gnRmsk)
            netdel()
            skip
            loop
          endif

        endif

        arec:={}
        getrec()
        sele ndsout
        netadd()
        putrec(,, 1)
        netunlock()
        sele nds
        skip
      enddo

    endif

    sele kpl
    skip
  enddo

  sele nds
  set orde to
  go top
  while (!eof())
    nomndsr=nomnds
    rmsk_r=rmsk
    sele ndsout
    kklr=kkl
    if (!netseek('t1', 'nomndsr'))
      if (rmsk_r#gnRmsk)
        sele nds
        netdel()
        skip
        loop
      else
        sele nds
        arec:={}
        getrec()
        sele ndsout
        netadd()
        putrec(,, 1)
        netunlock()
        sele kpl
        if (!netseek('t1', 'kklr'))
          crmskr=space(9)
          stuff(crmskr, gnRmsk, 1, '1')
          netadd()
          netrepl('kpl,crmskr', 'kklr,crmskr')
        endif

      endif

    endif

    sele nds
    skip
  enddo

  nuse('nds')
  nuse('ndsout')
  nuse('kpl')
  return (.t.)

/**************** */
function plgpsd1a()
  /**************** */
  if (gnArm#0)
    @ 1, 1 say 'KPLKGP'
  endif

  /*pathoutr=pathmoutr+gcDir_e
   *netuse('kpl')
   *pathr=pathoutr
   *copy stru to (pathr+'kpl.dbf')
   *use
   *netind('kpl',1)
   *netuse('kpl','kplout',,1)
   */
  netuse('kpl')
  go top
  while (!eof())
    crmskr=crmsk
    if (subs(crmskr, gnRmsk, 1)#'1')
      netdel()
      sele kpl
      skip
      loop
    endif

    /*   arec:={}
     *   getrec()
     *   sele kplout
     *   netadd()
     *   putrec()
     *   netunlock()
     */
    sele kpl
    skip
  enddo

  nuse('kpl')

  netuse('kgp')
  /*pathr=pathoutr
   *copy stru to (pathr+'kgp.dbf')
   *use
   *netind('kgp',1)
   *netuse('kgp','kgpout',,1)
   */
  netuse('kgp')
  go top
  while (!eof())
    if (rm#gnRmsk)
      netdel()
      sele kgp
      skip
      loop
    endif

    /*   arec:={}
     *   getrec()
     *   sele kgpout
     *   netadd()
     *   putrec()
     *   netunlock()
     */
    sele kgp
    skip
  enddo

  nuse('kgp')
  return (.t.)

/*************** */
function moddocsd1a()
  /*************** */
  if (gnArm#0)
    @ 1, 1 say 'MODDOC'
  endif

  pathoutr=pathmoutr+gcDir_e
  netuse('moddoc')
  pathr=pathoutr
  copy to (pathr+'moddoc.dbf')//for dtmod>=date()-7
  CLOSE
  netuse('mdall')
  pathr=pathoutr
  copy to (pathr+'mdall.dbf') //for dtmod>=date()-7
  CLOSE
  return (.t.)
