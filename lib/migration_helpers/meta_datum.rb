module MigrationHelpers

  module MetaDatum

    class RawMetaDatum < ActiveRecord::Base 
      set_table_name :meta_data
      belongs_to :meta_key
    end

    class << self

      ############ String ########################################
      def migrate_meta_string raw_meta_datum
        s = YAML.load raw_meta_datum.value
        raw_meta_datum.update_attributes({ 
          string: s, 
          value: nil
        })
        raw_meta_datum.save!
      end


      def migrate_meta_strings

        ids = RawMetaDatum
          .select("meta_data.id")
          .joins(:meta_key).where("meta_keys.object_type = 'MetaCountry' OR meta_keys.object_type is NULL")
          .where("type is NULL or type = 'MetaDatum' ")

        RawMetaDatum.where("id in (#{ids.to_sql})").each do |rmd|
          migrate_meta_string rmd
          rmd.update_column :type, "MetaDatumString"
        end

        MetaKey.where("object_type is NULL").each do |mk|
          mk.update_attributes object_type: nil
          mk.update_attributes meta_datum_object_type: 'MetaDatumString'
        end

        MetaKey.where("object_type = 'MetaCountry'").each do |mk|
          mk.update_attributes object_type: nil
          mk.update_attributes meta_datum_object_type: 'MetaDatumString'
        end

      end

      ############ Date ########################################
      def migrate_meta_date raw_meta_datum
        obj = YAML.load raw_meta_datum.value.gsub /^-\s+.*\n/, ""
        new_string_value=  
          if obj.is_a? Hash
            obj.try(:fetch,"free_text").try(:strip)
          else
            ""
          end
        raw_meta_datum.update_attributes({ 
          string: new_string_value, 
          value: nil
        })
        raw_meta_datum.save!
      end

      def migrate_meta_dates

        ids = RawMetaDatum
          .select("meta_data.id")
          .joins(:meta_key).where("meta_keys.object_type = 'MetaDate'")
          .where("type is NULL or type = 'MetaDatum'")

        RawMetaDatum.where("id in (#{ids.to_sql})").each do |rmd|
          migrate_meta_date rmd
          rmd.update_column :type, "MetaDatumDate"
        end

        MetaKey.where("object_type = 'MetaDate'").each do |mk|
          mk.update_attributes object_type: nil
          mk.update_attributes meta_datum_object_type: 'MetaDatumDate'
        end


      end


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

      ############ MetaDepartment ########################################
      def migrate_meta_datum_department rmd
        mdp = MetaDatumPerson.find rmd.id
        YAML.load(rmd.value).each do |pid|
          mdp.people << MetaDepartment.find(pid)
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
          migrate_meta_person rmd
        end

        MetaKey.where("object_type = 'MetaDepartment'").each do |mkp|
          mkp.update_column :object_type, nil
          mkp.update_column :meta_datum_object_type, 'MetaDatumDepartment'
        end

      end


    end
  end
end
