#include "common.ch"
#include "inkey.ch"
* Автоматический приход из отв.хр. в основной склад
sele cskl
if !netseek('t1','gnSkotv')
   wmess('Автомат не создан.Нет склада родителя отв хр '+str(gnSkotv,3),0)
   retu
endif

pathr=gcPath_d+alltrim(path)
skltpr=skl
netUse('pr1','pr1t',,1)
netUse('pr2','pr2t',,1)
netUse('pr3','pr3t',,1)
netUse('tov','tovt',,1)
netUse('tovm','tovmt',,1)
netuse('sgrp','sgrpt',,1)

sele pr2
if !netseek('t1','mnr')
   nuse('pr1t')
   nuse('pr2t')
   nuse('pr3t')
   nuse('tovt')
   nuse('tovmt')
   nuse('sgrpt')
   retu
endif

do while mn=mnr
   ktlr=ktl
   kgnr=int(ktlr/1000000)
   if !netseek('t1','kgnr','sgrpt')
      wmess('Автомат не создан.Нет группы '+str(kgnr,3)+' в складе '+str(gnSkotv,3),0)
      nuse('pr1t')
      nuse('pr2t')
      nuse('pr3t')
      nuse('tovt')
      nuse('tovmt')
      nuse('sgrpt')
      retu
   endif
   if gnVotv=2 // поставка на основной склад в упаковках поставщика
      if getfield('t1','gnSkl,ktlr','tov','upakp')=0
         wmess('Автомат не создан.Нет упаковки поставщика',0)
         nuse('pr1t')
         nuse('pr2t')
         nuse('pr3t')
         nuse('tovt')
         nuse('tovmt')
         nuse('sgrpt')
         retu
      endif
   endif
   sele pr2
   skip
endd




*** Данные из pr1 , записать в pr1t *******************
If mode = 1  // Формирование
   sele pr1t
   mntr=0
   if netseek('t3','1,kpsr')
      mntr=mn
      skltpr=skl
      sele pr1
      if netseek('t1','ndr')
         sklr=skl
         reclock()
         repl amnp with mntr,;
              sktp with gnSkotv,;
              skltp with skltpr
      endif
   else

      sele cskl
      netseek('t1','gnSkotv')
      Reclock()
      mntr=mn
      skltpr=skl
      if mn<999999
        netrepl('mn',{mn+1})
      else
        netrepl('mn',{1})
      endif

      sele pr1
      if netseek('t1','ndr')
         sklr=skl
         reclock()
         arec:={}
         getrec()
         repl amnp with mntr,;
              sktp with gnSkotv,;
              skltp with skltpr
         sele pr1t
         NetAdd()
         putrec()
         netrepl('nd,mn,skl,vo,sdv,sksp,sklsp,amnp,sktp,skltp,otv','mntr,mntr,skltpr,0,0,gnSk,sklr,mnr,0,0,1')
      endi
   endif
else
  sele pr1
  if netseek('t1','ndr')
     sklr=skl
     mntr=amnp
     sktpr=sktp
     skltpr=skltp
  endif
endi

*** Данные с pr3 , записать в pr3t ********************
*** Данные с pr2 , записать в pr2t ********************
if mode=1
   SELE pr2
   netseek('t1','mnr')
   do whil mn=mnr
      mntovr=mntov
      ktlr=ktl
      kgnr=int(ktlr/1000000)
      kfr=kf
*      zenr=zen
      zenr=0.01
      sele tov
      netseek('t1','sklr,ktlr')
      arec:={}
      getrec()
      sele tovt
      if !netseek('t1','skltpr,ktlr')
         netadd()
         putrec()
         netrepl('skl,ktl,opt,post,osn,osv,osf,osfm,osvo,osfo,osfop,otv',;
                 'skltpr,ktlr,zenr,kpsr,0,0,0,0,kfr,0,0,1')
      else
         netrepl('osvo','osvo+kfr')
      endif
      sele tovmt
      if !netseek('t1','skltpr,mntovr')
         sele tovm
         netseek('t1','sklr,mntovr')
         arec:={}
         getrec()
         sele tovmt
         netadd()
         putrec()
         netrepl('skl,osn,osv,osf,osfm,osvo,osfo,osfop,opt','skltpr,0,0,0,0,kfr,0,0,zenr')
      else
         netrepl('osvo,opt','osvo+kfr,zenr')
      endif

      sele pr2t
      if !netseek('t1','mntr,ktlr')
         netadd()
         netrepl('mn,ktl,kf,kfo,sf,zen,ktlp,ppt,mntov',;
                 'mntr,ktlr,kfr,kfr,0,zenr,ktlr,0,mntovr')
      else
         netrepl('kf,kfo','kf+kfr,kfo+kfr')
      endif
      sele pr2
      skip
   endd
else // Удаление
   sele pr2
   if netseek('t1','mnr')
      do while mn=mnr
         ktr=ktl
         mntovr=mntov
         kfr=kf
         sele pr2t
         if netseek('t1','mntr,ktlr')
            netrepl('kf,kfo','kf-kfr,kfo-kfr')
            sele tovt
            if netseek('t1','skltpr,ktlr')
               netrepl('osvo','osvo-kfr')
            endif
            sele tovmt
            if netseek('t1','skltpr,mntovr')
               netrepl('osvo','osvo-kfr')
            endif
         endif
         sele pr2
         skip
      enddo
   EndIf
endif
unlock all
nuse('pr1t')
nuse('pr2t')
nuse('pr3t')
nuse('tovt')
nuse('sgrpt')
nuse('sgrpet')
retu

***************************
func prtotv
* Протокол передачи отв хр
*
***************************
clea
kpsr=2248008
netuse('speng')
pathsoxr=gcPath_ew+'sox\'
do while .t.
   clea
   @ 0,1 say 'Поставщик' get kpsr pict '9999999'
   read
   if lastkey()=K_ESC
      retu .t.
   endif
   pathpstr=pathsoxr+'p'+alltrim(str(kpsr,7))+'\'
   if !file(pathpstr+'prot1.dbf')
      wmess('Нет передач для '+str(kpsr,7),2)
      loop
   endif
   sele 0
   use (pathpstr+'prot1')
   sele 0
   use (pathpstr+'prot2')
   sele prot1
   rcprot1r=recn()
   do while .t.
      clea typeahead
      sele prot1
      go rcprot1r
      rcprot1r=slcf('prot1',2,2,,,"e:sns h:'Сеанс' c:n(6) e:mn h:'N прих' c:n(6) e:dt h:'Дата' c:d(10) e:tm h:'Время' c:c(8) e:getfield('t1','prot1->kto','speng','fio') h:'Передал' c:c(20) e:rzlt h:'Результат' c:c(10)",,,1,,,,'Сеансы передачи')
      if lastkey()=K_ESC
         exit
      endif
      go rcprot1r
      snsr=sns
      mnr=mn
      do case
         case lastkey()=K_ENTER
         sele prot2
         if netseek('t1','snsr,mnr')
            rcprot2r=recn()
            do while sns=snsr.and.mn=mnr
               sele prot2
               go rcprot2r
               rcprot2r=slcf('prot2',,,,,"e:nat h:'Наименование' c:c(40) e:kol h:'Кол-во' c:n(15,3) e:bar h:'ШК' c:n(13)",,,,,,,'Товар')
               if lastkey()=K_ESC
                  exit
               endif
               sele prot2
               go rcprot2r
            endd
         endif
      endc
   endd
   sele prot1
   use
   sele prot2
   use
endd
nuse()
retu .t.
**************************************************************
func pacotv()
* Коррекция остатков в осн скл по расходу из склада отв хр
***************************************************************
sele cskl
if !netseek('t1','gnSkotv')
   wmess('Нет склада родителя отв хр '+str(gnSkotv,3),0)
   retu
endif
pathr=gcPath_d+alltrim(path)
skltpr=skl



netUse('pr1','pr1t',,1)
if !netseek('t3','1,kplr')
   wmess('Нет прихода с остатками отв хр '+str(gnSkotv,3),0)
   nuse('pr1t')
   retu .t.
endif
mntr=mn  // Приход с остатками

netUse('pr2','pr2t',,1)
netUse('tov','tovt',,1)
netUse('tovm','tovmt',,1)

sele rs2
if !netseek('t1','ttnr')
   nuse('pr1t')
   nuse('pr2t')
   nuse('tovt')
   nuse('tovmt')
   retu .t.
endif

*** Данные с rs2 , записать в pr2t ********************
if mode=1  // Снять  остатки
   sele rs2
   netseek('t1','ttnr')
   do whil ttn=ttnr
      ktlr=ktl
      mntovr=mntov
      kvpr=kvp
      sele tovt
      if netseek('t1','skltpr,ktlr')
         netrepl('osvo','osvo-kvpr')
      endif

      sele tovmt
      if netseek('t1','skltpr,mntovr')
         netrepl('osvo','osvo-kvpr')
      endif

      sele pr2t
      if netseek('t1','mntr,ktlr')
         netrepl('kf,kfo','kf-kvpr,kfo-kvpr')
      endif
      sele rs2
      skip
   endd
else // Восстановить остатки
   sele rs2
   netseek('t1','ttnr')
   do whil ttn=ttnr
      ktlr=ktl
      mntovr=mntov
      kvpr=kvp
      sele tovt
      if netseek('t1','skltpr,ktlr')
         netrepl('osvo','osvo+kvpr')
      endif

      sele tovmt
      if netseek('t1','skltpr,mntovr')
         netrepl('osvo','osvo+kvpr')
      endif

      sele pr2t
      if netseek('t1','mntr,ktlr')
         netrepl('kf,kfo','kf+kvpr,kfo+kvpr')
      endif
      sele rs2
      skip
   endd
endif
nuse('pr1t')
nuse('pr2t')
nuse('tovt')
nuse('tovmt')
retu .t.
