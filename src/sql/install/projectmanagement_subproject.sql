DELIMITER ;
CREATE TABLE IF NOT EXISTS `projectmanagement_subproject` (
  `project_id` varchar(36) NOT NULL,
  `parent_project` varchar(36) not NULL,
  KEY `fk_projectmanagement_project_id` (`project_id`),
  KEY `fk_projectmanagement_parent_project` (`parent_project`),
  PRIMARY KEY (`project_id`),
  CONSTRAINT `fk_projectmanagement_subproject_project_id` FOREIGN KEY (`project_id`) REFERENCES `projectmanagement` (`project_id`) ON DELETE   cascade ON UPDATE CASCADE,
  CONSTRAINT `fk_projectmanagement_subproject_parent_project` FOREIGN KEY (`parent_project`) REFERENCES `projectmanagement` (`project_id`) ON DELETE   cascade ON UPDATE CASCADE
);