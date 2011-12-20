class CreateUserpermissions < ActiveRecord::Migration
  include MigrationHelpers
  include Constants

  def up 
    create_table :userpermissions do |t|

      t.belongs_to  :resource, :polymorphic => true, :null => false
      t.references :user, :null => false

      ACTIONS.each do |action|
        t.boolean "may_#{action}", :default => false
        t.boolean "maynot_#{action}", :default => false
      end

    end

    add_index :userpermissions, ref_id(User)
    fkey_cascade_on_delete :userpermissions, :user_id, :users
    
    ACTIONS.each do |action|
      add_index :userpermissions, "may_#{action}"
      add_index :userpermissions, "maynot_#{action}"
    end

  end


  def down
    drop_table :userpermissions
  end

end
