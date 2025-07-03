CREATE OR REPLACE FUNCTION `convertAllSubProject`(
    use_project_id varchar(36),
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
                    "vdatum", projectmanagement.target_date,
                    "project_id", projectmanagement.project_id,
                    "notes", projectmanagement_tasks.description,
                    "unit", projectmanagement_tasks.unit,
                    "einheit", projectmanagement_tasks.unit,
                    "additionaltext", "",
                    "singleprice", projectmanagement_tasks.singleprice,
                    "tax", getArticleTaxRate('normalbesteuert',curdate(),projectmanagement_tasks.article),
                    "net", projectmanagement_tasks.amount * projectmanagement_tasks.singleprice,
                    "taxvalue", (1 + getArticleTaxRate('normalbesteuert',curdate(),projectmanagement_tasks.article)/100 )*(projectmanagement_tasks.amount * projectmanagement_tasks.singleprice) - (projectmanagement_tasks.amount * projectmanagement_tasks.singleprice),
                    "gross",  (1 + getArticleTaxRate('normalbesteuert',curdate(),projectmanagement_tasks.article)/100 )*(projectmanagement_tasks.amount * projectmanagement_tasks.singleprice)
                )
        ) c,
        target_date,
        sum(projectmanagement_tasks.amount * projectmanagement_tasks.singleprice) as total_netto

    INTO 
        positions,
        target_dt,
        net

    from projectmanagement_tasks
        join projectmanagement
            on projectmanagement_tasks.project_id = projectmanagement.project_id
    where 
        projectmanagement.project_id = use_project_id 
        and projectmanagement.state <> '90000'
        and projectmanagement_tasks.amount<>0
        and projectmanagement.invoice_id = 0
        and (
            JSON_LENGTH(use_ids) = 0
            or
            locate(projectmanagement.project_id,use_ids)>0
        )
    ;

    if positions is not null then

        set positions = json_merge('[]',positions);
        set total_net = total_net + net;

        IF (sv_stop<target_dt) THEN 
            set sv_stop = target_dt;
        END IF;
        IF (sv_start>target_dt) THEN 
            set sv_start = target_dt;
        END IF;
    else
            set positions = '[]';
    end if;
            



    for sub in ( 


        with recursive cte as (
    select projectmanagement.target_date,projectmanagement.name,projectmanagement_subproject.project_id,projectmanagement_subproject.parent_project, LPAD('root',36,'.')  state from 
        projectmanagement_subproject join projectmanagement on projectmanagement_subproject.project_id = projectmanagement.project_id 
    union 
    select projectmanagement.target_date,projectmanagement.name,projectmanagement_subproject.project_id, cte.parent_project ,projectmanagement_subproject.parent_project state from projectmanagement_subproject   join projectmanagement on projectmanagement_subproject.project_id = projectmanagement.project_id 
        join cte on cte.project_id = projectmanagement_subproject.parent_project



)
select * from cte  where parent_project = use_project_id
order by target_date,name

) do
    
        set sub_positions = null;
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
                        "unit", projectmanagement_tasks.unit,
                        "einheit", projectmanagement_tasks.unit,
                        "additionaltext", "",
                        "singleprice", projectmanagement_tasks.singleprice,
                        "vdatum", projectmanagement.target_date,
                        "tax", getArticleTaxRate('normalbesteuert',curdate(),projectmanagement_tasks.article),
                        "net", projectmanagement_tasks.amount * projectmanagement_tasks.singleprice,
                        "taxvalue", (1 + getArticleTaxRate('normalbesteuert',curdate(),projectmanagement_tasks.article)/100 )*(projectmanagement_tasks.amount * projectmanagement_tasks.singleprice) - (projectmanagement_tasks.amount * projectmanagement_tasks.singleprice),
                        "gross",  (1 + getArticleTaxRate('normalbesteuert',curdate(),projectmanagement_tasks.article)/100 )*(projectmanagement_tasks.amount * projectmanagement_tasks.singleprice)
                    )
            ) c,
            target_date,
            sum(projectmanagement_tasks.amount * projectmanagement_tasks.singleprice) as total_netto
        INTO sub_positions,
            target_dt,
            net

        from projectmanagement_tasks
            join projectmanagement
                on projectmanagement_tasks.project_id = projectmanagement.project_id
        where 
            projectmanagement.project_id = sub.project_id 
            and projectmanagement.state <> '90000'
            and projectmanagement_tasks.amount<>0
            and projectmanagement.invoice_id = 0
            
            
            
            and (
                JSON_LENGTH(use_ids) = 0
                or
                locate(projectmanagement.project_id,use_ids)>0
            )
            
        ;

        if sub_positions is not null then
            set positions = json_merge(positions,sub_positions);
            set total_net = total_net + net;
            IF (sv_stop<target_dt) THEN 
                set sv_stop = target_dt;
            END IF;
            IF (sv_start>target_dt) THEN 
                set sv_start = target_dt;
            END IF;
            
        end if;

    end for;

    select
        json_object(
            "date", cast(now() as date),
            "bookingdate",  cast(now() as date),
            "buchungsdatum", cast(now() as date),
            "service_period_start", sv_start,
            "service_period_stop", sv_stop,
            "address", view_editor_relation_rechnung.address,
            "time", cast(now() as time),
            "warehouse", 0,
            "tabellenzusatz", "preview",
            "referencenr", projectmanagement.kundennummer,
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
    join view_editor_relation_rechnung
    on view_editor_relation_rechnung.referencenr = projectmanagement.kundennummer
    WHERE projectmanagement.project_id = use_project_id;

    return result;
END