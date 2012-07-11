module MigrationHelpers
  module MetaDatum
    class << self

      def migrate_meta_datum_keyword rmd
        mdp = MetaDatumKeywords.find rmd.id
        ids = YAML.load(rmd.value)
        Keyword.where(:id => ids).each do |keyword|
          keyword = keyword.dup unless keyword.meta_datum_id.nil? 
          keyword.update_attributes(:meta_datum => mdp)
        end
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
                
        Keyword.delete_all(:meta_datum_id => nil)

        MetaKey.update_all({object_type: nil, meta_datum_object_type: 'MetaDatumKeywords'},
                           {object_type: 'Keyword'})
      end

    end
  end
end



class MigrateMetaDatumKeywords < ActiveRecord::Migration
  include MigrationHelpers
    
  def up
    change_table :keywords  do |t|
      t.belongs_to :meta_datum
      t.index :meta_datum_id
    end
    
    fkey_cascade_on_delete  :keywords, ::MetaDatum

    MigrationHelpers::MetaDatum.migrate_meta_datum_keywords
  end

  def down
    # raise "this is a irreversible migration"
  end
end
