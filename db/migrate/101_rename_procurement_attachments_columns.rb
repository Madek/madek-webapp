class RenameProcurementAttachmentsColumns < ActiveRecord::Migration[4.2]

  def change
    rename_column :procurement_attachments, :file_file_name, :filename
    rename_column :procurement_attachments, :file_content_type, :content_type
    rename_column :procurement_attachments, :file_file_size, :size
    rename_column :procurement_attachments, :file_updated_at, :updated_at
  end
end
