class AddFilenamextensionToMediafile < ActiveRecord::Migration

  class MediaFile < ActiveRecord::Base
  end

  def up

    add_column :media_files, :extension, :string 

    MediaFile.where("filename IS NOT null").select("id,filename,extension").each do |mf|
      mf.update_attribute :extension, File.extname(mf.filename).downcase.gsub(/^\./,'')
    end

    add_index :media_files, :extension
    add_index :media_files, :content_type

  end

  def down
    remove_column :media_files, :extension
  end

end
