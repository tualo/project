<?php

namespace Tualo\Office\Project\Routes;

use Tualo\Office\Mail\OutgoingMail;
use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route as BasicRoute;
use Tualo\Office\Basic\IRoute;
use Tualo\Office\RemoteBrowser\RemotePDF;


class CMSReportPDF implements IRoute
{
    public static function register()
    {

        BasicRoute::add('/tualocms/page/report/(?P<type>[\w\-\_]+)/(?P<id>[\w\-\_]+)', function ($matches) {


            $db = App::get('session')->getDB();
            $session = App::get('session');
            $types=[];
            $types['bill'] = ['table'=>'view_blg_list_rechnung','field'=>'invoice_id'];
            $types['offer'] = ['table'=>'view_blg_list_angebot','field'=>'offer_id'];;

            try {
                $project = $db->singleRow('select * from projectmanagement where project_id = {project_id} ', [
                    'project_id' => $matches['id']
                ]);
                if (is_null($project)) throw new \Exception('Project not found');
                if (!in_array($matches['type'],array_keys($types))) throw new \Exception('Type not allowed');

                $template = $db->singleValue('select pug_template from ds_renderer where table_name = {table_name} ', [
                    'table_name' => $types[$matches['type']]
                ],'pug_template');

                if ($template === false) throw new \Exception('Template not found');

                $res=RemotePDF::get($types[$matches['type']]['table'],$template, $project[$types[$matches['type']]['field']], true);
                App::contenttype('application/pdf');
                readfile($res['localfilename']);
                unlink($res['localfilename']);
                BasicRoute::$finished=true;
            } catch (\Exception $e) {
                App::result('msg', $e->getMessage());
            }
        }, ['get'], true);
    }
}
