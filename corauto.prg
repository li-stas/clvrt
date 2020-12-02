/* Коррекция автоматов (возвр тара отдельно) kop=188,189 */
clea
set prin to corauto.txt
set prin on
netuse('cmrsh')
netuse('cskl')
rccsklr=recn()
prretr=0
path_dr=gcPath_d
while (!eof())
  if (ent#gnEnt)
    skip
    loop
  endif

  if (ctov#1)
    skip
    loop
  endif

  pathr=path_dr+alltrim(path)
  if (tpstpok#0)
    skip
    loop
  endif

  if (!netfile('tov', 1))
    skip
    loop
  endif

  rccsklr=recn()
  skr=sk
  ?pathr
  netuse('soper',,, 1)
  netuse('tov',,, 1)
  netuse('tovm',,, 1)
  netuse('pr1',,, 1)
  netuse('pr2',,, 1)
  netuse('pr3',,, 1)
  netuse('rs1',,, 1)
  netuse('rs2',,, 1)
  netuse('rs3',,, 1)
  ?'Приход'
  sele pr1
  while (!eof())
    rcpr1r=recn()
    if (!(kop=188.or.kop=189))
      skip
      loop
    endif

    AutoPr()
    sele pr1
    go rcpr1r
    skip
  enddo

  ?'Расход'
  sele rs1
  while (!eof())
    rcrs1r=recn()
    if (!(kop=188.or.kop=189))
      skip
      loop
    endif

    AutoRs()
    sele rs1
    go rcrs1r
    skip
  enddo

  nuse('soper')
  nuse('tov')
  nuse('tovm')
  nuse('pr1')
  nuse('pr2')
  nuse('pr3')
  nuse('rs1')
  nuse('rs2')
  nuse('rs3')
  sele cskl
  go rccsklr
  skip
enddo

nuse()
set prin off
set prin to
if (prretr=1)
  wmess('Еще раз...', 0)
endif

/************** */
function prrsa(p1)
  /* p1 1 - ins; 2 - del
   **************
   */
  sele pr1
  if (p1=1.and.prz=0)
    ?str(prz, 1)+' ND '+str(nd, 6)+' MN '+str(mn, 6)+' KOP '+str(kop, 3)+' не подтвержден'
    return (.f.)
  endif

  reclock()
  ndr=nd
  mnr=mn
  kopr=kop
  qr=mod(kopr, 100)
  vor=vo
  sktr=skt
  skltr=sklt
  sksr=sks
  sklsr=skls
  amnr=amn
  przr=prz
  sklr=skl
  dprr=dpr
  tprr=tpr
  kpsr=kps
  rmskr=rmsk
  sdvr=sdv

  if (amnr=0)
    ttnr=ndr
  else
    ttnr=amnr
  endif

  sele soper
  if (netseek('t1', '1,1,vor,qr'))
    koppr=kopp
    qqr=mod(koppr, 100)
    autor=auto
  else
    ?str(przr, 1)+' ND '+str(ndr, 6)+' MN '+str(mnr, 6)+' KOP '+str(kopr, 3)+' не найден в SOPER'
    sele pr1
    netunlock()
    return (.f.)
  endif

  if (autor#3)
    ?str(przr, 1)+' ND '+str(ndr, 6)+' MN '+str(mnr, 6)+' KOP '+str(kopr, 3)+' auto#3 '
    sele pr1
    netunlock()
    return (.f.)
  endif

  if (koppr=0)
    ?str(przr, 1)+' ND '+str(ndr, 6)+' MN '+str(mnr, 6)+' KOP '+str(kopr, 3)+' kopp=0 '
    sele pr1
    netunlock()
    return (.f.)
  endif

  sele cskl
  if (!netseek('t1', 'sktr'))
    ?str(przr, 1)+' ND '+str(ndr, 6)+' MN '+str(mnr, 6)+' KOP '+str(kopr, 3)+' SKT '+str(sktr, 3)+' назн нет в CSKL '
    sele pr1
    netunlock()
    return (.f.)
  endif

  pathr=path_dr+alltrim(path)
  if (!netfile('tov', 1))
    ?str(przr, 1)+' ND '+str(ndr, 6)+' MN '+str(mnr, 6)+' KOP '+str(kopr, 3)+' нет файлов склада назн'
    sele pr1
    netunlock()
    return (.f.)
  endif

  netuse('soper', 'soperout',, 1)
  if (!netseek('t1', '1,1,vor,qqr'))
    nuse('soperout')
    ?str(przr, 1)+' ND '+str(ndr, 6)+' MN '+str(mnr, 6)+' KOPP '+str(koppr, 3)+' SKT '+str(sktr, 3)+' нет kopp в SOPEROUT '
    sele pr1
    netunlock()
    return (.f.)
  endif

  netuse('rs1', 'rs1out',, 1)
  netuse('rs2', 'rs2out',, 1)
  netuse('rs3', 'rs3out',, 1)
  netuse('tov', 'tovout',, 1)
  netuse('tovm', 'tovmout',, 1)
  netuse('sgrp', 'sgrpout',, 1)

  if (p1=1)
    sele rs1out
    if (netseek('t1', 'ttnr'))
      if (sks=skr.and.skls=sklr)
        nuse('rs1out')
        nuse('rs2out')
        nuse('rs3out')
        ?str(przr, 1)+' ND '+str(ndr, 6)+' MN '+str(mnr, 6)+' автомат существует'
        sele pr1
        netunlock()
        return (.f.)
      else
        ttnr=0
      endif

    endif

    if (ttnr=0)
      sele cskl
      reclock()
      ttnr=ttn
      sele rs1out
      while (netseek('t1', 'ttnr'))
        ttnr=ttnr+1
      enddo

      sele cskl
      netrepl('ttn', {ttnr+1})
      netunlock()
    endif

  else
    /* Проверка на двойников */
    if (amnr#0.and.sktr#0)
      sele rs1out
      locate for amn=mnr.and.sks=skr
      if (foun())
        set filt to amn=mnr.and.sks=skr
        go top
        while (!eof())
          if (ttn=amnr)
            sele rs1out
            skip
            loop
          endif

          ttn_r=ttn
          sele rs3out
          if (netseek('t1', 'ttn_r'))
            while (ttn=ttn_r)
              netdel()
              sele rs3
              skip
            enddo

          endif

          sele rs2out
          if (netseek('t1', 'ttn_r'))
            while (ttn=ttn_r)
              ktlr=ktl
              mntovr=mntov
              kfr=kvp
              sele tovout
              if (netseek('t1', 'sklr,ktlr'))
                netrepl('osv,osf,osfo',{osv+kfr,osf+kfr,osfo+kfr})
              endif

              sele tovmout
              if (netseek('t1', 'sklr,mntovr'))
                netrepl('osv,osf,osfo',{osv+kfr,osf+kfr,osfo+kfr})
              endif

              sele rs2out
              netdel()
              skip
            enddo

          endif

          sele rs1out
          netdel()
          skip
        enddo

        sele rs1out
        set filt to
        go top
      endif

    endif

  endif

  /*** Данные из pr1 , записать в rs1 ******************* */
  if (p1 = 1)             // Формирование
    sele pr1
    netrepl('amn',{ttnr}, 1)
    sele rs1out
    netadd()
    netrepl('ttn,ddc,tdc,dvp,vo,kop,prz,sdv,skl,kpl,sks,skls,amn,pst,kto,dot,tot,rmsk,dtmod,tmmod',                       ;
             {ttnr,date(),time(),dvpr,vor,koppr,1,sdvr,skltr,gnKkl_c,skr,sklr,mnr,pstr,ktor,dprr,tprr,rmskr,date(),time()} ;
         )
  else                      //Удаление mode <> 1
    sele rs1
    if (netseek('t1', 'ttnr'))
      while (ttn=ttnr)
        if (ttn=ttnr)
          netdel()
        endif

        skip
        if (eof())
          exit
        endif

      enddo

    endif

  endif

  /*** Данные с pr3 , записать в rs3 ******************** */
  if (p1=1)
    sele pr3
    netseek('t1', 'mnr')
    while (mn=mnr)
      kszr=ksz
      ssfr=ssf
      sele rs3out
      netadd()
      netrepl('ttn,ksz,ssf',{ttnr,kszr,ssfr})
      sele pr3
      skip
    enddo

  else
    sele rs3out
    if (netseek('t1', 'ttnr'))
      while (ttn=ttnr)
        netdel()
        skip
      enddo

    endif

  endif

  /*** Данные с pr2 , записать в rs2 ******************** */
  if (p1=1)
    sele pr2
    netseek('t1', 'mnr')
    while (mn=mnr)
      mntovr=mntov
      mntovpr=mntovp
      ktlr=ktl
      ktlpr=ktlp
      pptr=ppt
      kg_r=int(ktlr/1000000)
      kfr=kf
      sfr=sf
      optr=zen
      zenr=zen
      izgr=izg
      if (zenr=0)
        skip
        loop
      endif

      sele sgrpout
      if (!netseek('t1', 'kg_r'))
        sele sgrp
        if (netseek('t1', 'kg_r'))
          arec:={}
          getrec()
          sele sgrpout
          netadd()
          putrec()
        endif

      endif

      /*** Коpекция остатков ************************************** */
      sele tov
      if (netseek('t1', 'sklr,ktlr'))
        arec:={}
        getrec()
        izgr=izg
      endif

      sele tovmout
      if (netseek('t1', 'skltr,mntovr'))
        reclock()
        netrepl('osv,osf,osfo',{osv-kfr,osf-kfr,osfo-kfr}, 1)
      else
        netadd()
        putrec()
        reclock()
        netrepl('skl,ktl,osn,osv,osf,osfo',   ;
                 {skltr,0,0,-kfr,-kfr,-kfr}, 1 ;
             )
      endif

      sele tovout
      if (netseek('t1', 'skltr,ktlr'))
        netrepl('osv,osf,osfo',{osv-kfr,osf-kfr,osfo-kfr})
      else
        netadd()
        putrec()
        netrepl('skl,osn,osv,osf,osfo',  ;
                 {skltr,0,-kfr,-kfr,-kfr} ;
             )
      endif

      sele tovmout
      netunlock()
      /* Расход */
      sele rs2out
      set orde to tag t3
      if (!netseek('t3', 'ttnr,ktlpr,pptr,ktlr'))
        netadd()
        netrepl('ttn,mntov,mntovp,ktlp,ppt,ktl,kf,kvp,sf,svp,zen,izg,prosfo',     ;
                 {ttnr,mntovr,mntovpr,ktlpr,pptr,ktlr,kfr,kfr,sfr,sfr,zenr,izgr,1} ;
             )
      else
        netrepl('kf,kvp,sf,svp',                ;
                 {kf+kfr,kvp+kfr,sf+sfr,svp+sfr} ;
             )
      endif

      sele pr2
      skip
    enddo

  else                      // Удаление
    sele rs2out
    if (netseek('t1', 'ttnr'))
      while (ttn=ttnr)
        mntovr=mntov
        mntovpr=mntovp
        ktlr=ktl
        ktlpr=ktlp
        kvpr=kvp
        SELE tovout
        if (netseek('t1', 'skltr,ktlr'))
          netrepl('osv,osf,osfo',{osv+kvpr,osf+kvpr,osfo+kvpr})
        endif

        sele tovmout
        if (netseek('t1', 'skltr,mntovr'))
          netrepl('osv,osf,osfo',{osv+kvpr,osf+kvpr,osfo+kvpr})
        endif

        sele rs2out
        netdel()
        skip
        if (eof())
          exit
        endif

      enddo

    endif

  endif

  nuse('rs1out')
  nuse('rs2out')
  nuse('rs3out')
  nuse('soperout')
  nuse('tovout')
  nuse('tovmout')
  nuse('sgrpout')
  sele pr1
  netunlock()
  return (.t.)

/****************** */
function rspra(p1)
  /* p1 1 - ins; 2 - del
   ******************
   */
  sele rs1
  if (p1=1.and.prz=0)
    ?str(prz, 1)+' TTN '+str(ttn, 6)+' KOP '+str(kop, 3)+' не подтвержден'
    return (.f.)
  endif

  reclock()
  ttnr=ttn
  sklr=skl
  kopr=kop
  qr=mod(kopr, 100)
  vor=vo
  przr=prz
  sktr=skt
  skltr=sklt
  sksr=sks
  sklsr=skls
  amnr=amn
  rmskr=rmsk
  dotr=dot
  totr=tot
  dvpr=dvp
  pstr=pst
  sdvr=sdv

  ndr=ttnr

  if (amnr=0)
    mnr=0
  else
    mnr=amnr
  endif

  sele soper
  if (netseek('t1', '0,1,vor,qr'))
    koppr=kopp
    qqr=mod(koppr, 100)
    autor=auto
  else
    ?str(przr, 1)+' TTN '+str(ttnr, 6)+' KOP '+str(kopr, 3)+' не найден в SOPER'
    sele rs1
    netunlock()
    return (.f.)
  endif

  if (!(autor=3.or.vor=10.and.(kopr=183.or.kopr=193).or.vor=6.and.kopr=189))
    ?str(przr, 1)+' TTN '+str(ttnr, 6)+' KOP '+str(kopr, 3)+' auto#3 '
    sele rs1
    netunlock()
    return (.f.)
  endif

  if (koppr=0)
    ?str(przr, 1)+' TTN '+str(ttnr, 6)+' KOPP '+str(kopr, 3)+' kopp=0 '
    sele rs1
    netunlock()
    return (.f.)
  endif

  sele cskl
  if (!netseek('t1', 'sktr'))
    ?str(przr, 1)+' TTN '+str(ttnr, 6)+' KOP '+str(kopr, 3)+' SKT '+str(sktr, 3)+' назн нет в CSKL '
    sele rs1
    netunlock()
    return (.f.)
  endif

  pathr=path_dr+alltrim(path)
  if (!netfile('tov', 1))
    ?str(przr, 1)+' TTN '+str(ttnr, 6)+' KOP '+str(kopr, 3)+' SKT '+str(sktr, 3)+' нет файлов назн '
    sele rs1
    netunlock()
    return (.f.)
  endif

  netuse('soper', 'soperout',, 1)
  if (!netseek('t1', '1,1,vor,qqr'))
    nuse('soperout')
    ?str(przr, 1)+' TTN '+str(ttnr, 6)+' KOPP '+str(koppr, 3)+' SKT '+str(sktr, 3)+' нет kopp в SOPEROUT '
    sele rs1
    netunlock()
    return (.f.)
  endif

  netuse('pr1', 'pr1out',, 1)
  netuse('pr2', 'pr2out',, 1)
  netuse('pr3', 'pr3out',, 1)
  netuse('tov', 'tovout',, 1)
  netuse('tovm', 'tovmout',, 1)
  netuse('sgrp', 'sgrpout',, 1)

  if (p1=1)
    sele pr1out
    if (mnr#0)
      if (netseek('t2', 'mnr'))
        if (sks=skr.and.skls=sklr)
          nuse('pr1out')
          nuse('pr2out')
          nuse('pr3out')
          ?str(przr, 1)+' TTN '+str(ttnr, 6)+' автомат существует'
          sele rs1
          netunlock()
          return (.f.)
        else
          mnr=0
        endif

      endif

    endif

    if (mnr=0)
      sele cskl
      reclock()
      mnr=mn
      sele pr1out
      set orde to tag t2
      while (netseek('t2', 'mnr'))
        mnr=mnr+1
      enddo

      sele cskl
      netrepl('mn',{mnr+1})
      netunlock()
    endif

    sele pr1out
    if (netseek('t1', 'ndr'))
      ndr=mnr
    endif

  else
    /* Проверка на двойников */
    if (amnr#0.and.sktr#0)
      sele pr1out
      locate for amn=ttnr.and.sks=skr
      if (foun())
        set filt to amn=ttnr.and.sks=skr
        go top
        while (!eof())
          if (mn=amnr)
            sele pr1out
            skip
            loop
          endif

          mn_r=mn
          sele pr3out
          if (netseek('t1', 'mn_r'))
            while (mn=mn_r)
              netdel()
              sele pr3
              skip
            enddo

          endif

          sele pr2out
          if (netseek('t1', 'mn_r'))
            while (mn=mn_r)
              ktlr=ktl
              mntovr=mntov
              kfr=kf
              sele tovout
              if (netseek('t1', 'sklr,ktlr'))
                netrepl('osv,osf,osfo',{osv-kfr,osf-kfr,osfo-kfr})
              endif

              sele tovmout
              if (netseek('t1', 'sklr,mntovr'))
                netrepl('osv,osf,osfo',{osv-kfr,osf-kfr,osfo-kfr})
              endif

              sele pr2out
              netdel()
              skip
            enddo

          endif

          sele pr1out
          netdel()
          skip
        enddo

        sele pr1out
        set filt to
        go top
      endif

    endif

  endif

  /*** Данные с rs1 , записать в pr1 ******************* */
  if (p1 = 1)             // Формирование
    sele rs1
    netrepl('amn',{mnr}, 1)
    ttnr=ttn
    sele pr1out
    netadd()
    netrepl('nd,mn,ddc,tdc,dvp,vo,kop,prz,sdv,skl,kps,sks,skls,amn,kto,dpr,tpr,pst,rmsk,dtmod,tmmod',                          ;
             {ndr,mnr,date(),time(),dvpr,vor,koppr,1,sdvr,skltr,gnKkl_c,skr,sklr,ttnr,gnKto,dotr,totr,pstr,rmskr,date(),time()} ;
         )
  else                      //Удаление mode <> 1
    sele pr1out
    set orde to tag t2
    if (netseek('t2', 'mnr'))
      while (mn=mnr)
        if (mn=mnr)
          netdel()
        endif

        skip
        if (eof())
          exit
        endif

      enddo

    endif

  endif

  /*** Данные с rs3 , записать в pr3 ******************** */
  if (p1=1)
    sele rs3
    if (netseek('t1', 'ttnr'))
      while (ttn=ttnr)
        kszr=ksz
        ssfr=ssf
        sele pr3out
        netadd()
        netrepl('mn,ksz,ssf',{mnr,kszr,ssfr})
        sele rs3
        skip
      enddo

    endif

  else
    sele pr3out
    if (netseek('t1', 'mnr'))
      while (mn=mnr)
        netdel()
        skip
      enddo

    endif

  endif

  /*** Данные с rs2 , записать в pr2 ******************** */
  if (p1=1)
    sele rs2
    netseek('t1', 'ttnr')
    while (ttn=ttnr)
      mntovr=mntov
      prktlr=0
      ktlr=ktl
      ktlpr=ktlpr
      pptr=0
      mntovpr=mntovp
      kg_r=int(ktlr/1000000)
      kfr=kvp
      sfr=svp
      optr=zen
      zenr=zen
      izgr=izg
      if (zenr=0)
        skip
        loop
      endif

      sele sgrpout
      if (!netseek('t1', 'kg_r'))
        sele sgrp
        if (netseek('t1', 'kg_r'))
          arec:={}
          getrec()
          sele sgrpout
          netadd()
          putrec()
        endif

      endif

      /*** Коpекция остатков ************************************** */
      sele tov
      if (netseek('t1', 'sklr,ktlr'))
        arec:={}
        getrec()
      endif

      sele tovmout
      if (netseek('t1', 'skltr,mntovr'))
        reclock()
        netrepl('osv,osf,osfo',{osv+kfr,osf+kfr,osfo+kfr}, 1)
      else
        netadd()
        putrec()
        reclock()
        netrepl('skl,ktl,osn,osv,osf,osfo', ;
                 {skltr,0,0,kfr,kfr,kfr}, 1  ;
             )
      endif

      sele tovout
      if (netseek('t1', 'skltr,ktlr'))
        netrepl('osv,osf,osfo',{osv+kfr,osf+kfr,osfo+kfr})
      else
        netadd()
        putrec()
        netrepl('skl,osn,osv,osf,osfo',{skltr,0,kfr,kfr,kfr})
      endif

      sele tovmout
      netunlock()

      /* Приход */
      sele pr2out
      set orde to tag t3
      if (!netseek('t3', 'mnr,ktlpr,pptr,ktlr'))
        netadd()
        netrepl('mn,mntov,mntovp,ktlp,ppt,ktl,kf,sf,zen,izg',          ;
                 {mnr,mntovr,mntovpr,ktlpr,pptr,ktlr,kfr,sfr,zenr,izgr} ;
             )
      else
        netrepl('kf,sf',{kf+kfr,sf+sfr})
      endif

      sele rs2
      skip
    enddo

  else
    sele pr2out             // Удаление
    if (netseek('t1', 'mnr'))
      while (mn=mnr)
        mntovr=mntov
        ktlr=ktl
        kfr=kf
        sele tovout
        if (netseek('t1', 'skltr,ktlr'))
          netrepl('osv,osf,osfo',{osv-kfr,osf-kfr,osfo-kfr})
        endif

        sele tovmout
        if (netseek('t1', 'skltr,mntovr'))
          netrepl('osv,osf,osfo',{osv-kfr,osf-kfr,osfo-kfr})
        endif

        sele pr2out
        netdel()
        skip
      enddo

    endif

  endif

  nuse('pr1out')
  nuse('pr2out')
  nuse('pr3out')
  nuse('soperout')
  nuse('tovout')
  nuse('tovmout')
  nuse('sgrpout')
  return (.t.)

/**************** */
function AutoPr()
  /**************** */
  ndr=nd
  mnr=mn
  kopr=kop
  qr=mod(kopr, 100)
  vor=vo
  sktr=skt
  skltr=sklt
  sksr=sks
  sklsr=skls
  amnr=amn
  przr=prz
  sklr=skl
  sdvr=sdv
  sele soper
  if (netseek('t1', '1,1,vor,qr'))
    koppr=kopp
    autor=auto
  else
    ?str(przr, 1)+' ND '+str(ndr, 6)+' MN '+str(mnr, 6)+' KOP '+str(kopr, 3)+' не найден в SOPER'
    return (.f.)
  endif

  if (gnEntrm=1.and.autor=0)
    return (.t.)
  endif

  if (autor=0)            // Чужой автомат
    prdelr=0
    if (sksr#0)
      sele cskl
      if (netseek('t1', 'sksr'))
        if (ent=gnEnt)
          pathr=path_dr+alltrim(path)
          netuse('rs1', 'rs1in',, 1)
          if (amnr#0)
            if (!netseek('t1', 'amnr'))
              ?str(przr, 1)+' ND '+str(ndr, 6)+' MN '+str(mnr, 6)+' KOP '+str(kopr, 3)+' SKS '+str(sksr, 3)+' TTN '+str(amnr, 6)+' ист нет в RS1IN'
              prdelr=1
            else
              if (skt=0)
                ?str(przr, 1)+' ND '+str(ndr, 6)+' MN '+str(mnr, 6)+' KOP '+str(kopr, 3)+' SKS '+str(sksr, 3)+' TTN '+str(amnr, 6)+' ист не автомат'
                prdelr=1
              endif

            endif

          else
            if (!netseek('t1', 'ndr'))
              prdelr=1
            else
              if (amn#0)
                if (amn#mnr)
                  prdelr=1
                else
                  amnr=ttn
                  sele pr1
                  netrepl('amn',{amnr})
                endif

              else
                if (sdvr=sdv)
                  if (skt=0)
                    ?str(przr, 1)+' '+str(sksr, 3)+' TTN '+str(ttn, 6)+' skt=0'
                    netrepl('skt',{skr})
                    prretr=1
                  endif

                  if (sklt=0)
                    ?str(przr, 1)+' '+str(sksr, 3)+' TTN '+str(ttn, 6)+' sklt=0'
                    netrepl('sklt',{sklr})
                    prretr=1
                  endif

                  if (amn=0)
                    ?str(przr, 1)+' '+str(sksr, 3)+' TTN '+str(ttn, 6)+' amn=0'
                    netrepl('amn',{mnr})
                    prretr=1
                  endif

                  amnr=ttn
                  sele pr1
                  ?str(przr, 1)+' ND '+str(ndr, 6)+' MN '+str(mnr, 6)+' amn=0'
                  netrepl('amn',{amnr})
                  prretr=1
                else
                  prdelr=1
                endif

              endif

            endif

          endif

          nuse('rs1in')
        else
          ?str(przr, 1)+' ND '+str(ndr, 6)+' MN '+str(mnr, 6)+' KOP '+str(kopr, 3)+' SKS '+str(sksr, 3)+' TTN '+str(amnr, 6)+' ист ent#gnEnt'
          prdelr=1
        endif

      else
        ?str(przr, 1)+' ND '+str(ndr, 6)+' MN '+str(mnr, 6)+' KOP '+str(kopr, 3)+' SKS '+str(sksr, 3)+' TTN '+str(amnr, 6)+' ист нет в CSKL '
        prdelr=1
      endif

    else
      ?str(przr, 1)+' ND '+str(ndr, 6)+' MN '+str(mnr, 6)+' KOP '+str(kopr, 3)+' SKS '+str(sksr, 3)+' TTN '+str(amnr, 6)+' sks=0 '
      prdelr=1
    endif

    if (prdelr=0)
      if (amnr#0.and.sksr#0)
        prdvr=0
        sele pr1
        rcr=recn()
        locate for amn=amnr.and.sks=sksr
        while (.t.)
          cont
          if (foun())
            prdvr=1
            netrepl('amn,sks',{0,0})
            ?'ND '+str(nd, 6)+' MN '+str(mn, 6)+' AMN '+str(amnr, 6)+' SKS '+str(sksr, 3)+' Двойник amn,sks'
          else
            if (prdvr=1)
              go rcr
              ?'ND '+str(nd, 6)+' MN '+str(mn, 6)+' AMN '+str(amnr, 6)+' SKS '+str(sksr, 3)+' Двойник amn,sks'
              netrepl('amn,sks',{0,0})
            endif

            exit
          endif

        enddo

        if (prdvr=1)
          amnr=0
          sksr=0
          prdelr=1
        endif

      endif

    endif

    if (prdelr=1)
      sele pr3
      if (netseek('t1', 'mnr'))
        while (mn=mnr)
          netdel()
          sele pr3
          skip
        enddo

      endif

      sele pr2
      if (netseek('t1', 'mnr'))
        while (mn=mnr)
          if (przr=1)
            ktlr=ktl
            mntovr=mntov
            kfr=kf
            sele tov
            if (netseek('t1', 'sklr,ktlr'))
              netrepl('osv,osf,osfo',{osv-kfr,osf-kfr,osfo-kfr})
            endif

            sele tovm
            if (netseek('t1', 'sklr,mntovr'))
              netrepl('osv,osf,osfo',{osv-kfr,osf-kfr,osfo-kfr})
            endif

          endif

          sele pr2
          netdel()
          skip
        enddo

      endif

      sele pr1
      netdel()
      ?str(przr, 1)+' ND '+str(ndr, 6)+' MN '+str(mnr, 6)+' KOP '+str(kopr, 3)+' удален'
    endif

  else
    if (autor=3)          // Свой автомат
      if (sktr#0.and.skltr#0)
        if (prrsa(2))
          ?str(przr, 1)+' ND '+str(ndr, 6)+' MN '+str(mnr, 6)+' SKT '+str(sktr, 3)+' TTN '+str(amnr, 6)+' коррекция'
        else
          ?str(przr, 1)+' ND '+str(ndr, 6)+' MN '+str(mnr, 6)+' SKT'+str(sktr, 3)+' TTN '+str(amnr, 6)+' новый'
        endif

        if (przr=1)
          prrsa(1)
        endif

      else

      endif

    endif

  endif

  return (.t.)

/*************** */
function AutoRs()
  /*************** */
  ttnr=ttn
  kopr=kop
  qr=mod(kopr, 100)
  vor=vo
  sktr=skt
  skltr=sklt
  sksr=sks
  sklsr=skls
  amnr=amn
  przr=prz
  sklr=skl
  sdvr=sdv
  mrshr=mrsh
  sele soper
  if (netseek('t1', '0,1,vor,qr'))
    koppr=kopp
    autor=auto
  else
    ?str(przr, 1)+' TTN '+str(ttnr, 6)+' KOP '+str(kopr, 3)+' не найден в SOPER'
    return (.f.)
  endif

  if (gnEntrm=1.and.autor=0)
    return (.t.)
  endif

  if (autor=0)            // Чужой автомат
    prdelr=0
    sele cskl
    if (sksr#0)
      if (netseek('t1', 'sksr'))
        if (ent=gnEnt)
          pathr=path_dr+alltrim(path)
          netuse('pr1', 'pr1in',, 1)
          if (amnr#0)
            if (!netseek('t2', 'amnr'))
              ?str(przr, 1)+' TTN '+str(ttnr, 6)+' KOP '+str(kopr, 3)+' SKS '+str(sksr, 3)+' MN '+str(amnr, 6)+' ист нет в PR1IN'
              prdelr=1
            endif

          else
            if (!netseek('t1', 'ttnr'))
              ?str(przr, 1)+' TTN '+str(ttnr, 6)+' KOP '+str(kopr, 3)+' SKS '+str(sksr, 3)+' ND '+str(ttnr, 6)+' ист нет в PR1IN'
              prdelr=1
            else
              if (amn#0)
                if (amn#ttnr)
                  prdelr=1
                else
                  amnr=mn
                  sele rs1
                  netrepl('amn',{amnr})
                endif

              else
                if (sdvr=sdv)
                  if (skt=0)
                    ?str(przr, 1)+' '+str(sksr, 3)+' ND '+str(nd, 6)+' MN '+str(mn6)+' skt=0'
                    prretr=1
                    netrepl('skt',{skr})
                  endif

                  if (sklt=0)
                    ?str(przr, 1)+' '+str(sksr, 3)+' ND '+str(nd, 6)+' MN '+str(mn6)+' sklt=0'
                    netrepl('sklt',{sklr})
                    prretr=1
                  endif

                  if (amn=0)
                    ?str(przr, 1)+' '+str(sksr, 3)+' ND '+str(nd, 6)+' MN '+str(mn6)+' amn=0'
                    netrepl('amn',{ttnr})
                    prretr=1
                  endif

                  amnr=mn
                  sele rs1
                  ?str(przr, 1)+' TTN '+str(ttnr, 6)+' KOP '+str(kopr, 3)+' amn=0'
                  netrepl('amn',{amnr})
                  prretr=1
                endif

              endif

            endif

          endif

          nuse('pr1in')
        else
          ?str(przr, 1)+' TTN '+str(ttnr, 6)+' KOP '+str(kopr, 3)+' SKS '+str(sksr, 3)+' TTN '+str(amnr, 6)+' ист ent#gnEnt'
          prdelr=1
        endif

      else
        ?str(przr, 1)+' TTN '+str(ttnr, 6)+' KOP '+str(kopr, 3)+' SKS '+str(sksr, 3)+' TTN '+str(amnr, 6)+' ист нет в CSKL '
        prdelr=1
      endif

    else
      ?str(przr, 1)+' TTN '+str(ttnr, 6)+' KOP '+str(kopr, 3)+' SKS '+str(sksr, 3)+' TTN '+str(amnr, 6)+' sks=0 '
      prdelr=1
    endif

    if (prdelr=0)
      if (amnr#0.and.sksr#0)
        prdvr=0
        sele rs1
        rcr=recn()
        locate for amn=amnr.and.sks=sksr
        while (.t.)
          cont
          if (foun())
            prdvr=1
            netrepl('amn,sks',{0,0})
            ?'TTN '+str(ttn, 6)+' AMN '+str(amnr, 6)+' SKS '+str(sksr, 3)+' Двойник amn,sks'
          else
            if (prdvr=1)
              go rcr
              ?'TTN '+str(ttn, 6)+' AMN '+str(amnr, 6)+' SKS '+str(sksr, 3)+' Двойник amn,sks'
              netrepl('amn,sks',{0,0})
            endif

            exit
          endif

        enddo

        if (prdvr=1)
          amnr=0
          sksr=0
          prdelr=1
        endif

      endif

    endif

    if (prdelr=1)
      sele rs3
      if (netseek('t1', 'ttnr'))
        while (ttn=ttnr)
          netdel()
          sele rs3
          skip
        enddo

      endif

      sele rs2
      if (netseek('t1', 'ttnr'))
        while (ttn=ttnr)
          ktlr=ktl
          mntovr=mntov
          kvpr=kvp
          sele tov
          if (netseek('t1', 'sklr,ktlr'))
            if (przr=1)
              netrepl('osv,osf,osfo',{osv+kvpr,osf+kvpr,osfo+kvpr})
            else
              if (!empty(dotr))
                netrepl('osv,osfo',{osv+kvpr,osfo+kvpr})
              else
                netrepl('osv',{osv+kvpr})
              endif

            endif

          endif

          sele tovm
          if (netseek('t1', 'sklr,mntovr'))
            if (przr=1)
              netrepl('osv,osf,osfo',{osv+kvpr,osf+kvpr,osfo+kvpr})
            else
              if (!empty(dotr))
                netrepl('osv,osfo',{osv+kvpr,osfo+kvpr})
              else
                netrepl('osv',{osv+kvpr})
              endif

            endif

          endif

          sele rs2
          netdel()
          skip
        enddo

      endif

      sele rs1
      netdel()
      ?str(przr, 1)+' TTN '+str(ttnr, 6)+' KOP '+str(kopr, 3)+' удален'
    endif

  else
    if (autor=3.or.(autor=1.and.vor=6.and.kopr=189))// Свой автомат
      if (sktr#0.and.skltr#0)
        if (rspra(2))
          ?str(przr, 1)+' TTN '+str(ttnr, 6)+' KOP '+str(kopr, 3)+' SKT '+str(sktr, 3)+' MN '+str(amnr, 6)+' коррекция'
        else
          ?str(przr, 1)+' TTN '+str(ttnr, 6)+' KOP '+str(kopr, 3)+' SKT '+str(sktr, 3)+' MN '+str(amnr, 6)+' новый'
        endif

        if (przr=1)
          rspra(1)
        endif

      else
        if (mrshr#0)
          vmrshr=getfield('t2', 'mrshr', 'cmrsh', 'vmrsh')
          do case
          case (vmrshr=8)
            sktr=300
          case (vmrshr=2)
            sktr=400
          case (vmrshr=6)
            sktr=500
          endcase

          if (sktr#0)
            skltr=3
            sele rs1
            netrepl('skt,sklt',{sktr,skltr})
            if (rspra(2))
              ?str(przr, 1)+' TTN '+str(ttnr, 6)+' KOP '+str(kopr, 3)+' SKT '+str(sktr, 3)+' MN '+str(amnr, 6)+' коррекция mrsh '
            else
              ?str(przr, 1)+' TTN '+str(ttnr, 6)+' KOP '+str(kopr, 3)+' SKT '+str(sktr, 3)+' MN '+str(amnr, 6)+' новый mrsh '
            endif

            if (przr=1)
              rspra(1)
              sele rs1
              amnr=amn
              ??str(amnr, 6)
            endif

          else
            if (przr=1)
              ?str(przr, 1)+' TTN '+str(ttnr, 6)+' KOP '+str(kopr, 3)+' неопределен по vmrsh='+str(vmrshr, 2)
            endif

          endif

        else
          if (gnEnt=20)
            if (skr=300.or.skr=400.or.skr=500.or.skr=600)
              sktr=228
              skltr=3
            endif

          endif

          if (gnEnt=21)
            if (skr=700)
              sktr=232
              skltr=3
            endif

          endif

          if (sktr#0)
            sele rs1
            netrepl('skt,sklt',{sktr,skltr})
            if (rspra(2))
              ?str(przr, 1)+' TTN '+str(ttnr, 6)+' KOP '+str(kopr, 3)+' SKT '+str(sktr, 3)+' MN '+str(amnr, 6)+' коррекция default'
            else
              ?str(przr, 1)+' TTN '+str(ttnr, 6)+' KOP '+str(kopr, 3)+' SKT '+str(sktr, 3)+' MN '+str(amnr, 6)+' новый default '
            endif

            if (przr=1)
              rspra(1)
              sele rs1
              amnr=amn
              ??str(amnr, 6)
            endif

          else
            if (przr=1)
              ?str(przr, 1)+' TTN '+str(ttnr, 6)+' KOP '+str(kopr, 3)+' неопределен mrsh=0 sktr=0'
            endif

          endif

        endif

      endif

    endif

  endif

  return (.t.)
