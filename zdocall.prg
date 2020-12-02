********************
func cropl()
* Š®àà¥ªæ¨ï rs1.opl
********************
if gnArm#0
   clea
   mess('†¤¨â¥...')
endif
if .t.
netuse('cskl')
netuse('dokk')
netuse('doks')
sele dokk
copy stru to dokkopl
sele 0
use dokkopl excl
inde on str(dokksk,3)+str(dokkttn,6)+dtos(docprd) tag t1
use
sele 0
use dokkopl shared
set orde to tag t1
sele dokk
do while !eof()
   if empty(docprd)
      skip
      loop
   endif
   mnr=mn
   rndr=rnd
   nchekr=nchek
   if nchekr=0
      nchekr=getfield('t1','mnr,rndr','doks','nchek')
   endif
   arec:={}
   getrec()
   sele dokkopl
   netadd()
   putrec()
   netrepl('nplp','nchekr')
   sele dokk
   skip
endd

nuse('dokk')
nuse('doks')

crtt('ttnopl',"f:dokksk c:n(3) f:dokkttn c:n(6) f:kop c:n(3) f:kkl c:n(7) f:sdv c:n(10,2) f:sdo c:n(10,2) f:smopl c:n(10,2) f:smost c:n(10,2) f:errsdo c:n(10,2) f:fsdo c:n(1) f:docprd c:d(10) f:ttnddc c:d(10)")
sele 0
use ttnopl excl
inde on str(dokksk,3)+str(dokkttn,6) tag t1
use
sele 0
use ttnopl shared
set orde to tag t1

sele dokkopl
go top
do while !eof()
   dokkskr=dokksk
   dokkttnr=dokkttn
   docprdr=docprd
   smoplr=bs_s
   kklr=kkl
   sele ttnopl
   seek str(dokkskr,3)+str(dokkttnr,6)
   if !foun()
      netadd()
      netrepl('dokksk,dokkttn,kkl','dokkskr,dokkttnr,kklr')
   endif
   netrepl('smopl','smopl+smoplr')
   if docprdr>docprd
      netrepl('docprd','docprdr')
   endif
   sele dokkopl
   skip
endd

sele ttnopl
go top
do while !eof()
   dokkskr=dokksk
   dokkttnr=dokkttn
   docprdr=docprd
   yyr=year(docprdr)
   mmr=month(docprdr)
   pathmr=gcPath_e+'g'+str(yyr,4)+'\m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'
   sele cskl
   loca for sk=dokkskr
   pathr=pathmr+alltrim(path)
   if netfile('rs1',1)
      netuse('rs1',,,1)
      netuse('rs3',,,1)
      sele rs1
      if netseek('t1','dokkttnr')
*         sdvr=sdv
         sdvr=getfield('t1','dokkttnr,90','rs3','ssf')
         if rs1->sdv#sdvr
            netrepl('sdv','sdvr')
         endif
         kopr=kop
         ttnddcr=ddc
         if fieldpos('sdo')#0
            fsdor=1
            sdor=sdo
         else
            fsdor=0
            sdor=0
         endif
         sele ttnopl
         netrepl('sdv,sdo,fsdo,ttnddc,kop','sdvr,sdor,fsdor,ttnddcr,kopr')
      endif
      nuse('rs1')
      nuse('rs3')
   endif
   sele ttnopl
   skip
endd

sele ttnopl
go top
do while !eof()
   dokkskr=dokksk
   dokkttnr=dokkttn
   ttnddcr=ttnddc
   if !empty(ttnddcr)
*      yynr=year(ttnddcr)
*      mmnr=month(ttnddcr)
*      dter=addmonth(gdTd,-1)
      dt1r=addmonth(gdTd,-1)
      dt2r=ttnddcr
      for yyr=year(dt1r) to year(dt2r) step -1
          pathgr=gcPath_e+'g'+str(yyr,4)+'\'
          do case
             case year(dt1r)=year(dt2r)
                  mm1r=month(dt1r)
                  mm2r=month(dt2r)
             case yyr=year(dt1r)
                  mm1r=month(dt1r)
                  mm2r=1
             case yyr=year(dt2r)
                  mm1r=12
                  mm2r=month(dt2r)
             othe
                  mm1r=12
                  mm2r=1
          endc
          for mmr=mm1r to mm2r step -1
              pathr=pathgr+'m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\bank\'
              if !netfile('dokk',1)
                 loop
              endif
              netuse('dokk',,,1)
              if fieldpos('docprd')=0
                 nuse('dokk')
                 loop
              endif
              netuse('doks',,,1)
              sele dokk
              set orde to tag t9
              if netseek('t9','dokkskr,dokkttnr')
                 do while sk=dokkskr.and.dokkttn=dokkttnr
                    if empty(docprd)
                       skip
                       loop
                    endif
                    mnr=mn
                    rndr=rnd
                    nchekr=nchek
                    if nchekr=0
                       nchekr=getfield('t1','mnr,rndr','doks','nchek')
                       netrepl('nchek','nchekr')
                    endif
                    arec:={}
                    getrec()
                    sele dokkopl
                    netadd()
                    putrec()
                    netrepl('nplp','nchekr')
                    smoplr=bs_s
                    sele ttnopl
                    netrepl('smopl','smopl+smoplr')
                    sele dokk
                    skip
                 endd
              endif
              nuse('dokk')
              nuse('doks')
          next
      next
   endif
   sele ttnopl
   skip
endd
else
sele 0
use ttnopl shared
set orde to tag t1
sele 0
use dokkopl shared
set orde to tag t1
endif

sele ttnopl
go top
do while !eof()
   if sdv#0
      netrepl('smost','sdv-smopl')
      if smopl#sdo.and.sdo#0
         netrepl('errsdo','sdo-smopl')
      endif
   else
      netrepl('errsdo','0')
   endif
   sele ttnopl
   skip
endd

sele ttnopl
go top
rcttnor=recn()
wl_r='.t.'
for_r='.t.'
wlr='.t.'
forr='.t.'
fldnomr=1
store 0 to kkl_r,dokksk_r,dokkttn_r,prerr,prnzr,kop_r
if gnArm#0
   do while .t.
      sele ttnopl
      go rcttnor
      foot('ENTER,F2,F3','à®¢®¤ª¨,Š®àà SDO,”¨«ìâà')
      rcttnor=slce('ttnopl',1,0,18,,"e:dokksk h:'‘ª«' c:n(3) e:dokkttn h:' ’’  ' c:n(6) e:kop h:'Š®¯' c:n(3) e:kkl h:'Š®¤Š«' c:n(7)  e:sdv h:'‘ã¬¬  ’’' c:n(10,2) e:sdo h:'Ž¯« ¢ ’’' c:n(10,2) e:smopl h:'‘ã¬¬  Ž¯«' c:n(10,2) e:smost h:'‘¬Žáâ' c:n(10,2) e:errsdo h:'ŽèŽ¯«’’' c:n(10,2) e:fsdo h:'F' c:n(1) e:docprd h:'¥à¨®¤’’' c:d(10) e:ttnddc h:'„ â ‘§¤’’' c:d(10)",,,1,wlr,forr,,'’’')
      if lastkey()=27
         exit
      endif
      sele ttnopl
      go rcttnor
      dokkskr=dokksk
      dokkttnr=dokkttn
      do case
         case lastkey()=19 // Left
              fldnomr=fldnomr-1
              if fldnomr=0
                 fldnomr=1
              endif
         case lastkey()=4 // Right
              fldnomr=fldnomr+1
         case lastkey()=13 // à®¢®¤ª¨
              ttndokk()
         case lastkey()=-1 // Š®àà¥ªæ¨ï rs1.sdo,dokk.nchek
              crsdo()
         case lastkey()=-2 // ”¨«ìâà
              ttnoflt=setcolor('gr+/b,n/w')
              wttno=wopen(8,20,15,50)
              wbox(1)
              do while .t.
                 store 0 to kkl_r,dokksk_r,dokkttn_r,prerr,prnzr,kop_r
                 @ 0,1 say 'Š«¨¥­â      ' get kkl_r pict '9999999'
                 @ 1,1 say 'ŠŽ         ' get kop_r pict '999'
                 @ 2,1 say '‘ª« ¤       ' get dokksk_r pict '999'
                 @ 3,1 say '’’         ' get dokkttn_r pict '999999'
                 @ 4,1 say 'Žè¨¡ª¨ SDO  ' get prerr pict '9'
                 @ 5,1 say '¥ § ªàëâë¥ ' get prnzr pict '9'
                 read
                 if lastkey()=27
                    exit
                 endif
                 if lastkey()=13
                    forr=for_r
                    if kkl_r#0
                       forr=forr+'.and.kkl=kkl_r'
                    endif
                    if kop_r#0
                       forr=forr+'.and.kop=kop_r'
                    endif
                    if dokksk_r#0
                       forr=forr+'.and.dokksk=dokksk_r'
                    endif
                    if dokkttn_r#0
                       forr=forr+'.and.dokkttn=dokkttn_r'
                    endif
                    if prerr#0
                       forr=forr+'.and.errsdo#0'
                    endif
                    if prnzr#0
                       forr=forr+'.and.smost#0'
                    endif
                    exit
                 endif
              endd
              wclose(wttno)
              setcolor(ttnoflt)
              sele ttnopl
              go top
              rcttnor=recn()
      endc
   endd
else
   crsdo()
endi
nuse()
nuse('dokkopl')
nuse('ttnopl')
retu .t.

****************
func ttndokk()
****************
sele dokkopl
if netseek('t1','dokkskr,dokkttnr')
   sele dokkopl
   rcdokkor=recn()
   do while .t.
      rcdokkor=slcf('dokkopl',,,,,"e:ddk h:' „ â      ' c:d(10) e:rnd h:'N ¢ ¤ â¥' c:n(6) e:kop h:'Š®¯' c:n(4) e:bs_s h:'‘ã¬¬ ' c:n(10,2) e:nchek h:'—¥ª' c:n(6)",,,1,'dokksk=dokkskr.and.dokkttn=dokkttnr',,,'Ž¯« â ')
      sele dokkopl
      go rcdokkor
      if lastkey()=27
         exit
      endif
   endd
endif
retu .t.

**************
func crsdo()
**************
set cons off
set prin to crsdo.txt
set prin on
sele ttnopl
go top
do while !eof()
   if fsdo=0
      skip
      loop
   endif
   if sdo#smopl
      sdor=sdo
      smoplr=smopl
      dokkskr=dokksk
      dokkttnr=dokkttn
      docprdr=docprd
      ?str(dokkskr,7)+' '+str(dokkttnr,6)+' OPL '+str(smoplr,10,2)+' SDO '+str(sdor,10,2)
      yyr=year(docprdr)
      mmr=month(docprdr)
      pathmr=gcPath_e+'g'+str(yyr,4)+'\m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'
      sele cskl
      loca for sk=dokkskr
      pathr=pathmr+alltrim(path)
      if netfile('rs1',1)
         netuse('rs1',,,1)
         if netseek('t1','dokkttnr')
            netrepl('sdo','smoplr')
            sele ttnopl
            netrepl('sdo','smoplr')
            if sdv#0
               netrepl('smost','sdv-smopl')
               netrepl('errsdo','sdo-smopl')
            else
               netrepl('errsdo','0')
            endif
         endif
         nuse('rs1')
      endif
   endif
   sele ttnopl
   skip
endd
set prin off
set prin to
set cons on
retu .t.
