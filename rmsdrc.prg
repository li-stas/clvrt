/***********************************************************
 * Модуль    : rmsdrc.prg
 * Версия    : 0.0
 * Автор     :
 * Дата      : 04/04/19
 * Изменен   :
 * Примечание: Текст обработан утилитой CF версии 2.02
 */

#include "common.ch"
#include "inkey.ch"

/******************************************** */
function rmmain(p1, p2)
  /********************************************
   * p1 1-send;2-recieve
   * p2 - 1-arh 2-file 3-Сверка (в rmsdrcf.prg)
   */
  gnSdRc=1
  if (empty(p2))
    prexer=0
  else
    prexer=p2
  endif

  if (gnArm=0)
    kprdr=2
  else
    kprdr=1
  endif

  /* prexer=0 default все (update)
   * prexer=1 архив уд (update)
   * prexer=2 файл (update)
   * prexer=3 файл сверка (без update)
   * prexer=4 архив лок (update)
   */
  clea
  netuse('speng')
  set prin to rmsk.txt
  set prin on

  rmdirr=''
  pathminr=''
  pathmoutr=''
  kolmodr=1
  buhskr=0

  netuse('rmsk')
  if (netseek('t1', 'gnEnt'))
    rmdirr=alltrim(rmdir)
    rmbsr=rmbs
    srmskr=rmsk
    rmipr=rmip
    if (p1=1)             // SEND
      pathminr=gcPath_m
      if (gnEntrm=0)
        rcrmskr=recn()
        while (.t.)
          sele rmsk
          go rcrmskr
          foot('ENTER', 'Передать')
          rcrmskr=slcf('rmsk',,,,, "e:ent h:'ENT' c:n(2) e:rmdir h:'Дир' c:c(10) e:rmip h:'IP' c:c(15)",,,,, 'ent=gnEnt',, 'Уд.склады')
          if (lastkey()=27)
            rmdirr=''
            netunlock()
            exit
          endif

          sele rmsk
          go rcrmskr
          if (!reclock(1))
            nuserr=alltrim(getfield('t1', 'rmsk->ktoblk', 'speng', 'fio'))
            wmess('Занято '+nuserr, 2)
            loop
          endif

          rmbsr=rmbs
          rmdirr=alltrim(rmdir)
          srmskr=rmsk
          rmipr=rmip
          pathmoutr=gcPath_out+rmdirr+'\'
          if (lastkey()=13)
            do case
            case (prexer=0)
              delout()
              rmsd0()
            case (prexer=1)
            case (prexer=2)
            case (prexer=3)
            endcase

            sele rmsk
            netunlock()
          else
          endif

        enddo

      else
        sele rmsk
        if (reclock(1))
          pathmoutr=gcPath_out+rmdirr+'\'
          do case
          case (prexer=0)
            DelOut()
            RmSd1(1)
          case (prexer=1)
          case (prexer=2)
          case (prexer=3)
          endcase

          sele rmsk
          netunlock()
        endif

      endif

    else                    // RECIEVE
      pathmoutr=gcPath_m
      if (gnEntrm=0)
        rcrmskr=recn()
        while (.t.)
          sele rmsk
          go rcrmskr
          foot('ENTER', 'Загрузить')
          rcrmskr=slcf('rmsk',,,,, "e:ent h:'ENT' c:n(2) e:rmdir h:'Дир' c:c(10) e:rmip h:'IP' c:c(15)",,,,, 'ent=gnEnt',, 'Уд.склады')
          if (lastkey()=27)
            rmdirr=''
            sele rmsk
            netunlock()
            exit
          endif

          sele rmsk
          go rcrmskr
          if (!reclock(1))
            nuserr=alltrim(getfield('t1', 'rmsk->ktoblk', 'speng', 'fio'))
            wmess('Занято '+nuserr, 2)
            loop
          endif

          rmbsr=rmbs
          rmdirr=alltrim(rmdir)
          srmskr=rmsk
          rmipr=rmip
          pathminr=gcPath_in+rmdirr+'\'
          if (lastkey()=13)
            if (!(prexer=1.or.prexer=4))
              delin()
            endif

            do case
            case (prexer=0)
              kolmodr=1
              clsd1=setcolor('w/b,n/w')
              wsd1=wopen(10, 20, 13, 50)
              wbox(1)
              if (gnAdm=1)
                @ 0, 1 say 'Дней модиф       ' get kolmodr pict '99'
              endif

              @ 1, 1 say '0-все;1-бух;2-скл' get buhskr pict '9'
              read
              if (kolmodr=0)
                buhskr=0
              endif

              wclose(wsd1)
              setcolor(clsd1)
              if (lastkey()=27)
                loop
              endif

              scrpt(2)
            case (prexer=1)
              scrpt(2, 1)
            case (prexer=2)
              scrpt(2, 2)
            case (prexer=3)
              scrpt(2, 3)
            case (prexer=4)
            endcase

            arcin()
            if (dirchange(gcPath_in+rmdirr)#0)
              wmess(gcPath_in+rmdirr+' Нет данных', 2)
            else
              if (file(gcPath_in+rmdirr+'.tgz'))
                adirect=directory(gcPath_in+rmdirr+'.tgz')
                dtcr=adirect[ 1, 3 ]
                tmcr=adirect[ 1, 4 ]
              else
                dtcr=ctod('')
                tmcr=space(8)
              endif
              dirchange(gcPath_l)

              aqstr=1
              aqst:={ "Принять", "Отмена" }
              aqstr:=alert('Архив за '+dtoc(dtcr)+' '+tmcr, aqst)
              if (lastkey()=27)
                aqstr=0
              endif

              if (aqstr=1)
                rmrc0(prexer)
              endif

            endif

          endif

          sele rmsk
          netunlock()
        enddo

      else
        sele rmsk
        if (prexer=0)
          rmdirr=alltrim(rmdir)
          rmbsr=rmbs
          srmskr=rmsk
          rmipr=rmip
          if (reclock(1))
            pathminr=gcPath_in+rmdirr+'\'
            delin()
            arcin()
            if (dirchange(gcPath_in+rmdirr)#0)
              wmess(gcPath_in+rmdirr+' Нет данных', 2)
            else
              dirchange(gcPath_l)
              rmrc1()
            endif
            dirchange(gcPath_l)

          endif

          sele rmsk
          netunlock()
        endif

      endif

    endif

  endif

  nuse()
  set prin off
  set prin to
  gnSdRc=0
  return (.t.)

/******************************************** */
function delout()
  /********************************************
   * Удаление каталогов out
   */
  if (dirchange(gcPath_out+rmdirr)=0)
#ifdef __CLIP__
      cLogSysCmd:=""
      bdr=subs(gcPath_out, 1, 2)
      ubdr=upper(bdr)
      lbdr=set(ubdr)
      dir_outr=strtran(gcPath_out+rmdirr, bdr, lbdr)
      dir_outr=strtran(dir_outr, '\', '/')
      SYSCMD("rm -rf "+dir_outr, "", @cLogSysCmd)
#else
      do case
      case (getenv('os')='Windows_NT')
        tt='cmd /c rd '+gcPath_out+rmdirr+' /s/q >nul'
      case (getenv('os')='Windows_98')
        tt='deltree /y '+gcPath_out+rmdirr+' >nul'
      otherwise
        wait getenv('os')
        return (.f.)
      endcase

      !(tt)
#endif
  endif

  dirchange(gcPath_l)
RETURN (NIL)

/************ */
function crout(p1, p2)
  /************
   * Создание каталогов out
   */
  if (empty(p1))
    dt1r=gdTd
    dt2r=gdTd
  else
    dt1r=p1
    dt2r=p2
  endif

  dirmake(gcPath_out+rmdirr)
  erase(gcPath_out+rmdirr+'dmg.dbf')
  crtt(gcPath_out+rmdirr+'\dmg', 'f:dt c:d(20) f:sdt c:d(10) f:stm c:c(8) f:csk c:c(40) f:kolmod c:n(2) f:buhsk c:n(1)')
  sele 0
  use (gcPath_out+rmdirr+'\dmg.dbf')
  appe blank
  repl dt with gdTd, sdt with date(), stm with time()
  dirmake(gcPath_out+rmdirr+'\comm')
  pathcr=gcPath_out+rmdirr+'\'+gcDir_c
  dirmake(gcPath_out+rmdirr+'\'+gcNent)
  pather=gcPath_out+rmdirr+'\'+gcDir_e
  if (gnEntrm=0)
    dirmake(gcPath_out+rmdirr+'\'+'astru')
    pathar=gcPath_out+rmdirr+'\'+gcDir_a
  endif

  yy1r=year(dt1r)
  yy2r=year(dt2r)
  for yy=yy1r to yy2r
    dirmake(pather+'g'+str(yy, 4))
    dirmake(pathcr+'g'+str(yy, 4))
    do case
    case (yy1r=yy2r)
      mm1r=month(dt1r)
      mm2r=month(dt2r)
    case (yy=yy1r)
      mm1r=month(dt1r)
      mm2r=12
    case (yy=yy2r)
      mm1r=1
      mm2r=month(dt2r)
    endcase

    for mm=mm1r to mm2r
      dirmake(pather+'g'+str(yy, 4)+'\m'+iif(mm<10, '0'+str(mm, 1), str(mm, 2)))
      dirmake(pathcr+'g'+str(yy, 4)+'\m'+iif(mm<10, '0'+str(mm, 1), str(mm, 2)))
      dirmake(pather+'g'+str(yy, 4)+'\m'+iif(mm<10, '0'+str(mm, 1), str(mm, 2))+'\bank')
      if (gnEntrm=0)
        dirmake(pather+'g'+str(yy, 4)+'\m'+iif(mm<10, '0'+str(mm, 1), str(mm, 2))+'\glob')
      endif

      netuse('cskl')
      while (!eof())
        if (ent#gnEnt)
          skip
          loop
        endif

        /*           if rm=0
         *              skip
         *              loop
         *           else
         *              if rm#1.and.(rm#srmskr)
         *                 skip
         *                 loop
         *              endif
         *           endif
         *           if !(rm=srmskr.or.rm=0)
         *              skip
         *              loop
         *           endif
         */
        skr=sk
        path_r=pather+'g'+str(yy, 4)+'\m'+iif(mm<10, '0'+str(mm, 1), str(mm, 2))+'\'+alltrim(path)
        path_rr=gcPath_e+'g'+str(yy, 4)+'\m'+iif(mm<10, '0'+str(mm, 1), str(mm, 2))+'\'+alltrim(path)
        dir_r=subs(path_r, 1, len(path_r)-1)
        if (file(path_rr+'tprds01.dbf'))
          dirmake(dir_r)
          sele dmg
          if (empty(csk))
            repl csk with str(skr, 3)
          else
            repl csk with alltrim(csk)+','+str(skr, 3)
          endif

        endif

        sele cskl
        skip
      enddo

      nuse('cskl')
    next

  next

  sele dmg
  CLOSE
  return (.t.)

/******************************************** */
function delin()
  /********************************************
   * Удаление каталогов in
   */
  if (dirchange(gcPath_in+rmdirr)=0)
#ifdef __CLIP__
      cLogSysCmd:=""
      bdr=subs(gcPath_in, 1, 2)
      ubdr=upper(bdr)
      lbdr=set(ubdr)
      dir_inr=strtran(gcPath_in+rmdirr, bdr, lbdr)
      dir_inr=strtran(dir_inr, '\', '/')
      SYSCMD("rm -rf "+dir_inr, "", @cLogSysCmd)
#else
      do case
      case (getenv('os')='Windows_NT')
        tt='cmd /c rd '+gcPath_in+rmdirr+' /s/q >nul'
      case (getenv('os')='Windows_98')
        tt='deltree /y '+gcPath_in+rmdirr+' >nul'
      otherwise
        wait getenv('os')
        return (.f.)
      endcase

/*      !(tt) */
#endif
  endif
  dirchange(gcPath_l)
RETURN (NIL)

/**************** */
function ArcOut()
/****************
 * Архивация OUT
 */
#ifdef __CLIP__
    diroutr=subs(gcPath_out, 1, len(gcPath_out)-1)
    cErrSysCmd:=cLogSysCmd:=""
    dirchange(diroutr)

    aaa="tar czf ./"+rmdirr+".tgz ./"+rmdirr
    SYSCMD(aaa, "", @cLogSysCmd, @cErrSysCmd)
    outlog(3,__FILE__,__LINE__,'cLogSysCmd',cLogSysCmd)
    outlog(3,__FILE__,__LINE__,'cErrSysCmd',cErrSysCmd)

    dirchange(gcPath_l)
    if (gnEntrm=0)
      scrpt(1)
    endif

#else
    do case
    case (srmskr=3)
      !xcopy e:\work\upgrade\resurs\out\rom e:\worksho\upgrade\resurs\in\rom /I /Q /Y /E
    case (srmskr=4)
      !xcopy e:\work\upgrade\resurs\out\kon e:\worksho\upgrade\resurs\in\kon /I /Q /Y /E
    case (srmskr=5)
      !xcopy e:\work\upgrade\resurs\out\sho e:\worksho\upgrade\resurs\in\sho /I /Q /Y /E
    endcase

#endif
  dirchange(gcPath_l)
  return (.t.)

/**************** */
function arcin()
/* Извлечение в IN
 ****************
 */
#ifdef __CLIP__
    if (file(gcPath_in+rmdirr+'.tgz'))
      cLogSysCmd:=""
      dirinr=subs(gcPath_in, 1, len(gcPath_in)-1)
      dirchange(dirinr)
      aaa="tar xpzvf ./"+rmdirr+".tgz ./"
      SYSCMD(aaa, "", @cLogSysCmd)
      dirchange(gcPath_l)
    endif

#endif
  dirchange(gcPath_l)
  return (.t.)

/**************** */
function scrpt(p1, p2)
  /****************
   * для  gnEntrm=0
   */
  if (gnEntRm#0)
    outlog(3,__FILE__,__LINE__,'выход по gnEntRm#0 -> нужно Прием Арх(уд)')
    return (.t.)
  endif

  if (p1=2)
    if (empty(p2))
      prExr=0
    else
      prExr=p2
    endif

  else
    prExr=0
  endif

  dirchange(gcPath_l)

  /* Удаление файлов */
  erase files.txt
  erase hosts.txt
  erase commands.txt
  /*erase start.sh */

  /* Создание файлов */

  bdr=subs(gcPath_ew, 1, 2)
  ubdr=upper(bdr)
  lbdr=set(ubdr)

#ifdef __CLIP__
    dir_ewr=strtran(gcPath_ew, bdr, lbdr)
    dir_ewr=strtran(dir_ewr, '\', '/')
    outr='out/'
    inr='in/'
#else
    dir_ewr=gcPath_ew
    outr='out\'
    inr='in\'
#endif

  erase (dir_ewr+outr+'start.sh')

#ifdef __CLIP__
    moder=set(_SET_FILECREATEMODE, "775")
#endif

  if (prexr=0)

    hdr=fcreate(dir_ewr+outr+'start.sh')

    fwrite(hdr, '#!/bin/sh'+chr(10))
    fwrite(hdr, 'umask 002'+chr(10))
    fwrite(hdr, 'cd /m1/home/clvrt/hd2/exe/clvrt_super'+chr(10))

    if (p1=1)             // SEND
      fwrite(hdr, '/usr/local/sbin/app_clvrt /rc /gnEnt='+str(gnEnt, 2)+' &'+chr(10))
    else                    // RECIEVE
      fwrite(hdr, '/usr/local/sbin/app_clvrt /sd /gnEnt='+str(gnEnt, 2)+' /kolmod='+str(kolmodr, 2)+' /buhsk='+str(buhskr, 1)+' /gdTd'+dtos(gdTd)+chr(10))
    endif

    fclose(hdr)

  endif

#ifdef __CLIP__
    set(_SET_FILECREATEMODE, moder)
#endif

  hdr=fcreate('hosts.txt')
  rmipr=alltrim(rmipr)
  fwrite(hdr, rmipr+chr(10))
  fclose(hdr)

  if (p1=1)
    hdr=fcreate('files.txt')
    fwrite(hdr, 'l2r '+dir_ewr+outr+rmdirr+'.tgz '+dir_ewr+inr+chr(10))
    fwrite(hdr, 'l2r '+dir_ewr+outr+'start.sh '+'/m1/home/clvrt/hd2/exe/clvrt_super'+chr(10))
    fclose(hdr)
    hdr=fcreate('commands.txt')
    fwrite(hdr, 'nohup super clvrt_super &')//nohup  выполнение без ожидания
    fclose(hdr)
    gogo()
  else
    if (prexr=0)
      /* Создать удаленный архив */
      hdr=fcreate('files.txt')
      fwrite(hdr, 'l2r '+dir_ewr+outr+'start.sh '+'/m1/home/clvrt/hd2/exe/clvrt_super'+chr(10))
      fclose(hdr)
      hdr=fcreate('commands.txt')
      fwrite(hdr, 'nohup super clvrt_super &')//nohup  выполнение без ожидания
      fclose(hdr)
      gogo()
    endif

    /* Перетащить удаленный архив */
    hdr=fcreate('files.txt')
    fwrite(hdr, 'r2l '+dir_ewr+outr+rmdirr+'.tgz '+dir_ewr+inr+chr(10))
    fclose(hdr)
    hdr=fcreate('commands.txt')
    fwrite(hdr, '#')
    fclose(hdr)
    gogo()
  endif

  return (.t.)

/***********************************************************
 * gogo() -->
 *   Параметры :
 *   Возвращает:
 */
function gogo()
#ifdef __CLIP__
    cLogSysCmd:=""
    cCmd:="rm -f /home/itk/copy_scp_host/files.txt; "+  ;
     "cp ./files.txt /home/itk/copy_scp_host/files.txt"
    SYSCMD(cCmd, "", @cLogSysCmd)
    if (!EMPTY(cLogSysCmd))
      OUTLOG(__FILE__, __LINE__, cLogSysCmd, cCmd)
    endif

    cLogSysCmd:=""
    cCmd:="rm -f /home/itk/copy_scp_host/hosts.txt; "+  ;
     "cp ./hosts.txt /home/itk/copy_scp_host/hosts.txt"
    SYSCMD(cCmd, "", @cLogSysCmd)
    if (!EMPTY(cLogSysCmd))
      OUTLOG(__FILE__, __LINE__, cLogSysCmd, cCmd)
    endif

    cLogSysCmd:=""
    cCmd:="rm -f /home/itk/copy_scp_host/commands.txt; "+     ;
     "cp ./commands.txt /home/itk/copy_scp_host/commands.txt"
    SYSCMD(cCmd, "", @cLogSysCmd)
    if (!EMPTY(cLogSysCmd))
      OUTLOG(__FILE__, __LINE__, cLogSysCmd, cCmd)
    endif

    cLogSysCmd:=""
    cCmd:="super scp_host"  //nohup  выполнение без ожидания
    SYSCMD(cCmd, "", @cLogSysCmd)
    if (!EMPTY(cLogSysCmd))
      OUTLOG(__FILE__, __LINE__, cLogSysCmd, cCmd)
    endif

#else
#endif

  return (.t.)

/***********************************************************
 * hhh() -->
 *   Параметры :
 *   Возвращает:
 */
function hhh()
  /***************************************** */

  if (p1=1)               // SEND
    if (gnEntrm=0)
      fwrite(hdr, 'l2r '+dir_ewr+outr+rmdirr+'.tgz '+dir_ewr+inr+chr(10))
      fwrite(hdr, 'l2r '+dir_ewr+outr+'start.sh '+'/m1/home/clvrt/hd2/exe/clvrt_super'+chr(10))
    else
    endif

  else                      // RECIEVE
    if (gnEntrm=0)
      fwrite(hdr, 'l2r '+dir_ewr+outr+'start.sh '+'/m1/home/clvrt/hd2/exe/clvrt_super'+chr(10))
      fwrite(hdr, 'r2l '+dir_ewr+outr+rmdirr+'.tgz '+dir_ewr+inr+chr(10))
    else
    endif

  endif

  fclose(hdr)

  hdr=fcreate('commands.txt')
  if (gnEntrm=0)
    fwrite(hdr, 'nohup super clvrt_super &')//nohup  выполнение без ожидания
  else
    fwrite(hdr, '#')
  endif

  fclose(hdr)
  return (.t.)

/*************** */
function rmprot()
  /*************** */
  clea
  dtr=gdTd
  rmr:=4

  netuse('speng')
  if (file(gcPath_in+'cdmg.dbf'))
    sele 0
    use (gcPath_in+'cdmg')
    if (fieldpos('dto')=0)
      copy stru to stmp exte
      CLOSE
      sele 0
      use stmp excl
      appe blank
      repl field_name with 'DTO', ;
       field_type with 'D',       ;
       field_len with 0
      appe blank
      repl field_name with 'TMO', ;
       field_type with 'C',       ;
       field_len with 8
      CLOSE
      create tmp from stmp
      erase stmp.dbf
      appe from (gcPath_in+'cdmg.dbf')
      erase (gcPath_in+'cdmg.dbf')
      copy to (gcPath_in+'cdmg.dbf')
      CLOSE
      erase tmp.dbf
      sele 0
      use (gcPath_in+'cdmg')
    endif

    rccdmgr=recn()
    cdmgf_r='.t.'
    cdmgfr='.t.'
    while (.t.)
      sele cdmg
      go rccdmgr
      foot('F3', 'Фильтр')
      if (fieldpos('dto')=0)
        rccdmgr=slcf('cdmg',,,,, "e:rm h:'R' c:n(1) e:dt h:'Период' c:d(10) e:sdt h:'СДата' c:d(10) e:stm h:'СВремя' c:c(8) e:kolmod h:'Д' c:n(2) e:buhsk h:'БС' c:n(1) e:getfield('t1','cdmg->kto','speng','fio') h:'Оператор' c:c(15)",,,,, cdmgfr,, 'Протокол')
      else
        rccdmgr=slcf('cdmg',,,,, "e:rm h:'R' c:n(1) e:dt h:'Период' c:d(10) e:sdt h:'СДата' c:d(10) e:stm h:'СВремя' c:c(8) e:kolmod h:'Д' c:n(2) e:buhsk h:'БС' c:n(1) e:getfield('t1','cdmg->kto','speng','fio') h:'Оператор' c:c(15) e:tmz h:'ВрОЗ' c:c(8) e:tmo h:'ВрОВерт' c:c(8)",,,,, cdmgfr,, 'Протокол')
      endif

      if (lastkey()=27)
        exit
      endif

      go rccdmgr
      do case
      case (lastkey()=K_F3)
        clprot=setcolor('w/b,n/w')
        wprot=wopen(10, 20, 14, 50)
        wbox(1)
        @ 0, 1 say 'Дата' get dtr
        @ 1, 1 say 'УдСк' get rmr
        read
        wclose(wprot)
        setcolor(clprot)
        if (lastkey()=27.or.empty(dtr).or.empty(rmr))
          cdmgfr=cdmgf_r
        else
          if (!empty(dtr))
            cdmgfr=cdmgf_r+'.and.cdmg->sdt=dtr'
          endif

          if (!empty(rmr))
            cdmgfr+='.and.cdmg->rm=rmr'
          endif

        endif

        go top
        rccdmgr=recn()
      endcase

    enddo

    nuse('cdmg')
  endif

  nuse()
  return (.t.)
