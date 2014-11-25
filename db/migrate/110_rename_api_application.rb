class RenameApiApplication < ActiveRecord::Migration
  def change
    rename_table :applications, :api_clients
  end
end
