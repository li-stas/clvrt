FUNCTION Main(cParm)

#ifdef __CLIP__
   //C LEAR SCREEN
   //set(_SET_DISPBOX, .F.)

   //set("PRINTER_CHARSET","cp866")

   //set("C:","/home/itk/hd1")

   cHomeDir:=GETENV("HOME")
   set("C:",cHomeDir+"/hd1.drdos")
   set("D:",cHomeDir+"/hd2")

   set(_SET_FILECREATEMODE, "664")
   set(_SET_DIRCREATEMODE , "775")

   set translate path on
   set autopen on
   set optimize off
   SetTxlat(CHR(16),">")
   set(_SET_ESC_DELAY, 99)
   //outlog(__FILE__,__LINE__, SET("C:"))
   //outlog(__FILE__,__LINE__, SET("D:"))
#endif
   rddSetDefault("DBFCDX")

set device to print
set print to clvrt.log ADDI
clvrt(cParm)

RETURN

#ifdef __CLIP__
FUNCTION ISAT()
  RETURN (.T.)

FUNCTION ISVGA()
RETURN .F.

FUNCTION ISEGA()
RETURN .F.

FUNCTION netdisk()
RETURN .F.

FUNCTION NNETNAME()
  LOCAL cNNETNAME
  cNNETNAME:="" //GETENV("HOST")
  SYSCMD("loginfo -O","",@cNNETNAME)
  //outlog(__FILE__,__LINE__,cNNETNAME)
RETURN cNNETNAME

FUNCTION NETNAME()
  RETURN NNETNAME()

FUNCTION NNETSDATE()
RETURN .T.

FUNCTION PRINTREADY()
RETURN .T.

FUNCTION SETDATE()
RETURN .T.
#endif

