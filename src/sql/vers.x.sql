
alter table projectmanagement_tasks add tr_offer_request tinyint default 0;

-- set   system_versioning_alter_history = 'KEEP';

alter table projectmanagement_tasks DROP SYSTEM VERSIONING;

alter table projectmanagement_tasks add tr_request_accepted tinyint default 0;
alter table projectmanagement_tasks add tr_request_rejected tinyint default 0;

alter table projectmanagement_tasks add tr_offer_value decimal(15,5) default 0;


alter table projectmanagement_tasks add tr_offer_accepted tinyint default 0;
alter table projectmanagement_tasks add tr_offer_rejected tinyint default 0;


alter table projectmanagement_dokumente ADD SYSTEM VERSIONING;
alter table projectmanagement ADD SYSTEM VERSIONING;
alter table projectmanagement_tasks ADD SYSTEM VERSIONING;