# TODO: allow formats yaml, json ONLY for presenter-enabled resources!
# TODO: redirect format html to base-URI (without format, it's the default!)

Madek::Application.routes.draw do

  root to: 'application#root'

  # NOTE: does not work anymore :-(
  # for now this route must be defined explicitely
  # concern :permissions do
  #   get '/permissions', action: :permissions_show, as: 'permissions', on: :member
  # end

  resources :media_entries, path: 'entries' do
    member do
      get 'meta_data/edit', action: :edit_meta_data, as: 'edit_meta_data'
      put 'meta_data', action: :meta_data_update
      get 'more_data'

      get 'permissions'
      put 'permissions', action: :permissions_update
      get 'permissions/edit', action: :permissions_edit, as: 'edit_permissions'

      post :publish
      get 'preview/:size', action: :preview, as: :preview
      get 'relations'
    end
  end

  resources :collections, only: [:index, :show] do
    member do
      get 'permissions', action: :permissions_show, as: 'permissions'
      get 'permissions/edit', action: :permissions_edit, as: 'edit_permissions'
      put 'permissions', action: :permissions_update
      get 'highlights/edit', action: :edit_highlights
      get 'cover/edit', action: :edit_cover
      put :update_cover
      put :update_highlights
    end
  end
  resources :filter_sets, only: [:index, :show, :create] do
    member do
      get 'permissions', action: :permissions_show, as: 'permissions'
      get 'permissions/edit', action: :permissions_edit, as: 'edit_permissions'
    end
  end

  resources :people, only: [:index, :show]
  resources :users, only: :index
  resources :api_clients, only: :index

  resources :licenses, only: :index

  resources :keywords, only: :index

  resources :meta_data

  # Static App routes ##########################################################
  get '/id/:uuid', to: 'uuid#redirect_to_canonical_url'

  get :explore, controller: :explore

  namespace :my do
    root to: 'dashboard#dashboard', as: 'dashboard'
    # scope some resources here. order is important, they override 'plain' sections
    resources :groups
    # non-resourceful sections are just plain views:
    get ':section', to: 'dashboard#dashboard_section', as: 'dashboard_section'
  end

  post '/session/sign_in', to: 'sessions#sign_in', as: 'sign_in'
  post '/session/sign_out', to: 'sessions#sign_out', as: 'sign_out'

  # Admin routes ###############################################################
  namespace :admin do
    resources :api_clients
    resources :users do
      member do
        post :switch_to
        patch :reset_usage_terms
        patch :grant_admin_role
        delete :remove_admin_role
      end
      collection do
        get :new_with_person
      end
    end
    resources :groups do
      member do
        get 'form_add_user'
        post 'add_user'
        get 'form_merge_to'
        post 'merge_to'
      end
      resources :users, only: '' do
        delete :remove_user_from_group
      end
    end
    resources :api_clients, only: :index
    resources :collections, only: [:index, :show] do
      member do
        get :media_entries
        get :collections
        get :filter_sets
      end
    end
    resources :media_entries, only: [:index, :show]
    resources :media_files, only: :show
    resources :previews, only: [:show, :destroy] do
      get :raw_file
    end
    resources :zencoder_jobs, only: :show
    resources :filter_sets, only: [:index, :show]
    resources :vocabularies do
      resources :keywords
      resources :vocabulary_user_permissions, path: 'user_permissions'
      resources :vocabulary_group_permissions, path: 'group_permissions'
      resources :vocabulary_api_client_permissions, path: 'api_client_permissions'
    end
    resources :meta_keys
    resources :meta_datums, only: :index
    resources :io_mappings
    resources :io_interfaces, except: [:edit, :update]
    resources :app_settings, only: [:index, :edit, :update]

    resources :people

    root to: 'dashboard#index'
  end

  # STYLEGUIDE #################################################################
  get '/styleguide', to: 'styleguide#index', as: 'styleguide'
  get '/styleguide/:section', to: 'styleguide#show', as: 'styleguide_section'
  get '/styleguide/:section/:element', to: 'styleguide#element', as: 'styleguide_element'

  # Error page to be rendered as static page for the proxy
  get '/proxy_error', to: 'errors#proxy_error', :constraints => {:ip => /127.0.0.1/}

end
