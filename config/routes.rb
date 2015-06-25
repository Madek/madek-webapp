# -*- encoding : utf-8 -*-
MAdeK::Application.routes.draw do

  get 'api', controller: "api", action: "show"
  
  resources :applications, only: [:index] # TODO: refactor as "internal API"

  namespace "api" do
    resources :media_resources, only: [:index,:show]
    resources :media_entries, only: [:show] do
      member do
        resources :previews, only: [:index]
        get 'content_stream', to: "media_entries#content_stream"
      end
    end
    resources :previews, only: [:show] do
      get 'content_stream', to: "previews#content_stream"
    end

    # reverse redirects from the "new" entries and sets urls 
    get '/entries/:id' => redirect("/api/media_resources/%{id}", status: 301)
    get '/sets/:id' => redirect("/api/media_resources/%{id}", status: 301)


  end

  get 'public', controller: "public", action: "index"
  namespace "public" do
    resource "api_docs", only: [:show] do
      member do
        get 'authentication'
        get 'authorization'
        get 'resources'
        get 'urls'
        get 'media_resources'
        get 'query_parameters'
        get 'forwarding_auth'
      end
    end
  end

  ##### ROOT

  root :to => "application#root"

  ##### STYLEGUIDE

  get "styleguide", :to => "styleguide#show"
  get "styleguide/:section", :to => "styleguide#show"

  ##### VISUALIZATION

  put 'visualization' => 'visualization#put', via: 'put'
  get 'visualization/filtered_resources' => 'visualization#filtered_resources'
  get 'visualization/my/media_resources' => 'visualization#my_media_resources', :as => "visualization_of_my_media_resources"
  get 'visualization/my/favorites' => 'visualization#my_favorites', :as => "visualization_of_my_favorites"
  get 'visualization/:action(/:id)', controller: 'visualization'

  ##### Zencoder

  post 'zencoder_jobs/:id/notification' => 'zencoder_jobs#post_notification', as: 'zencoder_job_notification'
  resources 'previews', only: [:show]

  ##### SEARCH
  
  resource :search , controller: :search, only: [:show] do
    get 'result'
  end

  ##### EXPLORE

  get 'explore', :to => 'explore#index', :as => "explore"
  get 'explore/catalog', :to => 'explore#catalog', :as => "explore_catalog"
  get 'explore/catalog/:category', :to => 'explore#category', :as => "explore_category"
  get 'explore/catalog/:category/:section', :to => 'explore#section', :as => "explore_section"
  get 'explore/featured_set', :to => 'explore#featured_set', :as => "explore_featured_set"
  get 'explore/keywords', :to => 'explore#keywords', :as => "explore_keywords"
  get 'explore/vocabulary', :to => 'explore#contexts', :as => "explore_contexts"

  ##### MY

  get 'my', :to => 'my#dashboard', :as => "my_dashboard"
  get 'my/media_resources', :to => 'my#media_resources', :as => "my_media_resources"
  get 'my/latest_imports', :to => 'my#latest_imports', :as => "my_latest_imports"
  get 'my/favorites', :to => 'my#favorites', :as => "my_favorites"
  get 'my/keywords', :to => 'my#keywords', :as => "my_keywords"
  get 'my/entrusted_media_resources', :to => 'my#entrusted_media_resources', :as => "my_entrusted_media_resources"
  get 'my/groups', :to => 'my#groups', :as => "my_groups"
  get 'my/vocabulary', :to => 'my#contexts', :as => "my_contexts"

  ##### COLLECTIONS

  get 'collections/:id', :to => 'collections#get', :as => "collections_get"
  put 'collections/add', :to => 'collections#add', :as => "collections_add"
  put 'collections/remove', :to => 'collections#remove', :as => "collections_remove"
  delete 'collections/:id', :to => 'collections#destroy', :as => "collections_destroy"

  ##### IMPORT

  get  'import' => 'import#start', :as => "import"
  get  'import/cancel' => 'import#destroy', :as => "cancel_import"
  post 'import' => 'import#upload'
  delete 'import' => 'import#destroy'
  get  'import/dropbox' => 'import#dropbox_info'
  post 'import/dropbox' => 'import#dropbox_create'
  post 'import/dropbox_import' => 'import#dropbox_import'
  get  'import/permissions' => 'import#permissions', :as => "permissions_import"
  get  'import/meta_data' => 'import#meta_data', :as => "meta_data_import"
  get  'import/organize' => 'import#organize', :as => "organize_import"
  post  'import/complete' => 'import#complete', :as => "complete_import"

  ##### CONTEXTS

  get 'vocabulary/:id', :to => 'contexts#show', :as => "context"
  get 'vocabulary/:id/entries', :to => 'contexts#entries', :as => "context_entries"
  
  ##### METADATA

  put 'meta_data/apply_to_all', :to => 'meta_data#apply_to_all'

  ##############################################################################################
  ##############################################################################################
  ##############################################################################################
  ### TODO: AFTER HERE HAS TO BE CHECKED IF STILL NEEDED #######################################
  ##############################################################################################
  ##############################################################################################
  ##############################################################################################

  get '/login', :to => "madek_zhdk_integration/authentication#login"
  get '/authenticator/zhdk/login_successful/:id', :to => "madek_zhdk_integration/authentication#login_successful"

  get '/login_and_return_here', :to => "application#login_and_return_here" 
  #post '/logout', :to => "authenticator/zhdk#logout"
  #get '/db/login', :to => "authenticator/database_authentication#login"
  #post '/db/do_login', :to => "authenticator/database_authentication#do_login"
  #post '/db/logout', :to => "authenticator/database_authentication#logout"


  ###############################################

  # TODO this is to unspecific; I wonder that it works at all
  get '/download', :controller => 'download', :action => 'download'

  get '/nagiosstat', :to => Nagiosstat


  ### media_resource_arcs ###############################

  get "/media_resource_arcs/:parent_id", controller: "media_resource_arcs", action: "get_arcs_by_parent_id"
  get "/media_resource_arcs/", controller: "media_resource_arcs", action: "index"
  put "/media_resource_arcs/", controller: "media_resource_arcs", action: "update_arcs"

  ################################################

  resources :permissions, only: :index do
    collection do
      get :edit
      put :update 
    end
  end

  resources :responsibilities, only: [] do
    collection do
      get :edit
      post :transfer
    end
  end

  resources :permission_presets, :only => :index, :format => true, :constraints => {:format => /json/}

  resources :context_groups, only: :index

  resources :keywords, only: :index
  resources :meta_terms, only: :index
  resources :copyrights, only: :index


  ###############################################

  resources :filter_sets, only: [:create,:update,:edit,:show]

  ###############################################
  #NOTE first media_entries and then media_sets

  # TODO merge to :media_resources ?? 
  resources 'entries', :to => 'media_entries', :as => 'media_entries', :except => :destroy do
    collection do
      get :edit_multiple
      post :update_multiple
      post :media_sets
      delete :media_sets
    end

    member do
      post :media_sets
      delete :media_sets
      get :image, :to => "media_resources#image"
      get :map
      get :document
      get :more_data
      get :browse
      get :relations
      get 'vocabulary', :to => 'media_entries#contexts', :as => "contexts"
    end
  end

  ###############################################

  # TODO merge to :media_resources ??
  
  resources 'sets', :to => 'media_sets', :as => 'media_sets', :except => :destroy do #-# TODO , :except => :index # the index is only used to create new sets
    member do
      post :settings
      get :category
      get :relations
      get :browse    
      get 'vocabulary/:context_id', controller: 'media_sets', action: 'individual_contexts', as: 'context'
      put 'vocabulary/:context_id/enable', to: 'media_sets#enable_individual_context', as: 'enable_context'
      put 'vocabulary/:context_id/disable', to: 'media_sets#disable_individual_context', as: 'disable_context'
    end


  # resources :media_sets, :except => :destroy do #-# TODO , :except => :index # the index is only used to create new sets
  #   member do
  #     get :abstract
  #     get :vocabulary
  #     get :inheritable_contexts
    # end
    
    

    resources 'entries', :to => 'media_entries', :as => 'media_entries', :except => :destroy do
      collection do
        delete :remove_multiple
      end
      member do
        delete :media_sets
      end
    end
  end

  ###############################################

  resources :media_resources do

    collection do
      post :collection
      post :parents
      delete :parents
    end

    member do
      post '/custom_urls/:url/set_as_primary', url: /[^\/]+/, controller: :custom_urls, action: :set_primary_url, as: :set_primary_url
      get '/custom_urls/:url/confirm_url_transfer', url: /[^\/]+/, controller: :custom_urls, action: :confirm_url_transfer, as: :confirm_url_transfer
      post '/custom_urls/:url/transfer_url', url: /[^\/]+/, controller: :custom_urls, action: :transfer_url, as: :transfer_url
      resources :custom_urls, only: [:index,:create,:new] do
      end
      post :toggle_favorites
      put :favor
      put :disfavor
      get :image
      get :browse
    end

    resources :meta_data do
      collection do
       post :update_multiple
      end
    end


  end

  #tmp#  end

  ###############################################

  resources :media_files # TODO remove ??

  ###############################################
  # TODO refactor nested resources to people and make user as single resource

  resources :users do
    member do
      get :usage_terms
      post :usage_terms_accept
      get :usage_terms_reject
      get :keywords
      put :contrast_mode
    end
    collection do
      get :usage_terms
    end

    resources :media_sets, :except => [:index, :destroy] do # TODO remove
      member do
        post :add_member # TODO
      end
      collection do
        get :add_member
      end
      resources :media_entries, :except => :destroy
    end 
  end

  resources :people

  resources :groups, :only => [:index, :show, :create, :update, :destroy]

  ###################

  resource 'session', only: [] do
    post 'sign_in'
    post 'sign_out'
  end


  #__ Admin namespace __##############################################################
  ####################################################################################

  namespace :app_admin do

    post 'enter_uberadmin' => "base#enter_uberadmin"
    post 'exit_uberadmin' => "base#exit_uberadmin"

    resources :settings, only: [:index,:edit] do
      put '', on: :collection, to: "settings#update", as: :update
    end
    resources :usage_terms
    resources :permission_presets do
      put 'move_up', on: :member
      put 'move_down', on: :member
    end

    resources :zencoder_jobs, only: [:index, :show]

    resources :media_files, only: [:index, :show] do
      member do 
        post 'reencode'
        post 'recreate_thumbnails'
      end
      collection do
        post 'reencode_incomplete_videos'
      end
    end

    resources :media_sets, only: [:index, :show, :edit, :update, :destroy] do
      member do
        delete 'delete_with_child_media_resources'
        get 'change_ownership_form'
        put 'change_ownership'
      end

      resources 'individual_contexts', only: [] do
        collection do
          get 'manage', action: 'manage_individual_contexts', controller: 'media_sets'
        end
        member do
          post 'remove', action: 'remove_individual_context', controller: 'media_sets'
          post 'add', action: 'add_individual_context', controller: 'media_sets'
        end
      end
    end

    resources :filter_sets, only: [:index, :destroy]

    resources :media_entries, only: [:index, :show] do
    end

    resources :meta_keys, only: [:index, :create, :new, :edit, :update, :destroy] do
      resources :meta_terms, only: [] do
        patch 'move_up',   on: :member, controller: 'meta_keys'
        patch 'move_down', on: :member, controller: 'meta_keys'
      end
      post :apply_alphabetical_order, on: :member
      post :change_type,              on: :member
    end
    resources :meta_terms, only: [:index, :edit, :update, :destroy] do
      member do
        get  :form_transfer_resources
        post :transfer_resources
      end
    end
    resources :context_groups, only: [:index, :edit, :update, :new, :create]
    resources :contexts do
      get :media_sets, on: :member
      resources :meta_key_definitions, only: [:edit, :update, :new, :create, :destroy] do
        patch 'move_up',   on: :member
        patch 'move_down', on: :member
      end
    end
    resources :keywords, only: [:index, :edit, :update, :destroy] do
      member do
        get  :form_transfer_resources
        post :transfer_resources
        get  :users
      end
    end

    resources :previews, only: [:show,:destroy]

    resources :groups do
      member do
        get 'form_add_user'
        post 'add_user'
        get 'form_merge_to'
        post 'merge_to'
        get 'show_media_sets'
        get 'show_media_entries'
      end
      resources :users, only: [] do
        member do 
          delete 'remove_user_from_group'
        end
      end
    end
    resources :people do 
      member do
        get  :form_transfer_meta_data
        post :transfer_meta_data
      end
    end
    resources :users do
      collection do
        get :form_create_with_user
        get :search
        get :autocomplete_search
        post :create_with_user
      end
      member do
        post :switch_to
        post :add_to_admins
        delete :remove_from_admins
        put :reset_usage_terms
      end
    end

    resources :statistics, only: [:index]
    resources :copyrights do
      put 'move_up', on: :member
      put 'move_down', on: :member
    end

    resources :io_mappings
    resources :io_interfaces, except: [:edit, :update]

    resources :applications

    with_options only: [:new, :create, :destroy] do |o|
      o.resources :userpermissions
      o.resources :grouppermissions
    end

    root to: "dashboard#index"

  end

  ####################################################################################
  # LEGACY REDIRECTIONS! We need to keep them around indefinitely… ###################
  ####################################################################################
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

end
