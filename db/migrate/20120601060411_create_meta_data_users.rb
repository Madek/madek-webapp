class CreateMetaDataUsers < ActiveRecord::Migration
  include MigrationHelpers

  def up

    create_table :meta_data_users, :id => false do |t|
      t.belongs_to :meta_datum
      t.belongs_to :user
    end

    change_table :meta_data_users  do |t|
      t.index [:meta_datum_id, :user_id], unique: true
    end
    
    fkey_cascade_on_delete  :meta_data_users, ::MetaDatum
    fkey_cascade_on_delete  :meta_data_users, ::User

  end

  def down
    drop_table :meta_data_users
  end

end
