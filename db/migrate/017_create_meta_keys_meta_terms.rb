# -*- encoding : utf-8 -*-
class CreateMetaKeysMetaTerms < ActiveRecord::Migration

  def change
    create_table :meta_keys_meta_terms, id: :uuid  do |t|
      t.string :meta_key_id, null: false
      t.index :meta_key_id

      t.uuid :meta_term_id, null: false

      t.index [:meta_key_id, :meta_term_id], unique: true

      t.integer :position, default: 0, null: false
      t.index :position
    end

    add_foreign_key :meta_keys_meta_terms, :meta_keys, dependent: :delete
    add_foreign_key :meta_keys_meta_terms, :meta_terms, dependent: :delete
  end

end
