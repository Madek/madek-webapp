# -*- encoding : utf-8 -*-
class CreateFullTexts < ActiveRecord::Migration
  include MigrationHelper

  def change
    create_table :full_texts, id: false do |t|
      t.uuid :media_resource_id, null: false, primary_key: true
      t.text :text
    end

    reversible do |dir|
      dir.up do
        create_trgm_index :full_texts, :text
        create_text_index :full_texts, :text
      end
    end

    add_foreign_key :full_texts, :media_resources, on_delete: :cascade
  end

end
