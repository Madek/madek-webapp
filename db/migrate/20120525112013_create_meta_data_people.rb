class CreateMetaDataPeople < ActiveRecord::Migration
  include MigrationHelpers

  def up

    create_table :meta_data_people, :id => false do |t|
      t.belongs_to :meta_datum
      t.belongs_to :person
    end

    change_table :meta_data_people  do |t|
      t.index [:meta_datum_id, :person_id], unique: true
    end
    
    fkey_cascade_on_delete  :meta_data_people, ::MetaDatum
    fkey_cascade_on_delete  :meta_data_people, ::Person

  end

  def down
    drop_table :meta_data_people
  end

end
