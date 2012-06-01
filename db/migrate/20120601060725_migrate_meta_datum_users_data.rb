
module MigrationHelpers
  module MetaDatum
    class << self

      def migrate_meta_datum_user rmd
        mdp = MetaDatumUsers.find rmd.id
        YAML.load(rmd.value).each do |id|
          md = User.find(id)
          mdp.users <<  md unless mdp.users.include?(md)
        end
        mdp.update_column :value, nil
        mdp.save!
      end

      def migrate_meta_datum_users
      
        ids = RawMetaDatum
          .select("meta_data.id")
          .joins(:meta_key).where("meta_keys.object_type = 'User'")
          .where("type is NULL OR type = 'MetaDatum'")

        RawMetaDatum.where("id in (#{ids.to_sql})").each do |rmd|
          rmd.update_column :type, "MetaDatumUsers"
          migrate_meta_datum_user rmd
        end

        MetaKey.where("object_type = 'User'").each do |mkp|
          mkp.update_column :object_type, nil
          mkp.update_column :meta_datum_object_type, 'MetaDatumUsers'
        end

      end

    end
  end
end



class MigrateMetaDatumUsersData < ActiveRecord::Migration
  def up
    MigrationHelpers::MetaDatum.migrate_meta_datum_users
  end

  def down
  end
end
