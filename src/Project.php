<?php

namespace Tualo\Office\Project;

use Tualo\Office\Basic\TualoApplication as App;

class Project
{
    public static function getPreview(string $id, string $string_ids = '[]'): mixed
    {
        $db = App::get('session')->getDB();
        $j = json_decode(str_replace("'", '"', $string_ids), true);
        $report = $db->singleValue(
            'select convertAllSubProject({id},{ids}) o',
            [
                'id' => $id,
                'ids' => json_encode($j ? $j : [])
            ],
            'o'
        );
        return json_decode($report, true);
    }

    public static function getDLPreview(string $id, string $string_ids = '[]'): mixed
    {
        $db = App::get('session')->getDB();
        $j = json_decode(str_replace("'", '"', $string_ids), true);
        $report = $db->singleValue(
            'select convertDLProject({id},{ids}) o',
            [
                'id' => $id,
                'ids' => json_encode($j ? $j : [])
            ],
            'o'
        );
        return json_decode($report, true);
    }
}
