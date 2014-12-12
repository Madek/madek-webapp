class CreateMetaData < ActiveRecord::Migration

  def change
    create_table :meta_data, id: :uuid do |t|

      t.uuid :media_resource_id, null: false
      t.index :media_resource_id

      t.string :meta_key_id, null: false
      t.index :meta_key_id

      t.index [:media_resource_id, :meta_key_id], unique: :true

      t.string :type
      t.index :type

      t.text :string

      t.uuid :copyright_id
    end

    add_foreign_key :meta_data, :media_resources, dependent: :delete
    add_foreign_key :meta_data, :meta_keys

    add_foreign_key :meta_data, :copyrights
  end

end
