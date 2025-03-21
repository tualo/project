CREATE
OR REPLACE VIEW `translator_dd_view` AS 
with lc as(

select projectmanagement_tasks.current_translator,projectmanagement_tasks.name,projectmanagement_tasks.source_language,projectmanagement_tasks.target_language,max(projectmanagement.updatedate) contact  from projectmanagement_tasks 
join projectmanagement on projectmanagement.project_id = projectmanagement_tasks.project_id
where 

projectmanagement_tasks.current_translator is not null and projectmanagement_tasks.current_translator<>''
group by current_translator,name,source_language, target_language
order by contact desc 
)
select
    `uebersetzer_sprachen`.`kundennummer` AS `kundennummer`,
    `uebersetzer_sprachen`.`kostenstelle` AS `kostenstelle`,
    `uebersetzer_sprachen`.`artikel` AS `article`,
    `a`.`code` AS `source_language`,
    `b`.`code` AS `target_language`,
    concat (
        ifnull(`uebersetzer`.`vorname`,''),
        ' ',
        ifnull(`uebersetzer`.`nachname`,''),
        ' ( ',
        `a`.`code`,
        ' - ',
        `b`.`code`,
        ')',
        ' ',
        '',
        format (ifnull(`uebersetzer_sprachen`.`preis`,0), 2),
        ' €',
        ' ',
        'zuletzt: ',
        ifnull(lc.contact,' noch nicht im Einsatz'),
        ' '
    ) AS `name`
from
    (
        (
            (
                `translator_dd_view_combined` `uebersetzer_sprachen`
                join `languagecodes` `a` on (
                    `uebersetzer_sprachen`.`source_language` = `a`.`code`
                )
            )
            join `languagecodes` `b` on (
                `uebersetzer_sprachen`.`destination_language` = `b`.`code`
            )
        )
        join `uebersetzer` on (
            (
                `uebersetzer`.`kundennummer`,
                `uebersetzer`.`kostenstelle`
            ) = (
                `uebersetzer_sprachen`.`kundennummer`,
                `uebersetzer_sprachen`.`kostenstelle`
            )
        )
        left join `lc` on (
            (
                `uebersetzer`.`kundennummer`,
                `uebersetzer`.`kostenstelle`,
                `uebersetzer_sprachen`.`artikel`,
                `a`.`code`,
                `b`.`code`
            ) = (
                `lc`.`current_translator`,
                0,
                `lc`.`name`,
                `lc`.`source_language`,
                `lc`.`target_language`
            )
        )
    )