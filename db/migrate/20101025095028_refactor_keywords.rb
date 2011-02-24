class RefactorKeywords < ActiveRecord::Migration
  def self.up

    create_table :keywords do |t|
      t.belongs_to :term
      t.belongs_to :user
      t.datetime :created_at
    end
    change_table :keywords do |t|
      t.index [:term_id, :user_id]
      t.index :user_id
      t.index :created_at
    end

    ##################################
    
    key = MetaKey.where(:label => "keywords").first
    if key
      key.update_attributes(:object_type => "Keyword")
      key.meta_data.each do |md|
        md.update_attributes(:value => md.value)
      end
    end
    
  end

  def self.down
  end
end
