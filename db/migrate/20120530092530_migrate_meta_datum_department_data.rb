module MigrationHelpers
  module MetaDatum
    class << self
      ############ MetaDepartment ########################################
      def migrate_meta_datum_department rmd
        mdp = MetaDatumDepartments.find rmd.id
        YAML.load(rmd.value).each do |id|
          md = MetaDepartment.find(id)
          mdp.meta_departments <<  md unless mdp.meta_departments.include?(md)
        end
        mdp.update_column :value, nil
        mdp.save!
      end

      def migrate_meta_datum_departments
        ids = RawMetaDatum
          .select("meta_data.id")
          .joins(:meta_key).where("meta_keys.object_type = 'MetaDepartment'")
          .where("type is NULL OR type = 'MetaDatum'")

        RawMetaDatum.where("id in (#{ids.to_sql})").each do |rmd|
          rmd.update_column :type, "MetaDatumDepartments"
          migrate_meta_datum_department rmd
        end

        MetaKey.where("object_type = 'MetaDepartment'").each do |mkp|
          mkp.update_column :object_type, nil
          mkp.update_column :meta_datum_object_type, 'MetaDatumDepartment'
        end

      end
    end
  end
end


class MigrateMetaDatumDepartmentData < ActiveRecord::Migration
  def up
    MigrationHelpers::MetaDatum.migrate_meta_datum_departments
  end

  def down
    # raise "this is a irreversible migration"
  end
end
