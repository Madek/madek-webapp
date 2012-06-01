module MigrationHelpers
  module MetaDatum
    class << self

      ############ Person ########################################
      def migrate_meta_person rmd
        mdp = MetaDatumPerson.find rmd.id
        YAML.load(rmd.value).each do |pid|
          mdp.people << Person.find(pid)
        end
        mdp.update_column :value, nil
        mdp.save!
      end

      def migrate_meta_people
        ids = RawMetaDatum
          .select("meta_data.id")
          .joins(:meta_key).where("meta_keys.object_type = 'Person'")
          .where("type is NULL OR type = 'MetaDatum'")

        RawMetaDatum.where("id in (#{ids.to_sql})").each do |rmd|
          rmd.update_column :type, "MetaDatumPerson"
          migrate_meta_person rmd
        end

        MetaKey.where("object_type = 'Person'").each do |mkp|
          mkp.update_column :object_type, nil
          mkp.update_column :meta_datum_object_type, 'MetaDatumPerson'
        end

      end


    end
  end
end


class MigrateMetaDataPeopleData < ActiveRecord::Migration
  def up
    MigrationHelpers::MetaDatum.migrate_meta_people
  end

  def down
    # raise "this is a irreversible migration"
  end

end
