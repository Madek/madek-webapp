
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
  




