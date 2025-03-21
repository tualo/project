explain 
with
    dlrn as(
        select
            `view_readtable_projectmanagement_dokumente_abrechnung`.`id` AS `id`,
            `view_readtable_projectmanagement_dokumente_abrechnung`.`project_id` AS `project_id`,
            sum(
                `view_readtable_projectmanagement_dokumente_abrechnung`.`open`
            ) AS `open`,
            sum(
                `view_readtable_projectmanagement_dokumente_abrechnung`.`net`
            ) AS `net`,
            sum(
                `view_readtable_projectmanagement_dokumente_abrechnung`.`gross`
            ) AS `gross`
        from
            `view_readtable_projectmanagement_dokumente_abrechnung`
        group by
            `view_readtable_projectmanagement_dokumente_abrechnung`.`project_id`
    ),
    gtasks as ( 

        select
                    `projectmanagement_tasks`.`project_id` AS `project_id`,
                    '' projectmanagement_tasks_uebersetzer_status_text
                from
                    `projectmanagement_tasks`
                where
                    `projectmanagement_tasks`.`state` in(
                        select
                            `projectmanagement_states`.`id`
                        from
                            `projectmanagement_states`
                        where
                            `projectmanagement_states`.`select_for_report` = 1
                    )
                group by
                    `projectmanagement_tasks`.`project_id`
    )


ifnull(`blg_hdr_rechnung`.`brutto`, 0) AS `cu_gross`,
ifnull(`blg_hdr_rechnung`.`offen`, 0) AS `cu_open`,
ifnull(`dlrn`.`gross`, 0) AS `dl_gross`,
ifnull(`dlrn`.`open`, 0) AS `dl_open`,
ifnull(`blg_hdr_rechnung`.`netto`, 0) - ifnull(`dlrn`.`net`, 0) AS `net_result`,

create table projectmanagement_additional_data as 
(
    project_id	varchar(36)	primary key,
    cu_gross	decimal(10,2) default 0,
    cu_open	decimal(10,2) default 0,
    dl_gross	decimal(10,2) default 0,
    dl_open	decimal(10,2)   default 0,
    net_result	decimal(10,2) default 0,
    search_fld	varchar(255) default '',
    abrechnung	varchar(255) default '',
    projectmanagement_tasks_uebersetzer_status_text    varchar(255) default '',
    report_links    varchar(255) default '',
    name	varchar(255) default ''
)



CREATE or replace TRIGGER `trigger_projectmanagement_ai_additional_data` AFTER INSERT ON `projectmanagement` FOR EACH ROW
BEGIN
    insert ignore into projectmanagement_additional_data (project_id) values ( new.project_id);
END //

CREATE or replace TRIGGER `trigger_blg_hdr_rechnung_au_additional_data` AFTER UPDATE ON `blg_hdr_rechnung` FOR EACH ROW
BEGIN
    update 
        projectmanagement_additional_data 
    set 
        cu_gross = new.brutto,
        cu_open = new.offen,
        net_result = new.netto - ifnull(`dlrn`.`net`, 0)
    where project_id = new.project_id;
END //

CREATE or replace TRIGGER `trigger_projectmanagement_additional_data_bu_net_result` BEFORE UPDATE ON `projectmanagement_additional_data` FOR EACH ROW
BEGIN
    update 
        projectmanagement_additional_data
    set
        net_result = new.cu_gross - new.dl_gross
    where project_id = new.project_id;
END //

CREATE or replace TRIGGER `trigger_projectmanagement_au_additional_data` AFTER UPDATE ON `projectmanagement` FOR EACH ROW
BEGIN
    update 
        projectmanagement_additional_data 
    set 
        report_links = if(
        if(
            `projectmanagement`.`invoice_id` = 0,
            `projectmanagement`.`offer_id`,
            `projectmanagement`.`invoice_id`
        ) = 0,
        '',
        concat(
            '<a href="./remote/pdf/view_blg_list_rechnung/report_template/',
            if(
                `projectmanagement`.`invoice_id` = 0,
                `projectmanagement`.`offer_id`,
                `projectmanagement`.`invoice_id`
            ),
            '" target="_blank">',
            'Rechnung',
            '</a> | ',
            '<a href="./remote/pdf/view_blg_list_rechnung/report_pol/',
            if(
                `projectmanagement`.`invoice_id` = 0,
                `projectmanagement`.`offer_id`,
                `projectmanagement`.`invoice_id`
            ),
            '" target="_blank">',
            'Pol. RN',
            '</a>'
        )
    ),
    where new.project_id;
END //


select
    concat('', `projectmanagement`.`name`, '') AS `link_feld`,
    `projectmanagement`.`project_id` AS `project_id`,
    
    ifnull(`blg_hdr_rechnung`.`brutto`, 0) AS `cu_gross`,
    ifnull(`blg_hdr_rechnung`.`offen`, 0) AS `cu_open`,
    ifnull(`dlrn`.`gross`, 0) AS `dl_gross`,
    ifnull(`dlrn`.`open`, 0) AS `dl_open`,
    ifnull(`blg_hdr_rechnung`.`netto`, 0) - ifnull(`dlrn`.`net`, 0) AS `net_result`,

    concat(
        '',
        `projectmanagement`.`name`,
        ' ',
        `projectmanagement`.`client_order_id`,
        ' ',
        replace(`projectmanagement`.`client_order_id`, ' ', '')
    ) AS `search_fld`,

    if(
        `projectmanagement`.`invoice_id` <> 0,
        'abgerechnet',
        ''
    ) AS `abrechnung`,

    `projectmanagement`.`name` AS `name`,
    `projectmanagement`.`description` AS `description`,
    `projectmanagement`.`state` AS `state`,
    `projectmanagement`.`createdate` AS `createdate`,
    `projectmanagement`.`updatedate` AS `updatedate`,
    `projectmanagement`.`offer_id` AS `offer_id`,
    `projectmanagement`.`invoice_id` AS `invoice_id`,
    `projectmanagement`.`client_order_id` AS `client_order_id`,
    `projectmanagement`.`client_order_date` AS `client_order_date`,
    `projectmanagement`.`project_folder` AS `project_folder`,
    `projectmanagement`.`source_language` AS `source_language`,
    `projectmanagement`.`kundennummer` AS `kundennummer`,
    `projectmanagement`.`kostenstelle` AS `kostenstelle`,
    `projectmanagement`.`projectmanagement_schema` AS `projectmanagement_schema`,
    `projectmanagement`.`target_date` AS `target_date`,
    `projectmanagement`.`target_time` AS `target_time`,
    `projectmanagement`.`target_language` AS `target_language`,
    `projectmanagement`.`uebersetzer` AS `uebersetzer`,
    `projectmanagement`.`copies` AS `copies`,
    `projectmanagement`.`dl_post` AS `dl_post`,
    `projectmanagement`.`ansprechpartner` AS `ansprechpartner`,
    `getSessionUserFullName`() AS `service_member_name`,
    `projectmanagement`.`tr_offer_required` AS `tr_offer_required`,
    if(
        `projectmanagement`.`target_date` > curdate()
        and `rle`.`project_id` is not null,
        1 = 1,
        0 = 1
    ) AS `ready_to_invoice`,
    if(
        `projectmanagement`.`target_date` = curdate(),
        'heute',
        '-'
    ) AS `target_date_str`,
    `rle`.`projectmanagement_tasks_uebersetzer_status_text` AS `projectmanagement_tasks_uebersetzer_status_text`,
    'view_projectmanagement_faxinfo' AS `__sendfax_info`,
    'fax_anreisegenehmigung' AS `__sendfax_template`,
    'project_id' AS `__sendfax_filterfields`,
    if(
        if(
            `projectmanagement`.`invoice_id` = 0,
            `projectmanagement`.`offer_id`,
            `projectmanagement`.`invoice_id`
        ) = 0,
        '',
        concat(
            '<a href="./remote/pdf/view_blg_list_rechnung/report_template/',
            if(
                `projectmanagement`.`invoice_id` = 0,
                `projectmanagement`.`offer_id`,
                `projectmanagement`.`invoice_id`
            ),
            '" target="_blank">',
            'Rechnung',
            '</a> | ',
            '<a href="./remote/pdf/view_blg_list_rechnung/report_pol/',
            if(
                `projectmanagement`.`invoice_id` = 0,
                `projectmanagement`.`offer_id`,
                `projectmanagement`.`invoice_id`
            ),
            '" target="_blank">',
            'Pol. RN',
            '</a>'
        )
    ) AS `report_links`
from
   (
       (
           (
               (
                    `projectmanagement`
                    left join `blg_hdr_rechnung` on(
                        `projectmanagement`.`invoice_id` = `blg_hdr_rechnung`.`id`
                    )
                )
                left join `dlrn` on(
                    `dlrn`.`project_id` = `projectmanagement`.`project_id`
                )
            )
            left join gtasks `rle` on(
                `projectmanagement`.`project_id` = `rle`.`project_id`
            )
        )
    )
group by
    `projectmanagement`.`project_id`