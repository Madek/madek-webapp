class CreateMetaKeyDefinitions < ActiveRecord::Migration
  include MigrationHelper

  def change
    create_table :meta_key_definitions, id: :uuid do |t|

      t.text :description, null: false, default: ''
      t.text :hint, null: false, default: ''
      t.text :label, null: false, default: ''

      t.string :context_id, null: false
      t.index :context_id

      t.string :meta_key_id, null: false
      t.index :meta_key_id

      t.boolean :is_required, default: false
      t.integer :length_max
      t.integer :length_min
      t.integer :position, null: false

      t.integer :input_type

      t.timestamps null: false
    end

    reversible do |dir|
      dir.up do
        set_timestamps_defaults :meta_key_definitions
      end
    end

    add_foreign_key :meta_key_definitions, :meta_keys
    add_foreign_key :meta_key_definitions, :contexts
  end

end
