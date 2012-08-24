# -*- encoding : utf-8 -*-
class CreateMediaResourceArcs < ActiveRecord::Migration
  include MigrationHelpers

  def up
    create_table :media_resource_arcs do |t|

      t.integer :parent_id, null: false
      t.integer :child_id, null: false

      t.boolean :highlight, default: false
      t.boolean :cover

    end

    add_index :media_resource_arcs, [:parent_id,:child_id], unique: true
    add_index :media_resource_arcs, :cover
    add_index :media_resource_arcs, :parent_id
    add_index :media_resource_arcs, :child_id

    add_foreign_key :media_resource_arcs, :media_resources, column: :child_id, dependent: :delete
    add_foreign_key :media_resource_arcs, :media_resources, column: :parent_id, dependent: :delete


    add_check :media_resource_arcs, "(parent_id <> child_id)"

  end

  def down
    drop_table :media_resource_arcs
  end

end

