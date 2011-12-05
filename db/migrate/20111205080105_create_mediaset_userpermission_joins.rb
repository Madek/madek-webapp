class CreateMediasetUserpermissionJoins < ActiveRecord::Migration
  include MigrationHelpers

  def up

    create_table :mediaset_userpermission_joins do |t|
      t.references :userpermission, :null => false
      t.references :media_set, :null => false
    end

  add_index :mediaset_userpermission_joins, :userpermission_id
  add_index :mediaset_userpermission_joins, :media_set_id
  fkey_cascade_on_delete :mediaset_userpermission_joins, :userpermission_id, :userpermissions
  fkey_cascade_on_delete :mediaset_userpermission_joins, :media_set_id, :media_sets


  create_table :mediaentry_userpermission_joins do |t|
      t.references :userpermission, :null => false
      t.references :media_entry, :null => false
    end

  add_index :mediaentry_userpermission_joins, :userpermission_id
  add_index :mediaentry_userpermission_joins, :media_entry_id
  fkey_cascade_on_delete :mediaentry_userpermission_joins, :userpermission_id, :userpermissions
  fkey_cascade_on_delete :mediaentry_userpermission_joins, :media_entry_id, :media_entries



  end

  def down

    drop_table :mediaentry_userpermission_joins

    drop_table :mediaset_userpermission_joins


  end

end
