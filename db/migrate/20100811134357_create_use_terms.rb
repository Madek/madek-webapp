class CreateUseTerms < ActiveRecord::Migration
  def self.up
    create_table :use_terms do |t|
      t.string :title
      t.string :version
      t.text :intro
      t.text :body
      t.datetime :updated_at
    end
  
    change_table :users do |t|
      t.datetime :use_terms_accepted_at
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :use_terms_accepted_at
    end

    drop_table :use_terms
  end
end
