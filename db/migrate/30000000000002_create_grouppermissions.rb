class CreateGrouppermissions < ActiveRecord::Migration
  def up
    create_table :grouppermissions do |t|

      t.belongs_to  :resource, :polymorphic => true, :null => false
      t.references :group, :null => false

      t.boolean :may_view, :default => false
      t.boolean :may_download, :default => false # high-res
      t.boolean :may_edit_metadata, :default => false 

      t.timestamps
    end

    # TODO can't constrain on fkey with polymorphic
    sql = <<-SQL

      ALTER TABLE grouppermissions ADD CONSTRAINT grouppermissions_group_id_fkey FOREIGN KEY (group_id) REFERENCES groups (id) ON DELETE CASCADE;

      CREATE INDEX grouppermissions_may_view_idx ON grouppermissions (may_view);

      CREATE INDEX grouppermissions_resource_id_idx on grouppermissions (resource_id);
      CREATE INDEX grouppermissions_group_id_idx on grouppermissions (group_id);

    SQL

    sql.split(/;\s*$/).each {|cmd| execute cmd} if SQLHelper.adapter_is_mysql?
    execute sql if SQLHelper.adapter_is_postgresql?

  end

  def down
    drop_table :grouppermissions
  end
end
