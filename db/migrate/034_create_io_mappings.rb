class CreateIoMappings < ActiveRecord::Migration
  include MigrationHelper
  def change
    create_table :io_mappings, id: false do |t|
      t.string :io_interface_id, nil: false
      t.string :meta_key_id, nil: false
      t.string :key_map, nil: false
      t.string :key_map_type
      t.timestamps
    end

    add_foreign_key :io_mappings, :meta_keys, dependent: :delete
    add_foreign_key :io_mappings, :io_interfaces, dependent: :delete

    reversible do |dir|
      dir.up do
        execute 'ALTER TABLE io_mappings ADD PRIMARY KEY (io_interface_id,meta_key_id)'
        set_timestamps_defaults :io_mappings
      end
    end
  end

end
