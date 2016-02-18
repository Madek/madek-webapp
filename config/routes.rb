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

  resources :media_entries, path: 'entries' do
    member do
      get 'meta_data/edit', action: :edit_meta_data, as: 'edit_meta_data'
      put 'meta_data', action: :meta_data_update
      get 'more_data'

      patch 'favor', to: 'media_entries#favor'
      patch 'disfavor', to: 'media_entries#disfavor'

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
      patch 'favor', to: 'collections#favor'
      patch 'disfavor', to: 'collections#disfavor'

    end
  end
  resources :filter_sets, only: [:index, :show, :create] do
    member do
      get 'permissions', action: :permissions_show, as: 'permissions'
      get 'permissions/edit', action: :permissions_edit, as: 'edit_permissions'
    end
  end

  resources :media_files, only: :show

  resources :people, only: [:index, :show]
  resources :users, only: :index
  resources :api_clients, only: :index

  resources :licenses, only: :index

  resources :keywords, only: :index

  resources :meta_data

  resources :meta_keys, only: :index

  # Static App routes ##########################################################
  get '/id/:uuid', to: 'uuid#redirect_to_canonical_url'

  get :explore, controller: :explore, action: :index

  namespace :my do
    get 'session-token', to: '/my#session_token'

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
