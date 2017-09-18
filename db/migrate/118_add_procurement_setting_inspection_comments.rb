class AddProcurementSettingInspectionComments < ActiveRecord::Migration[5.0]

  def change
    add_column :procurement_settings, :inspection_comments, :jsonb, :default => []
  end

end
