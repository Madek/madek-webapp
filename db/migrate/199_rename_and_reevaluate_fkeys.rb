class RenameAndReevaluateFkeys < ActiveRecord::Migration
  def change
    remove_foreign_key :users, :people
    add_foreign_key :users, :people, name: :users_people_fkey

    remove_foreign_key :groups_users, :users
    add_foreign_key :groups_users, :users, on_delete: :cascade, name: 'groups-users_users_fkey'
    remove_foreign_key :groups_users, :groups
    add_foreign_key :groups_users, :groups, on_delete: :cascade, name: 'groups-users_groups_fkey'

    remove_foreign_key :media_files, column: :media_entry_id
    add_foreign_key :media_files, :media_resources, column: :media_entry_id, name: 'media-files_media-resource_fkey'

    remove_foreign_key :previews, :media_files
    add_foreign_key :previews, :media_files, on_delete: :cascade, name: 'previews_media-files_fkey'

    remove_foreign_key :full_texts, :media_resources
    add_foreign_key :full_texts, :media_resources, on_delete: :cascade, name: 'full-texts_media-resources_fkey'

    remove_foreign_key :meta_data, :meta_keys
    add_foreign_key :meta_data, :meta_keys, on_delete: :cascade, name: 'meta-data_meta-keys_fkey'

    remove_foreign_key :keywords, :keyword_terms
    add_foreign_key :keywords, :keyword_terms, on_delete: :cascade,
      name: 'keywords_keyword-terms_fkey'
    remove_foreign_key :keywords, :users
    add_foreign_key :keywords, :users, name: :keywords_users_fkey
    remove_foreign_key :keywords, :meta_data
    add_foreign_key :keywords, :meta_data, on_delete: :cascade, name: 'keywords_meta-data_fkey'

    remove_foreign_key :meta_data_meta_terms, :meta_data
    add_foreign_key :meta_data_meta_terms, :meta_data, on_delete: :cascade, name: 'meta-data-meta-terms_meta-data_fkey'

    remove_foreign_key :meta_data_people, :meta_data
    add_foreign_key :meta_data_people, :meta_data, on_delete: :cascade, name: 'meta-data-people_meta-data_fkey'
    remove_foreign_key :meta_data_people, :people
    add_foreign_key :meta_data_people, :people, name: 'meta-data-people_people_fkey'

    remove_foreign_key :meta_data_users, :meta_data
    add_foreign_key :meta_data_users, :meta_data, on_delete: :cascade, name: 'meta-data-users_meta-data_fkey'
    remove_foreign_key :meta_data_users, :users
    add_foreign_key :meta_data_users, :users, on_delete: :cascade, name: 'meta-data-users_users_fkey'

    remove_foreign_key :edit_sessions, :users
    add_foreign_key :edit_sessions, :users, on_delete: :cascade, name: 'edit-sessions_users_fkey'

    remove_foreign_key :app_settings, column: :featured_set_id
    add_foreign_key :app_settings, :media_resources, column: :featured_set_id, name: 'app-settings_featured-sets_fkey'
    remove_foreign_key :app_settings, column: :splashscreen_slideshow_set_id
    add_foreign_key :app_settings, :media_resources, column: :splashscreen_slideshow_set_id,
      name: 'app-settings_splashscreen-slideshow-sets_fkey'
    remove_foreign_key :app_settings, column: :catalog_set_id
    add_foreign_key :app_settings, :media_resources, column: :catalog_set_id, name: 'app-settings_catalog-sets_fkey'

    remove_foreign_key :visualizations, :users
    add_foreign_key :visualizations, :users, dependent: :destroy, name: :visualizations_users_fkey

    remove_foreign_key :zencoder_jobs, :media_files
    add_foreign_key :zencoder_jobs, :media_files, name: 'zencoder-jobs_media-files_fkey'

    remove_foreign_key :custom_urls, :media_resources
    add_foreign_key :custom_urls, :media_resources, on_delete: :cascade, name: 'custom-urls_media-resources_fkey'
    remove_foreign_key :custom_urls, column: :creator_id
    add_foreign_key :custom_urls, :users, column: :creator_id, name: 'custom-urls_creators_fkey'
    remove_foreign_key :custom_urls, column: :updator_id
    add_foreign_key :custom_urls, :users, column: :updator_id, name: 'custom-urls_updators_fkey'

    remove_foreign_key :io_mappings, :io_interfaces
    add_foreign_key :io_mappings, :io_interfaces, on_delete: :cascade, name: 'io-mappings_io-interfaces_fkey'
    remove_foreign_key :io_mappings, :meta_keys
    add_foreign_key :io_mappings, :meta_keys, on_delete: :cascade, name: 'io-mappings_meta-keys_fkey'

    remove_foreign_key :admins, :users
    add_foreign_key :admins, :users, name: :admins_users_fkey

    remove_foreign_key :media_files, :media_entries
    add_foreign_key :media_files, :media_entries, name: 'media-files_media-entries_fkey'

    remove_foreign_key :collection_media_entry_arcs, :media_entries
    add_foreign_key :collection_media_entry_arcs, :media_entries, on_delete: :cascade,
      name: 'collection-media-entry-arcs_media-entries_fkey'
    remove_foreign_key :collection_media_entry_arcs, :collections
    add_foreign_key :collection_media_entry_arcs, :collections, on_delete: :cascade,
      name: 'collection-media-entry-arcs_collections_fkey'

    remove_foreign_key :collection_filter_set_arcs, :filter_sets
    add_foreign_key :collection_filter_set_arcs, :filter_sets, on_delete: :cascade,
      name: 'collection-filter-set-arcs_filter-sets_fkey'
    remove_foreign_key :collection_filter_set_arcs, :collections
    add_foreign_key :collection_filter_set_arcs, :collections, on_delete: :cascade,
      name: 'collection-filter-set-arcs_collections_fkey'

    remove_foreign_key :collection_collection_arcs, column: :child_id
    add_foreign_key :collection_collection_arcs, :collections, column: :child_id, on_delete: :cascade,
      name: 'collection-collection-arcs_children_fkey'
    remove_foreign_key :collection_collection_arcs, column: :parent_id
    add_foreign_key :collection_collection_arcs, :collections, column: :parent_id, on_delete: :cascade,
      name: 'collection-collection-arcs_parents_fkey'

    %w(media_entries collections filter_sets).each do |table_name|
      remove_foreign_key table_name, column: :responsible_user_id
      add_foreign_key table_name, :users, column: :responsible_user_id, name: "#{table_name.dasherize}_responsible-users_fkey"
      remove_foreign_key table_name, column: :creator_id
      add_foreign_key table_name, :users, column: :creator_id, name: "#{table_name.dasherize}_creators_fkey"
    end

    remove_foreign_key :meta_data, :media_entries
    add_foreign_key :meta_data, :media_entries, name: 'meta-data_media-entries_fkey'
    remove_foreign_key :meta_data, :collections
    add_foreign_key :meta_data, :collections, name: 'meta-data_collections_fkey'
    remove_foreign_key :meta_data, :filter_sets
    add_foreign_key :meta_data, :filter_sets, name: 'meta-data_filter-sets_fkey'

    remove_foreign_key :media_entry_user_permissions, :users
    add_foreign_key :media_entry_user_permissions, :users, on_delete: :cascade,
      name: 'media-entry-user-permissions_users_fkey'
    remove_foreign_key :media_entry_user_permissions, :media_entries
    add_foreign_key :media_entry_user_permissions, :media_entries, on_delete: :cascade,
      name: 'media-entry-user-permissions_media-entries_fkey'
    remove_foreign_key :media_entry_user_permissions, column: :updator_id
    add_foreign_key :media_entry_user_permissions, :users, column: :updator_id,
      name: 'media-entry-user-permissions_updators_fkey'

    remove_foreign_key :media_entry_group_permissions, :groups
    add_foreign_key :media_entry_group_permissions, :groups, on_delete: :cascade,
      name: 'media-entry-group-permissions_groups_fkey'
    remove_foreign_key :media_entry_group_permissions, :media_entries
    add_foreign_key :media_entry_group_permissions, :media_entries, on_delete: :cascade,
      name: 'media-entry-group-permissions_media-entries_fkey'
    remove_foreign_key :media_entry_group_permissions, column: :updator_id
    add_foreign_key :media_entry_group_permissions, :users, column: :updator_id,
      name: 'media-entry-group-permissions_updators_fkey'

    remove_foreign_key :media_entry_api_client_permissions, :api_clients
    add_foreign_key :media_entry_api_client_permissions, :api_clients, on_delete: :cascade,
      name: 'media-entry-api-client-permissions_api-clients_fkey'
    remove_foreign_key :media_entry_api_client_permissions, :media_entries
    add_foreign_key :media_entry_api_client_permissions, :media_entries, on_delete: :cascade,
      name: 'media-entry-api-client-permissions_media-entries_fkey'
    remove_foreign_key :media_entry_api_client_permissions, column: :updator_id
    add_foreign_key :media_entry_api_client_permissions, :users, column: :updator_id,
      name: 'media-entry-api-client-permissions_updators_fkey'

    remove_foreign_key :favorite_collections, :users
    add_foreign_key :favorite_collections, :users, on_delete: :cascade,
      name: 'favorite-collections_users_fkey'
    remove_foreign_key :favorite_collections, :collections
    add_foreign_key :favorite_collections, :collections, on_delete: :cascade,
      name: 'favorite-collections_collections_fkey'

    remove_foreign_key :favorite_media_entries, :users
    add_foreign_key :favorite_media_entries, :users, on_delete: :cascade,
      name: 'favorite-media-entries_users_fkey'
    remove_foreign_key :favorite_media_entries, :media_entries
    add_foreign_key :favorite_media_entries, :media_entries, on_delete: :cascade,
      name: 'favorite-media-entries_media-entries_fkey'

    remove_foreign_key :edit_sessions, :media_entries
    add_foreign_key :edit_sessions, :media_entries, dependent: :destroy,
      name: 'edit-sessions_media-entries_fkey'
    remove_foreign_key :edit_sessions, :collections
    add_foreign_key :edit_sessions, :collections, dependent: :destroy,
      name: 'edit-sessions_collections_fkey'
    remove_foreign_key :edit_sessions, :filter_sets
    add_foreign_key :edit_sessions, :filter_sets, dependent: :destroy,
      name: 'edit-sessions_filter-sets_fkey'

    remove_foreign_key :collection_group_permissions, :groups
    add_foreign_key :collection_group_permissions, :groups, on_delete: :cascade,
      name: 'collection-group-permissions_groups_fkey'
    remove_foreign_key :collection_group_permissions, :collections
    add_foreign_key :collection_group_permissions, :collections, on_delete: :cascade,
      name: 'collection-group-permissions_collections_fkey'
    remove_foreign_key :collection_group_permissions, column: :updator_id
    add_foreign_key :collection_group_permissions, :users, column: :updator_id,
      name: 'collection-group-permissions_updators_fkey'

    remove_foreign_key :collection_api_client_permissions, :api_clients
    add_foreign_key :collection_api_client_permissions, :api_clients, on_delete: :cascade,
      name: 'collection-api-client-permissions_api-clients_fkey'
    remove_foreign_key :collection_api_client_permissions, :collections
    add_foreign_key :collection_api_client_permissions, :collections, on_delete: :cascade,
      name: 'collection-api-client-permissions_collections_fkey'
    remove_foreign_key :collection_api_client_permissions, column: :updator_id
    add_foreign_key :collection_api_client_permissions, :users, column: :updator_id,
      name: 'collection-api-client-permissions_updators_fkey'

    remove_foreign_key :filter_set_api_client_permissions, :api_clients
    add_foreign_key :filter_set_api_client_permissions, :api_clients, on_delete: :cascade,
      name: 'filter-set-api-client-permissions_api-clients_fkey'
    remove_foreign_key :filter_set_api_client_permissions, :filter_sets
    add_foreign_key :filter_set_api_client_permissions, :filter_sets, on_delete: :cascade,
      name: 'filter-set-api-client-permissions_filter-sets_fkey'
    remove_foreign_key :filter_set_api_client_permissions, column: :updator_id
    add_foreign_key :filter_set_api_client_permissions, :users, column: :updator_id,
      name: 'filter-set-api-client-permissions-updators_fkey'

    remove_foreign_key :filter_set_user_permissions, :users
    add_foreign_key :filter_set_user_permissions, :users, on_delete: :cascade,
      name: 'filter-set-user-permissions_users_fkey'
    remove_foreign_key :filter_set_user_permissions, :filter_sets
    add_foreign_key :filter_set_user_permissions, :filter_sets, on_delete: :cascade,
      name: 'filter-set-user-permissions_filter-sets_fkey'
    remove_foreign_key :filter_set_user_permissions, column: :updator_id
    add_foreign_key :filter_set_user_permissions, :users, column: :updator_id,
      name: 'filter-set-user-permissions_updators_fkey'

    remove_foreign_key :collection_user_permissions, :users
    add_foreign_key :collection_user_permissions, :users, on_delete: :cascade,
      name: 'collection-user-permissions_users_fkey'
    remove_foreign_key :collection_user_permissions, :collections
    add_foreign_key :collection_user_permissions, :collections, on_delete: :cascade,
      name: 'collection-user-permissions_collections_fkey'
    remove_foreign_key :collection_user_permissions, column: :updator_id
    add_foreign_key :collection_user_permissions, :users, column: :updator_id,
      name: 'collection-user-permissions-updators_fkey'

    remove_foreign_key :filter_set_group_permissions, :groups
    add_foreign_key :filter_set_group_permissions, :groups, on_delete: :cascade,
      name: 'filter-set-group-permissions_groups_fkey'
    remove_foreign_key :filter_set_group_permissions, :filter_sets
    add_foreign_key :filter_set_group_permissions, :filter_sets, on_delete: :cascade,
      name: 'filter-set-group-permissions_filter-sets_fkey'
    remove_foreign_key :filter_set_group_permissions, column: :updator_id
    add_foreign_key :filter_set_group_permissions, :users, column: :updator_id,
      name: 'filter-set-group-permissions_updators_fkey'

    remove_foreign_key :favorite_filter_sets, :users
    add_foreign_key :favorite_filter_sets, :users, on_delete: :cascade,
      name: 'favorite-filter-sets_users_fkey'
    remove_foreign_key :favorite_filter_sets, :filter_sets
    add_foreign_key :favorite_filter_sets, :filter_sets, on_delete: :cascade,
      name: 'favorite-filter-sets_filter-sets_fkey'

    remove_foreign_key :media_files, column: :uploader_id
    add_foreign_key :media_files, :users, column: :uploader_id,
      name: 'media-files_uploaders_fkey'

    remove_foreign_key :meta_data_groups, :meta_data
    add_foreign_key :meta_data_groups, :meta_data, on_delete: :cascade,
      name: 'meta-data-groups_meta-data_fkey'
    remove_foreign_key :meta_data_groups, column: :group_id
    add_foreign_key :meta_data_groups, :groups, column: :group_id, on_delete: :cascade,
      name: 'meta-data-groups_groups_fkey'

    remove_foreign_key :licenses_license_groups, :licenses
    add_foreign_key :licenses_license_groups, :licenses,
      name: 'licenses-license-groups_licenses_fkey'
    remove_foreign_key :licenses_license_groups, :license_groups
    add_foreign_key :licenses_license_groups, :license_groups,
      name: 'licenses-license-groups_license-groups_fkey'

    remove_foreign_key :meta_data, :meta_keys
    add_foreign_key :meta_data, :meta_keys, on_delete: :cascade,
      name: 'meta-data_meta-keys_fkey'

    remove_foreign_key :meta_keys, :vocabularies
    add_foreign_key :meta_keys, :vocabularies, on_delete: :cascade,
      name: 'meta-keys_vocabularies_fkey'
    remove_foreign_key :keyword_terms, :meta_keys
    add_foreign_key :keyword_terms, :meta_keys, on_delete: :cascade,
      name: 'keyword-terms_meta-keys_fkey'

    %w(user api_client group).each do |entity|
      remove_foreign_key "vocabulary_#{entity}_permissions", "#{entity.pluralize}"
      add_foreign_key "vocabulary_#{entity}_permissions", "#{entity.pluralize}", on_delete: :cascade,
        name: "vocabulary-#{entity.dasherize}-permissions_#{entity.pluralize.dasherize}_fkey"
      remove_foreign_key "vocabulary_#{entity}_permissions", :vocabularies
      add_foreign_key "vocabulary_#{entity}_permissions", :vocabularies, on_delete: :cascade,
        name: "vocabulary-#{entity.dasherize}-permissions_vocabularies_fkey"
    end
  end
end
