class MigrateCoreKeys < ActiveRecord::Migration

  class MetaKey < ActiveRecord::Base ; end
  class IoMapping < ActiveRecord::Base ; end
  class MetaData < ActiveRecord::Base ; end
  class MetaKeyDefinitions < ActiveRecord::Base ; end
  class Vocabulary < ActiveRecord::Base; end


  def change


    Vocabulary.find_or_create_by id: "madek:core", label: "Madek Core", 
      description: "This is the predefined and immutable Madek core vocabulary."

    execute "SET session_replication_role = REPLICA;"

    [{id: 'core:title',
      attributes: {
        id: 'madek:core:title',
        label: 'Title',
        enabled_for_media_entries: true,
        enabled_for_collections: true,
        enabled_for_filters_sets: true, 
        vocabulary_id: 'madek::core'
    }},
    
    {id: 'core:keywords',
      attributes: {
        id: 'madek:core:keywords',
        label: 'Schlagworte',
        enabled_for_media_entries: true,
        enabled_for_collections: true,
        enabled_for_filters_sets: true, 
        vocabulary_id: 'madek::core'
    }}, 

    {id: 'core:author',
      attributes: {
        id: 'madek:core:authors',
        label: 'Autoren',
        enabled_for_media_entries: true,
        enabled_for_collections: false,
        enabled_for_filters_sets: false, 
        vocabulary_id: 'madek::core'
    }},

    {id: 'core:portrayed_object_dates',
      attributes: {
        id: 'madek:core:portrayed_object_date',
        label: 'Datierung',
        enabled_for_media_entries: true,
        enabled_for_collections: false,
        enabled_for_filters_sets: false, 
        vocabulary_id: 'madek::core'
    }},

    {id: 'core:copyright_notice',
      attributes: {
        id: 'madek:core:copyright_notice',
        label: 'Rechteinhaber',
        enabled_for_media_entries: true,
        enabled_for_collections: false,
        enabled_for_filters_sets: false, 
        vocabulary_id: 'madek::core'
    }},


    ].each do |update_data| 

      MetaKey.find_or_create_by(id: update_data[:id]) \
        .update_columns update_data[:attributes]

      [IoMapping,MetaData,MetaKeyDefinitions].each do |klass| 
        klass.where(meta_key_id: update_data[:id]).find_each do |model|
          model.update_columns(meta_key_id: update_data[:attributes][:id])
        end
      end

    end

    execute "SET session_replication_role = DEFAULT;"

  end

end
