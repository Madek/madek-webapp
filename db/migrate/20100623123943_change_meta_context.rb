# -*- encoding : utf-8 -*-
class ChangeMetaContext < ActiveRecord::Migration
  def self.up
    change_table  :meta_contexts do |t|
      t.string    :name
      t.text      :field      # serialized
    end

    MetaContext.reset_column_information

    MetaContext.all.each do |meta_context|
      name = meta_context.label.downcase.gsub(/\s+/, '_')
      field = {:label => {}, :description => {}}
      LANGUAGES.each do |lang|
        field[:label][lang] = meta_context.label
        field[:description][lang] = meta_context.description unless meta_context.description.blank?
      end
      meta_context.update_attributes(:name => name, :field => field)
    end

    remove_column(:meta_contexts, :label)
    remove_column(:meta_contexts, :description)

    change_table :meta_contexts do |t|      
      t.index :name, :unique => true
    end
  end

  def self.down
  end
end
