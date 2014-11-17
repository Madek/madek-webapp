class RenameMetaDataTypes < ActiveRecord::Migration
  def change
    reversible do |dir| 
      dir.up do

        execute "UPDATE meta_keys
                  SET meta_datum_object_type = 'MetaDatum::Text' 
                  WHERE meta_datum_object_type = 'MetaDatumString'"

        execute "UPDATE meta_data 
                  SET type = 'MetaDatum::Text' 
                  WHERE type = 'MetaDatumString'"


      end
    end
  end
end
