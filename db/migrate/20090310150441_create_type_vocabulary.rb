# -*- encoding : utf-8 -*-
class CreateTypeVocabulary < ActiveRecord::Migration
  def self.up
    create_table      :type_vocabularies, :force => true do |t|
      t.string        :term_name
      t.string        :label
      t.string        :definition
      t.text          :comment
    end

  end

  def self.down
    drop_table        :type_vocabularies
  end
end
