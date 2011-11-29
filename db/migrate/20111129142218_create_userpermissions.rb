class CreateUserpermissions < ActiveRecord::Migration
  def up 
    create_table :userpermissions do |t|

      t.belongs_to  :resource, :polymorphic => true, :null => false
      t.references :user, :null => false

      t.boolean :may_view, :default => false
      t.boolean :maynot_view, :default => false

      t.boolean :may_download, :default => false # same as high-res
      t.boolean :maynot_download, :default => false

      t.boolean :may_edit_metadata, :default => false 
      t.boolean :maynot_edit_metadata, :default => false

      t.timestamps
    end

    # TODO can't constrain on fkey with polymorphic
    sql = <<-SQL

      ALTER TABLE userpermissions ADD CONSTRAINT userpermissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE;

      CREATE INDEX userpermissions_may_view_idx ON userpermissions (may_view);
      CREATE INDEX userpermissions_maynot_view_idx ON userpermissions (maynot_view);

      CREATE INDEX userpermissions_resource_id_idx on userpermissions (resource_id);
      CREATE INDEX userpermissions_user_id_idx on userpermissions (user_id);

    SQL

    sql.split(/;\s*$/).each {|cmd| execute cmd} if SQLHelper.adapter_is_mysql?
    execute sql if SQLHelper.adapter_is_postgresql?

  end


  def down
    drop_table :userpermissions
  end

end
