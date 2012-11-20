class ChangeFkeyRaisOnPersonMetadata < ActiveRecord::Migration
  def up
    remove_foreign_key :meta_data_people, :people
    add_foreign_key :meta_data_people, :people
  end
  
  def down
    remove_foreign_key :meta_data_people, :people
    add_foreign_key :meta_data_people, :people, dependent: :delete
  end
end
