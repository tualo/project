<?php

namespace Tualo\Office\Project;

use Tualo\Office\Basic\TualoApplication as App;

class Project
{
    public static function getPreview(string $id): mixed
    {
        $db = App::get('session')->getDB();
        $report = $db->singleValue('select convertAllSubProject({id}) o', ['id' => $id],'o');
        return json_decode($report, true);
    }
}