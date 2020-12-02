para prZnk,ktll,ktlpl
local slr
slr=select()

/*  Значения признака prZnk для записи в протокол PRO
*  1 - Удаление выписанного документа
*  2 -
*  3 - Снятие признака подтвержденного документа
*  4 - Коррекция товарной части документа
*  5 - Удаление позиции из выписанного документа
*  6 - Печать в товарном отделе
*  7 - Печать на складе
*  8 - Подтверждение складом
*  9 - Создание нового документа
* 10 - Коррекция шапки
* 11 - Ошибка отв. хран.
*/

if prZnk#prNppr
   sele cSkl
   netseek('t1','gnSk')
   reclock()
   nppr=pronpp
   if nppr=999999
      nppr=1
      netrepl('pronpp','2')
   else
      netrepl('pronpp','pronpp+1')
   endif
   netuse('pro1')
   arec:={}
   sele pr1
   getrec()
   sele pro1
   netadd()
   putrec()
   netrepl('npp,dnpp,tnpp,ktonpp,prnpp','nppr,date(),time(),gnKto,prZnk')
   prNppr=prZnk
   if fieldpos('docip')#0
     if !empty(gcNnetname)
       netrepl('docip','gcNnetname')
     else
       netrepl('docip','unamer')
     endif
   endif
endif

netuse('pro2')

do case
case prZnk=1 // Удаление выписанного документа
case prZnk=2 //
case prZnk=3 // Снятие признака подтвержденного документа
case prZnk=4 // Коррекция товарной части документа
    sele pr2
    if !(mn=mnr.and.ktl=ktll.and.iif(ktlpl#nil,ktlp=ktlpl,.t.))
        if ktlpl=nil
          netseek('t1','mnr,ktll,ktlpl')
        else
          netseek('t1','mnr,ktll')
        endif
    endif
    reclock()
    arec:={}
    getrec()
    sele pro2
    netadd()
    reclock()
    putrec()
    netrepl('npp','nppr')
case prZnk=5 // Удаление позиции из выписанного документа
    sele pr2
    if !(mn=mnr.and.ktl=ktll.and.iif(ktlpl#nil,ktlp=ktlpl,.t.))
        if ktlpl=nil
          netseek('t1','mnr,ktll,ktlpl')
        else
          netseek('t1','mnr,ktll')
        endif
    endif
    arec:={}
    getrec()
    sele pro2
    netadd()
    reclock()
    putrec()
    netrepl('npp','nppr')
case prZnk=6  // Печать в товарном отделе
case prZnk=7  //
case prZnk=8  // Подтверждение складом
case prZnk=9  // Создание нового документа
case prZnk=10 // Коррекция шапки
case prZnk=11 // Ошибка отв хран
endcase

nuse('pro1')
nuse('pro2')
sele (slr)



/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  03-19-18 * 04:00:11pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Pr1ToMemVar()
  dvpr = DVP           //дата выписки
  dprr = Dpr           //дата отгрузки
  dgdtdr=dgdtd
  dtmodr=dtmod
  tmmodr=tmmod
  mrshr=mrsh
  ndr = Nd             //номер документа
  mnr=mn
  amnr=amn             //номер автоматического документа/номер документа источника
  kopr = KOP           //код операции
  if (gnEnt=20.or.gnEnt=21).and.kopr=110.and.vor=1
      prvzznr=1
  endif
  katgrr=katgr
  qr   = mod(kopr,100)
  vur  = gnVu
  ktor = KTO           //код инженера
  przn = 1             //признак нового документа = 0 новый, = 1 есть
  prZr = PRZ           //признак подтверждения = 0 не подтв., = 1 подтв.
  pstr=pst
  kpsr=kps
  kpsbbr=getfield('t1','kpsr','kps','prbb')
  pr1ndsr=getfield('t1','kpsr','kpl','pr1nds')
  if kopr#110
      pr1ndsr=0
  endif
  Skvzr=Skvz
  ttnvzr=ttnvz
  dnnvzr=dnnvz
  nndsvzr=nndsvz
  kzgr=kzg
  nzgr=getfield('t1','kzgr','kln','nkl')
  dtvzr=dtvz
  ttnpstr=ttnpst
  dttnpstr=dttnpst
  ndspstr=ndspst
  dndspstr=dndspst
  nDotVr=otv             // Отв.хр.
  sdvr=sdv
  ktar=kta
  ktasr=ktas
  prvzr=prvz
  nktar=getfield('t1','ktar','s_tag','fio')
  if ktasr=0
      ktasr=getfield('t1','ktar','s_tag','ktas')
  endif
  if ktasr#0
      prexter=getfield('t1','ktasr','s_tag','prexte')
  else
      prexter=1
  endif
  nnzr = NNZ           //номер договора
  dnzr = DNZ           //дата договора
  docguidr=docguid
  Sklr=Skl
  textr=text
  hngr=hng
  mngr=mng
  hogrr=hog
  mogr=mog
  Sksr=Sks
  nSksr=getfield('t1','Sksr','cSkl','nSkl')
  mSklsr=getfield('t1','Sksr','cSkl','mSkl')
  Sklsr=Skls
  if mSklsr=0
      nSklsr=nSksr
  else
      nSklsr=getfield('t1','Sklsr','kln','nkl')
  endif
  Sktr=Skt
  Skltr=Sklt
  nSktr=getfield('t1','Sktr','cSkl','nSkl')
  mSkltr=getfield('t1','Sktr','cSkl','mSkl')
  if mSklsr=0
      nSkltr=nSktr
  else
      nSkltr=getfield('t1','Skltr','kln','nkl')
  endif
  prizenr=prizen
  vor=vo
  pvtr=pvt
  entpr =entp
  nentpr=getfield('t1','entpr','setup','uss')
  AMnPr=AMnP

  Skspr=Sksp
  nSkspr=getfield('t1','Skspr','cSkl','nSkl')
  mSklspr=getfield('t1','Sksr','cSkl','mSkl')
  Sklspr=Sklsp
  if mSklspr=0
      nSklspr=nSkspr
  else
      nSklspr=getfield('t1','Sklspr','kln','nkl')
  endif

  Sktpr=Sktp
  Skltpr=Skltp
  nSktpr=getfield('t1','Sktpr','cSkl','nSkl')
  mSkltpr=getfield('t1','Sktr','cSkl','mSkl')
  if mSkltpr=0
      nSkltpr=nSktpr
  else
      nSkltpr=getfield('t1','Skltr','kln','nkl')
  endif
  nndsr=nnds
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  03-19-18 * 04:05:06pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION  Pr1IniMemVar()
  public mnr,ndr,przn,prZr,kopr,tcenr,kplr,sdvr,kpsr,prnnr,kzgr,;
              Sklr,przp,pprr,Sktr,Sksr,Sklsr,Sktr,Skltr,pbzenr,;
              Skspr,Sklspr,Sktpr,Skltpr,katgrr,prmodr,pr361r,prvzznr,;
              Skar,Sklar,rtcenr,okklr,pprr,Skndr,otpcr,pstr,amnr,;
              pvtr,ttnvr,godvr,msvr,rcpr1r,ktar,ktasr,prvzr,hngr,mrshr,;
              mngr,hogr,mogr,nndsr,nomndsvzr,Skvzr,ttnvzr,dnnvzr,kpsbbr,;
              kgbbr, nndsvzr,pr1ndsr,prizenr
  public kpsr
  public nvor,nopr,nvur,nkplr,nkpsr,nSklar,nzgr
  public nktar
  public ttnpstr,ndspstr

  public textr
  public serr

  public nnzr
  public docguidr
  public dnzr,dprr,dtmodr,dtvzr,dvozr,dnnvzr
  public tmmodr
  public dvpr,dgdtdr,dttnpstr,dndspstr
  public nDotVr
  public sdvr
  public ktar
  public ktasr
  public prvzr
  public nktar
  public prexter
  public nnzr
  public dnzr
  public docguidr
  public Sklr
  public textr
  public hngr
  public mngr
  public hogrr
  public mogr
  public Sksr

  public vvz
  public qr
  public vur
  public vor
  public entpr
  public nentpr
  public AMnPr

  public nSksr, mSkltr, AMnPr, nSkspr, mSklspr, nSktpr, mSkltpr
  public Skar,  Sklar, mSklar, nSklar



  store 0 to mnr,ndr,przn,prZr,kopr,tcenr,kplr,sdvr,kpsr,prnnr,kzgr,;
              Sklr,przp,pprr,Sktr,Sksr,Sklsr,Sktr,Skltr,pbzenr,;
              Skspr,Sklspr,Sktpr,Skltpr,katgrr,prmodr,pr361r,prvzznr,;
              Skar,Sklar,rtcenr,okklr,pprr,Skndr,otpcr,pstr,amnr,;
              pvtr,ttnvr,godvr,msvr,rcpr1r,ktar,ktasr,prvzr,hngr,mrshr,;
              mngr,hogr,mogr,nndsr,nomndsvzr,Skvzr,ttnvzr,dnnvzr,kpsbbr,;
              kgbbr, nndsvzr,pr1ndsr,prizenr
  if gnSkOtv#0          //gnOtv=1.and.gnSkOtv#0
      kpsr=gnKklm  //2163805  ЗАШИТО !!!
  endif
  store '' to nvor,nopr,nvur,nkplr,nkpsr,nSklar,nzgr
  store space(15) to nktar
  store space(40) to ttnpstr,ndspstr

  store space(60) to textr
  store space(5) to serr

  nnzr  = space(9)
  docguidr=space(36)
  store ctod('') to dnzr,dprr,dtmodr,dtvzr,dvozr,dnnvzr
  store space(8) to tmmodr
  store gdTd to dvpr,dgdtdr,dttnpstr,dndspstr
  vvz   = 1
  vur=gnVu
  vor=gnVo
  RETURN (NIL)
