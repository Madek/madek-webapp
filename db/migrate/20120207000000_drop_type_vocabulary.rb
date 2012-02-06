class DropTypeVocabulary < ActiveRecord::Migration

  def up
    drop_table :type_vocabularies
  end

  def down
    create_table      :type_vocabularies, :force => true do |t|
      t.string        :term_name
      t.string        :label
      t.string        :definition
      t.text          :comment
    end

  end
end
