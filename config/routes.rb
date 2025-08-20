Madek::Application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'application#root'

  scope path: '/in-admin', as: :admin do
    get 'entries/:id' => redirect("/admin/media_entries/%{id}"), as: :entry
    get 'sets/:id' => redirect("/admin/collections/%{id}/"), as: :collection
  end

  get :status, controller: :application, action: :status

  # NOTE: does not work anymore :-(
  # for now this route must be defined explicitely
  # concern :permissions do
  #   get '/permissions', action: :permissions_show, as: 'permissions', on: :member
  # end

  concern :confidential_links do
    member do
      get 'confidential_links'
      get 'confidential_links/new', controller: 'confidential_links', action: 'new', as: 'new_confidential_link'
      post 'confidential_links', controller: 'confidential_links', action: 'create', as: 'create_confidential_link'
      get 'confidential_links/:confidential_link_id', controller: 'confidential_links', action: 'show', as: 'confidential_link'
      patch 'confidential_links/:confidential_link_id', controller: 'confidential_links', action: 'update', as: 'update_confidential_link'
    end
  end

  resources :media_entries, path: 'entries', except: [:new], concerns: :confidential_links do
    # NOTE: 'new' action is under '/my/upload'!
    member do
      get 'meta_data/edit/by_context(/:context_id)', action: :edit_meta_data_by_context, as: 'edit_meta_data_by_context'
      get 'meta_data/edit/by_vocabularies', action: :edit_meta_data_by_vocabularies, as: 'edit_meta_data_by_vocabularies'
      put 'meta_data', action: :meta_data_update
      get 'more_data'
      get 'usage_data'
      get 'list_meta_data'

      get 'share'

      patch 'favor', to: 'media_entries#favor'
      patch 'disfavor', to: 'media_entries#disfavor'

      put 'transfer_responsibility', action: :update_transfer_responsibility, as: 'update_transfer_responsibility'

      get 'ask_delete', action: :ask_delete, as: 'ask_delete'

      get 'permissions'
      put 'permissions', action: :permissions_update
      get 'permissions/edit', action: :permissions_edit, as: 'edit_permissions'

      get 'custom_urls', action: 'custom_urls', as: 'custom_urls'
      get 'custom_urls/edit', action: 'edit_custom_urls', as: 'edit_custom_urls'
      put 'custom_urls', action: 'update_custom_urls', as: 'update_custom_urls'
      patch 'set_primary_custom_url/:custom_url_id', action: 'set_primary_custom_url', as: 'set_primary_custom_url'

      get 'select_collection', action: :select_collection, as: 'select_collection'
      patch 'add_remove_collection', to: 'media_entries#add_remove_collection'

      post :publish
      get 'relations'
      get 'relations/children', action: :relation_children, as: 'relation_children'
      get 'relations/siblings', action: :relation_siblings, as: 'relation_siblings'
      get 'relations/parents', action: :relation_parents, as: 'relation_parents'

      get 'browse'
      get 'siblings'
      get 'export'

      get 'embedded'
      get 'fullscreen'

      get 'access/:token', action: :show_by_confidential_link, as: 'show_by_confidential_link'

      get 'meta_data', action: :rdf_export

      get 'image', action: :image
      get 'video', action: :video
      get 'audio', action: :audio
      get 'document', action: :document
    end

    collection do
      get 'batch_edit_meta_data_by_context(/:context_id)', action: :batch_edit_meta_data_by_context, as: 'batch_edit_meta_data_by_context'
      post 'batch_edit_meta_data_by_context(/:context_id)', action: :batch_edit_meta_data_by_context
      get 'batch_edit_meta_data_by_vocabularies', action: :batch_edit_meta_data_by_vocabularies, as: 'batch_edit_meta_data_by_vocabularies'
      post 'batch_edit_meta_data_by_vocabularies', action: :batch_edit_meta_data_by_vocabularies
      put 'batch_meta_data', action: :batch_meta_data_update

      put 'batch_update_transfer_responsibility', action: :batch_update_transfer_responsibility, as: 'batch_update_transfer_responsibility'

      get 'batch_edit_permissions', controller: :batch, action: :batch_edit_entry_permissions, as: 'batch_edit_permissions'
      post 'batch_edit_permissions', controller: :batch, action: :batch_edit_entry_permissions
      put 'batch_update_permissions', controller: :batch, action: :batch_update_entry_permissions, as: 'batch_update_permissions'
    end

  end

  get 'batch_select_add_to_set', controller: :batch, action: :batch_select_add_to_set, as: 'batch_select_add_to_set'
  post 'batch_select_add_to_set', controller: :batch, action: :batch_select_add_to_set
  put 'batch_destroy_resources', controller: :batch, action: :batch_destroy_resources, as: 'batch_destroy_resources'
  put 'batch_add_to_set', controller: :batch, action: :batch_add_to_set, as: 'batch_add_to_set'
  get 'batch_ask_remove_from_set', controller: :batch, action: :batch_ask_remove_from_set, as: 'batch_ask_remove_from_set'
  patch 'batch_remove_from_set', controller: :batch, action: :batch_remove_from_set, as: 'batch_remove_from_set'
  put 'batch_add_to_clipboard', controller: :batch, action: :batch_add_to_clipboard, as: 'batch_add_to_clipboard'
  put 'batch_remove_from_clipboard', controller: :batch, action: :batch_remove_from_clipboard, as: 'batch_remove_from_clipboard'
  put 'batch_remove_all_from_clipboard', controller: :batch, action: :batch_remove_all_from_clipboard, as: 'batch_remove_all_from_clipboard'
  post 'batch_edit_title', controller: :batch, action: :batch_edit_title_select
  put 'batch_edit_title', controller: :batch, action: :batch_edit_title_update

  resources :collections, path: 'sets', only: [:index, :show, :create, :update, :destroy] do
    member do
      get 'permissions'
      get 'permissions/edit', action: :permissions_edit, as: 'edit_permissions'
      put 'permissions', action: :permissions_update
      get 'highlights/edit', action: :edit_highlights
      get 'cover', action: :cover, as: :cover
      get 'cover/edit', action: :edit_cover
      put :update_cover
      put :update_highlights
      patch 'favor', to: 'collections#favor'
      patch 'disfavor', to: 'collections#disfavor'
      get 'ask_delete', action: :ask_delete, as: 'ask_delete'

      get 'share'

      put 'transfer_responsibility', action: :update_transfer_responsibility, as: 'update_transfer_responsibility'

      get 'custom_urls', action: 'custom_urls', as: 'custom_urls'
      get 'custom_urls/edit', action: 'edit_custom_urls', as: 'edit_custom_urls'
      put 'custom_urls', action: 'update_custom_urls', as: 'update_custom_urls'
      patch 'set_primary_custom_url/:custom_url_id', action: 'set_primary_custom_url', as: 'set_primary_custom_url'

      get 'meta_data/edit/by_context(/:context_id)', action: :edit_meta_data_by_context, as: 'edit_meta_data_by_context'
      get 'meta_data/edit/by_vocabularies', action: :edit_meta_data_by_vocabularies, as: 'edit_meta_data_by_vocabularies'
      put 'meta_data', action: :meta_data_update
      put 'batch_update_all', action: :batch_update_all, as: 'batch_update_all'

      get 'batch_edit_all', action: :batch_edit_all, as: 'batch_edit_all'

      get 'list_meta_data'
      get 'more_data'
      get 'usage_data'
      get 'relations'
      get 'relations/children', action: :relation_children, as: 'relation_children'
      get 'relations/siblings', action: :relation_siblings, as: 'relation_siblings'
      get 'relations/parents', action: :relation_parents, as: 'relation_parents'

      get 'context(/:context_id)', action: :context, as: 'context'

      get 'select_collection', action: :select_collection, as: 'select_collection'
      patch 'add_remove_collection', to: 'collections#add_remove_collection'

      patch 'change_position'
    end

    collection do
      get 'batch_edit_meta_data_by_context(/:context_id)', action: :batch_edit_meta_data_by_context, as: 'batch_edit_meta_data_by_context'
      post 'batch_edit_meta_data_by_context(/:context_id)', action: :batch_edit_meta_data_by_context
      get 'batch_edit_meta_data_by_vocabularies(/:context_id)', action: :batch_edit_meta_data_by_vocabularies, as: 'batch_edit_meta_data_by_vocabularies'
      post 'batch_edit_meta_data_by_vocabularies(/:context_id)', action: :batch_edit_meta_data_by_vocabularies
      put 'batch_meta_data', action: :batch_meta_data_update

      put 'batch_update_transfer_responsibility', action: :batch_update_transfer_responsibility, as: 'batch_update_transfer_responsibility'

      get 'batch_edit_permissions', controller: :batch, action: :batch_edit_collection_permissions, as: 'batch_edit_permissions'
      post 'batch_edit_permissions', controller: :batch, action: :batch_edit_collection_permissions
      put 'batch_update_permissions', controller: :batch, action: :batch_update_collection_permissions, as: 'batch_update_permissions'
    end
  end

  resources :media_files, path: :files, only: :show
  resources :previews, path: 'media', only: :show

  # MetaData & Meta-Resources:
  resources :meta_data

  # # Canonical Paths for Vocabularies and their related MetaKeys.
  # # For MetaKeys and their related Keywords they are needed for RDF and friends:
  # # both attributes (MKs) and specified values (Ks) are referenced as IRIs,
  # # and as a web application it is most appropriate to use a (working) URL.
  # # ORDER MATTERS!!!
  get 'vocabulary', to: 'vocabularies#index', as: 'vocabularies'

  # routes for terms! careful, we want to support ANY STRING as last route part
  get 'vocabulary/:meta_key_id/terms/*term', constraints: { meta_key_id: /.*:[^:\/]*/ },
    to: 'keywords#redirect_by_term', as: 'vocabulary_meta_key_term_redirect', format: false

  get 'vocabulary/keyword/:keyword_id', constraints: { meta_key_id: /.*:[^:\/]*/ },
    to: 'keywords#show', as: 'vocabulary_meta_key_term_show'

  # redirect /vocabulary/{meta_key} to their anchor in the vocabulary metakeys list:
  get 'vocabulary/:meta_key_id', as: 'vocabulary_meta_key',
    constraints: { meta_key_id: /.*:[^:\/]*/ },
    to: redirect{ |p| v, m = p[:meta_key_id].split(':'); "/vocabulary/#{v}##{m}" }

  get 'vocabulary/:vocabulary_id', to: 'vocabularies#show', as: 'vocabulary'
  get 'vocabulary/:vocab_id/keywords', to: 'vocabularies#keywords', as: 'vocabulary_keywords'
  get 'vocabulary/:vocab_id/people', to: 'vocabularies#people', as: 'vocabulary_people'
  get 'vocabulary/:vocab_id/content', to: 'vocabularies#contents', as: 'vocabulary_contents'
  get 'vocabulary/:vocab_id/permissions', to: 'vocabularies#permissions', as: 'vocabulary_permissions'

  resources :meta_keys, only: :index
  resources :keywords, only: :index
  resources :licenses, only: [:index, :show]
  resources :people, only: [:index, :show, :edit, :update]

  # Clients/Logins:
  resource :user, only: [] do
    post :accepted_usage_terms
  end

  resources :users, only: :index
  resources :api_clients, only: :index
  resources :delegations, only: :index
  resources :roles, only: :index

  # Static App routes ##########################################################
  get '/id/:uuid', to: 'uuid#redirect_to_canonical_url'

  get :explore, controller: :explore, action: :index, as: :explore
  get 'explore/catalog', controller: :explore, action: :catalog, as: :explore_catalog
  get 'explore/catalog/:category', controller: :explore, action: :catalog_category, as: :explore_catalog_category
  get 'explore/featured_set', controller: :explore, action: :featured_set, as: :explore_featured_set
  get 'explore/keywords', controller: :explore, action: :keywords, as: :explore_keywords
  get 'explore/:object_type/:object_id/previews/:preview_size',
      controller: :explore,
      action: :catalog_key_item_thumb,
      as: :catalog_key_item_thumb
  get 'explore/catalog/:category/thumb/:preview_size',
      controller: :explore,
      action: :catalog_key_thumb,
      as: :catalog_key_thumb

  resource :search , controller: :search, only: [:show] do
    get :result
  end

  # NOTE: uploader is REST-ish, but use custom a nicer URL for users
  get 'my/upload', controller: :media_entries, action: :new, as: :new_media_entry

  namespace :my do

    get 'new_collection', action: 'new_collection', as: 'new_collection'
    post 'create_collection', action: 'create_collection', as: 'create_collection'

    root action: 'dashboard', as: 'dashboard'

    # scope some resources here. order is important, they override 'plain' sections
    resources :groups

    # tokens (get index is one of the 'sections' below)
    get 'tokens/new', controller: '/api_tokens', action: 'new_api_token', as: 'new_api_token'
    post 'tokens', controller: '/api_tokens', action: 'create_api_token', as: 'create_api_token'
    patch 'tokens/:id', controller: '/api_tokens', action: 'update_api_token', as: 'update_api_token'

    resources :workflows, only: [:index, :new, :create, :edit, :update] do
      get :preview, on: :member
      patch :save_and_not_finish, on: :member
      patch :finish, on: :member
      patch :update_owners, on: :member
    end

    # notifications
    resources :notifications, only: [:update] do
      post :acknowledge_all, on: :collection
      post :acknowledge_multiple, on: :collection
    end

    # settings
    resource :settings, only: [:update]

    # non-resourceful sections are just plain views:
    get ':section', action: 'dashboard_section', as: 'dashboard_section'
  end

  resources :groups, only: :index

  post '/session/sign_in', to: 'sessions#sign_in', as: 'sign_in'
  post '/session/sign_out', to: 'sessions#sign_out', as: 'sign_out'
  post '/session/uberadmin', to: 'users#toggle_uberadmin', as: 'toggle_uberadmin'
  patch '/session/list_config', to: 'users#set_list_config'
  # get '/Shibboleth.sso/Session', to: 'sessions#shibboleth'
  get '/session/shib_sign_in', to: 'sessions#shib_sign_in'

  # user-friendly redirects:
  get '/session/sign_in', to: 'sessions#redirect_for_get_methods'
  get '/session/sign_out', to: 'sessions#redirect_for_get_methods'
  get '/session/uberadmin', to: 'sessions#redirect_for_get_methods'

  # drop-in replacement for auth module (not for production)
  if Rails.env.development? or Rails.env.test?
    get '/auth/sign-in', to: 'test_auth#step1'
    get '/auth/sign-in/auth-systems', to: 'test_auth#step2'
  end

  post '/zencoder_jobs/:id/notification' => 'zencoder_jobs#notification', as: :zencoder_job_notification

  get '/oembed', controller: 'oembed', action: 'show', defaults: { format: 'json' }

  get '/release', controller: 'release', action: 'show'

  resources :about, path: 'about', only: [:index, :show], controller: :about_pages

  # STYLEGUIDE #################################################################
  get '/styleguide', to: 'styleguide#index', as: 'styleguide'
  get '/styleguide/:section', to: 'styleguide#show', as: 'styleguide_section'
  get '/styleguide/:section/:element', to: 'styleguide#element', as: 'styleguide_element'

  # Error page to be rendered as static page for the proxy
  get '/proxy_error', to: 'errors#proxy_error', :constraints => {:ip => /127\.0\.0\.1/}

  ####################################################################################
  # LEGACY REDIRECTIONS! We need to keep them around indefinitely… ###################
  ####################################################################################
  # v2:
  get '/media_resources/:uuid', to: 'uuid#redirect_to_canonical_url'

  # pre-v2
  get '/media_entries/:id' => redirect("/entries/%{id}")
  get '/media_entries/:id/context_group/:name' => redirect("/entries/%{id}/vocabulary")
  get '/media_entries/:id/image' => redirect("/entries/%{id}/image")
  get '/media_entries/:id/map' => redirect("/entries/%{id}/map")
  get '/media_entries/:id/document' => redirect("/entries/%{id}/document")
  get '/media_entries/:id/more_data' => redirect("/entries/%{id}/more_data")
  get '/media_entries/:id/parents' => redirect("/entries/%{id}/parents")

  get '/media_sets/:id' => redirect("/sets/%{id}")
  get '/media_sets/:id/media_entries/:entry_id' => redirect("/sets/%{id}/entries/%{entry_id}")
  get '/media_sets/:id/category' => redirect("/sets/%{id}/category")
  get '/media_sets/:id/parents' => redirect("/sets/%{id}/parents")

  get '/entries/:id/parents' => redirect("/entries/%{id}/relations")
  get '/sets/:id/parents' => redirect("/sets/%{id}/relations")

  get '/contexts/:id' => redirect("/vocabulary/%{id}")
  get '/contexts/:id/entries' => redirect("/vocabulary/%{id}/entries")
  get '/media_entries/:id/context_group/:name' => redirect("/entries/%{id}/vocabulary")

  ####################################################################################
  # ONLY FOR TEST
  ####################################################################################
  if Rails.env.test?
    get '/error_500', to: 'only_for_test#error_500'
  end
  ####################################################################################
end
