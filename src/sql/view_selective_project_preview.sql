CREATE
OR REPLACE VIEW `view_selective_project_preview` AS
with
    list as (
        select
            `projectmanagement_subproject`.`project_id` AS `project_id`,
            `projectmanagement_subproject`.`parent_project` AS `parent_project`,
            `projectmanagement_subproject`.`parent_project` AS `sel`
        from
            `projectmanagement_subproject`
    ),
    list2 as (
        select
            `b`.`project_id` AS `project_id`,
            `a`.`parent_project` AS `parent_project`,
            `a`.`project_id` AS `sel`
        from
            (
                `projectmanagement_subproject` `a`
                join `projectmanagement_subproject` `b` on (`a`.`parent_project` = `b`.`parent_project`)
            )
        union
        select
            `b`.`parent_project` AS `parent_project`,
            `a`.`parent_project` AS `parent_project`,
            `a`.`project_id` AS `sel`
        from
            (
                `projectmanagement_subproject` `a`
                join `projectmanagement_subproject` `b` on (`a`.`parent_project` = `b`.`parent_project`)
            )
    ),
    x as (
        select
            `l`.`sel` AS `sel`,
            `projectmanagement`.`project_id` AS `project_id`,
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
            `projectmanagement`.`tr_offer_required` AS `tr_offer_required`,
            `projectmanagement`.`copies` AS `copies`,
            `projectmanagement`.`dl_post` AS `dl_post`,
            `projectmanagement`.`ansprechpartner` AS `ansprechpartner`
        from
            (
                `projectmanagement`
                join `list` `l` on (
                    `projectmanagement`.`project_id` = `l`.`project_id`
                )
            )
        union
        select
            `l`.`sel` AS `sel`,
            `projectmanagement`.`project_id` AS `project_id`,
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
            `projectmanagement`.`tr_offer_required` AS `tr_offer_required`,
            `projectmanagement`.`copies` AS `copies`,
            `projectmanagement`.`dl_post` AS `dl_post`,
            `projectmanagement`.`ansprechpartner` AS `ansprechpartner`
        from
            (
                `projectmanagement`
                join `list2` `l` on (
                    `projectmanagement`.`project_id` = `l`.`project_id`
                )
            )
        union
        select
            `projectmanagement`.`project_id` AS `sel`,
            `projectmanagement`.`project_id` AS `project_id`,
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
            `projectmanagement`.`tr_offer_required` AS `tr_offer_required`,
            `projectmanagement`.`copies` AS `copies`,
            `projectmanagement`.`dl_post` AS `dl_post`,
            `projectmanagement`.`ansprechpartner` AS `ansprechpartner`
        from
            `projectmanagement`
        where
            `projectmanagement`.`project_folder` = ''
    )
select
    `x`.`sel` AS `sel`,
    `x`.`project_id` AS `project_id`,
    `x`.`name` AS `name`,
    `x`.`state` AS `state`,
    `x`.`createdate` AS `createdate`,
    `x`.`updatedate` AS `updatedate`,
    `x`.`offer_id` AS `offer_id`,
    `x`.`invoice_id` AS `invoice_id`,
    `x`.`client_order_id` AS `client_order_id`,
    `x`.`client_order_date` AS `client_order_date`,
    `x`.`project_folder` AS `project_folder`,
    `x`.`source_language` AS `source_language`,
    `x`.`kundennummer` AS `kundennummer`,
    `x`.`kostenstelle` AS `kostenstelle`,
    `x`.`projectmanagement_schema` AS `projectmanagement_schema`,
    `x`.`target_date` AS `target_date`,
    `x`.`target_time` AS `target_time`,
    `x`.`target_language` AS `target_language`,
    `x`.`uebersetzer` AS `uebersetzer`,
    `u`.`anzeige_name` AS `description`,
    `x`.`tr_offer_required` AS `tr_offer_required`,
    `x`.`copies` AS `copies`,
    `x`.`dl_post` AS `dl_post`,
    `x`.`ansprechpartner` AS `ansprechpartner`
from
    `x` join view_readtable_uebersetzer u on (
        `x`.`uebersetzer` = `u`.`kundennummer`
    )