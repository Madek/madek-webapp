class RemoveNestetSetFromCopyrights < ActiveRecord::Migration
  def up
    remove_column :copyrights, :lft
    remove_column :copyrights, :rgt
    execute "ALTER TABLE copyrights ADD CONSTRAINT parent_id_fkey FOREIGN KEY (parent_id) REFERENCES copyrights (id)"
  end

  def down
    raise "irreversible" 
  end

end
