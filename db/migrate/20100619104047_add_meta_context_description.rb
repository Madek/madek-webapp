# -*- encoding : utf-8 -*-
class AddMetaContextDescription < ActiveRecord::Migration
  def self.up
    add_column :meta_contexts, :description, :text
  end

  def self.down
    remove_column :meta_contexts, :description
  end
end
