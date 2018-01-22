class AddNoteToSuppliers < ActiveRecord::Migration[5.0]
  def change
    add_column :suppliers, :note, :text, default: ''
  end
end
