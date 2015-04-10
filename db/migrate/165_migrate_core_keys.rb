class MigrateCoreKeys < ActiveRecord::Migration

  class MetaKey < ActiveRecord::Base ; end
  class IoMapping < ActiveRecord::Base ; end
  class MetaData < ActiveRecord::Base ; end
  class MetaKeyDefinitions < ActiveRecord::Base ; end
  class KeywordTerm < ActiveRecord::Base ; end
  class Vocabulary < ActiveRecord::Base; end


  def change


    Vocabulary.find_or_create_by id: "madek_core", label: "Madek Core",
      description: "This is the predefined and immutable Madek core vocabulary."

    execute "SET session_replication_role = REPLICA;"

    [{id: 'core:title',
      attributes: {
        id: 'madek_core:title',
        label: 'Title',
        is_enabled_for_media_entries: true,
        is_enabled_for_collections: true,
        is_enabled_for_filter_sets: true,
        vocabulary_id: 'madek_core'
    }},

    {id: 'media_content:subtitle',
      attributes: {
        id: 'madek_core:subtitle',
        label: 'Subtitle',
        is_enabled_for_media_entries: true,
        is_enabled_for_collections: true,
        is_enabled_for_filter_sets: true,
        vocabulary_id: 'madek_core'
    }},
    
    {id: 'core:keywords',
      attributes: {
        id: 'madek_core:keywords',
        label: 'Schlagworte',
        is_enabled_for_media_entries: true,
        is_enabled_for_collections: true,
        is_enabled_for_filter_sets: true,
        vocabulary_id: 'madek_core'
    }}, 

    {id: 'core:author',
      attributes: {
        id: 'madek_core:authors',
        label: 'Autoren',
        is_enabled_for_media_entries: true,
        is_enabled_for_collections: false,
        is_enabled_for_filter_sets: false,
        vocabulary_id: 'madek_core'
    }},

    {id: 'core:portrayed_object_dates',
      attributes: {
        id: 'madek_core:portrayed_object_date',
        label: 'Datierung',
        is_enabled_for_media_entries: true,
        is_enabled_for_collections: false,
        is_enabled_for_filter_sets: false,
        vocabulary_id: 'madek_core'
    }},

    {id: 'core:copyright_notice',
      attributes: {
        id: 'madek_core:copyright_notice',
        label: 'Rechteinhaber',
        is_enabled_for_media_entries: true,
        is_enabled_for_collections: false,
        is_enabled_for_filter_sets: false,
        vocabulary_id: 'madek_core'
    }},


    ].each do |update_data|

      MetaKey.find_or_create_by(id: update_data[:id]) \
        .update_columns update_data[:attributes]

      [IoMapping,MetaData,MetaKeyDefinitions,KeywordTerm].each do |klass|
        klass.where(meta_key_id: update_data[:id]).find_each do |model|
          model.update_columns(meta_key_id: update_data[:attributes][:id])
          puts "* #{klass} * #{model.reload.meta_key_id}"
        end
      end

    end

    execute "SET session_replication_role = DEFAULT;"


  end

end
