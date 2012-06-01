module MigrationHelpers
  module MetaDatum
    class << self

      def migrate_meta_datum_keyword rmd
        puts "migrating #{rmd}"
        mdp = MetaDatumKeywords.find rmd.id
        YAML.load(rmd.value).find_all{|id| id.to_i != 0}.each do |id|
            md = Keyword.find_by_id(id)
            mdp.keywords <<  md unless (not md) or mdp.keywords.include?(md)
        end
        mdp.update_column :value, nil
        mdp.save!
      end

      def migrate_meta_datum_keywords
      
        ids = RawMetaDatum
          .select("meta_data.id")
          .joins(:meta_key).where("meta_keys.object_type = 'Keyword'")
          .where("type is NULL OR type = 'MetaDatum'")

        RawMetaDatum.where("id in (#{ids.to_sql})").each do |rmd|
          rmd.update_column :type, "MetaDatumKeywords"
          migrate_meta_datum_keyword rmd
        end

        MetaKey.where("object_type = 'Keyword'").each do |mkp|
          mkp.update_column :object_type, nil
          mkp.update_column :meta_datum_object_type, 'MetaDatumKeywords'
        end

      end


    end
  end
end



class MigrateMetaDatumKeywords < ActiveRecord::Migration
  def up
    MigrationHelpers::MetaDatum.migrate_meta_datum_keywords
  end

  def down
    # raise "this is a irreversible migration"
  end
end
