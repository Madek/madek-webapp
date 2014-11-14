class AddCreatorAndResponsibleUser < ActiveRecord::Migration
  include MigrationHelper

  def change

    %w( media_entries collections filter_sets).each do |table_name|
      change_table table_name  do |t|
        t.uuid :responsible_user_id
        t.index :responsible_user_id

        t.uuid :creator_id, null: true
        t.index :creator_id
      end
    end


    reversible do |dir|
      dir.up do

        execute "UPDATE media_entries 
                 SET responsible_user_id = media_resources.user_id
                 FROM media_resources
                 WHERE media_resources.id = media_entries.id"

        execute "UPDATE collections 
                 SET responsible_user_id = media_resources.user_id
                 FROM media_resources
                 WHERE media_resources.id = collections.id"

        execute "UPDATE filter_sets 
                 SET responsible_user_id = media_resources.user_id
                 FROM media_resources
                 WHERE media_resources.id = filter_sets.id"
      end

    end

    %w(media_entries collections filter_sets).each do |table_name|
      change_column table_name, :responsible_user_id, :uuid, null: false 
      add_foreign_key table_name, :users, column: :responsible_user_id
      add_foreign_key table_name, :users, column: :creator_id
    end

    reversible do |dir|
      dir.up do 
        execute "ALTER TABLE media_resources DROP COLUMN user_id CASCADE"
      end
      dir.down do
        add_column :media_resources, :user_id, :uuid
      end
    end



  end

end
