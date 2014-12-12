class CreateUsageTerms < ActiveRecord::Migration
  include MigrationHelper

  def change
    create_table :usage_terms, id: :uuid  do |t|
      t.string :title
      t.string :version
      t.text :intro
      t.text :body
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        set_timestamps_defaults :usage_terms
      end
    end
  end
end
