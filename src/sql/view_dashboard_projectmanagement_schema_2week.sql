alter table projectmanagement_states add in_progress_chart tinyint default 0;
create or replace view view_dashboard_projectmanagement_schema_2week as 
select 

    projectmanagement_schema.name,
    count(projectmanagement.project_id) amount,
    sum(
        projectmanagement_tasks.amount* projectmanagement_tasks.singleprice
    ) value

from 
    projectmanagement
    join projectmanagement_schema 
        on projectmanagement_schema.id = projectmanagement.projectmanagement_schema
        and projectmanagement.createdate > curdate() + interval - 2 week
    join projectmanagement_states
        on 
            projectmanagement_states.id = projectmanagement.state
            and projectmanagement_states.in_progress_chart = 1
    join projectmanagement_tasks on
        projectmanagement_tasks.project_id = projectmanagement.project_id
group by projectmanagement_schema.name 
