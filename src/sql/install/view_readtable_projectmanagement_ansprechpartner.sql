
delimiter ;
CREATE OR REPLACE VIEW `view_readtable_projectmanagement_ansprechpartner` AS
select
  `pm`.`project_id` AS `project_id`,
  `an`.`id` AS `ansprechpartner_id`,
  ifnull(`projectmanagement_ansprechpartner`.`aktiv`, 0) AS `aktiv`,
  `an`.`kundennummer` AS `kundennummer`,
  `an`.`kostenstelle` AS `kostenstelle`,
  `an`.`anrede` AS `anrede`,
  `an`.`vorname` AS `vorname`,
  `an`.`nachname` AS `nachname`,
  `an`.`titel` AS `titel`,
  `an`.`stellung` AS `stellung`,
  `an`.`telefon` AS `telefon`,
  `an`.`telefax` AS `telefax`,
  `an`.`mail` AS `mail`,
  `an`.`serienbrief` AS `serienbrief`,
  `an`.`mobil` AS `mobil`
from
  (
    (
      `projectmanagement` `pm`
      join `ansprechpartner` `an` on(
        (`pm`.`kundennummer`, `pm`.`kostenstelle`) = (`an`.`kundennummer`, `an`.`kostenstelle`)
      )
    )
    left join `projectmanagement_ansprechpartner` on(
      `projectmanagement_ansprechpartner`.`project_id` = `pm`.`project_id`
      and `an`.`id` = `projectmanagement_ansprechpartner`.`ansprechpartner_id`
    )
  );
