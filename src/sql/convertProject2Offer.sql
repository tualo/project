DELIMITER //




CREATE OR REPLACE PROCEDURE `convertProject2Offer`(in use_project_id varchar(36),out report json)
BEGIN 
    DECLARE positions JSON;


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
            "tax", 19,
            "net", projectmanagement_tasks.amount * projectmanagement_tasks.singleprice,
            "taxvalue", 1.19*(projectmanagement_tasks.amount * projectmanagement_tasks.singleprice) - (projectmanagement_tasks.amount * projectmanagement_tasks.singleprice),
            "gross", 1.19*(projectmanagement_tasks.amount * projectmanagement_tasks.singleprice)
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
            "address", view_editor_relation_angebot.address,
            "time", cast(now() as time),
            "warehouse", 0,
            "referencenr", projectmanagement.kundennummer,
            "reference", projectmanagement.client_order_id,
            "costcenter", 0,
            "project_name", projectmanagement.name,
            "project_id", projectmanagement.project_id,
            "companycode", "0000",
            "office", 1,
            "positions", json_merge('[]',positions)
        )
    INTO @report
    FROM projectmanagement
    join view_editor_relation_angebot
    on view_editor_relation_angebot.referencenr = projectmanagement.kundennummer
    WHERE projectmanagement.project_id = use_project_id;
            select @report;
            call setReport('angebot',@report,report);
            update projectmanagement set offer_id = json_value(report,'$.id') where project_id = use_project_id;

END //


CREATE OR REPLACE PROCEDURE `convertAllSubProject2Offer`(in use_project_id varchar(36), out report json) BEGIN
DECLARE rpt JSON;
SET rpt = (
        select convertAllSubProjectOffer(use_project_id)
    );
call setReport('angebot', rpt, report);
for r in (
    select project_id
    from JSON_TABLE(
            rpt,
            '$.positions[*]' COLUMNS (
                `project_id` varchar(128) path '$.project_id'
            )
        ) as jtx
) do
update projectmanagement
set offer_id = json_value(report, '$.id')
where project_id = r.project_id;
end for;
END //