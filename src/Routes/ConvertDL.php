<?php

namespace Tualo\Office\Project\Routes;

use Tualo\Office\Mail\OutgoingMail;
use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route as BasicRoute;
use Tualo\Office\Basic\IRoute;
use Tualo\Office\DS\DSTable;
use Tualo\Office\PUG\PUG;
use Tualo\Office\RemoteBrowser\RemotePDF;
use DOMDocument;
use PHPMailer\PHPMailer\PHPMailer;

class ConvertDL extends \Tualo\Office\Basic\RouteWrapper
{
    public static function register()
    {
        BasicRoute::add('/project/convertdl', function ($matches) {

            try {
                $postdata = json_decode(file_get_contents("php://input"), true);
                if (is_null($postdata)) throw new \Exception('Payload not readable');
                if (!isset($postdata['ids'])) $postdata['ids'] = '[]';
                if (is_array($postdata['ids'])) {
                    $postdata['ids'] = json_encode($postdata['ids']);
                } elseif (!is_string($postdata['ids'])) {
                    throw new \Exception('ids must be an array or a string');
                }

                $db = App::get('session')->getDB();
                $db->direct('start transaction');
                // $db->direct('call convertProject2Bill({project_id},@result)',$postdata);
                $db->direct('call convertDL({project_id},{ids},@result)', $postdata);
                App::result('mr', $db->moreResults());
                $result = json_decode($db->singleValue('select @result r', [], 'r'), true);
                App::result('data',  $result);
                App::result('success', true);
                $db->direct('commit');
            } catch (\Exception $e) {
                App::result('msg_sql', $db->last_sql);
                $db->direct('rollback');
                App::result('msg', $e->getMessage());
            }
            App::contenttype('application/json');
        }, ['put', 'get', 'post'], true);
    }
}
