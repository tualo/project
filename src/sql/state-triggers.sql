DELIMITER //

CREATE OR REPLACE PROCEDURE `proc_projectmanagement_state`(in in_project_id varchar(36),in in_task_id varchar(36))
    MODIFIES SQL DATA
BEGIN
    DECLARE current_projectmanagement_schema varchar(36) default null;
    -- DECLARE current_projectmanagement_state varchar(36) default null;
    DECLARE current_projectmanagement_source_document varchar(36) default null;
    DECLARE current_projectmanagement_charge_document varchar(36) default null;
    

    DECLARE old_projectmanagement_state varchar(36) default null;
    DECLARE new_projectmanagement_state varchar(36) default null;
    DECLARE next_projectmanagement_state varchar(36) default null;

    DECLARE use_row_current boolean default false;

    DECLARE tr_request_accepted tinyint default 0;
    DECLARE tr_request_rejected tinyint default 0;


    DECLARE tr_offer_accepted tinyint default 0;
    DECLARE tr_offer_rejected tinyint default 0;


    DECLARE is_private tinyint default 1;
    DECLARE sql_command longtext;
    

    select 
        (projectmanagement.ROW_END>now()) row_current,
        FIRST_VALUE(projectmanagement.state) OVER (
                partition by projectmanagement.project_id 
                ORDER BY projectmanagement.ROW_START ROWS BETWEEN 1 PRECEDING  AND  CURRENT ROW
        ) lv,
        projectmanagement.state,
        projectmanagement.projectmanagement_schema
    into 
        use_row_current,
        old_projectmanagement_state,
        new_projectmanagement_state,
        current_projectmanagement_schema
    from 
        projectmanagement for system_time all 
    where 
        projectmanagement.project_id = in_project_id
    having 
        row_current = 1
    ;
    

    select 
        id 
    into 
        current_projectmanagement_source_document
    from 
        projectmanagement_dokumente 
    where 
        project_id = in_project_id 
        and typ = 'original'
    ;

    select 
        id 
    into 
        current_projectmanagement_charge_document
    from 
        projectmanagement_dokumente 
    where 
        project_id = in_project_id 
        and typ = 'charge'
    ;



    select 
        projectmanagement_tasks.tr_request_accepted,
        projectmanagement_tasks.tr_request_rejected,

        projectmanagement_tasks.tr_offer_accepted,
        projectmanagement_tasks.tr_offer_rejected 
    into 
        tr_request_accepted,
        tr_request_rejected,

        tr_offer_accepted,
        tr_offer_rejected
    from 
        projectmanagement_tasks 
    where 
        projectmanagement_tasks.project_id = in_project_id 
        and projectmanagement_tasks.task_id = in_task_id 
    ;



    if (current_projectmanagement_schema = 'f996a8ea-4d67-11ee-b94d-002590c4e7c6') then

        if (new_projectmanagement_state = '0' and current_projectmanagement_source_document is null  ) then
            set next_projectmanagement_state = '20001';
        end if;

        if (new_projectmanagement_state = '20001' and current_projectmanagement_source_document is not null  ) then
            set next_projectmanagement_state = '20002';
        end if;

        if (new_projectmanagement_state = '20003' and tr_request_rejected = 1  ) then
            set next_projectmanagement_state = '20002';
        end if;

        if (new_projectmanagement_state = '20003' and tr_request_accepted = 1  ) then
            set next_projectmanagement_state = '20004';
        end if;

        if (new_projectmanagement_state = '20004' and tr_offer_accepted = 1  ) then
            set next_projectmanagement_state = '20005';
        end if;

    elseif (current_projectmanagement_schema = '7b5ccd29-4d68-11ee-bb38-002590c72640') then

        
        if (new_projectmanagement_state = '0' and current_projectmanagement_charge_document is null  ) then
            set next_projectmanagement_state = '30002';
        end if;

        if (new_projectmanagement_state = '30002' and current_projectmanagement_charge_document is not null  ) then
            set next_projectmanagement_state = '30003';
        end if;


    end if;


    if (next_projectmanagement_state is not null) then
        set sql_command = concat('UPDATE ',database(),'.projectmanagement SET state = "',next_projectmanagement_state,'" where project_id="',in_project_id,'" ');

        insert into deferred_sql_tasks
                (taskid,sessionuser     ,hostname  ,sqlstatement)
        values  (uuid(),getsessionuser(),@@hostname,sql_command );

        -- PREPARE stmt FROM sql_command;
        -- EXECUTE stmt;
        -- DEALLOCATE PREPARE stmt;
    end if;
END //

CREATE OR REPLACE FUNCTION `getNewCustomerNumber`( ) RETURNS varchar(10) 
    NO SQL
    DETERMINISTIC
BEGIN
    DECLARE use_result varchar(10);
    SELECT ifnull( max(kundennummer), 10001 ) + 1 INTO use_result  FROM  adressen WHERE kundennummer BETWEEN 10000 AND 69000;

	RETURN use_result;
END //

CREATE OR REPLACE TRIGGER `adressen_bi_kundennummer` 
BEFORE INSERT ON `adressen` FOR EACH ROW
BEGIN
    if new.kundennummer = '-1' then
        SET new.kundennummer = getNewCustomerNumber();
        
    end if;
END //


CREATE OR REPLACE TRIGGER `projectmanagement_bi_state_20001` 
BEFORE INSERT ON `projectmanagement` FOR EACH ROW
BEGIN
    if new.projectmanagement_schema = 'f996a8ea-4d67-11ee-b94d-002590c4e7c6' then
        SET new.state = '20001';
    end if;
END //


CREATE OR REPLACE TRIGGER `projectmanagement_dokumente_ai_state` 
AFTER INSERT ON `projectmanagement_dokumente` FOR EACH ROW
BEGIN
    call proc_projectmanagement_state(new.project_id,null);
END //

CREATE OR REPLACE TRIGGER `projectmanagement_tasks_state` 
AFTER UPDATE ON `projectmanagement_tasks` FOR EACH ROW
BEGIN
    call proc_projectmanagement_state(new.project_id,new.task_id);
END //

