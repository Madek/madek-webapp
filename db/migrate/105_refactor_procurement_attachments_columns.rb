class RefactorProcurementAttachmentsColumns < ActiveRecord::Migration

  def change
    remove_column :procurement_attachments, :updated_at
  end

end
