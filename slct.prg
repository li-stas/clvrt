function slct_kl(k,l,m2)
local GetList:={},oclr

Private scr,ins,screen0,screen1,screen2,kod_p,mfo_p,rso_p,name_p,;
        m,klop,pstr,kkl_r,rcn,kl,ii,j,i,o1,x,o,bx,x1,s,tek,p,;
        pred,x2
h=1

stor 0 to scr,ins
stor ' ' to screen0,screen1,screen2
stor 0 to kod_p                      &&         Для поиска !!!
stor spac(9) to mfo_p
stor spac(20) to rso_p
stor spac(30) to name_p
oclr=setcolor('gr+/b')
save scre to screen0

sele kln
go top
m=0
Klop = 0
Pstr = Replicate(' ',30)
Kkl_r = 0
rcn=recn()
if .not.eof()
  set orde to tag t1
  kl=0
  do whil .t.
    If Kklr <> 0
      Seek Str(Kklr,7)
      Kklr = 0
      Kl = 0
    EndIf
    rest scre from screen0
    sele kln
    if kl#0
      goto rcn
      if kl=3
        ii=1
        do whil .t.
          skip
          if eof()
            go top
//            skip -(m+1)
            exit
          endi
          ii=ii+1
          if ii>m
            exit
          endi
        endd
      endi
      if kl=18
        skip -m
      endi
      if kl=13
        exit
      endi
      if kl#18.and.kl#3.and.kl#13
        skip -m
      endi
    endi
    j=1
    rcn=recn()
    do whil .t.
      if j>m2
        m=m2
        exit
      endi
      i=1
      o1=ltrim(str(j,2))
      a&o1=' '
      sele kln
      a&o1=a&o1+str(kkl,7)+'│'+nkl+'│'+kb1+'│'+ns1+' '
      skip
      if eof()
        m=j
        exit
      endi
      j=j+1
    endd
    x=1
    i=1
    o=k
    bx=len(a1)
    @ k-3,l-1,k-1,l+bx box ""
    @ k-1,l-1,m+k,l+bx box ""
    do while x<=m
      x1='a'+ltrim(str(x,2))
      @ o,l say &x1
      o=o+h
      x=x+1
    enddo
    @ k-3,l-1,k-1,l+bx box frame
    @ k-2,l say '   код  │   Наименование  предприятия  │      МФО      │ Р/счет             '
    o=k
    s=k
    tek=i
    p=k+(m-1)*h
    pred=m
    kl=0
    do while kl<>13
      if tek>m
        tek=i
        s=k
      endif
      if tek<i
        tek=m
        s=k+(m-1)*h
      endi
      x1='a'+ltrim(str(tek,2))
      x2='a'+ltrim(str(pred,2))
      set colo to g/n,n/g,,,
      @ 24,0 say ' строк вверх  строк вниз PgDn стр.вниз PgUp стр.вверх INS доп.функ. ─┘ выбор '
      set colo to gr+/b

      @ p,l say &x2
      set colo to gr+/br
      @ s,l say &x1
      set colo to gr+/b

      #ifdef INKEY_OLD
        kl=0
        do while kl=0
          kl=inkey()
        enddo
      #else
        kl:=inkey(0)
      #endif

      if kl=27
         kod=0
         exit
      endif

      if kl=13
         set filt to
         go top
      endif

      pred=tek

      if kl=13.or.kl=18.or.kl=3
        o=ltrim(str(tek,2))
        kod=val(substr(a&o,2,7))
        set colo to n/gr+
        @ s,l say a&o
        set colo to gr+/b
//        rest scre
        exit
      endi

      p=s
      if kl=24
        tek=tek+1
        s=s+h
      endi

      if kl=5
        tek=tek-1
        s=s-h
      endi

      if kl=22
        kkl_r = 0
        pstr=''
        do whil .t.
          set orde to tag t1
          ins = 1
          save scre to screen2
          @ 1,12,5,62 box ''
          @ 1,13,3,61 box frame
          @ 4,13 Say 'Строка для поиска ' + Pstr
          @ 1,38 say 'Выбор Режима:'
          @ 2,15 prom ' Поиск  '    //1
          @ 2,25 prom ' Повтор '    //2
          @ 2,35 prom ' Выбор  '    //3
          @ 2,45 prom ' Отказ  '    //4

          menu to ins
          if ins = 0
            set filt to
            go top
            exit
          endi

          if ins=1
            Set Cursor On
            Pstr = Replicate(' ',30)
            SELECT kln
            Go Top
            @ 4,13 Say Replicate(' ',40)
            @ 4,13 Say 'Строка для поиска' Get Pstr Picture 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
            Read
            Pstr = Alltrim(Pstr)
            If Len(Pstr) = 0
              @ 4,12,4,76 box ''
              @ 4,15 say '         Не задан критерий поиска !'
              inkey(1.5)
              @ 4,12,4,76 box ''
              loop
            EndIf
            Ins = 2
            Klop = -1
          EndIf

          If Ins = 2
            If Klop <> - 1
              Loop
            EndIf
            SELECT kln
            @ 4,13 Say 'Строка для поиска ' + Pstr
            Kod_p = 0
            teni(10,29,12,54)
            set color to gr+/r
            @ 10,29,12,54 box frame
            @ 11,30 Say 'Ждите. Выполняется поиск'
            set color to gr+/b
*            pstr=upper(pstr)
            Set Filter To At(Pstr,Alltrim(NKL+KB1+NS1))<>0
            locate for At(Pstr,Alltrim(NKL+KB1+NS1))<>0
            if FOUND()
               rcn=recn()
               kklr=kkl
            else
               go top
               rcn=recn()
            endif
            Go Top
            Exit
            If Kod_p = 0
              Go Top
              Loop
            EndIf
            seek str(kod_p,7)
            kl=0
            exit
          endi

          if ins = 3
            o=ltrim(str(tek,2))
            kklr=val(substr(a&o,2,7))
            kkl_r = Kklr
            seek str(kklr,7)
            Kl = 22
            Ins = 4
            exit
          endi

          if ins = 4
            set filt to
            go top
            Kod = 0
            exit
          endi

        EndDo
        kod=kkl_r
        rest scre from screen2
        EXIT
      endi
    enddo
    if kl = 22 .and. ins=4.or.kl=27.and.kod=0
      set filt to
      go top
      exit
    endi
  endd
endi
oclr=SETCOLOr(oclr)
rest scre from screen0
set orde to tag t1
retu kod

