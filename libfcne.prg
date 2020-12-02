#include "common.ch"
#define LF CHR(10)
#define CR CHR(13)
********************
func dcpere(p1,p2)
  ********************
  // p1 - d0k1
  // p2 - (ttn,mn)
  ********************
  d0k1_r=p1
  doc_r=p2

  store 0 to d0k1r,kopr,qr,ndsr,pndsr,xndsr,grtcenr,tcenr,ptcenr,xtcenr,nofr,;
             skar,sklar,msklar,zcr,prnnr,ttor,vpr,autor,okklr,okplr,pbzenr,;
             pxzenr,rtcenr,s361r,kpsbbr
  store '' to cuchr,cotpr,cdopr
  vur=1
  vor=0
  store space(40) to NOPr
  store '' to nvur,nvor,nopr,nndsr,npndsr,ntcenr,nptcenr,nsklar,;
              nokklr,nrtcenr,nttor,nnzr
  store '' to coptr,cboptr,croptr
  store 0 to optr,boptr,roptr,przr
  nnzr:='Чек  '

  skr=gnSk

  if d0k1_r=1.and.select('pr1')#0
     mnr=doc_r
     if netseek('t2','mnr')
        if !reclock(1)
           ?str(mnr,6)+' '+'Занят'
           return .t.
        endif
        sec1r=seconds()
        sdv1r=sdv
        sklr=skl
        dvpr=dvp
        kpsr=kps
        ndr=nd
        vor=vo
        kopr=kop
        pstr=pst
        ptr=pt
        przr=prz
        rmskr=rmsk
        ktar=kta
        ktasr=ktas
        dtmodr=dtmod
        tmmodr=tmmod
        if ktasr=0
           if ktar#0
              ktasr=getfield('t1','ktar','s_tag','ktas')
              netrepl('ktas','ktasr',1)
           endif
        endif
        SkVzr=SkVz
        TtnVzr=TtnVz
        dtvzr=dtvz
        if TtnVzr#0.and.!empty(dtvzr)
           ChkOptVz()
        endif
        sele pr2
        if netseek('t1','mnr')
           do while mn=mnr
              ktlr=ktl
              kfr=kf
              zenr=zen
              optr=getfield('t1','sklr,ktlr','tov','opt')
              if round(zenr-optr,0)#0
                 if vor=9
                    sele tov
                    if netseek('t1','sklr,ktlr')
                       ?str(mnr,6)+' '+str(prz_rr,1)+' tov '+str(ktlr,9)+' '+str(opt,10,3)+' -> '+str(zenr,10,3)
                       netrepl('opt','zenr')
                    endif
                 else
                    sele pr2
                    ?str(mnr,6)+' '+str(prz_rr,1)+' pr2 '+str(ktlr,9)+' '+str(zenr,10,3)+' -> '+str(optr,10,3)
                    netrepl('zen','optr')
                 endif
              endif
              sele pr2
              sfr=sf
              sf_r:=round(kfr*optr,2)
              if round(sfr-sf_r,0)#0
                 sele pr2
                 netrepl('sf','sf_r')
              endif
              sele pr2
              skip
           enddo
        endif
        store '' to coptr,cboptr,cuchr,cotpr,cdopr,s361r
        store 0 to onofr,opbzenr,opxzenr,;
                   otcenpr,otcenbr,otcenxr,;
                   odecpr,odecbr,odecxr
        if !inikop(gnD0k1,1,vor,kopr)
           ?str(mnr,6)+' '+str(kopr,3)+' Ош. inikop'
           return .t.
        endif
        sele soper
        nofr=nof
        tbl1r='pr1'
        tbl2r='pr2'
        tbl3r='pr3'
        mdocr='mnr'
        fdocr='mn'
        if kopr#110
           fkolr='kf'
        else
           if gnEnt=20.or.gnEnt=21
              fkolr='kfttn'
           else
              fkolr='kf'
           endif
        endif
        fprr='prp'
        ssf12r=getfield('t1','mnr,12','pr3','ssf')
        if ssf12r#0
           tarar=0
        else
           tarar=1
        endif
        ptr=tarar
        sele pr1
        netrepl('pt','ptr',1)
        ksz90r=getfield('t1','mnr,90','pr3','ssf')
        set cons off
        pere(2)
        set cons on
        ksz90_r=getfield('t1','mnr,90','pr3','ssf')
        ?str(mnr,6)+' '+str(kopr,3)+' '+str(rmskr,1)+' '+str(prz_rr,1)
        set cons off
        if pr1->prz = 1 //подтвержден
           prprv(1)
        else
           prprv(2)
        endif
        set cons on
        sele pr1
        if round(sdv1r,2)#round(sdv,2)
           ??str(sdv1r,12,2)+' '+str(sdv,12,2)
        endif
     endif
     sec2r=seconds()
     ??str((sec2r-sec1r),10,3)
  endif

  if d0k1_r=0.and.select('rs1')#0
     ttnr=doc_r
     sele rs1
     if netseek('t1','ttnr')
        if !reclock(1)
           ?str(ttnr,6)+' '+'Занят'
           return .t.
        endif
        sec1r=seconds()
        prz_rr=prz
        prz_r=prz
        sklr=skl
        ttnr=ttn
        dvpr=dvp
        dopr=dop
        vor=vo
        kopr=kop
        pstr=pst
        ptr=pt
        prcorr=1
        kplr=kpl
        kpsbbr=getfield('t1','kplr','kps','prbb')
        nkklr=nkkl
        kgpr=kgp
        ktar=kta
        ktasr=ktas
        tmestor=tmesto
        dtmodr=dtmod
        tmmodr=tmmod
        if ktasr=0
           if ktar#0
              ktasr=getfield('t1','ktar','s_tag','ktas')
              netrepl('ktas','ktasr',1)
           endif
        endif
        sdv1r=sdv
        rmskr=rmsk
        sele rs2
        if netseek('t1','ttnr')
           s96r=0
           do while ttn=ttnr
              ktlr=ktl
              kvpr=kvp
              zenr=zen
              svpr=svp
              svp_r=round(kvpr*zenr,2)
              optr=round(sr/kvpr,3)
              opt_r=getfield('t1','sklr,ktlr','tov','opt')
              srr=sr
              sr_r=round(kvpr*opt_r,2)
              if round(srr-sr_r,2)#0
                 ?str(ttnr,6)+' '+str(prz_rr,1)+' '+str(ktlr,9)+" srr#sr_r ", ALLTRIM(STR(srr)),ALLTRIM(STR(sr_r))
                 sele rs2
                 netrepl('sr','sr_r')
              endif
              if int(ktlr/1000000)>1
                 s96r=s96r+sr
              endif
              if round(svpr-svp_r,2)#0
                 ?str(ttnr,6)+' '+str(prz_rr,1)+' '+str(ktlr,9)+" svpr#svp",  ALLTRIM(STR(svpr)),ALLTRIM(STR(svp_r))
                 sele rs2
                 netrepl('svp','svp_r')
                 if prz_r=1
                    netrepl('sf','svp_r')
                 endif
              endif
              if prz_r=1
                 netrepl('sf','svp_r')
              endif
              sele rs2
              skip
           enddo
           s96_r=getfield('t1','ttnr,96','rs3','ssf')
           if round(s96r-s96_r,2)#0
              ?str(ttnr,6)+' '+str(prz_rr,1)+" s96r#s96_r",  ALLTRIM(STR(s96r)),ALLTRIM(STR(s96_r))
           endif
        endif
        store '' to coptr,cboptr,cuchr,cotpr,cdopr,s361r
        store 0 to onofr,opbzenr,opxzenr,;
                   otcenpr,otcenbr,otcenxr,;
                   odecpr,odecbr,odecxr
        if !inikop(gnD0k1,1,vor,kopr)
           ?str(ttnr,6)+' '+str(kopr,3)+' Ош.inikop'
        else
           tbl1r='rs1'
           tbl2r='rs2'
           tbl3r='rs3'
           mdocr='ttnr'
           fdocr='ttn'
           fkolr='kvp'
           fprr='pr'
           ssf12r=getfield('t1','ttnr,12','rs3','ssf')
           if ssf12r#0
              tarar=0
           else
              tarar=1
           endif
           ptr=tarar
           sele rs1
           netrepl('pt','ptr',1)
           ksz90r=getfield('t1','ttnr,90','rs3','ssf')
           set cons off
           pere(2)
           set cons on
           ksz90_r=getfield('t1','ttnr,90','rs3','ssf')
           sele rs2
           set orde to tag t1
           if netseek('t1','ttnr')
              s92r=0
              if FOUND()
                 do while ttn=ttnr
                    s92r=s92r+seu
                    skip
                 enddo
              endif
              sele rs3
              if netseek('t1','ttnr,92')
                 if s92r#0
                    netrepl('ssf,ssz','s92r,s92r')
                    if pbzenr=1
                       netrepl('bssf','s92r')
                    endif
                 else
                    netdel()
                 endif
              else
                 if s92r#0
                    netadd()
                    netrepl('ttn,ksz,ssz,ssf','ttnr,92,s92r,s92r')
                    if pbzenr=1
                       netrepl('bssf','s92r')
                    endif
                 endif
              endif
           endif
           ?str(ttnr,6)+' '+str(kopr,3)+' '+str(rmskr,1)+' '+str(prz_rr,1)
           sele rs1
           if round(sdv1r,2)#round(sdv,2)
              ??str(sdv1r,12,2)+' '+str(sdv,12,2)
           endif
           set cons off
           if rs1->prz=1 // Подтвержденный
              sele dokko
              if netseek('t12','0,0,skr,ttnr,0') // Был отгружен
                 rsprv(2,1) // Снять отгрузку
              endif
              sele dokk
              rsprv(1,0) // Подтвердить
           else // Неподтвержденный
              sele dokk
              if netseek('t12','0,0,skr,ttnr,0') // Был подтвержден
                 rsprv(2,0) // Снять подтверждение
              endif
              if !empty(dopr)
                 rsprv(1,1) // Отгрузить
              else
                 rsprv(2,1) // Снять отгрузку
              endif
           endif
           set cons on
        endif
        sele rs1
        sec2r=seconds()
        ??str((sec2r-sec1r),10,3)
        netunlock()
     endif
  endif
***********************
func rzdprv()
  // Разделение проводки
  ***********************
  bs_s_r=bs_sr
  clzvr=setcolor('gr+/b,n/bg')
  wzvr=wopen(8,20,14,70)
  wbox(1)
  do while .t.
     kta_r=ktar
     ktas_r=ktasr
     nap_r=nap
     @ 1,1 say 'Агент      '+' '+str(kta_r,4)+' '+getfield('t1','kta_r','s_tag','fio')
     @ 2,1 say 'Супервайзер'+' '+str(ktas_r,4)+' '+getfield('t1','ktas_r','s_tag','fio')
     @ 3,1 say 'Направление'+' '+str(nap_r,4)+' '+getfield('t1','nap_r','nap','nnap')
     @ 0,1 say 'Сумма' get bs_sr pict '999999999.99' range 0,bs_s_r
     read
     if lastkey()=27
        exit
     endif
     @ 1,1 say 'Агент      ' get kta_r    pict '9999' valid chkas(kta_r)
     read
     if lastkey()=27
        exit
     endif
     @ 1,1 say 'Агент      '+' '+str(kta_r,4)+' '+getfield('t1','kta_r','s_tag','fio')
     ktas_r=getfield('t1','kta_r','s_tag','ktas')
     nap_r=getfield('t1','kta_r','ktanap','nap')
     if nap_r=0
        nap_r=getfield('t1','ktas_r','ktanap','nap')
     endif
     @ 2,1 say 'Супервайзер'+' '+str(ktas_r,4)+' '+getfield('t1','ktas_r','s_tag','fio')
     @ 3,1 say 'Направление'+' '+str(nap_r,4)+' '+getfield('t1','nap_r','nap','nnap')
     if kta_r=0
        @ 2,1 say 'Супервайзер' get ktas_r   pict '9999' valid chkas(ktas_r)
        read
        if lastkey()=27
           exit
        endif
        if nap_r=0
           nap_r=getfield('t1','ktas_r','ktanap','nap')
        endif
     endif
     @ 2,1 say 'Супервайзер'+' '+str(ktas_r,4)+' '+getfield('t1','ktas_r','s_tag','fio')
     @ 3,1 say 'Направление'+' '+str(nap_r,4)+' '+getfield('t1','nap_r','nap','nnap')
     if nap_r=0
        @ 3,1 say 'Направление' get nap_r    pict '9999'
        read
        if lastkey()=27
           exit
        endif
        if !netseek('t1','nap_r','nap')
           nap_r=0
        endif
     endif
     @ 3,1 say 'Направление'+' '+str(nap_r,4)+' '+getfield('t1','nap_r','nap','nnap')
     @ 4,1 say 'ENTER - запись; ESC - отмена'
     inkey(0)
     if lastkey()=13
        if rnparr=0
           if bs_sr=0.or.bs_sr=bs_s_r
              sele dokk
              netrepl('kta,ktas,nap','kta_r,ktas_r,nap_r')
              docmod('корр')
              mdall('корр')
           else
              sele dokk
              arec:={}
              getrec()
              rn_r=rn
              do while mn=mnr.and.rnd=rndr
                 rn_r=rn
                 skip
              enddo
              rn_r=rn_r+1
              go rcdokkr
              netrepl('bs_s','bs_s-bs_sr')
              docmod('корр')
              mdall('корр')
              netadd()
              putrec()
              netrepl('kta,ktas,nap,rn,bs_s,rnpar',;
                      'kta_r,ktas_r,nap_r,rn_r,bs_sr,rnr')
              docmod('доб')
              mdall('доб')
           endif
        else
           if bs_sr=0 // Удалить
              if netseek('t1','mnr,rndr,kklr,rnparr')
                 rcparr=recn()
                 netrepl('bs_s','bs_s+bs_s_r')
                 docmod('корр')
                 mdall('корр')
                 go rcdokkr
                 docmod('уд')
                 mdall('уд')
                 netdel()
                 rcdokkr=rcparr
              endif
           else       // Коррекция
              if netseek('t1','mnr,rndr,kklr,rnparr')
                 rcparr=recn()
                 netrepl('bs_s','bs_s+bs_s_r-bs_sr')
                 docmod('корр')
                 mdall('корр')
                 go rcdokkr
                 netrepl('kta,ktas,nap,bs_s','kta_r,ktas_r,nap_r,bs_sr')
                 docmod('корр')
                 mdall('корр')
              endif
           endif
        endif
        exit
     endif
  enddo
  wclose(wzvr)
  setcolor(clzvr)
  return .t.

*****************
func pkpltara(p1)
  *****************
  if gnEnt#21
     return .t.
  endif
  if ttnr#238550
     return .t.
  endif
  kpl_r=p1
  sele cskl
  locate for ent=gnEnt.and.tpstpok=2
  if foun()
     sktarar=sk
     pathr=gcPath_d+alltrim(path)
     netuse('tovm','tovmpok',,1)
     set orde to tag t2
     if select('kpltara')#0
        sele kpltara
        use
     endif
     erase kpltara.dbf
     crtt('kpltara','f:kpl c:n(7) f:mntov c:n(7) f:nat c:c(40) f:nei c:c(5) f:osf c:n(10)')
     sele 0
     use kpltara
     inde on str(kpl,7)+str(mntov,7) tag t1
     sele tovmpok
     if netseek('t2','kpl_r')
        do while skl=kpl_r
           if kg#0
              skip
              loop
            endif
            mntovr=mntov
            mntovtr=mntovt
            if mntovtr=0
               mntovtr=getfield('t1','mntovr','ctov','mntovt')
            endif
            if mntovtr=0
               mntovr=mntovtr
            endif
            natr=nat
            neir=nei
            osfr=osf
            sele kpltara
            locate for kpl=kplr.and.mntov=mntovr
            if !foun()
               netadd()
               netrepl('kpl,mntov,nat,nei,osf',;
                       'kplr,mntovr,natr,neir,osfr')
            else
               netrepl('osf','osf+osfr')
            endif
            sele tovmpok
            skip
        enddo
        nuse('tovmpok')
     endif
  endif
  rlistr=42
  rlist_r=0
  sele cmrsh
  if netseek('t2','mrshr')
     dfior=dfio
     kecsr=kecs
     anomr=anom
  else
     dfior=''
     kecsr=0
     anomr=''
  endif
  for itrr=1 to 2
      sele kpltara
      go top
      ?space(30)+'НАКЛАДНА N_______________'+'('+str(mrshr,6)+')'+'('+str(ttnr,6)+')'
      rlist_r=rlist_r+1
      ?space(20)+'вiд '+'"'+'______'+'"'+'______________________________200  р.'
      rlist_r=rlist_r+1
      ?'Вiд кого: '+str(kpl_r,7)+' '+getfield('t1','kpl_r','kln','nkl')+' '+str(kgpr,7)+' '+getfield('t1','kgpr','kln','nkl')
      rlist_r=rlist_r+1
      ?'Мiсце   : '+str(kgpr,7)+' '+getfield('t1','kgpr','kln','nkl')
      rlist_r=rlist_r+1
      ?'Кому    : '+getfield('t1','gnKkl_c','kln','nkl')
      rlist_r=rlist_r+1
      ?'Через   : '+'Номер '+anomr+' '+'Водитель'+' '+dfior+' '+'експедитор '+getfield('t1','kecsr','s_tag','fio')
      rlist_r=rlist_r+1
      ?'Пiдстава: Договiр'
      rlist_r=rlist_r+1
      ?'┌───────┬─────────────────────────────────────┬─────┬──────────┬──────────┬─────────┬─────────┐'
      rlist_r=rlist_r+1
      ?'│ Код   │           Назва                     │Вимiр│  Борг    │  Цiна    │Повернуто│  Сума   │'
      rlist_r=rlist_r+1
      ?'├───────┼─────────────────────────────────────┼─────┼──────────┼──────────┼─────────┼─────────┤'
      rlist_r=rlist_r+1
      sele kpltara
      go top
      do while !eof()
         mntovr=mntov
         natr=nat
         neir=nei
         osfr=osf
         ?'│'+str(mntovr,7)+'│'+subs(natr,1,37)+'│'+neir+'│'+str(osfr,10)+'│'+str(optr,10,3)+'│'+space(9)+'│'+space(9)+'│'
         rlist_r=rlist_r+1
         sele kpltara
         skip
      enddo
      ?'└───────┴─────────────────────────────────────┴─────┴──────────┴──────────┴─────────┴─────────┘'
      rlist_r=rlist_r+1
      ?''
      rlist_r=rlist_r+1
      ?'Сума до сплати____________________________________________________________________________'
      rlist_r=rlist_r+1
      ?'Керiвник________________________________________________Вiдпустив_________________________'
      rlist_r=rlist_r+1
      ?'Головний бухгалтер__________________'
      rlist_r=rlist_r+1
      if itrr=1
         kspcr=rlistr-rlist_r*2
         if kspcr>0
            for itt=1 to kspcr
                ?''
            endf
         endif
      endif
  next
  eject
  return .t.
*********************
func rzdt(p1,p2,p3)
  // p1 Дата
  // p2 1 - 8
  // p3 формат
  *********************
  local a,b
  a='│'
  b=dtos(p1)
  a=a+subs(b,7,1)+'│'+subs(b,8,1)+'│'+subs(b,5,1)+'│'+subs(b,6,1)+'│'
  if !empty(p2)
     a=a+subs(b,3,1)+'│'+subs(b,4,1)+'│'
  else
     a=a+subs(b,1,1)+'│'+subs(b,2,1)+'│'+subs(b,3,1)+'│'+subs(b,4,1)+'│'
  endif
  return a

*********************
func rznum(p1,p2)
  // p1 число
  // p2 к-во
  *********************
  local a,b,i
  a='│'
  if !empty(p2)
     b=padl(alltrim(str(p1,20)),p2)
  else
     b=alltrim(str(p1,20))
  endif
  for i=1 to len(b)
      if p1#0
         a=a+subs(b,i,1)+'│'
      else
         a=a+' │'
      endif
  next
  return a

*********************
func rzchr(p1,p2,p3,p4)
  // p1 строка
  // p2 к-во
  // p3 0 - L;1 - C; 2 - R
  // p4 без разделителя
  *********************
  local a,b,i
  a='│'
  if !empty(p2)
     do case
        case p3=0
             b=padl(p1,p2)
        case p3=1
             b=padc(p1,p2)
        case p3=2
             b=padr(p1,p2)
     endc
  else
     b=p1
  endif
  for i=1 to len(b)
      if i#len(b)
         if empty(p4)
            a=a+subs(b,i,1)+'│'
         else
            a=a+subs(b,i,1)+' '
         endif
      else
         a=a+subs(b,i,1)+'│'
      endif
  next
  return a

*************************
func acc361(p1,p2,p3, l_nuse)
  // p1 dt1
  // p2 dt2
  // p3 имя выходного файла
  *************************
  default lnuse to .t.
     netuse('cskl')
     netuse('rmsk')
     netuse('kln')
     netuse('knasp')
     netuse('opfh')
     netuse('s_tag')
     netuse('nap')
     netuse('ktanap')

     netuse('etm')

    copy file (gcPath_a+'acc361.dbf') to (p3+'.dbf')
    sele 0
    use (p3) alias acc361 excl
    inde on str(sk,3)+str(rn,6) tag t1
    use
    sele 0
    use (p3) alias acc361 share
    set index to (p3)
    for yyr=year(p1) to year(p2)
        do case
           case year(p1)=year(p2)
                mm1r=month(p1)
                mm2r=month(p2)
           case yyr=year(p1)
                mm1r=month(p1)
                mm2r=12
           case yyr=year(p2)
                mm1r=1
                mm2r=month(p2)
           othe
                mm1r=1
                mm2r=12
        endc
        for mmr=mm1r to mm2r
            pathgr=gcPath_e+'g'+str(yyr,4)+'\'
            pathmr=pathgr+'m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'
            pathr=pathmr+'bank\'
            if !netfile('dokk',1)
               loop
            endif

            netuse('dokk',,,1)
            set orde to tag t10 // kkl,bs_d
            if netseek('t10','20034,361001')
               do while kkl=20034.and.bs_d=361001
                  if mn#0
                     skip
                     loop
                  endif
                  if kop#169
                     skip
                     loop
                  endif
                  skr=sk
                  rnr=rn
                  ddkr=ddk
                  bs_sr=bs_s // для sdv
                  kopr=kop
                  kplr=kkl
                  napr=nap
                  dopr=dop
                  nkklr=nkkl
                  ktar=kta
                  ktasr=ktas

                  sele acc361
                  seek str(skr,3)+str(rnr,6)
                  if !foun()
                     appe blank
                     repl sk with skr,rn with rnr,ddk with ddkr,;
                          kop with kopr,kpl with kplr,nap with napr,;
                          dop with dopr,nkkl with nkklr,kta with ktar,;
                          ktas with ktasr

                    path_dr:=pathmr
                    pathr=path_dr+ALLTRIM(getfield("t1","dokk->sk","cskl","path"))
                    netuse('rs1','','',1)
                    IF netseek("t1","dokk->rn")
                      sele acc361
                      _FIELD->bs_tp:="KA"
                      _FIELD->nplp:=888169
                      //_FIELD->DtOpl_tp:=
                      _FIELD->DtOpl_ttn:=dokk->ddk
                      _FIELD->DtOpl_raz:=0
                      //'f:mn  c:n(6) f:rnd c:n(6) f:sk  c:n(3) f:rn  c:n(6) f:mnp c:n(6) '+;
                      _FIELD->prz:=1

                      //
                      rmskr:=gnEnt*10+rs1->rmsk
                      IF rs1->rmsk = 0 // основное предприятие
                        setup->(__dbLocate({|| setup->Ent = gnEnt }))
                        nrmskr:=setup->uss
                      ELSE
                        rmsk->(__dbLocate({|| rmsk->rmsk = rs1->rmsk }))
                        nrmskr:=rmsk->nrmsk
                      ENDIF
                      _FIELD->dep:=rmskr
                      _FIELD->ndep:=nrmskr
                      //_FIELD->nkkl
                      _FIELD->ttn := rn
                      //_FIELD->dop
                      //_FIELD->sdv

                      //
                      kln->(netseek('t1','dokk->nKkl'))
                      //_FIELD->kpl
                      _FIELD->npl:=str(dokk->nKkl)+" "+ATREPL('"',ALLTRIM(kln->nkl),"'")
                      //
                      kln->(netseek('t1','rs1->kgp'))
                      _FIELD->kgp:=rs1->kgp
                      _FIELD->ngp:=ATREPL('"',ALLTRIM(kln->nkl),"'")
                      //
                      //_FIELD->ktan
                      //_FIELD->nktan

                      //
                      s_tag->(netseek('t1','rs1->kta'))
                      //_FIELD->kta
                      _FIELD->nkta:=ALLTRIM(s_tag->fio)

                      //
                      s_tag->(netseek('t1','rs1->ktas'))
                      //_FIELD->ktas
                      _FIELD->nktas:=ALLTRIM(s_tag->fio)

                      //
                      ktanap->(netseek('t1','rs1->ktas')) //ktanap->nap
                      nap->(netseek('t1','ktanap->nap')) //nap->nnap
                      //_FIELD->nap
                      _FIELD->nnap:=ALLTRIM(nap->nnap)
                      //
                      //_FIELD->kop
                      //_FIELD->sdp
                      _FIELD->DtOpl:=rs1->DtOpl //ddk
                      nuse("rs1")

                    endif
                  endif
                  sele acc361
                  reclock()
                  repl sdv with sdv+bs_sr
                  _FIELD->Bs_s:=sdv
                  _FIELD->splp:=sdv
                  netunlock()
                  sele dokk
                  skip
               enddo
            endif
            nuse('dokk')
        next
    next
    sele acc361
    use
  If l_nuse
     nuse('cskl')
     nuse('rmsk')
     nuse('kln')
     nuse('knasp')
     nuse('opfh')
     nuse('s_tag')
     nuse('nap')
     nuse('ktanap')
  EndIf

    return .t.
**************
func nnds(p1)
  **************
  if alias()=='DOKK'.and.!(dokk->kop=168.and.dokk->vo=9)
  #ifndef __CLIP__
  #endif
     if gnEntRm=0
        if p1=1 // Добавить
           if dokk->bs_d=641002.and.bs_k=704101.or.dokk->bs_k=641002.and.!int(bs_k/1000)=311.or.dokk->bs_d=641002.and.dokk->bs_k=643001
  //         if dokk->bs_d=641002.and.!((int(bs_k/1000)=311.or.dokk->bs_k=641001).or.!(dokk->bs_d=948001.and.dokk->bs_k=641002)
              if dokk->mn#0
                 pr1ndsr=0
              endif
              if pr1ndsr=0
                 if dokk->nnds#0
                    sele nnds
                    if netseek('t1','dokk->nnds')
                       if rn#0
                          if !(mn=dokk->mn.and.rnd=dokk->rnd.and.sk#dokk->sk.and.rn#dokk->rn.and.mnp#dokk->mnp)
                             nndsr=0
                             sele dokk
                             netrepl('nnds','nndsr',1)
                          endif
                       endif
                    else
                       nndsr=0
                       sele dokk
                       netrepl('nnds','nndsr',1)
                    endif
                 endif
                 if dokk->nnds=0
                    sele nnds
                    if netseek('t2','dokk->mn,dokk->rnd,dokk->sk,dokk->rn,dokk->mnp')
                       netrepl('sm','sm+dokk->bs_s')
                       nndsr=nnds
                       sele kln
                       if netseek('t1','dokk->kkl')
                          nn_r=nn
                          nsv_r=nsv
                          nkl_r=subs(nkl,1,40)
                       else
                          nn_r=0
                          nsv_r=''
                          nkl_r=''
                       endif
                       sele nnds
                       netrepl('kkl,nkl,nn,nsv','dokk->kkl,nkl_r,nn_r,nsv_r')
  //                     if nn#0.and.!empty(nsv).and.mn=0
                       if nn#0.and.mn=0.or.sm>=10000
                          netrepl('prxml','prxmlr')
  //                        netrepl('prxml','1')
                       else
                          netrepl('prxml','0')
                       endif
                       sele dokk
                       netrepl('nnds','nndsr')
                       sele dokk
                       sele nnds
                       netrepl('nnds1,dnn1','dokk->nndsvz,dokk->dnnvz')
                       nnvz()
                       if dokk->mn=0
                          if dokk->mnp=0
                             if select('rs1')#0
                                if dokk->rn=rs1->ttn.and.dokk->mnp=0
                                   sele rs1
                                   netrepl('nnds','nndsr',1)
                                endif
                             endif
                          else
                             if select('pr1')#0
                                if dokk->rn=pr1->nd.and.dokk->mnp=pr1->mn
                                   sele pr1
                                   netrepl('nnds','nndsr',1)
                                endif
                             endif
                          endif
                       endif
                       sele dokk
                    else // не найден по mn,rnd,sk,rn,mnp в nnds
  //                     nndsr=0
                       if dokk->mn=0
                          if dokk->mnp=0
                             if select('rs1')#0
                                if dokk->rn=rs1->ttn.and.dokk->mnp=0
                                   sele rs1
                                   nndsr=nnds
                                else
                                   nndsr=0
                                endif
                             else
                                nndsr=0
                             endif
                          else
                             if select('pr1')#0
                                if dokk->rn=pr1->nd.and.dokk->mnp=pr1->mn
                                   sele pr1
                                   nndsr=nnds
                                else
                                   nndsr=0
                                endif
                             else
                                nndsr=0
                             endif
                          endif
                          if nndsr#0
                             sele nnds
                             if netseek('t1','nndsr')
                                if rn#0
                                   if !(mn=dokk->mn.and.rnd=dokk->rnd.and.sk#dokk->sk.and.rn#dokk->rn.and.mnp#dokk->mnp)
                                      nndsr=0
                                   else
                                      if !reclock(1)
                                         nndsr=0
                                      endif
                                   endif
                                else
                                   if !reclock(1)
                                      nndsr=0
                                   endif
                                endif
                             else
                                nndsr=0
                             endif
                          endif
                       else
                          nndsr=0
                       endif
                       if nndsr=0 // Новый номер
                          sele cntm
                          if recc()=0
                             netadd()
                          endif
                          reclock()
                          if nnds=0
                             repl nnds with 1
                          endif
                          nndsr=nnds
                          do while .t.
                             sele nnds
                             if !netseek('t1','nndsr')
                                sele cntm
                                netrepl('nnds','nndsr+1')
                                exit
                             else
                                nndsr=nndsr+1
                             endif
                          enddo
                          sele nnds
                          netadd()
                          netrepl('nnds,mn,rnd,sk,rn,mnp,sm,dnn,rm,vdnal,tvdnal',;
                          'nndsr,dokk->mn,dokk->rnd,dokk->sk,dokk->rn,dokk->mnp,dokk->bs_s,dokk->ddk,dokk->rmsk,dokk->vdnal,dokk->tvdnal')
                          sele kln
                          if netseek('t1','dokk->kkl')
                             nn_r=nn
                             nsv_r=nsv
                             nkl_r=subs(nkl,1,40)
                          else
                             nn_r=0
                             nsv_r=''
                             nkl_r=''
                          endif
                          sele nnds
                          netrepl('kkl,nkl,nn,nsv','dokk->kkl,nkl_r,nn_r,nsv_r')
  //                        if nn#0.and.!empty(nsv).and.mn=0
                          if nn#0.and.mn=0.or.sm>=10000
                             netrepl('prxml','prxmlr')
  //                           netrepl('prxml','1')
                          else
                             netrepl('prxml','0')
                          endif
                          sele dokk
                          netrepl('nnds','nndsr')
                          sele nnds
                          netrepl('nnds1,dnn1','dokk->nndsvz,dokk->dnnvz')
                          nnvz()
                          sele dokk
                       else // Уже есть
                          netrepl('mn,rnd,sk,rn,mnp,sm,dnn,rm',;
                           'dokk->mn,dokk->rnd,dokk->sk,dokk->rn,dokk->mnp,dokk->bs_s,dokk->ddk,dokk->rmsk')
                          sele kln
                          if netseek('t1','dokk->kkl')
                             nn_r=nn
                             nsv_r=nsv
                             nkl_r=subs(nkl,1,40)
                          else
                             nn_r=0
                             nsv_r=''
                             nkl_r=''
                          endif
                          sele nnds
                          netrepl('kkl,nkl,nn,nsv','dokk->kkl,nkl_r,nn_r,nsv_r')
  //                        if nn#0.and.!empty(nsv).and.mn=0
                          if nn#0.and.mn=0.or.sm>=10000
                             netrepl('prxml','prxmlr')
  //                           netrepl('prxml','1')
                          else
                             netrepl('prxml','0')
                          endif
                          sele dokk
                          netrepl('nnds','nndsr')
                          sele dokk
                          sele nnds
                          netrepl('nnds1,dnn1','dokk->nndsvz,dokk->dnnvz')
                          nnvz()
                          sele dokk
                       endif
                    endif
                 else // Номер НН уже присвоен
                    sele dokk
                    nndsr=nnds
                    sele nnds
                    if nndsr#0
                       if netseek('t1','nndsr')
                          netrepl('mn,rnd,sk,rn,mnp,dnn,rm',;
                          'dokk->mn,dokk->rnd,dokk->sk,dokk->rn,dokk->mnp,dokk->ddk,dokk->rmsk')
                          netrepl('sm','sm+dokk->bs_s')
                       else
                          netadd()
                          netrepl('nnds,mn,rnd,sk,rn,mnp,sm,dnn,rm,vdnal,tvdnal',;
                          'nndsr,dokk->mn,dokk->rnd,dokk->sk,dokk->rn,dokk->mnp,dokk->bs_s,dokk->ddk,dokk->rmsk,dokk->vdnal,dokk->tvdnal')
                       endif
                    endif
                    sele nnds
                    sele kln
                    if netseek('t1','dokk->kkl')
                       nn_r=nn
                       nsv_r=nsv
                       nkl_r=subs(nkl,1,40)
                    else
                       nn_r=0
                       nsv_r=''
                       nkl_r=''
                    endif
                    sele nnds
                    netrepl('kkl,nkl,nn,nsv','dokk->kkl,nkl_r,nn_r,nsv_r')
  //                  if nn#0.and.!empty(nsv).and.mn=0
                    if nn#0.and.mn=0.or.sm>=10000
                       netrepl('prxml','prxmlr')
  //                     netrepl('prxml','1')
                    else
                       netrepl('prxml','0')
                    endif
                    sele dokk
                    sele nnds
                    netrepl('nnds1,dnn1','dokk->nndsvz,dokk->dnnvz')
                    nnvz()
                    sele dokk
                 endif
                 // Запись номера НН в складской документ
                 if dokk->mn=0
                    if dokk->mnp=0
                       if select('rs1')#0
                          if dokk->rn=rs1->ttn.and.dokk->mnp=0
                             sele rs1
                             netrepl('nnds','nndsr',1)
                          endif
                       endif
                    else
                       if select('pr1')#0
                          if dokk->rn=pr1->nd.and.dokk->mnp=pr1->mn
                             sele pr1
                             netrepl('nnds','nndsr',1)
                          endif
                       endif
                    endif
                 endif
              else // pr1ndsr=1
                 nndsr=dokk->nnds
                 nnds1r=dokk->nndsvz
                 if dokk->mnp=0
                    if select('rs1')#0
                       sele rs1
                       nndsr=nnds
                       nnds1r=0
                    endif
                 else
                    if select('pr1')#0
                       sele pr1
                       nndsr=nnds
                       nnds1r=nndsvz
                    endif
                 endif

                 if nndsr#0
                    sele nnds
                    set orde to tag t3
                    if netseek('t3','dokk->kkl,nndsr')
                       nnds1r=nnds1
                       // нужная НН есть в реестре
                    else
                       nndsr=0
                       nnds1r=0
                    endif
                 endif

                 if nndsr=0
                    sele nnds
                    set orde to tag t3
                    if netseek('t3','dokk->kkl')
                       // Поиск подходящей НН
                       do while kkl=dokk->kkl
                          if dokk->bs_k=641002
                             if nnds1=0.and.rn=0 // Найдена
                                nndsr=nnds
                                nnds1r=nnds1
                                exit
                             endif
                          else
                             if nnds1#0.and.rn=0 // Найдена
                                nndsr=nnds
                                nnds1r=nnds1
                                exit
                             endif
                          endif
                          sele nnds
                          skip
                       enddo
                    else // клиента нет в реестре
                       nndsr=0
                       nnds1r=0
                    endif
                 endif

                 if nndsr#0 // Добавить сумму
                    sele nnds
                    netrepl('sm,dnn','sm+dokk->bs_s,dokk->ddk')
                    sele dokk
                    netrepl('nnds','nndsr')
                 else // создать новую запись в реестре
                    sele cntm
                    if recc()=0
                       netadd()
                    endif
                    reclock()
                    if nnds=0
                       repl nnds with 1
                    endif
                    nndsr=nnds
                    do while .t.
                       sele nnds
                       if !netseek('t1','nndsr')
                          sele cntm
                          netrepl('nnds','nndsr+1')
                          exit
                       else
                          nndsr=nndsr+1
                       endif
                    enddo
                    sele nnds
                    netadd()
                    netrepl('nnds,sm,dnn,vdnal,tvdnal',;
                            'nndsr,dokk->bs_s,dokk->ddk,dokk->vdnal,dokk->tvdnal')
                    sele kln
                    if netseek('t1','dokk->kkl')
                       nn_r=nn
                       nsv_r=nsv
                       nkl_r=subs(nkl,1,40)
                    else
                       nn_r=0
                       nsv_r=''
                       nkl_r=''
                    endif
                    sele nnds
                    netrepl('kkl,nkl,nn,nsv','dokk->kkl,nkl_r,nn_r,nsv_r')
  //                  if nn#0.and.!empty(nsv).and.mn=0
                    if nn#0.and.mn=0.or.sm>=10000
                       netrepl('prxml','prxmlr')
  //                     netrepl('prxml','1')
                    else
                       netrepl('prxml','0')
                    endif
                    sele dokk
                    netrepl('nnds','nndsr')
                    sele nnds
                    netrepl('nnds1,dnn1','dokk->nndsvz,dokk->dnnvz')
                    nnvz()
                    sele dokk
                 endif
                 // Запись номера НН в складской документ
                 if dokk->mn=0
                    if dokk->mnp=0
                       if select('rs1')#0
                          if dokk->rn=rs1->ttn.and.dokk->mnp=0
                             sele rs1
                             netrepl('nnds','nndsr',1)
                          endif
                       endif
                    else
                       if select('pr1')#0
                          if dokk->rn=pr1->nd.and.dokk->mnp=pr1->mn
                             sele pr1
                             netrepl('nnds','nndsr',1)
                          endif
                       endif
                    endif
                 endif
              endif
           endif
        else // Удалить
           sele dokk
           nndsr=nnds
           if nndsr#0
              sele nnds
              if netseek('t1','nndsr')
                 netrepl('sm','sm-dokk->bs_s')
                 if nnds->sm=0
                    cnlr=''
                    netrepl('mn,rnd,sk,rn,mnp,sm,rm,kkl,nn,nsv','0,0,0,0,0,0,0,0,0,cnlr')
                    netrepl('mn1,rnd1,sk1,rn1,mnp1,nnds1,sm1','0,0,0,0,0,0,0')
                endif
                nndsr=0
                nndsvzr=0
                sele dokk
                netrepl('nnds,nndsvz','nndsr,nndsvzr')
              endif
           endif
        endif
     else // gnEntRm=1
        if p1=1 // Добавить
           if dokk->bs_d=641002.and.bs_k=704101.or.dokk->bs_k=641002.and.dokk->rmsk=gnRmSk.or.dokk->bs_d=641002.and.dokk->bs_k=643001
              nndsr=dokk->nnds
              if nndsr#0
                 sele nnds
                 if !netseek('t1','nndsr')
                    nndsr=0
                 endif
              endif
              if nndsr=0
                 sele dokk
                 netrepl('nnds,nndsvz','0,0')
              else
                 // Запись номера НН в складской документ
                 if dokk->mn=0
                    if dokk->mnp=0
                       if select('rs1')#0
                          if dokk->rn=rs1->ttn.and.dokk->mnp=0
                             sele rs1
                             netrepl('nnds','nndsr',1)
                          endif
                       endif
                    else
                       if select('pr1')#0
                          if dokk->rn=pr1->nd.and.dokk->mnp=pr1->mn
                             sele pr1
                             netrepl('nnds','nndsr',1)
                          endif
                       endif
                    endif
                 endif
              endif
           endif
        endif
     endif
  endif
  return .t.

*************
func chknn()
  *************
  if nndsr#0
     sele nnds
     if !netseek('t1','nndsr')
        wmess('Нет такого номера',2)
        return .f.
     else
        if pr1ndsr=0.and.rn#0.and.kkl#0
           wmess('Занят',2)
           return .f.
        endif
    endif
  endif
  return .t.

************
func nnvz()
  ************
  sele nnds
  nnds1r=nnds1
  dnn1r=dnn1
  sk1r=sk1
  rn1r=rn1
  sm1r=sm1
  if nnds1r#0.and.!empty(dnn1r)
     if bom(dnn1r)<ctod('01.03.2011')
        sele nds
        if netseek('t1','nnds1r')
           sm1r=sum/6
           sk1r=sk
           rn1r=ttn
        endif
     else
        pathr=gcPath_e+'g'+str(year(dnn1r),4)+'\m'+iif(month(dnn1r)<10,'0'+str(month(dnn1r),1),str(month(dnn1r),2))+'\'
        netuse('nnds','nndsc',,1)
        if netseek('t1','nnds1r')
           sm1r=sm
           sk1r=sk
           rn1r=rn
        endif
        nuse('nndsc')
     endif
     sele nnds
     netrepl('sm1,sk1,rn1','sm1r,sk1r,rn1r')
  endif
  return .t.
*******************************************************
func bon174()
  // если находимся не в документе
  // необходимо предварительно определить mk174r=chk174() и skr
  // при этом стоять в rs1 на документе
  *******************************************************
  if !(rs1->vo=9.and.(rs1->kop=174.or.rs1->kopi=174))
     return .t.
  endif
  if mk174r#0
     ttn_rr=rs1->ttn
     nkkl_rr=rs1->nkkl
     if nkkl_rr=0
        nkkl_rr=rs1->kpl
     endif
     if empty(rs1->dfp) // Удалить
        sele kplbon
        if netseek('t1','nkkl_rr,mk174r')
           reclock()
           sele kplboe
           if netseek('t1','nkkl_rr,mk174r,skr,ttn_rr')
              do while kpl=nkkl_rr.and.mkeep=mk174r.and.sk=skr.and.ttn=ttnr
                 smr=sm
                 netdel()
                 sele kplbon
                 netrepl('smbon,smost','smbon-smr,smost+smr',1)
                 sele kplboe
                 skip
              enddo
           endif
           sele kplbon
           netunlock()
        endif
     else // Добавить,коррекция
        sele kplbon
        if netseek('t1','nkkl_rr,mk174r')
           reclock()
           sele kplboe
           if netseek('t1','nkkl_rr,mk174r,skr,ttn_rr')
              do while kpl=nkkl_rr.and.mkeep=mk174r.and.sk=skr.and.ttn=ttn_rr
                 smr=sm
                 netdel()
                 sele kplbon
                 netrepl('smbon,smost','smbon-smr,smost+smr',1)
                 sele kplboe
                 skip
              enddo
           endif
           sele rs2
           if netseek('t1','ttn_rr')
              do while ttn=ttn_rr
                 if int(mntov/10000)<2
                    skip
                    loop
                 endif
                 mntov_rr=mntov
                 mkeep_rr=getfield('t1','mntov_rr','ctov','mkeep')
                 if mkeep_rr=mk174r
                    sele rs2
                    kvpr=kvp
                    zenr=zenp
                    smr=round(kvpr*zenr,2)
                    sele kplboe
                    if !netseek('t1','nkkl_rr,mk174r,skr,ttn_rr')
                       appe blank
                       repl kpl with nkkl_rr,;
                            mkeep with mk174r,;
                            sk with skr,;
                            ttn with ttn_rr
                    endif
                    repl sm with sm+smr
                    sele kplbon
                    netrepl('smbon,smost','smbon+smr,smost-smr',1)
                 endif
                 sele rs2
                 skip
              enddo
           endif
           sele kplbon
           netunlock()
        endif
     endif
  endif
  return .t.

**************
func chk174()
  **************
  local aaa
  aaa=0
  if rs1->kop=174.or.rs1->kopi=174
     sele rs2
     if netseek('t1','rs1->ttn')
        do while rs2->ttn=rs1->ttn
           mntov_rr=mntov
           if int(mntov_rr/10000)>1
              aaa=getfield('t1','mntov_rr','ctov','mkeep')
              if aaa#0
                 exit
              endif
           endif
           sele rs2
           skip
        enddo
     endif
  endif
  return aaa


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  02-13-17 * 10:26:40am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ.......... skvzr dtvzr
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION TtnVz()
  If TtnVzr > 0 // например -169 не обратывает
    If !empty(skvzr)
     cPthSkVz:=alltrim(getfield('t1','skvzr','cskl','path'))
    Else
     cPthSkVz:=gcDir_t
    EndIf
    prTtnVzr=0
    dnnvzr=ctod('')
    if TtnVzr#0 // есть номер
       if !empty(dtvzr) // есть дата ТТН
          pathr=gcPath_e + pathYYYYMM(dtvzr) + '\' + cPthSkVz
          if !netfile('rs1',1)
             dtvzr=ctod('')
             kzgr=0
          else
             netuse('rs1','rs1vz',,1)
             sele rs1vz
             if !netseek('t1','TtnVzr')
               dtvzr=ctod('')
               kzgr=0
             else
               ktar=kta
               nktar=getfield('t1','ktar','s_tag','fio')
               ktasr=ktas
               kpsr=kpl
               kzgr=kgp
               nkpsr=getfield('t1','kpsr','kln','nkl')
               nomndsvzr=nnds
               nndsvzr=nnds
               if dtvzr<ctod('01.03.2011')
                 dnnvzr=getfield('t1','nndsvzr','nds','dnn')
               else
                 pathr=gcPath_e + pathYYYYMM(dtvzr) + '\'
                 netuse('nnds','nndsvz',,1)
                 dnnvzr=getfield('t1','nndsvzr','nndsvz','dnn')
                 nuse('nndsvz')
               endif
               prTtnVzr=1
             endif
             nuse('rs1vz')
             nuse('nndsvz')
          endif
       else
          dtvzr=ctod('')
       endif
       if empty(dtvzr)
          for yyr=year(gdTd) to 2006 step -1
              do case
              case yyr=year(gdTd)
                mm1r=month(gdTd)
                mm2r=1
              case yyr=2006
                mm1r=12
                mm2r=9
              other
                mm1r=12
                mm2r=1
              endc
              for mmr=mm1r to mm2r step -1
                cdtvzr='01.'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'.'+str(yyr,4)
                dtvzr=ctod(cdtvzr)
                pathr=gcPath_e + pathYYYYMM(dtvzr)  + '\' +  cPthSkVz
                if !netfile('rs1',1)
                    loop
                endif
                if !netfile('rs1',1)
                    loop
                endif
                netuse('rs1','rs1vz',,1)
                sele rs1vz
                if netseek('t1','TtnVzr')
                  if fieldpos('ndvz')#0
                    netrepl('ndvz,mnvz','ndr,mnr')
                    if fieldpos('dtvz')#0
                      netrepl('dtvz','gdTd')
                    endif
                  endif
                  ktar=kta
                  nktar=getfield('t1','ktar','s_tag','fio')
                  ktasr=ktas
                  kpsr=kpl
                  kzgr=kgp
                  nkpsr=getfield('t1','kpsr','kln','nkl')
                  nomndsvzr=nnds
                  nndsvzr=nnds
                  prTtnVzr=1
                  if dtvzr<ctod('01.03.2011')
                    dnnvzr=getfield('t1','nndsvzr','nds','dnn')
                  else
                    pathr=gcPath_e + pathYYYYMM(dtvzr) + '\'
                    netuse('nnds','nndsvz',,1)
                    if netseek('t1','nndsvzr')
                      if rn=TtnVzr.and.mnp=0
                        dnnvzr=dnn
                      else
                        dnnvzr=ctod('')
                      endif
                    endif
                    nuse('nndsvz')
                    endif
                endif
                nuse('rs1vz')
                if prTtnVzr=1
                  exit
                endif
              next
              if prTtnVzr=1
                 exit
              endif
          next
       endif
    else
       wmess('rs1->TtnVz=0',2)
    endif

    if prTtnVzr=1
      If Empty(dnnVzr) .and. !empty(nomndsvzr)
        outlog(__FILE__,__LINE__,ndr,skvzr,TtnVzr,dtvzr,nomndsvzr,pathr)
        wmess('Не найдена дата НН 4 ТТН',2)
        return .f.
      Else
        return .t.
      EndIf
    else
      wmess('Не найдена ТТН',2)
      TtnVzr=0
      dtvzr=ctod('')
      nndsvzr=0
      dnnvzr=ctod('')
      kzgr=0
      return .f.
    endif
  EndIf
  return .t.

*************************
func dftcen(p1,p2,p3)
  // p1 kpl
  // p2 kgp
  // p3 mntov
  *************************
  local tcen_rr
  tcen_rr=0
  kpl_rr=p1
  kgp_rr=p2
  mntov_rr=p3
  kg_rr=int(mntov_rr/10000)
  izg_rr=getfield('t1','mntov_rr','ctov','izg')
  mkeep_rr=getfield('t1','mntov_rr','ctov','mkeep')
  tcen_rr=getfield('t1','kpl_rr,izg_rr,kg_rr','klnnac','tcen')
  if tcen_rr=0
     tcen_rr=getfield('t1','kpl_rr,izg_rr,999','klnnac','tcen')
  endif
  if tcen_rr=0
     tcen_rr=getfield('t1','kgp_rr,mkeep_rr','kgptm','tcen')
  endif
  if tcen_rr=0
     knasp_rr=getfield('t1','kgp_rr','kln','knasp')
     kgpcat_rr=getfield('t1','kgp_rr','kgp','kgpcat')
     if knasp_rr#0
        tcen_rr=getfield('t2','knasp_rr,kgpcat_rr,mkeep_rr','nasptm','tcen')
     endif
     if tcen_rr=0
        tcen_rr=getfield('t2','knasp_rr,0,mkeep_rr','nasptm','tcen')
     endif
  endif
  if tcen_rr=0
     krn_rr=getfield('t1','kgp_rr','kln','krn')
     if krn_rr#0
        tcen_rr=getfield('t2','krn_rr,kgpcat_rr,mkeep_rr','rntm','tcen')
     endif
  endif
  if tcen_rr=0
     tcen_rr=getfield('t1','krn_rr,mkeep_rr','krntm','tcen')
  endif
  return tcen_rr

***************************
func sox(p1,p2,p3,p4)
  // p1 - date дата прихода
  // p2 - date месяц прихода
  // p3 - sk
  // p4 - kps
  ***************************
  if empty(p1)
     return .f.
  endif
  if !(NdOtvr=3.or.NdOtvr=4)
     return .f.
  endif
  dt_r=p1

  if empty(p2)
     dtp_r=dt_r
  else
     dtp_r=p2
  endif

  if empty(p3)
     sk_r=228
  else
     sk_r=p3
  endif

  if empty(p4)
     kps_r=2248008
  else
     kps_r=p4
  endif

  netuse('cskl')
  netuse('ctov')
  if select('sox')#0
     sele sox
     use
  endif
  erase sox.dbf
  erase sox.cdx
  crtt('sox','f:bar c:c(15) f:nat c:c(60) f:cnt c:c(15) f:kol c:n(10,3)')
  sele 0
  use sox
  sele cskl
  locate for sk=sk_r
  if foun()
     dir_r=alltrim(path)
  endif
  pathr=gcPath_e+'g'+str(year(dtp_r),4)+'/m'+iif(month(dtp_r)<10,'0'+str(month(dtp_r),1),str(month(dtp_r),2))+'\'+dir_r
  if netfile('pr1',1)
     netuse('pr1',,,1)
     netuse('pr2',,,1)
     sele pr1
     go top
     do while !eof()
        if pr1->ddc#dt_r
           skip
           loop
        endif
        if pr1->otv#NdOtvr
           skip
           loop
        endif
        if pr1->kps#kps_r
           skip
           loop
        endif
        mn_r=mn
        sele pr2
        if netseek('t1','mn_r')
           do while mn=mn_r
              store '' to bar_r,nat_r
              mntov_r=mntov
              kol_r=kf
              sele ctov
              if netseek('t1','mntov_r')
                 nat_r=subs(nat,1,60)
                 mntovc_r=mntovc
                 if mntov=mntovc.or.mntovc=0
                    bar_r=str(bar,13)
                 else
                    sele ctov
                    if netseek('t1','mntovc_r')
                       bar_r=str(bar,13)
                       nat_r=subs(nat,1,60)
                    endif
                 endif
              endif
              sele sox
              if !empty(bar_r)
                 locate for bar=bar_r
              else
                 locate for nat=nat_r
              endif
              if !foun()
                 appe blank
                 repl bar with bar_r,;
                      nat with nat_r
              endif
  //            repl cnt with cnt+cnt_r
              repl kol with kol+kol_r
              sele pr2
              skip
           enddo
        endif
        sele pr1
        skip
     enddo
     sele sox
     repl all cnt with str(kol,15)
     nuse('pr1')
     nuse('pr2')
  endif
  nuse('cskl')
  nuse('ctov')
  return .t.

***************************
func soxs(nBlkMk)
  DEFAULT nBlkMk TO 0
  if !(NdOtvr=3.or.NdOtvr=4.or.(NdOtvr=2.and.nBlkMk=1))
     return .f.
  endif
    if select('sox')#0
       sele sox
       use
    endif
    erase sox.dbf
    erase sox.cdx
    crtt('sox','f:bar c:c(15) f:nat c:c(60) f:cnt c:c(15) f:kol c:n(10,3)')
    sele 0
    use sox
    if pr1->otv#NdOtvr
       return .f.
    endif
    if pr1->prz#0
       return .f.
    endif
    sele pr2
    set orde to tag t1
    if netseek('t1','mnr')
       do while mn=mnr
          store '' to bar_r,nat_r
          mntov_r=mntov
          /*
          *if mntov_r=5070379
          *wait
          *endif
          */
          kol_r=kf
          sele ctov
          if netseek('t1','mntov_r')
             nat_r=subs(nat,1,60)
             mntovc_r=mntovc
             if mntov=mntovc.or.mntovc=0
                if bar#0
                   bar_r=str(bar,13)
                else
                   bar_r=space(13)
                endif
             else
                sele ctov
                if netseek('t1','mntovc_r')
                   if bar#0
                      bar_r=str(bar,13)
                   else
                      bar_r=space(13)
                   endif
                   nat_r=subs(nat,1,60)
                endif
             endif
          endif
          sele sox
          if !empty(bar_r)
            locate for bar=bar_r .and. nat == nat_r  //mntov = mntov_r
          else
            locate for nat=nat_r //mntov = mntov_r
          endif
          if !foun()
             appe blank
             repl bar with bar_r,;
                  nat with nat_r
          endif
          repl kol with kol+kol_r
          sele pr2
          skip
       enddo
    else
       return .f.
    endif

    sele sox
    repl all cnt with str(kol,15)
    if dirchange(gcPath_ew+'sox')#0
       dirmake(gcPath_ew+'sox')
    endif
    dirchange(gcPath_l)

    if dirchange(gcPath_ew+'/sox/p'+alltrim(str(kpsr,7)))#0
       dirmake(gcPath_ew+'/sox/p'+alltrim(str(kpsr,7)))
    endif
    dirchange(gcPath_l)
    copy to (gcPath_ew+'sox/p'+alltrim(str(kpsr,7))+'/sox.dbf')

    fl_r=gcPath_ew+'sox/p'+alltrim(str(kpsr,7))+'/sns.dbf'
    if !file(fl_r)
       crtt(fl_r,'f:sns c:n(6)')
       sele 0
       use (fl_r)
       appe blank
       repl sns with 1
       use
    endif
    sele 0
    use (fl_r) shared

    fl_r=gcPath_ew+'sox/p'+alltrim(str(kpsr,7))+'/prot1.dbf'
    if !file(fl_r)
       crtt(fl_r,'f:sns c:n(6) f:mn c:n(6) f:dt c:d(10) f:tm c:c(8) f:kto c:n(4) f:rzlt c:c(10)')
       sele 0
       use (fl_r) excl
       inde on str(sns,6)+str(mn,6) tag t1
       use
    endif
    sele 0
    use (fl_r) shared

    fl_r=gcPath_ew+'sox/p'+alltrim(str(kpsr,7))+'/prot2.dbf'
    if !file(fl_r)
       crtt(fl_r,'f:sns c:n(6) f:mn c:n(6) f:nat c:c(60) f:kol c:n(15,3) f:bar c:n(13)')
       sele 0
       use (fl_r) excl
       inde on str(sns,6)+str(mn,6)+str(bar,13) tag t1
       use
    endif
    sele 0
    use (fl_r) shared

    sele sns
    reclock()
    snsr=sns
    netrepl('sns','sns+1')

    sele prot1
    appe blank
    repl sns with snsr,;
         mn with mnr,;
         dt with date(),;
         tm with time(),;
         kto with gnKto

    sele sox
    go top
    do while !eof()
       natr=nat
       barr=val(bar)
       kolr=kol
       sele prot2
       appe blank
       repl sns with snsr,;
            mn with mnr,;
            nat with natr,;
            bar with barr,;
            kol with kolr
       sele sox
       skip
    enddo

    sele sox
    use
    sele sns
    use
    sele prot1
    use
    sele prot2
    use
    return .t.

**************
func BlkOtv()
  **************
  netuse('pr1')
  netuse('pr2')

  sele pr1
  mnotv_r=0
  if netseek('t3','1,post_r')
    mnotv_r=mn
  endif

  sele pr2
  if netseek('t1','mnotv_r,ktl_r')
  //     reclock()
    kfotv_r=kf
    if kfotv_r#osvo_r
      if gnArm#0
        wmess('Несовпадает остаток с отв.хран.',0)
        quit
        nuse('pr1')
        nuse('pr2')
      endif
  //        if rs2vidr=2.and.gnCtov=1
           sele tovm
  //         db_unlock()
  //        endif
      sele tov
  //      db_unlock()
      return .f.
    endif
  else
    outlog(__FILE__,__LINE__,"netseek('t1','mnotv_r,ktl_r')",mnotv_r,ktl_r,'post_r',post_r)
    wmess('Нет прихода с отв.хр.',0)
    quit
    nuse('pr1')
    nuse('pr2')
  //     if rs2vidr=2.and.gnCtov=1
    sele tovm
  //      db_unlock()
  //     endif
    sele tov
  //   db_unlock()
    return .f.
  endif
  return .t.

***************
func crprotp()
  ***************
  if otv_r=2               // Коррекция протокола продаж
     sele rs2
     kvpor=kvpo            // Отправлено в отчет
     kvpr=kvp              // Текущее значение
     kfr=kvpr-kvpor        // Количество для коррекции
     pptr=ppt
     amnp_r=amnp
     // Коррекция количества в приходе с отв.хр.
     sele pr2
     netrepl('kf','kf-kfr') // Снятие блокировки пр.отв.Откат старого к-ва
     sele rs2
     netrepl('kvpo,otv,amnp,ktlm,ktlmp','kvpr,otv_r,amnp_r,ktl_r,ktlp_r')
     sele pr2
     if amnp_r#0
        if !netseek('t2','amnp_r','pr1')
            amnp_r=0
        endif
     endif
     if amnp_r=0
        sele pr1
        if netseek('t3','2,kpsr')
           if mn#0
              amnp_r=mn
           endif
        endif
        if amnp_r=0

           sele cskl
           netseek('t1','gnSk')
           Reclock()
           amnp_r=mn
           if mn<999999
              netrepl('mn',{mn+1})
           else
              netrepl('mn',{1})
           endif

           sele pr1
           netadd()
           netrepl('nd,mn,skl,vo,kps,kop,ddc,tdc,otv',;
                   'amnp_r,amnp_r,sklr,9,kpsr,101,date(),time(),2')
        endif
     endif
     sele pr2
     if !netseek('t3','amnp_r,ktlp_r,pptr,ktl_r')
        netadd()
        netrepl('mn,mntov,ktl,kf,kfo,ktlp,ppt,ktlm,ktlmp',;
                'amnp_r,mntov_r,ktl_r,kfr,kfr,ktlp_r,pptr,ktl_r,ktlp_r')
        if fieldpos('mntovp')#0
           netrepl('mntovp','mntovp_r')
        endif
     else
        netrepl('kf,kfo','kf+kfr,kfo+kfr')
     endif
     kf_r=kfr
     sele rs2
     netrepl('amnp','amnp_r')
  endif
  return .t.

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  11-17-12 // 11:06:41am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION List_aRmDep()
  aRmDep:={}
   cskl->(DBGOTOP())
   DO WHILE cskl->(!EOF())
     IF gnEnt = cskl->Ent
      IF EMPTY(aRmDep)
        AADD(aRmDep,cskl->Rm)
      ELSE
        IF ASCAN(aRmDep,cskl->Rm)=0
          AADD(aRmDep,cskl->Rm)
        ENDIF
      ENDIF
     ENDIF
     cskl->(DBSKIP())
   enddo

   ASORT(aRmDep)
  RETURN (aRmDep)

*************
func ndsvz()
  *************
  prndsvzr=0
  prndsr=0
  dnnvzr=ctod('')
  sele nnds
  set orde to tag t3
  if !netseek('t3','kpsr')
     wmess('Нет НН для этого клиента',2)
     return .f.
  else
     do while kkl=kpsr
        if mn=0.and.rn=0.and.nnds1=0 // есть основная НН
           nndsvzr=nnds
           dnnvzr=dnn
           prndsr=1
           exit
        endif
        sele nnds
        skip
     enddo

     sele kln
     if netseek('t1','kpsr')
        nn_r=nn
        nsv_r=nsv
        nkl_r=subs(nkl,1,40)
        if !empty(nn_r) //.and.!empty(nsv_r)
           prxml_r=1
        else
           prxml_r=0
        endif
     else
        nn_r=0
        nsv_r=''
        nkl_r=''
        prxml_r=0
     endif

     if nndsr#0
        sele nnds
        netseek('t1','nndsr')
        if kkl=kklr.and.rn=0
           if nnds1=0.and.sm=0
              netrepl('nnds,dnn,nnds1,dnn1','kpsr,nndsr,gdTd,nndsvzr,dnnvzr')
              if !empty(nn_r) //.and.!empty(nsv_r)
                 prxml_r=1
              else
                 prxml_r=0
              endif
              sele nnds
  //            netrepl('nkl,nn,nsv','nkl_r,nn_r,nsv_r')
              netrepl('nkl,nn,nsv,prxml','nkl_r,nn_r,nsv_r,prxml_r')
           else
              nndsr=0
           endif
        endif
     endif

     if nndsr=0
        sele nnds
        netseek('t3','kpsr')
        do while kkl=kpsr
           if mn=0.and.rn=0.and.nnds1#0 // есть коррекция
              nndsr=nnds
              dnnr=dnn
              nnds1r=nnds1
              dnn1r=dnn1
  //            netrepl('nkl,nn,nsv','nkl_r,nn_r,nsv_r')
              netrepl('nkl,nn,nsv,prxml','nkl_r,nn_r,nsv_r,prxml_r')
              prndsvzr=1
              exit
           endif
           sele nnds
           skip
        enddo
     endif
  endif

  if prndsr=0
     wmess('Нет основной НН '+str(nndsvzr,10),2)
     return .f.
  endif

  if prndsvzr=1
     if nndsvzr#nnds1r
        wmess('Несовпадение номеров'+str(nndsr,10),2)
        return .f.
     endif
  else // Новая
     sele cntm
     if recc()=0
        netadd()
     endif
     reclock()
     if nnds=0
        repl nnds with 1
     endif
     nndsr=nnds
     do while .t.
        sele nnds
        if !netseek('t1','nndsr')
           sele cntm
           netrepl('nnds','nndsr+1')
           exit
        else
           nndsr=nndsr+1
        endif
     enddo
     sele nnds
     netadd()
     netrepl('kkl,nnds,dnn,nnds1,dnn1','kpsr,nndsr,gdTd,nndsvzr,dnnvzr')
     sele kln
     if netseek('t1','kpsr')
        nn_r=nn
        nsv_r=nsv
        nkl_r=subs(nkl,1,40)
     else
        nn_r=0
        nsv_r=''
        nkl_r=''
     endif
     if !empty(nn_r) //.and.!empty(nsv_r)
        prxml_r=1
     else
        prxml_r=0
     endif
     sele nnds
     netrepl('nkl,nn,nsv,prxml','nkl_r,nn_r,nsv_r,prxml_r')
  //   netrepl('nkl,nn,nsv','nkl_r,nn_r,nsv_r')
  endif
  sele nnds
  TtnVzr=0
  dtvzr=ctod('')
  nndsr=nnds
  dnnr=dnn
  nndsvzr=nnds1
  dnnvzr=dnn1
  return .t.

*************************
func DecStr(p1)
  local aaa
  aaa=' '
  return aaa

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  05-23-16 * 11:51:53am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION KProd_KodVid(uktr,kprodr,vidr)
          //sele kprod
  locate for ukt=uktr
  if foun()
    kprodr=kod
    vidr=vid
  else
    locate for left(ukt,6)=left(uktr,6)
    if foun()
      kprodr=kod
      vidr=vid
    endif
    // может ошибка при наборе
    for i=10 to 1 step -1

      exit // 01-13-17 03:11pm отмена исправление ошибок

      uktr=subs(uktr,1,i)
      locate for ukt=uktr
      if foun()
        kprodr=kod
        vidr=vid
        exit
      endif
    next
  endif
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-28-16 * 03:12:37pm
 НАЗНАЧЕНИЕ......... проверка наличия кода операции в списке
 ПАРАМЕТРЫ.......... cKop- код операции
                     cLsKop- список операций 4 который делается проверка
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION  BrandCodeList(cKop, cLsKop)
  LOCAL lRet:=.T.
  // доп. проверка по бренду
  IF cKop $ cLsKop
    brandr:=getfield('t1','mntovr','ctov','brand')
    outlog(3,__FILE__,__LINE__,brandr,mntovr,'brandr,mntovr')
    // есть бренд
    if brandr # 0
      cCodeList:=getfield('t2','mkeepr,brandr','brand','CodeList')
      // проверка списка на разрешенные КОР
      outlog(3,__FILE__,__LINE__,cKop $ cCodeList,mkeepr,brandr,'$,cCodeList,mkeepr,brandr',cCodeList)
      IF cKop $ cCodeList
      ELSE
        lRet:= .F.
      endif
    endif
  ENDIF
  RETURN (lRet)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  07-25-16 * 11:24:19am
 НАЗНАЧЕНИЕ......... вычилсяем номер Товарный документ
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION NextNumTtn(cVarNumTtn)
  LOCAL bVarNumTtn
  DEFAULT  cVarNumTtn  TO  "ttnr"
  bVarNumTtn:=memvarblock(cVarNumTtn)

  sele cskl
  reclock()
  EVAL(bVarNumTtn,ttn) //  ttnr:=ttn
  do while .t.
    if netseek('t1',cVarNumTtn,'rs1')
      // номер найден
      sele cskl
      if ttn<999999
        netrepl('ttn',{ttn+1},1)
      else
        netrepl('ttn',{1},1)
      endif
      EVAL(bVarNumTtn,ttn) //ttnr:=ttn
    else
      //sele cskl
      //netunlock()

      // получен новый номер ТТН, поствим счетчик на следующий
      if ttn<999999
        netrepl('ttn',{ttn+1})
      else
        netrepl('ttn',{1})
      endif

      exit
    endif
  enddo
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  08-15-16 * 03:20:04pm
 НАЗНАЧЕНИЕ......... создание врем таблицы
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Crt_trs2()
  if select('trs2')#0
     sele trs2
     use
  endif
  crtt('trs2','f:npp c:n(3) f:nat c:c(60) f:ukt c:c(10) f:upu c:c(20) f:kod c:n(4) f:kol c:n(12,3) f:zen c:n(10,2) f:sm c:n(12,2) f:ktl c:n(9) f:mntov c:n(7)')
  sele 0
  use trs2 excl

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  08-15-16 * 03:24:24pm
 НАЗНАЧЕНИЕ......... добавление всернутой строки
 ПАРАМЕТРЫ.......... nMk177Uc - какой МК свернут
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION AddRec2Trs2(nMk177Uc)
  if mntov177r=0
    mntov177r:=mntov177r(gnEnt,nMk177Uc)
  endif
  // цена
  if prc177r=0
    prc177r=getfield('t1','mntov177r','ctov','cenpr')
  endif
  sele rs1
  if mntov177=0.or.prc177=0
    netrepl('mntov177,prc177','mntov177r,prc177r')
  endif
  mntovr=mntov177r
  kg_r=int(mntovr/10000)
  sele ctov
  if netseek('t1','mntovr')
      natr=alltrim(nat)
      uktr=ukt
      kodr=kspovo
      kger=kge
  else
      natr=''
      uktr=space(10)
      kodr=0
      kger=0
  endif
  markr=getfield('t1','kg_r','cgrp','mark')
  if markr=1
      if kger#0
        natr=alltrim(getfield('t1','kger','GrpE','nge'))+' '+natr
      endif
  else
    if (OnGrpE4NotFullName())
        natr=alltrim(getfield('t1','kger','GrpE','nge'))+' '+natr
      endif
  endif

  upur=getfield('t1','kodr','kspovo','upu')

  kvp_r:=0; zen_r=round(prc177r,2)
  sm10r:=sm10r
  TmpSvp4Trs2(mntov177r)   //kvp_r zen_r
  smr=round(kvp_r*zen_r,2)
  outlog(3,__FILE__,__LINE__,"kvp_r,zen_r,smr,sm10r",kvp_r,zen_r,smr,sm10r)

  sele trs2
  netadd()
  netrepl('npp,nat,ukt,upu,kod,kol,zen,sm,mntov',;
          {1,natr,uktr,upur,kodr,kvp_r,zen_r,sm10r,mntovr})


  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  03-06-18 * 01:58:01pm
 НАЗНАЧЕНИЕ......... получение кода товара для подмены массива строк
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION MnTov177r(l_gnEnt, nMk177Uc)
  LOCAL mntov177r
  DEFAULT nMk177Uc TO 102
  //wmess(str(l_gnEnt))
  outlog(3,__FILE__,__LINE__,'l_gnEnt, nMk177Uc',l_gnEnt, nMk177Uc)
  Do Case
  Case l_gnEnt=20

    mntov177r=3800730   // 3800645 - весовой
    If nMk177Uc = 69
      mntov177r=3910346 // закуска Штучный
    EndIf

    // пока Кр.палочки
    // mntov177r=3800730   // 3800645

  Case  l_gnEnt=21
    mntov177r := ;
    {;
      {3300703, '// Живчик 0.33'},; // [1,1]
      {3300521, '// Живчик 0.5 '} ; // [2,1]
      }[1,1]
    //3410628
  EndCase
  RETURN (mntov177r)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  08-15-16 * 03:29:38pm
 НАЗНАЧЕНИЕ......... расчет цены, которая бы дала сумму без округления
 ПАРАМЕТРЫ..........  zen_r - начальная цена
                      sm10r - сумма, которая нужна
 ВОЗВР. ЗНАЧЕНИЕ....  zen_r - новая цена
                      kvp_r - к-во для получения суммы sm10r
                      создана таблица tmpsvp, где запись fnd=1 с zen kvp
 ПРИМЕЧАНИЯ.........
 */
FUNCTION TmpSvp4Trs2(lc_mntov177r)
  LOCAL roundKvp, MaxZen_r, MinZen_r, i
  LOCAL nKfNds:=round(gnNDS/100,2)
  LOCAL nKei

  If !Empty(lc_mntov177r)
    nKei := getfield('t1','mntov177r','ctov','kei')  // весовой
  Else
    if gnEnt=20
       nKei := 166
    else // Лодис
       nKei := 796 //щт
    EndIf
  EndIf

  if nKei = 166 // вес
    MaxZen_r=round(zen_r*1.05,2) // +5%
    MinZen_r=round(zen_r*0.95,2) // -5%
    kvp_r=round(sm10r/zen_r,2)   // базовое - к-во
    roundKvp:=2 // для округление к-ва до 2

  else // шт.
    // 02-19-18 11:18am
    // MaxZen_r=round(zen_r*1.99,2) //  +99%
    // MinZen_r=round(zen_r*0.01,2) //  -99%
    MaxZen_r=round(zen_r*1.49,2) //  +49%
    MinZen_r=round(zen_r*0.70,2) //  не меньше себестоимости
    kvp_r=round(sm10r/zen_r,0)   // базовое - к-во
    roundKvp:=0 // для округление к-ва до 0 - целого
  endif

  outlog(3,__FILE__,__LINE__,"base",sm10r,kvp_r,zen_r)

  // заполение данными для поиска подхоящей суммы
  crtt('tmpsvp','f:zen c:n(10,2) f:zen20 c:n(10,2) f:kvp c:n(10,2) f:svp c:n(10,2) f:svp20 c:n(10,2) f:svp_add20 c:n(10,2) f:zenp c:n(10,2) f:pr c:n(7,2) f:fnd c:n(1)')
  use tmpsvp new
  for i=MinZen_r to MaxZen_r step 0.01
    appe blank
    repl zen with i, kvp with round(sm10r/zen,roundKvp),;
      svp with round(zen*kvp,2),;
      zenp with zen_r, pr with 100-zen/zenp*100,;
      zen20 with round(zen + round(zen*nKfNds,2),2),; // цена втч НДС для КА
      svp20 with round(zen20 * kvp,2),;  // сумма с учетом втч НДС
      svp_add20 with round(svp + round(svp*nKfNds,2),2) // сумма д-та + НДС
  next i

  locate for svp=sm10r .and. svp20=svp_add20
  outlog(3,__FILE__,__LINE__,"found(),sm10r,svp=sm10r & svp20=svp_add20",found(),sm10r)
  If found()
    rz_r=1000
    rc_r=0
    Do While found()
      rzr=abs(zen_r-zen)
      if rzr<rz_r
        rz_r=rzr
        rc_r=recn()
      endif
      Continue
    enddo
    go rc_r
    zen_r=zen
    kvp_r=kvp
    repl fnd with 1
  Else
    // найдем совпадающию сумму
    inde on svp tag t1
    // dbseek(sm10r)
    locate for svp=sm10r
    if foun()
      // найдем мин разницу в ценах
      rz_r=1000
      rc_r=0
      do while svp=sm10r
        rzr=abs(zen_r-zen)
        if rzr<rz_r
          rz_r=rzr
          rc_r=recn()
        endif
        skip
      enddo
      if rc_r#0
          go rc_r
          zen_r := zen
          kvp_r := kvp
          //sm10r := svp
          repl fnd with 1
      endif
    else
      if gnArm=2 .or. gnArm=3
          dbseek(sm10r,.t.)
          wmess('Нет совпадений для S='+allt(str(sm10r));
          +' измените S д-та на '+allt(str(svp)),3)
      endif
    endif
  EndIf
  sele tmpsvp
  use
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  01-14-17 * 09:55:05pm
 НАЗНАЧЕНИЕ......... создали тбл Заданий
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION tzvk_crt(cTblNm)
  DEFAULT cTblNm TO 'tzvk'
  ///  создали тбл Заданий
  crtt(cTblNm,'f:dvp c:d(8) f:kpl c:n(7) f:kgp c:n(7) f:sk c:n(3) f:ttn c:n(6) f:dop c:d(8) f:sdv c:n(10,2) f:DtOpl c:d(8) f:nap c:n(4) f:ttn2 c:n(6) f:dop2 c:d(8) f:kom c:c(30)')
  sele 0
  use (cTblNm) Exclusive
  inde on str(kpl,7)+str(ttn,6) tag t1
  //  end  тбл Заданий
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  01-12-17 * 08:09:33pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ.......... plr - платель gpr - грузпол zTxtr - строка задания
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION tzvk_zTxt(plr,gpr,zTxtr,ttn2r,dop2r, dvpr)
  Local nLastSel:=SELECT(), i
  DEFAULT plr TO _FIELD->pl, gpr to _FIELD->gp, zTxtr TO zTxt,;
  dop2r TO STOD(""), dvpr TO date()

  zTxtr=alltrim(zTxtr)


  zTr='т=' // номер ТТН
  zSr='с=' // сумма забора
  zSsr='c=' // сумма забора
  zKr='к=' // коментарий
  zNr='н=' // направление

  if !empty(zTxtr).and.at(zTr,zTxtr)#0
    store '' to cTr,cSr,cKr,cNr
    store 0 to pTr,pSr,pKr,pNr
    for i=1 to len(zTxtr)
      do case
      case subs(zTxtr,i,2)=zTr

        sdvr=val(alltrim(cSr))
        komr=alltrim(cKr)
        Do While (nPos10:=AT('&#10;',komr),nPos10 # 0)
          komr:=LEFT(komr,nPos10-1)+SUBSTR(komr,nPos10+5)
        enddo
        napr=val(alltrim(cNr))
        ttnr=val(alltrim(cTr))
        if ttnr>999999
          komr := alltrim(komr) + ' T:' + alltrim(cTr)
          ttnr=999999
        endif

        if sdvr#0
          sele tzvk
          locate for kpl=plr.and.kgp=gpr.and.ttn=ttnr
          if !foun()
              appe blank
              repl kpl with plr,;
              kgp with gpr,;
              dvp with dvpr,;
              ttn with ttnr,;
              sdv with sdvr,;
              kom with komr,;
              nap with napr,;
              ttn2 with ttn2r,;
              dop2 with dop2r

          endif
        endif
        store '' to cTr,cSr,cKr,cNr
        store 0 to pTr,pSr,pKr,pNr
        i=i+1
        pTr=1
      case subs(zTxtr,i,2)=zSr.or.subs(zTxtr,i,2)=zSsr
        store 0 to pTr,pSr,pKr,pNr
        i=i+1
        pSr=1
      case subs(zTxtr,i,2)=zKr
        store 0 to pTr,pSr,pKr,pNr
        i=i+1
        pKr=1
      case subs(zTxtr,i,2)=zNr
        store 0 to pTr,pSr,pKr,pNr
        i=i+1
        pNr=1
      othe
        do case
        case pTr=1
          cTr=cTr+subs(zTxtr,i,1)
        case pSr=1
          cSr=cSr+subs(zTxtr,i,1)
        case pKr=1
          cKr=cKr+subs(zTxtr,i,1)
        case pNr=1
          cNr=cNr+subs(zTxtr,i,1)
        endcase
      endcase
    next

    sdvr=val(alltrim(cSr))
    komr=alltrim(ckr)
        Do While (nPos10:=AT('&#10;',komr),nPos10 # 0)
          komr:=LEFT(komr,nPos10-1)+SUBSTR(komr,nPos10+5)
        enddo
    napr=val(alltrim(cnr))
    ttnr=val(alltrim(ctr))
    if ttnr>999999
      komr := alltrim(komr) + ' T:' + alltrim(cTr)
      ttnr=999999
    endif

    sele tzvk
    locate for kpl=plr.and.kgp=gpr.and.ttn=ttnr
    if !foun()
      appe blank
      repl kpl with plr,;
            kgp with gpr,;
            dvp with dvpr,;
            ttn with ttnr,;
            sdv with sdvr,;
            kom with komr,;
            nap with napr,;
              ttn2 with ttn2r,;
              dop2 with dop2r
    endif
  endif

  If !empty(select('skdoc'))
    // заполнением Даты Оплаты
    sele tzvk
    DBGoTop()
    Do While !eof()
      sele skdoc
      dbseek(str(tzvk->kpl, 7))
      locate for ttn = tzvk->ttn while kpl = tzvk->kpl
      If found()
        sele tzvk
        repl DtOpl with skdoc->DtOpl
      EndIf

      sele tzvk
      DBSkip()
    EndDo
  else
    // wmess("!empty(select('skdoc'))")
  EndIf
   SELECT (nLastSel)
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  02-08-17 * 03:37:39pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION pathYYYYMM(dDate)
  RETURN ('g'+str(year(dDate),4);
  +'\m'+iif(month(dDate)<10,'0'+str(month(dDate),1),str(month(dDate),2)))


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  08-15-17 * 04:06:46pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ.......... nLenParam - сколько ожидать символов
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION kta_DosParam(cDosParam,cKeyParam,nLenParam)
  LOCAL nKta
  cKeyParam:=UPPER(cKeyParam)
  IF UPPER(cKeyParam) $ cDosParam
    nKta:=VAL(SUBSTR(cDosParam,AT(cKeyParam,cDosParam)+LEN(cKeyParam),nLenParam))
  ELSE
    nKta:=NIL
  ENDIF
  RETURN (nKta)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  09-28-17 * 09:34:05pm
 НАЗНАЧЕНИЕ......... полный адрес ТТ
 ПАРАМЕТРЫ.......... Pablic kgpr - заранее определена
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........   netuse('kln');  netuse('krn');  netuse('knasp')
 */
FUNCTION adr_full(cMem_kgpr)
  LOCAL cAdr, nRec:=RECNO()
  DEFAULT cMem_kgpr TO 'kgpr'

  netseek('t1', cMem_kgpr)

  cAdr := ''
  cAdr += ALLTRIM(kln->adr)
  cAdr += ', ' + ALLTRIM(getfield("t1","kln->knasp","knasp","nnasp"))
  // cAdr += ', ' + ALLTRIM(getfield("t1","kln->krn","krn","nrn")) + ' район'
  cAdr += ', ' + 'Сумская обл, Украина'
  DBGoTo(nRec)
  RETURN (cAdr)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  07-05-18 * 02:41:57pm
 НАЗНАЧЕНИЕ......... проверка на свертку д-тов
 139 177 129 - свернутые
 169 - свернутый, если цена 1коп
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION pr169rEQ2(ln_ttnr)
  LOCAL lRet
  LOCAL nSele:=SELECT()

  If pr169r=2.or.pr139r=2.or.pr129r=2.or.pr177r=2

    sele rs2
    set orde to tag t1
    netseek('t1','ttnr')
    locate for zen=0.01 while ttn = ttnr

    lRet:=FOUND()
    //lRet:=.T.
  Else
    lRet:=(pr139r=2.or.pr129r=2.or.pr177r=2)
  EndIf

  SELECT (nSele)
  RETURN (lRet)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-24-17 * 07:07:10pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION JsonDecode(cL)
  LOCAL oJson:=MAP()
  LOCAL nPos2, nPos1, cKey, xVal,cSep1a, cSep1, aElem, axVal
  // outlog(__FILE__,__LINE__,cL)
  cL := LEFT(cL,LEN(cL)-1)
  Do While .t.
    nPos2:=AT(':', cL)
    If nPos2 = 0
      exit
    EndIf

    //слева хеш
    nPos2:=RAT('"',SUBSTR(cL,1,nPos2))
    nPos1:=RAT('"',SUBSTR(cL,1,nPos2-1))

    cKey:=ALLTRIM(SUBSTR(cL,nPos1+1,(nPos2-nPos1)-1))
    // outlog(__FILE__,__LINE__, nPos1, nPos2,cKey, cL)
    // outlog(__FILE__,__LINE__, LEFT(cL,nPos2+1))

    // удалим ключ
    nPos2:=AT(':', cL)
    cL:=LTRIM(SUBSTR(cL,nPos2+1))
    // outlog(__FILE__,__LINE__, cL)



    // справа значение
    cSep1:=LEFT(cL,1)
    // outlog(__FILE__,__LINE__, cSep1,cL)
    nPos1:=1
    Do Case
    Case cSep1 = '{' // объект

      nPos2:= JsScanSkobClose(cL,'{','}')
      nPos2++
      xVal:=SUBSTR(cL,nPos1,nPos2-nPos1)

      xVal:=JsonDecode(xVal)

    Case cSep1 = '[' // массив !!! считается, ОДНИН элемнт
      // уберем скобки массива

      nPos2:= JsScanSkobClose(cL,'[',']')
      nPos2++
      xVal:=SUBSTR(cL,nPos1,nPos2-nPos1)
      // outlog(__FILE__,__LINE__,xVal)
      xVal:=LTRIM(SUBSTR(xVal,2))
      xVal:=LTRIM(SUBSTR(xVal,1,LEN(xVal)-1))
      // без []
        // outlog(__FILE__,__LINE__,xVal)

      xVal := JsonArray(xVal)
        // outlog(__FILE__,__LINE__,xVal)

    case cSep1 = '"' // строка
      nPos2:=0
      xVal:=JsonChr(cL,@nPos2)

    case LOWER(cSep1) $ 't f n' // строка true false null
      nPos2:=0
      xVal:=JsonBul(cSep1,@nPos2)

    otherwise  // число
      nPos2:=JsScanNumClose(cL)
      xVal:=VAL(SUBSTR(cL,nPos1,nPos2-nPos1))

    EndCase

    oJson[cKey]:=xVal

    // outlog(__FILE__,__LINE__, cSep1, nPos2,xVal)
    // удалим значение
    cL:=LTRIM(SUBSTR(cL,nPos2+1))
    // outlog(__FILE__,__LINE__, 'cL', cL)
    // outlog(__FILE__,__LINE__, 'LEN(cL)',LEN(cL))

    If EMPTY(LEN(cL))
      exit
    EndIf
  EndDo
  RETURN (oJson)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-24-17 * 10:32:10pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION JsonChr(cL,nPos2)
  LOCAL nPos1:=2
  nPos2:=JsScanKavychClose(cL,'"')
  cL:=SUBSTR(cL,nPos1,nPos2-nPos1)
  RETURN (cL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-24-17 * 05:17:58pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION JsScanSkobClose(cL, cSkodkaOpen,cSkodkaClose)
  LOCAL nLen := LEN(cL), i
  LOCAL nOpen:=0, cChr
  lColon:=.F.
  lDoubleQuotes:=.F.

  For i:=2 To nLen
    cChr:=SUBSTR(cL,i,1)
    Do Case

    case cChr = ':' // открыт разделител обък
      lColon:=.T.
      loop
    case lColon .and. cChr = ' ' // удал пробелы
      loop
    case lColon .and. cChr = '"' .and. !lDoubleQuotes
      // после разлителя окрывающию кавычку
      lDoubleQuotes:=.T.
      loop
    case lColon .and. lDoubleQuotes
      // есть разлител и кавычка
      If cChr = '"'
        // закрыли тк завершили
        lColon:=.F.
        lDoubleQuotes:=.F.
      EndIf
      loop
    Case cChr = cSkodkaOpen // '{'
        nOpen++
    Case cChr = cSkodkaClose // '}'
      If nOpen = 0
        exit
      Else
        nOpen--
      EndIf
    OtherWise

    EndCase
  Next i
  RETURN (i)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-24-17 * 06:29:05pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION JsScanKavychClose(cL,cSkodkaClose)
  LOCAL nLen := LEN(cL), i

  For i:=2 To nLen
    cChr:=SUBSTR(cL,i,1)
    Do Case
    Case cChr = '\'
      i++; loop
    Case cChr = cSkodkaClose
      exit
    EndCase
  Next i
  RETURN (i)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-24-17 * 06:47:56pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION JsScanNumClose(cL)
  LOCAL nLen := LEN(cL), i
  LOCAL cChr
  For i:=2 To nLen

    If !SUBSTR(cL,i,1)$'1234567890.-eE'
      exit
    EndIf

  Next i

  RETURN (i)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-25-17 * 00:58:22am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION JsonBul(cSep1,nPos2)
  LOCAL xVal
      Do Case
      Case LOWER(cSep1) = 't'
        nPos2:=4
        xVal:=.T.
      Case LOWER(cSep1) $ 'f'
        nPos2:=5
        xVal:=.F.
      Case LOWER(cSep1) $ 'n'
        nPos2:=4
        xVal:=NIL
      EndCase
  RETURN (xVal)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  09-21-17 * 04:12:23pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION JsonArray(cL)
  LOCAL nLen := LEN(cL), i
  LOCAL cChr
  LOCAL aElem:={}, axVal:={}, xVal
  LOCAL cSep1a, nPos1, nPos2

  ii:=0
  // разбор по элементам массива
  For i:=1 To nLen
    // outlog(__FILE__,__LINE__,i)

    cChr:=SUBSTR(cL,i,1)

    // элементы массива только объекты
    Do Case
    case cChr $ ' ,:' // след элемент
      loop
    case cChr = '"' // след элемент
      nPos1:=i
      nPos2:=JsScanKavychClose(SubStr(cL,nPos1),'"')

    Case cChr = '{'
      nPos1:=i
      nPos2:= JsScanSkobClose(SubStr(cL,nPos1),'{','}')
    Case cChr = '['
      nPos1:=i
      nPos2:= JsScanSkobClose(SubStr(cL,nPos1),'[',']')
    case LOWER(cChr) $ 't f n' // строка true false null
      nPos1:=i
      nPos2:=0
      JsonBul(cChr,@nPos2)
    OtherWise
      nPos1:=i
      nPos2:=JsScanNumClose(SubStr(cL,nPos1))
    EndCase

    nPos2 := nPos2 + nPos1 - 1
    xVal:=SUBSTR(cL,nPos1,(nPos2-nPos1)+1)


    AADD(aElem,xVal)
    i:=nPos2
       // outlog(__FILE__,__LINE__,xVal,i)
  Next

  // просчитаем каждый э-т массива
  FOR i:=1 TO LEN(aElem)
    nPos1:=1
    xVal := aElem[i]
    cSep1a := LEFT(xVal,1)
    DO CASE
    case cSep1a $ 't f n' // строка true false null
      nPos2:=0
      xVal:=JsonBul(cSep1a,@nPos2)
    CASE cSep1a = '"'
      nPos2:=0
      xVal:=JsonChr(xVal,@nPos2)   // заменил xVal:=JsonChr(xVal) 10-27-17 04:24pm
    CASE cSep1a = '{'
      nPos2:= JsScanSkobClose(xVal,'{','}')
      nPos2++
      xVal:=SUBSTR(xVal,nPos1,nPos2-nPos1)

      //outlog(__FILE__,__LINE__,xVal)
      xVal:=JsonDecode(xVal)
      //outlog(__FILE__,__LINE__,xVal)
    OTHERWISE
      nPos2:=JsScanNumClose(xVal)
      xVal:=VAL(SUBSTR(xVal,nPos1,nPos2-nPos1))

    ENDCASE
    AADD(axVal,xVal)
  NEXT
  RETURN (axVal)

FUNCTION URLEncode(s)
  LOCAL I := 1
  LOCAL ch
  LOCAL ret := ""
  LOCAL len := LEN(s)

  FOR I:=1 TO len
    ch := SUBSTR(s,I,1)
    IF ch == " "
            ret += "+"
    ELSEIF ASC(ch) > 32 .AND. ASC(ch) < 127
            ret += ch
    ELSE
            ret += "%"+NTOC(ASC(ch),16)
    ENDIF
  NEXT
RETURN ret


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  09-29-17 * 05:23:55pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION UrlParamEncode(cL)
  If left(cL,1) = '"' // символьный
    cL := translate_charset(host_charset(),'utf-8', cL)

    cL := URLEncode(cL)
  Else // числовой

  EndIf
  RETURN (cL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  10-23-17 * 10:26:00am
 НАЗНАЧЕНИЕ......... вычисление дистанци по прямой
 ПАРАМЕТРЫ.......... lat1, long1, lat2, long2 - числа
 ВОЗВР. ЗНАЧЕНИЕ.... число
 ПРИМЕЧАНИЯ.........
 */
function LatLng2Distance(lat1, long1, lat2, long2)
  LOCAL R
  LOCAL cl1, cl2, sl1,  sl2, delta, cdelta,  sdelta
  LOCAL y ,  x,  ad,  dist

  //радиус Земли
  R := 6372795
  //перевод коордитат в радианы
  lat1 *= pi() / 180
  lat2 *= pi() / 180
  long1 *= pi() / 180
  long2 *= pi() / 180
  //вычисление косинусов и синусов широт и разницы долгот
  cl1    := cos(lat1)
  cl2    := cos(lat2)
  sl1    := sin(lat1)
  sl2    := sin(lat2)
  delta  := long2 - long1
  cdelta := cos(delta)
  sdelta := sin(delta)
  //вычисления длины большого круга
  y := sqrt((cl2 * sdelta)^2 + (cl1 * sl2 - sl1 * cl2 * cdelta)^2)
  x := sl1 * sl2 + cl1 * cl2 * cdelta
  ad := atan(y/x)
  //расстояние между двумя координатами в метрах
  dist := ad * R
  return dist

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  10-15-17 * 12:31:07pm
      https://ru.wikipedia.org/wiki/K-means%2B%2B
 НАЗНАЧЕНИЕ......... выбор центронов
 ПАРАМЕТРЫ.......... массив к-т, и сколько центонов выбрать
 структура массива { cName,{к-та_X,к-та_X} }
 ВОЗВР. ЗНАЧЕНИЕ.... к-ты центронов
 ПРИМЕЧАНИЯ.........
 */
FUNCTION CenterSeek(aCrd, nCntCenter, lGpsDist)
  LOCAL aDist, i, m, aC
  LOCAL nSumDist, nSumRnd, nLen_aCrd
  LOCAL aCenter,  nCenter, nRand

  DEFAULT nCntCenter TO 2, aCrd TO {{'A',{-2,0}},{'B',{-2,-1}},{'C',{-3,0}},{'D',{4,0}},{'E',{3,0}},{'F',{0,0}}}
  DEFAULT  lGpsDist TO .f.

  aCenter:={}
  nLen_aCrd :=len(aCrd)

  nRand:=rand(seconds())
  nRand:=rand()
  nCenter:=round(nRand * nLen_aCrd,0)
  If EMPTY(nCenter)
    nCenter:=1
  EndIf
  m:=0

  Do While Len(aCenter) < nCntCenter
    // р-ни меж точками
    aDist:={}
    For i:=1 To nLen_aCrd
      If i == nCenter
       nDist:=0
      else
        If lGpsDist
          nDist:=(LatLng2Distance(aCrd[nCenter][2,1],aCrd[nCenter][2,2],aCrd[i][2,1],aCrd[i][2,2]))^2
        Else
          nDist:=(XY2distance(aCrd[nCenter][2,1],aCrd[nCenter][2,2],aCrd[i][2,1],aCrd[i][2,2]))^2
        EndIf
      EndIf
      AADD(aDist,nDist)
    Next

    // сумма р-ний
    nSumDist:=0
    AEval(aDist,{|nD| nSumDist += nD })
    // сучайная сумма из интервала
    nRand:=rand()
    nSumRnd:=nRand * nSumDist

    // поиск суммы пока не привысят nSumDist > nSumRnd
    nSumDist:=0
    For i:=1 To nLen_aCrd
      nSumDist += aDist[i]
      If nSumDist > nSumRnd // сумма больше
        nCenter:=i
        aC:=ACLONE(aCrd[i])
        If Len(aCenter)=0
          Aadd(aCenter,aC)
        Else
          If EMPTY(ASCAN(aCenter,{|aElem| aElem[1,1] = aCrd[i][1] }))
            Aadd(aCenter,aC)
          EndIf
        EndIf

        exit
      EndIf
    Next

    If m++ > 150
      exit
    EndIf
  EndDo

  RETURN (aCenter)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  10-15-17 * 01:01:07pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION XY2distance(x1,y1,x2,y2)
  //RETURN (SQRT((x1-x2)^2 + (y1-y2)^2))
  RETURN (SQRT((x1-x2)*(x1+x2) + (y1-y2)*(y1+y2)))



/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  10-17-17 * 12:03:46pm
 https://axd.semestr.ru/upr/k-means.php
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ.......... aCrdOrig - массив к-т точек
                     aCenter  - массив к-т центнронов
 структура массива { cName,{к-та_X,к-та_X} }
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION kmeans(aCrdOrig,aCenter,lGpsDist)
  LOCAL nLenCenter, nLen_aCrd
  LOCAL aCrdBeg, aCrdEnd, aCrd
  LOCAL aCntrBeg, aCntrEnd
  LOCAL i, nKoef
  LOCAL nMinD, x1,y1,x2,y2, nXY2D, nMinDInd

  //outlog(__FILE__,__LINE__,aCenter)
  DEFAULT  aCrdOrig TO {{'A',{-2,0}},{'B',{-2,-1}},{'C',{-3,0}},{'D',{4,0}},{'E',{3,0}},{'F',{0,0}}},;
           aCenter TO {ACLONE(aCrdOrig[1]),ACLONE(aCrdOrig[2]),ACLONE(aCrdOrig[3])}
  DEFAULT lGpsDist TO .F.
  //outlog(__FILE__,__LINE__,aCenter)

  nLenCenter:=LEN(aCenter)
  nLen_aCrd:=Len(aCrdOrig)

  aCntrBeg:=Aclone(aCenter)
  aCntrEnd:=Aclone(aCenter)


  aCrdBeg:={}
  aCrdEnd:={}
  For i:=1 To nLenCenter
    AAdd(aCrdBeg,{})
    AAdd(aCrdEnd,{})
  Next
  // раскидуем т-ки в группы цетронов для сравения
  c:=1
  For i:=1 To nLen_aCrd
    AADD(aCrdBeg[c],aCrdOrig[i])
    If ++c > nLenCenter
      c:=1
    EndIf
  Next
  // outlog(__FILE__,__LINE__,aCrdBeg)

  // перестроим массив к-т, чтобы центрные были последними
  aCrd := {}
  /*
  For i:=1 To nLen_aCrd
      Aadd(aCrd,aCrdOrig[i])
  Next
  */
  For i:=1 To nLen_aCrd
    // центроны пропустим
    If EMPTY(ASCAN(aCenter,{|aElem| aElem[1,1] = aCrdOrig[i][1] }))
      Aadd(aCrd,aclone(aCrdOrig[i]))
    EndIf
  Next
  // добавим центроны
  For i:=1 To nLenCenter
    AAdd(aCrd,aclone(aCenter[i]))
  Next

  // outlog(__FILE__,__LINE__,aCrd)
  Do While .t.
    ////////////////
    For i:=1 To nLen_aCrd
       outlog(__FILE__,__LINE__,aCrd[i][1])

      x1:=aCrd[i][2,1]
      y1:=aCrd[i][2,2]
      nMinD:=99999999999
      nMinDInd:=1
      // минимально растояние между точкой и центронами
      For k:=1 To nLenCenter
        x2:=aCntrEnd[k][2,1]
        y2:=aCntrEnd[k][2,2]

        if lGpsDist
          nXY2D:=LatLng2Distance(x1,y1,x2,y2)
        else
          nXY2D:=XY2distance(x1,y1,x2,y2)
        endif
         outlog(__FILE__,__LINE__,'  dist,x1,y1,x2,y2',nXY2D,x1,y1,x2,y2)

        If nXY2D < nMinD
          nMinD := nXY2D
          nMinDInd:=k
        EndIf
      Next k
        outlog(__FILE__,__LINE__,'  min-nXY2D',nXY2D,nMinDInd)
      // пересчет к-т эталона центрона
      //outlog(__FILE__,__LINE__,x1, aCenter[nMinDInd][2,1])
      //outlog(__FILE__,__LINE__,y1, aCenter[nMinDInd][2,2])
      nKoef:=1 //10^7
      x2 := ROUND((x1*nKoef + aCntrEnd[nMinDInd][2,1]*nKoef) / 2,7)
      y2 := ROUND((y1*nKoef + aCntrEnd[nMinDInd][2,2]*nKoef) / 2,7)
      // outlog(__FILE__,__LINE__,' o',aCenter[nMinDInd][2,1], aCenter[nMinDInd][2,2])
      //outlog(__FILE__,__LINE__,' n',nMinDInd,x2,y2)
      // запомним новые к-т
      aCntrEnd[nMinDInd][2,1] := ROUND(x2/nKoef,7)
      aCntrEnd[nMinDInd][2,2] := ROUND(y2/nKoef,7)
      // outlog(__FILE__,__LINE__,aCenter)
    Next i

    //оценка точек
    aCrdEnd:={}
    For i:=1 To nLenCenter
      AAdd(aCrdEnd,{})
    Next
    For i:=1 To nLen_aCrd
      x1:=aCrd[i][2,1]
      y1:=aCrd[i][2,2]

      // минимально растояние между точкой и центонами
      nMinD:=99999999999
      nMinDInd:=1
      For k:=1 To nLenCenter
        x2:=aCntrEnd[k][2,1]
        y2:=aCntrEnd[k][2,2]

        if lGpsDist
          nXY2D:=LatLng2Distance(x1,y1,x2,y2)
        else
          nXY2D:=XY2distance(x1,y1,x2,y2)
        endif
        // outlog(__FILE__,__LINE__,'nXY2Dx1,y1,x2,y2',x1,y1,x2,y2)
        // outlog(__FILE__,__LINE__,'nXY2D',nXY2D)

        If nXY2D < nMinD
          nMinD := nXY2D
          nMinDInd:=k
        EndIf
      Next k
        // outlog(__FILE__,__LINE__,' min nXY2D',nXY2D,nMinDInd)
      AADD(aCrdEnd[nMinDInd],aCrd[i])
    Next i
    //outlog(__FILE__,__LINE__,aCrdEnd)

    If CompArray(aCrdBeg, aCrdEnd)
      exit
    else
      if lGpsDist .and. len(aCntrEnd) = 2
        If CompArray(aCntrBeg[1,2], aCntrEnd[2,2])
          outlog(__FILE__,__LINE__,'выход по циклиности простчета')
          exit
        EndIf
      endif
    EndIf

    aCrdBeg := AClone(aCrdEnd)
    aCntrBeg := AClone(aCntrEnd)
  enddo
  aCenter := AClone(aCntrEnd)
  aCrdBeg :={}
  aCntrBeg := {}
  aCntrEnd := {}
  RETURN (aCrdEnd)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  09-29-17 * 04:26:07pm
 НАЗНАЧЕНИЕ......... прямой запрос googleapis чз wget
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION  GMA_Dist(cOrigins,cDestinations)
  LOCAL cSysCmd, cLogSysCmd, cErrSysCmd
  LOCAL cUrlWGet, nHandle
  LOCAL cFile_wget, cFile_json

  cFile_wget:='_distmatr.wget'
  cFile_json:='_distmatr.json'

  cOrigins := translate_charset(host_charset(),'utf-8',cOrigins)

  cDestinations := translate_charset(host_charset(),'utf-8', cDestinations)

  cUrlWget:='http://maps.googleapis.com/maps/api/distancematrix/json?';
          +'origins=' + cOrigins;
          +'&destinations='+ cDestinations

  nHandle:=fcreate(cFile_wget)
    fwrite(nHandle,cUrlWGet)
  fclose(nHandle)


  cErrSysCmd := cLogSysCmd := cSysCmd := ""
  cSysCmd := "wget ";
          +'-O ' +  cFile_json + ' ' ;
          +'-i ' +  cFile_wget

  SYSCMD(cSysCmd,"" ,@cLogSysCmd,@cErrSysCmd)

  // outlog(__FILE__,__LINE__,cSysCmd)
  // outlog(__FILE__,__LINE__,cErrSysCmd)
  // outlog(__FILE__,__LINE__,cLogSysCmd)

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-25-17 * 12:01:43pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION GMA_DistMatr(cOrigins,cDestinations)
  LOCAL cSysCmd, cLogSysCmd, cErrSysCmd
  LOCAL cL, oD, cUrl, cUrlWGet, nHandle
  LOCAL cFile_wget, cFile_json

  // GMA_Dist(cOrigins,cDestinations)  - работает

  cFile_wget:='_distmatr.wget'
  cFile_json:='_distmatr.json'

  cOrigins := UrlParamEncode(cOrigins)
  cDestinations := UrlParamEncode(cDestinations)

  cUrl:='http://maps.googleapis.com/maps/api/distancematrix/json?';
          +'origins=' + cOrigins;
          +'&destinations='+ cDestinations


  //outlog(__FILE__,__LINE__,cUrl)
  //cUrl:=StrTran(cUrl," ",'%'+'20')
  //outlog(__FILE__,__LINE__,cUrl)


  // кодируем base64
  cUrl:=base64encode(cUrl)
  cUrl:=CharRem(CHR(10),cUrl)

  cUrlWGet:='http://10.0.1.113/wget-https.php?url='+cUrl

  //outlog(__FILE__,__LINE__,cUrl)
  //outlog(__FILE__,__LINE__,cUrlWGet)

  nHandle:=fcreate(cFile_wget)
    fwrite(nHandle,cUrlWGet)
  fclose(nHandle)


  // 50.916988,34.7920503,50.8976135,34.7871896
  cErrSysCmd := cLogSysCmd := cSysCmd := ""

  cSysCmd += "wget ";
          +'-O ' +  cFile_json + ' ' ; // '- ' ; //
          +'-i ' +  cFile_wget

  SYSCMD(cSysCmd,"" ,@cLogSysCmd,@cErrSysCmd)

  //OUTLOG(__FILE__,__LINE__,cSysCmd)
  //OUTLOG(__FILE__,__LINE__,cErrSysCmd)
  //OUTLOG(__FILE__,__LINE__,cLogSysCmd)

  //quit
   cL := memoread(cFile_json) // alltrim(cErrSysCmd) //
   cL := CHARREM(CHR(10),cL)

   oD:=JsonDecode(cL)
   /*
   outlog(__FILE__,__LINE__,oD)
   outlog(__FILE__,__LINE__,oD['rows'])
   outlog(__FILE__,__LINE__,oD['rows'][1])
   outlog(__FILE__,__LINE__,oD['rows'][1]['elements'])
   outlog(__FILE__,__LINE__,oD['rows'][1]['elements'][1])

   outlog(__FILE__,__LINE__,oD['rows'][1]['elements'][1]['distance']['value'])
   */
  RETURN (oD['rows'][1]['elements'][1]['distance']['value'])

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  04-13-12 * 09:05:14am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........  aFile первый э-т имя файла отправки
                            второй э-т тема
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION SendingJafa(cSmtpTo,aFile,cPath,l_skr)
  LOCAL cSmtpServ, cSmtpFrom //, cSmtpTo
  LOCAL oSmtp
  LOCAL cFileNameArc, dDt, lError, i, cSendMess

  lError:=NO

  dDt:=DATE()
    cSmtpServ:="10.0.1.113"
    cSmtpFrom:="saha@sumyprodresurs.sumy.ua"     // for kbmxas.bbhua.com

  IF UPPER("/support") $ UPPER(DosParam())
    DEFAULT cSmtpTo TO "lista@bk.ru"
  ELSE
    //cSmtpTo:="distrsales@vitmark.com"
  ENDIF


  cFileNameArc:=cPath+"\"+aFile[1,1]


  set print to clvrt.log ADDI
  qout(cFileNameArc,filesize(cFileNameArc),;
  cSmtpFrom, gcUname, gcNNETNAME)

  oSmtp:=smtp():new(cSmtpServ)
  //oSmtp:EOL := "&\r&\n"
  //oSmtp:lf := CHR(13)+CHR(10)
  oSmtp:timeout := 6000*10 //6000 - default
  oSmtp:port:=25
  #ifdef __CLIP__
  IF MySmtpConnect(@oSmtp) // oSmtp:connect()

    IF oSmtp:Hello(SUBSTR(cSmtpFrom,AT("@",cSmtpFrom)+1))
      IF oSmtp:addField("Subject",aFile[1,2])
          //? oSmtp:error,"oSmtp:addField"
        lOk:=YES

          If !Empty(aFile[1,1])
            IF oSmtp:attach(cFileNameArc)
              //
            ELSE
              lOk:=NO
            ENDIF
          EndIf

          IF lOk //все приатачили
            //? oSmtp:error,"oSmtp:attach"
            lOk:=YES

            set print to clvrt.log ADDI
            qout(DATE(),TIME())

            aSmtpTo:=split(cSmtpTo,",")

            FOR i:=1 TO LEN(aSmtpTo)

              cSmtpTo:=aSmtpTo[i]

              // IF oSmtp:send(cSmtpFrom,cSmtpTo,"do not respond "+LF+"body of letter "+cFileNameArc)
              cSendMess := ""
              If !Empty(aFile[1,1]) // файл на отрпаку
                cSendMess += "Do not respond! "+''+"Body of letter "
              EndIf
              cSendMess += cFileNameArc

              IF oSmtp:send(cSmtpFrom,cSmtpTo,cSendMess)
                //
              ELSE
                lOk:=NO
              ENDIF

              IF lOk
                 set print to clvrt.log ADDI
                 qout("==oSmtp:send() OK!====",cSmtpTo)
                 //qout(cFileNameArc,"===============oSmtp:send() OK!=========",cSmtpFrom,cSmtpTo)
                 //outlog("===============oSmtp:send() OK!=========",cSmtpFrom,cSmtpTo)
                 //qout("oSmtp:send() OK!")
              ELSE
                #ifdef __CLIP__
                   outlog("Error ",cFileNameArc,"oSmtp:send()",oSmtp:error)
                   //outlog(oSmtp)
                #endif
                lError:=TRUE
              ENDIF

            NEXT i
            oSmtp:close()

          ELSE
             #ifdef __CLIP__
                outlog("Error ","oSmtp:attach()",oSmtp:error)
             #endif
              lError:=TRUE
          ENDIF
        ELSE
        #ifdef __CLIP__
           outlog("Error ","oSmtp:addField()",oSmtp:error)
        #endif
            lError:=TRUE
      ENDIF
    ELSE
      #ifdef __CLIP__
         outlog("Error ","oSmtp:Hello()",oSmtp:error)
      #endif
            lError:=TRUE
    ENDIF
  ELSE
    #ifdef __CLIP__
       outlog("Error ","oSmtp:connect()",cSmtpServ,oSmtp:port,oSmtp:error)
    #endif
          lError:=TRUE
  ENDIF
  #endif
  IF !EMPTY(lError)
    //oSmtp:reset()
    oSmtp:close()
  ENDIF

  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  11-11-18 * 09:09:09am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION PathTtnUc(Ttn_r,cCskl_path,Dtr,Kopr,gcPath_ew)

  LOCAL PathYYMMr:='g'+str(year(dtr), 4)+'\m'+iif(month(dtr)<10, '0'+str(month(dtr), 1), str(month(dtr), 2))+'\'
  LOCAL cPath
  cPath:=gcPath_ew // диск и назв лат. предприятия

  // анализ КОП8
  cPath += (Iif(Kopr = 151,'ttnlist', 'ttn'+str(Kopr,3)) +'\')
  // каталог Даты периода
  cPath += PathYYMMr
  // путь Склад
  cPath += allt(cCskl_path)
  // номер ТТН
  cPath += 't'+alltrim(str(ttn_r, 6))+'\'

  RETURN (cPath)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  02-12-20 * 10:47:58pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION OnGrpE4NotFullName()
  RETURN ( (gnEnt=20.and.(str(kg_r,3) $ '507'));
  .or. (gnEnt=20.and.(str(kg_r,3) $ '342;343;338;339')))
