class CreateIoInterfaces < ActiveRecord::Migration
  include MigrationHelper

  def change

    create_table :io_interfaces, id: false  do |t|
      t.string :id, null: false, primary_key: true
      t.string :description
      t.timestamps null: false
    end

    reversible do |dir|
      dir.up do 
        set_timestamps_defaults :io_interfaces
      end
    end


  end
end
