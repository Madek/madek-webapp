module MigrationHelpers
  module MetaDatum
    class << self

      def migrate_meta_datum_keyword rmd
        mdp = MetaDatumKeywords.find rmd.id
        YAML.load(rmd.value).find_all{|id| id.to_i != 0}.each do |id|
            next unless k = Keyword.where(:id => id).first
            if k.meta_datum_id.nil?
              k.update_attributes(:meta_datum => mdp)
            else
              new_k = k.dup 
              new_k.update_attributes(:meta_datum => mdp)
            end
        end
        mdp.update_column :value, nil
        mdp.save!
      end

      def migrate_meta_datum_keywords
        RawMetaDatum.joins(:meta_key)
        .where("meta_keys.object_type = 'Keyword'")
        .where("type is NULL OR type = 'MetaDatum'").each do |rmd|
          rmd.update_column :type, "MetaDatumKeywords"
          migrate_meta_datum_keyword rmd
        end
        
        Keyword.delete_all(:meta_datum_id => nil)

        MetaKey.where("object_type = 'Keyword'").each do |mkp|
          mkp.update_column :object_type, nil
          mkp.update_column :meta_datum_object_type, 'MetaDatumKeywords'
        end
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
