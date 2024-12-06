
CREATE TABLE IF NOT EXISTS `projectmanagement` (
  `project_id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` longtext DEFAULT NULL,
  `state` int(11) DEFAULT 0,
  `createdate` date NOT NULL,
  `updatedate` date NOT NULL,
  `offer_id` bigint(20) DEFAULT NULL,
  `invoice_id` bigint(20) DEFAULT NULL,
  `client_order_id` varchar(255) DEFAULT NULL,
  `client_order_date` date DEFAULT NULL,
  `project_folder` varchar(255) DEFAULT NULL,
  `source_language` varchar(5) DEFAULT NULL,
  `kundennummer` varchar(10) DEFAULT NULL,
  `kostenstelle` int(11) DEFAULT NULL,
  `projectmanagement_schema` varchar(36) DEFAULT '0',
  `target_date` date DEFAULT curdate(),
  `target_time` time DEFAULT '18:00:00',

   

  PRIMARY KEY (`project_id`),
  KEY `fk_projectmanagement_state` (`state`),
  KEY `fk_projectmanagement_kundennummer_kostenstelle` (`kundennummer`,`kostenstelle`),
  KEY `idx_projectmanagement_name` (`name`),
  KEY `fk_projectmanagement_projectmanagement_schema` (`projectmanagement_schema`),
  CONSTRAINT `fk_projectmanagement_kundennummer_kostenstelle` FOREIGN KEY (`kundennummer`, `kostenstelle`) REFERENCES `adressen` (`kundennummer`, `kostenstelle`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `fk_projectmanagement_projectmanagement_schema` FOREIGN KEY (`projectmanagement_schema`) REFERENCES `projectmanagement_schema` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_projectmanagement_state` FOREIGN KEY (`state`) REFERENCES `projectmanagement_states` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
);



CREATE TABLE IF NOT EXISTS `projectmanagement_uebersetzer` (

    `project_id` varchar(36) NOT NULL,
    `source_language` varchar(5) DEFAULT NULL,
    `target_language` varchar(5) DEFAULT NULL,
    `uebersetzer`varchar(10) NOT NULL,

    KEY `idx_projectmanagement_uebersetzer_project_id` (`project_id`),
    KEY `idx_projectmanagement_uebersetzer_uebersetzer` (`uebersetzer`),

    CONSTRAINT `fk_projectmanagement_uebersetzer_project_id` FOREIGN KEY (`project_id`) REFERENCES `projectmanagement` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE

);

--  WITH SYSTEM VERSIONING