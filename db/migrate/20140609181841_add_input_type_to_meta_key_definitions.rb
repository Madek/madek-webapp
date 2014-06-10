class AddInputTypeToMetaKeyDefinitions < ActiveRecord::Migration
  def change
    add_column :meta_key_definitions, :input_type, :integer
  end
end
