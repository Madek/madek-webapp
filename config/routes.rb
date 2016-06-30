# TODO: allow formats yaml, json ONLY for presenter-enabled resources!
# TODO: redirect format html to base-URI (without format, it's the default!)

Madek::Application.routes.draw do

  root to: 'application#root'

  get :status, controller: :application, action: :status

  # NOTE: does not work anymore :-(
  # for now this route must be defined explicitely
  # concern :permissions do
  #   get '/permissions', action: :permissions_show, as: 'permissions', on: :member
  # end

  resources :media_entries, path: 'entries', except: [:new] do
    # NOTE: 'new' action is under '/my/upload'!
    member do
      get 'meta_data/edit', action: :edit_meta_data, as: 'edit_meta_data'
      get 'meta_data/edit_context(/:context_id)', action: :edit_context_meta_data, as: 'edit_context_meta_data'
      put 'meta_data', action: :meta_data_update
      get 'more_data'

      patch 'favor', to: 'media_entries#favor'
      patch 'disfavor', to: 'media_entries#disfavor'

      get 'ask_delete', action: :ask_delete, as: 'ask_delete'

      get 'permissions'
      put 'permissions', action: :permissions_update
      get 'permissions/edit', action: :permissions_edit, as: 'edit_permissions'

      get 'select_collection', action: :select_collection, as: 'select_collection'
      patch 'add_remove_collection', to: 'media_entries#add_remove_collection'

      post :publish
      get 'relations'

      get 'export'
    end

    # TMP
    collection do
      get 'batch_meta_data_edit', action: :batch_edit_meta_data, as: 'batch_edit_meta_data'
      get 'batch_edit_context_meta_data(/:context_id)', action: :batch_edit_context_meta_data, as: 'batch_edit_context_meta_data'
      put 'batch_meta_data', action: :batch_meta_data_update
    end
    # /TMP

  end

  get 'batch_select_add_to_set', controller: :batch, action: :batch_select_add_to_set, as: 'batch_select_add_to_set'
  put 'batch_add_to_set', controller: :batch, action: :batch_add_to_set, as: 'batch_add_to_set'

  resources :collections, path: 'sets', only: [:index, :show, :create, :destroy] do
    member do
      get 'permissions', action: :permissions_show, as: 'permissions'
      get 'permissions/edit', action: :permissions_edit, as: 'edit_permissions'
      put 'permissions', action: :permissions_update
      get 'highlights/edit', action: :edit_highlights
      get 'cover/edit', action: :edit_cover
      put :update_cover
      put :update_highlights
      patch 'favor', to: 'collections#favor'
      patch 'disfavor', to: 'collections#disfavor'
      get 'ask_delete', action: :ask_delete, as: 'ask_delete'

      get 'meta_data/edit', action: :edit_meta_data, as: 'edit_meta_data'
      get 'meta_data/edit_context(/:context_id)', action: :edit_context_meta_data, as: 'edit_context_meta_data'
      put 'meta_data', action: :meta_data_update

      get 'more_data'
      get 'relations'

      get 'select_collection', action: :select_collection, as: 'select_collection'
      patch 'add_remove_collection', to: 'collections#add_remove_collection'

    end
  end
  resources :filter_sets, only: [:index, :show, :create] do
    member do
      get 'permissions', action: :permissions_show, as: 'permissions'
      get 'permissions/edit', action: :permissions_edit, as: 'edit_permissions'
    end
  end

  resources :media_files, path: :files, only: :show
  resources :previews, path: 'media', only: :show

  # MetaData & Meta-Resources:
  resources :meta_data


  # TODO: finish this
  # # Canonical Paths for Vocabularies and their related MetaKeys.
  # # For MetaKeys and their related Keywords they are needed for RDF and friends:
  # # both attributes (MKs) and specified values (Ks) are referenced as IRIs,
  # # and as a web application it is most appropriate to use a (working) URL.
  # get 'vocabulary', to: 'vocabularies#index', as: 'vocabularies'
  # get 'vocabulary/:vocabulary_id', to: 'vocabularies#show', as: 'vocabulary', constraints: { id: /[^:]/ }
  # get 'vocabulary/:meta_key_id', to: 'vocabularies#show_meta_key', as: 'vocabulary_meta_key'
  get 'vocabulary/:meta_key_id/:term', to: 'keywords#show', as: 'vocabulary_meta_key_term'

  # TODO: also "scope" this inside /vocabulary ↑ (but don't break CRUD & search)
  resources :meta_keys, only: :index
  resources :keywords, only: :index
  resources :licenses, only: [:index, :show]
  resources :people, only: [:index, :show]

  # Clients/Logins:
  resources :users, only: :index
  resources :api_clients, only: :index

  # Static App routes ##########################################################
  get '/id/:uuid', to: 'uuid#redirect_to_canonical_url'

  get :explore, controller: :explore, action: :index
  get 'explore/catalog', controller: :explore, action: :catalog
  get 'explore/catalog/:category', controller: :explore, action: :catalog_category
  get 'explore/featured_set', controller: :explore, action: :featured_set
  get 'explore/keywords', controller: :explore, action: :keywords
  get 'explore/keywords/:keyword_id/previews/:preview_size',
      controller: :previews,
      action: :show_for_keyword,
      as: :preview_for_keyword

  resource :search , controller: :search, only: [:show] do
    get :result
  end

  # NOTE: uploader is REST-ish, but use custom a nicer URL for users
  get 'my/upload', controller: :media_entries, action: :new, as: :new_media_entry

  namespace :my do
    get 'session-token', to: '/my#session_token'

    get 'new_collection', action: 'new_collection', as: 'new_collection'
    post 'create_collection', action: 'create_collection', as: 'create_collection'

    root to: 'dashboard#dashboard', as: 'dashboard'
    # scope some resources here. order is important, they override 'plain' sections
    resources :groups
    # non-resourceful sections are just plain views:
    get ':section', to: 'dashboard#dashboard_section', as: 'dashboard_section'
  end

  post '/session/sign_in', to: 'sessions#sign_in', as: 'sign_in'
  post '/session/sign_out', to: 'sessions#sign_out', as: 'sign_out'

  post '/zencoder_jobs/:id/notification' => 'zencoder_jobs#notification', as: :zencoder_job_notification

  # STYLEGUIDE #################################################################
  get '/styleguide', to: 'styleguide#index', as: 'styleguide'
  get '/styleguide/:section', to: 'styleguide#show', as: 'styleguide_section'
  get '/styleguide/:section/:element', to: 'styleguide#element', as: 'styleguide_element'

  # Error page to be rendered as static page for the proxy
  get '/proxy_error', to: 'errors#proxy_error', :constraints => {:ip => /127.0.0.1/}

end
