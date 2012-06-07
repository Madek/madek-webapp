
module MigrationHelpers
  module MetaDatum
    class << self

      def migrate_meta_datum_user rmd
        mdp = MetaDatumUsers.find rmd.id
        ids = YAML.load(rmd.value)
        User.where(:id => ids).each do |md|
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

        MetaKey.update_all({object_type: nil, meta_datum_object_type: 'MetaDatumUsers'},
                           {object_type: 'User'})
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
