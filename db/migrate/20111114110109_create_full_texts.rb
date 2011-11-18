class CreateFullTexts < ActiveRecord::Migration
  def up
    create_table(:full_texts) do |t| #with fulltext index# , :options => "ENGINE=MyISAM"
      t.belongs_to  :resource, :polymorphic => true
      t.text        :text
    end
    
    change_table :full_texts do |t|
      t.index [:resource_id, :resource_type], :unique => true
    end
    
    MediaResource.reindex
    
    #with fulltext index#
    # execute "ALTER TABLE full_texts ADD FULLTEXT INDEX (text);"
  end

  def down
    drop_table :full_texts
  end
end
