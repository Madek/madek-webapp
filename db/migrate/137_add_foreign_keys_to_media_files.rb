class AddForeignKeysToMediaFiles < ActiveRecord::Migration
  def change
    add_foreign_key :media_files, :users, column: :uploader_id
  end
end
