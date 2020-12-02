#include "common.ch"
#include "inkey.ch"
**************
func prvotv()
**************
*if gnArm#0.and.pozicion=6
*   clea
*   aqstr=1
*   aqst:={"Просмотр","Коррекция"}
*   aqstr:=alert(" ",aqst)
*   if lastkey()=K_ESC
*      retu
*   endif
*else
*   aqstr=2
*endif
set prin to crotvv.txt
set prin on
pathr=path_tr
netuse('pr1',,,1)
locate for otv=1
if !foun()
   nuse('pr1')
   wmess('Этот склад не имеет ответхранения',1)
   retu .t.
endif
netuse('cskl')
pathr=path_tr
netuse('tov',,,1)
netuse('tovm',,,1)
netuse('rs1',,,1)
netuse('rs2',,,1)
netuse('pr1',,,1)
netuse('pr2',,,1)
*dtr=bom(gdTd)-1
*mmr=month(dtr)
*yyr=year(dtr)
*pathpr=gcPath_e+'g'+str(yyr,4)+'\m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'+gcDir_t
crtt('qkps','f:mn c:n(6) f:kps c:n(7) f:skl c:n(7)')
sele 0
use qkps
sele pr1
do while !eof()
   if otv#1
      skip
      loop
   endif
   mnr=mn
   kpsr=kps
   sklr=skl
   sele qkps
   appe blank
   netrepl('mn,kps,skl','mnr,kpsr,sklr')
   sele pr1
   skip
endd
sele qkps
go top
do while !eof()
     kpsr=kps
     mnr=mn
     sklr=skl
     sele pr1
     locate for kps=kpsr.and.otv=1
     skspr=sksp
*     pathr=pathpr
     pathr=path_pr
     if select('totchp')#0
        sele totchp
        use
     endif
     if netfile('tov',1)
        netuse('pr1','pr1p',,1)
        netuse('pr2','pr2p',,1)
        netuse('tov','tovp',,1)
        * Остаток на конец месяца
        if select('tostp')#0
           sele tostp
           use
        endif
        crtt('tostp','f:ktl c:n(9) f:kfo c:n(12,3)')
        sele 0
        use tostp
        sele pr2p
        if netseek('t1','mnr')
           do while mn=mnr
              ktlr=ktl
              kfor=kfo
*              if kfor#0
                 sele tostp
                 appe blank
                 netrepl('ktl,kfo','ktlr,kfor')
                 if kfor#0
                    sele pr2
                    if !netseek('t1','mnr,ktlr')
                       ?str(mnr,6)+' '+str(ktlr,9)+' нет в текущем'
                       if aqstr=2
                          sele pr2p
                          arec:={}
                          getrec()
                          sele pr2
                          netadd()
                          putrec()
                       endif
                    endif
                 endif
*              endif
              sele pr2p
              skip
           endd
        endif
        sele tovp
        go top
        do while !eof()
           if otv#1
              skip
              loop
           endif
           sklr=skl
           ktlr=ktl
           osvor=osvo
           sele tostp
           locate for ktl=ktlr
           if !foun()
              if osvor#0
                 sele tov
                 if !netseek('t1','sklr,ktlr')
                    ?str(sklr,7)+' '+str(ktlr,9)+' нет в текущем'
                    if aqstr=2
                       sele tovp
                       arec:={}
                       getrec()
                       sele tov
                       netadd()
                       putrec()
                    endif
                 endif
              endif
           endif
           sele tovp
           skip
        endd
        ?'Коррекция KFN текущего'
        sele tostp
        go top
        do while !eof()
           arec:={}
           getrec()
             ktlr=ktl
             kfnr=kfo
             sele pr2
             if netseek('t1','mnr,ktlr')
                if kfn#kfnr
                   ?str(mnr,6)+' '+str(ktlr,9)+' Тек '+str(kfn,12,3)+' Расч '+str(kfnr,12,3)
                   if aqstr=2
                      netrepl('kfn','kfnr')
                   endif
                endif
             else
*                ?str(mnr,6)+' '+str(ktlr,9)+' Нет в тек '
*                if aqstr=2
*                   netadd()
*                   putrec()
*                   netrepl('kfn,kfo,kf','kfnr,0,0')
*                endif
             endif
             sele tostp
             skip
        endd
        use
        erase tostp.dbf
        nuse('pr1p')
        nuse('pr2p')
        nuse('tovp')
     endif
     ?'Коррекция KFO,KF текущего'
     sele cskl
     loca for sk=skspr
     if foun()
        pathr=gcPath_d+alltrim(path) // Склад ответхранения
        netuse('pr1','pr1o',,1)
        netuse('pr2','pr2o',,1)
        netuse('rs1','rs1o',,1)
        netuse('rs2','rs2o',,1)
        netuse('tov','tovo',,1)
        if select('qpro')#0
           sele qpro
           use
        endif
        crtt('qpro','f:ktl c:n(9) f:upakp c:n(12,3) f:kf c:n(12,3)')
        sele 0
        use qpro excl
        inde on str(ktl,9)  tag t1
        sele pr1o
        do while !eof()
           if prz=0
              skip
              loop
           endif
           if kps#kpsr
              skip
              loop
           endif
           if sktp#gnSk
              skip
              loop
           endif
           skl_r=skl
           mn_r=mn
           sele pr2o
           if netseek('t1','mn_r')
              do while mn=mn_r
                 ktlr=ktl
                 mntovr=mntov
                 kfr=kf
                 upakpr=getfield('t1','skl_r,ktlr','tovo','upakp')
                 sele qpro
                 if !netseek('t1','ktlr')
                    netadd()
                    netrepl('ktl,upakp,kf','ktlr,upakpr,kfr')
                 else
                    netrepl('kf','kf+kfr')
                 endif
                 sele pr2o
                 skip
              endd
           endif
           sele pr1o
           skip
        endd

        if select('qrso')#0
           sele qrso
           use
        endif
        crtt('qrso','f:ktl c:n(9) f:kvp c:n(12,3)')
        sele 0
        use qrso excl
        inde on str(ktl,9)  tag t1
        sele rs1o
        do while !eof()
           if amnp#0
              skip
              loop
           endif
           if prz=0
              skip
              loop
           endif
           skl_r=skl
           ttn_r=ttn
           sele rs2o
           if netseek('t1','ttn_r')
              do while ttn=ttn_r
                 ktlr=ktl
                 mntovr=mntov
                 kvpr=kvp
                 sele qrso
                 if !netseek('t1','ktlr')
                    netadd()
                    netrepl('ktl,kvp','ktlr,kvpr')
                 else
                    netrepl('kvp','kvp+kvpr')
                 endif
                 sele rs2o
                 skip
              endd
           endif
           sele rs1o
           skip
        endd
        nuse('pr1o')
        nuse('pr2o')
        nuse('rs1o')
        nuse('rs2o')
        nuse('tovo')

        ?'Ручные приходы с отв хр'
        if select('qotchrp')#0
           sele qotchrp
           use
        endif
        crtt('qotchrp','f:ktlm c:n(9) f:kf c:n(12,3)')
        sele 0
        use qotchrp excl
        inde on str(ktlm,9) tag t1
        sele pr1
        go top
        do while !eof()
           if otv#4
              skip
              loop
           endif
           if kps#kpsr
              skip
              loop
           endif
           mn_r=mn
           amnpr=mn
           sele pr2
           if netseek('t1','mn_r')
              do while mn=mn_r
                 ktlmr=ktlm
                 ktlr=ktl
                 kfr=kf
                 sele qotchrp
                 if !netseek('t1','ktlmr')
                    netadd()
                    netrepl('ktlm,kf','ktlmr,kfr')
                 else
                    netrepl('kf','kf+kfr')
                 endif
                 sele pr2
                 skip
              endd
           endif
           sele pr1
           skip
        endd
        ?'Подтвержденные отчеты'
        if select('qotchp')#0
           sele qotchp
           use
        endif
        crtt('qotchp','f:ktlm c:n(9) f:kf c:n(12,3) f:ktl c:n(9)')
        sele 0
        use qotchp excl
        inde on str(ktlm,9) tag t1
        sele pr1
        go top
        do while !eof()
           if prz=0
              skip
              loop
           endif
           if otv#3
              skip
              loop
           endif
           if kps#kpsr
              skip
              loop
           endif
           mn_r=mn
           amnpr=mn
           sele pr2
           if netseek('t1','mn_r')
              do while mn=mn_r
                 ktlmr=ktlm
                 ktlr=ktl
                 kfr=kf
                 sele qotchp
                 if !netseek('t1','ktlmr')
                    netadd()
                    netrepl('ktlm,kf,ktl','ktlmr,kfr,ktlr')
                 else
                    netrepl('kf','kf+kfr')
                 endif
                 sele pr2
                 skip
              endd
              ?'Отчет '+str(amnpr,6)
              sele qotchp
              go top
              do while !eof()
                 ktlmr=ktlm
                 ktlr=ktl
                 sele rs2
                 set orde to tag t5 // amnp,ktl
                 do while .t.
                    sele rs2
                    if netseek('t5','amnpr,ktlmr')
                       ?str(ttn,6)+' '+str(ktl,9)+' '+' -> '+str(ktlr,9)
                       if aqstr=2
                          netrepl('ktl,ktlp,otv','ktlr,ktlr,0')
                       else
                          exit
                       endif
                    else
                       exit
                    endif
                 enddo
                 sele qotchp
                 skip
              endd
           endif
           sele pr1
           skip
        endd
******************
        sele pr1
        go top
        do while !eof()
           if prz=0
              skip
              loop
           endif
           if otv#3
              skip
              loop
           endif
           if kps#kpsr
              skip
              loop
           endif
           mn_r=mn
           amnpr=mn
           sele pr2
           if netseek('t1','mn_r')
              do while mn=mn_r
                 ktlmr=ktlm
                 ktlr=ktl
                 sele rs2
                 set orde to tag t7 // amnp,ktlm
                 if netseek('t7','amnpr,ktlmr')
                    do while amnp=amnpr.and.ktlm=ktlmr
                       if ktl#ktlr
                          ?'TTN '+str(ttn,6)+' '+str(ktl,9)+' MN '+str(amnp,6)+' '+str(ktlr,9)+' KTLM '+str(ktlmr,9)
                          if aqstr=2
                             netrepl('ktl','ktlr')
                          endif
                       endif
                       sele rs2
                       skip
                    endd
                 endif
                 sele pr2
                 skip
              endd
           endif
           sele pr1
           skip
        endd
******************
        ?'Неподтвержденные отчеты'
        if select('qotchn')#0
           sele qotchn
           use
        endif
        crtt('qotchn','f:ktlm c:n(9) f:kf c:n(12,3) f:ktl c:n(9) f:zen c:n(10,3)')
        sele 0
        use qotchn excl
        inde on str(ktlm,9) tag t1
        sele pr1
        go top
        do while !eof()
           if prz=1
              skip
              loop
           endif
           if otv#3
              skip
              loop
           endif
           if kps#kpsr
              skip
              loop
           endif
           mn_r=mn
           amnpr=mn
           sele pr2
           if netseek('t1','mn_r')
              do while mn=mn_r
                 ktlmr=ktlm
                 ktlr=ktl
                 kfr=kf
                 zenr=zen
                 sele qotchn
                 if !netseek('t1','ktlmr')
                    netadd()
                    netrepl('ktlm,kf,ktl,zen','ktlmr,kfr,ktlr,zenr')
                 else
                    netrepl('kf','kf+kfr')
                 endif
                 sele pr2
                 skip
              endd
              ?'Отчет '+str(amnpr,6)
              sele qotchn
              go top
              do while !eof()
                 ktlmr=ktlm
                 ktlr=ktl
                 if zen=0 // Пропуск неперекодированных
                    skip
                    loop
                 endif
                 sele rs2
                 set orde to tag t5 // amnp,ktl  // t7 amnp,ktlm
                 do while .t.
                    sele rs2
                    if netseek('t5','amnpr,ktlmr')
                       ?str(ttn,6)+' '+str(ktl,9)+' '+' -> '+str(ktlr,9)
                       if aqstr=2
                          netrepl('ktl,ktlp,otv','ktlr,ktlr')
                       else
                          exit
                       endif
                    else
                       exit
                    endif
                 enddo
                 sele qotchn
                 skip
              endd
           endif
           sele pr1
           skip
        endd
        ?'Протоколы'
        if select('qprot')#0
           sele qprot
           use
        endif
        crtt('qprot','f:ktl c:n(9) f:kf c:n(12,3)')
        sele 0
        use qprot excl
        inde on str(ktl,9) tag t1
        sele pr1
        go top
        do while !eof()
           if prz=1
              skip
              loop
           endif
           if otv#2
              skip
              loop
           endif
           if kps#kpsr
              skip
              loop
           endif
           mn_r=mn
           sele pr2
           if netseek('t1','mn_r')
              do while mn=mn_r
                 ktlr=ktl
                 kfr=kf
                 sele qprot
                 if !netseek('t1','ktlr')
                    netadd()
                    netrepl('ktl,kf','ktlr,kfr')
                 else
                    netrepl('kf','kf+kfr')
                 endif
                 sele pr2
                 skip
              endd
           endif
           sele pr1
           skip
        endd
        ?'Коррекция '
        sele pr2
        set orde to tag t1
        if netseek('t1','mnr')
           do while mn=mnr
                mntovr=mntov
                ktlr=ktl
                upakpr=getfield('t1','gnSkl,ktlr','tov','upakp')
                kfnr=kfn
                kfr=kf     // Тек kf // По подтв док
                kfor=kfo   // Тек kfo // По подтв док -прот-неподтв отчет (osvo)
                kfpor=0    // Приходов с отв
                kvpr=0     // Расходы не авт отв хр
                kfotchpr=0 // Подтв. отч.
                kfotchnr=0 // Неподтв. отч.
                kfprotr=0  // Протокол
                kfrpr=0    // Ручные отчеты
                sele qpro
                locate for ktl=ktlr
                if foun()
                   kfpor=kf
                endif
                sele qrso
                locate for ktl=ktlr
                if foun()
                   kvpr=kvp
                endif
                sele qotchp
                locate for ktlm=ktlr
                if foun()
                   kfotchpr=kf
                endif
                sele qotchrp
                locate for ktlm=ktlr
                if foun()
                   kfrpr=kf
                endif
                sele qotchn
                locate for ktlm=ktlr
                if foun()
                   kfotchnr=kf
                endif
                sele qprot
                locate for ktl=ktlr
                if foun()
                   kfprotr=kf
                endif
                if kfnr=0.and.kfpor=0.and.kfotchpr=0.and.kfotchnr=0.and.kfprotr=0.and.kfrpr=0.and.kvpr=0
                   prdelr=1
                else
                   prdelr=0
                endif
                sele pr2
                mntovr=mntov
                kf_r =kfnr+kfpor-kfotchpr-kfotchnr-kfprotr-kfrpr-kvpr
                kfo_r=kfnr+kfpor-kfotchpr-kfrpr-kvpr
                if kfor#kfo_r.or.kfr#kf_r
                   if (kfor#kfnr+kfpor-kfotchpr-kvpr)
                      ?str(mnr,6)+' '+str(ktlr,9)+' Коррекция KFO '+str(kfor,10,3)+' -> '+str(kfo_r,10,3)
                   else
                      ?str(mnr,6)+' '+str(ktlr,9)+' Коррекция KF  '+str(kfr,10,3)+' -> '+str(kf_r,10,3)
                   endif
                   if aqstr=2
                      netrepl('kf,kfo','kf_r,kfo_r')
                   endif
                endif
                sele tov
                if netseek('t1','sklr,ktlr')
                   if osvo#kf_r
                      ?str(sklr,7)+' '+str(ktlr,9)+' '+' PR2->KF '+str(kf_r,10,3)+' '+' TOV->OSVO '+str(osvo,10,3)
                      if aqstr=2
                         netrepl('osvo','kf_r')
                      endif
                   endif
                   if otv#1 //.or.opt#0
                      ?str(sklr,7)+' '+str(ktlr,9)+' '+str(opt,10.3)+' TOV->OTV=0'
                      if aqstr=2
                         netrepl('opt,otv','0.01,1')
                      endif
                   endif
                   if osn#0.or.osv#0.or.osf#0.or.osfm#0
                      ?str(sklr,7)+' '+str(ktlr,9)+' '+'osn#0.or.osv#0.or.osf#0.or.osfm#0'
                      if aqstr=2
                         netrepl('osn,osv,osf,osfm','0,0,0,0')
                      endif
                   endif
*                   #ifndef __CLIP__
                     if prdelr=1
                        ?str(sklr,7)+' '+str(ktlr,9)+' '+str(otv,1)+' '+str(osvo,12,3)+' TOV удален'
                        if aqstr=2
                           netdel()
                        endif
                     endif
*                   #endif
                else
                   ?str(sklr,7)+' '+str(ktlr,9)+' '+' Нет в TOV'
                endif
                sele pr2
*                #ifndef __CLIP__
                  if prdelr=1
                     ?str(mnr,6)+' '+str(ktlr,9)+' '+str(kfn,12,3)+' '+str(kf,12,3)+' '+str(kfo,12,3)+' PR2 удален'
                     if aqstr=2
                        netdel()
                     endif
                  endif
*                #endif
                skip
           endd
           ?'TOVM'
           sele tovm
           go top
           do while !eof()
              sklr=skl
              mntovr=mntov
              if !netseek('t5','sklr,mntovr','tov')
                 ?str(sklr,7)+' '+str(mntovr,7)+' '+subs(nat,1,40)+' нет в TOV удален'
                 if aqstr=2
                    sele tovm
                    netdel()
                 endif
              endif
              sele tovm
              skip
           endd
           sele qprot
           use
           erase qprot.dbf
           erase qprot.cdx
           sele qotchn
           use
           erase qotchn.dbf
           erase qotchn.cdx
           sele qotchrp
           use
           erase qotchrp.dbf
           erase qotchrp.cdx
           sele qotchp
           use
           erase qotchp.dbf
           erase qotchp.cdx
           sele qpro
           use
           erase qpro.dbf
           erase qpro.cdx
           sele qrso
           use
           erase qrso.dbf
           erase qrso.cdx
        endif
     endif
     sele qkps
     skip
endd
if select('qkps')#0
   sele qkps
   use
endif
erase qkps.dbf
nuse()
nuse('pr1p')
nuse('pr2p')
set prin off
set prin to
retu .t.

**************
func otvprv()
**************
if gnArm#0
   clea
   aqstr=1
   aqst:={"Просмотр","Коррекция"}
   aqstr:=alert(" ",aqst)
   if lastkey()=K_ESC
      retu .t.
   endif
else
   aqstr=2
endif
set prin to crotv.txt
set prin on
if gnSkotv#0
   carsotv()
   retu .t.
endif
pathr=path_tr
netuse('pr1',,,1)
locate for otv=1
if !foun()
   nuse('pr1')
   wmess('Этот склад не имеет ответхранения',1)
   retu
endif
netuse('cskl')
pathr=path_tr
netuse('tov',,,1)
netuse('tovm',,,1)
netuse('rs1',,,1)
netuse('rs2',,,1)
netuse('pr1',,,1)
netuse('pr2',,,1)
*dtr=bom(gdTd)-1
*mmr=month(dtr)
*yyr=year(dtr)
*pathpr=gcPath_e+'g'+str(yyr,4)+'\m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'+gcDir_t
pathr=path_pr
if !netfile('tov',1)
   nuse()
   retu .t.
endif

netuse('tov','tovp',,1)
netuse('pr1','pr1p',,1)
netuse('pr2','pr2p',,1)
netuse('rs1','rs1p',,1)
netuse('rs2','rs2p',,1)

if .f. // gnArm#0.and.gnAdm=1
   acrdcr=0
   if aqstr=1
      acrdcr=1
   else
      if bom(gdTd)=bom(date())
         acrdc:={"Просмотр","Коррекция"}
         acrdcr:=alert("Корр только для завершения переворота ",acrdc)
      else
         acrdcr=1
      endif
   endif
   if acrdcr=2
      ?'Коррекция TTN по отчетам прошлого месяца'
   else
      ?'Просмотр TTN по отчетам прошлого месяца'
   endif
   sele pr1p
   go top
   do while !eof()
      if otv#3
         skip
         loop
      endif
      mnr=mn
      sele pr2p
      if netseek('t1','mnr')
         do while mn=mnr
            if ktlm=0
               ?str(mnr,6)+' ktlm=0'
               skip
               loop
            endif
            if ktl=ktlm
               ?str(mnr,6)+' ktl=ktlm'
               skip
               loop
            endif
            ktlr=ktl
            ktlpr=ktlp
            ktlmr=ktlm
            ktlmpr=ktlmp
            sele rs2p
            set orde to tag t5 // amnp,ktl,ktlp
            if netseek('t5','mnr,ktlr,ktlpr')
               do while amnp=mnr.and.ktl=ktlr.and.ktlp=ktlpr
                  ttnr=ttn
                  ktlm_r=ktlm
                  ktlmp_r=ktlmp
                  otvr=otv
                  sele rs2
                  set orde to tag t1
                  if netseek('t1','ttnr')
                     do while ttn=ttnr
                        if ktlm=ktlm_r.and.ktlmp=ktlmp_r //.or.ktlm=0.and.ktl=ktlmr.and.ktlp=ktlmpr
                           if ktl#ktlr.or.amnp#mnr.or.otv#otvr
                              ?str(ttnr,6)+' KTL '+str(ktl,9)+'->'+str(ktlr,9)+' AMNP '+str(amnp,6)+'->'+str(mnr,6)+' OTV '+str(otv,1)+'->'+str(otvr,1)
                              if acrdcr=2
                                 netrepl('amnp,ktl,ktlp,ktlm,ktlmp,otv','mnr,ktlr,ktlpr,ktlmr,ktlmpr,otvr')
                              endif
                           endif
                        endif
                        sele rs2
                        skip
                     endd
                  endif
                  sele rs2p
                  skip
               endd
            endif
            sele pr2p
            skip
         endd
      endif
      sele pr1p
      skip
   endd
endif
if .f. // В rs2 может быть коррекция на 0 - некорректная проверка
?'Коррекция отчетов текущего месяца'
sele pr1
go top
do while !eof()
   if otv#3
      skip
      loop
   endif
   mnr=mn
   sele rs2
   set orde to tag t5
   if !netseek('t5','mnr')
      sele pr2
      if netseek('t1','mnr')
         do while mn=mnr
            ?str(mnr,6)+' '+str(ktlr,9)+' уд'
            if aqstr=2
               netdel()
            endif
            sele pr2
            skip
         endd
      endif
      sele pr1
      ?str(mnr,6)+' уд'
      if aqstr=2
         netdel()
      endif
   endif
   sele pr1
   skip
endd
endif
*#ifndef __CLIP__
acrdc1r=0
if .f. // gnArm#0.and.gnAdm=1
   if aqstr=1
      acrdc1r=1
   else
      acrdc:={"Просмотр","Коррекция"}
      acrdc1r:=alert("Коррекция подтвержденных расходов ОТВ",acrdc)
   endif
   if acrdc1r=2
      ?'Коррекция подтвержденных расходов ОТВ'
   else
      ?'Проверка подтвержденных расходов ОТВ'
   endif
endif
sele cskl
go top
do while !eof()
   if skotv#gnSk
      skip
      loop
   endif
   sk_r=sk
   pathr=gcPath_d+alltrim(path) // Склад ответхранения
   netuse('rs1','rs1o',,1)
   netuse('rs2','rs2o',,1)
   ?'Расход->Приход'
   sele rs1o
   go top
   do while !eof()
      ttnr=ttn
      mnr=amnp
      skspr=sksp
      ?str(sk_r,3)+' '+'TTN'+' '+str(ttnr,6)+' -> MN '+str(mnr,6)
      if skspr=gnSk
         sele pr1
         if netseek('t2','mnr')
            sele rs2o
            if netseek('t1','ttnr')
               do while ttn=ttnr
                  ktlr=ktl
                  ktlmr=ktlm
                  kvpr=kvp
                  kfr=0
                  sele pr2
                  if netseek('t1','mnr,ktlmr')
                     prfnd_r=0
                     do while mn=mnr.and.ktl=ktlmr
                        if ktlm=ktlr
                           kfr=kf
                           if kvpr#kfr
                              ?str(sk_r,3)+' TTN '+str(ttnr,6)+' '+str(ktlr,9)+' kvpr '+str(kvpr,12,3)+' MN '+str(mnr,6)+' '+str(ktlmr,9)+' kfr '+str(kfr,12,3)
                              if acrdc1r=2
                                 sele rs2o
                                 netrepl('kvp','kfr')
                              endif
                           endif
                           prfnd_r=1
                        endif
                        sele pr2
                        skip
                     endd
                     if prfnd_r=0
                        ?str(sk_r,3)+' TTN '+str(ttnr,6)+' '+str(ktlr,9)+' kvpr '+str(kvpr,12,3)+' MN '+str(mnr,6)+' '+str(ktlmr,9)+' kfr '+str(kfr,12,3)+' не найден'
                     endif
                  else
                     ?str(sk_r,3)+' TTN '+str(ttnr,6)+' '+str(ktlr,9)+' kvpr '+str(kvpr,12,3)+' MN '+str(mnr,6)+' '+str(ktlmr,9)+' не найден'
                     if acrdc1r=2
                        sele rs2o
                        netdel()
                     endif
                  endif
                  sele rs2o
                  skip
               endd
            endif
         else
            ?str(sk_r,3)+' '+' TTN '+str(ttnr,6)+' MN '+str(mnr,6)+' не найден'
         endif
      endif
      sele rs1o
      skip
   endd
   ?'Приход->Расход'
   sele pr1
   go top
   do while !eof()
      if prz#1
         skip
         loop
      endif
      if otv#3
         skip
         loop
      endif
      mn_r=mn
      ttn_r=amnp
      ?'MN'+' '+str(mn_r,6)+' -> TTN '+str(ttn_r,6)
      sele pr2
      if netseek('t1','mn_r')
         do while mn=mn_r
            ktl_r=ktl
            ktlm_r=ktlm
            kf_r=kf
            sele rs2o
            if netseek('t1','ttn_r,ktlm_r')
               prfnd_r=0
               do while ttn=ttn_r.and.ktl=ktlm_r
                  kvp_r=kvp
                  if ktlm=ktl_r
                     if kf_r#kvp_r
                        ?'MN'+' '+str(mn_r,6)+' KTL '+str(ktl_r,9)+' '+str(kf_r,12,3)+' TTN '+str(ttn_r,6)+' KTL '+str(ktlm_r,9)+' '+str(kvp_r,12,3)
                     endif
                     prfnd_r=1
                  endif
                  sele rs2o
                  skip
               endd
               if prfnd_r=0
                  ?'MN'+' '+str(mn_r,6)+' KTL '+str(ktl_r,9)+' '+str(kf_r,12,3)+' TTN '+str(ttn_r,6)+' KTL '+str(ktlm_r,9)+' '+str(kvp_r,12,3)+' не найден'
               endif
            else
               ?'MN'+' '+str(mn_r,6)+' KTL '+str(ktl_r,9)+' '+str(kf_r,12,3)+' TTN '+str(ttn_r,6)+' KTL '+str(ktlm_r,9)+' не найден'
            endif
            sele pr2
            skip
         endd
      endif
      sele pr1
      skip
   endd
   nuse('rs1o')
   nuse('rs2o')
   sele cskl
   skip
endd
*#endif

crproto()
nuse('tovp')
nuse('pr1p')
nuse('pr2p')
nuse('rs1p')
nuse('rs2p')
nuse()
cukach()
cadrot()
prvotv()

retu .t.
***************
func cukach()
***************
pathr=path_tr
netuse('pr1',,,1)
netuse('pr2',,,1)
sele pr1
set orde to tag t3 // otv,kps
if !netseek('t3','1')
   nuse('pr1')
   nuse('pr2')
   wmess('Этот склад не имеет ответхранения',1)
   retu .t.
endif
?'Коррекция качественных'
crtt('lkpssk','f:kps c:n(7) f:sk c:n(3)')
sele 0
use lkpssk
sele pr1
do while otv=1
   kpsr=kps
   skr=sksp
   sele lkpssk
   locate for kps=kpsr.and.sk=skr
   if !foun()
      appe blank
      repl kps with kpsr,sk with skr
   endif
   sele pr1
   skip
endd
netuse('cskl')
pathr=path_tr
netuse('tov',,,1)
sele lkpssk
go top
do while !eof()
   skr=sk
   sele cskl
   if netseek('t1','skr')
      pathr=gcPath_d+alltrim(path)
      if netfile('tov',1)
         netuse('tov','tovotv',,1)
         do while !eof()
            ktlr=ktl
            ksertr=ksert
            kukachr=kukach
            if ksertr#0.and.kukachr#0
               sele tov
               if netseek('t1','gnSkl,ktlr')
                  if ksertr#ksert.or.kukachr#kukach
                     ?str(ktl,9)+' KSERT '+str(ksert,6)+'->'+str(ksertr,6)+' KUKACH '+str(kukach,6)+'->'+str(kukachr,6)
                     if aqstr=2
                        netrepl('ksert,kukach','ksertr,kukachr')
                     endif
                  endif
               endif
            endif
            sele tovotv
            skip
         endd
         nuse('tovotv')
      endif
   endif
   sele lkpssk
   skip
endd
sele lkpssk
use
sele pr1
if netseek('t3','3')
   do while otv=3
      mnr=mn
      sele pr2
      if netseek('t1','mnr')
         do while mn=mnr
            ktlr=ktl
            ktlmr=ktlm
            if ktlr=ktlmr
               skip
               loop
            endif
            sele tov
            if netseek('t1','gnSkl,ktlmr')
               ksertr=ksert
               kukachr=kukach
               if ksertr#0.and.kukachr#0
                  sele tov
                  if netseek('t1','gnSkl,ktlr')
                     if ksertr>ksert.or.kukachr>kukach
                        ?str(ktlmr,9)+'->'+str(ktl,9)+' KSERT '+str(ksert,6)+'->'+str(ksertr,6)+' KUKACH '+str(kukach,6)+'->'+str(kukachr,6)
                        if aqstr=2
                           netrepl('ksert,kukach','ksertr,kukachr')
                        endif
                     endif
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
endif
nuse()
retu .t.
******************
func crproto(p1)
******************
if !empty(p1)
   set cons off
endif
?'Коррекция протокола'
if select('lprot')#0
   sele lprot
   use
endif
crtt('lprot','f:amnp c:n(6) f:mntov c:n(7) f:ktl c:n(9) f:kf c:n(15,3)')
sele 0
use lprot shared
sele rs2
go top
do while !eof()
   if otv#2
      skip
      loop
   endif
   if amnp=0
      skip
      loop
   endif
   ttnr=ttn
   przr=getfield('t1','ttnr','rs1','prz')
   if przr=0
      amnpr=amnp
      mntovr=mntov
      ktlr=ktl
      ktlpr=ktlp
      kvpr=kvp
      sele lprot
      locate for amnp=amnpr.and.ktl=ktlr
      if !foun()
         appe blank
         repl ktl with ktlr,;
              mntov with mntovr,;
              amnp with amnpr
      endif
      reclock()
      repl kf with kf+kvpr
      netunlock()
   else
      ?str(ttnr,6)+' '+str(ktlr,9)+' PRZ= 1'
   endif
   sele rs2
   skip
endd
sele lprot
go top
do while !eof()
   amnpr=amnp
   mntovr=mntov
   ktlr=ktl
   kfr=kf
   sele pr2
   if netseek('t1','amnpr,ktlr,ktlr')
      if kf#kfr
         ?str(amnpr,6)+' '+str(ktlr,9)+' '+str(kf,15,3)+'->'+str(kfr,15,3)
         if aqstr=2
            netrepl('kf,kfo','kfr,kfr')
         endif
      endif
   else
      ?str(amnpr,6)+' '+str(ktlr,9)+' не найден '+'->'+str(kfr,15,3)
      if aqstr=2
         netadd()
         netrepl('mn,mntov,mntovp,ktl,ktlp,kf,kfo,ktlm,ktlmp','amnpr,mntovr,mntovr,ktlr,ktlr,kfr,kfr,ktlr,ktlr')
      endif
   endif
   sele lprot
   skip
endd
sele rs2
set orde to tag t5 // amnp,ktl,ktlp
sele pr1
go top
do while !eof()
   if otv#2
      skip
      loop
   endif
   mnr=mn
   sele pr2
   if netseek('t1','mnr')
      do while mn=mnr
         ktlr=ktl
         sele rs2
         if !netseek('t5','mnr,ktlr')
            sele pr2
            ?str(mnr,6)+' '+str(ktlr,9)+' '+str(kf,15,3)+' '+str(kfo,15,3)+' нет в rs2'
            if aqstr=2
               netdel()
*               netrepl('kf,kfo','0,0')
            endif
         endif
         sele pr2
         skip
      endd
   endif
   sele pr1
   skip
endd
sele lprot
use
if !empty(p1)
   set cons on
endif
retu .t.
*************
func cadrot()
* Коррекция skt,sklt,amn,sktp,skltp,amnp
*************
?'Коррекция skt,sklt,amn,sktp,skltp,amnp'
pathr=path_tr
netuse('pr1',,,1)
set orde to tag t3
if !netseek('t3','1')
   nuse('pr1')
   wmess('Этот склад не имеет ответхранения',1)
   retu .t.
endif
netuse('soper',,,1)
sele pr1
set orde to tag t3 // otv,kps
if !netseek('t3','3')
   nuse('pr1')
   nuse('soper')
   wmess('Нет отчетов',1)
   retu .t.
endif
do while otv=3
   kpsr=kps
   sktr=skt
   skltr=sklt
   amnr=amn
   sktpr=sktp
   skltpr=skltp
   amnpr=amnp
   kopr=kop
   vor=vo
   mnr=mn
   if sktpr=0.and.sktr#0
      ?str(mnr,6)+' '+'AMNP'+' '+str(amnpr,6)+'->'+str(amnr,6)+' '+'SKTP'+' '+str(sktpr,3)+'->'+str(sktr,3)+' '+'SKLTP'+' '+str(skltpr,7)+'->'+str(skltr,7)
      if aqstr=2
         netrepl('sktp,skltp,amnp,amn','sktr,skltr,amnr,0')
      endif
   endif

   qr=mod(kopr,100)
   sele soper
   netseek('t1','1,1,vor,qr')
   skt_r=ska
   sklt_r=kpsr

   sele pr1
   if skt_r#0
      if sktr#skt_r
         ?str(mnr,6)+' '+'SKT'+' '+str(sktr,3)+'->'+str(skt_r,3)+' '+'SKLT'+' '+str(skltr,7)+'->'+str(sklt_r,7)
         if aqstr=2
            netrepl('skt,sklt','skt_r,sklt_r')
         endif
      endif
   endif
   sele pr1
   skip
endd
nuse()
retu .t.
*************
func carsotv()
**************
pathr=path_tr
netuse('rs1',,,1)
go top
do while !eof()
   ttnr=ttn
   amnpr=amnp
   amnr=amn
   if amnpr=0.and.amnr#0
      ?'TTN'+' '+str(ttnr,6)+' AMNP '+str(amnpr,6)+'->'+str(amnr,6)
      if aqstr=2
         netrepl('amnp,amn','amnr,0')
      endif
   endif
   sele rs1
   skip
endd
nuse()
retu .t.
******************
func chkoto()
******************
mnprotr=val(nnzr)
*wmess('chkoto')
netuse('rs2','rs2co')
crtt('chkoto','f:ktl c:n(9) f:otv c:n(1) f:ktlm c:n(9) f:otvm c:n(1) f:kf c:n(12,3) f:rs c:n(12,3) f:rsm c:n(12,3) f:pr c:n(12,3) f:prm c:n(12,3) f:prot c:n(12,3) f:osvo c:n(12,3)')
sele 0
use chkoto excl
sele pr2
set orde to tag t1
if netseek('t1','mnr')
   do while mn=mnr
      ktlr=ktl
      ktlmr=ktlm
      kfr=kf
      otvr=getfield('t1','gnSkl,ktlr','tov','otv')
      otvmr=getfield('t1','gnSkl,ktlmr','tov','otv')
      sele chkoto
      netadd()
      netrepl('ktl,otv,ktlm,otvm,kf','ktlr,otvr,ktlmr,otvmr,kfr')
      sele pr2
      skip
   endd
endif
sele pr2
set orde to tag t1
if netseek('t1','mnprotr')
   do while mn=mnprotr
      ktlr=ktl
      kfr=kf
      osvor=getfield('t1','gnSkl,ktlr','tov','osvo')
      sele chkoto
      locate for ktl=ktlr
      if foun()
         netrepl('prot,osvo','prot+kfr,osvo+osvor')
      endif
      sele pr2
      skip
   endd
endif
sele chkoto
go top
do while !eof()
   ktlr=ktl
   ktlmr=ktlm
   sele rs2co
   set orde to tag t5 // amnp,ktl,ktlp
   rsmr=0
   if netseek('t5','mnr')
      do while amnp=mnr
         if ktlm=ktlmr
            rsmr=rsmr+kvp
         endif
         sele rs2co
         skip
      endd
   endif
   rsr=0
   if ktlr#ktlmr
      sele rs2co
      set orde to tag t6 // ktl,
      if netseek('t6','ktlr')
         do while ktl=ktlr
            ttn_r=ttn
            if ktlm=ktlmr.and.amnp=0
               rsr=rsr+kvp
            endif
            sele rs2co
            skip
         endd
      endif
   endif
   sele pr2
   set orde to tag t6 // ktl,
   prmr=0
   if netseek('t6','ktlmr')
      do while ktl=ktlmr
         mn_r=mn
         otv_r=getfield('t2','mn_r','pr1','otv')
         if ktl=ktlmr.and.mn_r#mnr.and.!(otv_r=1.or.otv_r=2)
            prmr=prmr+kf
         endif
         sele pr2
         skip
      endd
   endif
   sele pr2
   prr=0
   if netseek('t6','ktlr')
      do while ktl=ktlr
         mn_r=mn
         otv_r=getfield('t2','mn_r','pr1','otv')
         if ktl=ktlr.and.mn_r#mnr.and.!(otv_r=1.or.otv_r=2)
            prr=prr+kf
         endif
         sele pr2
         skip
      endd
   endif
   sele chkoto
   netrepl('rs,rsm,pr,prm','rsr,rsmr,prr,prmr')
   skip
endd

aqstr=1
if przr=0
   aqst:={"Просмотр","Коррекция"}
   aqstr:=alert(" ",aqst)
   if lastkey()=K_ESC
      aqstr=0
   endif
else
   aqstr=1
endif

if aqstr=2
   sele chkoto
   go top
   do while !eof()
      ktlr=ktl
      ktlmr=ktlm
      kfr=rsm
      sele pr2
      if netseek('t1','mnr,ktlr')
         if kfr#0
            netrepl('kf','kfr')
         else
            netdel()
         endif
      endif
      sele chkoto
      skip
   endd
endif
if aqstr=1
   sele chkoto
   go top
   rcchkr=recn()
   fldnomr=1
   do while .t.
      sele chkoto
      go rcchkr
      rcchkr=slce('chkoto',,,,,"e:ktl h:'ktl' c:n(9) e:otv h:'otv' c:n(1) e:ktlm h:'ktlm' c:n(9) e:otvm h:'otvm' c:n(1) e:kf h:'kf' c:n(12,3) e:rsm h:'rsm' c:n(12,3) e:rs h:'rs' c:n(12,3) e:pr h:'pr' c:n(12,3) e:prm h:'prm' c:n(12,3) e:prot h:'prot' c:n(12,3) e:osvo h:'osvo' c:n(12,3)")
      sele chkoto
      go rcchkr
      if lastkey()=K_ESC
         exit
      endif
      do case
         case lastkey()=19 // Left
              fldnomr=fldnomr-1
              if fldnomr=0
                 fldnomr=1
              endif
         case lastkey()=4 // Right
              fldnomr=fldnomr+1
      endc
   endd
endif
sele chkoto
use
nuse('rs2co')
retu .t.



