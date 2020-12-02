#include "common.ch"
#include "inkey.ch"
#define DEB_CNT_DAY 40
PARAMETER nA361, dEnd


// Дебеторка по клиентам
  if gnArm#0
    clea
  endif

  PathDebr=gcPath_ew+'deb\'
  DirDebr=gcPath_ew+'deb'

  if dirchange(DirDebr)#0
     dirmake(DirDebr)
  endif
  dirchange(gcPath_l)

  netuse('kln')
  netuse('kplkgp')
  netuse('klndog')
  netuse('cskl')
  netuse('s_tag')
  netuse('krn')
  netuse('knasp')
  netuse('opfh')
  netuse('bs')
  netuse('edz')


  if !file(PathDebr+'tbs.dbf')
     crtt(PathDebr+'tbs','f:bs c:n(6) f:nbs c:c(20) f:uchr c:n(1) f:dtc c:d(10) f:tmc c:c(8)')
  endif

  lpDebr=gcPath_l+'\deb'+str(gnEnt,2)+'\'
  DirDbr=gcPath_l+'\deb'+str(gnEnt,2)

  if dirchange(DirDbr)#0
     dirmake(DirDbr)
  endif
  dirchange(gcPath_l)

  if gnAdm=1.or.gnArm=0
    // tbs  список счетов по которым считать д-ку
     sele 0
     use (PathDebr+'tbs') excl
     sele bs
     do while !eof()
        if gnArm#0
           if !(uchr=1.or.uchr=2)
              skip
              loop
           endif
        else
           if !(bs=361001.or.bs=361002)
              skip
              loop
           endif
        endif
        bsr=bs
        nbsr=nbs
        uchrr=uchr
        sele tbs
        locate for bs=bsr
        if !foun()
           netadd()
           netrepl('bs,nbs,uchr',{bsr,nbsr,uchrr})
        endif
        sele bs
        skip
     enddo

     // создаем каталоги
     sele tbs
     go top
     do while !eof()
        bsr=bs
        ddebr=PathDebr+'s'+str(bsr,6)
        if dirchange(ddebr)#0
           dirmake(ddebr)
        endif
        dirchange(gcPath_l)

        pDebr=PathDebr+'s'+str(bsr,6)+'\'
        if file(pDebr+'pdeb.dbf')
           adirect=directory(pDebr+'pdeb.dbf')
           dtcr=adirect[1,3]
           tmcr=adirect[1,4]
           repl dtc with dtcr,tmc with tmcr
        endif
        sele tbs
        skip
     enddo
     sele tbs
     use
  endif

  if file (PathDebr+'tbs.dbf')
     copy file (PathDebr+'tbs.dbf') to (lpDebr+'tbs.dbf')
  endif
  if file (PathDebr+'tbs.cdx')
     copy file (pDebr+'tbs.cdx') to (lpDebr+'tbs.cdx')
  endif
  sele 0
  use (lpDebr+'tbs') excl

  // создание каталого для счетов
  sele tbs
  go top
  do while !eof()
     bsr=bs
     lddebr=lpDebr+'s'+str(bsr,6)
     if dirchange(lddebr)#0
        dirmake(lddebr)
     endif
     dirchange(gcPath_l)

     sele tbs
     skip
  enddo

  dirchange(gcPath_l)

  sele tbs
  go top
  if gnArm#0
     store 0 to bsr,uchr,Ogrr
     store ctod('') to dtcr
     store '' to nbsr,tmcr
     store 1 to psr
     rctbsr=recn()
     do while .t.
        sele tbs
        go rctbsr
        foot('ENTER,F5','Просмотр,Обновить')
        rctbsr=slcf('tbs',,,,,"e:bs h:'Счет' c:n(6) e:nbs h:'Наименование' c:c(20) e:uchr h:'Уч' c:n(3) e:dtc h:'Дата' c:d(10) e:tmc h:'Время' c:c(8)",,,,,,,'СЧЕТА')
        if lastkey()=K_ESC
           exit
        endif
        go rctbsr
        bsr=bs
        nbsr=nbs
        uchrr=uchr
        dtcr=dtc
        tmcr=tmc
        pDebr=PathDebr+'s'+str(bsr,6)+'\'
        ldebr=lpDebr+'s'+str(bsr,6)+'\'
        do case
           case lastkey()=K_ENTER
                if empty(dtcr).and.gnAdm=1
                   debb(bsr)
                endif
                save scre to scshow
                ShowDeb()
                rest scre from scshow
           case lastkey()=K_F5.and.(gnAdm=1.or.gnKto=289)
                debb(bsr)
        endcase
     enddo
  else
     Ogrr=0 // сумма ограничния сальдо
     sele tbs
     go top
     do while !eof()
        rctbsr=recn()
        bsr=bs
        if !(bsr=361001.or.bsr=361002)
           skip
           loop
        endif
        nbsr=nbs
        uchrr=uchr
        dtcr=dtc
        tmcr=tmc
        pDebr=PathDebr+'s'+str(bsr,6)+'\'
        debb(bsr)
        sele tbs
        go rctbsr
        skip
     enddo
  endif
  sele tbs
  use
  if select('pdeb')#0
     sele pdeb
     use
  endif
  if select('trs2')#0
     sele trs2
     use
  endif
  if select('tpr2')#0
     sele tpr2
     use
  endif
  if select('tdokk')#0
     sele tdokk
     use
  endif
  nuse()

*******************
static func debb(p1)
  *******************
  if select('pdeb')#0
     sele pdeb
     use
  endif
  erase (pDebr+'pdeb.ddf')
  erase (pDebr+'pdeb.cdx')

  if select('dz')#0
     sele dz
     use
  endif
  erase (pDebr+'dz.dbf')
  erase (pDebr+'dz.cdx')

  if select('kz')#0
     sele kz
     use
  endif
  erase (pDebr+'kz.dbf')
  erase (pDebr+'kz.cdx')

  if select('tDop')#0
     sele tDop
     use
  endif
  erase (pDebr+'tDop.dbf')
  erase (pDebr+'tDop.cdx')

  if select('trs2')#0
     sele trs2
     use
  endif
  erase (pDebr+'trs2.dbf')
  erase (pDebr+'trs2.cdx')

  if select('tpr2')#0
     sele tpr2
     use
  endif
  erase (pDebr+'tpr2.dbf')
  erase (pDebr+'tpr2.cdx')

  if select('tSaldo')#0
     sele tSaldo
     use
  endif
  erase (pDebr+'tSaldo.dbf')
  erase (pDebr+'tSaldo.cdx')

  if select('tPrz01')#0
     sele tPrz01
     use
  endif
  erase (pDebr+'tPrz01.dbf')
  erase (pDebr+'tPrz01.cdx')

  if select('tPrz02')#0
     sele tPrz02
     use
  endif
  erase (pDebr+'tPrz02.dbf')
  erase (pDebr+'tPrz02.cdx')

  if select('trs27')#0
     sele trs27
     use
  endif
  erase (pDebr+'trs27.dbf')
  erase (pDebr+'trs27.cdx')

  if select('tdeb')#0
     sele tdeb
     use
  endif
  erase (pDebr+'tdeb.dbf')
  erase (pDebr+'tdeb.cdx')

  if select('tdokk')#0
     sele tdokk
     use
  endif
  erase (pDebr+'tdokk.dbf')
  erase (pDebr+'tdokk.cdx')

  If file(pDebr+'tpr2'+'.cdx');    erase (pDebr+'tpr2'+'.cdx');  EndIf
  crtt(pDebr+'tpr2','f:kps c:n(7) f:kzg c:n(7) f:dpr c:d(10) f:sdv c:n(10,2) f:sdvm c:n(10,2) f:sdvt c:n(10,2) f:sdvs c:n(10,2) f:prz c:n(1) f:reg c:n(4) f:kta c:n(4) f:sk c:n(3) f:nd c:n(6) f:mn c:n(6) f:kop c:n(3) f:sdp c:n(11,2)')
  use (pDebr+'tpr2') new  excl

  If file(pDebr+'trs2'+'.cdx');    erase (pDebr+'trs2'+'.cdx');  EndIf
  crtt(pDebr+'trs2','f:kpl c:n(7) f:kgp c:n(7) f:dop c:d(10) f:sdv c:n(10,2) f:sdvm c:n(10,2) f:sdvm1 c:n(10,2) f:sdvm2 c:n(10,2) f:sdvt c:n(10,2) f:sdvs c:n(10,2) f:prz c:n(1) f:reg c:n(4) f:kta c:n(4) f:sk c:n(3) f:ttn c:n(6) f:kop c:n(3) f:sdp c:n(11,2) f:DtOpl c:d(10)')
  use (pDebr+'trs2') new excl

  // путь пред месяца
  dtpmr=bom(addmonth(gdTd,-1)) //ctod(stuff(dtoc(addmonth(gdTd,-1)),1,2,'01')))
  gpmr=year(dtpmr);  mpmr=month(dtpmr)
  pPathr=gcPath_e+'g'+str(gpmr,4)+'\m'+iif(mpmr>9,str(mpmr,2),'0'+str(mpmr,1))+'\'

  sele cskl
  go top
  do while !eof()
     if !(rasc=1.and.ent=gnEnt)
        skip;     loop
     endif
     skr=sk
     pathr=gcPath_d+alltrim(path)
     if !netfile('soper',1)
        sele cskl;        skip;        loop
     endif
     netuse('rs1',,,1)
     netuse('rs3',,,1)
     netuse('pr1',,,1)
     netuse('pr3',,,1)
     netuse('soper',,,1)
     koprp(bsr)
     // условие пропускаем (берем все кроме выписанных)
     bFor:={||empty(_Field->Dop)}
     pDebr_trs22(bFor)

     pDebr_tpr22() // Возвраты

     nuse('rs1')
     nuse('rs3')
     nuse('pr1')
     nuse('pr3')
     nuse('soper')

     // Предыдущий
     sele cskl
     pathr=pPathr+alltrim(path)
     if !netfile('soper',1)
        sele cskl;        skip;        loop
     endif
     netuse('rs1',,,1)
     netuse('rs3',,,1)
     netuse('pr1',,,1)
     netuse('pr3',,,1)
     netuse('soper',,,1)
     koprp(bsr)
     // условие пропускаем (только подтвержденные)
     bFor:={|| _Field->prz=0 }
     pDebr_trs22(bFor)

     pDebr_tpr22() // Возвраты

     nuse('rs1')
     nuse('rs3')
     nuse('pr1')
     nuse('pr3')
     nuse('soper')
     sele cskl
     skip
  enddo


  sele trs2
  do case
  case bsr=361001
    repl all Sdvs with Sdvm, Sdp with Sdvs // товар
  case bsr=361002
    repl all Sdvs with Sdvt, Sdp with Sdvs // тара
  other
      repl all Sdvs with Sdv, Sdp with Sdvs
  endcase
  inde on str(kpl,7) tag t1

  sele tpr2
  do case
  case bsr=361001
    repl all Sdvs with Sdvm, Sdp with Sdvs
  case bsr=361002
    repl all Sdvs with Sdvt, Sdp with Sdvs
  other
    repl all Sdvs with Sdv, Sdp with Sdvs
  endcase
  inde on str(kps,7) tag t1


  netuse('dkkln')
  netuse('dknap')

  /////////////// сальдок по П-кам из dkkln официальное ////////////
  // П-щик, Сальдо, дата обновлния сальдо
  crtt('tSaldo','f:kkl c:n(7) f:saldo c:n(12,2) f:ddb c:d(10)')
  use tSaldo new excl
  sele dkkln
  go top
  do while !eof()
     if bs#bsr
        skip
        loop
     endif
     kklr=kkl
  //if kklr=22009
  //wait
  //endif
     Saldor=dn-kn+db-kr
     ddbr=ddb
     sele tSaldo
     appe blank
     repl kkl with kklr,;
          saldo with Saldor,;
          ddb with ddbr
     sele dkkln
     skip
  enddo
  sele tSaldo
  inde on str(kkl,7) tag t1
  //////////////////////////////////

  ///////////// Кредиторская задолженность//////////////
  crtt(pDebr+'kz','f:kkl c:n(7) f:kz c:n(12,2)')
  use (pDebr+'kz') new excl
  sele dkkln
  go top
  do while !eof()
     kklr=kkl
     bs_r=bs
     if bs_r=bsr
        skip
        loop
     endif
     sele tbs
     locate for bs=bs_r
     if !foun()
        sele dkkln
        skip
        loop
     endif
     sele dkkln
     if dn-kn+db-kr>=0
        sele dkkln
        skip
        loop
     endif
     kzr=dn-kn+db-kr
     sele kz
     appe blank
     repl kkl with kklr,kz with kzr
     sele dkkln
     skip
  enddo
  sele kz
  inde on str(kkl,7) tag t1
  ///////////////////////////////////////////


  ////// Дебеторская задолженность  ////////////
  crtt(pDebr+'dz','f:kkl c:n(7) f:dz c:n(10,2) f:ddb c:d(10)')
  use (pDebr+'dz') new excl
  inde on str(kkl,7) tag t1

  // суммы догла Пл-ка по Откруженных (Не подвержденных)
  crtt('tPrz01','f:kkl c:n(7) f:Sdv c:n(12,2)')
  use tPrz01 new excl
  inde on str(kkl,7) tag t1
  sele trs2
  go top
  do while !eof()
     if prz=1 // подвержденные
        skip
        loop
     endif
     kklr=kpl
    //if kklr=22009
    //wait
    //endif
     sele tSaldo // сальдо из dkkln
     seek str(kklr,7)
     if !found()
        sele trs2
        skip
        loop
     endif

     sele trs2
     Sdvr=Sdvs
     sele tPrz01
     seek str(kklr,7)
     if !foun()
        appe blank
        repl kkl with kklr
     endif
     repl Sdv with Sdv+Sdvr
     sele trs2
     skip
  enddo
  ///////////////////////////////////////////////////////////

  // какие даты открузки участвют
  crtt(pDebr+'tDop1','f:ndop c:n(4) f:dop c:d(10)')
  use (pDebr+'tDop1') new excl
  inde on dtos(dop) tag t1 desc

  // салько П-ков, которых нет в dkkln
  crtt('tPrz02','f:kkl c:n(7) f:Sdv c:n(12,2) f:dop c:d(10)')
  use tPrz02 new excl
  inde on str(kkl,7) tag t1
  sele trs2
  go top
  do while !eof()

     //  добавление дат отрузок
     dopr=dop // дата отгрузки
     sele tDop1
     seek dtos(dopr)
     if !found()
        appe blank
        repl Dop with Dopr
     endif

     // пропустим подвержденне
     sele trs2
     if prz=1
        skip;  loop
     endif

  //if kklr=22009
  //wait
  //endif
     // если п-к в официальнм сальде  участвует, то пропуск
     kklr=kpl
     sele tSaldo
     seek str(kklr,7)
     if found()
        sele trs2
        skip
        loop
     endif

     // салько П-ков, которых нет в dkkln
     sele trs2
     Sdvr=Sdvs
     Dopr=Dop
     sele tPrz02
     seek str(kklr,7)
     if !foun()
        appe blank
        repl kkl with kklr
     endif
     repl Sdv with Sdv+Sdvr

     sele trs2
     skip
  enddo
  ////////////////////////// END салько П-ков, которых нет в dkkln



  ////////////// добавление к долгу Отгруженных
  sele tSaldo // сальдо из dkkln
  go top
  do while !eof()
     kklr=kkl
  //if kklr=22009
  //wait
  //endif
     Saldor=saldo
     ddbr=ddb

     sele tPrz01 // суммы догла Пл-ка по Откруженных
     seek str(kklr,7)
     if foun()
        Saldor=Saldor+Sdv
     endif

     if Saldor>=Ogrr
        sele dz
        appe blank
        repl kkl with kklr,dz with Saldor,ddb with ddbr
     endif

     sele tSaldo
     skip
  enddo
  /////////////////////////////////////////////


  sele tPrz02 // салько П-ков, которых нет в dkkln
  go top
  do while !eof()
     if Sdv=0
        skip
        loop
     endif

     kklr=kkl
     Saldor=Sdv
     ddbr=Dop

     if Saldor>=Ogrr
        sele dz
        appe blank
        repl kkl with kklr,dz with Saldor,ddb with ddbr
     endif

     sele tPrz02
     skip
  enddo
  ///////////////////////////////////////


  //// добавляем текующию дату
  sele tDop1
  locate for Dop=date()
  if !foun()
     sele tDop1
     appe blank
     repl Dop with date()

     sele trs2
     appe blank
     repl Dop with date()
  endif



  sele tDop1
  go bott
  minDopr=Dop
  go top
  do while !eof()
     rcnr=recn()
     Dopr=Dop
     if Dopr=minDopr
        exit
     endif
     skip
     if Dop#Dopr-1
        appe blank
        repl Dop with Dopr-1
        sele trs2
        appe blank
        repl Dop with Dopr-1
        sele tDop1
        go rcnr
        skip
        loop
     endif
  enddo

  rccr=recc()
  if rccr < DEB_CNT_DAY // меньше, то дополним
     sele tDop1
     go bott
     Dopr=Dop
     for l=rccr+1 to DEB_CNT_DAY
         Dopr=Dopr-1
         sele tDop1
         appe blank
         repl Dop with Dopr
         sele trs2
         appe blank
         repl Dop with Dopr
     next
  endif

  sele tDop1
  ir=recc()

  if ir > 94
    ir := 94
  endif

  sele tDop1
  sort to (pDebr+'tDop') on Dop /D // сортировка в обратном прядке
  use

  use (pDebr+'tDop') new excl
  repl all nDop with recn()
  dele all for nDop>94
  pack

  crtt(pDebr+'trs27','f:kkl c:n(7) f:dop c:d(10) f:prz c:n(1) f:Sdv c:n(12,2) f:ndop c:n(2) f:reg c:n(4)')
  use (pDebr+'trs27') new excl
  inde on str(kkl,7)+dtos(Dop) tag t1
  sele trs2
  go top
  do while !eof()
     Dopr=Dop
     sele tDop
     locate for Dop=Dopr
     if !foun()
        sele trs2
        skip
        loop
     else
        nDopr=nDop
     endif
     sele trs2
     kklr=kpl
     przr=prz
     Sdvr=Sdvs
     regr=reg
     sele trs27
     seek str(kklr,7)+dtos(Dopr)
     if !foun()
        appe blank
        repl kkl with kklr,;
             Dop with Dopr
     endif
     repl Sdv with Sdv+Sdvr,;
          prz with przr,;
          reg with regr,;
          nDop with nDopr
     sele trs2
     skip
  enddo
  sele tDop
  copy stru to stemp exte
  sele 0
  use stemp excl
  zap
  appe blank
  repl field_name with 'kkl',;
       field_type with 'n',;
       field_len with 7,;
       field_dec with 0
  appe blank
  repl field_name with 'reg',;
       field_type with 'n',;
       field_len with 4,;
       field_dec with 0
  appe blank
  repl field_name with 'nkl',;
       field_type with 'c',;
       field_len with 40,;
       field_dec with 0
  appe blank
  repl field_name with 'krn',;
       field_type with 'n',;
       field_len with 4,;
       field_dec with 0
  appe blank
  repl field_name with 'knasp',;
       field_type with 'n',;
       field_len with 4,;
       field_dec with 0
  appe blank
  repl field_name with 'nrn',;
       field_type with 'c',;
       field_len with 20,;
       field_dec with 0
  appe blank
  repl field_name with 'pdz',;
       field_type with 'n',;
       field_len with 10,;
       field_dec with 2
  appe blank
  repl field_name with 'pdz1',;
       field_type with 'n',;
       field_len with 10,;
       field_dec with 2
  appe blank
  repl field_name with 'pdz3',;
       field_type with 'n',;
       field_len with 10,;
       field_dec with 2
  appe blank
  repl field_name with 'pdz4',;
       field_type with 'n',;
       field_len with 10,;
       field_dec with 2
  appe blank
  repl field_name with 'dz',;
       field_type with 'n',;
       field_len with 12,;
       field_dec with 2
  appe blank
  repl field_name with 'kz',;
       field_type with 'n',;
       field_len with 12,;
       field_dec with 2
  appe blank
  repl field_name with 'ddk',;
       field_type with 'd',;
       field_len with 10,;
       field_dec with 0
  appe blank
  repl field_name with 'ddb',;
       field_type with 'd',;
       field_len with 10,;
       field_dec with 0
  appe blank
  repl field_name with 'bs_s',;
       field_type with 'n',;
       field_len with 10,;
       field_dec with 2
  appe blank
  repl field_name with 'bs_d',;
       field_type with 'n',;
       field_len with 3,;
       field_dec with 0
  appe blank
  repl field_name with 'sprz0',;
       field_type with 'n',;
       field_len with 10,;
       field_dec with 2
  appe blank
  repl field_name with 'kdopl',;
       field_type with 'n',;
       field_len with 3,;
       field_dec with 0
  appe blank
  repl field_name with 'rkdopl',;
       field_type with 'n',;
       field_len with 4,;
       field_dec with 0

  Fld_SdvDop(99) // для контроля разницы между DZ и того, что разнесено

  sele tDop
  go top
  do while !eof()
     nDopr=nDop
     stemp->(Fld_SdvDop(nDopr))
     sele tdop
     skip
  enddo
  sele stemp
  use
  create (pDebr+'tdeb') from stemp new
  use

  use (pDebr+'tdeb') new excl
  inde on str(kkl,7) tag t1

  sele trs27
  go top
  do while !eof()
     kklr=kkl
     Dopr=Dop
     regr=reg
     Sdvr=Sdv
     nDopr=nDop
     cSdvr='Sdv'+padl(alltrim(str(nDopr,3)),3,'0')
     cDopr='Dop'+padl(alltrim(str(nDopr,3)),3,'0')
     sele tdeb
     seek str(kklr,7)
     if !foun()
        appe blank
        repl kkl with kklr,;
             reg with regr
     endif
     repl &cSdvr with Sdvr,;
          &cDopr with Dopr
     sele trs27
     skip
  enddo

  sele dz
  go top
  do while !eof()
     kklr=kkl
     sele tdeb
     seek str(kklr,7)
     if !foun()
        appe blank
        repl kkl with kklr
     endif
     sele dz
     skip
  enddo
  sele trs27
  use

  netuse('dokk')
  netuse('doks')
  crtt(pDebr+'tdokk','f:kkl c:n(7) f:ddk c:d(10) f:bs_d c:n(6) f:bs_s c:n(10,2) f:rn c:n(6) f:nplp c:n(6) f:osn c:c(20) f:kta c:n(4) f:ktapl c:n(4)')
  sele 0
  use (pDebr+'tdokk') excl
  inde on str(kkl,7) tag t1
  sele dokk
  go top
  do while !eof()
     if prc
        skip
        loop
     endif
     if mn=0
        skip
        loop
     endif
     if bs_d<1000.or.bs_k<1000
        skip
        loop
     endif
     kklr=kkl
     sele tdeb
     seek str(kklr,7)
     if !foun()
        sele dokk
        skip
        loop
     endif
     sele dokk
     mnr=mn
     kklr=kkl
     rndr=rnd
     ktar=kta
     if fieldpos('ktapl')#0
        ktaplr=ktapl
     else
        ktaplr=0
     endif
     sele doks
     seek str(mnr,6)+str(rndr,6)+str(kklr,7)
     if !foun()
        sele dokk
        skip
        loop
     else
        osnr=alltrim(osn)
     endif
     sele dokk
     ddkr=ddk
     bs_dr=bs_d
     bs_sr=bs_s
     rnr=rn
     nplpr=nplp
     sele tdokk
     appe blank
     repl kkl with kklr,     rn with rnr,;
          bs_d with bs_dr,   bs_s with bs_sr,;
          nplp with nplpr,   osn with osnr,;
          ddk with ddkr,     kta with ktar,;
          ktapl with ktaplr
     sele dokk
     skip
  enddo
  // sele tdokk
  // kklr=0
  // scan all
  //     if kklr=kkl
  //        kklr=kkl
  //        dele
  //     endif
  // ends
  // pack

  sele tdeb
  go top
  do while !eof()
     kklr=kkl
     kDoplr=getfield('t1','kklr','klndog','kDopl')
     krnr=krn
     regr=reg
     knaspr=getfield('t1','kklr','kln','knasp')
     nnaspr=getfield('t1','knaspr','knasp','nnasp')
     nkler=getfield('t1','kklr','kln','nkle')
     opfhr=getfield('t1','kklr','kln','opfh')
     nsopfhr=getfield('t1','opfhr','opfh','nsopfh')
     nklr=alltrim(nnaspr)+' '+alltrim(nsopfhr)+' '+alltrim(nkler)
     nklr=upper(nklr)
     pdzr=0
     pdz1r=0
     pdz2r=0
     pdz3r=0
     pdz4r=0
     sele dz
     seek str(kklr,7)
     if foun()
        pdzr=dz
        pdz1r=dz
        pdz2r=dz
        pdz3r=dz
        pdz4r=dz
     endif

     sele dkkln
     locate for kkl=kklr.and.bs=bsr
     if foun()
        ddbr=ddb
        sele tdeb
        repl ddb with ddbr
     endif
     sele tdeb
     for i=1 to ir
         cSdvr='Sdv'+padl(alltrim(str(i,3)),3,'0')
         Sdvr=&cSdvr
         if i<8
            if pdzr>Sdvr
               pdzr=pdzr-Sdvr
            else
               Sdvr=pdzr
               repl &cSdvr with Sdvr
               pdzr=0
            endif
         endif
         if i<15
            if pdz1r>Sdvr
               pdz1r=pdz1r-Sdvr
            else
               Sdvr=pdz1r
               repl &cSdvr with Sdvr
               pdz1r=0
            endif
         endif
         if i<22
            if pdz3r>Sdvr
               pdz3r=pdz3r-Sdvr
            else
               Sdvr=pdz3r
               repl &cSdvr with Sdvr
               pdz3r=0
            endif
         endif
         if i<31
            if pdz4r>Sdvr
               pdz4r=pdz4r-Sdvr
            else
               Sdvr=pdz4r
               repl &cSdvr with Sdvr
               pdz4r=0
            endif
         endif
         if pdz2r>Sdvr
            pdz2r=pdz2r-Sdvr
         else
            Sdvr=pdz2r
            repl &cSdvr with Sdvr
            pdz2r=0
         endif
         if Sdvr>100
            sele tDop
            locate for nDop=i
            ddbr=Dop
            sele tdeb
            repl ddb with ddbr
         endif
    next
    repl pdz with pdzr,pdz1 with pdz1r,pdz3 with pdz3r,pdz4 with pdz4r
    sele kz
    locate for kkl=kklr
    kzr=0
    if foun()
       kzr=abs(kz)
       sele tdeb
       repl kz with kzr
    endif
    sele tPrz01
    locate for kkl=kklr
    if foun()
       sprz0r=Sdv
       sele tdeb
       repl sprz0 with sprz0r
    endif
    sele tPrz02
    locate for kkl=kklr
    if foun()
       sprz0r=Sdv
       sele tdeb
       repl sprz0 with sprz0r
    endif
    sele dz
    seek str(kklr,7)
    if foun()
       dzr=dz
       sele tdeb
       repl dz with dzr
    endi
    nrnr=''
    sele krn
    locate for krn=krnr
    if foun()
       nrnr=nrn
    endif
    sele tdeb
    repl nrn with nrnr,;
         nkl with nklr ,;
         kDopl with kDoplr
    sele tdokk
    seek str(kklr,7)
    if foun()
       ddkr=ddk
       bs_sr=bs_s
       bs_dr=int(bs_d/1000)
       sele tdeb
       repl bs_s with bs_sr,ddk with ddkr,bs_d with bs_dr
    endif
    sele tdeb
    for i=94 to 1 step -1
        cSdvr='Sdv'+padl(alltrim(str(i,3)),3,'0'); pSdvr:=FieldPos(cSdvr)
        cDopr='Dop'+padl(alltrim(str(i,3)),3,'0'); pDopr:=FieldPos(cDopr)
        if fieldpos(cSdvr)=0
           loop
        endif
        if FieldGet(pSdvr) > 0 // &cSdvr>0
           Dopr=FieldGet(pDopr)// &cDopr
           rkDoplr = gdTd - Dopr // сколько дней назад откгружали
           sele tdeb
           repl rkDopl with rkDoplr
           exit
        endif
    next
    sele tdeb
    skip
  enddo

  nSumTotMaxDay := SumMaxDay('tdeb', 99)
  nSumMaxDay := 0
  outlog(__FILE__,__LINE__,'skdoc91',nSumMaxDay, nSumTotMaxDay)

  sele trs2
  inde on str(kpl, 7)+dtos(dop) tag t1

  sele tdokk
  sele tdeb // текущий
  sort on nkl to (pDebr+'pdeb') for dz#0 // сортированный
  use

  // обновление поля DopXXX
  use (pDebr+'pdeb') new excl
  sele tDop
  go top
  do while !eof()
     cDopr='Dop'+padl(alltrim(str(nDop,3)),3,'0'); pDopr:=FieldPos(cDopr)
     Dopr:=Dop

     sele pdeb
     FieldPut(pDopr,Dopr) // repl all &cDopr with Dopr

     sele tDop;     skip
  enddo

  sele pdeb
  sele trs2
  Updt_Sdp('pdeb','trs2',iif(bsr=361001,{||_FIELD->kop=170},{||.t.}),.F.)


  if select('dz')#0
     sele dz;     use
  endif
  if select('kz')#0
     sele kz ;     use
  endif
  if select('tDop')#0
     sele tDop;     use
  endif
  if select('trs2')#0
     sele trs2 ;     use
  endif
  if select('tpr2')#0
     sele tpr2 ;     use
  endif
  if select('tSaldo')#0
     sele tSaldo;     use
  endif
  if select('tPrz01')#0
     sele tPrz01 ;     use
  endif
  if select('tPrz02')#0
     sele tPrz02  ;     use
  endif
  if select('trs27')#0
     sele trs27  ;     use
  endif
  if select('tdeb')#0
     sele tdeb  ;     use
  endif
  if select('tdokk')#0
     sele tdokk ;     use
  endif

  sele pdeb
  inde on nkl tag t1
  repl all reg with 1
  if select('edz')#0
     if bsr=361001
        sele pdeb
        go top
        do while !eof()
           kklr=kkl
           dzr=dz
           pdzr=pdz
           pdz1r=pdz1
           pdz3r=pdz3
           pdz4r=pdz4
           sele edz
           if !netseek('t1','kklr')
              netadd()
              netrepl('kkl',{kklr})
           endif
           netrepl('dz,pdz,pdz1,pdz3,pdz4',{dzr,pdzr,pdz1r,pdz3r,pdz4r})
           sele pdeb
           skip
        enddo
     endif
  endif
  sele pdeb
  use
  use
  retu .t.

********************
func ShowDeb()
  ********************
  netuse('kln')
  if select('pdeb')#0
     sele pdeb
     use
  endif
  if select('trs2')#0
     sele trs2
     use
  endif
  if select('tpr2')#0
     sele tpr2
     use
  endif
  if select('tdokk')#0
     sele tdokk
     use
  endif

  if file (pDebr+'pdeb.dbf')
     copy file (pDebr+'pdeb.dbf') to (ldebr+'pdeb.dbf')
  endif
  if file (pDebr+'pdeb.cdx')
     copy file (pDebr+'pdeb.cdx') to (ldebr+'pdeb.cdx')
  endif
  sele 0
  use (ldebr+'pdeb') share
  set orde to tag t1
  go top

  if file (pDebr+'trs2.dbf')
     copy file (pDebr+'trs2.dbf') to (ldebr+'trs2.dbf')
  endif
  if file (pDebr+'trs2.cdx')
     copy file (pDebr+'trs2.cdx') to (ldebr+'trs2.cdx')
  endif
  sele 0
  use (ldebr+'trs2') share
  set orde to tag t1
  go top

  if file (pDebr+'tpr2.dbf')
     copy file (pDebr+'tpr2.dbf') to (ldebr+'tpr2.dbf')
  endif
  if file (pDebr+'tpr2.cdx')
     copy file (pDebr+'tpr2.cdx') to (ldebr+'tpr2.cdx')
  endif
  sele 0
  use (ldebr+'tpr2') share
  set orde to tag t1
  go top

  if file (pDebr+'tdokk.dbf')
     copy file (pDebr+'tdokk.dbf') to (ldebr+'tdokk.dbf')
  endif
  if file (pDebr+'tdokk.cdx')
     copy file (pDebr+'tdokk.cdx') to (ldebr+'tdokk.cdx')
  endif
  sele 0
  use (ldebr+'tdokk') share
  set orde to tag t1
  go top

  sele pdeb
  rcdebr=recn()
  fldnomr=1
  for_r='.t.'
  forr=for_r
  store space(20) to ctextr
  store 0 to kkl_r,napr,kta_r
  store space(9) to msk_r
  do while .t.
     sele pdeb
     go rcdebr
     foot('F3,F4,F5,F6','Фильтр,Отгрузки,Оплата,Возврат')
     rcdebr=slce('pdeb',1,1,18,,"e:kkl h:'Код' c:n(7) e:nkl h:'Наименование' c:c(30) e:dz h:'ДЗ' c:n(10,2) e:pdz h:'ПДЗ>7' c:n(10,2) e:pdz1 h:'ПДЗ>14' c:n(10,2) e:pdz3 h:'ПДЗ>21' c:n(10,2) e:pdz4 h:'ПДЗ>30' c:n(10,2) e:kz h:'КЗ' c:n(10,2) e:ddk h:'ДПО' c:d(10) e:bs_s h:'СПО' c:n(10,2) e:bs_d h:'Вид' c:n(3) e:kdopl h:'ДнО' c:n(3) e:rkdopl h:'ДнЗ' c:n(3)",,,1,,forr,,str(bsr,6),1,2)
     go rcdebr
     kklr=kkl
     nkplr=getfield('t1','kklr','kln','nkl')
     nkplr=alltrim(nkplr)
     do case
        case lastkey()=K_ESC
             exit
        case lastkey()=19 // Left
             fldnomr=fldnomr-1
             if fldnomr=0
                fldnomr=1
             endif
        case lastkey()=4 // Right
             fldnomr=fldnomr+1
        case lastkey()=K_F3
             debflt()
        case lastkey()=K_F4 // Отгрузки
             sele trs2
             if netseek('t1','kklr')
                fldnom_rr=fldnomr
                fldnomr=1
                rcskdocr=recn()
                do case
                   case bsr=361001
                        rsforr='.t..and.Sdvm#0'
                   case bsr=361002
                        rsforr='.t..and.Sdvt#0'
                   othe
                        rsforr='.t.'
                endcase
                do while .t.
                   go rcskdocr
                   rcskdocr=slce('trs2',,,,,"e:sk h:'SK' c:n(3) e:ttn h:'TTN' c:n(6) e:dop h:'Дата' c:d(10) e:prz h:'П' c:n(1) e:kop h:'КОП' c:n(3) e:Sdv h:'Сумма' c:n(10,2) e:Sdvm h:'СуммаM' c:n(10,2) e:Sdvt h:'СуммаT' c:n(10,2) e:kta  h:'Код' c:n(4) e:getfield('t1','trs2->kta','s_tag','fio') h:'Агент' c:с(15) e:kgp h:'КодП' c:n(7) e:getfield('t1','trs2->kgp','kln','nkl') h:'Получатель' c:c(20)",,,,'kpl=kklr',rsforr,,nkplr)
                   go rcskdocr
                   do case
                      case lastkey()=K_ESC
                           exit
                      case lastkey()=19 // Left
                           fldnomr=fldnomr-1
                           if fldnomr=0
                              fldnomr=1
                           endif
                      case lastkey()=4 // Right
                           fldnomr=fldnomr+1
                   endcase
                enddo
                fldnomr=fldnom_rr
             endif
        case lastkey()=K_F5 // Оплата
             sele tdokk
             if netseek('t1','kklr')
                fldnom_rr=fldnomr
                fldnomr=1
                rcbdocr=recn()
                do while .t.
                   go rcbdocr
                   do case
                      case gnEnt=20
                           rcbdocr=slce('tdokk',,,,,"e:ddk h:'Дата' c:d(10) e:bs_d h:'Счет' c:n(6) e:bs_s h:'Сумма' c:n(10,2) e:nplp  h:'Поруч' c:n(6) e:osn h:'Основание' c:с(20)",,,,'kkl=kklr',,,nkplr)
                      case gnEnt=21
                           rcbdocr=slce('tdokk',,,,,"e:ddk h:'Дата' c:d(10) e:bs_d h:'Счет' c:n(6) e:bs_s h:'Сумма' c:n(10,2) e:nplp  h:'Поруч' c:n(6) e:osn h:'Основание' c:с(20) e:kta h:'КОД' c:n(4) e:getfield('t1','tdokk->kta','s_tag','fio') h:'Агент' c:c(15)",,,,'kkl=kklr',,,nkplr)
                      othe
                           rcbdocr=slce('tdokk',,,,,"e:ddk h:'Дата' c:d(10) e:bs_d h:'Счет' c:n(6) e:bs_s h:'Сумма' c:n(10,2) e:nplp  h:'Поруч' c:n(6) e:osn h:'Основание' c:с(20)",,,,'kkl=kklr',,,nkplr)
                   endcase
                   go rcbdocr
                   do case
                      case lastkey()=K_ESC
                           exit
                      case lastkey()=19 // Left
                           fldnomr=fldnomr-1
                           if fldnomr=0
                              fldnomr=1
                           endif
                      case lastkey()=4 // Right
                           fldnomr=fldnomr+1
                   endcase
                enddo
                fldnomr=fldnom_rr
             endif
        case lastkey()=K_F6 // Возврат
             sele tpr2
             if netseek('t1','kklr')
                fldnom_rr=fldnomr
                fldnomr=1
                rcskdocr=recn()
                do case
                   case bsr=361001
                        prforr='.t..and.Sdvm#0'
                   case bsr=361002
                        prforr='.t..and.Sdvt#0'
                   othe
                        rsforr='.t.'
                endcase
                do while .t.
                   go rcskdocr
                   rcskdocr=slce('tpr2',,,,,"e:sk h:'SK' c:n(3) e:nd h:'ND' c:n(6) e:mn h:'MN' c:n(6) e:dpr h:'Дата' c:d(10) e:kop h:'КОП' c:n(3) e:Sdv h:'Сумма' c:n(10,2) e:Sdvm h:'СуммаM' c:n(10,2) e:Sdvt h:'СуммаT' c:n(10,2)",,,,'kps=kklr',prforr,,nkplr)
                   go rcskdocr
                   do case
                      case lastkey()=K_ESC
                           exit
                      case lastkey()=19 // Left
                           fldnomr=fldnomr-1
                           if fldnomr=0
                              fldnomr=1
                           endif
                      case lastkey()=4 // Right
                           fldnomr=fldnomr+1
                   endcase
                enddo
                fldnomr=fldnom_rr
             endif
     endcase
  enddo
  retu .t.

func debflt()
  cldeb=setcolor('w/b,n/w')
  wdeb=wopen(10,20,14,60)
  wbox(1)
  store space(20) to ctextr
  store 0 to kkl_r,kta_r
  store space(9) to msk_r
  do while .t.
     @ 0,1 say 'Контекст   ' get ctextr
     @ 1,1 say 'Клиент     ' get kkl_r pict '9999999'
     @ 2,1 say 'Агент      ' get kta_r pict '9999'
     read
     if lastkey()=K_ESC
        forr=for_r
        sele pdeb
        go top
        rcdebr=recn()
        exit
     endif
     if lastkey()=K_ENTER
        forr=for_r
        if !empty(ctextr)
           ctextr=alltrim(ctextr)
           ctextr=upper(ctextr)
           forr=forr+'.and.at(ctextr,nkl)#0'
        endif
        if !empty(kkl_r)
           forr=forr+'.and.kkl=kkl_r'
        endif
        if !empty(kta_r)
           forr=forr+".and.netseek('t3','kta_r,pdeb->kkl','kplkgp')"
        endif
        sele pdeb
        go top
        rcdebr=recn()
        exit
     endif
  enddo
  wclose(wdeb)
  setcolor(cldeb)
  retu .t.

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  07-08-17 * 11:19:59pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION pDebr_tpr22()
  // Возвраты
  crtt(pDebr+'tpr22','f:sk c:n(3) f:kps c:n(7) f:kzg c:n(7) f:dpr c:d(10) f:Sdv c:n(12,2) f:prz c:n(1) f:reg c:n(4) f:nd c:n(6) f:mn c:n(6) f:kta c:n(4) f:kop c:n(3) f:Sdvm c:n(12,2) f:Sdvt c:n(12,2) f:vo c:n(2)')
  sele 0
  use (pDebr+'tpr22') excl
  sele pr1
  go top
  do while !eof()
    if prz=0
        skip
        loop
    endif
    kopr=kop
    vor=vo
    sele koprp
    locate for d0k1=1.and.vo=vor.and.kop=kopr
    if !foun()
        sele pr1
        skip
        loop
    endif
    sele pr1
    kpsr=kps
    kzgr=kzg
    dprr=dpr
    Sdvr=Sdv
    przr=prz
    ndr=nd
    mnr=mn
    ktar=kta
    Sdvmr=Sdvm
    Sdvtr=Sdvt
    sele tpr22
    appe blank
    repl sk with skr,;
          vo with vor,;
          kop with kopr,;
          kps with kpsr,;
          kzg with kzgr,;
          dpr with dprr,;
          Sdv with Sdvr,;
          prz with przr,;
          nd with ndr,;
          mn with mnr,;
          kta with ktar,;
          Sdvm with Sdvmr,;
          Sdvt with Sdvtr
    sele pr1
    skip
  enddo
  sele tpr22
  use
  sele tpr2
  appe from (pDebr+'tpr22')
  erase (pDebr+'tpr22.dbf')
  sele koprp
  use
  erase koprp.dbf
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  07-08-17 * 11:37:47pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION pDebr_trs22(bFor)
  crtt(pDebr+'trs22','f:sk c:n(3) f:kpl c:n(7) f:kgp c:n(7) f:dop c:d(10) f:Sdv c:n(12,2) f:prz c:n(1) f:reg c:n(4) f:ttn c:n(6) f:kta c:n(4) f:kop c:n(3) f:Sdvm c:n(12,2) f:Sdvm1 c:n(12,2) f:Sdvm2 c:n(12,2) f:Sdvt c:n(12,2) f:vo c:n(2) f:sdp c:n(11,2) f:DtOpl c:d(10)')
  sele 0
  use (pDebr+'trs22') excl
  sele rs1
  go top
  do while !eof()
    if rs1->sdv = 0
        skip;  loop
    endif
    if eval(bFor)
        skip
        loop
    endif
    kopr=kop
    vor=vo
    sele koprp
    locate for d0k1=0.and.vo=vor.and.kop=kopr
    if !foun()
        sele rs1
        skip
        loop
    endif
    sele rs1
    kplr=kpl
    kgpr=kgp
    Dopr=Dop
    Sdvr=Sdv
    przr=prz
    ttnr=ttn
    ktar=kta
    DtOplr=DtOpl
    Sdvmr=Sdvm
    if fieldpos('Sdvm1')#0
        Sdvm1r=Sdvm1
        Sdvm2r=Sdvm2
    else
        Sdvm1r=0
        Sdvm2r=0
    endif
    Sdvtr=Sdvt
    sele trs22
    appe blank
    repl sk with skr,;
          vo with vor,;
          kop with kopr,;
          kpl with kplr,;
          kgp with kgpr,;
          Dop with Dopr,;
          Sdv with Sdvr,;
          prz with przr,;
          ttn with ttnr,;
          kta with ktar,;
          Sdvm with Sdvmr,;
          Sdvm1 with Sdvm1r,;
          Sdvm2 with Sdvm2r,;
          Sdvt with Sdvtr,;
          DtOpl with DtOplr,;
          Sdp with Sdv
    sele rs1
    skip
  enddo
  sele trs22
  use
  sele trs2
  appe from (pDebr+'trs22')
  erase (pDebr+'trs22.dbf')
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  07-10-17 * 01:40:40pm
 НАЗНАЧЕНИЕ......... добавление поля для даты
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Fld_SdvDop(nDopr,stemp)
 local  cSdvr:='Sdv'+padl(alltrim(str(nDopr,2)),3,'0')
 local  cDopr:='Dop'+padl(alltrim(str(nDopr,2)),3,'0')
     //sele (stemp)
     appe blank
     repl field_name with cSdvr,;
          field_type with 'n',;
          field_len with 10,;
          field_dec with 2
     appe blank
     repl field_name with cdopr,;
          field_type with 'd',;
          field_len with 10,;
          field_dec with 0
  RETURN (NIL)
