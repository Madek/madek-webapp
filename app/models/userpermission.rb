class Userpermission < ActiveRecord::Base 
  belongs_to :media_resource
  belongs_to :user 

  def self.destroy_irrelevant
    Userpermission.where(view: false, edit:false, download: false,manage: false).delete_all
    Userpermission.connection.execute <<-SQL
        DELETE
          FROM "userpermissions"
            USING "media_resources"
          WHERE "media_resources"."id" = "userpermissions"."media_resource_id"
          AND userpermissions.user_id = media_resources.user_id
    SQL
  end

end
