class AddNullRestrictionToUploaderId < ActiveRecord::Migration
  def change
    change_column :media_files, :uploader_id, :uuid, null: false
  end
end
