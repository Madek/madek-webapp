class CreateUsageTerms < ActiveRecord::Migration
  def self.up
    create_table :usage_terms do |t|
      t.string :title
      t.string :version
      t.text :intro
      t.text :body
      t.datetime :updated_at
    end
  
  end

  def self.down
    drop_table :usage_terms
  end
end
