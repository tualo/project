CREATE
OR REPLACE VIEW `view_selective_project_preview_uebersetzer` AS

select
    `x`.`uebersetzer` AS `sel`,
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
    projectmanagement `x` join view_readtable_uebersetzer u on (
        `x`.`uebersetzer` = `u`.`kundennummer`
    )
    
    and projectmanagement.state in ('20010',

    '20011',
    '30090',
    '200')