class AddHighlightOnMediaResourceArcs < ActiveRecord::Migration
  def up
    add_column  :media_resource_arcs, :highlight, :boolean, default: false
  end

  def down
    remove_column :media_resource_arcs, :highlight
  end
end
