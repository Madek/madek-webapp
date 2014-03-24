class CreateApplications < ActiveRecord::Migration
  def up

    create_table :applications, id: false do |t|
      t.uuid :user_id, null: false
      t.string :id, null: false
      t.text :description
      t.uuid :secret, default: 'uuid_generate_v4()', null: false
    end

    add_foreign_key :applications, :users

    execute %[ALTER TABLE applications ADD PRIMARY KEY (id)]

  end

  def down
    drop_table :applications
  end

end
