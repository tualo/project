CREATE or replace TRIGGER `projectmanagement_bi_name` BEFORE INSERT ON `projectmanagement` FOR EACH ROW
BEGIN

    declare pattern varchar(10);


    SET pattern = concat('P',date_format(curdate(),'%y%m%d'));

    if new.project_folder is null or new.project_folder ='' then

        SET new.name = (
            select concat( pattern, lpad( ifnull(max( cast(REGEXP_REPLACE(substring(name,length(pattern)+1),'[^0-9]','') as integer)),0)+1, 4,'0') ) n 
            from projectmanagement where LOCATE(pattern,name)=1 and REGEXP_REPLACE(name,'[^0-9]','')<> '' and name not like '%-__'
        );    
    
    end if;
END  //


CREATE or replace TRIGGER `projectmanagement_ai_project_folder` AFTER INSERT ON `projectmanagement` FOR EACH ROW
BEGIN
    insert ignore into projectmanagement_subproject (parent_project,project_id) values (
        new.project_folder,
        new.project_id
    );
END //



CREATE or replace TRIGGER `projectmanagement_subproject_ai_copy` AFTER INSERT ON `projectmanagement_subproject` FOR EACH ROW
BEGIN
    DECLARE use_sql longtext;

    insert ignore into projectmanagement_dokumente (
        id,
        project_id,
        file_id,
        typ
    )
    select 
        uuid(),
        new.project_id,
        projectmanagement_dokumente.file_id,
        projectmanagement_dokumente.typ
    from 
        projectmanagement_dokumente 
    where 
        projectmanagement_dokumente.project_id = new.parent_project;

    replace into projectmanagement_mission (
        project_id,
        name,
        room,
        street,
        zipcode,
        city
    )
    select 
        new.project_id,
        projectmanagement_mission.name,
        projectmanagement_mission.room,
        projectmanagement_mission.street,
        projectmanagement_mission.zipcode,
        projectmanagement_mission.city
    from 
        projectmanagement_mission 
    where 
        projectmanagement_mission.project_id = new.parent_project;




    set use_sql=concat("call projectmanagement_subproject_copy_tasks('",new.project_id,"','",new.parent_project,"')");
    insert into deferred_sql_tasks (taskid,sessionuser     ,hostname  ,sqlstatement) values  (uuid(),getsessionuser(),@@hostname,use_sql );
    
    


END //


CREATE or replace PROCEDURE `projectmanagement_subproject_copy_tasks` (in_project_id varchar(36),in_parent_project varchar(36))
MODIFIES SQL DATA
BEGIN
    for r in (
        select 
        *
        from 
            projectmanagement_tasks 
        where 
            projectmanagement_tasks.project_id = in_parent_project
    ) do

        update 
            projectmanagement_tasks
        set
            description=r.description,
            state=r.state,
            source_language=r.source_language,
            target_language=r.target_language,
            unit_text=r.unit_text,
            article=r.article,
            amount=r.amount,
            singleprice=r.singleprice,
            unit=r.unit,
            current_translator=r.current_translator
        where 
            projectmanagement_tasks.name = r.name
            and projectmanagement_tasks.project_id = in_project_id
            and (amount=0 or current_translator is null);

    end for;
END // 