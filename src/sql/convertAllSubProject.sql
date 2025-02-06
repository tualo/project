CREATE Function `convertAllSubProject`(in use_project_id varchar(36)) returns json BEGIN
DECLARE positions JSON;
DECLARE sub_positions JSON;
DECLARE sv_start date default curdate();
DECLARE sv_stop date default '1999-01-01';
DECLARE target_dt date;
declare result json default json_object;
IF (
    select count(*)
    from projectmanagement
    where project_id = use_project_id
) = 0 THEN SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Project not found';
END IF;
select json_arrayagg(
        json_object(
            "article",
            projectmanagement_tasks.article,
            "source_language",
            projectmanagement_tasks.source_language,
            "target_language",
            projectmanagement_tasks.target_language,
            "position",
            1,
            "account",
            '8400',
            "amount",
            projectmanagement_tasks.amount,
            "project_name",
            projectmanagement.name,
            "project_id",
            projectmanagement.project_id,
            "notes",
            projectmanagement_tasks.description,
            "additionaltext",
            "",
            "singleprice",
            projectmanagement_tasks.singleprice,
            "tax",
            getArticleTaxRate(
                'normalbesteuert',
                curdate(),
                projectmanagement_tasks.article
            ),
            "net",
            projectmanagement_tasks.amount * projectmanagement_tasks.singleprice,
            "taxvalue",
            (
                1 + getArticleTaxRate(
                    'normalbesteuert',
                    curdate(),
                    projectmanagement_tasks.article
                ) / 100
            ) *(
                projectmanagement_tasks.amount * projectmanagement_tasks.singleprice
            ) - (
                projectmanagement_tasks.amount * projectmanagement_tasks.singleprice
            ),
            "gross",
            (
                1 + getArticleTaxRate(
                    'normalbesteuert',
                    curdate(),
                    projectmanagement_tasks.article
                ) / 100
            ) *(
                projectmanagement_tasks.amount * projectmanagement_tasks.singleprice
            )
        )
    ) c,
    target_date INTO positions,
    target_dt
from projectmanagement_tasks
    join projectmanagement on projectmanagement_tasks.project_id = projectmanagement.project_id
where projectmanagement.project_id = use_project_id
    and projectmanagement_tasks.amount <> 0;
set positions = json_merge('[]', positions);
IF (sv_stop < target_dt) THEN
set sv_stop = target_dt;
END IF;
IF (sv_start > target_dt) THEN
set sv_start = target_dt;
END IF;
for sub in (
    select project_id
    from projectmanagement_subproject
    where parent_project = use_project_id
) do
set sub_positions = null;
select json_arrayagg(
        json_object(
            "article",
            projectmanagement_tasks.article,
            "source_language",
            projectmanagement_tasks.source_language,
            "target_language",
            projectmanagement_tasks.target_language,
            "position",
            1,
            "account",
            '8400',
            "amount",
            projectmanagement_tasks.amount,
            "project_name",
            projectmanagement.name,
            "project_id",
            projectmanagement.project_id,
            "notes",
            projectmanagement_tasks.description,
            "additionaltext",
            "",
            "singleprice",
            projectmanagement_tasks.singleprice,
            "tax",
            getArticleTaxRate(
                'normalbesteuert',
                curdate(),
                projectmanagement_tasks.article
            ),
            "net",
            projectmanagement_tasks.amount * projectmanagement_tasks.singleprice,
            "taxvalue",
            (
                1 + getArticleTaxRate(
                    'normalbesteuert',
                    curdate(),
                    projectmanagement_tasks.article
                ) / 100
            ) *(
                projectmanagement_tasks.amount * projectmanagement_tasks.singleprice
            ) - (
                projectmanagement_tasks.amount * projectmanagement_tasks.singleprice
            ),
            "gross",
            (
                1 + getArticleTaxRate(
                    'normalbesteuert',
                    curdate(),
                    projectmanagement_tasks.article
                ) / 100
            ) *(
                projectmanagement_tasks.amount * projectmanagement_tasks.singleprice
            )
        )
    ) c,
    target_date INTO sub_positions,
    target_dt
from projectmanagement_tasks
    join projectmanagement on projectmanagement_tasks.project_id = projectmanagement.project_id
where projectmanagement.project_id = sub.project_id
    and projectmanagement_tasks.amount <> 0
    and projectmanagement.invoice_id = 0;
if sub_positions is not null then
set positions = json_merge(positions, sub_positions);
IF (sv_stop < target_dt) THEN
set sv_stop = target_dt;
END IF;
IF (sv_start > target_dt) THEN
set sv_start = target_dt;
END IF;
end if;
end for;
select json_object(
        "date",
        cast(now() as date),
        "bookingdate",
        cast(now() as date),
        "buchungsdatum",
        cast(now() as date),
        "service_period_start",
        sv_start,
        "service_period_stop",
        sv_stop,
        "address",
        view_editor_relation_rechnung.address,
        "time",
        cast(now() as time),
        "warehouse",
        0,
        "referencenr",
        projectmanagement.kundennummer,
        "reference",
        projectmanagement.name,
        "costcenter",
        0,
        "project_name",
        projectmanagement.name,
        "project_id",
        projectmanagement.project_id,
        "companycode",
        "0000",
        "office",
        1,
        "positions",
        json_merge('[]', positions)
    ) INTO result
FROM projectmanagement
    join view_editor_relation_rechnung on view_editor_relation_rechnung.referencenr = projectmanagement.kundennummer
WHERE projectmanagement.project_id = use_project_id;
return result;
END