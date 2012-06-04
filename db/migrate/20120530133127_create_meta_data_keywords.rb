class CreateMetaDataKeywords < ActiveRecord::Migration
  include MigrationHelpers

  def up

    create_table :meta_data_keywords, :id => false do |t|
      t.belongs_to :meta_datum
      t.belongs_to :keyword
    end

    change_table :meta_data_keywords  do |t|
      t.index [:meta_datum_id, :keyword_id], unique: true
    end
    
    fkey_cascade_on_delete  :meta_data_keywords, ::MetaDatum
    fkey_cascade_on_delete  :meta_data_keywords, ::Keyword

  end

  def down
    drop_table :meta_data_keywords
  end


end
