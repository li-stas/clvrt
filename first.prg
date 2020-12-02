/***********************************************************
 * Модуль    : first.prg
 * Версия    : 0.0
 * Автор     :
 * Дата      : 03/30/18
 * Изменен   :
 * Примечание: Текст обработан утилитой CF версии 2.02
 */

set prin on
set cons off
//cpfls()

//index()

//crdoc()
fsec1r=seconds()
DokkKta()
?'DokkKta'+' '+str((seconds()-fsec1r), 10, 3)

fsec1r=seconds()
crbsDokk()
?'CrBsDokk'+' '+str((seconds()-fsec1r), 10, 3)

fsec1r=seconds()
ChkDokkO()
?'chkDokko'+' '+str((seconds()-fsec1r), 10, 3)

fsec1r=seconds()
CrDkKln()
?'crdkkln'+' '+str((seconds()-fsec1r), 10, 3)

fsec1r=seconds()
CrNac()
?'crnac'+' '+str((seconds()-fsec1r), 10, 3)

fsec1r=seconds()
CrOpl()
?'cropl'+' '+str((seconds()-fsec1r), 10, 3)

netuse('setup')
entr=gnEnt
netuse('cskl')
go top
while (!eof())
  if (ent#gnEnt)
    skip
    loop
  endif

  if (merch=1)
    skip
    loop
  endif

     if TPsTPok=2
        skip
        loop
     endif
  rccsklr=recn()
  skr=sk
  gnSk=sk
  gnKt=kt
  gnSkl=skl
  gnMskl=mskl
  gnArnd=arnd
  gnTpstpok=tpstpok
  gdNPrd=nprd
  gnSkotv=skotv
  path_tr=gcPath_d+alltrim(path)
  if (!file(path_tr+'tprds01.dbf'))
    skip
    loop
  endif

  ?path_tr
  ctov_r=ctov
  sklr=skl
  arndr=arnd
  tpstpokr=tpstpok
  dtpr=bom(gdTd)-1
  yyr=year(dtpr)
  mmr=month(dtpr)
  path_pr=gcPath_e+'g'+str(yyr, 4)+'\m'+iif(mmr<10, '0'+str(mmr, 1), str(mmr, 2))+'\'+alltrim(path)
  nost()
  tost()
  otvprv()
  //   netuse('nds')
  //   if fieldpos('nomndsvz')#0
  //     crvznds()
  //   endif
  netuse('cskl')
  go rccsklr
  skip
enddo

//fpodg()
set prin off
set prin to
nuse()

set prin off

/***********************************************************
 * index
 *   Параметры:
 */
procedure index
  // Коррекция структуры,Индексация
  //clea
  ndirfr=''
  dirr=0

  qdirr=1
  tflr=1
  sele 0
  crtt('tfl', "f:als c:c(6) f:fname c:c(8) f:parent c:c(6) f:dop c:c(6)")
  sele 0
  use tfl excl

  sele 0
  crtt('ttskl', "f:sk c:n(3) f:nskl c:c(20) f:path c:c(20) f:mskl c:n(1) f:ctov c:n(1)")
  sele 0
  use ttskl excl

  sele dir
  go top
  rcdir=recn()
  n=0
  while (!eof())
    rcdir=recn()
    dirr=dir
    aa=alltrim(ndir)
    ndirr=&aa
    if (empty(ndirr))
      skip
      if (eof())
        exit
      endif

      loop
    endif

    setcolor("gr+/n")
    if (dirr=3)
      ?ndirc+' '+gcPath_d
    else
      ?ndirc+' '+ndirr
    endif

    setcolor("g/n")
    sele tfl
    zap
    if (set(11))
      ?'DELE ON'
    else
      ?'DELE OFF'
    endif

    sele dbft
    go top
    while (!eof())
      if (dir#dirr)
        skip
        loop
      endif

      alsr=als
      if (empty(alsr))
        skip
        loop
      endif

      fnamer=fname
      parentr=parent
      dopr=dop
      sele tfl
      appe blank
      repl als with alsr,   ;
       fname with fnamer,   ;
       parent with parentr, ;
       dop with dopr
      sele dbft
      skip
    enddo

    sele tfl
    //     copy to ('tfl'+str(dirr,1))
    if (dirr=3)
      sele ttskl
      zap
      netuse('cskl')
      while (!eof())
        if (ent#gnEnt)
          skip
          loop
        endif

        skr=sk
        nsklr=nskl
        msklr=mskl
        ctovr=ctov
        path_r=path
        pathr=gcPath_d+alltrim(path)
        if (!netfile('tov', 1))
          skip
          loop
        endif

        sele ttskl
        appe blank
        repl sk with skr, ;
         nskl with nsklr, ;
         mskl with msklr, ;
         ctov with ctovr, ;
         path with path_r
        sele cskl
        skip
      enddo

      nuse('cskl')
      sele ttskl
      go top
      while (!eof())
        pathr=gcPath_d+alltrim(path)
        ctovr=ctov
        msklr=mskl
        setcolor("br+/n")
        ?pathr
        setcolor("g/n")
        sele tfl
        go top
        while (!eof())
          flr=alltrim(als)
          parentr=parent
          dopr=dop
          if (!netfile(flr, 1))
            skip
            loop
          endif

          fnamer=alltrim(fname)
          fptr=fnamer+'.fpt'
          cdxr=fnamer+'.cdx'
          ?flr
          if (file(pathr+fptr))
            setcolor("r/n")
            ??' MEMO'
            setcolor("g/n")
            skip
            loop
          endif

          if (!netfile(flr, 1))
            sele ttskl
            skip
            loop
          endif

          /************************** */
          // Коррекция структуры
          if (!(flr='tovst'.or.flr='tovf'))
            erase (pathr+cdxr)
            struc()
          endif

          /************************** */
          //              if flr='tovpt'
          //                 if netuse('tovpt',,'e',1)
          //                    dele all for dt<date()-1
          //                    nuse('tovpt')
          //                 endif
          //              endif
          if (!netind(flr, 1))
            setcolor("r+/n")
            ??' нет'
            setcolor("g/n")
          endif

          sele tfl
          skip
        enddo

        ?'Удаление незарегистрированных файлов'
        aall:=directory(pathr+'*.*')
        for i=1 to len(aall)
          ffnamer=aall[ i, 1 ]
          //               extr=right(ffnamer,3)
          extr=lower(right(ffnamer, 3))
          fnamer=subs(ffnamer, 1, len(ffnamer)-4)
          fnamer=lower(fnamer)
          sele dbft
          LOCATE for alltrim(fname)==fnamer
          if (!FOUND())
            erase (pathr+ffnamer)
          else
            if (!(extr='dbf'.or.extr='cdx'.or.extr='fpt').or.dir#dirr)
              erase (pathr+ffnamer)
            endif

          endif

        next

        sele ttskl
        skip
      enddo

    else
      if (set(11))
        ?'DELE ON'
      else
        ?'DELE OFF'
      endif

      pathr=ndirr
      sele tfl
      go top
      while (!eof())
        flr=alltrim(als)
        parentr=parent
        dopr=dop
        if (!netfile(flr, 1))
          ?'Нет файла 1 '+flr
          skip
          loop
        endif

        fnamer=alltrim(fname)
        fptr=fnamer+'.fpt'
        cdxr=fnamer+'.cdx'
        ?flr
        if (file(pathr+fptr))
          setcolor("r/n")
          ??' MEMO'
          setcolor("g/n")
          skip
          loop
        endif

        /************************** */
        // Коррекция структуры
        if (flr='setup')
          nuse('setup')
        endif

        if (flr='cskl')
          nuse('cskl')
        endif

        if (flr='cntcm')
          nuse('cntcm')
        endif

        if (flr='prd')
          nuse('prd')
        endif

        if (!netfile(flr, 1))
          ?'Нет файла 2 '+flr
          sele tfl
          skip
          loop
        endif

        //           if !(flr='dir'.or.flr='dbft'.or.flr='cskl'.or.flr='setup')
        erase (pathr+cdxr)
        struc()
        //           endif
        /************************** */
        if (!netind(flr, 1))
          setcolor("r+/n")
          ??' нет'
          setcolor("g/n")
        endif

        if (flr='setup')
          netuse('setup')
        endif

        if (flr='cskl')
          netuse('cskl')
        endif

        if (flr='cntcm')
          netuse('cntcm')
        endif

        if (flr='prd')
          netuse('prd')
        endif

        sele tfl
        skip
      enddo

      if (dirr#0)
        ?'Удаление незарегистрированных файлов'
        if (set(11))
          ?'DELE ON'
        else
          ?'DELE OFF'
        endif

        aall:=directory(pathr+'*.*')
        for i=1 to len(aall)
          ffnamer=aall[ i, 1 ]
          //               extr=right(ffnamer,3)
          extr=lower(right(ffnamer, 3))
          fnamer=subs(ffnamer, 1, len(ffnamer)-4)
          fnamer=lower(fnamer)
          if (fnamer=='dbft'.or.fnamer=='dir')
            loop
          endif

          sele dbft
          LOCATE for alltrim(fname)==fnamer
          if (!FOUND())
            copy to err1dbft
            erase (pathr+ffnamer)
            ?pathr+ffnamer+' '+fnamer
          else
            if (!(extr='dbf'.or.extr='cdx'.or.extr='fpt').or.dir#dirr)
              copy to err2dbft
              erase (pathr+ffnamer)
              ?pathr+ffnamer+' '+fnamer
            endif

          endif

        next

      endif

    endif

    sele dir
    go rcdir
    if (dirr=2.or.dir=3.or.dir=5.or.dir=6).and.n=0
      n=1
      // Cохранение параметров текущего месяца
      path_drr=gcPath_d
      dir_drr=gcDir_d
      path_grr=gcPath_g
      dir_grr=gcDir_g
      path_brr=gcPath_b
      td_rr=gdTd
      path_glrr=gcPath_gl

      gdTd=gomonth(gdTd, -1)
      gcDir_d='m'+iif(month(gdTd)<10, '0'+str(month(gdTd), 1), str(month(gdTd), 2))+'\'
      gcDir_g='g'+str(year(gdTd), 4)+'\'
      gcPath_g=gcPath_e+gcDir_g
      gcPath_d=gcPath_g+gcDir_d
      gcPath_b=gcPath_d+'bank\'
      gcPath_gl=gcPath_d+'glob\'
    else
      if (n=1)
        // Восстановление параметров текущего месяца
        gdTd=td_rr
        gcDir_d=dir_drr
        gcDir_g=dir_grr
        gcPath_g=path_grr
        gcPath_d=path_drr
        gcPath_b=path_brr
        gcPath_gl=path_glrr
        n=0
      endif

      skip
    endif

  enddo

RETURN

/***********************************************************
 * struc() -->
 *   Параметры :
 *   Возвращает:
 */
static function struc()
  if (nstru(flr, 1))
    return
  endif

  ?pathr+flr+' структура'
  if (empty(parentr))   // Основная таблица
    pathsr=gcPath_a+flr
    if (file(pathsr+'.dbf'))
      sele 0
      use (pathsr) alias str_u
      copy stru to (gcPath_l+'\'+flr)
      CLOSE

      use (flr) alias in NEW
      if (file(pathr+fnamer+'.dbf'))
        use (pathr+fnamer) ALIAS Out EXCLUSIVE NEW
        if (NETERR())
          ??' блокирована [appe from] '
        else
          close out
          sele in
          appe from (pathr+fnamer+'.dbf')

          use (pathr+fnamer) ALIAS Out EXCLUSIVE NEW
          if (NETERR())
            ??' блокирована [copy to] '
          else
            close Out
            sele in
            copy to (pathr+fnamer+'.dbf')
          endif

        endif

      endif

      sele in
      CLOSE
      erase (flr+'.dbf')
    endif

  else                      // Дочерняя таблица
    adop:={}
    dfil_r=fnamer
    sele dbft
    while (.t.)
      LOCATE for alltrim(als)==dfil_r
      if (!empty(dop))
        aadd(adop, dop)
      endif

      if (!empty(parent))
        dfil_r=alltrim(parent)
      else
        aadd(adop, alltrim(als))
        exit
      endif

    enddo

    for i=1 to len(adop)
      fil_r=adop[ i ]
      sele 0
      use (gcPath_a+fil_r)
      copy to (gcPath_l+'\stemp'+str(i, 1)+'.dbf') stru exte
      CLOSE
    next

    k=0
    for i=len(adop) to 1 step -1
      fil_r=gcPath_l+'\stemp'+str(i, 1)
      if (k=0)
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
    sele stemp
    CLOSE
    crea in from ('stemp'+str(k, 1)+'.dbf')
    erase ('stemp'+str(k, 1)+'.dbf')
    if (file(pathr+fnamer+'.dbf'))
      appe from (pathr+fnamer+'.dbf')
      copy to (pathr+fnamer+'.dbf')
    endif

    sele in
    CLOSE
    erase in.dbf
  endif

RETURN (NIL)

/***********************************************************
 * crdoc
 *   Параметры:
 */
procedure crdoc
  netuse('setup')
  netuse('tara')
  netuse('tcen')
  netuse('kln')
  netuse('s_tag')
  netuse('vop')
  netuse('dclr')
  netuse('vo')
  netuse('dokk')
  // netuse('aninf'); netuse('aninfl'); netuse('doka')
  netuse('dkkln')
  netuse('dknap')
  netuse('dkklns')
  netuse('bs')
  netuse('cgrp')
  set prin to crdoc.txt
  set prin on
  netuse('cskl')
  go top
  while (!eof())
    if (ent#gnEnt)
      skip
      loop
    endif

    skr=sk
    gnSk=sk
    ctovr=ctov
    pathr=gcPath_d+alltrim(path)
    if (!file(pathr+'tprds01.dbf'))
      skip
      loop
    endif

    ?pathr
    //складские таблицы
    netuse('tov',,, 1)
    netuse('sgrp',,, 1)
    if (ctovr=1)
      netuse('tovm',,, 1)
    endif

    netuse('soper',,, 1)
    netuse('grpizg',,, 1)
    //приход
    netuse('pr1',,, 1)
    netuse('pr2',,, 1)
    netuse('pr3',,, 1)
    //расход
    netuse('rs1',,, 1)
    netuse('rs2',,, 1)
    netuse('rs3',,, 1)

    cdocopt()

    //закрытие прихода
    nuse('pr1')
    nuse('pr2')
    nuse('pr3')
    //закрытие расхода
    nuse('rs1')
    nuse('rs2')
    nuse('rs3')
    //складские таблицы
    nuse('tov')
    nuse('sgrp')
    nuse('tovm')
    nuse('soper')
    nuse('grpizg')
    sele cskl
    skip
  enddo

  nuse()
  set prin off
  set prin to

RETURN

/**************** */
function crnac()
  /**************** */
  netuse('ctov')
  netuse('mkeep')
  netuse('mkeepe')
  netuse('klnnac')
  go top
  while (!eof())
    if (fieldpos('kdopl')=0)
      if (nac=0.and.nac1=0.and.tcen=0)
        netdel()
      endif

    else
      if (nac=0.and.nac1=0.and.tcen=0.and.kdopl=0)
        netdel()
      endif

    endif

    skip
  enddo

  sele klnnac
  go top
  while (!eof())
    izgr=izg
    mkeepr=getfield('t2', 'izgr', 'mkeepe', 'mkeep')
    sele ctov
    if (!netseek('t6', 'mkeepr'))
      sele klnnac
      netdel()
    endif

    sele klnnac
    skip
  enddo

  sele klnnac
  /*pack */
  CLOSE

  netuse('brnac')
  go top
  while (!eof())
    if (nac=0.and.nac1=0)
      netdel()
    endif

    skip
  enddo

  go top
  while (!eof())
    mkeepr=mkeep
    sele ctov
    if (!netseek('t6', 'mkeepr'))
      sele brnac
      netdel()
    endif

    sele brnac
    skip
  enddo

  sele brnac
  /*pack */
  CLOSE

  netuse('mnnac')
  go top
  while (!eof())
    if (nac=0.and.nac1=0)
      netdel()
    endif

    skip
  enddo

  go top
  while (!eof())
    mntovr=mntov
    sele ctov
    if (!netseek('t1', 'mntovr'))
      sele mnnac
      netdel()
    endif

    sele mnnac
    skip
  enddo

  sele mnnac
  /*pack */
  CLOSE

  nuse('ctov')
  nuse('mkeep')
  nuse('mkeepe')

  return (.t.)

/***********************************************************
 * crvznds() -->
 *   Параметры :
 *   Возвращает:
 */
function crvznds()
  pathr=path_tr
  netuse('pr1',,, 1)
  if (fieldpos('ttnvz')=0)
    nuse('pr1')
    return (.t.)
  endif

  while (!eof())
    if (ttnvz=0)
      sele pr1
      skip
      loop
    endif

    if (nnds=0)
      sele pr1
      skip
      loop
    endif

    mnr=mn
    ttnvzr=ttnvz
    dtvzr=dtvz
    nndsr=nnds
    sele nds
    set orde to tag t3
    if (netseek('t3', 'skr,mnr,1'))
      nndsr=nomnds
      nomndsvzr=nomndsvz
      dnnvzr=dnnvz
      if (nomndsvzr=0)
        nomndsvzr=getfield('t3', 'gnSk,ttnvzr,0', 'nds', 'nomnds')
        dnnvzr=getfield('t3', 'gnSk,ttnvzr,0', 'nds', 'dnn')
        netrepl('nomndsvz,dnnvz,ttnvz', 'nomndsvzr,dnnvzr,ttnvzr')
      endif

    endif

    sele pr1
    skip
  enddo

  nuse('pr1')
  return (.t.)

