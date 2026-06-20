CREATE OR REPLACE function ERP_SCHEMA.dohvati_racun_partnera(msifpar varchar2) 
 return varchar2 is rez varchar2(1000);

begin

 select IBAN into rez from partner_bankovni_racuni where sifpar=msifpar and recno in (select min(recno) from partner_bankovni_racuni where sifpar=msifpar);
 return rez;
exception when others then rez:=null;
 return rez; 


end;
/