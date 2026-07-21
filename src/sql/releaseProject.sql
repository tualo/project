

DELIMITER //
CREATE OR REPLACE PROCEDURE `releaseProject`(
    in use_project_id varchar(36),     
    out result tinyint,
    out msg varchar(255)
) BEGIN
    SET result=0;
    IF (
        select count(*)
        from projectmanagement
        where project_id = use_project_id
    ) = 0 THEN 
    
    SET result=0;
    SET msg = 'Das Projekt wurde nicht gefunden';



    ELSE 

        set @offen = (select offen from blg_hdr_rechnung where id in ( SELECT invoice_id FROM projectmanagement where project_id = use_project_id ));

        if @offen<>0 then
            SET result=0;
            SET msg = 'Die entsprechende Rechnung ist noch nicht storniert und ausgeziffert.';

        else
        SET @allow_update_invoice_id  = 1;
        update projectmanagement set invoice_id  = 0 where project_id = use_project_id; 
            SET result=1;
            SET msg = 'erledigt.';
        end if;


    END IF;


END //