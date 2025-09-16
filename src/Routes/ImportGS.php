<?php

namespace Tualo\Office\Project\Routes;

use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route as BasicRoute;
use Tualo\Office\Basic\IRoute;
use Tualo\Office\DS\DSTable;
use Tualo\Office\RemoteBrowser\RemotePDF;


class ImportGS implements IRoute
{
    public static function register()
    {
        BasicRoute::add('/project/importgs/(?P<id>[\/.\w\d\-\_\.]+)', function ($matches) {

            try {


                $db = App::get('session')->getDB();
                $db->direct('start transaction');

                $report = $db->singleRow('select * from blg_hdr_gs where id={id}', ['id' => $matches['id']]);

                if ($report === false) {
                    throw new \Exception('Report not found');
                }
                $res = RemotePDF::get('view_blg_list_gs', 'report_2025_content', $matches['id']);
                if (isset($res['filename'])) {
                    /*
                        header('Content-type: application/pdf');
                        header('Content-Disposition: inline; filename="' . $matches['id'] . '.pdf"');
                        header('Content-Transfer-Encoding: binary');
                        header('Access-Control-Allow-Headers: Content-Type, Authorization');
                        header('Access-Control-Allow-Credentials: true');
                        header('X-Content-Type-Options: nosniff');
                        header('Cache-Control: must-revalidate');
                        header('Pragma: public');
                        header('Expires: 0');
                        header('Content-Length: ' . filesize($res['filename']));
                        readfile($res['filename']);
                    
                        */
                    $record = [
                        "__file_data" => "data:application/pdf;base64," . base64_encode(file_get_contents($res['filename'])),
                        "__file_id" => "",
                        "__file_name" => basename($res['filename']),
                        "__file_size" => 0,
                        "__file_type" => "application/pdf"
                    ];

                    $projectmanagement_dokumente = DSTable::instance('projectmanagement_dokumente');
                    $record = array_merge($record, [
                        "id" => "GS_" . $report['id'],
                        "__table_name" => "projectmanagement_dokumente",
                        "__id" => "projectmanagement_dokumente-7",
                        "__rownumber" => 1,
                        "project_id" => $report['project_id'],
                        "typ" => 'invoice',

                    ]);
                    $projectmanagement_dokumente->insert($record);

                    /*CREATE TABLE `projectmanagement_dokumente_abrechnung` (
  `pid` varchar(36) NOT NULL,
  `project_id` varchar(36) DEFAULT NULL,
  `file_id` varchar(36) DEFAULT NULL,
  `typ` varchar(50) DEFAULT NULL,
  `report_id` bigint(20) DEFAULT NULL,
  `net` decimal(15,6) DEFAULT 0.000000,
  `gross` decimal(15,6) DEFAULT 0.000000,
  `angewiesen` tinyint(4) DEFAULT 0,
  `iban` varchar(36) DEFAULT NULL,
  `bic` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`pid`),
  KEY `fk_projectmanagement_dokumente_abrechnung_project_id` (`project_id`),
  KEY `fk_projectmanagement_dokumente_abrechnung_file_id` (`file_id`),
  CONSTRAINT `fk_projectmanagement_dokumente_abrechnung_project_id` FOREIGN KEY (`project_id`) REFERENCES `projectmanagement` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
 */
                    /*
                    $projectmanagement_dokumente_abrechnung = DSTable::instance('projectmanagement_dokumente_abrechnung');
                    $record = array_merge($record, [
                        "id" => "GS_" . $report['id'],
                        "__table_name" => "projectmanagement_dokumente_abrechnung",
                        "__id" => "projectmanagement_dokumente_abrechnung-7",
                        */
                    unlink($res['filename']);
                    App::result('success', true);
                }



                $db->direct('commit');

                App::result('success', true);
            } catch (\Exception $e) {
                $db->direct('rollback');

                App::result('msg', $e->getMessage());
            }
            App::contenttype('application/json');
        }, ['put', 'get', 'post'], true);
    }
}
