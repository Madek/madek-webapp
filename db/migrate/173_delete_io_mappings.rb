class DeleteIoMappings < ActiveRecord::Migration
  def change
    execute "DELETE FROM io_mappings"
  end
end
