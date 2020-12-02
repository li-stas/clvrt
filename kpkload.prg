#define _T CHR(9)
#translate  NTRIM(< v1 >) => LTRIM(STR(< v1 >))

#ifdef __CLIP__
#else
  #translate  DTOC(< v1 >, <v2>) => ;
  (iif(<v2> = NIL,DTOC(<v1>),;
    (;
    _sdtf:=Set(_SET_DATEFORMAT,<v2>);
    ,_cDtoC:=DTOC(<v1>);
    ,Set(_SET_DATEFORMAT,_sdtf);
    ,_cDtoC;
  );
 ))
  #translate  CTOD(< v1 >, <v2>) => ;
  (iif(<v2> = NIL,CTOD(<v1>),;
    (;
    _sdtf:=Set(_SET_DATEFORMAT,<v2>);
    ,_cCtoD:=CTOD(<v1>);
    ,Set(_SET_DATEFORMAT,_sdtf);
    ,_cCtoD;
  );
 ))
#endif


/*
GUID_KPK("C", - клиенты
GUID_KPK("B" - тогровые агеты
GUID_KPK("A"  - товар
GUID_KPK("F" - доки кассы
GUID_KPK("D"  - доки ТТН
GUID_KPK("D0"  - договора
GUID_KPK("CAC"  - код торг агетра
GUID_KPK("С0" - категория
GUID_KPK("AD5" - код операции
GUID_KPK("CA1" - тип торг точки

*/
//FUNCTION main()
//set("PRINTER_CHARSET", "cp866")
LOCAL dSHDATEBG, dSHDATEEND

set(_SET_FILECREATEMODE, "664")
set(_SET_DIRCREATEMODE, "775")
#ifdef __CLIP__
   set translate path ON
#endif
set autopen ON
set optimize OFF

rddSetDefault("DBFCDX")
  dSHDATEBG  := STOD("20061115")-(7*3) //три недели назад
  dSHDATEEND := STOD("20061115")-7

kpk_load()
//RETURN

FUNCTION kpk_load(ktar,nAgSk,cFio,dShDateBg, dShDateEnd, aKop,;
     nRef_Price,nDoc_Debt,nRef_Sales,nRef_Routes, nRef_Ini)

  LOCAL oRef_System
  LOCAL cktar:=PADL(LTRIM(STR(ktar,3)), 3, "0")
  LOCAL aLoadFile

  set("PRINTER_CHARSET","cp1251")
  SET DATE FORMAT "yyyy-mm-dd"
  SET CENTURY ON

  USE (gcPath_ew+"deb\deb") ALIAS deb NEW SHARED
  SET ORDER TO TAG t1

  IF gnEnt=20
    USE (gcPath_ew+"deb\accord_deb") ALIAS skdoc NEW SHARED READONLY
    SET ORDER TO TAG t1
  else
    USE (gcPath_ew+"deb\skdoc") ALIAS skdoc NEW SHARED READONLY
    SET ORDER TO TAG t1
  endif
     //index on str(kpl)+str(ktan) tag t1


  USE (gcPath_ew+"deb\bdoc") ALIAS bdoc  NEW SHARED
  SET ORDER TO TAG t1

  USE ('k'+cktar+'pcen.dbf')  ALIAS PersonalPrice NEW EXCLUSIVE

  USE ('k'+cktar+'cnfr.dbf') ALIAS Confirm NEW EXCLUSIVE

  USE ('k'+cktar+'mrch.dbf') ALIAS Merch NEW EXCLUSIVE
  IF FILE('k'+cktar+'mrch.cdx')
    ERASE ('k'+cktar+'mrch.cdx')
  ENDIF
  INDEX ON STR(Kpl)+STR(Kgp)+STR(MNTOV)+STR(WEEK(Dop),2) TAG KGp_MnTov
  INDEX ON STR(Kpl)+STR(Kgp)+STR(MNTOVT)+STR(WEEK(Dop),2) TAG KGp_MnTovT

  USE ('k'+cktar+'sale.dbf') ALIAS Sales NEW EXCLUSIVE
  IF FILE('k'+cktar+'sale.cdx')
    ERASE ('k'+cktar+'sale.cdx')
  ENDIF
  INDEX ON STR(Kpl)+STR(Kgp)+STR(MNTOV)+STR(WEEK(Dop),2) TAG KGp_MnTov
  INDEX ON STR(Kpl)+STR(Kgp)+STR(MNTOVT)+STR(WEEK(Dop),2) TAG KGp_MnTovT

  USE ("k"+cktar+"ost") ALIAS price_full NEW EXCLUSIVE
  IF FILE('k'+cktar+'ost.cdx')
    ERASE ('k'+cktar+'ost.cdx')
  ENDIF
  INDEX ON STR(mkeep)+STR(INT(MnTov/10^4),3)+Nat TAG Nat
  INDEX ON nmkeep+STR(INT(MnTov/10^4),3)+Nat TAG mnkeep

  USE ("k"+cktar+"ot") ALIAS price NEW EXCLUSIVE
  IF FILE('k'+cktar+'ot.cdx')
    ERASE ('k'+cktar+'ot.cdx')
  ENDIF
  INDEX ON STR(mkeep)+STR(INT(MnTov/10^4),3)+Nat TAG Nat
  INDEX ON nmkeep+STR(INT(MnTov/10^4),3)+Nat TAG mnkeep

  USE ("k"+cktar+"firm") ALIAS TPoints NEW EXCLUSIVE
  IF FILE('k'+cktar+'firm.cdx')
    ERASE ('k'+cktar+'firm.cdx')
  ENDIF
  INDEX ON STR(KPL)+STR(KGP) TAG "kgp_kpl"

  //торговые точки
  TOTAL ON STR(KPL)+STR(KGP) TO tmp_ktt
  //клиеты
  TOTAL ON STR(KPL) TO tmp_kpl
  //CLOSE TPoints

  USE tmp_ktt NEW EXCLUSIVE
  USE tmp_kpl NEW EXCLUSIVE

  tmp_kpl->(AddKplKgpSkDoc())


  //какие цены грузить
  aPrice:=PriceType2Kop("Price")
         //витрина  152
  oRef_System:=Ref_System_ini(nRef_Ini, ktar, nAgSk, cFio,dShDateBg, dShDateEnd,aPrice)
  RSSave(oRef_System)

  Ref_Sales(nRef_Sales, dShDateBg, dShDateEnd)

  Ref_TblStruct(nRef_Ini)

  Doc_Move(nDoc_Debt,ktar)
  Doc_Sale(nDoc_Debt)
  Doc_Debt(nDoc_Debt,ktar)
  Doc_Cash(nDoc_Debt)

  Ref_Routes(nRef_Routes)
  Ref_Clients(nRef_Routes,aKop)
  Ref_TPoints(nRef_Routes)


  IF STR(s_tag->Ref_Price) $ "7,8" //s_tag->Dt_Price#DATE()
    //передаем новые цены и новые индивидуальные цены
    Ref_Price(nRef_Price,aPrice)
    Ref_GoodsStock(0)
  ELSE
    //передаем новые цены
    Ref_Price(0,aPrice)
    Ref_GoodsStock(nRef_Price)
    //новые остатки
  ENDIF

  IF (STR(s_tag->Ref_Price) $ "7,8" .AND. ; //s_tag->Dt_Price#DATE() .AND.;
     !EMPTY(nRef_Price)) .OR. !EMPTY(nRef_Routes)
    Ref_PersonalPrices(nRef_Price+nRef_Routes)
  ELSE
    Ref_PersonalPrices(0)
  ENDIF

  Ref_Barcodes()
  Ref_Firms(nRef_Ini)
  Ref_Stores(nRef_Ini)
  Ref_Sertif(nRef_Ini)

  Ref_Commands(.T.) //nRef_Ini)

  Ref_Confirm()

  Ref_AttrTypes(nRef_Ini,aKop)
  Ref_PrnScripts(nRef_Ini)
  Ref_FirmsPrnLinks(nRef_Ini)
  Ref_RepScripts(nRef_Ini)
  Ref_FillDocScripts(nRef_Ini)
  Ref_Scripts(nRef_Ini)

//set translate path OFF

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO From1C.dat

  IF .F. .AND. ktar=688
    QQOUT("agentp_data"+_T+"to_ppc"+_T+"k"+LTRIM(STR(688)))
  ELSE
    QQOUT("agentp_data"+_T+"to_ppc"+_T+"Основная")
  ENDIF


  //QQOUT("agentp_data"+_T+"to_ppc"+_T+"Продресурс")
  QOUT("")
  SET PRINT TO
  SET PRINT OFF

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO QOUT.dat
  QOUT("")
  SET PRINT TO
  SET PRINT OFF

  FILEAPPEND("Ref_System.txt","From1C.dat")
  FILEAPPEND("QOUT.dat","From1C.dat")

  aLoadFile:={"Ref_Sales.txt",;
  "Ref_TblStruct.txt",;
  "Doc_Move.txt",;
  "Doc_Sale.txt",;
  "Doc_Debt.txt",;
  "Doc_Cash.txt",;
  "Ref_Routes.txt",;
  "Ref_Clients.txt",;
  "Ref_TPoints.txt",;
  "Ref_Price.txt",;
  "Ref_GoodsStock.txt",;
  "Ref_PersonalPrices.txt",;
  "Ref_Barcodes.txt",;
  "Ref_Firms.txt",;
  "Ref_Stores.txt",;
  "Ref_Commands.txt",;
  "Ref_Sertif.txt",;
  "Ref_AttrTypes.txt",;
  "Ref_Confirm.txt",;
  "Ref_PrnScripts.txt",;
  "Ref_FirmsPrnLinks.txt",;
  "Ref_RepScripts.txt",;
  "Ref_FillDocScripts.txt",;
  "Ref_Scripts.txt"}

//outlog(__FILE__,__LINE__,ktar, s_tag->kod)

   AEVAL(aLoadFile,{|cFile| IIF(FILESIZE(cFile)=0,;
   (NIL),;//(outlog(__FILE__,__LINE__,FILE(cFile),cFile,FILESIZE(cFile))),;
    (;
    ;//outlog(__FILE__,__LINE__,FILE(cFile),cFile,FILESIZE(cFile)),;
    FILEAPPEND(cFile,"From1C.dat"),;
    FILEAPPEND("QOUT.dat","From1C.dat");
  );
  )})

  CLOSE deb
  CLOSE skdoc
  CLOSE bdoc

  CLOSE PersonalPrice
  CLOSE Confirm
  CLOSE Merch

  CLOSE Sales
  CLOSE price
  CLOSE price_full
  CLOSE tmp_ktt
  CLOSE tmp_kpl
  CLOSE TPoints

  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  16.11.06 * 13:28:59
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Ref_System_ini(nRun,ktar, nAgSk,cFio,dShDateBg, dShDateEnd,aPrice)
#ifdef __CLIP__
  LOCAL oObj:=map()
#endif
  //Дата и время выгрузки данных. Значение этой константы должно включаться
  //в каждый файл выгрузки.
  oObj:GUID_SYSTEM_TIMEUNLD:={ DTOC(DATE())+" "+CHARREPL(":", TIME(), "-"), "5A9D4A4C-CC7A-49F8-8C4E-6E23B964CACB" }
  //"2006-10-15 15-12-36"

    //Дата начала периода истории продаж, выгружаемой в файле.
    oObj:GUID_SYSTEM_SHDATEBG:={ DTOC(LastMonday(dSHDATEBG)), "3935BEAE-9F40-4BA5-BA9E-03F860CC1750" }
    //
    //Дата конца периода истории продаж, выгружаемой в файле
    oObj:GUID_SYSTEM_SHDATEND:={ DTOC(LastMonday(dShDateEnd)+7-2), "3343E400-1577-4DDE-9A82-BF1E53267FD6" }

  IF !EMPTY(nRun)
    //константа = 1, то программа проверяет для документов "Заявка", "Реализация"
    //и "Реализация розничная" выбор документа "Мерчендайзинг" в поле "Мерчендайзинг"
    //закодки дополнительно. Если д-нт не выбран, то программа предупреждает о
    //необходимости выбрать док-нт мерчендайзинга и не открывает окно подбора. Такая
    //же проверка сделана и при попытке заполнить табличную часть док-та ч.з.
    //контекстное меню табличной части.
    //Снятие режима проверки включается при выгрузке в КПК этой контанты со значением "0"
    IF gnEnt=20
      oObj:GUID_SYSTEM_DOCMERCHSEL:={"1","19AB0B3D-EE81-461B-91E8-C47C5E76E324"}
    ELSE
      oObj:GUID_SYSTEM_DOCMERCHSEL:={"0","19AB0B3D-EE81-461B-91E8-C47C5E76E324"}
    ENDIF
    //
    //заКонстанта используется для выгрузки в КПК сокращенного названия единицы
    //измерения веса по умолчанию. Если значение константы не указано, то ее
    //значение устанавливается в "кг".
    oObj:GUID_SYSTEM_WEIGHT_UNIT:={"кг","CF527139-1867-4A66-8C44-ABD2D9AE202C"}
    //
    //Подпись к строке названия истории остатков товаров (истории
    //мерчендайзинга). Если значение константы не указано, то ее значение
    //устанавливается в "Мерч.:" (т.е. "мерчендайзинг").
    oObj:GUID_SYSTEM_MERCH:={"Мерч.","3A27217E-46BD-449E-8C95-574076DB9087"}
    //
    //ФИО торгового агента, для которого предназначены выгружаемые данные.
    oObj:GUID_SYSTEM_AGENTNAME:={ ;
    ALLTRIM(PADL(LTRIM(STR(ktar,3)), 3, "0"))+ALLTRIM(STR(nAgSk,3))+" "+;
    cFio, "FB55C4DC-885C-4D39-AB62-44FBAE50F1AC" }
    //
    //Идентификатор торгового агента.
    oObj:GUID_SYSTEM_AGENTID:={ GUID_KPK("B",ALLTRIM(PADL(LTRIM(STR(ktar,3)), 3, "0"))+ALLTRIM(STR(nAgSk,3))), "A2F737BD-37CD-4F08-910B-9E2A130226D4" }
    //
    //Идентификатор фирмы по умолчанию. Фирма проставляется автоматически в каждый
    //новый создаваемый документ.
    oObj:GUID_SYSTEM_FIRMID:={ "8FC6CB94-AEFD-4498-951C-7BAEA9298658", "30AC90F6-99D2-439f-8AA2-007FF391DEA4" }
    //код "ПродРесурса"
    //
    //Список скидок в документе "Заявка". Например: "0, 1, 2.5, 3, 5". Если
    //значение константы пустое (например, значение "пробел"), тогда пользователь
    //в КПК может указывать скидку не выбирая ее из списка, а в виде числового
    //значения, вводя его с клавиатуры.
    //Скидка указывается с точностью от 0 до 4 знаков после запятой.
    //Желательно скидки располагать в порядке возрастания. Количество скидок
    //ограничивается размером строки списка скидок - она не должна превышать 128
    //символов.
    oObj:GUID_SYSTEM_DISCOUNTS:={ "0", "AA82CC96-4485-4351-98D8-BCF2EFFB5F7D" }
    //7D  0,3,4,5,5.5,7,10
    //

    //Дата и время выгрузки данных. Значение этой константы должно включаться
    //в каждый файл выгрузки.
    oObj:GUID_SYSTEM_TIMEUNLD:={ DTOC(DATE())+" "+CHARREPL(":", TIME(), "-"), "5A9D4A4C-CC7A-49F8-8C4E-6E23B964CACB" }
    //"2006-10-15 15-12-36"

    //
    //Количество знаков после запятой для указания дробного количества товара
    //(от 0 до 4 знаков). В КПК при подборе товара в документы (или при
    //редактировании количества товара в документе) допускается  указание дробных
    //количеств только для товаров, у которых
    //имеется признак "Весовой" (см. раздел 2.8 "Тэг Ref_Price" на стр. 23).
    oObj:GUID_SYSTEM_AMNTPRECISION:={ "1", "0980573E-CA63-4C1D-941D-09218063BF40" }
    //
    //Название национальной валюты (не более трех символов). Если константа не
    //указана, то название валюты устанавливается как "руб".
    oObj:GUID_SYSTEM_MONEYNAME:={ "грн", "28C8F78E-61BB-4F8A-AA5E-E242B680067B" }
    //
    //Используется для указания внутренних настроек Агент+. В константе
    //указываются значения нескольких параметров, влияющих на работу Агент+.
    //В константе указываются следующие параметры:
    //discount - принимает значения, которые получаются сложением числовых величин,
    //             описываемых ниже:
    //1 - в документах "Заявка" и "Реализация" применяется наценочный алгоритм
    //     расчета скидки: (X * 100 / (100+Скидка), иначе в документах применяется
    //     стандартный алгоритм расчета скидки: (X * (100-Скидка) / 100)
    //     (значение по умолчанию - 0);
    //2 - в документах "Заявка" и "Реализация" возможно указание скидки для
    //    каждого товара в табличной части, иначе скидка указывается только
    //    на весь документ;
    //4 - в документах "Заявка" и "Реализация" расчет скидки идет от суммы
    //    товаров в каждой строке документов, иначе расчет скидки идет от
    //    цены товара в каждой строке документа.
    //Пример использования параметра discount.
    //Если в константе указано значение "discount=6" (результат суммы 2+4),
    //то это означает, что в документах используется стандартный алгоритм расчета
    //скидки, возможно указание скидок для каждого товара в табличной части,
    //расчет скидки идет от суммы товара в каждой строке.
    //
    //fltgoods - параметр задает режим использования персональных фильтров товаров
    // при подборе товаров в документы. Фильтр товаров устанавливается персонально
    // в зависимости от выбранного в документе клиента или торговой точки.
    //Возможные значения параметра:
    //0 - не использовать персональные фильтры товаров;
    //1 - товары, отвечающие фильтру, показываются подчеркнутыми в окне подбора
    //    товаров;
    //2 - товары, не отвечающие фильтру, не показываются в окне подбора товаров.
    //4 - включается фильтр условий ИЛИ, иначе включается фильтр условий И.
    //Как задавать значения персональных фильтров товаров описано в разделах
    //2.4 "Тэг Ref_Clients" и "2.5 Тэг Ref_TPoints".
    oObj:GUID_SYSTEM_FLAGS:={ "discount=6 fltgoods=1", "A44AFE59-9F8B-47D8-BB94-4CB447170EF2" }
    //oObj:GUID_SYSTEM_FLAGS:={ "discount=4 fltgoods=1", "A44AFE59-9F8B-47D8-BB94-4CB447170EF2" }
    //
    //
    //Используется для передачи в КПК идентификатора передвижного склада, который
    //закреплен за торговым агентом. Константа используется только в "Инвент"
    oObj:GUID_SYSTEM_MSTOREID:={ NIL, "2AEBEC0B-20B0-46f1-99D9-20661AEDA77A" }
    //
    //Максимальное количество типов цен, используемых в прайс-листе.
    //Если константа не указана, то ее значение считается равным 10. Максимально
    //допустимое количество типов цен в Агент+ - не более 32 типа цен.
    //Рекомендуется указывать только используемое количество типов цен -
    //чем меньше значение этой константы, тем меньше будет объем БД в КПК.
    //Важно! Константу в файле выгрузки следует всегда указывать перед тэгом
    //Ref_Price (не обязательно сразу перед тэгом - достаточно, чтобы значение
    //константы в файле выгрузки было объявлено до начала тэга Ref_Price).
    //Смотрите так же раздел 2.8 "Тэг Ref_Price".
    oObj:GUID_SYSTEM_PRICECOUNT:={ LTRIM(STR(LEN(aPrice),2)), "8166BF59-8507-45B3-AF14-A3D111DBC61C" }
    //
    //Смещение в часах для автоматического расчета времени доставки товара.
    //Значение константы используется для автоматического проставления времени
    //доставки товаров в документах "Заявка". При создании нового документа в
    //КПК к текущему системному времени в КПК прибавляется значение этой константы
    //и таким образом рассчитывается примерные дата и время доставки товара,
    //которое проставляется в документе в реквизите "Время доставки". Допустимо
    //нулевое значение константы - в этом случае пользователю всегда требуетс
    //я указывать время доставки самостоятельно.
    oObj:GUID_SYSTEM_TIMEDLVDISP:={ "24", "24EB38BB-DD8E-4816-9A29-9DA53EEB6BAE" }
    //
    //Количество знаков после запятой для указания дробных значений скидок
    //(от 0 до 4 знаков) в документах и справочнике клиентов. Если константа в
    //тэге не указана, то ее значение приравнивается к 1. Значение константы
    //учитывается только если в Агент+ включен числовой режим ввода скидок
    //(смотрите выше описание константы oObj:GUID_SYSTEM_DISCOUNTS).
    oObj:GUID_SYSTEM_DSCNTRECISION:={ NIL, "24EB38BB-DD8E-4816-9A29-9DA53EEB6BAE" }
    //
    //Основная ставка НДС в процентах. Если константа не указана, то значение
    //константы приравнивается к 18.
    oObj:GUID_SYSTEM_VATRATE:={ "20", "EE7AE207-9BE2-4494-85C8-433DB1AEA735" }

    //
    //Указанные в константе телефонные номера показываются в КПК в окне
    //"О программе" в виде меню набора телефонного номера при нажатии на кнопку
    //"Звонок авторам". Если телефонных номеров несколько, их можно указывать
    //через запятую.
    //Если Агент+ устанавливается на коммуникатор**, данная функция полезна для
    //возможности пользователю быстро связаться с фирмой, внедрившей Агент+
    //клиенту.
    oObj:GUID_SYSTEM_AUTHOR_TEL:={ "+380972137756", "2D9C4ED7-6CC4-4145-8721-F344BC24E1FA" }

    //
    //Рекомендуемое время (в секундах), затрачиваемое на упаковку прайс-листа в
    //КПК (упаковка прайс-листа запускается всегда перед загрузкой в КПК тэга
    //Ref_Price в режиме Full). Если время, затрачиваемое КПК на упаковку
    //прайс-листа, превышает рекомендуемое, то КПК после загрузки данных
    //показывает пользователю в информационном окне рекомендации для повышения
    //скорости загрузки данных в КПК. Значение константы никак не влияет на
    //результат загрузки всех данных в КПК - все данные из файла загружаются
    //корректно в любом случае.
    //Если константа в тэге не указана, то ее значение приравнивается к 60
    //секундам.
    oObj:GUID_SYSTEM_PRICEPACKTIME:={ "60", "F83718D6-C6E8-404A-AFF5-B4D3A3F9503F" }


    //
    //Путь к папке картинок товаров в КПК. Значение данной константы используется
    //при показе в КПК картинок товаров. Смотрите так же раздел 2.13
    //"Тэг Ref_GoodsPictures".
    oObj:GUID_SYSTEM_GOODS_PICT_PATH:={ NIL, "FA6B30C2-1D7F-46EC-8EAD-0979D2965747" }

  ENDIF

  RETURN (oObj)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  16.11.06 * 13:42:11
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION RSSave(oRef_System)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_System.txt

  qqout('<Begin>'+_T+'Ref_System'+_T+'Struct:ObjID,Value')
#ifdef __CLIP__
  FOR elem IN oRef_System
    IF (elem[ 1 ]#NIL)
      qout(elem[ 2 ]+_T+elem[ 1 ])
    ENDIF

  NEXT
#endif

  qout('<End>'+_T+'Ref_System')
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  20.11.06 * 12:18:33
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Ref_Sales(nRun, dSHDATEBG, dShDateEnd)
  LOCAL nKgp, nKpl, nMnTov, nQRest, i, nCurWeek, nCurWeekFor
  LOCAL cSales, nSales
  LOCAL aDt_Range,k

  /*
  IF DOW(dShDateEnd) >= 2 //воскр, пон
    dShDateEnd:=LastMonday(dShDateEnd)-2 //перейдем в пред неделю
  ELSE
    dShDateEnd:=dShDateEnd - 3 //перейдем в пред неделю
  ENDIF
  */

    dShDateBg:=LastMonday(dShDateBg) //понедельник этой недели
    dShDateEnd:=LastMonday(dShDateEnd)+7-2 //суббота анализируемой недели

  //SEEK(STR(2399705))
  //BROWSE()

  //TOTAL ON STR(Kgp)+STR(MNTOV) FIELDS KVP TO KGp_MnTov
  //USE KGp_MnTov NEW

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_Sales.txt

  IF !EMPTY(nRun)
    QQOUT('<Begin>'+_T+'Ref_Sales'+_T+'Struct:TPointID,GoodsID,Sales')

    SELE tmp_ktt //торговые точки
    DBGOTOP()
    DO WHILE !EOF()
      nKgp:=Kgp
      nKpl:=Kpl

      lWeek_One:=.F.
      aDt_Range:={}

      IF TPoints->(DBSEEK(STR(nKPL)+STR(nKGP)))
        IF !EMPTY(TPoints->RouteTime) .AND. LEN(ALLTRIM(TPoints->RouteTime))>1

          aDt_Range:=Dt_Range(dShDateEnd,TPoints->RouteTime)
          //outlog(__FILE__,__LINE__,'"',TPoints->RouteTime,'"')
          //outlog(__FILE__,__LINE__,aDt_Range)
          //lWeek_One:=.T.
          //QUIT

        ELSE
          lWeek_One:=.T.
        ENDIF
      ELSE
        lWeek_One:=.T.
      ENDIF

      IF lWeek_One
        nWeekEnd:=WEEK(dSHDATEEND)+IIF(WEEK(dSHDATEBG) > WEEK(dSHDATEEND), 52, 0)
        //outlog(__FILE__,__LINE__,nCurWeekFor,nWeekEnd,WEEK(dSHDATEBG),WEEK(dSHDATEEND))

        k:=0
        FOR nCurWeekFor:=WEEK(dSHDATEBG) TO nWeekEnd

          IF WEEK(dSHDATEBG) > WEEK(dSHDATEEND)
            nCurWeek:=nCurWeekFor-IIF(WEEK(dSHDATEBG) > WEEK(dSHDATEEND) .AND. nCurWeekFor<=52, 0, 52)
           ELSE
            nCurWeek:=nCurWeekFor
          ENDIF
          AADD(aDt_Range,{dSHDATEBG+(7*k), dSHDATEBG+(7*(k+1))-1})
          k++
        NEXT
      ENDIF

      /*
      outlog(__FILE__,__LINE__,lWeek_One,'"',TPoints->RouteTime,'"',aDt_Range)
      IF nKgp = 8460198
        outlog(__FILE__,__LINE__,"!!!!!!!",nKgp,nKpl)
      ENDIF
      */

      i:=0

      SELE price
      DBGOTOP()
      DO WHILE !EOF()

        //nMnTov:=MnTov
        nMnTov:=MnTovT

        cSales:="" //строка с продажами
        nSales:=0

        FOR k:=1 TO LEN(aDt_Range)
        //FOR nCurWeekFor:=WEEK(dSHDATEBG) TO nWeekEnd

          SELE Sales
          OrdSetFocus("KGp_MnTovT")
          IF DBSEEK(STR(nKpl)+STR(nKgp)+STR(nMnTov)) //+STR(nCurWeek,2))
            SUM KVP TO nKVP ;
            WHILE STR(nKpl)+STR(nKgp)+STR(nMnTov) = ;
              STR(Kpl)+STR(Kgp)+STR(MnTovT) ; // MnTov MnTovT
            FOR  Dop>=aDt_Range[k,1] .AND. Dop<=aDt_Range[k,2]
            //WHILE STR(nKpl)+STR(nKgp)+STR(nMnTov)+STR(nCurWeek,2) = STR(Kpl)+STR(Kgp)+STR(MnTov)+STR(WEEK(Dop),2)
          ELSE
            nKVP:=0
          ENDIF

          nQRest:=0
          SELE Merch
          OrdSetFocus("KGp_MnTovT")
          IF DBSEEK(STR(nKpl)+STR(nKgp)+STR(nMnTov)) //+STR(nCurWeek,2))
            SUM KVP TO nQRest ;
            WHILE STR(nKpl)+STR(nKgp)+STR(nMnTov) = ;
                  STR(Kpl)+STR(Kgp)+STR(MnTovT) ; // MnTov MnTovT
            FOR  Dop>=aDt_Range[k,1] .AND. Dop<=aDt_Range[k,2]
            //WHILE STR(nKpl)+STR(nKgp)+STR(nMnTov)+STR(nCurWeek,2) = STR(Kpl)+STR(Kgp)+STR(MnTov)+STR(WEEK(Dop),2)
          ELSE
            nQRest:=0
          ENDIF

          cSales+=LTRIM(STR(nQRest ,4,0))+":"+LTRIM(STR(nKVP ,4,0))+" "
          //cSales+=LTRIM(STR(nQRest ,4,0))+"|"+LTRIM(STR(nKVP ,4,0))+" "
          nSales+=(nQRest+nKVP)

          /*
          IF nKgp = 8460198
            outlog(__FILE__,__LINE__,nMnTov,nQRest,nKVP,aDt_Range[k,1],aDt_Range[k,2])
          ENDIF
          */

        NEXT

        IF ROUND(nSales,3) # 0 //есть продажи
          cSales:=RTRIM(cSales)
          QOUT(;
              ;//TPointID
                IIF(i=0, GUID_KPK("C",ALLTRIM(STR(nKgp)),ALLTRIM(STR(nKpl))),"*")+_T+      ;
              ;//GoodsID
                GUID_KPK("A",ALLTRIM(STR(nMnTov)))+_T+;
              ;//Sales
              RIGHT(cSales, 127)  ;
            )
          i++//повтор грузополучателя
        ENDIF


        SELE price
        SKIP
      ENDDO

      SELE tmp_ktt //торговые точки
      SKIP
    ENDDO

    QOUT('<End>'+_T+'Ref_Sales')

  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-28-07 * 01:02:08pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Dt_Range(dDateEnd,cRouteTime)
  LOCAL i, aDtRouteTime,dRouteTime, aDt_Range, dDate

  aDtRouteTime:={}
  aDt_Range:={}
  dDate:=dDateEnd

  DO WHILE .T.
    FOR i:=1 TO 7
      IF !EMPTY(SUBSTR(cRouteTime,i,1))

        dRouteTime:=LastMonday(dDate)+i-1
        AADD(aDtRouteTime, dRouteTime)


      ENDIF
    NEXT

    FOR i:=LEN(aDtRouteTime) TO 1 STEP -1
      IF i = LEN(aDtRouteTime)
        AADD(aDt_Range,{aDtRouteTime[i],dDateEnd+1}) //+1 - т.к. суббота, а будет воскр
      ELSE
        AADD(aDt_Range,{aDtRouteTime[i],aDtRouteTime[i+1]-1})
      ENDIF
      IF LEN(aDt_Range)=4 //четыре диапазона
        EXIT
      ENDIF
    NEXT
    IF LEN(aDt_Range)=4 //четыре диапазона
      EXIT
    ENDIF
    dDate:=dDate-7
    dDateEnd:=aDtRouteTime[1]-1-1 //см. выше добавляется +1
    aDtRouteTime:={}
  ENDDO

  RETURN (aDt_Range)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  20.11.06 * 12:54:14
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Ref_TblStruct(nRun)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_TblStruct.txt

  IF !EMPTY(nRun)

    QQOUT('<Begin>'+_T+'Ref_TblStruct'+_T+'Struct:TblCD,FormOrder,Name,Present,Type,TypeID,Size,Flags')
    QOUT('Firms'+_T+'1'+_T+'FNAME'+_T+'Полн.наименование'+_T+'2'+_T+''+_T+'128'+_T+'0')
    QOUT('Firms'+_T+'2'+_T+'INN'+_T+'ИНН'+_T+'2'+_T+''+_T+'32'+_T+'0')
    QOUT('Firms'+_T+'3'+_T+'KPP'+_T+'КПП'+_T+'2'+_T+''+_T+'32'+_T+'0')
    QOUT('Firms'+_T+'4'+_T+'OKPO'+_T+'ОКПО'+_T+'2'+_T+''+_T+'16'+_T+'0')
    QOUT('Firms'+_T+'5'+_T+'BANK'+_T+'Банк'+_T+'2'+_T+''+_T+'64'+_T+'0')
    QOUT('Firms'+_T+'6'+_T+'BIK'+_T+'БИК'+_T+'2'+_T+''+_T+'32'+_T+'0')
    QOUT('Firms'+_T+'7'+_T+'BANKADR'+_T+'Адрес банка'+_T+'2'+_T+''+_T+'64'+_T+'0')
    QOUT('Firms'+_T+'8'+_T+'KSCHET'+_T+'Кор.счет'+_T+'2'+_T+''+_T+'32'+_T+'0')
    QOUT('Firms'+_T+'9'+_T+'RSCHET'+_T+'Расч.счет'+_T+'2'+_T+''+_T+'32'+_T+'0')
    QOUT('Firms'+_T+'10'+_T+'DIREKTOR'+_T+'Директор'+_T+'2'+_T+''+_T+'64'+_T+'0')
    QOUT('Firms'+_T+'11'+_T+'GLBUH'+_T+'Гл.бухгалтер'+_T+'2'+_T+''+_T+'64'+_T+'0')
    QOUT('Clients'+_T+'1'+_T+'INN'+_T+'ИНН'+_T+'2'+_T+''+_T+'21'+_T+'1')
    QOUT('Clients'+_T+'2'+_T+'KPP'+_T+'КПП'+_T+'2'+_T+''+_T+'9'+_T+'1')
    QOUT('Clients'+_T+'3'+_T+'FNAME'+_T+'Полн.наименование'+_T+'2'+_T+''+_T+'128'+_T+'0')
    QOUT('Clients'+_T+'4'+_T+'MSALES'+_T+'Оборот продаж'+_T+'1'+_T+''+_T+'2'+_T+'2')
    QOUT('Clients'+_T+'5'+_T+'SROKDOG'+_T+'Договор до'+_T+'3'+_T+''+_T+''+_T+'0')
    QOUT('Clients'+_T+'6'+_T+'VIP'+_T+'VIP-клиент'+_T+'20'+_T+''+_T+''+_T+'0')
    QOUT('Clients'+_T+'7'+_T+'CLKONKUR'+_T+'Клиент конкурентов'+_T+'20'+_T+''+_T+''+_T+'0')
    QOUT('Clients'+_T+'8'+_T+'DEBTLIST'+_T+'График долгов'+_T+'2'+_T+''+_T+'128'+_T+'0')
    QOUT('TPoints'+_T+'1'+_T+'TPTYPE'+_T+'Тип точки'+_T+'10'+_T+'5BB29DAF-6769-423A-AEAF-AEFE111736A0'+_T+''+_T+'0')
    QOUT('TPoints'+_T+'2'+_T+'WORKTIME'+_T+'Время работы'+_T+'2'+_T+' '+_T+'64'+_T+'0')
    QOUT('Price'+_T+'1'+_T+'GTD'+_T+'ГТД'+_T+'10'+_T+'EA2D47CD-0E34-4176-8EBF-F4A9AAF2716D'+_T+''+_T+'0')
    QOUT('Price'+_T+'2'+_T+'STRANA'+_T+'Страна-произв.'+_T+'10'+_T+'2BA57449-AECB-4C00-BDA0-E08120251AC7'+_T+''+_T+'0')
    QOUT('Sertif'+_T+'1'+_T+'BLANKN'+_T+'Бланк №'+_T+'2'+_T+''+_T+'32'+_T+'0')
    QOUT('Sertif'+_T+'2'+_T+'ADRES'+_T+'Адрес'+_T+'2'+_T+''+_T+'64'+_T+'0')
    QOUT('Stores'+_T+'1'+_T+'AVTOSKLAD'+_T+'Передвижной склад'+_T+'20'+_T+''+_T+''+_T+'0')
    QOUT('Stores'+_T+'2'+_T+'TONNAJ'+_T+'Тоннаж'+_T+'1'+_T+''+_T+'3'+_T+'0')
    QOUT('Stores'+_T+'3'+_T+'TEHOSM'+_T+'Техосмотр'+_T+'3'+_T+''+_T+''+_T+'0')

    QOUT('Order'+_T+'1'+_T+'TRASP'+_T+'Транспортные услуги'+_T+'20'+_T+' '+_T+''+_T+'0')
    QOUT('Order'+_T+'2'+_T+'REPORT'+_T+'ТАРА другой ТТН'+_T+'20'+_T+' '+_T+''+_T+'0')
    QOUT('Order'+_T+'3'+_T+'SERTIF'+_T+'Сертификаты'+_T+'20'+_T+' '+_T+''+_T+'0')
    //QOUT('Order'+_T+'2'+_T+'REPORT'+_T+'Отчет по взаиморасчетам'+_T+'20'+_T+' '+_T+''+_T+'0')
    QOUT('Order'+_T+'4'+_T+'DOSTAVKA'+_T+'Вид доставки'+_T+'10'+_T+'1124A28B-63EE-4F01-9AFA-37594D06CCCB'+_T+'0'+_T+'1')
    QOUT('Order'+_T+'5'+_T+'ADRES'+_T+'Альтерн.адрес доставки'+_T+'2'+_T+' '+_T+'64'+_T+'0')
    QOUT('Order'+_T+'6'+_T+'SROK'+_T+'Оплата до'+_T+'3'+_T+' '+_T+''+_T+'0')

    QOUT('Sale'+_T+'1'+_T+'DOSTAVKA'+_T+'Вид доставки'+_T+'10'+_T+'1124A28B-63EE-4F01-9AFA-37594D06CCCB'+_T+'0'+_T+'0')
    QOUT('Sale'+_T+'2'+_T+'ADRES'+_T+'Альтерн.адрес доставки'+_T+'2'+_T+' '+_T+'64'+_T+'0')
    QOUT('Sale'+_T+'3'+_T+'DOSTAVLEN'+_T+'Товар доставлен'+_T+'20'+_T+' '+_T+''+_T+'0')
    QOUT('Merch'+_T+'1'+_T+'FKAT_A'+_T+'Фейсинг A (категория товаров "A")'+_T+'1'+_T+''+_T+'0'+_T+'1')
    QOUT('Merch'+_T+'2'+_T+'FKAT_B'+_T+'Фейсинг B (категория товаров "B")'+_T+'1'+_T+''+_T+'0'+_T+'0')
    QOUT('Merch'+_T+'3'+_T+'FKAT_C'+_T+'Фейсинг C (категория товаров "C")'+_T+'1'+_T+''+_T+'0'+_T+'0')
    QOUT('Merch'+_T+'4'+_T+'FKAT_RP'+_T+'Фейсинг РП (рекламная продукция)'+_T+'1'+_T+''+_T+'0'+_T+'1')
    QOUT('Visit'+_T+'1'+_T+'VISIT'+_T+'Резултат посещения'+_T+'10'+_T+'FC233E4A-DA80-4481-B280-76CE1855CA9C'+_T+''+_T+'1')
    QOUT('<End>'+_T+'Ref_TblStruct')

  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  20.11.06 * 13:10:56
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Ref_Scripts(nRun)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_Scripts.txt
  IF !EMPTY(nRun)

    QQOUT('<Begin>'+_T+'Ref_Scripts'+_T+'Struct:ObjectID,Script')

    QOUT('CC56ADA6-3584-40A1-A83E-B5B1F5FA8648'+_T+'[Name]|Кредит: [Credit], Скидка: [Discount]%|Долг: [Debt]|')
    QOUT('*'+_T+'[_DEBTLIST]|')
    QOUT('*'+_T+'VIP: [_VIP]; Клиент конкурентов: [_CLKONKUR]|-------|')
    QOUT('*'+_T+'Тел.: [Tel]|Адрес: [Addr]|ИНН: [_INN], КПП: [_KPP]|[_FNAME]|')
    QOUT('*'+_T+'Продажи прошл. месяца: [_MSALES]|Срок договора: [_SROKDOG]')

    QOUT('5BD7E0A7-4B93-4962-8A62-1DF6F40FB56C'+_T+'[Name]|Категория: [Category]|Зона: [Zone]|-------|')
    QOUT('*'+_T+'Адрес: [Addr]|Тел: [Tel]|Конт. лицо: [Contact]|-------|')
    QOUT('*'+_T+'Тип: [_TPTYPE]|Время работы: [_WORKTIME]')

    QOUT('<End>'+_T+'Ref_Scripts')

  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  20.11.06 * 13:17:34
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Doc_Move(nRun, ktar)
 LOCAL i1, i2
      i1:=0
      i2:=0
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Doc_Move.txt
  IF .F. .AND. !EMPTY(nRun)
    QQOUT('<Begin>'+_T+'Doc_Move'+_T+'Struct:DocID,DocState,DocFlags,TimeCrt,DocNumber,FirmID,StoreID,DocSum,MoveType,Comment,MDocID')
    QOUT('<Sub>'+_T+'Lines'+_T+'Struct:GoodsID,Amount,Price,Sum,=VAT')

    DBGOTOP()
    DO WHILE !EOF()
    //шапка документа
    QOUT(;
          ;//DocID GUID Идентификатор документа.
          GUID_KPK("F",ALLTRIM(LTRIM(STR(SK))+PADL(LTRIM(STR(TTN)),7,"0")))+_T+             ;
          ;//DocState Число - 1.0 Состояние документа, как он должен быть представлен в журнале документов КПК:
          ;//1 - проведен;2 - записан.
          STR(1,1)+_T+;
          ;//DocFlags Число - 3.0 Описание параметра смотрите в разделе 2.28 "Тэг Doc_Debt".
          STR(2+8+(64*0),3)+_T+;
          ;//TimeCrt Дата и время Дата и время создания документа
          DTOC(DOP)+_T+;
          ;//DocNumber Строка - 25 Номер документа
          ALLTRIM(STR(SK))+" "+ALLTRIM(STR(TTN))+":"+STR(KOP)+":КОП"+_T+;
          ;//FirmID GUID Идентификатор фирмы, от имени которой оформлен документ.
          IIF(i1=0,'8FC6CB94-AEFD-4498-951C-7BAEA'+PADL(LTRIM(STR(gnKkl_c)),7,'0'),"*")+_T+      ;
          ;//StoreID, GUID Идентификатор СКЛАДА (код торг агента)
          IIF(i2=0, GUID_KPK("CAC",PADL(LTRIM(STR(ktar,3)), 3, "0")),"*")+_T+      ;
          ;//DocSum Число 15.2 Сумма долга по документн.
          LTRIM(STR(SDV,15,2))+_T+;
          ;//MoveType 1 - загрузка в машину, 2-выгрузка
          IIF(.T.,"1","2")+_T+;
          ;//Comment Строка - 128 Комментарий к документу.
          LEFT(PADL(LTRIM(STR(ktar,3)), 3, "0"),128)+_T+;
          ;//MDocID
          ;//MDocID GUID Идентификатор документа, на основании которого введен ордер.
          IIF(.T.,"",GUID_KPK("D",ALLTRIM(PADL(LTRIM(STR(898989)),6,"0"))))             ;
      )
        //товарная часть
         QOUT('<Begin>'+_T+'Lines')
         nTtn:=Ttn
         DO WHILE nTTn = ttn
           QOUT(;
              ;//GoodsID
              GUID_KPK("A",ALLTRIM(STR(MnTovT)))+_T+;
              ;//Amount число 15.4 -  количество товар в базовых ед.изм
              ALLTRIM(STR(KVP, 15, 4))+_T+        ;
              ;//Price
              ALLTRIM(STR(ZEN, 15, 2))+_T+        ;
              ;//Sum
              ALLTRIM(STR(SVP, 15, 2))+_T+        ;
              ;//=VAT 15, 2
              ALLTRIM("")        ;
              )
          DBSKIP()
         ENDDO
        QOUT('<End>'+_T+'Lines')
    ENDDO
    QOUT('<End>'+_T+'Doc_Move')

  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  20.11.06 * 13:37:11
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Doc_Sale(nRun)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Doc_Sale.txt

  IF !EMPTY(nRun)
    /*
    QQOUT('<Begin>'+_T+'Doc_Sale'+_T+'Struct:DocID,DocState,DocFlags,TimeCrt,DocNumber,FirmID,ClientID,=TPointID,DocSum,=DocVAT,=Discount,Comment,=PaymntType,=PriceType,=PayDate,MDocID,=SFNumber,=UseVAT,_DOSTAVKA,_ADRES,_DOSTAVLEN')

    QOUT('<Sub>'+_T+'Lines Struct:GoodsID,Amount,Price,Sum,=VAT")
    QOUT('//5272A5EA-67D6-421E-68E5-A7824FA3798A  2 10  2006-10-02 15-34-36 0CKC000003  8FC6CB94-AEFD-4498-951C-7BAEA9298658  A0BA5952-CA7C-4510-8DBC-4F87492B08A3  CB17BD0F-3EFA-41E4-AEF6-C99B6B3BBE3F  926.9 141.39  0   0 1 2006-08-16  52724719-B7D6-47FE

    -C4BD-7107F46BBD42  1 0  0')
    QOUT('//<Begin>'+_T+'Lines')
    QOUT('//F51F7461-A33D-4838-9D19-758344C30997  23  40.3  926.9 141.39')
    QOUT('//<End>'+_T+'Lines')
    QOUT('<End>'+_T+'Doc_Sale')
    */
  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  20.11.06 * 13:45:35
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Doc_Debt(nRun,ktar)
  LOCAL i1, i2, ktasr
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Doc_Debt.txt
  IF !EMPTY(nRun)
  //QQOUT("<Begin>"+_T+"Doc_Debt"+_T+"Struct:DocID,DocState,DocFlags,TimeCrt,DocNumber,FirmID,ClientID,=TPointID,DocSum,Comment,=DocDescr,FullSum,PayDate")
  QQOUT("<Begin>"+_T+"Doc_Debt"+_T+"Struct:DocID,DocState,DocFlags,TimeCrt,DocNumber,FirmID,ClientID,=TPointID,DocSum,Comment,=DocDescr,FullSum,PayDate")
    SELE skdoc
    SET FILTER TO !DELETED()

    locate for ktan=ktar
    ktasr:=ktas

    DBGOTOP()

    SELE tmp_kpl
    //SET RELA TO STR(kpl,7) INTO skdoc
    DBGOTOP()
    WHILE (!EOF())
      IF STR(tmp_kpl->Kpl)$"     20034"
        SELECT tmp_kpl
        DBSKIP()
        LOOP
      ENDIF
      IF !skdoc->(DBSEEK(STR(tmp_kpl->kpl,7)))
        SELECT tmp_kpl
        DBSKIP()
        LOOP
      ENDIF
      i1:=0
      i2:=0

      SELE skdoc
      DO WHILE skdoc->Kpl = tmp_kpl->Kpl

        IF iif(.F.,ktasr=ktas,.T.) //выводим только д-ки, те которые в маршуте и принадлежат Суперу ТоргАгента
          QOUT(;
            ;//DocID GUID Идентификатор документа.
            GUID_KPK("F",ALLTRIM(LTRIM(STR(SK))+PADL(LTRIM(STR(TTN)),7,"0")))+_T+             ;
            ;//DocState Число - 1.0 Состояние документа, как он должен быть представлен в журнале документов КПК:
            ;//1 - проведен;2 - записан.
            STR(1,1)+_T+;
            ;//DocFlags Число - 3.0 Описание параметра смотрите в разделе 2.28 "Тэг Doc_Debt".
            ;//STR(2+8+(64*iif(ktasr=ktas,1,0)),3)+_T+;
            STR(2+8+(64*iif(ktan=ktar,1,0)),3)+_T+;
            ;//TimeCrt Дата и время Дата и время создания документа
            DTOC(DOP)+_T+;
            ;//DocNumber Строка - 25 Номер документа
            ALLTRIM(STR(SK))+" "+ALLTRIM(STR(TTN))+":"+STR(KOP)+":КОП"+_T+;
            ;//FirmID GUID Идентификатор фирмы, от имени которой оформлен документ.
            IIF(i1=0,'8FC6CB94-AEFD-4498-951C-7BAEA'+PADL(LTRIM(STR(gnKkl_c)),7,'0'),"*")+_T+      ;
            ;//ClientID GUID Идентификатор клиента.
            IIF(i2=0, GUID_KPK("C",ALLTRIM(STR(Kpl))),"*")+_T+      ;
            ;//=TPointID GUID Идентификатор торговой точки (не обязателен).
            GUID_KPK("C",ALLTRIM(STR(KGp)),ALLTRIM(STR(Kpl)))+_T+      ;
            ;//DocSum Число 15.2 Сумма долга по документн.
            LTRIM(STR(SDP,15,2))+_T+;
            ;//Comment Строка - 128 Комментарий к документу.
            LEFT(ALLTRIM(NKtaN),128)+_T+;
            ;// ,=DocDescr Вид документа (не обязателен)
            LEFT(ALLTRIM("НКЛ"),24)+_T+;
            ;//FullSum Число 15.2 Сумма документа.
            LTRIM(STR(SDV,15,2))+_T+;
            ;//PayDate  Дата оплаты документа
            DTOC(IIF(EMPTY(DtOpl), DOP+14,DtOpl));
          )
          i1:=0//1
          i2:=0//1
        ENDIF
        DBSKIP()
      ENDDO

      SELECT tmp_kpl
      DBSKIP()
    ENDDO

  /*
  QOUT("//926A2A53-07D0-48C6-B539-084C8599B5C6  1 73  2004-02-28 12-00-00 0000000008  C76B90B5-9180-4E0E-B723-6A864BB408A8  99663023-26D9-4963-B71E-BF7246718A55  6BBBA48E-E872-453F-B470-DFF6F91444C0  1291.4    Реализация  1491.4  2004-03-04")
  */
    QOUT("<End>"+_T+"Doc_Debt")

    SELE skdoc
    SET FILTER TO
    SELE tmp_kpl
    SET RELA TO

  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  01-15-07 * 02:29:25pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Doc_Cash(nRun)
  LOCAL i1, i2
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Doc_Cash.txt
  IF !EMPTY(nRun)
  //QQOUT("<Begin>"+_T+"Doc_Cash"+_T+"Struct:DocID,DocState,DocFlags,TimeCrt,DocNumber,FirmID,ClientID,=TPointID,DocSum,=DocVAT,MDocID,Comment,=PaymntType")
  QQOUT("<Begin>"+_T+"Doc_Cash"+_T+"Struct:DocID,DocState,DocFlags,TimeCrt,DocNumber,FirmID,ClientID,DocSum,MDocID,Comment")
    SELE bdoc
    SET FILTER TO !DELETED()
    DBGOTOP()

    SELE tmp_kpl
    //SET RELA TO STR(kpl,7) INTO skdoc
    DBGOTOP()
    WHILE (!EOF())
      IF STR(tmp_kpl->Kpl)$"     20034"
        SELECT tmp_kpl
        DBSKIP()
        LOOP
      ENDIF
      IF !bdoc->(DBSEEK(STR(tmp_kpl->kpl,7)))
        SELECT tmp_kpl
        DBSKIP()
        LOOP
      ENDIF
      i1:=0
      i2:=0

      SELE bdoc
      DO WHILE bdoc->KKl = tmp_kpl->Kpl
        QOUT(;
          ;//DocID GUID Идентификатор документа.
          GUID_KPK("D",ALLTRIM(LTRIM(DTOS(DDK))+PADL(LTRIM(STR(RND)),6,"0")))+_T+             ;
          ;//DocState Число - 1.0 Состояние документа, как он должен быть представлен в журнале документов КПК:
          ;//1 - проведен;2 - записан.
          STR(1,1)+_T+;
          ;//DocFlags Число - 3.0 Описание параметра смотрите в разделе 2.28 "Тэг Doc_Debt".
          STR(2+8+(64*0),3)+_T+;
          ;//TimeCrt Дата и время Дата и время создания документа
          DTOC(DDK)+_T+;
          ;//DocNumber Строка - 25 Номер документа
          ALLTRIM(STR(NPLP))+"/"+ALLTRIM(STR(RND))+_T+;
          ;//FirmID GUID Идентификатор фирмы, от имени которой оформлен документ.
          IIF(i1=0,'8FC6CB94-AEFD-4498-951C-7BAEA'+PADL(LTRIM(STR(gnKkl_c)),7,'0'),"*")+_T+      ;
          ;//ClientID GUID Идентификатор клиента.
          IIF(i2=0, GUID_KPK("C",ALLTRIM(STR(KKL))),"*")+_T+      ;
          ;//=TPointID GUID Идентификатор торговой точки (не обязателен).
          ;//DocSum Число 15.2 Сумма документа. Для расходных кассовых ордеров сумма указывается меньше нуля.
          LTRIM(STR(BS_S,15,2))+_T+;
          ;//=DocVAT Число 15.2 Сумма НДС документа.
          ;//MDocID GUID Идентификатор документа, на основании которого введен ордер.
          IIF(.T.,"",GUID_KPK("D",ALLTRIM(LTRIM(DTOS(DDK))+PADL(LTRIM(STR(RND)),6,"0"))))+_T+             ;
          ;//Comment Строка - 128 Комментарий к документу.
          LEFT(ALLTRIM(STR(BS_D,6,0)+":"+OSN),128);
          ;//= PaymntType Число - 10.0 Код вида оплаты документа (не обязателен)
        )
        i1:=0//1
        i2:=0//1
        DBSKIP()
      ENDDO

      SELECT tmp_kpl
      DBSKIP()
    ENDDO

  /*
  QOUT("//926A2A53-07D0-48C6-B539-084C8599B5C6  1 73  2004-02-28 12-00-00 0000000008  C76B90B5-9180-4E0E-B723-6A864BB408A8  99663023-26D9-4963-B71E-BF7246718A55  6BBBA48E-E872-453F-B470-DFF6F91444C0  1291.4    Реализация  1491.4  2004-03-04")
  */
    QOUT("<End>"+_T+"Doc_Cash")

    SELE bdoc
    SET FILTER TO
    SELE tmp_kpl
    SET RELA TO

  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  20.11.06 * 13:52:32
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Ref_Barcodes()
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_Barcodes.txt

  /*
  QQOUT('<Begin>'+_T+'Ref_Barcodes'+_T+'Struct:GoodsID,Name,=UnitCode')

  //QQOUT('6B8C0DC0-38EE-4B6A-883D-F432FCC0C5E4'+_T+'5995327275147'+_T+'2')
  //QQOUT('9867C63E-BF08-41B8-833B-3110695BF708'+_T+'4605658044060'+_T+'0')
  //QQOUT('*'+_T+'5411416003731'+_T+'0')
  //QQOUT('B694272D-C5F9-4E29-896F-EE7EB2085DD0'+_T+'5000174439090'+_T+'1')

  QOUT('<End>'+_T+'Ref_Barcodes')
  */

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  20.11.06 * 14:26:30
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Ref_Firms(nRun)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_Firms.txt
  IF !EMPTY(nRun)
    kln->(netseek("t1","gnKkl_c"))
    QQOUT('<Begin>'+_T+'Ref_Firms'+_T+'Struct:FirmID,Name,=CodesList,=Addr,=Tel,=UseVAT,=UseSF,=DocPrefix,_FNAME,_INN,_KPP,_OKPO,_BANK,_BIK,_BANKADR,_KSCHET,_RSCHET,_DIREKTOR,_GLBUH')
    QOUT('8FC6CB94-AEFD-4498-951C-7BAEA'+PADL(LTRIM(STR(gnKkl_c)),7,'0')+_T+;//'9298658'
    LEFT(ALLTRIM(kln->NKLE),64)+_T+; //'Продресурс'
    '1,2,3,4,5'+_T+;
    LEFT(ALLTRIM(kln->ADR),128)+_T+; //'г.Сумы, ул. Скрябина 7'
    LEFT(ALLTRIM(kln->TLF),64)+_T+; //'22-33-55, 56-66-67'
    '1'+_T+'1'+_T+'ПСКС'+_T+;
    LEFT(ALLTRIM(kln->NKL),64)+_T+;//'ТОВ "Продресурс"'
    '0056123412'+_T+'005601123'+_T+'4564311'+_T+;
    'АКБ "АВТ-БАНК"'+_T+'044599774'+_T+;
    'Г.СУМЫ'+_T+'30101810100000000774'+_T+'40702810900000109991'+_T+'Сидоров В.С.'+_T+'Кириченко Т.А.')

    QOUT('<End>'+_T+'Ref_Firms')

  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  21.11.06 * 08:59:00
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Ref_Stores(nRun)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_Stores.txt
  IF !EMPTY(nRun)
    /*
    QQOUT('<Begin>'+_T+'Ref_Stores'+_T+'Struct:ObjID,Name,_AVTOSKLAD,_TONNAJ,_TEHOSM')
    QOUT('//3746A311-78A0-463E-B61D-5D0263C38920'+_T+'А/М Газель №248'+_T+'1'+_T+'0'+_T+'2005-12-01')
    QOUT('//0B452C0F-0EC7-46F7-8669-5487662F92D7'+_T+'А/М Форд №329'+_T+'1'+_T+'1.5'+_T+'2005-07-01')
    QOUT('//F58FBEC2-FAC4-48A3-AB7B-AA28259189AD'+_T+'Основной'+_T+'0'+_T+'0'+_T+'2000-01-01')
    QOUT('//4F049830-21D7-4C7E-A593-4FA800D198FB'+_T+'Филиал'+_T+'0'+_T+'0'+_T+'2000-01-01')
    QOUT('<End>'+_T+'Ref_Stores')
    */
  ENDIF
  SET PRINT TO
  SET PRINT OFF
 RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  21.11.06 * 08:59:00
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Ref_Commands(nRun)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_Commands.txt
  IF !EMPTY(nRun)
    QQOUT('<Begin>'+_T+'Ref_Commands'+_T+'Struct:CmdCode,Arg')
    //QOUT('DeleteOldDocuments'+_T+'-31 DocList:Order,Sale,Merch') //не подтвержденные не удаляет
    QOUT('DeleteAllDocuments'+_T+'-14 DocList:Order,Sale,Merch') //все удаляет
    IF DATE()<=STOD("20071231")
      QOUT('Message'+_T+;
      ;//'       ======         '+;
      ;//'   === ВНИМАНИЕ ===   '+;
      ;//'       ======         '+;
      ;//'                       '+;
      ;//'     РАБОТАЕТ ОПЦИЯ        '     СЕРТИФИКАТЫ       '+;
         '    ИСТОРИЯ ПРОДАЖ ПОКАЗЫВАЕТСЯ ПО ПОСЕЩЕНИЯМ      '+;
         '              (а не понедельно)                    '+;
         '      обновите, если нужно историю продаж          '+;
      ;//'                       '+;
      ;//'       ======         '+;
      "";//'       ======         ';
    )
    ENDIF
    /*QOUT('Message'+_T+'!   === ВНИМАНИЕ ===   ')
    QOUT('Message'+_T+'!       ======         ')
    QOUT('Message'+_T+'                       ')
    QOUT('Message'+_T+'    РАБОТАЕТ ОПЦИЯ     ')
    QOUT('Message'+_T+'     СЕРТИФИКАТЫ       ')
    QOUT('Message'+_T+' (Заявка/Дополнительно)')
    QOUT('Message'+_T+'                       ')
    QOUT('Message'+_T+'!       ======         ')
    QOUT('Message'+_T+'!       ======         ')*/

    /*
    QOUT('//0B452C0F-0EC7-46F7-8669-5487662F92D7'+_T+'А/М Форд №329'+_T+'1'+_T+'1.5'+_T+'2005-07-01')
    QOUT('//F58FBEC2-FAC4-48A3-AB7B-AA28259189AD'+_T+'Основной'+_T+'0'+_T+'0'+_T+'2000-01-01')
    QOUT('//4F049830-21D7-4C7E-A593-4FA800D198FB'+_T+'Филиал'+_T+'0'+_T+'0'+_T+'2000-01-01')
    */
    QOUT('<End>'+_T+'Ref_Commands')
  ENDIF
  SET PRINT TO
  SET PRINT OFF
 RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  21.11.06 * 09:05:06
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Ref_Sertif(nRun)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_Sertif.txt
  IF !EMPTY(nRun)
    /*
    QQOUT('<Begin>'+_T+'Ref_Sertif'+_T+'Struct:SertifID,Name,OrgSertif,DateBgn,DateEnd,_BLANKN,_ADRES')
    QOUT('<End>'+_T+'Ref_Sertif')
    */
  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  21.11.06 * 09:07:26
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Ref_AttrTypes(nRun,aKop)
  LOCAL aNn_price, i
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_AttrTypes.txt
  IF !EMPTY(nRun)
    QQOUT('<Begin>'+_T+'Ref_AttrTypes'+_T+'Struct:AttrID,Code,Name,=DocList,=AddValue')

    QOUT('A1F1127E-BB91-41DE-87F5-4A00E5C4C409'+_T+'-1'+_T+'Комментарий:'+_T+' '+_T+' ')
    QOUT('*'+_T+'1'+_T+'СРОЧНО!'+_T+'Order'+_T+' ')
    QOUT('*'+_T+'2'+_T+'Самовывоз'+_T+'Order'+_T+' ')
    QOUT('*'+_T+'3'+_T+'Акция'+_T+'Order'+_T+' ')
    QOUT('*'+_T+'4'+_T+'Клиент:  , Маг:  , Адр:  , Тел:'+_T+' '+_T+' ')
    QOUT('*'+_T+'5'+_T+'Заявка на погрузку'+_T+'Order'+_T+' ')
    QOUT('*'+_T+'6'+_T+'Брак!'+_T+'Arrival'+_T+' ')

    aNn_price:=PriceType2Kop('Nm_price')

    QOUT('08449B6B-75CA-464A-8D29-42EE6E94E08F'+_T+'1'+_T+aNn_price[1]+_T+'Order,Sale,Arrival'+_T+'')
    FOR i:=2 TO LEN(aNn_price)
      QOUT('*'+_T+'2'+_T+aNn_price[2]+_T+'Order,Sale,Arrival'+_T+'')
    NEXT
    QOUT('*'+_T+'3'+_T+'Розничная'+_T+'Order,Sale,Arrival'+_T+'')
    QOUT('*'+_T+'4'+_T+'Оптовая, безнал'+_T+'Order,Sale,Arrival'+_T+'')

    QOUT('60277704-5AB1-4FC5-BF78-9B032723B8B7'+_T+'-1'+_T+'Вид оплаты:'+_T+'Order,Sale,Cash,Arrival'+_T+' ')
    FOR i:=1 TO LEN(aKop) //-1
      QOUT('*'+_T+LTRIM(STR(aKop[i,3],2))+_T+aKop[i,2]+_T+'Order,Sale,Cash,Arrival'+_T+'1,2')
    NEXT
    /*
    QOUT('*'+_T+'169'+_T+'169-Нал.без.док'+_T+'Order,Sale,Cash,Arrival'+_T+'1,2')
    QOUT('*'+_T+'161'+_T+'161-Нал.с.док'+_T+'Order,Sale,Cash,Arrival'+_T+'1,2')
    QOUT('*'+_T+'160'+_T+'160-Отср. с док'+_T+'Order,Sale,Cash,Arrival'+_T+'1,2')
    QOUT('*'+_T+'126'+_T+'126-Отср. без док'+_T+'Order,Sale,Cash,Arrival'+_T+'1,2')
    */
    QOUT('51DA11C0-6B6A-4EE7-BB9E-CB9E5515B536'+_T+'1'+_T+'FF0000'+_T+''+_T+'')
    QOUT('*'+_T+'2'+_T+'FF0000'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'FF00FF'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'00СС00'+_T+''+_T+'')
    QOUT('3C1B73C4-7956-4CA2-84C0-118E20847BB6'+_T+'1'+_T+'Оформление документов продаж для этого клиента запрещено!'+_T+''+_T+'')
    QOUT('*'+_T+'2'+_T+'Внимание! У клиента нет действующего договора! Предупредите клиента - оплата по факту поставки!'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'Внимание! У клиента заканчивается договор на следующей неделе! Предупредите клиента!'+_T+''+_T+'')
    QOUT('*'+_T+'4'+_T+'Это новый клиент! Окажите ему особое внимание!'+_T+''+_T+'')

    QOUT('4FD62396-E3F5-409F-A84E-A390D6876766'+_T+'2'+_T+'Спец.пред.маг VIP'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'Спец.пред.маг CM A'+_T+''+_T+'')
    QOUT('*'+_T+'4'+_T+'Спец.пред.маг B'+_T+''+_T+'')
    QOUT('*'+_T+'5'+_T+'Спец.пред.маг C'+_T+''+_T+'')
    /*
    QOUT('4FD62396-E3F5-409F-A84E-A390D6876766'+_T+'7'+_T+'Гигиена'+_T+''+_T+'')
    QOUT('*'+_T+'8'+_T+'Спец.предложение'+_T+''+_T+'')
    QOUT('*'+_T+'6'+_T+'Товары повседневного спроса'+_T+''+_T+'')
    QOUT('*'+_T+'10'+_T+'Товары сезонного спроса'+_T+''+_T+'')
    QOUT('*'+_T+'9'+_T+'Товары элитного спроса'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'Хранение от -10°C до -5°C'+_T+''+_T+'')
    QOUT('*'+_T+'1'+_T+'Хранение от -20°C до -18°C'+_T+''+_T+'')
    QOUT('*'+_T+'2'+_T+'Хранение от -5°C до -3°C'+_T+''+_T+'')
    QOUT('*'+_T+'5'+_T+'Хранение от 1°C до 5°C'+_T+''+_T+'')
    */

    QOUT('1CABA333-1D1D-4F41-86C8-B175E9CEB6B3'+_T+'1'+_T+'Обновить остатки'+_T+''+_T+'')
    QOUT('*'+_T+'2'+_T+'Обновить взаиморасчеты'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'Обновить историю продаж'+_T+''+_T+'')
    QOUT('*'+_T+'4'+_T+'Обновить маршруты'+_T+''+_T+'')

    QOUT('1124A28B-63EE-4F01-9AFA-37594D06CCCB'+_T+'1'+_T+'Самовывоз'+_T+''+_T+'')
    QOUT('*'+_T+'2'+_T+'Плановая доставка'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'Срочная доставка!'+_T+''+_T+'')

    QOUT('FC233E4A-DA80-4481-B280-76CE1855CA9C'+_T+'1'+_T+'Нет денег'+_T+''+_T+'')
    QOUT('*'+_T+'2'+_T+'Достаточный товарный запас'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'Нет ответственного лица'+_T+''+_T+'')
    QOUT('*'+_T+'4'+_T+'Лучшие цены у конкурентов'+_T+''+_T+'')
    QOUT('*'+_T+'5'+_T+'Анкетирование'+_T+''+_T+'')
    QOUT('*'+_T+'6'+_T+'Поставка от другого поставщика'+_T+''+_T+'')
    QOUT('*'+_T+'7'+_T+'Маленький кредит'+_T+''+_T+'')
    QOUT('*'+_T+'8'+_T+'Закрыто'+_T+''+_T+'')
    QOUT('*'+_T+'9'+_T+'Другое'+_T+''+_T+'')

    SELE kgpcat
    DBGOTOP()
    DO WHILE !EOF()
      IF RECNO()=1
        QOUT('5BB29DAF-6769-423A-AEAF-AEFE111736A0'+_T)
      ELSE
        QOUT('*'+_T)
      ENDIF
      QQOUT(LTRIM(STR(kgpcat+1,2))+_T+ALLTRIM(nkgpcat)+_T+''+_T+'')
      DBSKIP()
    ENDDO

    /*
    QOUT('5BB29DAF-6769-423A-AEAF-AEFE111736A0'+_T+'1'+_T+'Супермаркет'+_T+''+_T+'')
    QOUT('*'+_T+'2'+_T+'Спец. магазин'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'Отдел'+_T+''+_T+'')
    QOUT('*'+_T+'4'+_T+'Торговое место'+_T+''+_T+'')
    QOUT('*'+_T+'5'+_T+'Киоск'+_T+''+_T+'')
    QOUT('*'+_T+'6'+_T+'Павильон'+_T+''+_T+'')
    QOUT('*'+_T+'7'+_T+'Магазин'+_T+''+_T+'')
    */

    QOUT('3B4E9F70-9F00-4C15-99B8-81E1DF95DC2C'+_T+'1'+_T+'Бальзамы'+_T+''+_T+'')
    QOUT('*'+_T+'9'+_T+'Дезодоранты'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'Зубные пасты'+_T+''+_T+'')
    QOUT('*'+_T+'10'+_T+'Крема'+_T+''+_T+'')
    QOUT('*'+_T+'4'+_T+'Мыло'+_T+''+_T+'')
    QOUT('*'+_T+'5'+_T+'Напитки'+_T+''+_T+'')
    QOUT('*'+_T+'8'+_T+'Продукты питания'+_T+''+_T+'')
    QOUT('*'+_T+'11'+_T+'Снек'+_T+''+_T+'')
    QOUT('*'+_T+'6'+_T+'Стиральные порошки'+_T+''+_T+'')
    QOUT('*'+_T+'7'+_T+'Табачные изделия'+_T+''+_T+'')
    QOUT('*'+_T+'2'+_T+'Шампуни'+_T+''+_T+'')
    QOUT('EA2D47CD-0E34-4176-8EBF-F4A9AAF2716D'+_T+'1'+_T+'01234/11020/7654321'+_T+''+_T+'')
    QOUT('*'+_T+'2'+_T+'11234/11020/7654321'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'12345/11031/7654321'+_T+''+_T+'')
    QOUT('*'+_T+'4'+_T+'123456/11032/765432'+_T+''+_T+'')
    QOUT('*'+_T+'5'+_T+'21234/11020/7654321'+_T+''+_T+'')
    QOUT('*'+_T+'6'+_T+'34534/54654/5676346'+_T+''+_T+'')
    QOUT('*'+_T+'7'+_T+'43535/65748/6774356'+_T+''+_T+'')
    QOUT('*'+_T+'8'+_T+'50245/11020/7684323'+_T+''+_T+'')
    QOUT('*'+_T+'9'+_T+'51239/11020/7654324'+_T+''+_T+'')
    QOUT('*'+_T+'10'+_T+'51239/11023/7653327'+_T+''+_T+'')
    QOUT('*'+_T+'11'+_T+'56445/77645/7564876'+_T+''+_T+'')
    QOUT('*'+_T+'12'+_T+'56765/45666/4565445'+_T+''+_T+'')
    QOUT('*'+_T+'13'+_T+'84345/54623/5645645'+_T+''+_T+'')
    QOUT('2BA57449-AECB-4C00-BDA0-E08120251AC7'+_T+'1'+_T+'Бельгия'+_T+''+_T+'')
    QOUT('*'+_T+'3'+_T+'Голландия'+_T+''+_T+'')
    QOUT('*'+_T+'4'+_T+'Испания'+_T+''+_T+'')
    QOUT('*'+_T+'5'+_T+'Норвегия'+_T+''+_T+'')
    QOUT('*'+_T+'2'+_T+'Швеция'+_T+''+_T+'')
    QOUT('F07C563C-8EC9-44FA-8EDA-CBECBA4DF43B'+_T+'0'+_T+'---АНКЕТА---'+_T+'Visit'+_T+'')
    QOUT('81A492CE-D274-48FF-97BB-49FD4F69EE9D'+_T+'0'+_T+'Как Вы оцениваете работу службы доставки?'+_T+'Visit,!'+_T+'')
    QOUT('*'+_T+'1'+_T+'Отлично'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'2'+_T+'Хорошо'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'3'+_T+'Удовлетворительно'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'4'+_T+'Плохо'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'5'+_T+'Очень плохо'+_T+'Visit'+_T+'')
    QOUT('72D89678-3E88-442A-8837-F9C8E0597F48'+_T+'0'+_T+'Вас устраивает периодичность посещения агентами?'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'1'+_T+'Да'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'2'+_T+'Нет, желательно раз в неделю'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'3'+_T+'Нет, желательно 2 раза в месяц'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'4'+_T+'Нет, желательно 1 раз в месяц'+_T+'Visit'+_T+'')
    QOUT('9F1B99FE-A5CC-4499-9E74-EFD75746B23B'+_T+'0'+_T+'Пользуетесь Вы услугами других поставщиков?'+_T+'Visit,!'+_T+'')
    QOUT('*'+_T+'1'+_T+'Да'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'2'+_T+'Нет'+_T+'Visit'+_T+'')
    QOUT('9DF88983-874D-4634-A5F1-C3085A2DDE88'+_T+'0'+_T+'Желательное время посещения Вас торговым агентом?'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'1'+_T+'Любое'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'2'+_T+'9.00'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'3'+_T+'10.00'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'4'+_T+'11.00'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'5'+_T+'12.00'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'6'+_T+'13.00'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'7'+_T+'14.00'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'8'+_T+'15.00'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'9'+_T+'16.00'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'10'+_T+'17.00'+_T+'Visit'+_T+'')
    QOUT('8FE3E181-DE1A-4F1D-9A20-98DDF760DDC8'+_T+'0'+_T+'Вас устраивает ассортимент стиральных порошков?'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'1'+_T+'Да'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'2'+_T+'Нет'+_T+'Visit'+_T+'')
    QOUT('0F3F2988-733C-43ED-843A-C06BB41E3F86'+_T+'0'+_T+'Вас устраивает ассортимент шампуней?'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'1'+_T+'Да'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'2'+_T+'Нет'+_T+'Visit'+_T+'')
    QOUT('4C34BAF0-A4D2-467E-A820-4E2BF20FC637'+_T+'0'+_T+'Вас устраивает ассортимент сигарет?'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'1'+_T+'Да'+_T+'Visit'+_T+'')
    QOUT('*'+_T+'2'+_T+'Нет'+_T+'Visit'+_T+'')

    QOUT('<End>'+_T+'Ref_AttrTypes')
  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  21.11.06 * 09:11:49
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Ref_Confirm()
  LOCAL nDocState
  LOCAL cDocState
  cDocState:="вфсоп"

  SELE Confirm

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_Confirm.txt

  QQOUT('<Begin>'+_T+'Ref_Confirm'+_T+'Struct:DocID,DocState,DocNumber')
  DBGOTOP()
  WHILE (!EOF())

    IF !EMPTY(DocGUID)

      nDocState:=1+8    // 8-запрет изменения (записан)
      DO CASE
      CASE EMPTY(dFp)
        cDocState:="в----"
      CASE EMPTY(dSp)
        cDocState:="вф---"
      CASE EMPTY(dTOt) .AND. PRZ=0
        cDocState:="вфс--"
      CASE !EMPTY(dTOt) .AND. PRZ=0
        cDocState:="вфсо-"
        nDocState:=1+8+64 //64-красным   (записан + красным)
      CASE PRZ=1
        cDocState:="вфсоп"
      ENDCASE
        /*
        cDocState:= 3453466 В. . . . . "
        cDocState:="В.Ф. . . .3434566"
        cDocState:="В.Ф.C. . ."
        cDocState:="В.Ф.C.O. ."
        cDocState:="В.Ф.C.O.П."
        */

          qout(                               ;
              ;//DocID
                DocGUID+_T+      ;
              ;//DocState
                ALLTRIM(STR(nDocState, 2, 0))+_T+      ;
              ;//DocNumber
                ALLTRIM(cDocState)+""+ALLTRIM(STR(TTN));
             )
    ENDIF
    DBSKIP()
  ENDDO
  QOUT('<End>'+_T+'Ref_Confirm')

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  21.11.06 * 09:15:13
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Ref_PrnScripts(nRun)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_PrnScripts.txt

  IF !EMPTY(nRun)
    QQOUT('<Begin>'+_T+'Ref_PrnScripts'+_T+'Struct:ObjCode,Name,FileName,Copyes,=ScriptName')
    QOUT('Cash'+_T+'Кассовый ордер'+_T+'PrnCash.lua'+_T+'1'+_T+'Cash')
    QOUT('Move'+_T+'Перемещение'+_T+'PrnMove.lua'+_T+'2'+_T+'Move')
    QOUT('Sale'+_T+'Перечень сертификатов'+_T+'PrnSaleSertif.lua'+_T+'1'+_T+'Sertif')
    QOUT('Arrival'+_T+'Поступление'+_T+'PrnArrival.lua'+_T+'1'+_T+'Arrival')

    QOUT('Order'+_T+'Счет'+_T+'PrnOrder.lua'+_T+'1'+_T+'Order')
    QOUT('Order'+_T+'Отчет по заявкам'+_T+'RepOrder.lua'+_T+'1'+_T+'Order')
    QOUT('Order'+_T+'Отчет по заявкам.txt'+_T+'RepOrder_txt.lua'+_T+'1'+_T+'Order')

    QOUT('Sale'+_T+'Счет-фактура'+_T+'PrnSaleInvoice.lua'+_T+'1'+_T+'SaleInv')
    QOUT('Sale'+_T+'Упрощенная форма'+_T+'PrnSaleSimple.lua'+_T+'2'+_T+'Sale')
    QOUT('Sale'+_T+'Отчет по продажам'+_T+'RepSale.lua'+_T+'1'+_T+'Sale')
    QOUT('Sale'+_T+'Отчет по продажам.txt'+_T+'RepSale_txt.lua'+_T+'1'+_T+'Sale')
    QOUT('Sale'+_T+'Форма Торг-12'+_T+'PrnSaleT12.lua'+_T+'2'+_T+'SaleT12')

    QOUT('<End>'+_T+'Ref_PrnScripts')
  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  21.11.06 * 09:15:13
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION  Ref_FirmsPrnLinks(nRun)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_FirmsPrnLinks.txt

  IF !EMPTY(nRun)

    QQOUT('<Begin>'+_T+'Ref_FirmsPrnLinks'+_T+'Struct:FirmID,ScriptName')
    QOUT('<End>'+_T+'Ref_FirmsPrnLinks')

  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  20.11.06 * 13:10:56
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION  Ref_RepScripts(nRun)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_RepScripts.txt

  IF !EMPTY(nRun)

    QQOUT('<Begin>'+_T+'Ref_RepScripts'+_T+'Struct:Name,FileName')
    QOUT('Реестр кассовых ордеров'+_T+'RepCashList.lua')
    QOUT('Остатки товаров'+_T+'RepGoodsList.lua')
    QOUT('<End>'+_T+'Ref_RepScripts')

  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  16.11.06 * 16:16:02
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Ref_Clients(nRun,aKop)
  LOCAL cCodeList
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_Clients.txt

  IF !EMPTY(nRun)
    qqout('<Begin>'+_T+'Ref_Clients'+_T+'Struct:ClientID,Name,Credit,Debt,Discount,Tel,=BlockSales,=Addr,=CodesList,=PriceTypes,=PriceType,=UsePPrices,_DEBTLIST,_INN,_KPP,_FNAME,_MSALES,_SROKDOG,_VIP,_CLKONKUR')
    SELE tmp_kpl
    SET RELA TO STR(Kpl,7) INTO deb
    DBGOTOP()
    WHILE (!EOF())
      cCodeList:=""
      IF !EMPTY(CodeList)
        FOR i:=1 TO LEN(aKop) //-1
          //проверим вхождение в разрешенных КОП в строку
          //проверим дубляж
          IF PADL(LTRIM(STR(aKop[i,1],3,0)),3,"0")$CodeList .AND. ;
            !(PADL(LTRIM(STR(aKop[i,3],3,0)),2,"0")$cCodeList)
            IF EMPTY(cCodeList)
              cCodeList:=PADL(LTRIM(STR(aKop[i,3],3,0)),2,"0")
            ELSE
              cCodeList+=","+PADL(LTRIM(STR(aKop[i,3],3,0)),2,"0")
            ENDIF
          ENDIF
          /*
          IF LTRIM(STR(aKop[i,1],3,0))$CodeList .AND. ;
            !(LTRIM(STR(aKop[i,3],3,0))$CodeList)
            IF EMPTY(cCodeList)
              cCodeList:=LTRIM(STR(aKop[i,3],3,0))
            ELSE
              cCodeList+=","+LTRIM(STR(aKop[i,3],3,0))
            ENDIF
          ENDIF
          */
        NEXT
      ENDIF
      //outlog(__FILE__,__LINE__,cCodeList)

      qout(                                      ;
          ;//ClientID
            GUID_KPK("C",ALLTRIM(STR(Kpl)))+_T+             ;
          ;//Name
            LEFT(ALLTRIM(Npl), 50)+_T+        ;
          ;// Credit  15.2
            ALLTRIM(STR(deb->KZ, 15, 2))+_T+        ;
          ;// Debt
            ALLTRIM(STR(deb->DZ, 15, 2))+_T+        ;
          ;//  Discount
            ALLTRIM(STR(IIF(discount=999,0,discount), 4, 1))+_T+         ;
          ;// Tel
            LEFT(ALLTRIM(TelPl), 50)+_T+ ;
          ;//  =BlockSales блокировка продаж если-1,
          ;// 2-обратить внимание просроченный,
          ;// 3-обратить внимание заканчивается,
          ;// 4-новый
            ALLTRIM(STR(;
            IIF(dogPl < DATE(), 2,;
              IIF(dogPl <= DATE()+7, 3,;
                IIF(dtDogB >= DATE() .AND. dtDogB <= DATE()+7, 4,;
                                     0);
                  )                  ;
                ),                   ;
                  1, 0))+_T+         ;
          ;//=Addr
            LEFT(ALLTRIM(Apl), 50)+_T+        ;
          ;//=CodesList список допустимых видов оплат, от 1 до 32. Указываются ч.з запятую
            LEFT(ALLTRIM(cCodeList), 128)+_T+        ;
          ;//=PriceTypes - список кодов типов цен для клиента. Указываются ч.з запятую
            LEFT(ALLTRIM(""), 128)+_T+        ;
          ;//=PriceType - код типа цены, закреп за клиентом.
            ALLTRIM(STR(0, 2, 0))+_T+         ;
          ;//=UsePPrice - признак исползования персоналных цен
            ALLTRIM(STR(IIF(discount=999,1,0), 1, 0))+_T+         ;
          ;// _DEBTLIST список долгов по периодам
            LEFT(ALLTRIM(">7дн:"+LTRIM(STR(deb->PDZ,10,2))+" >14дн:"+LTRIM(STR(deb->PDZ1,10,2))+" >21дн:"+LTRIM(STR(deb->PDZ3,10,2))), 128)+_T+        ;
          ;//_INN
            ALLTRIM(STR(OKPO, 32, 0))+_T+     ;
          ;//_KPP
            LEFT(ALLTRIM(""), 32)+_T+         ;
          ;//_FNAME - полное наименование
            LEFT(ALLTRIM(Apl), 128)+_T+       ;
          ;//_MSALES - оборот продаж
            ALLTRIM(STR(0, 15, 2))+_T+        ;
          ;//_SROKDOG
            DTOC(DogPl)+_T+     ;
          ;//_VIP
            IIF(.F., "1", "0")+_T+              ;
          ;//_CLKONKUR - клиент конкурентов
            IIF(.F., "1", "0")                  ;
        )

      DBSKIP()
    ENDDO
  qout('<End>'+_T+'Ref_Clients')
  SELE tmp_kpl
  SET RELA TO

  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  17.11.06 * 10:11:26
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Ref_TPoints(nRun)
  Local cNGp, nDD, nSDD
  SELE tmp_ktt
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_TPoints.txt

  IF !EMPTY(nRun)
    qqout('<Begin>'+_T+'Ref_TPoints'+_T+'Struct:ClientID,TPointID,Name,Addr,=Zone,=Tel,=Category,=Contact,=FltGdsProp,_TPTYPE,_WORKTIME')
    DBGOTOP()
    WHILE (!EOF())

      nDD:=dol-date()
      nSDD:=14
      DO CASE
      CASE Empty(dol) .or. nDD > nSDD
        cNGp:=""
      CASE nDD >= 0 .and. nDD <= nSDD
        cNGp:="!"
      CASE nDD < 0
        cNGp:="*"
      ENDCASE
      cNGp+=alltrim(NGp)
  #ifdef __CLIP__
      qout(                               ;
          ;//ClientID
            GUID_KPK("C",ALLTRIM(STR(Kpl)))+_T+      ;
          ;//TPointID
            GUID_KPK("C",ALLTRIM(STR(KGp)),ALLTRIM(STR(Kpl)))+_T+      ;
          ;//Name
            LEFT(ALLTRIM(cNGp), 50)+_T+ ;
          ;//Addr
            LEFT(ALLTRIM(AGp), 64)+_T+ ;
          ;//=Zone - номер зоны,  если точки классифицированы по зонам маршутам
            LEFT(ALLTRIM(""), 8)+_T+ ;
          ;//=Tel
            LEFT(ALLTRIM(TelGp), 50)+_T+ ;
          ;//=Category "Катег.торг.точ.A|B|C"
            LEFT(ALLTRIM(STR(KgpCat)), 24)+_T+ ;
          ;//=Contact
            ;//LEFT(ALLTRIM("Контактные лица"), 128)+_T+        ;
            LEFT(ALLTRIM(DTOC(dnl,"DD.MM.YY")+"-"+DTOC(dol,"DD.MM.YYYY")+" "+alltrim(serlic)+ltrim(str(numlic))), 128)+_T+        ;
          ;//=FltGdsProp
            LEFT(ALLTRIM(IIF(KgpCat=0,;
                               "",;
                               IIF(KgpCat=1 .OR. KgpCat>=5,;
                                  "5",;
                                   STR(KgpCat);
                                );
                            ) ;
                        ), 24)+_T+        ;
          ;//_TPTYPE - перечесление
          ;// 1 Супермаркет      2 Спец. магазин 3 Отдел  4 Торговое место
          ;// 5 Киоск           6 Павильон       7 Магазин
            ALLTRIM(STR(KgpCat+1))+_T+      ;
          ;//_WORKTIME
            LEFT(ALLTRIM("с 9.00 до 18.00, обед с 13.00 до 13.30, вых. суббота,воскресенье"), 64);
        )
  #endif
      DBSKIP()
    ENDDO

    qout('<End>'+_T+'Ref_TPoints')
  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  17.11.06 * 11:12:25
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION  Ref_Price(nRun,aPrice)
  LOCAL MKeepr,i
  LOCAL nGUID_Mkeep, nKg

  SELE price
  ORDSETFOCUS("Nat")

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_Price.txt

  IF !EMPTY(nRun)
    //qqout('<Begin>'+_T+'Ref_Price'+_T+'Mode:Full'+_T+;
    //'Struct:GoodsID,FolderID,IsFolder,Name,=Code,=NameUnits,=Unit0,=Unit1,=Unit2,=MinAmount,Price1,=Price2,=Price3,=Price4,Rest,=RDiscount,=Action,=Weight,=PropList,=Comment,=VAT,=Category,=SertifID,_GTD,_STRANA')
    qqout('<Begin>'+_T+'Ref_Price'+_T+'Mode:Full'+_T+;
           'Struct:GoodsID,FolderID,IsFolder,Name,=Code,=NameUnits,=Unit0,=Unit1,=Unit2,=MinAmount,Price1,=Price2,Rest,=RDiscount,=Action,=Weight,=Weight0,=PropList,=Comment,=VAT,=Category,=SertifID,_GTD,_STRANA')
    i:=0
  DBGOTOP()
  DO WHILE !EOF()

    If !(gnEnt = 21)
      IF MNTOV < 10^6
        DBSKIP()
        LOOP
      ENDIF
    EndIf

    MKeepr:=MKeep
    i:=i+1

    //вывод маркадержателя
    nGUID_Mkeep:=111111+mkeep+i

    qout(;
  ;//GoodsID
    GUID_KPK("A", LTRIM(STR(nGUID_Mkeep)))+_T+; //пусть будет такой для Козацька розвага
  ;//FolderID
    ''+_T+;
  ;//IsFolder
    '1'+_T+;
  ;//Name
    ALLTRIM(nmkeep)+_T+; //'Козацька розвага'
  ;//Code
    '1';
  )

  DO WHILE MKeepr = MKeep
    kg_r:=INT(MNTOV/10^4)
    ng_r:=getfield('t1',"kg_r","cgrp","ngr")//название группы

    nGUID_Kg:=nGUID_MKeep+222222+kg_r


    //вывод маркадержателя + группа
      qout(;
    ;//GoodsID
      GUID_KPK("A", LTRIM(STR(nGUID_Kg)))+_T+; //пусть будет такой
    ;//FolderID
      GUID_KPK("A",LTRIM(STR(nGUID_MKeep)))+_T+;
    ;//IsFolder
      '1'+_T+;
    ;//Name
      ALLTRIM(ng_r)+_T+; //название группы
    ;//Code
      '1';
    )

    //DO WHILE kg_r = INT(MNTOV/10^4)
    DO WHILE kg_r = INT(MNTOV/10^4) .AND. MKeepr = MKeep
      qout(;
      ;//GoodsID
        GUID_KPK("A",ALLTRIM(STR(MNTOVT)))+_T+;
      ;//FolderID
          GUID_KPK("A", LTRIM(STR(nGUID_Kg)))+_T+; //пусть будет такой
      ;//IsFolder
        '0'+_T+;
      ;//Name
          LEFT(ALLTRIM(Nat), 64)+_T+ ;
      ;//Code
        LEFT(ALLTRIM(STR(MNTOVT)),64)+_T+;
      ;//NameUnits -  ед. измер
          LEFT(ALLTRIM(NEi)+',уп', 11)+_T+ ;
      ;//Unit0
        ALLTRIM(STR(1, 12, 2))+_T+        ;
      ;//Unit1
        ALLTRIM(STR(Upak, 12, 2))+_T+        ;
      ;//Unit2
        ALLTRIM(STR(1, 12, 2))+_T+        ;
      ;//MinAmount - минимальное к-во выписки
        '0'+_T)

      FOR i:=1 TO LEN(aPrice)
        IF !EMPTY(FIELDPOS(aPrice[i]))
          qqout(;
          ;//Price1
            ALLTRIM(STR(FIELDGET(FIELDPOS(aPrice[i])), 12, 2))+_T        ;
        )
        ELSE
          qqout(;
          ;//Price1
            ALLTRIM(STR(0, 12, 2))+_T        ;
        )
        ENDIF
      NEXT

      qqout(;
      ;//Rest
        ALLTRIM(STR(OsV, 15, 4))+_T+        ;
      ;//RDiscount - ограничение скидки
        ALLTRIM(STR(0, 4, 1))+_T+        ;
      ;//Action 0 - черный, 1 - красный
        ALLTRIM(STR(IIF(Merch=2,1,0), 1, 0))+_T+        ; //ALLTRIM(STR(IIF((-1)^RECNO()>0,0,1), 1, 0))+_T+        ;
      ;//Weight  - 1 - весовой, 0 - не  весовой
        ALLTRIM(STR(iif("кг" $ lower(NEi),1,0), 1, 0))+_T+        ;
      ;//Weight0  - вес первой единицы измерения товара
        ALLTRIM(STR(Ves, 15, 4))+_T+        ;
      ;//PropList - список  свойств
        LEFT(ALLTRIM(PropList), 128)+_T+ ;
      ;//Comment
          LEFT(ALLTRIM("Самые низкие цены!"), 48)+_T+ ;
      ;//VAT
        ALLTRIM(STR(20, 12, 2))+_T+        ;
      ;//Category - код категории товара
        ALLTRIM(STR(1, 10, 0))+_T+        ;
      ;//SertifID
          LEFT(ALLTRIM(""), 12)+_T+ ;
      ;//_GTD
        ALLTRIM(STR(0, 2, 0))+_T+        ;
      ;//_STRANA - страна производитель
        ALLTRIM(STR(0, 2, 0))        ;
      )
          DBSKIP()

      ENDDO
    ENDDO
  ENDDO
    qout('<End>'+_T+'Ref_Price')
  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  11-11-07 * 12:33:26pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Ref_GoodsStock(nRun)
  SELE price
  ORDSETFOCUS("Nat")

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_GoodsStock.txt
  IF !EMPTY(nRun)
    qqout('<Begin>'+_T+'Ref_GoodsStock'+_T+'Mode:Full'+_T+'Struct:GoodsID,Rest')
    DBGOTOP()
    DO WHILE !EOF()
      IF MNTOV < 10^6
        DBSKIP()
        LOOP
      ENDIF
      qout(;
      ;//GoodsID
        GUID_KPK("A",ALLTRIM(STR(MNTOVT)))+_T+;
      ;//Rest
        ALLTRIM(STR(OsV, 15, 4));
      )
      DBSKIP()
    ENDDO
      qout('<End>'+_T+'Ref_GoodsStock')
  ENDIF


  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-29-06 * 10:06:22am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Ref_PersonalPrices(nRun)
  LOCAL i
  SELE PersonalPrice

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO Ref_PersonalPrices.txt

  IF !EMPTY(nRun)

    QQOUT('<Begin>'+_T+'Ref_PersonalPrices'+_T+'Mode:Full'+_T+'Struct:ClientID,GoodsID,Price,=Discount')
    DBGOTOP()
    i:=0
    DO WHILE !EOF()
          QOUT(;
          ;//ClientID
            IIF(i=0, GUID_KPK("C",ALLTRIM(STR(kpl))),"*")+_T+      ;
          ;//GoodsID
            GUID_KPK("A",ALLTRIM(STR(MnTovT)))+_T+;
          ;//Price
            ALLTRIM(STR(Cenpr, 15, 2))+_T+        ;
          ;//=Discount'
            ALLTRIM(STR(Discount, 15, 4))        ;
        )

      i++//повтор грузополучателя
      i:=0
      DBSKIP()
    ENDDO

    QOUT('<End>'+_T+'Ref_PersonalPrices')

  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  01.12.06 * 11:03:32
 НАЗНАЧЕНИЕ......... Процедура для выгрузки в КПК описания скриптов заполнения документов
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION  Ref_FillDocScripts(nRun)
    SET CONSOLE OFF
    SET PRINT ON
    SET PRINT TO Ref_FillDocScripts.txt

    IF !EMPTY(nRun)

    qqout('<Begin>'+_T+'Ref_FillDocScripts'+_T+'Struct:DocList,Name,Message,FileNameAndFunct')

    qout("Order" +_T+;
     "По формуле 1.5 (полтора)"+_T+;
     "Заполнить документ согласно формулы 1.5 (полтора) "+;
     "товара в точке?" +_T+;
      "FillDocuments.lua:FillOrderK15")

    qout("Order" +_T+;
     "По формуле 1.5 (полтора) (в упак.)"+_T+;
     "Заполнить документ согласно формулы 1.5 (полтора) "+;
     "товара в точке (с округлением до упаковок)?" +_T+;
      "FillDocuments.lua:FillOrderPackK15")

   /*
    qout("Order" +_T+;
     "Сред. продажи минус наличие"+_T+;
     "Заполнить документ согласно средних данных истории продаж и наличия "+;
     "товара в точке?" +_T+;
      "FillDocuments.lua:FillOrder")

    qout("Order" +_T+;
     "Сред. прод. минус налич.(в упак.)"+_T+;
     "Заполнить документ согласно средних данных истории продаж и наличия "+;
     "товара в точке (с округлением до упаковок)?" +_T+;
      "FillDocuments.lua:FillOrderPack")

    qout("Sale,RSale" +_T+ "Сред. продажи минус наличие" +_T+;
         "Заполнить документ согласно средних данных истории продаж и наличия"+;
         "товара в точке?" +_T+;
         "FillDocuments.lua:FillSale")

    qout("Sale,RSale" +_T+ "Сред. прод. минус налич.(в упак.)" +_T+;
     "Заполнить документ согласно средних данных истории продаж и наличия "+;
     "товара в точке (с округлением до упаковок)?" +_T+;
     "FillDocuments.lua:FillSalePack")
    */
    qout('<End>'+_T+'Ref_FillDocScripts')

    ENDIF

    SET PRINT TO
    SET PRINT OFF
  RETURN (NIL)
/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-15-06 * 01:10:52pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION Ref_Routes(nRun,dDate)
    LOCAL dRouteTime, i, m

    dDate:=DATE()

    crtt('tempRtDt','f:kgp c:n(7) f:kpl c:n(7)  f:rtdt c:d(10) f:Comment c:c(64)')
    USE tempRtDt NEW EXCLUSIVE
    IF FILE('tempRtDt.cdx')
      ERASE ('tempRtDt.cdx')
    ENDIF
    INDEX ON rtdt TAG RtDt

    SELE TPoints
    DBGOTOP()
    WHILE (!EOF())
      FOR i:=1 TO 7
        IF !EMPTY(SUBSTR(RouteTime,i,1))
          dRouteTime:=LastMonday(dDate)+i-1
          FOR m:=0 TO 0 // 1-на две недели 0-одна
            tempRtDt->(DBAPPEND())
            tempRtDt->Kpl:=TPoints->Kpl
            tempRtDt->Kgp:=TPoints->Kgp
            tempRtDt->rtdt:=dRouteTime+(7*m)
            tempRtDt->Comment:=""
          NEXT
        ENDIF
      NEXT
      DBSKIP()
    ENDDO


    SELE tempRtDt
    DBGOTOP()

    SET CONSOLE OFF
    SET PRINT ON
    SET PRINT TO Ref_Routes.txt

    IF !EMPTY(nRun)
      qqout('<Begin>'+_T+'Ref_Routes'+_T+'Struct:=RouteID,ClientID,=TPointID,RouteTime,=Comment')
      DBGOTOP()
      DO WHILE !EOF()
        qout(                               ;
            ;//RouteId
            " "+_T+      ;
            ;//ClientID
              GUID_KPK("C",ALLTRIM(STR(Kpl)))+_T+      ;
            ;//TPointID
              GUID_KPK("C",ALLTRIM(STR(KGp)),ALLTRIM(STR(Kpl)))+_T+      ;
            ;//RouteTime
              DTOC(rtdt)+_T+     ;
            ;//Comment
              LEFT(ALLTRIM(""), 64) ;
            )
        DBSKIP()
      ENDDO
      qout('<End>'+_T+'Ref_Routes')

    ENDIF
    CLOSE tempRtDt


    SET PRINT TO
    SET PRINT OFF
    RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  22.11.06 * 08:12:41
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION GUID_KPK(cPref,cKod, cKod1)
  LOCAL cGUID
  cGUID:="FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"
  //outlog(__FILE__,__LINE__,cGUID,LEN(cGUID)-(LEN(cPref)+LEN(cKod))+1,LEN(cPref+cKod), cPref+cKod)
  cGUID:=STUFF(cGUID,LEN(cGUID)-(LEN(cPref)+LEN(cKod))+1,LEN(cPref+cKod), cPref+cKod)
  IF !EMPTY(cKod1)
    cGUID:=STUFF(cGUID,1,LEN(cKod1), cKod1)
  ENDIF
  //outlog(__FILE__,__LINE__,cGUID)
  RETURN (cGUID)

FUNCTION LastMonday(dDate)
   RETURN (dDate - DOW(dDate) + 2)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  05-30-07 * 11:50:21am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ......... сделать изменения kta_ost() для загрузки новых цен
 */
FUNCTION PriceType2Kop(cTypeArr)
  LOCAL aMass

  DO CASE
  CASE UPPER(cTypeArr)=UPPER("kop")

    IF gnEnt = 21  // Лодис
      aMass:={0,150}
    ELSE //IF gnEnt = 20  // ресурс
      //aMass:={0,152}
      aMass:={0,160}
    ENDIF

  CASE UPPER(cTypeArr)=UPPER("price")
    IF gnEnt = 21  // Лодис
      aMass:={"CenPr","CenPs"}
    ELSE //IF gnEnt = 20  // ресурс
      //aMass:={"CenPr","c29"}
      aMass:={"CenPr","CenPr"}
    ENDIF

  CASE UPPER(cTypeArr)=UPPER("nm_price")
    IF gnEnt = 21  // Лодис
      aMass:={'Витрина','Цена +% (150)'}
    ELSE //IF gnEnt = 20  // ресурс
      //aMass:={'Витрина','Базовая (152)'}
      aMass:={'Витрина','!!-НЕЛЬЗЯ-!!'}
    ENDIF

  CASE UPPER(cTypeArr)=UPPER("guid_price")
      aMass:={;
      "CBCF495A-55BC-11D9-848A-00112F43529A",;
      "CBCF495B-55BC-11D9-848A-00112F43529A";
               }

  ENDCASE
  RETURN (aMass)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-13-15 * 05:07:16pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION AddKplKgpSkDoc()

  COPY STRU TO tmp_ktt1
  USE tmp_ktt1 NEW EXCLUSIVE
  INDEX ON STR(KPL)+STR(KGP) TAG "kgp_kpl"

    SELE tmp_kpl
    DBGOTOP()
    WHILE (!EOF())
      IF STR(tmp_kpl->Kpl)$"     20034"
        SELECT tmp_kpl
        DBSKIP()
        LOOP
      ENDIF
      IF !skdoc->(DBSEEK(STR(tmp_kpl->kpl,7)))
        SELECT tmp_kpl
        DBSKIP()
        LOOP
      ENDIF

      SELE skdoc
      DO WHILE skdoc->Kpl = tmp_kpl->Kpl
        // берем из Д-ки о груз.получ.
        IF skdoc->KGP # 0 ;
           .AND. .NOT. TPoints->(DBSEEK(STR(skdoc->KPL)+STR(skdoc->KGP))) ;
           .AND. .NOT. tmp_ktt1->(DBSEEK(STR(skdoc->KPL)+STR(skdoc->KGP)))
           COPY TO tmp1 NEXT 1
           SELE tmp_ktt1
           APPEND FROM tmp1
           SELE skdoc
        ENDIF
        DBSKIP()
      ENDDO

      SELECT tmp_kpl
      DBSKIP()
    ENDDO

    //заполняем
    SELE tmp_ktt1
    DBGOTOP()
    DO WHILE !EOF()
      kln->(netseek("t1","tmp_ktt1->kgp"))
      _FIELD->ngp:=kln->nkl
      _FIELD->agp:=kln->adr
      _FIELD->telGp:=kln->tlf
      SELE tmp_ktt1
      DBSKIP()
    ENDDO
    CLOSE tmp_ktt1

  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  11-20-15 * 11:25:27am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION cdb_load(ktar,nAgSk,cFio,dShDateBg, dShDateEnd, aKop,;
     nRef_Price,nDoc_Debt,nRef_Sales,nRef_Routes, nRef_Ini)

  LOCAL oRef_System
  LOCAL cktar:=PADL(LTRIM(STR(ktar,3)), 3, "0")
  LOCAL aLoadFile //, a PlSl_TA

  set("PRINTER_CHARSET", "cp1251") //"utf-8")//"cp1251")
  SET DATE FORMAT "yyyy-mm-dd"
  SET CENTURY ON

  USE (gcPath_ew+"deb\deb") ALIAS deb NEW SHARED
  SET ORDER TO TAG t1

  IF gnEnt=20
    USE (gcPath_ew+"deb\accord_deb") ALIAS skdoc NEW SHARED READONLY
    SET ORDER TO TAG t1
  else
    USE (gcPath_ew+"deb\skdoc") ALIAS skdoc NEW SHARED READONLY
    SET ORDER TO TAG t1
  endif
     //index on str(kpl)+str(ktan) tag t1


  USE (gcPath_ew+"deb\bdoc") ALIAS bdoc  NEW SHARED
  SET ORDER TO TAG t1

  USE ('k'+cktar+'pcen.dbf')  ALIAS PersonalPrice NEW EXCLUSIVE

  USE ('k'+cktar+'cnfr.dbf') ALIAS Confirm NEW EXCLUSIVE
  USE ('k'+cktar+'plsl.dbf') ALIAS PlanSale NEW EXCLUSIVE

  IF FILE('k'+cktar+'mrch.cdx');  ERASE ('k'+cktar+'mrch.cdx');  ENDIF
  USE ('k'+cktar+'mrch.dbf') ALIAS Merch NEW EXCLUSIVE
  INDEX ON STR(Kpl)+STR(Kgp)+STR(MNTOV)+STR(WEEK(Dop),2) TAG KGp_MnTov
  INDEX ON STR(Kpl)+STR(Kgp)+STR(MNTOVT)+STR(WEEK(Dop),2) TAG KGp_MnTovT

  IF FILE('k'+cktar+'sale.cdx');   ERASE ('k'+cktar+'sale.cdx');  ENDIF
  USE ('k'+cktar+'sale.dbf') ALIAS Sales NEW EXCLUSIVE
  INDEX ON STR(Kpl)+STR(Kgp)+STR(MNTOV)+STR(WEEK(Dop),2) TAG KGp_MnTov
  INDEX ON STR(Kpl)+STR(Kgp)+STR(MNTOVT)+STR(WEEK(Dop),2) TAG KGp_MnTovT

  IF FILE('k'+cktar+'ost.cdx'); ERASE ('k'+cktar+'ost.cdx');  ENDIF
  USE ("k"+cktar+"ost") ALIAS price_full NEW EXCLUSIVE
  INDEX ON STR(mkeep)+STR(INT(MnTov/10^4),3)+Nat TAG Nat
  INDEX ON nmkeep+STR(INT(MnTov/10^4),3)+Nat TAG mnkeep

  IF FILE('k'+cktar+'ot.cdx');    ERASE ('k'+cktar+'ot.cdx');  ENDIF
  USE ("k"+cktar+"ot") ALIAS price NEW EXCLUSIVE
  INDEX ON STR(mkeep)+STR(INT(MnTov/10^4),3)+Nat TAG Nat
  INDEX ON nmkeep+STR(INT(MnTov/10^4),3)+Nat TAG mnkeep

  IF FILE('k'+cktar+'firm.cdx');    ERASE ('k'+cktar+'firm.cdx');  ENDIF
  USE ("k"+cktar+"firm") ALIAS TPoints NEW EXCLUSIVE
  INDEX ON STR(KPL)+STR(KGP) TAG "kgp_kpl"

  //торговые точки
  TOTAL ON STR(KPL)+STR(KGP) TO tmp_ktt
  //клиеты
  TOTAL ON STR(KPL) TO tmp_kpl
  //CLOSE TPoints

  USE tmp_ktt NEW EXCLUSIVE
  USE tmp_kpl NEW EXCLUSIVE

   tmp_kpl->(AddKplKgpSkDoc())
  SELE tmp_ktt
  APPEND FROM tmp_ktt1

  //какие цены грузить
  aPrice:=PriceType2Kop("Price")


         //витрина  152
  cdbSystem_ini(nRef_Ini, ktar, nAgSk, cFio,dShDateBg, dShDateEnd,aPrice)
  cdbCategory()
  cdbSales(nRef_Sales, dShDateBg, dShDateEnd)

  cdbDoc_Debt(nDoc_Debt,ktar)
  cdbDoc_Cash(nDoc_Debt,aKop)

  cdbRoutes(nRef_Routes)
  cdbFirms(nRef_Ini)
  cdbClients(nRef_Routes,aKop)
  cdbTPoints(nRef_Routes)


  IF STR(s_tag->Ref_Price) $ "7,8" //s_tag->Dt_Price#DATE()
    //передаем новые цены и новые индивидуальные цены
    cdbPrice(nRef_Price,aPrice)
    cdbPlanSale(1)
  ELSE
    //передаем новые цены
    #ifdef CDBFULLPRICE
      cdbPrice(nRef_Price,aPrice,aPrice)
    #else
      cdbGoodsStock(nRef_Price)
      cdbPlanSale(0)
    #endif
    //новые остатки
  ENDIF

  IF (STR(s_tag->Ref_Price) $ "7,8" .AND. ; //s_tag->Dt_Price#DATE() .AND.;
     !EMPTY(nRef_Price)) .OR. !EMPTY(nRef_Routes)
    cdbPersonalDiscount(nRef_Price+nRef_Routes)
  ELSE
    cdbPersonalDiscount(0)
  ENDIF

  //Ref_Barcodes()
  //Ref_Stores(nRef_Ini)
  //Ref_Sertif(nRef_Ini)

  //Ref_Commands(.T.) //nRef_Ini)

  CdbDoc_Confirm()

  //Ref_AttrTypes(nRef_Ini,aKop)
  //Ref_PrnScripts(nRef_Ini)
  //Ref_FirmsPrnLinks(nRef_Ini)
  //Ref_RepScripts(nRef_Ini)
  //Ref_FillDocScripts(nRef_Ini)
  //Ref_Scripts(nRef_Ini)

  //set translate path OFF
  SET CONSOLE OFF;  SET PRINT ON
  SET PRINT TO QOUT.dat
  QOUT("")
  SET PRINT TO  ;  SET PRINT OFF




  SET CONSOLE OFF;  SET PRINT ON
  SET PRINT TO DATAEND.txt
    QQOUT("</DATA>")
  SET PRINT TO  ;  SET PRINT OFF

  SET CONSOLE OFF;  SET PRINT ON
  SET PRINT TO CATALOGS.txt
    QQOUT('<CATALOGS Comment="Справочники">')
  SET PRINT TO;  SET PRINT OFF


  SET CONSOLE OFF;  SET PRINT ON
  SET PRINT TO CATALOGSEND.txt
  QQOUT("</CATALOGS>")
  SET PRINT TO  ;  SET PRINT OFF

  SET CONSOLE OFF;  SET PRINT ON
  SET PRINT TO DOCUMENTS.txt
    QQOUT('<DOCUMENTS Comment="Документы">')
  SET PRINT TO;  SET PRINT OFF


  SET CONSOLE OFF;  SET PRINT ON
  SET PRINT TO DOCUMENTSEND.txt
    QQOUT("</DOCUMENTS>")
  SET PRINT TO  ;  SET PRINT OFF




  SET CONSOLE OFF;  SET PRINT ON
  SET PRINT TO FromCDB.dat
    QQOUT('<?xml version="1.0" encoding="UTF-8"?>')
     QOUT('<DATA DBVERSION="1977">')
  SET PRINT TO;  SET PRINT OFF
    FILEAPPEND("QOUT.dat","FromCDB.dat")
    FILEAPPEND("cdbSystem.txt","FromCDB.dat");FILEAPPEND("QOUT.dat","FromCDB.dat")

  aLoadFile:={;
  "CATALOGS.txt",;
    "cdbClients.txt" ,;
    "cdbTPoints.txt" ,;
    "cdbDogovor.txt" ,;
    "cdbCodeList.txt",;
    "cdbPersDisc.txt",;
    "cdbPrice.txt"   ,;
    "cdbSales.txt"   ,;
    "cdbCategory.txt",;
    "cdbFirms.txt"   ,;
  "CATALOGSEND.txt",;
  "DOCUMENTS.txt",;
    "cdbDoc_Debt.txt"   ,;
    "cdbDoc_Cash.txt"   ,;
    "cdbDoc_Routes.txt" ,;
    "cdbDoc_Confirm.txt",;
  "DOCUMENTSEND.txt",;
  "cdbPlanSale.txt";
  }

   AEVAL(aLoadFile,{|cFile| IIF(FILESIZE(cFile)=0,;
   (NIL),;//(outlog(__FILE__,__LINE__,FILE(cFile),cFile,FILESIZE(cFile))),;
    (;
    ;//outlog(__FILE__,__LINE__,FILE(cFile),cFile,FILESIZE(cFile)),;
    FILEAPPEND(cFile,"FromCDB.dat"),;
    FILEAPPEND("QOUT.dat","FromCDB.dat");
  );
  )})

  FILEAPPEND("DATAEND.txt","FromCDB.dat");FILEAPPEND("QOUT.dat","FromCDB.dat")



  CLOSE deb
  CLOSE skdoc
  CLOSE bdoc

  CLOSE PersonalPrice
  CLOSE Confirm
  CLOSE Merch

  CLOSE Sales
  CLOSE price
  CLOSE price_full
  CLOSE tmp_ktt
  CLOSE tmp_kpl
  CLOSE TPoints
  CLOSE PlanSale
  //iconv -f CP1251 -t UTF8 fromCDB.dat -o /tmp/fromCDB.dat

  RETURN (NIL)



/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  11-20-15 * 11:25:27am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION cdbSystem_ini(nRef_Ini, ktar, nAgSk, cFio,dShDateBg, dShDateEnd,aPrice)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbSystem.txt
  //qqout('<?xml version="1.0" encoding="UTF-8"?>')
  //qout('<DATA DBVERSION="1977">')
  qqout('  <CONSTANTS Comment="Константы">')
  qout('    <ELEMENTS>')
  qout('      <ITEM GUID="D2B5508C-7453-4A52-B803-A846992A485D" VALUE="грн."/>')
  qout('      <ITEM GUID="ADB99DF4-739B-4E6F-AEA9-E751B55CB18A" VALUE="Валюта: наименование, код гривна, 980"/>')
  qout('      <ITEM GUID="13AF34A5-664D-4AAD-A29C-EEFC04FEFCA9" VALUE="кг"/>')
  //фирма от которой выписывается берется из справочника
  qout('      <ITEM GUID="13FAF2A0-3D1E-469E-BC53-CDADA6AC1375" VALUE="'+GUID_KPK("C",ALLTRIM(STR(gnKkl_c)))+'"/>')

  // использовать ПланПродаж
  qout('      <ITEM GUID="C26639D8-F729-4C9F-ABB4-7154AE9C632B" VALUE="0"/>')

  // пересчет в базовую Ед. изм.
  qout('      <ITEM GUID="0D0B118F-A77D-4A90-ADFB-C79E5EB08CDB" VALUE="1"/>')
  qout('      <ITEM GUID="0DE4A49F-691B-4910-95BF-6F25A281D9E1" VALUE="0"/>')
  qout('      <ITEM GUID="6E9470DB-C618-4BF8-B510-D1E39E2217F6" VALUE="0"/>')
  qout('      <ITEM GUID="C21ED754-43D4-423D-BDB6-8D2F36B9F8D1" VALUE=""/> ')
  qout('      <ITEM GUID="63B7D515-CE1D-4F91-B65E-1293495A07E1" VALUE="0"/>')
  //склад справочника складов
  qout('      <ITEM GUID="86BA5DAD-16D0-46B8-9D8D-3EAB2CF08685" VALUE="BD72D91F-55BC-11D9-848A-00112F43529A"/>')
  qout('      <ITEM GUID="8C52BBBF-8BBB-447D-B18B-06860D372818" VALUE="1"/>')
  qout('      <ITEM GUID="B201164E-E265-4C1D-B3D0-0579BCD1FDA6" VALUE="0"/>')
  //ИндификаторФактическогоАдреса - вид конт инфор котрагента, который отображается в "маршут". Значение из спр. Виды контакт информации.
  qout('      <ITEM GUID="1B3D41B2-EB00-4F25-A476-6A668C5E69F0" VALUE="663DE54A-DA59-44A4-9BD0-7509DFA63856"/>')
  qout('      <ITEM GUID="7BC85296-F536-411E-AAA9-74AD5C7ADEA2" VALUE=""/>')
  qout('      <ITEM GUID="0270B3D5-4213-419B-9E3A-48CBA4CAEC04" VALUE="1"/>')
  qout('      <ITEM GUID="0A253E8B-9043-414B-8026-0C9369F781AD" VALUE=""/>')
  //точность к-во товара 0...4
  qout('      <ITEM GUID="27952AB3-1365-4B56-A0EF-34EC0133E5D3" VALUE="1"/>')
  qout('      <ITEM GUID="5D54ED85-FDEA-4027-8ECD-129C27BDBF64" VALUE="2"/>')
  qout('      <ITEM GUID="A978F039-3F17-4705-B7F6-16C580C9AC5F" VALUE="2"/>')
  // мобильный склад D54381E5-D965-11DC-B30B-0018F30B88B5
  qout('      <ITEM GUID="448B6FAB-5E21-479C-9A9A-63E8ECED59B9" VALUE=""/>')
  qout('      <ITEM GUID="F4F9EA70-D4F9-4F21-AC4A-F073C5D08B95" VALUE=""/>')
  qout('      <ITEM GUID="5DC7AEA9-E9DA-4AA4-BABB-DF5A43AF1AD5" VALUE="0"/>')
  qout('      <ITEM GUID="DDEDCE5E-7A69-4858-BC89-F48E3E44A8EF" VALUE=""/>')
  qout('      <ITEM GUID="8E0A70A1-476C-4C7B-A8A7-0C9CE334FC68" VALUE="0"/>')
  qout('      <ITEM GUID="36767A2E-4DF5-43B5-9813-893BF6F65A7F" VALUE="0"/>')
  qout('      <ITEM GUID="73355324-F463-428A-91D2-2868DD35A168" VALUE="0"/>')
  qout('      <ITEM GUID="B0FDDB94-CAF7-4003-B2FD-DF15BD2F1F1B" VALUE="0"/>')
  qout('      <ITEM GUID="A2E1CC68-0624-45A6-8057-EFD35259B9FE" VALUE="'+;
    ALLTRIM(PADL(LTRIM(STR(ktar,3)), 3, "0"))+ALLTRIM(STR(nAgSk,3))+" "+;
    cFio +'"/>')
  qout('      <ITEM GUID="6D4C184B-810D-4C23-BA6E-FB7E03B48812" VALUE="1"/>')
  qout('      <ITEM GUID="B8396958-7D13-4633-A6C3-C8D639CBF9E6" VALUE="1"/>')
  // рекоменд к=во показывать 1
  qout('      <ITEM GUID="E4D51F85-CC81-402C-9F14-A8EAA07B945F" VALUE="1"/>')
  qout('      <ITEM GUID="690B5736-E1B9-41EF-A132-807ACAD31687" VALUE="0"/>')
  qout('      <ITEM GUID="D2DD4509-E164-4E6C-A0B2-C46B5CA0397D" VALUE="1"/>')
  qout('      <ITEM GUID="D902C64A-9A7A-40D1-8067-E4BB6B309534" VALUE="0"/>')
  qout('      <ITEM GUID="79C698DB-3C55-465E-ACFE-4741ACDD5655" VALUE="'+GUID_KPK("B",ALLTRIM(PADL(LTRIM(STR(ktar,3)), 3, "0"))+ALLTRIM(STR(nAgSk,3)))+'"/>')
  qout('      <ITEM GUID="4A6B2C4C-445B-4985-A509-10FB1A2D57CE" VALUE="0"/>')
  qout('      <ITEM GUID="3ABCD996-1632-46F6-8855-CB25759BC304" VALUE="0"/>')
  qout('      <ITEM GUID="8DEB5086-FB67-436E-A5F7-5118CE0DC09E" VALUE="0"/>')
  qout('      <ITEM GUID="B1945151-4055-4BC4-A9A0-9E1D39BABE99" VALUE="0"/>')
  //маршут показывать 1
  qout('      <ITEM GUID="99EEEEF3-015A-4727-8166-65F2DCCEAB29" VALUE="1"/>')
  qout('      <ITEM GUID="ED0274E1-3B90-4DB9-951F-3037260B80AC" VALUE="1"/>')
  qout('      <ITEM GUID="EF7C73D2-D745-4E04-A5F1-AFCBBCB72F05" VALUE="0"/>')
  qout('      <ITEM GUID="6E7183CC-ABF6-4B18-AF75-F4D851551FD4" VALUE="0"/>')
  qout('      <ITEM GUID="6517DA49-A145-43A7-8730-A3E9978E437B" VALUE="0"/>')
  qout('      <ITEM GUID="16D90B81-6BA0-4E72-A471-4350213B934E" VALUE="1"/>')
  qout('      <ITEM GUID="32CD846C-CAFA-4006-BC05-EF2CD135E2EA" VALUE="1"/>')
  //работа со перс скиками
  qout('      <ITEM GUID="4838F24A-FFAA-48F3-98F8-7863125944C8" VALUE="1"/>')
  qout('      <ITEM GUID="54E2A0B0-4F94-499D-875A-9D2EE7634DA9" VALUE="300"/>')

  IF .T. // PADL(LTRIM(STR(ktar,3)), 3, "0") $ "482 775"
    //GPS
    //Вкл.
    qout('      <ITEM GUID="E8DCA437-FA0D-4F92-B7B8-4A7A162638C5" VALUE="1"/>')

    //"РежимОпределенияКоординат"
    aRegOprKt:={;
    {'GPS',              '95013C3C-BC8B-468B-A797-69998743613A' },;// 1
    {'GPSИМобильныеСети','F1D4E26C-BECE-495B-BFED-F42F4B40AE4A' },;// 2
    {'МобильныеСети',    'C0BE1868-DD2F-4245-95B3-4BFFE605C470' }; // 3
    }
    /*
    РежимОпределенияКоординат
    В значении константы указывается режим определения GPS-координат.
    Значение выбирается из перечисления "РежимОпределенияКоординат".
    */
    qout('      <ITEM GUID="964FFAD2-52AC-4C67-8B36-C7F99D08445C" VALUE="'+aRegOprKt[2,2]+'"/>')



  ELSE
    qout('      <ITEM GUID="E8DCA437-FA0D-4F92-B7B8-4A7A162638C5" VALUE="0"/>')
  ENDIF

  qout('      <ITEM GUID="711587ED-1589-4E69-A7F7-09ADE3FB5888" VALUE="0"/>')
  qout('      <ITEM GUID="23AE51B7-55DE-46A0-9ECC-A796EB5035D2" VALUE="111"/>')
  qout('      <ITEM GUID="138F9A6C-7F96-4136-9FBC-0663476BC094" VALUE="1"/>')
  qout('      <ITEM GUID="E41A7026-551C-44F9-997F-51A8B68B88AC" VALUE="0"/>')
  qout('      <ITEM GUID="C6B9563F-947A-46C2-82DD-D375E103317D" VALUE="0"/>')
  qout('      <ITEM GUID="CCD3F25E-A29B-419F-B8A2-D58E380EFAE2" VALUE="0"/>')
  qout('      <ITEM GUID="F52E3C06-48D6-4809-AE16-13C61E78EABD" VALUE="0"/>')
  qout('      <ITEM GUID="83A6772E-4DDE-4668-9318-BDF82BFDE445" VALUE="0"/>')
  qout('      <ITEM GUID="A86959B3-ED83-44D8-B457-DF8DFEA9EFDD" VALUE="1"/>')
  qout('      <ITEM GUID="AEDDB719-EB7A-493E-B80E-EE2D63E76FE5" VALUE="0"/>')
  qout('      <ITEM GUID="0DEEF076-FF1F-4E4D-ACB5-8344BE0281A1" VALUE="1"/>')
  qout('      <ITEM GUID="60A12916-08C0-4ABF-86D2-7F508282BAB8" VALUE="/data/data/ru.agentplus.agentp2/backup/"/>')
  qout('      <ITEM GUID="5616D1E9-BFA3-40FC-BABA-852D16B5E774" VALUE="0"/>')
  qout('      <ITEM GUID="FAF41508-AB25-4E1B-9BBD-F80634A3D264" VALUE="0"/>')
  qout('      <ITEM GUID="4C6B29D4-3D61-43C7-A063-A63823E55069" VALUE="0"/>')
  //qout('      <ITEM GUID="90C4C934-85A6-449E-A519-D5AE44DA667B" VALUE="5B629B5B-0D6E-081E-3335-323938353035"/>')
  qout('      <ITEM GUID="072EC906-BD0B-4B75-AFA8-BECE1434F1EB" VALUE="0"/>')
  qout('      <ITEM GUID="ABC5B73A-F477-406B-89C5-E9AAB3B4F1E1" VALUE="0"/>')
  qout('      <ITEM GUID="8886E1E1-FCDA-4EA0-85F8-DF3D3DD8A5E3" VALUE="1"/>')
  qout('      <ITEM GUID="72889BFF-CC95-4C2E-9C4E-0D28E2EFBF7C" VALUE="0"/>')
  qout('      <ITEM GUID="56649629-21E4-4116-AEC6-E794F12C62FE" VALUE="0"/>')
  qout('      <ITEM GUID="C64DAC8A-2FBC-40BF-BF49-143398AAAC9A" VALUE="0"/>')
  qout('      <ITEM GUID="DC63708B-9257-48DC-9F16-D9846AC7D5FE" VALUE="1"/>')
  qout('      <ITEM GUID="EA614964-30B8-4065-BD65-940E38DB1F31" VALUE="1"/>')
  qout('      <ITEM GUID="F984E263-B838-489E-A1D4-F775DB7EDE98" VALUE="1"/>')
  // алгоритм автозаполнения 1 - посл. прод. 2 - мах продажа 3 - ср.прод-наличие 4 - формула 1.5
  qout('      <ITEM GUID="404D1878-4456-4095-BFD5-EAF93F6C0E1B" VALUE="3"/>')
  qout('      <ITEM GUID="195BCCD6-F8EA-481E-A411-1D33A52CFE49" VALUE="0"/>')
  qout('      <ITEM GUID="B69EC9A6-565F-4E3E-844F-0060C5975FED" VALUE="0"/>')
  qout('      <ITEM GUID="68524BCF-B992-4896-8A91-44EE31498831" VALUE="0"/>')
  qout('      <ITEM GUID="018DD98C-D617-4D35-B5C0-EFDABF6B37A2" VALUE="0"/>')
  qout('      <ITEM GUID="32798A23-C58F-4C7A-8C3D-36E5A60184D3" VALUE=""/>')
  qout('      <ITEM GUID="61A474B1-21D0-4047-B2D5-7213A7294050" VALUE="Заказ,Долг,ПКО,Мерчендайзинг,Посещение,Реализация,Перемещение,Поступление,Задание"/>')
  qout('      <ITEM GUID="B917AF50-AF2B-43C1-A111-CC8822B180C2" VALUE="0"/>')
  qout('      <ITEM GUID="4280AE75-B17C-48C2-9140-4FC09853A4AD" VALUE="0"/>')
  qout('      <ITEM GUID="344436BC-3E1B-42D7-B453-496D61EAE2D8" VALUE="/sdcard/AgentPlusPictures/"/>')
  qout('      <ITEM GUID="EC1C050F-9183-4CF8-9A40-8546C8617EBB" VALUE="1"/>')
  qout('      <ITEM GUID="DF297AD7-E2CE-478A-974E-FB399239E23E" VALUE="2013-03-29T11:10:15"/>')
  qout('    </ELEMENTS>')
  qout('  </CONSTANTS>')

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  11-20-15 * 09:46:58pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION cdbSales(nRun, dSHDATEBG, dShDateEnd)
  LOCAL nKgp, nKpl, nMnTov, nQRest, i, nCurWeek, nCurWeekFor
  LOCAL cSales, nSales
  LOCAL aDt_Range,k


    dShDateBg:=LastMonday(dShDateBg) //понедельник этой недели
    dShDateEnd:=LastMonday(dShDateEnd)+7-2 //суббота анализируемой недели


  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbSales.txt

  IF !EMPTY(nRun)
    QQOUT('<CATALOG GUID="AF9FAA26-9638-41C5-BFCE-9514E670EF2E" KILLALL="1" Comment="Справочник.ИсторияПродаж">')
     QOUT('  <ELEMENTS>')

    SELE tmp_ktt //торговые точки
    DBGOTOP()
    DO WHILE !EOF()
      nKgp:=Kgp
      nKpl:=Kpl

      lWeek_One:=.F.
      aDt_Range:={}

      IF TPoints->(DBSEEK(STR(nKPL)+STR(nKGP)))
        IF !EMPTY(TPoints->RouteTime) .AND. LEN(ALLTRIM(TPoints->RouteTime))>1

          aDt_Range:=Dt_Range(dShDateEnd,TPoints->RouteTime)

        ELSE
          lWeek_One:=.T.
        ENDIF
      ELSE
        lWeek_One:=.T.
      ENDIF

      IF lWeek_One
        nWeekEnd:=WEEK(dSHDATEEND)+IIF(WEEK(dSHDATEBG) > WEEK(dSHDATEEND), 52, 0)
        //outlog(__FILE__,__LINE__,nCurWeekFor,nWeekEnd,WEEK(dSHDATEBG),WEEK(dSHDATEEND))

        k:=0
        FOR nCurWeekFor:=WEEK(dSHDATEBG) TO nWeekEnd

          IF WEEK(dSHDATEBG) > WEEK(dSHDATEEND)
            nCurWeek:=nCurWeekFor-IIF(WEEK(dSHDATEBG) > WEEK(dSHDATEEND) .AND. nCurWeekFor<=52, 0, 52)
           ELSE
            nCurWeek:=nCurWeekFor
          ENDIF
          AADD(aDt_Range,{dSHDATEBG+(7*k), dSHDATEBG+(7*(k+1))-1})
          k++
        NEXT
      ENDIF

      i:=0

      SELE price
      DBGOTOP()
      DO WHILE !EOF()

        //nMnTov:=MnTov
        nMnTov:=MnTovT

        cSales:="" //строка с продажами
        nSales:=0

        FOR k:=1 TO LEN(aDt_Range)
        //FOR nCurWeekFor:=WEEK(dSHDATEBG) TO nWeekEnd

          SELE Sales
          OrdSetFocus("KGp_MnTovT")
          IF DBSEEK(STR(nKpl)+STR(nKgp)+STR(nMnTov)) //+STR(nCurWeek,2))
            SUM KVP TO nKVP ;
            WHILE STR(nKpl)+STR(nKgp)+STR(nMnTov) = ;
              STR(Kpl)+STR(Kgp)+STR(MnTovT) ; // MnTov MnTovT
            FOR  Dop>=aDt_Range[k,1] .AND. Dop<=aDt_Range[k,2]
            //WHILE STR(nKpl)+STR(nKgp)+STR(nMnTov)+STR(nCurWeek,2) = STR(Kpl)+STR(Kgp)+STR(MnTov)+STR(WEEK(Dop),2)
          ELSE
            nKVP:=0
          ENDIF

          nQRest:=0
          SELE Merch
          OrdSetFocus("KGp_MnTovT")
          IF DBSEEK(STR(nKpl)+STR(nKgp)+STR(nMnTov)) //+STR(nCurWeek,2))
            SUM KVP TO nQRest ;
            WHILE STR(nKpl)+STR(nKgp)+STR(nMnTov) = ;
                  STR(Kpl)+STR(Kgp)+STR(MnTovT) ; // MnTov MnTovT
            FOR  Dop>=aDt_Range[k,1] .AND. Dop<=aDt_Range[k,2]
            //WHILE STR(nKpl)+STR(nKgp)+STR(nMnTov)+STR(nCurWeek,2) = STR(Kpl)+STR(Kgp)+STR(MnTov)+STR(WEEK(Dop),2)
          ELSE
            nQRest:=0
          ENDIF

          cSales+=LTRIM(STR(nKVP ,4,0))+" "
          nSales+=(nQRest+nKVP)

          /*
          IF nKgp = 8460198
            outlog(__FILE__,__LINE__,nMnTov,nQRest,nKVP,aDt_Range[k,1],aDt_Range[k,2])
          ENDIF
          */

        NEXT

        IF ROUND(nSales,3) # 0 //есть продажи
          cSales:=RTRIM(cSales)
          QOUT('    <ITEM '+;
          ' GUID="'+uuid()+'"'+;
              ;//TPointID
          ' A02="'+GUID_KPK("C",ALLTRIM(STR(nKgp)),ALLTRIM(STR(nKpl)))+'"'+; //GUID клиент
              ;//GoodsID
          ' A04="'+GUID_KPK("A",ALLTRIM(STR(nMnTov)))+'"'+; //GUID товар
              ;//Sales
          ' A07="'+RIGHT(cSales, 100)+'"'+;  // сторка к-во
          '/>')
          i++//повтор грузополучателя
        ENDIF


        SELE price
        SKIP
      ENDDO

      SELE tmp_ktt //торговые точки
      SKIP
    ENDDO

    QOUT('  </ELEMENTS>')
    QOUT('</CATALOG>')
  //ELSE
    //QOUT('  </ELEMENTS>')
  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  01-21-17 * 01:38:24pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION cdbPlanSale(nRun)
  /*
  6.7.  Типы планов продаж (стандарт)
  Перечисление "Типы планов продаж" предназначено для хранения списка типов планов продаж.
  */
  LOCAL aPlSl_Ctg:={;
                    { 'AFE4839F-2734-4BF0-A209-08CCB9A358E9',; //1,1
                    'Планы продаж по категориям товаров.'; // 1,2
                    },;
                    {'DC403B36-A935-4624-AA96-CF4B85097612',; // 2,1
                    'Планы продаж по товарам.';              // 2,2
                    };
                  }
  LOCAL dBeg:=STOD(STR(YEAR(DATE()),4)+'01'+'01')
  LOCAL dEnd:=STOD(STR(YEAR(DATE()),4)+'12'+'31')
  LOCAL nPerCent


  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbPlanSale.txt
  IF !EMPTY(nRun)
    sele PlanSale
    DBGoTop()

    qqout('  <CONSTANTS Comment="Константы">')
    qout('    <ELEMENTS>')
    // использовать ПланПродаж
    qout('      <ITEM GUID="C26639D8-F729-4C9F-ABB4-7154AE9C632B" VALUE="1"/>')
    // Основной ПланПродаж
    qout('      <ITEM GUID="50F284E8-BCD6-47D4-8DD1-181D9592CB20" VALUE="'+PlanSale->gplsl+'"/>')
    qout('    </ELEMENTS>')
    qout('  </CONSTANTS>')


    QOUT('<CATALOGS Comment="Справочники">')
    QOUT('     <CATALOG GUID="D6D52ADA-0F38-4112-AF3C-2F1E425A43D1"  Comment="Справочник.Номенклатура">')

    QOUT('       <GROUPS>')
    QOUT('         <GROUP GUID="E42DA5B9-E29B-43E1-B7E3-9B500879D6B7" Comment="Элементы группировки по категориям">')
    QOUT('           <ELEMENTS>')

    DBGoTop()
    Do While !eof()
      nPerCent:= PlanSale->Fakt / PlanSale->Plan * 100
      QOUT('             <ITEM '+;
          ' GUID="' + PlanSale->gPlslTa + '"'+; // GUID - эле-тов ПланаПродаж
            ' Name="'+LEFT(XmlCharTran(PADR(PlanSale->nplslta,25,' ');
            +'|'+STR(PlanSale->Plan,12,0);
            +'|'+STR(PlanSale->Fakt,12,0);
            +'|'+STR(nPerCent,12,0)+'%';
            ), 150)+'"'+;
            ' ParId="'+''+'"'+;
                '/>')

      sele PlanSale
      DBSkip()
    EndDo

    QOUT('           </ELEMENTS>')
    QOUT('         </GROUP>')

    QOUT('       </GROUPS>')

    QOUT('       <ELEMENTS Comment="Элементы справочника Номенклатура">')
    DBGoTop()
    Do While !eof()
      /*
      //{'План продаж',ktar,'Общий объем',   9000,  1000,  11, i=8 , i=7 }
      _FIELD->nplsl :=  'План продаж'
      _FIELD->nplslta := 'Общий объем'
      _FIELD->plan := 9000
      _FIELD->fakt := 1000
      _FIELD->gPlsl:=cGuid_plsl
      _FIELD->gPlslTa:=uuid()
      */

        cDocID:=uuid() // услуга как наполение группы

        QOUT('     <ITEM'+;
        ' GUID="'+cDocID+'"'+;
        ' Name="'+XmlCharTran(alltrim(PlanSale->nplslta))+'"'+;
        ' Code="" A04="20" A05=""'+;
        ' A06="'+cDocID+'"'+;
        ' A08="0"'+;
        ' A013="'+cDocID+'"'+;
        ' A014="0" A015="0"'+; // 1 - услуга 0 - товар
        ' A035="'+XmlCharTran(alltrim(PlanSale->nplslta))+'"'+;
        ' A038="0"'+;
        ' A039="'+cDocID+'"'+;
        ' A042="" A043=""  A044="" A048=""'+;
        ' A050="'+cDocID+'"'+;
        ' A037="0" A011="0" A041="0" A052="2"'+; // 2 нет ост-ков на борту
        ' A020="0" A021="0" A022="0" A023="0" A030="0" A031="0" A032="0"'+;
        ' A033="0" A034="0"'+;
        ' GrpID0="'+PlanSale->gPlslTa+'"'+;
        ' GrpID1="'+PlanSale->gPlslTa+'"'+;
        '>')
         /*
         QOUT('       <TABLES>')
         QOUT('         <TABLE GUID="AF0A6972-4BCA-4652-A3CF-8EBC1ED1EE0D" Comment="Табличная часть Остатки">')
         QOUT('           <ITEM'+;
                           ' GUID="'+uuid()+'"'+;
                           ' CtlgId="'+cDocID+'"'+;
                           ' A06="1" A01="0" A02="0"/>')
         QOUT('         </TABLE>')
         QOUT('       </TABLES>')
         */
       QOUT('     </ITEM>')

      sele PlanSale
      DBSkip()
    EndDo
  qout('    </ELEMENTS>')
  QOUT('  </CATALOG>')


    sele PlanSale
    DBGoTop()
    cDocID := PlanSale->gPlsl // GUID - Плана, для Состава_Плана

    QOUT('  <CATALOG GUID="41598C02-F788-48A7-A039-645EF74BD57F" Comment="Документ.Планы продаж" KILLALL="1">')
    QOUT('    <ELEMENTS>')
          QOUT('      <ITEM'+;
            ;// GUID  GUID
                      ' GUID="'+cDocID+'"'+;
            ;// IsDeleted Число - 1.0
                      ' Name="'+LEFT(XmlCharTran(PlanSale->nPlSl), 50)+'"'+;
            ;// A02 Тип
                      ' A02="'+aPlSl_Ctg[1,1]+'"'+;
            ;// A03 УчетПоКоличеству
                      ' A03="1"'+;
            ;// A04 УчетПоСумме
                      ' A04="0"'+;
            ;// A05 НачалоПериода
                      ' A05="'+cdbDTLM(dBeg,'00:00:00')+'"'+;
            ;// A06 ОкончаниеПериода
                      ' A06="'+cdbDTLM(dEnd,'23:59:59')+'"'+;
            ;// A07 Актуальность  0 - расчет по тек. данны, 1 - не считать
                      ' A07="1"'+;
            ;// A08 - контрагет ГУИД за которым креплен план
                 '/>')
    QOUT('    </ELEMENTS>')
    QOUT('  </CATALOG>')

    //Q
    QOUT('  <CATALOG GUID="6B5D547E-B683-4990-89CD-61D0F8497A9C" Comment="Документ.Состав плана продаж" KILLALL="1">')
    QOUT('    <ELEMENTS>')
    DBGoTop()
    Do While !eof()
      nPerCent:= PlanSale->Fakt / PlanSale->Plan * 100
        QOUT('      <ITEM'+;
          ;// GUID
              ' GUID="'+uuid()+'"'+;
          ;// IsDeleted
          ;// A01 ПланПродаж
              ' A01="'+cDocID+'"'+;  // GUID - Плана
          ;// A02 ИдНоменклатуры
              ' A02="'+PlanSale->gPlslTa +'"'+;  // GUID -  категории
          ;// A03 ПланКоличество
              ' A03="'+LTRIM(STR(PlanSale->Plan,5,0))+'"'+;
          ;// A04 ПланСумма
          ;// A05 ФактКоличество
              ' A05="'+LTRIM(STR(PlanSale->Fakt,4,0))+'"'+;
          ;// A06 ФактСумма
          ;// A07 ПроцентВыполнения
              ' A07="'+LTRIM(STR( nPerCent,3,0))+'"'+;
               '/>')
      sele PlanSale
      DBSkip()
    EndDo

    QOUT('    </ELEMENTS>')
    QOUT('  </CATALOG>')

    QOUT("</CATALOGS>")

  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  11-20-15 * 09:47:11pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION cdbDoc_Debt(nRun,ktar)
  LOCAL i1, i2, ktasr
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbDoc_Debt.txt
  IF !EMPTY(nRun)
  QQOUT('  <DOCUMENT GUID="A93AADFA-2A35-40FE-B88A-3768825CDD31" Comment="Документ.Долг" KILLALL="1">')
  QOUT('    <ELEMENTS>')

    SELE skdoc
    SET FILTER TO !DELETED()

    locate for ktan=ktar
    ktasr:=ktas

    DBGOTOP()

    SELE tmp_kpl
    //SET RELA TO STR(kpl,7) INTO skdoc
    DBGOTOP()
    WHILE (!EOF())
      IF STR(tmp_kpl->Kpl)$"     20034"
        SELECT tmp_kpl
        DBSKIP()
        LOOP
      ENDIF
      IF !skdoc->(DBSEEK(STR(tmp_kpl->kpl,7)))
        SELECT tmp_kpl
        DBSKIP()
        LOOP
      ENDIF
      i1:=0
      i2:=0

      SELE skdoc
      DO WHILE skdoc->Kpl = tmp_kpl->Kpl

        IF iif(.F.,ktasr=ktas,.T.) //выводим только д-ки, те которые в маршуте и принадлежат Суперу ТоргАгента
          dDtOpl:=IIF(EMPTY(DtOpl), DOP+14,DtOpl)
          QOUT('      <ITEM'+;
                      ;//GUID  GUID
                    ' GUID="';
                      +PADR(DTOS(DOP) ,8,'F')+'-';// NNNNNNNN- дата
                      +PADR(NTOC(Rand(0)*10^7,16),4,'F')+'-'; // NNNN-
                      +PADR(NTRIM(Nap),4,'F')+'-'; // NNNN- направление
                      +PADR(NTRIM(Sk) ,4,'F')+'-'; // NNNN- склад
                      +PADR(NTRIM(ABS(TTN)) ,12,'F');//NNNNNNNNNNNN // номер ТТН
                      ;// +uuid();
                      +'"'+;
                      ;//DT  ДатаВремя
                    ' dt="'+cdbDTLM(DOP,'00:00:00')+'"'+;
                      ;//IsDeleted Число - 1.0
                      ;//IsPost  Число - 1.0
                    ' IsPost="1"'+;
                      ;//DocNumberPrefix ПрефиксДокумента  Строка
                      ;//DocNumber НомерДокумента  Число
                    ' DocNumber="'+NTRIM(NAP)+'_'+NTRIM(SK)+'_'+NTRIM(TTN)+'"'+;
                      ;//A01      Категория  GUID
                      ;//  IIF(ktan=ktar,' A01="'+GUID_KPK("С0",'255000000')+'"','')+;
                      ;//A02      Организация  GUID
                    ' A02="'+GUID_KPK("C",ALLTRIM(STR(gnKkl_c)))+'"'+;
                      ;//A03      Контрагент GUID
                    ' A03="'+GUID_KPK("C",ALLTRIM(STR(Kpl)))+'"'+;
                      ;//A04      ТорговаяТочка  GUID
                      IIF(KGp=0,;
                      '',;
                      ' A04="'+GUID_KPK("C",ALLTRIM(STR(KGp)),ALLTRIM(STR(Kpl)))+'"';
                    )+;
                      ;//A05      Договор  GUID
                    ' A05=""'+;
                      ;//A06      ДатаОплаты ДатаВремя
                    ' A06="'+cdbDTLM(dDtOpl,'00:00:00')+'"'+;
                      ;//A07      Сумма  Число - *.4
                    ' A07="'+LTRIM(STR(SDP,15,2))+'"'+;
                      ;//A08      Комментарий  Строка - 255
                    ' A08="';
                      +LEFT('';
                      +' создан ТА:'+NTRIM(KtaN)+' '+ALLTRIM(NKtaN);
                      +' напр.'+LTRIM(STR(Nap))+' '+alltrim(NNap);
                      ,255);
                      +'"'+;
                      ;//A011     ДокументОснование  Строка - 36
                    ' A011="C9A2F172-BC81-11E2-8971-B8AC6F8EA8C5"'+;
                      ;//А012     ЕстьПодчиненные  Число - 1.0
                      ;//A014     Выделять Число - 1.0
                    ' A014="'+IIF(dDtOpl>DATE(),'1','0')+'"'+;
                      ;//A015     Представление  Строка - 255
                    ' A015="'+'Реализация товаров и услуг ';
                    +'от '+DTOC(DOP,"DD.MM.YYYY")+' ';
                    +'N'; // '&#8470;';//'№'
                    +ALLTRIM(STR(TTN));
                    +' '+'Сумма:';
                    +LTRIM(STR(SDV,15,2));
                    +'"'+;
               '/>')
          i1:=0//1
          i2:=0//1
        ENDIF
        DBSKIP()
      ENDDO

      SELECT tmp_kpl
      DBSKIP()
    ENDDO

    QOUT('    </ELEMENTS>')
    QOUT('  </DOCUMENT>')

    SELE skdoc
    SET FILTER TO
    SELE tmp_kpl
    SET RELA TO

  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  11-21-15 * 04:49:47pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION cdbDoc_Cash(nRun,aKop)
  LOCAL i1, i2
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbDoc_Cash.txt
  IF !EMPTY(nRun)
  QQOUT('  <DOCUMENT GUID="749BE2E0-9B00-4D7B-9D4D-88CA53327511" Comment="Документ.Касса поступление" KILLALL="1">')
  QOUT('    <ELEMENTS>')
    SELE bdoc
    SET FILTER TO !DELETED()
    DBGOTOP()

    SELE tmp_kpl
    //SET RELA TO STR(kpl,7) INTO skdoc
    DBGOTOP()
    WHILE (!EOF())
      IF STR(tmp_kpl->Kpl)$"     20034"
        SELECT tmp_kpl
        DBSKIP()
        LOOP
      ENDIF
      IF !bdoc->(DBSEEK(STR(tmp_kpl->kpl,7)))
        SELECT tmp_kpl
        DBSKIP()
        LOOP
      ENDIF
      i1:=0
      i2:=0

      SELE bdoc
      DO WHILE bdoc->KKl = tmp_kpl->Kpl
        QOUT('      <ITEM'+;
          ;//GUID  GUID
                    ' GUID="'+uuid()+'"'+; //GUID_KPK("D",ALLTRIM(LTRIM(DTOS(DDK))+PADL(LTRIM(STR(RND)),6,"0")))
          ;//DT  ДатаВремя
                    ' DT="'+cdbDTLM(DDK,'00:00:00')+'"'+;
          ;//IsDeleted Число - 1.0
          ;//IsPost  Число - 1.0
                    ' IsPost="1"'+;
          ;//DocNumberPrefix Префикс Документа Строка
          ;//DocNumber НомерДокумента  Число
          ' DocNumber="'+ALLTRIM(STR(NPLP))+"/"+ALLTRIM(STR(RND))+'"'+;
          ;//A01  Организация  GUID
                    ' A01="'+GUID_KPK("C",ALLTRIM(STR(gnKkl_c)))+'"'+;
          ;//A02  Контрагент GUID
                    ' A02="'+GUID_KPK("C",ALLTRIM(STR(KKl)))+'"'+;
          ;//-A03  ТорговаяТочка  GUID           ;//          ' A03="'+'???'+'"'+;
          ;//-A04  Договор  GUID                    ' A04=""'+;
          ;//-A06  Комментарий  Строка - 255
                    ' A06="'+LEFT(ALLTRIM(STR(BS_D,6,0)+":"+OSN),255)+'"'+;
          ;//A07  Сумма  Число - *.4
                    ' A07="'+LTRIM(STR(BS_S,15,2))+'"'+;
          ;//-A09  ДокументОснование  GUID
          ;//-A011 Категория  GUID
          ;//-A012 Широта Строка - 20
          ;//-A013 Долгота  Строка - 20
          ;//A014 ДатаНачала ДатаВремя
                    ' A014="'+cdbDTLM(DATE(),'00:00:00')+'"'+;
          ;//A015 ДатаОкончания  ДатаВремя
                    ' A015="'+cdbDTLM(DATE(),'00:00:00')+'"'+;
          ;//A016 ВидОплаты  GUID
                    ' A016="'+aKop[1,4]+'"'+;
          ;//A017 ДатаТочкиТрека ДатаВремя
          ;//А018 Распечатан Число - 1.0
                    ' A18="1"'+;
               '/>')
        i1:=0//1
        i2:=0//1
        DBSKIP()
      ENDDO

      SELECT tmp_kpl
      DBSKIP()
    ENDDO

    QOUT('    </ELEMENTS>')
    QOUT('  </DOCUMENT>')

    SELE bdoc
    SET FILTER TO
    SELE tmp_kpl
    SET RELA TO

  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-25-15 * 01:28:13pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION CdbDoc_Confirm()
  LOCAL nDocState
  LOCAL cDocState, aDocState
  cDocState:="вфсоп"
  aDocState:={}

  SELE Confirm

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbDoc_Confirm.txt

  QQOUT('  <DOCUMENT GUID="E01E1F5C-D6E4-46E8-B923-3758B0D79BDE" Comment="Подтверждения документов Заказ покупателя">')
   QOUT('    <CONFIRMATIONS>')
  DBGOTOP()
  WHILE (!EOF())

    IF LEN(ALLTRIM(DocGUID)) = 36

      nDocState:=1+8    // 8-запрет изменения (записан)
      DO CASE
      CASE EMPTY(dFp)
        cDocState:="в----"
      CASE EMPTY(dSp)
        cDocState:="вф---"
      CASE EMPTY(dTOt) .AND. PRZ=0
        cDocState:="вфс--"
      CASE !EMPTY(dTOt) .AND. PRZ=0
        cDocState:="вфсо-"
        nDocState:=1+8+64 //64-красным   (записан + красным)
      CASE PRZ=1
        cDocState:="вфсоп"
      ENDCASE
        /*
        cDocState:= 3453466 В. . . . . "
        cDocState:="В.Ф. . . .3434566"
        cDocState:="В.Ф.C. . ."
        cDocState:="В.Ф.C.O. ."
        cDocState:="В.Ф.C.O.П."
        */
        QOUT('      <ITEM'+;
            ;//GUID  GUID
                  ' GUID="'+DocGUID+'"'+;
                     '/>')
        // замена номера ТТН
        AADD(aDocState,{DocGUID,;
        CHARREPL('-',UPPER(cDocState),'#'),;
        ALLTRIM(STR(TTN))})

        // подверждения фото 02-18-17 02:48am
        sele phtdoc
        ordsetfocus('t1')
        If DBSeek(Confirm->DocGUID)
          Do While DocGUID = Confirm->DocGUID
            QOUT('      <ITEM'+;
                ;//GUID  GUID
                      ' GUID="'+GUID+'"'+;
                         '/>')
            QOUT('      <ITEM'+;
                ;//GUID  GUID
                      ' GUID="'+PhotGUID+'"'+;
                         '/>')
            sele phtdoc
            DBSkip()
          EndDo
        EndIf

    ENDIF
    SELE Confirm
    DBSKIP()
  ENDDO
  QOUT('  </CONFIRMATIONS>')
  QOUT('  <ELEMENTS>')
  FOR i:=1 TO LEN(aDocState)
        QOUT('       <ITEM'+;
          ' GUID="'+aDocState[i,1]+'"'+;
          ' DocNumberPrefix="'+aDocState[i,2]+'"'+;
          ' DocNumber="'+aDocState[i,3]+'"'+;
          '/>')
  NEXT
  QOUT('  </ELEMENTS>')
  QOUT('  </DOCUMENT>')

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  11-24-15 * 02:37:46pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION cdbRoutes(nRun,dDate)
  LOCAL dRouteTime, i, m
  LOCAL cDocId

  dDate:=DATE()

  crtt('tempRtDt','f:kgp c:n(7) f:kpl c:n(7)  f:rtdt c:d(10) f:Comment c:c(64)')
  USE tempRtDt NEW EXCLUSIVE
  IF FILE('tempRtDt.cdx')
    ERASE ('tempRtDt.cdx')
  ENDIF
  INDEX ON rtdt TAG RtDt

  SELE TPoints
  DBGOTOP()
  WHILE (!EOF())
    IF EMPTY(RouteTime)
      DBSKIP()
      LOOP
    ENDIF
    FOR i:=1 TO 7
      IF !EMPTY(SUBSTR(RouteTime,i,1))
        dRouteTime:=LastMonday(dDate)+i-1
        FOR m:=0 TO 0 // 1-на две недели 0-одна
          tempRtDt->(DBAPPEND())
          tempRtDt->Kpl:=TPoints->Kpl
          tempRtDt->Kgp:=TPoints->Kgp
          tempRtDt->rtdt:=dRouteTime+(7*m)
          tempRtDt->Comment:=""
        NEXT
      ENDIF
    NEXT
    DBSKIP()
  ENDDO


  SELE tempRtDt
  DBGOTOP()

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbDoc_Routes.txt

  IF !EMPTY(nRun)
    QQOUT('  <DOCUMENT GUID="43920FA1-745D-4499-84AF-7000672CEEFF" Comment="Документ.Маршут" KILLALL="1">')
    QOUT('    <ELEMENTS>')
    cDocID:=uuid()
    QOUT('       <ITEM'+;
                    ;//GUID  GUID
                  ' GUID="'+cDocID+'"'+;
                    ;//DT  ДатаВремя
                  ' dt="'+cdbDTLM(DATE(),'00:00:00')+'"'+;
                    ;//IsDeleted Число - 1.0
                    ;//IsPost  Число - 1.0
                  ' IsPost="1"'+;
                    ;//DocNumber НомерДокумента  Строка 16
                  ' DocNumber="'+'Док-т маршут недел'+'"'+;
                 '>')
    QOUT('         <TABLES>')
    //GUID табличной части "Точки маршрута" - ED832712-A167-4B9E-87F1-5127E6F70814
    QOUT('           <TABLE GUID="ED832712-A167-4B9E-87F1-5127E6F70814">')

    DBGOTOP()
    DO WHILE !EOF()
      QOUT('             <ITEM'+;
                      ;//GUID  GUID
                    ' GUID="'+UuID()+'"'+;
                      ;//DocID GUID
                    ' DocID="'+cDocID+'"'+;
                      ;//A01 Контрагент  GUID
                    ' A01="'+GUID_KPK("C",ALLTRIM(STR(Kpl)))+'"'+;
                      ;//A02 ТорговаяТочка GUID
                    ' A02="'+GUID_KPK("C",ALLTRIM(STR(KGp)),ALLTRIM(STR(Kpl)))+'"'+;
                      ;//A03 Время Строка - 16
                    ' A03="'+DTOC(rtdt)+'"'+;
                      ;//A04 Напоминание Строка - 255
                    ' A04="'+LEFT(ALLTRIM(""), 255)+'"'+;
                      ;//A05 Порядок Число
                        '/>')

      DBSKIP()
    ENDDO
    QOUT('           </TABLE>')
    QOUT('         </TABLES>')
    QOUT('       </ITEM>')
    QOUT('    </ELEMENTS>')
    QOUT('  </DOCUMENT>')

  ENDIF
  CLOSE tempRtDt


  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  11-24-15 * 06:18:06pm
 НАЗНАЧЕНИЕ.........3.1.  Организации
 Справочник "Организации" предназначен для хранения информации об организациях,
  от имени которых оформляются документы

 Таблица 3 4 Список атрибутов справочника "Контрагенты"

 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION cdbClients(nRun,aKop)
  LOCAL cCodeList, aClientsA08, aClient_KOP, cGuIdClient, cGuId_Base_KOP
  LOCAL cGuIdGrClient
  LOCAL aGuId_price:=PriceType2Kop('guid_price')


  aClientsA08:={}
  aClient_KOP:={}

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbClients.txt

  IF !EMPTY(nRun)

    QQOUT('<CATALOG GUID="9450980F-FB59-47E3-BAE2-AA3C58441B1A" KILLALL="1" Comment="Контрагенты" >')
    QOUT('          <GROUPS>')
    QOUT('            <GROUP GUID="1E18C8DB-08F6-47DA-874B-100D6E109AB8" Comment="Группы">')
    QOUT('               <ELEMENTS>')
          cGuIdGrClient:="CBCF494A-55BC-11D9-848A-00112F43529A"
    QOUT('                  <ITEM GUID="'+cGuIdGrClient+'" IsDeleted="0" Name="ПОКУПАТЕЛИ" ParId=""/>')
    QOUT('               </ELEMENTS>')
    QOUT('            </GROUP>')
    QOUT('         </GROUPS>')
    QOUT('         <ELEMENTS Comment="Элементы справочника.Контрагенты">')

    SELE tmp_kpl
    SET RELA TO STR(Kpl,7) INTO deb
    DBGOTOP()
    WHILE (!EOF())
      cGuIdClient:=GUID_KPK("C",ALLTRIM(STR(Kpl)))
      cCodeList:=""
      IF !EMPTY(CodeList)
        FOR i:=1 TO LEN(aKop) //-1
          //проверим вхождение в разрешенных КОП в строку
          //проверим дубляж
          IF PADL(LTRIM(STR(aKop[i,1],3,0)),3,"0")$CodeList .AND. ;
            !(PADL(LTRIM(STR(aKop[i,3],3,0)),2,"0")$cCodeList)
            IF EMPTY(cCodeList)
              cCodeList:=PADL(LTRIM(STR(aKop[i,3],3,0)),2,"0")
              cGuId_Base_KOP:=aKop[i,4]
            ELSE
              cCodeList+=","+PADL(LTRIM(STR(aKop[i,3],3,0)),2,"0")
            ENDIF
            AADD(aClient_KOP,{cGuIdClient,aKop[i,4]})
          ENDIF
        NEXT
      ENDIF
      //outlog(__FILE__,__LINE__,cCodeList)
      /*
      3.10 Договора
      */
      // AADD(aClientsA08,{uuid(),cGuIdClient,NDog,dtDogB,dogPl})
      AADD(aClientsA08,{;
      GUID_KPK("D0",ALLTRIM(STR(Kpl))), cGuIdClient,NDog,dtDogB,dogPl})
      /*
      3.32 Виды оплат
      3.33 Виды оплат организаций


      */
      QOUT('  <ITEM'+;
            ;//GUID  GUID
                    ' GUID="'+cGuIdClient+'"'+;
            ;//IsDeleted Число - 1.0
            ;//Name Наименование  Строка - 100
                    ' Name="'+LEFT(XmlCharTran(Npl), 100)+'"'+;
            ;//-A05 Скидка  Число - *.2
            ;//-A06 Статус  GUID
                    ' A06="'+ClientStatus()+'"'+;
            ;//-A08 ОсновнойДоговор GUID
                    ' A08="'+ATAIL(aClientsA08)[1]+'"'+;
            ;//-A09 ТипЦены GUID
                    ' A09="'+aGuId_price[1]+'"'+;
            ;//A010 ЗапретПродаж Число - 1.0
            ;//A011 Категория  GUID
            ;//-A012 НаименованиеПолное Строка - 255
                    ' A012="'+LEFT(XmlCharTran(Apl), 255)+'"'+;
            ;//-A013 ИННКПП Строка - 22
                    ' A013="'+"!"+ALLTRIM(STR(OKPO, 22, 0))+'"'+;
            ;//-A014 РасчетныйСчет  Строка - 255
            ;//-A015 Долг Число - *.4
                    ' A015="'+ALLTRIM(STR(deb->DZ, 15, 2))+'"'+;
            ;//-A016 Долгота  Строка - 20
            ;//-A017 Широта Строка - 20
            ;//-A018 ИспользоватьПерсональныеЦены Число - 1.0
                    ' A018="'+'1'+'"'+;
            ;//-A019 ВидОплаты  GUID
                    ' A019="'+cGuId_Base_KOP+'"'+;
            ;//-A020 Организация  GUID
            ;//-A021 АлгоритмАвтозаполнения Число - 1.0
            ;//-А022 КодПоОКПО  Строка - 10
                    ' A022="'+"$"+ALLTRIM(STR(OKPO, 10, 0))+'"'+;
            ;//-А023 Комментарий  Строка - 255
                    ' A023="';
                    +'Договор №'+LTRIM(STR(NDog))+' от '+DTOC(dtDogB,'dd.mm.yy');
                    +' срок оконч. '+DTOC(dogPl,'dd.mm.yy'); // +LEFT(ALLTRIM(">7дн:"+LTRIM(STR(deb->PDZ,10,2))+" >14дн:"+LTRIM(STR(deb->PDZ1,10,2))+" >21дн:"+LTRIM(STR(deb->PDZ3,10,2))), 255);
                    +'"'+;
            ;//-A024 ЗагруженыКоординаты  Число - 1.0
            ;//-GrpID0 Группа GUID
                    ' GrpID0="'+cGuIdGrClient+'"'+;
                        '/>')

      DBSKIP()
    ENDDO
    QOUT('        </ELEMENTS>')
    QOUT('      </CATALOG>')
    SELE tmp_kpl
    SET RELA TO

    //Comment="Справочник.СтатусыКонтрагентов"
    QOUT('  <CATALOG GUID="74046D94-B25D-4F3A-B553-27B7FDD3C60C" KILLALL="0" Comment="Справочник.СтатусыКонтрагентов">')
    QOUT('    <ELEMENTS>')
    QOUT('      <ITEM GUID="5BB4A902-C29F-11DC-96A3-0018F30B88B5" Name="Договор просроченный" A02="Договор просроченный" A03="250,130,250"/>')
    QOUT('      <ITEM GUID="5BB4A903-C29F-11DC-96A3-0018F30B88B5" Name="Договор заканчивается" A02="Договор заканчивается чз 28 дней" A03="230,225,200"/>') //серый
    QOUT('      <ITEM GUID="5BB4A904-C29F-11DC-96A3-0018F30B88B5" Name="Новый клиент" A02="Это новый клиент! Окажите ему особое внимание!" A03="0,231,0"/>')
    QOUT('      <ITEM GUID="5BB4A905-C29F-11DC-96A3-0018F30B88B5" Name="Большая задолженность" A02="У данного клиента большая задолженность!" A03="255,188,0"/>')
    QOUT('      <ITEM GUID="5BB4A906-C29F-11DC-96A3-0018F30B88B5" Name="Лояльность" A02="Лояльность клиента" A03="0,108,155"/>')
    QOUT('      <ITEM GUID="50D75AAF-45D8-4542-A3AA-09B13A5B909D" Name="Запрет продаж" A02="Для данного клиента запрещено оформление продаж!" A03="255,0,0"/>')
    QOUT('      <ITEM GUID="9B2C0187-0922-11E0-8764-6CF04917B338" Name="Большой опт" A02="" A03="128,128,0"/>')
    QOUT('      <ITEM GUID="E88D5533-7217-11DF-9314-8000600FE800" Name="Важный клиент" A02="Очень важный клиент. Обратите внимание!" A03="12,115,26"/>')
    QOUT('      <ITEM GUID="E88D5534-7217-11DF-9314-8000600FE800" Name="Клиент конкурентов" A02="Клиент работает с конкурентами" A03="98,79,172"/>')
    QOUT('      <ITEM GUID="D54381E3-D965-11DC-B30B-0018F30B88B5" Name="Просроченная оплата" A02="Этот клиент просрочил оплату!" A03="240,17,211"/>')
    QOUT('    </ELEMENTS>')
    QOUT('  </CATALOG>')

    //Comment="Справочник.КатегорииКонтрагентов"
    QOUT('  <CATALOG GUID="C75131A9-F98E-4443-B790-3ADA6137440B" KILLALL="0" Comment="Справочник.КатегорииКонтрагентов">')
    QOUT('    <ELEMENTS>')
    QOUT('      <ITEM GUID="EA1ABCD6-0F34-11DF-A13A-001921430A4C" Name="Категория VIP" A01=""/>')
    QOUT('      <ITEM GUID="12F17A17-8BFA-11DE-A11F-001921430A4C" Name="Категория В" A01=""/>')
    QOUT('      <ITEM GUID="12F17A16-8BFA-11DE-A11F-001921430A4C" Name="Категория А" A01=""/>')
    QOUT('      <ITEM GUID="51665E76-0F36-11DF-A13A-001921430A4C" Name="Категория &quot;Потенциальные&quot;" A01=""/>')
    QOUT('      <ITEM GUID="12F17A18-8BFA-11DE-A11F-001921430A4C" Name="Категория С" A01=""/>')
    QOUT('      <ITEM GUID="AF5F45C9-9007-11DF-8D14-6CF04917B338" Name="Новые клиенты" A01=""/>')
    QOUT('    </ELEMENTS>')
    QOUT('  </CATALOG>')

  ENDIF


  SET PRINT TO
  SET PRINT OFF


  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbDogovor.txt

  IF !EMPTY(LEN(aClientsA08))

    QQOUT('  <CATALOG GUID="735A9CE5-DCC1-4D1A-8F8D-643A50A6BEFC" KILLALL="1"  Comment="Справочник.ДоговорыКонтрагентов">')
    QOUT('    <ELEMENTS>')
          //3.10. Договоры
          //Справочник "Договоры" предназначен для хранения информации
          //о договорах, заключенных с контрагентами
          //AADD(aClientsA08,{uuid(),cGuIdClient,NDog,dtDogB,dogPl})

          FOR i:=1 TO LEN(aClientsA08)
            QOUT('      <ITEM'+;
                        ;//GUID  GUID
                      ' GUID="'+aClientsA08[i,1]+'"'+;
            ;//IsDeleted Число - 1.0
            ;//Name        Наименование  Строка - 50
                      ' Name="'+'Договор поставки №'+LTRIM(STR(aClientsA08[i,3]))+'"'+;
            ;//A02 Контрагент  GUID
                      ' A02="'+aClientsA08[i,2]+'"'+;
            ;//-A03 ДатаЗаключения ДатаВремя
                      ' A03="'+cdbDTLM(aClientsA08[i,4],'00:00:00')+'"'+;
            ;//-A04  СрокДействия  ДатаВремя
                      ' A04="'+cdbDTLM(aClientsA08[i,5],'00:00:00')+'"'+;
            ;//A05 Организация GUID
                      ' A05="'+GUID_KPK("C",ALLTRIM(STR(gnKkl_c)))+'"'+;
            ;//-A06 ТипЦены  GUID
            ;//A07 ИспользоватьНДС Число - 1.0
            ;//-A08 Скидка Число - *.2
            ;//-A09 ВидОплаты  GUID
            ;//-A010 ТорговаяТочка  GUID
                 '/>')
          NEXT
    QOUT('    </ELEMENTS>')
    QOUT('  </CATALOG>')
    SET PRINT TO
    SET PRINT OFF
  ENDIF


  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbCodeList.txt
  IF !EMPTY(LEN(aClient_KOP))
    QQOUT('<CATALOG GUID="04977681-EBAF-4589-B6E7-93E883333DB7" KILLALL="1"  Comment="Справочник.ВидыОплат">')
    QOUT('   <ELEMENTS>')
          //FOR i:=LEN(aKop) TO 1 STEP -1
          FOR i:=1 TO LEN(aKop) STEP 1
            QOUT('      <ITEM'+;
              ;//GUID  GUID
                      ' GUID="'+aKop[i,4]+'"'+;
              ;//IsDeleted Число - 1.0
              ;//Name     Наименование Строка - 50
                      ' Name="'+aKop[i,2]+'"'+;
              ;//A01      ВидыДокументов Строка - 255
                      ' A01="'+'Заказ,Реализация,ПКО,РКО,ВозвратТоваров,Поступление'+'"'+;
                 '/>')
          NEXT
    QOUT('   </ELEMENTS>')
    QOUT('  </CATALOG>')

    QOUT('  <CATALOG GUID="1362EC92-F3F9-43AF-94CD-6937CEBA0AEE" KILLALL="1" Comment="Справочник.ВидыОплатОрганизаций">')
    QOUT('   <ELEMENTS>')
          FOR i:=LEN(aClient_KOP) TO 1 STEP -1
            QOUT('      <ITEM'+;
            ;//GUID  GUID
            ' GUID="'+uuid()+'"'+;
            ;//IsDeleted Число - 1.0
            ;//A01 Организация GUID
                      ' A01="'+aClient_KOP[i,1]+'"'+;
            ;//A02 ВидОплаты GUID
                      ' A02="'+aClient_KOP[i,2]+'"'+;
                 '/>')
          NEXT
    QOUT('   </ELEMENTS>')
    QOUT('  </CATALOG>')


    SET PRINT TO
    SET PRINT OFF
  ENDIF

  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  11-26-15 * 06:20:04pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........   //"Справочник.СтатусыКонтрагентов"
 */
STATIC FUNCTION ClientStatus()
  LOCAL cGUID
  DO CASE
  CASE dogPl < DATE() // просрочен
    //, 2
    cGUID:="5BB4A902-C29F-11DC-96A3-0018F30B88B5"
  CASE dogPl <= DATE()+14+14
    //, 3
    cGUID:="5BB4A903-C29F-11DC-96A3-0018F30B88B5"
  CASE dtDogB >= DATE() .AND. dtDogB <= DATE()+14
    //, 4,
    cGUID:="5BB4A904-C29F-11DC-96A3-0018F30B88B5"
  OTHERWISE
    // прочие статусы
    cGUID:=""
  ENDCASE

  RETURN (cGUID)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-03-15 * 10:11:11am
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION cdbTPoints(nRun)
  Local cNGp, nDD, nSDD
  SELE tmp_ktt
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbTPoints.txt

  IF !EMPTY(nRun)
    QQOUT('<CATALOG GUID="D3DBB02E-681E-4FC2-AD0E-8EF1234E9F48" KILLALL="1" Comment="Справочник.ТорговыеТочки">')
    QOUT('   <ELEMENTS>')
    DBGOTOP()
    WHILE (!EOF())
      QOUT('      <ITEM'+;
        ;//GUID  GUID
           ' GUID="'+GUID_KPK("C",ALLTRIM(STR(KGp)),ALLTRIM(STR(Kpl)))+'"'+;
        ;//IsDeleted Число - 1.0Name
        ;//Наименование  Строка - 150
            ' Name="'+LEFT(XmlCharTran(iif(empty(gpslon),'~','')+ NGp), 150)+'"'+;
        ;//A02Контрагент GUID
        IIF(;
        EMPTY(RouteTime),;
        '',;
        ' A02="'+GUID_KPK("C",ALLTRIM(STR(Kpl)))+'"';
      )+;
        ;//A05Категория  GUID
        ;//A06Тип  GUID
            ' A06="'+GUID_KPK("CA1",ALLTRIM(STR(kgpcat)))+'"'+;
        ;//A07Комментарий  Строка - 250
            ' A07="'+LEFT(XmlCharTran(AGp)+" тел."+XmlCharTran(TelGp), 250)+'"'+;
        ;//-A08ТипЦены  GUID
        ;//-A09Долгота  Строка - 20
            ' A09="'+ alltrim(gpslon)+'"'+;
        ;//-A010Широта  Строка - 20
            ' A10="'+ alltrim(gpslat)+'"'+;
        ;//-A011ИспользоватьПерсональныеЦены  Число - 1.0
             ' A011="'+'1'+'"'+;
        ;//-A012Скидка  Число - *.2
        ;//-A013АлгоритмАвтозаполнения  Число - 1.0
               '/>')
     /*
      qout(                               ;
          ;//Addr
            LEFT(ALLTRIM(AGp), 64)+_T+ ;
          ;//=Tel
            LEFT(ALLTRIM(TelGp), 50)+_T+ ;
          ;//=Contact
            ;//LEFT(ALLTRIM("Контактные лица"), 128)+_T+        ;
            LEFT(ALLTRIM(DTOC(dnl,"DD.MM.YY")+"-"+DTOC(dol,"DD.MM.YYYY")+" "+alltrim(serlic)+ltrim(str(numlic))), 128)+_T+        ;
        )*/
      DBSKIP()
    ENDDO

    QOUT('  </ELEMENTS>')
    QOUT(' </CATALOG>')

    QOUT('  <CATALOG GUID="EDB6B6C0-922F-42D2-8868-CBEB347D8C74" KILLALL="0" Comment="Справочник.ТипыТорговыхТочек">')
    QOUT('    <ELEMENTS>')
      SELE kgpcat
      DBGOTOP()
      DO WHILE !EOF()
        QOUT('      <ITEM'+;
          ;//GUID  GUID
             ' GUID="'+GUID_KPK("CA1",ALLTRIM(STR(kgpcat)))+'"'+;
          ;//Наименование  Строка -
              ' Name="'+LEFT(XmlCharTran(ALLTRIM(nkgpcat)), 50)+'"'+;
               '/>')
        DBSKIP()
      ENDDO
    QOUT('    </ELEMENTS>')
    QOUT('  </CATALOG>')
  ENDIF




  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-03-15 * 04:12:41pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION cdbPrice(nRun,aPrice)
  LOCAL MKeepr,i
  LOCAL nGUID_Mkeep, nKg, nGUID_Kg
  LOCAL aDicEi, cGuId_MNTOVT

  aDicEi:={}

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbPrice.txt

  IF !EMPTY(nRun)
    QQOUT('     <CATALOG GUID="D6D52ADA-0F38-4112-AF3C-2F1E425A43D1" KILLALL="1" Comment="Справочник.Номенклатура">')

    QOUT('       <GROUPS>')

    QOUT('         <GROUP GUID="8E502A85-8DD4-41CF-A7A4-17AB50872D36" KILLALL="1" Comment="Элементы группировки по иерархии">')
    QOUT('           <ELEMENTS>')
    SELE price
    //  ORDSETFOCUS("Nat")
    ORDSETFOCUS("mnkeep")
    DBGOTOP()
    DO WHILE !EOF()
      If !(gnEnt = 21)
        IF MNTOV < 10^6
          DBSKIP()
          LOOP
        ENDIF
      EndIf

      //вывод маркадержателя
      MKeepr:=MKeep
      nGUID_Mkeep:=111111+mkeep
      QOUT('             <ITEM'+;
          ' GUID="'+GUID_KPK("A", LTRIM(STR(nGUID_Mkeep)))+'"'+;
          ' Name="'+XmlCharTran(nmkeep)+'"'+;
          ' ParId="'+''+'"'+;
      '/>')

      DO WHILE MKeepr = MKeep
        kg_r:=INT(MNTOV/10^4)
        ng_r:=getfield('t1',"kg_r","cgrp","ngr")//название группы

        //вывод маркадержателя + группа      0.89  -> 89

        nGUID_Kg:=nGUID_MKeep + VAL(SUBSTR(LTRIM(STR(RAND(kg_r),18,15)),3,6))
        //222222+kg_r //+ROUND(RAND(kg_r)*100,0)
                //outlog(__FILE__,__LINE__,nGUID_MKeep,kg_r, nGUID_Kg,VAL(SUBSTR(LTRIM(STR(RAND(nGUID_Kg),18,15)),3,6)))
        //nGUID_Kg:=VAL(SUBSTR(LTRIM(STR(RAND(nGUID_Kg),18,15)),3,6))

        QOUT('             <ITEM'+;
            ' GUID="'+GUID_KPK("A", LTRIM(STR(nGUID_Kg)))+'"'+;
            ' Name="'+XmlCharTran(ng_r)+'"'+;
            ' ParId="'+GUID_KPK("A", LTRIM(STR(nGUID_Mkeep)))+'"'+;
        '/>')

        DO WHILE kg_r = INT(MNTOV/10^4) .AND. MKeepr = MKeep
          DBSKIP()
        ENDDO
      ENDDO

    ENDDO
  QOUT('           </ELEMENTS>')
  QOUT('         </GROUP>')

  QOUT('         <GROUP GUID="E42DA5B9-E29B-43E1-B7E3-9B500879D6B7" KILLALL="1" Comment="Элементы группировки по категориям">')
  QOUT('           <ELEMENTS>')
  QOUT('             <ITEM GUID="A8EBEAC9-5818-11D9-A2C3-00055D80A2D1" Name="Продукуты питания" ParId=""/>')
  QOUT('           </ELEMENTS>')
  QOUT('         </GROUP>')

  QOUT('       </GROUPS>')

  QOUT('       <ELEMENTS Comment="Элементы справочника Номенклатура">')
    i:=0
  SELE price
  ORDSETFOCUS("Nat")
  DBGOTOP()
  DO WHILE !EOF()

    If !(gnEnt = 21)
      IF MNTOV < 10^6
        DBSKIP()
        LOOP
      ENDIF
    EndIf

      //вывод маркадержателя
      MKeepr:=MKeep
      nGUID_Mkeep:=111111+mkeep

      kg_r:=INT(MNTOV/10^4)
      ng_r:=getfield('t1',"kg_r","cgrp","ngr")//название группы
      //вывод маркадержателя + группа        0.0000000
        nGUID_Kg:=nGUID_MKeep + VAL(SUBSTR(LTRIM(STR(RAND(kg_r),18,15)),3,6))
      // +222222 + kg_r //+ROUND(RAND(kg_r)*100,0)
      // nGUID_Kg:=VAL(SUBSTR(LTRIM(STR(RAND(nGUID_Kg),18,15)),3,6))

      //Ед изм.
      cGuId_MNTOVT:=GUID_KPK("A",ALLTRIM(STR(MNTOVT)))
      cGuId_Ei2_MNTOV:=GUID_KPK("A",ALLTRIM(STR(MNTOVT)),ALLTRIM(STR(778)))
      cGuId_Ei1_MNTOV:=GUID_KPK("A",ALLTRIM(STR(MNTOVT)),ALLTRIM(STR(796)))
      AADD(aDicEi,{cGuId_Ei2_MNTOV,          "уп",Upak,cGuId_MNTOVT,NIL})
      AADD(aDicEi,{cGuId_Ei1_MNTOV,ALLTRIM(NEi),   1,cGuId_MNTOVT,Ves})

       QOUT('     <ITEM '+;
        ;//GUID  GUID
                ' GUID="'+cGuId_MNTOVT+'"'+;
        ;//-IsDeleted Число - 1.0
        ;//-Code Код  Строка - 20
                ' Code="'+LEFT(ALLTRIM(STR(MNTOVT)),20)+'"'+;
        ;//Name Наименование Строка - 200
                ' Name="'+LEFT(XmlCharTran(Nat), 200)+'"'+;
        ;//A04  СтавкаНДС  Число - 3.2
                ' A04="'+ALLTRIM(STR(20, 12, 2))+'"'+;
        ;//A06  БазоваяЕдиница GUID
                ' A06="'+ATAIL(aDicEi)[1]+'"'+;
        ;//A08 УчетПоХарактеристикам Число - 1.0
        ;//A010 МинимальныйОстаток Число - *.3
        ;//A011 Остаток  Число - *.3
                ' A011="'+ALLTRIM(STR(OsV, 15, 4))+'"'+;
        ;//A013 ЕдиницаХраненияОстатков  GUID
                ' A013="'+ATAIL(aDicEi)[1]+'"'+;
        ;//A014 Весовой  Число - 1.0
                ' A014="'+ALLTRIM(STR(iif("кг" $ lower(NEi),1,0), 1, 0))+'"'+;
        ;//A015 Услуга Число - 1.0
        ;//A020 Цена0  Число - *.4
                ' A020="'+ALLTRIM(STR(FIELDGET(FIELDPOS(aPrice[1])), 12, 2)) +'"'+;
        ;//A021 Цена1  Число - *.4
        ;//A022 Цена2  Число - *.4
        ;//A023 Цена3  Число - *.4
        ;//A024 Цена4  Число - *.4
        ;//A025 Цена5  Число - *.4
        ;//A026 Цена6  Число - *.4
        ;//A027 Цена7  Число - *.4
        ;//A028 Цена8  Число - *.4
        ;//A029 Цена9  Число - *.4
        ;//A030 Остаток0 Число - *.4
        ;//A031 Остаток1 Число - *.4
        ;//A032 Остаток2 Число - *.4
        ;//A033 Остаток3 Число - *.4
        ;//A034 Остаток4 Число - *.4
        ;//А035 НаименованиеПолное Строка - 255
                ' А035="'+LEFT(XmlCharTran(Nat), 255)+'"'+;
        ;//А036 ОграничениеСкидки  Число - *.2
        ;//A037 ЕстьОстатки  Число - 1.0
        ;//A038 Акция  Число - 1.0
        ;//A039 ЕдиницаОтгрузки  GUID
                ' A039="'+ATAIL(aDicEi)[1]+'"'+;
        ;//A040 МинимальнаяЦена  Число - *.4
        ;//A041 ОстатокНаБорту Число - *.4
        ;//A042 ПодробноеОписание  Строка - 255
                ' А042="'+LEFT(ALLTRIM(IIF(Merch=2,'Merch','')), 255)+'"'+;
        ;//A043 ОсновнаяКартинка GUID
        ;//A044 ПорядокВФайлеВыгрузки  Число - *.0
        ;//A045 Алкоголь Число - 1.0
        ;//A046 ДатаРозлива  ДатаВремя
        ;//A048 ЦеноваяГруппа  Строка - 36
        ;//A049 МинимальныйЗаказ Число - *.4
        ;//A050 ЕдиницаЦены  GUID
                ' A050="'+ATAIL(aDicEi)[1]+'"'+;
        ;//A051 ЕдиницаПечати  GUID
        ;//А052 ЕстьОстаткиНаБорту Число - 0 1 2
        ;//А053 ГруппаЕдиницИзмерения  GUID
        ;//GrpID0 Группа GUID
           ' GrpID0="'+GUID_KPK("A", LTRIM(STR(nGUID_Kg)))+'"'+;
        ;//GrpID1 Категория  GUID
           ' GrpID1="'+'A8EBEAC9-5818-11D9-A2C3-00055D80A2D1'+'"'+;
       '>')
            /*
              <TABLES>
                <TABLE GUID="AF0A6972-4BCA-4652-A3CF-8EBC1ED1EE0D" Comment="Табличная часть 'Остатки'">
                  <ITEM GUID="00B4790F-51B7-4BBD-B48C-5494993A67B8" CtlgId="5CA073EB-8661-11DA-9AEA-000D884F5D77" A06="1" A01="0" A02="0"/>
                </TABLE>
              </TABLES>
            */
       QOUT('     </ITEM>')

     DBSKIP()

  ENDDO
  qout('    </ELEMENTS>')

  qout('  </CATALOG>')

  QOUT('  <CATALOG GUID="80452C60-B442-4DA9-A048-42F63270CA14" KILLALL="1" Comment="Справочник.ВидыЕдиницИмерений">')
  QOUT('   <ELEMENTS>')
        FOR i:=1 TO LEN(aDicEi)
      //AADD(aDicEi,{uuid(),ALLTRIM(NEi),   1,cGuId_MNTOVT, Ves})
          QOUT('      <ITEM'+;
          ;//GUID  GUID
            ' GUID="'+aDicEi[i,1]+'"'+;
          ;//IsDeleted Число - 1.0
          ;//Name Наименование Строка - 50
            ' Name="'+LEFT(ALLTRIM(aDicEi[i,2]), 50)+'"'+;
          ;//A02  Коэффициент  Число - *.3
            ' A02="'+ALLTRIM(STR(aDicEi[i,3], 12,0))+'"'+;
          ;//A03  Номенклатура GUID
            ' A03="'+aDicEi[i,4]+'"'+;
          ;//A04  Вес  Число - *.3
            ' A04="'+IIF(aDicEi[i,5]=NIL,'',ALLTRIM(STR(aDicEi[i,5], 12,3)))+'"'+;
          ;//А05  ЭтоГруппа  Число - 1.0
          ;//А06  Родитель GUID
          ;//А07  Классификатор  Строка - 36
               '/>')
        NEXT
  QOUT('   </ELEMENTS>')
  QOUT('  </CATALOG>')

  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  03-22-16 * 04:02:14pm
 НАЗНАЧЕНИЕ......... обновление остатков
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
STATIC FUNCTION CdbGoodsStock(nRun)
  LOCAL cGuId_MNTOVT


  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbPrice.txt

  IF !EMPTY(nRun)
    //!!KILLALL="0"
    QQOUT('     <CATALOG GUID="D6D52ADA-0F38-4112-AF3C-2F1E425A43D1" KILLALL="0" Comment="Справочник.Номенклатура">')

    QOUT('       <ELEMENTS Comment="Элементы справочника Номенклатура">')
      i:=0
    SELE price
    ORDSETFOCUS("Nat")
    DBGOTOP()
    DO WHILE !EOF()

      If !(gnEnt = 21)
        IF MNTOV < 10^6
          DBSKIP()
          LOOP
        ENDIF
      EndIf
      cGuId_MNTOVT:=GUID_KPK("A",ALLTRIM(STR(MNTOVT)))

        QOUT('     <ITEM '+;
        ;//GUID  GUID
                ' GUID="'+cGuId_MNTOVT+'"'+;
        ;//A011 Остаток  Число - *.3
                ' A011="'+ALLTRIM(STR(OsV, 15, 4))+'"'+;
        '>')
        QOUT('     </ITEM>')

      DBSKIP()

  ENDDO
  qout('    </ELEMENTS>')

  qout('  </CATALOG>')

  ENDIF
  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)


/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  12-08-15 * 02:10:56pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION cdbPersonalDiscount(nRun)
  LOCAL cGuId_MNTOVT
  SELE PersonalPrice

  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbPersDisc.txt

  IF !EMPTY(nRun)

    QQOUT('  <CATALOG GUID="12CF8990-D7D7-4CFA-9CCD-AD4CCB5EE9E6" KILLALL="1" Comment="Справочник.Персональные скидки">')
    QOUT('   <ELEMENTS>')

    DBGOTOP()
    DO WHILE !EOF()
      cGuId_MNTOVT:=GUID_KPK("A",ALLTRIM(STR(MNTOVT)))
          QOUT('      <ITEM'+;
            ;//GUID  GUID
          ' GUID="'+uuid()+'"'+;
            ;//IsDeleted Число - 1.0
            ;//A01 ИдОбъекта GUID
                ' A01="'+GUID_KPK("C",ALLTRIM(STR(kpl)))+'"'+;
            ;//A02 ИдТовара  GUID
                ' A02="'+cGuId_MNTOVT+'"'+;
            ;//A03 Скидка  Число - *.4
                ' A03="'+ALLTRIM(STR(Discount, 15, 4))+'"'+;
            ;//A04 ДляВсехОбъектов Число - 1.0
               '/>')

      DBSKIP()
    ENDDO

    QOUT('   </ELEMENTS>')
    QOUT('  </CATALOG>')

  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  11-21-15 * 01:33:22pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION cdbDTLM(dDate,cTime)
  LOCAL cDTLM
  #ifdef __CLIP__
    cDTLM:=DTOC(dDate,"yyyy-mm-dd")+'T'+cTime
  #endif
  RETURN (cDTLM)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  11-21-15 * 02:29:29pm
 НАЗНАЧЕНИЕ.........
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION cdbCategory()
  LOCAL  i
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbCategory.txt
  QQOUT('<CATALOG GUID="F997F837-8721-4896-8FE8-3497C6C38206" KILLALL="0" Comment="Справочник.КатегорияДокументов">')
     QOUT('  <ELEMENTS>')

          aCateg:={;
          {'255000000','красный'},; //GUID_KPK("С0",'255000000')
          NIL;
          }

          FOR i:=1 TO LEN(aCateg)-1
            QOUT('    <ITEM '+;
            ' GUID="'+GUID_KPK("C0",aCateg[i,1])+'"'+;
                ;//наименование
            ' Name="'+aCateg[i,2]+'"'+;
                ;//цвет
            ' A02="'+TRANSFORM(aCateg[i,1],"@R 999,999,999")+'"'+;
                ;//виды д-тов
            ' A03="'+'Заказ,Долг,ПКО,Мерчендайзинг,Посещение,Реализация,Перемещение,Поступление,Задание'+'"'+;  // сторка к-во
            '/>')
          NEXT

    QOUT('  </ELEMENTS>')
    QOUT('</CATALOG>')

    QOUT('<CATALOG GUID="E4623B4E-2F19-47AB-B158-EE0E021D3911" KILLALL="1" Comment="Справочник.ВидыДоставки">')
    QOUT('  <ELEMENTS>')
    QOUT('    <ITEM GUID="84D92255-6C8A-496D-8793-9EC28A04E33F" Code="1" Name="Плановая доставка"/>')
    QOUT('    <ITEM GUID="0473367A-03C0-46B7-A7D3-23E08A314066" Code="2" Name="Самовывоз"/>')
    //QOUT('    <ITEM GUID="CB88674C-7A2A-4792-8A4E-97C55395BE91" Name="Нет доставки"/>')
    //QOUT('    <ITEM GUID="A6E5F825-AA13-4117-9754-B5FA4278FC32" Name="Платная доставка"/>')
    //QOUT('    <ITEM GUID="7F95F9A4-41CD-45A5-B03C-0503EDB8487D" Name="Условно бесплатная доставка"/>')
    QOUT('  </ELEMENTS>')
    QOUT('</CATALOG>')

    QOUT('<CATALOG GUID="564E0ECA-C498-4D28-83D7-4BDEAEC558E2" Comment="Справочник.ВидыКонтактнойИнформации" KILLALL="0">')
    QOUT('  <ELEMENTS>')
    QOUT('    <ITEM GUID="968558FF-8FE0-40D0-84E3-CA694ACBC839" Name="Телефон юр.лица" A02="8FC8F351-14F0-48EB-952A-38BB313B28D5" A03="Контрагенты"/>')
    QOUT('    <ITEM GUID="87D961A6-9E2F-405C-855E-215869755D34" Name="Юридический адрес юр.лица" A02="A4D0F540-64ED-4F3E-B2BB-818DA38F5AB2" A03="Контрагенты"/>')
    QOUT('    <ITEM GUID="4E1FCD79-FFE7-42C0-8944-2FA878EA7246" Name="Адрес электронной почты контрагента для обмена электронными документами" A02="52477200-AF54-405B-9888-14B8BDED0E19" A03="Контрагенты"/>')
    QOUT('    <ITEM GUID="663DE54A-DA59-44A4-9BD0-7509DFA63856" Name="Фактический адрес юр.лица" A02="A4D0F540-64ED-4F3E-B2BB-818DA38F5AB2" A03="Контрагенты"/>')
    QOUT('    <ITEM GUID="17CBA4A2-5872-420A-A3E3-C01B4186F873" Name="Факс контрагента" A02="8FC8F351-14F0-48EB-952A-38BB313B28D5" A03="Контрагенты"/>')
    QOUT('    <ITEM GUID="EB76D981-09C1-4968-B969-67D016F86B83" Name="Адрес доставки" A02="A4D0F540-64ED-4F3E-B2BB-818DA38F5AB2" A03="Контрагенты"/>')
    QOUT('    <ITEM GUID="0B82B2C7-BEDA-448C-9F17-6652E106471A" Name="Мобильный телефон контактного лица контрагента" A02="8FC8F351-14F0-48EB-952A-38BB313B28D5" A03="КонтактныеЛица"/>')
    QOUT('    <ITEM GUID="EEFB301E-97D3-4197-A472-816B951FB280" Name="Адрес электронной почты контактного лица контрагента" A02="52477200-AF54-405B-9888-14B8BDED0E19" A03="КонтактныеЛица"/>')
    QOUT('    <ITEM GUID="CE482D50-E425-4A87-BF1E-21E55285DC32" Name="Рабочий телефон контактного лица контрагента" A02="8FC8F351-14F0-48EB-952A-38BB313B28D5" A03="КонтактныеЛица"/>')
    QOUT('  </ELEMENTS>')
    QOUT('</CATALOG>')

    QOUT('<CATALOG GUID="00F1FFE7-E16E-4FF4-9EF1-B8D0C54BDF59" Comment="Справочник.ТипыЦен">')
    QOUT('  <ELEMENTS>')
      aNn_price:=PriceType2Kop('Nm_price')
      aGuId_price:=PriceType2Kop('guid_price')
      FOR i:=1 TO 1
          QOUT('    <ITEM'+;
          ' GUID="'+aGuId_price[i]+'"'+;
          ' Name="'+aNn_price[i]+'"'+;
          ' Code="'+ALLTRIM(STR(i-1))+'"'+;
          ' A02="1"'+;
          '/>')
      NEXT
    QOUT('  </ELEMENTS>')
    QOUT('</CATALOG>')


    QOUT('<CATALOG GUID="2516FFCE-F46F-4326-BE00-438EF0871D30" Comment="Справочник.Склады">')
    QOUT('  <ELEMENTS>')
    QOUT('    <ITEM GUID="BD72D91F-55BC-11D9-848A-00112F43529A" Name="Главный склад" Code="0"/>')
    /*
    QOUT('    <ITEM GUID="CBCF4956-55BC-11D9-848A-00112F43529A" Name="Склад электротоваров" Code="1"/>
    QOUT('    <ITEM GUID="1DE4815D-FD36-11DB-A40E-00055D80A2D1" Name="Магазин №1" Code="2"/>
    QOUT('    <ITEM GUID="1DE4815E-FD36-11DB-A40E-00055D80A2D1" Name="Магазин №2" Code="3"/>
    QOUT('    <ITEM GUID="1DE4815F-FD36-11DB-A40E-00055D80A2D1" Name="Торговый зал (офис)" Code="4"/>
    QOUT('    <ITEM GUID="49F16893-6380-11E0-A8CB-00004917B338" Name="Продуктовый склад" Code="5"/>')
    QOUT('    <ITEM GUID="D54381E5-D965-11DC-B30B-0018F30B88B5" Name="Автомобиль Баргузин 402" Code="6" A02="CBCF493B-55BC-11D9-848A-00112F43529A"/>')
    */
    QOUT('  </ELEMENTS>')
    QOUT('</CATALOG>')

    QOUT('<CATALOG GUID="1941E3E0-EEEF-43D2-A986-4A97000079B0" Comment="Справочник.Команды" KILLALL="1">')
    QOUT('   <ELEMENTS>')
    QOUT('    <ITEM GUID="B69D62A5-B856-11E5-82AD-BC5FF4E8425E" Name="DeleteAllDocuments" A01="КоличествоДней:7;СписокДокументов:Заказ,Мерчендайзинг,ПКО,РКО;" A02="1" A03="12"/>')
    QOUT('   </ELEMENTS>')
    QOUT('  </CATALOG>')



  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)

/*****************************************************************
 
 FUNCTION:
 АВТОР..ДАТА..........С. Литовка  11-26-15 * 11:32:54am
 НАЗНАЧЕНИЕ.........  3.1.  Организации
  GUID справочника - 0E3CBAEA-5467-45CD-8C86-FB1777DA435B.
 ПАРАМЕТРЫ..........
 ВОЗВР. ЗНАЧЕНИЕ....
 ПРИМЕЧАНИЯ.........
 */
FUNCTION cdbFirms(nRun)
  SET CONSOLE OFF
  SET PRINT ON
  SET PRINT TO cdbFirms.txt
  IF !EMPTY(nRun)
    kln->(netseek("t1","gnKkl_c"))

    QQOUT('<CATALOG GUID="0E3CBAEA-5467-45CD-8C86-FB1777DA435B" KILLALL="1" Comment="Справочник.Организации" >')
    QOUT('  <ELEMENTS>')
    QOUT('     <ITEM '+;
                ;//GUID  GUID
              ' GUID="'+GUID_KPK("C",ALLTRIM(STR(gnKkl_c)))+'"'+;
                ;//IsDeleted Число - 1.0
                ;//Name Наименование Строка - 150
              ' Name="'+LEFT(XmlCharTran(kln->NKLE),150)+'"'+;
                ;//A02  ИспользоватьНДС  Число - 1.0
              ' A02="'+'0'+'"'+;
                ;//-A03  ЮрАдрес  Строка - 250
                ;//-A04  Телефон  Строка - 150
              ' A04="'+ LEFT(ALLTRIM(kln->TLF),250)+'"'+;
                ;//A05  ИНН  Строка - 20
              ' A05="'+'0056123412'+'"'+;
                ;//A06  КПП  Строка - 20
              ' A06="'+'0056123412'+'"'+;
                ;//A07  ОГРН Строка - 20
              ' A07="'+'0056123412'+'"'+;
                ;//-A08  Комментарий  Строка - 250
                ;//-A09  ФактАдрес  Строка - 250
              ' A09="'+LEFT(ALLTRIM(kln->ADR),250)+'"'+;
                ;//-A010 Префикс  Строка - 3
                ;//-A011 БанкНаименование Строка - 255
                ;//-A012 НомерСчета Строка - 20
                ;//-A013 КоррСчет Строка - 20
                ;//-A014 Руководитель Строка - 150
                ;//-A015 Бухгалтер  Строка - 150
                ;//-A016 БИК  Стока - 9
                ;//-A017 НаименованиеПолное Строка - 255
              ' A17="'+LEFT(XmlCharTran(kln->NKL),255)+'"'+;
                ;//A018 ИспользоватьСчетаФактуры Число - 1.0
              ' A018="'+'0'+'"'+;
                ;//-А019 КодПоОКПО  Строка - 10
             '/>')
    QOUT('  </ELEMENTS>')
    QOUT('</CATALOG>')

    QOUT('<CATALOG GUID="CC458719-5078-4DC8-9A0C-FA19E3904F39" Comment="Справочник.Запросы">')
    QOUT('  <ELEMENTS>')
    QOUT('    <ITEM GUID="4D7EA2A2-C2A1-11DC-96A3-0018F30B88B5" Name="Обновить остатки" Code="4"/>')
    QOUT('    <ITEM GUID="4D7EA2A1-C2A1-11DC-96A3-0018F30B88B5" Name="Обновить маршруты" Code="3"/>')
    QOUT('    <ITEM GUID="4DBB8283-C2AD-11DD-926C-001FC6A1D79B" Name="Обновить все" Code="5"/>')
    QOUT('    <ITEM GUID="4D7EA2A0-C2A1-11DC-96A3-0018F30B88B5" Name="Обновить историю продаж" Code="2"/>')
    QOUT('    <ITEM GUID="4D7EA29F-C2A1-11DC-96A3-0018F30B88B5" Name="Обновить взаиморасчеты" Code="1"/>')
    QOUT('  </ELEMENTS>')
    QOUT('</CATALOG>')
  ENDIF

  SET PRINT TO
  SET PRINT OFF
  RETURN (NIL)


