require 'sqlhelper'

class RefactorMetaTerms < ActiveRecord::Migration
  def self.up
    MetaKey.update_all({:object_type => "Meta::Term"}, {:object_type => "Term"})
    rename_table :terms, :meta_terms
    rename_table :meta_keys_terms, :meta_keys_meta_terms
    rename_column :meta_keys_meta_terms, :term_id, :meta_term_id
    rename_column :keywords, :term_id, :meta_term_id

    change_table :meta_keys do |t|
      t.boolean :is_extensible_list, :null => true
    end

    sql = <<-SQL
      ALTER SEQUENCE terms_id_seq RENAME TO meta_terms_id_seq;
    SQL
    execute sql if SQLHelper.adapter_is_postgresql? 

  end

  def self.down
    drop_table :meta_lists

    rename_column :keywords, :meta_term_id, :term_id
    rename_column :meta_keys_meta_terms, :meta_term_id, :term_id
    rename_table :meta_keys_meta_terms, :meta_keys_terms
    MetaKey.update_all({:object_type => "Term"}, {:object_type => "Meta::Term"})
  end
end
