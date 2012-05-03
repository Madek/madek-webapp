class RenameUsageTerms < ActiveRecord::Migration
  include SQLHelper 

  def self.up
    rename_table :use_terms, :usage_terms
    rename_column :users, :use_terms_accepted_at, :usage_terms_accepted_at
    execute "ALTER SEQUENCE use_terms_id_seq RENAME TO usage_terms_id_seq;" if adapter_is_postgresql?
  end

  def self.down
    rename_column :users, :usage_terms_accepted_at, :use_terms_accepted_at
    rename_table :usage_terms, :use_terms
    execute "ALTER SEQUENCE usage_terms_id_seq RENAME TO use_terms_id_seq;" if adapter_is_postgresql?
  end
end
