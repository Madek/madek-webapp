module MigrationHelpers
  module MetaDatum
    class << self
      ############ MetaDepartment ########################################
      def migrate_meta_datum_department rmd
        mdp = MetaDatumDepartments.find rmd.id
        ids = YAML.load(rmd.value)
        MetaDepartment.where(:id => ids).each do |md|
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
        
        MetaKey.update_all({object_type: nil, meta_datum_object_type: 'MetaDatumDepartments'},
                           {object_type: 'MetaDepartment'})
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
