create table projectmanagement_search (
    `project_id` varchar(36) not null primary key,
    `seachvalue` text,
    FULLTEXT(`seachvalue`),
    CONSTRAINT `fk_projectmanagement_search_id` 
    FOREIGN KEY (`project_id`) 
    REFERENCES `projectmanagement` (`project_id`) 
    ON DELETE  CASCADE ON UPDATE CASCADE
)


CREATE OR REPLACE PROCEDURE `proc_projectmanagement_search`( in in_project_id varchar(36) )
    MODIFIES SQL DATA
BEGIN
    declare newvalue text;
    declare addvalue text;

    set newvalue = '';


    -- Block
    select 
        anzeigen_name 
    into 
        addvalue
    from 
        view_readtable_adressen 
    where (view_readtable_adressen.kundennummer,view_readtable_adressen.kostenstelle)
        = (select kundennummer, kostenstelle from projectmanagement where project_id = in_project_id);
    if addvalue is not null then
        set newvalue = concat_ws(char(10),newvalue,addvalue);
    end if;


    -- Block
    select 
        anzeigen_name 
    into 
        addvalue
    from 
        view_readtable_uebersetzer 
    where (view_readtable_uebersetzer.kundennummer,view_readtable_uebersetzer.kostenstelle)
        = (select kundennummer, kostenstelle from projectmanagement where project_id = in_project_id);
    if addvalue is not null then
        set newvalue = concat_ws(char(10),newvalue,addvalue);
    end if;


    -- Block
    select 
        search_fld 
    into 
        addvalue
    from 
        view_readtable_projectmanagement 
    where (view_readtable_projectmanagement.kundennummer,view_readtable_projectmanagement.kostenstelle)
        = (select kundennummer, kostenstelle from projectmanagement where project_id = in_project_id);
    if addvalue is not null then
        set newvalue = concat_ws(char(10),newvalue,addvalue);
    end if;


    


END