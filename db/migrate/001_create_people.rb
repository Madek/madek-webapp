# -*- encoding : utf-8 -*-
class CreatePeople < ActiveRecord::Migration

  def change

    create_table    :people do |t|
      t.boolean     :is_group, :default => false
      t.date        :birthdate
      t.date        :deathdate
      t.string      :firstname
      t.string      :lastname
      t.string      :nationality
      t.string      :pseudonym
      t.text        :wiki_links

      t.timestamps
    end

    add_index :people, :firstname
    add_index :people, :is_group
    add_index :people, :lastname

  end

end
