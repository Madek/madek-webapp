class RefactorAttachmentsColumns < ActiveRecord::Migration

  def change
    remove_column :attachments, :is_main
  end

end
