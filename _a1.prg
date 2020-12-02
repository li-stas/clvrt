      aList_MMYY:={}
      nCntMonth4Last:=7
      nCntMonth4First:=4
      dBeg:=BOM(Date()) ;  dBeg:=ADDMONTH(dBeg,1)
      dEnd:=ADDMONTH(dBeg,nCntMonth4Last*(-1)) //BOM(STOD('20160801'))
      While (dBeg:=ADDMONTH(dBeg,-1),dBeg) >= dEnd
        AADD(aList_MMYY,dBeg)
      enddo

      outlog(__FILE__,__LINE__,aList_MMYY)
      aList_MMYY:=ASORT(aList_MMYY,1,nCntMonth4First)
      ASIZE(aList_MMYY,nCntMonth4First)
      outlog(__FILE__,__LINE__,aList_MMYY)
