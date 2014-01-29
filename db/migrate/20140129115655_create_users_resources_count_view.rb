class CreateUsersResourcesCountView < ActiveRecord::Migration
  def up
    execute %[ CREATE VIEW user_resources_counts AS
      SELECT count(*) as resouces_count ,user_id FROM media_resources GROUP BY media_resources.user_id ]
  end
  def down
    execute %[ DROP VIEW user_resources_counts ]
  end
end
