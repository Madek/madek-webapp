class SetProperContentypeForMp4VideoPreviews < ActiveRecord::Migration
  def up
    Preview.where(content_type: 'video/mpeg4').each do |preview|
      preview.update_column :content_type, 'video/mp4'
    end
  end

  def down
  end
end
