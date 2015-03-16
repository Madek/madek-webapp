class MigrateIsAttributesToQuestionmarks < ActiveRecord::Migration
  def change
    rename_column :custom_urls, :is_primary, :primary?
  end
end
