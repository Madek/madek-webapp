class AddSearchableFieldToGroups < ActiveRecord::Migration
  def create_trgm_index t,c
    execute "CREATE INDEX ON #{t.to_s} USING gin(#{c.to_s} gin_trgm_ops);"
  end
  def create_text_index t,c
    execute "CREATE INDEX ON #{t.to_s} USING gin(to_tsvector('english',#{c.to_s}));"
  end


  def up
    add_column :groups, :searchable, :text, default: "", null: false 
    Group.all.each do |group| 
      group.update_searchable
    end
    create_trgm_index :groups, :searchable
    create_text_index :groups, :searchable
  end

  def down
    remove_column :groups, :searchable
  end
end
