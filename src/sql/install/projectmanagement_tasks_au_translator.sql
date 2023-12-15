CREATE OR REPLACE TRIGGER `projectmanagement_tasks_au_translator` AFTER UPDATE ON `projectmanagement_tasks` FOR EACH ROW
BEGIN
    if (
        (
        old.current_translator is null or 
        old.current_translator<>new.current_translator
    )
        and (
            new.current_translator<>''
        )
    ) then
        insert into projectmanagement_tasks_uebersetzer (task_id, kundennummer  ) values (new.task_id, new.current_translator);
    end if;
END