# -*- encoding : utf-8 -*-
class CreateFullTexts < ActiveRecord::Migration

  def up
    create_table :full_texts do |t| 
      t.belongs_to  :media_resource, null: false
      t.text        :text
    end

    add_index :full_texts, :media_resource_id
    add_foreign_key :full_texts, :media_resources, dependent: :delete

  end

  def down
    drop_table :full_texts
  end

end
