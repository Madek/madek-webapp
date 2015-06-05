class DropTemporaryTables < ActiveRecord::Migration
  def change
    # drop tables here that needed to be around for constraints
    drop_table :applications
  end
end
