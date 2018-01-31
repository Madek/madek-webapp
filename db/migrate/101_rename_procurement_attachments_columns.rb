class RenameProcurementAttachmentsColumns < ActiveRecord::Migration[4.2]

  def change
    if ActiveRecord::Base.connection.table_exists? :procurement_attachments
      # when migrating from pre-v4 leihs, table exists, so rename columns:
      rename_column :procurement_attachments, :file_file_name, :filename
      rename_column :procurement_attachments, :file_content_type, :content_type
      rename_column :procurement_attachments, :file_file_size, :size
      rename_column :procurement_attachments, :file_updated_at, :updated_at
    else
      # otherwise create everything from scratch
      create_table :procurement_attachments, id: :uuid do |t|
        t.uuid :request_id
        t.string :filename
        t.string :content_type
        t.integer :size
        t.datetime :updated_at
        t.text :content
      end
      add_foreign_key(:procurement_attachments, :procurement_requests, column: 'request_id')
    end
  end
end
