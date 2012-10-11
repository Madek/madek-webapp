class AddMediaTypeToMediafile < ActiveRecord::Migration

  def up
    add_column :media_files, :media_type, :string 

    MediaFile.where(true).select("id,media_type,content_type").each do |mf|
      mf.update_attribute :media_type, MediaFile.media_type(mf.content_type)
    end

    add_index :media_files, :media_type
    remove_index :media_files, :content_type
  end

  def down
    remove_column :media_files, :media_type
    add_index :media_files, :content_type
  end

end
