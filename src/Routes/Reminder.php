<?php
namespace Tualo\Office\Project\Routes;
use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route as BasicRoute;
use Tualo\Office\Basic\IRoute;
use Tualo\Office\DS\DSTable;

class Reminder implements IRoute{
    public static function register(){


        BasicRoute::add('/project/remindermails'.'',function($matches){
            App::contenttype('application/json');
            $db = App::get('session')->getDB();
            $db->direct('start transaction');
            $tpl_txt='sendmail_reminder_interpreter';
            try{
                $from = App::configuration('mail','force_mail_from');
                if (!$from) throw new \Exception('No from address defined');

                $table = DSTable::instance('projectmanagement_not_reminded');
                $list = $table->read()->get();
                if ($table->error())  throw new \Exception($table->errorMessage());

                foreach($list as $reminderRow){
                    $table = DSTable::instance('projectmanagement');
                    $project = $table->read()->f('project_id','=',$reminderRow['project_id'])->getSingle();
                    $translator = \Tualo\Office\DS\DSTable::instance('uebersetzer')->f('kundennummer','=',$project['uebersetzer'])->read()->getSingle();
                    $mission = [];
                    $projectmanagement_mission =\Tualo\Office\DS\DSTable::instance('projectmanagement_mission');
                    $table = $projectmanagement_mission->f('project_id','=',$project['project_id'])->read();
                    if (!$table->empty()){
                        $mission = $table->getSingle();
                    }

                    $to = App::configuration('mail','force_mail_to',$translator['email']);
                    $to_list = explode(';',$to);

                    $data = [];
                    $data['translator'] = $translator;
                    $data['project'] = $project;
                    $data['task'] =[
                        'task_id'=>$reminderRow['task_id'],
                    ];
                    $data['mission'] = $mission;

                    $mail = \Tualo\Office\Mail\SMTP::get();
                    $mail->setFrom($from);
                    foreach($to_list as $to){
                        $mail->addAddress(trim($to));
                    }

                    $mail->Subject = 'Erinnerung: '.$project['name'];
                    $mail->isHTML(false); 
                    $mail->Body    = strip_tags(\Tualo\Office\PUG\PUG::render($tpl_txt,   $data ));
                    if(!$mail->send()) {
                        throw new \Exception('Message has not been sent');
                    }
                }

                $db->direct('commit');

                App::result('success', true);
            } catch (\Exception $e) {
                App::result('msg', $e->getMessage());
            }
            
            
            
        
        },['get'],true);

    }
}
