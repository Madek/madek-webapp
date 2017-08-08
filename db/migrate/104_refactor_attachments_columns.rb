class RefactorAttachmentsColumns < ActiveRecord::Migration[4.2]

  def change
    remove_column :attachments, :is_main
  end

end
