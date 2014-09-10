class CreateIoInterfaces < ActiveRecord::Migration
  def change

    create_table :io_interfaces, id: false  do |t|
      t.string :id, null: false, primary_key: true
      t.string :description
      t.timestamps
    end

    reversible do |dir|
      dir.up do 
        # execute 'ALTER TABLE io_interfaces ADD PRIMARY KEY (id)'
      end
    end


  end
end
