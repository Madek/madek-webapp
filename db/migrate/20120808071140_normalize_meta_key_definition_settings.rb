module NormalizeMetaKeyDefinitionSettingsMigration
  class MetaKeyDefinition < ActiveRecord::Base
    table_name = :meta_key_definitions
    # serialize is not reliable 
    # serialize :settings, Hash
  end
end


class NormalizeMetaKeyDefinitionSettings < ActiveRecord::Migration

  def up
    add_column :meta_key_definitions, :is_required, :boolean, nil: false, default: false
    add_column :meta_key_definitions, :length_max, :integer
    add_column :meta_key_definitions, :length_min, :integer
    NormalizeMetaKeyDefinitionSettings::MetaKeyDefinition.all.each do |mkd|
      if mkd.settings 
        YAML.load(mkd.settings).each do |k,v|
          mkd.update_column k,v
        end
      end
    end
    remove_column :meta_key_definitions, :settings
  end

  def down
    raise "irreversible mirgration" 
  end

end
