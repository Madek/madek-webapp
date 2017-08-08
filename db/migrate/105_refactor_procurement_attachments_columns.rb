class RefactorProcurementAttachmentsColumns < ActiveRecord::Migration[4.2]

  def change
    remove_column :procurement_attachments, :updated_at
  end

end
