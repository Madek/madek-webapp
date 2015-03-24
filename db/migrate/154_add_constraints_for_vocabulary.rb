class AddConstraintsForVocabulary < ActiveRecord::Migration
  def change
    add_foreign_key :meta_keys, :vocabularies, on_delete: :cascade
    add_foreign_key :vocables, :meta_keys, on_delete: :cascade
    add_foreign_key :meta_data_vocables, :meta_data, on_delete: :cascade
    add_foreign_key :meta_data_vocables, :vocables, on_delete: :cascade
  end
end
