<?php

namespace Tualo\Office\Project\Routes;

use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route as BasicRoute;
use Tualo\Office\Basic\IRoute;
use Tualo\Office\DS\DSFiles;

class Documents implements IRoute
{
    public static function register()
    {


        BasicRoute::add('/tualocms/page/_pdoc/(?P<id>[\/.\w\d\-\_\.]+)' . '', function ($matches) {

            $image = DSFiles::instance('projectmanagement_dokumente');
            $imagedata = $image->getBase64('id', $matches['id'], true);
            $image_error = $image->getError();
            if ($image_error != '') {
                throw new \Exception($image_error);
            }
            BasicRoute::$finished = true;
            http_response_code(200);

            if ($imagedata == '') {
                throw new \Exception('File not found');
            }

            if ($imagedata == 'chunks') {
                $imagedata = '';
                $db = App::get('session')->getDB();
                $record = [
                    '__file_id' => $db->singleValue("select file_id from projectmanagement_dokumente where id = {id}", ['id' => $matches['id']], 'file_id'),
                    'tablename' => 'projectmanagement_dokumente'
                ];
                $liste = $db->direct("select page from ds_files_data_chunks where file_id = ({__file_id}) order by page ", $record);
                foreach ($liste as $item) {
                    $record['page'] = $item['page'];
                    $imagedata .= $db->singleValue("select data from ds_files_data_chunks where file_id = {__file_id} and page = {page} ", $record, 'data');
                }
            }



            if (strpos($imagedata, ',') === false) {
                header("HTTP/1.1 404 Not Found a Base64 File");
                exit;
            } else {
                list($mime, $data) =  explode(',', $imagedata);
                $etag = md5($data);
                App::contenttype(str_replace('data:', '', $mime));


                // header("Last-Modified: ".gmdate("D, d M Y H:i:s", $last_modified_time)." GMT"); 
                header("Etag: $etag");
                header('Cache-Control: public');

                if (
                    (isset($_SERVER['HTTP_IF_NONE_MATCH']) && (trim($_SERVER['HTTP_IF_NONE_MATCH']) == $etag))
                ) {
                    header("HTTP/1.1 304 Not Modified");
                    exit;
                }

                App::body(base64_decode($data));
                BasicRoute::$finished = true;
                http_response_code(200);
            }
        }, ['get'], true);
    }
}
