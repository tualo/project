DELIMITER //




CREATE OR REPLACE PROCEDURE `convertProject2Bill`(in use_project_id varchar(36),out report json)
BEGIN 
    DECLARE positions JSON;

IF (select count(*) from projectmanagement where project_id = use_project_id) = 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Project not found';
END IF;


IF (select count(*) from projectmanagement where project_id = use_project_id and invoice_id>0) > 0 THEN
    -- SIGNAL SQLSTATE '45000'
    -- SET MESSAGE_TEXT = 'Das Projekt ist bereits abgerechnet worden';
END IF;

    select 
json_arrayagg(
        json_object(
            "article", projectmanagement_tasks.article,
            "source_language", projectmanagement_tasks.source_language,
            "target_language", projectmanagement_tasks.target_language,
            "position", 1,
            "account", '8400',
            "amount", projectmanagement_tasks.amount,
            "project_name", projectmanagement.name,
            "project_id", projectmanagement.project_id,
            "notes", projectmanagement_tasks.description,
            "additionaltext", "",
            "singleprice", projectmanagement_tasks.singleprice,
            "tax", getArticleTaxRate('normalbesteuert',curdate(),projectmanagement_tasks.article),
            "net", projectmanagement_tasks.amount * projectmanagement_tasks.singleprice,
            "taxvalue", (1 + getArticleTaxRate('normalbesteuert',curdate(),projectmanagement_tasks.article)/100 )*(projectmanagement_tasks.amount * projectmanagement_tasks.singleprice) - (projectmanagement_tasks.amount * projectmanagement_tasks.singleprice),
            "gross",  (1 + getArticleTaxRate('normalbesteuert',curdate(),projectmanagement_tasks.article)/100 )*(projectmanagement_tasks.amount * projectmanagement_tasks.singleprice)
        )
 ) c
    INTO positions

    from projectmanagement_tasks
    join projectmanagement
    on projectmanagement_tasks.project_id = projectmanagement.project_id
    where projectmanagement.project_id = use_project_id 
    and projectmanagement_tasks.amount<>0;

    select
        json_object(
            "date", cast(now() as date),
            "bookingdate",  cast(now() as date),
            "buchungsdatum", cast(now() as date),
            "service_period_start", cast(now() as date),
            "service_period_stop", cast(now() as date),
            "address", view_editor_relation_rechnung.address,
            "time", cast(now() as time),
            "warehouse", 0,
            "referencenr", projectmanagement.kundennummer,
            "reference", projectmanagement.name,
            "costcenter", 0,
            "project_name", projectmanagement.name,
            "project_id", projectmanagement.project_id,
            "companycode", "0000",
            "office", 1,
            "positions", json_merge('[]',positions)
        )
    INTO @report
    FROM projectmanagement
    join view_editor_relation_rechnung
    on view_editor_relation_rechnung.referencenr = projectmanagement.kundennummer
    WHERE projectmanagement.project_id = use_project_id;
            call setReport('rechnung',@report,report);
            -- update projectmanagement set offer_id = json_value(report,'$.id') where project_id = use_project_id;
            update projectmanagement set invoice_id = json_value(report,'$.id') where project_id = use_project_id;

END