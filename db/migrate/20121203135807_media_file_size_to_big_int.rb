class MediaFileSizeToBigInt < ActiveRecord::Migration
  def change
    change_column :media_files, :size, :bigint
  end
  def down
    raise  ActiveRecord::IrreversibleMigration.new("can't revert this migration")
  end
end
