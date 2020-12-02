********************************************
func rmmn(p1,p2,p3)
  ********************************************
  * p1 1-send;2-recieve
  * p2 дней мод
  * p3 - 0-all;1-buh;2-skl
  gnSdRc=1
  kolmodr=p2
  set prin to rmsk.txt
  set prin on
  set cons off

  if gnArm=0
     kprdr=2
  else
     kprdr=1
  endif

  rmdirr=''
  pathminr=''
  pathmoutr=''

  prarhr=0

  netuse('rmsk')
  do while !eof()
     ?str(rmsk)
     if ent#gnEnt
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
     if p1=1  // SEND
        pathminr=gcPath_m
        pathmoutr=gcPath_out+rmdirr+'\'
        delout()
        if gnEntrm=0
           rmsd0()
        else
           rmsd1(kolmodr,buhskr)
        endif
  //      arcout()
     else     // p1 = 1 RECIEVE
       pathmoutr=gcPath_m
       pathminr=gcPath_in+rmdirr+'\'
       //      #ifdef __CLIP__
       //      #else
       if p1 == 2
         //wait
          // * Вычисление kolmodr
          sele 0
          use (gcPath_in+'cdmg') shared
          go bottom
          do while !bof()
            if rm#srmskr
                sele cdmg
                skip -1
                loop
            endif
            if empty(dtz).or.empty(dto)
                sele cdmg
                skip -1
                loop
            endif
            kolmodr=date()-sdt
            if kolmodr>31
                kolmodr=0
            endif
            if kolmodr<1
                kolmodr=1
            endif
            exit
          endd
          sele cdmg
          use
        endif
        //      #endif
        delin()
        scrpt(2)
        arcin()
        if dirchange(gcPath_in+rmdirr)#0
           if gnArm#0
              wmess(gcPath_in+rmdirr+' Нет данных',2)
           endif
        else
           dirchange(gcPath_l)
           if gnEntrm=0
              rmrc0()
           else
              rmrc1()
           endif
        endif
        dirchange(gcPath_l)
     endif
     sele rmsk
     go rcrmskr
     skip
  endd
  nuse()
  set prin off
  set prin to
  gnSdRc=0
  retu .t.


