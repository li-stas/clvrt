/***********************************************************
 * Модуль    : ftoken.prg
 * Версия    : 0.0
 * Автор     :
 * Дата      : 08/08/94
 * Изменен   :
 * Примечание: Текст обработан утилитой CF версии 2.02
 */

#include "Common.ch"
STATIC FToken := { 0, 0, "", 0, 0, FALSE }
STATIC cFtokBuffer := ""

/***********************************************************
 * FTOKENINIT() -->
 *   Параметры :
 *   Возвращает:
 */
FUNCTION FTOKENINIT(cFile, cSep, nSkip)
  LOCAL nRetVal := 0
*  PUBLIC FToken := { 0, 0, "", 0, 0, FALSE }
*  PUBLIC cFtokBuffer := ""
  FToken[ 1 ] := FOPEN(cFile)

  IF (FToken[ 1 ] < 0)
    nRetVal := -FERROR()
  ELSE
    FToken[ 2 ] := FSEEK(FToken[ 1 ], 0, 2)
    FToken[ 3 ] := cSep
    FToken[ 4 ] := nSkip
    FToken[ 5 ] := MIN(MIN(10000, MEMORY(1)*1024), FToken[ 2 ])
    FToken[ 6 ] := FALSE
    cFtokBuffer := REPLICATE(CHR(0), FToken[ 5 ])

    FSEEK(FToken[ 1 ], 0, 0)
    FREAD(FToken[ 1 ], @cFtokBuffer, FToken[ 5 ])

    TOKENINIT(@cFtokBuffer, FToken[ 3 ], nSkip)
  ENDIF

  RETURN (nRetVal)

  //* Get the next respective token from the file buffer *//

FUNCTION FTOKENNEXT()
  LOCAL cToken, nFilePos, nStill2Read

  cToken = TOKENNEXT(cFtokBuffer)

  IF (LEN(cToken) >= FToken[ 5 ])
    /* Token and buffer have the same size, a token is not
     * recognizable. The buffer has to be enhanced or it has
     * been tried to read text from a binary file.
     *
     */
    cToken = ""
    //FTOKENCLOS()
    FToken[ 6 ] := .T.

  ELSE
    IF (TOKENEND())
      /* Last token for the current buffer. If the file contains
       * further data, this last token has to be 'illegal' and
       * read again with further data.
       */

      IF (FSEEK(FToken[ 1 ], 0, 1) < FToken[ 2 ])
      //IF (FSEEK(FToken[ 1 ], 0, 1) =< FToken[ 2 ])
        /* new loading of the buffer
         *
         * If the file has not reached EOF, the last token of the
         * buffer will be ignored, because it is not sure if the
         * token is complete. The file pointer will be moved back to
         * the beginning of the token and a new buffer will be
         * loaded.
         *
         */
        nFilePos := FSEEK(FToken[ 1 ], -((FToken[ 5 ] -TOKENAT()) +1), 1)
        nStill2Read := FToken[ 2 ] -nFilePos

        /* creating a new, smaller buffer
         *
         */
        IF (nStill2Read < FToken[ 5 ])
          FToken[ 5 ] := nStill2Read
          cFtokBuffer := REPLICATE(CHR(0), FToken[ 5 ])
        ENDIF

        /* read the following data into the buffer
         *
         */
        FREAD(FToken[ 1 ], @cFtokBuffer, FToken[ 5 ])
        TOKENINIT(@cFtokBuffer, FToken[ 3 ], FToken[ 4 ])
        cToken := TOKENNEXT(cFtokBuffer)
      ELSE
        //FTOKENCLOS()
        FToken[ 6 ] := .T.
      ENDIF

    ENDIF

  ENDIF

#ifdef __CLIP__
  cToken:=translate_charset(set("PRINTER_CHARSET"), host_charset(), cToken)
#endif
  RETURN (cToken)

  //* displays if further tokens are existing *//

FUNCTION FTOKENEND()
  RETURN (FToken[ 6 ])

  //* closes the file *//

FUNCTION FTOKENCLOS()
  FCLOSE(FToken[ 1 ])
  FToken := { 0, 0, "", 0, 0, TRUE }
  cFtokBuffer := ""
  RETURN (NIL)

