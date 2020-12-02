********************************************************
func msk(p1,p2)
********************************************************
* p1 0 - снять ; 1-добавить
* p2 - признак dbo

alsdk_r=alias()

kkl_r=kkl
db_r=bs_d
kr_r=bs_k
mask_r=dokkmsk
ddk_r=ddk
skl_r=skl
sum_r=bs_s
sk_r=sk
rmsk_r=rmsk

if fieldpos('dokksk')#0
   dokksk_r=dokksk
else
   dokksk_r=0
endif

if fieldpos('nap')#0
   nap_r=nap
else
   nap_r=0
endif

dokkttn_r=dokkttn

if mn=0
   if mnp=0
      dokkttn_r=rn
   else
      dokkttn_r=dokkttn
   endif
else
   dokkttn_r=dokkttn
endif
kta_r=kta
ktas_r=ktas
mn_r=mn
rnd_r=rnd
rn_r=rn
vo_r=vo
kop_r=kop

dk_r=p1

if dk_r=0 // Снять
   sum_r=-sum_r
endif

if empty(p2)
   prdbo_r=0 // db
else
   prdbo_r=1 // dbo
endif

alsmsk_r=alias()
if !empty(alsmsk_r)
   rcmsk_r=recn()
endif

* BS
if select('bs')#0
   if prdbo_r=0
      if subs(mask_r,1,1)='1'
         sele bs
         if netseek('t1','db_r')
            netrepl('db','db+sum_r')
         endif
      endif
      if subs(mask_r,2,1)='1'
         sele bs
         if netseek('t1','kr_r')
            netrepl('kr','kr+sum_r')
         endif
      endif
   endif
endif

* DKKLN
if select('dkkln')#0
   if !(subs(mask_r,5,1)='1'.or.subs(mask_r,6,1)='1')
      if subs(mask_r,3,1)='1'
         dkadd('dkkln',kkl_r,db_r,0,0,sum_r,ddk_r,prdbo_r)
      endif
      if subs(mask_r,4,1)='1'
         dkadd('dkkln',kkl_r,kr_r,0,1,sum_r,ddk_r,prdbo_r)
      endif
   else   // В разрезе складов
      if subs(mask_r,5,1)='1'
         sele dkkln
         dkadd('dkkln',kkl_r,db_r,skl_r,0,sum_r,ddk_r,prdbo_r)
      endif
      if subs(mask_r,6,1)='1'
         dkadd('dkkln',kkl_r,kr_r,skl_r,1,sum_r,ddk_r,prdbo_r)
      endif
   endif
endif

* NNDS
sele (alsdk_r)
if p1=0
   nnds(0)
else
   nnds(1)
endif

*if int(db_r/1000)=361
*   dkadd('dkklns',kkl_r,db_r,ktas_r,0,sum_r,ddk_r,prdbo_r)
*   dkadd('dkklna',kkl_r,db_r,kta_r,0,sum_r,ddk_r,prdbo_r)
*endif
*if int(kr_r/1000)=361
*   dkadd('dkklns',kkl_r,kr_r,ktas_r,1,sum_r,ddk_r)
*   dkadd('dkklna',kkl_r,kr_r,kta_r,1,sum_r,ddk_r)
*endif

*#ifndef __CLIP__
if gnEnt=20
   if int(db_r/1000)=361.or.int(kr_r/1000)=361
      sele dknap
      if int(db_r/1000)=361
         if !netseek('t1','kkl_r,db_r,nap_r')
            netadd()
            netrepl('kkl,bs,skl','kkl_r,db_r,nap_r')
         endif
         if alsdk_r=='DOKK'
            netrepl('db','db+sum_r')
            if p1=1
               if ddk_r>ddb
                  netrepl('ddb','ddk_r')
               endif
            endif
         endif
         if alsdk_r=='DOKKO'
            netrepl('dbo','dbo+sum_r')
            if p1=1
               if ddk_r>ddbo
                  netrepl('ddbo','ddk_r')
               endif
            endif
         endif
      endif
      if int(kr_r/1000)=361
         if !netseek('t1','kkl_r,kr_r,nap_r')
            netadd()
            netrepl('kkl,bs,skl','kkl_r,kr_r,nap_r')
         endif
         if alsdk_r=='DOKK'
            netrepl('kr','kr+sum_r')
            if p1=1
               if ddk_r>dkr
                  netrepl('dkr','ddk_r')
               endif
            endif
         endif
      endif
   endif
endif
*#endif

if !empty(alsmsk_r)
   sele (alsmsk_r)
   go rcmsk_r
else
   sele 0
endif
retu .t.

***********************************
func dkadd(p1,p2,p3,p4,p5,p6,p7,p8)
***********************************
* Корррекция DKKLN,DKKLNA,DKKLNS
* p1 - алиас
* p2 - kkl
* p3 - bs
* p4 - skl
* p5 - 0-db;1-kr
* p5 - сумма (+/-)
* p7 - дата
* p8 - 0-db;1-dbo

alsdka_r=alias()
* ВРЕМЕННО
if alsdka_r=='DKKLNS'.or.alsdka_r=='DKKLNA'
   retu .t.
endif
if !empty(alsdka_r)
   rcdka_r=recn()
else
   rcdka_r=0
endif
als_rr=p1
kkl_rr=p2
bs_rr=p3
skl_rr=p4
dk_rr=p5
sum_rr=p6
ddk_rr=p7
if empty(p8)
   prdb_rr=0
else
   prdb_rr=1
endif

#ifdef __CLIP__
#else
#endif

sele (als_rr)
if als_rr=='dkkln'.or.int(bs_rr/1000)=361
   if !netseek('t1','kkl_rr,bs_rr,skl_rr')
      netadd()
      netrepl('kkl,bs,skl','kkl_rr,bs_rr,skl_rr')
   endif
   if dk_rr=0
      if prdb_rr=0
         netrepl('db','db+sum_rr')
         if ddk_rr>ddb
            netrepl('ddb','ddk_rr')
         endif
      else
         netrepl('dbo','dbo+sum_rr')
         if ddk_rr>ddbo
            netrepl('ddbo','ddk_rr')
         endif
      endif
   else
      netrepl('kr','kr+sum_rr')
      if ddk_rr>dkr
         netrepl('dkr','ddk_rr')
      endif
   endif
endif

if !empty(alsdka_r)
   sele (alsdka_r)
   go rcdka_r
else
   sele 0
endif
retu .t.

