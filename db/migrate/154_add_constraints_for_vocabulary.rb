class AddConstraintsForVocabulary < ActiveRecord::Migration
  def change
    add_foreign_key :meta_keys, :vocabularies, dependent: :delete
    add_foreign_key :vocables, :meta_keys, dependent: :delete
    add_foreign_key :meta_data_vocables, :meta_data, dependent: :delete
    add_foreign_key :meta_data_vocables, :vocables, dependent: :delete
  end
end
