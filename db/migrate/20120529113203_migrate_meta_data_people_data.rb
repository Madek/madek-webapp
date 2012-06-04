module MigrationHelpers
  module MetaDatum
    class << self

      ############ Person ########################################
      def migrate_meta_person rmd
        mdp = MetaDatumPeople.find rmd.id
        ids = YAML.load(rmd.value)
        Person.where(:id => ids).each do |person|
          mdp.people << person
        end
        mdp.update_column :value, nil
        mdp.save!
      end

      def migrate_meta_people
        RawMetaDatum.joins(:meta_key)
        .where("meta_keys.object_type = 'Person'")
        .where("type is NULL OR type = 'MetaDatum'").each do |rmd|
          rmd.update_column :type, "MetaDatumPeople"
          migrate_meta_person rmd
        end

        MetaKey.update_all({object_type: nil, meta_datum_object_type: 'MetaDatumPeople'},
                           {object_type: 'Person'})
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
