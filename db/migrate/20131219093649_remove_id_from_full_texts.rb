class RemoveIdFromFullTexts < ActiveRecord::Migration
  def up
    remove_column :full_texts, :id
    execute %[ALTER TABLE full_texts ADD PRIMARY KEY (media_resource_id)]
  end
end
