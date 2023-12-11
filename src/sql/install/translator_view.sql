create or replace view translator_dd_view as
select 

uebersetzer_sprachen.kundennummer,
uebersetzer_sprachen.kostenstelle,
a.code source_language,
b.code target_language,

concat(uebersetzer.vorname ,' ',uebersetzer.nachname, ' ( ',a.code,' - ',b.code,')') name

 from uebersetzer_sprachen join languagecodes a
 on uebersetzer_sprachen.source_language = a.name
 join languagecodes b
 on uebersetzer_sprachen.destination_language = b.name
 join uebersetzer on (uebersetzer.kundennummer,uebersetzer.kostenstelle) = (uebersetzer_sprachen.kundennummer,uebersetzer_sprachen.kostenstelle);
