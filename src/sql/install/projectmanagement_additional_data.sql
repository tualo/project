delimiter //


create table projectmanagement_additional_data (
    project_id	varchar(36)	primary key not null,
    cu_gross	decimal(10,2) default 0,
    cu_open	decimal(10,2) default 0,
    dl_gross	decimal(10,2) default 0,
    dl_open	decimal(10,2)   default 0,
    net_result	decimal(10,2) default 0,
    search_fld	varchar(255) default '',
    abrechnung	varchar(255) default '',
    ready_to_invoice tinyint(1) default 0,
    projectmanagement_tasks_uebersetzer_status_text    varchar(255) default '',
    report_links    varchar(255) default '',
    constraint fk_projectmanagement_additional_data_project_id foreign key (project_id) references projectmanagement (project_id)
    on delete cascade
    on update cascade
) //




CREATE or replace TRIGGER `trigger_projectmanagement_ai_additional_data` AFTER INSERT ON `projectmanagement` FOR EACH ROW
BEGIN
    insert ignore into projectmanagement_additional_data (project_id) values ( new.project_id);
END //

CREATE or replace TRIGGER `trigger_blg_hdr_rechnung_au_additional_data` AFTER UPDATE ON `blg_hdr_rechnung` FOR EACH ROW
BEGIN
    update 
        projectmanagement_additional_data 
    set 
        cu_gross = new.brutto,
        cu_open = new.offen
    where project_id = new.project_id;
END //


CREATE or replace TRIGGER `trigger_blg_hdr_rechnung_au_additional_data` AFTER UPDATE ON `blg_hdr_krechnung` FOR EACH ROW
BEGIN
    update 
        projectmanagement_additional_data 
    set 
        dl_gross = new.brutto,
        dl_open = new.offen
    where project_id = new.project_id;
END //


CREATE or replace TRIGGER `trigger_projectmanagement_additional_data_bu_net_result` BEFORE UPDATE ON `projectmanagement_additional_data` FOR EACH ROW
BEGIN
    set new.net_result = new.cu_gross - new.dl_gross;
END //

CREATE or replace TRIGGER `trigger_projectmanagement_au_additional_data` AFTER UPDATE ON `projectmanagement` FOR EACH ROW
BEGIN
    declare ready tinyint(1) default 0;
    DECLARE use_sql longtext;

    
    select
        1
    into ready
    from
        `projectmanagement_tasks`
    where
        `projectmanagement_tasks`.`state` in(
            select
                `projectmanagement_states`.`id`
            from
                `projectmanagement_states`
            where
                `projectmanagement_states`.`select_for_report` = 1
        )
        and `projectmanagement_tasks`.`project_id` = new.project_id
    limit 1;

    set use_sql=concat('update 
        projectmanagement_additional_data 
    set 
        report_links = ',quote(if(
        if(
            new.`invoice_id` = 0,
             new.`offer_id`,
             new.`invoice_id`
        ) = 0,
        '',
        concat(
            '<a href="./remote/pdf/view_blg_list_rechnung/report_template/',
            if(
                 new.`invoice_id` = 0,
                 new.`offer_id`,
                 new.`invoice_id`
            ),
            '" target="_blank">',
            'Rechnung',
            '</a> | ',
            '<a href="./remote/pdf/view_blg_list_rechnung/report_pol/',
            if(
                 new.`invoice_id` = 0,
                 new.`offer_id`,
                 new.`invoice_id`
            ),
            '" target="_blank">',
            'Pol. RN',
            '</a>'
        )
    )),', ready_to_invoice = ',ready,'
    where project_id = ',quote(new.project_id),'');

    

    insert into deferred_sql_tasks (taskid,sessionuser     ,hostname  ,sqlstatement) values  (uuid(),getsessionuser(),@@hostname,use_sql );
    

END //
