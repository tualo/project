create table projectmanagement_dokumente_abrechnung (
    id	varchar(36),
    project_id	varchar(36),
    file_id	varchar(36),
    typ	varchar(50),
    report_id bigint default null,
  PRIMARY KEY (`id`),
  KEY `fk_projectmanagement_dokumente_abrechnung_project_id` (`project_id`),
  KEY `fk_projectmanagement_dokumente_abrechnung_file_id` (`file_id`),
  CONSTRAINT `fk_projectmanagement_dokumente_abrechnung_project_id` FOREIGN KEY (`project_id`) REFERENCES `projectmanagement` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE
)
