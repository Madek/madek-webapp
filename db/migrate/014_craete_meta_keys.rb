class CraeteMetaKeys < ActiveRecord::Migration

  def up
    create_table :meta_keys do |t|

      t.boolean :is_dynamic
      t.boolean :is_extensible_list

      t.string  :label
      t.string  :meta_datum_object_type
    end

    add_index :meta_keys, :label, unique: true

  end

  def down
    drop_table :meta_keys
  end

end
