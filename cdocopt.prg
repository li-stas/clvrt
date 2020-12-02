if gnScOut=0
   netuse('tara')
   netuse('tcen')
   netuse('kln')
   netuse('kpl')
   netuse('kps')
   netuse('kgp')
   netuse('kgptm')
   netuse('krntm')
   netuse('nasptm')
   netuse('rntm')
   netuse('ctov')
   netuse('stagm')
   netuse('tmesto')
   netuse('cskl')
   netuse('s_tag')
   netuse('vop')
   netuse('dclr')
   netuse('vo')
   netuse('dokk')
   netuse('dkkln')
   netuse('dknap')
   netuse('dkklns')
   netuse('dkklna')
   netuse('dokko')
   netuse('bs')
   netuse('moddoc')
   netuse('mdall')
   netuse('tov')
   netuse('sgrp')
   if gnCtov=1
      netuse('cgrp')
      netuse('tovm')
   endif 
   netuse('soper')
   netuse('grpizg')
   netuse('nap')
   netuse('naptm')
   netuse('kplnap')
   netuse('ktanap')
   netuse('nnds')
   netuse('cntm')
   netuse('nds')
   *Приход
   netuse('pr1')
   netuse('pr2')
   netuse('pr3')
   *Расход
   netuse('rs1')
   netuse('rs2')
   netuse('rs3')
endif

RunCDocOpt()

if gnScOut=0
   nuse()
endif 
return nil

