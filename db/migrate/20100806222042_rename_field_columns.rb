# -*- encoding : utf-8 -*-
class RenameFieldColumns < ActiveRecord::Migration
  def self.up
    rename_column(:meta_contexts, :field, :meta_field)
    rename_column(:meta_key_definitions, :field, :meta_field)
  end

  def self.down
    rename_column(:meta_contexts, :meta_field, :field)
    rename_column(:meta_key_definitions, :meta_field, :field)
  end
end
