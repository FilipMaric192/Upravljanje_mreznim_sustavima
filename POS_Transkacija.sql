CREATE OR REPLACE PROCEDURE ERP_SCHEMA.POS_TRANSAKCIJA_PROCES (
    MPOS_UREDJAJ      IN     VARCHAR2,
    MPOS_RESPONSE     IN     VARCHAR2,
    MRACZAG_KOJIK     IN     VARCHAR2,
    MRACZAG_RECNO     IN     INTEGER,
    MRACZAG_BRAC      IN     INTEGER,
    MRACZAG_SYSDATE   IN     DATE,
    STATUS_OK         OUT BOOLEAN,
    MCEKOVI_OZNAKA    OUT VARCHAR2,
    MGRESKA           OUT VARCHAR2)
AS
    data_row            VARCHAR2 (4000);
    data_row1           VARCHAR2 (4000);
    delimiter           VARCHAR2 (2);
    delimiter1          VARCHAR2 (2);
    Pos0                INTEGER;
    Pos1                INTEGER;
    Pos2                INTEGER;
    Pos3                INTEGER;
    Pos4                INTEGER;
    Pos5                INTEGER;
    Pos6                INTEGER;
    Pos7                INTEGER;
    Pos8                INTEGER;
    Pos9                INTEGER;
    Pos10               INTEGER;
    Pos11               INTEGER;
    Pos12               INTEGER;
    Pos13               INTEGER;
    Pos14               INTEGER;
    Pos15               INTEGER;
    Pos16               INTEGER;
    Pos17               INTEGER;
    Pos18               INTEGER;
    Pos19               INTEGER;
    upoz                INTEGER;
    upoz1                INTEGER;
    mduz                NUMBER;
    mduz1               NUMBER;
    Mbroj_kartice       VARCHAR2 (100);
    Mnaziv_kartice      VARCHAR2 (100);
    valjanost_kartice   VARCHAR2 (100);
    oznaka_citanja      VARCHAR2 (100);
    iznos_transakcije   VARCHAR2 (100);
    Mbroj_trans_ter     VARCHAR2 (100);
    naziv_vlas          VARCHAR2 (300);
    dat_vrijeme         VARCHAR2 (300);
    aut_kod             VARCHAR2 (100);
    Mstatus             VARCHAR2 (10);
    Mbroj_terminala     VARCHAR2 (100);
    Mtid                VARCHAR2 (100);
    Mopis               VARCHAR2 (300);
    minv_no             VARCHAR2 (100);
    mapp_no             VARCHAR2 (100);
    mrrn                VARCHAR2 (100);
    moz                 VARCHAR2 (100);
    mhost_resp          VARCHAR2 (100);
    mhead_line1         VARCHAR2 (100);
    mhead_line2         VARCHAR2 (100);
    mcardh_v            VARCHAR2 (100);
    mapp_name           VARCHAR2 (100);
    mapp_id             VARCHAR2 (100);
    mcrypto             VARCHAR2 (4000);
    mcard_type          VARCHAR2 (100);
    mcardhold_name      VARCHAR2 (100);
    mzag varchar2(100);
   -- mstatus varchar2(100);
    mtemp varchar2(1000);
    mtemp1 varchar2(1000);
BEGIN
  begin
   IF  MPOS_UREDJAJ = 'BANKA_A' THEN
      delimiter:=CHR(28);  --- FS
      data_row := MPOS_RESPONSE;

      upoz := 0;
      mduz := LENGTH (data_row);
      mstatus:=substr(data_row,7,2);


      if mstatus='00' then
         status_ok:=true;
         mopis:='Transakcija potvrđena';
      else
         status_ok:=false;
         IF mstatus ='02' then
            mgreska:='Potrebna telefonska autorizacija !! ';
            mopis:='Potrebna telefonska autorizacija !! ';
         elsif mstatus = '04' then
            mgreska:='Zadrži karticu !! ';
            mopis:='Zadrži karticu !! ';
         elsif mstatus = '05' then
            mgreska:='Transakcija prekinuta !! ';
            mopis:= 'Transakcija prekinuta !! ';
         elsif mstatus = '33' then
            mgreska:='Kartica nije važeća !! ';
            mopis:='Kartica nije važeća !! ';
         elsif mstatus = '43' then
            mgreska:='Ukradena kartica !! Oduzmi karticu !! ';
            mopis:='Ukradena kartica !! Oduzmi karticu !! ';
         end if;
      end if;

       Pos1 := INSTR (data_row, delimiter);
       mtemp := SUBSTR (data_row, 1, pos1 - 1);
       upoz := NVL (upoz, 0) + pos1;
    --   insert into a1(aaa) values ('1  '||pos1||'   '||mtemp);

       Pos2 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
       mtemp := SUBSTR (data_row, upoz + 1, pos2 - 1);
       upoz := NVL (upoz, 0) + pos2;
    --   insert into a1(aaa) values ('2  '||pos2||'   '||mtemp);

       Pos3 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
       Mbroj_trans_ter := SUBSTR (data_row, upoz + 1, pos3 - 1);
       upoz := NVL (upoz, 0) + pos3;
    --  insert into a1(aaa) values ('3  '||pos3||'   '||mbroj_trans_ter);

       Pos4 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
       iznos_transakcije :=podijeli_sigurno(SUBSTR (data_row, upoz + 1, pos4 - 1),100);
       upoz := NVL (upoz, 0) + pos4;

    --   insert into a1(aaa) values ('4  '||pos4||'   '||iznos_transakcije);


       Pos5 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
       mtemp :=SUBSTR (data_row, upoz + 1, pos5 - 1);
       upoz := NVL (upoz, 0) + pos5;
    --   insert into a1(aaa) values ('5  '||pos5||'   '||mtemp);

       Pos6 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
       Mbroj_kartice := SUBSTR (data_row, upoz + 1, pos6 - 1);
       upoz := NVL (upoz, 0) + pos6;
    --   insert into a1(aaa) values ('6  '||pos6||'   '||mbroj_kartice);


       Pos7 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
       mtemp := SUBSTR (data_row, upoz + 1, pos7 - 1);
       upoz := NVL (upoz, 0) + pos7;
    --   insert into a1(aaa) values ('7  '||pos7||'   '||mtemp);


       Pos8 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
       mtemp := SUBSTR (data_row, upoz + 1, pos8 - 1);
       upoz := NVL (upoz, 0) + pos8;
    --   insert into a1(aaa) values ('8  '||pos8||'   '||mtemp);

       Pos9 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
       mtemp1 := ltrim(rtrim(sUBSTR (data_row, upoz + 1, pos9 - 1)));
       upoz := NVL (upoz, 0) + pos9;
       aut_kod:=substr(mtemp1,1, 12);
       dat_vrijeme:=substr(mtemp1,13,8);
       mnaziv_kartice:=substr(mtemp1,21,100);
   --    insert into a1(aaa) values ('9  '||pos9||'   '||mtemp1);
   --    insert into a1(aaa) values ('9  '||pos9||'  autokod '||aut_kod);
   --    insert into a1(aaa) values ('9  '||pos9||'  dat_vrijeme '||dat_vrijeme);
   --    insert into a1(aaa) values ('9  '||pos9||'  mnaziv_kartice '||mnaziv_kartice);

       Pos10 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
       mtemp := SUBSTR (data_row, upoz + 1, pos10 - 1);
       upoz := NVL (upoz, 0) + pos10;
    --   insert into a1(aaa) values ('10  '||pos10||'   '||mtemp);

       Mbroj_trans_ter := SUBSTR (data_row, upoz + 1,100);


    BEGIN

       select broj into mcekovi_oznaka from nacini_placanja where ime like  Mnaziv_kartice||'%';

     EXCEPTION
       When no_data_found then
            mcekovi_oznaka:='997';
       When TOO_MANY_ROWS then
          select MIN(broj) into mcekovi_oznaka from nacini_placanja where  ime like  Mnaziv_kartice||'%';
       When others then
           mcekovi_oznaka:='997';

    END;

    INSERT INTO POS_LOG_BANKA_A   (POS_UREDJAJ,
                                      POS_RESPONSE,
                                      RACZAG_RECNO,
                                      RACZAG_BRAC,
                                      RACZAG_SYSDATE,
                                      RACZAG_KOJIK,
                                      BROJ_KARTICE,
                                      NAZIV_KARTICE,
                                      VALJANOST,
                                      OZNAKA,
                                      IZNOS_TRANS,
                                      BROJ_TRANS_TER,
                                      VLASNIK,
                                      DATUM_VRIJEME,
                                      KOD,
                                      STATUS,
                                      BROJ_TERMINALA,
                                      TID,
                                      OPIS,
                                      CEKOVI_OZNAKA,
                                      GRESKA)
         VALUES (MPOS_UREDJAJ,
                 MPOS_RESPONSE,
                 MRACZAG_RECNO,
                 MRACZAG_BRAC,
                 MRACZAG_SYSDATE,
                 MRACZAG_KOJIK,
                 Mbroj_kartice,
                 Mnaziv_kartice,
                 valjanost_kartice,
                 oznaka_citanja,
                 iznos_transakcije,
                 Mbroj_trans_ter,
                 naziv_vlas,
                 dat_vrijeme,
                 aut_kod,
                 Mstatus,
                 Mbroj_terminala,
                 Mtid,
                 mopis,
                 MCEKOVI_OZNAKA,
                 mgreska);
      commit;

   ELSIF  MPOS_UREDJAJ = 'BANKA_B' THEN

     delimiter:=CHR(28);
     delimiter1:=CHR(30);

     data_row := substr(MPOS_RESPONSE,1,instr(MPOS_RESPONSE,delimiter1)-1);
     data_row1:= substr(MPOS_RESPONSE,instr(MPOS_RESPONSE,delimiter1)+1,4000);

     upoz:=0;
     mduz := LENGTH (data_row);
     mduz1 := LENGTH (data_row1);

     Pos0 := INSTR (data_row, delimiter);
     Mzag := SUBSTR (data_row, 1, pos0 - 1);
     upoz := NVL (upoz, 0) + pos0;

     Pos1 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
     Mtid := SUBSTR (data_row,  upoz + 1, pos1 - 1);
     upoz := NVL (upoz, 0) + pos1;

     Pos2 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
     Mbroj_terminala := SUBSTR (data_row, upoz + 1, pos2 - 1);
     upoz := NVL (upoz, 0) + pos2;

     Pos3 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
     minv_no := SUBSTR (data_row, upoz + 1, pos3 - 1);
     upoz := NVL (upoz, 0) + pos3;

     Pos4 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
     mapp_no := SUBSTR (data_row, upoz + 1, pos4 - 1);
     upoz := NVL (upoz, 0) + pos4;

     Pos5 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
     mrrn := SUBSTR (data_row, upoz + 1, pos5 - 1);
     upoz := NVL (upoz, 0) + pos5;

     Pos6 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
     aut_kod := SUBSTR (data_row, upoz + 1, pos6 - 1);
     upoz := NVL (upoz, 0) + pos6;

     Pos7 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
     Mbroj_kartice := SUBSTR (data_row, upoz + 1, pos7 - 1);
     upoz := NVL (upoz, 0) + pos7;

     Pos8 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
     valjanost_kartice := SUBSTR (data_row, upoz + 1, pos8 - 1);
     upoz := NVL (upoz, 0) + pos8;

     --Pos9 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
     --moz := SUBSTR (data_row, upoz + 1, pos9 - 1);
     moz := SUBSTR (data_row, upoz + 1,  1);
     upoz := NVL (upoz, 0) + pos9;


     Pos10 := INSTR (data_row1, delimiter1);
     Mnaziv_kartice := SUBSTR (data_row1, 1, pos10 - 1);
     upoz1 := NVL (upoz1, 0) + pos10;

     Pos11 := INSTR (SUBSTR (data_row1, upoz1 + 1, mduz1), delimiter1);
     mhost_resp := SUBSTR (data_row1, upoz1 + 1, pos11 - 1);
     upoz1 := NVL (upoz1, 0) + pos11;

     Pos12 := INSTR (SUBSTR (data_row1, upoz1 + 1, mduz1), delimiter1);
     mhead_line1  := SUBSTR (data_row1, upoz1 + 1, pos12 - 1);
     upoz1 := NVL (upoz1, 0) + pos12;

     Pos13 := INSTR (SUBSTR (data_row1, upoz1 + 1, mduz1), delimiter1);
     mhead_line2  := SUBSTR (data_row1, upoz1 + 1, pos13 - 1);
     upoz1 := NVL (upoz1, 0) + pos13;

     Pos14 := INSTR (SUBSTR (data_row1, upoz1 + 1, mduz1), delimiter1);
     mcardh_v  := SUBSTR (data_row1, upoz1 + 1, pos14 - 1);
     upoz1 := NVL (upoz1, 0) + pos14;

     Pos15 := INSTR (SUBSTR (data_row1, upoz1 + 1, mduz1), delimiter1);
     mapp_name := SUBSTR (data_row1, upoz1 + 1, pos15 - 1);
     upoz1 := NVL (upoz1, 0) + pos15;

     Pos16 := INSTR (SUBSTR (data_row1, upoz1 + 1, mduz1), delimiter1);
     mapp_id := SUBSTR (data_row1, upoz1 + 1, pos16 - 1);
     upoz1 := NVL (upoz1, 0) + pos16;

     Pos17 := INSTR (SUBSTR (data_row1, upoz1 + 1, mduz1), delimiter1);
     mcrypto:= SUBSTR (data_row1, upoz1 + 1, pos17 - 1);
     upoz1 := NVL (upoz1, 0) + pos17;

     Pos18 := INSTR (SUBSTR (data_row1, upoz1 + 1, mduz1), delimiter1);
     mcard_type:= SUBSTR (data_row1, upoz1 + 1, pos18 - 1);
     upoz1 := NVL (upoz1, 0) + pos18;

     Pos19 := INSTR (SUBSTR (data_row1, upoz1 + 1, mduz1), delimiter1);
     mcardhold_name:= SUBSTR (data_row1, upoz1 + 1, pos19 - 1);
     upoz1 := NVL (upoz1, 0) + pos19;

     mstatus:= substr(Mzag,length(mzag)-2,3);

     BEGIN
        if MRACZAG_KOJIK='AL' then
       --select broj into mcekovi_oznaka from nacini_placanja where substr(ime,1,INSTR(ime,'=')) = substr(Mnaziv_kartice,1,INSTR(Mnaziv_kartice,'='));
         select broj into mcekovi_oznaka  from nacini_placanja where  substr(IME,1,INSTR(IME,'-')-1) = rtrim(substr(Mnaziv_kartice,1,100)) ;
       else
          select broj into mcekovi_oznaka  from nacini_placanja where  substr(IME,instr(ime,'=')+1,100) = rtrim(upper(substr(Mnaziv_kartice,INSTR(Mnaziv_kartice,'a')+1,100))) ;
       end if; 

     EXCEPTION
       When no_data_found then
          begin
             select broj into mcekovi_oznaka  from nacini_placanja where  substr(IME,instr(ime,'=')+1,100) = rtrim(upper(substr(Mnaziv_kartice,INSTR(Mnaziv_kartice,'a')+1,100))) ;
          exception 
        
          When TOO_MANY_ROWS then
             select MIN(broj) into mcekovi_oznaka  from nacini_placanja where  substr(IME,instr(ime,'=')+1,100) = rtrim(upper(substr(Mnaziv_kartice,INSTR(Mnaziv_kartice,'a')+1,100))) ;
          when others then 
             mcekovi_oznaka:='999';
          end;   
       When TOO_MANY_ROWS then
          select MIN(broj) into mcekovi_oznaka  from nacini_placanja where  substr(IME,instr(ime,'=')+1,100) = rtrim(upper(substr(Mnaziv_kartice,INSTR(Mnaziv_kartice,'a')+1,100))) ;
       WHEN OTHERS THEN
          mcekovi_oznaka:='999';

    END;

     INSERT INTO POS_LOG_BANKA_B (POS_UREDJAJ,
                                   POS_RESPONSE,
                                   RACZAG_RECNO,
                                   RACZAG_BRAC,
                                   RACZAG_SYSDATE,
                                   RACZAG_KOJIK,
                                   TERMINAL_ID,
                                   MERCHANT_ID,
                                   INVOICE_NO,
                                   APPROVAL_NO,
                                   RRN,
                                   RESPONSE_CODE,
                                   BROJ_KARTICE,
                                   NAZIV_KARTICE,
                                   VALJANOST,
                                   OZNAKA,
                                   IZNOS_TRANS,
                                   BROJ_TRANS_TER,
                                   VLASNIK,
                                   DATUM_VRIJEME,
                                   KOD,
                                   STATUS,
                                   APLICATION_NAME,
                                   APLICATION_ID,
                                   OPIS,
                                   CRYPTO_DATA,
                                   CARD_ENTRY_TYPE,
                                   CARD_HOLDER_NAME,
                                   CEKOVI_OZNAKA,
                                   GRESKA)
 VALUES (MPOS_UREDJAJ,
                 MPOS_RESPONSE,
                 MRACZAG_RECNO,
                 MRACZAG_BRAC,
                 MRACZAG_SYSDATE,
                 MRACZAG_KOJIK,
                 Mtid,
                 Mbroj_terminala ,
                 minv_no,
                 mapp_no,
                 mrrn ,
                 aut_kod,
                 Mbroj_kartice,
                 Mnaziv_kartice,
                 valjanost_kartice,
                 moz,
                 null,
                 substr(mzag,1,8),
                 mhead_line2,
                 substr(Mzag,20,12),
                 aut_kod,
                 mstatus,
                 mapp_name,
                 mapp_id,
                 mhost_resp,
                 mcrypto,
                 mcard_type,
                 mcardhold_name,
                 MCEKOVI_OZNAKA,
                 mgreska);

    commit;

    IF mstatus IN ('000') and substr(aut_kod,2,3) in ('000','001','002','003','004','005','006','007','008','009','010') THEN
        status_ok := TRUE;
    ELSE
        status_ok := FALSE;
        mgreska:=initcap(substr(lower(mhost_resp),2,100));

    END IF;



   ELSIF  MPOS_UREDJAJ = 'BANKA_C' THEN

    delimiter:=CHR(28);
    data_row := MPOS_RESPONSE;

    upoz := 0;
    mduz := LENGTH (data_row);

    Pos1 := INSTR (data_row, delimiter);
    Mbroj_kartice := SUBSTR (data_row, 1, pos1 - 1);
    upoz := NVL (upoz, 0) + pos1;

    Pos2 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
    Mnaziv_kartice := SUBSTR (data_row, upoz + 1, pos2 - 1);
    upoz := NVL (upoz, 0) + pos2;

    Pos3 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
    valjanost_kartice := SUBSTR (data_row, upoz + 1, pos3 - 1);
    upoz := NVL (upoz, 0) + pos3;

    Pos4 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
    oznaka_citanja := SUBSTR (data_row, upoz + 1, pos4 - 1);
    upoz := NVL (upoz, 0) + pos4;


    Pos5 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
    iznos_transakcije :=podijeli_sigurno(SUBSTR (data_row, upoz + 1, pos5 - 1),100);
    upoz := NVL (upoz, 0) + pos5;

    Pos6 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
    Mbroj_trans_ter := SUBSTR (data_row, upoz + 1, pos6 - 1);
    upoz := NVL (upoz, 0) + pos6;

    Pos7 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
    naziv_vlas := SUBSTR (data_row, upoz + 1, pos7 - 1);
    upoz := NVL (upoz, 0) + pos7;

    Pos8 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
    dat_vrijeme := SUBSTR (data_row, upoz + 1, pos8 - 1);
    upoz := NVL (upoz, 0) + pos8;

    Pos9 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
    aut_kod := SUBSTR (data_row, upoz + 1, pos9 - 1);
    upoz := NVL (upoz, 0) + pos9;

    Pos10 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
    Mstatus := SUBSTR (data_row, upoz + 1, pos10 - 1);
    upoz := NVL (upoz, 0) + pos10;

    Pos11 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
    Mbroj_terminala := SUBSTR (data_row, upoz + 1, pos11 - 1);
    upoz := NVL (upoz, 0) + pos11;

    Pos12 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
    Mtid := SUBSTR (data_row, upoz + 1, pos12 - 1);
    upoz := NVL (upoz, 0) + pos12;

    Pos13 := INSTR (SUBSTR (data_row, upoz + 1, mduz), delimiter);
    Mopis := SUBSTR (data_row, upoz + 1, pos13 - 1);
    upoz := NVL (upoz, 0) + pos13;

    BEGIN

       select broj into mcekovi_oznaka from nacini_placanja where substr(ime,1,INSTR(ime,'=')) = substr(Mnaziv_kartice,1,INSTR(Mnaziv_kartice,'='));

     EXCEPTION
       When no_data_found then
            mcekovi_oznaka:='998';
       When TOO_MANY_ROWS then
          select MIN(broj) into mcekovi_oznaka from nacini_placanja where substr(ime,1,INSTR(ime,'=')) = substr(Mnaziv_kartice,1,INSTR(Mnaziv_kartice,'='));
       When others then
           mcekovi_oznaka:='998';

    END;

    INSERT INTO POS_LOG_BANKA_C   (POS_UREDJAJ,
                                      POS_RESPONSE,
                                      RACZAG_RECNO,
                                      RACZAG_BRAC,
                                      RACZAG_SYSDATE,
                                      RACZAG_KOJIK,
                                      BROJ_KARTICE,
                                      NAZIV_KARTICE,
                                      VALJANOST,
                                      OZNAKA,
                                      IZNOS_TRANS,
                                      BROJ_TRANS_TER,
                                      VLASNIK,
                                      DATUM_VRIJEME,
                                      KOD,
                                      STATUS,
                                      BROJ_TERMINALA,
                                      TID,
                                      OPIS,
                                      CEKOVI_OZNAKA,
                                      GRESKA)
         VALUES (MPOS_UREDJAJ,
                 MPOS_RESPONSE,
                 MRACZAG_RECNO,
                 MRACZAG_BRAC,
                 MRACZAG_SYSDATE,
                 MRACZAG_KOJIK,
                 Mbroj_kartice,
                 Mnaziv_kartice,
                 valjanost_kartice,
                 oznaka_citanja,
                 iznos_transakcije,
                 Mbroj_trans_ter,
                 naziv_vlas,
                 dat_vrijeme,
                 aut_kod,
                 Mstatus,
                 Mbroj_terminala,
                 Mtid,
                 mopis,
                 MCEKOVI_OZNAKA,
                 mgreska);

    COMMIT;


    IF mstatus IN ('10', '14', '100')
    THEN
        status_ok := TRUE;
    ELSE
        status_ok := FALSE;
        mgreska:=mopis;
    END IF;

 end if;


    EXCEPTION   WHEN OTHERS THEN
        status_ok := FALSE;
        MGRESKA:=sqlerrm;
    end;



END;
/
