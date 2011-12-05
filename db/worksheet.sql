

-- migrating owner data

ALTER TABLE media_entries ADD COLUMN owner_id integer;
UPDATE media_entries 
SET owner_id = (SELECT upload_sessions.user_id as user_id
  FROM upload_sessions
  INNER JOIN  media_entries as me ON  upload_sessions.id = me.upload_session_id
                WHERE media_entries.id = me.id);




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
  



