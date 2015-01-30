class UuidPkeyForIoMapping < ActiveRecord::Migration
  def change
    add_column  :io_mappings, :id, :uuid, nil: false, default: 'uuid_generate_v4()'
    execute "ALTER TABLE io_mappings DROP CONSTRAINT io_mappings_pkey;";
    add_index :io_mappings, :id, name: :io_mappings_pkey, unique: true
    execute "ALTER TABLE io_mappings ADD CONSTRAINT io_mappings_pkey PRIMARY KEY USING INDEX io_mappings_pkey; ";
  end
end
