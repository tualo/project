<?php

namespace Tualo\Office\Project;

use Tualo\Office\Basic\TualoApplication as App;

class Project
{
    public static function getPreview(string $id, string $string_ids = '[]'): mixed
    {
        $db = App::get('session')->getDB();
        $report = $db->singleValue(
            'select convertAllSubProject({id},{ids}) o',
            [
                'id' => $id,
                'ids' => $string_ids
            ],
            'o'
        );
        return json_decode($report, true);
    }
}
