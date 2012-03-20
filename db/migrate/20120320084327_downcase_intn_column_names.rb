class DowncaseIntnColumnNames < ActiveRecord::Migration
  def up
    rename_column(:meta_terms, :en_GB, :en_gb)
    rename_column(:meta_terms, :de_CH, :de_ch)
  end

  def down
    rename_column(:meta_terms, :en_gb, :en_GB)
    rename_column(:meta_terms, :de_ch, :de_CH)
  end
end
