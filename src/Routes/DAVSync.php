<?php
namespace Tualo\Office\Project\Routes;

use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route as BasicRoute;
use Tualo\Office\Basic\IRoute;
use Tualo\Office\DS\DSTable;


class DAVSync implements IRoute{
    public static function register()
    {
        BasicRoute::add('/project/davsync', function ($matches) {
            // https://doc.owncloud.com/webui/next/classic_ui/files/access_webdav.html
            try {
                /*
                    1. finden und löschen alter verzeichnisse, deren project nicht mehr den entsprechenden status besitzt und welches leer ist
                    2. finden und erstellen neuer verzeichnisse, deren project den entsprechenden status besitzt und welches noch nicht existiert
                    3. finden von dateien und import dieser in die datenbank mit anschließendem löschen

                    alter table projectmanagement_states add column file_sync_dir varchar(255) default '';
                    alter table projectmanagement_states add column file_sync_type varchar(50) default null;

                */

                $db = App::get('session')->getDB();
                $db->direct('start transaction');

                $syncdir = App::configuration('projectmanagement','file_sync_dir','');
                if ($syncdir==''){
                    throw new \Exception('file_sync_dir not configured');
                }
                $dirs = $db->directHash("select id,file_sync_dir,file_sync_type from projectmanagement_states where file_sync_dir<>''",[],'file_sync_dir');
                $debug = [];
                

                // 1. finden und löschen alter verzeichnisse, deren project nicht mehr den entsprechenden status besitzt und welches leer ist
                foreach(    $dirs as $dir=>$dir_elem){
                    if (!is_dir($syncdir.'/'.$dir)){
                        mkdir($syncdir.'/'.$dir,0777,true);
                    }
                    $state = $dir_elem[0]['id'];
                    $type = $dir_elem[0]['file_sync_type'];
                    $checkdirs = glob($syncdir.'/'.$dir.'/*',GLOB_ONLYDIR);
                    App::result('checkdirs', $checkdirs );
                    foreach($checkdirs as $checkdir){
                        $project_name = basename($checkdir);
                        $project = $db->singleRow('select project_id,state from projectmanagement where name={name} and state={state} ',['name'=>$project_name,'state'=>$state ]);
                        $files = glob($syncdir.'/'.$dir.'/'.$project_name.'/*');
                        if (($project===false) && (count($files)==0)){
                            rmdir($checkdir);
                            $debug[]="rmdir($checkdir)  ".$syncdir.'/'.$dir.'/'.$project_name.'/*';
                        }
                        if (($project===false) && (count($files)>0)){
                            $project = $db->singleRow('select project_id,state from projectmanagement where name={name}   ',['name'=>$project_name  ]);
                        
                            foreach($files as $file){
                                $record = [
                                    "__file_data"=> "data:application/pdf;base64,".base64_encode(file_get_contents($file)),
                                    "__file_id"=> "",
                                    "__file_name"=> basename($file),
                                    "__file_size"=> 0,
                                    "__file_type"=> "application/pdf"
                                ];
                    
                                $projectmanagement_dokumente = DSTable::instance('projectmanagement_dokumente');
                                $record = array_merge($record,[
                                    "__table_name"=> "projectmanagement_dokumente",
                                    "__id"=>"projectmanagement_dokumente-7",
                                    "__rownumber"=> 1,
                                    "project_id"=> $project['project_id'],
                                    "typ"=> $type,
                                    
                                ]);
                                $projectmanagement_dokumente->insert($record);
                                unlink($file);
                            }
                        }
                    }
                }


                // 2. finden und erstellen neuer verzeichnisse, deren project den entsprechenden status besitzt und welches noch nicht existiert
                $pns =   $db->direct("select projectmanagement.name,projectmanagement_states.file_sync_dir,file_sync_type from projectmanagement_states join projectmanagement on projectmanagement.state = projectmanagement_states.id where file_sync_dir<>''",[]);
                foreach(    $pns as $row){
                    if (!is_dir($syncdir.'/'.$row['file_sync_dir'])){
                        mkdir($syncdir.'/'.$row['file_sync_dir'],0777,true);
                    }
                    if (!is_dir($syncdir.'/'.$row['file_sync_dir'].'/'.$row['name'])){
                        mkdir($syncdir.'/'.$row['file_sync_dir'].'/'.$row['name'],0777,true);
                    }
                }
                
                
                foreach($dirs as $dir=>$dir_elem){
                    if (!is_dir($syncdir.'/'.$dir)){
                        mkdir($syncdir.'/'.$dir,0777,true);
                    }
                    $state = $dir_elem[0]['id'];
                    $type = $dir_elem[0]['file_sync_type'];
                    $checkdirs = glob($syncdir.'/'.$dir.'/*',GLOB_ONLYDIR);
                    App::result('checkdirs', $checkdirs );
                    foreach($checkdirs as $checkdir){
                        $project_name = basename($checkdir);
                        $project_state = $db->singleRow('select project_id,state from projectmanagement where name={name} and state={state}',['name'=>$project_name,'state'=>$state]);
                        $project = $db->singleRow('select project_id,state from projectmanagement where name={name}  ',['name'=>$project_name ]);
                        // print_r(['name'=>$project_name,'state'=>$state]);
                        // var_dump($project_state);
                        // print_r($project);
                        $files = glob($syncdir.'/'.$dir.'/'.$project_name.'/*.pdf');
                        // print_r($files);
                        if (count($files)>0){
                            foreach($files as $file){
                                $record = [
                                    "__file_data"=> "data:application/pdf;base64,".base64_encode(file_get_contents($file)),
                                    "__file_id"=> "",
                                    "__file_name"=> basename($file),
                                    "__file_size"=> 0,
                                    "__file_type"=> "application/pdf"
                                ];
                    
                                $projectmanagement_dokumente = DSTable::instance('projectmanagement_dokumente');
                                $record = array_merge($record,[
                                    "__table_name"=> "projectmanagement_dokumente",
                                    "__id"=>"projectmanagement_dokumente-7",
                                    "__rownumber"=> 1,
                                    "project_id"=> $project['project_id'],
                                    "typ"=> $type,
                                    
                                ]);
                                $projectmanagement_dokumente->insert($record);
                                unlink($file);
                            }
                            
                        }
                    }
                }


                $db->direct('commit');
                App::result('debug', $debug);
                App::result('success', true);

            } catch (\Exception $e) {
                $db->direct('rollback');
                 
                App::result('msg', $e->getMessage());
            }
            App::contenttype('application/json');
        }, ['put','get','post'], true);

    }
}
