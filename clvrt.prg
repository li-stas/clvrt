#include 'directry.ch'
#include 'common.ch'
#define LF CHR(10)
#define CR CHR(13)
#define _T ";" //CHR(9)
*FUNCTION clvrt(cDosParam)
//LOCAL a-SumAccord
LOCAL lNo_Deb
LOCAL nSum, cPathOst019, cPathOst058, i, mDt
MEMVAR gnArm, ngMerch_Sk241

PUBLIC gnArm, ngMerch_Sk241



cDosParam := ALLTRIM(UPPER(DOSPARAM()))

IF EMPTY(cDosParam) .OR. ALLTRIM(cDosParam)==ALLTRIM(UPPER(EXENAME()))
  cDosParam:=UPPER("/first")
ENDIF

IF UPPER("/?") $ cDosParam
  ?"/first - "
  ?"/gdTd  - выбор периода"
  ?"/kolmod - 0-all"
  ?"/buhsk - (0-all;1-buh;2-skl)"
  ?"/gnEnt= - 99 код предприятия"
  ?""
  ?"/index -переидексация "
  ?"/crdoc - корр док "
  ?"/sd  -  передача на удаленные"
  ?"         /kolmod /buhskr (0-all;1-buh;2-skl)"
  ?"/s0d -  передача на удаленные ВСЕ тек месяца"
  ?"/rc  - прием с удаленных тек месяц"
  ?"       /cron - одни месяц назад"
  ?"/deb   - расчет Дебиторки"
  ?
  ?"/slavutich       - передача данных Славутича "
  ?"     /repite-zip - повторить передачу архива за день назад от текущего"
  ?"     /dtBeg      - дата начала периода формата YYYYMMDD"
  ?"     /dtEnd      - дата окончания периода формата YYYYMMDD"
  ?"                 - даты должны находится в отчентом периоде /gdTd"
  ?"     /CrmAdd     - передача без перетеки данных - добавление,"
  ?"                   по умолчанию данные перетираются "
  ?"     /support    - передача данных на альтенативный елект. адрес"
  ?"     /ost-dt    - передача данных на альтенативный елект. адрес"
  ?
  ?"/accord          - доготовка данных для Аккорда"
  ?"     /dtBeg      - установка даты формирования даных Аккорда"
  ?"     /vzr        - данные возращенные, но не подвержденные"
  ?"     /osn-n      - данные начала переиода"
  ?
  ?"/kpk_put         - подготовить выгрузку данны для КПК"
  ?"/kpk_get         - загрузить данные для КПК"
  ?"          может быть указн /kta=NNN, где NNN - код ТА"
  ?"/kpk_lrs         - обработать данные локальных баз"
  ?"/kpk_crm         - обратотать данные CRM и получить локальные базы"
  ?"           /kpk_crm может быть запущен с /all - обработака всех складов"
  ?"/cron     запуск clvrt по crontab "
  ?"/tzvk            - проверка Дебиторки с Заданием"
  INKEY(0)
  QUIT
ENDIF
gnArm:=0

Set Date       GERMAN
Set Deleted    ON
Set Bell       OFF
Set Confirm    ON
Set Intensity  ON
Set Talk       OFF
Set Wrap       ON
Set ScoreBoard OFF
set epoch to 1980
set cent on
set excl off

set device to print
set print to clvrt.log ADDI

?"Start clvrt", cDosParam,date(), time()

/*
?'Общая память для симв перем'+str(memory(0),10)
?memory(1)
?'Память для RUN             '+str(memory(2),10)
*/
  *******************************
  adirect=directory('*.cdx')
  if len(adirect)#0
     for i:=1 to len(adirect)
         fl:=LOWER(adirect[i,1])
         if 'accord_deb'$ fl
           loop
         endif
         dele file (fl)
     next
  endif
  *******************************

  stor '' to gcPath_m,gcPath_l,gcPath_e,gcPath_g,gcPath_d,Pathr,gcnEnt,;
             gcPath_b,gcPath_t,gcPath_tt,gcNot,gcTovdop,gcPath_h,gcPath_gl,;
             gcDir_e,gcDir_g,gcDir_d,gcDir_b,gcDir_t,gcDir_tt,gcDir_h,gcDir_gl,;
             gcUname,fnlrsay,gcCotp,gcCent,gcName_cp,gcDir_ep,gcPath_cg,gcPath_cd,;
             gcDisk,gcPath_w,gcPath_an,gcPath_ew,gcEot,gcIn,gcOut

  store 0 to gnKmes,gnEnt,gnSkt,gnSklt,gnTcen,gnD0k1,gnRegrs,gnOt,gnCtov,;
          gnSpech,gnSnds,gnFox,gnKart,gnEntp,gnBlk,gnRprd,dnPrd,gnSdRc
  store 1 to gnVu,gnOut,gnScOut
  store 0 to mnu,zz0,gnEntrm,gnRmsk,gnRm,gnRmbs,gnKt,prxmlr,gnSkOtv
  store 0 to wmessr,key,mnu,prc177r,mntov177r,prupr
  store 0 to ktlr,ktlpr,gnKklm,gnVo,gnTovd,gnTovo,dkklnr,gnCenr,gnCenp,;
             gnVttn,pr361r,kpsbbr,prvzznr
  store 0 to fnlr  // Признак закрытия месяца
  store ctod('07.08.2013') to gdDec
  store ctod('') to gdNPrd

  kolmodr=1
  buhskr=0

  gnPre=0 // 2
  gnPret=0 // 0.5

  gcPath_l=diskname()+':'+dirname()

  setdate(nnetsdate(),isat())

  gdTd:=date()
  IF UPPER("/gdTd") $ cDosParam
    gdTd:=IIF(AT("/GDTD",cDosParam)#0, ;
    STOD(SUBSTR(cDosParam,AT("/GDTD",cDosParam)+LEN("/gdTd"),8)), ;
    date())
  ENDIF


  gcDir_a= 'astru\'
  gcDir_c= 'comm\'
  gcDir_b= 'bank\'
  gcDir_gl='glob\'

  gcDir_g:='g'+str(year(gdTd),4)+'\'
  gcDir_d:='m'+iif(month(gdTd)<10,'0'+str(month(gdTd),1),str(month(gdTd),2))+'\'

  gdSd=date()  // Системная дата
  gdTdf=date()



  Frame="┌─┐│┘─└│"

#ifdef __CLIP__
    store map() to gaKassa
    gcNNETNAME:=GETENV("RemoteHost")
    gcNNETNAME:=TOKEN(gcNNETNAME,".",1)
    IF EMPTY(gcNNETNAME)
      gcNNETNAME:=GETENV("SSH_CLIENT")
      gcNNETNAME:=TOKEN(gcNNETNAME," ",1)
    ENDIF
    aaa=''
    for i=len(cHomeDir) to 1 step -1
        if subs(cHomeDir,i,1)='/'
           unamer=aaa
           gcUname=aaa
           exit
        else
            aaa=subs(cHomeDir,i,1)+aaa
        endif
    next
#else
  unamer=netname()
  gcUname=netname()
  gcNNETNAME:=""
#endif

  cenprr=0 // 1 - Разрешить ввод цены в приходе (skl.cenapr)

  sele 20
  if file(gcPath_l+'\_slct.dbf')
     erase (gcPath_l+'\_slct.dbf')
  endif

  crtt('_slct',"f:kod c:c(12) f:kol c:n(12,6)")

  if select('_slct')#0
     sele _slct
     use
  endif


  sele 0
  use shrift excl
  if neterr()
     set print to clvrt.log ADDI
     ?"Stop clvrt shrift excl", cDosParam,date(), time()
     quit
  endif

  gcDisk=subs(path_m,1,3)
  gcPath_m=alltrim(path_m)
  gcPath_ini=alltrim(path_m)
  gcPath_c=gcPath_m+gcDir_c
  gcPath_a=gcPath_m+gcDir_a

  IF UPPER("/kolmod") $ cDosParam
     nkolmod=at(upper('/kolmod'),cDosParam)+8
     kolmodr=val(subs(cDosParam,nkolmod,2))
  ELSE
     kolmodr=1
  ENDIF
  IF UPPER("/buhsk") $ cDosParam
     nbuhsk=at(upper('/buhsk'),cDosParam)+7
     buhskr=val(subs(cDosParam,nbuhsk,1))
  ELSE
     buhskr=0
  ENDIF
  IF UPPER("/gnEnt") $ cDosParam
     ngnEnt=at(upper('/gnEnt'),cDosParam)+7
     gnEnt=val(subs(cDosParam,ngnEnt,2))
  ELSE
     gnEnt=ent
  ENDIF
  gnEntp=0
  if fieldpos('entp')#0
     gnEntp=entp
  endif
  gnKmes=kmes
  gcDir_h='help\'
  gcPath_h=gcPath_m+gcDir_h
  if fieldpos('path_a')#0
     gcPath_aa=alltrim(path_a)
  endif

//  use


  gnOut=2
//  set print to txt.txt

  gcDir_c='comm\'
  gcPath_c=gcPath_m+gcDir_c
if gcDisk='i:\'.and.len(gcPath_m)=3
   if dirchange('j:\')=0
      gcPath_w='j:\'
   else
      gcPath_w=gcPath_m+'upgrade\'
      if dirchange(gcPath_m+'upgrade')#0
         dirmake(gcPath_m+'upgrade')
      endif
   endif
  dirchange(gcPath_l)

else
   gcPath_w=gcPath_m+'upgrade\'
   if dirchange(gcPath_m+'upgrade')#0
      dirmake(gcPath_m+'upgrade')
   endif
endif
dirchange(gcPath_l)


  sele 0
  use (gcPath_c+'setup') share
  loca for ent=gnEnt
  nEntr=alltrim(nEnt)
  gnEntrm=entrm
  if gnEntrm=1
     sele 0
     use (gcPath_c+'rmsk') share
     locate for ent=gnEnt
     gnRmsk=rmsk
     gnRmbs=rmbs
     use
  endif
  if at(nEntr,gcPath_m)#0
     gnComm=1
  else
     gnComm=0
  endif
  if gnComm=1
     pathmr=subs(gcPath_m,1,len(gcPath_m)-len(nEntr)-1)
     pathcsr=pathmr+'comm\'
     pathasr=pathmr+'astru\'
     pathctr=gcPath_m+'comm\'
     pathatr=gcPath_m+'astru\'
     copy file (pathcsr+'dbft.dbf') to (pathctr+'dbft.dbf')
     copy file (pathcsr+'dir.dbf') to (pathctr+'dir.dbf')
     afl:=directory(pathmr+'astru\*.dbf')
     for i=1 to len(afl)
         flr=lower(afl[i,1])
         copy file (pathasr+flr) to (pathatr+flr)
         fflr=strtran(flr,'.dbf','.fpt')
         if file(pathasr+fflr)
            copy file (pathasr+fflr) to (pathatr+fflr)
         endif
     next
  endif

  dirgr='g'+str(year(gdTd),4)
  if dirchange(gcPath_c+dirgr)#0
     dirmake(gcPath_c+dirgr)
  endif
  dirchange(gcPath_l)

  mr=month(gdTd)

  dirmr='\m'+iif(mr<10,'0'+str(mr,1),str(mr,2))
  if dirchange(gcPath_c+dirgr+dirmr)#0
     dirmake(gcPath_c+dirgr+dirmr)
  endif
  dirchange(gcPath_l)

  gcPath_cg=gcPath_c+dirgr+'\'
  gcPath_cd=gcPath_c+dirgr+dirmr+'\'

  Pathr=gcPath_c

  sele 0
  tt=gcPath_c+'dbft'
  use (tt) shared

  sele 0
  tt=gcPath_c+'dir'
  use (tt) share

  gcName='Администратор'
  gnKto=0
  gnAdm=1
  who=3
  gnSPech=1

  gdTdn=ctod(stuff(dtoc(gdTd),1,2,'01'))
  gdTdk=kmes(gdTd)
  aaa=date()

  *****************************************************************
  sele setup
  LOCATE FOR ent=gnEnt
  gcnEnt=alltrim(nEnt)
  gcDir_e=alltrim(nEnt)+'\'
  gcPath_e=gcPath_m+gcDir_e
  gnKln_c   = KKL
  gcName_c  = USS
  gnBank_c  = KB1
  gcNbank_c = OB1
  gcScht_c  = NS1
  gcFname_c = upr
  gcAdr_c   = adr
  gnKnal_c  = nn
  gcTlf_c   = tlf
  gcSvid_c  = nsv
  gcNdir_c  = direct
  gcNbuh_c  = buhg
  gnNds=nds
  gnKkl_c=kkl7
  if fieldpos('cotp')#0
     gcCotp=alltrim(cotp) // Отпускная цена
  endif
  if gnEntp#0
     LOCATE FOR ent=gnEntp
     gcnEntp=alltrim(nEnt)
     gcName_cp  = USS
     gcDir_ep=alltrim(nEnt)+'\'
     if fieldpos('cotp')#0
        gcCotpp=alltrim(cotp) // Отпускная цена Поставщика
     endif
  endif

  gcPath_ew=gcPath_w+gcDir_e
  gcPath_in=gcPath_ew+'in\'
  gcPath_out=gcPath_ew+'out\'
  if dirchange(gcPath_w+gcnEnt)#0
     dirmake(gcPath_w+gcnEnt)
  endif
  dirchange(gcPath_l)

  gcPath_an=gcPath_ew+'an\'
  if dirchange(gcPath_ew+'an')#0
     dirmake(gcPath_ew+'an')
  endif
  dirchange(gcPath_l)

  if dirchange(gcPath_ew+'\kpk')#0
     dirmake(gcPath_ew+'\kpk')
  endif
  dirchange(gcPath_l)

  gcPath_129=gcPath_ew+'ttn129\'
  gcPath_139=gcPath_ew+'ttn139\'
  gcPath_151=gcPath_ew+'ttnlist\'
  gcPath_169=gcPath_ew+'ttn169\'
  gcPath_177=gcPath_ew+'ttn177\'

  gcPath_Photo:=gcPath_e + 'photodoc'


  #ifdef __CLIP__
    gcIn='j:\'+'e'+padl(alltrim(str(gnEnt,2)),2,'0')+'\in\'
    gcOut='j:\'+'e'+padl(alltrim(str(gnEnt,2)),2,'0')+'\out\'
    if dirchange('j:\'+'e'+padl(alltrim(str(gnEnt,2)),2,'0'))#0
       dirmake('j:\'+'e'+padl(alltrim(str(gnEnt,2)),2,'0'))
    endif
    dirchange(gcPath_l)

    if dirchange('j:\'+'e'+padl(alltrim(str(gnEnt,2)),2,'0')+'\in')#0
       dirmake('j:\'+'e'+padl(alltrim(str(gnEnt,2)),2,'0')+'\in')
    endif
    dirchange(gcPath_l)
    if dirchange('j:\'+'e'+padl(alltrim(str(gnEnt,2)),2,'0')+'\out')#0
       dirmake('j:\'+'e'+padl(alltrim(str(gnEnt,2)),2,'0')+'\out')
    endif
    dirchange(gcPath_l)
  #else
    gcIn='g:\work\upgrade\'+'e'+padl(alltrim(str(gnEnt,2)),2,'0')+'\in\'
    gcOut='g:\work\upgrade\'+'e'+padl(alltrim(str(gnEnt,2)),2,'0')+'\out\'
    if dirchange('g:\work\upgrade\'+'e'+padl(alltrim(str(gnEnt,2)),2,'0'))#0
       dirmake('g:\work\upgrade\'+'e'+padl(alltrim(str(gnEnt,2)),2,'0'))
    endif
    dirchange(gcPath_l)
    if dirchange('g:\work\upgrade\'+'e'+padl(alltrim(str(gnEnt,2)),2,'0')+'\in')#0
       dirmake('g:\work\upgrade\'+'e'+padl(alltrim(str(gnEnt,2)),2,'0')+'\in')
    endif
    dirchange(gcPath_l)
    if dirchange('g:\work\upgrade\'+'e'+padl(alltrim(str(gnEnt,2)),2,'0')+'\out')#0
       dirmake('g:\work\upgrade\'+'e'+padl(alltrim(str(gnEnt,2)),2,'0')+'\out')
    endif
    dirchange(gcPath_l)
#endif

  dirchange(gcPath_l)

//  use

  // Имена полей в CTOV для отпускной цены,ее времени изменения и MNTOV
  // своего предприятия и предприятия поставщика
  gcOpt='opt'+iif(gnEnt<10,'0'+str(gnEnt,1),str(gnEnt,2))
  gcDopt='dopt'+iif(gnEnt<10,'0'+str(gnEnt,1),str(gnEnt,2))
  gcMntov='mntov'+iif(gnEnt<10,'0'+str(gnEnt,1),str(gnEnt,2))
  if gnEntp#0
     gcOptp='opt'+iif(gnEntp<10,'0'+str(gnEntp,1),str(gnEntp,2))
     gcDoptp='dopt'+iif(gnEntp<10,'0'+str(gnEntp,1),str(gnEntp,2))
     gcMntovp='mntov'+iif(gnEntp<10,'0'+str(gnEntp,1),str(gnEntp,2))
  endif

  netuse('prd')

  private menu1[gnKmes]

  do while .t.
     msr=month(gdTd)
     godr=year(gdTd)
     if msr<10
     else
        monr='m'+str(msr,2)+'\'
     endif
     gcPath_e=gcPath_m+gcnEnt+'\'
     gcDir_g='g'+str(godr,4)+'\'
     gcPath_g=gcPath_e+'g'+str(godr,4)+'\'

     monr=msr
     yy=godr
     pzcr=1

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

     pozicion=1
     mm=monr
     k=1
     do while k<gnKmes+1
        if mm<10
           zz1='a'+str(mm,1)
        else
           zz1='a'+str(mm,2)
        endif
        menu1[k]=&zz1+' '+str(yy,4)
        mm=mm-1
        if mm=0
           mm=12
           yy=yy-1
        endif
        k=k+1
     endd

     godr=val(subs(menu1[1],10,4))
     gcDir_g='g'+str(godr,4)+'\'
     gcPath_g=gcPath_e+'g'+str(godr,4)+'\'
     if monr<10
        gcDir_d='m0'+str(monr,1)+'\'
     else
        gcDir_d='m'+str(monr,2)+'\'
     endif
     gcPath_d:=gcPath_g+gcDir_d
     gcPath_b=gcPath_d+'bank\'
     gcDir_b='bank\'
     gcPath_gl=gcPath_d+'glob\'
     gcDir_gl='glob\'

     netuse('cskl')

     if select('skl')=0
        copy stru to (gcPath_l+'\skl.dbf')
        sele 0
        use skl excl
     else
        sele skl
        zap
     endif

      //определение мерч склада пре-тия
      SELECT cskl
      set index to
      LOCATE FOR ent=gnEnt .AND. !EMPTY(Merch) //Merch=1
      IF FOUND()
        ngMerch_Sk241:=cskl->Sk
        #ifdef __CLIP__
        outlog(__FILE__,__LINE__,Date(),TIME(),cDosParam ,"ngMerch_Sk241", ngMerch_Sk241)
        #endif
      ELSE
        #ifdef __CLIP__
        outlog(__FILE__,__LINE__,"Нет мерч склада для пред", gnEnt)
        #endif
      ENDIF

      nuse('cskl')


     skl()

     sele skl
     go top
     if eof()
        gdTd=eom(addmonth(gdTd,-1))
        if year(gdTd)<1998
           //@ 23,0
           ?'Нет доступных складов в CSKL,обратитесь к АДМИНИСТРАТОРУ'
           retu
        endif
        loop
     else
        exit
     endif
  enddo
  gcPath_df:=gcPath_d
  gcDir_df:=gcDir_d
  gdTdf:=gdTd

  Nsklr = STR(SKL,4) + " " + NSKL
  gcNdir=alltrim(PATH)
  gcDir_t=alltrim(PATH)
  gcPath_t = gcPath_d+gcDir_t
  if file(gcPath_t+'tovo.dbf')
     gnTovo=1
  endif
  // Определение закрытия месяца
  if file(gcPath_t+'final.dbf')
     fnlr=1
     fnlrsay='Месяц закрыт'
  endif

  // Режим работы АРМа
  if fieldpos('ctov')#0
     gnCtov=ctov
  else
     gnCtov=0
  endif
  if file(gcPath_t+'tovd.dbf').and.!gnCtov=1
     gnCtov=2
  endif
  do case
     case gnCtov=0
          gcTovdop=''     // Обычный
     case gnCtov=1        // Общий справочник товара
          gcTovdop='ctov'
     case gnCtov=2        // Разделенный справочник товара
          gcTovdop='tovd'
     othe
          gnCtov=0
          gcTovdop=''     // Обычный
  endc
  gcPath_tf=gcPath_df+gcDir_t
  gnSkl=skl
  gcNskl=alltrim(nskl)
  Sklr  = SKL
  Who   = WH          //WH = 1 - склад  WH = 2 - отдел WH = 3 - администр
  gnSk=SkOtv
  gnSkOtv=sk
  gnTcen=tcen
  gnCenpr=cenpr
  gnRoz=roz
  gnRp=rp
  gnMskl=mskl
  cenprr=cenpr
  gnKklm=kkl
  gcCopt=copt
  gcNcopt=ncopt
  gnSnds=nds
  gnVttn=vttn
  if fieldpos('ost0')#0
     gnOst0=ost0
  else
     gnOst0=0
  endif
  if fieldpos('bopt')#0
     gcBopt=bopt
  else
     gcBopt=0
  endif
  if fieldpos('blk')#0
     gnBlk=blk
  else
     gcBopt=0
  endif
  use

  gaKop:={;
  {169,"169-Нал. без док", 1,GUID_KPK("AD5",ALLTRIM(STR( 1169)))},;
  {161,"161-Нал. с док"  , 2,GUID_KPK("AD5",ALLTRIM(STR( 2161)))},;
  {160,"160-Отср. с док" , 3,GUID_KPK("AD5",ALLTRIM(STR( 3160)))},;
  {129,"129-!БОМБАЖ!----", 4,GUID_KPK("AD5",ALLTRIM(STR( 4129)))},;
  {139,"139-!ПРОСРОЧКА!-", 5,GUID_KPK("AD5",ALLTRIM(STR( 5139)))},;
  {126,"777-*!!АКЦИЯ!!*" , 6,GUID_KPK("AD5",ALLTRIM(STR( 6126)))},;
  {160,"160-Отср. c док" , 7,GUID_KPK("AD5",ALLTRIM(STR( 7160)))},;
  {169,"169-Нал. без док", 8,GUID_KPK("AD5",ALLTRIM(STR( 8169)))},;
  {161,"161-Нал. с док"  , 9,GUID_KPK("AD5",ALLTRIM(STR( 9161)))},;
  {160,"160-Отср. с док" ,10,GUID_KPK("AD5",ALLTRIM(STR(10160)))},;
  {126,"777-*!!АКЦИЯ!!*" ,11,GUID_KPK("AD5",ALLTRIM(STR(11126)))},;
  {160,"160-Отср. c док" ,12,GUID_KPK("AD5",ALLTRIM(STR(12160)))};
  }


netuse('setup')

/*
//sleep(50)
set print to clvrt.log ADDI
?"Stop clvrt", date(), time()
QUIT
*/

DO CASE
CASE UPPER("/GUID") $ cDosParam
  //CLEAR SCREEN
  //
  ?uuid()

  //wait

CASE UPPER("/first") $ cDosParam
  first()
CASE UPPER("/index") $ cDosParam
  index() //изменение структур
CASE UPPER("/crdoc") $ cDosParam
  crdoc() //корр док
CASE UPPER("/rc") $ cDosParam
     buhskr=0  // все
     rmmn(2,1) // принят и одни днень
     IF UPPER("/cron") $ cDosParam
        gdTd=gomonth(gdTd,-1) // сменить месяц
        buhskr=0
        rmmn(2,1)
     ENDIF
CASE UPPER("/sd") $ cDosParam
  rmmn(1,kolmodr,buhskr) // передать и /kolmod /buhskr
CASE UPPER("/s0d") $ cDosParam
  rmmn(1) // передать все

CASE UPPER("/debTPok") $ cDosParam
   TPokKegK() // тара из тарного склада

CASE UPPER("/deb03tov") $ cDosParam
  dtBegr:=dtEndr:=date()
  IF UPPER("/dtBeg") $ cDosParam
    Dt_Beg_End(cDosParam,.T.,@dtBegr,@dtEndr)
  endif
  Tov_Trs2(dtBegr) // расшифровка документа до позиций

CASE UPPER("/deb03") $ cDosParam // расчет Д-ки по 361002 тара
  dtBegr:=dtEndr:=date()
  IF UPPER("/dtBeg") $ cDosParam
    Dt_Beg_End(cDosParam,.T.,@dtBegr,@dtEndr)
    outlog(__FILE__,__LINE__,dtBegr,dtEndr)
    d2:=d1:=dtBegr
    If UPPER("/dtEnd") $ cDosParam
      d1:=dtBegr
      d2:=dtEndr
    EndIf
    FOR dBackDay:=d1 TO d2 STEP 1
      debn03(,dBackDay) //
    Next

  else
    // TPokKegK() // тара из тарного склада
    // quit
    debn03(,dtBegr)
    //Tov_Trs2(dtBegr) // расшифровка документа до позиций

  endif
case UPPER("/ActMntov") $ cDosParam

  netuse('ctov')

  kplr=4151028
  kgpr=2259318
  mntovr=3410917

  kplr:=kta_DosParam(cDosParam,'/kpl=',7)
  kgpr:=kta_DosParam(cDosParam,'/kgp=',7)
  MnTovr:=kta_DosParam(cDosParam,'/mntov=',7)
  MnTovA1r:=MnTovr
  MnTovAr:=kta_DosParam(cDosParam,'/mntovA=',7)

  outlog(__FILE__,__LINE__,'kplr,kgpr,mntovr',kplr,kgpr,mntovr)

  if Act_MnTov4_MnTov()
    outlog(__FILE__,__LINE__,'mntovr,MnTovAr',;
    iif(mntovr=MnTovAr,.T.,mntovr=MnTovA1r),;
    mntovr,MnTovAr)
  else
    outlog(__FILE__,__LINE__,'mntovr,MnTovAr',;
    mntovr=MnTovAr,;
    mntovr,MnTovAr)
  endif
  outlog(__FILE__,__LINE__,'zen', AktsSWZen(MnTovr,Kgpr,Kplr, Date()))




CASE UPPER("/debn") $ cDosParam
  dtBegr:=dtEndr:=date()
  IF UPPER("/dtBeg") $ cDosParam
    outlog(__FILE__,__LINE__,dtBegr,dtEndr)
    Dt_Beg_End(cDosParam,.T.,@dtBegr,@dtEndr)
    outlog(__FILE__,__LINE__,dtBegr,dtEndr)
  Else
    //
  EndIf
  deb(631001,dtBegr)

  //debn()
  //tpokkegk()
  //deb(361001, STOD('20170701')) //

CASE UPPER("/deb") $ cDosParam
  dtBegr:=dtEndr:=date()
  IF UPPER("/dtBeg") $ cDosParam
    deb(361001, dtBegr) //
  else
    //TPokKegk()
    // quit
    deb(361001,dtBegr)
    TPokKegk()
  endif
CASE UPPER("/JaffaOrder") $ cDosParam
  JaffaRedOstOrder(cDosParam)

  //
CASE UPPER("/JaffaOrdZap") $ cDosParam
  JaffaOrdZap()

CASE UPPER("/TPstOrder") $ cDosParam
  TPokOrder(cDosParam,{||ent=gnEnt.and.TPsTPok=1},107,1) // kop, vo

CASE UPPER("/tpokOrder") $ cDosParam
  /*
  '/kpl=' задается плательщик, для обработки

         задав плательщика  0000000 (7 - нулей) -
         обрабатываются ВСЕ плательщики с НУЛЕВЫМИ остатками, но
         развернутыми КТЛ. '/mntov=' и '/mntov2=' не задаются.


  '/mntov=' задается какой код товар обрабатывать
         9999999  (7 - девяток)

  '/mntov2=' задается на какой код товара перебрасывать


  задание mntov= без mntov2=, обнуляет все КТЛ и если есть остаток, то
  записывает на одни КТЛ


  */
  TPokOrder(cDosParam)
  //LRsPack()
  //close

CASE UPPER("/TPokSk263kop111") $ cDosParam
  // в ск-де Брак, остатки обнулим приход 111
  TPokOrder(cDosParam,{||ent=gnEnt.and.sk=263},111,6)

  sele lrs2
  repl all kvp with kvp * (-1)
  close

  sele lrs1
  close

CASE UPPER("/auto-pfakt") $ cDosParam

  Pr1IniMemVar()

  netuse('kps')
  netuse('kpl')
  netuse('s_tag')
  netuse('kln')

  TestSumQ_TPok()

  use lrs1 new Exclusive
  Do While !lrs1->(eof()) .and. lrs1->(RecNo()) <= 5000
    gnSk:=lrs1->Skl
    mnr:=lrs1->kps

    AutoPFakt(mnr,gnSk)

    lrs1->(DBSkip())
  EndDo

  TestSumQ_TPok(.t.)
  TestSumQ_TPok(,{||ent=gnEnt.and.TPsTPok = 1})

CASE UPPER("/pfakt") $ cDosParam

  Pr1IniMemVar()

  // gnEnt - определено
  // gdTd -  определено
  if (UPPER("/gnSk") $ cDosParam)
    gnSk:=val(SUBSTR(cDosParam, AT("/GNSK=", cDosParam)+LEN("/gnSk="), 3))
  else
    gnSk:=263
  endif

  if (UPPER("/mn") $ cDosParam)
    mnr:=val(SUBSTR(cDosParam, AT("/MN=", cDosParam)+LEN("/MN="), 6))
  endif
  If empty(mnr)
    outlog(__FILE__,__LINE__,'empty(mnr)')
    quit
  EndIf

  netuse('kps')
  netuse('kpl')
  netuse('s_tag')
  netuse('kln')

  Autopfakt(mnr,gnSk) //

  quit

CASE UPPER("/delta") $ cDosParam
  DDIA_delta("126", "34012600", "Delta", ;
  "lista@bk.ru,auto.exchange@delta-food.com.ua","OOO TDDelta")
CASE UPPER("/runa") $ cDosParam
  DDIA("041", "1005", "Runa", "n.zimovec@gmail.com","(Runa)")


CASE UPPER("/spod2d-zoze") $ cDosParam

  //spod2d("017", "7", "zoze", "lista@bk.ru,alena@pradata.com","(Золоте_Зерно)",;
  spod2d("017", "7", "kpk", "lista@bk.ru","(Золоте_Зерно)",;
         STOD("20131101"))
  QUIT

CASE UPPER("/spod2d-kvas") $ cDosParam

  spod2d("120", "28", "COCA", "lista@bk.ru","(Квас Беверидж)")
  QUIT


CASE UPPER("/kvas") $ cDosParam
  if (dirchange('idx')#0)
    dirmake('idx')
  endif
  dirchange(gcPath_l)


  cNmIndFl='qwe'
  outlog(__FILE__,__LINE__,file('idx\'+cNmIndFl+'.*'))

  QUIT

  /*
  Маркодержатель - 120 (Квас Беверидж)
  отправлять 2 отчета ежедневно.
  email: vnosenko@coca-cola.com


  */
  aMessErr:={}
  if .T.
    dtBegr:=dtEndr:=DATE()

    IF (UPPER("/get-date") $ UPPER(DosParam()))

      clvrt_get_date(@dtBegr,@dtEndr,;
      "Подготовка отчета 120 (Квас Беверидж) данных за период.",;
      "имя файла архива ol_<дата1>-<дата2>.zip",;
      {|a1,a2| a1<=a2 .and. BOM(a1)=BOM(a2) };
    )

      IF LASTKEY()=13
        set device to print
        set print to clvrt.log ADDI

        gdTd:=BOM(dtBegr)

      ELSE
        RETURN
      ENDIF
    ELSE
      IF UPPER("/dtBeg") $ cDosParam
        Dt_Beg_End(cDosParam,.T.,@dtBegr,@dtEndr)
      ELSE
        dtEndr:=date()-1
        dtBegr:=BOM(dtEndr)
      ENDIF
    ENDIF

    mkkplkgp(120,nil)
    MkOtchN_Range(120,@dtBegr,@dtEndr,cDosParam)
    //MkOtchN(dtBegr,092,NIL,1,dtEndr) //,{||.T.}) //1 все склады
  else
        dtEndr:=date()-1
        dtBegr:=BOM(dtEndr)
  endif

   netuse('s_tag')
   netuse('kgp')
   netuse('kgpcat')
   netuse('kln')
   netuse('krn')
   netuse('knasp')


  /*
  Продажи
  */

  set("PRINTER_CHARSET","cp1251")
  //set("PRINTER_CHARSET","koi8-u")
  SET DATE FORMAT "DD.MM.YYYY" //"yyyy-mm-dd"
  SET CENTURY ON

   use mkdoc120 alias mkdoc new  Exclusive
   append from mkpr120
   repl bar  with mntovt+0*(2*10^13*0) for empty(bar)

  //Отчет №1 (продажи за один день)- mkdoc.dbf
  //колонки:
  copy to sales ;
  for VO=9 ;// (только 9)!!!
       ;
  field ;
    KGP,;// - код грузополучателя
    KPL,;// - код плательщика
    NGP,;// - наименование груполучателя
    NPL,;// - наименование плательщика
    AGP,;// - адрес грузополучателя
    SK ,;//- код склада
    NSK,;// - наименование склада
    TTN,;// - ТТН отгрузки
    KOP,;// - код операции
    DTTN,;// - дата отгрузки
    BAR,;// - штрихкод продукции
    NAT,;// - наименование продукции
    KVP,;// - кол-во продукции, шт.
    DCL,;// - кол-во продукции, литры
    NNASP,;
    NRN

  /*
  Номенклатура  остатаки
  */

  use mktov120 alias  mktov new Exclusive
  repl bar  with mntovt+0*(2*10^13*0) for empty(bar)
  index on str(bar)+str(sk) to tmpmktov for ngMerch_Sk241 # Sk //.and. bar# mntovt
  total on str(bar)+str(sk) field OsFo to tmpmktov
  close mktov

  use tmpmktov alias  mktov new

  //Отчет №2 (остатки на текущую дату) - mktov.dbf
  //колонки:
  copy to stock ;
  field ;
  SK,;// - код склада
  NSK,;// - наименование склада
  BAR,;// - штрихкод продукции
  NAT,;// - наименование продукции
  OSFO,;// - остаток продукции, шт.
  DT // - дата формирование остатка


   nuse('krn')
   nuse('knasp')
   nuse('kgpcat')
   nuse('kgp')
   nuse('s_tag')
   nuse('kln')

    cLogSysCmd:=""
  #ifdef __CLIP__
    cRunZip:="/usr/bin/zip"
    cFileNameArc:="kvas_"+DTOS(dtBegr)+"-"+DTOS(dtEndr)+".zip"
    cFileList:="stock.dbf sales.dbf"+;
    ""


    SYSCMD(cRunZip+" "+cFileNameArc+" "+;
    cFileList,"",@cLogSysCmd)

    qout(__FILE__,__LINE__,cLogSysCmd)
      cMessErr:=""
       //SendingJafa("r eal.prodresurs@mail.ru,lista@bk.ru,vnosenko@coca-cola.com",{{ cFileNameArc,;
       //"vchumak@coca-cola.com",;
       SendingJafa(;
       "real.prodresurs@mail.ru",;
       {{ cFileNameArc,;
      ;//SendingJafa("lista@bk.ru",{{ cFileNameArc,;
      translate_charset(host_charset(),"utf-8","Маркодержатель - 120 (Квас Беверидж)");
      +" "+DTOC(DATE(),"YYYYMMDD")}},;
      cMessErr,;
      228)


    IF !EMPTY(aMessErr)
      cMessErr:=""
      AEVAL(aMessErr,{|cElem|cMessErr += cElem })
      SendingJafa("real.prodresurs@mail.ru,lista@bk.ru",{{ "","Error 120 (Квас -ProdResSumy"+" "+DTOC(DATE(),"YYYYMMDD")}},;
      cMessErr,;
      228)

    ENDIF
  #endif

CASE UPPER("/OblnActSW") $ cDosParam

  OblnActSW() // чтение акций

  cPth_Plt_lpos=gcPath_ew+'arnd'
  PosObolonRead(cPth_Plt_lpos, 'pos.xml') // чтение оборудования

CASE UPPER("/obolon") $ cDosParam
  lNo_Deb := (UPPER("/no_deb") $ UPPER(cDosParam))

  DO CASE
  CASE UPPER("/lpos_xml") $ cDosParam
    cPth_Plt_lpos=gcPath_ew+'arnd'
    If ! UPPER("/no_mkotch") $ cDosParam
      PosObolonRead(cPth_Plt_lpos, 'pos.xml') // чтение оборудования
      SbArOst(27)
    EndIf
    SbArOst2Swe(cPth_Plt_lpos) // предварительно считаный pos.xml & ->pos_swe.dbf
    lod2swe2xml(cPth_Plt_lpos)

    //copy file pos.xml to (cPth_Plt_lpos+'\pos.xml')

    // запуск передачи ФТП
    cCmd:='CUR_PWD=`pwd`; cd /m1/upgrade2/lodis/arnd; ';
    +'./put-ftp-POS.sh;  cd $CUR_PWD'
    cLogSysCmd:=''
    SYSCMD(cCmd,"",@cLogSysCmd)
    outlog(__FILE__,__LINE__,cCmd)


    lod2swe2sql(cPth_Plt_lpos)


  CASE UPPER("/repite") $ cDosParam
    aFileListZip:={}
    IF (UPPER("/FlMn") $ UPPER(cDosParam))
        gdTd:=BOM(DATE())
        dtBegr:=BOM(DATE())
        dtEndr:=EOM(DATE())
      Dt_Beg_End(cDosParam,.T.,@dtBegr,@dtEndr)
      d1:=dtBegr ;    d2:=dtEndr

    ELSE
      dtBegr:=dtEndr:=DATE()
      Dt_Beg_End(cDosParam,.T.,@dtBegr,@dtEndr)
      d1:=dtBegr ;    d2:=dtEndr
    ENDIF

    IF d1 = d2

      pilot2_obolon("/no_mkotch /CrmAdd",d1,;
      "Full",@aFileListZip,lNo_Deb)

    ELSE
      //добавлени данных предыдущих дней
      FOR dBackDay:=d1 TO d2 STEP 1
        IF dBackDay = d1
          //удаление данных до конца месяца
          pilot2_obolon("/no_mkotch",dBackDay,"NoCopyZip",@aFileListZip,lNo_Deb)
        ELSE
          pilot2_obolon("/no_mkotch /CrmAdd",dBackDay,;
          IIF(dBackDay = d2,"Full","NoCopyZip"),@aFileListZip,lNo_Deb)
        ENDIF
      NEXT
    ENDIF

  CASE UPPER("/dtBeg") $ cDosParam ;
    .OR. (UPPER("/get-date") $ UPPER(cDosParam)) ;
    .OR. (UPPER("/FlMn") $ UPPER(cDosParam))
    aFileListZip:={}

    // просчет без передачи

    pilot2_obolon(cDosParam, , , aFileListZip,lNo_Deb)

  OTHERWISE
    // обновление прошлого и текуего дня
    IF val(ltrim(left(time(),2)))>=21 .or. (UPPER("/online") $ UPPER(cDosParam))
      dStartOthet:=date()-0
    ELSE
      dStartOthet:=date()-1
    ENDIF
    aFileListZip:={}

    IF !(UPPER("/online") $ UPPER(cDosParam)) .AND. !(UPPER("/HendMake") $ UPPER(cDosParam))
      cNo_mk:="/no_mkotch"
      bBackDay := 5
      //удаление данных до конца месяца по первому дню
      pilot2_obolon(cNo_mk,(dStartOthet-bBackDay),"NoCopyZip",@aFileListZip,lNo_Deb)
      //добавлени данных предыдущих дней
      FOR dBackDay:=(dStartOthet-bBackDay)+1 TO dStartOthet-1 STEP 1
        cCmdParam:=cNo_mk+" /CrmAdd"
        IF dBackDay = BOM(dBackDay) // если встретилось начало месяца
          cCmdParam:=cNo_mk //удаление до конца месяца
        ENDIF

        cCmdCopyZip:="NoCopyZip"
        IF dBackDay = dStartOthet-1 //на последнем дне цикла копируем.
          // cCmdCopyZip:="Full"
          cCmdCopyZip:="NoCopyZip"
        ENDIF

        pilot2_obolon(cCmdParam,dBackDay,cCmdCopyZip,@aFileListZip,lNo_Deb)

      NEXT
      // пересчет
      cNo_mk:=''
      cCmdParam:=cNo_mk+" /CrmAdd"

    ENDIF

    If (UPPER("/online") $ UPPER(cDosParam))
      // +1
      If bom(dStartOthet)=bom(dStartOthet+1) // обе даты в одном месяце
        pilot2_obolon(cDosParam, dStartOthet+1,'NoCopyZip', @aFileListZip, (lNo_Deb,.T.), YES) // c не выполнеными заявками
      else
        // текущий день
        pilot2_obolon(cDosParam, dStartOthet,'NoCopyZip' , @aFileListZip,lNo_Deb) //, dStartOthet)
      EndIf
    else
      // текущий день
      pilot2_obolon(cDosParam, dStartOthet,'NoCopyZip' , @aFileListZip,lNo_Deb) //, dStartOthet)
    EndIf


    IF !(UPPER("/online") $ UPPER(cDosParam)) .AND. !(UPPER("/HendMake") $ UPPER(cDosParam))
      If .T. .OR. BOM(gdTd) = BOM(dStartOthet+1)
        // Д-ку с перд дня и расчет не отгруженных
        pilot2_obolon(cDosParam, dStartOthet+1,'NoCopyZip', @aFileListZip, (lNo_Deb,.T.), YES) // c не выполнеными заявками

      EndIf

    ENDIF

    // передача
    cPath_Pilot:=gcPath_ew+"obolon\cus2swe"
    cPth_Plt_tmp:=gcPath_ew+"obolon\cus2swe.tmp"
    OblnSend(aFileListZip,cPth_Plt_tmp,cPath_Pilot)

  ENDCASE

CASE UPPER("/OblnOrdZap") $ cDosParam
  OblnOrdZap()

CASE UPPER("/OblnSend") $ cDosParam

  dtBegr:=dtEndr:=date()

  If UPPER("/dtBeg") $ cDosParam
      Dt_Beg_End(cDosParam,.T.,@dtBegr,@dtEndr)
  Else
    //dtBegr:=dtEndr:=date()
  EndIf

  cPath_Pilot:=gcPath_ew+"obolon\cus2swe"
  cPth_Plt_tmp:=gcPath_ew+"obolon\cus2swe.tmp"

  aFileListZip:={}

  FOR i:=dtBegr TO dtEndr
    //имя архива с путем
    cFileNameArc:=cPth_Plt_tmp+"\"+"ob"+;
    SUBSTR(DTOS(i),3)+;
    ".zip"
    cFileArcNew:=cPath_Pilot+"\"+"ob"+;
    SUBSTR(DTOS(i),3)+;
    ".zip"
    AADD(aFileListZip,{cFileNameArc,cFileArcNew})
  //копирование
    copy file (cFileNameArc) to (cFileArcNew)

  NEXT i
  outlog(3,__FILE__,__LINE__,aFileListZip)

  OblnSend(aFileListZip,cPth_Plt_tmp,cPath_Pilot)

CASE UPPER("/olejna") $ cDosParam
  //cListNoSaleSk:="254 256 255 259"+STR(ngMerch_Sk241,3)
  cListNoSaleSk:="254 256 255 259 403 "+STR(ngMerch_Sk241,3)

  aMessErr:={}
  if .T.
    dtBegr:=dtEndr:=DATE()

    IF (UPPER("/get-date") $ UPPER(DosParam()))
      IF DAY(DATE())<7
        dtBegr:=BOM(ADDMONTH(date(),-1))
        dtEndr:=EOM(ADDMONTH(date(),-1))
      ELSE
        dtBegr:=BOM(date())
        dtEndr:=EOM(date())
      ENDIF
      clvrt_get_date(@dtBegr,@dtEndr,;
      "Подготовка отчета ОЛЕЙНА данных за месяц",;
      "(даты могут быть любыми отчетного месяца)",;
      {|a1,a2| a1<=a2 .and. BOM(a1)=BOM(a2) };
    )

      IF LASTKEY()=13
        set device to print
        set print to clvrt.log ADDI

        gdTd:=BOM(dtBegr)
        dtBegr:=BOM(dtBegr)
        dtEndr:=EOM(dtEndr)

      ELSE
        RETURN
      ENDIF
    ELSE
      IF UPPER("/dtBeg") $ cDosParam
        Dt_Beg_End(cDosParam,.T.,@dtBegr,@dtEndr)
      ELSE
        dtEndr:=date()-1
        dtBegr:=BOM(dtEndr)
      ENDIF
    ENDIF

    IF !(UPPER("/no_mkotch") $ UPPER(DosParam()))
      mkkplkgp(092,nil)
      MkOtchN_Range(092,@dtBegr,@dtEndr,cDosParam)
    ENDIF
  else
        dtEndr:=date()-1
        dtBegr:=BOM(dtEndr)
  endif

   netuse('s_tag')
   netuse('kgp')
   netuse('kgpcat')
   netuse('krn')
   netuse('knasp')
   netuse('kln')


  /*
  Продажи
  */

  set("PRINTER_CHARSET","cp1251")
  //set("PRINTER_CHARSET","koi8-u")
  SET DATE FORMAT "DD.MM.YYYY" //"yyyy-mm-dd"
  SET CENTURY ON

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO sales_tmpl.txt

   use mkpr092 alias mkpr new  Exclusive
      copy to mkprv01 for vo=1 .or. (vo=6 .and. kop=111)
   close
    use mkprv01 new Exclusive
    repl all kvp with kvp*(-1)
    close mkprv01


   use mkdoc092 alias mkdoc new  Exclusive
   append from mkprv01
   repl bar  with mntovt+0*(2*10^13*0) for empty(bar)

   DBGoTop()
   i:=0
   Do While !mkdoc->(eof())
     If mkdoc->(vo=9 .or. vo=1 .or. (vo=6 .and. kop=111)) ;
      .and. ngMerch_Sk241 # mkdoc->Sk //.and. bar# mntovt
      kln->(netseek('t1','mkdoc->kpl'))
      cLine:=;
      ;//str(int(mkdoc->mntovt/10^3))+_T+;
      DTOC(mkdoc->dttn)+_T+;//,"DD.MM.YYYY"Дата (DD.MM.YYYY)
      "34012600"+_T+;//ЕДРПОУ Дистрибьютора
      alltrim(mkdoc->NaT)+_T+;//Товар
      LTRIM(str(mkdoc->bar))+_T+;//Штрих-код
      LTRIM(str(mkdoc->kvp))+_T+;//Кол-во
      LTRIM(str(mkdoc->(IIF((zenn=0,.T.),zen,zenn))*1.2,15,2))+_T+; //Цена 05-23-17 04:59pm -.t.
      LTRIM(str(mkdoc->OKPO))+_T+; //LTRIM(str(kln->kkl1)) +_T+;//ОКПО Клиента
      ALLTRIM(kln->nkl)+_T+;//Юридическое название клиента
      LTRIM(str(mkdoc->kgp))+_T+;//Код розничной точки
      (;
      s_tag->(netseek('t1','mkdoc->kta')),;
      PADL(LTRIM(STR(mkdoc->kta)),4,"0")+"_"+ALLTRIM(s_tag->fio);
    )+_T+;//Торговый агент
      (;
      ktasr:=getfield('t1','mkdoc->kta','s_tag','ktas'),;
      s_tag->(netseek('t1','ktasr')),;
      PADL(LTRIM(STR(ktasr)),4,"0")+"_"+ALLTRIM(s_tag->fio);
    )+_T+;//Супервайзер
      ltrim(str(mkdoc->mntovt))//код товара

      IF i=0
        QQOUT(cLine)
        i++
      ELSE
        QOUT(cLine)
      ENDIF

     EndIf

     mkdoc->(DBSkip())
   EndDo

  SET PRINT TO
  SET PRINT OFF

  /*
  Номенклатура  остатаки

  */

  use mktov092 alias  mktov new Exclusive
  repl bar  with mntovt+0*(2*10^13*0) for empty(bar)

  index on mntovt to tmpmktov for !(STR(mktov->Sk,3) $ cListNoSaleSk)
  total on mntovt  field OsFo  to tmpmktov

  /*
  index on bar to tmpmktov for !(STR(mktov->Sk,3) $ cListNoSaleSk)
  //ngMerch_Sk241 # Sk //.and. bar# mntovt
  total on bar field OsFo to tmpmktov
  */
  close mktov

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO stock_tmpl.txt

  use tmpmktov alias  mktov new
   i:=0
   dOtch:=dtEndr //dtBegr
  Do While !mktov->(eof())
     If .T.
      //!(STR(mktov->Sk,3) $ cListNoSaleSk) .and. ;


      mktov_OsFo := mktov->OsFo
      IF mktov->OsFo  < 0
        cLine:=;
        DTOC(dOtch)+_T+;//,"DD.MM.YYYY"Дата (DD.MM.YYYY)
        "34012600"+_T+;//ЕДРПОУ Дистрибьютора
        alltrim(mktov->NaT)+_T+;//Товар
        LTRIM(str(mktov->bar))+_T+;//Штрих-код
        LTRIM(str(mktov_OsFo))+_T+;//Кол-во
        LTRIM(str(mktov->CenPr*mktov_OsFo*1.2,15,2))+_T+;//Сумма всего
        ltrim(str(mktov->mntovt))//код товара

        AADD(aMessErr,"Кол-во '-' "+cLine+CHR(10)+CHR(13))

        mktov_OsFo:=0
      ENDIF

      cLine:=;
      DTOC(dOtch)+_T+;//,"DD.MM.YYYY"Дата (DD.MM.YYYY)
      "34012600"+_T+;//ЕДРПОУ Дистрибьютора
      alltrim(mktov->NaT)+_T+;//Товар
      LTRIM(str(mktov->bar))+_T+;//Штрих-код
      LTRIM(str(mktov_OsFo))+_T+;//Кол-во
      LTRIM(str(mktov->CenPr*mktov_OsFo*1.2,15,2))+_T+;//Сумма всего
      ltrim(str(mktov->mntovt))//код товара

      IF i=0
        QQOUT(cLine)
        i++
      ELSE
        QOUT(cLine)
      ENDIF
    endif
    mktov->(DBSkip())
  EndDo

  SET PRINT TO
  SET PRINT OFF



  sele mkdoc
  index on str(OKPO)+str(kgp) to tmpkgp ;
  for  mkdoc->(vo=9 .or. vo=1 .or. (vo=6 .and. kop=111)) ;
    .and. ngMerch_Sk241 # Sk
  //.and. int(mkdoc->mntovt/10^4)=311
  total on str(OKPO)+str(kgp) to tmpkgp

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO plc_tmpl.txt

  /*
  Торговые точки
  */
  use tmpkgp new
  i:=0

  Do While tmpkgp->(!eof())
    kln->(netseek('t1','tmpkgp->kpl'))

    cLine:=;
    LTRIM(str(tmpkgp->OKPO))+_T+;//ОКПО Клиента //    LTRIM(str(kln->kkl1))+_T+;//ОКПО Клиента
    LTRIM(str(tmpkgp->kgp))+_T+;//Код розничной точки
    (kln->(netseek('t1','tmpkgp->kgp')),;
    alltrim(getfield("t1","kln->krn","krn","nrn"))+" "+;       //Район
    alltrim(getfield("t1","kln->knasp","knasp","nnasp"))+" "+; //Город
    alltrim(tmpkgp->agp)+" "+;//Физическое местонахождение
    alltrim(tmpkgp->ngp); //.." "//09-10-14 02:38pm Назв. груз. пол. (Ищенко)
  )

    IF i=0
      QQOUT(cLine)
      i++
    ELSE
      QOUT(cLine)
    ENDIF

    tmpkgp->(DBSkip())
  EndDo
  SET PRINT TO
  SET PRINT OFF

   nuse('krn')
   nuse('knasp')
   nuse('kgpcat')
   nuse('kgp')
   nuse('s_tag')
   nuse('kln')

    cLogSysCmd:=""
  #ifdef __CLIP__
    cRunZip:="/usr/bin/zip"
    cFileNameArc:="ol_"+DTOS(dtBegr)+"-"+DTOS(dtEndr)+".zip"
    cFileList:="stock_tmpl.txt sales_tmpl.txt plc_tmpl.txt"+;
    ""


    SYSCMD(cRunZip+" "+cFileNameArc+" "+;
    cFileList,"",@cLogSysCmd)

    qout(__FILE__,__LINE__,cLogSysCmd)

    IF !EMPTY(aMessErr)
      cMessErr:=""
      AEVAL(aMessErr,{|cElem|cMessErr += cElem })
      SendingJafa("real.prodresurs@mail.ru,lista@bk.ru",{{ "","Error Olejna-ProdResSumy"+" "+DTOC(DATE(),"YYYYMMDD")}},;
      cMessErr,;
      228)

    ENDIF
  #endif


CASE UPPER("/aquaplast") $ cDosParam
  //spod2d("119", "73", "aqpl", "lista@bk.ru","(aquaplast)",;
  spod2d("119", "73", "aqpl", "lista@bk.ru","(aquaplast)",;
         STOD("20131101"),'258;402;') // !(str(sk,3) $ cListSkSox)
  QUIT

CASE UPPER("/sox-aqpl") $ cDosParam
  spod2d("119", "173", "aqsx", "lista@bk.ru","(aquaplast-sox)",;
         STOD("20131101"),'258;402;','SOX') // !(str(sk,3) $ cListSkSox)
  QUIT


CASE UPPER("/RptJafa") $ cDosParam
  RptJafaSpod2D(cDosParam)
  QUIT

CASE UPPER("/jafa") $ cDosParam .AND. UPPER("/sox") $ cDosParam
    IF UPPER("/dtBeg") $ cDosParam
      Dt_Beg_End(cDosParam,.T.,@dtBegr,@dtEndr)
    ELSE
      dtBegr:=date()-1
      dtEndr:=date()-1
    ENDIF
    /* * p1 - date дата прихода
       * p2 - date месяц прихода
       * p3 - sk
       * p4 - kps       */
     sox(dtBegr,p2,p3,p4)
     //передача по е-почте
CASE UPPER("/indcmnst") $ cDosParam
  indxcmnst()
CASE UPPER("/indxnst") $ cDosParam
  // indxnst() 11-08-17 03:08pm
CASE UPPER("/jafa") $ cDosParam
  djaffa()
CASE UPPER("/listGetKpk") $ cDosParam
  listGetKpk(cDosParam)
CASE UPPER("/slav") $ cDosParam
  dtBegr:=date()
  dtEndr:=date()
  IF UPPER("/dtBeg") $ cDosParam
    Dt_Beg_End(cDosParam,.T.,@dtBegr,@dtEndr)
  ENDIF

  set('DBF_CHARSET','cp1251')
  OblnPayments(dtBegr)
  OblnOrders(dtBegr)
  OblnOrdZap(.T.)  // удалить   // добавить считанные
  set('DBF_CHARSET','cp866')

  //slavutich()
CASE UPPER("/edin") $ cDosParam
  EdinOrders(cDosParam)
    // kpk_billa()
CASE UPPER("/accord") $ cDosParam

  //set("PRINTER_CHARSET","cp866")
  set("PRINTER_CHARSET","koi8-u")
  //a-SumAccord:={}

  //Accord_RS1(dtBegr,dtEndr,gaKop)
  //Accord_Dokk(dtBegr,dtEndr)

  DO CASE
  CASE UPPER("/vzt") $ cDosParam
      Accord_VztDoc(gaKop)
  CASE UPPER("/moddoc") $ cDosParam
      Accord_ModDoc(gaKop)
  CASE UPPER("/ost-n") $ cDosParam
      Accord_ost(gdTd,gaKop)



  CASE UPPER("/all") $ cDosParam
      IF UPPER("/dtBeg") $ cDosParam
        dtBegr:=dtEndr:=DATE()
        Dt_Beg_End(cDosParam, .F.,@dtBegr,@dtEndr)
        #ifdef __CLIP__
            outlog(__FILE__,__LINE__,"Учетные периоды  dtBeg dtEnd ",dtBegr, dtEndr)
        #endif
        //dtEndr:=dtBegr
        FOR dOtch:=dtBegr TO dtEndr

          CreateAccordXml(dOtch,dOtch,NIL,gaKop)

        NEXT
      ENDIF
  ENDCASE


CASE UPPER("/pepsi") $ cDosParam
  /*
  mkkplkgp(19,nil)
  mkkplkgp(58,1)
  */
  #ifdef __CLIP__
     Xml2Rs1_4CRM("j:\resurs\crm","crmorder.xml",gaKop)
  #endif
  //mkotch(STOD("20080321"),19,NIL,1) //1 все склады
  /*
  set("PRINTER_CHARSET","cp866")
  slavu("058")
  */
CASE UPPER("/kpk_xml") $ cDosParam
  Xml2Rs1(".","to1c.xml",gaKop)

CASE UPPER("/kpk_put") $ cDosParam
  ppc(ASIZE(ACLONE(gaKop),5))
CASE UPPER("/kpk_get") $ cDosParam
  ppc_get(ASIZE(ACLONE(gaKop),5))
  //aGetFld()
CASE UPPER("/kpk_lrs") $ cDosParam
  fromkpk_merch()
  //aGetFld()
CASE UPPER("/kpk_swe") $ cDosParam
  ObolonOrder(cDosParam)
CASE UPPER("/kpk_jfa") $ cDosParam
  JaffaOrders(cDosParam)
  //aGetFld()
CASE UPPER("/kpk_crm") $ cDosParam
  #ifdef __CLIP__
     Xml2Rs1_4CRM("j:\resurs\crm","crmorder.xml",gaKop)
  #endif
  //Xml2Rs1_4CRM(".\","crmorder.xml")
  set("PRINTER_CHARSET","cp866")
  lRs1_CRMOrdStat()
CASE UPPER("/crm_ord") $ cDosParam
  SET DATE FORMAT "yyyy-mm-dd"
  SET CENTURY ON
  set("PRINTER_CHARSET","cp866")
  lRs1_CRMOrdStat()

CASE UPPER("/rd_631") $ cDosParam
  rd_631()

CASE UPPER("/rd_anb") $ cDosParam
  rd_anb()

CASE UPPER("/kop139-69") $ cDosParam
  kop139_69()

  quit

CASE UPPER("/oblswr") $ cDosParam
  oblswr()

CASE UPPER("/tzvk") $ cDosParam
  if gnEntrm=0
    skr=228
  else
    skr=400
  endif

  netuse('cskl')
  sele cskl
  netseek('t1','skr')
  pathr=gcPath_d+alltrim(path)
  gnKt=kt
  dirskr=alltrim(path)

  netuse('kln')
  netuse('klndog')

  netuse('rs1')
  set order to 't1'
  netuse('rs2')
  set order to 't1'
  netuse('rs3')
  set order to 't1'
  netuse('rso1')
  set order to 't2'


  netuse('kpl')
  netuse('kgp')
     If file(gcPath_ew+"deb\accord_deb"+".dbf")
        netuse('dkkln')
        USE (gcPath_ew+"deb\accord_deb") ALIAS skdoc NEW SHARED READONLY
        SET ORDER TO TAG t1
        lAccDeb:=.T.
     EndIf
  tzvk_chsk() // проверка документов последняя

  i := 0
  n := 0
  m := 0
  sele rs1
  set filt to valpos(LEFT(LTRIM(GpsLat),1)) <> 0 ;
    .and. ttn = DocId
  DBGOTOP()
  DO WHILE !eof()
    i++
    kgpr:=kpv
    sele kln
    If netseek('t1','kgpr')
      If empty(GpsLat)
        netrepl('GpsLat,GpsLon',{rs1->GpsLat,rs1->GpsLon})
        n++
      EndIf
      // outlog(__FILE__,__LINE__,GpsLat,GpsLon)
      m++
    endif
    sele rs1
    DBSKIP()
  ENDDO

  outlog(__FILE__,__LINE__,str(i,4),str(n,4),str(m,4), "полученно записано к-т")
  //outanetseek()

  //quit

CASE UPPER("/nds20") $ cDosParam
  quit
  smr:=25.99
  zenr:=43.33
  kvp_r:=0; zen_r:=zenr; sm10r:=round(round(smr/(100+gnNDS),2)*100,2)
    TmpSvp4Trs2()
  zenr:=zen_r; kvpr:=kvp_r

CASE UPPER("/Iptc") $ cDosParam
    Iptc_Foto()
CASE UPPER("/bank") $ cDosParam
  bank361email()
  quit

CASE UPPER("/jsonmap") $ cDosParam
  //  mkkplkgp(27,nil)
  //ActSW_tt()
  //quit
  /*
  ActSW_idAct()
  ActSW_prod()
  quit
  */

  /*
  //cNat:='qwertertr АКЦ кцкцукцук N1234 wrwer'
  cNat:='АКЦ 5678 N 7890 wrwer'

  OUTLOG(__FILE__,__LINE__,cNat)
  OUTLOG(__FILE__,__LINE__, DeleChrWd_AKZ(cNat))

  cNat:='qwertertr АКЦ кцкцукцук N 1234 wrwer'

  OUTLOG(__FILE__,__LINE__,cNat)
  OUTLOG(__FILE__,__LINE__, DeleChrWd_AKZ(cNat))
  QUIT
  */

  cPth_Plt_lpos=gcPath_ew+'arnd'
  PosObolonRead(cPth_Plt_lpos, 'pos.xml')

  // quit
  //  pos.xml write
  cPth_Plt_lpos=gcPath_ew+'arnd'

  SbArOst2Swe(cPth_Plt_lpos) //?
  lod2swe2xml(cPth_Plt_lpos)

  quit
  /// end pos.xml


  /// чтение spod3d
  cL := memoread('import.json')
  cL := CHARREM(CHR(10),cL)

  oD:=JsonDecode(cL)
  outlog(__FILE__,__LINE__,oD['data'])

  outlog(__FILE__,__LINE__,'moneys')
  If 'moneys' $ oD['data']
    outlog(__FILE__,__LINE__,LEN(oD['data']['moneys']),oD['data']['moneys'])

    // перечень д-тов забора денег
    For i:=1 To 1 //LEN(oD['data']['moneys'])
      outlog(__FILE__,__LINE__,oD['data']['moneys'][i]['id'])
      outlog(__FILE__,__LINE__,'  ',oD['data']['moneys'][i]['date'])
      outlog(__FILE__,__LINE__,'  ',oD['data']['moneys'][i]['peopleCode'])
      outlog(__FILE__,__LINE__,'  ',oD['data']['moneys'][i]['clientCode'])
      outlog(__FILE__,__LINE__,'  ',oD['data']['moneys'][i]['sum'])
      outlog(__FILE__,__LINE__,'  ',oD['data']['moneys'][i]['PaymentID'])
    Next

  EndIf

  outlog(__FILE__,__LINE__,'orders')
  If 'orders' $ oD['data']
    For i:=1 To LEN(oD['data']['orders'])
      oOrder:=oD['data']['orders'][i]
      outlog(__FILE__,__LINE__,oOrder['id'],oOrder['code'])
      outlog(__FILE__,__LINE__,'  ',oOrder['date'])
      outlog(__FILE__,__LINE__,'  ',oOrder['peopleCode'])
      //outlog(__FILE__,__LINE__,'  ',oOrder["priceCode"])
      outlog(__FILE__,__LINE__,'  ',oOrder["IdentCertificate"])
      outlog(__FILE__,__LINE__,'  ',oOrder["IdentOperationCode"])
      outlog(__FILE__,__LINE__,'  ',oOrder["ExpectedDeliveryDate"])
      outlog(__FILE__,__LINE__,'  ',oOrder["comment"])

      If "products" $ oOrder
         outlog(__FILE__,__LINE__,'  ',"  ","products")
         oRs2:=oOrder["products"]
         For k:=1 To len(oRs2)
           outlog(__FILE__,__LINE__,'  ',"  ",oRs2[k]['code'])
           outlog(__FILE__,__LINE__,'  ',"  ",oRs2[k]['quantity'])
         Next k

      EndIf
    Next
  EndIf

  quit
  ///  end  - чтение spod3d



 // заполнение к-т
  netuse('kln')

  // заполнение чз супперы
  sele kln

  cPath_coord:=gcPath_ew+"coord"  //"j:\lodis\obolon\cus2swe"
  USE (cPath_Coord+"\"+"COORD.DBF") ALIAS coord NEW READONLY
  i := 0 // просмотрено
  k := 0 // уже есть
  n := 0 // new
  DBGoTop()
  Do While !eof()
    cCoord := ALLT(coord->Coord)
    If Empty(cCoord)
      skip; loop
    EndIf

    kgpr := coord->kgp// n 10
    nPosS := AT(',',cCoord)
    sele kln
    If netseek('t1','kgpr')
      If empty(GpsLat)
        n++ // новые
        cGpsLat := left(cCoord,nPosS - 1)
        cGpsLon := ltrim(substr(cCoord,nPosS + 1))
        netrepl('GpsLat,GpsLon',{cGpsLat,cGpsLon})
      EndIf
      i++ // просмотрено
    else
      k++ // точка не найдена
    EndIf

    sele coord
    DBSkip()
  EndDo
  outlog(__FILE__,__LINE__,'всего',i,"новые",n,"нет ТТ",k,'заполнение к-т')

  quit


  /////////////////////////////////////////////////////////////////
  cPath_Order:=gcPath_ew+"obolon\swe2cus"  //"j:\lodis\obolon\cus2swe"

  #ifdef __CLIP__
    set translate path off
  #endif

  USE (cPath_Order+"\"+"OLCOORD.DBF") ALIAS coord NEW READONLY

  #ifdef __CLIP__
    set translate path on
  #endif
  i := 0 // просмотрено
  k := 0 // уже есть
  n := 0 // new
  DBGoTop()

  DBGoBottom();  DBSkip()

  Do While !EOF()
    nPosS := AT('-',coord->Ol_code)
    kgpr := VAL(LEFT(coord->Ol_code,nPosS-1))
    kplr := VAL(SUBSTR(LTRIM(coord->Ol_code), nPosS+1))
    sele kln
    If netseek('t1','kgpr')
      If empty(GpsLat)
        // перепутаны названия полей
        cGpsLat := str(coord->Latitude,10,7)
        cGpsLon := str(coord->Longitude,10,7)
        netrepl('GpsLat,GpsLon',{cGpsLat,cGpsLon})
        n++ // новые
      EndIf
      i++ // просмотрено
    else
      k++ // точка не найдена
    EndIf
    sele coord
    DBSkip()
  EndDo
  close coord
  outlog(__FILE__,__LINE__,'всего',i,"новые",n,"нет ТТ",k,'заполнение к-т')






  quit

CASE UPPER("/testczg") $ cDosParam
  nikolaPrice()
  quit

  /*
  nDist:=GMA_DistMatr('50.916988,34.7920503','50.8976135,34.7871896')
  nDist:=GMA_DistMatr('50.862293,34.9462870','50.8625533,34.9468783')
  //nDist:=GMA_DistMatr('50.916988,34.7920503','50.8976135,34.7871896')
  OUTLOG(__FILE__,__LINE__,nDist)
  quit
   nCntCenter := 3
   aCrd := {{'A',{-2,0}},{'B',{-2,-1}},{'C',{-3,0}},{'D',{4,0}},{'E',{3,0}},{'F',{0,0}}}
   aCenter := CenterSeek(aCrd, nCntCenter)

  OUTLOG(__FILE__,__LINE__, aCenter) //)

  OUTLOG(__FILE__,__LINE__, kmeans())
  //kmeans(aCrd,aCenter)

  //kmeans(aCrd,{aCenter[2],aCenter[1],aCenter[3]})
  //kmeans(aCrd,{ACLONE(aCrd[1]),ACLONE(aCrd[2]),ACLONE(aCrd[3])})


  quit

  // OUTLOG(__FILE__,__LINE__,mod(65,23),65%23)
  x1:=50.916988
  x2:=50.8976135
  y1:=34.7920503
  y2:=34.7871896

  OUTLOG(__FILE__,__LINE__,;
  latlng2distance(x1,y1, x2,y2))

  OUTLOG(__FILE__,__LINE__,;
  STR(latlng2distance((x1+x2)/2,(y1+y2)/2, x2,y2),9,3))
  OUTLOG(__FILE__,__LINE__,;
  latlng2distance(x2,y2,(x1+x2)/2,(y1+y2)/2))

  OUTLOG(__FILE__,__LINE__,;
  str(latlng2distance(x1,y1,(x1+x2)/2,(y1+y2)/2),9,3))

  OUTLOG(__FILE__,__LINE__,;
  latlng2distance((x1+x2)/2,(y1+y2)/2,x1,y1))



  */
  i := 0
  k := 0
  crtt('coordkgp', 'f:adr_full c:c(80) f:nkl c:c(30) f:kgp c:n(10) f:knasp c:n(4) f:krn c:n(4) f:coord c:c(30)')
  use coordkgp new Exclusive
  index on kgp to t1

  netuse('kln');  netuse('krn');  netuse('knasp')


  netuse('czg')
  DBGoTop()
  Do While !eof()
    k++
    kgpr:=kkl

    sele kln
    If netseek('t1','kgpr')
      If empty(GpsLat)
        cAdr := ''
        cAdr += ALLTRIM(kln->adr)
        cAdr += ', ' + ALLTRIM(getfield("t1","kln->knasp","knasp","nnasp"))
        cAdr += ', ' + ALLTRIM(getfield("t1","kln->krn","krn","nrn")) + ' район'
        cAdr += ', ' + 'Сумская обл, Украина'
        outlog(__FILE__,__LINE__,kgpr,allt(kln->nkl),cAdr)
        If !coordkgp->(DBSeek(kgpr))
           coordkgp->(DBAppend())
           coordkgp->adr_full := cAdr
           coordkgp->nkl := allt(kln->nkl)
           coordkgp->kgp := kgpr
           coordkgp->coord := ''
           coordkgp->knasp := kln->knasp
           coordkgp->krn   := kln->krn
        endif
        i++
      EndIf
    EndIf

    sele czg
    DBSkip()
  EndDo
  outlog(__FILE__,__LINE__,i,k,i/k*100,'не заполнение к-т в маршруте')

  quit


  nDist:=GMA_DistMatr(;
  '50.916988,34.7920503',;
  '"улица Малиновского, 10, Сумы, Сумская обл, Украина"',;
)

  nDist:=GMA_DistMatr('50.916988,34.7920503','50.8976135,34.7871896')
  OUTLOG(__FILE__,__LINE__,nDist)
  quit

  OUTLOG(__FILE__,__LINE__,nDist)
  quit




  nDist:=GMA_DistMatr(;
  '"улица Малиновского, 10, Сумы, Сумская обл, Украина"',;
  '"проезд Нины Братусь, 20, Сумы, Сумская обл, Украина"';
)
  OUTLOG(__FILE__,__LINE__,nDist)

  QUIT










  /*
  '{
     "destination_addresses" : [ "Malynovs'koho St, 10, Sumy, Sums'ka oblast, Ukraine" ],
     "origin_addresses" : [ "Niny Bratus Passage, 20, Sumy, Sums'ka oblast, Ukraine" ],
     "rows" : [
        {
           "elements" : [
              {
                 "distance" : {
                    "text" : "3.2 km",
                    "value" : 3157
                 },
                 "duration" : {
                    "text" : "11 mins",
                    "value" : 641
                 },
                 "status" : "OK"
              }
           ]
        }
     ],
     "status" : "OK"
  }'
  */


  cL := memoread('_logj')
  cL := CHARREM(CHR(10),cL)

  oD:=JsonDecode(cL)

    outlog(__FILE__,__LINE__, oD['status']) //, oD)
    outlog(__FILE__,__LINE__, oD)//:elements:distance:value)
    outlog(__FILE__,__LINE__, oD['rows']['elements']) //:distance:value)
    outlog(__FILE__,__LINE__, oD['rows']['elements']['distance']['value']) //:distance:value)
    outlog(__FILE__,__LINE__, oD['rows']['elements']['distance']['value']) //:distance:value)
    //outlog(__FILE__,__LINE__, oD:rows) //:elements:distance:value) //:distance:value)
    //outlog(__FILE__,__LINE__, oD['row'['elements']]) //:['distance']:['value'])
  /*
  cL := '[ "12,3", [123], {12,3}, 400 ]'
  m := split(cL,',')
  For i:=1 To len(m)
    outlog(__FILE__,__LINE__, m[i])

  Next
  */
  quit

CASE UPPER("/cmiv") $ cDosParam
  aM:={}
  aM1:={}
  aRez:={0}
  nLenRez:=0

  AADD(aM,{ 0,       1,        2,        3,      4  })
  AADD(aM,{ 1, {NIL,0},  {  5,0},  { 11,0}, {  9,0} })
  AADD(aM,{ 2, { 10,0},  {NIL,0},  {  8,0}, {  7,0} })
  AADD(aM,{ 3, {  7,0},  { 14,0},  {NIL,0}, {  8,0} })
  AADD(aM,{ 4, { 12,0},  {  6,0},  { 15,0}, {NIL,0} })

  /*
  AADD(aM,{ 0,       1,        2,        3,      4  })
  AADD(aM,{ 1, {NIL,0},  {  5,0},  { 11,0}, {  9,0} })
  AADD(aM,{ 2, {  5,0},  {NIL,0},  {  8,0}, {  7,0} })
  AADD(aM,{ 3, { 11,0},  {  8,0},  {NIL,0}, {  8,0} })
  AADD(aM,{ 4, { 09,0},  {  7,0},  {  9,0}, {NIL,0} })

  AADD(aM,{ 0,       1,        2,        3,      4  })
  AADD(aM,{ 1, {NIL,0},  {  5,0},  { 11,0}, {  9,0} })
  AADD(aM,{ 2, {100,0},  {NIL,0},  {  8,0}, {  7,0} })
  AADD(aM,{ 3, {100,0},  {100,0},  {NIL,0}, {  8,0} })
  AADD(aM,{ 4, {100,0},  {100,0},  {100,0}, {NIL,0} })
  */

  aM1:=ACLONE(aM)

  AEVAL(aM, {|aElem|outlog(__FILE__,__LINE__,aElem)})

  DO WHILE .T.
    outlog(__FILE__,__LINE__,'// 2. min строки')
    For i:=2 To LEN(aM)
      // первый не NIL э-нт
      For k:=2 To LEN(aM[i])
        nValElem:=aM[i,k][1]
        nMin:=nValElem
        If .not. ISNIL(nValElem); exit; EndIf
      Next

      // нахождния мин по строке
      For k:=2 To LEN(aM[i])
        nValElem:=aM[i,k][1]
        If ISNIL(nValElem); loop; EndIf
        nMin:=Iif(nValElem < nMin, nValElem, nMin)
      Next k

      // редукуция строки
      For k:=2 To LEN(aM[i])
        nValElem:=aM[i,k][1]
        If ISNIL(nValElem); loop; EndIf
        nValElem -= nMin
        aM[i,k][1]:=nValElem
      Next k
    // след строку
    Next i

    AEVAL(aM, {|aElem|outlog(__FILE__,__LINE__,aElem)})

    outlog(__FILE__,__LINE__,'// 4. min столбца')
    For i:=2 To LEN(aM[1])

      For k:=2 To LEN(aM)
      // первый не NIL э-нт
        nValElem:=aM[k,i][1]
        nMin:=nValElem
        If ISNIL(nValElem); loop; EndIf
        exit
      Next

      // нахождния мин по столбца
      For k:=2 To LEN(aM)
        nValElem:=aM[k,i][1]
        If ISNIL(nValElem); loop; EndIf
        nMin:=Iif(nValElem < nMin, nValElem, nMin)
      Next
      // редукуция столбца
      For k:=2 To LEN(aM)
        nValElem:=aM[k,i][1]
        If ISNIL(nValElem); loop; EndIf
        nValElem -= nMin
        aM[k,i][1]:=nValElem
      Next k
    Next i


    AEVAL(aM, {|aElem|outlog(__FILE__,__LINE__,aElem)})

    outlog(__FILE__,__LINE__,'// 6. вычисление оценок 0-вых клеток')
    // cм. весь массив ищем значение 0
    For i:=2 To LEN(aM)
      For k:=2 To LEN(aM[i])
        nValElem:=aM[i,k][1]

        If ISNIL(nValElem); loop; EndIf

        If nValElem = 0
           aM[i,k][2]:= Oczenka(aM,i,k) //оценка - мин по строке и столбцу
        EndIf

      Next k

    Next i
    AEVAL(aM, {|aElem|outlog(__FILE__,__LINE__,aElem)})

    outlog(__FILE__,__LINE__,'// 7. Редукция м-цы 0-вых клеток с мах оценкой')
    nMax:=0
    a_i2k:={}
    For i:=2 To LEN(aM)
      For k:=2 To LEN(aM[i])

        nValElem:=aM[i,k][2]
        If ISNIL(nValElem); loop; EndIf

        if  nValElem >= nMax  // >=
          nMax:=nValElem
          // запишим откуда - куда и длину
          // ном города - ном.строки, ном_город-ном.кол-ки, макс, элемныты
          a_i2k:={{aM[i,1],i},{aM[1,k],k},nMax,0,0}
        endif

      Next k

    Next i

    outlog(__FILE__,__LINE__,'// 7.2. NIL на оборатный маршрут',a_i2k[2,1],a_i2k[1,1]) //,a_i2k[5],a_i2k[4])

    // найдем по ном.города индексы
    a_i2k[4]:=ASCAN(aM,{|aElem| aElem[1] = a_i2k[2,1] }, 2) // строка
    a_i2k[5]:=ASCAN(aM[1],a_i2k[1,1]) // колонка

    If a_i2k[4] # 0 .AND. a_i2k[5] # 0  // начальный пункт
      aM[a_i2k[4],a_i2k[5]]:={NIL,0}
    endif
    AEVAL(aM, {|aElem|outlog(__FILE__,__LINE__,aElem)})
    //EndIf

    outlog(__FILE__,__LINE__,'// 7.1. Удаляем строку и столбец',str(a_i2k[1,2],2),str(a_i2k[2,2],2))
    // строку
    ADEL(aM, a_i2k[1,2])
    ASIZE(aM, LEN(aM)-1)
    // удаляем столбцы
    For i:=1 To LEN(aM)
      ADEL(aM[i], a_i2k[2,2])
      ASIZE(aM[i], LEN(aM[i])-1)
    Next i

    outlog(__FILE__,__LINE__,'// 7.3. удаляем все оценки')
    For i:=2 To LEN(aM)
      For k:=2 To LEN(aM[i])
        aM[i,k][2]:= 0
      Next k
    Next i

    AEVAL(aM, {|aElem|outlog(__FILE__,__LINE__,aElem)})


    //AEVAL(aM, {|aElem|outlog(__FILE__,__LINE__,aElem)})
    outlog(__FILE__,__LINE__,a_i2k)

    // запись
    IF EMPTY(ASCAN(aRez,a_i2k[1,1]))
      AADD(aRez,a_i2k[1,1])
    ENDIF
    IF EMPTY(ASCAN(aRez,a_i2k[2,1]))
      AADD(aRez,a_i2k[2,1])
    ENDIF


    // получение длины меж городами
    a_i2k[5]:=ASCAN(aM1[1],a_i2k[2,1]) // колонка
    a_i2k[4]:=ASCAN(aM1,{|aElem| aElem[1] = a_i2k[1,1] }, 2) // строка

    nLenRez += aM1[a_i2k[4],a_i2k[5]][1]

    If LEN(aM) = 2
      a_i2k[5]:=ASCAN(aM1[1],aM[1,2]) // колонка
      a_i2k[4]:=ASCAN(aM1,{|aElem| aElem[1] = aM[2,1] }, 2) // строка
      nLenRez += aM1[a_i2k[4],a_i2k[5]][1]
      exit
    EndIf

  ENDDO
  ADEL(aRez,1); ASIZE(aRez,LEN(aRez)-1)
  outlog(__FILE__,__LINE__,nLenRez,aRez)

  quit
    /*
    For i:=2 To LEN(aM)
      If aM[i,1] = a_i2k[2,1]
        a_i2k[4]:=i
        exit
      EndIf
    Next
    */

CASE UPPER("/mem") $ cDosParam

  dtBegr:=STOD('20180701')
  dtEndr:=EOM(dtBegr) //STOD('20180228')

  JoinMkDt(102,dtBegr, dtEndr)

  quit

  n=(2017+0)-2007
  outlog(__FILE__,__LINE__, NTOC(n,16),n,PADL(NTOC(n,16),2,'0'))
  n=(2017+128)-2007
  outlog(__FILE__,__LINE__, NTOC(n,16),n,PADL(NTOC(n,16),2,'0'))
  quit

  DtVzr=BOM(gDtd)
  dEnd:=STOD('20160901')
  Do While DtVzr >= dEnd

    outlog(__FILE__,__LINE__,DtVzr)

    DtVzr:=ADDMONTH(DtVzr,-1)
  EndDo


  /*
  тест проверки вхождения по условию

  12-02-16 10:25am
    !!! быстре всего if str(int(bsr/1000),3) $ '361,301,311'

  bsr=361000
  t1:=Seconds()
  For i:=1 To 100000
    x:=int(bsr/1000)
    if (x=311.or.x=301.or.x=361)
    endif
  Next
  outlog(__FILE__,__LINE__,str(t1-Seconds(),10,7))

  t1:=Seconds()
  For i:=1 To 100000
    if ascan({361,301,311},int(bsr/1000))#0
    endif
  Next
  outlog(__FILE__,__LINE__,str(t1-Seconds(),10,7))

  t1:=Seconds()
  For i:=1 To 100000
    if str(int(bsr/1000),3) $ '361,301,311'
    endif
  Next
  outlog(__FILE__,__LINE__,str(t1-Seconds(),10,7))
  */
  /*
  outlog(__FILE__,__LINE__,RANDOMIZE())
  //outlog(__FILE__,__LINE__,str(RANDOMIZE(),18,15))

  outlog(__FILE__,__LINE__,str(RANDOM(23),18,15))
  outlog(__FILE__,__LINE__,str(RANDOM(23),18,15))
  outlog(__FILE__,__LINE__,ROUND(RAND(403)*100,0))
  outlog(__FILE__,__LINE__,ROUND(RAND(403)*100,0))
  */
  /*
  outlog(__FILE__,__LINE__,gcPath_l,at('get',gcPath_l))
  cDir := posdel(gcPath_l, , 3) + 'put'
  outlog(__FILE__,__LINE__,cDir)
  cDir += 'put'
  //posrepl('put',gcPath_l, at('get',gcPath_l)) //,)

  outlog(__FILE__,__LINE__,cDir,gcPath_l)
  quit
  */

  //quit


  lRLk:=.T.
  nOldTnn := 250831
  nNewTnn := 252733

  sele rs1
  If lRLk .and. netseek('t1','nOldTnn')
    DBEval({|| lRLk:=dbRlock(RecNo())  },{|| lRLk },{|| ttn = nOldTnn  })
  EndIf

  sele rs2
  If lRLk .and. netseek('t1','nOldTnn')
    DBEval({|| lRLk:=dbRlock(RecNo())  },{|| lRLk },{|| ttn = nOldTnn  })
  EndIf

  sele rs3
  If lRLk .and. netseek('t1','nOldTnn')
    DBEval({|| lRLk:=dbRlock(RecNo())  },{|| lRLk },{|| ttn = nOldTnn  })
  EndIf

  sele rso1
  If lRLk .and. netseek('t2','nOldTnn')
    DBEval({|| lRLk:=dbRlock(RecNo())  },{|| lRLk },{|| ttn = nOldTnn  })
  EndIf

  If lRLk
    outlog(__FILE__,__LINE__, rs1->(dbRlockList()))
    sele rs1
    aRecLock:= dbRlockList();  nSize:=LEN(aRecLock)
    For i:=1 To nSize
      DBGoTo(aRecLock[i])
      _Field->ttn:= nNewTnn
    Next

    outlog(__FILE__,__LINE__, rs2->(dbRlockList()))
    sele rs2
    aRecLock:= dbRlockList();  nSize:=LEN(aRecLock)
    For i:=1 To nSize
      DBGoTo(aRecLock[i])
      _Field->ttn:= nNewTnn
    Next

    outlog(__FILE__,__LINE__, rs3->(dbRlockList()))
    sele rs3
    aRecLock:= dbRlockList();  nSize:=LEN(aRecLock)
    For i:=1 To nSize
      DBGoTo(aRecLock[i])
      _Field->ttn:= nNewTnn
    Next

    sele rso1
    outlog(__FILE__,__LINE__, rso1->(dbRlockList()))
    aRecLock:= dbRlockList();  nSize:=LEN(aRecLock)
    For i:=1 To nSize
      DBGoTo(aRecLock[i])
      _Field->ttn:= nNewTnn
    Next
  EndIf

  sele rs1
  dbunlock()
  sele rs1
  If lRLk //.and. netseek('t1','nOldTnn')
    DBEval({|| lRLk:=dbRlock(RecNo())  },{|| lRLk .and. ttn169 = nOldTnn })
  EndIf

  If lRLk
    outlog(__FILE__,__LINE__, len(rs1->(dbRlockList())), rs1->(dbRlockList()))
    sele rs1
    aRecLock:= dbRlockList();  nSize:=LEN(aRecLock)
    For i:=1 To nSize
      DBGoTo(aRecLock[i])
      _Field->ttn169:= nNewTnn
    Next
  EndIf



  /*
    проверка координат на одну ТТ
  // поиск к-т торг.точек за разные дни
  netuse('rs1')
  index on kpv tag kpv
  set filt to valpos(LEFT(LTRIM(GpsLat),1)) <> 0 ;
    .and. ttn = DocId

  nCp:=0

  DBGOTOP()
  DO WHILE !eof()
    //проверка на разные даты
    kpvr:=kpv
    dvpr:=dvp
    nRec:=RecNo()
    locate rest  for !(dvpr = dvp) while kpvr = kpv
    If FOUND()
      DBGOTO(nRec)
      copy to tmp ;
      field ttn, dvp, kta, kpv, GpsLat, GpsLon ;
      while kpvr = kpv
      If nCp = 0
        copy file tmp.dbf to tmp1.dbf
        use tmp1 Exclusive new
        nCp:=1
      Else
        sele tmp1
        append from tmp
      EndIf
    EndIf
    sele rs1
    DBSKIP()
  ENDDO
  //browse()
  */

  /*
  copy to tmp ;
  field ttn, dvp, kta, kpv, GpsLat, GpsLon ;
  for  valpos(LTRIM(GpsLat,1)) <> 0 ;
    .and. ttn = DocId
  */

  //r+';'+GpsLonr
  quit




 outlog(__FILE__,__LINE__,"5035.7774",DDMM2DDDD("5035.7774"),VAL("-"))
 outlog(__FILE__,__LINE__, EMPTY(VAL("-")))

  use mkkplkgp NEW //EXCLUSIVE
    INDEX ON STR(KPL)+STR(KGP) TAG "kpl_kgp"
    INDEX ON STR(KGP) TAG "kgp"

  ORDSETFOCUS("kpl_kgp")
  cKey:=str(3260349,7)

  outlog(dbseek(cKey), kpl, kgp)
  outlog(GoBottomFilt(cKey), kpl, kgp)


  quit
  aRec1:={1,2,3}

  p1="aRec1"
  p2:=EVAL(memvarblock(p1))

  outlog(__FILE__,__LINE__,("aRec1")[1],(p1)[2],aRec1[1],&p1[3],;
  EVAL(memvarblock("aRec1"))[2], EVAL(memvarblock(p1))[2])
  outlog(__FILE__,__LINE__, p2[2])
  @ 2,2 say "stop"
  inkey(0)
  QUIT

  @ 2,2 say "stop"
  inkey(0)
  CLEAR SCREEN
  numlicr=VAL(" 23456789012")
  serlicr=""
  dnlr:=date()

  cSerlic:=alltrim(serlicr)
  cKlnLic:=alltrim(STR(numlicr))
  IF !EMPTY(cSerlic)
    cKlnLic:=PADL(cKlnLic,6,'0')
  ELSE
    cKlnLic:=PADL(cKlnLic,12,'0')
    cKlnLic:=TRANSFORM(cKlnLic,"@R 9999-9999-9999")
  ENDIF
  ??'Лицензия N '+ cKlnLic
  IF !EMPTY(cSerlic)
    ?? ' Серия'+' '+ cSerlic
  ENDIF
  ??' '+dtoc(dnlr)


  numlicr=VAL(" 12345")
  serlicr="CF"
  dnlr:=date()

  cSerlic:=alltrim(serlicr)
  cKlnLic:=alltrim(STR(numlicr))
  IF !EMPTY(cSerlic)
    cKlnLic:=PADL(cKlnLic,6,'0')
  ELSE
    cKlnLic:=PADL(cKlnLic,12,'0')
    cKlnLic:=TRANSFORM(cKlnLic,"@R 9999-9999-9999")
  ENDIF
  ??'Лицензия N '+ cKlnLic
  IF !EMPTY(cSerlic)
    ?? ' Серия'+' '+ cSerlic
  ENDIF
  ??' '+dtoc(dnlr)


  QUIT

  use sales //skl
  DBF2XLS(ALIAS()+".xls") //,ALIAS())



  WAIT
  QUIT
  //outlog(__FILE__,__LINE__,MEMORY(0),MEMORY(1))
   netuse('rs1',,,1)
  Test_id(.T.)
   netuse('rs2',,,1)
  Test_id(.T.)
   netuse('rs3',,,1)
  Test_id(.T.)
   netuse('rs2m',,,1)
  Test_id(.T.)
   netuse('soper',,,1)
  Test_id(.T.)
   netuse('tov',,,1)
  Test_id(.T.)
   netuse('tovm',,,1)
  Test_id(.T.)
   netuse('rs1kpk',,,1)
  Test_id(.T.)
   netuse('rs2kpk',,,1)
  Test_id(.T.)
  //WAIT
  ERRORLEVEL(0)
  QUIT

CASE UPPER("/koz") $ cDosParam
  koz()
ENDCASE
if select('shrift')#0
   sele shrift
   use
endif
nuse()
netuse('setup')

set print to clvrt.log ADDI
#ifdef __CLIP__
  //outanetseek()

?"Stop clvrt", date(), time()
QUIT
#endif

proc skl
if gnAdm=1.or.(gnArm#3.and.gnArm#6)
   tt=gcPath_c+'cskl.dbf'
   if select('skl')=0
      sele 0
      use skl excl
   endif
   sele skl
   zap
   appe from &tt for ent=gnEnt
   sele skl
   go top
   do while !eof()
      tt=gcPath_d+alltrim(path)+'tprds01.dbf'
      if !file(tt)
         sele skl
         dele
      endif
      skip
   endd
endif

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  03-16-08 * 10:16:45pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Dt_Beg_End(cDosParam,lgdTd,dtBegr,dtEndr)
  IF .NOT. (UPPER("/FlMn") $ cDosParam)

    dtBegr:=STOD(SUBSTR(cDosParam,AT("/DTBEG",cDosParam)+LEN("/dtBeg"),8))

    IF !EMPTY(dtBegr) .AND. IIF(lgdTd,BOM(gdTd)=BOM(dtBegr),.T.)
      dtEndr:=IIF(AT("/DTEND",cDosParam)#0, ;
      STOD(SUBSTR(cDosParam,AT("/DTEND",cDosParam)+LEN("/dtEnd"),8)), ;
      date())
      DO CASE
      CASE EMPTY(dtEndr)
        dtEndr:=date()
      CASE BOM(gdTd) # BOM(dtEndr)
        #ifdef __CLIP__
           // outlog(__FILE__,__LINE__,;
           // "Разные учетные периоды BOM(gdTd)=BOM(dtEndr) ",BOM(gdTd),BOM(dtEndr))
           // outlog(__FILE__,__LINE__,;
           // "                                Принята дата ",EOM(gdTd))
        #endif
        dtEndr:=EOM(gdTd)
      ENDCASE

    ELSE
      #ifdef __CLIP__
         outlog(__FILE__,__LINE__,"Разные учетные периоды BOM(gdTd)=BOM(dtBegr)",BOM(gdTd),BOM(dtBegr))
      #endif
      QUIT
    ENDIF
    IF dtBegr > dtEndr
      #ifdef __CLIP__
         outlog(__FILE__,__LINE__,"Не верные учетные периоды, dtBegr < dtEndr",dtBegr, dtEndr)
      #endif
      QUIT
    ENDIF
  ENDIF
  outlog(3,__FILE__,__LINE__,"dtBegr,dtEndr",dtBegr, dtEndr)

  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-04-08 * 10:09:40pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION test_doc_sk(nSk,dOtch,lBoll,bEvalREpl)
  DEFAULT lBoll TO .F.
  IF !EMPTY(lBoll) // движение Стеклотары
    LOCATE FOR sk=nSk .and. DTtn = dOtch .and. (mntov>=10^4 .and. mntov<=10^6)
  ELSE
    LOCATE FOR sk=nSk .and. DTtn = dOtch
  ENDIF
  IF .F. .OR. !FOUND()
    append from test.dbf
    _FIELD->Sk:=nSk
    _FIELD->TTN:=RAND(VAL(RIGHT(DTOS(dOtch),6)))*10^5*(-1)

*    VAL(RIGHT(DTOS(dOtch),6))*(-1)
    //PADL(LTRIM(STR(DAY(dOtch))),2,"0"))*(-1)
    //    "-"+DTOS(dOtch)
    _FIELD->DTtn:=dOtch
    _FIELD->Kvp:=DAY(dOtch)
    IF !EMPTY(bEvalREpl)
      EVAL(bEvalREpl)
    ENDIF
  ENDIF
  RETURN (NIL)



/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-10-09 * 10:53:10am
 НАЗНАЧЕНИЕ.........  dOtch - дата отчета ,cDir - каталог где лежита остаки для коррекции
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION OtguzFuture(dOtch,cDir)
  //////////////////////////////////////////////////////
  //вычиляем отгрузку наперед
  MkOtchN({dOtch+1,EOM(dOtch)},19,NIL,1) //1 все склады
  //
  MkOtchN({dOtch+1,EOM(dOtch)},58,NIL,1) //1 все склады

  USE mkdoc019 ALIAS doc NEW EXCLUSIVE
  if !file("mkpr019.dbf") .or. !file("mkpr058.dbf")
    copy stru to mkpr019
    copy stru to mkpr058
  endif
  CLOSE

  USE mkpr019 NEW EXCLUSIVE
  REPL ALL dcl WITH dcl*(-1),  kvp WITH kvp*(-1)
  USE
  USE mkpr058 NEW EXCLUSIVE
  REPL ALL dcl WITH dcl*(-1),  kvp WITH kvp*(-1)
  USE

  USE mkdoc019 ALIAS doc NEW EXCLUSIVE
  APPEND FROM mkpr019
  APPEND FROM mkdoc058
  APPEND FROM mkpr058

  COPY TO mkdoc // для контроля, без пересчета

  USE (cDir+"\"+"mktov019.dbf") ALIAS tov NEW EXCLUSIVE
  INDEX ON STR(sk)+STR(mntovt) TO tmptov

  SELE doc
  SET RELA TO STR(sk)+STR(mntovt) INTO tov
  REPL ALL ;
  tov->osfo WITH tov->osfo + doc->kvp,;
  tov->dcl WITH tov->dcl + doc->dcl

  CLOSE doc
  CLOSE tov
  /////////////// фючерные отгрузки - КОНЕЦ /////
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  07-24-11 * 09:11:23am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION clvrt_get_date(d_dtBegr,d_dtEndr, cMess1, cMess2, bValid)
  CLEAR SCREEN
  set device to screen

  @ 2,2 SAY cMess1 COLOR "W+/N"
  @ 3,2 SAY cMess2 COLOR "W+/N"

  @ 5,2 SAY "Введите начальную дату:" COLOR "W+/N"
  @ 5,25 GET d_dtBegr
  @ 6,2 SAY "Введите последнию дату:" COLOR "W+/N"
  @ 6,25 GET d_dtEndr ;
  VALID  EVAL(bValid,d_dtBegr,d_dtEndr)
  READ

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  10-03-12 * 09:55:06am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION  MkOtchN_Range(nMkeep, dtBegr, dtEndr, cDosParam)
  LOCAL dtOstr, cMkeep

  cMkeep:=PADL(LTRIM(STR(nMkeep)),3,"0")

      DO CASE
      CASE UPPER("/dtBeg") $ cDosParam
        Dt_Beg_End(cDosParam,.T.,@dtBegr,@dtEndr)
        MkOtchN(dtBegr,nMkeep,NIL,1,dtEndr) //,{||.T.}) //1 все склады
        dtOstr:=dtEndr
      CASE UPPER("/gdTd") $ cDosParam
        dtBegr:=BOM(gdTd)
        dtEndr:=EOM(gdTd)
        dtOstr:=IIF(BOM(date()-1)=BOM(gdTd),date()-1,EOM(gdTd))
        MkOtchN(dtBegr,nMkeep,NIL,1,dtEndr) //,{||.T.}) //1 все склады
      OTHERWISE

        dtOstr:=dtEndr

        If eom(dtBegr)=EOM(dtEndr)
          d1:=dtBegr
          d2:=dtEndr
        Else
          d1:=dtBegr
          d2:=EOM(dtBegr)
        EndIf
          outlog(__FILE__,__LINE__,"1",d1,d2)

        // run  d1 d2
        MkOtchN(d1,nMkeep,NIL,1,d2) //,{||.T.}) //1 все склады
        copy file ("mktov"+cMkeep+".dbf") to mktov.dbf
        copy file ("mkdoc"+cMkeep+".dbf") to mkdoc.dbf
        copy file ("mkpr"+cMkeep+".dbf") to mkpr.dbf
        copy file ("mkpe"+cMkeep+".dbf") to mkpe.dbf

        If !(eom(dtBegr) = EOM(dtEndr))
          d1:=d2+1
          IF BOM(d1) = BOM(dtEndr)
            d2:=dtEndr
            outlog(__FILE__,__LINE__," 2",d1,d2)
            // run  d1 d2
            MkOtchN(d1,nMkeep,NIL,1,d2) //,{||.T.}) //1 все склады
            use mktov new
            append from ("mktov"+cMkeep+".dbf")
            use
            use ("mkdoc"+cMkeep+"") new
            append from mkdoc.dbf
            use
            use ("mkpr"+cMkeep+"") new
            append from mkpr.dbf
            use
            use ("mkpe"+cMkeep+"") new
            append from mkpe.dbf
            use
          ELSE
            d2:=EOM(d1)
            outlog(__FILE__,__LINE__,"02",d1,d2)
            // run  d1 d2
            MkOtchN(d1,nMkeep,NIL,1,d2) //,{||.T.}) //1 все склады
            use mktov new
            append from ("mktov"+cMkeep+".dbf")
            use
            use ("mkdoc"+cMkeep+"") new
            append from mkdoc.dbf
            use
            use ("mkpr"+cMkeep+"") new
            append from mkpr.dbf
            use
            use ("mkpe"+cMkeep+"") new
            append from mkpe.dbf
            use

            copy file ("mkdoc"+cMkeep+".dbf") to mkdoc.dbf
            copy file ("mkpr"+cMkeep+".dbf") to mkpr.dbf
            copy file ("mkpe"+cMkeep+".dbf") to mkpe.dbf

            d1:=d2+1
            d2:=dtEndr
            outlog(__FILE__,__LINE__,"03",d1,d2)
            // run  d1 d2
            MkOtchN(d1,nMkeep,NIL,1,d2) //,{||.T.}) //1 все склады
            use mktov new
            append from ("mktov"+cMkeep+".dbf")
            use
            use ("mkdoc"+cMkeep+"") new
            append from mkdoc.dbf
            use
            use ("mkpr"+cMkeep+"") new
            append from mkpr.dbf
            use
            use ("mkpe"+cMkeep+"") new
            append from mkpe.dbf
            use
          ENDIF
        ENDIF

      ENDCASE

    mkkplkgp(nMkeep,nil)
  RETURN (NIL)


#ifdef __CLVRT__CGI_BIN__
/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  03-06-09 * 09:41:14am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */

FUNCTION Cgi_Bin_get(cHost, nPort,ServerResponce,cGET_cgi_bin)
  #define FISC_MAX_CONNECT 10
  #define SERVER_ANSWER_MAXSIZE 8096
  //#define LF CHR(10)
  // #define CR CHR(13)
  STATIC nConnect
  LOCAL nBytes, nTimeOut //, cHost, nPort
  LOCAL nL
  LOCAL nFError, cFErrorStr
  //LOCAL ServerResponce

  //cHost:="localhost"
  //nPort:=80
  nTimeOut:=60*10^3
  nBytes:=1024

    OUTlog(3,__FILE__,__LINE__,"Test for apache__client",nConnect)

    //If empty(nConnect)
      nConnect := apache_open_server(cHost, nPort, @ServerResponce, nTimeOut, SERVER_ANSWER_MAXSIZE)
            outlog(3,__FILE__,__LINE__,"nConnect",nConnect)
            OUTlog(3,__FILE__,__LINE__,"Ответ",ServerResponce)
    //EndIf

    IF  ISNUM(nConnect) .and.  nConnect >= 0
      apache_write_to_server(nConnect,cGET_cgi_bin)
      //читаем, что пришло в буфере
      nL:=apache_read_from_server(nConnect,@ServerResponce,nTimeOut,SERVER_ANSWER_MAXSIZE)
      IF ISNUM(nL) .and. nL>=0

          outlog(3,__FILE__,__LINE__,"nConnect",nConnect)
          OUTlog(3,__FILE__,__LINE__,"Ответ",ServerResponce)

      ELSE
        //расшифровывем ошибку
          outlog(3,__FILE__,__LINE__,"nConnect",nConnect,nL)
          OUTlog(3,__FILE__,__LINE__,"Ответ",ServerResponce)
      ENDIF

      //outlog(__FILE__,__LINE__,;
      TCPCLOSE(nConnect) //,;
      //"TCPCLOSE(nConnect)")
      /*
      fisc_close_server(nConnect)
      WAIT
      //RUN ("./mariq")
      */
    ELSE
      outlog(__FILE__,__LINE__,"nConnect",nConnect)
      OUTlog(__FILE__,__LINE__,"Ответ",ServerResponce)

    ENDIF

  RETURN (NIL)


FUNCTION apache_open_server(cHost,nPort,cBuf,nTimeOut,nBytes)
  LOCAL nConnect
  LOCAL nFError, cFErrorStr, nL, i
  LOCAL aTypeModel

  nFError:=0
  aTypeModel:={}
  nConnect:=-1

  FOR i:=1 TO FISC_MAX_CONNECT
    nConnect:=TCPCONNECT(cHost,nPort,nTimeOut) //22) //7654)
    IF nConnect > -1
      //добавить в массив общий соединений aAllCon
      EXIT
    ELSE
      nFError:=FERROR()
      cFErrorStr:=FERRORSTR()
      cBuf:=ALLTRIM(STR(nFError))+","+cFErrorStr
      outlog(__FILE__,__LINE__,"Connect error to host",nFError,cFErrorStr)
      outlog(__FILE__,__LINE__,cHost,nPort,nTimeOut)
    ENDIF
  NEXT

  /*
  IF nConnect > -1
    cBuf:=SPACE(nBytes,.T.)
    nL:=TCPREAD(nConnect,@cBuf,nBytes,nTimeOut)
    IF nL = -1
      nConnect := nL
      outlog(__FILE__,__LINE__,"TCPREAD","Read from host error",nL,nFError, cFErrorStr)
      return FISC_ERROR_READ_DATA
    ELSE
      cBuf:=LEFT(cBuf,nL)
      IF ASC(RIGHT(cBuf,1))<=13
        cBuf:=LEFT(cBuf,nL-1)
      ENDIF
      outlog(cBuf)
      //проверим что прочитали
      IF "OK" $ cBuf
        TOKENINIT(@cBuf," ")
        TOKENNEXT()
        DO WHILE !TOKENEND()
          AADD(aTypeModel,{nConnect,TOKENNEXT()})
        ENDDO
      ELSE
        nConnect:=-1
      ENDIF
    ENDIF
  ELSE
    return FISC_ERROR_CONNECT_HOST
  ENDIF
  */

  RETURN (nConnect)

FUNCTION apache_read_from_server(nConnect,cBuf,nTimeOut,nBytes)
  LOCAL nL
  LOCAL nFError, cFErrorStr
  LOCAL cBufRead

  cBufRead:=''
  //проверка на максимальное подключение КА
  //конетк зарегитрирован aAllCon
  IF !(nConnect >= 0)
    return "ERROR_INVALID_HANDLE"
  ELSE

    DO WHILE .T.
      cBuf:=SPACE(nBytes) //,.T.)
      nL:=TCPREAD(nConnect,@cBuf,nBytes,nTimeOut)

      IF nL = -1
        nFError   :=FERROR()
        cFErrorStr:=FERRORSTR()
        outlog(__FILE__,__LINE__,"TCPREAD","Read from host error",nL,nFError, cFErrorStr)
        return "ERROR_READ_DATA"
      ELSE
        cBuf:=LEFT(cBuf,nL)
        cBufRead+=cBuf
        If Right(cBuf,1)=CHR(26)
          exit
        EndIf
        /*
        IF ASC(RIGHT(cBuf,1))<=13
          cBuf:=LEFT(cBuf,nL-1)
        ENDIF
        */
      ENDIF
    ENDDO

    cBuf:=cBufRead


  ENDIF
  RETURN (nL)


FUNCTION apache_write_to_server(nConnect,cBuf)
  LOCAL nL
  //проверка на максимальное подключение КА
  //конетк зарегитрирован aAllCon
  IF !(nConnect >= 0)
    return "ERROR_INVALID_HANDLE"
  ELSE
    nL:=TCPWRITE(nConnect, cBuf)
    IF nL = -1
      outlog(__FILE__,__LINE__,"TCPWRITE",nL)
      return "ERROR_SEND_HOST"
    ELSE
      IF nL != LEN(cBuf)
        outlog(__FILE__,__LINE__,"Send to host error (data lost) ",nL)
        return "ERROR_SEND_DATA"
      ELSE
        //outlog(3,__FILE__,__LINE__,"TCPWRITE",cBuf,nL)
      ENDIF
    ENDIF
  ENDIF
  RETURN (nL)
#endif // "__CLVRT__CGI_BIN__"


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  10-08-13 * 08:31:47pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ.......... ddtBeg - дата с которой начинам отчеты
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION spod2d(cMark, cKod_spod2d, cFilePef, cListEmail, cNmMark, ;
                       ddtBeg, cListSkSox, lSox)
  LOCAL verSpod2D:=2
  DEFAULT cListSkSox TO '999;', lSox TO .F.
  If !Empty(lSox)
    lSox := .T.
  EndIf


  //DEFAULT ddtBeg TO DATE()
  if .t.
    dtBegr:=dtEndr:=DATE()

    IF (UPPER("/get-date") $ UPPER(DosParam()))

      clvrt_get_date(@dtBegr,@dtEndr,;
      "Подготовка отчета "+cMark+" "+cNmMark+"данных за период.",;
      "имя файла архива ol_<дата1>-<дата2>.zip",;
      {|a1,a2| a1<=a2 .and. BOM(a1)=BOM(a2) };
    )

      IF LASTKEY()=13
        set device to print
        set print to clvrt.log ADDI

        gdTd:=BOM(dtBegr)

      ELSE
        RETURN
      ENDIF
    ELSE
      dtEndr:=date()-1
      dtBegr:=dtEndr-45
      IF !EMPTY(ddtBeg)
        IF dtBegr <  ddtBeg
          dtBegr:=ddtBeg
        ENDIF
      ENDIF
    ENDIF
    IF !(UPPER("/no_mkotch") $ UPPER(DosParam()))
      MkOtchN_Range( VAL(cMark), @dtBegr,@dtEndr,cDosParam)
    ENDIF
  endif
  //quit
   dtOstr:=dtEndr

   netuse('s_tag')
   netuse('kgp')
   netuse('kgpcat')
   netuse('krn')
   netuse('knasp')
   netuse('kln')

  set("PRINTER_CHARSET","cp1251")
  //set("PRINTER_CHARSET","koi8-u")
  SET DATE FORMAT "DD.MM.YYYY" //"yyyy-mm-dd"
  SET CENTURY ON


  //1.5 Таблица остатков  END_date (stocks.csv)
  use mktov alias  mktov new Exclusive //остатки за несколько переиодов
  locate for MntovT > 1000000 // товар
  copy to tmpost1 next 1
  use  tmpost1 alias DefOst new Exclusive
  DefOst->OsFo:=0
  close mktov


  use ("mktov"+cMark) alias  mktov new //тек остатки на момент сборки
  index on mntovt to tmp__tov
  If lSox
    total on mntovt FIELDS OsFo to tmp__tov  ;
    for (str(sk,3) $ cListSkSox)
  Else
    total on mntovt FIELDS OsFo to tmp__tov  ;
    for .not. (str(sk,3) $ cListSkSox)
  endif

  // для отчета
  index on dtos(DT)+str(MnTovT,7) to tmpTov
  If lSox
    total on dtos(DT)+str(MnTovT,7) to tmpTov field OsFo ;
    for (str(sk,3) $ cListSkSox)
  Else
    total on dtos(DT)+str(MnTovT,7) to tmpTov field OsFo ;
    for .not. (str(sk,3) $ cListSkSox)
  EndIf

  close mktov

  use tmpTov alias Ost new
    ///////////////////  продажи

    lConv:= .T. //.T. //NEED_OEM2ANSI ковертарция
    lYesNo:= .F.

    cFile:='otchet'+".xls"
    cLine:=;
    'N п/п;Название продукта;Код продукта;Остаток,шт'
    nRow:=0

    _h:=XlsHeadCREATE(cFile,cLine,lConv,lYesNo,@nRow)

      sele Ost
      Do While !Ost->(eof())
        i:=0
        // N п/п;
        cCell := str(Ost->(RecNo()))
          WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
        // Название продукта;
        cCell := allt(nat)
          WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
        // Код продукта'+;
        cCell := str(MnTov)
          WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
        //;Остаток, шт'+;
        cCell := osfo
          WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)

        nRow++
        Ost->(DBSkip())
      EndDo

      XlsCLOSE_XLSEOF(_h)

  close Ost

  use tmp__tov alias  mktov new

  // остатки по умолчанию  добавление остатка=0 для товара
  DefOst->(DBGoTop())
  sele mktov
  locate for mktov->mntovt == DefOst->mntovt
  If !found()
    close DefOst
    sele MkTov
    append from TmpOst1
  else
    close DefOst
  EndIf
  //

  sele MkTov
  go top

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO stocks.csv
   i:=0
  Do While !mktov->(eof())
    cLine:=;
        cKod_spod2d+_T+; //Код дистрибьютора в системе SPOT 2D
        dtoc(dtOstr)+_T+; //Дата подсчета остатков (конец вчерашнего дня)
        ltrim(str(mktov->mntovt))+_T+; //  Код SKU в системе дистрибьютора
        LTRIM(str(IIF(mktov->OsFo<0,0,mktov->OsFo)))//Кол-во //Размер остатков в штуках
    IF i=0
      QQOUT(cLine)
      i++
    ELSE
      QOUT(cLine)
    ENDIF

    mktov->(DBSkip())
  EndDo
  SET PRINT TO
  SET PRINT OFF
  close mktov



  use mktov alias  mktov new Exclusive //остатки за несколько переиодов
  repl bar  with mntovt+0*(2*10^13*0) for empty(bar)

  index on mntovt to tmpmktov
  If lSox
    total on mntovt FIELDS OsFo to tmpmktov for (str(sk,3) $ cListSkSox)
  else
    total on mntovt FIELDS OsFo to tmpmktov for .not. (str(sk,3) $ cListSkSox)
  endif
  close mktov

  use tmpmktov alias  mktov new
  index on mntovt tag t1
  copy to mksku

  //1.1 Таблица продуктов SKU (products.csv) ALL_period
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO products.csv
  i:=0

  sele mktov
  go top
  //mktov->(Iif(lSox,(DBGoBottom(),DBSkip()),NIL))
  Do While !mktov->(eof())

    IF verSpod2D=2
      cLine:=;
      cKod_spod2d+_T+; //Код дистрибьютора в системе SPOT 2D
      ltrim(str(mktov->mntovt))+_T+;  //- Код продукта (внутренний)*
      alltrim(mktov->NaT)+_T+;//Товар
      LTRIM(str(mktov->bar))+_T+; //- Штрих-код производителя
      alltrim(mktov->NEi)+_T+;  //- шт в упак
      LTRIM(str(mktov->UPak))+_T  //- ед изм
    ELSE
      cLine:=;
      LTRIM(str(mktov->bar))+_T+; //- Штрих-код производителя
      ltrim(str(mktov->mntovt))+_T+;  //- Код продукта (внутренний)*
      alltrim(mktov->NaT)+_T+;//Товар
      alltrim(mktov->NEi)+_T+;  //- шт в упак
      LTRIM(str(mktov->UPak))+_T  //- ед изм
    ENDIF


    IF i=0
      QQOUT(cLine)
      i++
    ELSE
      QOUT(cLine)
    ENDIF

    mktov->(DBSkip())
  EndDo
  SET PRINT TO
  SET PRINT OFF

  //close mktov  // ниже закроем

  use mksku alias  mksku new
// файла продуктов sku.csv
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO sku.csv
    i:=0
    cLine:=;
    'ID дистрибьютора'+_T+;
    'Код продукта дистрибьютора'+_T+;
    'Название продукта'+_T+;
    'Штрихкод'+_T+;
    'Код продукта производителя'+_T+;
    'ID единицы измерения продукта'
    QQOUT(cLine);    i++

    sele mkSku
    DBGoTop()
    Do While !eof()

      cLine:=;
          cKod_spod2d+_T+; //Код дистрибьютора в системе SPOT 2D
          allt(str(_FIELD->MnTov))+_T+;
          _FIELD->nat+_T+;
          str(_FIELD->bar)+_T+;
          str(_FIELD->bar)+_T+;
          allt(str(1))

      iif(i=0,QQOUT(cLine),QOUT(cLine)); i++
      DBSkip()
    EndDo

  SET PRINT TO
  SET PRINT OFF
  close mksku




  use ("mkpr"+cMark) new
  copy to tmpimex for kop=108
  close

  use tmpimex Exclusive
  repl kvp with kvp*(-1) all
  close

  use ("mkdoc"+cMark) alias mkdoc new
  append from tmpimex  //from ("mkpr"+cMark)
  sele mkdoc
  index on str(kpl)+str(kgp) to tmpkplkgp for mkdoc->vo=9
  total on str(kpl)+str(kgp) to tmpkplkgp

  sele mkdoc
  index on str(kta) to tmpkta for mkdoc->vo=9
  total on str(kta) to tmpkta
  //close mkdoc



  use tmpkplkgp alias tmpkgp new
  //1.2 Таблица клиентов (clients.csv)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO clients.csv
   i:=0
  tmpkgp->(Iif(lSox,(DBGoBottom(),DBSkip()),NIL))
  Do While !tmpkgp->(eof())

    cLine:=;
        cKod_spod2d+_T+; //Код дистрибьютора в системе SPOT 2D
         ;//код торговой точки в системе дистрибьютора
         PADL(LTRIM(str(tmpkgp->kpl)),7,"0")+;//Код плательщика
         PADL(LTRIM(str(tmpkgp->kgp)),7,"0")+_T+;//Код розничной точки
         ALLTRIM(tmpkgp->npl)+"-"+;//название клиента с название
         ALLTRIM(tmpkgp->ngp)+_T+; // ТТ в одной строке (через дефис) адрес ТТ
         ;// ALLTRIM(tmpkgp->agp) //адрес ТТ
         (kln->(netseek('t1','tmpkgp->kgp')),;
          alltrim(getfield("t1","kln->krn","krn","nrn"))+" "+;       //Район
          alltrim(getfield("t1","kln->knasp","knasp","nnasp"))+" "+; //Город
          alltrim(tmpkgp->agp);//Физическое местонахождение
       )+_T+;
       (;
       kgpcatr:=getfield("t1","tmpkgp->kgp","kgp","kgpcat"),;
       nkgpcatr:=getfield("t1","kgpcatr","kgpcat","nkgpcat"),;
       alltrim(nkgpcatr); //Канал (Розница,VIP,Horeca, Киоск)
     )



    IF i=0
      QQOUT(cLine)
      i++
    ELSE
      QOUT(cLine)
    ENDIF

    tmpkgp->(DBSkip())
  EndDo
  SET PRINT TO
  SET PRINT OFF
  close tmpkgp


  //1.3 Таблица торговых агентов (ta.csv)
  use tmpkta alias tmpkta new
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO ta.csv
   i:=0
   #ifdef __CLIP__
     oFIO:=map()
   #endif
  tmpkta->(Iif(lSox,(DBGoBottom(),DBSkip()),NIL))
  Do While !tmpkta->(eof())

    s_tag->(netseek('t1','tmpkta->kta'))
    cKta := PADL(LTRIM(STR(tmpkta->kta)),4,"0")
    cFIO := Key := UPPER(ALLTRIM(s_tag->fio))

    #ifdef __CLIP__
      IF Key $ oFIO
        Key:=cFIO:=CHARREPL("О", cFIO, "O")
        Key:=cFIO:=CHARREPL("Е", cFIO, "E")
        Key:=cFIO:=CHARREPL("К", cFIO, "K")
        Key:=cFIO:=CHARREPL("А", cFIO, "A")
        oFIO[Key]:=cFIO
      ELSE
        oFIO[Key]:=cFIO
      ENDIF
    #endif

    cLine:=;
        cKod_spod2d+_T+; //Код дистрибьютора в системе SPOT 2D
        cKta + _T+; // Код ТА в системе дистрибьютора
        cFIO + _T+; //  ФИО ТА
        "A"+_T+; //Тип торгового агента
        str(tmpkta->sk) //Город
    IF i=0
      QQOUT(cLine)
      i++
    ELSE
      QOUT(cLine)
    ENDIF

    tmpkta->(DBSkip())
  EndDo
  SET PRINT TO
  SET PRINT OFF

  close tmpkta


  sele mkdoc
  set rela to mntovt into mktov
  go top
  //1.4 Таблица отгрузок (delivery.csv)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO delivery.csv
   i:=0
  mkdoc->(Iif(lSox,(DBGoBottom(),DBSkip()),NIL))
  Do While !mkdoc->(eof())

    cLine:=;
        cKod_spod2d+_T+; //Код дистрибьютора в системе SPOT 2D
        PADL(LTRIM(str(mkdoc->kpl)),7,"0")+;//Код плательщика
        PADL(LTRIM(str(mkdoc->kgp)),7,"0")+_T+;//Код розничной точки
        ; //Код клиента в системе дистрибьютора
        DTOC(mkdoc->dttn)+_T+;// Дата отгрузки клиенту dd.mm.yyyy
        ltrim(str(mkdoc->mntovt))+_T+;  //Код SKU в системе дистрибьютора
        LTRIM(str(mkdoc->kvp))+_T+; ///  Размер отгрузки в штуках
        LTRIM(str(mkdoc->zen*1.2,15,2))+_T+;//Стоимость единицы в грн (с НДС)
        PADL(LTRIM(STR(mkdoc->kta)),4,"0") // Код ТА в системе дистрибьютора
    IF i=0
      QQOUT(cLine)
      i++
    ELSE
      QOUT(cLine)
    ENDIF

    mkdoc->(DBSkip())
  EndDo
  SET PRINT TO
  SET PRINT OFF

  close mkdoc
  close mktov

         #ifdef __CLIP__
           set translate path off
         #endif
    cLogSysCmd:=""
  #ifdef __CLIP__
  //SET DATE FORMAT "yyyy-mm-dd"
  //SET CENTURY ON
    cRunZip:="/usr/bin/zip"
    cFileNameArc:=cFilePef+"SP2D"+cMark+DTOC(DATE(),"yyyy-mm-dd")+'T'+CHARREPL(":", TIME(), "-")+".zip"
    cFileList:="";
    +"stocks.csv ";
    +"otchet.xls ";
    +"sku.csv "
    +"products.csv "

    If lSox
      //
    Else
      cFileList+="";
      +"clients.csv ";
      +"ta.csv ";
      +"delivery.csv "
    EndIf

    If lSox
      SYSCMD(cRunZip+" "+cFileNameArc+" "+;
      cFileList +;
      " ; ./SumSox.bat "+cFileNameArc,"",@cLogSysCmd)
    Else
      SYSCMD(cRunZip+" "+cFileNameArc+" "+;
      cFileList +;
      " ; ./Sum.bat "+cFileNameArc,"",@cLogSysCmd)
    EndIf

    qout(__FILE__,__LINE__,cLogSysCmd)

    SendingJafa(cListEmail,{{ cFileNameArc,cMark+"_"+str(228,3)+" "+cFilePef+"__ProdResSumy"+" "+DTOC(DATE(),"YYYYMMDD")}},"./",228)


  #endif
         #ifdef __CLIP__
           set translate path on
         #endif
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-08-15 10:48am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ.......... ddtBeg - дата с которой начинам отчеты
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION DDIA(cMark, cKod_DDIA, cFilePef, cListEmail, cNmMark, ddtBeg)
  //DEFAULT ddtBeg TO DATE()
  if .t.
    dtEndr:=dtEndr:=DATE()

    IF (UPPER("/get-date") $ UPPER(DosParam()))

      clvrt_get_date(@dtBegr,@dtEndr,;
      "Подготовка отчета "+cMark+" "+cNmMark+"данных за период.",;
      "имя файла архива ol_<дата1>-<дата2>.zip",;
      {|a1,a2| a1<=a2 .and. BOM(a1)=BOM(a2) };
    )

      IF LASTKEY()=13
        set device to print
        set print to clvrt.log ADDI

        gdTd:=BOM(dtBegr)

      ELSE
        RETURN
      ENDIF
    ELSE
      dtEndr:=date()-1
      dtBegr:=dtEndr-45
      IF !EMPTY(ddtBeg)
        IF dtBegr <  ddtBeg
          dtBegr:=ddtBeg
        ENDIF
      ENDIF
    ENDIF
    IF !(UPPER("/no_mkotch") $ UPPER(DosParam()))
      MkOtchN_Range( VAL(cMark), @dtBegr,@dtEndr,cDosParam)
    ENDIF
  endif
   dtOstr:=dtEndr

   netuse('s_tag')
   netuse('kgp')
   netuse('kgpcat')
   netuse('krn')
   netuse('knasp')
   netuse('kln')

  set("PRINTER_CHARSET","cp1251")
  //set("PRINTER_CHARSET","koi8-u")
  SET DATE FORMAT "DD.MM.YYYY" //"yyyy-mm-dd"
  SET CENTURY ON


  use ("mktov"+cMark) alias  mktov new //тек остатки на момент сборки
  index on mntovt to tmp__tov
  total on mntovt FIELDS OsFo to tmp__tov
  close mktov

  use tmp__tov alias  mktov new

  sele mktov
  go top

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO stocks.csv
  //Таблиця залишк в (stocks.csv)
   i:=0
    cLine:=;
    "distr_code;stock_date;distr_product_code;stock_volume"
      QQOUT(cLine)
   i++

   Do While !mktov->(eof())
    cLine:=;
     cKod_DDIA+_T+;//distr_code  +  String  Код дистриб'ютора в систем  DDIA
     dtoc(dtOstr)+_T+; //stock_date  +  Date  Дата п драхунку залишк в sku_code або
     ltrim(str(mktov->mntovt))+_T+;//distr_product_code +  String  Артикул виробника * або Артикул дистриб'ютора
     LTRIM(str(IIF(mktov->OsFo<0,0,mktov->OsFo)))//stock_volume  +  Integer  Розм р залишк в у одиницях вим ру **
    IF i=0
      QQOUT(cLine)
      i++
    ELSE
      QOUT(cLine)
    ENDIF

    mktov->(DBSkip())
  EndDo
  SET PRINT TO
  SET PRINT OFF
  close mktov


  use mktov alias  mktov new Exclusive //остатки за несколько переиодов
  repl bar  with mntovt+0*(2*10^13*0) for empty(bar)

  index on mntovt to tmpmktov
  total on mntovt FIELDS OsFo to tmpmktov
  close mktov
  //Таблиця продукт в SKU (sku.csv)

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO sku.csv

  use tmpmktov alias  mktov new
  index on mntovt tag t1
  i:=0
  cLine:=;
  "distr_code;Barcode;sku_code;distr_product_code;distr_product_name;distr_product_unit_name"
   QQOUT(cLine)
  i++
  Do While !mktov->(eof())
      cLine:=;
    cKod_DDIA+_T+;//distr_code   +  String  Код дистриб'ютора в систем  DDIA
    LTRIM(str(mktov->bar))+_T+;//barcode  +  String  Штрих-код
    ""+_T+;//sku_code  +  String  Код / Артикул Виробника
    ltrim(str(mktov->mntovt))+_T+;//distr_product_code  +  String  Код / Артикул дистриб'ютора
    alltrim(mktov->NaT)+_T+;//distr_product_name    String  Назва продукту
    "шт." //alltrim(mktov->NEi) //distr_product_unit_name    String  Назва одиниц  вим ру  з дов дника виробника, в
                            //як й показан  залишки, продаж  та  нше в
                            //таблицях, що формуються зг дно цього ТЗ
    IF i=0
      QQOUT(cLine)
      i++
    ELSE
      QOUT(cLine)
    ENDIF

    mktov->(DBSkip())
  EndDo
  SET PRINT TO
  SET PRINT OFF
  //close mktov


  use ("mkpr"+cMark) alias  mkpr new
  append from ("mkpe"+cMark)
  copy to tmpimex for kop=108 //возвраты
  copy to tmpimpr for vo=9 //kop=101 .OR.  kop=104 //от поставщиков
  close mkpr

  use tmpimex Exclusive NEW
  repl kvp with kvp*(-1) all
  close tmpimex

  use ("mkdoc"+cMark) alias mkdoc new
  copy to tmpmkdok for vo=9
  close mkdoc

  use tmpmkdok alias mkdoc NEW
  append from tmpimex // р-ци + возварат

  copy to tmpkplkgp
  use tmpkplkgp NEW
  append from tmpimpr // + приход + (р-ци + возварат)

  index on str(kgp)+str(kpl) to tmpkgp
  total on str(kgp)+str(kpl) to tmpkgp
  //close tmpkplkgp
  use tmpkgp alias tmpkgp new
  //Таблиця адрес доставки (adrd.csv)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO adrd.csv
   i:=0
    cLine:=;
      "distr_code;client_addr_code;client_addr_name;client_addr_address"
      //;client_code"
      QQOUT(cLine)
   i++
   Do While !tmpkgp->(eof())
    Kgpr:=tmpkgp->Kgp
    cLine:=;
    cKod_DDIA+_T+;                            //distr_code + String  Код дистриб'ютора в систем  DDIA
      PADL(LTRIM(str(tmpkgp->kgp)),7,"0")+_T+;//client_addr_code  +  String  Ун кальний код адреси доставки в систем  дистриб'ютора
      ALLTRIM(tmpkgp->ngp)+_T+;               //client_addr_name  +  String  Назва адреси доставки або назва торг вельно  точки
      (kln->(netseek('t1','tmpkgp->kgp')),;
      alltrim(getfield("t1","kln->krn","krn","nrn"))+" "+;       //Район
      alltrim(getfield("t1","kln->knasp","knasp","nnasp"))+" "+; //Город
      alltrim(kln->adr);//Физическое местонахождение
    )      //                                  //client_addr_address  +  String  Адреса доставки в систем  дистриб'ютора
      ;//+_T+PADL(LTRIM(str(tmpkgp->kpl)),7,"0")+_T+;//client_code    String  Код кл  нта, якому належить адреса доставки
      ;//ALLTRIM(tmpkgp->npl)                   //client_name    String  Назва кл  нта

    IF i=0
      QQOUT(cLine)
      i++
    ELSE
      QOUT(cLine)
    ENDIF
    DO WHILE Kgpr = tmpkgp->Kgp
      tmpkgp->(DBSkip())
    ENDDO
  EndDo
  SET PRINT TO
  SET PRINT OFF
  close tmpkgp

  SELE tmpkplkgp
  index on str(kta) to tmpkta
  total on str(kta) to tmpkta

  //1.3 Таблица торговых агентов (ta.csv)
  use tmpkta alias tmpkta new
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO ta.csv

   i:=0
    cLine:=;
    "distr_code;distr_ta_code;distr_ta_name"
      QQOUT(cLine)
   i++

   #ifdef __CLIP__
     oFIO:=map()
   #endif
  Do While !tmpkta->(eof())

    s_tag->(netseek('t1','tmpkta->kta'))
    cKta := PADL(LTRIM(STR(tmpkta->kta)),4,"0")
    cFIO := Key := UPPER(ALLTRIM(s_tag->fio))

    #ifdef __CLIP__
      IF Key $ oFIO
        Key:=cFIO:=CHARREPL("О", cFIO, "O")
        Key:=cFIO:=CHARREPL("Е", cFIO, "E")
        Key:=cFIO:=CHARREPL("К", cFIO, "K")
        Key:=cFIO:=CHARREPL("А", cFIO, "A")
        oFIO[Key]:=cFIO
      ELSE
        oFIO[Key]:=cFIO
      ENDIF
    #endif

    cLine:=;
        cKod_DDIA+_T+; //distr_code + String  Код дистриб'ютора в систем  DDIA
        cKta + _T+; // distr_ta_code  +  String  Ун кальний код ТА в систем  дистриб'ютора
        cFIO  // str_ta_name  +  String   Ун кальне П Б торгового агента
    IF i=0
      QQOUT(cLine)
      i++
    ELSE
      QOUT(cLine)
    ENDIF

    tmpkta->(DBSkip())
  EndDo
  SET PRINT TO
  SET PRINT OFF
  close tmpkta


  sele mkdoc
  set rela to mntovt into mktov
  go top
  //Таблиця продаж в (sales.csv)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO sales.csv
   i:=0
    cLine:=;
   "distr_code;client_addr_code;sale_date;distr_product_code;sale_volume;"+;
   "sale_product_price;"+;//sale_product_price_input;sale_sum;"+;
   "distr_ta_code"
      QQOUT(cLine)
   i++

  Do While !mkdoc->(eof())

    cLine:=;
        cKod_DDIA+_T+; //distr_code  +  String  Код дистриб'ютора в систем  DDIA
        PADL(LTRIM(str(mkdoc->kgp)),7,"0")+_T+;//client_addr_code  +  String  Код адреси доставки в систем  дистриб'ютора
        DTOC(mkdoc->dttn)+_T+;// sale_date  +  Date  Дата в двантаження в торгову точку *
        ltrim(str(mkdoc->mntovt))+_T+;//sku_code або distr_product_code +  String  Артикул виробника ** або Артикул дистриб'ютора
        LTRIM(str(mkdoc->kvp))+_T+; //sale_volume  +  Integer  К льк сть в двантаженого товару в одиницях вим ру ***
        LTRIM(str(mkdoc->zen*1.0,15,2))+_T+;//sale_product_price    Float  Варт сть одиниц  в нац валют  (без урахування ПДВ)
        ;//sale_product_price_input    Float  Закуп вельна варт сть одиниц  в нац валют  (без ПДВ)
        ;//sale_sum    Float  Сума продажу в нац валют  (без ПДВ)
        PADL(LTRIM(STR(mkdoc->kta)),4,"0") //distr_ta_code    String  Код ТА в систем  дистриб'ютора ****


    IF i=0
      QQOUT(cLine)
      i++
    ELSE
      QOUT(cLine)
    ENDIF

    mkdoc->(DBSkip())
  EndDo
  SET PRINT TO
  SET PRINT OFF


  USE tmpimpr ALIAS mkpr NEW
  set rela to mntovt into mktov
  go top
  //Таблиця прих д (income.csv)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO income.csv

   i:=0
    cLine:=;
   "distr_code;income_date;distr_product_code;income_volume"
      QQOUT(cLine)
   i++

  Do While !mkpr->(eof())

    cLine:=;
        cKod_DDIA+_T+; //distr_code  +  String  Код дистриб'ютора в систем  DDIA
        DTOC(mkpr->dttn)+_T+;// income_date  +  Date  Дата приходу
        ltrim(str(mkpr->mntovt))+_T+;//sku_code або distr_product_code+  String  Артикул виробника * або Артикул дистриб'ютора
        LTRIM(str(mkpr->kvp)) //income_volume  +  Integer  Розм р приходу у одиницях вим ру

    IF i=0
      QQOUT(cLine)
      i++
    ELSE
      QOUT(cLine)
    ENDIF

    mkpr->(DBSkip())
  EndDo
  SET PRINT TO
  SET PRINT OFF




         #ifdef __CLIP__
           set translate path off
         #endif
    cLogSysCmd:=""
  #ifdef __CLIP__
  //SET DATE FORMAT "yyyy-mm-dd"
  //SET CENTURY ON
    cRunZip:="/usr/bin/zip"
    cFileNameArc:=cFilePef+"DDIA"+cMark+DTOC(DATE(),"yyyy-mm-dd")+'T'+CHARREPL(":", TIME(), "-")+".zip"
    cFileList:="";
    +"income.csv ";
    +"adrd.csv ";
    +"stocks.csv ";
    +"ta.csv ";
    +"sales.csv ";
    +"sku.csv"

    SYSCMD(cRunZip+" "+cFileNameArc+" "+;
    cFileList +;
    " ; ./Sum.bat "+cFileNameArc,"",@cLogSysCmd)

    qout(__FILE__,__LINE__,cLogSysCmd)

    SendingJafa(cListEmail,{{ cFileNameArc,cMark+"_"+str(228,3)+" "+cFilePef+"__ProdResSumy"+" "+DTOC(DATE(),"YYYYMMDD")}},"./",228)


  #endif
         #ifdef __CLIP__
           set translate path on
         #endif
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  03-18-16 * 12:02:06pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION DDIA_delta(cMark, cKod_DDIA, cFilePef, cListEmail, cNmMark, ddtBeg)
  //DEFAULT ddtBeg TO DATE()
  if .t.
    dtBegr:=dtEndr:=DATE()

    IF (UPPER("/get-date") $ UPPER(DosParam()))

      clvrt_get_date(@dtBegr,@dtEndr,;
      "Подготовка отчета "+cMark+" "+cNmMark+"данных за период.",;
      "имя файла архива ol_<дата1>-<дата2>.zip",;
      {|a1,a2| a1<=a2 .and. (BOM(a1)=BOM(a2),.T.) };
    )

      IF LASTKEY() = 13
        set device to print
        set print to clvrt.log ADDI

        gdTd:=BOM(dtBegr)

      ELSE
        RETURN
      ENDIF
    ELSE

      dtEndr:=date() - iif(val(ltrim(left(time(),2))) > 21,0,-1)
      dtBegr:=dtEndr - 10
      IF !EMPTY(ddtBeg)
        IF dtBegr <  ddtBeg
          dtBegr:=ddtBeg
        ENDIF
      ENDIF
    ENDIF
    IF !(UPPER("/no_mkotch") $ UPPER(DosParam()))
      MkOtchN_Range( VAL(cMark), @dtBegr,@dtEndr,cDosParam)
    ENDIF
  endif

    IF (UPPER("/support") $ UPPER(DosParam()))
      quit
    ENDIF

   dtOstr:=dtEndr

   netuse('s_tag')
   netuse('kgp')
   netuse('kgpcat')
   netuse('krn')
   netuse('knasp')
   netuse('kln')


  /////////  товар  ///////
  use mktov alias  mktov new Exclusive //остатки за несколько переиодов
  repl bar  with mntovt+0*(2*10^13*0) for empty(bar)

  INDEX ON STR(sk)+STR(mntovt) TO tmptov
  total on STR(sk)+STR(mntovt) FIELDS OsFo to tmpmktov
  close mktov

  use tmpmktov alias  mktov new
  index on mntovt tag t1 uniq
  ordsetfocus(0)
  ///////////


  use ("mkpr"+cMark) alias  mkpr new
  copy to mkpr
  close
  use ("mkpr") alias  mkpr new Exclusive
  append from ("mkpe"+cMark)
  repl bar  with mntovt+0*(2*10^13*0) for empty(bar)
  set rela to mntovt into mktov
  go top

  use ("mkdoc"+cMark) alias mkdoc new
  copy to mkdoc
  close
  use ("mkdoc") alias mkdoc  Exclusive new
  append from ("mkdoe"+cMark)
  repl bar  with mntovt+0*(2*10^13*0) for empty(bar)

  set rela to mntovt into mktov

  sele  mkpr
  go top
  SELE mkdoc
  go top
  Delta2Csv(cMark, cKod_DDIA, cFilePef, cListEmail, cNmMark, ddtBeg)

  /*
  sele  mkpr
  go top
  SELE mkdoc
  go top
  Delta2Xls(cMark, cKod_DDIA, cFilePef, cListEmail, cNmMark, ddtBeg)
  */

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-15-16 * 02:16:30pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Delta2Csv(cMark, cKod_DDIA, cFilePef, cListEmail, cNmMark, ddtBeg)
  LOCAL cLogSysCmd:=""
  LOCAL cDTLM, cFile

  //Таблиця продаж в (sales.csv)
  set("PRINTER_CHARSET","cp1251")
  //set("PRINTER_CHARSET","cp866")
  //set("PRINTER_CHARSET","koi8-u")
  SET DATE FORMAT "DD.MM.YYYY" //"yyyy-mm-dd"
  SET CENTURY ON

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO sales.csv
   i:=0
   // #define CSV2DBF
   #ifdef CSV2DBF
      //set("PRINTER_CHARSET","cp866")
   #else
    set("PRINTER_CHARSET","cp1251")
    cLine:=;
    "НомерДокумента;ДатаДокумента;ВидДокумента;ДистрибюторИД;НаименованиеДистрибьютора;КонтрагентИД;НаименованиеКонтрагента;АдресДоставкиТТ;ВидДвижения;ЭтоВозврат;Количество;НоменклатураИД;СкладДистрибьютора;ТорговыйПредставитель;Сумма"
    //'НомерДокумента;ДатаДокумента;ВидДокумента;ДистрибюторИД;НаименованиеДистрибьютора;КонтрагентИД;НаименованиеКонтрагента;АдресДоставкиТТ;ВидДвижения;ЭтоВозврат;Количество;НоменклатураИД;СкладДистрибьютора;ТорговыйПредставитель;Сумма'
      QQOUT(cLine)
     i++
   #endif

  sele  mkdoc
  go top
  Do While !mkdoc->(eof())
   if ngMerch_Sk241 # mkdoc->Sk
   else
     mkdoc->(DBSkip())
     loop
   endif
    cDTLM := DTOS(DATE())
    #ifdef __CLIP__
      cDTLM := DTOC(DTTN,"yyyy-mm-dd")+' '+TDC
    #endif
    VidDoc:=""
    DO CASE
    CASE vo=9
      cDoc_Type:="РеализацияТоваровУслуг"
    CASE vo=1
      cDoc_Type:="ВозвратТоваровПоставщику"
    CASE vo= 6
      cDoc_Type:="ПеремещениеНаФилиал"
    CASE vo=5
      cDoc_Type:="СписаниеТоваров"
    OTHERWISE
      cDoc_Type:=' для VO='+STR(mkdoc->vo)+;
      ' KOP='+STR(mkdoc->kop)
    ENDCASE

    cLine:=;
   ALLTRIM(LTRIM(STR(SK))+PADL(LTRIM(STR(TTN)),7,"0"))+_T+; //"НомерДокумента;
   cDTLM+_T+; //ДатаДокумента;
   cDoc_Type+_T+; //ВидДокумента;
   cKod_DDIA+_T+; //ДистрибюторИД;
   "ТОВ Сумипродресус"+_T+; //НаименованиеДистрибьютора;
   ALLTRIM(STR(OKPO))+_T+; //КонтрагентИД;
   ALLTRIM(NPL)+_T+; //НаименованиеКонтрагента;
      (kln->(netseek('t1','mkdoc->kgp')),;
      alltrim(getfield("t1","kln->krn","krn","nrn"))+" "+;       //Район
      alltrim(getfield("t1","kln->knasp","knasp","nnasp"))+" "+; //Город
      alltrim(mkdoc->agp);//Физическое местонахождение
    )      ;//                                  //client_addr_address  +  String  Адреса доставки в систем  дистриб'ютора
   +_T+; //АдресДоставкиТТ;
   "2"+_T+; //ВидДвижения;
   "0"+_T+; //ЭтоВозврат ;
   strtran(ALLTRIM(STR(kvp*(-1))),".",",")+_T+; //Количество;
   STR(Bar);//НоменклатураИД;
   +_T+ LTRIM(STR(SK)); //СкладДистрибьютора;
   +_T+ (;
       s_tag->(netseek('t1','mkdoc->kta')),;
      PADL(LTRIM(STR(mkdoc->kta)),4,"0")+"_"+ALLTRIM(s_tag->fio);
      ); //ТорговыйПредставитель"
   +_T+ strtran(ALLTRIM(STR(kvp*(-1)*IIF(zenn=0,zen,zenn)*1.2,15,2)),".",",")//Сумма"

    IF i=0
      QQOUT(cLine)
      i++
    ELSE
      QOUT(cLine)
    ENDIF

    mkdoc->(DBSkip())
  EndDo


  sele  mkpr
  go top
  Do While !mkpr->(eof())
   if ngMerch_Sk241 # mkpr->Sk
   else
     mkpr->(DBSkip())
     loop
   endif
    cDTLM := DTOS(DATE())
    #ifdef __CLIP__
      cDTLM := DTOC(DTTN,"yyyy-mm-dd")+' '+TDC
    #endif
    VidDoc:=""
    DO CASE
    CASE kop=108
      cDoc_Type:="ВозвратТоваровОтПокупателя"
    CASE vo=6 .and. mkpr->kop=111
      cDoc_Type:="ОприходываниеТоваров"
    CASE vo= 6 .and. mkpr->kvp>0 //6 Перемещение на филиал (+)       salInH
      cDoc_Type:="ПриходНаФилиал"
    CASE vo= 9 // - приход от поставщика,
      cDoc_Type:="ПоступлениеТоваров"
    CASE vo= 1   // возврат производителю
      cDoc_Type:="ВозвратТоваровПоставщику"
    OTHERWISE
      cDoc_Type:=' для VO='+STR(mkpr->vo)+;
      ' KOP='+STR(mkpr->kop)
    ENDCASE

    cLine:=;
   ALLTRIM(LTRIM(STR(SK))+PADL(LTRIM(STR(TTN)),7,"0"))+_T+; //"НомерДокумента;
   cDTLM+_T+; //ДатаДокумента;
   cDoc_Type+_T+; //ВидДокумента;
   cKod_DDIA+_T+; //ДистрибюторИД;
   "ТОВ Сумипродресус"+_T+; //НаименованиеДистрибьютора;
   ALLTRIM(STR(OKPO))+_T+; //КонтрагентИД;
   ALLTRIM(NPL)+_T+; //НаименованиеКонтрагента;
      (kln->(netseek('t1','mkpr->kgp')),;
      alltrim(getfield("t1","kln->krn","krn","nrn"))+" "+;       //Район
      alltrim(getfield("t1","kln->knasp","knasp","nnasp"))+" "+; //Город
      alltrim(mkpr->agp);//Физическое местонахождение
    )      ;//                                  //client_addr_address  +  String  Адреса доставки в систем  дистриб'ютора
   +_T+; //АдресДоставкиТТ;
   IIF(vo=1,;
       IIF(kop=108,;
            "1",;
            "2";
         ),;
       "1";
     );
   +_T+; //ВидДвижения;
   IIF(vo=1,"1","0")+_T+; //ЭтоВозврат ;
   STRTRAN(ALLTRIM(STR(kvp*;
   IIF(vo=1,;
       IIF(kop=108,;
               1,;
              -1;
         ),;
       1);
     )),".",",");
       +_T+; //Количество;
   STR(Bar); //НоменклатураИД;
   +_T+ LTRIM(STR(SK)); //СкладДистрибьютора;
   +_T+ (;
       s_tag->(netseek('t1','mkdoc->kta')),;
      PADL(LTRIM(STR(mkdoc->kta)),4,"0")+"_"+ALLTRIM(s_tag->fio);
      ); //ТорговыйПредставитель"
   +_T+ STRTRAN(ALLTRIM(STR(kvp*;
   IIF(vo=1,;
     IIF(kop=108,;
               1,;
              -1;
       ),;
       1);
       *IIF(zen=0,0.01,zen)*1.2,15,2)),".",",")//Сумма"

    IF i=0
      QQOUT(cLine)
      i++
    ELSE
      QOUT(cLine)
    ENDIF

    mkpr->(DBSkip())
  EndDo


  sele mktov
  ordsetfocus(0)
  If DATE() = EOM(DATE())
    mktov->(DBGoTop())
  Else
    sele mktov
    DBGOBOTTOM(); DBSKIP()
  EndIf
  DO WHILE !mktov->(EOF())
    cDTLM := DTOS(DATE())
    #ifdef __CLIP__
      cDTLM := DTOC(mktov->DT,"yyyy-mm-dd")+' '+mktov->TM
    #endif
    VidDoc:=""
    cDoc_Type:="ОтражениеОстаткаСКЮ"

    cLine:=;
   ALLTRIM(LTRIM(STR(SK))+PADL(LTRIM(STR(mntovt)),7,"0"))+_T+; //"НомерДокумента;
   cDTLM+_T+; //ДатаДокумента;
   cDoc_Type+_T+; //ВидДокумента;
   cKod_DDIA+_T+; //ДистрибюторИД;
   "ТОВ Сумипродресус"+_T+; //НаименованиеДистрибьютора;
   cKod_DDIA+_T+; //КонтрагентИД;
   "ТОВ Сумипродресус"+_T+; //НаименованиеКонтрагента;
   NSK+_T+; //Адрес склада;
   "3"+_T+; //ВидДвижения;
   "0"+_T+; //ЭтоВозврат ;
   strtran(ALLTRIM(STR(OsFo)),".",",")+_T+; //Количество;
   STR(Bar);//НоменклатураИД;
   +_T+ LTRIM(STR(SK)); //СкладДистрибьютора;
   +_T+ "_"+ ; //ТорговыйПредставитель"
   +_T+ strtran(ALLTRIM(STR(OsFo * CenPr * 1.2,15,2)),".",",")//Сумма"

    IF i=0
      QQOUT(cLine)
      i++
    ELSE
      QOUT(cLine)
    ENDIF

    mktov->(DBSkip())
  ENDDO

  SET PRINT TO
  SET PRINT OFF



  mktov->(DBGoTop())
  cFileBalance := "balance_"+DTOC(mktov->DT,"yyyymmdd")+"."+"csv"

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO (cFileBalance)
   i:=0
   #ifdef CSV2DBF
      //set("PRINTER_CHARSET","cp866")
   #else
    set("PRINTER_CHARSET","cp1251")
    cLine:=;
    "ДистрибюторИД;НаименованиеДистрибьютора;ДатаДокумента;НоменклатураИД;СкладДистрибьютора;ОстатокКоличество"
    QQOUT(cLine)
     i++
   #endif
    sele mktov
    mktov->(DBGoTop())
    DO WHILE !mktov->(EOF())
      If OsFo <= 0
        mktov->(DBSkip())
        LOOP
      EndIf
      cDTLM := DTOS(DATE())
      #ifdef __CLIP__
        cDTLM := DTOC(mktov->DT,"yyyy-mm-dd")+' '+mktov->TM
      #endif
      cBar:=STR(iif(Empty(Bar),mntovt,Bar))

     cLine:=;
     cKod_DDIA;//ДистрибюторИД               Число       ОКПО/ИНН дистрибьютора
     +_T+"ТОВ Сумипродресус"; // //НаименованиеДистрибьютора   Строка(150) Короткое наименование дистрибьютора
     +_T+cDTLM; //ДатаДокумента               Строка(19)  Формат dd-MM-yyyy Пример 12-01-2020
     +_T+cBar;//НоменклатураИД              Число       Артикул номенклатуры (см. Штрих-коды). Если не определен, то системный код товара.
     +_T+LTRIM(STR(SK));//СкладДистрибьютора          Число       Код склада, на котором хранится остаток товара.
     +_T+strtran(ALLTRIM(STR(OsFo)),".",",");//ОстатокКоличество           Число       Ненулевой остаток товара на текущую дату, также не должен быть отрицательным
     +""

      IF i=0
        QQOUT(cLine)
        i++
      ELSE
        QOUT(cLine)
      ENDIF

      mktov->(DBSkip())
    ENDDO

    SET PRINT TO
    SET PRINT OFF





  //Таблиця продукт в SKU (sku.csv)
  sele mktov
  ordsetfocus('t1') // по товару уникальный

  If .T. .or. DATE() = EOM(DATE())
    mktov->(DBGoTop())
  Else
    sele mktov
    DBGOBOTTOM(); DBSKIP()
  EndIf

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO sku.csv

  i:=0
  cLine:=;
  "distr_code;Barcode;sku_code;distr_product_code;distr_product_name;distr_product_unit_name"
   QQOUT(cLine)
  i++
  Do While !mktov->(eof())
      cLine:=;
    cKod_DDIA+_T+;//distr_code   +  String  Код дистриб'ютора в систем  DDIA
    LTRIM(str(mktov->bar))+_T+;//barcode  +  String  Штрих-код
    ""+_T+;//sku_code  +  String  Код / Артикул Виробника
    ltrim(str(mktov->mntovt))+_T+;//distr_product_code  +  String  Код / Артикул дистриб'ютора
    alltrim(mktov->NaT)+_T+;//distr_product_name    String  Назва продукту
    "шт." //alltrim(mktov->NEi) //distr_product_unit_name    String  Назва одиниц  вим ру  з дов дника виробника, в
                            //як й показан  залишки, продаж  та  нше в
                            //таблицях, що формуються зг дно цього ТЗ
    IF i=0
      QQOUT(cLine)
      i++
    ELSE
      QOUT(cLine)
    ENDIF

    mktov->(DBSkip())
  EndDo
  SET PRINT TO
  SET PRINT OFF



  #ifdef __CLIP__
    set translate path off
  #endif

   #ifdef CSV2DBF
    crtt('sales',;
     'f:НомерДокумента c:c(10) ';
    +'f:ДатаДокумента c:c(19) ';
    +'f:ВидДокумента c:c(30)  ';
    +'f:ДистрибюторИД c:n(10) ';
    +'f:НаимДистрибьютора c:c(30) ';
    +'f:КонтрагентИД c:n(10) ';
    +'f:НаимКонтрагента c:c(60) ';
    +'f:АдресДоставкиТТ c:c(60) ';
    +'f:ВидДвижения c:n(1) ';
    +'f:ЭтоВозврат  c:n(1) ';
    +'f:Количество c:n(9,3) ';
    +'f:НоменклатураИД c:n(20) ';
    +'f:Сумма c:n(10,2)';
  )
    use sales new
    append from sales.csv delim with ';'
     quit
   #else
    //
   #endif


    #ifdef __CLIP__
      cDTLM := DTOC(date(),"yyyy-mm-dd")+'T'+CHARREPL(":", TIME(), "-")
    #endif
  cFile:=cKod_DDIA+cDTLM //+".xls"

  copy file sales.csv to (cFile + ".csv")

  #ifdef __CLIP__
  //SET DATE FORMAT "yyyy-mm-dd"
  //SET CENTURY ON
    cRunZip:="/usr/bin/zip"
    cFileNameArc := cFile + ".zip"  //cFilePef+"DDIA"+cMark+DTOC(DATE(),"yyyy-mm-dd")+'T'+CHARREPL(":", TIME(), "-")+".zip"
    cFileList := cFile + ".csv"+;
    +' '+"sku.csv"


    cLogSysCmd:=""
    SYSCMD(cRunZip+" "+cFileNameArc+" "+;
    cFileList + " ; ./Sum.bat "+cFileNameArc,"",@cLogSysCmd)

    outlog(__FILE__,__LINE__, cLogSysCmd,;
     cRunZip+" "+cFileNameArc+" "+;
        cFileList ;
  )
    //cFileNameArc:="sales.csv"

    SendingJafa(cListEmail,{{ cFileNameArc,cMark+"_"+str(228,3)+" "+cFilePef+"__ProdResSumy"+" "+DTOC(DATE(),"YYYYMMDD")}},"./",228)

    //отправка cFileBalance
    If UPPER("/balance") $ cDosParam
      cFileNameArc := cFileBalance
      SendingJafa(cListEmail,{{ cFileNameArc,cMark+"_"+str(228,3)+" "+cFilePef+"__ProdResSumy"+" "+DTOC(DATE(),"YYYYMMDD")}},"./",228)
    EndIf

    qout(__FILE__,__LINE__,cLogSysCmd)


  #endif
         #ifdef __CLIP__
           set translate path on
         #endif
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-15-16 * 02:24:06pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Delta2Xls(cMark, cKod_DDIA, cFilePef, cListEmail, cNmMark, ddtBeg)
  LOCAL cFile
  LOCAL cDTLM
  LOCAL nCount, nI
  LOCAL nRow, cCell, i
  LOCAL cTitle
  LOCAL lConv, lYesNo
  LOCAL cLogSysCmd:=""


  lConv:= .T. //.T. //NEED_OEM2ANSI ковертарция
  lYesNo:= .F.


    #ifdef __CLIP__
      cDTLM := DTOC(date(),"yyyy-mm-dd")+'T'+CHARREPL(":", TIME(), "-")
    #endif
  cFile:=cKod_DDIA+cDTLM+".xls"

         #ifdef __CLIP__
           set translate path off
         #endif

  // header
  //header OpenOffice.org excelfileformat.pdf, MSDN ID: Q178605
  _h:=FCREATE(cFile)
  FWRITE(_h, CHR(9)+CHR(8)+I2Bin(8)+;
    I2Bin(0)+I2Bin(16)+L2Bin(0);
      )
  nRow:=0
  /*
  // заголовок
  IF !EMPTY(cTitle)
    WriteCell(_h,cTitle, INT(LEN(_fc)/2)+1, nRow, 0, lConv, lYesNo)
    nRow+=2
  ENDIF
  */

  cLine:=;
  "НомерДокумента;ДатаДокумента;ВидДокумента;ДистрибюторИД;НаименованиеДистрибьютора;КонтрагентИД;НаименованиеКонтрагента;АдресДоставкиТТ;ВидДвижения;ЭтоВозврат ;Количество;НоменклатураИД;Сумма;"

  nCount := NUMTOKEN(cLine, ";", 1)
  FOR nI := 1 TO nCount
    cNmCol:=TOKEN(cLine, ";", nI, 1)
    i:=nI

    // Для многострочных заголовков вставляется line break
    cCell:=StrTran(cNmCol, ';', CHR(10))
    WriteCell(_h, cCell, i-1, nRow, 0, lConv, lYesNo)

  NEXT nI
  nRow++



  Do While !mkdoc->(eof())
    i:=0
    cDTLM := DTOS(DATE())
    #ifdef __CLIP__
      cDTLM := DTOC(DTTN,"yyyy-mm-dd")+' '+TDC
    #endif
    VidDoc:=""
    DO CASE
    CASE vo=9
      cDoc_Type:="РеализацияТоваровУслуг"
    CASE vo=1
      cDoc_Type:="ВозвратТоваровПоставщику"
    CASE vo= 6
      cDoc_Type:="ПеремещениеНаФилиал"
    CASE vo=5
      cDoc_Type:="СписаниеТоваров"
    OTHERWISE
      cDoc_Type:=' для VO='+STR(mkdoc->vo)+;
      ' KOP='+STR(mkdoc->kop)
    ENDCASE

   i:=0

   cCell:=ALLTRIM(LTRIM(STR(SK))+PADL(LTRIM(STR(TTN)),7,"0")) //"НомерДокумента;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
   cCell:=cDTLM //ДатаДокумента;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
   cCell:=cDoc_Type //ВидДокумента;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
   cCell:=VAL(cKod_DDIA) //ДистрибюторИД;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
   cCell:="ТОВ Сумипродресус" // НаименованиеДистрибьютора;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
   cCell:=OKPO // КонтрагентИД;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
   cCell:=ALLTRIM(NPL) // НаименованиеКонтрагента;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)

   cCell:=   (kln->(netseek('t1','mkdoc->kgp')),;
      alltrim(getfield("t1","kln->krn","krn","nrn"))+" "+;       //Район
      alltrim(getfield("t1","kln->knasp","knasp","nnasp"))+" "+; //Город
      alltrim(mkdoc->agp);//Физическое местонахождение
    )      //                                  //client_addr_address  +  String  Адреса доставки в систем  дистриб'ютора
       //АдресДоставкиТТ;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
   cCell:=2 //ВидДвижения;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
   cCell:=0 //ЭтоВозврат ;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
   cCell:=kvp*(-1) //Количество;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
   cCell:=STR(Bar) //НоменклатураИД;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
   cCell:=ROUND(kvp*(-1) * IIF(zenn=0,zen,zenn) * 1.20,2) //Сумма"
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
    nRow++
    mkdoc->(DBSkip())
  EndDo

  //FWRITE(_h, I2Bin(10)+I2Bin(0))  //XLSEOF
  //FCLOSE(_h)


  sele  mkpr
  go top
  Do While !mkpr->(eof())
    cDTLM := DTOS(DATE())
    #ifdef __CLIP__
      cDTLM := DTOC(DTTN,"yyyy-mm-dd")+' '+TDC
    #endif
    VidDoc:=""
    DO CASE
    CASE kop=108
      cDoc_Type:="ВозвратТоваровОтПокупателя"
    CASE vo=6 .and. mkpr->kop=111
      cDoc_Type:="ОприходываниеТоваров"
    CASE vo= 6 .and. mkpr->kvp>0 //6 Перемещение на филиал (+)       salInH
      cDoc_Type:="ПриходНаФилиал"
    CASE vo= 9 // - приход от поставщика,
      cDoc_Type:="ПоступлениеТоваров"
    CASE vo= 1   // возврат производителю
      cDoc_Type:="ВозвратТоваровПоставщику"
    OTHERWISE
      cDoc_Type:=' для VO='+STR(mkpr->vo)+;
      ' KOP='+STR(mkpr->kop)
    ENDCASE
   i:=0
   cCell:=ALLTRIM(LTRIM(STR(SK))+PADL(LTRIM(STR(TTN)),7,"0")) //"НомерДокумента;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
   cCell:=cDTLM //ДатаДокумента;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
   cCell:=cDoc_Type //ВидДокумента;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
   cCell:=VAL(cKod_DDIA) //ДистрибюторИД;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
   cCell:="ТОВ Сумипродресус" //НаименованиеДистрибьютора;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
   cCell:=OKPO //КонтрагентИД;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
   cCell:=ALLTRIM(NPL) //НаименованиеКонтрагента;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
   cCell:=   (kln->(netseek('t1','mkpr->kgp')),;
      alltrim(getfield("t1","kln->krn","krn","nrn"))+" "+;       //Район
      alltrim(getfield("t1","kln->knasp","knasp","nnasp"))+" "+; //Город
      alltrim(mkpr->agp);//Физическое местонахождение
    )      //                                  //client_addr_address  +  String  Адреса доставки в систем  дистриб'ютора
    //АдресДоставкиТТ;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
   cCell:=IIF(vo=1, IIF(kop=108, 1, 2), 1)  //ВидДвижения;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)

   cCell:=IIF(vo=1,1,0) //ЭтоВозврат ;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)

   cCell:=kvp * IIF(vo=1, IIF(kop=108, 1, -1),  1) //Количество;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
   cCell:=STR(Bar) //НоменклатураИД;
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
   cCell:=kvp * IIF(vo=1, IIF(kop=108, 1, -1),  1) * IIF(zenn=0,zen,zenn) *1.2 //Сумма"
        WriteCell(_h, cCell, i++, nRow, 0, lConv, lYesNo)
   nRow++

    mkpr->(DBSkip())
  EndDo
  //return
   // exit

  FWRITE(_h, I2Bin(10)+I2Bin(0))  //XLSEOF
  FCLOSE(_h)

    cLogSysCmd:=""


  #ifdef __CLIP__
    /*
    cRunZip:="/usr/bin/zip"
    cFileNameArc:=cFilePef+"DDIA"+cMark+DTOC(DATE(),"yyyy-mm-dd")+'T'+CHARREPL(":", TIME(), "-")+".zip"
    cFileList:="";
    +cFile

    SYSCMD(cRunZip+" "+cFileNameArc+" "+;
    cFileList +;
    " ; ./Sum.bat "+cFileNameArc,"",@cLogSysCmd)

    qout(__FILE__,__LINE__,cLogSysCmd)
    */
    cFileNameArc:=cFile
    SendingJafa(cListEmail,{{ cFileNameArc,cMark+"_"+str(228,3)+" "+cFilePef+"__ProdResSumy"+" "+DTOC(DATE(),"YYYYMMDD")}},"./",228)

    qout(__FILE__,__LINE__,cLogSysCmd,cFileNameArc,cFile)


  #endif
         #ifdef __CLIP__
           set translate path on
         #endif
  RETURN (NIL)




/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  10-20-16 * 04:24:44am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
#include "fox.ch"
#include "foxsql.ch"

FUNCTION foxsele()
  sele rs2
  set rela to
  ordsetfocus('t2')

  SELECT kvp, rs1.ttn, mntov ;
  FROM rs1, rs2 ;
  WHERE rs1.ttn = rs2.ttn ;
  and rs1.kop = 139 and (rs1.ktofp = -69 or rs1.ktofp = -68);
  INTO TO TABLE t2

  RETURN (NIL)
 */

/*
CASE UPPER("/runa") $ cDosParam

  distributor_id = "3DA99F89-5D0B-435F-9D1C-64DE57D7DE06"

  if .t.
    dtBegr:=dtEndr:=DATE()

    IF (UPPER("/get-date") $ UPPER(DosParam()))

      clvrt_get_date(@dtBegr,@dtEndr,;
      "Подготовка отчета РУНА данных за период.",;
      "имя файла архива ol_<дата1>-<дата2>.zip",;
      {|a1,a2| a1<=a2 .and. BOM(a1)=BOM(a2) };
    )

      IF LASTKEY()=13
        set device to print
        set print to clvrt.log ADDI

        gdTd:=BOM(dtBegr)

      ELSE
        RETURN
      ENDIF
    ELSE
      dtEndr:=date()-1
      dtBegr:=dtEndr//-1 //45
      MkOtchN_Range(041,@dtBegr,@dtEndr,cDosParam)
    ENDIF
  endif

   netuse('s_tag')
   netuse('kgp')
   netuse('kgpcat')
   netuse('krn')
   netuse('knasp')
   netuse('kln')

  /*
  Продажи
     #ifdef __CLIP__
        Commentr   := translate_charset("utf-8",host_charset(),aZ_CRM[i,3, 1,2]) //коментарий
     #endif
  Описание
  distributor id: уникальный идентификатор дистрибьютора
  distributor state: тип учета остатков.
    0 - состояние на начало дня,
    1 - состояние на конец дня

  offeringmovement: складское движение
  ofадское движение
  offeringmovement sroreID: Идентификатор торговой точки дистрибьютора
  offeringmovement date: дата складского движения в формате ГГГГ-ММ-ДД.
  offeringmovement type: тип складского движения.
    0 - приход от поставщика,
    1 - расход покупателям,
    2 - возврат поставщику,
    3 - возврат от покупателя,
    4 и 5 - перемещение между регионами внутри одного дистрибутора
    (4 - списание в одном регионе, 5 - поступление в другом регионе),
    6 - списание товара

  store торговая точка в складском движении
  store dp_name: название торговой точки
  store dp_region: область торговой точки.
     На русском языке без дополнительных сокращений. Примеры: Киевская, Львовская, Луганская
  store dp_city: город торговой точки.
     На русском языке без дополнительных сокращений. Примеры: Киев, Львов, Луганск, Луцк
  store dp_address: адрес торговой точки.
     На русском языке в произвольном формате.
  store dp_type: тип торговой точки (
    ПМ - Продуктовый магазин,
    П - Павильон,
    ММ - Мини-маркет,
    ГМ - Гастроном,
    Р - Розничный рынок,
    ОР - Оптовый рынок,
    Г - Гипермаркет,
    СС - Саch&Carry,
    С1 - Супермаркет,
    Д - Дискаунтеры)
  store dp_agent: имя торгового агента (ФИО)
  store dp_supervisor: имя супервайзера (ФИО)

  offering: продукт в складском движение.
    Штрих-код поставщика (http://www.runa.com.ua/production/all/index.html)
  offering package: тип упаковки:
    1 - банка скляна "Тв?ст-офф",
    2 - ПЕТФ,
    3 - Дой-Пак (без дозатора),
    4 - Дой-пак (з дозатором),
    5 - в?дро,
    6 - ПЕТ пл?вка
  offering quantity: количество единиц
  offering cost: стоимость за единицу с учетом НДС

  update: дата генерации файла в формате ГГГГ-ММ-ДД ЧЧ:ММ:СС.

  XML-файл выгружается 1 раз в сутки на FTP сервер "Луцк-Фудз"
  в архиве ${distributor id}.zip
  (6F9619FF-8B86-D011-B42D-00CF4FC964FF.zip) самостоятельно или
  с помощью предоставляемой утилиты.
  */

  cCharSetPrn:="koi8-u"//"cp1251"//"UTF-8" //"koi8-u"
  //cCharSetPrn:="UTF-8" //"koi8-u"
  set("PRINTER_CHARSET",cCharSetPrn)
  //set("PRINTER_CHARSET","cp1251")
  //set("PRINTER_CHARSET","koi8-u")

  SET DATE FORMAT "yyyy-mm-dd"
  SET CENTURY ON

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO sales_tmpl.xml
            //outlog(__FILE__,__LINE__," 2")

  //qqout('<?xml version = "1.0" encoding = "UTF-8" ?>')
  qqout('<?xml version = "1.0" encoding = "'+cCharSetPrn+'" ?>')
  qout('<distributor id = "{'+distributor_id+'}" state = "1" >')

  use mktov new
  index on mntovt to tmpmktov

  use mkdoc041 alias mkdoc new

  use mkpr041  new Exclusive
  repl all  vo with vo*10
  close
  sele mkdoc
  append from mkpr041

  sele mkdoc
  index on str(vo)+str(kgp)+str(mntovt) to mkdoc

  set rela to mntovt into mktov
  sele mkdoc

  DBGoTop()
  DO WHILE !EOF()

    vor := mkdoc->vo
    /*
    offeringmovement type: тип складского движения.
    */
    DO CASE
    CASE vor= 90
      type := "0" // - приход от поставщика,
    CASE vor= 9
      type := "1" //  расход покупателям,
    CASE vor= 1
      type := "2" //  2 - возврат поставщику,
    CASE vor= 10
      type := "3" //  3 - возврат от покупателя,
    //4 и 5 - перемещение между регионами внутри одного дистрибутора
    CASE vor= 6
      type := "4" //  (4 - списание в одном регионе,
    CASE vor= 60
      type := "5" //  5 - поступление в другом регионе),
    CASE vor=5
      type := "6" //  6 - списание товара
    OTHERWISE
      type := "6" //  6 - списание товара

    ENDCASE
    //type := "2"// //char

    qout('   <offeringmovement date = "'+DTOC(mkdoc->dttn)+'" type = "'+type+'" >')
    DO WHILE vor = mkdoc->vo //вид операции
    /*
    store dp_type: тип торговой точки (
    */
    //Канал (Розница,VIP,Horeca, Киоск)
    kgpcatr:=getfield("t1","mkdoc->kgp","kgp","kgpcat")
    nkgpcatr:=getfield("t1","kgpcatr","kgpcat","nkgpcat")
    DO CASE
    CASE kgpcatr = 1
      dp_type:="ОР" // - Оптовый рынок,
    CASE kgpcatr = 2
      dp_type:="С1" //- Супермаркет,
    CASE kgpcatr = 3
      dp_type:="ММ" // - Мини-маркет,
    CASE kgpcatr = 4
      dp_type:="ГМ"// - Гастроном,
    CASE kgpcatr = 5
      dp_type:="ПМ" //ПМ - Продуктовый магазин,
    CASE kgpcatr = 6
      dp_type:="Р" // - Розничный рынок,
    CASE kgpcatr = 7
      dp_type:="П" // П - Павильон,
    CASE kgpcatr = 8
      dp_type:="П" // П - Павильон,
    CASE kgpcatr = 9
      dp_type:="П" // П - Павильон,
    CASE kgpcatr = 10
      dp_type:="П" // П - Павильон,
    CASE kgpcatr = 11
      dp_type:="П" // П - Павильон,

    OTHERWISE
      //dp_type:="Д" //- Дискаунтеры)
      //dp_type:="СС"// - Саch&Carry,
      //dp_type:="Г" //- Гипермаркет,
      dp_type:="П" // П - Павильон,

    ENDCASE

    s_tag->(netseek('t1','mkdoc->kta'))
    ktasr:=s_tag->ktas
    kln->(netseek('t1','mkdoc->kgp'))
      qout('      <store  '+;
      'dp_name = "'+XmlCharTran(mkdoc->ngp,"0542","-name")+'" '+;
      'dp_region = "'+"Сумcкая"+'" '+;
      'dp_city = "'+XmlCharTran(getfield("t1","kln->knasp","knasp","nnasp"),"0542","-city")+'" '+; //Город
      'dp_address = "'+XmlCharTran(mkdoc->agp,"0542","-address")+'" '+;//Физическое местонахождение
      'dp_type = "'+dp_type+'" '+;
      'dp_agent = "'+XmlCharTran(s_tag->fio,"0542","-agent")+'" '+;
      'dp_supervisor = "'+XmlCharTran((s_tag->(netseek('t1','ktasr')), str(ktasr,4)+" "+ALLTRIM(s_tag->fio)),"0542","-supervisor")+'" '+;
      '>')

        kgpr := mkdoc->kgp
        DO WHILE kgpr = mkdoc->kgp //грузополучель

          mntovtr:=mkdoc->mntovt
          /*
          offering package: тип упаковки:
          1 - банка скляна "Тв?ст-офф",
          2 - ПЕТФ,
          3 - Дой-Пак (без дозатора),
          4 - Дой-пак (з дозатором),
          5 - в?дро,
          6 - ПЕТ пл?вка
          */
          pkg:="2"
          cost:=mktov->opt*1.2
          quan:=0

          DO WHILE mntovtr = mkdoc->mntovt
             quan+=mkdoc->kvp
             mkdoc->(DBSkip())
          ENDDO

          mkdoc->(DBSkip(-1))
          if !Empty(mkdoc->bar)
            qout(;
            '         <offering'+;
            ' package = "'+pkg+'"'+;
            ' quantity = "'+LTRIM(str(quan))+'"'+;
            ' cost = "'+LTRIM(str(cost,15,2))+'" >'+;
                        LTRIM(str(mkdoc->bar))+;
            '</offering>';
          )
          else
            /*
            outlog(__FILE__,__LINE__,date(),time(),;
            */
            qout(;
            '         <offering'+;
            ' package = "'+pkg+'"'+;
            ' quantity = "'+LTRIM(str(quan))+'"'+;
            ' cost = "'+LTRIM(str(cost,15,2))+'" >'+;
                        LTRIM(str(mkdoc->mntovt))+;
            alltrim(mkdoc->nat)+;
            '</offering>';
          )
          endif
          DBSkip()
        ENDDO

      qout('      </store>')
    ENDDO

    qout('   </offeringmovement>')
  ENDDO

  qout(' <update>'+DTOC(DATE())+' '+TIME()+'</update>')
  qout('</distributor>')

  SET PRINT TO
  SET PRINT OFF


         #ifdef __CLIP__
           set translate path off
         #endif
    cLogSysCmd:=""
  #ifdef __CLIP__
    cRunZip:="/usr/bin/zip"
    //cFileNameArc:=distributor_id+".zip"
    cFileNameArc:="ru042"+DTOC(DATE())+'T'+CHARREPL(":", TIME(), "-")+".zip"
    cFileList:="sales_tmpl.xml"+;
    ""


    SYSCMD(cRunZip+" "+cFileNameArc+" "+;
    cFileList +;
    " ; ./Sum.bat "+cFileNameArc,"",@cLogSysCmd)

    qout(__FILE__,__LINE__,cLogSysCmd)

      //"042_"+str(l_skr,3)+" "+aFile[1,2]+" "+DTOC(dDt,"YYYYMMDD")
    SendingJafa("lista@bk.ru",{{ cFileNameArc,"042_"+str(228,3)+" "+"RUNA__ProdResSumy"+" "+DTOC(DATE(),"YYYYMMDD")}},"./",228)


  #endif
         #ifdef __CLIP__
           set translate path on
         #endif
  QUIT
*/






/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  06-21-17 * 01:56:31pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Oczenka(aM,x1,k1)
  LOCAL l1, c1, nMinL1, nMinC1, nMin
  // начальный мин элемент
  FOR l1:=2 TO LEN(aM[x1])
    nValElem:=aM[x1,l1][1]

    If ISNIL(nValElem); loop; EndIf
    If l1 = k1; loop; EndIf

    nMin:=nValElem
    exit
  NEXT

  If !ISNIL(nMin)
    // мин в строке
    FOR l1:=2 TO LEN(aM[x1])
      nValElem:=aM[x1,l1][1]

      If ISNIL(nValElem); loop; EndIf
      If l1 = k1; loop; EndIf

      nMin:=Iif(nValElem < nMin, nValElem, nMin)

    NEXT
    nMinL1:=nMin
  else
    nMinL1:=99
  EndIf

  For c1:=2 To LEN(aM)
    nValElem:=aM[c1,k1][1]

    If ISNIL(nValElem); loop; EndIf
    If c1 = x1; loop; EndIf

    nMin:=nValElem
    exit
  NEXT

  If !ISNIL(nMin)
    // мин в столбец
    For c1:=2 To LEN(aM)
      nValElem:=aM[c1,k1][1]

      If ISNIL(nValElem); loop; EndIf
      If c1 = x1; loop; EndIf

      nMin:=Iif(nValElem < nMin, nValElem, nMin)

    Next
    nMinC1:=nMin
  else
    nMinC1:=9900
  EndIf
  // сумма
  RETURN (nMinL1 + nMinC1)


STATIC FUNCTION DeleChrWd_AKZ(cNat)
  LOCAL nPos, natr
  Natr:=CHARONE(' ',cNat)

  If UPPER('АКЦ') $ UPPER(cNat)
    nPos:=AT('N',cNat)
    natr:=LEFT(cNat,nPos-1)

    cNat:=SUBSTR(cNat,nPos)

    nPos := 1
    If substr(cNat,2,1)=' '
      nPos += 2
    EndIf

    cNat:=SUBSTR(cNat,nPos)

    nPos:=AT(' ',cNat)
    natr+=SUBSTR(cNat,nPos+1)

  EndIf
  RETURN (natr)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  09-02-19 * 11:15:54am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION JaffaOrdZap()

  FileDelete('_jfa_zap.txt')

  use lrs1 new
  use lrs2 new
  use tzvk new

  sele lrs1
  If !empty(lrs1->(LastRec()))
    SET CONSOLE OFF
    SET PRINT ON
    SET PRINT TO _jfa_zap.txt

    qqout('{')

    set filt to '2R__' $ DocGUID
    go top
    If !eof()
      qqout('"orders":[')
      qqout(allt(substr(DocGUID,5)))
      DBSkip()
      DBEval({||qqout(','+allt(substr(DocGUID,5)))}, , , , ,.T.)
      qqout(']')
    EndIf

    set filt to '2RT_' $ DocGUID
    go top
    If !eof()
      qqout(',"returns":[')
      qqout(allt(substr(DocGUID,5)))
      DBSkip()
      DBEval({||qqout(','+allt(substr(DocGUID,5)))}, , , , ,.T.)
      qqout(']')
    EndIf

    sele tzvk
    If !empty(tzvk->(LastRec()))
      qqout(',"moneys":[')
      qqout(allt(substr(Kom,5)))
      DBSkip()
      DBEval({||qqout(','+allt(substr(Kom,5)))}, , , , ,.T.)
      qqout(']')
    EndIf

    qqout('}')

    SET PRINT TO
    SET PRINT OFF
  EndIf


  close lrs1
  close lrs2
  RETURN (NIL)

