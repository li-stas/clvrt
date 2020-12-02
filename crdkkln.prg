// Коррекция DKKLN,DKKLNS,DKKLNA,DKKLNT,ZDOC,BS,DKNAP
// по прошлому месяцу
  if gnScOut=0
     clea
     aqstr=1
     aqst:={"Просмотр","Коррекция"}
     aqstr:=alert(;
     " Корр. оборотов "+SUBSTR(DMY(gdTd),4)+" DKKLN,DKKLNS,DKKLNA,DKKLNT,ZDOC,BS,DKNAP"+;
     "; перенос остактов с "+SUBSTR(DMY(ADDMONTH(gdTd,-1)),4),;
     aqst)
     if lastkey()=27
        retu
     endif
  else
     aqstr=2
  endif

  set print to crdkkln.txt
  set prin on
  netuse('kpl')
  netuse('kln')
  netuse('dokk')
  netuse('dokko')
  netuse('s_tag')
  netuse('operb')
  netuse('tmesto')
  netuse('nds')

  If UPPER("/mask4") $ UPPER(DOSPARAM())
    // удаление плательщиков на филиале, которые не зайдствованы
    aAlLst:={'dkkln','dkklns','dkklna','dkklnt','dkklnt'}
    FOR i:=1 TO LEN(aAlLst)
      netuse(aAlLst[i],'dkkln')
      DO WHILE !EOF()
        sele kpl
        IF !(netseek('t1','dkkln->kkl')) .or.  !(substr(kpl->crmsk,4,1)="1")
          sele dkkln
          netdel()
        ENDIF
        sele dkkln
        DBSKIP()
      ENDDO
      //return
      close dkkln
    NEXT
  EndIf


  ?'Копирование BS'
  netuse('bs')
  copy to lbs
  use
  sele 0
  use lbs alias bs excl
  repl all dp with db,kp with kr,db with 0,kr with 0
  inde on str(bs,6) tag t1




  ?'Копирование DKKLN'
  netuse('dkkln')
  copy to ldkkln
  use
  sele 0
  use ldkkln alias dkkln excl
  repl all dp with db,kp with kr,dpo with dbo,db with 0,kr with 0,dbo with 0
  inde on str(kkl,7)+str(bs,6)+str(skl,7) tag t1

  ?'Копирование NNDS'
  netuse('nnds')
  copy to lnnds
  use
  /*
  *sele 0
  *use lnnds alias nnds excl
  *zap
  *use
  */
  lindx('lnnds','nnds')
  luse('lnnds','nnds')
  /*
  *inde on str(nnds,10) tag t1
  *inde on str(mn,6)+str(rnd,6)+str(sk,3)+str(mnp,6) tag t2
  *inde on str(kkl,7)+str(nnds,10) tag t3
  */
  ?'Копирование CNTM'
  netuse('cntm')
  copy to lcntm
  use
  sele 0
  use lcntm alias cntm excl
  if recc()=0
     netadd()
  endif

  ?'Копирование DKNAP'
  netuse('dknap')
  copy to ldknap
  use
  sele 0
  use ldknap alias dknap excl
  repl all dp with db,kp with kr,dpo with dbo,db with 0,kr with 0,dbo with 0
  inde on str(kkl,7)+str(bs,6)+str(skl,7) tag t1
  inde on str(kkl,7)+str(bs,6)+dtos(ddb) tag t2

  if .f.
     ?'Копирование DKKLNS'
     netuse('dkklns')
     copy to ldkklns
     use
     sele 0
     use ldkklns alias dkklns excl
     repl all dp with db,kp with kr,dpo with dbo,db with 0,kr with 0,dbo with 0
     inde on str(kkl,7)+str(bs,6)+str(skl,7) tag t1

     ?'Копирование DKKLNA'
     netuse('dkklna')
     copy to ldkklna
     use
     sele 0
     use ldkklna alias dkklna excl
     repl all dp with db,kp with kr,dpo with dbo,db with 0,kr with 0,dbo with 0
     inde on str(kkl,7)+str(bs,6)+str(skl,7) tag t1
  /*
  *   ?'Копирование ZDOC'
  *   netuse('zdoc')
  *   if fieldpos('dbc')=0
  *      copy to lzdoc for !(dn=0.and.kn=0.and.db=0.and.dbo=0.and.kr=0.and.ttn#0)
  *   else
  *      copy to lzdoc for !(dn=0.and.kn=0.and.db=0.and.dbo=0.and.kr=0.and.dbc=0.and.krc=0.and.ttn#0)
  *   endif
  *   use
  *   lindx('lzdoc','zdoc')
  *   sele 0
  *   use lzdoc alias zdoc excl
  *   repl all dp with db,kp with kr,dpo with dbo,db with 0,kr with 0,dbo with 0
  *   if fieldpos('dbc')#0
  *      repl all krc with 0,dbc with 0
  *   endif
  */
  endif

  if gnScOut=0
     clea
  endif
   // *DOKK
  ldokk()
   //*DOKKO
  ldokko()

  nuse('dkkln')
  nuse('dknap')
  nuse('bs')
  nuse('nnds')

  /*
  *nuse('dkklna')
  *nuse('zdoc')
  *nuse('dokkp')
  */

  netuse('dkkln')
  netuse('dknap')
  netuse('bs')

  /*
  *netuse('dkklns')
  *netuse('dkklna')
  *netuse('zdoc')
  */

  luse('lbs')
  luse('ldkkln')
  luse('ldknap')

  ldknap()

  /*
  *luse('ldkklns')
  *luse('ldkklna')
  *luse('lzdoc')
  */

  dtpr:=addmonth(gdTd,-1)
  pathpr:=gcPath_e+'g'+str(year(dtpr),4)+'/m'+iif(month(dtpr)<10,'0'+str(month(dtpr),1),str(month(dtpr),2))+'\bank\'
  pathr:=pathpr

// Остатки на начало DKKLN,DKKLNS,DKKLNA,DKKLNT
  for idk=1 to 1 //4
      do case
         case idk=1
              aldkr='dkkln'
         case idk=2
              aldkr='dknap'
         case idk=3
              aldkr='dkklns'
         case idk=4
              aldkr='dkklna'
      endcase
      if netfile(aldkr,1)
         netuse(aldkr,'dkp',,1)
         prbegr=0 // Пока нет оборот по кред
         if idk=1
            prbegr=1
         else
            sele dkp
            locate for kr#0
            if foun()
               prbegr=1
            endif
         endif
         if prbegr=1

            sele dkp
            go top
            do while !eof()
               kklr=kkl
               bsr=bs
               sklr=skl
               saldor=dn-kn+db-kr
               store 0 to dnr,knr
               if saldor>0
                  dnr=saldor
               endif
               if saldor<0
                  knr=abs(saldor)
               endif
               sele ('l'+aldkr)
               if !netseek('t1','kklr,bsr,sklr')
                  if saldor#0
                     netadd()
                     netrepl('kkl,bs,skl','kklr,bsr,sklr')
                  else
                     sele dkp
                     skip
                     loop
                  endif
               endif
               netrepl('dn,kn','dnr,knr')
               sele dkp
               skip
            endd

            sele ('l'+aldkr)
            DBGoTop()
            Do While !Eof()
              kklr=kkl
              bsr=bs
              sklr=skl
              sele dkp //пред месяц
              // нет данных
              if !netseek('t1','kklr,bsr,sklr')
                // обнули Нач. Мес.
                 sele ('l'+aldkr)
                 netrepl('dn,kn','0,0')
              endif
              sele ('l'+aldkr)
              skip
            EndDo
         endif
         nuse('dkp')
      endif
  next

?'BS'
  sele lbs
  go top
  do while !eof()
     bsr=bs
     dbr=db
     krr=kr
     dpr=dp
     kpr=kp
     sele bs
     if netseek('t1','bsr')
        if !(db=dpr.and.kr=kpr)
           ?str(bsr,6)+' Изменились данные'
        else
           if !(db=dbr.and.kr=krr)
              ?str(bsr,6)
              ?'ДТ  '+str(db,12,2)+ ' ДР  '+str(dbr,12,2)
              ?'КТ  '+str(kr,12,2)+ ' КР  '+str(krr,12,2)
           endif
           if aqstr=2
              sele bs
              netrepl('db,kr','dbr,krr')
           endif
        endif
     else
        ?str(bsr,6)+' Не найден'
     endif
     sele lbs
     skip
  endd
sele bs
go top
do while !eof()
  if !(dn=0.and.kn=0)
    skip
    loop
  endif
  bsr=bs
  sele lbs
  if !netseek('t1','bsr')
    sele bs
    ?str(bsr,6)+' Нет оборотов'
    ?'ДТ  '+str(db,12,2)+ ' ДР  '+str(0,12,2)
    ?'КТ  '+str(kr,12,2)+ ' КР  '+str(0,12,2)
    if aqstr=2
        netrepl('db,kr','0,0')
    endif
  endif
  sele bs
  skip
endd

// Коррекция DKKLN,DKKLNS,DKKLNA,DKNAP
  for idk=1 to 2 //4
    do case
    case idk=1
        inr='ldkkln'
        outr='dkkln'
        ?'DKKLN'
    case idk=2
        inr='ldknap'
        outr='dknap'
        ?'DKNAP'
    case idk=3
        inr='ldkklns'
        outr='dkklns'
        ?'DKKLNS'
    case idk=4
        inr='ldkklna'
        outr='dkklna'
        ?'DKKLNA'
    endcase

     // inr='ldkkln'  // outr='dkkln'
    sele (inr)
    go top
    do while !eof()
      kklr=kkl
      bsr=bs
      sklr=skl
      dnr=dn
      knr=kn
      dpr=dp
      kpr=kp
      dbr=db
      krr=kr
      ddbr=ddb
      dkrr=dkr
      dbor=dbo
      ddbor=ddbo
      dpor=dpo
      sele (outr)
      seek str(kklr,7)+str(bsr,6)+str(sklr,7)
      if foun()
        if !(db=dpr.and.kr=kpr.and.dbo=dpor)
            ?str(kklr,7)+' '+str(bsr,6)+' '+str(sklr,7)+' Изменились данные'
        else
            if !(db=dbr.and.kr=krr.and.dbo=dbor)
              ?str(kklr,7)+' '+str(bsr,6)+' '+str(sklr,7)
              ?'ДТ  '+str(db,12,2)+ ' ДР  '+str(dbr,12,2)
              ?'КТ  '+str(kr,12,2)+ ' КР  '+str(krr,12,2)
              ?'ДТO '+str(dbo,12,2)+' ДРO '+str(dbor,12,2)
            endif
            if aqstr=2
              sele (outr)
              netrepl('db,kr,ddb,dkr,dbo,ddbo','dbr,krr,ddbr,dkrr,dbor,ddbor')
            endif
            if !(dn=dnr.and.kn=knr).and.idk#2
              ?str(kklr,7)+' '+str(bsr,6)+' '+str(sklr,7)
              ?'ДНТ '+str(dn,12,2)+' ДНР '+str(dnr,12,2)
              ?'КНТ '+str(kn,12,2)+' КНР '+str(knr,12,2)
            endif
            if aqstr=2
              sele (outr)
              netrepl('dn,kn','dnr,knr')
            endif
        endif
      else
        ?str(kklr,7)+' '+str(bsr,6)+' '+str(sklr,7)+' Не найден'
        if aqstr=2
            sele (outr)
            netadd()
            netrepl('kkl,bs,db,kr,skl,ddb,dkr,dn,kn,dbo,ddbo','kklr,bsr,dbr,krr,sklr,ddbr,dkrr,dnr,knr,dbor,ddbor')
        endif
      endif
      sele (inr)
      skip
    enddo
    // inr='ldkkln'            // outr='dkkln'
    sele (outr)
    go top
    do while !eof()
        kklr=kkl
        bsr=bs
        sklr=skl
        dnr=dn
        knr=kn
        dpr=dp
        kpr=kp
        dbr=db
        krr=kr

        if !(dnr=0.and.knr=0);  skip;  loop;       endif

        sele (inr)
        seek str(kklr,7)+str(bsr,6)+str(sklr,7)
        if !foun()
          sele (outr)
          netdel()
          ?str(kklr,7)+' '+str(bsr,6)+' '+str(sklr,7)+' Удален'
        endif
        sele (outr)
        skip
        loop
    endd
  next

if .f.
   * На начало ZDOC
   #ifdef __CLIP__
   #else
   pathr=pathpr
   if netfile('zdoc',1) //.and..f. // Временно закрыто,пока не закр док
      netuse('zdoc','zdocp',,1)
      go top
      do while !eof()
         if prz=2
            skip
            loop
         endif
         kklr=kkl
         bsr=bs
         skr=sk
         ttnr=ttn
         dn_r=dn
         kn_r=kn
         db_r=db
         kr_r=kr
         dbo_r=dbo
         if fieldpos('dbc')#0
            dbc_r=dbc
            krc_r=krc
         else
            dbc_r=dbc
            krc_r=krc
         endif
         saldor=dn_r-kn_r+db_r-kr_r+dbo_r+dbc_r-krc_r
         store 0 to dnr,knr
         if saldor>0
            dnr=saldor
         endif
         if saldor<0
            knr=abs(saldor)
         endif
         sele lzdoc
         if !netseek('t1','kklr,bsr,skr,ttn')
            if saldor#0
               netadd()
               netrepl('kkl,bs,skl','kklr,bsr,sklr')
            else
               sele zdocp
               skip
               loop
            endif
         endif
         netrepl('dn,kn','dnr,knr')
         sele zdocp
         skip
      endd
      nuse('zdocp')
   endif
   #endif
   * Коррекция ZDOC
   ?'ZDOC'
   sele lzdoc
   go top
   do while !eof()
      kklr=kkl
      bsr=bs
      skr=sk
      ttnr=ttn
      dbr=db
      dtdbr=dtdb
      if fieldpos('dbc')#0
         dbcr=dbc
         dtdbcr=dtdbc
         krcr=krc
         dtkrcr=dtkrc
      else
         dbcr=0
         dtdbcr=ctod('')
         krcr=0
         dtkrcr=ctod('')
      endif
      krr=kr
      dtkrr=dtkr
      dbor=dbo
      dtdbor=dtdbo
      dnr=dn
      knr=kn
      dpr=dp
      kpr=kp
      dpor=dpo
      ktar=kta
      ktasr=ktas
      tmestor=tmesto
      vor=vo
      kopr=kop
      rmskr=rmsk
      przr=prz
      sele zdoc
      if netseek('t1','kklr,bsr,skr,ttnr')
         if !(db=dpr.and.kr=kpr.and.dbo=dpor)
            ?str(kklr,7)+' '+str(bsr,6)+' '+str(skr,3)+' '+str(ttnr,6)+' Изменились данные'
         else
            if !(db=dbr.and.kr=krr.and.dbo=dbor)
               ?str(kklr,7)+' '+str(bsr,6)+' '+str(skr,3)+' '+str(ttnr,6)
               ?'ДТ  '+str(db,12,2)+ ' ДР  '+str(dbr,12,2)
               ?'КТ  '+str(kr,12,2)+ ' КР  '+str(krr,12,2)
               ?'ДТO '+str(dbo,12,2)+' ДРO '+str(dbor,12,2)
               if aqstr=2
                  sele zdoc
                  netrepl('db,kr,dtdb,dtkr,dbo,dtdbo,kta,ktas,tmesto',;
                          'dbr,krr,dtdbr,dtkrr,dbor,dtdbor,ktar,ktasr,tmestor')
               endif
            endif
            if fieldpos('dbc')#0
               if dbc#dbcr
                  ?str(kklr,7)+' '+str(bsr,6)+' '+str(skr,3)+' '+str(ttnr,6)
                  ?'ДCТ '+str(dbc,12,2)+' ДCР '+str(dbcr,12,2)
                  if aqstr=2
                    sele zdoc
                     netrepl('dbc,dtdbc','dbcr,dtdbcr')
                  endif
               endif
               if krc#krcr
                  ?str(kklr,7)+' '+str(bsr,6)+' '+str(skr,3)+' '+str(ttnr,6)
                  ?'KCТ '+str(krc,12,2)+' KCР '+str(krcr,12,2)
                  if aqstr=2
                     sele zdoc
                     netrepl('krc,dtkrc','krcr,dtkrcr')
                  endif
               endif
            endif
            if !(dn=dnr.and.kn=knr)
               ?str(kklr,7)+' '+str(bsr,6)+' '+str(skr,3)+' '+str(ttnr,6)
               ?'ДНТ '+str(dn,12,2)+' ДНР '+str(dnr,12,2)
               ?'КНТ '+str(kn,12,2)+' КНР '+str(knr,12,2)
               if aqstr=2
                  sele zdoc
                  netrepl('dn,kn','dnr,knr')
               endif
            endif
            if aqstr=2
               sele zdoc
               netrepl('kta,ktas,tmesto,vo,kop,rmsk,prz',;
                       'ktar,ktasr,tmestor,vor,kopr,rmskr,przr')
            endif
         endif
      else
         ?str(kklr,7)+' '+str(bsr,6)+' '+str(skr,7)+' '+str(ttnr,6)+' Не найден'
         if aqstr=2
            sele zdoc
            netadd(1)
            netrepl('kkl,bs,db,kr,sk,ttn,dtdb,dtkr,dn,kn,dbo,dtdbo,kta,ktas,tmesto,vo,kop,rmsk,prz',;
                    'kklr,bsr,dbr,krr,skr,ttnr,dtdbr,dtkrr,dnr,knr,dbor,dtdbor,ktar,ktasr,tmestor,vor,kopr,rmskr,przr')
            if fieldpos('dbc')#0
               sele zdoc
               netrepl('dbc,dtdbc','dbcr,dtdbcr')
            endif
         endif
      endif
      sele lzdoc
      skip
   endd
   * Временно, пока нет закрытия документов
   sele zdoc
   go top
   do while !eof()
      kklr=kkl
      bsr=bs
      skr=sk
      ttnr=ttn
      sele lzdoc
      if !netseek('t1','kklr,bsr,skr,ttnr')
         ?str(kklr,7)+' '+str(bsr,6)+' '+str(skr,3)+' '+str(ttnr,6)+' Нет в текущем удален'
         if aqstr=2
            sele zdoc
            netdel()
         endif
      endif
      sele zdoc
      skip
   endd
endif

nuse()
nuse('lbs')
nuse('ldkkln')
nuse('ldknap')
*nuse('ldkklns')
*nuse('ldkklna')
*nuse('lzdoc')

erase lbs.dbf
erase lbs.cdx
*erase ldkkln.dbf
*erase ldkkln.cdx
*erase ldknap.dbf
*erase ldknap.cdx
erase ldkklns.dbf
erase ldkklns.cdx
erase ldkklna.dbf
erase ldkklna.cdx
*erase lzdoc.dbf
*erase lzdoc.cdx


set prin off
set prin to
if gnOut=2
   set prin to txt.txt
endif
wmess('Проверка закончена',0)

******************
func ldokk(p1)
* p1=1 только 361
******************

store ctod('') to ddkr,ddbr
sele dokk
if gnScOut=0.and.empty(p1)
   @ 1,1 say str(recc(),10)
endif
go top
n_nnn=0
n_nn=0
do while !eof()
   sele dokk
   if gnScOut=0.and.empty(p1)
      if n_nn=1000
         n_nnn=n_nnn+1000
         @ 2,1 say str(n_nnn,10)
         n_nn=0
      endif
      @ 2,1 say str(n_nnn,10)
      n_nn=n_nn+1
   endif
   if prc
      skip
      loop
   endif
   if empty(p1)
   else
      if int(bs_d/1000)=361.or.int(bs_k/1000)=361.or.bs_d=641002.or.bs_k=641002
      else
         skip
         loop
      endif
   endif
   if bs_d<1000.or.bs_k<1000
      skip
      loop
   endif
   kklr=kkl
   pr1ndsr=getfield('t1','kklr','kpl','pr1nds')
   kopr=kop
   sklr=skl
   bs_sr=bs_s
   bs_dr=bs_d
   bs_kr=bs_k
   ddkr=ddk
   ktar=kta
   ktasr=ktas
   tmestor=tmesto
   if fieldpos('nap')#0
      napr=nap
   else
      napr=0
   endif
   if ktar#0.and.ktasr=0
      ktas_r=getfield('t1','ktar','s_tag','ktas')
      if ktasr#ktas_r
         netrepl('ktas','ktas_r')
         ktasr=ktas
      endif
   endif
   skr=sk
   dokkmskr=dokkmsk
   msk(1,0)
   sele dokk
   skip
endd
retu .t.

******************
func ldokko(p1)
* p1=1 только 361
******************
sele dokko
if gnScOut=0.and.empty(p1)
   @ 1,1 say str(recc(),10)
endif
go top
n_nnn=0
n_nn=0
do while !eof()
   if gnScOut=0.and.empty(p1)
      if n_nn=1000
         n_nnn=n_nnn+1000
         @ 2,1 say str(n_nnn,10)
         n_nn=0
      endif
      @ 2,1 say str(n_nnn,10)
      n_nn=n_nn+1
   endif
   if prc
      skip
      loop
   endif
   if bs_d<1000.or.bs_k<1000
      skip
      loop
   endif
   msk(1,1)
   sele dokko
   skip
endd
retu .t.

*******************
func ksfin()
* Контрольная сумма
*******************
clea
crtt('ksfin','f:rmsk c:n(1) f:bs c:n(6) f:dn c:n(12,2) f:kn c:n(12,2) f:db c:n(12,2) f:kr c:n(12,2) f:dk c:n(12,2) f:kk c:n(12,2)')
sele 0
use ksfin
netuse('kpl')
netuse('dokk')
go top
do while !eof()
   if !(int(bs_d/1000)=361.or.int(bs_k/1000)=361.or.int(bs_d/1000)=301.or.int(bs_k/1000)=301.or.int(bs_d/1000)=311.or.int(bs_k/1000)=311)
      skip
      loop
   endif
   rmskr=rmsk
   bs_dr=bs_d
   bs_kr=bs_k
   bs_sr=bs_s
   kklr=kkl
   mnr=mn
   if rmskr=0.and.mnr#0
      crmskr=getfield('t1','kklr','kpl','crmsk')
      if bs_dr=301001.or.bs_kr=301001
         rmskr=0
      else
         do case
            case subs(crmskr,3,1)='1'
                 rmskr=3
            case subs(crmskr,4,1)='1'
                 rmskr=4
            case subs(crmskr,5,1)='1'
                 rmskr=5
            case subs(crmskr,6,1)='1'
                 rmskr=6
             othe
                 rmskr=0
         endcase
      endif
   endif
   if int(bs_d/1000)=361.or.int(bs_d/1000)=301.or.int(bs_d/1000)=311
      bsr=bs_dr
      sele ksfin
      locate for rmsk=rmskr.and.bs=bsr
      if !foun()
         appe blank
         repl rmsk with rmskr,;
              bs with bsr
      endif
      repl db with db+bs_sr
   endif
   sele dokk
   if int(bs_k/1000)=361.or.int(bs_k/1000)=301.or.int(bs_k/1000)=311
      bsr=bs_kr
      sele ksfin
      locate for rmsk=rmskr.and.bs=bsr
      if !foun()
         appe blank
         repl rmsk with rmskr,;
              bs with bsr
      endif
      repl kr with kr+bs_sr
   endif
   sele dokk
   skip
endd
sele ksfin
inde on str(rmsk,1)+str(bs,6) tag t1
go top
rcskfinr=slcf('ksfin',1,,18,,"e:rmsk h:'R' c:n(1) e:bs h:'Счет' c:n(6) e:db h:'Дебет' c:n(12,2) e:kr h:'Кредит' c:n(12,2)",,,,,,,'Контрольные суммы')
sele ksfin
use
nuse()
retu .t.

***************
func crklnprd()
***************
if gnScOut=0
   clea
   store gdTd to dt1r,dt2r
   bs_r=0
   clr=setcolor('gr+/b,n/bg')
   wr=wopen(8,20,12,60)
   wbox(1)
   @ 0,1 say 'Период с ' get dt1r
   @ 0,col()+1 say ' по ' get dt2r
   @ 1,1 say 'Счет     ' get bs_r pict '999999'
   read
   wbox(1)
   wclose(wr)
   setcolor(clr)
   if lastkey()=27.or.empty(dt1r).or.empty(dt2r).or.dt2r<dt1r
      retu .t.
   endif

   aqstr=1
   aqst:={"Просмотр","Коррекция"}
   aqstr:=alert(" ",aqst)
   if lastkey()=27
      retu .t.
   endif
else
   aqstr=2
endif

set print to crklnptd.txt
set prin on
for yyr=year(dt1r) to year(dt2r)
    pathgr=gcPath_e+'g'+str(yyr,4)+'\'
    do case
       case year(dt1r)=year(dt2r)
            mm1r=month(dt1r)
            mm2r=month(dt2r)
       case yyr=year(dt1r)
            mm1r=month(dt1r)
            mm2r=12
       case yyr=year(dt2r)
            mm1r=1
            mm2r=month(dt2r)
       othe
            mm1r=1
            mm2r=12
    endcase
    for mmr=mm1r to mm2r
        dtr=ctod('01.'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'.'+str(yyr,4))
        dtpr=addmonth(dtr,-1)
        pathmpr=gcPath_e+'g'+str(year(dtpr),4)+'\m'+iif(month(dtpr)<10,'0'+str(month(dtpr),1),str(month(dtpr),2))+'\'
        pathmr=pathgr+'m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'
        pathbr=pathmr+'bank\'
        ?pathbr
        pathbpr=pathmpr+'bank\'
        prchekr=1
        pathr=pathbr
        if !netfile('dkkln',1)
           prchekr=0
        endif
        pathr=pathbpr
        if !netfile('dkkln',1)
           prchekr=0
        endif
        if prchekr=1
           pathr=pathbr
           netuse('dknap',,,1)
           netuse('dkkln',,,1)
           pathr=pathbpr
           netuse('dkkln','dkklnp',,1)
           sele dkklnp
           go top
           do while !eof()
              kklr=kkl
              if kklr=0
                 sele dkklnp
                 skip
                 loop
              endif
              bsr=bs
              if bs_r#0
                 if bs_r#bsr
                    sele dkklnp
                    skip
                    loop
                 endif
              endif
              sklr=skl
              dn_r=dn
              kn_r=kn
              db_r=db
              kr_r=kr
              saldor=dn_r-kn_r+db_r-kr_r
              store 0 to dnr,knr
              if saldor<0
                 knr=abs(saldor)
              else
                 dnr=saldor
              endif
              sele dkkln
              if !netseek('t1','kklr,bsr,sklr',,,1)
                 if saldor#0
                    ?str(kklr,7)+' '+str(bsr,6)+' '+str(sklr,7)+' '+'нет в текущем'
                    if aqstr=2
                       netadd()
                       netrepl('kkl,bs,skl,dn,kn','kklr,bsr,sklr,dnr,knr')
                    endif
                 endif
              else
                 if str(dn,15,2)#str(dnr,15,2).or.str(kn,15,2)#str(knr,15,2)
                    ?str(kklr,7)+' '+str(bsr,6)+' '+str(sklr,7)
                    ?'DNT'+' '+str(dn,12,2)+' '+'DNP'+' '+str(dnr,12,2)
                    ?'KNT'+' '+str(kn,12,2)+' '+'KNP'+' '+str(knr,12,2)
                    if aqstr=2
                       netrepl('dn,kn','dnr,knr')
                    endif
                 endif
              endif
              sele dkklnp
              skip
           endd
           sele dkkln
           go top
           do while !eof()
              if dn=0.and.kn=0
                 sele dkkln
                 skip
                 loop
              endif
              kklr=kkl
              if kklr=0
                 sele dkkln
                 skip
                 loop
              endif
              bsr=bs
              if bs_r#0
                 if bs_r#bsr
                    sele dkkln
                    skip
                    loop
                 endif
              endif
              sklr=skl
              sele dkklnp
*if kklr=1005122.and.bsr=361001
*wait
*endif
              if !netseek('t1','kklr,bsr,sklr',,,1)
                 ?str(kklr,7)+' '+str(bsr,6)+' '+str(sklr,7)+' '+'нет в прошлом'
                 if aqstr=2
                    sele dkkln
                    netrepl('dn,kn','0,0')
                 endif
              endif
              sele dkkln
              skip
           endd
           nuse('dkkln')
           nuse('dknap')
           nuse('dkklnp')
        endif
    next
next
set prin off
set prin to
retu .t.

***************
func crdokk3()
***************
netuse('cskl')
crtt('tsk','f:sk c:n(3)')
sele 0
use tsk excl
if gnScOut=0
   clea
   store gdTd to dt1r,dt2r
   clr=setcolor('gr+/b,n/bg')
   wr=wopen(8,20,11,60)
   wbox(1)
   @ 0,1 say 'Период с ' get dt1r
   @ 0,col()+1 say ' по ' get dt2r
   read
   wbox(1)
   wclose(wr)
   setcolor(clr)
   if lastkey()=27.or.empty(dt1r).or.empty(dt2r).or.dt2r<dt1r
      retu .t.
   endif

   aqstr=1
   aqst:={"Просмотр","Коррекция"}
   aqstr:=alert(" ",aqst)
   if lastkey()=27
      retu .t.
   endif
else
   aqstr=2
endif

set print to crdokk3.txt
set prin on
for yyr=year(dt1r) to year(dt2r)
    pathgr=gcPath_e+'g'+str(yyr,4)+'\'
    do case
       case year(dt1r)=year(dt2r)
            mm1r=month(dt1r)
            mm2r=month(dt2r)
       case yyr=year(dt1r)
            mm1r=month(dt1r)
            mm2r=12
       case yyr=year(dt2r)
            mm1r=1
            mm2r=month(dt2r)
       othe
            mm1r=1
            mm2r=12
    endcase
    for mmr=mm1r to mm2r
        dtr=ctod('01.'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'.'+str(yyr,4))
        dtpr=addmonth(dtr,-1)
        pathmpr=gcPath_e+'g'+str(year(dtpr),4)+'\m'+iif(month(dtpr)<10,'0'+str(month(dtpr),1),str(month(dtpr),2))+'\'
        pathmr=pathgr+'m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'
        pathr=pathmr+'bank\'
        ?pathr
        if !netfile('dokk',1)
           loop
        endif
        netuse('dokk',,,1)
        netuse('dokko',,,1)
        sele tsk
        zap
        sele dokk
        if netseek('t1','0')
           do while mn=0
              if !(rn#0.and.sk#0)
                 skip
                 if eof()
                    exit
                 endif
                 loop
              endif
              if !(int(bs_d/1000)=361.or.int(bs_k/1000)=361001)
                 skip
                 if eof()
                    exit
                 endif
                 loop
              endif
              rnr=rn
              mnpr=mnp
              skr=sk
              if mnpr=0
                 tbl_r='rs'+str(skr,3)
                 tbl_rr='rs1'
              else
                 tbl_r='pr'+str(skr,3)
                 tbl_rr='pr1'
              endif
              if select(tbl_r)=0
                 pathr=pathmr+alltrim(getfield('t1','skr','cskl','path'))
                 netuse(tbl_rr,tbl_r,,1)
                 sele tsk
                 locate for sk=skr
                 if !foun()
                    appe blank
                    repl sk with skr
                 endif
              endif
              sele (tbl_r)
              netseek('t1','rnr')
              napr=nap
              if napr#0
                 sele dokk
                 if nap#napr.and.(int(bs_d/1000)=361.or.int(bs_k/1000)=361)
                    ?str(sk,3)+' '+str(rn,6)+' '+str(nap,4)+'->'+str(napr,4)
                    if aqstr=2
                       netrepl('nap','napr')
                    endif
                 endif
              endif
              sele dokk
              skip
           endd
        endif
        sele dokk
        set orde to tag t10
        if netseek('t10','20034,301000',,'3')
           do while kkl=20034.and.int(bs_d/1000)=301
              if dokkttn=0.or.dokksk=0
                 skip
                 if eof()
                    exit
                 endif
                 loop
              endif
              rnr=dokkttn
              skr=dokksk
              tbl_r='rs'+str(skr,3)
              tbl_rr='rs1'
              if select(tbl_r)=0
                 pathr=pathmr+alltrim(getfield('t1','skr','cskl','path'))
                 netuse(tbl_rr,tbl_r,,1)
                 sele tsk
                 locate for sk=skr
                 if !foun()
                    appe blank
                    repl sk with skr
                 endif
              endif
              sele (tbl_r)
              netseek('t1','rnr')
              napr=nap
              if napr#0
                 sele dokk
                 if nap#napr
                    ?str(sk,3)+' '+str(rn,6)+' '+str(nap,4)+'->'+str(napr,4)
                    if aqstr=2
                       netrepl('nap','napr')
                    endif
                 endif
              endif
              sele dokk
              skip
           endd
        endif
        sele dokk
        set orde to tag t1
        sele dokko
        if netseek('t1','0')
           do while mn=0
              if !(rn#0.and.sk#0)
                 skip
                 if eof()
                    exit
                 endif
                 loop
              endif
              if !(int(bs_d/1000)=361.or.int(bs_k/1000)=361001)
                 skip
                 if eof()
                    exit
                 endif
                 loop
              endif
              rnr=rn
              mnpr=mnp
              skr=sk
              if mnpr=0
                 tbl_r='rs'+str(skr,3)
                 tbl_rr='rs1'
              else
                 tbl_r='pr'+str(skr,3)
                 tbl_rr='pr1'
              endif
              if select(tbl_r)=0
                 pathr=pathmr+alltrim(getfield('t1','skr','cskl','path'))
                 netuse(tbl_rr,tbl_r,,1)
                 sele tsk
                 loca for sk=skr
                 if !foun()
                    appe blank
                    repl sk with skr
                 endif
              endif
              sele (tbl_r)
              netseek('t1','rnr')
              napr=nap
              if napr#0
                 sele dokko
                 if nap#napr.and.(int(bs_d/1000)=361.or.int(bs_k/1000)=361)
                    ?str(sk,3)+' '+str(rn,6)+' '+str(nap,4)+'->'+str(napr,4)
                    if aqstr=2
                       netrepl('nap','napr')
                    endif
                 endif
              endif
              sele dokko
              skip
           endd
        endif
        sele tsk
        go top
        do while !eof()
           skr=sk
           tbl_r='rs'+str(skr,3)
           nuse(tbl_r)
           tbl_r='pr'+str(skr,3)
           nuse(tbl_r)
           sele tsk
           skip
        endd
        nuse('dokk')
        nuse('dokko')
    next
next
sele tsk
use
erase tsk.dbf
retu .t.

***********************************
func crdkx()
* Коррекция DKKLN,DKNAP за период
***********************************
netuse('s_tag')
netuse('nap')
netuse('kpl')

if gnScOut=0
   clea
   store gdTd to dt1r,dt2r
*   bs_r=0
   clr=setcolor('gr+/b,n/bg')
   wr=wopen(8,20,11,60)
   wbox(1)
   @ 0,1 say 'Период с ' get dt1r
   @ 0,col()+1 say ' по ' get dt2r
*   @ 1,1 say 'Счет     ' get bs_r
   read
   wbox(1)
   wclose(wr)
   setcolor(clr)
   if lastkey()=27.or.empty(dt1r).or.empty(dt2r).or.dt2r<dt1r
      retu .t.
   endif
endif

set print to crdkx.txt
set prin on
for yyr=year(dt1r) to year(dt2r)
    pathgr=gcPath_e+'g'+str(yyr,4)+'\'
    do case
       case year(dt1r)=year(dt2r)
            mm1r=month(dt1r)
            mm2r=month(dt2r)
       case yyr=year(dt1r)
            mm1r=month(dt1r)
            mm2r=12
       case yyr=year(dt2r)
            mm1r=1
            mm2r=month(dt2r)
       othe
            mm1r=1
            mm2r=12
    endcase
    for mmr=mm1r to mm2r
        dtr=ctod('01.'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'.'+str(yyr,4))
        dtpr=addmonth(dtr,-1)
        pathmpr=gcPath_e+'g'+str(year(dtpr),4)+'\m'+iif(month(dtpr)<10,'0'+str(month(dtpr),1),str(month(dtpr),2))+'\'
        pathmr=pathgr+'m'+iif(mmr<10,'0'+str(mmr,1),str(mmr,2))+'\'
        pathr=pathmr+'bank\'
        ?pathr
        if !netfile('dokk',1)
           loop
        endif
        netuse('dokk',,,1)
        netuse('dokko',,,1)

*        ?'Копирование DKKLN'
        netuse('dkkln',,,1)
        copy to ldkkln for int(bs/1000)=361
        use
        sele 0
        use ldkkln alias dkkln excl
        repl all dp with db,kp with kr,dpo with dbo,db with 0,kr with 0,dbo with 0
        inde on str(kkl,7)+str(bs,6)+str(skl,7) tag t1

*        ?'Копирование DKNAP'
        netuse('dknap',,,1)
        copy to ldknap
        use
        sele 0
        use ldknap alias dknap excl
        repl all dp with db,kp with kr,dpo with dbo,db with 0,kr with 0,dbo with 0
        inde on str(kkl,7)+str(bs,6)+str(skl,7) tag t1
        inde on str(kkl,7)+str(bs,6)+dtos(ddb) tag t2

        *Постоение оборотов в LDKKLN,LDKNAP
        ldokk(1)
        ldokko(1)

        nuse('dkkln')
        nuse('dknap')

        * Закрытие направлений
        luse('ldkkln')
        luse('ldknap')
        ldknap()

        * Остатки на начало LDKKLN,LDKNAP
        for idk=1 to 2
            do case
               case idk=1
                    aldkr='dkkln'
               case idk=2
                    aldkr='dknap'
            endcase
            pathr=pathmpr+'bank\'
            if netfile(aldkr,1)
               netuse(aldkr,'dkp',,1)
               prbegr=0 // Пока нет оборот по кред
               sele dkp
               locate for kr#0
               if foun()
                  prbegr=1
               endif
               if prbegr=1
                  sele dkp
                  go top
                  do while !eof()
                     if int(bs/1000)#361
                        skip
                        loop
                     endif
                     kklr=kkl
                     bsr=bs
                     sklr=skl
                     saldor=dn-kn+db-kr
                     store 0 to dnr,knr
                     if saldor>0
                        dnr=saldor
                     endif
                     if saldor<0
                        knr=abs(saldor)
                     endif
                     sele ('l'+aldkr)
                     if !netseek('t1','kklr,bsr,sklr')
                        if saldor#0
                           netadd()
                           netrepl('kkl,bs,skl','kklr,bsr,sklr')
                        else
                           sele dkp
                           skip
                           loop
                        endif
                     endif
                     netrepl('dn,kn','dnr,knr')
                     sele dkp
                     skip
                  endd
               endif
               nuse('dkp')
            endif
        next

        * Коррекция DKKLN,DKNAP из LDKKLN,LDKNAP
        pathr=pathmr+'bank\'
        netuse('dkkln',,,1)
        netuse('dknap',,,1)

        for idk=1 to 2
            do case
               case idk=1
                    inr='ldkkln'
                    outr='dkkln'
                    ?'DKNAP'
               case idk=2
                    inr='ldknap'
                    outr='dknap'
                    ?'DKNAP'
            endcase
            sele (inr)
            go top
            do while !eof()
               kklr=kkl
               bsr=bs
               sklr=skl
               dnr=dn
               knr=kn
               dpr=dp
               kpr=kp
               dbr=db
               krr=kr
               ddbr=ddb
               dkrr=dkr
               dbor=dbo
               ddbor=ddbo
               dpor=dpo
               sele (outr)
               seek str(kklr,7)+str(bsr,6)+str(sklr,7)
               if foun()
                  if !(db=dpr.and.kr=kpr.and.dbo=dpor)
                     ?str(kklr,7)+' '+str(bsr,6)+' '+str(sklr,7)+' Изменились данные'
                  else
                     if !(db=dbr.and.kr=krr.and.dbo=dbor)
                        ?str(kklr,7)+' '+str(bsr,6)+' '+str(sklr,7)
                        ?'ДТ  '+str(db,12,2)+ ' ДР  '+str(dbr,12,2)
                        ?'КТ  '+str(kr,12,2)+ ' КР  '+str(krr,12,2)
                        ?'ДТO '+str(dbo,12,2)+' ДРO '+str(dbor,12,2)
                        netrepl('db,kr,ddb,dkr,dbo,ddbo','dbr,krr,ddbr,dkrr,dbor,ddbor')
                     endif
                     if !(dn=dnr.and.kn=knr)
                        ?str(kklr,7)+' '+str(bsr,6)+' '+str(sklr,7)
                        ?'ДНТ '+str(dn,12,2)+' ДНР '+str(dnr,12,2)
                        ?'КНТ '+str(kn,12,2)+' КНР '+str(knr,12,2)
                        netrepl('dn,kn','dnr,knr')
                     endif
                  endif
               else
                  ?str(kklr,7)+' '+str(bsr,6)+' '+str(sklr,7)+' Не найден'
                  netadd()
                  netrepl('kkl,bs,db,kr,skl,ddb,dkr,dn,kn,dbo,ddbo','kklr,bsr,dbr,krr,sklr,ddbr,dkrr,dnr,knr,dbor,ddbor')
               endif
               sele (inr)
               skip
            enddo
            sele (outr)
            go top
            do while !eof()
               if int(bs/1000)#361
                  skip
                  loop
               endif
               kklr=kkl
               bsr=bs
               sklr=skl
               dnr=dn
               knr=kn
               dpr=dp
               kpr=kp
               dbr=db
               krr=kr
               if !(dnr=0.and.knr=0)
                  skip
                  loop
               endif
               sele (inr)
               seek str(kklr,7)+str(bsr,6)+str(sklr,7)
               if !foun()
                  sele (outr)
                  netdel()
                  ?str(kklr,7)+' '+str(bsr,6)+' '+str(sklr,7)+' Удален'
               endif
               sele (outr)
               skip
            endd
        next
        nuse('dokk')
        nuse('dokko')
        nuse('dkkln')
        nuse('dknap')
        nuse('ldkkln')
        nuse('ldknap')
    next
next
nuse()
retu .t.

***************
func ldknap()
***************
sele ldkkln
go top
do while !eof()
   if int(bs/1000)#361
      skip
      loop
   endif
   kklr=kkl
   bsr=bs
   tzdocr=getfield('t1','kklr','kpl','tzdoc')
   sele ldknap
   if netseek('t1','kklr,bsr,0')
      if dn+db-kn-kr<0
         rc0r=recn()
         kr_r=abs(dn+db-kn-kr)
         sele ldknap
         set orde to tag t2
         if netseek('t2','kklr,bsr')
            do while kkl=kklr.and.bs=bsr
               if skl=0
                  skip
                  loop
               endif
               rcxr=recn()
               if dn+db-kn-kr>0
                  if dn+db-kn-kr-kr_r>=0
                     repl kr with kr+kr_r
                     go rc0r
                     repl kr with kr-kr_r
                     go rcxr
                     kr_r=0
                     exit
                  else
                     kr_r=abs(dn+db-kn-kr-kr_r)
                     kr_rr=dn+db-kn-kr
                     repl kr with kr+kr_rr
                     go rc0r
                     repl kr with kr-kr_rr
                     go rcxr
                  endif
               endif
               sele ldknap
               skip
            endd
         endif
      endif
   endif
   sele ldkkln
   skip
endd
sele ldknap
set orde to tag t1
retu .t.
