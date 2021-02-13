/********************************************
  * p1 1-send;2-recieve
  * p2 дней мод
  * p3 - 0-all;1-buh;2-skl
  ********************************************/
function RmMn(p1, p2, p3)
  gnSdRc=1
  KolModr=p2
  set prin to rmsk.txt
  set prin on
  set cons off

  if (gnArm=0)
    kprdr=2
  else
    kprdr=1
  endif

  rmdirr=''
  PathmInr=''
  PathmOutr=''

  prarhr=0

  netuse('rmsk')
  while (!eof())
    ?str(rmsk)
    if (ent#gnEnt)
      skip
      loop
    endif

    /*
    if ent=20.and.rmsk#4
       skip
       loop
    endif
    */
    rcrmskr=recn()
    rmdirr=alltrim(rmdir)
    rmbsr=rmbs
    srmskr=rmsk
    rmipr=alltrim(rmip)
    if (p1=1)             // SEND
      PathmInr=gcPath_m
      PathmOutr=gcPath_out+rmdirr+'\'
      delout()
      if (gnEntrm=0)
        rmsd0()
      else
        rmsd1(KolModr, buhskr)
      endif

    else                    // p1 = 2 RECIEVE
      PathmOutr=gcPath_m
      PathmInr=gcPath_in+rmdirr+'\'
      if (p1 == 2)
        sele 0
        use (gcPath_in+'cdmg') shared
        go bottom
        while (!bof())
          if (rm#srmskr)
            sele cdmg
            skip -1
            loop
          endif

          if (empty(dtz).or.empty(dto))
            sele cdmg
            skip -1
            loop
          endif

          KolModr=date()-sdt
          if (KolModr>31)
            KolModr=0
          endif

          if (KolModr<1)
            KolModr=1
          endif

          exit
        enddo

        sele cdmg
        CLOSE
      endif

      outlog(3, __FILE__, __LINE__, "KolModr", KolModr)

      DelIn()
      scrpt(2)
      ArcIn()
      outlog(3, __FILE__, __LINE__, "//DelIn() scrpt(2) ArcIn()")

      if (dirchange(gcPath_in+rmdirr)#0)
        if (gnArm#0)
          wmess(gcPath_in+rmdirr+' Нет данных', 2)
        endif

      else
        dirchange(gcPath_l)
        if (gnEntrm=0)
          outlog(3, __FILE__, __LINE__, "//RmRC0()")
          RmRC0()
        else
          outlog(3, __FILE__, __LINE__, "//RmRC1()")
          RmRC1()
        endif

      endif

      dirchange(gcPath_l)
    endif

    sele rmsk
    go rcrmskr
    skip
  enddo

  nuse()
  set prin off
  set prin to
  gnSdRc=0
  return (.t.)

