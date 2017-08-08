class RefactorImagesColumns < ActiveRecord::Migration[4.2]

  def change
    remove_column :images, :height
    remove_column :images, :width
    remove_column :images, :is_main

    add_column :images, :thumbnail_tmp, :boolean, default: false
    execute <<-SQL
      UPDATE images
      SET thumbnail_tmp = TRUE
      WHERE thumbnail = 'thumb'
    SQL
    remove_column :images, :thumbnail
    rename_column :images, :thumbnail_tmp, :thumbnail
  end
end

