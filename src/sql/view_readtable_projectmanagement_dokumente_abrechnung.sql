alter table projectmanagement_dokumente
add iban varchar(35) default null;
alter table projectmanagement_dokumente
add bic varchar(35) default null;

CREATE OR REPLACE  VIEW `view_readtable_projectmanagement_dokumente_abrechnung` AS
select ifnull(`a`.`report_id`, -1) AS `id`,
    `a`.`pid` AS `pid`,
    if(
        `df`.`type` = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        or `df`.`type` = 'application/msword',
        concat(
            './dsfilesconvert/projectmanagement_dokumente/',
            `projectmanagement_dokumente`.`file_id`
        ),
        concat(
            './dsfilesdirect/projectmanagement_dokumente/',
            `projectmanagement_dokumente`.`file_id`
        )
    ) AS `imgurl`,
    `projectmanagement_dokumente`.`file_id` AS `file_id`,
    concat(
        '<a href="./dsfilesdirect/projectmanagement_dokumente/',
        `projectmanagement_dokumente`.`file_id`,
        '" target="_blank">',
        `df`.`name`,
        '</a>'
    ) AS `file_link`,
    `projectmanagement_dokumente`.`project_id` AS `project_id`,
    `projectmanagement_dokumente`.`typ` AS `typ`,
    ifnull(`a`.`report_id`, -1) AS `report_id`,
    ifnull(`blg_hdr_krechnung`.`netto`, 0) AS `net`,
    ifnull(`blg_hdr_krechnung`.`brutto`, 0) AS `gross`,
    ifnull(`blg_hdr_krechnung`.`offen`, 0) AS `open`,
    `df`.`name` AS `datei`,
    `df`.`type` AS `type`,
    `uebersetzer`.`kundennummer` AS `kundennummer`,
    `uebersetzer`.`kostenstelle` AS `kostenstelle`,
    ifnull(`a`.`iban`, `uebersetzer`.`iban`) AS `iban`,
    ifnull(`a`.`bic`, `uebersetzer`.`bic`) AS `bic`,
    'krechnung' AS `tabellenzusatz`,
    `projectmanagement`.`name` AS `projectmanagement_name`,
    ifnull(`a`.`report_id`, -1) AS `belegnummer`,
    concat(
        './pugreporthtml/GiroCode/report_template/110885',
        `projectmanagement_dokumente`.`id`
    ) AS `girocode`,
    concat_ws(
        ' ',
        ifnull(`uebersetzer`.`firma`, ''),
        ifnull(`uebersetzer`.`nachname`, ''),
        ', ',
        ifnull(`uebersetzer`.`vorname`, '')
    ) AS `gironame`,
    ifnull(`a`.`angewiesen`, 0) AS `angewiesen1`
from (
        (
            (
                (
                    (
                        `projectmanagement_dokumente`
                        join `ds_files` `df` on(
                            `projectmanagement_dokumente`.`file_id` = `df`.`file_id`
                        )
                    )
                    join `projectmanagement` on(
                        `projectmanagement`.`project_id` = `projectmanagement_dokumente`.`project_id`
                    )
                )
                left join `uebersetzer` on(
                    `projectmanagement`.`uebersetzer` = `uebersetzer`.`kundennummer`
                )
            )
            left join `projectmanagement_dokumente_abrechnung` `a` on(
                `projectmanagement_dokumente`.`file_id` = `a`.`file_id`
            )
        )
        left join `blg_hdr_krechnung` on(`a`.`report_id` = `blg_hdr_krechnung`.`id`)
    )
where `projectmanagement_dokumente`.`typ` = 'invoice'