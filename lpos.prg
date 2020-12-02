//  LPOS()
PRIVATE dtlmr
  netuse('cskl')
  netuse('ctov')
  clea
set prin to lpos.txt
set prin on
  pathr=gcPath_ew+'arnd\'

  dtlmr:=dtos(date())+' '+subs(time(),1,5)

  sele 0
  use (pathr+'localpos') excl
  zap
  inde on localcode tag t1

  sele 0
  use (pathr+'lposarch') excl
  zap
  inde on ol_code+localcode tag t1

  sele 0
  use (pathr+'lpossinh') excl
  zap
  inde on lposin_no tag t1

  sele 0
  use (pathr+'lpossind') excl
  zap
  inde on lposin_no+localcode tag t1

  sele 0
  use (pathr+'lpostrsh') excl
  zap
  inde on lposth_no tag t1

  sele 0
  use (pathr+'lpostrsd') excl
  zap
  inde on lposth_no+localcode tag t1

  lposost()
  lpos2d()
  lpos3d()
  lpospr()
  lpossv()
***********************************
func lposost()
  // Остатки
  ***********************************
  sele cskl
  do while !eof()
     if !(ent=gnEnt.and.arnd=2)
        skip
        loop
     endif
     skr=sk
     pathr=gcPath_d+alltrim(path)
     mess(pathr)
     netuse('tov',,,1)
     do while !eof()
        if osf#1
           skip
           loop
        endif
        ktlr=ktl
        mntovr=mntov
        localcoder=alltrim(str(ktlr,9))

  //        invent_nor=alltrim(znom)
  //        serial_nor=alltrim(zn)
  //        namer=getfield('t1','mntovr','ctov','nat')
        sele ctov
        netseek('t1','mntovr')
        namer=nat
        post_idr:=iif(posid = 0,10000,posid)
        posb_idr:=iif(posbrn = 0,52,posbrn)
        invent_nor=alltrim(znom)
        serial_nor=alltrim(zn)
        sele localpos
        seek localcoder
        if !foun()
           dtlmr:=dtos(date())+' '+subs(time(),1,5)
           netadd()
           netrepl('localcode,invent_no,serial_no,name,dtlm,post_id,posb_id',;
           'localcoder,invent_nor,serial_nor,namer,dtlmr,post_idr,posb_idr')
        endif
        sele tov
        skip
     endd
     nuse('tov')
     sele cskl
     skip
  endd

  sele cskl
  locate for ent=gnEnt.and.arnd=3
  skr=sk
  pathr=gcPath_d+alltrim(path)
  mess(pathr)
  netuse('tov',,,1)
  do while !eof()
     if osf#1
        skip
        loop
     endif
     sklr=skl
     ol_coder=padr(alltrim(str(sklr,7)),25)
     ktlr=ktl
     mntovr=mntov
     optr=opt
     localcoder=padr(alltrim(str(ktlr,9)),20)
     sele ctov
     netseek('t1','mntovr')
     namer=nat
      post_idr:=iif(posid = 0,10000,posid)
      posb_idr:=iif(posbrn = 0,52,posbrn)
     invent_nor=alltrim(znom)
     serial_nor=alltrim(zn)

     sele localpos
     seek localcoder
     if !foun()
        dtlmr:=dtos(date())+' '+subs(time(),1,5)
        date45r=ctod('09.05.1945')
        netadd()
        netrepl('localcode,invent_no,serial_no,name,price,dtlm,post_id,posb_id,date',;
        'localcoder,invent_nor,serial_nor,namer,optr,dtlmr,post_idr,posb_idr,date45r')
     endif

     sele lposarch
     seek ol_coder+localcoder
     if !foun()
        dtlmr:=dtos(date())+' '+subs(time(),1,5)
        netadd()
        netrepl('ol_code,localcode,stockdate,dtlm',;
                'ol_coder,localcoder,date(),dtlmr')
     endif
     sele tov
     skip
  endd
  nuse('tov')
  retu.t.
***********************
func lpos2d()
  // Двухсторонний договор
  ***********************
  prexr=0
  sele cskl
  go top
  do while !eof()
     if !(ent=gnEnt.and.arnd=2)
        skip
        loop
     endif
     skr=sk
     dir_rr=alltrim(path)

     for yyr=year(gdTd) to 2006 step -1
         pathgr=gcPath_e+'g'+str(yyr,4)+'\'
         do case
            case yyr=year(gdTd)
                 mm1r=month(gdTd)
                 mm2r=1
            case yyr=2006
                 mm1r=12
                 mm2r=8
            othe
                 mm1r=12
                 mm2r=1
         endc
         for mmr=mm1r to mm2r step -1
             pathmr=pathgr+'m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'
             pathr=pathmr+dir_rr
             if !netfile('tov',1)
                loop
             endif
             mess(pathr)
             netuse('pr1',,,1)
             netuse('pr2',,,1)
             netuse('tov',,,1)

             sele pr1
             do while !eof()
                if prz=0
                   skip
                   loop
                endif
                if kop#101
                   skip
                   loop
                endif
                kopr=kop
                sklr=skl
                mnr=mn
                dprr=dpr
                if dprr>=ctod('26.12.2012')
                   contr_nor='18005'
                   contr_sdr=ctod('26.12.2012')
                   contr_edr=ctod('31.12.'+str(year(dprr),4))
                else
                   contr_sdr=dnz
                   if !empty(contr_sdr)
                      contr_edr=ctod('31.12.'+str(year(dprr),4))
                   else
                      contr_edr=ctod('')
                   endif
                   contr_nor=nnz
                endif
                sele pr2
                if netseek('t1','mnr')
                   do while mn=mnr
                      ktlr=ktl
                      pricer=zen
                      localcoder=padr(alltrim(str(ktlr,9)),20)
                      sele localpos
                      seek localcoder
                      if foun()
                         if empty(contr_no)
                             repl contr_no with contr_nor,;
                                  contr_sd with contr_sdr,;
                                  contr_ed with contr_edr,;
                                  date with dprr
                         endif
                      else
                         sele tov
                         if netseek('t1','sklr,ktlr')
                            mntovr=mntov
                            sele ctov
                            netseek('t1','mntovr')
                            namer=nat
                            post_idr:=iif(posid = 0,10000,posid)
                            posb_idr:=iif(posbrn = 0,52,posbrn)
                            invent_nor=alltrim(znom)
                            serial_nor=alltrim(zn)
                            sele localpos
                            dtlmr:=dtos(date())+' '+subs(time(),1,5)
                            netadd()
                            netrepl('localcode,invent_no,serial_no,name,dtlm,post_id,posb_id',;
                            'localcoder,invent_nor,serial_nor,namer,dtlmr,post_idr,posb_idr')
                            if kopr=101
                               repl contr_no with contr_nor,;
                                    contr_sd with contr_sdr,;
                                    contr_ed with contr_edr,;
                                    date with dprr
                            endif
                         endif
                      endif
                      sele pr2
                      skip
                   endd
                endif
                sele pr1
                skip
             endd
             nuse('pr1')
             nuse('pr2')
             nuse('tov')
             sele localpos
             loca for empty(contr_no)
             if !foun()
                prexr=1
             endif
             if prexr=1
                exit
             endif
         next
         if prexr=1
            exit
         endif
     next
     if prexr=1
        exit
     endif
     sele cskl
     skip
  endd
  retu .t.

***********************
func lpos3d()
  // Трехсторонний договор
  ***********************
  prexr=0
  sele cskl
  go top
  do while !eof()
     if !(ent=gnEnt.and.arnd=3)
        skip
        loop
     endif
     skr=sk
     dir_rr=alltrim(path)

     for yyr=year(gdTd) to 2006 step -1
         pathgr=gcPath_e+'g'+str(yyr,4)+'\'
         do case
            case yyr=year(gdTd)
                 mm1r=month(gdTd)
                 mm2r=1
            case yyr=2006
                 mm1r=12
                 mm2r=8
            othe
                 mm1r=12
                 mm2r=1
         endc
         for mmr=mm1r to mm2r step -1
             pathmr=pathgr+'m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'
             pathr=pathmr+dir_rr
             if !netfile('tov',1)
                loop
             endif
             mess(pathr)
             netuse('pr1',,,1)
             netuse('pr2',,,1)
  //             netuse('tov',,,1)

             sele pr1
             do while !eof()
                if prz=0
                   skip
                   loop
                endif
                if kop#193
                   skip
                   loop
                endif
                sklr=skl
                mnr=mn
                amnr=amn
                sksr=sks
                sklr=skl
                tsidnumr=padr(alltrim(str(amnr,6))+' '+str(sksr,3)+' 0',50)
                tsidsdatr=dpr
                ol_coder=padr(alltrim(str(sklr,7)),25)
                sele pr2
                if netseek('t1','mnr')
                   do while mn=mnr
                      ktlr=ktl
                      mntovr=mntov
                      pricer=zen
                      localcoder=padr(alltrim(str(ktlr,9)),20)
                      sele lposarch
                      seek ol_coder+localcoder
                      if foun()
                         if empty(tsidnum)
                             repl tsidnum with tsidnumr,;
                                  tsidsdat with tsidsdatr,;
                                  tsidedat with tsidsdatr+255
  //                                  wareh_code with padr(str(sksr,3),20)
                         endif
                      endif
  /*
  *                      sele localpos
  *                      seek localcoder
  *                      if foun()
  *                         repl date with pr1->dpr
  *                      endif
  *                      sele localpos
  *                      seek localcoder
  *                      if !foun()
  *                         sele tov
  *                         if netseek('t1','sklr,ktlr')
  *                            mntovr=mntov
  *                            invent_nor=alltrim(znom)
  *                            serial_nor=alltrim(zn)
  *                            namer=getfield('t1','mntovr','ctov','nat')
  *                            sele localpos
  *                            date45r=ctod('09.05.1945')
  *                            dtlmr:=dtos(date())+' '+subs(time(),1,5)
  *                            netadd()
  *                            netrepl('localcode,invent_no,serial_no,name,dtlm','localcoder,invent_nor,serial_nor,namer,dtlmr')
  *                            repl contr_no with contr_nor,;
  *                                 contr_sd with pr1->dpr,;
  *                                 contr_ed with pr1->dpr+255,;
  *                                 date with date45r
  *                         endif
  *                      endif
  */
                      sele pr2
                      skip
                   endd
                endif
                sele pr1
                skip
             endd
             nuse('pr1')
             nuse('pr2')
 //             nuse('tov')
             sele lposarch
             loca for empty(tsidnum)
             if !foun()
                prexr=1
             endif
             if prexr=1
                exit
             endif
         next
         if prexr=1
            exit
         endif
     next
     if prexr=1
        exit
     endif
     sele cskl
     skip
  endd
  retu .t.
********************************
func lpospr()
* Приходы,расходы
  *********************************
  sele cskl
  go top
  do while !eof()
     if !(ent=gnEnt.and.arnd=2)
        skip
        loop
     endif
     skr=sk
     dir_rr=alltrim(path)

     for yyr=year(gdTd) to 2006 step -1
         pathgr=gcPath_e+'g'+str(yyr,4)+'\'
         do case
            case yyr=year(gdTd)
                 mm1r=month(gdTd)
                 mm2r=1
            case yyr=2006
                 mm1r=12
                 mm2r=8
            othe
                 mm1r=12
                 mm2r=1
         endc
         for mmr=mm1r to mm2r step -1
             pathmr=pathgr+'m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'
             pathr=pathmr+dir_rr
             if !netfile('tov',1)
                loop
             endif

             mess(pathr)
             netuse('pr1',,,1)
             netuse('pr2',,,1)
             netuse('rs1',,,1)
             netuse('rs2',,,1)
             netuse('tov',,,1)

             sele pr1 // 101,188,183
             do while !eof()
                if prz=0
                   skip
                   loop
                endif
                if !(kop=101.or.kop=188.or.kop=183)
                   skip
                   loop
                endif
                ktar=kta
                sklr=skl
                kopr=kop
                mnr=mn
                sklsr=skls
                dprr=dpr
                lposin_nor=padr(alltrim(str(mnr,6))+' '+str(skr,3)+' 1',50)
                lposth_nor=lposin_nor
                if kopr=101
                   if dprr>=ctod('26.12.2012')
                      contr_nor='18005'
                      contr_sdr=ctod('26.12.2012')
                      contr_edr=ctod('31.12.'+str(year(dprr),4))
                   else
                      contr_sdr=dnz
                      if !empty(contr_sdr)
                         contr_edr=ctod('31.12.'+str(year(dprr),4))
                      else
                         contr_edr=ctod('')
                      endif
                      contr_nor=nnz
                   endif
                else
  //                   lposin_nor=''
  //                   lposth_nor=''
                   contr_nor=''
                   contr_sdr=ctod('')
                   contr_edr=ctod('')
                endif
                ol_coder=padr(alltrim(str(sklsr,7)),25)
                wareh_coder=padr(str(skr,3),20)
  //                contr_nor=padr(alltrim(str(mnr,6)+' '+str(skr,3)+' 1'),50)
                if kopr=101.or.kopr=188
                   sele lpossinh
                   seek lposin_nor
                   if !foun()
                      dtlmr:=dtos(date())+' '+subs(time(),1,5)
                      netadd()
                      netrepl('lposin_no,date,totalsum,wareh_code,dtlm,status',;
                      {lposin_nor,pr1->dpr,pr1->sdv,wareh_coder,dtlmr,2})
                      do case
                         case kopr=101
                              doc_typer=11
                         case kopr=188
                              doc_typer=15
                      endc
                      netrepl('doc_type',{doc_typer})
                   endif
                endif
                if kopr=183
                   sele lpostrsh
                   seek lposth_nor
                   if !foun()
                      netadd()
                      doc_typer=17
                      dtlmr:=dtos(date())+' '+subs(time(),1,5)
                      netrepl('lposth_no,date,totalsum,doc_type,ol_code,wareh_code,dtlm,status,merch_id',;
                              {lposth_nor,pr1->dpr,pr1->sdv,doc_typer,ol_coder,wareh_coder,dtlmr,2,ktar})
                      If !empty(FieldPos('MERCH_CODE'))
                        netrepl('MERCH_CODE',{allt(str(pr1->Kta))})
                      EndIf

                   endif
                endif
                sele pr2
                if netseek('t1','mnr')
                   do while mn=mnr
                      mntovr=mntov
                      ktlr=ktl
                      pricer=zen
                      localcoder=padr(alltrim(str(ktlr,9)),20)
                      if kopr=101
                         sele localpos
                         seek localcoder
                         if !foun()
  //                            ?str(yyr,4)+' '+str(mmr,2)+' '+str(skr,3)+' p '+str(mnr,6)+' '+str(ktlr,9)
                            sele tov
                            if netseek('t1','sklr,ktlr')
                               mntovr=mntov
                               sele ctov
                               netseek('t1','mntovr')
                               namer=nat
                                post_idr:=iif(posid = 0,10000,posid)
                                posb_idr:=iif(posbrn = 0,52,posbrn)
                               invent_nor=alltrim(znom)
                               serial_nor=alltrim(zn)
                               sele localpos
                               dtlmr:=dtos(date())+' '+subs(time(),1,5)
                               netadd()
                               netrepl('localcode,invent_no,serial_no,name,dtlm,post_id,posb_id',;
                               'localcoder,invent_nor,serial_nor,namer,dtlmr,post_idr,posb_idr')
                               if kopr=101
                                  repl contr_no with contr_nor,;
                                       contr_sd with contr_sdr,;
                                       contr_ed with contr_edr,;
                                       date with dprr
                               endif
                            endif
                         endif
                      endif
                      if kopr=101.or.kopr=188
                         sele lpossind
                         seek lposin_nor+localcoder
                         if !foun()
                            netadd()
                            netrepl('lposin_no,localcode,price',;
                            {lposin_nor,localcoder,pricer})
                         endif
                      endif
                      if kopr=183
                         sele lpostrsd
                         seek lposth_nor+localcoder
                         if !foun()
                            netadd()
                            netrepl('lposth_no,localcode,price',;
                            {lposth_nor,localcoder,pricer})
                         endif
                      endif
                      sele pr2
                      skip
                   endd
                endif
                sele pr1
                skip
             endd

             sele rs1
             do while !eof()
                if !(kop=154.or.kop=188.or.kop=193)
                   skip
                   loop
                endif
                if prz=0
                   skip
                   loop
                endif
                kopr=kop
                skltr=sklt
                sklr=skl
                ttnr=ttn
                sklr=skl
                lposin_nor=padr(alltrim(str(ttnr,6))+' '+str(skr,3)+' 0',50)
                lposth_nor=lposin_nor
                ol_coder=padr(alltrim(str(skltr,7)),25)
                wareh_coder=padr(str(skr,3),20)
                if kopr=154.or.kopr=188
                   sele lpossinh
                   seek lposin_nor
                   if !foun()
                      netadd()
                      do case
                         case kopr=154
                              doc_typer=12
                         case kopr=188
                              doc_typer=14
                      endc
                      dtlmr:=dtos(date())+' '+subs(time(),1,5)
                      netrepl('lposin_no,date,totalsum,doc_type,dtlm,status',;
                              {lposin_nor,rs1->dot,rs1->sdv,doc_typer,dtlmr,2})
                      netrepl('wareh_code',{wareh_coder})
                   endif
                endif
                if kopr=193
                   sele lpostrsh
                   seek lposth_nor
                   if !foun()
                      netadd()
                      doc_typer=16
                      dtlmr:=dtos(date())+' '+subs(time(),1,5)
                      netrepl('lposth_no,date,totalsum,doc_type,ol_code,dtlm,status,merch_id',;
                      {lposth_nor,rs1->dot,rs1->sdv,doc_typer,ol_coder,dtlmr,2,ktar})
                      netrepl('wareh_code',{wareh_coder})
                      If !empty(FieldPos('MERCH_CODE'))
                        netrepl('MERCH_CODE',{allt(str(rs1->Kta))})
                      EndIf
                   endif
                endif
                sele rs2
                if netseek('t1','ttnr')
                   do while ttn=ttnr
                      mntovr=mntov
                      ktlr=ktl
                      pricer=zen
                      localcoder=padr(alltrim(str(ktlr,9)),20)
                      sele localpos
                      seek localcoder
                      if !foun()
  /*
  *                         ?str(yyr,4)+' '+str(mmr,2)+' '+str(skr,3)+' r '+str(ttnr,6)+' '+str(ktlr,9)
  *                         sele tov
  *                         if netseek('t1','sklr,ktlr')
  *                            mntovr=mntov
  *                            invent_nor=alltrim(znom)
  *                            serial_nor=alltrim(zn)
  *                            namer=getfield('t1','mntovr','ctov','nat')
  *                            sele localpos
  *                            dtlmr:=dtos(date())+' '+subs(time(),1,5)
  *                            date45r=ctod('09.05.1945')
  *                            netadd()
  *                            netrepl('localcode,invent_no,serial_no,name,dtlm','localcoder,invent_nor,serial_nor,namer,dtlmr')
  *                            repl contr_no with contr_nor,;
  *                                 contr_sd with pr1->dpr,;
  *                                 contr_ed with pr1->dpr+255,;
  *                                 date with date45r
  *                         endif
  */
                      endif
                      if kopr=193
                         sele lpostrsd
                         seek lposth_nor+localcoder
                         if !foun()
                            netadd()
                            netrepl('lposth_no,localcode,price,tscon_no,tsconsd,tsconed',;
                            {lposth_nor,localcoder,pricer,lposth_nor,rs1->dot,rs1->dot+255})
                            If !empty(FieldPos('MERCH_CODE'))
                              netrepl('MERCH_CODE',{allt(str(rs1->Kta))})
                            EndIf
                         endif
                      endif
                      if kopr=154.or.kopr=188
                         sele lpossind
                         seek lposin_nor+localcoder
                         if !foun()
                            netadd()
                            //netrepl('lposin_no,localcode,price,wareh_code','lposin_nor,localcoder,pricer,wareh_coder')
                            netrepl('lposin_no,localcode,price','lposin_nor,localcoder,pricer')
                         endif
                      endif
                      sele rs2
                      skip
                   endd
                endif
                sele rs1
                skip
             endd

             nuse('pr1')
             nuse('pr2')
             nuse('rs1')
             nuse('rs2')
             nuse('tov')
         next
     next
     sele cskl
     skip
  endd
  retu .t.
*******************************
func lpossv()
// Приход-Расход связь
  *******************************
  mess('Связи')
  sele lpostrsd
  kolar=recc()
  coun to koler for empty(tscon_no)
  kolir=0
  if gnArm#0
     @ 0,1 say kolar
     @ 1,1 say koler
  endif
  go top
  do while !eof()
     if !empty(tscon_no)
        skip
        loop
     endif
     lposth_nor=lposth_no // Номер возврата
     localcoder=localcode
     rcr=recn()
     sele lpostrsh
     seek lposth_nor
     if foun()
        if doc_type=17 // Действительно возврат
           ol_coder=ol_code
             // Поиск tmesto c этим оборудованием
           sele lpostrsh
           go top
           do while !eof()
              if doc_type#16
                 skip
                 loop
              endif
              if ol_code#ol_coder
                 skip
                 loop
              endif
              lposth_nor=lposth_no // Договор
              sele lpostrsd
              seek lposth_nor+localcoder
              if foun()
                 tscon_nor=lposth_no
                 sele lpostrsh
                 seek tscon_nor
                 if foun()
                    tsconsdr=date
                    tsconedr=date+255
                    sele lpostrsd
                    go rcr
                    netrepl('tscon_no,tsconsd,tsconed',;
                    {tscon_nor,tsconsdr,tsconedr})
                    if gnArm#0
                       kolir=kolir+1
                       @ 2,1 say kolir
                    endif
                    exit
                 endif
              endif
              sele lpostrsh
              skip
           endd
        endif
     endif
     sele lpostrsd
     go rcr
     skip
  endd
  retu .t.

  sele localpos
  use
  sele lposarch
  use
  sele lpossind
  use
  sele lpossinh
  use
  sele lpostrsd
  use
  sele lpostrsh
  use
  nuse()
set prin to
set prin off
