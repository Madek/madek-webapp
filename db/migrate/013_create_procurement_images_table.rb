class CreateProcurementImagesTable < ActiveRecord::Migration[4.2]

  def change
    create_table :procurement_images, id: :uuid do |t|
      t.uuid :main_category_id, null: false
      t.string :content_type, null: false
      t.string :content, null: false
      t.string :filename, null: false
      t.integer :size
      t.uuid :parent_id
    end
    add_foreign_key(:procurement_images, :procurement_main_categories,
                    column: 'main_category_id')
    add_foreign_key(:procurement_images, :procurement_images,
                    column: 'parent_id')
  end

end
