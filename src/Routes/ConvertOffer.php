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

class ConvertOffer implements IRoute{
    public static function register()
    {
        BasicRoute::add('/project/convert2offer', function ($matches) {
            $db = App::get('session')->getDB();
            
            try {

                

                App::result('success', true);
            } catch (\Exception $e) {
                App::result('msg', $e->getMessage());
            }
            App::contenttype('application/json');
        }, ['put'], true);

    }
}
