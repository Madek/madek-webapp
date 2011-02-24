# -*- encoding : utf-8 -*-
class CreateMetaKeysTerms < ActiveRecord::Migration
  def self.up
    create_table :meta_keys_terms, :id => false, :force => true do |t|
      t.belongs_to :meta_key
      t.belongs_to :term
    end
    change_table :meta_keys_terms do |t|
      t.index [:meta_key_id, :term_id], :unique => true
    end

    MetaKeyDefinition.all.each do |mkd|
      if mkd.field.options
        mkd.field.options.each do |option|
          mkd.meta_key.terms << option
        end
        mkd.field.options = nil
        mkd.save
        mkd.meta_key.update_attributes(:object_type => "Term")
      end
    end
  end

  def self.down
    drop_table :meta_keys_terms
  end
end
