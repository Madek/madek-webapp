class CreateVocabularyPermissions < ActiveRecord::Migration
  def change

    change_table :vocabularies do |t|
      t.boolean :enabled_for_public_view, default: true, null: false 
      t.boolean :enabled_for_public_use, default: true, null: false 
    end

    %w(user api_client group).each do |entity| 
      create_table "vocabulary_#{entity}_permissions", id: :uuid do |t| 
        t.uuid "#{entity}_id", null: false
        t.string :vocabulary_id, null: false
        t.index ["#{entity}_id",:vocabulary_id], name: "idx_vocabulary_#{entity}",unique: true
        t.boolean :use, default: false, null: false
        t.boolean :view, default: true, null: false
      end

      add_foreign_key "vocabulary_#{entity}_permissions", "#{entity.pluralize}", on_delete: :cascade
      add_foreign_key "vocabulary_#{entity}_permissions", :vocabularies, on_delete: :cascade
    end


  end

end
