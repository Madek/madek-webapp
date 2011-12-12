class DagToDg < ActiveRecord::Migration
  def up

    create_table :media_set_arcs do |t|
      t.integer :parent_id
      t.integer :child_id
    end
    add_index :media_set_arcs, :parent_id
    add_index :media_set_arcs, :child_id


    Media::SetLink.where(direct: true).each do |link|
      Media::SetArc.create child_id: link.descendant_id, parent_id: link.ancestor_id
    end

    drop_table :media_set_links

  end

  def down

    create_table :media_set_links do |t|
      t.integer :descendant_id
      t.integer :ancestor_id
      t.boolean :direct
      t.integer :count
    end
    add_index :media_set_links, :descendant_id
    add_index :media_set_links, :ancestor_id
    add_index :media_set_links, :direct

    Media::SetArc.all.each do |arc|
      Media::SetLink.create_edge arc.parent_id, arc.child_id 
    end

    drop_table :media_set_arcs
  end

end
