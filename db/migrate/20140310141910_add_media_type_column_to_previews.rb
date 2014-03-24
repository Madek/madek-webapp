class AddMediaTypeColumnToPreviews < ActiveRecord::Migration
  def up
    add_column :previews, :media_type, :string

    Preview.find_each do |p| 
      p.set_media_type
      p.save!
    end

    change_column :previews, :media_type, :string, null: false
    change_column :previews, :content_type, :string, null: false

    add_index :previews, :media_type
    add_index :previews, :created_at

    change_column :media_files, :media_type, :string, null: false
    change_column :media_files, :content_type, :string, null: false


  end

  def down
    remove_column :previews, :media_type
  end
end
