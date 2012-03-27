

-- metadata

SELECT media_resources.id as media_resource_id 
     , meta_data.id as meta_datum_id 
     , meta_data.value as meta_datum_value
     , meta_keys.id as meta_key_id
     , meta_contexts.id as meta_context_id
     , meta_contexts.name as meta_contex_name
     , meta_key_definitions.id as meta_key_definition_id
     , meta_key_definitions.label_id as label_id
     , meta_terms.en_gb as meta_term_en
  FROM media_resources 
  INNER JOIN meta_data ON meta_data.media_resource_id = media_resources.id
  INNER JOIN meta_keys ON meta_data.meta_key_id = meta_keys.id
  INNER JOIN meta_key_definitions ON meta_key_definitions.meta_key_id = meta_keys.id
  INNER JOIN meta_contexts ON meta_key_definitions.meta_context_id = meta_contexts.id
  INNER JOIN meta_terms ON meta_key_definitions.label_id = meta_terms.id
  where true
  AND media_resources.id = 4
  ;

-- relative top level sets of the user with id = 999999 

SELECT * from media_resources
    WHERE type = 'MediaSet'
    AND user_id = 999999
    AND id NOT IN 
      (SELECT child_id FROM media_set_arcs 
          WHERE parent_id in
          (SELECT id from media_resources
            WHERE type = 'MediaSet'
            AND user_id = 999999)
          AND child_id in
          (SELECT id from media_resources
              WHERE type = 'MediaSet'
              AND user_id = 999999));

SELECT DISTINCT mr1.* FROM media_resources mr1
  LEFT JOIN media_set_arcs msa ON msa.child_id = mr1.id
  LEFT JOIN media_resources mr2 ON msa.parent_id = mr2.id AND mr2.user_id = mr1.user_id
WHERE mr1.type IN ('MediaSet') AND mr1.user_id = 999999 AND mr2.id IS NULL;

-- 

SELECT "users".* FROM "users" 
  INNER JOIN "groups_users" ON "groups_users"."user_id" = "users"."id" 
  INNER JOIN "groups" ON "groups"."id" = "groups_users"."group_id" 
  INNER JOIN "grouppermissions" ON "grouppermissions"."group_id" = "groups"."id" 
  INNER JOIN "media_resources" ON "media_resources"."id" = "grouppermissions"."media_resource_id" 
  WHERE "grouppermissions"."view" = 't'  
  NOT IN ( SELECT "users".* FROM "users" INNER JOIN "userpermissions" ON "userpermissions"."user_id" = "users"."id" INNER JOIN "media_resources" ON "media_resources"."id" = "userpermissions"."media_resource_id" WHERE "userpermissions"."view" = 't' AND "media_resources"."id" = 1 AND "userpermissions"."view" = 'f' )

SELECT "media_resources".* FROM "media_resources"  WHERE ( media_resources.id IN  (
         SELECT media_resource_id FROM "userpermissions"  WHERE "userpermissions"."view" = 't' AND (user_id = 1 ) 
        UNION
         SELECT media_resource_id FROM "grouppermissions" INNER JOIN "groups" ON "groups"."id" = "grouppermissions"."group_id" INNER JOIN groups_users ON groups_users.group_id = grouppermissions.group_id WHERE "grouppermissions"."view" = 't' AND (groups_users.user_id = 1) AND ( media_resource_id NOT IN ( SELECT media_resource_id FROM "userpermissions"  WHERE "userpermissions"."view" = 'f' AND (user_id = 1 ) )) 
              ))

 

SELECT media_resource_id FROM `userpermissions`  WHERE `userpermissions`.`view` = 1 AND (user_id = 2233 )
UNION
SELECT media_resource_id FROM `grouppermissions` INNER JOIN `groups` ON `groups`.`id` = `grouppermissions`.`group_id` INNER JOIN groups_users ON groups_users.group_id = grouppermissions.group_id WHERE `grouppermissions`.`view` = 1 AND (groups_users.user_id = 2233) AND ( media_resource_id NOT IN ( SELECT media_resource_id FROM `userpermissions`  WHERE `userpermissions`.`view` = 0 AND (user_id = 2233 ) ))


SELECT users from users
  INNER JOIN  manageable_media_resources_users ON manageable_media_resources_users.user_id = users.id
  INNER JOIN media_resources ON media_resources.id = manageable_media_resources_users.media_resource_id;


---

SELECT DISTINCT * FROM "media_resources" 
  INNER JOIN "media_set_arcs" ON "media_resources"."id" = "media_set_arcs"."parent_id" 
  INNER JOIN editable_media_resources_users ON media_resources.id = media_set_id 
  WHERE "media_resources"."type" IN ('MediaSet') AND "media_set_arcs"."child_id" = 2


SELECT "media_resources".* FROM "media_resources" 
  INNER JOIN "media_set_arcs" ON "media_set_arcs"."parent_id" = "media_resources"."id" 
  INNER JOIN viewable_media_sets_users ON media_resources.id = media_set_id
  WHERE "media_resources"."type" IN ('MediaSet') AND ( child_id = 2 ) 



SELECT media_resource_id as media_resource_id, user_id as user_id 
  FROM userpermissions 
  JOIN permissionsets ON permissionsets.id = userpermissions.permissionset_id
  WHERE permissionsets.view = true;


SELECT media_resource_id as media_resource_id, user_id as user_id 
  FROM grouppermissions
    JOIN permissionsets ON permissionsets.id = grouppermissions.permissionset_id
    JOIN groups_users ON groups_users.group_id = grouppermissions.group_id
  WHERE permissionsets.view = true; 

SELECT media_resource_id as media_resource_id, user_id as user_id 
        FROM userpermissions 
        JOIN permissionsets ON permissionsets.id = userpermissions.permissionset_id
        WHERE permissionsets.view = false);
       
-- combined: 

SELECT media_resource_id as media_resource_id, user_id as user_id 
  FROM grouppermissions
    JOIN permissionsets ON permissionsets.id = grouppermissions.permissionset_id
    JOIN groups_users ON groups_users.group_id = grouppermissions.group_id
  WHERE permissionsets.view = true 
    AND (media_resource_id, user_id) NOT IN  (
      SELECT media_resource_id as media_resource_id, user_id as user_id 
        FROM userpermissions 
        JOIN permissionsets ON permissionsets.id = userpermissions.permissionset_id
        WHERE permissionsets.view = false);
       
SELECT media_resources.id as media_resource_id, users.id as user_id 
  FROM media_resources
  INNER JOIN permissionsets ON permissionsets.id = media_resources.permissionset_id
  CROSS JOIN users
  WHERE permissionsets.view = true;
  

  SELECT #{table_name}.id as #{ref_id model}, #{action}able_media_resources_users.user_id as user_id 
  FROM #{table_name}
  INNER JOIN #{action}able_media_resources_users 
  ON #{action}able_media_resources_users.media_resource_id = #{table_name}.media_resource_id;





SELECT "userpermissions".* FROM "userpermissions" 
  INNER JOIN "users" ON "users"."id" = "userpermissions"."user_id" 
  INNER JOIN "permissionsets" ON "permissionsets"."id" = "userpermissions"."permissionset_id" 
  INNER JOIN "media_resources" ON "media_resources"."id" = "userpermissions"."media_resource_id" 
  WHERE "userpermissions"."user_id" = 1 
  AND "userpermissions"."media_resource_id" = 1 
  AND (permissionsets.view = false) 
  LIMIT 1

-- migrating owner data

ALTER TABLE media_entries ADD COLUMN owner_id integer;
UPDATE media_entries 
SET owner_id = (SELECT upload_sessions.user_id as user_id
  FROM upload_sessions
  INNER JOIN  media_entries as me ON  upload_sessions.id = me.upload_session_id
                WHERE media_entries.id = me.id);



---

CREATE OR REPLACE FUNCTION del_SOURCETABLE_TARGETTABLE_referenced_fkey_KEYROW() 
RETURNS trigger
AS $$
DECLARE
BEGIN
  PERFORM DELETE FROM TARGETTABLE WHERE id = OLD.KEYROW;
  RETURN OLD;
END $$
LANGUAGE PLPGSQL;

CREATE TRIGGER del_SOURCETABLE_TARGETTABLE_referenced_fkey_KEYROW
  AFTER DELETE
  ON SOURCETABLE
  FOR EACH ROW execute procedure del_SOURCETABLE_TARGETTABLE_referenced_fkey_KEYROW();



CREATE OR REPLACE FUNCTION update_v_m_u_sanspublic_on_mediaresource_owner_update() 
RETURNS trigger
AS $$
DECLARE
BEGIN
  IF NEW.owner_id <> OLD.owner_id THEN
    IF NOT can_view_by_group_or_user_perm(OLD.id, OLD.owner_id) THEN
      PERFORM v_m_u_sanspublic_delete_if_exists(OLD.id, OLD.owner_id);
    END IF;
    PERFORM v_m_u_sanspublic_insert_if_not_exists(NEW.id,NEW.owner_id);
  END IF;
  RETURN NEW;
END $$
LANGUAGE PLPGSQL;


CREATE FUNCTION delref_fkey_userperm2ba04ffd52973efb154726d2ed4bdc7973eec9f4() 
RETURNS trigger
AS $$
DECLARE
BEGIN
  PERFORM DELETE FROM userpermissions WHERE id = OLD.userpermission_id;
  RETURN OLD;
END $$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION delref_fkey_userperm2ba04ffd52973efb154726d2ed4bdc7973eec9f4() 
RETURNS trigger
AS $$
DECLARE
BEGIN
  PERFORM DELETE FROM userpermissions WHERE id = OLD.userpermission_id;
  RETURN OLD;
END $$
LANGUAGE PLPGSQL;

--

CREATE VIEW viewable_mediasets_by_userpermission AS
  SELECT media_sets.id as media_set_id, users.id as user_id
    FROM media_sets
    INNER JOIN mediaset_userpermission_joins ON mediaset_userpermission_joins.media_set_id = media_sets.id
    INNER JOIN userpermissions ON userpermissions.id = mediaset_userpermission_joins.userpermission_id
    INNER JOIN users ON users.id = userpermissions.user_id
    WHERE userpermissions.may_view = true;


  
  
SELECT media_sets.id as media_set_id
  FROM media_sets;
  INNER JOIN mediaset_userpermission_joins ON mediaset_userpermission_joins.media_set_id = media_sets.id
  INNER JOIN userpermissions ON userpermissions.id = mediaset_userpermission_joins.userpermission_id
  INNER JOIN users ON users.id = userpermissions.user_id
  WHERE userpermissions.may_view = true;
  




