# -*- encoding : utf-8 -*-
class CreateMediaResourceArcs < ActiveRecord::Migration

  def change
    create_table :media_resource_arcs, id: :uuid do |t|

      t.uuid :parent_id, null: false
      t.uuid :child_id, null: false

      t.boolean :highlight, default: false
      t.boolean :cover

    end

    add_index :media_resource_arcs, [:parent_id,:child_id], unique: true
    add_index :media_resource_arcs, [:child_id,:parent_id], unique: true
    add_index :media_resource_arcs, :cover
    add_index :media_resource_arcs, :parent_id
    add_index :media_resource_arcs, :child_id

    add_foreign_key :media_resource_arcs, :media_resources, column: :child_id, dependent: :delete
    add_foreign_key :media_resource_arcs, :media_resources, column: :parent_id, dependent: :delete

    reversible do |dir|
      dir.up do 
      execute "ALTER TABLE media_resource_arcs  ADD CHECK (parent_id <> child_id);"
      end
    end

  end
end

