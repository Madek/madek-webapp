# -*- encoding : utf-8 -*-
class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table    :people do |t|
      t.string      :firstname
      t.string      :lastname
      t.string      :pseudonym
      t.date        :birthdate
      t.date        :deathdate
      t.string      :nationality
      t.text        :wiki_links

      t.boolean     :delta, :null => false, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :people
  end
end
