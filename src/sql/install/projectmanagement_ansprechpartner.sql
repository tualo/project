delimiter ;

create table if not exists projectmanagement_ansprechpartner (
    `project_id` varchar(36),
    `ansprechpartner_id` varchar(36),
    `aktiv` tinyint default 0,
  PRIMARY KEY (`project_id`,`ansprechpartner_id`),
  KEY `fk_projectmanagement_ansprechpartner_project_id` (`project_id`),
  KEY `fk_projectmanagement_ansprechpartner_ansprechpartner_id` (`ansprechpartner_id`),
  CONSTRAINT `fk_projectmanagement_ansprechpartner_project_id` FOREIGN KEY (`project_id`) REFERENCES `projectmanagement` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_projectmanagement_ansprechpartner_ansprechpartner_id` FOREIGN KEY (`ansprechpartner_id`) REFERENCES `ansprechpartner` (`id`) ON DELETE CASCADE ON UPDATE CASCADE

);