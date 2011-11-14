class CreateFullTexts < ActiveRecord::Migration
  def up
    create_table(:full_texts, :options => "ENGINE=MyISAM") do |t|
      t.belongs_to  :resource, :polymorphic => true
      t.text        :text
    end
    
    change_table :full_texts do |t|
      t.index [:resource_id, :resource_type], :unique => true
    end
    
    MediaResource.reindex
    
    execute "ALTER TABLE full_texts ADD FULLTEXT INDEX (text);"
  end

  def down
    drop_table :full_texts
  end
end
