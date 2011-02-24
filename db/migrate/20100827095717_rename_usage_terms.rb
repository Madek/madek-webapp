class RenameUsageTerms < ActiveRecord::Migration
  def self.up
    rename_table :use_terms, :usage_terms
    
    rename_column :users, :use_terms_accepted_at, :usage_terms_accepted_at
  end

  def self.down
    rename_column :users, :usage_terms_accepted_at, :use_terms_accepted_at

    rename_table :usage_terms, :use_terms
  end
end
