create table if not exists objekt_anschrift (
  id varchar(36) primary key,

  objekt_nummer varchar(36) not null,
  strasse varchar(255) not null,
  hausnummer varchar(20) not null,
  plz varchar(8) not null,
  ort varchar(255) not null,

  kundennummer varchar(10) not null,
  kostenstelle integer default 0 not null,
  
  CONSTRAINT `fk_objekt_anschrift_adressen` FOREIGN KEY (`kundennummer`,`kostenstelle`) REFERENCES `adressen` (`kundennummer`,`kostenstelle`) ON DELETE CASCADE ON UPDATE CASCADE,

  created_at timestamp not null default current_timestamp,
  updated_at timestamp not null default current_timestamp on update current_timestamp
);

create table if not exists objekt_regie_arbeit_vorgaben (
  id varchar(36) primary key,
  vorgabe text not null,
  created_at timestamp not null default current_timestamp,
  updated_at timestamp not null default current_timestamp on update current_timestamp
);


create table if not exists objekt_regie_arbeit_abrechnungsarten (
  id varchar(36) primary key,
  name varchar(255) not null,
  zusatztext varchar(255) not null,
  created_at timestamp not null default current_timestamp,
  updated_at timestamp not null default current_timestamp on update current_timestamp
);


/*

An- und Abfahrt zum Objekt;
- Rüstzeit für Betriebsmaterialien, Hilfsstoffe und Werkzeuge ab Betriebsstätte;
- Einrichten der Baustelle;
- Abdecken von Einrichtungsgegenstände, mit Errichten einer Staubwand im Arbeitszimmer, sowie Abschottungen der Nebenräume;
> Arbeitszimmer und Flur
- Suchen durch Ortung im Unterputz verlegten Installationen;
- Händisches Abklopfen des bestehenden Wandputzes;


insert into objekt_regie_arbeit_vorgaben (id, vorgabe) values
(uuid(), 'An- und Abfahrt zum Objekt'),
(uuid(), 'Rüstzeit für Betriebsmaterialien, Hilfsstoffe und Werkzeuge ab Betriebsstätte'),
(uuid(), 'Einrichten der Baustelle'),
(uuid(), 'Abdecken von Einrichtungsgegenstände, mit Errichten einer Staubwand im Arbeitszimmer, sowie Abschottungen der Nebenräume'),
(uuid(), 'Suchen durch Ortung im Unterputz verlegten Installationen'),
(uuid(), 'Händisches Abklopfen des bestehenden Wandputzes');

insert into objekt_regie_arbeit_abrechnungsarten (id, name, zusatztext) values
(uuid(), 'Stunde', 'Stundenlohn'),
(uuid(), 'Pauschale', 'Pauschalpreis'),
(uuid(), 'Stück', 'Stückpreis'),
(uuid(), 'Laufmeter', 'Laufmeterpreis'),
(uuid(), 'Quadratmeter', 'Quadratmeterpreis'),
(uuid(), 'Kubikmeter', 'Kubikmeterpreis')
*/