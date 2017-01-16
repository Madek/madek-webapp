class AddMissingFkeys < ActiveRecord::Migration
  def change
    add_foreign_key :hidden_fields, :fields, on_delete: :cascade
    add_foreign_key :hidden_fields, :users, on_delete: :cascade
    add_foreign_key :mail_templates, :inventory_pools, on_delete: :cascade
    add_foreign_key :mail_templates, :languages, on_delete: :cascade

    add_foreign_key :procurement_category_inspectors, :users
    add_foreign_key :procurement_requests, :locations
    add_foreign_key :procurement_requests, :models
    add_foreign_key :procurement_requests, :suppliers
    add_foreign_key :procurement_requests, :users
    add_foreign_key :procurement_templates, :models
    add_foreign_key :procurement_templates, :suppliers

    add_foreign_key :images, :images, column: :parent_id, name: :fkey_images_images_parent_id
  end
end
