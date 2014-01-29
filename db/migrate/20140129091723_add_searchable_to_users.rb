class AddSearchableToUsers < ActiveRecord::Migration

  def create_text_index t,c
    execute "CREATE INDEX ON #{t.to_s} USING gin(to_tsvector('english',#{c.to_s}));"
  end

  def up
    add_column :users, :searchable, :text, default: "", null: false
    User.all.each do |user| 
      user.update_searchable
    end
    create_text_index :users, :searchable
  end

  def down
    remove_column :users, :searchable
  end

end
