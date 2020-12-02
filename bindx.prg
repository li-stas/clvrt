SETCOLOR("n/g,,,,")
@ MAXROW(),1 say 'Индексация... '
cll=col()+2
sele dbft
copy to ldbft
sele 0
use ldbft
go top
do while !eof()
*   rcnr=recn()
   if subs(ind,gnArm,1)#'1'
      skip
      loop
   endif
   cifilr=alltrim(als)
   @ MAXROW()-1,1 say space(30)
   @ MAXROW()-1,1 say cifilr
   if !netfile(cifilr,1) 
      sele ldbft
      skip
      loop      
   endif 
*   if fil='tovpt'
*      if netfile('tovpt',1)
*         netuse('tovpt',,,1)
*         do while !eof()
*            if dt<date()-1
*               netdel()
*            endif
*            skip 
*         endd
*         nuse('tovpt')
*      endif  
*   endif
*   if netuse(fil,,'e')
*      dbclearindex()
*      pack
*      netind(fil)
*      use
*      cp866(fil)
*      @ MAXROW(),cll say '▒'
*   else
*      @ MAXROW(),cll say '▒' colo 'r/w'
*   endif
   netuse(cifilr)
   netcind(cifilr)
   nuse('cifilr')
   cll=col()
   sele ldbft
*   go rcnr
   skip
enddo
sele ldbft
use
erase ldbft.dbf



