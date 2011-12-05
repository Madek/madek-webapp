class CreateMediasetUserpermissionJoins < ActiveRecord::Migration

  def up

    create_table :mediaset_userpermission_joins do |t|
      t.references :userpermission, :null => false
      t.references :media_set, :null => false
    end


  create_table :mediaentry_userpermission_joins do |t|
      t.references :userpermission, :null => false
      t.references :media_entry, :null => false
    end



  end

  def down

    drop_table :mediaentry_userpermission_joins

    drop_table :mediaset_userpermission_joins


  end

end
