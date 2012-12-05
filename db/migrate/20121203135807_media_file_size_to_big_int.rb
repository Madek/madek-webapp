class MediaFileSizeToBigInt < ActiveRecord::Migration
  def change
    change_column :media_files, :size, :bigint
  end
end
