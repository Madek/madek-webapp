# -*- encoding : utf-8 -*-
class CreateMetaKeysMetaTerms < ActiveRecord::Migration

  def up

    create_table :meta_keys_meta_terms do |t|
      t.belongs_to :meta_key, null: false
      t.belongs_to :meta_term, null: false
      t.integer :position, default: 0, null: false
    end

    change_table :meta_keys_meta_terms do |t|
      t.index [:meta_key_id, :meta_term_id], :unique => true
      t.index :position
    end

    add_foreign_key :meta_keys_meta_terms, :meta_keys, dependent: :delete
    add_foreign_key :meta_keys_meta_terms, :meta_terms, dependent: :delete

  end

  def down
    drop_table :meta_keys_meta_terms
  end
end
