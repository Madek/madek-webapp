class AddConstraintsForVocabulary < ActiveRecord::Migration
  def change
    add_foreign_key :meta_keys, :vocabularies, on_delete: :cascade
    add_foreign_key :keyword_terms, :meta_keys, on_delete: :cascade
  end
end
