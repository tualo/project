delimiter ;

create table if not exists projectmanagement_reminder_mail_state (
    id 	varchar(36)  not null primary key,
    name varchar(255) not null
);
insert ignore into projectmanagement_reminder_mail_state(id,name) values ('na','N/A');

create table  if not exists  projectmanagement_reminder_mail (
    
    project_id	varchar(36) not null,
    mail_to	varchar(100) not null,
    state 	varchar(36) not null default 'na',

    primary key (project_id,mail_to,state),
    constraint fk_projectmanagement_reminder_mail_project_id 
    foreign key (project_id) references projectmanagement(project_id)
    on delete cascade
    on update cascade,

    constraint fk_projectmanagement_reminder_mail_state 
    foreign key (state) references projectmanagement_reminder_mail_state(id)
    on delete cascade
    on update cascade,

    createtimestamp timestamp default current_timestamp
);



create view if not exists projectmanagement_not_reminded as  
with not_reminded as (
    select project_id,target_date from  projectmanagement
    where project_id not in (
        select project_id from projectmanagement_reminder_mail
        where state='na'
    )
    and curdate() + interval - 1 day <=  target_date
)
select not_reminded.project_id,target_date,projectmanagement_tasks.task_id from not_reminded
join projectmanagement_tasks on projectmanagement_tasks.project_id = not_reminded.project_id
and projectmanagement_tasks.name='Dolmetschen'
;
