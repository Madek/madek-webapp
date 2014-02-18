class AddTrgmSearchForUsers < ActiveRecord::Migration

  def create_trgm_index t,c
    execute "CREATE INDEX ON #{t.to_s} USING gin(#{c.to_s} gin_trgm_ops);"
  end


  def up
    add_column :users, :trgm_searchable, :text, default: "", null: false 
    User.all.each do |user| 
      user.update_trgm_searchable
    end
    create_trgm_index :users, :trgm_searchable
  end

  def down
    remove_column :users, :trgm_searchable
  end
end
