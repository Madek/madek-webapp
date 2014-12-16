class AddUploaderIdToMediaFiles < ActiveRecord::Migration
  def change
    add_column :media_files, :uploader_id, :uuid, index: true
  end
end
