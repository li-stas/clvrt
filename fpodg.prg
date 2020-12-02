local gg,mm
store 0 to gg,mm
if gnArm#25
   dt1r=bom(addmonth(gdTd,-6)) 
   dt2r=gdTd 
   prfpodgbr=1
   prfpodgsr=1
   przamr=0
endif
period1r=year(dt1r)*100+month(dt1r)
period2r=year(dt2r)*100+month(dt2r)
pathr=''

store '' to strpr,strdkr,strbr
netuse('anskbs')
locate for an=0.and.anvd=0
if foun()
   uslr=alltrim(usl)
   aaa=''
   if !empty(uslr)
      n=0
      for i=1 to len(uslr)+1 
          if subs(uslr,i,1)=','.or.i=len(uslr)+1 
             if len(aaa)=3
                if n=0
                   strpr=strpr+'int(ddbr/1000)='+aaa+'.or.int(dkrr/1000)='+aaa
                   strdkr=strdkr+'int(ddbr/1000)='+aaa
                   n=1
                else
                   strpr=strpr+'.or.int(ddbr/1000)='+aaa+'.or.int(dkrr/1000)='+aaa
                   strdkr=strdkr+'.or.int(ddbr/1000)='+aaa
                endif   
	             else
                if n=0
                   strpr=strpr+'ddbr='+aaa+'.or.dkrr='+aaa
                   strdkr=strdkr+'ddbr='+aaa
                   n=1
                else
                   strpr=strpr+'.or.ddbr='+aaa+'.or.dkrr='+aaa
                   strdkr=strdkr+'.or.ddbr='+aaa
                endif   
             endif
             aaa=''
          else
             aaa=aaa+subs(uslr,i,1)   
          endif
      next
   endif
endif
strbr=strtran(strpr,'ddbr','bs_dr')
strbr=strtran(strbr,'dkrr','bs_kr')

store '' to strbdr
locate for an=0.and.anvd=1
if foun()
   uslr=alltrim(usl)
   aaa=''
   if !empty(uslr)
      n=0
      for i=1 to len(uslr)+1 
          if subs(uslr,i,1)=','.or.i=len(uslr)+1 
             if len(aaa)=3
                if n=0
                   strbdr=strbdr+'int(bs_dr/1000)='+aaa+'.or.int(bs_kr/1000)='+aaa
                   n=1
                else
                   strbdr=strbdr+'.or.int(bs_dr/1000)='+aaa+'.or.int(bs_kr/1000)='+aaa
                endif   
             else
                if n=0
                   strbdr=strbdr+'bs_dr='+aaa+'.or.bs_kr='+aaa
                   n=1
                else
                   strbdr=strbdr+'.or.bs_dr='+aaa+'.or.bs_kr='+aaa
                endif   
             endif
             aaa=''
          else
             aaa=aaa+subs(uslr,i,1)   
          endif
      next
   endif
endif

gg1r=year(dt1r)
gg2r=year(dt2r)

netuse('anskbs')
netuse('st1sb')
netuse('mkeepe')
netuse('ctov')
netuse('cgrp')
netuse('cskl')

if prfpodgbr=1
   fpodgb()
endif
if prfpodgsr=1   
   fpodgs()
endif   
doit()

func fpodgb()
if przamr=0
   erase (gcPath_an+'andkkln.dbf')
   erase (gcPath_an+'andkkln.cdx')
   erase (gcPath_an+'andokk.dbf')
   erase (gcPath_an+'andokk.cdx')
   copy file (gcPath_a+'andokk.dbf') to (gcPath_an+'andokk.dbf')
endif
sele 0
use (gcPath_an+'andokk') excl
if przamr=1
   dele all for period>=period1r.and.period<=period2r
   pack
endif
inde on str(mn,6)+str(sk,3)+str(mnp,6)+str(rn,6)+str(kkl,7) tag t1
inde on str(period,6)+str(mn,6)+str(sk,3)+str(mnp,6)+str(rn,6)+str(kkl,7) tag t2
set orde to tag t2
if przamr=0
   copy to tstrub exte
   sele 0
   use tstrub excl
   zap
   appe blank
   repl field_name with 'KKL',;
        field_type with 'N',;
        field_len with 7,;
        field_dec with 0
   appe blank
   repl field_name with 'BS',;
        field_type with 'N',;
        field_len with 6,;
        field_dec with 0
     
   for gg=gg1r to gg2r
       do case
          case gg1r=gg2r
               mm1r=month(dt1r)
               mm2r=month(dt2r)
          case gg=gg1r
               mm1r=month(dt1r)
               mm2r=12
          case gg=gg2r
               mm1r=1
               mm2r=month(dt2r)
       endc
       for mm=mm1r to mm2r
           sele tstrub
           appe blank
           repl field_name with 'DN'+str(gg,4)+iif(mm<10,'0'+str(mm,1),str(mm,2)),;
                field_type with 'N',;
                field_len with 15,;
                field_dec with 2
           appe blank
           repl field_name with 'KN'+str(gg,4)+iif(mm<10,'0'+str(mm,1),str(mm,2)),;
                field_type with 'N',;
                field_len with 15,;
                field_dec with 2
           appe blank
           repl field_name with 'DB'+str(gg,4)+iif(mm<10,'0'+str(mm,1),str(mm,2)),;
                field_type with 'N',;
                field_len with 15,;
                field_dec with 2
           appe blank
           repl field_name with 'KR'+str(gg,4)+iif(mm<10,'0'+str(mm,1),str(mm,2)),;
                field_type with 'N',;
                field_len with 15,;
                field_dec with 2
           appe blank
           repl field_name with 'DDB'+str(gg,4)+iif(mm<10,'0'+str(mm,1),str(mm,2)),;
                field_type with 'D',;
                field_len with 8,;
                field_dec with 0
           appe blank
           repl field_name with 'DKR'+str(gg,4)+iif(mm<10,'0'+str(mm,1),str(mm,2)),;
                field_type with 'D',;
                field_len with 8,;
                field_dec with 0
       next
   next
   sele tstrub
   use
   crea (gcPath_an+'andkkln') from tstrub 
   use
endif
sele 0
use (gcPath_an+'andkkln') excl
inde on str(kkl,7)+str(bs,6) tag t1
retu .t.

func fpodgs()
if przamr=0
   erase (gcPath_an+'anost.dbf')
   erase (gcPath_an+'anost.cdx')
   erase (gcPath_an+'andoc.dbf')
   erase (gcPath_an+'andoc.cdx')
   erase (gcPath_an+'andocz.dbf')
   erase (gcPath_an+'andocz.cdx')
   copy file (gcPath_a+'andoc.dbf') to (gcPath_an+'andoc.dbf')
endif
sele 0
use (gcPath_an+'andoc') excl
if przamr=1
   dele all for period>=period1r.and.period<=period2r
   pack
endif
inde on str(sk,3)+str(doc,6)+str(mdoc,6)+str(ktl,9)+str(ktlt,9) tag t1
inde on str(period,6)+str(sk,3)+str(doc,6)+str(mdoc,6)+str(ktl,9)+str(ktlt,9) tag t2
inde on str(sk,3)+str(ktl,9) tag t3
set orde to tag t1
if przamr=0
   copy file (gcPath_a+'andocz.dbf') to (gcPath_an+'andocz.dbf')
endif
sele 0
use (gcPath_an+'andocz') excl
if przamr=1
   dele all for period>=period1r.and.period<=period2r
   pack
endif
inde on str(sk,3)+str(doc,6)+str(mdoc,6) tag t1
inde on str(period,6)+str(sk,3)+str(doc,6)+str(mdoc,6) tag t2
inde on str(kta,3)+str(nkkl,7)+str(kpv,7) tag t3
inde on str(kta,3)+str(kkl,7)+str(kgp,7) tag t4
set orde to tag t1
if przamr=0
   sele 0
   use (gcPath_a+'anost.dbf')
   copy stru to tstruo exte
   use
   sele 0
   use tstruo
   
   for gg=gg1r to gg2r
       do case
          case gg1r=gg2r
               mm1r=month(dt1r)
               mm2r=month(dt2r)
          case gg=gg1r
               mm1r=month(dt1r)
               mm2r=12
          case gg=gg2r
               mm1r=1
               mm2r=month(dt2r)
       endc
       for mm=mm1r to mm2r
           sele tstruo
           appe blank
           repl field_name with 'N'+str(gg,4)+iif(mm<10,'0'+str(mm,1),str(mm,2)),;
                field_type with 'N',;
                field_len with 15,;
                field_dec with 3
           appe blank
           repl field_name with 'F'+str(gg,4)+iif(mm<10,'0'+str(mm,1),str(mm,2)),;
                field_type with 'N',;
                field_len with 15,;
                field_dec with 3
           appe blank
           repl field_name with 'V'+str(gg,4)+iif(mm<10,'0'+str(mm,1),str(mm,2)),;
                field_type with 'N',;
                field_len with 10,;
                field_dec with 3
           appe blank
           repl field_name with 'MI'+str(gg,4)+iif(mm<10,'0'+str(mm,1),str(mm,2)),;
                field_type with 'N',;
                field_len with 10,;
                field_dec with 3
       next
   next
   sele tstruo
   use
   crea (gcPath_an+'anost') from tstruo 
   use
endif
sele 0
use (gcPath_an+'anost') excl
inde on str(sk,3)+str(ktl,9) tag t1
retu .t.

func doit()
for gg=year(dt1r) to year(dt2r) 
    do case
       case year(dt1r)=year(dt2r) 
            mm1r=month(dt1r)
            mm2r=month(dt2r)
       case gg=year(dt1r).and.gg#year(dt2r) 
            mm1r=month(dt1r)
            mm2r=12
       case gg=year(dt2r).and.gg#year(dt1r) 
            mm1r=1
            mm2r=month(dt2r)
       othe
            mm1r=1     
            mm2r=12     
    endc
    for mm=mm1r to mm2r 
        periodr=gg*100+mm
        do while .t.
           fdnr='dn'+str(periodr,6)
           fknr='kn'+str(periodr,6)
           fdbr='db'+str(periodr,6)
           fkrr='kr'+str(periodr,6)
           fddbr='ddb'+str(periodr,6)
           fdkrr='dkr'+str(periodr,6)
           if przamr=1
              if !(periodr>=period1r.and.periodr<=period2r)
                 exit
              else 
                 sele andkkln
                 if fieldpos(fdnr)#0  
                    repl all &fdnr with 0,;
                         &fknr with 0,;    
                         &fdbr with 0,;
                         &fkrr with 0,;    
                         &fddbr with ctod(''),;
                         &fdkrr with ctod('')    
                 else
                    exit
                 endif  
              endif    
           endif
           pathr=gcPath_e+'g'+str(gg,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\bank\'
           if !netfile('dkkln',1)
              exit  
           endif     
           if gnArm=25  
              ?pathr   
           endif
           netuse('dkkln',,,1)
           sele dkkln
           do while !eof()
              kklr=kkl
              bsr=bs
              sele dkkln
              dnr=dn
              knr=kn
              dbr=db
              krr=kr
              ddbr=ddb
              dkrr=dkr
              sele andkkln
              seek str(kklr,7)+str(bsr,6) 
              if !foun()
                 appe blank  
                 repl kkl with kklr,;
                      bs with bsr     
              endif 
              repl &fdnr with dnr,;
                   &fknr with knr,;    
                   &fdbr with dbr,;
                   &fkrr with krr,;    
                   &fddbr with ddbr,;
                   &fdkrr with dkrr    
              sele dkkln
              skip 
           endd       
           nuse('dkkln') 
           nuse('dknap') 
           netuse('doks',,,1)
           netuse('dokk',,,1)
           copy stru to (gcPath_l+'\stdokk') exte
           sele 0
           use stdokk 
           appe blank
           repl field_name with 'PERIOD',;
                field_type with 'N',;
                field_len with 6,;
                field_dec with 0
           appe blank
           repl field_name with 'OSN',;
                field_type with 'C',;
                field_len with 20,;
                field_dec with 0
           appe blank
           repl field_name with 'BOSN',;
                field_type with 'C',;
                field_len with 100,;
                field_dec with 0
           use
           sele 0
           create tdokk from stdokk     
           erase stdokk.dbf
           sele dokk
           do while !eof()
              if prc
                 skip
                 loop
              endif
              bs_dr=bs_d
              bs_kr=bs_k
              if !&strbr
                 sele dokk
                 skip
                 loop
              endif
              if !&strbdr
                 sele dokk
                 skip
                 loop
              endif
              sele dokk
              mnr=mn
              rndr=rnd
              kklr=kkl
              sele doks
              if netseek('t1','mnr,rndr,kklr')
                 osnr=osn
                 if fieldpos('bosn')#0 
                    bosnr=bosn
                 else
                    bosnr=''
                 endif 
              else
                 osnr=''
                 bosnr=''
              endif
              arec:={}
              sele dokk
              getrec()
              sele tdokk
              netadd()
              putrec()   
              netrepl('period,osn,bosn','periodr,osnr,bosnr')
              sele dokk
              skip
           endd
           nuse('doks') 
           nuse('dokk') 
           nuse('tdokk')
           sele andokk
           appe from tdokk
           erase tdokk.dbf
           exit
        endd
        do while .t.
           fldvr='V'+str(periodr,6)
           fldmr='MI'+str(periodr,6)
           fldnr='N'+str(periodr,6)
           fldfr='F'+str(periodr,6)
           if prfpodgsr=0
              exit   
           endif  
           if przamr=1
              if !(periodr>=period1r.and.periodr<=period2r)
                 exit
              endif 
              sele anost
              if fieldpos(fldvr)#0
                 repl all &fldvr with 0,;
                          &fldmr with 0,;
                          &fldnr with 0,;
                          &fldfr with 0
              else 
                 exit
              endif
           endif  
           pathr=gcPath_e+'g'+str(gg,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'
           netuse('cmrsh',,,1)  
           set orde to tag t2
           sele cskl     
           go top
           do while !eof() 
              if ent#gnEnt
                 skip
                 loop
              endif
              if rasc#1
                 skip
                 loop 
              endif 
              skr=sk
              pathr=gcPath_e+'g'+str(gg,4)+'\m'+iif(mm<10,'0'+str(mm,1),str(mm,2))+'\'+alltrim(path)
              if !netfile('tov','1')
                 sele cskl
                 skip  
                 loop
              endif
              if gnArm=25  
                 ?pathr   
              endif
              netuse('soper',,,1)
              netuse('tov',,,1)
              netuse('tovm',,,1)
              netuse('rs1',,,1)
              netuse('rs2',,,1)
              set orde to tag t3
              netuse('pr1',,,1)
              netuse('pr2',,,1)
              set orde to tag t3
              
              * Остатки
              sele tov
              go top
              do while !eof()
                 if int(mntov/10000)<1
                    skip   
                    loop
                 endif
                 rctovr=recn()
                 sklr=skl
                 ktlr=ktl
                 m1tr=m1t
                 k1tr=k1t
                 opttr=0
                 if k1tr#0
                    if int(k1tr/1000000)=1
                       opttr=getfield('t1','sklr,k1tr','tov','opt') 
                    endif
                 endif
                 sele tov
                 go rctovr
                 mntovr=mntov
                 osnr=osn
                 osfr=osf
                 optr=opt
                 otvr=otv
                 otr=ot
                 postr=post
                 cenprr=cenpr
                 c24r=c24
                 sele ctov
                 seek str(mntovr,7)
                 kodstr=kodst1
                 vesstr=vesst1
                 brandr=brand
                 mkeepr=mkeep
                 izgr=izg
                 krstatr=krstat 
                 if mkeepr=0
                    sele mkeepe
                    seek str(izgr,7)
                    mkeepr=mkeep
                 endif
                 sele ctov 
                 vespr=vesp
                 vesr=ves
                 keipr=keip
                 keir=kei
                 upakr=upak
                 upakpr=upakp
                 kgrr=kg
                 sele st1sb
                 seek str(kodstr,4)   
                 kgstr=kg
                 neistr=neist 
                 sele cgrp
                 seek str(kgrr,3) 
                 kovsr=kovs 
                 kovr=kov 
                 if otvr=1
                    sele tovm
                    seek str(sklr,7)+str(mntov,7)
                    optr=opt
                 endif
                 sele anost
                 seek str(skr,3)+str(ktlr,9)
                 if !foun()
                    appe blank
                    repl sk with skr,;
                         ktl with ktlr,;
                         mntov with mntovr,;
                         opt with optr,;
                         kodst with kodstr,;
                         vesst with vesstr,;
                         krstat with krstatr,;
                         brand with brandr,;
                         mkeep with mkeepr,;
                         izg with izgr,;
                         kovs with kovsr,;
                         kov with kovr,;
                         otv with otvr,;
                         vesp with vespr,;
                         kei with keir,;
                         keip with keipr,;
                         post with postr,;
                         upak with upakr,;
                         upakp with upakpr,;
                         ves with vesr,;
                         ot with otr,;
                         kg with kgrr,;
                         kgst with kgstr,;
                         neist with neistr,;
                         m1t with m1tr,;
                         k1t with k1tr,;
                         optt with opttr,;
                         &fldvr with cenprr,;
                         &fldmr with c24r,;
                         &fldnr with osnr,;
                         &fldfr with osfr
                 else   
                    repl &fldvr with cenprr,;
                         &fldmr with c24r,;
                         &fldnr with osnr,;
                         &fldfr with osfr
                 endif
                 sele tov
                 skip 
              endd
              
              * Расход
              kops()
              sele rs1
              set orde to 
              go top
              do while !eof()
                 ttnr=ttn
                 if ttnr=0
                    skip
                    loop  
                 endif
                 sdvr=sdv 
                 if sdvr=0
                    przapr=0 
                    sele rs2
                    seek str(ttnr,6)
                    do while ttn=ttnr
                       if kvp#0
                          przapr=1 
                          exit
                       endif
                       sele rs2
                       skip
                    endd
                 else   
                    przapr=1 
                 endif
                 if przapr=0
                    sele rs1
                    skip
                    loop
                 endif  
                 sele rs1 
                 kopr=kop
                 vor=vo
                 sele koprs
                 loca for vo=vor.and.kop=kopr
                 if !foun()
                    prdocr=1
                    bsr=0
                    dkr=0
                 else
                    prdocr=0
                    bsr=bs 
                    dkr=dk  
                 endif
                 qr=mod(kopr,100)
                 sele soper
                 tcenr=0
                 if netseek('t1','0,1,vor,qr') 
                    ndsr=nds   
                    tcenr=tcen
                 endif
                 sele rs1
                 if prz=0.and.empty(dop).and.empty(dot)
                    skip
                    loop
                 endif
                 sklr=skl
                 przr=prz
                 ttnr=ttn
                 kklr=kpl
                 pstr=pst
                 do case
                    case vor=6.and.kopr=181
                         kklr=2054800
                    case vor=6.and.kopr=101
                         kklr=2653305
                    case vor=6.and.kopr=121
                         kklr=3352550
                 endc
                 kgpr=kgp
                 nkklr=nkkl
                 if nkklr=0
                    nkklr=kklr
                 endif
                 kpvr=kpv
                 if kpvr=0
                    kpvr=kgp
                 endif
                 przr=prz
                 dvpr=dvp
                 ddcr=ddc
                 if empty(ddcr)  
                    ddcr=dvpr
                 endif
                 dopr=dop
                 dotr=dot
                 if empty(dopr)
                    dopr=dotr
                 endif
                 pr49r=pr49
                 mrshr=mrsh
                 atrcr=0  
                 msdvr=0 
                 if mrsh#0    
                    sele cmrsh
                    if netseek('t2','mrshr') 
                       atrcr=atrc
                       msdvr=msdv
                    else
                       atrcr=0
                       msdvr=0
                    endif
                 endif    
                 sele rs1 
                 ktar=kta
                 sele andocz
                 appe blank
                 repl sk with skr,;
                      mdoc with ttnr,;
                      kkl with kklr,;
                      kgp with kgpr,;
                      nkkl with nkklr,;
                      kpv with kpvr,;
                      kop with kopr,;
                      prz with przr,;
                      dvp with dvpr,;
                      dttn with dopr,;
                      dbuh with dotr,;
                      nds with ndsr,;
                      mrsh with mrshr,;
                      kta with ktar,;
                      vo with vor,;
                      bs with bsr,;
                      dk with dkr,;
                      period with periodr,;
                      prdoc with prdocr,;
                      atrc with atrcr,;
                      msdv with msdvr,;
                      sdv with sdvr,;
                      tcen with tcenr,;
                      ddc with ddcr      
                 sele rs2
                 if netseek('t3','ttnr')
                    do while ttn=ttnr 
                       if int(mntov/10000)<1
                          skip   
                          loop
                       endif
                       mntovr=mntovp
                       mntovtr=mntov
                       ktlr=ktlp
                       ktltr=ktl
                       if int(mntov/10000)=1
                          if ktlr=ktltr
                             skip   
                             loop
                          endif
                       endif    
                       pptr=ppt
                       kvpr=kvp
                       zenr=zen
                       sele rs2
                       if pr49r#0
                          if pr49r=1
                             zenr=bzen
                          else
                             zenr=xzen
                          endif
                       endif
                       if ndsr=1.or.ndsr=4
                          zenr=roun(zenr/1.2,3)
                       endif
                       if ktlr=ktltr && Товар
                          k1tr=getfield('t1','skr,ktlr','anost','k1t')   
                          if k1tr#0.and.int(k1tr/1000000)=1
                             zentr=getfield('t1','skr,k1tr','anost','opt')   
                             tvr=1
                          else
                             k1tr=0   
                             zentr=0  
                             tvr=0
                          endif    
                          sele andoc
                          appe blank
                          repl sk with skr,;
                               mdoc with ttnr,;
                               mntov with mntovr,;
                               ktl with ktlr,;
                               zen with zenr,;
                               kvp with kvpr,;
                               period with periodr,;
                               pst with pstr,; 
                               ktlt with k1tr,;
                               zent with zentr,;   
                               tv with tvr
                       else && Привязанная тара
                          sele andoc   
                          if netseek('t1','skr,0,ttnr,ktlr')
                             repl ktlt with ktltr,;
                                  zent with zenr,;
                                  tv with 0   
                          endif
                       endif     
                       sele rs2
                       skip   
                    endd
                 endif
                 sele rs1
                 skip 
              endd
              * Приход
              sele pr1
              set orde to   
              go top  
              do while !eof()
                 mnpr=mn
                 if mnpr=0
                    skip
                    loop 
                 endif 
                 if prz=0
                    skip
                    loop 
                 endif 
                 sdvr=sdv
                 if sdvr=0
                    przapr=0 
                    sele pr2
                    seek str(mnpr,6)
                    do while mn=mnpr
                       if kf#0
                          przapr=1 
                          exit
                       endif
                       skip  
                    endd
                 else   
                    przapr=1 
                 endif
                 if przapr=0
                    sele pr1
                    skip
                    loop
                 endif
                 sele pr1 
                 vor=vo
                 kopr=kop
                 sele koppr
                 loca for vo=vor.and.kop=kopr
                 if !foun()
                    prdocr=1
                    bsr=0
                    dkr=0  
                 else
                    prdocr=0
                    bsr=bs  
                    dkr=dk   
                 endif
                 qr=mod(kopr,100)
                 tcenr=0
                 sele soper
                 if netseek('t1','1,1,vor,qr') 
                    ndsr=nds   
                    tcenr=tcen
                 endif
                 sele pr1
                 sklr=skl
                 ndr=nd
                 mnpr=mn
                 kklr=kps
                 przr=prz
                 dvpr=dvp
                 ddcr=ddc
                 if empty(ddcr)  
                    ddcr=dvpr  
                 endif  
                 dprr=dpr
                 qr=mod(kopr,100)
                 kklr=kps
                 ktar=kta
                 sele andocz
                 appe blank
                 repl sk with skr,;
                      doc with ndr,;
                      mdoc with mnpr,;
                      kkl with kklr,;
                      kop with kopr,;
                      prz with przr,;
                      dvp with dvpr,;
                      dbuh with dprr,;
                      nds with ndsr,;
                      kta with ktar,;
                      vo with vor,;
                      bs with bsr,;
                      dk with dkr,;
                      period with periodr,;
                      prdoc with prdocr,;
                      sdv with sdvr,;
                      tcen with tcenr,;
                      ddc with ddcr       
                 sele pr2
                 if netseek('t3','mnpr')
                    do while mn=mnpr 
                       mntovr=mntovp
                       mntovtr=mntov
                       if int(mntov/10000)<1
                          skip   
                          loop
                       endif
                       ktlr=ktlp
                       ktltr=ktl
                       if int(mntov/10000)=1
                          if ktlr=ktltr
                             skip   
                             loop
                          endif
                       endif
                       pptr=ppt
                       kvpr=kf
                       zenr=zen
                       if ndsr=1.or.ndsr=4
                          zenr=roun(zenr/1.2,3)
                       endif
                       sele andoc
                       if ktlr=ktltr && Товар
                          k1tr=getfield('t1','skr,ktlr','anost','k1t')   
                          if k1tr#0.and.int(k1tr/1000000)=1
                             zentr=getfield('t1','skr,k1tr','anost','opt')   
                             tvr=1
                          else
                             k1tr=0  
                             zentr=0  
                             tvr=0  
                          endif    
                          appe blank
                          repl sk with skr,;
                               doc with ndr,;   
                               mdoc with mnpr,;
                               mntov with mntovr,;
                               ktl with ktlr,;
                               zen with zenr,;
                               kvp with kvpr,;
                               period with periodr,;
                               ktlt with k1tr,;
                               zent with zentr,;   
                               tv with tvr
                       else && Привязанная тара
                          if netseek('t1','skr,ndr,mnpr,ktlr')
                             repl ktlt with ktltr,;
                                  zent with zenr,;
                                  tv with 0
                          endif
                       endif     
                       sele pr2
                       skip    
                    endd     
                 endif
                 sele pr1
                 skip  
              endd
              nuse('rs1')
              nuse('rs2')
              nuse('pr1')
              nuse('pr2')
              nuse('soper')
              nuse('tov')
              nuse('tovm')
              if select('koprs')#0
                 sele koprs
                 use
              endif   
              if select('koppr')#0
                 sele koppr
                 use
              endif 
              sele cskl
              skip  
           endd
           nuse('cmrsh')  
           exit  
        endd     
    next        
next    
nuse('anost')
nuse('andkkln')
nuse('andokk')
nuse('andoc')
nuse('andocz')
nuse()

func kops
crtt('koprs',"f:vo c:n(1) f:kop c:n(3) f:bs c:n(6) f:dk c:n(1)")
sele 0
use koprs
copy stru to qrs1
sele 0
use qrs1
crtt('koppr',"f:vo c:n(1) f:kop c:n(3) f:bs c:n(6) f:dk c:n(1)")
sele 0
use koppr
copy stru to qpr1
sele 0
use qpr1
sele rs1
go top
do while !eof()
   vor=vo
   kopr=kop
   sele qrs1
   loca for vo=vor.and.kop=kopr
   if !foun()
      appe blank
      repl vo with vor,kop with kopr   
   endif
   sele rs1
   skip
endd
sele pr1
go top
do while !eof()
   vor=vo
   kopr=kop
   sele qpr1
   loca for vo=vor.and.kop=kopr
   if !foun()
      appe blank
      repl vo with vor,kop with kopr   
   endif
   sele pr1
   skip
endd
sele soper
go top
do while !eof()
   d0k1r=d0k1
   vor=vo
   kopr=kop+100
   dkrr=dkr1
   if d0k1r=0
      sele qrs1
   else
      sele qpr1
   endif
   loca for vo=vor.and.kop=kopr
   if !foun()
      sele soper
      skip  
      loop 
   endif
   sele soper
   prinsr=0
   bsr=0 
   dkr=0
   for ii=1 to 20
       cddbr='ddb'+alltrim(str(ii,2))
       cdkrr='dkr'+alltrim(str(ii,2))
       ddbr=&cddbr
       dkrr=&cdkrr
       if &strpr
          prinsr=1
          if &strdkr
             bsr=ddbr 
             dkr=1 
          else
             bsr=dkrr 
             dkr=2 
          endif       
          exit
       endif
   next
   if prinsr=1
      if d0k1r=0
         sele koprs
      else
         sele koppr
      endif
      loca for vo=vor.and.kop=kopr
      if !foun()
         appe blank
         repl vo with vor,kop with kopr,bs with bsr,dk with dkr
      endif
   endif
   sele soper
   skip 
endd
if select('qrs1')#0
   sele qrs1
   use
endif
if select('qpr1')#0
   sele qpr1
   use
endif
*sele sktara
*use
*erase sktara.dbf
*erase sktara.cdx
retu .t.
