
CREATE OR REPLACE FUNCTION PARTNER_UPOZORENJE
(
   p_sifpar           IN VARCHAR2,
   p_datum_knjizenja  IN DATE
)
RETURN VARCHAR2
IS
   v_datum_od          DATE;
   v_datum_do          DATE;
   v_potroseno         NUMBER;
   v_iznos_ugovora     NUMBER;
   v_iznos_upozorenja  NUMBER;
   v_naziv_ugovora     VARCHAR2(200);
BEGIN
   SELECT naziv_ugovora,
          datum_ugovora,
          NVL(istek_ugovora, DATE '2999-12-31'),
          NVL(iznos_ugovora, 0),
          NVL(iznos_upozorenja, 0)
   INTO v_naziv_ugovora,
        v_datum_od,
        v_datum_do,
        v_iznos_ugovora,
        v_iznos_upozorenja
   FROM (
      SELECT naziv_ugovora,
             datum_ugovora,
             istek_ugovora,
             iznos_ugovora,
             iznos_upozorenja,
             recno
      FROM partner_ugovori
      WHERE sifpar = p_sifpar
        AND TRUNC(p_datum_knjizenja) >= TRUNC(datum_ugovora)
        AND TRUNC(p_datum_knjizenja) <= TRUNC(NVL(istek_ugovora, DATE '2999-12-31'))
      ORDER BY datum_ugovora DESC, recno DESC
   )
   WHERE ROWNUM = 1;

   v_potroseno := partner_potroseno(
                     p_sifpar   => p_sifpar,
                     p_datum_od => v_datum_od,
                     p_datum_do => v_datum_do
                  );

   IF v_iznos_ugovora > 0
      AND v_potroseno >= v_iznos_ugovora THEN

      RETURN 'PREKORAČEN UGOVOR!' ||
             CHR(10) ||
             'Naziv ugovora: ' || v_naziv_ugovora ||
             CHR(10) ||
             'Šifra partnera: ' || p_sifpar ||
             CHR(10) || CHR(10) ||
             'Utrošeno:  ' || TO_CHAR(v_potroseno, 'FM999G999G999G990D00') ||
             CHR(10) ||
             'Ugovoreno: ' || TO_CHAR(v_iznos_ugovora, 'FM999G999G999G990D00');

   ELSIF v_iznos_upozorenja > 0
      AND v_potroseno >= v_iznos_upozorenja THEN

      RETURN 'UPOZORENJE: Potrošnja je blizu ugovorenog iznosa.' ||
             CHR(10) || CHR(10) ||
             'Naziv ugovora: ' || v_naziv_ugovora ||
             CHR(10) ||
             'Šifra partnera: ' || p_sifpar ||
             CHR(10) || CHR(10) ||
             'Potrošeno: ' || TO_CHAR(v_potroseno, 'FM999G999G999G990D00') ||
             CHR(10) ||
             'Ugovoreni iznos: ' || TO_CHAR(v_iznos_ugovora, 'FM999G999G999G990D00');

   ELSE
      RETURN NULL;
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN NULL;
END PARTNER_UPOZORENJE;
/

