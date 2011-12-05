class CreateMediasetUserpermissionJoins < ActiveRecord::Migration

  def up

    create_table :mediaset_userpermission_joins do |t|
      t.references :userpermission, :null => false
      t.references :media_set, :null => false
    end

  add_index :mediaset_userpermission_joins, :userpermission_id
  add_index :mediaset_userpermission_joins, :media_set_id


  create_table :mediaentry_userpermission_joins do |t|
      t.references :userpermission, :null => false
      t.references :media_entry, :null => false
    end

  add_index :mediaentry_userpermission_joins, :userpermission_id
  add_index :mediaentry_userpermission_joins, :media_entry_id




  end

  def down

    drop_table :mediaentry_userpermission_joins

    drop_table :mediaset_userpermission_joins


  end

end
