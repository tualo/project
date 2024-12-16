delimiter // 

CREATE PROCEDURE IF NOT EXISTS `create_reports_projectmanagement_dokumente_abrechnung`( )
BEGIN 
    declare adr text;
    declare report json;
    declare reportresult json;
    for rec in  (select * from view_readtable_projectmanagement_dokumente_abrechnung where report_id<0 limit 1) do
        

        set adr = (select address from view_editor_relation_krechnung where referencenr = rec.kundennummer and costcenter = rec.kostenstelle);
        
        select 
            json_object(
                "date", curdate(),
                "time", curtime(),
                "bookingdate", curdate(),
                "service_period_start",curdate(),
                "service_period_stop", curdate(),
                "warehouse", 0,
                "reference", rec.projectmanagement_name,
                "filename",rec.datei,
                "fileid",rec.file_id,
                "kindofbill","netto",
                "referencenr", rec.kundennummer,
                "costcenter", rec.kostenstelle,
                "address", adr,
                "companycode", "0000",
                "office", 1,
                "positions",
                    json_array(
                        json_object(
                            "article", 'Eingangsrechnung',
                            "position", 1,
                            "account", 5906,
                            "amount", 1.00000,
                            "notes", "",
                            "additionaltext", "",
                            "singleprice", 0,
                            "tax", 19.00000,
                            "net", 0,
                            "taxvalue", 0,
                            "gross", 0
                        ),
                        json_object(
                            "article", 'Eingangsrechnung, Steuerfrei',
                            "position", 2,
                            "account", 5906,
                            "amount", 1.00000,
                            "notes", "",
                            "additionaltext", "",
                            "singleprice", 0,
                            "tax", 0,
                            "net", 0,
                            "taxvalue", 0,
                            "gross", 0
                        )
                    )
            ) o
            
            into report;

select report;
select json_value(report,"$.referencenr");
select rec.pid;

             call setReport('krechnung',report,reportresult);
             select json_value(reportresult,"$.id");
             select reportresult;
             -- update projectmanagement_dokumente_abrechnung set report_id = json_value(reportresult,"$.id") where id=rec.pid; 
             insert into projectmanagement_dokumente_abrechnung
             (
                pid,
                project_id,
                file_id,
                typ,
                report_id
             ) values 
             (
                rec.pid,
                rec.project_id,
                rec.file_id,
                rec.typ,
                json_value(reportresult,"$.id")
             );
    end for;

END //