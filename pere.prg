/***********************************************************
 * Модуль    : pere.prg
 * Версия    : 0.0
 * Автор     :
 * Дата      : 04/04/18
 * Изменен   :
 * Примечание: Текст обработан утилитой CF версии 2.02
 */

#translate do while &fDocr=&mDocr             ;
                                              ;
 => b_fDocr:=FieldBlock(fDocr)              ;
 ; b_mDocr:=MemvarBlock(mDocr)              ;
 ; do while EVAL(b_fDocr) = EVAL(b_mDocr)

para p1, p2
nS43:=0
    If  (tbl1r)->prz = 0 // не подвержден
      tbl3add(43, nS43, 0, nS43, 0, nS43, 0)
    endif
PereDoc(p1,p2)

If gnD0k1 = 0 // расход
  RndSdvr:=RndSdvr()
    outlog(3,__FILE__,__LINE__,"RndSdvr",RndSdvr,tbl1r)
  If RndSdvr < 2 ;//отличает от копейки
    .and. str(kopr,3) $ "169,160,161";
    .and. (tbl1r)->sdv # round((tbl1r)->sdv,RndSdvr)

    nS10 = getfield('t1',mDocr+',10',tbl3r,'ssf')
    nS11 = getfield('t1',mDocr+',11',tbl3r,'ssf')

    nS43 = S43(nS10, nS11, RndSdvr)
    If  (tbl1r)->prz = 0 // не подвержден
      //tbl3add(10, smp1r, 0, smp2r, 0, smp3r, 0)
      outlog(3,__FILE__,__LINE__)
      tbl3add(43, nS43, 0, nS43, 0, nS43, 0)
      outlog(3,__FILE__,__LINE__)
      PereDoc(p1,p2)
    EndIf

    outlog(3,__FILE__,__LINE__,nS10,nS11,nS43,"nS10,nS11,nS43")
  EndIf
EndIf
Return


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  11-05-19 * 03:32:03pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
Function PereDoc()
  para p1, p2
  // p1=1 Пересчитывается только товар
  // p1=2 Полный перерасчет без удаления пустых статей
  // p1=3 Полный перерасчет с удалением пустых статей
  LOCAL pfKolr
  /*******  перерасчет ********** */
  armoldr=gnArm
  gnArm=3
  qr=mod(kopr, 100)
  /*******  перерасчет ********** */
  if (gnD0k1=1)
    sele pr1
    netseek('t2', 'mnr')
    przr=prz
    kopr=kop
    ptr=0
    if (prvzznr=0)
      fKolr='kf'
    else
      fKolr='kfttn'
    endif

    prc177r=0
    mntov177r=0
    pr177r=0
    pr169r=0
  endif

  if (gnD0k1=0)
    sele rs1
    netseek('t1', 'ttnr')
    pr49r=pr49
    przr=prz
    kopr=kop
  endif

  pstr=pst
  if (fieldpos('cnap')#0)
    cnapr=nap
  else
    cnapr=''
  endif

  sele tov
  rctovr=recn()
  cntt2r=0                    // Счетчик позиций
  cntt21r=0                   // Счетчик позиций алкоголя
  cntst2r=0                   // Счетчик сертификатов
  rznst2r=0                   // Разница по 177 для Лодиса

  sele (tbl2r)
  set orde to tag t1
  rct2r=recn()

  //  cenu  uch   Учетная
  //  cenp1 otp   Отпускная      (1-я прайсовая)
  //  cenp2 dop   Дополнительная (2-я)
  //  cenp3 xotp                 (3-я)

  store 0 to smur, smp1r, smp2r, smp3r, smp4r, smp5r// Суммы товара по документу
  store 0 to smtur, smtp1r, smtp2r, smtp3r, smtp4r// Суммы тары по документу
  store 0 to smstur, smstp1r, smstp2r, smstp3r, smstp4r// Суммы стеклотары по документу
  store 0 to sdvur, sdvp1r, sdvp2r, sdvp3r, sdvp4r// Общие суммы по документу
  store 0 to cenur, cenp1r, cenp2r, cenp3r, cenp3r// Цены  по позиции
  store 0 to sur, sp1r, sp2r, sp3r, sp3r, sp5r// Суммы по позиции
  store 0 to vsv_r, rvsv_r, kg290_r, ssf12r, ssf19r, sdf_r, mkeep_r,;
   ssf41r, ssf40r, ssf13r, pr13r, ssf43r, pr43r
  store '' to cnap_r
  prxmlr=0

  pr43r:=0 // округлять не нужно
  RndSdvr:=2
  If !empty((tbl1r)->(FieldPos("RndSdv")))
    If (tbl1r)->RndSdv = 0 //.and. (tbl1r)->Dvp < STOD("20191115")
      (tbl1r)->(netrepl('RndSdv','2'))
    EndIf
    RndSdvr := (tbl1r)->RndSdv
    pr43r := 1
    If (tbl1r)->RndSdv == 2 // до копейки
      pr43r:=0 // нет округления
    EndIf
  EndIf

  if (netseek('t1', mDocr))
    cntt2r=0
    cntt21r=0
    store 0 to ktl_r, ktlp_r, seu_r, ppt_r, sert_r, kol_r, izg_r, vsv_r, rvsv_r, sdf_r
    pfKolr:=(tbl2r)->(FieldPos(fKolr))
    while (&fDocr=&mDocr)
      store 0 to cenur, cenp1r, cenp2r, cenp3r, cenp4r, cvzbbr, cvzbtr// Цены  по позиции
      store 0 to sur, sp1r, sp2r, sp3r, sp4r, sp5r// Суммы по позиции
      store 0 to kovs_r
      mntovr=mntov
      if (gnCtov=1)
        uktr=getfield('t1', 'mntovr', 'ctov', 'ukt')
      else
        uktr=space(10)
      endif

      if (!empty(uktr))
        if (gnD0k1=1.and.(kopr=108.or.kopr=110).or.gnD0k1=0.and.(kopr=160.or.kopr=161))
          prxmlr=1
        endif

      endif

      ktl_r=ktl
      kg_r=int(ktl_r/1000000)
      if (vor=9.and.gnD0k1=0.and.(kg_r=290.or.kg_r=460.or.kg_r=280))
        kg290_r=0
      endif

      mntov_rr=mntov
      if (gnCtov=1)
        mkeep_r=getfield('t1', 'mntov_rr', 'ctov', 'mkeep')
        sele naptm
        set orde to tag t2
        if (netseek('t2', 'mkeep_r'))
          while (mkeep=mkeep_r)
            napr=nap
            cnap_rr=alltrim(str(nap, 4))
            cnap_rr=padl(cnap_rr, 2, '0')
            if (at(cnap_rr, cnap_r)=0)
              cnap_r=cnap_r+cnap_rr+','
            endif

            skip
          enddo

        endif

      endif

      sele (tbl2r)
      kol_r:=FieldGet(pfKolr) //  &fkolr   l:88   // pr2.kf или pr2.kvp
      seu_r=seu
      if (gnD0k1=0)
        sert_r=sert
        cvzbbr=cvzbb
        cvzbtr=cvzbt
      endif

      if (fieldpos('prosfo')#0)
        prosfo_r=prosfo
      else
        prosfo_r=0
      endif

      sele tov
      ves_r=0
      vesp_r=0
      keip_r=0
      if (netseek('t1', 'sklr,ktl_r'))
        ves_r=ves
        vesp_r=vesp
        keip_r=keip
        cenur=opt
        cenubbr=cenbb
        cenubtr=cenbt
        if (mntov=0)
          netrepl('mntov', { mntov_rr })
        endif

        if (gnD0k1=0)
          if (!empty(dopr))
            if (fieldpos('osfo')#0.and.prosfo_r=0)
              netrepl('osfo', { osfo-kol_r })
              if (gnCtov=1)
                sele tovm
                if (netseek('t1', 'sklr,mntov_rr'))
                  netrepl('osfo', { osfo-kol_r })
                endif

              endif

              sele (tbl2r)
              netrepl('prosfo', { 1 })
            endif

          else
            if (fieldpos('osfo')#0.and.prosfo_r=1)
              netrepl('osfo', { osfo+kol_r })
              if (gnCtov=1)
                sele tovm
                if (netseek('t1', 'sklr,mntov_rr'))
                  netrepl('osfo', { osfo+kol_r })
                endif

              endif

              sele (tbl2r)
              netrepl('prosfo', { 0 })
            endif

          endif

        endif

      endif

      kovs_r=1
      if (gnCtov=1)
        kovs_r=getfield('t1', 'kg_r', 'cgrp', 'kovs')
      endif

      sele (tbl2r)

      VesFull(ktl_r, kol_r, kovs_r, ves_r, vesp_r, keip_r, ;
               @sdf_r, @vsv_r, @rvsv_r                      ;
           )

      // Зашито для 3-й цены
      // cenp3r=cenur*gnPre
      /********************************************* */
      if (nofr=1.and.int(ktl_r/1000000)<2)
        if (zen=0)
          netrepl('bzen', { 0 })
          if (fieldpos('xzen')#0)
            netrepl('xzen', { 0 })
          endif

        endif

        if (zenp=0)
          netrepl('bzenp', { 0 })
          if (fieldpos('xzenp')#0)
            netrepl('xzenp', { 0 })
          endif

        endif

      endif

      if (prvzznr=1)
        cenur=zen
      endif

      cenp1r=zen
      cenp2r=bzen
      cenp4r=roun(cenp1r*1.2, 2)
      if (fieldpos('xzen')#0.and.gnD0k1=0)
        if (pxzenr=1)
          xzenpr=cenur
          nof_r=nofr; nofr=1
          if (xzen=0.and.nofr=1.and.int(ktl_r/1000000)>1)//Товар
            if (ndsr=5.or.ndsr=3.or.ndsr=2)
              xzenr=xzenpr
            else
              xzenr=round(xzenpr*1.2, 2)
            endif

            netrepl('xzen,pxzen,xzenp', { xzenr, 0, xzenpr })
          endif

          cenp3r=xzen
          nofr=nof_r
        else
          cenp3r=0
        endif

      else
        cenp3r=0
      endif

      sur=ROUND(cenur*kol_r, 2)
      if (subs(nnzr, 1, 3)='Чек')
        if (gnD0k1=0)
          sp1r=svp
        else
          sp1r=round(cenp1r*kol_r, 2)
        endif

      else
        sp1r=round(cenp1r*kol_r, 2)
      endif

      sp2r=round(cenp2r*kol_r, 2)
      sp3r=round(cenp3r*kol_r, 2)
      sp4r=round(cenp4r*kol_r, 2)

      if (gnVo=1.and.cvzbbr#0.and.cvzbtr#0.and.kpsbbr=1.and.gnD0k1=0)
        sp5r=round(cvzbbr*kol_r, 2)
      else
        sp5r=0
      endif

      do case
      case (int(ktl_r/1000000)=0)// Тара
        smtur=smtur+sur
        smtp1r=smtp1r+sp1r
        smtp2r=smtp2r+sp2r
        smtp3r=smtp3r+sp3r
        smtp4r=smtp4r+sp4r
      case (int(ktl_r/1000000)=1)// Стеклотара
        smstur=smstur+sur
        smstp1r=smstp1r+sp1r
        smstp2r=smstp2r+sp2r
        smstp3r=smstp3r+sp3r
        smstp4r=smstp4r+sp4r
      otherwise                      // Товар
        smur=smur+sur
        smp1r=smp1r+sp1r
        smp2r=smp2r+sp2r
        smp3r=smp3r+sp3r
        smp4r=smp4r+sp4r
        smp5r=smp5r+sp5r
        if (gnD0k1=0)
          if (gnVo=3.and.kopr=136.and.gnKt=1)
            ssf40r=ssf40r+roun(kol_r*(cenp2r-cenp1r), 2)
          endif

        endif

      endcase

      cntt2r++

      if (gnD0k1=0)
        if (gnCtov=1)
          sele cgrp
          if (fieldpos('tgrp')#0)
            if (getfield('t1', 'int(ktl_r/1000000)', 'cgrp', 'tgrp')=1)
              cntt21r++
            endif

          endif

          if (gnEnt=21)
            pr13r=getfield('t1', 'int(ktl_r/1000000)', 'cgrp', 'nal')
          else
            pr13r=''
          endif

        else
          pr13r=''
          cntt21r=0
        endif

        sele (tbl2r)
        if (sert#0)
          cntst2r++
        endif

        if (!empty(pr13r))
          ssf13r=ssf13r+roun(kvp*zen, 2)
        endif

      endif

      sele (tbl2r)
      if (fieldpos('skbon')#0)
        ssf41r=ssf41r-skbon
      endif

      sele (tbl2r)
      skip
    enddo

  endif

  if (prc177r#0)
    if (gnEnt=21)
      kol_rrr=int(smp1r/roun(prc177r, 2))
      if (mod(smp1r, roun(prc177r, 2))#0)
        rznst2r=(kol_rrr+1)*roun(prc177r, 2)-smp1r
      endif

    else
      kol_rrr=roun(smp1r/roun(prc177r, 2), 2)
      if (kol_rrr<0.10)
        kol_rrr=0.10
      endif

      rznst2r=kol_rrr*roun(prc177r, 2)-smp1r
    endif

  endif

  sdvur=smur+smtur+smstur
  sdvp1r=smp1r+smtp1r+smstp1r
  sdvp2r=smp2r+smtp2r+smstp2r
  sdvp3r=smp3r+smtp3r+smstp3r
  sdvp4r=smp4r+smtp4r+smstp4r

  if (p1#1)                 // Полный перерасчет
    sele (tbl3r)
    /***************************************************************************** */
    //  Автоматические статьи
    store 0 to prndsur, prndsp1r, prndsp2r, prndsp3r, prndsp4r
    store 0 to prndstur, prndstp1r, prndstp2r, prndstp3r, prndstp4r
    store 0 to smndsur, smndsp1r, smndsp2r, smndsp3r, smndsp4r
    store 0 to smndstur, smndstp1r, smndstp2r, smndstp3r, smndstp4r
    store 0 to smndsstur, smndsstp1r, smndsstp2r, smndsstp3r, smndsstp4r
    if (gnD0k1=1)           // Приход
      tbl3add(10, smur, 0, smp1r, 0)
      tbl3add(19, smtur, 0, smtp1r, 0)
      sele (tbl3r)
      ssf19r=ssf
      tbl3add(18, smstur, 0, smstp1r, 0)
      if (gnRoz=1)
        tbl3add(91, smp2r+smstp2r-smur-smstur, 0, 0, 0)
        tbl3add(93, smtp2r-smtur, 0, 0, 0)
      endif

      if (netseek('t1', mDocr+',11'))
        smndsur=ssf
        prndsur=pr
        smndsp1r=bssf
        prndsp1r=bpr
      endif

    endif

    if (gnD0k1=0)           // Расход
      if (fieldpos('xxssf')=0)
        tbl3add(10, smp1r, 0, smp2r, 0, smp3r, 0)
      else
        tbl3add(10, smp1r, 0, smp2r, 0, smp3r, 0, smp4r, 0)
      endif

      /**************************************************************** */
      s49()
      if (kg290_r=1)
        s61()
      endif

      if (gnEnt=21)
        s62()
      endif

      /**************************************************************** */
      if (fieldpos('xxssf')=0)
        tbl3add(19, smtp1r, 0, smtp2r, 0, smtp3r, 0)
      else
        tbl3add(19, smtp1r, 0, smtp2r, 0, smtp3r, 0, smtp4r, 0)
      endif

      sele (tbl3r)
      ssf19r=ssf
      if (fieldpos('xxssf')=0)
        tbl3add(18, smstp1r, 0, smstp2r, 0, smstp3r, 0)
      else
        tbl3add(18, smstp1r, 0, smstp2r, 0, smstp3r, 0, smstp4r, 0)
      endif

      if (gnVo=3.and.kopr=136.and.gnKt=1)
        tbl3add(40, ssf40r, 0, 0, 0, 0, 0)
      endif

      if (gnCtov=1)
        sele rs1
        if (gnEnt=21)
          if (getfield('t1', 'ttnr', 'rs1', 'bso')#0)
            bsor=1
            if (cntt21r-10>0)
            //                  bsor=bsor+int(((cntt21r-10)/21)/1)+iif(mod((cntt21r-10)/21,1)#0,1,0)
            endif

            sele (tbl1r)
            netrepl('bso', { bsor }, 1)
            sele soper
            if (netseek('t1', 'gnD0k1,gnVu,vor,qr'))
              pr48r=0
              for i=1 to 20
                sele soper
                dszr=FieldGet(FieldPos('dsz'+ltrim(str(i, 2))))//      &dsz_r
                if (dszr=48)
                  pr48r=1
                  exit
                endif

              next

              if (pr48r=1)
                if (cntt21r#0)
                  ssf48r=0
                  if (cntt21r-10>0)
                  //                           ssf48r=ssf48r+(int(((cntt21r-10)/21)/1)+iif(mod((cntt21r-10)/21,1)#0,1,0))*4.5
                  endif

                  if (empty(rs1->dop))
                    if (fieldpos('xxssf')=0)
                      tbl3add(48, ssf48r, 0, 0, 0)
                    else
                      tbl3add(48, ssf48r, 0, 0, 0, 0, 0)
                    endif

                  endif

                endif

              else
                sele (tbl3r)
                if (netseek('t1', 'ttnr,48'))
                  netdel()
                endif

              endif

            endif

          else
            sele (tbl3r)
            if (netseek('t1', 'ttnr,48'))
              netdel()
            endif

          endif

          tbl3add(41, ssf41r, 0, 0, 0, 0, 0)
        else
          sele (tbl3r)
          if (netseek('t1', 'ttnr,48'))
            netdel()
          endif

        endif

        sele soper
        if (netseek('t1', 'gnD0k1,gnVu,vor,qr'))
          pr13r=0
          for i=1 to 20
            sele soper
            dszr=FieldGet(FieldPos('dsz'+ltrim(str(i, 2))))//      &dsz_r
            if (dszr=13)
              pr13r=1
              exit
            endif

          next

          if (pr13r=1.and.((rs1->dot>ctod('19.02.2015').and.gnSk=232.or.rs1->dot>ctod('23.02.2015').and.gnSk=700).and.rs1->prz=1.or.rs1->prz=0))
            ssf13r=round(ssf13r * 1.2, 2)
            ssf13r=round(ssf13r * .05, 2)
            ssf13_1r=ssf13r
            If RndSdvr # 2
              // округление в большую сторону
              ssf13r=round(Ceiling(ssf13_1r * 10^RndSdvr)/10^RndSdvr, RndSdvr)
            EndIf
            tbl3add(13, ssf13r, 0, ssf13_1r, 0,  0, 0)
          else
            sele (tbl3r)
            if (netseek('t1', 'ttnr,13'))
              netdel()
            endif

          endif

        endif

      endif

      sele (tbl3r)
      // Наверняка
      if (rs1->prz=0)
        if (netseek('t1', 'ttnr,48'))
          netdel()
        endif

      endif

      /** */
      if (fieldpos('xxssf')=0)
        tbl3add(96, smur, 0, iif(pbzenr=1, smur, 0), 0, iif(pxzenr=1, smur, 0), 0)
        tbl3add(97, smtur, 0, iif(pbzenr=1, smtur, 0), 0, iif(pxzenr=1, smtur, 0), 0)
        tbl3add(94, smstur, 0, iif(pbzenr=1, smstur, 0), 0, iif(pxzenr=1, smstur, 0), 0)
        tbl3add(98, smp1r-smur, 0, iif(pbzenr=1, smp2r-smur, 0), 0, iif(pxzenr=1, smp3r-smur, 0), 0)
        tbl3add(99, smtp1r-smtur, 0, iif(pbzenr=1, smtp2r-smtur, 0), 0, iif(pxzenr=1, smtp3r-smtur, 0), 0)
        tbl3add(95, smstp1r-smstur, 0, iif(pbzenr=1, smstp2r-smstur, 0), 0, iif(pxzenr=1, smstp3r-smstur, 0), 0)
        if (gnRoz=1)
          tbl3add(91, iif(pbzenr=1, smp2r+smstp2r-smur-smstur, 0), 0, 0, 0)
          tbl3add(93, iif(pbzenr=1, smtp2r-smtur, 0), 0, 0, 0)
        endif

      else
        tbl3add(96, smur, 0, iif(pbzenr=1, smur, 0), 0, iif(pxzenr=1, smur, 0), 0, smur, 0)
        tbl3add(97, smtur, 0, iif(pbzenr=1, smtur, 0), 0, iif(pxzenr=1, smtur, 0), 0, smtur, 0)
        tbl3add(94, smstur, 0, iif(pbzenr=1, smstur, 0), 0, iif(pxzenr=1, smstur, 0), 0, smstur, 0)
        tbl3add(98, smp1r-smur, 0, iif(pbzenr=1, smp2r-smur, 0), 0, iif(pxzenr=1, smp3r-smur, 0), 0, smp4r-smur, 0)
        tbl3add(99, smtp1r-smtur, 0, iif(pbzenr=1, smtp2r-smtur, 0), 0, iif(pxzenr=1, smtp3r-smtur, 0), 0, smtp4r-smtur, 0)
        tbl3add(95, smstp1r-smstur, 0, iif(pbzenr=1, smstp2r-smstur, 0), 0, iif(pxzenr=1, smstp3r-smstur, 0), 0, smstp4r-smstur, 0)
        if (gnRoz=1)
          tbl3add(91, iif(pbzenr=1, smp2r+smstp2r-smur-smstur, 0), 0, 0, 0, 0, 0)
          tbl3add(93, iif(pbzenr=1, smtp2r-smtur, 0), 0, 0, 0, 0, 0)
        endif

      endif

      store gnNds to prndsur, prndsp1r, prndsp2r, prndsp3r, prndsp4r, prndsp5r
    endif

    /***************************************************************************** */
    // Остальные статьи
    sele (tbl3r)
    if (netseek('t1', mDocr))
      store 0 to ssur, ssp1r, ssp2r, ssp3r, ssp4r// Суммы скидок
      store 0 to snur, snp1r, snp2r, snp3r, snp4r// Суммы наценок
      while (&fDocr=&mDocr)
        store 0 to prur, prp1r, prp2r, prp3r, prp4r// Проценты статей
        store 0 to ssfur, ssfp1r, ssfp2r, ssfp3r, ssfp4r// Суммы статей
        store 0 to ssfur1, ssfp1r1, ssfp2r1, ssfp3r1, ssfp4r1
        store 0 to ssfur2, ssfp1r2, ssfp2r2, ssfp3r2, ssfp4r2
        store 0 to prr90, nalr
        sele (tbl3r)
        if (ksz=11)         // НДС для считается позже
          skip
          loop
        endif

        if (ksz=12 .and.tarar=1 .and.gnD0k1=0)// если поменялся клиент, а расчет был по ksz=12
          netdel()
          skip
          loop
        endif

        if (ksz=12 .and.pstr=0 .and.gnD0k1=1)// если поменялся клиент, а расчет был по ksz=12
          netdel()
          skip
          loop
        endif

        kszr=ksz
        if (gnD0k1=0)
          ssfp1r=ssf
          prp1r=pr
          ssfp2r=bssf
          prp2r=bpr
          if (fieldpos('xxssf')#0)
            ssfp4r=xxssf
            prp4r=pr
          else
            ssfp4r=0
            prp4r=0
          endif

          if (fieldpos('xssf')#0)
            ssfp3r=xssf
            prp3r=xpr
          else
            ssfp3r=0
            prp3r=0
          endif

        else
          ssfur=ssf
          prur=pr
          ssfp1r=bssf
          prp1r=bpr
          if (kszr=12)
            ssfur=round(smtur/100*prur, 2)
            ssfp1r=round(smtp1r/100*prp1r, 2)
            tbl3add(kszr, ssfur, prur, ssfp1r, prp1r)
            smndstur=ssfur
            smndstp1r=ssfp1r
            prndstur=pr
            prndstp1r=bpr
            sele (tbl3r)
            ssf12r=ssf
            skip
            loop
          endif

        endif

        sele dclr
        if (netseek('t1', 'kszr'))
          if (&fprr=0.or.kszr=48)// Не автоматическая статья по DCLR
            prr90=pr90
            nalr=nal
            if (prur#0)
              if (nalr#1)
                ssfur=ROUND(smur/100*prur, 2)
              else
                prur=0
              endif

            endif

            if (prp1r#0)
              ssfp1r=ssfp1r1+ssfp1r2
              if (nalr#1)
                ssfp1r=ROUND(smp1r/100*prp1r, 2)
              else
                prp1r=0
              endif

            endif

            if (prp2r#0)
              if (nalr#1)
                ssfp2r=ROUND(smp2r/100*prp2r, 2)
              else
                prp2r=0
              endif

            endif

            if (prp4r#0)
              ssfp4r=ssfp4r1+ssfp4r2
              if (nalr#1)
                ssfp4r=ROUND(smp4r/100*prp4r, 2)
              else
                prp4r=0
              endif

            endif

            if (kszr>=20.and.kszr<39 .and.prr90<>1)// Скидка
              ssur=ssur+ssfur
              ssp1r=ssp1r+ssfp1r
              ssp2r=ssp2r+ssfp2r
              ssp3r=ssp3r+ssfp3r
              ssp4r=ssp4r+ssfp4r
            endif

            if (kszr>=40.and.kszr<=80 .and.prr90<>1)// Наценка
              snur=snur+ssfur
              snp1r=snp1r+ssfp1r
              snp2r=snp2r+ssfp2r
              snp3r=snp3r+ssfp3r
              snp4r=snp4r+ssfp4r
            endif

            if (gnD0k1=0)
              tbl3add(kszr, ssfp1r, prp1r, ssfp2r, prp2r, ssfp3r, prp3r, ssfp4r, prp4r)
            else
              tbl3add(kszr, ssfur, prur, ssfp1r, prp1r)
            endif

          endif

        endif

        sele (tbl3r)
        skip
        if (kszr#0.and.ksz=kszr)
          netdel()
          skip
        endif

      enddo

      store 0 to ondsur, ondsp1r, ondsp2r, ondsp3r, ondsp4r
      if (gnD0k1=0)
        ondsp1r=ndsr
        ondsp2r=pndsr
        ondsp3r=xndsr
        ondsp4r=1
      else
        ondsur=ndsr
        ondsp1r=pndsr
      endif

      if (gnD0k1=0)
        smp1_r=smp1r
        if (smp5r#0)
          smp1r=smp5r
        endif

        onds('p1r')
        smp1r=smp1_r
        onds('p2r')
        onds('p3r')
        onds('p4r')
        if (tarar=0)
          //            if vor=3.and.(kopr=135.or.kopr=136.or.kopr=137)
          //               tbl3add(12,smndstp2r,prndsp2r,smndstp2r,prndsp2r,smndstp3r,prndsp3r,smndstp4r,prndsp4r)
          //           else
          tbl3add(12, smndstp1r, prndsp1r, smndstp2r, prndsp2r, smndstp3r, prndsp3r, smndstp4r, prndsp4r)
          //            endif
          sele (tbl3r)
          ssf12r=ssf
        else                  // tarar=1

        endif

        if (pstr=0)
          //            if vor=3.and.(kopr=135.or.kopr=136.or.kopr=137)
          //               tbl3add(11,smndsp2r,prndsp2r,smndsp2r,prndsp2r,smndsp3r,prndsp3r,smndsp4r,prndsp4r)
          //            else
          tbl3add(11, smndsp1r, prndsp1r, smndsp2r, prndsp2r, smndsp3r, prndsp3r, smndsp4r, prndsp4r)
        //            endif
        else
          //            if vor=3.and.(kopr=135.or.kopr=136.or.kopr=137)
          //               tbl3add(11,(smndsp2r+smndsstp2r),prndsp2r,(smndsp2r+smndsstp2r),prndsp2r,(smndsp3r+smndsstp3r),prndsp3r,(smndsp4r+smndsstp4r),prndsp4r)
          //            else
          tbl3add(11, (smndsp1r+smndsstp1r), prndsp1r, (smndsp2r+smndsstp2r), prndsp2r, (smndsp3r+smndsstp3r), prndsp3r, (smndsp4r+smndsstp4r), prndsp4r)
        //            endif
        endif

      else
        smp1_r=smp1r
        onds('ur')
        onds('p1r')
        if (pstr=0)
          tbl3add(11, smndsur, prndsur, smndsp1r, prndsp1r)
        endif

        if (pstr=1)
          tbl3add(11, (smndsur+smndsstur), prndsur, (smndsp1r+smndsstur), prndsp1r)
        endif

      endif

    endif

    /************************************************************************** */

    sele (tbl3r)
    if (gnD0k1=1)           // Приход
                              //      if kopr#188
      store 0 to s89uchr, s89otpr, s89dopr
      if (netseek('t1', mDocr+',90'))
        ssfur=ssf
        ssfp1r=bssf
        s89ur=ssfur-sdvur
        s89p1r=ssfp1r-sdvp1r
      else
        ssfur=0
        ssfp1r=0
        s89ur=ssfur-sdvur
        s89p1r=ssfp1r-sdvp1r
      endif

      tbl3add(89, s89ur, 0, s89p1r, 0)
    //      endif
    else                      // Расход
      if (ssf13r=0)
        tbl3add(90, sdvp1r, 0, sdvp2r, 0, sdvp3r, 0, sdvp4r, 0)
      else
        if (empty(pr13r)) // pr13r=0
          tbl3add(90, sdvp1r, 0, sdvp2r, 0, sdvp3r, 0, sdvp4r, 0)
        else
          if (rs1->dot>ctod('19.02.2015').and.gnSk=232.or.rs1->dot>ctod('23.02.2015').and.gnSk=700).and.rs1->prz=1.or.rs1->prz=0
            //            if rs1->dot>ctod('19.02.2015').and.rs1->prz=1.or.rs1->prz=0
            tbl3add(90, sdvp1r+ssf13r, 0, sdvp2r+ssf13r, 0, sdvp3r, 0, sdvp4r, 0)
          else
            tbl3add(90, sdvp1r, 0, sdvp2r, 0, sdvp3r, 0, sdvp4r, 0)
          endif

        endif

      endif

    endif

    if (p1=3)
      if (netseek('t1', mDocr))
        while (&fDocr=&mDocr)
          if (gnD0k1=0)
            if (fieldpos('xssf')#0)
              if (ssf=0.and.bssf=0.AND.pr=0.AND.bpr=0.AND.xpr=0.AND.xssf=0)
                netdel()
              endif

            else
              if (ssf=0.and.bssf=0.AND.pr=0.AND.bpr=0)
                netdel()
              endif

            endif

          else
            if (ssf=0.and.bssf=0)
              netdel()
            endif

          endif

          skip
        enddo

      endif

    endif

    sele (tbl1r)
    if (gnArm#6)
      if (gnD0k1=1)
        //         netrepl('sdv','sdvur',1)
        netrepl('sdv', { ssfur }, 1)
        if (fieldpos('sdvm')#0)
          if (ssf12r=0.and.ssf19r#0)
            netrepl('sdvm,sdvt', { ssfur-ssf19r, ssf19r })
          else
            netrepl('sdvm', { ssfur })
          endif

        endif

      else
        if (ssf13r=0)
          netrepl('sdv,vsv,sdf', { sdvp1r, vsv_r, sdf_r }, 1)
        else
          if (empty(pr13r))
            netrepl('sdv,vsv,sdf', { sdvp1r, vsv_r, sdf_r }, 1)
          else
            if (rs1->dot>ctod('19.02.2015').and.gnSk=232.or.rs1->dot>ctod('23.02.2015').and.gnSk=700).and.rs1->prz=1.or.rs1->prz=0
              //               if rs1->dot>ctod('19.02.2015').and.rs1->prz=1.or.rs1->prz=0
              netrepl('sdv,vsv,sdf', { sdvp1r+ssf13r, vsv_r, sdf_r }, 1)
            else
              netrepl('sdv,vsv,sdf', { sdvp1r, vsv_r, sdf_r }, 1)
            endif

          endif

        endif

        //         netrepl('sdv,vsv,sdf',{sdvp1r,vsv_r,sdf_r},1)
        if (fieldpos('vsvb')#0)
          netrepl('vsvb', { rvsv_r }, 1)
          vsvbr=vsvb
        endif

        if (fieldpos('sdvm')#0)
          if (ssf12r=0.and.ssf19r#0)
            netrepl('sdvm,sdvt', { sdvp1r-ssf19r, ssf19r })
          else
            netrepl('sdvm', { sdvp1r })
          endif

        endif

        if (fieldpos('sdvm1')#0)
          if (ssf12r=0.and.ssf19r#0)
            netrepl('sdvm1', { sdvp2r-ssf19r })
            netrepl('sdvm2', { sdvp3r-ssf19r })
          else
            netrepl('sdvm1', { sdvp2r })
            netrepl('sdvm2', { sdvp3r })
          endif

        endif

      endif

    endif

  endif

  // wmess(str(seconds()-aaaaa,10),2)
  // rest screen from scperer
  if (gnScout=0)
    if (subs(nnzr, 1, 3)#'Чек'.and.armoldr#0)
      if (gnD0k1=1)
        if (pbzenr=1)
          @ 5, 0 say ' По отпускным ценам   : ' + str(sdvp1r, 10, 2)+' '+str(prdecr, 1) color 'g/n,n/g'
        endif

        @ 5, 43 say ' По закупочным ценам  : ' + str(sdvur, 10, 2) color 'g/n,n/g'
        @ 6, 43 say ' Количество позиций   : ' + str(cntt2r, 3) color 'g/n'
      else
        if (gnRmag=0)
          if (pbzenr=1.and.(gnArm=2.or.gnArm=6))
            //@ 5,43 say ' Итого                : ' + str(sdvp1r,10,2) color 'g/n,n/g'
          //@ 6,43 say ' Итого коррекция      : ' + str(sdvp2r,10,2) color 'g/n,n/g'
          else
            @ 3, 52 say str(sdf_r, 5, 0) color 'g/n,n/g'
            @ 3, 62 say 'Вес:' + str(vsv_r, 5, 0)+'('+str(rvsv_r, 5, 0)+')'+'кг' color 'g/n,n/g'
            //            @ 3,62 say 'Вес:' + alltrim(str(vsv_r,11,3))+'('+alltrim(str(rvsv_r,11,3))+')'+'кг' color 'g/n,n/g'
            if (p1=1.and.ndsr=5)
              @ 5, 43 say ' Итого                : ' + str(sdvp1r*1.2, 10, 2) color 'g/n,n/g'
            else
              //               @ 5,43 say ' Итого                : ' + str(sdvp1r,10,2) color 'g/n,n/g'
              @ 5, 43 say ' По отпускным ценам   : ' + str(sdvp1r, 10, 2)+' '+str(prdecr, 1) color 'g/n,n/g'
            endif

            if (sdvp2r#0)
              //               @ 4,67 say str(sdvp2r,10,2)
              @ 4, 43 say '                        ' + str(sdvp2r, 10, 2) color 'g/n,n/g'
            endif

            if (gnVo#7)
              @ 6, 43 say ' Количество позиций   : ' + str(cntt2r, 3)+iif(cntst2r#0, '('+str(cntst2r, 3)+')', '') color 'g/n'
              if ((str(pr129r,1)$'2;3' .OR. str(pr139r,1)$'2;3'  .or. str(pr169r,1)$'2;3' .OR. str(pr177r,1)$'2;3'))
                @ 7, 43 say ' Разница: ' + str(rznst2r, 10, 2) color 'g/n'
              endif

            else
              @ 6, 43 say ' Количество позиций   : ' + str(cntst2r, 3)+iif(cntst2r#0, '('+str(cntst2r, 3)+')', '') color 'g/n'
            endif

            do case
            case (pr49r=0)
              @ 6, 78 say ' ' color 'g/n,n/g'
            case (pr49r=1)
              @ 6, 78 say str(pr49r+1, 1) color 'gr+/n,n/g'
            case (pr49r=2)
              @ 6, 78 say str(pr49r+1, 1) color 'r+/n,n/g'
            endcase

          endif

        endif

      endif

    endif

  endif

  if (gnD0k1=0)
    sele rs1
    netrepl('kolpos', { cntt2r }, 1)
    kolposr=kolpos
    if (fieldpos('cnap')#0)
      netrepl('cnap', { cnap_r }, 1)
    endif

  endif

  sele tov
  go rctovr
  sele (tbl2r)
  go rct2r
  sele (tbl3r)
  netseek('t1', mDocr)
  gnArm=armoldr
  Return (Nil)

/***************************************************************** */
function tbl3add(p1, p2, p3, p4, p5, p6, p7, p8, p9)
  /***************************************************************** */
  // p1 - Номер статьи
  // p2 - Сумма ssf
  // p3 - Процент ssf
  // p4 - Сумма bssf
  // p5 - Процент bssf
  // p6 - Сумма xssf
  // p7 - Процент xssf
  // p8 - Сумма xxssf
  // p9 - Процент xxssf

  private ksz_rr, ssf_rr, bssf_rr, xssf_rr, pr_rr, bpr_rr, xpr_rr, xxpr_rr

  ksz_rr=p1

  if (p2=nil)
    ssf_rr=0
  else
    ssf_rr=p2
  endif

  if (p3=nil)
    pr_rr=0
  else
    pr_rr=p3
  endif

  if (p4=nil)
    bssf_rr=0
  else
    bssf_rr=p4
  endif

  if (p5=nil)
    bpr_rr=0
  else
    bpr_rr=p5
  endif

  if (p6=nil)
    xssf_rr=0
  else
    xssf_rr=p6
  endif

  if (p7=nil)
    xpr_rr=0
  else
    xpr_rr=p7
  endif

  if (p8=nil)
    xxssf_rr=0
  else
    xxssf_rr=p8
  endif

  if (p9=nil)
    xxpr_rr=0
  else
    xxpr_rr=p9
  endif

  sele (tbl3r)
  if (fieldpos('xxssf')#0)
    if (netseek('t1', mDocr+',ksz_rr'))
      if (ssf#ssf_rr.or.bssf#bssf_rr.or.xssf#xssf_rr.or.xxssf#xxssf_rr)
        do case
        case (gnArm=2.or.gnArm=6)
          netrepl('bssf,bpr', { bssf_rr, bpr_rr })
        case (gnArm=3)
          netrepl('ssf,pr,bssf,bpr,xssf,xpr,xxssf,xxpr', { ssf_rr, pr_rr, bssf_rr, bpr_rr, xssf_rr, xpr_rr, xxssf_rr, xxpr_rr })
        endcase

      endif

    else
      if (ssf_rr#0.or.bssf_rr#0.or.xssf_rr#0.or.xxssf_rr#0)
        netAdd()
        do case
        case (gnArm=2.or.gnArm=6)
          //netrepl(fDocr+',ksz,bssf,bpr',mDocr+',ksz_rr,bssf_rr,bpr_rr')
          netrepl(fDocr+',ksz,bssf,bpr', { &mDocr, ksz_rr, bssf_rr, bpr_rr })
        case (gnArm=3)
          netrepl(fDocr+',ksz,ssf,pr,bssf,bpr,xssf,xpr,xxssf,xxpr',                                      ;
                   { &mDocr, ksz_rr, ssf_rr, pr_rr, bssf_rr, bpr_rr, xssf_rr, xpr_rr, xxssf_rr, xxpr_rr } ;
               )
        endcase

      endif

    endif

  else
    if (netseek('t1', mDocr+',ksz_rr'))
      if (ssf#ssf_rr.or.bssf#bssf_rr.or.xssf#xssf_rr)
        do case
        case (gnArm=2.or.gnArm=6)
          netrepl('bssf,bpr', 'bssf_rr,bpr_rr')
        case (gnArm=3)
          netrepl('ssf,pr,bssf,bpr,xssf,xpr', { ssf_rr, pr_rr, bssf_rr, bpr_rr, xssf_rr, xpr_rr })
        endcase

      endif

    else
      if (ssf_rr#0.or.bssf_rr#0.or.xssf_rr#0)
        netAdd()
        do case
        case (gnArm=2.or.gnArm=6)
          netrepl(fDocr+',ksz,bssf,bpr', { &mDocr, ksz_rr, bssf_rr, bpr_rr })
        case (gnArm=3)
          netrepl(fDocr+',ksz,ssf,pr,bssf,bpr,xssf,xpr',                              ;
                   { &mDocr, ksz_rr, ssf_rr, pr_rr, bssf_rr, bpr_rr, xssf_rr, xpr_rr } ;
               )
        endcase

      endif

    endif

  endif

  return (.t.)

/************************************************************************** */
function tbl3oper()         // Добавление в TBL3 не автоматических статей
  /************************************************************************** */
  asz:={}                   // Массив статей затрат по которым есть проводки в SOPER
  sele soper
  netseek('t1', 'gnD0k1,gnVu,vor,qr')
  for i=1 to 20
    sele soper
    dszr=FieldGet(FieldPos('dsz'+ltrim(str(i, 2))))//      &dsz_r
    if (dszr=0)
      loop
    endif

    aadd(asz, dszr)
    sele dclr
    if (netseek('t1', 'dszr'))
      if (&fprr=0)        // Не автомат
        sele (tbl3r)
        if (!netseek('t1', mDocr+',dszr'))
          netadd()
          netrepl(fDocr+',ksz', { &mDocr, dszr })
        endif

      endif

    endif

  next

  sele (tbl3r)
  if (netseek('t1', mDocr))
    while (&fDocr=&mDocr)
      kszr=ksz
      if (gnD0k1=1)
        if (kszr=94.or.kszr=95.or.kszr=96.or.kszr=97.or.kszr=98.or.kszr=99)
          netdel()
          skip
          loop
        endif

        if (kszr=91.or.kszr=93).and.gnRoz=0
          netdel()
          skip
          loop
        endif

        if (kszr=90)
          skip
          loop
        endif

      endif

      if (ascan(asz, kszr)=0)
        sele dclr
        netseek('t1', 'kszr')
        if (gnD0k1=0)
          pr_r=pr
        else
          pr_r=prp
        endif

        sele (tbl3r)
        if (pr_r=0)       // Не автоматическая статья
          netdel()
        endif

      endif

      skip
    enddo

  endif

  return (.t.)

/********************************************************************* */
function onds(p1)         // Отношение к НДС
  /********************************************************************* */
  p1r=p1
  do case
  case (onds&p1r = 5)     //НДС с товара/тары кроме того
    if (prnds&p1r#0)
      if (vor=3.and.gnKt=1.and.(kopr=135.or.kopr=136.or.kopr=137))
        smnds&p1r=ROUND((smp2r+snp2r-ssp2r)*prndsp2r/100, 2)// ндс с товара
      else
        smnds&p1r=ROUND((sm&p1r+sn&p1r-ss&p1r)*prnds&p1r/100, 2)// ндс с товара
      endif

      if (gnD0k1=0)
        if (vor=3.and.gnKt=1.and.(kopr=135.or.kopr=136.or.kopr=137))
          smndst&p1r=ROUND(smtp2r*prndsp2r/100, 2)// ндс с тары(расход)
        else
          smndst&p1r=ROUND(smt&p1r*prnds&p1r/100, 2)// ндс с тары(расход)
        endif

      endif

      smndsst&p1r=ROUND(smst&p1r*prnds&p1r/100, 2)// ндс со стеклотары
    endif

    if (gnD0k1=1)
      if (prndst&p1r#0)
        smndst&p1r=ROUND(smt&p1r*prndst&p1r/100, 2)// ндс с тары(приход)
      endif

    endif

    smp1r=smp1_r
    sdv&p1r=sm&p1r+smt&p1r+smst&p1r+sn&p1r-ss&p1r+smnds&p1r
    if (tarar=0)
      sdv&p1r=sdv&p1r+smndst&p1r
    endif

    if (pstr=1)
      sdv&p1r=sdv&p1r+smndsst&p1r
    endif

    //        if gnD0k1=0
    //           if prnds&p1r#0
    //              smnds&p1r=(sm&p1r+sn&p1r-ss&p1r)*prnds&p1r/100       // ндс с товара
    //              smndst&p1r=st&p1r*prnds&p1r/100                      // ндс с тары
    //              smndstl&p1r=stl&p1r*prnds&p1r/100                    // ндс со стеклотары
    //           endif
    //        endif
    //        if gnD0k1=1
    //           if prnds&p1r#0
    //              smnds&p1r=(sm&p1r+sn&p1r-ss&p1r)*prnds&p1r/100       // ндс с товара
    //              smndst&p1r=st&p1r*prndst&p1r/100                      // ндс с тары
    //              smndstl&p1r=stl&p1r*prnds&p1r/100                    // ндс со стеклотары
    //           endif
    //        endif
    //         if gnD0k1=0
    //           if tarar=1
    //              if pstr=1
    //                 sdv&p1r=sm&p1r+st&p1r+stl&p1r+sn&p1r-ss&p1r+smnds&p1r+smndstl&p1r
    //              else
    //                sdv&p1r=sm&p1r+st&p1r+stl&p1r+sn&p1r-ss&p1r+smnds&p1r
    //              endif
    //           else
    //              sdv&p1r=sm&p1r+st&p1r+stl&p1r+sn&p1r-ss&p1r+smnds&p1r+smndstl&p1r+smndst&p1r
    //           endif
    //          endif
    //         if gnD0k1=1
    //               if tarar=1
    //                  if pstr=0
    //                     sdv&p1r=sm&p1r+st&p1r+stl&p1r+sn&p1r-ss&p1r+smnds&p1r
    //                  else
    //                     sdv&p1r=sm&p1r+st&p1r+stl&p1r+sn&p1r-ss&p1r+smnds&p1r+smndst&p1r+smndstl&p1r
    //                  endif
    //               else
    //                  if pstr=1
    //                     sdv&p1r=sm&p1r+st&p1r+stl&p1r+sn&p1r-ss&p1r+smnds&p1r+smndst&p1r+smndstl&p1r
    //                  endif
    //               endif
  //         endif
  case (onds&p1r = 1)     //НДС с товара/тары в том числе
    if (prnds&p1r#0)
      smnds&p1r=ROUND((sm&p1r+sn&p1r-ss&p1r)*prnds&p1r/(100+prnds&p1r), 2)
      smndst&p1r=ROUND((smt&p1r)*prnds&p1r/(100+prnds&p1r), 2)
      smndsst&p1r=ROUND((smst&p1r)*prnds&p1r/(100+prnds&p1r), 2)
    endif

    sdv&p1r=sm&p1r+smt&p1r+smst&p1r+sn&p1r-ss&p1r
  case (onds&p1r = 2)     //Без НДС
    smnds&p1r=0
    sdv&p1r=sm&p1r+smt&p1r+smst&p1r+sn&p1r-ss&p1r
  case (onds&p1r = 3)     //НДС с наценки кроме того
    if (prnds&p1r#0)
      smnds&p1r=ROUND((sm&p1r-smur+sn&p1r-ss&p1r)*prnds&p1r/100, 2)
    endif

    sdv&p1r=sm&p1r+smt&p1r+smst&p1r+sn&p1r-ss&p1r+smnds&p1r
  case (onds&p1r = 4)     //НДС с наценки в том числе
    if (prnds&p1r#0)
      smnds&p1r=ROUND((sm&p1r-smur+sn&p1r-ss&p1r)*prnds&p1r/(100+prnds&p1r), 2)
    endif

    sdv&p1r=sm&p1r+smt&p1r+smst&p1r+sn&p1r-ss&p1r
  endcase

  return (.t.)

/*********** */
function s49()
  /*********** */
  if (nofr=1)
    s492r=0
    s493r=0
    sele rs3
    if (netseek('t1', 'ttnr,10'))
      s492r=bssf-ssf
      if (fieldpos('xssf')#0)
        s493r=xssf-ssf
      else
        s493r=0
      endif

    endif

    do case
    case (pr49r=0)
      ssf_r=0
    case (pr49r=1)
      ssf_r=s492r
    case (pr49r=2)
      ssf_r=s493r
    endcase

    sele rs3
    if (netseek('t1', 'ttnr,49'))
      netrepl('ssf,pr', { ssf_r, 0 })
    endif

  endif

  return (.t.)

/*********** */
function s61()
  /*********** */
  if (gnEnt=21.and.kopir=177)
    return (.t.)
  endif

  sele rs3
  if (!(STR(kplr, 7)$"3210425,2842412,3176604,2980308,2070905,1116758"))
    if (netseek('t1', 'ttnr,10'))
      sele rs3
      if (netseek('t1', 'ttnr,61'))
        netrepl('pr,bpr,xpr', { 6, 6, 6 })
      endif

    endif

  endif

  return (.t.)

/*********** */
function s62()
  /*********** */
  if (przr=1)
    return (.t.)
  endif

  if (kopir=177)
    return (.t.)
  endif

  if (kopr#169)
    naclr=getfield('t1', 'kplr', 'kpl', 'nacl')
  else
    if (kplr#nkklr.and.nkklr#0)
      naclr=getfield('t1', 'nkklr', 'kpl', 'nacl')
    else
      naclr=getfield('t1', 'kplr', 'kpl', 'nacl')
    endif

  endif

  /*if naclr#0 */
  sele rs3
  if (netseek('t1', 'ttnr,10'))
    sele rs3
    if (netseek('t1', 'ttnr,62'))
      netrepl('pr,bpr,xpr', { naclr, naclr, naclr })
    endif

  endif

  /*endif */
  return (.t.)

/******************************* */
function lpere(p1)
  /* Перерасчет готовых документов
   *******************************
   */
  // p1=1 Пересчитывается только товар
  // p1=2 Полный перерасчет без удаления пустых статей
  // p1=3 Полный перерасчет с удалением пустых статей
  LOCAL pfKolr

  armoldr=gnArm
  gnArm=3

  if (gnD0k1=1)
    tbl1r='pr1'
    tbl2r='pr2'
    tbl3r='pr3'
    fDocr='mn'
    mDocr='mnr'
    ptr=0
  endif

  if (gnD0k1=0)
    tbl1r='rs1'
    tbl2r='rs2'
    tbl3r='rs3'
    fDocr='ttn'
    mDocr='ttnr'
    pr49r=pr49
  endif

  sele (tbl1r)
  pstr=pst
  vor=vo
  qr=mod(kop, 100)

  sele ldoc3
  zap

  sele (tbl3r)
  pr48r=0
  if (netseek('t1', mDocr))
    while (&fDocr=&mDocr)
      if (ksz=48)
        pr48r=1
      endif

      arec:={}
      getrec()
      sele ldoc3
      appe blank
      putrec()
      sele (tbl3r)
      skip
    enddo

  else
    sele soper
    if (netseek('t1', 'gnD0k1,gnVu,vor,qr'))
      for i=1 to 20
        sele soper
        dszr=FieldGet(FieldPos('dsz'+ltrim(str(i, 2))))//      &dsz_r
        if (dszr=48)
          pr48r=1
        endif

        sele ldoc3
        appe blank
        repl &fDocr with &mDocr, ;
         ksz with dszr
      next

    endif

  endif

  sele tov
  rctovr=recn()
  cntt2r=0                  // Счетчик позиций
  cntt21r=0                 // Счетчик позиций алкоголя
  cntst2r=0                 // Счетчик сертификатов

  sele (tbl2r)
  set orde to tag t1
  rct2r=recn()

  //  cenu  uch   Учетная
  //  cenp1 otp   Отпускная      (1-я прайсовая)
  //  cenp2 dop   Дополнительная (2-я)
  //  cenp3 xotp                 (3-я)

  store 0 to smur, smp1r, smp2r, smp3r// Суммы товара по документу
  store 0 to smtur, smtp1r, smtp2r, smtp3r// Суммы тары по документу
  store 0 to smstur, smstp1r, smstp2r, smstp3r// Суммы стеклотары по документу
  store 0 to sdvur, sdvp1r, sdvp2r, sdvp3r// Общие суммы по документу
  store 0 to cenur, cenp1r, cenp2r, cenp3r// Цены  по позиции
  store 0 to sur, sp1r, sp2r, sp3r        // Суммы по позиции
  store 0 to vsv_r, rvsv_r, kg290_r, ssf12r, ssf19r, sdf_r
  if (netseek('t1', mDocr))
    cntt2r=0
    cntt21r=0
    store 0 to ktl_r, ktlp_r, seu_r, ppt_r, sert_r, kol_r, izg_r, vsv_r, rvsv_r, sdf_r
    pfKolr:=(tbl2r)->(FieldPos(fKolr))
    while (&fDocr=&mDocr)
      store 0 to cenur, cenp1r, cenp2r, cenp3r// Цены  по позиции
      store 0 to sur, sp1r, sp2r, sp3r// Суммы по позиции
      store 0 to kovs_r
      ktl_r=ktl
      kg_r=int(ktl_r/1000000)
      if (vor=9.and.gnD0k1=0.and.(kg_r=290.or.kg_r=460.or.kg_r=280))
        kg290_r=1
      endif

      mntov_rr=mntov
      kol_r:=FieldGet(pfKolr) //  &fkolr   l:1519   // pr2.kf или pr2.kvp
      seu_r=seu
      if (gnD0k1=0)
        sert_r=sert
      endif

      if (fieldpos('prosfo')#0)
        prosfo_r=prosfo
      else
        prosfo_r=0
      endif

      sele tov
      ves_r=0
      vesp_r=0
      keip_r=0
      if (netseek('t1', 'sklr,ktl_r'))
        ves_r=ves
        vesp_r=vesp
        keip_r=keip
        if (mntov=0)
          netrepl('mntov', { mntov_rr })
        endif

        if (gnD0k1=0)
          if (!empty(dopr))
            if (fieldpos('osfo')#0.and.prosfo_r=0)
              netrepl('osfo', { osfo-kol_r })
              if (gnCtov=1)
                sele tovm
                if (netseek('t1', 'sklr,mntov_rr'))
                  netrepl('osfo', { osfo-kol_r })
                endif

              endif

              sele (tbl2r)
              netrepl('prosfo', { 1 })
            endif

          else
            if (fieldpos('osfo')#0.and.prosfo_r=1)
              netrepl('osfo', { osfo+kol_r })
              if (gnCtov=1)
                sele tovm
                if (netseek('t1', 'sklr,mntov_rr'))
                  netrepl('osfo', { osfo+kol_r })
                endif

              endif

              sele (tbl2r)
              netrepl('prosfo', { 0 })
            endif

          endif

        endif

      endif

      kovs_r=1
      if (gnCtov=1)
        kovs_r=getfield('t1', 'kg_r', 'cgrp', 'kovs')
      endif

      sele (tbl2r)

      VesFull(ktl_r, kol_r, kovs_r, ves_r, vesp_r, keip_r, ;
               @sdf_r, @vsv_r, @rvsv_r                      ;
           )

      cenur=getfield('t1', 'sklr,ktl_r', 'tov', 'opt')
      // Зашито для 3-й цены
      // cenp3r=cenur*gnPre
      /********************************************* */
      if (nofr=1.and.int(ktl_r/1000000)<2)
        if (zen=0)
          netrepl('bzen,xzen', { 0, 0 })
        endif

        if (zenp=0)
          netrepl('bzenp,xzenp', { 0, 0 })
        endif

      endif

      cenp1r=zen
      cenp2r=bzen
      if (gnD0k1=0)
        if (pxzenr=1)
          xzenpr=cenur
          if (xzen=0.and.nofr=1.and.int(ktl_r/1000000)>1)//Товар
            if (ndsr=5.or.ndsr=3.or.ndsr=2)
              xzenr=xzenpr
            else
              xzenr=round(xzenpr*1.2, 2)
            endif

            netrepl('xzen,pxzen,xzenp', { xzenr, 0, xzenpr })
          endif

          cenp3r=xzen
        else
          cenp3r=0
        endif

      else
        cenp3r=0
      endif

      sur=ROUND(cenur*kol_r, 2)
      if (subs(nnzr, 1, 3)='Чек')
        if (gnD0k1=0)
          sp1r=svp
        else
          sp1r=round(cenp1r*kol_r, 2)
        endif

      else
        sp1r=round(cenp1r*kol_r, 2)
      endif

      sp2r=round(cenp2r*kol_r, 2)
      sp3r=round(cenp3r*kol_r, 2)

      do case
      case (int(ktl_r/1000000)=0)// Тара
        smtur=smtur+sur
        smtp1r=smtp1r+sp1r
        smtp2r=smtp2r+sp2r
        smtp3r=smtp3r+sp3r
      case (int(ktl_r/1000000)=1)// Стеклотара
        smstur=smstur+sur
        smstp1r=smstp1r+sp1r
        smstp2r=smstp2r+sp2r
        smstp3r=smstp3r+sp3r
      otherwise                      // Товар
        smur=smur+sur
        smp1r=smp1r+sp1r
        smp2r=smp2r+sp2r
        smp3r=smp3r+sp3r
      endcase

      cntt2r++

      if (gnD0k1=0)
        if (gnCtov=1)
          sele cgrp
          if (getfield('t1', 'int(ktl_r/1000000)', 'cgrp', 'tgrp')=1)
            cntt21r++
          endif

        else
          cntt21r=0
        endif

        sele (tbl2r)
        if (sert#0)
          cntst2r++
        endif

      endif

      sele (tbl2r)
      skip
    enddo

  endif

  sdvur=smur+smtur+smstur
  sdvp1r=smp1r+smtp1r+smstp1r
  sdvp2r=smp2r+smtp2r+smstp2r
  sdvp3r=smp3r+smtp3r+smstp3r

  if (p1#1)               // Полный перерасчет
    sele ldoc3
    //  Автоматические статьи
    store 0 to prndsur, prndsp1r, prndsp2r, prndsp3r
    store 0 to prndstur, prndstp1r, prndstp2r, prndstp3r
    store 0 to smndsur, smndsp1r, smndsp2r, smndsp3r
    store 0 to smndstur, smndstp1r, smndstp2r, smndstp3r
    store 0 to smndsstur, smndsstp1r, smndsstp2r, smndsstp3r
    if (gnD0k1=1)         // Приход
      ldoc3add(10, smur, 0, smp1r, 0)
      ldoc3add(19, smtur, 0, smtp1r, 0)
      sele ldoc3
      ssf19r=ssf
      ldoc3add(18, smstur, 0, smstp1r, 0)
      if (gnRoz=1)
        ldoc3add(91, smp2r+smstp2r-smur-smstur, 0, 0, 0)
        ldoc3add(93, smtp2r-smtur, 0, 0, 0)
      endif

      if (netseek('t1', mDocr+',11'))
        smndsur=ssf
        prndsur=pr
        smndsp1r=bssf
        prndsp1r=bpr
      endif

    endif

    if (gnD0k1=0)         // Расход
      ldoc3add(10, smp1r, 0, smp2r, 0, smp3r, 0)
      ls49()
      if (kg290_r=1)
        ls61()
      endif

      if (.f..and.gnEnt=21)
        ls62()
      endif

      ldoc3add(19, smtp1r, 0, smtp2r, 0, smtp3r, 0)
      sele ldoc3
      ssf19r=ssf
      ldoc3add(18, smstp1r, 0, smstp2r, 0, smstp3r, 0)
      if (gnCtov=1)
        sele rs1
        if (bso#0)
          bsor=1
          if (cntt21r-10>0)
            bsor=bsor+int(((cntt21r-10)/21)/1)+iif(mod((cntt21r-10)/21, 1)#0, 1, 0)
          endif

          sele (tbl1r)
          netrepl('bso', { bsor }, 1)
          if (pr48r=1)
            if (cntt21r#0)
              ssf48r=5.0
              //                  ssf48r=4.5
              if (cntt21r-10>0)
              //                     ssf48r=ssf48r+(int(((cntt21r-10)/21)/1)+iif(mod((cntt21r-10)/21,1)#0,1,0))*4.5
              endif

            endif

          else
            sele ldoc3
            if (netseek('t1', 'ttnr,48'))
              netdel()
            endif

          endif

        else
          sele ldoc3
          if (netseek('t1', 'ttnr,48'))
            netdel()
          endif

        endif

      endif

      sele ldoc3
      ldoc3add(96, smur, 0, iif(pbzenr=1, smur, 0), 0, iif(pxzenr=1, smur, 0), 0)
      ldoc3add(97, smtur, 0, iif(pbzenr=1, smtur, 0), 0, iif(pxzenr=1, smtur, 0), 0)
      ldoc3add(94, smstur, 0, iif(pbzenr=1, smstur, 0), 0, iif(pxzenr=1, smstur, 0), 0)
      ldoc3add(98, smp1r-smur, 0, iif(pbzenr=1, smp2r-smur, 0), 0, iif(pxzenr=1, smp3r-smur, 0), 0)
      ldoc3add(99, smtp1r-smtur, 0, iif(pbzenr=1, smtp2r-smtur, 0), 0, iif(pxzenr=1, smtp3r-smtur, 0), 0)
      ldoc3add(95, smstp1r-smstur, 0, iif(pbzenr=1, smstp2r-smstur, 0), 0, iif(pxzenr=1, smstp3r-smstur, 0), 0)
      if (gnRoz=1)
        ldoc3add(91, iif(pbzenr=1, smp2r+smstp2r-smur-smstur, 0), 0, 0, 0)
        ldoc3add(93, iif(pbzenr=1, smtp2r-smtur, 0), 0, 0, 0)
      endif

      store gnNds to prndsur, prndsp1r, prndsp2r, prndsp3r
    endif

    /***************************************************************************** */
    // Остальные статьи
    sele ldoc3
    if (netseek('t1', mDocr))
      store 0 to ssur, ssp1r, ssp2r, ssp3r// Суммы скидок
      store 0 to snur, snp1r, snp2r, snp3r// Суммы наценок
      while (&fDocr=&mDocr)
        store 0 to prur, prp1r, prp2r, prp3r// Проценты статей
        store 0 to ssfur, ssfp1r, ssfp2r, ssfp3r// Суммы статей
        store 0 to ssfur1, ssfp1r1, ssfp2r1, ssfp3r1
        store 0 to ssfur2, ssfp1r2, ssfp2r2, ssfp3r2
        store 0 to prr90, nalr
        sele ldoc3
        if (ksz=11)       // НДС для считается позже
          skip
          loop
        endif

        if (ksz=12 .and.tarar=1 .and.gnD0k1=0)// если поменялся клиент, а расчет был по ksz=12
          dele
          skip
          loop
        endif

        if (ksz=12 .and.pstr=0 .and.gnD0k1=1)// если поменялся клиент, а расчет был по ksz=12
          dele
          skip
          loop
        endif

        kszr=ksz
        if (gnD0k1=0)
          ssfp1r=ssf
          prp1r=pr
          ssfp2r=bssf
          prp2r=bpr
          ssfp3r=xssf
          prp3r=xpr
        else
          ssfur=ssf
          prur=pr
          ssfp1r=bssf
          prp1r=bpr
          if (kszr=12)
            ssfur=round(smtur/100*prur, 2)
            ssfp1r=round(smtp1r/100*prp1r, 2)
            ldoc3add(kszr, ssfur, prur, ssfp1r, prp1r)
            smndstur=ssfur
            smndstp1r=ssfp1r
            prndstur=pr
            prndstp1r=bpr
            sele ldoc3
            ssf12r=ssf
            skip
            loop
          endif

        endif

        sele dclr
        if (netseek('t1', 'kszr'))
          if (&fprr=0.or.kszr=48)// Не автоматическая статья по DCLR
            prr90=pr90
            nalr=nal
            if (prur#0)
              if (nalr#1)
                ssfur=ROUND(smur/100*prur, 2)
              else
                prur=0
              endif

            endif

            if (prp1r#0)
              ssfp1r=ssfp1r1+ssfp1r2
              if (nalr#1)
                ssfp1r=ROUND(smp1r/100*prp1r, 2)
              else
                prp1r=0
              endif

            endif

            if (prp2r#0)
              if (nalr#1)
                ssfp2r=ROUND(smp2r/100*prp2r, 2)
              else
                prp2r=0
              endif

            endif

            if (kszr>=20.and.kszr<39 .and.prr90<>1)// Скидка
              ssur=ssur+ssfur
              ssp1r=ssp1r+ssfp1r
              ssp2r=ssp2r+ssfp2r
              ssp3r=ssp3r+ssfp3r
            endif

            if (kszr>=40.and.kszr<=80 .and.prr90<>1)// Наценка
              snur=snur+ssfur
              snp1r=snp1r+ssfp1r
              snp2r=snp2r+ssfp2r
              snp3r=snp3r+ssfp3r
            endif

            if (gnD0k1=0)
              ldoc3add(kszr, ssfp1r, prp1r, ssfp2r, prp2r, ssfp3r, prp3r)
            else
              ldoc3add(kszr, ssfur, prur, ssfp1r, prp1r)
            endif

          endif

        endif

        sele ldoc3
        skip
        if (kszr#0.and.ksz=kszr)
          dele
          skip
        endif

      enddo

      store 0 to ondsur, ondsp1r, ondsp2r, ondsp3r
      if (gnD0k1=0)
        ondsp1r=ndsr
        ondsp2r=pndsr
        ondsp3r=xndsr
      else
        ondsur=ndsr
        ondsp1r=pndsr
      endif

      if (gnD0k1=0)
        onds('p1r')
        onds('p2r')
        onds('p3r')
        if (tarar=0)
          ldoc3add(12, smndstp1r, prndsp1r, smndstp2r, prndsp2r, smndstp3r, prndsp3r)
          sele ldoc3
          ssf12r=ssf
        endif

        if (pstr=0)
          ldoc3add(11, smndsp1r, prndsp1r, smndsp2r, prndsp2r, smndsp3r, prndsp3r)
        else
          ldoc3add(11, (smndsp1r+smndsstp1r), prndsp1r, (smndsp2r+smndsstp2r), prndsp2r, (smndsp3r+smndsstp3r), prndsp3r)
        endif

      else
        onds('ur')
        onds('p1r')
        if (pstr=0)
          ldoc3add(11, smndsur, prndsur, smndsp1r, prndsp1r)
        endif

        if (pstr=1)
          ldoc3add(11, (smndsur+smndsstur), prndsur, (smndsp1r+smndsstur), prndsp1r)
        endif

      endif

    endif

    /************************************************************************** */

    sele ldoc3
    if (gnD0k1=1)         // Приход
      store 0 to s89uchr, s89otpr, s89dopr
      if (netseek('t1', mDocr+',90'))
        ssfur=ssf
        ssfp1r=bssf
        s89ur=ssfur-sdvur
        s89p1r=ssfp1r-sdvp1r
      else
        ssfur=0
        ssfp1r=0
        s89ur=ssfur-sdvur
        s89p1r=ssfp1r-sdvp1r
      endif

      ldoc3add(89, s89ur, 0, s89p1r, 0)
    else                    // Расход
      ldoc3add(90, sdvp1r, 0, sdvp2r, 0, sdvp3r, 0)
    endif

    if (p1=3)
      if (netseek('t1', mDocr))
        while (&fDocr=&mDocr)
          if (gnD0k1=0)
            if (ssf=0.and.bssf=0.AND.pr=0.AND.bpr=0.AND.xpr=0.AND.xssf=0)
              dele
            endif

          else
            if (ssf=0.and.bssf=0)
              dele
            endif

          endif

          skip
        enddo

      endif

    endif

    sele (tbl1r)
    if (gnArm#6)
      if (gnD0k1=1)
        netrepl('sdv', { ssfur }, 1)
        if (ssf12r=0.and.ssf19r#0)
          netrepl('sdvm,sdvt', { ssfur-ssf19r, ssf19r })
        else
          netrepl('sdvm', { ssfur })
        endif

      else
        netrepl('sdv,vsv,sdf', { sdvp1r, vsv_r, sdf_r }, 1)
        if (fieldpos('vsvb')#0)
          netrepl('vsvb', { rvsv_r }, 1)
        endif

        if (ssf12r=0.and.ssf19r#0)
          netrepl('sdvm,sdvt', { sdvp1r-ssf19r, ssf19r })
        else
          netrepl('sdvm', { sdvp1r })
        endif

        if (ssf12r=0.and.ssf19r#0)
          netrepl('sdvm1', { sdvp2r-ssf19r })
          netrepl('sdvm2', { sdvp3r-ssf19r })
        else
          netrepl('sdvm1', { sdvp2r })
          netrepl('sdvm2', { sdvp3r })
        endif

      endif

    endif

  endif

  if (gnScout=0)
    if (subs(nnzr, 1, 3)#'Чек'.and.armoldr#0)
      if (gnD0k1=1)
        if (pbzenr=1)
          @ 5, 0 say ' По отпускным ценам   : ' + str(sdvp1r, 10, 2)+' '+str(prdecr, 1) color 'g/n,n/g'
        endif

        @ 5, 43 say ' По закупочным ценам  : ' + str(sdvur, 10, 2) color 'g/n,n/g'
        @ 6, 43 say ' Количество позиций   : ' + str(cntt2r, 3) color 'g/n'
      else
        if (gnRmag=0)
          if (pbzenr=1.and.(gnArm=2.or.gnArm=6))
            //@ 5,43 say ' Итого                : ' + str(sdvp1r,10,2) color 'g/n,n/g'
          //@ 6,43 say ' Итого коррекция      : ' + str(sdvp2r,10,2) color 'g/n,n/g'
          else
            @ 3, 52 say str(sdf_r, 5, 0) color 'g/n,n/g'
            @ 3, 62 say 'Вес:' + str(vsv_r, 5, 0)+'('+str(rvsv_r, 5, 0)+')'+'кг' color 'g/n,n/g'
            if (p1=1.and.ndsr=5)
              @ 5, 43 say ' Итого                : ' + str(sdvp1r*1.2, 10, 2) color 'g/n,n/g'
            else
              @ 5, 43 say ' По отпускным ценам   : ' + str(sdvp1r, 10, 2)+' '+str(prdecr, 1) color 'g/n,n/g'
            endif

            if (sdvp2r#0)
              @ 4, 43 say '                        ' + str(sdvp2r, 10, 2) color 'g/n,n/g'
            endif

            if (gnVo#7)
              @ 6, 43 say ' Количество позиций   : ' + str(cntt2r, 3)+iif(cntst2r#0, '('+str(cntst2r, 3)+')', '') color 'g/n'
            else
              @ 6, 43 say ' Количество позиций   : ' + str(cntst2r, 3)+iif(cntst2r#0, '('+str(cntst2r, 3)+')', '') color 'g/n'
            endif

            do case
            case (pr49r=0)
              @ 6, 78 say ' ' color 'g/n,n/g'
            case (pr49r=1)
              @ 6, 78 say str(pr49r+1, 1) color 'gr+/n,n/g'
            case (pr49r=2)
              @ 6, 78 say str(pr49r+1, 1) color 'r+/n,n/g'
            endcase

          endif

        endif

      endif

    endif

  endif

  sele tov
  go rctovr
  sele (tbl2r)
  go rct2r
  sele ldoc3
  go top
  while (!eof())
    kszr=ksz
    ssfr=ssf
    arec:={}
    getrec()
    sele (tbl3r)
    if (netseek('t1', mDocr+',kszr'))
      if (ssfr#0)
        arec1:={}
        getrec('arec1')
        prupdtr=0
        for iput=1 to len(arec)
          if (arec[ iput ]#arec1[ iput ])
            prupdtr=1
            exit
          endif

        next

        if (prupdtr=1)
          reclock()
          putrec()
          netunlock()
        endif

      else
        netdel()
      endif

    else
      if (ssfr#0)
        netadd()
        putrec()
        netunlock()
      endif

    endif

    sele ldoc3
    skip
  enddo

  sele (tbl3r)
  if (netseek('t1', mDocr))
    while (&fDocr=&mDocr)
      kszr=ksz
      if (!netseek('t1', mDocr+',kszr', 'ldoc3'))
        sele (tbl3r)
        netdel()
      endif

      sele (tbl3r)
      skip
    enddo

  endif

  gnArm=armoldr
  return (.t.)

/***************************************************************** */
function ldoc3add(p1, p2, p3, p4, p5, p6, p7)
  /***************************************************************** */
  // p1 - Номер статьи
  // p2 - Сумма ssf
  // p3 - Процент ssf
  // p4 - Сумма bssf
  // p5 - Процент bssf
  // p6 - Сумма xssf
  // p7 - Процент xssf

  private ksz_rr, ssf_rr, bssf_rr, xssf_rr, pr_rr, bpr_rr, xpr_rr

  ksz_rr=p1

  if (p2=nil)
    ssf_rr=0
  else
    ssf_rr=p2
  endif

  if (p3=nil)
    pr_rr=0
  else
    pr_rr=p3
  endif

  if (p4=nil)
    bssf_rr=0
  else
    bssf_rr=p4
  endif

  if (p5=nil)
    bpr_rr=0
  else
    bpr_rr=p5
  endif

  if (p6=nil)
    xssf_rr=0
  else
    xssf_rr=p6
  endif

  if (p7=nil)
    xpr_rr=0
  else
    xpr_rr=p7
  endif

  sele ldoc3
  if (netseek('t1', mDocr+',ksz_rr'))
    if (ssf#ssf_rr.or.bssf#bssf_rr.or.xssf#xssf_rr)
      do case
      case (gnArm=2.or.gnArm=6)
        netrepl('bssf,bpr', { bssf_rr, bpr_rr },, 1)
      case (gnArm=3)
        netrepl('ssf,pr,bssf,bpr,xssf,xpr', { ssf_rr, pr_rr, bssf_rr, bpr_rr, xssf_rr, xpr_rr },, 1)
      endcase

    endif

  else
    if (ssf_rr#0.or.bssf_rr#0.or.xssf_rr#0)
      netAdd()
      do case
      case (gnArm=2.or.gnArm=6)
        netrepl(fDocr+',ksz,bssf,bpr', mDocr+',ksz_rr,bssf_rr,bpr_rr',, 1)
      case (gnArm=3)
        netrepl(fDocr+',ksz,ssf,pr,bssf,bpr', mDocr+',ksz_rr,ssf_rr,pr_rr,bssf_rr,bpr_rr',, 1)
      endcase

    endif

  endif

  return (.t.)

/************* */
function ls49()
  /************* */
  if (nofr=1)
    s492r=0
    s493r=0
    sele ldoc3
    if (netseek('t1', 'ttnr,10'))
      s492r=bssf-ssf
      if (fieldpos('xssf')#0)
        s493r=xssf-ssf
      else
        s493r=0
      endif

    endif

    do case
    case (pr49r=0)
      ssf_r=0
    case (pr49r=1)
      ssf_r=s492r
    case (pr49r=2)
      ssf_r=s493r
    endcase

    sele ldoc3
    if (netseek('t1', 'ttnr,49'))
      netrepl('ssf,pr', { ssf_r, 0 },, 1)
    endif

  endif

  return (.t.)

/*********** */
function ls61()
  /*********** */
  sele ldoc3
  if (!(STR(kplr, 7)$"3210425,2842412,3176604,2980308,2070905,1116758"))
    if (netseek('t1', 'ttnr,10'))
      sele ldoc3
      if (netseek('t1', 'ttnr,61'))
        netrepl('pr,bpr,xpr', { 6, 6, 6 },, 1)
      endif

    endif

  endif

  return (.t.)

/*********** */
function ls62()
  /*********** */
  naclr=getfield('t1', 'kplr', 'kpl', 'nacl')
  if (naclr#0)
    sele ldoc3
    if (netseek('t1', 'ttnr,10'))
      sele ldoc3
      if (netseek('t1', 'ttnr,62'))
        netrepl('pr,bpr,xpr', { naclr, naclr, naclr },, 1)
      endif

    endif

  endif

  return (.t.)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  11-06-17 * 04:24:04pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
function VesFull(ktl_r, kol_r, kovs_r, ves_r, vesp_r, keip_r, ;
                  sdf_r, vsv_r, rvsv_r                         ;
              )
  rvsv_r=rvsv_r+round(kol_r*ves_r, 3)
  if (str(keip_r, 3) $ '800;166;')
    sdf_r=sdf_r+ROUND(kol_r*vesp_r, 3)
  endif

  if (kovs_r=0)           // объемный вес
    do case
    case (int(ktl_r/1000000)=350)
      vsv_r=vsv_r+ROUND(kol_r*ves_r*1.50, 3)
    case (int(ktl_r/1000000)=341)
      vsv_r=vsv_r+ROUND(kol_r*ves_r*1.67, 3)
    case (int(ktl_r/1000000)=252)
      vsv_r=vsv_r+ROUND(kol_r*ves_r*2.5, 3)
    case (int(ktl_r/1000000)=330)
      vsv_r=vsv_r+ROUND(kol_r*ves_r*0.85, 3)
    case (int(ktl_r/1000000)=329)
      vsv_r=vsv_r+ROUND(kol_r*ves_r*0.85, 3)
    otherwise
      vsv_r=vsv_r+ROUND(kol_r*ves_r, 3)
    endcase

  else
    vsv_r=vsv_r+ROUND(kol_r*ves_r*kovs_r, 3)
  endif

  return (nil)

  /*
      rvsv_r=rvsv_r+round(kol_r*ves_r,3)
      if str(keip_r,3) $ '800;166'
         sdf_r=sdf_r+ROUND(kol_r*vesp_r,3)
      endif
      if kovs_r=0
         do case
          case int(ktl_r/1000000)=350
                vsv_r=vsv_r+ROUND(kol_r*ves_r*1.50,3)
          case int(ktl_r/1000000)=341
                vsv_r=vsv_r+ROUND(kol_r*ves_r*1.67,3)
          case int(ktl_r/1000000)=252
                vsv_r=vsv_r+ROUND(kol_r*ves_r*2.5,3)
          case int(ktl_r/1000000)=330
                vsv_r=vsv_r+ROUND(kol_r*ves_r*0.85,3)
          case int(ktl_r/1000000)=329
                vsv_r=vsv_r+ROUND(kol_r*ves_r*0.85,3)
          othe
                vsv_r=vsv_r+ROUND(kol_r*ves_r,3)
         endc
      else
         vsv_r=vsv_r+ROUND(kol_r*ves_r*kovs_r,3)
      endif
  */

***************
func DocPereRs()
***************
  if reclock(1)
     prz_rr=prz
     prz_r=prz
     przr=prz
     sklr=skl
     Ttnr=ttn
     dvpr=dvp
     dopr=dop
     vor=vo
     gnVo=vor
     kopr=kop
     kopir=kop
     if gnEnt=21
        if kopi=177
           kopir=kopi
        endif
     endif
     pstr=pst
     prcorr=1
     kplr=kpl
     nkklr=nkkl
     kpsbbr=getfield('t1','kplr','kps','prbb')
     kgpr=kgp
     kpvr=kpv
     sdv1r=sdv
     rmskr=rmsk
     nnzr=nnz
     store '' to coptr,cboptr,cuchr,cotpr,cdopr
     store 0 to nofr,pxzenr,ndsr,pndsr,xndsr,pbzenr,gnRmag,prc177r,MnTov177r
     store 0 to onofr,opbzenr,opxzenr,;
                otcenpr,otcenbr,otcenxr,;
                odecpr,odecbr,odecxr
     if inikop(gnD0k1,1,vor,kopr)
        tbl1r='rs1'
        tbl2r='rs2'
        tbl3r='rs3'
        mDocr='Ttnr'
        fDocr='ttn'
        fKolr='kvp'
        fPrr='pr'
        sele tara
        tarar=tarar()
        rs2pzen(1)
        if pr61r=1
           if smksz61r#0
              sele rs3
              set orde to tag t1
              if !netseek('t1','Ttnr,61')
                 netadd()
                 netrepl('ttn,ksz',{Ttnr,61})
              endif
              netrepl('ssf,bssf,xssf',{smksz61r,smksz61r,smksz61r})
           else
              if prksz61r#0
                 sele rs3
                 set orde to tag t1
                 if !netseek('t1','Ttnr,61')
                    netadd()
                    netrepl('ttn,ksz',{Ttnr,61})
                 endif
                 netrepl('pr,bpr,xpr',{prksz61r,prksz61r,prksz61r})
              endif
           endif
        endif
        pere(2)
     else
        ?str(Ttnr,6)+' нет inikop'
     endif
  else
     ?str(Ttnr,6)+' нет блокировки'
  endif
  return .t.

****************
func DocTPereRs()
****************
  if reclock(1)
     prz_rr=prz
     prz_r=prz
     przr=prz
     sklr=skl
     Ttnr=ttn
     dvpr=dvp
     dopr=dop
     vor=vo
     kopr=kop
     kopir=kop
     pstr=pst
     prcorr=1
     kplr=kpl
     nkklr=nkkl
     kpsbbr=getfield('t1','kplr','kps','prbb')
     kgpr=kgp
     kpvr=kpv
     sdv1r=sdv
     rmskr=rmsk
     nnzr=nnz
     store '' to coptr,cboptr,cuchr,cotpr,cdopr
     store 0 to nofr,pxzenr,ndsr,pndsr,xndsr,pbzenr,gnRmag,prc177r,MnTov177r
     store 0 to onofr,opbzenr,opxzenr,;
                otcenpr,otcenbr,otcenxr,;
                odecpr,odecbr,odecxr
     if inikop(gnD0k1,1,vor,kopr)
        tbl1r='rs1'
        tbl2r='rs2'
        tbl3r='rs3'
        mDocr='Ttnr'
        fDocr='ttn'
        fKolr='kvp'
        fPrr='pr'
        tarar=tarar()
        pere(2)
     else
        ?str(Ttnr,6)+' нет inikop'
     endif
  else
     ?str(Ttnr,6)+' нет блокировки'
  endif
  return .t.

***************
func PrPere()
  ***************
  if reclock(1)
     prz_rr=prz
     prz_r=prz
     przr=prz
     sklr=skl
     mnr=mn
     ndr=nd
     dvpr=dvp
     vor=vo
     gnVo=vor
     kopr=kop
     kpsr=kps
     sdvr=sdv
     rmskr=rmsk
     nnzr=nnz
     store '' to coptr,cboptr,cuchr,cotpr,cdopr
     store 0 to nofr,pxzenr,ndsr,pndsr,xndsr,pbzenr,gnRmag,prc177r,MnTov177r
     store 0 to onofr,opbzenr,opxzenr,;
                otcenpr,otcenbr,otcenxr,;
                odecpr,odecbr,odecxr
     if inikop(1,1,vor,kopr)
        tbl1r='pr1'
        tbl2r='pr2'
        tbl3r='pr3'
        mDocr='mnr'
        fDocr='mn'
        fKolr='kf'
        fPrr='pr'
        tarar=tarar()
        pere(2)
     else
        outlog(__FILE__,__LINE__,str(Ttnr,6)+' нет inikop')
     endif
  else
     outlog(__FILE__,__LINE__,str(Ttnr,6)+' нет блокировки')
  endif
  return .t.


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  04-04-18 * 09:00:59pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION tarar(kplr)
  LOCAL tarar
  if !(kplr=20034.or.kplr=30001.or.kplr=30003.or.kplr=30004.or.kplr=30005)
    tarar=1
  else
    tarar=0
  endif
  RETURN (tarar)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  11-05-19 * 03:44:57pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION RndSdvr()
  LOCAL RndSdvr:=2
  If !empty((tbl1r)->(FieldPos("RndSdv")))
    If (tbl1r)->RndSdv = 0
      (tbl1r)->(netrepl('RndSdv','2'))
    EndIf
    RndSdvr := (tbl1r)->RndSdv
  EndIf
  RETURN (RndSdvr)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  11-05-19 * 04:25:48pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION s43(nS10,nS11, nRndSdv)
  LOCAL nSdv4Ttn := ROUND(nS10 + nS11,2)
  LOCAL nNewSdv4Ttn:=Round(nSdv4Ttn,nRndSdv) // цель получить сумму
  LOCAL nTaxNds:=20
  LOCAL nNoNdsSdv10    := round(nSdv4Ttn/(100+nTaxNds)*100,2) // без НДС
  LOCAL nNoNdsNewSdv10 := round(nNewSdv4Ttn/(100+20)*100,2) // без НДС новая
  LOCAL nSum43         := ROUND(nNoNdsNewSdv10 - nNoNdsSdv10,2)   // разница между ними.

  nS10 := ROUND(nNoNdsSdv10 + nSum43,2) // товар + окр
  nS11 := round(nS10/100*nTaxNds,2) // ндс

  If round(nS10+nS11,2) # round(nS10+nS11,nRndSdv)

    Do While nSdv4Ttn # Round(nSdv4Ttn,nRndSdv)

      nNewSdv4Ttn := round(nNoNdsSdv10 + nSum43,2) // товар + округ
      nNds11   := round(nNewSdv4Ttn/100*nTaxNds,2)
      nNewSdv4Ttn := ROUND(nNewSdv4Ttn + nNds11,2)

      nSum43 += 0.01
      nSdv4Ttn := nNewSdv4Ttn
    EndDo
  EndIf

  RETURN (nSum43)
