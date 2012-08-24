# -*- encoding : utf-8 -*-
class CreateMediaFiles< ActiveRecord::Migration

  def change
    create_table  :media_files do |t|
      t.integer   :height
      t.integer   :size
      t.integer   :width
      t.string    :content_type
      t.string    :filename   
      t.string    :guid
      t.string    :job_id      
      t.text      :access_hash 
      t.text      :meta_data   

      t.timestamps
    end
  end


end
