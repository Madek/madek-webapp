module MigrationHelpers
  module MetaDatum
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


    end
  end
end

class AddStringToMetaDatum < ActiveRecord::Migration
  def change
    add_column :meta_data, :string, :text
  end
end
