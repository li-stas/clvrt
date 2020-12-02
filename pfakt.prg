#include "common.ch"
#include "inkey.ch"
/*
    PFakt()  - подтверждение прихода
*/
If pr1->prZ = 1
  mess("Подтвеpждн!!! "+str(mnr,6)+' '+str(gnSk)+' '+DTOS(pr1->DtMod)+' '+pr1->TmMod,1)
EndIf
if Who = 2.or. Who=4
  mess("Подтвеpждение запpещено !!!",1)
  Return
endif
if getfield('t1','mnr,90','pr3','ssf')=0 ;
  .and.!((vor=6.and.kopr=111) .OR. vor=1.and.(str(kopr,3)$'108;107'))
  wmess('Нет суммы по документу',3)
  return
endif

skr=gnSk
rmskr=gnRmsk
//gnSkT=skar
SkTr=SkAr
if autor#0
   if SkTr#0         // gnVo=6
      sele cskl
      if netseek('t1','SkTr')
         gcPath_tt=gcPath_d+alltrim(path)
         gnMsklt=mskl
         gnSklt=skl
         //gnTPsTPok:=TPsTPok
      endif
      if autor#0.and.!file(gcPath_tt+'tprds01.dbf')
         wmess ('Нет адресата '+str(SkTr,3),3)
         return
      endif
   endif
endif

pr1ndsr=getfield('t1','kpsr','kpl','pr1nds')
if kopr#110
  pr1ndsr=0
endif
prXmlr=0
sele pr2
set orde to tag t1
if netseek('t1','mnr')
  do while mn=mnr
    ktlr=ktl
    mntovr=mntov
    if (ndotvr=3.or.ndotvr=4).and.ktl=ktlm
      wmess('Неперекодированный товар '+str(ktlr,9),2)
      return
    endif
    uktr=getfield('t1','mntovr','ctov','ukt')
    optr=getfield('t1','sklr,ktlr','tov','opt')
    if optr=0.and.!(int(ktlr/1000000)=0.or.int(ktlr/1000000)=1)
      wmess('Нет входной цены',2)
      return
    endif
    if gnSkOtv#0.and.gnVOtv=2
       kfr=kf
       upakpr=getfield('t1','sklr,ktlr','tov','upakp')
       if upakpr=0
          wmess('Нет упаковки пост '+str(ktlr,9),2)
          return
       endif
       if mod(kfr,upakpr)#0
          wmess('Не целая упаковка пост '+str(ktlr,9),2)
          return
       endif
    endif
    if !empty(uktr)
       if pr1->kop=108.or.pr1->kop=110
          prXmlr=1
       endif
    endif
    sele pr2
    skip
  enddo
else
   wmess('Нет товара',2)
   return
endif

if !netUse ('dokk')
   return
endif
if !netUse ('bs')
   nuse('dokk')
   return
endif
if !netUse ('dkkln')
   nuse('dokk')
   nuse('bs')
   return
endif
if !ChkVzt(.t.) // провека полная
  return
endif
 // outlog(__FILE__,__LINE__,dprr, bom(gdTd), dprr,eom(gdTd))

If Empty(dprr)
  dprr:=date()
EndIf

if dprr < bom(gdTd) .or. dprr > eom(gdTd)
   dprr=eom(gdTd)
endif

If gnScOut=0
  If empty(Get_dprr(@dprr))
    return
  EndIf
EndIf

sele pr1
tprr=time()
netrepl('DPR,tpr','dprr,tprr',1)
mode=1
tsz60r=0
pr60r=getfield('t1','mnr,60','pr3','pr')
if pr60r=0
   sm60r=getfield('t1','mnr,60','pr3','ssf')
   if sm60r#0
      sm10r=getfield('t1','mnr,10','pr3','ssf')
      sm11r=getfield('t1','mnr,11','pr3','ssf')
      if sm10r+sm11r#0
         tsz60r=sm60r/(sm10r+sm11r)
      endif
   endif
else
   tsz60r=pr60r/100
endif
mnor=0 // Otv hr
if ndotvr=3.or.ndotvr=4
   netuse('pr1','pr1t')
   locate for otv=1.and.kps=kpsr
   if FOUND()
      mnor=mn
   endif
   netuse('pr2','pr2t')
endif

sele pr2
set orde to tag t1
if netseek('t1','mnr')
   do whil MN = mnr
      ktlr = KTL
      ktlmr=ktlm
      kfr  = KF
      sfr  = SF
      seur = seu
      SELE Tov
      if netseek('t1','sklr,ktlr')
         mntov_r=mntov
         osfr=osf+kfr
         osvr=osv+kfr
         osfmr=osfm-osv-kfr+osvr
         osfor=osfo+kfr
         if fieldpos('osfop')#0.and.kopr=188
            osfopr=osfop-kfr
         else
            osfopr=0
         endif
         if gnVo#2 .and. gnVo#1
            netrepl('OSF,OSV,osfm,DPP','OSFr,OSVr,osfmr,DPrr')
         else
            netrepl('OSF,OSV,osfm','OSFr,OSVr,osfmr')
         endif
         if fieldpos('tsz60')#0
            netrepl('tsz60','tsz60r')
         endif
         if fieldpos('prmn')#0
            if gnVo=9.or.gnVo=6.and.((kopr=168.or.kopr=185).and.(gnEnt=14.or.gnEnt=15.or.gnEnt=17).or.kopr=120.and.gnEnt=16)
               netrepl('prmn','mnr')
            endif
         endif
         netrepl('osfo','osfor')
         if fieldpos('osfop')#0.and.kopr=188
            netrepl('osfop','osfopr')
         endif
         if gnCtov=1.and.mntov_r#0
            sele tovm
            if netseek('t1','sklr,mntov_r')
               osfr=osf+kfr
               osvr=osv+kfr
               osfmr=osfm-osv-kfr+osvr
               osfor=osfo+kfr
               if fieldpos('osfop')#0.and.kopr=188
                  osfopr=osfop-kfr
               else
                  osfopr=0
               endif
               netrepl('osf,osfo,osv,osfm,dpp','osfr,osfor,osvr,osfmr,dprr')
               if fieldpos('tsz60')#0
                  netrepl('tsz60','tsz60r')
               endif
               if fieldpos('osfop')#0.and.kopr=188
                  netrepl('osfop','osfopr')
               endif
            endif
         endif
         sele tov
         keurr=keur
         keur1r=keur1
         keur2r=keur2
         keur3r=keur3
         keur4r=keur4
         keuhr=keuh
         do case
            case month(dprr)>2.and.month(dprr)<6
                 keu_r=keur1r
            case month(dprr)>5.and.month(dprr)<9
                 keu_r=keur2r
            case month(dprr)>8.and.month(dprr)<12
                 keu_r=keur3r
            othe
                 keu_r=keur4r
         endcase
         if keu_r=0
            keu_r=keurr
         endif
         sele pR2
         if gnRoz=1
            seur=ROUND(sf*keu_r/100,2)
            netrepl('seu','seur')
         endif
      endif
      if mnor#0.and.(ndotvr=3.or.ndotvr=4)
         sele pr2t
         if netseek('t1','mnor,ktlmr')
            netrepl('kfo','kfo-kfr')
         endif
      endif
      SELE PR2
      skip
   enddo
   sele pr2
   if gnRoz=1
      s92r=0
      if netseek('t1','mnr')
         do while mn=mnr
            s92r=s92r+seu
            skip
         enddo
      endif
      sele pr3
      if netseek('t1','mnr,92')
         netrepl('ssf','s92r')
      else
         netadd()
         netrepl('mn,ksz,ssf','mnr,92,s92r')
      endif
   endif
endif
if ndotvr=3.or.ndotvr=4
   nuse('pr1t')
   nuse('pr2t')
endif

If gnScOut=0
  @ 23,0 clear
endif

PrPrv(1) // проводки
// Автомат по таре
if autor#0 //and.ndotvr=0
  //outlog(__FILE__,__LINE__)
  PPrh()
  //outlog(__FILE__,__LINE__)
endif

// Приход-автомат в складе cskl.skotv
if gnSkOtv#0 // gnOtv=1
  PaOtv()
endif
// Расход - автомат в складе отв.хр.
if ndOtvr=3.or.ndOtvr=4
  mode=1
  PraOtv()
endif

sele pr1
go rcpr1r
pro(8)
netrepl('PRZ','1',1)
if fieldpos('rmsk')#0
   netrepl('rmsk','rmskr',1)
endif
if fieldpos('dtmod')#0
   netrepl('dtmod,tmmod','date(),time()',1)
endif
prmodr=1
przr=prz

return .T.

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  03-29-17 * 10:05:03am
 НАЗНАЧЕНИЕ......... проверка долга по таре 19-(код затрат
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION ChkVzt(lPrz)
  LOCAL lc_pathr:= pathr
  LOCAL dBeg:=BOM(gDtd),  dEnd:=BOM(DtVzr)
  LOCAL nKf, lRet:=.T.
  DEFAULT lPrz TO NO

  //   пропускаем склады 169 - 263;705'
  if str(kopr, 3) $ "108;107" .and. !(str(gnSk,3)$'263;705')
    if select('dkkln')=0
      netuse('dkkln')
      netuse('dknap')
      prDkKlnr=0
    else
      prDkKlnr=1
    endif
    // сумма тары
    sumtr=getfield('t1','mnr,19','pr3','ssf')
    if sumtr#0.and.getfield('t1','mnr,18','pr3','ssf')=0
      sele dkkln
      if netseek('t1','kpsr,361002')
          dbzr=dn-kn+db-kr
          if dbzr<sumtr
            wmess('Задолж по таре '+str(dbzr,10,2)+' в док '+str(sumtr,10,2))
            if prDkKlnr=0
                nuse('dkkln')
                nuse('dknap')
                return .f.
            endif
          endif
      else
          wmess('Клиент не должен тару',2)
          if prDkKlnr=0
            nuse('dkkln')
            nuse('dknap')
          endif
          return .f.
      endif
    endif
    if prDkKlnr=0
      nuse('dkkln')
      nuse('dknap')
    endif

    If lPrz
      // проверка на позварат строк товара
      // найти ТТН возврата
      If !empty(SkVzr)
       cPthSkVz:=alltrim(getfield('t1','skvzr','cskl','path'))
      Else
       cPthSkVz:=gcDir_t
      EndIf
      if !empty(DtVzr) // есть дата ТТН
        pathr=gcPath_e + pathYYYYMM(dtvzr) + '\' + cPthSkVz
        If netfile('rs1',1)
          // скопировать шапку и строки в ВрмТбл
          netuse('rs1','rs1vz',,1)
          netuse('rs2','rs2vz',,1)
          // скопировать шапку
          sele rs1vz
          if netseek('t1','TtnVzr')
            copy to tmptvzR1 next 1
            // скопировать строки
            sele rs2vz
            If netseek('t1','TtnVzr')
              copy to tmptvzR2 while TtnVzr = ttn

            Else
              outlog(__FILE__,__LINE__,3,'нет строк ТТНВЗР',skvzr,TtnVzr,pathr)
            EndIf
          else
            outlog(3,__FILE__,__LINE__,'нет ТТНВЗР',skvzr,TtnVzr,pathr)
          endif
          nuse('rs2vz')
          nuse('rs1vz')

          sele pr1 ; copy to tmpTVzP1 next 1 // stru
          sele pr2 ; copy to tmpTVzP2 for pr1->mn = mn     // stru

          use tmpTVzP1 alias pr1_vz new Exclusive
          use tmpTVzP2 alias pr2_vz new Exclusive
          use tmpTVzR1 alias rs1_vz new Exclusive
          use tmpTVzR2 alias rs2_vz new Exclusive

          // сканировать с Даты ВзрНакл по ТекДату
          dBeg:=BOM(gDtd);  dEnd:=BOM(DtVzr)
          dBeg:=ADDMONTH(dBeg,+1)
          While (dBeg:=ADDMONTH(dBeg,-1),dBeg) >= dEnd
            outlog(3,__FILE__,__LINE__,dBeg)
            sele cskl; DBGoTop()
            while !eof()
              if ent#gnEnt // не то Пред-тия
                 skip;   loop
              endif
              //  пропускаем склады 169 - 263;705'
              if str(Sk,3)$'263;705' // склады 169 брака
                 skip;   loop
              endif
              pathr:=gcPath_e + pathYYYYMM(dBeg) + '\' + alltrim(path)
              //  ищем склад в pr1 взр_склад и взр_ттн
              If netfile('pr1',1)
                netuse('pr1','pr1vz',,1)
                netuse('pr2','pr2vz',,1)

                //  если нашли, то читаем строки товара во ВрмТбл
                sele pr1vz
                locate for TtnVzr = TtnVz .and. prz = 1
                If found()
                  copy to tmpPr1 next 1
                  sele pr2vz
                  copy to tmpPr2 for pr1vz->mn = mn

                  sele pr1_vz ; append from tmpPr1
                  sele pr2_vz ; append from tmpPr2

                EndIf
                nuse('pr2vz')
                nuse('pr1vz')
              else
                 outlog(3,__FILE__,__LINE__,'нет РR1',pathr)
              EndIf
              sele cskl
              skip
            enddo

          Enddo
          // проверить на превышение возвратов и расхода
          sele rs2_vz
          repl all KvpO with 0
          DBGoTop()
          While !eof()
            sele pr2_vz
            sum kf to nKf for rs2_vz->ktl = ktl // сумма
            sele rs2_vz
            repl KvpO with KvpO + nKf // запомним
            sele rs2_vz
            skip
          EndDo
          sele rs2_vz
          locate for KvpO > Kvp
          If found()
            // проблема с больше ВЗР
            outlog(__FILE__,__LINE__,'проблема с больше ВЗР, KvpO, Kvp', ktl, KvpO, Kvp)
            wmess('проблема с код '+str(ktl,9)+' к-во ВЗР:'+ltrim(str(KvpO,4))+' в TTH:'+ltrim(str(Kvp,4)),3)
            lRet:=NO
          EndIf
          // ?проверить на возврат того чего не было.
          close pr1_vz
          close pr2_vz
          close rs1_vz
          close rs2_vz

        Else
          outlog(__FILE__,__LINE__,'нет RS1 данных о ТТНВЗР',pathr)
        EndIf

      else
          outlog(__FILE__,__LINE__,'нет укажите дату ТТНВЗР')
      EndIf
    EndIf

  endif
  pathr:=lc_pathr
  return lRet

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  03-20-18 * 01:24:58pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION Get_dprr(dprr)
  LOCAL clpdp:=setcolor('gr+/b,n/w')
  LOCAL wpdp:=wopen(10,20,13,50)
  wbox(1)
  @ 0,1 say 'Дата прихода:' get dprr range bom(gdTd),eom(gdTd)
  read
  if lastkey()=K_ESC
     wclose(wpdp)
     setcolor(clpdp)
     return .F.
  endif
  wclose(wpdp)
  setcolor(clpdp)
  RETURN (.T.)
