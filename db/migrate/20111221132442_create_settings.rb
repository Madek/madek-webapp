class CreateSettings < ActiveRecord::Migration
  def up
    create_table :settings, :force => true do |t|
      t.string  :var,         :null => false
      t.text    :value
      t.integer :target_id
      t.string  :target_type, :limit => 30
      t.timestamps
    end
    add_index :settings, [ :target_type, :target_id, :var ], :unique => true
  end

  def down
    drop_table :settings
  end
end
