class AddSearcheableFieldToPeople < ActiveRecord::Migration

  def create_trgm_index t,c
    execute "CREATE INDEX ON #{t.to_s} USING gin(#{c.to_s} gin_trgm_ops);"
  end
  def create_text_index t,c
    execute "CREATE INDEX ON #{t.to_s} USING gin(to_tsvector('english',#{c.to_s}));"
  end


  def up
    add_column :people, :searchable, :text, default: "", null: false 
    Person.all.each do |person| 
      person.update_searchable
    end
    create_trgm_index :people, :searchable
    create_text_index :people, :searchable
  end

  def down
    remove_column :people, :searchable
  end

end
