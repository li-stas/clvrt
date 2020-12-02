/*****************************************************************
 
 FUNCTION: StartCDocOpt
 €‚’Ž..„€’€..........‘. ‹¨â®¢ª   26.07.04 * 09:45:51
 €‡€—…ˆ….........
 €€Œ…’›..........
 ‚Ž‡‚. ‡€—…ˆ…....
 ˆŒ…—€ˆŸ.........
 */
FUNCTION StartCDocOpt(dGdTd)
  MEMVAR gnSk
  LOCAL d_gdTd
  PUBLIC gnSk
  netuse('tara')
  netuse('tcen')
  netuse('kln')
  netuse('cskl')

  netuse('vop')
  netuse('dclr')
  netuse('vo')
  netuse('s_tag')
  //¯¥à¥¡®à ®â¤¥«®¢

  FOR i:=1 TO 2
    d_gdTd:=ADDMONTH(dGdTd,i-1)  && „ â  ¢ë¡à ­­®£® ¯¥à¨®¤ 
    Path_Dr:=gcPath_e+"G"+STR(YEAR(d_gdTd),4)+"\M"+PADL(ALLTRIM(STR(MONTH(d_gdTd))),2,"0")+"\"
    PathR:=Path_Dr+"BANK\"

    netuse('dokk',"","",1)
    netuse('dkkln',"","",1)
    netuse('bs',"","",1)

    PathR:=gcPath_e
*    netuse('aninf',"","",1); netuse('aninfl',"","",1)

    cskl->(DBGOTOP())
    DO WHILE cskl->(!EOF())
      IF cskl->(!DELETED())
        IF cskl->Ent # MEMVAR->gnEnt
          cskl->(DBSKIP())
          LOOP
        ENDIF
        PathR:=Path_Dr+ ALLTRIM(cskl->(Path))
        IF !NetFile("tov",1)
          cskl->(DBSKIP())
          LOOP
        ENDIF
        netuse('tov',"","",1)
        netuse('sgrp',"","",1)
        netuse('grpizg',"","",1)
        netuse("soper","","",1)

        netuse("pr1","","",1)
        netuse("pr2","","",1)
        netuse("pr3","","",1)
        netuse("rs1","","",1)
        netuse("rs2","","",1)
        netuse("rs3","","",1)
        gnSk:=cskl->Sk
        RunCDocOpt()

        nuse('tov')
        nuse('sgrp')
        nuse('grpizg')
        nuse("soper")

        nuse("pr1")
        nuse("pr2")
        nuse("pr3")
        nuse("rs1")
        nuse("rs2")
        nuse("rs3")


      ENDIF
      cskl->(DBSKIP())
    ENDDO
    nuse('dokk')
    nuse('dkkln')
    nuse('dknap')
    nuse('bs')
  NEXT

  nuse('tara')
  nuse('tcen')
  nuse('kln')
  nuse('cskl')

  nuse('vop')
  nuse('dclr')
  nuse('vo')

  RETURN (NIL)
