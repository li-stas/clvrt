* Коррекция BS по DOKK
if gnScOut=0
   clea
   aqstr=1
   aqst:={"Просмотр","Коррекция"}
   aqstr:=alert(" ",aqst)
   if lastkey()=27
      retu
   endif
else
   aqstr=2
endif

set print to crbsdokk.txt
set prin on

netuse('bs')
netuse('dokk')
sele bs
go top
do while !eof()
   if !reclock(1)
      sele bs
      skip
      loop
   endif
   bsr=bs
   if bsr<1000.and.bsr#22.and.bsr#0
      skip
      loop
   endif
   dbr=db
   krr=kr
   sele dokk
   set orde to tag t2
   db_r=0
   if netseek('t2','bsr')
      do while bs_d=bsr
         if prc
            skip
            loop
         endif
         if bs_k<1000.and.bsr#22.and.bsr#0
            skip
            loop
         endif
         if subs(dokkmsk,1,1)#'1'
            skip
            loop
         endif
         sele dokk
         db_r=db_r+bs_s
         skip
      endd
      sele bs
      if round(dbr,2)#round(db_r,2)
         ?str(bsr,6)+' Дб '+str(dbr,12,2)+' '+str(db_r,12,2)
         if aqstr=2
            netrepl('db','db_r')
         endif
      endif
   endif
   sele dokk
   set orde to tag t3
   kr_r=0
   if netseek('t3','bsr')
      do while bs_k=bsr
         if prc
            skip
            loop
         endif
         if bs_d<1000.and.bsr#22.and.bsr#0
            skip
            loop
         endif
         if subs(dokkmsk,2,1)#'1'
            skip
            loop
         endif
         sele dokk
         kr_r=kr_r+bs_s
         skip
      endd
   endif
   sele bs
   if round(krr,2)#round(kr_r,2)
      ?str(bsr,6)+' Кр '+str(krr,12,2)+' '+str(kr_r,12,2)
      if aqstr=2
         netrepl('kr','kr_r')
      endif
   endif
   sele bs
   netunlock()
   skip
endd
sele dokk
set filt to !prc
go top
sele bs
go top
do while !eof()
   bsr=bs
   dbr=db
   krr=kr
   if dbr#0
      if !netseek('t2','bsr','dokk')
         ?str(bsr,6)+' '+str(bs->db,12,2)+' ->0'
         if aqstr=2
            sele bs
            netrepl('db','0')
         endif
      endif
   endif
   if krr#0
      if !netseek('t3','bsr','dokk')
         ?str(bsr,6)+' '+str(bs->kr,12,2)+' ->0'
         if aqstr=2
            sele bs
            netrepl('kr','0')
         endif
      endif
   endif
   sele bs
   skip
endd
nuse()
set prin off
set print to
wmess('Проверка закончена',0)


func delstorn()
clea
netuse('dokk')
go top
wwwn=0
wwnn=0
do while !eof()
   if prc.or.bs_d=0.or.bs_k=0
      netdel()
      wwwn=wwwn+1
      if wwwn=1000
         wwnn=wwnn+1000
         @ 1,1 say str(wwnn,10)
         wwwn=0
      endif
   endif
   skip
endd
nuse('dokk')
wmess('Сделайте индексацию DOKK',0)
retu .t.
