# -*- encoding : utf-8 -*-

class Media::FeaturedSet < MediaSet
end

class MediaSetLink < ActiveRecord::Base
  def self.table_name_prefix
    "media_"
  end

  # TODO use dagnabit gem instead ??
  acts_as_dag_links :node_class_name => 'MediaSet'  
end

class DagToDg < ActiveRecord::Migration
  include MigrationHelpers

  def up

    create_table :media_set_arcs do |t|
      t.integer :parent_id, :null => false
      t.integer :child_id, :null => false
    end

    add_index :media_set_arcs, :parent_id
    add_index :media_set_arcs, :child_id
    add_index :media_set_arcs, [:parent_id, :child_id], :unique => true

    if adapter_is_postgresql?
      cascade_on_delete :media_set_arcs,  :media_sets, :parent_id
      cascade_on_delete :media_set_arcs, :media_sets, :child_id
      add_check :media_set_arcs, "(parent_id <> child_id)"
    end


#    MediaSetLink.where(direct: true).each do |link|
#      if (MediaSet.exists? link.descendant_id) \
#        and (MediaSet.exists? link.ancestor_id) \
#        and link.descendant_id != link.ancestor_id
#          MediaSetArc.create child_id: link.descendant_id, parent_id: link.ancestor_id
#      end
#    end

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

    MediaSetArc.all.each do |arc|
      MediaSetLink.create_edge arc.parent_id, arc.child_id 
    end

    drop_table :media_set_arcs
  end

end
