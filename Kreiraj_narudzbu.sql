PROCEDURE KREIRAJ_AUTO_NARUDZBU IS

   recno_narudz          NUMBER;
   recno_narud           NUMBER;

   provjeri              VARCHAR2(10);
   v_vrstdok             VARCHAR2(10);
   v_brdok               NUMBER;
   greska                VARCHAR2(2000);
   v_nrecno              NUMBER;

   v_ksint               VARCHAR2(10);
   datum                 DATE;

   v_kolicina            NUMBER;
   v_min_zaliha          NUMBER;
   v_postoji             NUMBER;
   vec_naruceno          NUMBER;

   v_recno               NUMBER;
   v_recno_postojeci     NUMBER;

   al_button             NUMBER;
   v_sifra_dobav         VARCHAR2(10):=ERP_UTIL.VAR_GLOBAL_VALUE('G$SIFRA_PARTNERA_NAR');
   

BEGIN

   datum := TRUNC(SYSDATE);
   v_ksint := '2200';

  
   -- Uzmi recno trenutnog računa
   
   SELECT MAX(recno)
     INTO v_recno
     FROM dok_zaglavlje
    WHERE brac    = :DOK_ZAG.BRAC
      AND godina  = :GLOBAL.MGODINA
      AND kojik   = :GLOBAL.MKOJE
      AND SIFORG  = :GLOBAL.TRGOVINA 
      AND VRSTDOK = :GLOBAL.VPOS;

   IF v_recno IS NULL THEN
      SET_ALERT_PROPERTY('INFO_AUTO_NARUDZBA',
                         ALERT_MESSAGE_TEXT,
                         'Nije pronađen RECNO računa. Automatska narudzba_stavkežba nije kreirana.');
      al_button := SHOW_ALERT('INFO_AUTO_NARUDZBA');
      RETURN;
   END IF;

   
   -- Odredi vrstu dokumenta
   
   SELECT vrijednost
     INTO provjeri
     FROM sistem_postavke
    WHERE rb = '504';

   IF provjeri = 'DA' THEN
      v_vrstdok := 'NAR' || :GLOBAL.TRGOVINA;
   ELSE
      v_vrstdok := 'NAR';
   END IF;

   
   -- Pronađi minimalnu zalihu za taj artikl
  
   SELECT minimalna
     INTO v_min_zaliha
     FROM artikli_min_zaliha
    WHERE kojik   = :GLOBAL.MKOJE
      AND siforg  =  :GLOBAL.TRGOVINA
      AND sif_rob = :DOK_STAVKA.SIF_ROB;
   
   -- Koliko je već naručeno, ali još nije isporučeno u skladište
   
   
   SELECT NVL(SUM(NVL(n.kolic, 0) - NVL(n.isporuceno, 0)), 0)
     INTO vec_naruceno
     FROM narudzba_stavke n, narudzba_zaglavlje z
    WHERE z.kojik   = n.kojik
      AND z.godina  = n.godina
      AND z.vrstdok = n.vrstdok
      AND z.brdok   = n.brdok
      AND z.siforg  = n.siforg
      AND n.kojik   = :GLOBAL.MKOJE
      AND n.godina  = :GLOBAL.MGODINA
      AND n.siforg  = :GLOBAL.TRGOVINA
      AND n.sif_rob = :DOK_STAVKA.SIF_ROB
      AND NVL(z.isdeleted, '0') IN ('0', '2')
      AND z.naput LIKE '%AUTO_NAR%'
      AND n.opis  LIKE '%AUTO_NAR%'
      AND NVL(n.kolic, 0) > NVL(n.isporuceno, 0)
      AND NVL(n.recno1, -1) <> NVL(v_recno, -1);

   
   -- Spremi sklstanje za kasnije ažuriranje
   
   IF :DOK_ZAG.SKLSTANJE_ORIG IS NULL THEN
   :DOK_ZAG.SKLSTANJE_ORIG := NVL(:ART_STANJE.SKLSTANJE, 0);
   END IF;
   
   
   -- Izračun koliko još treba dodati u prendarudžbu
   
   v_kolicina := v_min_zaliha -
                 (
                    NVL(:ART_STANJE.SKLSTANJE, 0)
                    - NVL(:DOK_STAVKA.KOLIC, 0)
                    + NVL(vec_naruceno, 0)
                 );


   -- Ako s onim što stiže ne treba povećavati količinu za tu stavku , izađi
   
   IF v_kolicina <= 0 THEN 
   	
   	SET_ALERT_PROPERTY('INFO_AUTO_NARUDZBA', ALERT_MESSAGE_TEXT, 
   	'Za ovaj artikl nije potrebna nova prednarudžba jer je količina već pokrivena postojećom prednarudžbom.');
   	 
   	 al_button := SHOW_ALERT('INFO_AUTO_NARUDZBA'); 
   	 
   	 RETURN; 
   	 
   	END IF;

  
   -- Ako postoji prednarudžba koja nije zaključena, uzmi njen brodk. Ako ne postoji, kreiraj novo zaglavlje.
   
   SELECT COUNT(*)
     INTO v_postoji
     FROM narudzba_zaglavlje
    WHERE kojik   = :GLOBAL.MKOJE
      AND vrstdok = v_vrstdok
      AND siforg  = :GLOBAL.TRGOVINA
      AND godina  = :GLOBAL.MGODINA
      AND naput LIKE '%AUTO_NAR%'
      AND NVL(isdeleted, '0') = '0';

   IF v_postoji = 0 THEN

      recno_narudz := erp_sekvence.sekvenca('NARUDZBA_ZAGLAVLJE');

      ERP_OBRADA.BRDOK_PROVJERI(
         0,
         v_vrstdok,
         :GLOBAL.MGODINA,
         :GLOBAL.MKOJE,
         0,
         'NARUDZBA_ZAGLAVLJE',
         '1=1',
         v_nrecno,
         v_brdok,
         greska
      );

      INSERT INTO NARUDZBA_ZAGLAVLJE
         (RECNO, VRSTDOK, BRDOK, KOJIK, GODINA, SIFORG, DATUM, DATRAC, KSINT, KANAL, SIFPAR, NAPUT)
      VALUES
         (recno_narudz, v_vrstdok, v_brdok, :GLOBAL.MKOJE, :GLOBAL.MGODINA, :GLOBAL.TRGOVINA,
          datum, datum, v_ksint,v_sifra_dobav,v_sifra_dobav, 'AUTO NARUDZBA_STAVKEŽBA');


      COMMIT;

   ELSE

      SELECT MAX(brdok)
        INTO v_brdok
        FROM narudzba_zaglavlje
       WHERE kojik   = :GLOBAL.MKOJE
         AND vrstdok = v_vrstdok
         AND siforg  = :GLOBAL.TRGOVINA
         AND godina  = :GLOBAL.MGODINA
         AND NVL(isdeleted, '0') = '0'
         AND naput LIKE '%AUTO_NAR%';

   END IF;

   
   -- Opet provjeri postoji li stavka za ovaj račun baš u toj aktivnoj automatskoj narudzba_stavkežbi.
   
   SELECT MIN(recno)
     INTO v_recno_postojeci
     FROM narudzba_stavke
    WHERE kojik   = :GLOBAL.MKOJE
      AND godina  = :GLOBAL.MGODINA
      AND vrstdok = v_vrstdok
      AND brdok   = v_brdok
      AND siforg  = :GLOBAL.TRGOVINA
      AND sif_rob = :DOK_STAVKA.SIF_ROB
      AND recno1  = v_recno
      AND opis LIKE '%AUTO_NAR%';

   
   -- Ako već postoji stavka za isti račun i artikl, ažuriraj količinu
  
   IF v_recno_postojeci IS NOT NULL THEN

      UPDATE narudzba_stavke
         SET kolic = v_kolicina
       WHERE recno = v_recno_postojeci;

      COMMIT;

      SET_ALERT_PROPERTY('INFO_AUTO_NARUDZBA',
                         ALERT_MESSAGE_TEXT,
                         'Stavka je ažurirana u automatskoj narudzba_stavkežbi broj: ' || v_brdok);

      al_button := SHOW_ALERT('INFO_AUTO_NARUDZBA');

      RETURN;

   END IF;

   
   -- Ako ne postoji stavka za ovaj račun i artikl, dodaj novu
   
   recno_narud := erp_sekvence.sekvenca('NARUDZBA_STAVKE');

   INSERT INTO NARUDZBA_STAVKE
      (RECNO, VRSTDOK, BRDOK, KOJIK, GODINA, SIF_ROB, SIFORG, DATUM, JM, KOLIC, TAR_BR, OZN, MET, OPIS, RECNO1)
   VALUES
      (recno_narud, v_vrstdok, v_brdok, :GLOBAL.MKOJE, :GLOBAL.MGODINA, :DOK_STAVKA.SIF_ROB,
       :GLOBAL.TRGOVINA, datum, :DOK_STAVKA.JM, v_kolicina, :DOK_STAVKA.TAR_BR, :DOK_STAVKA.OZN, :DOK_STAVKA.MET,
       'AUTO NARUDZBA_STAVKEŽBA', v_recno);

   COMMIT;

   SET_ALERT_PROPERTY('INFO_AUTO_NARUDZBA',
                      ALERT_MESSAGE_TEXT,
                      'Stavka je dodana u narudzbu broj: ' || v_brdok);

   al_button := SHOW_ALERT('INFO_AUTO_NARUDZBA');

	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	      SET_ALERT_PROPERTY('INFO_AUTO_NARUDZBA',
	                         ALERT_MESSAGE_TEXT,
	                         'Nedostaje podatak za kreiranje automatske narudzbe.');
	
	      al_button := SHOW_ALERT('INFO_AUTO_NARUDZBA');
	      RAISE FORM_TRIGGER_FAILURE;
	
	   WHEN TOO_MANY_ROWS THEN
	      SET_ALERT_PROPERTY('INFO_AUTO_NARUDZBA',
	                         ALERT_MESSAGE_TEXT,
	                         'Pronađeno je više zapisa nego očekivano kod kreiranja automatske narudzbe.');
	
	      al_button := SHOW_ALERT('INFO_AUTO_NARUDZBA');
	      RAISE FORM_TRIGGER_FAILURE;
	
	   WHEN OTHERS THEN
	      ROLLBACK;
	
	      SET_ALERT_PROPERTY('INFO_AUTO_NARUDZBA',
	                         ALERT_MESSAGE_TEXT,
	                         'Greška kod kreiranja narudzbe.');
	
	      al_button := SHOW_ALERT('INFO_AUTO_NARUDZBA');
	      RAISE FORM_TRIGGER_FAILURE;
	
	END;
	
//
