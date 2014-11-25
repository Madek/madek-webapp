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

        ### #################################################

        execute "UPDATE meta_keys
                  SET meta_datum_object_type = 'MetaDatum::People' 
                  WHERE meta_datum_object_type = 'MetaDatumPeople'"

        execute "UPDATE meta_data 
                  SET type = 'MetaDatum::People' 
                  WHERE type = 'MetaDatumPeople'"

        ### #################################################

        execute "UPDATE meta_keys
                  SET meta_datum_object_type = 'MetaDatum::Keywords' 
                  WHERE meta_datum_object_type = 'MetaDatumKeywords'"

        execute "UPDATE meta_data 
                  SET type = 'MetaDatum::Keywords' 
                  WHERE type = 'MetaDatumKeywords'"


      end
    end
  end
end
