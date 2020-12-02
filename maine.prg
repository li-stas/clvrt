/***********************************************************
 * Модуль    : maine.prg
 * Версия    : 0.0
 * Автор     :
 * Дата      : 03/19/18
 * Изменен   :
 * Примечание: Текст обработан утилитой CF версии 2.02
 */

local cDosParam := ALLTRIM(UPPER(DOSPARAM()))
#ifndef __CLIP__
  #include 'blinker.ch'
  //освобождение клавиатуры
  IIF (!("/NODOSIDLE" $ cDosParam), DosIdle(), nil)
#else
  #define NTRIM(x) LTRIM(STR(x))
  //  LOCAL ServerResponce

  set idle inkey on
  //cRemoteHost:=GETENV("RemoteHost")
//cRemoteHost:=TOKEN(cRemoteHost,".",1)
#endif

Set Date GERMAN
Set Deleted on
Set Bell off
Set Confirm on
Set Intensity on
Set Talk off
Set Wrap on
Set ScoreBoard off
set epoch to 1980
set cent on
#ifdef __CLIP__
  setkey(28, nil)
#endif
SetColor("g/n,n/r+")
clea

erase menent.dbf
erase menent.cdx
erase MenSkl.dbf
erase MenSkl.cdx
erase menmes.dbf
erase menmes.cdx

#ifndef __CLIP__
  #ifdef BLINKERMEMSHOW

    ?'Общая память для симв перем'+str(memory(0), 10)
    ?memory(1)
    ?'Память для RUN             '+str(memory(2), 10)
    if (BLIMGRSTS(BliMachineMode) = BliModeReal)
      ?"Running in real mode"
      cacheloc = BLIMGRSTS(BliCacheLoc)
      do case
      case (cacheloc = BliCacheNone)
        ? "No cache available"
      case (cacheloc = BliCacheXMS)
        ? "Cache is in XMS"
      case (cacheloc = BliCacheEMS)
        ? "Cache is in EMS"
      endcase

    else
      ? "Running in protected mode"
      hosttype = BLIMGRSTS(BliHostMode)
      ? "DOS extender host is : "
      do case
      case (hosttype = BliHostDPMI)
        ?? "DPMI"
      case (hosttype = BliHostVCPI)
        ?? "VCPI"
      case (hosttype = BliHostXMS)
        ?? "XMS"
      endcase

    endif

    WAIT                    //inkey(3)
  #endif
#endif

wsetshadow('n+')
/******************************* */
adirect=directory('*.cdx')
if (len(adirect)#0)
  for i=1 to len(adirect)
    fl=adirect[ i, 1 ]
    dele file &fl
  next

endif

adirect=directory('*.idx')
if (len(adirect)#0)
  for i=1 to len(adirect)
    fl=adirect[ i, 1 ]
    dele file &fl
  next

endif

/******************************* */

stor '' to gcPath_m, gcPath_s, gcPath_l, gcPath_e, gcPath_g, gcPath_d, Pathr, gcNent, ;
 gcPath_b, gcPath_t, gcPath_tt, gcNot, gcTovdop, gcPath_h, gcPath_gl,                 ;
 gcDir_e, gcDir_g, gcDir_d, gcDir_b, gcDir_t, gcDir_tt, gcDir_h, gcDir_gl,            ;
 gcUname, fnlrsay, gcCotp, gcCotpp, gcPath_ep, gcDir_ep, gcNskl, gcCent, gcPath_srt,  ;
 gcPath_df, gcDir_df, gcCopt, nsklr, gcPath_cs, gcPath_im, gcPath_ex,                 ;
 gcDir_c, gcDir_b, gcDir_a, gcEot, gcNarm, gcIn, gcOut, gcScht_c
stor '' to sectionr, operationr, edatar, wmessr, resultr, gcPrn, gcPath_pm, gcPath_cg, ;
 gcPath_cd, gcPath_a, gcName_c, gcAdr_c, gcOb1_c, gcNs1_c, gcOb2_c, gcNs2_c,           ;
 gcName, gcTlf_c, gcSvid_c, gcOpt, gcOptp, gcDopt, gcDoptp, gcMntov, gcMntovp,         ;
 gcName_cp, gcNentp, gcDisk, gcPath_w, gcPath_db, gnBank_c, gcName_cc,                 ;
 gcPath_ew, gcPath_an, gcPath_ini, gcPath_nw, gcPath_ts, gcPath_nds, gcNamep_c,        ;
 gcPath_nxml, gcPath_yxml, gcPath_mxml
store 0 to gnEnt, gnKmes, gnSkt, gnSklt, gnTcen, gnD0k1, gnRegrs, gnOt, gnCtov, gnSpech,    ;
 gnSnds, gnFox, gnKart, gnMskl, gnSk, gnSkl, gnRoz, who, gnRp, gnOst0, gnRmag,              ;
 gnMserv, gnOtv, gnSkotv, gnVotv, gnBlk, gnAtmrsh, gnScOut, gnRspo, gnRspb, gnRspnb, gnRasc
store 0 to gnRsp, gnRdsp, gnRBso, gnRfp, gnRsps, gnRrs2m, gnRlic, gnAdm, gnKto, gnNds, ;
 gnKln_c, gnKb1_c, gnKb2_c, gnKnal_c, gnComm, gnEntp, gnKkl_c, gnRml, gnRmlo,          ;
 gnEntrm, gnRmsk, gnRm, gnRmbs, gnTpstpok, gnRrm, gnArnd, gnTskl, gnRup, gnRkln,       ;
 gnRks, gnKassa, gnRkpl, gnRfc, gnRnap
store 0 to gnMerch, gnSdRc, gnKklRm, gnKt, gnPrDec, gnKonds, prupr
store ctod('13.08.2013') to gdDec
store '' to pathemr, pathecr, pathepr, direpr, gcPath_in, gcPath_out, gcNbank_c, dirdxmlr, ;
 gcPath_177, gcPath_y177, gcPath_m177,                                                     ;
 gcPath_169, gcPath_m169, gcPath_m169,                                                     ;
 gcPath_129, gcPath_m129, gcPath_m129,                                                     ;
 gcPath_139, gcPath_m139, gcPath_m139,                                                     ;
 gcPath_151, gcPath_m151, gcPath_m151
gnPre=0                     // Процент предприятия
gnPret=0                    // Процент предприятия для табака
store 1 to gnVu, gnOut, gnPrd
store 0 to mnu, zz0, tmor, kpsbbr, prvzznr, PrnOprnr
store 0 to wmessr, key, mnu
store 0 to ktlr, ktlpr, gnKklm, gnVo, gnTovd, gnTovo, dkklnr, gnCenr, gnCenp, ;
 gnVttn, gnCorsh, prlkr, gnRPrd, pr361r, prxmlr, prndsktor

store 0 to fnlr             // Признак закрытия месяца
store ctod('') to gdNPrd

menu[ 1 ]='Предпр'
menu[ 2 ]='Период'
/*menu[3]='Склад ' */
sizam[ 1 ]=0
/*sizam[3]=0 */
menu1:={}
/*menu3:={} */

gcPath_l=diskname()+':'+dirname()

setdate(nnetsdate(), isat())

gdTd:=date()
if (UPPER("/gdTd") $ cDosParam)
  gdTd:=IIF(AT("/GDTD=", cDosParam)#0,                                               ;
             STOD(SUBSTR(cDosParam, AT("/GDTD=", cDosParam)+LEN("/gdTd="), 8)), ;
             date()                                                                     ;
         )
endif

store gdTd to path_tr, path_pr

gcDir_a= 'astru\'
gcDir_c= 'comm\'
gcDir_b= 'bank\'
gcDir_gl='glob\'

gcDir_g='g'+str(year(gdTd), 4)+'\'
gcDir_d='m'+iif(month(gdTd)<10, '0'+str(month(gdTd), 1), str(month(gdTd), 2))+'\'

gdSd=date()
gdTdf=date()

Frame="┌─┐│┘─└│"

#ifdef __CLIP__
  store map() to gaKassa
  gcNNETNAME:=GETENV("RemoteHost")
  gcNNETNAME:=TOKEN(gcNNETNAME, ".", 1)
  if (EMPTY(gcNNETNAME))
    gcNNETNAME:=GETENV("SSH_CLIENT")
    gcNNETNAME:=TOKEN(gcNNETNAME, " ", 1)
  endif

  aaa=''
  for i=len(cHomeDir) to 1 step -1
    if (subs(cHomeDir, i, 1)='/')
      unamer=aaa
      gcUname=aaa
      exit
    else
      aaa=subs(cHomeDir, i, 1)+aaa
    endif

  next

#else
  unamer=netname()
  gcUname=netname()
  gcNNETNAME:=""
#endif
cenprr=0                    // 1 - Разрешить ввод цены в приходе (skl.cenapr)

sele 0
use shrift
if (NETERR())
  close ALL
  ALERT("Обнаруджен флаг работающей задачи;"+              ;
         "Выберите  ДА, если задача завершилась аварийно;"+ ;
         "Выберите НЕТ, для запуска ", { "ДА ", "НЕТ" }     ;
     )
  QUIT
endif

sele 0
if (file(gcPath_l+'\_slct.dbf'))
  erase (gcPath_l+'\_slct.dbf')
endif

crtt('_slct', "f:kod c:c(12) f:kol c:n(12,6)")

if (select('_slct')#0)
  sele _slct
  CLOSE
endif

select shrift
gcPrn=upper(alltrim(shr1))
if (gcPrn#'PCL')
  gcPrn=''
endif

gcPath_srt=upper(alltrim(shr2))
if (empty(gcPath_srt))
  gcPath_srt=gcPath_l+'\'
endif

if (fieldpos('path_a')#0)
  gcPath_aa=alltrim(path_a)
endif

if (fieldpos('path_cs')#0)
  gcPath_cs=alltrim(path_cs)
endif

if (fieldpos('path_pm')#0)
  gcPath_pm=alltrim(path_pm)
else
  gcPath_pm=gcPath_l+'\'
endif

gnEnt:=Ent
if (UPPER("/gnEnt") $ cDosParam)
  gnEnt:=val(SUBSTR(cDosParam, AT("/GNENT=", cDosParam)+LEN("/gnEnt="), 3))
endif

gnKmes=kmes
private menu2[ gnKmes ]
sizam[ 2 ]:=gnKmes

gcDisk=subs(path_m, 1, 3)
gcPath_m=alltrim(path_m)
gcPath_ini=alltrim(path_m)
gcPath_c=gcPath_m+gcDir_c
gcPath_a=gcPath_m+gcDir_a
if (gcDisk='i:\'.and.len(alltrim(path_m))=3)
  if (dirchange('j:\')=0)
    gcPath_w='j:\'
  else
    gcPath_w=gcPath_m+'upgrade\'
    if (dirchange(gcPath_m+'upgrade')#0)
      dirmake(gcPath_m+'upgrade')
    endif

  endif
  dirchange(gcPath_l)


else
  gcPath_w=gcPath_m+'upgrade\'
  if (dirchange(gcPath_m+'upgrade')#0)
    dirmake(gcPath_m+'upgrade')
  endif
  dirchange(gcPath_l)

endif
dirchange(gcPath_l)

sele 0
use (gcPath_c+'rmsk') share
set orde to tag t1
sele 0
use (gcPath_c+'setup') share
crtt('menent', "f:ent c:n(2) f:nent c:c(15) f:uss c:c(20) f:locrem c:n(1) f:comm c:n(1) f:st c:n(2) f:tord c:n(2) f:entrm c:n(1) f:rmsk c:n(1) f:rmbs c:n(6) f:kklrm c:n(7)")
sele 0
use menent
sele setup
locate for ent=gnEnt
if (!found())
  gnEnt=0
else
  if (dirchange(gcPath_m+alltrim(nent))#0)
    gnEnt=0
  else
    if (dirchange(gcPath_m+alltrim(nent)+'\'+'comm')=0)
      gnEnt=0
    endif

  endif
endif
dirchange(gcPath_l)


set orde to tag t1
if (gnEnt#0)
  sele setup
  nentr=alltrim(nent)
  ussr=uss
  locremr=1
  commr=0
  if (fieldpos('entnpp')#0)
    tordr=entnpp
  else
    tordr=0
  endif

  entrmr=entrm
  if (entrmr=1)
    sele rmsk
    locate for ent=gnEnt
    gnRmsk=rmsk
    gnRmbs=rmbs
    gnKklRm=kkl
  endif

  if (tordr=0)
    tordr=9
  endif

  sele menent
  appe blank
  repl ent with gnEnt,  ;
   nent with nentr,     ;
   uss with ussr,       ;
   locrem with locremr, ;
   comm with commr,     ;
   tord with tordr,     ;
   entrm with entrmr,   ;
   rmsk with gnRmsk,    ;
   rmbs with gnRmbs,    ;
   kklrm with gnKklRm
endif

sele 0
use (gcPath_c+'arms') share
locate for arm=gnArm
gcNarm=alltrim(name)
sele setup
go top
while (!eof())
  if (empty(nent))
    skip
    loop
  endif

  nentr=alltrim(nent)
  if (dirchange(gcPath_m+nentr)#0)
    sele setup
    skip
    loop
  endif
  dirchange(gcPath_l)

  entr=ent
  entrmr=entrm
  if (entrmr=1)
    sele rmsk
    locate for ent=entr     //gnEnt
    if (foun())
      rmdirr=alltrim(rmdir)
      rmskr=rmsk
      rmbsr=rmbs
    else
      rmdirr=''
      rmskr=0
      rmbsr=0
    endif

  else
    rmdirr=''
    rmskr=0
    rmbsr=0
  endif

  if (dirchange(gcPath_w+nentr)#0)
    dirmake(gcPath_w+nentr)
  endif
  dirchange(gcPath_l)

  if (dirchange(gcPath_w+nentr+'\comm')#0)
    dirmake(gcPath_w+nentr+'\comm')
  endif
  dirchange(gcPath_l)

  if (dirchange(gcPath_w+nentr+'\in')#0)
    dirmake(gcPath_w+nentr+'\in')
  endif
  dirchange(gcPath_l)

  if (!file(gcPath_w+nentr+'\in\cdmg.dbf'))
    crtt(gcPath_w+nentr+'\in\cdmg', 'f:rm c:n(1) f:dt c:d(10) f:sdt c:d(10) f:stm c:c(8) f:csk c:c(40) f:kolmod c:n(2) f:buhsk c:n(1) f:dtz c:d(10) f:tmz c:c(8) f:kto c:n(4) f:dto c:d(10) f:tmo c:c(8)')
  endif

  if (dirchange(gcPath_w+nentr+'\out')#0)
    dirmake(gcPath_w+nentr+'\out')
  endif
  dirchange(gcPath_l)

  if (dirchange(gcPath_w+nentr+'\kpk')#0)
    dirmake(gcPath_w+nentr+'\kpk')
  endif
  dirchange(gcPath_l)

  if (dirchange(gcPath_w+nentr+'\ups')#0)
    dirmake(gcPath_w+nentr+'\ups')
  endif
  dirchange(gcPath_l)

  sele arms
  go top
  while (!eof())
    if (na=0)
      skip
      loop
    endif

    namer=lower(alltrim(name))
    if (dirchange(gcPath_w+nentr+'\'+namer)#0)
      dirmake(gcPath_w+nentr+'\'+namer)
    endif
    dirchange(gcPath_l)

    sele arms
    skip
  enddo

  sele setup
  ussr=uss
  if (fieldpos('entnpp')#0)
    tordr=entnpp
  else
    tordr=0
  endif

  if (tordr=0)
    tordr=9
  endif

  locremr=1
  if (dirchange(gcPath_m+nentr+'\comm')=0)
    commr=1
  else
    commr=0
  endif
  dirchange(gcPath_l)

  if (ent=gnEnt)
    skip
    loop
  endif

  sele menent
  locate for ent=entr
  if (!foun())
    appe blank
    repl ent with entr,   ;
     nent with nentr,     ;
     uss with ussr,       ;
     locrem with locremr, ;
     comm with commr,     ;
     st with 1,           ;
     tord with tordr,     ;
     entrm with entrmr,   ;
     rmsk with rmskr,     ;
     rmbs with rmbsr
    dirchange(gcPath_l)
  endif

  sele setup
  skip
enddo

CLOSE
sele arms
CLOSE
sele rmsk
CLOSE
sele menent
inde on str(st, 1)+str(comm, 1)+str(tord, 2)+str(ent, 2) tag t1

if (gnEnt=0)
  go top
  gnEnt=ent
endif

clea
@ MAXROW(), 1 Prompt 'PRINT'
@ MAXROW(), col()+2 Prompt 'FILE '
Menu to gnOut
if (LastKey() = 27)
  Quit
endif

if (gnOut=1)
  if (.not. isprinter())
    apcen=alert('Принтер не готов;Продолжить работу в режиме ФАЙЛ ? ', { 'ДА', 'НЕТ' })
    if (apcen=1)
      gnOut=2
      set print to txt.txt
    else
      quit
    endif

  else
    Set Device to Print
  endif

else
  set prin to txt.txt
endif

@ 0, 0 say chr(27)+chr(77)
Set Device to Screen

clea
#ifdef __CLIP__
  @ 1, 1 say 'Пароль '
#else
  @ 1, 1 say 'ПАРОЛЬ '
#endif
uprlr=space(10)
for c=1 to 10
  xx=0
  xx=inkey(0)
  if (xx=27)
    return
  endif

  if (xx=13)
    exit
  endif

  if (xx=8.or.xx=224)
    c=c-1
    uprlr=stuff(uprlr, c, 1, ' ')
    @ 1, col()-1 say ' '
    @ 1, col()-1
    c=c-1
    loop
  endif

  xxx=chr(xx)
  uprlr=stuff(uprlr, c, 1, xxx)
  @ 1, col() say '*'
endfor

if (empty(uprlr))
  return
endif

/*if uprlr='orex'
 *   uprlr='flat'
 *endif
 */
gcSprl='frog'
if (uprlr=gcSprl)
  gnAdm=1
  gnKto=9999
  who:=3
endif

clea

if (gnAdm=0)
  sele 0
  use (gcPath_ini+'comm\speng') share
  locate for prl==uprlr
  if (foun())
    if (fieldpos('ulogin')#0)
      netrepl('ulogin', 'gcUname')
    endif

    gnKto=kgr
    sele 0
    use (gcPath_ini+'comm\spenge') share
    set orde to tag t1
    sele 0
    use (gcPath_ini+'comm\cskl') share
    set orde to tag t1
    sele menent
    go top
    while (!eof())
      prentr=0
      entr=ent
      commr=comm
      if (commr=1)
        sele menent
        skip
        loop
      endif

      sele cskl
      go top
      while (!eof())
        if (ent#entr)
          sele cskl
          skip
          loop
        endif

        skr=sk
        sele spenge
        seek str(gnKto, 4)+str(skr, 3)
        if (foun())
          prentr=1
          exit
        endif

        sele cskl
        skip
      enddo

      sele menent
      if (prentr=0)
        /*            entr=0 */
        netdel()
      endif

      skip
    enddo

    sele spenge
    CLOSE
    sele cskl
    CLOSE
  else
    sele menent
    set orde to
    dele all
  endif

  sele speng
  CLOSE
endif

sele menent
locate for ent=gnEnt
if (!found())
  locate for ent>=20
  gnEnt=ent
endif

if (IniEnt())
  IniMes(gdTd)
  IniSkl()
  if (UPPER("/gnSk") $ cDosParam)
    gnSk=val(SUBSTR(cDosParam, AT("/GNSK=", cDosParam)+LEN("/gnSk="), 3))
  endif

  MenSkl()
else
  wmess('Нет доступных предприятий', 3)
  quit
endif

/**************************** */

/******************************************
 * CTOV
 ******************************************
 *gcOpt='opt'+iif(gnEnt<10,'0'+str(gnEnt,1),str(gnEnt,2))
 *gcDopt='dopt'+iif(gnEnt<10,'0'+str(gnEnt,1),str(gnEnt,2))
 *gcMntov='mntov'+iif(gnEnt<10,'0'+str(gnEnt,1),str(gnEnt,2))
 */

/******************************************
 * CASHTAN
 ******************************************
 */
if (!empty(gcPath_cs).and.file(gcPath_cs+'smp9.ini'))
  gnMserv=1                 // Сервер магазина
  if (file('csimex.dbf'))
    erase csimex.dbf
  endif

  if (file('cssect.dbf'))
    erase cssect.dbf
  endif

  if (file('cskass.dbf'))
    erase cskass.dbf
  endif

  crtt('csimex', "f:import c:c(50) f:export c:c(50) f:smp90 c:c(10)")
  sele 0
  use csimex
  appe blank
  crtt('cssect', "f:sect c:c(10)")
  sele 0
  use cssect
  crtt('cskass', "f:sect c:c(10) f:kass c:c(10)")
  sele 0
  use cskass

  finr=fopen(gcPath_cs+'smp9.ini')
  foutr=fcreate(gcPath_l+'\lsmp9.ini')
  store 0 to prsmpr, prsectr, prkassr
  while (.t.)
    lnr=fgets(finr)
    if (lnr=="")
      exit
    endif

    if (lnr=chr(13)+chr(10))
      loop
    endif

    lnr=subs(lnr, 1, len(lnr)-2)
    do case
    case (at('[SMP9List]', lnr)#0)
      prsmpr=1
    case (at('SMP90=', lnr)#0.and.prsmpr=1)
      smp90r=subs(lnr, 7)
      sele csimex
      netrepl('smp90', 'smp90r')
      prsmpr=0
    case (at('DbfImportPath', lnr)#0)
      importr=subs(lnr, 15)
      sele csimex
      netrepl('import', 'importr')
    case (at('DbfExportPath', lnr)#0)
      exportr=subs(lnr, 15)
      sele csimex
      netrepl('export', 'exportr')
    case (at('[ECRGroup', lnr)#0)
      prsectr=1
      prkassr=0
    case (at('Name', lnr)#0.and.prsectr=1)
      sectr=subs(lnr, 6)
      sele cssect
      netadd()
      netrepl('sect', 'sectr')
    case (at('[ECR', lnr)#0)
      prsectr=0
      prkassr=1
    case (at('Name', lnr)#0.and.prkassr=1)
      kassr=subs(lnr, 6)
      sele cskass
      netadd()
      netrepl('sect,kass', 'sectr,kassr')
    endcase

  enddo

  fclose(finr)
  fclose(foutr)
  sele csimex
  gcPath_im=alltrim(import)
  gcPath_ex=alltrim(export)
  sele csimex
  CLOSE
  sele cssect
  CLOSE
  sele cskass
  CLOSE
endif

/***************************************** */
clea
/*if gnArm=1
 *   clea
 *   @ 1,1 say 'Проверте дату' get gdTd color 'g/n,n/w'
 *   read
 *   setdate(gdTd,isat())
 *   clea
 *endif
 */

gdTdn=ctod(stuff(dtoc(gdTd), 1, 2, '01'))
gdTdk=kmes(gdTd)
aaa=date()

netuse('setup')

menu()

nuse()
close all
erase menent.dbf
erase menent.cdx
erase MenSkl.dbf
erase MenSkl.cdx

/************* */
function IniEnt()
  /************* */
  sele menent
  locate for ent=gnEnt
  if (!foun())
    return (.f.)
  endif

  gcNent=alltrim(nent)
  gnComm=comm
  gnEntrm=entrm
  gnRmsk=rmsk
  gnRmbs=rmbs
  gnKklRm=kklrm

  if (gnComm=1)
    gcPath_m=lower(gcPath_ini)+lower(gcNent)+'\'
  else
    gcPath_m=lower(gcPath_ini)
  endif

  gcPath_e=gcPath_m+lower(gcNent)+'\'

  gcPath_c=gcPath_m+gcDir_c
#ifdef __CLIP__
    gcIn='j:\'+'e'+padl(alltrim(str(gnEnt, 2)), 2, '0')+'\in\'
    gcOut='j:\'+'e'+padl(alltrim(str(gnEnt, 2)), 2, '0')+'\out\'
    if (dirchange('j:\'+'e'+padl(alltrim(str(gnEnt, 2)), 2, '0'))#0)
      dirmake('j:\'+'e'+padl(alltrim(str(gnEnt, 2)), 2, '0'))
    endif
    dirchange(gcPath_l)

    if (dirchange('j:\'+'e'+padl(alltrim(str(gnEnt, 2)), 2, '0')+'\in')#0)
      dirmake('j:\'+'e'+padl(alltrim(str(gnEnt, 2)), 2, '0')+'\in')
    endif
    dirchange(gcPath_l)

    if (dirchange('j:\'+'e'+padl(alltrim(str(gnEnt, 2)), 2, '0')+'\out')#0)
      dirmake('j:\'+'e'+padl(alltrim(str(gnEnt, 2)), 2, '0')+'\out')
    endif
    dirchange(gcPath_l)

#else
    gcIn='g:\work\upgrade\'+'e'+padl(alltrim(str(gnEnt, 2)), 2, '0')+'\in\'
    gcOut='g:\work\upgrade\'+'e'+padl(alltrim(str(gnEnt, 2)), 2, '0')+'\out\'
    if (dirchange('g:\work\upgrade\'+'e'+padl(alltrim(str(gnEnt, 2)), 2, '0'))#0)
      dirmake('g:\work\upgrade\'+'e'+padl(alltrim(str(gnEnt, 2)), 2, '0'))
    endif
    dirchange(gcPath_l)

    if (dirchange('g:\work\upgrade\'+'e'+padl(alltrim(str(gnEnt, 2)), 2, '0')+'\in')#0)
      dirmake('g:\work\upgrade\'+'e'+padl(alltrim(str(gnEnt, 2)), 2, '0')+'\in')
    endif
    dirchange(gcPath_l)

    if (dirchange('g:\work\upgrade\'+'e'+padl(alltrim(str(gnEnt, 2)), 2, '0')+'\out')#0)
      dirmake('g:\work\upgrade\'+'e'+padl(alltrim(str(gnEnt, 2)), 2, '0')+'\out')
    endif
    dirchange(gcPath_l)

#endif
  dirchange(gcPath_l)

  if (select('cntcm')#0)
    sele cntcm
    CLOSE
  endif

  if (!file(gcPath_c+'cntcm.dbf'))
    if (file(gcPath_a+'cntcm.dbf'))
      copy file (gcPath_a+'cntcm.dbf') to (gcPath_c+'cntcm.dbf')
      appe blank
    endif

  endif

  if (file(gcPath_c+'cntcm.dbf'))
    sele 0
    use (gcPath_c+'cntcm') share
    if (recc()>1)
      go top
      while (!eof())
        if (brand=0)
          netdel()
          skip
        endif

      enddo

      go top
    endif

  endif

  if (select('setup')#0)
    sele setup
    CLOSE
  endif

  sele 0
  use (gcPath_c+'setup') share

  if (select('dbft')#0)
    sele dbft
    CLOSE
  endif

  sele 0
  use (gcPath_c+'dbft') share

  if (select('dir')#0)
    sele dir
    CLOSE
  endif

  sele 0
  use (gcPath_c+'dir') share

  if (select('prd')#0)
    sele prd
    CLOSE
  endif

  netuse('prd')
  for god_r=year(date()) to 1997 step -1
    dir_gr='g'+str(god_r, 4)+'\'
    path_gr=gcPath_e+dir_gr
    for mes_r=12 to 1 step -1
      if (mes_r<10)
        dir_dr='m0'+str(mes_r, 1)+'\'
      else
        dir_dr='m'+str(mes_r, 2)+'\'
      endif

      path_dr=path_gr+dir_dr
      path_br=path_dr+'\bank\'
      if (file(path_br+'dok_k.dbf'))
        sele prd
        locate for god=god_r.and.mes=mes_r
        if (!foun())
          netadd()
          if (!(god_r=year(date()).and.mes_r=month(date())))
            netrepl('god,mes,prd', 'god_r,mes_r,1')
          else
            netrepl('god,mes,prd', 'god_r,mes_r,0')
          endif

        endif

      endif

    next

  next

  if (gnAdm=0)
    if (gnComm=0.or.uprlr='briz')// "Свое" предприятие
      netuse('speng')
      locate for prl=uprlr
      if (foun())
        gnKto=kgr
        gcName=alltrim(fio)
        ktor=kgr
        fktor=gcName
        admr=adm
        if (admr=1)
          who:=3
        endif

        gnSPech=SPech
        dkklnr=dkkln
        gnCenr=cenr
        gnCenp=cenp
        gnKart=kart
        gnAtmrsh=atmrsh
        if (gnAtmrsh=1)
          who:=5
        endif

        gnRspo=rspo
        gnRspb=rspb
        gnRspnb=rspnb
        gnRsp=rsp
        gnRsps=rsps
        gnRdsp=rdsp
        gnRBso=rbso
        gnRfp=rfp
        gnRrs2m=rrs2m
        gnRlic=rlic
        gnRml=rml
        gnRmlo=rmlo
        gnRrm=rrm
        gnCorsh=corsh
        gnRup=rup
        gcEot=eot
        gnRprd=rprd
        if (fieldpos('rkln')#0)
          gnRkln=rkln
        endif

        if (fieldpos('rks')#0)
          gnRks=rks
        endif

        if (fieldpos('rkpl')#0)
          gnRkpl=rkpl
        endif

        if (fieldpos('rfc')#0)
          gnRfc=rfc
        endif

        if (fieldpos('rnap')#0)
          gnRnap=rnap
        endif

      else
        nuse('speng')
        return (.f.)
      endif

      nuse('speng')
    else
      gnKto=99999
      who:=0
    endif

  endif

  netuse('kln')
  netuse('opfh')
  netuse('banks')

  sele setup
  locate for ent=gnEnt
  gcNent_c=alltrim(nent)
  gcName_cc=alltrim(uss)
  gnKln_c = kkl
  gnKkl_c=kkl7

  sele kln
  netseek('t1', 'gnKkl_c')
  gcName_c=alltrim(nkl)
  nkler=alltrim(nkle)
  opfhr=opfh
  nopfhr=''
  if (opfhr#0)
    nopfhr=alltrim(getfield('t1', 'opfhr', 'opfh', 'nopfh'))
  endif

  gcNamep_c=alltrim(nklprn)
  if (empty(gcNamep_c))
    gcNamep_c=gcName_c
  endif

  sele setup
  if (empty(gcName_c))
     gcName_c = uss
  endif

    gcNbank_c = setup->ob1  // наз банка
    gnBank_c = alltrim(kln->kb1)
    ckb1r=padl(alltrim(kln->kb1), 9, ' ')//str(setup->kb1,6)
    sele banks; locate for alltrim(kob)=ckb1r; if foun(); gcNbank_c = otb; endif

    sele setup
    gcScht_c = ns1
    gcFname_c = upr
    gcAdr_c = kln->adr
    gnKnal_c = nn
    gcTlf_c = kln->tlf
    gcSvid_c = nsv
    gcNdir_c = direct
    gcNbuh_c = buhg
    gnNds = nds

    gnKb1_c = alltrim(kln->kb1)// setup-> type N
    gcNs1_c = alltrim(kln->ns1)
    gcOb1_c = alltrim(gcNbank_c)

    gnKb2_c = alltrim(kln->kb2)// setup-> type N
    gcNs2_c = alltrim(kln->ns2)
    gcOb2_c = setup->ob2
    ckb2r=padl(alltrim(kln->kb2), 9, ' ')//  '000'+str(setup->kb1,6)
    sele banks
    locate for alltrim(kob)=ckb2r
    if foun()
      gcOb2_c = otb
    endif

    gnKb3_c = kln->kb3

    nuse('banks')
    nuse('kln')
    nuse('opfh')

    /****************** */
    gcCotp=''               // alltrim(cotp)
    gcOpt=''                //'opt'+iif(gnEnt<10,'0'+str(gnEnt,1),str(gnEnt,2))
    gcDopt=''               //'dopt'+iif(gnEnt<10,'0'+str(gnEnt,1),str(gnEnt,2))
    gcMntov=''              //'mntov'+iif(gnEnt<10,'0'+str(gnEnt,1),str(gnEnt,2))

    gnEntp=0
    gcName_cp=''
    gcPath_ep=''
    gcDir_ep=''
    gcNentp=''
    gcCotpp=''              // Отпускная цена Поставщика
    gcOptp=''
    gcDoptp=''
    gcMntovp=''
    /****************** */
    IniPath()

    sizam[ 1 ]:=0
    sele menent
    if (recc()=0)
      wmess('Нет доступных предприятий')
      return
    endif

    go top
    while (!eof())
      aadd(menu1, uss)
      sizam[ 1 ]=sizam[ 1 ]+1
      sele menent
      skip
    enddo

    return (.t.)

/************ */
function IniMes(dDtCur)
  // перестройка тек периода по наличию данных tprds01.dbf
  DEFAULT dDtCur to date()
  netuse('cskl')
  rrr=0
  store 0 to godr, monr
  Do While year(dDtCur) >= 1997

    godr:=year(dDtCur)
    gcDir_g='g'+str(godr, 4)+'\'
    gcPath_g=gcPath_e+gcDir_g

    monr:=Month(dDtCur)
    gcDir_d='m'+padl(ltrim(str(monr, 2)),2,'0')+'\'
    gcPath_d=gcPath_g+gcDir_d

    sele cskl
    go top
    while (!eof())
      if (ent#gnEnt)
        skip
        loop
      endif

      gcDir_t=alltrim(path)
      gcPath_t=gcPath_d+gcDir_t
      if (file(gcPath_t+'tprds01.dbf'))
        rrr=1
        exit
      else
        // outlog(3,__FILE__,__LINE__,".not.file(gcPath_t+'tprds01.dbf')",gcPath_t)
      endif

      sele cskl
      skip
    enddo

    if (rrr=1)
      exit
    endif

    dDtCur:=AddMonth(dDtCur,-1)
  EndDo

  nuse('cskl')

  if (!(monr=month(gdTd).and.godr=year(gdTd)))
    cdtr='01/'+iif(monr<10, '0'+str(monr, 1), str(monr, 2))+'/'+str(godr, 4)
    gdTd=ctod(cdtr)
    gdTd=eom(gdTd)
  else
    gdTd:=gdTd              //date() // уже ранее создано
  endif

  if (gdTd<ctod('07.08.2013'))
    gnPrDec=0
  else
    gnPrDec=1
  endif

  sele prd
  locate for god=year(gdTd).and.mes=month(gdTd)
  if (foun())
    gnPrd=prd
  else
    gnPrd=1
  endif

  IniPath()
  a1= 'Январь  '
  a2= 'Февраль '
  a3= 'Март    '
  a4= 'Апрель  '
  a5= 'Май     '
  a6= 'Июнь    '
  a7= 'Июль    '
  a8= 'Август  '
  a9= 'Сентябрь'
  a10='Октябрь '
  a11='Ноябрь  '
  a12='Декабрь '

  k=1
  monr=month(gdTd)
  godr=year(gdTd)
  while (k<gnKmes)
    sele prd
    locate for god=godr.and.mes=monr
    if (foun())
      prdr=prd
    else
      prdr=1
    endif

    if (monr<10)
      zz1='a'+str(monr, 1)
    else
      zz1='a'+str(monr, 2)
    endif

    menu2[ k ]=&zz1+' '+str(godr, 4)+'│'+str(prdr, 1)
    monr=monr-1
    if (monr=0)
      monr=12
      godr=godr-1
    endif

    k=k+1
  enddo

  return (.t.)

/************ */
function IniPath()
  /************ */

  gcDir_g='g'+str(year(gdTd), 4)+'\'

  if (month(gdTd)<10)
    gcDir_d='m0'+str(month(gdTd), 1)+'\'
  else
    gcDir_d='m'+str(month(gdTd), 2)+'\'
  endif

  gcPath_cg=gcPath_c+gcDir_g
  gcPath_cd=gcPath_cg+gcDir_d

  gcPath_a=gcPath_m+gcDir_a

  gcDir_e=gcNent+'\'
  gcPath_e=gcPath_m+gcDir_e

  gcPath_ew=gcPath_w+gcDir_e
  direwr=gcPath_w+gcNent
  if (dirchange(direwr)#0)
    dirmake(direwr)
  endif
  dirchange(gcPath_l)


  gcPath_an=gcPath_ew+'an\'
  diranr=gcPath_ew+'an'
  if (dirchange(diranr)#0)
    dirmake(diranr)
  endif
  dirchange(gcPath_l)

  gcPath_nds=gcPath_ew+'nds\'
  dirndsr=gcPath_ew+'nds'
  if (dirchange(dirndsr)#0)
    dirmake(dirndsr)
  endif
  dirchange(gcPath_l)

  gcPath_arnd=gcPath_ew+'arnd\'
  dirarndr=gcPath_ew+'arnd'
  if (dirchange(dirarndr)#0)
    dirmake(dirarndr)
  endif
  dirchange(gcPath_l)

  if (.t.)                //gnEnt=20
    gcPath_177=gcPath_ew+'ttn177\'
    dir177r=gcPath_ew+'ttn177'
    if (dirchange(dir177r)#0)
      dirmake(dir177r)
    endif
    dirchange(gcPath_l)

    gcPath_y177=gcPath_177+'g'+str(year(gdTd), 4)+'\'
    diryr=gcPath_177+'g'+str(year(gdTd), 4)
    if (dirchange(diryr)#0)
      dirmake(diryr)
    endif
    dirchange(gcPath_l)

    gcPath_m177=gcPath_y177+'m'+iif(month(gdTd)<10, '0'+str(month(gdTd), 1), str(month(gdTd), 2))+'\'
    dirmr=gcPath_y177+'m'+iif(month(gdTd)<10, '0'+str(month(gdTd), 1), str(month(gdTd), 2))
    if (dirchange(dirmr)#0)
      dirmake(dirmr)
    endif
    dirchange(gcPath_l)

    gcPath_169=gcPath_ew+'ttn169\'
    dir169r=gcPath_ew+'ttn169'
    if (dirchange(dir169r)#0)
      dirmake(dir169r)
    endif
    dirchange(gcPath_l)

    gcPath_y169=gcPath_169+'g'+str(year(gdTd), 4)+'\'
    diryr=gcPath_169+'g'+str(year(gdTd), 4)
    if (dirchange(diryr)#0)
      dirmake(diryr)
    endif
    dirchange(gcPath_l)

    gcPath_m169=gcPath_y169+'m'+iif(month(gdTd)<10, '0'+str(month(gdTd), 1), str(month(gdTd), 2))+'\'
    dirmr=gcPath_y169+'m'+iif(month(gdTd)<10, '0'+str(month(gdTd), 1), str(month(gdTd), 2))
    if (dirchange(dirmr)#0)
      dirmake(dirmr)
    endif
    dirchange(gcPath_l)

    gcPath_129=gcPath_ew+'ttn129\'
    dir129r=gcPath_ew+'ttn129'
    if (dirchange(dir129r)#0)
      dirmake(dir129r)
    endif
    dirchange(gcPath_l)

    gcPath_y129=gcPath_129+'g'+str(year(gdTd), 4)+'\'
    diryr=gcPath_129+'g'+str(year(gdTd), 4)
    if (dirchange(diryr)#0)
      dirmake(diryr)
    endif
    dirchange(gcPath_l)

    gcPath_m129=gcPath_y129+'m'+iif(month(gdTd)<10, '0'+str(month(gdTd), 1), str(month(gdTd), 2))+'\'
    dirmr=gcPath_y129+'m'+iif(month(gdTd)<10, '0'+str(month(gdTd), 1), str(month(gdTd), 2))
    if (dirchange(dirmr)#0)
      dirmake(dirmr)
    endif
    dirchange(gcPath_l)

    gcPath_139=gcPath_ew+'ttn139\'
    dir139r=gcPath_ew+'ttn139'
    if (dirchange(dir139r)#0)
      dirmake(dir139r)
    endif
    dirchange(gcPath_l)

    gcPath_y139=gcPath_139+'g'+str(year(gdTd), 4)+'\'
    diryr=gcPath_139+'g'+str(year(gdTd), 4)
    if (dirchange(diryr)#0)
      dirmake(diryr)
    endif
    dirchange(gcPath_l)

    gcPath_m139=gcPath_y139+'m'+iif(month(gdTd)<10, '0'+str(month(gdTd), 1), str(month(gdTd), 2))+'\'
    dirmr=gcPath_y139+'m'+iif(month(gdTd)<10, '0'+str(month(gdTd), 1), str(month(gdTd), 2))
    if (dirchange(dirmr)#0)
      dirmake(dirmr)
    endif
    dirchange(gcPath_l)

    gcPath_151=gcPath_ew+'ttnlist\'
    dir151r=gcPath_ew+'ttnlist'
    if (dirchange(dir151r)#0)
      dirmake(dir151r)
    endif
    dirchange(gcPath_l)

    gcPath_y151=gcPath_151+'g'+str(year(gdTd), 4)+'\'
    diryr=gcPath_151+'g'+str(year(gdTd), 4)
    if (dirchange(diryr)#0)
      dirmake(diryr)
    endif
    dirchange(gcPath_l)

    gcPath_m151=gcPath_y151+'m'+iif(month(gdTd)<10, '0'+str(month(gdTd), 1), str(month(gdTd), 2))+'\'
    dirmr=gcPath_y151+'m'+iif(month(gdTd)<10, '0'+str(month(gdTd), 1), str(month(gdTd), 2))
    if (dirchange(dirmr)#0)
      dirmake(dirmr)
    endif
    dirchange(gcPath_l)

  endif

  gcPath_nxml=gcPath_ew+'nxml\'
  dirndsr=gcPath_ew+'nxml'
  if (dirchange(dirndsr)#0)
    dirmake(dirndsr)
  endif
  dirchange(gcPath_l)

  gcPath_yxml=gcPath_nxml+'g'+str(year(gdTd), 4)+'\'
  diryr=gcPath_nxml+'g'+str(year(gdTd), 4)
  if (dirchange(diryr)#0)
    dirmake(diryr)
  endif
  dirchange(gcPath_l)

  gcPath_mxml=gcPath_yxml+'m'+iif(month(gdTd)<10, '0'+str(month(gdTd), 1), str(month(gdTd), 2))+'\'
  dirmr=gcPath_yxml+'m'+iif(month(gdTd)<10, '0'+str(month(gdTd), 1), str(month(gdTd), 2))
  if (dirchange(dirmr)#0)
    dirmake(dirmr)
  endif
  dirchange(gcPath_l)

  for i=1 to day(eom(gdTd))
    dirdr=gcPath_mxml+'d'+iif(i<10, '0'+str(i, 1), str(i, 2))
    if (dirchange(dirdr)#0)
      dirmake(dirdr)
    endif
    dirchange(gcPath_l)

  next

  gcPath_nw=gcPath_ew+'newwave\'
  dirnwr=gcPath_ew+'newwave'
  if (dirchange(dirnwr)#0)
    dirmake(dirnwr)
  endif
  dirchange(gcPath_l)

  gcPath_ts=gcPath_ew+'ts\'
  dirtsr=gcPath_ew+'ts'
  if (dirchange(dirtsr)#0)
    dirmake(dirtsr)
  endif
  dirchange(gcPath_l)

  gcPath_db=gcPath_ew+'deb\'
  dirdbr=gcPath_ew+'deb'
  if (dirchange(dirdbr)#0)
    dirmake(dirdbr)
  endif
  dirchange(gcPath_l)

  gcPath_in=gcPath_ew+'in\'
  gcPath_out=gcPath_ew+'out\'

  path_r=gcPath_l+'\'+gcDir_e
  dir_r=lower(gcPath_l+'\'+gcNent)
  if (dirchange(dir_r)#0)
    dirmake(dir_r)
  endif
  dirchange(gcPath_l)

  if (gnEntrm=0)
    netuse('rmsk')
    go top
    while (!eof())
      if (ent#gnEnt)
        skip
        loop
      endif

      rmdirr=alltrim(rmdir)
      dir_r=lower(path_r+rmdir)
      if (dirchange(dir_r)#0)
        dirmake(dir_r)
      endif
      dirchange(gcPath_l)

      sele rmsk
      skip
    enddo

    nuse('rmsk')
  else
    dir_r=lower(path_r+'sum')
    if (dirchange(dir_r)#0)
      dirmake(dir_r)
    endif
    dirchange(gcPath_l)

  endif

  dirchange(gcPath_l)

  gcPath_g=gcPath_e+gcDir_g
  gcPath_d=gcPath_g+gcDir_d

  gcPath_b=gcPath_d+gcDir_b
  gcPath_gl=gcPath_d+gcDir_gl
  gcPath_t=gcPath_d+gcDir_t

  return (.t.)

/************* */
function IniSkl()
  /************* */
  dirchange(gcPath_l)
  if (select('MenSkl')#0)
    sele MenSkl
    CLOSE
  endif

  netuse('cskl')
  copy to MenSkl for ent=gnEnt.and.blk=0
  netuse('spenge')

  sele 0
  use MenSkl
  go top
  while (!eof())
    skr=sk
    pathr=gcPath_d+alltrim(path)
    if (!netfile('tov', 1))
      dele
    endif

    if (gnAdm=0.and.gnComm=0)
      sele spenge
      if (!netseek('t1', 'gnKto,skr'))
        sele MenSkl
        netdel()
        skip
        loop
      else
        whr=wh
        sele MenSkl
        netrepl('wh', 'whr')
      endif

    else
      if (gnAdm=0.and.gnComm=1.and.uprlr#'briz')
        sele MenSkl
        netrepl('wh', '0')
      endif

    endif

    sele MenSkl
    skip
  enddo

  nuse('cskl')
  nuse('spenge')
  sele MenSkl
  go top
  gnSk=sk
  return (.t.)

/***********************************************************
 * MenSkl() -->
 *   Параметры :
 *   Возвращает:
 */
function MenSkl()
  netuse('spenge')
  netuse('cskl')
  locate for sk=gnSk
  gcNskl=nskl
  gnSk=sk
  gnRm=rm
  gnSkotv=skotv
  gnVotv=otv                // вид отв хр
  gnSkp=skp
  gnSkl=skl
  sklr=skl
  gnCtov=ctov
  gnMskl=mskl
  gnRmag=rmag
  gnRoz=roz
  gnSkl=sklr
  gnTpstpok=tpstpok
  /*who=wh */
  if (gnAdm=0)
    if (gnComm=0.or.uprlr='briz')
      who:=getfield('t1', 'gnKto,gnSk', 'spenge', 'wh')
    else
      who:=0
    endif

  endif

  gnCenpr=cenpr
  cenprr=cenpr
  gnTcen=tcen
  gnRp=rp
  gcCopt=copt
  gnKklm=kkl
  gnOst0=ost0
  gnRasc=rasc
  gcBopt=bopt
  gnSnds=nds
  gnVttn=vttn
  gnBlk=blk
  gnTskl=tskl
  pathr=gcPath_c
  gnOtv=0
  gdNPrd=nprd
  if (gnCtov=0)
    if (file(gcPath_m+alltrim(path)+'tovd.dbf'))
      gnCtov=2
    endif

  endif

  gcDir_t=alltrim(path)
  nuse('cskl')
  gcPath_t=gcPath_d+gcDir_t
  gnOtv=0
  if (netfile('pr1'))
    /*   netind('pr1') */
    netuse('pr1')
    if (fieldpos('otv')#0)
      locate for otv=1
      if (foun())
        gnOtv=1
      endif

    endif

    nuse('pr1')
  endif

  nuse('spenge')
  return (.t.)
