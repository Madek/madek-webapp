class AddPositionToCopyrights < ActiveRecord::Migration
  def change
    add_column :copyrights, :position, :float
    Copyright.where(parent_id: nil).each_with_index do |p, i|
      p.update_attribute(:position, i+1)
      p.children.each_with_index do |ch, j|
        ch.update_attribute(:position, j+1)
        update_position(ch)
      end
    end
  end

  def update_position(child)
    child.children.each_with_index do |ch, i|
      ch.update_attribute(:position, i+1)
      update_position(ch)
    end
  end
end
