class RemoveProcurementMainCategoriesColumns < ActiveRecord::Migration[4.2]

  def change
    [
      :image_file_name, :image_file_size, :image_content_type, :image_updated_at
    ].each do |col|
      if ActiveRecord::Base.connection.column_exists? :procurement_attachments, col
        remove_column :procurement_main_categories, col
      end
    end
  end
end
