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
  end

  def self.down
    drop_table :terms
  end
end
