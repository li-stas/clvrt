/***********************************************************
 * Модуль    : tost.prg
 * Версия    : 0.0
 * Автор     :
 * Дата      : 07/23/17
 * Изменен   :
 * Примечание: Текст обработан утилитой CF версии 2.02
 */

#include "common.ch"
#include "inkey.ch"
// Текущие остатки
if (gnArm#0)
else
  skr=gnSk
  ktr=gnKt
endif

if (gnScOut=0)
  clea
  aqstr=1
  aqst:={ "Просмотр", "Коррекция" }
  aqstr:=alert(" ", aqst)
  if (lastkey()=K_ESC)
    return
  endif

else
  aqstr=2
endif

netuse('setup')
sele setup
locate for ent=entr
fnatr='n'+alltrim(str(kkl, 8))
fidr='id'+alltrim(str(kkl, 8))
netuse('speng')
netuse('tara')
netuse('tmesto')
netuse('nei')
pathr=path_tr
netuse('soper',,, 1)
netuse('sgrp',,, 1)
if (netfile('rso1', 1))
  netuse('rso1',,, 1)
endif

set orde to tag t2
netuse('rs1',,, 1)
netuse('rs2',,, 1)
set orde to tag t6
netuse('pr1',,, 1)
set orde to tag t2
netuse('pr2',,, 1)
set orde to tag t6
netuse('tov',,, 1)
netuse('skl',,, 1)
if (ctov_r=1)
  netuse('tovm',,, 1)
  netuse('ctov')
  netuse('cgrp')
  netuse('kln')
  netuse('ntov')
  netuse('upak')
  netuse('kach')
endif

if (ctov_r=3)
  netuse('ctovk')
endif

netuse('nds')
netuse('st1sb')
netuse('stkg')
netuse('mkeepe')
netuse('crosid')
netuse('s_tag')
netuse('kps')
netuse('kpsmk')

if (gnScOut=0)
  set cons on
else
  set cons off
endif

set prin to ('tost'+alltrim(str(skr, 3))+'.txt')
set prin on

if (gnScOut=0.and.gnKt=0)
  clea
  aqqstr=2
  aqqst:={ "Да", "Нет" }
  // aqqstr:=alert("Проверять Ctov ? ",aqqst)
  if (lastkey()=K_ESC)
    return
  endif

else
  if (gnKt=0)
    aqqstr=1
  else
    aqqstr=0
  endif

endif

if (ctov_r=1.and.aqqstr=1)
  ?' CTOV '
  mntov_r=999999
  sele ctov
  set orde to tag t1
  go top
  while (!eof())
    if (mntov=mntov_r)
      ?str(mntov, 7)+' '+subs(nat, 1, 30)+' Двойник'
      if (aqstr=2)
        netdel()
      endif

      skip
      loop
    endif

    mntov_r=mntov
    natr=nat
    kg_r=int(mntov/10000)
    izgr=izg
    mkeepr=mkeep
    kspovor=kspovo
    m1tr=m1t
    sele ctov
    kodst1r=kodst1
    krstatr=krstat
    otr=ot
    kg_r=int(mntov_r/10000)
    ot_r=getfield('t1', 'kg_r', 'cgrp', 'ot')
    if (int(mntov_r/10000)>1.and.otr#ot_r)
      if (aqstr=2)
        netrepl('ot', { ot_r })
      endif

      otr=ot_r
    endif

    if (gnArnd#3)
      if (krstatr=0)
        if (kodst1r#0)
          kgstatr=getfield('t1', 'kodst1r', 'st1sb', 'kg')
          krstatr=getfield('t1', 'kgstatr', 'stkg', 'krstat')
          sele ctov
          if (krstatr#0)
            ?str(mntov, 7)+' '+subs(nat, 1, 30)+' '+str(krstatr, 4)
            if (aqstr=2)
              netrepl('krstat', { krstatr })
            endif

          endif

        endif

      endif

    endif

    cmkeepr=0
    sele ctov
    mark_r=getfield('t1', 'kg_r', 'cgrp', 'mark')
    if (mark_r=1)
      ntovr=getfield('t1', 'ctov->mnntov', 'ntov', 'ntov')
      ntovr=subs(ntovr, 1, 23)
      nupakr=getfield('t1', 'ctov->vupak', 'upak', 'nupak')
      nkachr=getfield('t1', 'ctov->kach', 'kach', 'nkach')
      nizg_r=getfield('t1', 'ctov->izg', 'kln', 'nkls')
      nat_r=alltrim(ntovr)+' '+iif(kei#keip, iif(vesp#0, iif(keip=800, str(vesp, 6, 3), kzero(vesp, 10, 3)), '')+iif(!empty(neip), alltrim(neip), '')+' ', '')+iif(!empty(nkachr), ' '+alltrim(nkachr), '')+iif(!empty(dop), ' '+alltrim(dop), '')+iif(!empty(nupakr), ' '+alltrim(nupakr), '')+' '+alltrim(nizg_r)
      if (natr#nat_r)
        ?str(mntov_r, 7)+' '+subs(natr, 1, 40)
        ?str(mntov_r, 7)+' '+subs(nat_r, 1, 40)
        if (aqstr=2)
          sele ctov
          netrepl('nat', { nat_r })
          natr=nat
        endif

      endif

    else
      if (empty(natr))
        nat_r=getfield('t1', 'sklr,mntov_r', 'tov', 'nat')
        sele ctov
        netrepl('nat', { nat_r })
        natr=nat
      endif

    endif

    sele tovm
    if (netseek('t1', 'sklr,mntov_r'))
      if (int(mntov_r/10000)>1.and.ot#otr)
        ?str(mntov, 7)+' '+subs(nat, 1, 30)+' TOVM'+str(ot, 2)+' CTOV '+str(otr, 2)+' OT'
        if (aqstr=2)
          netrepl('ot', { otr })
        endif

      endif

      if (izg#izgr)
        ?str(mntov, 7)+' '+subs(nat, 1, 30)+' TOVM'+str(izg, 7)+' CTOV '+str(izgr, 7)+' IZG'
        if (aqstr=2)
          netrepl('izg', { izgr })
        endif

      endif

      if (kspovo#kspovor)
        ?str(mntov, 7)+' '+subs(nat, 1, 30)+' TOVM'+str(kspovo, 4)+' CTOV '+str(kspovor, 4)+' KSPOVOR'
        if (aqstr=2)
          netrepl('kspovo', { kspovor })
        endif

      endif

      if (mkeep#mkeepr)
        ?str(mntov, 7)+' '+subs(nat, 1, 30)+' TOVM'+str(mkeep, 3)+' CTOV '+str(mkeepr, 7)+' MKEEP'
        if (aqstr=2)
          netrepl('mkeep', { mkeepr })
        endif

      endif

      if (nat#natr)
        if (aqstr=2)
          netrepl('nat', { natr })
        endif

      endif

      sele crosid
      if (!netseek('t1', 'mntov_r'))
        netadd()
        netrepl('mntov', { mntov_r })
        if (fieldpos(fidr)#0)
          netrepl(fidr, { mntov_r })
          netrepl(fnatr, { natr })
        endif

      else
        if (fieldpos(fidr)#0)
          if (&fidr=0)
            netrepl(fidr, { mntov_r })
          endif

          if (empty(&fnatr))
            netrepl(fnatr, { natr })
          endif

        endif

      endif

    endif

    sele ctov
    skip
  enddo

endif

if (ctov_r=1)
  ?' TOVM '
  sele tovm
  go top
  while (!eof())
    if (gnMskl=0)
      if (skl#gnSkl)
        netdel()
      endif

    endif

    mntovr=mntov
    mntovt_r=mntovt
    mntovc_r=mntovc

    armod_r=armod
    arprim_r=arprim
    arnpp_r=arnpp
    arvid_r=arvid
    nei_r=nei
    kspovo_r=kspovo
    m1t_r=m1t

    sele ctov
    if (netseek('t1', 'mntovr'))
      armod_rr=armod
      arprim_rr=arprim
      arnpp_rr=arnpp
      arvid_rr=arvid
      nei_rr=nei
      kspovo_rr=kspovo
      m1t_rr=m1t
      if (mntovt=0.and.mntovt_r#0)
        ?str(sklr, 7)+' '+str(mntovr, 7)+' CTOV->MNTOVT=0'
        if (aqstr=2)
          netrepl('mntovt', { mntovt_r })
        endif

      endif

      if (mntovc=0.and.mntovc_r#0)
        ?str(sklr, 7)+' '+str(mntovr, 7)+' CTOV->MNTOVC=0'
        if (aqstr=2)
          netrepl('mntovc', { mntovc_r })
        endif

      endif

      if (mntovt=0)
        netrepl('mntovt', { mntov })
      endif

      mntovt_rr=mntovt
      mntovc_rr=mntovc

      if (mntovt_r#mntovt_rr)
        ?str(sklr, 7)+' '+str(mntovr, 7)+' MNTOVT '+str(mntovt_r, 7)+' -> '+str(mntovt_rr, 7)+'  TOVM'
        if (aqstr=2)
          sele tovm
          netrepl('mntovt', { mntovt_rr })
        endif

      endif

      if (mntovc_r#mntovc_rr)
        ?str(sklr, 7)+' '+str(mntovr, 7)+' MNTOVTC '+str(mntovc_r, 7)+' -> '+str(mntovc_rr, 7)+'  TOVM'
        if (aqstr=2)
          sele tovm
          netrepl('mntovc', { mntovc_rr })
        endif

      endif

      if (!empty(armod_rr).and.armod_rr#armod_r)
        if (aqstr=2)
          sele tovm
          netrepl('armod', { armod_rr })
        endif

      endif

      if (!empty(nei_rr).and.nei_rr#nei_r)
        if (aqstr=2)
          sele tovm
          netrepl('nei', { nei_rr })
        endif

      endif

      if (!empty(arvid_rr).and.arvid_rr#arvid_r)
        if (aqstr=2)
          sele tovm
          netrepl('arvid', { arvid_rr })
        endif

      endif

      if (!empty(arprim_rr).and.arprim_rr#arprim_r)
        if (aqstr=2)
          sele tovm
          netrepl('arprim', { arprim_rr })
        endif

      endif

      if (!empty(arnpp_rr).and.arnpp_rr#arnpp_r)
        if (aqstr=2)
          sele tovm
          netrepl('arnpp', { arnpp_rr })
        endif

      endif

      if (!empty(kspovo_rr).and.kspovo_rr#kspovo_r)
        if (aqstr=2)
          sele tovm
          netrepl('kspovo', { kspovo_rr })
        endif

      endif

      if (!empty(m1t_rr).and.m1t_rr#m1t_r)
        if (aqstr=2)
          sele tovm
          netrepl('m1t', { m1t_rr })
        endif

      endif

    endif

    sele tovm
    skip
  enddo

endif

if (ctov_r=3)
  ?' CTOV '
  ktl_r=99999999
  sele ctovk
  set orde to tag t1
  go top
  while (!eof())
    if (ktl=ktl_r)
      ?str(ktl, 7)+' '+subs(nat, 1, 30)+' Двойник'
      if (aqstr=2)
        netdel()
      endif

      skip
      loop
    endif

    ktl_r=ktl
    sele ctovk
    skip
  enddo

endif

if (ctov_r=1)
  ?'PR2-TOV;RS2->TOV'
  sele pr2
  go top
  nMax:=LASTREC(); IF gnScOut = 0; Termo((nCurent:=0), nMax, MaxRow(), 4); endif
  while (!eof())
    ktlr=ktl
    mntovr=mntov
    mnr=mn
    zenr=zen
    zenbbr=zenbb
    zenbtr=zenbt
    sklr=getfield('t2', 'mnr', 'pr1', 'skl')
    vor=getfield('t2', 'mnr', 'pr1', 'vo')
    if (vor=9.or.vor=10.and.arndr=2)
      postr=getfield('t2', 'mnr', 'pr1', 'kps')
    else
      postr=0
    endif

    sele tov
    if (!netseek('t1', 'sklr,ktlr'))
      sele ctov
      if (netseek('t1', 'mntovr'))
        if (aqstr=2)
          arec:={}
          getrec()
          sele tov
          netadd()
          putrec()
          netrepl('skl,ktl,osn,osv,osf,osfo,osfm,opt', { sklr, ktlr, 0, 0, 0, 0, 0, zenr })
        endif

        ?str(sklr, 7)+' '+str(ktlr, 9)+' '+' PR Нет в TOV'
      endif

    else
      if (vor=9.or.vor=10.and.arndr=2).and.postr#0.and.post#postr
        netrepl('post', { postr })
      endif

      if (vor=9)
        if (cenbb#zenbbr)
          ?str(sklr, 7)+' '+str(ktlr, 9)+' '+'cenbb'+' '+str(cenbb, 10, 3)+'->'+str(zenbbr, 10, 3)
          netrepl('cenbb', { zenbbr })
        endif

        if (cenbt#zenbtr)
          ?str(sklr, 7)+' '+str(ktlr, 9)+' '+'cenbt'+' '+str(cenbt, 10, 3)+'->'+str(zenbtr, 10, 3)
          netrepl('cenbt', { zenbtr })
        endif

      endif

      if (gnTpstpok#0)
        if (mntov#mntovr)
          ?str(sklr, 7)+' '+str(ktlr, 9)+' '+'tov.mntov'+' '+str(mntov, 7)+'->'+str(mntovr, 7)
          netrepl('mntov', { mntovr })
        endif

      endif

    endif

    sele pr2
    skip
    IF gnScOut = 0; Termo((++nCurent), nMax, MaxRow(), 4); endif
  enddo

  IF gnScOut = 0; Termo(nMax, nMax, MaxRow(), 4); endif

  sele rs2
  go top
  nMax:=LASTREC(); IF gnScOut = 0; Termo((nCurent:=0), nMax, MaxRow(), 4); endif
  while (!eof())
    ktlr=ktl
    mntovr=mntov
    ttnr=ttn
    sklr=getfield('t1', 'ttnr', 'rs1', 'skl')
    kvpr=kvp
    if (kvpr=0)
      ?str(sklr, 7)+' '+str(ktlr, 9)+' '+str(kvpr, 10, 3)+' '+' RS2 kvp=0'
      netdel()
      skip
      loop
    endif

    sele tov
    if (!netseek('t1', 'sklr,ktlr'))
      sele ctov
      if (netseek('t1', 'mntovr'))
        if (aqstr=2)
          arec:={}
          getrec()
          sele tov
          netadd()
          putrec()
          netrepl('skl,ktl,osn,osv,osf,osfo,osfm', { sklr, ktlr, 0, 0, 0, 0, 0 })
        endif

        ?str(sklr, 7)+' '+str(ktlr, 9)+' '+' RS Нет в TOV'
      endif

    else
      if (gnTpstpok#0)
        if (mntov#mntovr)
          ?str(sklr, 7)+' '+str(ktlr, 9)+' '+'tov.mntov'+' '+str(mntov, 7)+'->'+str(mntovr, 7)
          netrepl('mntov', { mntovr })
        endif

      endif

    endif

    sele rs2
    skip
    IF gnScOut = 0; Termo((++nCurent), nMax, MaxRow(), 4); endif
  enddo

endif

IF gnScOut = 0; Termo(nMax, nMax, MaxRow(), 4); endif

skldoc()

?' TOV '
sele tov
go top
nMax:=LASTREC(); IF gnScOut = 0; Termo((nCurent:=0), nMax, MaxRow(), 4); endif
skl_r=9999999
ktl_r=999999999
while (!eof())
  if (skl=0)
    ?str(skl, 7)+' '+str(ktl, 9)+' '+subs(nat, 1, 30)+' SKL=0'
    if (aqstr=2)
      netdel()
    endif

    skip
    IF gnScOut = 0; Termo((++nCurent), nMax, MaxRow(), 4); endif
    loop
  endif

  if (skl=skl_r.and.ktl=ktl_r)
    ?str(skl, 7)+' '+str(ktl, 9)+' '+subs(nat, 1, 30)+' Двойник'
    if (aqstr=2)
      netdel()
    endif

    skip
    IF gnScOut = 0; Termo((++nCurent), nMax, MaxRow(), 4); endif
    loop
  endif

  kg_r=int(mntov/10000)
  if (ctov_r=1)
    if (!netseek('t1', 'kg_r', 'sgrp'))
      sele cgrp
      if (netseek('t1', 'kg_r'))
        arec:={}
        getrec()
        sele sgrp
        netadd()
        putrec()
        netunlock()
        ?'Добавлена группа '+str(kg_r, 3)+' в SGRP'
      endif

    endif

  endif

  sele tov
  ktl_r=ktl
  skl_r=skl
  sklr=skl
  sele skl
  if (!netseek('t1', 'sklr'))
    netadd()
    netrepl('skl', { sklr })
  endif

  sele tov
  otr=ot
  mntovr=mntov
  mntovtr=mntov
  mntovcr=mntovc
  natr=subs(nat, 1, 30)
  nat_r=nat
  vesp_r=vesp

  armod_r=armod
  arvid_r=arvid
  arprim_r=arprim
  arnpp_r=arnpp

  store 0 to prprir, rsprir
  sele tov
  arec:={}
  getrec()
  if (ctov_r=1)
    natr=''
    sele ctov
    if (netseek('t1', 'mntovr'))
      natr=nat
      grpr=grp
      kger=kge
      mnntovr=mnntov
      kachr=kach
      keir=kei
      neir=nei
      if (empty(neir))
        neir=getfield('t1', 'keir', 'nei', 'nei')
        netrepl('nei', { neir })
      endif

      keipr=keip
      vespr=vesp
      izgr=izg
      dopr=dop

      armod_rr=armod
      arvid_rr=arvid
      arprim_rr=arprim
      arnpp_rr=arnpp

      if (natr#nat_r.or.vesp_r#vespr)
        sele tov
        if (aqstr=2)
          netrepl('nat,grp,kge,mnntov,kach,kei,keip,vesp,izg,dop', { natr, grpr, kger, mnntovr, kachr, keir, keipr, vespr, izgr, dopr })
        endif

      endif

      if (aqstr=2)
        sele tov
        netrepl('nei', { neir })
      endif

      if (!empty(armod_rr).and.armod_rr#armod_r)
        if (aqstr=2)
          sele tov
          netrepl('armod', { armod_rr })
        endif

      endif

      if (!empty(arvid_rr).and.arvid_rr#arvid_r)
        if (aqstr=2)
          sele tov
          netrepl('arvid', { arvid_rr })
        endif

      endif

      if (!empty(arprim_rr).and.arprim_rr#arprim_r)
        if (aqstr=2)
          sele tov
          netrepl('arprim', { arprim_rr })
        endif

      endif

      if (!empty(arnpp_rr).and.arnpp_rr#arnpp_r)
        if (aqstr=2)
          sele tov
          netrepl('arnpp', { arnpp_rr })
        endif

      endif

    endif

    sele tovm
    if (!netseek('t1', 'sklr,mntovr',,, 1))
      set orde to
      locate for skl=sklr.and.mntov=mntovr
      if (!foun())
        ?str(sklr, 7)+' '+str(ktlr, 9)+' '+str(mntovr, 7)+' '+natr+' Не найден в TOVM'
        if (aqstr=2)
          netadd()
          putrec()
          netrepl('ktl', { 0 })
        endif

      else
        ?str(sklr, 7)+' '+str(ktlr, 9)+' '+str(mntovr, 7)+' '+natr+' Индекс в TOVM'
        creci()
      endif

      set orde to tag t1
    else
      if (!empty(natr))
        if (nat#natr.or.vesp#vespr)
          if (aqstr=2)
            sele tovm
            netrepl('nat,grp,kge,mnntov,kach,kei,keip,vesp,izg,dop', { natr, grpr, kger, mnntovr, kachr, keir, keipr, vespr, izgr, dopr })
          endif

        endif

      endif

    endif

  endif

  if (ctov_r=3)
    sele ctovk
    if (!netseek('t1', 'ktlr'))
      set orde to
      locate for ktl=ktlr
      if (!foun())
        ?str(ktlr, 9)+' '+natr+' Не найден в CTOVK'
        if (aqstr=2)
          netadd()
          putrec()
          netrepl('skl,osn,osv,osf,osfo,osvo', { 0, 0, 0, 0, 0, 0 })
        endif

      else
        ?str(ktlr, 9)+' '+natr+' Индекс в CTOVK'
      endif

      set orde to tag t1
    endif

  endif

  sele tov
  otvr=otv
  //   if otv=1
  //      skip
  //      loop
  //   endif
  sele tov
  if (!reclock(1))
    ?str(sklr, 7)+' '+str(ktlr, 9)+' '+natr+' '+' Блокирован'
    sele tov
    skip
    IF gnScOut = 0; Termo((++nCurent), nMax, MaxRow(), 4); endif
    loop
  endif

  ktlr=ktl
  mntovr=mntov
  mntovtr=mntovt
  mntovcr=mntovc
  otr=ot
  kg_r=int(ktlr/1000000)
  if (kg_r>1.and.ctov_r=1)
    ot_r=getfield('t1', 'kg_r', 'sgrp', 'ot')
    sele tov
    if (aqstr=2)
      netrepl('ot', { ot_r })
    endif

  endif

  sele tov
  k1tr=k1t
  if (ktlr=k1tr)
    if (aqstr=2)
      netrepl('k1t', { 0 }, 1)
    endif

    ?str(sklr, 7)+' '+str(ktlr, 9)+' '+natr+' '+' Привязка тары'
  endif

  m1tr=m1t
  sklr=skl
  prmnr=prmn
  mkeepr=mkeep
  brandr=brand
  cmkeepr=mkeepr
  cmntovtr=mntovtr
  cmntovcr=mntovcr
  izgr=izg
  cizgr=izgr
  if (ctov_r=1)
    sele ctov
    if (netseek('t1', 'mntovr'))
      cizgr=izg
      cmkeepr=mkeep
      cbrandr=brand
      cmntovtr=mntovt
      cmntovcr=mntovc
    else
      cizgr=0
      cmkeepr=0
      cbrandr=0
      cmntovtr=0
      cmntovcr=0
    endif

    sele tov
  endif

  if (izgr#cizgr.and.cizgr#0)
    izgr=cizgr
    netrepl('izg', { izgr }, 1)
  endif

  if (mkeepr#cmkeepr.and.cmkeepr#0)
    mkeepr=cmkeepr
    netrepl('mkeep', { mkeepr }, 1)
  endif

  if (mntovtr#cmntovtr)
    ?str(ktlr, 9)+' '+str(mntovtr, 7)+'->'+str(cmntovtr)
    mntovtr=cmntovtr
    netrepl('mntovt', { mntovtr }, 1)
  endif

  if (mntovcr#cmntovcr)
    ?str(ktlr, 9)+' '+str(mntovcr, 7)+'->'+str(cmntovcr)
    mntovcr=cmntovcr
    netrepl('mntovc', { mntovcr }, 1)
  endif

  if (ctov_r=1)
    if (brandr#cbrandr.and.cbrandr#0)
      brandr=cbrandr
      netrepl('brand', { brandr }, 1)
    endif

  endif

  sele tov
  osnr=round(osn, 3)
  osvr=round(osv, 3)
  osfr=round(osf, 3)
  osfmr=round(osfm, 3)
  osfor=round(osfo, 3)
  if (fieldpos('osfop')#0)
    osfopr=round(osfop, 3)
  else
    osfopr=0
  endif

  optr=ROUND(opt, 3)
  store 0 to pkfr, pkfmr, pkfor, pkfopr, rkfr, rkvpr, pkfoor, rkvpor
  sele pr2
  if (netseek('t6', 'ktlr'))
    while (ktl=ktlr)
      kfr=kf
      mnr=mn
      ktlpr=ktlp
      mntovr=mntov
      zenr=round(zen, 3)
      vor=getfield('t2', 'mnr', 'pr1', 'vo')
      if (vor=9.or.vor=3.and.gnKt=1).and.zenr#optr.or.vor#9.and.optr=0
        sele tov
        if (zenr#0)
          netrepl('opt', { zenr }, 1)
        endif

        sele pr2
      endif

      if (fieldpos('mntovp')#0)
        if (mntovp=0)
          if (ktlr=ktlpr)
            netrepl('mntovp', { mntovr })
          else
            mntovpr=getfield('t1', 'sklr,ktlpr', 'tov', 'mntov')
            if (mntovpr#0)
              netrepl('mntovp', { mntovpr })
            endif

          endif

        endif

      endif

      if (izg#izgr)
        ?str(mnr, 6)+' '+str(ktl, 9)+' pr2->izg '+str(izg, 7)+' tov->izg '+str(izgr, 7)
        if (aqstr=2)
          netrepl('izg', { izgr })
        endif

      endif

      sele pr1
      if (netseek('t2', 'mnr',,, 1))
        if (prz=1)
          if (gnMskl=0)
            pkfr=pkfr+kfr
            prprir=1
          else
            if (skl=sklr)
              pkfr=pkfr+kfr
              prprir=1
            endif

          endif

        else
          if (gnMskl=0)
            pkfmr=pkfmr+kfr
            prprir=1
          else
            if (skl=sklr)
              pkfmr=pkfmr+kfr
              prprir=1
            endif

          endif

          if (kop=188)
            if (gnMskl=0)
              pkfopr=pkfopr+kfr
              prprir=1
            else
              if (skl=sklr)
                pkfopr=pkfopr+kfr
                prprir=1
              endif

            endif

          endif

        endif

      else
        sele pr2
        netdel()
      endif

      sele pr2
      skip
    enddo

  endif

  sele rs2
  if (netseek('t6', 'ktlr'))
    while (ktl=ktlr)
      kvpr=kvp
      ttnr=ttn
      ktlpr=ktlp
      mntovr=mntov
      if (fieldpos('mntovp')#0)
        if (mntovp=0)
          if (ktlr=ktlpr)
            netrepl('mntovp', { mntovr })
          else
            mntovpr=getfield('t1', 'sklr,ktlpr', 'tov', 'mntov')
            if (mntovpr#0)
              if (mntovp#mntovpr)
                netrepl('mntovp', { mntovpr })
              endif

            endif

          endif

        endif

      endif

      if (fieldpos('bsvp')#0)
        if (roun(bsvp, 2)#roun(bzen*kvp, 2))
          netrepl('bsvp', { roun(bzen*kvp, 2) })
        endif

        if (roun(xsvp, 2)#roun(xzen*kvp, 2))
          netrepl('xsvp', { roun(xzen*kvp, 2) })
        endif

        if (round(xzenp, 2)#optr)
          netrepl('xzenp', { optr })
        endif

      endif

      if (fieldpos('mzen')#0)
        if (ctov_r=1)
          mzenr=getfield('t1', 'mntovr', 'ctov', 'c24')
        else
          mzenr=getfield('t1', 'sklr,ktlr', 'tov', 'c24')
        endif

        if (mzen=0)
          if (mzenr#0)
            netrepl('mzen', { mzenr })
          endif

        endif

      endif

      if (izg#izgr)
        ?str(ttnr, 6)+' ttn->izg '+str(izg, 7)+' tov->izg '+str(izgr, 7)
        if (aqstr=2)
          if (izg#izgr)
            netrepl('izg', { izgr })
          endif

        endif

      endif

      sele rs1
      if (netseek('t1', 'ttnr',,, 1))
        dopr=dop
        dotr=dot
        vor=vo
        przr=prz
        kopr=kop
        kopir=kopi
        kplr=kpl
        kpvr=kpv
        przr=prz
        qr=kop-100
        nofr=getfield('t1', '0,1,vor,qr', 'soper', 'nof')
        if (przr=1)
          if (gnMskl=0)
            rkfr=rkfr+kvpr
            rsprir=1
          else
            if (sklr=skl)
              rkfr=rkfr+kvpr
              rsprir=1
            endif

          endif

        else
          if (gnMskl=0)
            rkvpr=rkvpr+kvpr
            rsprir=1
          else
            if (sklr=skl)
              rkvpr=rkvpr+kvpr
              rsprir=1
            endif

          endif

          if (!empty(dopr))//.and.dop<=gdTd //.or.!empty(dot)
            if (gnMskl=0)
              rkvpor=rkvpor+kvpr
            else
              if (sklr=skl)
                rkvpor=rkvpor+kvpr
              endif

            endif

          endif

        endif

        sele rs2
        if (!empty(dopr))//.or.!empty(dot)
          if (fieldpos('prosfo')#0)
            if (prosfo=0)
              if (aqstr=2)
                netrepl('prosfo', { 1 })
              endif

              if (gnSkotv=0)
                ?str(ttnr, 6)+' '+str(ktlr, 9)+' prosfo '
              endif

            endif

          endif

        else
          if (fieldpos('prosfo')#0)
            if (prosfo=1)
              if (aqstr=2)
                netrepl('prosfo', { 0 })
              endif

              if (gnSkotv=0)
                ?str(ttnr, 6)+' '+str(ktlr, 9)+' prosfo '
              endif

            endif

          endif

        endif

        if (int(ktl/1000000)<2.and.nofr=1)
          if (zen=0.and.(bzen#0.or.xzen#0))
            if (aqstr=2)
              netrepl('bzen,xzen', { 0, 0 })
            endif

            ?str(ttnr, 6)+' '+str(ktlr, 9)+' bzen=0,xzen=0 '
          endif

        endif

      else
        sele rs2
        netdel()
      endif

      sele rs2
      skip
    enddo

  endif

  osf_r=ROUND(osnr+pkfr-rkfr, 3)
  osfm_r=ROUND(osnr+pkfr+pkfmr-rkfr-rkvpr, 3)
  osv_r=ROUND(osf_r-rkvpr, 3)
  osfo_r=ROUND(osnr+pkfr-rkfr-rkvpor, 3)
  osfop_r=ROUND(osnr+pkfr-rkfr-rkvpor+pkfopr, 3)
  sele tov
  if (otvr=0)
    if (osfr#osf_r.or.osfor#osfo_r.or.osfopr#osfop_r.or.osvr#osv_r.or.osfmr#osfm_r.or.osfr<0.and.!(gnSk=140.or.gnSk=141).or.osf_r<0.and.!(gnSk=140.or.gnSk=141).or.osfor<0.and.!(gnSk=140.or.gnSk=141).or.osfo_r<0.and.!(gnSk=140.or.gnSk=141).or.osvr<0.and.!(Skr=140.or.Skr=141).or.osv_r<0.and.!(Skr=140.or.Skr=141))
      natr=subs(nat, 1, 30)
      if (osfr=osf_r.and.osvr=osv_r)
        set cons off
      endif

      ?str(sklr, 7)+' '+str(ktlr, 9)+' '+str(sklr, 4)+' '+natr+' '+str(optr, 10, 3)
      ?'V '+iif(osvr#osv_r.or.osv_r<0.and.!(Skr=140.or.Skr=141), str(osvr, 10, 3)+' '+str(osv_r, 10, 3), space(10)+' '+space(10))+' F '+iif(osfr#osf_r.or.osfr<0.and.!(Skr=140.or.Skr=141).or.osf_r<0.and.!(Skr=140.or.Skr=141), str(osfr, 10, 3)+' '+str(osf_r, 10, 3), space(10)+' '+space(10))
      if (aqstr=2)
        netrepl('osf,osv,osfm', { osf_r, osv_r, osfm_r }, 1)
      endif

      if (fieldpos('osfo')#0)
        if (osfor#osfo_r)
          ??' FO '+iif(osfor#osfo_r.or.osfo_r<0.and.!(Skr=140.or.Skr=141), str(osfor, 10, 3)+' '+str(osfo_r, 10, 3), space(10)+' '+space(10))
          if (aqstr=2)
            netrepl('osfo', { osfo_r }, 1)
          endif

        endif

      endif

      if (fieldpos('osfop')#0)
        if (osfopr#osfop_r)
          ??' FOP '+iif(osfopr#osfop_r.or.osfop_r<0.and.!(Skr=140.or.Skr=141), str(osfopr, 10, 3)+' '+str(osfop_r, 10, 3), space(10)+' '+space(10))
          if (aqstr=2)
            netrepl('osfop', { osfop_r }, 1)
          endif

        endif

      endif

      set cons on
    endif

  endif

  sele tov
  if (otv=0.and.osnr=0.and.prprir=0.and.rsprir=0)
    netdel()
  endif

  netunlock()
  skip
  IF gnScOut = 0; Termo((++nCurent), nMax, MaxRow(), 4); endif
enddo

IF gnScOut = 0; Termo(nMax, nMax, MaxRow(), 4); endif

if (ctov_r=1)
  sele tov
  set orde to tag t5
  sele tovm
  go top
  ?'TOVM->TOV'
  mntov_r=9999999
  skl_r=9999999
  while (!eof())
    sele tovm
    if (!reclock(1))
      ?str(skl, 7)+' '+str(mntov, 7)+' '+subs(nat, 1, 30)+' Блокирован'
      skip
      loop
    endif

    if (skl=0)
      ?str(skl, 7)+' '+str(mntov, 7)+' '+subs(nat, 1, 30)+' SKL=0'
      if (aqstr=2)
        netdel()
      endif

      skip
      loop
    endif

    if (mntov=0)
      ?str(skl, 7)+' '+str(mntov, 7)+' '+subs(nat, 1, 30)+' MNTOV=0'
      if (aqstr=2)
        netdel()
      endif

      skip
      loop
    endif

    if (skl=skl_r.and.mntov=mntov_r)
      ?str(skl, 7)+' '+str(mntov, 7)+' '+subs(nat, 1, 30)+' Двойник'
      if (aqstr=2)
        netdel()
      endif

      skip
      loop
    endif

    mntov_r=mntov
    skl_r=skl
    sklr=skl
    mntovr=mntov
    osnr=round(osn, 3)
    osvr=round(osv, 3)
    osfr=round(osf, 3)
    osfor=round(osfo, 3)
    if (fieldpos('osfop')#0)
      osfopr=round(osfop, 3)
    else
      osfopr=0
    endif

    osfmr=round(osfm, 3)
    osvor=round(osvo, 3)
    natr=nat
    m1tr=m1t
    sele tov
    set orde to tag t5
    store 0 to osn_r, osv_r, osf_r, osfm_r, osvo_r, osfo_r, osfop_r
    if (netseek('t5', 'sklr,mntovr'))
      while (skl=sklr.and.mntov=mntovr)
        osn_r=osn_r+osn
        if (otv=0)
          osv_r=osv_r+osv
          osf_r=osf_r+osf
          osfm_r=osfm_r+osfm
          osfo_r=osfo_r+osfo
          if (fieldpos('osfop')#0)
            osfop_r=osfop_r+osfop
          endif

        else
          osvo_r=osvo_r+osvo
        endif

        skip
      enddo

    else
      ?str(sklr, 7)+' '+str(mntovr, 7)+' '+subs(natr, 1, 30)+' Нет в TOV'
      //         sele tovm
      //         if aqstr=2
      //            netdel()
      //            netunlock()
      //         else
      //            netunlock()
      //         endif
      //         skip
    //         loop
    endif

    sele tovm
    if (round(osn_r, 3)#osnr.or.round(osv_r, 3)#osvr.or.round(osf_r, 3)#osfr.or.round(osfm_r, 3)#osfmr.or.round(osvo_r, 3)#osvor.or.round(osfo_r, 3)#osfor.or.round(osfop_r, 3)#osfopr)
      if (round(osv_r, 3)=osvr.and.round(osf_r, 3)=osfr)
        set cons off
      endif

      ?str(sklr, 7)+' '+str(mntovr, 7)+' '+natr
      ?' N '+str(osnr, 10, 3)+' '+str(osn_r, 10, 3)+       ;
       ' V '+str(osvr, 10, 3)+' '+str(osv_r, 10, 3)+       ;
       ' F '+str(osfr, 10, 3)+' '+str(osf_r, 10, 3)+       ;
       ' FO '+str(osfor, 10, 3)+' '+str(osfo_r, 10, 3)+    ;
       ' FOP '+str(osfopr, 10, 3)+' '+str(osfop_r, 10, 3)+ ;
       ' O '+str(osvor, 10, 3)+' '+str(osvo_r, 10, 3)
      set cons on
    endif

    if (round(osn_r, 3)#osnr)
      if (aqstr=2)
        netrepl('osn', { osn_r }, 1)
      endif

    endif

    if (round(osv_r, 3)#osvr)
      if (aqstr=2)
        netrepl('osv', { osv_r }, 1)
      endif

    endif

    if (round(osf_r, 3)#osfr)
      if (aqstr=2)
        netrepl('osf', { osf_r }, 1)
      endif

    endif

    if (round(osfm_r, 3)#osfmr)
      if (aqstr=2)
        netrepl('osfm', { osfm_r }, 1)
      endif

    endif

    if (round(osfo_r, 3)#osfor)
      if (aqstr=2)
        netrepl('osfo', { osfo_r }, 1)
      endif

    endif

    if (fieldpos('osfop')#0)
      if (round(osfop_r, 3)#osfopr)
        if (aqstr=2)
          netrepl('osfop', { osfop_r }, 1)
        endif

      endif

    endif

    if (round(osvo_r, 3)#osvor)
      if (aqstr=2)
        netrepl('osvo', { osvo_r }, 1)
      endif

    endif

    sele tovm
    netunlock()
    skip
  enddo

  ?'TOV->TOVM,TOV->CTOV'
  sele tov
  set orde to tag t1
  go top
  while (!eof())
    sklr=skl
    mntovr=mntov
    mntovtr=mntovt
    mntovcr=mntovc
    k1tr=k1t
    natr=subs(nat, 1, 30)
    ktlr=ktl
    nat_r=nat
    krstatr=krstat
    rctovr=recn()
    sele ctov
    if (!netseek('t1', 'mntovr'))
      ?str(sklr, 7)+' '+str(ktlr, 9)+' '+str(mntovr, 7)+' '+natr+' Не найден в CTOV'
      if (aqstr=2)
        sele tov
        go rctovr
        arec:={}
        getrec()
        sele ctov
        netadd()
        putrec()
        netrepl('skl,ktl,osn,osv,osf,osfm,osvo,osfo,k1t', { 0, 0, 0, 0, 0, 0, 0, 0, 0 })
        if (fieldpos('osfop')#0)
          netrepl('osfop', { 0 })
        endif

      endif

    else
      mntovtr=mntovt
      mntovcr=mntovc
      if (gnEnt=21.and.gnArnd=3)
        if (krstat=0)
          ?str(sklr, 7)+' '+str(ktlr, 9)+' KRSTAT '+str(krstat, 4)+' -> '+str(krstatr, 4)+'  CTOV'
          netrepl('krstat', { krstatr })
        endif

      endif

    endif

    sele tov
    if (!(gnEnt=21.and.gnArnd=3))
      if (k1tr=0)
        sele tov
        skip
        loop
      endif

      m1tr=m1t
      m1t_r=getfield('t1', 'sklr,k1tr', 'tov', 'mntov')
      if (m1t_r=0)        // Привязанной тары нет
        sele tov
        if (aqstr=2)
          netrepl('k1t,m1t', { 0, 0 })
        endif

        ?str(sklr, 7)+' '+str(ktlr, 9)+' '+'TOV Нет привязанной тары'
        skip
        loop
      endif

      if (m1tr#m1t_r)
        sele tov
        if (aqstr=2)
          netrepl('m1t', { m1t_r })
        endif

        ?'TOV '+str(sklr, 7)+' '+str(ktlr, 9)+' Т  m1t '+str(m1tr, 7)+' Р m1t '+str(m1t_r, 7)
      endif

    endif

    sele tovm
    if (netseek ('t1', 'sklr,mntovr'))
      if (!(gnEnt=21.and.gnArnd=3))
        m1tr=m1t
        if (m1tr#m1t_r)
          if (aqstr=2)
            netrepl('m1t', { m1t_r })
          endif

          ?'TOVM '+str(sklr, 7)+' '+str(mntovr, 7)+' Т  m1t '+str(m1tr, 7)+' Р m1t '+str(m1t_r, 7)
        endif

      endif

      if (nat#nat_r)
        ?str(sklr, 7)+' '+str(ktlr, 9)+' '+str(mntovr, 7)+' '+nat_r+' '+'  TOV'
        ?str(sklr, 7)+' '+str(ktlr, 9)+' '+str(mntovr, 7)+' '+nat+'  TOVM'
      endif

      if (mntovt#mntovtr)
        ?str(sklr, 7)+' '+str(ktlr, 9)+' MNTOVTR '+str(mntovt, 7)+' -> '+str(mntovtr, 7)+'  TOVM'
        if (aqstr=2)
          netrepl('mntovt', { mntovtr })
        endif

      endif

      if (mntovc#mntovcr)
        ?str(sklr, 7)+' '+str(ktlr, 9)+' MNTOVTС '+str(mntovc, 7)+' -> '+str(mntovcr, 7)+'  TOVM'
        if (aqstr=2)
          netrepl('mntovc', { mntovcr })
        endif

      endif

      if (gnEnt=21.and.gnArnd=3)
        if (krstat=0)
          ?str(sklr, 7)+' '+str(ktlr, 9)+' KRSTAT '+str(krstat, 4)+' -> '+str(krstatr, 4)+'  TOVM'
          netrepl('krstat', { krstatr })
        endif

      endif

    endif

    sele tov
    go rctovr
    skip
  enddo

endif

?'PR2->TOV'
sele pr2
go top
while (!eof())
  mnr=mn
  ktlr=ktl
  mntovr=mntov
  sklr=getfield('t2', 'mnr', 'pr1', 'skl')
  sele tov
  if (!netseek('t1', 'sklr,ktlr'))
    ?str(sklr, 7)+' '+str(ktlr, 9)+' Нет в TOV'
  endif

  sele pr2
  skip
enddo

nuse()
if (gnScOut=0)
  set prin off
  set prin to
  if (gnOut=2)
    set prin to txt.txt
  endif

else
  set prin off
  set prin to
endif

wmess('Проверка закончена', 0)

/************** */
function skldoc()
  /************** */
  ?'Приход'
  sele pr1
  go top
  while (!eof())
    if (!reclock(1))
      sele pr1
      skip
      loop
    endif

    if (fieldpos('dtmod')#0)
      if (empty(dtmod))
        if (!empty(dpr))
          dtmodr=dpr
          tmmodr=tpr
        else
          dtmodr=ddc
          tmmodr=tdc
        endif

        netrepl('dtmod,tmmod', { dtmodr, tmmodr }, 1)
      endif

    endif

    if (kta#0)
      if (ktas=0)
        ktasr=getfield('t1', 'pr1->kta', 's_tag', 'ktas')
        if (ktasr#0)
          if (ktasr=getfield('t1', 'ktasr', 's_tag', 'ktas'))
            if (entr=getfield('t1', 'ktasr', 's_tag', 'ent'))
              netrepl('ktas', { ktasr }, 1)
            endif

          endif

        endif

      endif

    endif

    sele pr1
    netunlock()
    skip
  enddo

  ?'Расход'
  sele rs1
  go top
  while (!eof())
    ttnr=ttn
    if (ttnr=0)
      if (aqstr=2)
        netdel()
        skip
        loop
      endif

    endif

    //   if fieldpos('prkpk')#0
    //      if !empty(docguid).or.docid#0.or.!empty(getfield('t1','rs1->ttnp','rs1','docguid'))
    //         netrepl('prkpk','1')
    //      endif
    //   endif
    rcrs1r=recn()
    skip
    if (eof())
      exit
    endif

    if (ttn=ttnr)
      ?str(ttnr, 6)+' '+'Двойник'
      if (aqstr=2)
        netdel()
        go rcrs1r
        loop
      endif

    else
      loop
    endif

    sele rs1
    skip
  enddo

  sele rs1
  go top
  while (!eof())
    if (!reclock(1))
      sele rs1
      skip
      loop
    endif

    if (fieldpos('dtmod')#0)
      if (empty(dtmod))
        if (!empty(dot))
          dtmodr=dot
          tmmodr=tot
        else
          if (!empty(dop))
            dtmodr=dop
            tmmodr=top
          else
            if (!empty(dvp))
              dtmodr=dvp
              tmmodr=tdc
            else
              dtmodr=ddc
              tmmodr=tdc
            endif

          endif

        endif

        netrepl('dtmod,tmmod', { dtmodr, tmmodr }, 1)
      endif

    endif

    if (fieldpos('dtot')#0)
      if (empty(dtot))
        if (!empty(dop))
          dtotr=dop
          tmotr=top
          netrepl('dtot,tmot', { dtotr, tmotr }, 1)
        endif

      endif

    endif

    if (fieldpos('tmesto')#0)
      if (empty(tmesto))
        tmestor=getfield('t2', 'rs1->nkkl,rs1->kpv', 'tmesto', 'tmesto')
        netrepl('tmesto', { tmestor }, 1)
      endif

    endif

    if (kta#0)
      if (ktas=0)
        ktasr=getfield('t1', 'rs1->kta', 's_tag', 'ktas')
        if (ktasr#0)
          if (ktasr=getfield('t1', 'ktasr', 's_tag', 'ktas'))
            if (entr=getfield('t1', 'ktasr', 's_tag', 'ent'))
              netrepl('ktas', { ktasr }, 1)
            endif

          endif

        endif

      endif

    endif

    sele rs1
    kpl_r=kpl
    dvp_r=dvp
    if (fieldpos('pt')#0)
      if (ddc<ctod('29.01.2007'))
        sele tara
        if (netseek('t1', 'kpl_r').and.ddog<=dvp_r.and.!empty(ddog).and.pd=0)
          ptr:=1
        else
          ptr:=0
        endif

        sele rs1
        netrepl('pt', { ptr }, 1)
      endif

    endif

    sele rs1
    ttnr=ttn
    dopr=dop
    dotr=dot
    vor=vo
    przr=prz
    kopr=kop
    kopir=kopi
    kplr=kpl
    kpvr=kpv
    qr=kop-100
    nofr=getfield('t1', '0,1,vor,qr', 'soper', 'nof')
    sele rs1
    if (fieldpos('nkkl')#0)
      nkklr=nkkl
      if (nkklr=0)
        if (aqstr=2)
          netrepl('nkkl', { kplr }, 1)
        endif

        //         if !(kopr=191.or.kopr=169.or.kopr=168.or.kopr=196)
        //            if kplr#0
        //               if aqstr=2
        //                  netrepl('nkkl','kplr},1)
        //               endif
        //               ?str(ttnr,6)+' '+str(kopr,3)+' '+str(nkklr,7)+' '+str(kplr,7)+' nkkl'
        //            endif
        //         else
        //            if kopr=kopir
        //               if kpvr#0
        //                  if aqstr=2
        //                     netrepl('nkkl','kpvr},1)
        //                  endif
        //                  ?str(ttnr,6)+' '+str(kopr,3)+' '+str(nkklr,7)+' '+str(kpvr,7)+' nkkl'
        //               endif
        //            else
        //               nkklr=0
        //               if select('rso1')#0
        //                  sele rso1
        //                  if netseek('t2','ttnr')
        //                     do while ttn=ttnr
        //                        if prnpp=10
        //                           if !(kop=191.or.kop=169.or.kopr=168.or.kop=196)
        //                              nkklr=kpl
        //                           endif
        //                        endif
        //                        sele rso1
        //                        skip
        //                     endd
        //                  endif
        //               endif
        //               sele rs1
        //               if nkklr#0
        //                  if !(nkklr=20034.or.nkklr=20540)
        //                     if aqstr=2
        //                        netrepl('nkkl','nkklr},1)
        //                     endif
        //                     ?str(ttnr,6)+' '+str(kopr,3)+' '+str(0,7)+' '+str(kplr,7)+' nkkl'
        //                  else
        //                     if kpvr#0.and.!(kpvr=20034.or.kpvr=20540)
        //                        if aqstr=2
        //                           netrepl('nkkl','kpvr},1)
        //                        endif
        //                        ?str(ttnr,6)+' '+str(kopr,3)+' '+str(0,7)+' '+str(kpvr,7)+' nkkl'
        //                     endif
        //                  endif
        //               endif
        //            endif
        //         endif
        //      else
        //         if (kopr=191.and.nkklr=20540).or.(kopr=169.and.nkklr=20034).or.(kopr=196.and.(nkklr=20034.or.nkklr=20540))
        //            if kopr=kopir
        //               if kpvr#0.and.!(kpvr=20540.or.kpvr=20034)
        //                  if aqstr=2
        //                     netrepl('nkkl','kpvr},1)
        //                  endif
        //                  ?str(ttnr,6)+' '+str(kopr,3)+' '+str(nkklr,7)+' '+str(kpvr,7)+' nkkl'
        //               endif
        //            else
        //               nkkl_r=nkklr
        //               nkklr=0
        //               if select('rso1')#0
        //                  sele rso1
        //                  if netseek('t2','ttnr')
        //                     do while ttn=ttnr
        //                        if prnpp=10
        //                           if !(kop=191.or.kop=169.or.kopr=168.or.kop=196)
        //                              nkklr=kpl
        //                           endif
        //                        endif
        //                        sele rso1
        //                        skip
        //                     endd
        //                  endif
        //               endif
        //               sele rs1
        //               if nkklr#0
        //                  if !(nkklr=20034.or.nkklr=20540)
        //                     if aqstr=2
        //                        netrepl('nkkl','nkklr},1)
        //                     endif
        //                     ?str(ttnr,6)+' '+str(kopr,3)+' '+str(nkkl_r,7)+' '+str(nkklr,7)+' nkkl'
        //                  else
        //                     if kpvr#0.and.!(kpvr=20540.or.kpvr=20034)
        //                        if aqstr=2
        //                           netrepl('nkkl','kpvr},1)
        //                        endif
        //                        ?str(ttnr,6)+' '+str(kopr,3)+' '+str(nkklr,7)+' '+str(kpvr,7)+' nkkl'
        //                     endif
        //                  endif
        //               endif
        //            endif
      //        endif
      endif

    endif

    sele rs1
    if (prz=1)
      if (empty(dopr))
        netrepl('dop', { dotr }, 1)
      endif

      dopr=dop
    endif

    sele rs1
    if (nnds=0)
      nndsr=getfield('t3', 'skr,ttnr,0', 'nds', 'nomnds')
      if (nndsr#0)
        netrepl('nnds', { nndsr }, 1)
      endif

    endif

    sele rs1
    netunlock()
    skip
  enddo

  return (.t.)

