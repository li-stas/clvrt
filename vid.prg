* Виды продукции
clea
netuse('vid')
netuse('vide')
netuse('cgrp')
netuse('cskl')

sele vid
do while .t.
   foot('INS,DEL,F4,ENTER','Добавить,Удалить,Коррекция,Состав')
   rcvidr=slcf('vid',1,1,18,,"e:vid h:'Код' c:n(2) e:nvid h:'Наименование' c:c(20)",,,1,,,,'Виды товара')
   go rcvidr
   vidr=vid
   nvidr=nvid
   do case
      case lastkey()=27
           exit
      case lastkey()=22 // INS
           vidins(0)
      case lastkey()=7  // DEL
           sele vide
           go top
           do while !eof()
              if vid=vidr
                 netdel()
              endif
              skip
           enddo
           sele vid
           netdel()
           skip -1
           if bof()
              go top
           endif
      case lastkey()=-3 // CORR
           vidins(1)
      case lastkey()=13 // Состав
           vide()
   endc
enddo
nuse()

func vidins(p1)
if p1=0
   vid_r=0
   nvid_r=space(20)
else
   vid_r=vidr
   nvid_r=nvidr
endif
clvidi=setcolor('gr+/b,n/w')
wvidi=wopen(10,20,14,50)
wbox(1)
sele vid
do while .t.
   if p1=0
      @ 0,1 say 'Код         ' get vid_r pict '99'
   else
      @ 0,1 say 'Код         '+' '+str(vid_r,2)
   endif
   @ 1,1 say 'Наименование' get nvid_r
   read
   if lastkey()=27
      exit
   endif
   @ 2,1 prom 'Верно'
   @ 2,col()+1 prom 'Не Верно'
   menu to vn
   if lastkey()=27
      exit
   endif
   if vn=1
      if p1=0
         loca for vid=vid_r
         if foun()
            wmess('Такой код уже есть',1)
         else
            netadd()
            netrepl('vid,nvid','vid_r,nvid_r')
            exit
         endif
      else
         netrepl('nvid','nvid_r')
         exit
      endif
   endif
enddo
wclose(wvidi)
setcolor(clvidi)

retu .t.

func vide()
sele vide
go top
do while .t.
   foot('INS,DEL','Добавить,Удалить')
   rcvider=slcf('vide',1,29,18,,"e:sk h:'Код' c:n(3) e:getfield('t1','vide->sk','cskl','nskl') h:'Склад' c:c(20) e:grp h:'Код' c:n(3) e:getfield('t1','vide->grp','cgrp','ngr') h:'Группа' c:c(20)",,,,,'vid=vidr',,'Состав')
   go rcvider
   skr=sk
   nsklr=getfield('t1','skr','cskl','nskl')
   grpr=grp
   ngrpr=getfield('t1','grpr','cgrp','ngr')
   do case
      case lastkey()=27
           exit
      case lastkey()=22 // INS
           videins()
      case lastkey()=7  // DEL
           netdel()
           skip -1
           if vid#vidr.or.bof()
              go top
           endif
   endc
enddo
retu .t.

func videins()
sk_r=0
nskl_r=space(20)
grp_r=0
ngrp_r=space(20)
clvidei=setcolor('gr+/b,n/w')
wvidei=wopen(10,20,16,50)
wbox(1)
sele vide
do while .t.
   @ 0,1 say 'Код  склада ' get sk_r pict '999'
   @ 2,1 say 'Код группы  ' get grp_r pict '999'
   read
   if lastkey()=27
      exit
   endif
   nskl_r=getfield('t1','sk_r','cskl','nskl')
   ngrp_r=getfield('t1','grp_r','cgrp','ngr')
   @ 1,1 say 'Склад   '+' '+nskl_r
   @ 3,1 say 'Группа  '+' '+ngrp_r
   @ 4,1 prom 'Верно'
   @ 4,col()+1 prom 'Не Верно'
   menu to vn
   if lastkey()=27
      exit
   endif
   if vn=1
      loca for vid=vidr.and.sk=sk_r.and.grp=grp_r
      if foun()
         wmess('Такая запись уже есть',1)
      else
         netadd()
         netrepl('vid,sk,grp','vidr,sk_r,grp_r')
         exit
      endif
   endif
enddo
wclose(wvidei)
setcolor(clvidei)
retu .t.

****************
func TPokKeg()
  *****************
  netuse('ctov')
  netuse('cskl')
  netuse('mkcros')
  netuse('kln')
  netuse('etm')
  netuse('tmesto')

  crtt('kegtov','f:mntov c:n(7) f:mntovt c:n(7) f:keg c:n(3) f:nat c:c(60) f:opt c:n(10,2)')
  sele 0
  use kegtov excl
  inde on str(mntov,7) tag t1
  // wait
  sele ctov
  set orde to tag t1
  go top
  do while int(mntov/10000)=0
     if mkeep#27
        skip
        loop
     endif
     if mkcros=0
        skip
        loop
     endif
     mntovr=mntov
     mntovtr=mntovt
     if mntovtr=0
        mntovtr=mntovr
     endif
     mkcrosr=mkcros
     natr=nat
     optr=opt
     sele mkcros
     if netseek('t1','mkcrosr')
        if keg>=30
           kegr=keg
           sele kegtov
           seek str(mntovr,7)
           if !foun()
              appe blank
              repl mntov with mntovr,;
                   mntovt with mntovtr,;
                   keg with kegr,;
                   nat with natr,;
                   opt with optr
           endif
        endif
     endif
     sele ctov
     skip
  enddo

  crtt('kegkpl','f:kgp c:n(7) f:kpl c:n(7) f:npl c:c(60) ';
       +'f:mntov c:n(7) f:mntovt c:n(7) f:keg c:n(3) f:nat c:c(60) ';
       +'f:osf c:n(12,3) f:Sdv c:n(10,2) f:sdp c:n(10,2) f:DtOpl c:d(10)')
  sele 0
  use kegkpl excl
  inde on str(kpl,7)+str(mntov,7) tag t1

  sele cskl
  locate for sk=234 // TPOK
  pathr=gcPath_d+alltrim(path)
  netuse('tov',,,1)
  go top
  do while !eof()
     if osf=0
        skip
        loop
     endif
     osfr=osf
     kplr=skl
     kgpr:=KegKgp()
     mntovr=mntov
     osfr=osf
     sele kegtov
     seek str(mntovr,7)
     if foun()
        mntovtr=mntovt
        natr=nat
        kegr=keg
        sele kegkpl
        seek str(kplr,7)+str(mntovr,7)
        if !foun()
           appe blank
           repl kpl with kplr,;
                kgp with kgpr,;
                mntov with mntovr,;
                mntovt with mntovtr,;
                nat with natr,;
                keg with kegr
           nplr=getfield('t1','kplr','kln','nkl')
           sele kegkpl
           repl npl with nplr
        endif
        repl osf with osf+osfr
     endif
     sele tov
     skip
  enddo

  PathDebr=gcPath_ew+'deb\'
  sele kegkpl
  repl all Sdv with osf*opt  ,sdp with Sdv
  //copy file kegkpl.dbf to (PathDebr+'kegkpl.dbf')
  copy for osf <> 0 to (PathDebr+'kegkpl.dbf')
  IF FILE((PathDebr+'kegkpl.cdx'))
    erase (PathDebr+'kegkpl.cdx')
  ENDIF
  close
  use (PathDebr+'kegkpl.dbf') alias kegkpl NEW
  inde on str(kpl,7)+str(mntov,7) tag t1
  inde on str(kpl)+str(keg) tag t2
  total on str(klp)+str(keg) field kvp to (PathDebr+'kegkplk2.dbf')

  close
  //copy file kegkpl.cdx to (PathDebr+'kegkpl.cdx')

  nuse()
  nuse('kegtov')
  nuse('kegkpl')

  PathDebr=gcPath_ew+'deb\'
  copy file kegtov.dbf to (PathDebr+'kegtov.dbf')
  copy file kegtov.cdx to (PathDebr+'kegtov.cdx')


  retu .t.

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  07-04-17 * 10:29:01am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION KegKgp()
  Local cTmp_pathr, nKgp
  Local cTmp_Select, dPeriod
  nKgp:=0

  cTmp_pathr:=pathr
  cTmp_Select:=select()

  sele etm
  if netseek('t2','kplr')
    nKgp:=etm->Kgp
    locate for empty(etm->nact) while kplr = etm->Kpl
    If found()
      nKgp:=etm->Kgp
    EndIf
  else
     nKgp=getfield('t2','kplr','tmesto','Kgp')
  endif

  // !!! .F.
  if .f.
    dPeriod:=Iif(empty(tov->Dpo),tov->Dpp,tov->Dpo)
    If bom(dPeriod) < STOD('20060801')
      dPeriod:=Iif(empty(tov->Dpp),tov->Dpo,tov->Dpp)
    EndIf

    // путь Периода, где создавалась карточка
    Pathr=gcPath_e + pathYYYYMM(dPeriod) + "\" + alltrim(cskl->path)
    outlog(__FILE__,__LINE__,Pathr,tov->ktl,tov->(RecNo()))
    netuse('rs1',,,1)

    netuse('rs2',,,1)
    ordsetfocus('t6') // по КТЛ
    If netseek('t6','tov->ktl')
      LOCATE for rs1->(netseek('t1','tov->Skl'), rs1->Skl = tov->Skl) ;
      while rs2->ktl = tov->ktl
      If Found()
        // нашли, по какому д-ту Покупатель делал возврат
        // по какому документу Лодис делал приход
        // rs1->Sks    rs1->AMn
        // перейдем в склад
        sele cskl
        locate for sk = rs2->Sks
        Pathr=gcPath_e + pathYYYYMM(tov->Dpp) + "\" + alltrim(cskl->path)
        netuse('pr1',,,1)
        nKgp:=getfield('t2','rs1->AMn','pr1','kzg')
        nuse('pr1')
      EndIf
    EndIf
    nuse('rs1')
    nuse('rs2')
  endif

  // получение данных ГП

  select (cTmp_Select)
  pathr:=cTmp_pathr
  //outlog(__FILE__,__LINE__,Pathr,tov->ktl,Select())
  RETURN (nKgp)

/**************
 дебиторка по кегам
 */
func TPokKegK()
  netuse('ctov')
  netuse('cskl')
  netuse('mkcros')
  netuse('kln')
  netuse('etm')
  netuse('tmesto')

  crtt('kegtov','f:mntov c:n(7) f:mntovt c:n(7) f:keg c:n(3) f:nat c:c(60)')
  sele 0
  use kegtov excl
  inde on str(mntov,7) tag t1
  //wait
  sele ctov
  set orde to tag t1
  go top
  do while int(mntov/10000)=0
     if mkeep#27
        skip
        loop
     endif
     if mkcros=0
        skip
        loop
     endif
     mntovr=mntov
     mntovtr=mntovt
     if mntovtr=0
        mntovtr=mntovr
     endif
     mkcrosr=mkcros
     natr=nat
     optr=opt
     sele mkcros
     if netseek('t1','mkcrosr')
        if keg>=30
           kegr=keg
           sele kegtov
           seek str(mntovr,7)
           if !foun()
              appe blank
              repl mntov with mntovr,;
                   mntovt with mntovtr,;
                   keg with kegr,;
                   nat with natr
           endif
        endif
     endif
     sele ctov
     skip
  enddo

  crtt('kegkpl','f:kgp c:n(7) f:kpl c:n(7) f:npl c:c(60) f:mntov c:n(7) ';
  +'f:mntovt c:n(7) f:ktl c:n(9) f:keg c:n(3) f:nat c:c(60) f:osf c:n(12,3) ';
  +'f:opt c:n(10,3)  f:Sdv c:n(11,2) f:sdp c:n(11,2) f:DtOpl c:d(10)')
  sele 0
  use kegkpl excl
  inde on str(kpl,7)+str(ktl,9) tag t1
  sele cskl
  locate for sk=234 // TPOK
  pathr=gcPath_d+alltrim(path)
  netuse('tov',,,1)
  go top
  do while !eof()
     if osf=0
        skip
        loop
     endif
     osfr=osf
     kplr=skl
     kgpr:=KegKgp()
     mntovr=mntov
     ktlr=ktl
     osfr=osf
     optr=opt

     sele kegtov
     seek str(mntovr,7)
     if foun()
        mntovtr=mntovt
        natr=nat
        kegr=keg

        sele kegkpl
        set orde to tag t1
        seek str(kplr,7)+str(ktlr,9)
        if !foun()
           appe blank
           repl kpl with kplr,;
                kgp with kgpr,;
                mntov with mntovr,;
                mntovt with mntovtr,;
                ktl with ktlr,;
                nat with natr,;
                keg with kegr,;
                opt with optr
           nplr=getfield('t1','kplr','kln','nkl')
           sele kegkpl
           repl npl with nplr
        endif
        repl osf with osf+osfr
     endif
     sele tov
     skip
  enddo

  PathDebr=gcPath_ew+'deb\'
  sele kegkpl
  repl all Sdv with osf*opt, sdp with Sdv
  //copy file kegkpl.dbf to (PathDebr+'kegkpl.dbf')
  copy for osf <> 0 to (PathDebr+'kegkpl.dbf')
  IF FILE((PathDebr+'kegkpl.cdx'));    erase (PathDebr+'kegkpl.cdx');  ENDIF
  close

  //fileDelete(PathDebr+kegkpl'+'.cdx')
  If file(PathDebr+'kegkpl'+'.cdx');     Erase (PathDebr+'kegkpl'+'.cdx');  EndIf

  use (PathDebr+'kegkpl.dbf') alias kegkpl NEW
  inde on str(kpl,7)+str(mntov,7) tag t1
  inde on str(kpl)+str(keg) tag t2
  total on str(kpl)+str(keg) field osf to tmpkgplk2.dbf
  close kegkpl

  use tmpkgplk2.dbf new
  copy to (PathDebr+'kegkplk2.dbf') for osf <> 0
  close tmpkgplk2

  close
  //copy file kegkpl.cdx to (PathDebr+'kegkpl.cdx')

  nuse()
  nuse('kegtov')
  nuse('kegkpl')

  PathDebr=gcPath_ew+'deb\'
  copy file kegtov.dbf to (PathDebr+'kegtov.dbf')
  copy file kegtov.cdx to (PathDebr+'kegtov.cdx')


  retu .t.

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  07-21-17 * 11:32:49am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION KegKgpKtl(nKpl, nKtl, dtEnd)
  LOCAL lSeek,  dBeg,  dEnd
  LOCAL ii:=1
  PRIVATE Kplr, Ktlr
  DEFAULT dtEnd TO  date()

        //outlog(__FILE__,__LINE__,nKpl, nKtl, dtEnd)

  set device to screen
  clear screen

  Ktlr:=nKtl
  Kplr:=nKpl

  // открыть склад ТараПокупателей
  sele cskl
  locate for sk=234 // TPOK

  dBeg:=ADDMONTH(BOM(dtEnd),-1)    //dBeg:=BOM(dtBeg)
  dEnd:=BOM(STOD('20060801'))

  lSeek:=.F.
  // начало цикла
  dBeg:=ADDMONTH(dBeg,+1)
  While (dBeg:=ADDMONTH(dBeg,-1),dBeg) >= dEnd
    pathr:=gcPath_e + pathYYYYMM(dBeg) + '\' + allt(cskl->path)
    @ 24, 0 say pathr
    If netfile('tov',1)
      netuse('tov','_tov',,1)
      ordsetfocus('t1')
      // ищем период, где нач.ост = 0
      //If dbseek(str(Kplr,7)+str(Ktlr,9))
      If netseek('t1','Kplr,Ktlr')
        If _tov->Osn = 0 // нашли
          lSeek:=.T.
          outlog(3,__FILE__,__LINE__,Kplr,Ktlr,RecNo(),pathr)
          nuse('_tov')
          exit
        EndIf
      EndIf
      nuse('_tov')
    endif
  enddo

  If lSeek
    lSeek:=.F.

    // расход
    netuse('rs1','_rs1',,1)
    netuse('rs2','_rs2',,1)
    ordsetfocus('t6')
    If netseek('t6','Ktlr')
      // промотрет все КТЛ в расходе
      Do While Ktlr = Ktl
        // прочитать чз ном. ТТН поле skl и сравнить Kplr
        If Kplr = getfield('t1','_rs2->ttn','_rs1','skl')
          lSeek:=.T.
          If EMPTY(_rs1->SkS)
            outlog(3,__FILE__,__LINE__,kegkpl->(RecNo()),'Err _rs1->SkS,',0,Kplr,Ktlr,pathr)
          Else
            outlog(3,__FILE__,__LINE__,' ','расход',_rs1->ttn,_rs1->SkS,_rs1->Amn)
          EndIf
          // идем в Склад  _rs1->SkS и в Приходе ищем Nm = _rs1->Amn
          exit
        EndIf
        sele _rs2
        skip
      EndDo
    Else
       // ,'  ',Ktlr,' RS2 строка расх не найдена')
    EndIf
    nuse('_rs1')
    nuse('_rs2')

    // поиск в приход
    If !lSeek
      netuse('pr1','_pr1',,1)
      netuse('pr2','_pr2',,1)
      ordsetfocus('t2')
      If netseek('t2','Ktlr')
        // промотрет все КТЛ в расходе
        Do While Ktlr = Ktl
          // прочитать чз ном. ТТН поле skl и сравнить Kplr
          If Kplr = getfield('t2','_pr2->mn','_pr1','skl')
            lSeek:=.T.
            If EMPTY(_pr1->SkS)
              outlog(__FILE__,__LINE__,kegkpl->(RecNo()),'Err _pr1->SkS,',0,Kplr,Ktlr,pathr)
            Else
              outlog(3,__FILE__,__LINE__,' ','приход',_pr1->mn,_pr1->SkS,_pr1->Amn,_pr1->Nd)
            EndIf
             // идем в Склад  _pr1->SkS и в Расходе ищем Nm = _rs1->Amn
            exit
          EndIf
          sele _pr2
          skip
        EndDo
      Else
         // outlog(__FILE__,__LINE__,'  ',Ktlr,' PR2 строка При-да не найдена')
      EndIf

    EndIf
    nuse('_pr1')
    nuse('_pr2')

    If lSeek
      // смотрим _rs1->SkS,_rs1->Amn
    else
      outlog(__FILE__,__LINE__,kegkpl->(RecNo()),kplr,Ktlr,'Err расход/приход не найден в TPOK',pathr)
      // поищем дальше от тек месяца
      if dBeg >= dEnd
        // outlog(__FILE__,__LINE__,nKpl, nKtl, dBeg)
        KegKgpKtl(nKpl, nKtl, dBeg)
      endif
    EndIf
  Else
    outlog(__FILE__,__LINE__,kegkpl->(RecNo()),Kplr,Ktlr,'Err нач.ост.не найден')
  EndIf
  //outlog(__FILE__,__LINE__)


  RETURN (NIL)
