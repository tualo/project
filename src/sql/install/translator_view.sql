CREATE OR REPLACE VIEW `translator_dd_view` AS
select
    `uebersetzer_sprachen`.`kundennummer` AS `kundennummer`,
    `uebersetzer_sprachen`.`kostenstelle` AS `kostenstelle`,
    `uebersetzer_sprachen`.`artikel` AS `article`,
    `a`.`code` AS `source_language`,
    `b`.`code` AS `target_language`,
    concat(
        `uebersetzer`.`vorname`,
        ' ',
        `uebersetzer`.`nachname`,
        ' ( ',
        `a`.`code`,
        ' - ',
        `b`.`code`,
        ')',
        '',
        '',
        format(`uebersetzer_sprachen`.`preis`, 2),
        ' €',
        '',
        'zuletzt: ',
        current_timestamp(),
        ' '
    ) AS `name`
from
    (
        (
            (
                `uebersetzer_sprachen`
                join `languagecodes` `a` on(
                    `uebersetzer_sprachen`.`source_language` = `a`.`code`
                )
            )
            join `languagecodes` `b` on(
                `uebersetzer_sprachen`.`destination_language` = `b`.`code`
            )
        )
        join `uebersetzer` on(
            (
                `uebersetzer`.`kundennummer`,
                `uebersetzer`.`kostenstelle`
            ) = (
                `uebersetzer_sprachen`.`kundennummer`,
                `uebersetzer_sprachen`.`kostenstelle`
            )
        )
    )