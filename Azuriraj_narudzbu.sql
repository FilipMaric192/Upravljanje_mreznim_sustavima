PROCEDURE AZURIRAJ_AUTO_NAR IS
	v_recno NUMBER;
	v_recno_narud NUMBER;
	v_min NUMBER;
	v_vec_naruceno NUMBER;
	v_kolicina NUMBER;
BEGIN
  
  SELECT MAX(recno)
  INTO v_recno
  FROM dok_zaglavlje
  WHERE brac=:DOK_ZAG.brac
  AND godina=:GLOBAL.mgodina
  AND kojik=:GLOBAL.mkoje;
  
  IF v_recno IS NULL THEN
  	RETURN;
  END IF;	
  
  message('Pokrenuo ažuriranje');
  message('');
  -- Provjera postoji li već ova stavka
  
  SELECT MAX(recno)
  INTO v_recno_narud
  FROM narudzba_stavke
  WHERE recno1=v_recno
  AND sif_rob=:DOK_STAVKA.sif_rob
  AND kojik=:GLOBAL.mkoje
  AND godina=:GLOBAL.mgodina
  AND siforg=:GLOBAL.trgovina
  AND opis LIKE 'AUTO_NAR%';
  
  IF v_recno_narud IS NULL THEN
  	RETURN;
  ELSE
  	skloni_min_zaliha;
  END IF;	
  
  -- Provjeri minimalnu zalihu
  
  SELECT minimalna
  INTO v_min
  FROM artikli_min_zaliha
  WHERE sif_rob=:DOK_STAVKA.sif_rob
  AND kojik=:GLOBAL.mkoje
  AND siforg=:GLOBAL.trgovina;
  
  -- Koliko je već naručeno a nije stiglo na skladište
  
  SELECT NVL(SUM(NVL(n.kolic, 0) - NVL(n.isporuceno, 0)), 0)
  INTO v_vec_naruceno
  FROM narudzba_stavke n, narudzba_zaglavlje z
  WHERE z.kojik= n.kojik
  AND z.godina= n.godina
  AND z.vrstdok= n.vrstdok
  AND z.brdok= n.brdok
  AND z.siforg= n.siforg
  AND n.kojik= :GLOBAL.MKOJE
  AND n.godina= :GLOBAL.MGODINA
  AND n.siforg= :GLOBAL.TRGOVINA
  AND n.sif_rob= :DOK_STAVKA.SIF_ROB
  AND z.isdeleted= '2'
  AND z.naput LIKE 'AUTO_NAR%'
  AND n.opis LIKE 'AUTO_NAR%'
  AND NVL(n.kolic, 0) > NVL(n.isporuceno, 0)
  AND NVL(n.recno1, -1) <> NVL(v_recno, -1);
  
  -- Novo računanje koja količina treba u narudzbu
  
   IF :DOK_ZAG.SKLSTANJE_ORIG IS NULL THEN
   MESSAGE('SKLSTANJE_ORIG nije napunjen za artikl ' || :DOK_STAVKA.SIF_ROB);
   MESSAGE(' ');
   RETURN;
   END IF;
   
    v_kolicina := v_min -
                 (
                    NVL(:DOK_ZAG.SKLSTANJE_ORIG,0)
                    - NVL(:DOK_STAVKA.KOLIC, 0)
                    + NVL(v_vec_naruceno, 0)
                 );
  
  -- Ako je s novim izračunom zaliha iznad minimalne, briši stavku
  
  IF v_kolicina <=0 THEN
  	
	  DELETE FROM narudzba_stavke
	  WHERE recno1=v_recno
	  AND sif_rob=:DOK_STAVKA.sif_rob
	  AND siforg=:GLOBAL.trgovina
	  AND kojik=:GLOBAL.mkoje
	  AND godina=:GLOBAL.mgodina
	  AND opis LIKE 'AUTO_NAR%';
  
  COMMIT;
    
  ELSE
  
  -- Ako treba dodati ili oduzet napravi update
  
  UPDATE narudzba_stavke
      SET kolic = v_kolicina
      WHERE recno1 = v_recno
      AND sif_rob=:DOK_STAVKA.sif_rob
      AND siforg=:GLOBAL.trgovina
	    AND kojik=:GLOBAL.mkoje
	    AND godina=:GLOBAL.mgodina
	    AND opis LIKE 'AUTO_NAR%';
	
	COMMIT;
	END IF;    
  
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
      NULL;

  
END;
//
