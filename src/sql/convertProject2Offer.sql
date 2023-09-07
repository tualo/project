DELIMITER //




CREATE OR REPLACE PROCEDURE `convertProject2Offer`(in use_project_id varchar(36),out report json)
BEGIN 
    DECLARE positions JSON;


    select 

        json_object(
            "article", projectmanagement_tasks.product,
            "source_language", projectmanagement_tasks.source_language,
            "target_language", projectmanagement_tasks.target_language,
            "position", 1,
            "account", '8400',
            "amount", projectmanagement_tasks.product_amount,
            "project_name", projectmanagement.name,
            "project_id", projectmanagement.project_id,
            "notes", projectmanagement_tasks.description,
            "additionaltext", "",
            "singleprice", projectmanagement_tasks.product_price,
            "tax", 19,
            "net", projectmanagement_tasks.product_amount * projectmanagement_tasks.product_price,
            "taxvalue", 1.19*(projectmanagement_tasks.product_amount * projectmanagement_tasks.product_price) - (projectmanagement_tasks.product_amount * projectmanagement_tasks.product_price),
            "gross", 1.19*(projectmanagement_tasks.product_amount * projectmanagement_tasks.product_price)
        ) c
    INTO positions

    from projectmanagement_tasks
    join projectmanagement
    on projectmanagement_tasks.project_id = projectmanagement.project_id
    where projectmanagement.project_id = use_project_id 
    and projectmanagement_tasks.product_amount<>0;

    select
        json_object(
            "date", cast(now() as date),
            "bookingdate",  cast(now() as date),
            "buchungsdatum", cast(now() as date),
            "service_period_start", cast(now() as date),
            "service_period_stop", cast(now() as date),
            "address", view_editor_relation_angebot.address,
            "time", cast(now() as time),
            "warehouse", 0,
            "referencenr", projectmanagement.kundennummer,
            "reference", projectmanagement.name,
            "costcenter", 0,
            "address", use_address,
            "project_name", projectmanagement.name,
            "project_id", projectmanagement.project_id,
            "companycode", "0000",
            "office", 1,
            "positions", positions
        )
    INTO @report
    FROM projectmanagement
    join view_editor_relation_angebot
    on view_editor_relation_angebot.referencenr = projectmanagement.kundennummer
    WHERE projectmanagement.project_id = use_project_id;
            select @report;
            call setReport('angebot',@report,report);
            update projectmanagement set offer_id = json_value(report,'$.id') where project_id = use_project_id;

END