CREATE OR REPLACE PROCEDURE `convertAllSubProject2Bill`(
    in use_project_id varchar(36),
    in use_ids json, 
    out report json)
BEGIN
DECLARE rpt JSON;
SET rpt = (
        select convertAllSubProject(use_project_id,use_ids)
    );
call setReport('rechnung', rpt, report);
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
set invoice_id = json_value(report, '$.id')
where project_id = r.project_id;
end for;
END


CREATE OR REPLACE PROCEDURE `convertDL`(
    in use_project_id varchar(36),
    in use_ids json, 
    out report json)
BEGIN
DECLARE rpt JSON;
SET rpt = (
        select convertDLProject(use_project_id,use_ids)
    );
call setReport('gutschrift', rpt, report);
/*
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
set invoice_id = json_value(report, '$.id')
where project_id = r.project_id;
end for;
*/
END