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