class AddMetaDatumDate < ActiveRecord::Migration

  def change
    add_column :meta_data, :meta_date_from, :integer
    add_column :meta_data, :meta_date_to, :integer
  end

end
