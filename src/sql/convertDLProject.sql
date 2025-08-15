CREATE or replace FUNCTION `convertDLProject`(use_project_id varchar(36),
    use_ids json
) RETURNS longtext CHARSET utf8mb4 COLLATE utf8mb4_bin
    DETERMINISTIC
BEGIN
    DECLARE positions JSON;
    DECLARE sub_positions JSON;
    DECLARE sv_start date default '2099-12-31';
    DECLARE sv_stop date  default '1999-01-01';
    DECLARE total_net decimal(15,6) default 0;
    DECLARE net decimal(15,6) default 0;
    DECLARE target_dt date;
    
    declare result json default json_object();
    
    

    IF (select count(*) from projectmanagement where project_id = use_project_id) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Project not found';
    END IF;

     set use_ids = JSON_ARRAY_APPEND(use_ids, '$', use_project_id);


select 
       
       json_arrayagg( json_object(
                    "article", projectmanagement_tasks.article,
                    "source_language", projectmanagement_tasks.source_language,
                    "target_language", projectmanagement_tasks.target_language,
                    "position", 1,
                    "account", '8400',
                    "amount", ifnull(projectmanagement_tasks.translated_rows, 1),
                    "project_name", projectmanagement.name,
                    "vdatum", projectmanagement.target_date,
                    "project_id", projectmanagement.project_id,
                    "notes", projectmanagement_tasks.description,
                    "unit", projectmanagement_tasks.unit,
                    "einheit", projectmanagement_tasks.unit,
                    "additionaltext", "",
                    "singleprice", projectmanagement_tasks.tr_offer_value / ifnull(projectmanagement_tasks.translated_rows, 1),
                    "tax", getArticleTaxRate('normalbesteuert',curdate(),projectmanagement_tasks.article),
                    "net", projectmanagement_tasks.tr_offer_value,
                    "taxvalue", (1 + getArticleTaxRate('normalbesteuert',curdate(),projectmanagement_tasks.article)/100 )*(projectmanagement_tasks.tr_offer_value) - (projectmanagement_tasks.tr_offer_value),
                    "gross",  (1 + getArticleTaxRate('normalbesteuert',curdate(),projectmanagement_tasks.article)/100 )*(projectmanagement_tasks.tr_offer_value),
                    "brutto",  (1 + getArticleTaxRate('normalbesteuert',curdate(),projectmanagement_tasks.article)/100 )*(projectmanagement_tasks.tr_offer_value)
                )
        ) c,
        min(target_date) as sv_start,
        max(target_date) as sv_stop,
        sum(projectmanagement_tasks.tr_offer_value) as total_netto

    INTO 
        positions,
        sv_start,
        sv_stop,
        total_net

 
    from 

        (SELECT 
            distinct 
            project_id
        FROM 
        JSON_TABLE(
            use_ids,
            '$[*]'
            COLUMNS(
                project_id VARCHAR(36) PATH '$'
            )
        ) as x ) AS jt
        join projectmanagement_tasks
            on jt.project_id = projectmanagement_tasks.project_id
        join projectmanagement
            on projectmanagement_tasks.project_id = projectmanagement.project_id
            and projectmanagement_tasks.current_translator is not null
    where 
        projectmanagement.state <> '90000'
        and projectmanagement_tasks.amount<>0
        and projectmanagement_tasks.translated_rows <> 0
        -- and projectmanagement.invoice_id = 0 
        ;
    
    select
        json_object(
            "date", cast(now() as date),
            "bookingdate",  cast(now() as date),
            "buchungsdatum", cast(now() as date),
            "service_period_start", sv_start,
            "service_period_stop", sv_stop,
            "address", view_editor_relation_gs.address,
            "time", cast(now() as time),
            "warehouse", 0,
            "tabellenzusatz", "gs",
            "referencenr", projectmanagement.uebersetzer,
            "reference", projectmanagement.name,
            "costcenter", 0,
            "project_name", projectmanagement.name,
            "project_id", projectmanagement.project_id,
            "companycode", "0000",
            "kindofbill", "netto",
            "texts", json_array(),
            "office", 1,
            "positions", json_merge('[]',positions),
            "report_footer", json_array(),
            "report_taxes", json_array(
                json_object(
                    "text", "Netto:",
                    "wert",  concat(format (total_net, 2, 'de_DE'), ' €')
                    
                )
            )
        )
    INTO result
    FROM projectmanagement
    join view_editor_relation_gs
    on view_editor_relation_gs.referencenr = projectmanagement.uebersetzer
    WHERE projectmanagement.project_id = use_project_id;

    return result;
END