class RemoveProcurementMainCategoriesColumns < ActiveRecord::Migration[4.2]

  def change
    remove_column :procurement_main_categories, :image_file_name
    remove_column :procurement_main_categories, :image_file_size
    remove_column :procurement_main_categories, :image_content_type
    remove_column :procurement_main_categories, :image_updated_at
  end
end
