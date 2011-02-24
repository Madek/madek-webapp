# -*- encoding : utf-8 -*-
class CreateTerms < ActiveRecord::Migration
  def self.up
    create_table  :terms, :force => true do |t|
      t.string    :en_GB
      t.string    :de_CH
    end
    change_table    :terms do |t|
      t.index       [:en_GB, :de_CH]
    end

    MetaKeyDefinition.all.each do |mkd|
      [:label, :description, :hint].each do |attr|
        mkd.field.send("#{attr}=", mkd.field.send(attr).ivars) if mkd.field.send(attr).respond_to? :ivars
      end
      mkd.field.options = mkd.field.options unless mkd.field.options.nil?
      mkd.save
    end
  end

  def self.down
    drop_table :terms
  end
end
