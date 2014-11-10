require Rails.root.join "db","migrate","media_resource_migration_models"

class AddCreatorAndResponsibleUser < ActiveRecord::Migration
  include MigrationHelper
  include MediaResourceMigrationModels

  def change

    rename_column :resources, :user_id, :responsible_user_id

    change_table :resources do |t|
      t.uuid :creator_id 
      t.uuid :updator_id
    end

    MigrationResource.reset_column_information

    MigrationResource.find_each do |mr|
      mr.creator_id= mr.migration_edit_sessions.first.try(:user_id) || mr.responsible_user_id 
      mr.updator_id= mr.migration_edit_sessions.last.try(:user_id) || mr.responsible_user_id
      mr.save!
    end

    reversible do |dir|
      dir.up do
        change_column :resources, :creator_id, :uuid, null: false
        change_column :resources, :updator_id, :uuid, null: false
      end
    end

    add_foreign_key :resources, :users, column: :creator_id
    add_foreign_key :resources, :users, column: :updator_id




    #
#    %w( media_entries collections filter_sets).each do |table_name|
#      change_table table_name  do |t|
#        t.uuid :responsible_user_id
#        t.index :responsible_user_id
#        t.uuid :creator_id, null: true
#        t.index :creator_id
#      end
#    end
#
#
#
#    ::MigrationMediaResource.find_each do |mr|
#      case mr.type
#      when 'MediaEntryResource'
#        MigrationMediaEntry.find(mr.id).update_attributes! responsible_user_id: mr.user_id
#      when 'CollectionResource'
#        MigrationCollection.find(mr.id).update_attributes! responsible_user_id: mr.user_id
#      when 'MediaResourceFilterSet'
#        MigrationFilterSet.find(mr.id).update_attributes! responsible_user_id: mr.user_id
#      else
#        raise "Illegal state" 
#      end
#    end
#
#    %w( media_entries collections filter_sets).each do |table_name|
#      change_column table_name, :responsible_user_id, :uuid, null: false 
#
#      add_foreign_key table_name, :users, column: :responsible_user_id
#      add_foreign_key table_name, :users, column: :creator_id
#    end
#
    # rename_column :media_resources, :user_id, :responsible_user_id

  end


end
