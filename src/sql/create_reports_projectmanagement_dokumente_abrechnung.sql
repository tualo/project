
CREATE OR REPLACE PROCEDURE `create_reports_projectmanagement_dokumente_abrechnung`( )
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
                            "notes", null,
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
                            "notes", null,
                            "additionaltext", "",
                            "singleprice", 0,
                            "tax", 0,
                            "net", 0,
                            "taxvalue", 0,
                            "gross", 0
                        )
                    )
            ) o;

            call setReport('krechnung',report,reportresult);
            select json_value(reportresult,"$.id");
            update projectmanagement_dokumente_abrechnung set report_id = json_value(reportresult,"$.id") where id=rec.report_id; 
    end for;

END 
