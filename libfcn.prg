/***********************************************************
 * Модуль    : termo.prg
 * Версия    : 0.0
 * Автор     :
 * Изменен   :
 */
#include "Common.ch"

/***********************************************************
 * qq() -->
 *   Параметры :
 *   Возвращает:

FUNCTION qq

  Vsego:=2000
  FOR i:=1 TO Vsego
    Termo(i,Vsego)
  NEXT

  RETURN (NIL)
*/

/***********************************************************
 * Termo() -->
 *   Дата      : 03/10/94
 *   Параметры :
 *   Возвращает:
                Тек  Всего         Цвет Фона   Цвет Термо   Цвет %    выдача звука*/
function Termo(i, Vsego, y1, x1, nClrFon, nClrTerm, nClrPerc, xSound)
  static lOpen, Y_term, X_term, nColorFon, nColorTerm, nColorPerc, ;
   lBlink, Pr1, Pos1, OldFont, SaveScreen
  local Pr :=Int(i * 100 / Vsego), mm :=Int((i * 37 * 8 / Vsego))
  local Pos:=Int(mm / 8)
  local Kus:=mm - Pos * 8, cMusic:=""

  if (ISNIL(lOpen))
    lOpen:=TRUE; Pr1:=0; Pos1:=0
  endif

#ifdef __CLIP__

#else                       //clip53
  //#define __CLIP53FULL__
  #define __CLIP53_WIN__
#endif

#ifdef __CLIP53_FULL__
    if (lOpen)
      if (i > Vsego)
        return (TRUE)
      endif

      DEFAULT y1 to 12, x1 to 20
      DEFAULT nClrFon to 136
      DEFAULT nClrTerm to 143
      DEFAULT nClrPerc to 159//27

      nColorFon :=nClrFon
      nColorTerm:=nClrTerm
      nColorPerc:=nClrPerc
      Y_term:=y1
      X_term:=x1

      SaveScreen:=SaVeScreen(Y_term, X_term, Y_term, X_term+40)

      lBlink:=SETBLINK(.F.)

  #ifdef __CLIP53_FULL__
        OldFont:=GetFont(1)
        SetFont(PosRepl(OldFont,                            ;
                          Replicate(Chr(128), CharPix())+ ;
                          Replicate(Chr(192), CharPix())+ ;
                          Replicate(Chr(224), CharPix())+ ;
                          Replicate(Chr(240), CharPix())+ ;
                          Replicate(Chr(248), CharPix())+ ;
                          Replicate(Chr(252), CharPix())+ ;
                          Replicate(Chr(254), CharPix()), ;
                          1*CharPix()+1                       ;
                      ), 1                                  ;
             )
  #endif

      SCreenMix(Replicate("█", 37)+"  0%",                      ;
                 Replicate(Chr(nColorFon), 37)+                ;
                 Replicate(Chr(nColorPerc), 4), Y_term, X_term ;
             )
      lOpen:=FALSE
    endif

    if (Pr1 # Pr)
      ScreenMix(Str(Pr, 3, 0), Chr(nColorPerc)+                    ;
                 Chr(nColorPerc)+Chr(nColorPerc), Y_term, X_term+37 ;
             )
      Pr1:=Pr
    endif

    if (Pos > Pos1)
      RestScreen(Y_term, X_term, Y_term, X_term-1+Pos,   ;
                  Replicate("█"+Chr(nColorTerm), Pos) ;
              )
      Pos1:=Pos
    endif

    if (Kus > 0)
      Restscreen(Y_term, X_term+Pos, Y_term, X_term+Pos, ;
                  Chr(Kus)+Chr(nColorTerm)            ;
              )
    endif

    if (Vsego - i = 0)
      Pr1:=0; Pos1:=0
      lOpen:=TRUE
  /*
  IF xSound # NIL
    MYTONE( 10, 1)
    MYTONE(130, 16, 1)
    MYTONE(164, 16, 1)
    MYTONE(196, 16, 1)
  ENDIF
  */
  #ifdef __CLIP53_FULL__
        SetFont (OldFont, 1)
        SetBlink(lBlink)
        RestScreen (Y_term, X_term, Y_term, X_term+40, SaveScreen)
  #endif
    endif

#else
    /*
    IF i > Vsego
      RETURN (TRUE)
    ENDIF
    DEFAULT y1 TO 12, x1 TO 20
    @ y1, x1 SAY PADL(allt(STR(i/Vsego*100,0)),3,"0") COLOR "+GR/+W"
    */
    if (lOpen)
      if (i > Vsego)
        return (TRUE)
      endif

      DEFAULT y1 to 12, x1 to 20
      DEFAULT nClrFon to 136
      DEFAULT nClrTerm to 143
      DEFAULT nClrPerc to 159//27

      nColorFon :=nClrFon
      nColorTerm:=nClrTerm
      nColorPerc:=nClrPerc
      Y_term:=y1
      X_term:=x1

      SaveScreen:=SaVeScreen(Y_term, X_term, Y_term, X_term+40)

      lBlink:=SETBLINK(.F.)

  #ifdef _CLIP53_FULL__
        OldFont:=GetFont(1)
        SetFont(PosRepl(OldFont,                            ;
                          Replicate(Chr(128), CharPix())+ ;
                          Replicate(Chr(192), CharPix())+ ;
                          Replicate(Chr(224), CharPix())+ ;
                          Replicate(Chr(240), CharPix())+ ;
                          Replicate(Chr(248), CharPix())+ ;
                          Replicate(Chr(252), CharPix())+ ;
                          Replicate(Chr(254), CharPix()), ;
                          1*CharPix()+1                       ;
                      ), 1                                  ;
             )
  #endif

      SCreenMix(Replicate("█", 37)+"  0%",                      ;
                 Replicate(Chr(nColorFon), 37)+                ;
                 Replicate(Chr(nColorPerc), 4), Y_term, X_term ;
             )
      lOpen:=FALSE
    endif

    do case
    case (Kus=0)
      Kus:=ASC(" ")
    case (Kus=1)
      Kus:=ASC("·")       //ASC(" ")
    case (Kus=2)
      Kus:=ASC(":")       //ASC("·")
    case (Kus=3)
      Kus:=ASC("|")       //ASC("∙")
    case (Kus=4)
      Kus:=ASC("│")       //ASC(":")
    case (Kus=5)
      Kus:=ASC("║")       //ASC("|")
    case (Kus=6)
      Kus:=ASC("▒")       //ASC("║")
    case (Kus=7)
      Kus:=ASC("▓")
    /*
    CASE Kus=5
    Kus:=ASC("░")//ASC("│")
    */
    endcase

    if (Pr1 # Pr)
      ScreenMix(Str(Pr, 3, 0), Chr(nColorPerc)+                    ;
                 Chr(nColorPerc)+Chr(nColorPerc), Y_term, X_term+37 ;
             )
      Pr1:=Pr
    endif

    if (Pos > Pos1)
      RestScreen(Y_term, X_term, Y_term, X_term-1+Pos,   ;
                  Replicate("█"+Chr(nColorTerm), Pos) ;
              )
      Pos1:=Pos
    endif

    if (Kus > 0 .AND. Vsego - i # 0)
      Restscreen(Y_term, X_term+Pos, Y_term, X_term+Pos, ;
                  Chr(Kus)+Chr(nColorTerm)            ;
              )
    endif

    if (Vsego - i = 0)
      Pr1:=0; Pos1:=0
      lOpen:=TRUE

      if (xSound # nil)
        MYTONE(10, 1)
        MYTONE(130, 16, 1)
        MYTONE(164, 16, 1)
        MYTONE(196, 16, 1)
      endif

  #ifdef _CLIP53_FULL__
        SetFont (OldFont, 1)
        SetBlink(lBlink)
        RestScreen (Y_term, X_term, Y_term, X_term+40, SaveScreen)
  #endif
    endif

#endif
  return (TRUE)

/***********************************************************
 * NOTA() -->
 *   Параметры :
 *   Возвращает:
 */
function NOTA(P1)
  local oclr
  if (NETERR())
    @ MAXROW()-1, 0 clea
    oclr=SETCOLOR("rg+/n,,,,")
    @ MAXROW()-1, 5 say P1
    INKEY(10)
    oclr=SETCOLOR(oclr)
    @ MAXROW()-1, 0 clea
    nuse()
    return (.F.)
  endif

  return (.T.)

/***********************************************************
 * SHADBOX() -->
 *   Параметры :
 *   Возвращает:
 */
function SHADBOX(P1, P2, P3, P4, P5, P6)
  L7=SETCOLOR()
  P6=if(P6 == nil, SETCOLOR(), P6)
  SETCOLOR("N/N")
  SCROLL(P1 + 1, P2 + 2, P3 + 1, P4 + 2)
  SETPOS(P1 + 1, P2 + 2)
  SETCOLOR(P6)
  DISPBOX(P1, P2, P3, P4, P5)
  SETCOLOR(L7)
  return (nil)

/***********************************************************
 * ach
 *   Параметры:
 */
procedure ach
  local oclr
  MENU_MAX=LEN((&("MENUD&D"))[ 1 ])
  T=POZICION + 6
  L=CL_L[ I ] - 1
  B=POZICION + SD + 6
  R=CL_L[ I ] + MENU_MAX
  TENI(T, L, B, R)
  oclr=SETCOLOR("gr+/w,w+/n,,,")
  DISPBOX(POZICION + 5, CL_L[ I ] - 1, POZICION + SD + 6, ;
           CL_L[ I ] + MENU_MAX, ""                        ;
       )
  DISPBOX(POZICION + 5, CL_L[ I ] - 1, POZICION + SD + 6, ;
           CL_L[ I ] + MENU_MAX, "╔═╗║╝═╚║"                ;
       )
  POZ=ACHOICE(POZICION + 6, CL_L[ I ], POZICION + SD + 5,  ;
               CL_L[ I ] + MENU_MAX - 1, (&("MENUD&D")) ;
           )
  oclr=SETCOLOR(oclr)

  return

/***********************************************************
 * TENI() -->
 *   Параметры :
 *   Возвращает:
 */
function TENI()
  PARAMETER T, L, B, R
  local l5
  L5=SAVESCREEN(T + 1, L + 2, B + 1, R + 2)
  if (LEN(L5) > 2048)
    L5=TRANSFORM(SUBSTR(L5, 1, 2048), REPLICATE("x"+CHR(8), 1024)) +          ;
     TRANSFORM(SUBSTR(L5, 2049), REPLICATE("x"+CHR(8), (len(l5)-2048)/2))
  else
    L5=TRANSFORM(L5, REPLICATE("x"+CHR(8), LEN(L5) / 2))
  endif

  RESTSCREEN(T + 1, L + 2, B + 1, R + 2, L5)
  return (.T.)

/***********************************************************
 * kzero() -->
 *   Параметры :
 *   Возвращает:
 */
function kzero(p1)
  local aa
  aa=str(p1, 12, 6)
  for i=12 to 6 step -1
    if (subs(aa, i, 1)='0')
      aa=stuff(aa, i, 1, ' ')
    else
      if (subs(aa, i, 1)='.')
        aa=stuff(aa, i, 1, ' ')
      endif

      exit
    endif

  endfor

  aa=allt(aa)
  return (aa)

/***********************************************************
 * s126() -->
 *   Параметры :
 *   Возвращает:
 */
function s126(p1)
  local aa
  aa=str(p1, 12, 6)
  for i=12 to 6 step -1
    if (subs(aa, i, 1)='0')
      aa=stuff(aa, i, 1, ' ')
    else
      if (subs(aa, i, 1)='.')
        aa=stuff(aa, i, 1, ' ')
      endif

      exit
    endif

  next

  aa=ltrim(aa)
  aa=rtrim(aa)
  aa=space(12-len(aa))+aa
  return (aa)

/***********************************************************
 * szero() -->
 *   Параметры :
 *   Возвращает:
 */
function szero(p1)
  local aa
  aa=str(p1, 15, 2)
  aa=ltrim(aa)
  return (aa)

/***********************************************************
 * s25() -->
 *   Параметры :
 *   Возвращает:
 */
function s25(p1)
  local aa
  aa=rtrim(p1)
  aa=space(25-len(aa))+aa
  return (aa)

/***********************************************************
 * s30() -->
 *   Параметры :
 *   Возвращает:
 */
function s30(p1)
  local aa
  aa=rtrim(p1)
  aa=space(30-len(aa))+aa
  return (aa)

/***********************************************************
 * czero() -->
 *   Параметры :
 *   Возвращает:
 */
function czero(p1)
  local aa
  aa=ltrim(p1)
  aa=rtrim(aa)
  return (aa)

/***********************************************************
 * kmes() -->
 *   Параметры :
 *   Возвращает:
 */
function kmes(P1)
  local kdmr
  do case
  case (month(p1)=1)
    kdmr=stuff(dtoc(P1), 1, 2, '31')
  case (month(P1)=2)
    if (mod(year(P1), 4)#0)
      kdmr=stuff(dtoc(P1), 1, 2, '28')
    else
      kdmr=stuff(dtoc(P1), 1, 2, '29')
    endif

  case (month(P1)=3)
    kdmr=stuff(dtoc(P1), 1, 2, '31')
  case (month(P1)=4)
    kdmr=stuff(dtoc(P1), 1, 2, '30')
  case (month(P1)=5)
    kdmr=stuff(dtoc(P1), 1, 2, '31')
  case (month(P1)=6)
    kdmr=stuff(dtoc(P1), 1, 2, '30')
  case (month(P1)=7)
    kdmr=stuff(dtoc(P1), 1, 2, '31')
  case (month(P1)=8)
    kdmr=stuff(dtoc(P1), 1, 2, '31')
  case (month(P1)=9)
    kdmr=stuff(dtoc(P1), 1, 2, '30')
  case (month(P1)=10)
    kdmr=stuff(dtoc(P1), 1, 2, '31')
  case (month(P1)=11)
    kdmr=stuff(dtoc(P1), 1, 2, '30')
  case (month(P1)=12)
    kdmr=stuff(dtoc(P1), 1, 2, '31')
  endcase

  return (ctod(kdmr))

/************************************************************** */
function mess(messrr, dl)
  local n:=4, oclr, dlr, wslc, scmess
  If !('...' $ messrr)
  outlog(3,__FILE__, __LINE__, messrr, ""                      ;
          +PROCNAME(5-n)+"("+STR(PROCLINE(5-n), 5)+");" ;
          +PROCNAME(6-n)+"("+STR(PROCLINE(6-n), 5)+");" ;
          +PROCNAME(7-n)+"("+STR(PROCLINE(7-n), 5)+");" ;
      )
  endif
  if (gnScOut=1)
    return (.t.)
  endif

  wslc=wselect(0)
  dlr=dl
  n=len(messrr)
  set curs off
  oclr=setcolor('w+/rb+')
  teni(1, 76-n, 3, 78)
  @ 1, 76-n, 3, 78 box frame+space(1)
  @ 2, 77-n say messrr
  if (dlr#nil)
    inkey(dlr)
  endif

  oclr=setcolor(oclr)
  set curs on
  wselect(wslc)
  return (.t.)

/************************************************************** */
function wmess(messr, p2)
  local n:=4, oclr, dlr, wsl
  If !('...' $ messr)
    outlog(3, __FILE__, __LINE__, messr, ""                       ;
            +PROCNAME(5-n)+"("+STR(PROCLINE(5-n), 5)+");" ;
            +PROCNAME(6-n)+"("+STR(PROCLINE(6-n), 5)+");" ;
            +PROCNAME(7-n)+"("+STR(PROCLINE(7-n), 5)+");" ;
        )
  EndIf
  if (gnScOut=1)
    return (.t.)
  endif

  if (p2=nil)
    tdr=3
  else
    tdr=p2
  endif

  n=len(messr)
  set curs off
  oclr=setcolor('w+/rb+')
  wsl=wselect()
  wmessr=wopen(1, 76-n, 3, 78)
  wbox(1)
  @ 0, 1 say messr
  keyboard ''
  inkey(tdr)
  wclose(wmessr)
  oclr=setcolor(oclr)
  set curs on
  wselect(wsl)
  return (.t.)

/********************************************************************** */
function dtous(ddd, p1, p2, p3)// Дата в укр.строку
  if (empty(ddd))
    return (' ')
  endif

  // p1 к-во пробелов между числом и месяцем
  // p2 к-во пробелов между месяцем и годом
  // p3 1 - только последняя цифра года
  private dd, mm, yy, rrr
  dd=str(day(ddd), 2)
  mm=month(ddd)
  do case
  case (mm=1)
    mm='  сiчня  '
  case (mm=2)
    mm=' лютого  '
  case (mm=3)
    mm=' березня '
  case (mm=4)
    mm=' квiтня  '
  case (mm=5)
    mm=' травня  '
  case (mm=6)
    mm=' червня  '
  case (mm=7)
    mm=' липня   '
  case (mm=8)
    mm=' серпня  '
  case (mm=9)
    mm=' вересня '
  case (mm=10)
    mm=' жовтня  '
  case (mm=11)
    mm='листопада'
  case (mm=12)
    mm=' грудня  '
  endcase

  rrr=dd
  if (p1#nil)
    rrr=rrr+space(p1)+mm
    if (p3=nil)
      rrr=rrr+space(p2)+str(year(ddd), 4)
    else
      rrr=rrr+space(p2)+subs(str(year(ddd), 4), 3, 1)
    endif

  else
    rrr=rrr+' '+mm+' '+str(year(ddd), 4)+'р.'
  endif

  return (rrr)

/******************************************************************** */
function umonth(p1, p2)   // Украинские месяцы
  local cmonth
  dt=p1
  do case
  case (month(dt)=1)
    if (empty(p2))
      cmonth='Сiчень'
    else
      cmonth='ciчня'
    endif

  case (month(dt)=2)
    if (empty(p2))
      cmonth='Лютий'
    else
      cmonth='лютого'
    endif

  case (month(dt)=3)
    if (empty(p2))
      cmonth='Березень'
    else
      cmonth='березня'
    endif

  case (month(dt)=4)
    if (empty(p2))
      cmonth='Квiтень'
    else
      cmonth='квiтня'
    endif

  case (month(dt)=5)
    if (empty(p2))
      cmonth='Травень'
    else
      cmonth='травня'
    endif

  case (month(dt)=6)
    if (empty(p2))
      cmonth='Червень'
    else
      cmonth='червня'
    endif

  case (month(dt)=7)
    if (empty(p2))
      cmonth='Липень'
    else
      cmonth='липня'
    endif

  case (month(dt)=8)
    if (empty(p2))
      cmonth='Серпень'
    else
      cmonth='серпня'
    endif

  case (month(dt)=9)
    if (empty(p2))
      cmonth='Вересень'
    else
      cmonth='вересня'
    endif

  case (month(dt)=10)
    if (empty(p2))
      cmonth='Жовтень'
    else
      cmonth='жовтня'
    endif

  case (month(dt)=11)
    if (empty(p2))
      cmonth='Листопад'
    else
      cmonth='листопада'
    endif

  case (month(dt)=12)
    if (empty(p2))
      cmonth='Грудень'
    else
      cmonth='грудня'
    endif

  endcase

  return (cmonth)

/*********************************************************************** */
function umg                // Украинский месяц,год
  para dt
  do case
  case (month(dt)=1)
    return ('Сiчень '+str(year(dt), 4))
  case (month(dt)=2)
    return ('Лютий '+str(year(dt), 4))
  case (month(dt)=3)
    return ('Березень '+str(year(dt), 4))
  case (month(dt)=4)
    return ('Квiтень '+str(year(dt), 4))
  case (month(dt)=5)
    return ('Травень '+str(year(dt), 4))
  case (month(dt)=6)
    return ('Червень '+str(year(dt), 4))
  case (month(dt)=7)
    return ('Липень '+str(year(dt), 4))
  case (month(dt)=8)
    return ('Серпень '+str(year(dt), 4))
  case (month(dt)=9)
    return ('Вересень '+str(year(dt), 4))
  case (month(dt)=10)
    return ('Жовтень '+str(year(dt), 4))
  case (month(dt)=11)
    return ('Листопад '+str(year(dt), 4))
  case (month(dt)=12)
    return ('Грудень '+str(year(dt), 4))
  endcase

RETURN (NIL)

/******************************************************************* */
function uday               // День недели украинский
  para dt
  do case
  case (dow(dt)=1)
    return ('Недiля')
  case (dow(dt)=2)
    return ('Понедiлок')
  case (dow(dt)=3)
    return ('Вiвторок')
  case (dow(dt)=4)
    return ('Середа')
  case (dow(dt)=5)
    return ('Четвер')
  case (dow(dt)=6)
    return ("П'ятниця")
  case (dow(dt)=7)
    return ('Субота')
  endcase

RETURN (NIL)

/*********************************************************************** */
function foot(p1, p2, p3)
  local i, afoot[ 11, 2 ], xxx, n, cl_r
  store '' to p1r, p2r
  p1r=p1
  p2r=p2

  if (empty(p3))
    @ MAXROW(), 0 say space(80) color 'n/w'
  else
    @ p3, 1 say space(80) color 'n/w'
  endif

  xxx=''
  n=1
  for i=1 to len(p1r)
    if (subs(p1r, i, 1)#',')
      xxx=xxx+subs(p1r, i, 1)
    else
      afoot[ n, 1 ]=xxx
      n++
      xxx=''
      loop
    endif

  next

  afoot[ n, 1 ]=xxx

  xxx=''
  n=1
  for i=1 to len(p2r)
    if (subs(p2r, i, 1)#',')
      xxx=xxx+subs(p2r, i, 1)
    else
      afoot[ n, 2 ]=xxx
      n++
      xxx=''
      loop
    endif

  next

  afoot[ n, 2 ]=xxx

  xxx=''
  if (empty(p3))
    @ MAXROW(), 1
  else
    @ p3, 2
  endif

  for i=1 to 10
    if (afoot[ i, 1 ]=nil)
      exit
    endif

    @ MAXROW(), col() say afoot[ i, 1 ] color 'r/w'
    @ MAXROW(), col() say '-'+afoot[ i, 2 ]+';' color 'n/w'
  next

  if (empty(p3))
    @ MAXROW(), col()-1 say ' ' color 'n/w'
    @ MAXROW(), col() say space(maxcol()-col()+1) colo 'n/w'
  else
    @ p3, col()-1 say ' ' color 'n/w'
    @ p3, col() say space(maxcol()-col()+1) colo 'n/w'
  endif

RETURN (NIL)

/*********************************************************************** */
function foota(p1, p2, p3)
  local i, afoot[ 11, 2 ], xxx, n, cl_r
  store '' to p1r, p2r
  p1r=p1
  p2r=p2

  if (empty(p3))
    @ MAXROW(), 0 say space(80) color 'n/w'
  else
    @ p3, 1 say space(80) color 'n/w'
  endif

  xxx=''
  n=1
  for i=1 to len(p1r)
    if (subs(p1r, i, 1)#',')
      xxx=xxx+subs(p1r, i, 1)
    else
      afoot[ n, 1 ]=xxx
      n++
      xxx=''
      loop
    endif

  next

  afoot[ n, 1 ]=xxx

  xxx=''
  n=1
  for i=1 to len(p2r)
    if (subs(p2r, i, 1)#',')
      xxx=xxx+subs(p2r, i, 1)
    else
      afoot[ n, 2 ]=xxx
      n++
      xxx=''
      loop
    endif

  next

  afoot[ n, 2 ]=xxx

  xxx=''
  if (empty(p3))
    @ MAXROW(), 1
  else
    @ p3, 2
  endif

  @ MAXROW(), col() say 'ALT+ ' color 'r/w'
  for i=1 to 10
    if (afoot[ i, 1 ]=nil)
      exit
    endif

    @ MAXROW(), col() say afoot[ i, 1 ] color 'b/w'
    @ MAXROW(), col() say '-'+afoot[ i, 2 ]+';' color 'n/w'
  next

  if (empty(p3))
    @ MAXROW(), col()-1 say ' ' color 'n/w'
    @ MAXROW(), col() say space(maxcol()-col()+1) colo 'n/w'
  else
    @ p3, col()-1 say ' ' color 'n/w'
    @ p3, col() say space(maxcol()-col()+1) colo 'n/w'
  endif

RETURN (NIL)

/*********************************************************************** */
function mmenu(p1)
  local i, afoot[ 10, 1 ], xxx, n, cl_r, aaa
  clmmenu=setcolor('n/w,n/bg')
  store '' to p1r
  aaa=1
  p1r=p1

  @ MAXROW(), 0 say space(80) color 'n/w'

  xxx=''
  n=1
  for i=1 to len(p1r)
    if (subs(p1r, i, 1)#',')
      xxx=xxx+subs(p1r, i, 1)
    else
      afoot[ n, 1 ]=xxx
      n++
      xxx=''
      loop
    endif

  next

  afoot[ n, 1 ]=xxx

  xxx=''
  @ MAXROW(), 1
  for i=1 to 11
    if (afoot[ i, 1 ]=nil)
      exit
    endif

    @ MAXROW(), col()+1 prom afoot[ i, 1 ]
  next

  @ MAXROW(), col() say space(maxcol()-col()+1) colo 'n/w'
  menu to aaa
  setcolor(clmmenu)
  return (aaa)
  /************************************************************** */

procedure cript
  // Шифрование - значение символа сдвигается на 3 вправо
  para aa
  private ii
  bb=''
  for ii=1 to len(trim(aa))
    bb=bb+chr(asc(subs(trim(aa), ii, 1))+3)
  next

  return (bb)

/***********************************************************
 * uncript
 *   Параметры:
 */
procedure uncript
  para aa
  private ii
  bb=''
  for ii=1 to len(trim(aa))
    bb=bb+chr(asc(subs(trim(aa), ii, 1))-3)
  next

  return (bb)

/*************************************************************************** */
function BEEPER()           //Музычка
  Tone(400, 2)
  Tone(322, 2)
  Tone(400, 2)
  Tone(322, 2)
  Tone(420, 2)
  Tone(400, 2)
  Tone(360, 2)
  return

/***************************************************************************
 *Перевод числа в украинскую строку для денег
 */
function numstr(numr, p2)
  private cr, dr, lcr, ldr, t[ 42, 3 ], adr[ 10, 2 ]
  t[ 1, 1 ]='одна '
  t[ 1, 2 ]='один '
  t[ 2, 1 ]='двi '
  t[ 2, 2 ]='два '
  t[ 3, 1 ]='три '
  t[ 4, 1 ]='чотири '
  t[ 5, 1 ]="п'ять "
  t[ 6, 1 ]='шiсть '
  t[ 7, 1 ]='сiм '
  t[ 8, 1 ]='вiсiм '
  t[ 9, 1 ]="дев'ять "
  t[ 10, 1 ]='десять '
  t[ 11, 1 ]= 'одинадцать '
  t[ 12, 1 ]='двaнадцять '
  t[ 13, 1 ]='тринадцять '
  t[ 14, 1 ]= 'чотирнадцять '
  t[ 15, 1 ]="п'ятнадцять "
  t[ 16, 1 ]='шiстнадцять '
  t[ 17, 1 ]='сiмнадцять '
  t[ 18, 1 ]='вiсiмнадцять '
  t[ 19, 1 ]="дев'ятнадцять "
  t[ 20, 1 ]='двадцять '
  t[ 21, 1 ]='тридцять '
  t[ 22, 1 ]='сорок '
  t[ 23, 1 ]="п'ятьдесят "
  t[ 24, 1 ]='шiстьдесят '
  t[ 25, 1 ]='сiмьдесят '
  t[ 26, 1 ]='вiсiмдесят '
  t[ 27, 1 ]="дев'яносто "
  t[ 28, 1 ]='сто '
  t[ 29, 1 ]='двiстi '
  t[ 30, 1 ]='триста '
  t[ 31, 1 ]='чотириста '
  t[ 32, 1 ]="п'ятсот "
  t[ 33, 1 ]='шiстсот '
  t[ 34, 1 ]='сiмсот '
  t[ 35, 1 ]='вiсiмсот '
  t[ 36, 1 ]="дев'ятсот "
  t[ 37, 1 ]="гривня "
  t[ 37, 2 ]="гривнi "
  t[ 37, 3 ]="гривень "
  t[ 38, 1 ]="копiйка "
  t[ 38, 2 ]="копiйки "
  t[ 38, 3 ]="копiйок "
  t[ 39, 1 ]="тисяча "
  t[ 39, 2 ]="тисячi "
  t[ 39, 3 ]="тисяч "
  t[ 40, 1 ]="мiльон "
  t[ 40, 2 ]="мiльони "
  t[ 40, 3 ]="мiльонiв "
  t[ 41, 1 ]="мiльярд "
  t[ 41, 2 ]="мiльярда "
  t[ 41, 3 ]="мiльярдiв "
  t[ 42, 1 ]="трiльон "
  t[ 42, 2 ]="трiльона "
  t[ 42, 3 ]="трiльонiв "

  cr=int(numr)
  //dr=ceiling((numr-cr)*100)
  if (empty(p2))
    dr=ROUND((numr-cr)*100, 0)
  else
    dr=ROUND((numr-cr)*1000, 0)
  endif

  lcr=numlen(cr)          // к-во цифр целой части
  if (lcr#0)
    slcr=str(cr, lcr)     // симв целая часть
  endif

  ldr=numlen(dr)          // к-во цифр дес части
  if (ldr#0)
    sldr=str(dr, ldr)     // симв дес часть
  endif

  if (lcr#0)
    k=lcr/3
    if (mod(lcr, 3)#0)
      k=int(k)+1
    endif

    for i=1 to k
      adr[ i, 1 ]=right(slcr, 3)
      slcr=subs(slcr, 1, iif(lcr-3>0, lcr-3, 3-lcr))
      lcr=lcr-3
    next

    do strn

    aa=''
    for i=k to 1 step -1
      aa=aa+adr[ i, 2 ]
    next

    ggg=aa
  else
    ggg='нуль '             // гривень
  endif

  if (empty(p2))
    ggg=stuff(ggg, 1, 1, upper(subs(ggg, 1, 1)))+' грн'
  else
    ggg=stuff(ggg, 1, 1, upper(subs(ggg, 1, 1)))
  endif

  if (empty(p2))
    if (ldr#0)
      //   dime adr(10,2)
      private adr[ 10, 2 ]
      k=ldr/3
      k=int(k)+1
      for i=1 to k
        adr[ i, 1 ]=right(sldr, 3)
        slcr=subs(sldr, 1, iif(ldr-3>0, ldr-3, 3-ldr))
        ldr=ldr-3
      next

      do strn

      bb=''
      for i=k to 1 step -1
        bb=bb+adr[ i, 2 ]
      next

      do case
      case (val(right(adr[ 1, 1 ], 1))=1)
        if (val(right(adr[ 1, 1 ], 2))#11)
          bb=bb+t[ 38, 1 ]
        else
          bb=bb+t[ 38, 3 ]
        endif

      case (val(right(adr[ 1, 1 ], 1))>=2.and.val(right(adr[ 1, 1 ], 1))<5)
        if (subs(right(adr[ 1, 1 ], 2), 1, 1)='1')
          bb=bb+t[ 38, 3 ]
        else
          bb=bb+t[ 38, 2 ]
        endif

      otherwise
        bb=bb+t[ 38, 3 ]
      endcase

    else
      bb='нуль копiйок'
    endif

  else
    bb=''
  endif

  aa=ggg+' '+bb
  return (aa)

/********************************************************************* */
function numlen
  para aa
  do case
  case (aa=0)
    return (0)
  case (aa>0.and.aa<10)
    return (1)
  case (aa>=10.and.aa<100)
    return (2)
  case (aa>=100.and.aa<1000)
    return (3)
  case (aa>=1000.and.aa<10000)
    return (4)
  case (aa>=10000.and.aa<100000)
    return (5)
  case (aa>=100000.and.aa<1000000)
    return (6)
  case (aa>=1000000.and.aa<10000000)
    return (7)
  case (aa>=10000000.and.aa<100000000)
    return (8)
  case (aa>=100000000.and.aa<1000000000)
    return (9)
  case (aa>=1000000000.and.aa<10000000000)
    return (10)
  case (aa>=10000000000.and.aa<100000000000)
    return (11)
  case (aa>=100000000000.and.aa<1000000000000)
    return (12)
  case (aa>=1000000000000.and.aa<10000000000000)
    return (13)
  endcase

RETURN (NIL)

/***************************************************************************** */
procedure num100
  para zz, yy
  if (val(zz)<21)
    if (right(zz, 1)='1'.or.right(zz, 1)='2')
      do case
      case (yy=1)
        kk_r=1
      case (yy=2)         // тыс.
        kk_r=1
      case (yy=3)         // млн.
        kk_r=2
      case (yy=4)         // млрд.
        kk_r=2
      case (yy=5)         // трлн.
        kk_r=2
      endcase

    else
      kk_r=1
    endif

    if (zz#'00')
      adr[ yy, 2 ]=t[ val(zz), kk_r ]
    else
      adr[ yy, 2 ]=''
    endif

  else
    dec=val(subs(zz, 1, 1))
    ed=val(subs(zz, 2, 1))
    if (ed=1.or.ed=2)
      do case
      case (yy=1)
        kk_r=1
      case (yy=2)         // тыс.
        kk_r=1
      case (yy=3)         // млн.
        kk_r=2
      case (yy=4)         // млрд.
        kk_r=2
      case (yy=5)         // трлн.
        kk_r=2
      endcase

    else
      kk_r=1
    endif

    adr[ yy, 2 ]=iif(dec#0, t[ 18+dec, kk_r ], '')+iif(ed#0, t[ ed, kk_r ], '')
  endif

RETURN

/***************************************************************************** */
procedure strn
  for i=1 to k
    aa=adr[ i, 1 ]
    laa=len(aa)
    if (laa=3)
      cc=val(subs(aa, 1, 1))
      do num100 with subs(aa, 2, 2), i
      if (subs(aa, 1, 1)#'0')
        adr[ i, 2 ]=t[ 27+cc, 1 ]+adr[ i, 2 ]
      endif

    else
      do num100 with aa, i
    endif

  next

  for i=1 to k
    aa=adr[ i, 1 ]
    do case
    case (i=2)
      l=39
    case (i=3)
      l=40
    case (i=4)
      l=41
    case (i=5)
      l=42
    endcase

    if (i#1)
      do case
      case (val(right(aa, 1))=1)
        if (val(aa)=1)
          adr[ i, 2 ]=adr[ i, 2 ]+t[ l, 1 ]
        else
          adr[ i, 2 ]=adr[ i, 2 ]+t[ l, 3 ]
        endif

      case (val(right(aa, 1))>=2.and.val(right(aa, 1))<5)
        adr[ i, 2 ]=adr[ i, 2 ]+t[ l, 2 ]
      otherwise
        adr[ i, 2 ]=adr[ i, 2 ]+t[ l, 3 ]
      endcase

    endif

  next

  /*************************************************************************** */

RETURN

function nwopen(p1, p2, p3, p4, p5, p6)
  if (p6#nil)
    setcolor(p6)
  endif

  nn=wopen(p1, p2, p3, p4)
  if (p5#nil)
    wbox(p5)
  endif

  return (nn)

/*********************** */
function cd2()
  /*********************** */
  para odt
  local dttr
  dttr=dtoc(odt)
  if (right(dttr, 4)='1900')
    dttr=subs(dttr, 1, 6)+'2000'
  endif

  return (ctod(dttr))

/***************************************************************** */
function inikop(p1, p2, p3, p4)
  // Инициализация кода операции
  /***************************************************************** */
  private d0k1_r, vu_r, vo_r, kop_r, q_r
  // p1 - d0k1
  // p2 - vu
  // p3 - vo
  // p4 - kop

  d0k1_r=p1
  vu_r =p2
  vo_r =p3
  kop_r =p4
  if (!empty(kop_r))
    q_r=mod(kop_r, 100)
  else
    q_r=qr
  endif

  store '' to coptr, cboptr, cxoptr, cuchr, cotpr, cdopr, cxotpr
  sele soper
  if (!netseek('t1', 'd0k1_r,vu_r,vo_r,q_r'))
    outlog(__FILE__,__LINE__,'Отсутствует операция с кодом '+str(kopr, 3)+' в SOPER')
    outlog(__FILE__,__LINE__,"Err->d0k1_r,vu_r,vo_r,q_r",d0k1_r,vu_r,vo_r,q_r)
    wmess('Отсутствует операция с кодом '+str(kopr, 3)+' в SOPER', 3)
    return (.f.)
  endif

  // для prdec
  /**************************** */
  onofr=nof
  opbzenr=pbzen
  opxzenr=pxzen

  otcenpr=tcen
  otcenbr=ptcen
  if (otcenbr=0)
    otcenbr=otcenpr
  endif

  otcenxr=xtcen
  if (otcenxr=0)
    otcenxr=1               // Входная цена
  endif

  odecpr=getfield('t1', 'otcenpr', 'tcen', 'dec')
  if (odecpr=0)
    odecpr=3
  endif

  odecbr=getfield('t1', 'otcenbr', 'tcen', 'dec')
  if (odecbr=0)
    odecbr=3
  endif

  odecxr=getfield('t1', 'otcenxr', 'tcen', 'dec')
  if (odecxr=0)
    odecxr=3
  endif

  /**************************** */
  prnnr=prnn

  nopr=allt(nop)

  if (fieldpos('kopp')#0)
    koppr=kopp
  else
    koppr=0
  endif

  if (fieldpos('nof')#0)
    nofr=nof
  else
    nofr=0
  endif

  if (gnD0k1=0)
    tcenr=tcen
  else
    tcenr=1                 // Для прихода - учетная цена
  endif

  if (tcenr=0)
    wmess('Неопределен тип 1-й цены в SOPER', 3)
    return (.f.)
  endif

  ndsr=nds
  if (ndsr=0)
    wmess('Неопределено отношение к НДС 1-й цены в SOPER', 3)
    return (.f.)
  endif

  coptr=allt(getfield('t1', 'tcenr', 'tcen', 'zen'))
  if (empty(coptr))
    wmess('Не найден тип 1-й цены в TCEN', 3)
    return (.f.)
  endif

  ntcenr=getfield('t1', 'tcenr', 'tcen', 'ntcen')

  rtcenr=rtcen
  nrtcenr=getfield('t1', 'rtcenr', 'tcen', 'ntcen')
  croptr=allt(getfield('t1', 'rtcenr', 'tcen', 'zen'))

  zcr=zc

  okklr=kkl
  nokklr=getfield('t1', 'okklr', 'kln', 'nkl')
  okplr=kpl
  nokplr=getfield('t1', 'okplr', 'kln', 'nkl')

  Autor=auto
  if (Autor=0.or.Autor=3.or.Autor=4)// Не автомат или автомат с запросом
    skar=0
    msklar=0
    sklar=0
    nsklar=''
  else
    skar=ska
    if (skar=0)
      wmess('Нет адреса для автоматического документа в SOPER', 3)
      return (.f.)
    endif

    nsklar=getfield('t1', 'skar', 'cskl', 'nskl')
    if (empty(nsklar))
      wmess('Не найден адрес автоматического документа в CSKL', 3)
      return (.f.)
    endif

    msklar=getfield('t1', 'skar', 'cskl', 'mskl')
    sklar=getfield('t1', 'skar', 'cskl', 'skl')
  endif

  /************************* */
  //entpr=entp
  //sktpr=sktp
  //skltpr=skltp
  //skspr=sksp
  //sklspr=sklsp
  //
  //sele menent
  //loca for ent=entpr
  //if foun()
  //   nentpr=uss
  //   direpr=allt(nent)+'\'
  //   if comm=0
  //      pathemr=gcPath_ini
  //   else
  //      pathemr=gcPath_ini+direpr
  //   endif
  //   pathepr=pathemr+direpr
  //   pathecr=pathemr+gcDir_c
  //
  //   if comm=0
  //      nsktpr=getfield('t1','sktpr','cskl','nskl')
  //      mskltpr=getfield('t1','sktpr','cskl','mskl')
  //      nskspr=getfield('t1','skspr','cskl','nskl')
  //      msklspr=getfield('t1','skspr','cskl','mskl')
  //   else
  //      sele 0
  //      use (pathecr+'cskl') alias ecskl
  //      nsktpr=getfield('t1','sktpr','ecskl','nskl')
  //      mskltpr=getfield('t1','sktpr','ecskl','mskl')
  //      nskspr=getfield('t1','skspr','ecskl','nskl')
  //      msklspr=getfield('t1','skspr','ecskl','mskl')
  //   endif
  //endif
  /************************* */
  sele soper
  if (nofr=0)
    pbzenr=pbzen
    if (pbzenr#0)
      ptcenr=ptcen
      pndsr=pnds
    else
      pbzenr=1
      ptcenr=tcenr
      pndsr=ndsr
    endif

  else
#ifndef __CLIP__
      pbzenr=pbzen
      if (pbzenr#0)
        ptcenr=ptcen
        pndsr=pnds
      else
        pbzenr=1
        ptcenr=tcenr
        pndsr=ndsr
      endif

#else
      pbzenr=1
      ptcenr=tcenr
      pndsr=ndsr
#endif
  endif

  if (pbzenr=1)
    if (ptcenr=0)
      wmess('Неопределен тип 2-й цены в SOPER', 3)
      return (.f.)
    endif

    cBOptr=allt(getfield('t1', 'ptcenr', 'tcen', 'zen'))
    if (empty(cboptr))
      wmess('Не найден тип 2-й цены в TCEN', 3)
      return (.f.)
    endif

    nptcenr=getfield('t1', 'ptcenr', 'tcen', 'ntcen')
    if (pndsr=0)
      wmess('Неопределено отношение к НДС 2-й цены в SOPER', 3)
      return (.f.)
    endif

  else
    store 0 to pndsr, ptcenr
    store '' to nptcenr
  endif

  if (fieldpos('pxzen')#0)
    if (nofr=0)
      if (pxzen#0)
        pxzenr=pxzen
        xtcenr=xtcen
        xndsr=xnds
      else
        pxzenr=1
        xtcenr=1
        xndsr=ndsr
      endif

    else
      pxzenr=1
      xtcenr=1
      xndsr=ndsr
    endif

    if (pxzenr=1)
      if (xtcenr=0)
        wmess('Неопределен тип 3-й цены в SOPER', 3)
        return (.f.)
      endif

      cxoptr=allt(getfield('t1', 'xtcenr', 'tcen', 'zen'))
      if (empty(cxoptr))
        wmess('Не найден тип 3-й цены в TCEN', 3)
        return (.f.)
      endif

      nxtcenr=getfield('t1', 'xtcenr', 'tcen', 'ntcen')
      if (xndsr=0)
        wmess('Неопределено отношение к НДС 3-й цены в SOPER', 3)
        return (.f.)
      endif

    else
      store 0 to xndsr, xtcenr
      store '' to nxtcenr, cxoptr
    endif

  else
    pxzenr=0
    xtcenr=0
    xndsr=0
    store '' to nxtcenr, cxoptr
  endif

  if (d0k1_r=0)
    cuchr='opt'
    cotpr=coptr
    cdopr=cboptr
    cxotpr=cxoptr
  else
    cuchr=coptr
    cotpr=cboptr
    cdopr=''
    cxotpr=''
  endif

  sele soper
  for spi=1 to 20
    cddbr='ddb'+allt(str(spi, 2))
    cdkrr='dkr'+allt(str(spi, 2))
    cprz='prz'+allt(str(spi, 2))
    db_r=&cddbr
    kr_r=&cdkrr
    if (int(db_r/1000)=361.or.int(kr_r/1000)=361)
      pr361r=1
      exit
    endif

  next

  return (.t.)

/********************************************************************** */
function lzero(p1, p2)
  local aa, bb
  aa=allt(str(p1, p2))
  bb=p2-len(aa)
  aa=repl('0', bb)+aa
  return (aa)

/********************************************** */
function STUFF(cString, nPos, nLen, cBuffer)
  return (SubStr(cString, 1, nPos-1) + cBuffer + SubStr(cString, nLen + nPos))

/***********************************************************************
 * Низкий уровень
 ***********************************************************************
 */
function FGets(nHandle, nLines, nLineLength, cDelim)
  return (FReadLn(nHandle, nLines, nLineLength, cDelim))

/***********************************************************
 * FPuts() -->
 *   Параметры :
 *   Возвращает:
 */
function FPuts(nHandle, cString, nLength, cDelim)
  return (FWriteLn(nHandle, cString, nLength, cDelim))

/***********************************************************
 * DirEval() -->
 *   Параметры :
 *   Возвращает:
 */
function DirEval(cMask, bAction)
  return (AEVAL(DIRECTORY(cMask), bAction))

/***********************************************************
 * FileTop() -->
 *   Параметры :
 *   Возвращает:
 */
function FileTop(nHandle)
  return (FSEEK(nHandle, 0))

/***********************************************************
 * FileBottom() -->
 *   Параметры :
 *   Возвращает:
 */
function FileBottom(nHandle)
  return (FSEEK(nHandle, 0, 2))

/***********************************************************
 * FilePos() -->
 *   Параметры :
 *   Возвращает:
 */
function FilePos(nHandle)
  return (FSEEK(nHandle, 0, 1))

/***********************************************************
 * FileSize() -->
 *   Параметры :
 *   Возвращает:
 */
static function FileSize(nHandle)
  local nCurrent
  local nLength
  nCurrent := FilePos(nHandle)
  nLength := FSEEK(nHandle, 0, 2)
  FSEEK(nHandle, nCurrent)
  return (nLength)

/***********************************************************
 * FReadLn() -->
 *   Параметры :
 *   Возвращает:
 */
function FReadLn(nHandle, nLines, nLineLength, cDelim)
  local nCurPos             // Current position in file
  local nFileSize           // The size of the file
  local nChrsToRead         // Number of character to read
  local nChrsRead           // Number of characters actually read
  local cBuffer             // File read buffer
  local cLines              // Return value, the lines read
  local nCount              // Counts number of lines read
  local nEOLPos             // Position of EOL in cBuffer

  if (nLines=nil)
    nLines=1
  endif

  if (nLineLength=nil)
    nLineLength=80
  endif

  if (cDelim=nil)
    cDelim=(CHR(13) + CHR(10))
  endif

  nCurPos := FilePos(nHandle)
  nFileSize := FileSize(nHandle)

  // Make sure no attempt is made to read past EOF
  nChrsToRead := MIN(nLineLength, nFileSize - nCurPos)

  cLines := ''
  nCount := 1
  while ((nCount <= nLines) .AND. (nChrsToRead != 0))

    cBuffer := SPACE(nChrsToRead)
    nChrsRead := FREAD(nHandle, @cBuffer, nChrsToRead)

    // Check for error condition
    if (!(nChrsRead == nChrsToRead))
      // Error!
      // In order to stay conceptually compatible with the other
      // low-level file functions, force the user to check FERROR()
      // (which was set by the FREAD() above) to discover this fact
      //
      nChrsToRead := 0
    endif

    nEOLPos := AT(cDelim, cBuffer)

    // Update buffer and current file position
    if (nEOLPos == 0)
      cLines += LEFT(cBuffer, nChrsRead)
      nCurPos += nChrsRead
    else
      cLines += LEFT(cBuffer, (nEOLPos + LEN(cDelim)) - 1)
      nCurPos += (nEOLPos + LEN(cDelim)) - 1
      FSEEK(nHandle, nCurPos, 0)
    endif

    // Make sure we don't try to read past EOF
    if ((nFileSize - nCurPos) < nLineLength)
      nChrsToRead := (nFileSize - nCurPos)
    endif

    nCount++

  enddo

  return (cLines)

/***********************************************************
 * FileEval
 *   Параметры:
 */
procedure FileEval(nHandle, nLineLength, cDelim, bBlock, bFor, bWhile, ;
                    nNextLines, nLine, lRest                            ;
                )

  local cLine               // Contains current line being acted on
  local lEOF := .F.         // EOF status
  local nPrevPos            // Previous file position

  if (bWhile=nil)
    bWhile={ || .T. }
  endif

  if (bFor=nil)
    bFor={ || .T. }
  endif

  // lRest == .T. means stay where I am.  Anything else means start from
  // the top of the file
  if (! ((VALTYPE(lRest) == 'L') .AND. (lRest == .T.)))
    FileTop(nHandle)
  endif

  begin sequence

    if (nLine != nil)
      // Process only that one record
      nNextLines := 1
      FileTop(nHandle)
      if (nLine > 1)
        cLine := FReadLn(nHandle, 1, nLineLength, cDelim)
        if (FERROR() != 0)
          break             // An error occurred, jump out of the SEQUENCE
        endif

        // If cLine is a null string, we're at end of file
        lEOF := (cLine == "")
        nLine--
      endif

      // Move to that record (nLine will equal 1 when we are there)
      while (! lEOF) .AND. (nLine > 1)
        cLine := FReadLn(nHandle, 1, nLineLength, cDelim)
        if (FERROR() != 0)
          break             // NOTE: will break out of SEQUENCE
        endif

        lEOF := (cLine == "")
        nLine--
      enddo

    endif

    // Save starting position
    nPrevPos := FilePos(nHandle)

    // If there is more to read from here, get the first line for
    // comparison and potential processing
    if (! lEOF) .AND. (nNextLines == nil .OR. nNextLines > 0)
      cLine := FReadLn(nHandle, 1, nLineLength, cDelim)
      if (FERROR() != 0)
        break               // NOTE
      endif

      lEOF := (cLine == "")
    endif

    while (! lEOF) .AND. EVAL(bWhile, cLine)     ;
     .AND. (nNextLines == nil .OR. nNextLines > 0)

      if (EVAL(bFor, cLine))
        EVAL(bBlock, cLine)
      endif

      // Save start of line
      nPrevPos := FilePos(nHandle)

      // Read next line
      cLine := FReadLn(nHandle, 1, nLineLength, cDelim)
      if (FERROR() != 0)
        break
      endif

      lEOF := (cLine == "")

      if (nNextLines != nil)
        nNextLines--
      endif

    enddo

    // If the reason for ending was that I ran past the WHILE or the number
    // of lines specified, back up to the beginning of the line that failed
    // so that there is no gap in processing
    //
    if (! EVAL(bWhile, cLine)) .OR.                  ;
     ((nNextLines != nil) .AND. (nNextLines == 0))

      FSEEK(nHandle, nPrevPos, FS_SET)

    endif

  endSEQUENCE

  return

/***********************************************************
 * FEof() -->
 *   Параметры :
 *   Возвращает:
 */
function FEof(nHandle)
  return (if(FileSize(nHandle) == FilePos(nHandle), .T., .F.))

/***********************************************************
 * FWriteLn() -->
 *   Параметры :
 *   Возвращает:
 */
function FWriteLn(nHandle, cString, nLength, cDelim)

  if (cDelim == nil)
    cString += CHR(13) + CHR(10)
  else
    cString += cDelim
  endif

  return (FWRITE(nHandle, cString, nLength))

/**************************************************************************/
function gomonth(p1, p2)
  // p1 дата   // p3 кол мес
  /*
  local yy,yyn,mm,mmn,dd,ddn,cnewd
  yy=year(p1)
  yyn=yy
  mm=month(p1)
  dd=day(p1)
  mmn=mm+p2
  if mmn>12
     mmn=mmn-12
     yyn=yyn+1
  endif
  if mmn=0
     mmn=12
     yyn=yyn-1
  endif
  if mmn<0
     mmn=12+mmn
     yyn=yyn-1
  endif
  cnewd='01.'+iif(mmn<10,'0'+str(mmn,1),str(mmn,2))+'.'+str(yyn,4)
  retu ctod(cnewd)
  */
  return (AddMonth(p1, p2))

/*****************************************************************
 
 FUNCTION: SequIdEval()
 АВТОР..ДАТА..........С. Литовка  20.07.04 * 10:28:06
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
function SequIdEval(cField, nLenStoreField)
  local bSequId
  local nPosField, nId
  nLenStoreField:=IIF(nLenStoreField==nil, 12, nLenStoreField)
  nPosField:=FIELDPOS(cField)
  __dbLocate({ || _field->Ent= memvar->gnEnt })
  RecLock()                 //,      ;//QOUT(LASTREC(),"RecLock()"), ;
  nId:=FIELDGET(nPosField)+1//,;// QOUT(LASTREC(),"FIELDGET(nPosField)"),;
  FIELDPUT(nPosField, nId)  //,;//  QOUT(LASTREC(),"FIELDPUT(nPosField, nId)"),;
  dbcommit()                  // ,     ;// QOUT(LASTREC(),"dbcommit()"),;
  dbunlock()                  //,     ;// QOUT(LASTREC(),"dbunlock()"),__WAIT(),;
  do case
  case (UPPER(allt(cField))="KDOKK")
    nId:=(VAL(RIGHT(allt(STR(YEAR(memvar->gdTd))), 2))*100+MONTH(memvar->gdTd))*10^(nLenStoreField-4)+nId
  // "-4" - оставлено для хранения месяца и года GGMM
  endcase

  return (nId)

/***********************************************************
 * edfile() -->
 *   Параметры :
 *   Возвращает:
 */
function edfile(p1)
  local mfiler, mclr, scmr:= SAVESCREEN(1, 0, MAXROW()-1, 80)
  local cTmpFile
  ClosePrintFile()

#ifdef __CLIP__
    /*
      cTmpFile:=TMPFILE()
      SYSCMD("iconv -fCP866 -tKOI8-U "+P1+" >"+cTmpFile,"","")
      mfiler := MEMOREAD(cTmpFile)
    */

    mfiler := translate_charset(set("PRINTER_CHARSET"), host_charset(), MEMOREAD(P1))
#else
    mfiler := MEMOREAD(P1)
#endif

  mclr=SETCOLOR("n/w, w+/n")
  mfiler:= MEMOEDIT(mfiler, 1, 0, MAXROW()-1, 80, .F., "", 300)
  RESTSCREEN(1, 0, MAXROW()-1, 80, scmr)
  SETCOLOR(mclr)
  return (.T.)

/***********************************************************
 * EditMemo() -->
 *   Параметры :
 *   Возвращает:
 */
function EditMemo(PathStr, NomD)
  local cString, cScr := SAVESCREEN(), OldColor := SETCOLOR(), ;
   nCurs := SETCURSOR(), x
  local cTmpFile
  ClosePrintFile()

#ifdef __CLIP__
    /*
      cTmpFile:=TMPFILE()
      SYSCMD("iconv -fCP866 -tKOI8-U "+PathStr+" >"+cTmpFile,"","")
      cString := MEMOREAD(cTmpFile)
      */
    cString := translate_charset(set("PRINTER_CHARSET"), host_charset(), MEMOREAD(PathStr))
#else
    cString := MEMOREAD(PathStr)
#endif

  //  SayHelpA(" ESCПродолжить",MAXROW(),'GR+*/N,W*/N')
  //  @0,0 SAY SPACE(80) COLOR "B*/W"
  //  x := (80-len(NomD))/2
  //  @0,x SAY NomD COLOR "B*/W"

  SETCOLOR("n/w, w+/n")
  //  FlagM := 0

  cString := MEMOEDIT(cString, 1, 0, MAXROW()-1, 80, .F., "", 300)
  SETCURSOR(nCurs)
  RESTSCREEN(,,,, cScr)
  SETCOLOR(OldColor)
  return (.T.)

/***********************************************************
 * OpenPrintFile() -->
 *   Параметры :
 *   Возвращает:
 */
function OpenPrintFile(cPathPrintFile, cTempPrn, lAdd)
  DEFAULT cTempPrn to TEMPFILE(cPathPrintFile, "PRN"), lAdd to TRUE
  Set(_SET_PRINTFILE, cTempPrn, lAdd)
  SET DEVICE to PRINT
  SET PRINT on
  SET CONSOLE off
  return (cTempPrn)

/***********************************************************
 * ClosePrintFile() -->
 *   Параметры :
 *   Возвращает:
 */
function ClosePrintFile()
  SET DEVICE to SCREEN
  SET PRINT off
  SET CONSOLE on
  SET PRINT to
  return (nil)

/************************************************************* */
function smes(p1, p2)
  /*************************************************************************** */
  ggg=''
  do case
  case (p1=1)
    if (p2=nil)
      ggg='январь'
    else
      ggg='января'
    endif

  case (p1=2)
    if (p2=nil)
      ggg='февраль'
    else
      ggg='февраля'
    endif

  case (p1=3)
    if (p2=nil)
      ggg='март'
    else
      ggg='марта'
    endif

  case (p1=4)
    if (p2=nil)
      ggg='апрель'
    else
      ggg='апреля'
    endif

  case (p1=5)
    if (p2=nil)
      ggg='май'
    else
      ggg='мая'
    endif

  case (p1=6)
    if (p2=nil)
      ggg='июнь'
    else
      ggg='июня'
    endif

  case (p1=7)
    if (p2=nil)
      ggg='июль'
    else
      ggg='июля'
    endif

  case (p1=8)
    if (p2=nil)
      ggg='август'
    else
      ggg='августа'
    endif

  case (p1=9)
    if (p2=nil)
      ggg='сентябрь'
    else
      ggg='сентября'
    endif

  case (p1=10)
    if (p2=nil)
      ggg='октябрь'
    else
      ggg='октября'
    endif

  case (p1=11)
    if (p2=nil)
      ggg='ноябрь'
    else
      ggg='ноября'
    endif

  case (p1=12)
    if (p2=nil)
      ggg='декабрь'
    else
      ggg='декабря'
    endif

  endcase

  return (ggg)

/********************* */
function oemtoansi(srt)
  /********************* */
  local j:=len(srt)
  local i:=1
  local ret:=""
  local asco:=""
  for i=1 to j
    asco:=substr(srt, i, 1)
    if (asc(asco)<128)
      ret+=asco
    elseif (asc(asco)>=128 .and. asc(asco)<=175)
      ret+=chr(asc(asco)+64)
    elseif (asc(asco)>=224 .and. asc(asco)<=239)
      ret+=chr(asc(asco)+16)
    else
      ret+=""
    endif

  next

  return (ret)

/**************************** */
function ansitoem(srt)
  /**************************** */
  local j:=len(srt)
  local i:=1
  local ret:=""
  local asco:=""
  for i=1 to j
    asco:=substr(srt, i, 1)
    if (asc(asco)<128)
      ret+=asco
    elseif (asc(asco)>=192 .and. asc(asco)<=239)
      ret+=chr(asc(asco)-64)
    elseif (asc(asco)>=240 .and. asc(asco)<=255)
      ret+=chr(asc(asco)-16)
    else
      ret+=""
    endif

  next

  return (ret)

/**************************** */
function koprp(p1)
  /**************************** */
  crtt('koprp', 'f:d0k1 c:n(1) f:vo c:n(1) f:kop c:n(3) f:nop c:c(30) f:bsd c:n(6) f:bsk c:n(6) f:nds c:n(1)')
  sele 0
  use koprp
  do case
  case (p1=361001)
    if (select('rs1')#0)
      crtt('trs1', 'f:d0k1 c:n(1) f:vo c:n(1) f:kop c:n(3)')
      sele 0
      use trs1
      sele rs1
      go top
      while (!eof())
        if (sdvm=0)
          skip
          loop
        endif

        d0k1r=0
        vor=vo
        kopr=kop
        sele trs1
        locate for d0k1=d0k1r.and.vo=vor.and.kop=kopr
        if (!found())
          appe blank
          repl d0k1 with d0k1r, ;
           vo with vor,         ;
           kop with kopr
        endif

        sele rs1
        skip
      enddo

    endif

    if (select('pr1')#0)
      crtt('tpr1', 'f:d0k1 c:n(1) f:vo c:n(1) f:kop c:n(3)')
      sele 0
      use tpr1
      sele pr1
      go top
      while (!eof())
        if (sdvm=0)
          skip
          loop
        endif

        d0k1r=1
        vor=vo
        kopr=kop
        sele tpr1
        locate for d0k1=d0k1r.and.vo=vor.and.kop=kopr
        if (!found())
          appe blank
          repl d0k1 with d0k1r, ;
           vo with vor,         ;
           kop with kopr
        endif

        sele pr1
        skip
      enddo

    endif

  case (p1=361002)
    if (select('rs1')#0)
      crtt('trs1', 'f:d0k1 c:n(1) f:vo c:n(1) f:kop c:n(3)')
      sele 0
      use trs1
      sele rs1
      go top
      while (!eof())
        if (sdvt=0)
          skip
          loop
        endif

        d0k1r=0
        vor=vo
        kopr=kop
        sele trs1
        locate for d0k1=d0k1r.and.vo=vor.and.kop=kopr
        if (!found())
          appe blank
          repl d0k1 with d0k1r, ;
           vo with vor,         ;
           kop with kopr
        endif

        sele rs1
        skip
      enddo

    endif

    if (select('pr1')#0)
      crtt('tpr1', 'f:d0k1 c:n(1) f:vo c:n(1) f:kop c:n(3)')
      sele 0
      use tpr1
      sele pr1
      go top
      while (!eof())
        if (sdvt=0)
          skip
          loop
        endif

        d0k1r=1
        vor=vo
        kopr=kop
        sele tpr1
        locate for d0k1=d0k1r.and.vo=vor.and.kop=kopr
        if (!found())
          appe blank
          repl d0k1 with d0k1r, ;
           vo with vor,         ;
           kop with kopr
        endif

        sele pr1
        skip
      enddo

    endif

  otherwise
    if (select('rs1')#0)
      crtt('trs1', 'f:d0k1 c:n(1) f:vo c:n(1) f:kop c:n(3)')
      sele 0
      use trs1
      sele rs1
      go top
      while (!eof())
        d0k1r=0
        vor=vo
        kopr=kop
        sele trs1
        locate for d0k1=d0k1r.and.vo=vor.and.kop=kopr
        if (!found())
          appe blank
          repl d0k1 with d0k1r, ;
           vo with vor,         ;
           kop with kopr
        endif

        sele rs1
        skip
      enddo

    endif

    if (select('pr1')#0)
      crtt('tpr1', 'f:d0k1 c:n(1) f:vo c:n(1) f:kop c:n(3)')
      sele 0
      use tpr1
      sele pr1
      go top
      while (!eof())
        d0k1r=1
        vor=vo
        kopr=kop
        sele tpr1
        locate for d0k1=d0k1r.and.vo=vor.and.kop=kopr
        if (!found())
          appe blank
          repl d0k1 with d0k1r, ;
           vo with vor,         ;
           kop with kopr
        endif

        sele pr1
        skip
      enddo

    endif

  endcase

  sele soper
  go top
  while (!eof())
    d0k1r=d0k1
    vor=vo
    kopr=kop+100
    if (d0k1r=0)
      if (select('rs1')#0)
        sele trs1
      else
        sele soper
        skip
        loop
      endif

    else
      if (select('pr1')#0)
        sele tpr1
      else
        sele soper
        skip
        loop
      endif

    endif

    locate for d0k1=d0k1r.and.vo=vor.and.kop=kopr
    if (!foun())
      sele soper
      skip
      loop
    endif

    sele soper
    nopr=nop
    prinsr=0
    ndsr=nds
    for i=1 to 20
      cddbr='ddb'+allt(str(i, 2))
      cdkrr='dkr'+allt(str(i, 2))
      ddbr=&cddbr
      dkrr=&cdkrr
      if (p1=361002)
        if (ddbr=361001.or.dkrr=361001)
          if (ddbr=361001)
            ddbr=361002
          endif

          if (dkrr=361001)
            dkrr=361002
          endif

          prinsr=1
          exit
        endif

      else
        if (ddbr=p1.or.dkrr=p1)
          prinsr=1
          exit
        endif

      endif

    next

    if (prinsr=1)
      sele koprp
      locate for d0k1=d0k1r.and.vo=vor.and.kop=kopr
      if (!foun())
        appe blank
        repl d0k1 with d0k1r, vo with vor, kop with kopr, nop with nopr, bsd with ddbr, bsk with dkrr, nds with ndsr
      endif

    endif

    sele soper
    skip
  enddo

  if (select('trs1')#0)
    sele trs1
    CLOSE
    erase trs1.dbf
  endif

  if (select('tpr1')#0)
    sele tpr1
    CLOSE
    erase tpr1.dbf
  endif

  return (.t.)

/***********************************************************
 * prdp() -->
 *   Параметры :
 *   Возвращает:
 */
function prdp()
  local tror
  if (gnAdm=1)
    return (.t.)
  endif

  tror=alias()
  sele prd
  locate for god=year(gdTd).and.mes=month(gdTd)
  if (!foun())
    if (!empty(tror))
      sele (tror)
    endif

    wmess('Несуществующий период', 1)
    return (.f.)
  endif

  if (prd=1)
    if (!empty(tror))
      sele (tror)
    endif

    wmess('Период закрыт', 1)
    return (.f.)
  endif

  if (!empty(tror))
    sele (tror)
  endif

  return (.t.)

/*********************** */
function pr361(p1, p2, p3, p4)
  /*********************** */
  local pr361_r, als_r
  pr361_r=0
  als_r=select()
  // p1 d0k1 1
  // p2 vu   1
  // p3 vo   2
  // p4 kop  2
  d0k1_r=p1
  vu_r=p2
  vo_r=p3
  kop_r=p4
  sele soper
  if (netseek('t1', 'd0k1_r,vu_r,vo_r,kop_r'))
    for spi=1 to 20
      cddbr='ddb'+allt(str(spi, 2))
      cdkrr='dkr'+allt(str(spi, 2))
      cprz='prz'+allt(str(spi, 2))
      db_rrr=&cddbr
      kr_rrr=&cdkrr
      if (int(db_rrr/1000)=361.or.int(kr_rrr/1000)=361)
        pr361_r=1
        exit
      endif

    next

  endif

  sele (als_r)
  return (pr361_r)

/********************************************** */
function schkktas(p1, p2, p3)
  /* Определение KTAS для складского документа
   * по документу или складской проводке в DOKK
   * p1 d0k1
   * p2 sk
   * p3 ndoc (ttn или mn)
   **********************************************
   */
  store 0 to kta_r, ktas_r, kta_rr, ktas_rr, rcdoc1_r, rcdoc2_r, cdoc_r, cdb1_r, ;
   cdb2_r, mkeep_r, sk_r, d0k1_r, ent_r

  d0k1_r=p1
  sk_r=p2
  ndoc_r=p3

  ent_r=getfield('t1', 'sk_r', 'cskl', 'ent')

  if (d0k1_r=0)
    cdb1_r='rs1'
    cdb2_r='rs2'
    cdoc_r='ttn'
  else
    cdb1_r='pr1'
    cdb2_r='pr2'
    cdoc_r='mn'
  endif

  sele (cdb1_r)
  rcdoc1_r=recn()
  if (&cdoc_r#ndoc_r)
    if (d0k1_r=0)
      netseek('t1', 'ndoc_r')
    else
      netseek('t2', 'ndoc_r')
    endif

  endif

  if (&cdoc_r#ndoc_r)
    go rcdoc1_r
    return (space(8))
  endif

  sele (cdb1_r)
  rmskr=rmsk
  kta_r=kta
  ktas_r=ktas

  if (d0k1_r=0)
    nkkl_r=nkkl
    kpv_r=kpv
  else
    nkkl_r=kps
    kpv_r=kps
  endif

  vu_r=1
  vo_r=vo
  kop_r=mod(kop, 100)

  if (pr361(d0k1_r, vu_r, vo_r, kop_r)=0)
    return (space(8))
  endif

  // для возврата
  kta_rr=kta
  ktas_rr=ktas

  if (ktas_r#0)
    // Проверить достоверность KTAS
    if (ktas_r#getfield('t1', 'ktas_r', 's_tag', 'ktas'))// Нет такого SV
      ktas_rr=0
      kta_rr=0
    else
      if (ent_r#getfield('t1', 'ktas_r', 's_tag', 'ent'))// SV др ENT
        ktas_rr=0
        kta_rr=0
      else
        if (sk_r#getfield('t1', 'ktas_r', 's_tag', 'agsk'))// SV др SK
          ktas_rr=0
          kta_rr=0
        endif

      endif

    endif

  endif

  if (ktas_rr#0)
    sele (cdb1_r)
    go rcdoc1_r
    if (kta_rr=0)
      kta_rr=ktas_rr
    endif

    cktas_r=str(ktas_rr, 4)+str(kta_rr, 4)
    return (cktas_r)
  endif

  if (kta_r#0.and.ktas_r=0)
    // Попытка определить KTAS по агенту
    ktas_rr=getfield('t1', 'kta_r', 's_tag', 'ktas')
    if (ktas_rr#0)
      if (ktas_rr#getfield('t1', 'ktas_rr', 's_tag', 'ktas'))// Нет такого SV
        ktas_rr=0
        kta_rr=0
      else
        if (ent_r#getfield('t1', 'ktas_rr', 's_tag', 'ent'))// SV др ENT
          ktas_rr=0
          kta_rr=0
        else
          if (sk_r#getfield('t1', 'ktas_rr', 's_tag', 'agsk'))// SV др SK
            ktas_rr=0
            kta_rr=0
          endif

        endif

      endif

    endif

  endif

  if (ktas_rr#0)
    sele (cdb1_r)
    go rcdoc1_r
    if (kta_rr=0)
      kta_rr=ktas_rr
    endif

    cktas_r=str(ktas_rr, 4)+str(kta_rr, 4)
    return (cktas_r)
  endif

  // Попытка определить KTAS по складу,если у склада только один KTAS
  sele s_tag
  count to aaa for kod=ktas.and.ent=ent_r.and.agsk=sk_r
  if (aaa=1)
    locate for kod=ktas.and.ent=ent_r.and.agsk=sk_r
    ktas_rr=ktas
    sele (cdb1_r)
    go rcdoc1_r
    if (kta_rr=0)
      kta_rr=ktas_rr
    endif

    cktas_r=str(ktas_rr, 4)+str(kta_rr, 4)
    return (cktas_r)
  endif

  if (rmskr#0)
    // Определить KTAS по rmskr
    do case
    case (rmskr=3)
      ktas_rr=770
    case (rmskr=4)
      ktas_rr=790
    case (rmskr=3)
      ktas_rr=810
    endcase

    if (kta_rr=0)
      kta_rr=ktas_rr
    endif

    cktas_r=str(ktas_rr, 4)+str(kta_rr, 4)
    return (cktas_r)
  endif

  // Удаленный уже должен быть определен

  aktas:={}

  if (d0k1_r=0)
    // Попытка определить KTAS по KPV
    sele kgp
    if (netseek('t1', 'kpv_r'))
      do case
      case (rm=0)         // город или район ktas
        if (getfield('t1', 'kpv_r', 'kln', 'knasp')=1701)
          aadd(aktas, 122)
          aadd(aktas, 338)
          aadd(aktas, 308)
          aadd(aktas, 457)
          aadd(aktas, 556)
          aadd(aktas, 678)
          aadd(aktas, 938)
        else
          aadd(aktas, 122)
          aadd(aktas, 270)
          aadd(aktas, 338)
          aadd(aktas, 308)
          aadd(aktas, 457)
          aadd(aktas, 556)
          aadd(aktas, 678)
          aadd(aktas, 938)
        endif

      case (rm=1)         // город
        aadd(aktas, 122)
        aadd(aktas, 338)
        aadd(aktas, 308)
        aadd(aktas, 457)
        aadd(aktas, 556)
        aadd(aktas, 678)
        aadd(aktas, 938)
      case (rm=2)         // район
        aadd(aktas, 270)
        aadd(aktas, 308)
        aadd(aktas, 457)
        aadd(aktas, 556)
        aadd(aktas, 678)
        aadd(aktas, 938)
      endcase

    else                    // Не найден в KGP
      if (getfield('t1', 'kpv_r', 'kln', 'knasp')=1701)
        aadd(aktas, 122)
        aadd(aktas, 338)
        aadd(aktas, 308)
        aadd(aktas, 457)
        aadd(aktas, 556)
        aadd(aktas, 678)
        aadd(aktas, 938)
      else
        aadd(aktas, 270)
        aadd(aktas, 308)
        aadd(aktas, 457)
        aadd(aktas, 556)
        aadd(aktas, 678)
        aadd(aktas, 938)
      endif

    endif

    if (ktas_rr#0)
      sele (cdb1_r)
      go rcdoc1_r
      if (kta_rr=0)
        kta_rr=ktas_rr
      endif

      cktas_r=str(ktas_rr, 4)+str(kta_rr, 4)
      return (cktas_r)
    endif

  endif

  // Попытка определить KTAS по NKKL
  sele kpl
  if (netseek('t1', 'nkkl_r'))
    crmskr=subs(crmsk, 1, 5)
    if (empty(crmskr))  // город или район
      if (ascan(aktas, 122)=0)
        aadd(aktas, 122)
      endif

      if (ascan(aktas, 270)=0)
        aadd(aktas, 270)
      endif

      if (ascan(aktas, 338)=0)
        aadd(aktas, 338)
      endif

      if (ascan(aktas, 308)=0)
        aadd(aktas, 308)
      endif

      if (ascan(aktas, 457)=0)
        aadd(aktas, 457)
      endif

      if (ascan(aktas, 556)=0)
        aadd(aktas, 556)
      endif

      if (ascan(aktas, 678)=0)
        aadd(aktas, 678)
      endif

      if (ascan(aktas, 938)=0)
        aadd(aktas, 938)
      endif

    else
      for i=1 to 2
        crm_r=subs(crmskr, i, 1)
        if (crm_r='1')
          do case
          case (i=1)      // город
            if (ascan(aktas, 122)=0)
              aadd(aktas, 122)
            endif

            if (ascan(aktas, 338)=0)
              aadd(aktas, 338)
            endif

            if (ascan(aktas, 308)=0)
              aadd(aktas, 308)
            endif

            if (ascan(aktas, 457)=0)
              aadd(aktas, 457)
            endif

            if (ascan(aktas, 556)=0)
              aadd(aktas, 556)
            endif

            if (ascan(aktas, 678)=0)
              aadd(aktas, 678)
            endif

            if (ascan(aktas, 938)=0)
              aadd(aktas, 938)
            endif

          case (i=2)      // район
            if (ascan(aktas, 270)=0)
              aadd(aktas, 270)
            endif

            if (ascan(aktas, 308)=0)
              aadd(aktas, 308)
            endif

            if (ascan(aktas, 457)=0)
              aadd(aktas, 457)
            endif

            if (ascan(aktas, 556)=0)
              aadd(aktas, 556)
            endif

            if (ascan(aktas, 678)=0)
              aadd(aktas, 678)
            endif

            if (ascan(aktas, 938)=0)
              aadd(aktas, 938)
            endif

          endcase

        endif

      next

    endif

  else                      // Не найден в KPL
    if (ascan(aktas, 122)=0)
      aadd(aktas, 122)
    endif

    if (ascan(aktas, 338)=0)
      aadd(aktas, 338)
    endif

    if (ascan(aktas, 270)=0)
      aadd(aktas, 270)
    endif

    if (ascan(aktas, 308)=0)
      aadd(aktas, 308)
    endif

    if (ascan(aktas, 457)=0)
      aadd(aktas, 457)
    endif

    if (ascan(aktas, 556)=0)
      aadd(aktas, 556)
    endif

    if (ascan(aktas, 678)=0)
      aadd(aktas, 678)
    endif

    if (ascan(aktas, 938)=0)
      aadd(aktas, 938)
    endif

  endif

  if (len(aktas)=1)
    ktas_rr=aktas[ 1 ]
    sele (cdb1_r)
    go rcdoc1_r
    if (kta_rr=0)
      kta_rr=ktas_rr
    endif

    cktas_r=str(ktas_rr, 4)+str(kta_rr, 4)
    return (cktas_r)
  endif

  // Попытка определить KTAS по товару накладной
  sele (cdb2_r)
  rcdoc2_r=recn()
  if (netseek('t1', 'ndoc_r'))
    prexr=0
    while (&cDoc_r=nDoc_r)
      mntov_r=mntov
      if (int(mntov_r/10000)>1)
        mkeep_r=getfield('t1', 'mntov_r', 'ctov', 'mkeep')
        if (mkeep_r#0)
          sele stagm
          go top
          while (!eof())
            rcstagmr=recn()
            if (mkeep#mkeep_r)
              sele stagm
              skip
              loop
            endif

            ktas_rrr=kta
            if (ascan(aktas, ktas_rrr)#0)
              ktas_rr=ktas_rrr
              sele (cdb1_r)
              go rcdoc1_r
              sele (cdb2_r)
              go rcdoc2_r
              if (kta_rr=0)
                kta_rr=ktas_rr
              endif

              cktas_r=str(ktas_rr, 4)+str(kta_rr, 4)
              return (cktas_r)
            else
              ktas_rrr=getfield('t1', 'ktas_rrr', 's_tag', 'ktas')
              if (netseek('t1', 'ktas_rrr,mkeep_r', 'stagm'))
                if (ascan(aktas, ktas_rrr)#0)
                  ktas_rr=ktas_rrr
                  sele (cdb1_r)
                  go rcdoc1_r
                  sele (cdb2_r)
                  go rcdoc2_r
                  if (kta_rr=0)
                    kta_rr=ktas_rr
                  endif

                  cktas_r=str(ktas_rr, 4)+str(kta_rr, 4)
                  return (cktas_r)
                endif

              endif

            endif

            sele stagm
            go rcstagmr
            skip
          enddo

        endif

      endif

      sele (cdb2_r)
      skip
    enddo

  endif

  sele (cdb2_r)
  go rcdoc2_r

  if (len(aktas)#0)
    ktas_rr=aktas[ 1 ]
  endif

  if (kta_rr=0)
    kta_rr=ktas_rr
  endif

  sele (cdb1_r)
  go rcdoc1_r
  cktas_r=str(ktas_rr, 4)+str(kta_rr, 4)
  return (cktas_r)

/******************************************************** */
function dchkktas(p1, p2, p3, p4)
  // Определение KTAS  для проплат по бух проводкам (DOKK)
  // p1 - bs
  // p2 - dk 1-Дебет 2-Кредит
  // p3 - 0 - по doks->osn  1 - по doks->ktas  2 - по dokk->mol
  // p4 - 0 - по dkklns, 1- по ldkklns
  /******************************************************** */
  store space(8) to cktas_r
  osn_r=''

  if (!(!dokk->prc.and.(int(dokk->bs_d/1000)=361.or.int(dokk->bs_k/1000)=361).and.val(subs(dokk->dokkmsk, 3, 2))#0.and.dokk->bs_s#0))
    return (cktas_r)
  endif

  bs_rr=p1
  dk_rr=p2
  if (p3=nil)
    pr_rr=0
  else
    pr_rr=p3
  endif

  ktas_r=0                  // вычисляемый
  ktas_rr=0                 // текущий

  do case
  case (pr_rr=0)          // doks->osn
    osn_r=getfield('t1', 'dokk->mn,dokk->rnd,dokk->kkl', 'doks', 'osn')
    osn_r=allt(osn_r)
    if (len(osn_r)>10)
      ktas_rr=val(subs(osn_r, 13, 3))
    else
      if (subs(osn_r, 1, 1)='*')
        ktas_rr=0
      else
        ktas_rr=val(osn_r)
      endif

    endif

  case (pr_rr=1)          // doks->ktas
    ktas_rr=getfield('t1', 'dokk->mn,dokk->rnd,dokk->kkl', 'doks', 'ktas')
  case (pr_rr=2)          // dokk->mol
    ktas_rr=dokk->mol
  endcase

  if (gnArm=1)
    ktas_r=0
  else
    ktas_r=ktas_rr
  endif

  if (ktas_r#0)
    cktas_r=str(ktas_r, 4)+space(4)
    return (cktas_r)
  else
    rmsk_rr=dokk->rmsk      // оффис/филиал
    aktas:={}               // Массив доступных ktas
    if (rmsk_rr#0)        // Проплата через удаленную кассу
                            // Определение KTAS по rmsk
      do case
      case (rmsk_rr=3)
        ktas_r=770
      case (rmsk_rr=4)
        ktas_r=790
      case (rmsk_rr=5)
        ktas_r=810
      endcase

      cktas_r=str(ktas_r, 4)+space(4)
      return (cktas_r)
    else
      if (dokk->bs_d=301001.or.dokk->bs_k=301001)// Проплата по кассе Сумы
        aadd(aktas, 122)
        aadd(aktas, 270)
        aadd(aktas, 338)
        aadd(aktas, 308)
        aadd(aktas, 457)
        aadd(aktas, 556)
        aadd(aktas, 678)
        aadd(aktas, 938)
      else                  // Проплата по банку
                            // Попытка определить KTAS по KPL
        sele kpl
        if (netseek('t1', 'dokk->kkl'))
          crmskr=subs(crmsk, 1, 5)
          if (empty(crmskr))// город или район
            aadd(aktas, 122)
            aadd(aktas, 270)
            aadd(aktas, 338)
            aadd(aktas, 308)
            aadd(aktas, 457)
            aadd(aktas, 556)
            aadd(aktas, 678)
            aadd(aktas, 938)
          else
            for i=1 to 5
              crm_r=subs(crmskr, i, 1)
              if (crm_r='1')
                do case
                case (i=1)    // город
                  if (ascan(aktas, 122)=0)
                    aadd(aktas, 122)
                  endif

                  if (ascan(aktas, 338)=0)
                    aadd(aktas, 338)
                  endif

                  if (ascan(aktas, 308)=0)
                    aadd(aktas, 308)
                  endif

                  if (ascan(aktas, 457)=0)
                    aadd(aktas, 457)
                  endif

                  if (ascan(aktas, 556)=0)
                    aadd(aktas, 556)
                  endif

                  if (ascan(aktas, 678)=0)
                    aadd(aktas, 678)
                  endif

                  if (ascan(aktas, 938)=0)
                    aadd(aktas, 938)
                  endif

                case (i=2)// район
                  if (ascan(aktas, 270)=0)
                    aadd(aktas, 270)
                  endif

                  if (ascan(aktas, 308)=0)
                    aadd(aktas, 308)
                  endif

                  if (ascan(aktas, 457)=0)
                    aadd(aktas, 457)
                  endif

                  if (ascan(aktas, 556)=0)
                    aadd(aktas, 556)
                  endif

                  if (ascan(aktas, 678)=0)
                    aadd(aktas, 678)
                  endif

                  if (ascan(aktas, 938)=0)
                    aadd(aktas, 938)
                  endif

                case (i=3)
                  if (ascan(aktas, 770)=0)
                    aadd(aktas, 770)
                  endif

                case (i=4)
                  if (ascan(aktas, 790)=0)
                    aadd(aktas, 790)
                  endif

                case (i=5)
                  if (ascan(aktas, 810)=0)
                    aadd(aktas, 810)
                  endif

                endcase

              endif

            next

          endif

        else                // Не найден в KPL
                            // По умолчанию Сумы
          aadd(aktas, 122)
          aadd(aktas, 270)
          aadd(aktas, 338)
          aadd(aktas, 308)
          aadd(aktas, 457)
          aadd(aktas, 556)
          aadd(aktas, 678)
          aadd(aktas, 938)
        endif

      endif

      if (len(aktas)=1)
        ktas_r=aktas[ 1 ]
        if (ktas_r#0)
          cktas_r=str(ktas_r, 4)+space(4)
          return (cktas_r)
        endif

      endif

    endif

  endif

  // ktas_r=0 но массив AKTAS доступных KTAS существует

  // Попытка определить KTAS по DKKLNS
  if (empty(p4))
    sele dkklns
  else
    sele ldkklns
  endif

  ktas_rrr=0
  if (netseek('t1', 'dokk->kkl,bs_rr'))
    maxr=0
    while (kkl=dokk->kkl.and.bs=bs_rr)
      if (skl=0)
        skip
        loop
      endif

      ktas_rrr=skl
      if (ascan(aktas, ktas_rrr)=0)
        ktas_rrr=0
        skip
        loop
      endif

      sldr=dn-kn+db-kr
      if (dk_rr=1)        // Поиск большего кредита
        if (sldr<=0)
          sldr=abs(sldr)
          if (sldr>=maxr)
            ktas_r=skl
            maxr=sldr
          endif

        endif

      endif

      if (dk_rr=2)        // Поиск большего дебета
        if (sldr>=0)
          if (sldr>=maxr)
            ktas_r=skl
            maxr=sldr
          endif

        endif

      endif

      skip
    enddo

  endif

  if (ktas_r#0)
    cktas_r=str(ktas_r, 4)+space(4)
    return (cktas_r)
  endif

  if (ktas_rrr#0)         // В DKKLNS существует доступный ktas, но не удовл условиям
    ktas_r=ktas_rrr
    cktas_r=str(ktas_r, 4)+space(4)
    return (cktas_r)
  endif

  // Попытка определить KTAS по KPLKGP

  sele kplkgp
  if (netseek('t1', 'dokk->kkl'))
    while (kpl=dokk->kkl)
      ktar=kta
      ktas_r=getfield('t1', 'ktar', 's_tag', 'ktas')
      if (ktas_r#0)
        if (ascan(aktas, ktas_r)=0)
          ktas_r=0
          skip
          loop
        else
          exit
        endif

      endif

      sele kplkgp
      skip
    enddo

  endif

  if (ktas_r#0)
    cktas_r=str(ktas_r, 4)+space(4)
    return (cktas_r)
  endif

  // Взять первый из доступных

  ktas_r=aktas[ 1 ]
  cktas_r=str(ktas_r, 4)+space(4)
  return (cktas_r)

/***********************************************************
 * prskbs() -->
 *   Параметры :
 *   Возвращает:
 */
function prskbs(p1, p2, p3, p4, p5)
  local pr361_r, als_r
  prbs_r=.f.
  als_r=select()
  // p1 bs
  // p2 d0k1 1
  // p3 vu   1
  // p4 vo   2
  // p5 kop  2
  cbs_r=allt(str(p1))
  lbs_r=len(cbs_r)
  d0k1_r=p2
  vu_r=p3
  vo_r=p4
  kop_r=p5
  sele soper
  if (netseek('t1', 'd0k1_r,vu_r,vo_r,kop_r'))
    for spi=1 to 20
      cddbr='ddb'+allt(str(spi, 2))
      cdkrr='dkr'+allt(str(spi, 2))
      cprz='prz'+allt(str(spi, 2))
      db_rrr=&cddbr
      kr_rrr=&cdkrr
      cdb_rrr=allt(str(db_rrr))
      ckr_rrr=allt(str(kr_rrr))
      if (subs(cdb_rrr, 1, lbs_r)=cbs_r.or.subs(ckr_rrr, lbs_r)=cbs_r)
        prbs_r=.t.
        exit
      endif

    next

  endif

  sele (als_r)
  return (prbs_r)

/***********************************************************
 * win2lin() -->
 *   Параметры :
 *   Возвращает:
 */
function win2lin(p1)
  local aaa
#ifdef __CLIP__
    aaa = translate_charset(                                                              ;
                             "cp1251",                                                    ;//p1
                             host_charset(),                                              ;//p2
                             translate_charset(host_charset(), set("DBF_CHARSET"), p1);//p3
                         )

#else
    aaa=p1
#endif
  return (aaa)

/***********************************************************
 * strel
 *   Параметры:
 */
procedure strel
  @ N1, 0 say '  '

RETURN

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  10-28-09 * 10:18:04pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
  * Запись в moddoc для 361сч
  * Определены gdTd,gnKto,gnAdm
  * Стоим в dokk,dokko
  * p1 - mod поле
  * p2 - 1 - dokk
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
function docmod(p1, p2)
  //local nSecDec, nSeconds
  /*
  ***************************************************
  *  if gnSdRc=1
  *     retu .t.
  *  endif
  */
  if (gnAdm=1)
    gnKto=9999
  endif

  if (gnArm=0)
    gnKto=0
  endif

  if (!empty(p1))
    fld_r=p1
  else
    fld_r=''
  endif

  if (alias()=='DOKK')
    przp_r=1
  else
    przp_r=0
  endif

  /*
  *if !empty(p2)
  *   przp_r=p2
  *else
  *   przp_r=0
  *endif
  */
  bs_drr=bs_d
  bs_krr=bs_k
  mnrr=mn
  rndrr=rnd
  rnrr=rn
  skrr=sk
  mnprr=mnp
  if (int(bs_drr/1000)=361.or.int(bs_krr/1000)=361)
    als_r=alias()
    sele moddoc
    if (!netseek('t1', 'mnrr,rndrr,rnrr,skrr,mnprr'))
      netadd()
      netrepl('mn,rnd,rn,sk,mnp', 'mnrr,rndrr,rnrr,skrr,mnprr')
    endif

    netrepl('dtmod,tmmod,prd,kto', 'date(),time(),bom(gdTd),gnKto')
    netrepl('fld,przp', 'fld_r,przp_r')
    if (fieldpos('rm')#0)
      netrepl('rm', 'gnRmSk')
    endif

    //nSeconds:=TIMETOSEC(TIME())+val(Right(str(seconds(),8,2),2))/100
    //Secr:=str(nSeconds,8,2)
    //nSecDec:=val(Right(str(seconds(),8,2),2))/100
    if (mnrr=0.and.mnprr=0)
      if (!empty(dtmodvz))
        netrepl('dtmodvz,tmmodvz', 'date(),str(MySeconds(),8,2)')
      else
        if (przp_r=1)
          netrepl('dtmodvz,tmmodvz', 'date(),str(MySeconds(),8,2)')
        endif

      endif

    else
      netrepl('dtmodvz,tmmodvz', 'date(),str(MySeconds(),8,2)')
    endif

    if (!empty(als_r))
      sele (als_r)
    endif

  endif

  return (.t.)

/*************************************************** */
function mdall(p1)
  // Запись в mdall
  // Определены gdTd,gnKto,gnAdm
  // Стоим в dokk,dokko
  // p1 - mod поле
  /*************************************************** */
  if (bom(date())=bom(gdTd))
    return (.t.)
  endif

  if (select('mdall')=0)
    return (.t.)
  endif

  //if gnSdRc=1
  //   retu .t.
  //endif
  if (gnAdm=1)
    gnKto=9999
  endif

  if (gnArm=0)
    gnKto=0
  endif

  if (!empty(p1))
    fld_r=p1
  else
    fld_r=''
  endif

  if (alias()=='DOKK')
    przp_r=1
  else
    przp_r=0
  endif

  //#ifdef __CLIP__
  //#else
  //wait
  //#endif
  bs_drr=bs_d
  bs_krr=bs_k
  mnrr=mn
  rndrr=rnd
  rnrr=rn
  skrr=sk
  mnprr=mnp
  als_r=alias()
  sele mdall
  if (!netseek('t1', 'mnrr,rndrr,rnrr,skrr,mnprr'))
    netadd()
    netrepl('mn,rnd,rn,sk,mnp', 'mnrr,rndrr,rnrr,skrr,mnprr')
  endif

  netrepl('dtmod,tmmod,prd,kto', 'date(),time(),bom(gdTd),gnKto')
  netrepl('fld,przp', 'fld_r,przp_r')
  if (mnrr=0.and.mnprr=0)
    if (!empty(dtmodvz))
      netrepl('dtmodvz,tmmodvz', 'date(),str(MySeconds(),8,2)')
    else
      if (przp_r=1)
        netrepl('dtmodvz,tmmodvz', 'date(),str(MySeconds(),8,2)')
      endif

    endif

  else
    netrepl('dtmodvz,tmmodvz', 'date(),str(MySeconds(),8,2)')
  endif

  if (!empty(als_r))
    sele (als_r)
  endif

  return (.t.)

/***************************
 ***************************/
function mddokk(p1)
  // p1 - возвращаемое поле
  local retflfr, fld_rr, als_rr

  if (empty(p1))
    return (999999)
  else
    fld_rr:=p1
  endif

  als_rr=alias()
  if (select('tprd')=0)
    crtt('tprd', 'f:prd c:d(10)')
    sele 0
    use tprd
  endif

  sele (als_rr)
  prdr=prd
  mnr=mn
  rndr=rnd
  rnr=rn
  skr=sk
  mnpr=mnp
  przpr=przp
  prdr=prd
  sele tprd
  locate for prd=prdr
  if (!foun())
    appe blank
    repl prd with prdr
  endif

  cyyr=str(year(prdr), 4)
  cmmr=iif(month(prdr)<10, '0'+str(month(prdr), 1), str(month(prdr), 2))
  pathr=gcPath_e+'g'+cyyr+'\m'+cmmr+'\bank\'
  cpalsr='xp'+cyyr+cmmr
  coalsr='xo'+cyyr+cmmr
  if (select(cpalsr)=0)
    netuse('dokk', cpalsr,, 1)
    netuse('dokko', coalsr,, 1)
  endif

  if (przpr=1)
    retflfr:=getfield('t12', 'mnr,rndr,skr,rnr,mnpr', cpalsr, fld_rr)
  else
    retflfr:=getfield('t12', 'mnr,rndr,skr,rnr,mnpr', coalsr, fld_rr)
  endif

  sele (als_rr)
  return (retflfr)

/*************** */
function close_mddokk()
  /*************** */
  if (select('tprd')#0)
    sele tprd
    go top
    while (!eof())
      prdr=prd
      cyyr=str(year(prdr), 4)
      cmmr=iif(month(prdr)<10, '0'+str(month(prdr), 1), str(month(prdr), 2))
      cpalsr='xp'+cyyr+cmmr
      coalsr='xo'+cyyr+cmmr
      if (select(cpalsr)#0)
        nuse(cpalsr)
      endif

      if (select(coalsr)#0)
        nuse(coalsr)
      endif

      sele tprd
      skip
    enddo

    sele tprd
    CLOSE
    erase tprd.dbf
  endif

  return (.t.)

/******************* */
function tcenkm(p1, p2)
  // p1 - kpl
  // p2 - mntov
  /******************* */
  kpl_r=p1
  mntov_r=p2
  izgr=getfield('t1', 'mntov_r', 'ctov', 'izg')
  return (getfield('t1', 'kpl_r,mntov_r,999', 'klnnac', 'tcen'))

/************** */
function docblk()
  /************** */
  if (gnVo=9.and.gnCtov=1)
    if (napr#0)
      blkr=getfield('t1', 'kplr,napr', 'kplnap', 'blk')
      if (blkr#0)
        nnapr=getfield('t1', 'napr', 'nap', 'nnap')
        wmess('Направление '+allt(nnapr)+' заблокировано', 2)
        return (.t.)
      endif

    endif

  endif

  return (.f.)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА.......... Ц.А.Ю   09-16-09 * 11:22:35am
 НАЗНАЧЕНИЕ.........по СВ, коду Плательщика, коду Грузополучателя
                    находим код ТА
 ПАРАМЕТРЫ..........
  * p1 ktas
  * p2 kpl
  * p3 kgp
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
function agtm(p1, p2, p3)
  local kta_r, nSelec
  nSelec:=select()
  kta_r=0
  ktas_r=p1
  kpl_r=p2
  kgp_r=p3
  tmesto_r=getfield('t2', 'kpl_r,kgp_r', 'etm', 'tmesto')
  if (tmesto_r#0)
    sele stagtm
    set orde to tag t2
    if (netseek('t2', 'tmesto_r'))
      while (tmesto=tmesto_r)
        kta_rr=kta
        If !empty(ktas_r)
          ktas_rr=getfield('t1', 'kta_rr', 's_tag', 'ktas')
          if (ktas_r=ktas_rr)
            kta_r=kta_rr
            exit
          endif
        Else
          kta_r=kta_rr // последняя привязка
        EndIf

        sele stagtm
        skip
      enddo

    endif

  endif

  select (nSelec)
  return (kta_r)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА........ Ю. Цыбульник 10-27-09 * 10:57:48am
 НАЗНАЧЕНИЕ......... корретировка периода проводки бухгалтерской
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
function crmoddoc()
  local lClose:=.f.
  if (gnArm#0)
    clea
  endif

  set prin to crmoddoc.txt
  set prin on
  if (EMPTY(SELECT('moddoc')))
    netuse('moddoc')
    lClose:=.t.
  endif

  sele moddoc
  go top
  while (!eof())
    if (mn=0)
      skip
      loop
    endif

    mnr=mn
    rndr=rnd
    rnr=rn
    prdr=prd
    prexr=0
    /*
    *if mnr=11207.and.rndr=1.and.rnr=1
    *wait
    *endif
    */

    for ggr=year(date()) to 2006 step -1
      do case
      case (ggr=year(date()))
        mm1r=month(date())
        mm2r=1
      case (ggr=2006)
        mm1r=12
        mm2r=9
      otherwise
        mm1r=12
        mm2r=1
      endcase

      for mmr=mm1r to mm2r step -1
        pathr=gcPath_e+'g'+str(ggr, 4)+'\m'+iif(mmr<10, '0'+str(mmr, 1), str(mmr, 2))+'\bank\'
        if (!netfile('dokz', 1))
          loop
        endif

        netuse('dokz',,, 1)
        ddcr=getfield('t2', 'mnr', 'dokz', 'ddc')
        if (!empty(ddcr))
          prd_r=bom(ddcr)
          if (prd_r=prdr)
            prexr=1
          else
            sele moddoc
            netrepl('prd', 'prd_r')// меняем период
            if (gnArm#0)
              ?str(mnr, 6)+' '+str(rndr, 6)+' '+str(rnr, 6)+' '+dtoc(prdr)+' -> '+dtoc(prd_r)
            endif

            prexr=1
          endif

        endif

        nuse('dokz')
        if (prexr=1)
          exit
        endif

      next

      if (prexr=1)
        exit
      endif

    next

    if (prexr=0)
      if (gnArm#0)
        ?str(mnr, 6)+' '+str(rndr, 6)+' '+str(rnr, 6)+' '+dtoc(prdr)+' -> не найден'
      endif

    endif

    sele moddoc
    skip
  enddo

  if (lClose)
    close moddoc
  endif

  nuse()
  set prin off
  set prin to
  return (.t.)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........Ю. Цыбульник  10-27-09 * 11:00:48am
 НАЗНАЧЕНИЕ.........* Существует ли агент/суперв
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........

 */
function chkas(p1, lMess)
  DEFAULT lMess to .T.
  chkasr=p1
  if (chkasr#0)
    if (!netseek('t1', 'chkasr', 's_tag'))
      if (lMess)
        wmess('Нет такого', 2)
      endif

      return (.f.)
    endif

  endif

  return (.t.)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........Ю. Цыбульник 10-27-09 * 11:34:05am
 НАЗНАЧЕНИЕ......... Нет в MODDOC  4 BS=361
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
      sele moddoc
      sele dokk
 */
function nomd()
  sele dokk
  set orde to tag t1
  locate for mn#0
  if (foun())
    while (mn=0)
      if (!int(bs_d/1000)=361.or.int(bs_k/1000)=361)
        skip
        loop
      endif

      mnr=mn
      rndr=rn
      rnr=rn
      skr=sk
      mnpr=mnp
      sele moddoc
      if (!netseek('t1', 'mnr,rndr,rnr,skr,mnpr'))
        sele dokk
        docmod()
      endif

      sele dokk
      skip
    enddo

  endif

  return (.t.)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  10-29-09 * 08:57:32am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
function MySeconds()
  return (TimeToSec(Time())+val(Right(str(seconds(), 8, 2), 2))/100)

/******************* */
function dfnap(p1)
  // p1 -kta или ktas
  /******************* */
  local napr
  napr=0
  kod_r=p1
  sele s_tag
  if (netseek('t1', 'kod_r'))
    kod_rr=ktas
    if (kod=ktas)
      napr=getfield('t1', 'kod_r', 'ktanap', 'nap')
    else
      napr=getfield('t1', 'kod_r', 'ktanap', 'nap')
      if (napr=0)
        napr=getfield('t1', 'kod_rr', 'ktanap', 'nap')
      endif

    endif

  endif

  return (napr)

  return (.t.)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  07-17-11 * 07:51:41pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
function DtLic(nKpl, nKgp, nTypeLic, nnKpl)
  local nRec
  kplr=nKpl
  kgpr=nKgp
  if (!netseek('t1', 'kplr,kgpr'))
    dolr=ctod('')
  else
    dolr=dol

    nRec:=RecNo()
    while (kkl=kplr .and. kgp=kgpr)
      if (lic # nTypeLic) // 2 - лицензия алкоголь
        skip
        loop
      endif

      if (dol>dolr)
        dolr:=dol
        nRec:=RecNo()
      endif

      skip
    enddo

  endif

  if (!Empty(nRec))
    DBGoTo(nRec)
  endif

  return (dolr)

#ifndef __CLIP__

  /***********************************************************
   * outlog() -->
   *   Параметры :
   *   Возвращает:
   */
  function outlog()
    return (nil)
#endif

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  01-30-12 * 03:50:56pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
function MySmtpConnect(oSmtp)
  if (oSmtp:connect())
    return (.T.)
  else
    oSmtp:port:=2525
    if (oSmtp:connect())
      return (.T.)
    endif

  endif

  return (.F.)

/***********************************************************
 * XmlCharTran() -->
 *   Параметры :
 *   Возвращает:
 */
function XmlCharTran(cChr, cAdd, c4emp)
  if (cAdd = nil)
    cAdd := ""
  endif

  if (c4emp = nil)
    c4emp = ""
  endif

  if (Empty(cChr))
    cChr := cAdd + c4emp
  endif

  cChr:=allt(cChr)
  cChr:=STRTRAN(cChr, '\', "/")
  cChr:=STRTRAN(cChr, "&", "&amp;")
  cChr:=STRTRAN(cChr, ">", "&gt;")
  cChr:=STRTRAN(cChr, "<", "&lt;")
  cChr:=STRTRAN(cChr, '"', "&quot;")
  cChr:=STRTRAN(cChr, "'", "&apos;")
  return (allt(cChr))

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  03-27-15 * 06:33:24pm
 НАЗНАЧЕНИЕ.........  дней отстрочки оплаты платежа
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
function kdopl(cMark, nkpl)
  n_Kplr:=nkpl
  izgr:=getfield("t1", cMark, "mkeepe", "izg")
  kdoplr:=getfield("t1", "n_Kplr,999,izgr", "klnnac", "kdopl")
  kdoplr:=Iif(empty(kdoplr), getfield("t1", "n_Kplr", "klndog", "kdopl"), kdoplr)
  return (kdoplr)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  11-20-15 * 09:16:38pm
 НАЗНАЧЕНИЕ......... генарация GUID
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
function uuid()
  seed0:=NTOC(Rand(0)*10^7, 16)//,6,"0"
  seedA:=NTOC(Rand(0)*10^7, 16)//,6,"0"
  seedB:=NTOC(Rand(0)*10^7, 16)//,6,"0")
  seedC:=NTOC(Rand(0)*10^7, 16)//,6,"0")
  seedD:=NTOC(Rand(0)*10^7, 16)//,6,"0")
  seedE:=NTOC(Rand(0)*10^7, 16)//,6,"0")
  seedF:=NTOC(Rand(0)*10^7, 16)//,6,"0")
  out := seed0 + seedA+ seedB+ seedC+ seedD+ seedE+ seedF
  return (TRANSFORM(out, "@R NNNNNNNN-NNNN-NNNN-NNNN-NNNNNNNNNNNN"))

  /***********************************************************
   * Модуль    : x_array.prg
   * Версия    : 0.0
   * Изменен   :
   */

  /***********************************************************
   * CompArray() -->сравнивает массивы
   *   Параметры : два массива
   *   Возвращает: FALSE  различны TRUE одинаковы
   * Автор     : Компьютор+программы 1993 г.
   * Дата      : 07/20/94
   */
  //#define FALSE  .F.

//#define TRUE   .T.
function CompArray(x1, x2)
  local RET:=TRUE
  local i, lSeek := SET(_SET_SOFTSEEK, TRUE)

  if (LEN(x1)# LEN(x2))
    SET(_SET_SOFTSEEK, lSeek); return FALSE
  endif

  AEVAL(x1, { | x, i | IIF(VALTYPE(x)#VALTYPE(x2[ i ]), RET:=FALSE, nil) })

  if (!RET)
    SET(_SET_SOFTSEEK, lSeek); return FALSE
  endif

  for i:=1 to LEN(x1)
    if (VALTYPE(x1[ i ])="A")
      if (!CompArray(x1[ i ], x2[ i ]))
        SET(_SET_SOFTSEEK, lSeek); return FALSE
      endif

    else
      if (x1[ i ]#x2[ i ])
        SET(_SET_SOFTSEEK, lSeek); return FALSE
      endif

    endif

  next

  SET(_SET_SOFTSEEK, lSeek)
  return (TRUE)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  05-10-16 * 11:42:19am
 НАЗНАЧЕНИЕ......... удаление локальный баз с проверкой
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
function lerase_lrs(lerase)
  local lDelFile:=.T.
  if (lerase)
    lDelFile:=.T.
    if (lDelFile .AND. (nErrCode:=DELETEFILE("lphtdoc.dbf"), nErrCode) = -5)
      OUTLOG(__FILE__, __LINE__, 'DELETEFILE("lphtdoc.dbf"),nErrCode', nErrCode)
    endif

    if (lDelFile .AND. (nErrCode:=DELETEFILE("lrs1.dbf"), nErrCode) = -5)
      OUTLOG(__FILE__, __LINE__, 'DELETEFILE("lrs1.dbf"),nErrCode', nErrCode)
    endif

    if (lDelFile .AND. (nErrCode:=DELETEFILE("lrs1.cdx"), nErrCode) = -5)
      OUTLOG(__FILE__, __LINE__, 'DELETEFILE("lrs1.cdx"),nErrCode', nErrCode)
    endif

    if (lDelFile .AND. (nErrCode:=DELETEFILE("lrs2.dbf"), nErrCode) = -5)
      OUTLOG(__FILE__, __LINE__, 'DELETEFILE("lrs2.cdx"),nErrCode', nErrCode)
    endif

    if (lDelFile .AND. (nErrCode:=DELETEFILE("lrs2.cdx"), nErrCode) = -5)
      OUTLOG(__FILE__, __LINE__, 'DELETEFILE("lrs2.cdx"),nErrCode', nErrCode)
    endif

    if (lDelFile)
      lcrtt('lphtdoc', 'phtdoc');      lindx('lphtdoc', 'phtdoc')
      lcrtt('lrs1', 'rs1','f:mess01 c:m(10)')
      lindx('lrs1', 'rs1')
      lcrtt('lrs2', 'rs2');      lindx('lrs2', 'rs2')
      return (.T.)
    else
      return (.F.)
    endif

  endif

  return (.T.)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  05-13-16 * 04:06:15pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
   cXLSFile - имя файла
   cTitle - заголовок
   lYesNo - конвертация логичеких
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
function DBF2XLS(_cXLSFile, cTitle, lYesNo)
  local i, n, cCell, cLine, bEval, _h, nRow, lConv
  local _fc, _Works
  local _MemoPrnt

  lConv:= .T.               //.T. //NEED_OEM2ANSI ковертарция
                            // OEM(CP866)  - ANSI (cp1225))
  bEval:= { || .T. }        // БК фильтра

  _MemoPrnt:=.T.
  _fc:=DbStruct()
  _Works:={}                // название заголовков
  n:=LEN(_fc)
  for i:=1 to n
    AADD(_Works, _fc[ i, 1 ])//+','+_fc[i,2]+','+LTRIM(STR(_fc[i,3]))+','+LTRIM(STR(_fc[i,4])))
  next i

  // header
  //header OpenOffice.org excelfileformat.pdf, MSDN ID: Q178605
  _h:=FCREATE(_cXLSFile)
  FWRITE(_h, CHR(9)+CHR(8)+I2Bin(8)+ ;
          I2Bin(0)+I2Bin(16)+L2Bin(0) ;
      )

  nRow:=0
  if (!EMPTY(cTitle))
    WriteCell(_h, cTitle, INT(LEN(_fc)/2)+1, nRow, 0, lConv, lYesNo)
    nRow+=2
  endif

  n:=LEN(_fc)
  for i:=1 to n
    // Для многострочных заголовков вставляется line break
    cCell:=StrTran(_Works[ i ], ';', CHR(10))
    WriteCell(_h, cCell, i-1, nRow, 0, lConv, lYesNo)
  next

  nRow++
  /*
  LOCATE FOR DELETED()
  IF FOUND()
    cCol:=0
  ENDIF
  */
  DBGOTOP()
  while (!EOF())          //.AND. CheckEsc()
    if (EVAL(bEval))
      //WriteCell(_h, IF(DELETED(), '*', ' '), 0,  nRow,  0, .F., .F.)
      n:=LEN(_fc)
      for i:=1 to n

        cCell:=if(_fc[ i, 2 ] =='M' .AND. !EMPTY(_MemoPrnt),                ;
                   SUBSTR(FieldGet(i), 10, AT(')', FieldGet(i)) - 10), ;
                   FieldGet(i)                                               ;
               )

        if (_fc[ i, 2 ] =='C')
        endif

        WriteCell(_h, cCell, i-1, nRow, 0, lConv, lYesNo)
      next

      nRow++
    endif

    DBSKIP()
  enddo

  FWRITE(_h, I2Bin(10)+I2Bin(0))//XLSEOF
  FCLOSE(_h)
  //свистнем о завершении

  return (.t.)

/********** */
procedure WriteCell(_h, xData, nCol, nRow, nIndex, lConv, lYesNo)
  local nLen

#ifdef __CLIP__
  #xdefine d2bin ftoc
  #xdefine FT_XTOY XTOC
#endif
#define YESNO 'Да', 'Нет'

  if (ValType(xData)=='N')
    FWRITE(_h,              ;
            I2Bin(515)+  ;// Cell type
            I2Bin(14)+   ;// Cell size
            I2Bin(nRow)+ ;// Cell Row
            I2Bin(nCol)+ ;// Cell Col
            I2Bin(nIndex)+;// Index to the XF record
            D2Bin(xData) ;// Float point number
        )
  else
    xData:=if(ValType(xData)='L' .AND. !EMPTY(lYesNo), ;
               if(xData, YESNO), FT_XTOY(xData, 'C')    ;
           )

    nLen:=Len(xData)
    if (nLen > 255)
      nLen:=255
      xData:=LEFT(xData, 255)
    endif

    if (lConv)
      xData := translate_charset(                ;
                                  host_charset(),;//set("DBF_CHARSET"),; //
                                  "cp1251",      ;//p1
                                  xData          ;//p3
                              )
                            //xData:=Oem2Ansi(xData)
    endif

    FWRITE(_h,              ;
            I2Bin(516)+  ;// Cell type
            I2Bin(8+nLen)+;// Cell size
            I2Bin(nRow)+ ;// Cell Row
            I2Bin(nCol)+ ;// Cell Col
            I2Bin(nIndex)+;// Index to the XF record
            I2Bin(nLen)+ ;// Length of the string
            xData          ;// The string
        )
  endif

  return

  /***********************************************************
   * Модуль    : filtbott.prg
   * Версия    : 0.0
   * Автор     :
   * Дата      : 12/21/94
   * Изменен   :
   * Примечание: Текст обработан утилитой CF версии 2.02
   */

//#include "Lib.ch"
#xtranslate CHR_SORT([ <n> ]) => CHR([ <n> ])
#xtranslate ASC_SORT([ <n> ]) => ASC([ <n> ])

/**************************************************
* GoBottomFilt()
* Перемещает указатель последнюю запись соответствующую условию
****************************************************/
function GoBottomFilt(xValue)
  local lSeek := SET(_SET_SOFTSEEK, .T.)

  /* поиск записи, следующей сразу за последней записью, удовлетворяющей
     условию поиска                               */
  if (ISCHAR(xValue))
    DBSEEK(SUBSTR(xValue, 1, LEN(xValue)-1)+CHR_SORT(ASC_SORT(SUBSTR(xValue, LEN(xValue)))+1))
  else
    DBSEEK(xValue + 1)
  endif

  /* возвращение назад на одну запись, т.е. на последнюю запись,
     удовлетворяющую условию поиска    */
  DBSKIP(-1)

  SET(_SET_SOFTSEEK, lSeek)
  return (nil)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  10-10-16 * 11:39:24am
 НАЗНАЧЕНИЕ.........
   Возвращает последовательность псевдо-случайных чисел от 0.00 до 1.00
   Если указан параметр nStart,то последовательность начинается заново.
   От каждого nStart всегда возвращается одинаковая последовательность.
   Пример:
    ? Rand(seconds()) - первый элемент
    While !Waitkey(3)<>xbeK_ESC
      ? Rand()
    end
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
function Rand(nStart)
  static r_iy:=100001
  if (!Empty(nStart))
    r_iy:=nStart+100000
  endif
  r_iy = r_iy * 125
  r_iy = r_iy - int(r_iy/2796203) * 2796203
  return (r_iy/2796203.0)

    /*
    #define SET_OF_OEM  [АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмнопрстуфхцчшщъыьэюяЁёЄєЇїЎў°∙]
    */
