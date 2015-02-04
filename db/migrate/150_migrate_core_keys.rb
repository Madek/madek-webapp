class MigrateCoreKeys < ActiveRecord::Migration

  class MetaKey < ActiveRecord::Base ; end
  class IoMapping < ActiveRecord::Base ; end
  class MetaData < ActiveRecord::Base ; end
  class MetaKeyDefinitions < ActiveRecord::Base ; end


  def change

    execute "SET session_replication_role = REPLICA;"


    [{id: 'title',
      attributes: {
        id: 'madek:core:title',
        label: 'Title',
        enabled_for_media_entries: true,
        enabled_for_collections: true,
        enabled_for_filters_sets: true, 
    }},
    
    {id: 'subtitle',
      attributes: {
        id: 'madek:core:subtitle',
        label: 'Untertitel',
        enabled_for_media_entries: true,
        enabled_for_collections: true,
        enabled_for_filters_sets: true, 
    }},

    {id: 'keywords',
      attributes: {
        id: 'madek:core:keywords',
        label: 'Schlagworte',
        enabled_for_media_entries: true,
        enabled_for_collections: true,
        enabled_for_filters_sets: true, 
    }}, 

    {id: 'author',
      attributes: {
        id: 'madek:core:authors',
        label: 'Autoren',
        enabled_for_media_entries: true,
        enabled_for_collections: false,
        enabled_for_filters_sets: false, 
    }},

    {id: 'portrayed object dates',
      attributes: {
        id: 'madek:core:portrayed_object_date',
        label: 'Datierung',
        enabled_for_media_entries: true,
        enabled_for_collections: false,
        enabled_for_filters_sets: false, 
    }},

    {id: 'copyright notice',
      attributes: {
        id: 'madek:core:copyright_notice',
        label: 'Rechteinhaber',
        enabled_for_media_entries: true,
        enabled_for_collections: false,
        enabled_for_filters_sets: false, 
    }},


    ].each do |update_data| 


      MetaKey.where(id: update_data[:id]).find_each do |mk|
        mk.update_columns(update_data[:attributes])
      end

      [IoMapping,MetaData,MetaKeyDefinitions].each do |klass| 
        klass.where(meta_key_id: update_data[:id]).find_each do |model|
          model.update_columns(meta_key_id: update_data[:attributes][:id])
        end
      end

      MetaKeyDefinitions.where(meta_key_id: update_data[:id]).delete_all

    end


    execute "DELETE FROM contexts WHERE id = 'core'"
    

    execute "SET session_replication_role = DEFAULT;"

  end

end
