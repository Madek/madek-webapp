class AddStringToMetaDatum < ActiveRecord::Migration
  def change
    add_column :meta_data, :string, :text
  end
end
