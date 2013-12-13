# -*- encoding : utf-8 -*-
MAdeK::Application.routes.draw do

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
  get 'explore/contexts', :to => 'explore#contexts', :as => "explore_contexts"

  ##### MY

  get 'my', :to => 'my#dashboard', :as => "my_dashboard"
  get 'my/media_resources', :to => 'my#media_resources', :as => "my_media_resources"
  get 'my/latest_imports', :to => 'my#latest_imports', :as => "my_latest_imports"
  get 'my/favorites', :to => 'my#favorites', :as => "my_favorites"
  get 'my/keywords', :to => 'my#keywords', :as => "my_keywords"
  get 'my/entrusted_media_resources', :to => 'my#entrusted_media_resources', :as => "my_entrusted_media_resources"
  get 'my/groups', :to => 'my#groups', :as => "my_groups"

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
  get  'import/dropbox' => 'import#dropbox'
  post 'import/dropbox' => 'import#dropbox'
  put 'import/dropbox' => 'import#dropbox_import'
  get  'import/permissions' => 'import#permissions', :as => "permissions_import"
  get  'import/meta_data' => 'import#meta_data', :as => "meta_data_import"
  get  'import/organize' => 'import#organize', :as => "organize_import"
  post  'import/complete' => 'import#complete', :as => "complete_import"

  ##### CONTEXTS

  get 'contexts/:id', :to => 'meta_contexts#show', :as => "context"
  get 'contexts/:id/abstract', :to => 'meta_contexts#abstract', :as => "context_abstract"
  get 'contexts/:id/vocabulary', :to => 'meta_contexts#vocabulary', :as => "context_vocabulary"

  ##### METADATA

  put 'meta_data/apply_to_all', :to => 'meta_data#apply_to_all'

  ##############################################################################################
  ##############################################################################################
  ##############################################################################################
  ### TODO: AFTER HERE HAS TO BE CHECKED IF STILL NEEDED #######################################
  ##############################################################################################
  ##############################################################################################
  ##############################################################################################

  #get '/login', :to => "authenticator/zhdk#login"
  #post '/logout', :to => "authenticator/zhdk#logout"
  get '/login_and_return_here', :to => "application#login_and_return_here" 
  #get '/db/login', :to => "authenticator/database_authentication#login"
  #post '/db/do_login', :to => "authenticator/database_authentication#do_login"
  #post '/db/logout', :to => "authenticator/database_authentication#logout"
  #get '/authenticator/zhdk/login_successful/:id', :to => "authenticator/zhdk#login_successful"


  ###############################################

  # TODO this is to unspecific; I wonder that it works at all
  get '/download', :controller => 'download', :action => 'download'

  #match '/nagiosstat', :to => Nagiosstat


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

  resources :meta_context_groups, only: :index

  resources :keywords, only: :index
  resources :meta_terms, only: :index
  resources :copyrights, only: :index


  ###############################################

  resources :filter_sets, only: [:create,:update,:edit,:show]

  ###############################################
  #NOTE first media_entries and then media_sets

  # TODO merge to :media_resources ?? 
  resources :media_entries, :except => :destroy do
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
      get :parents
      get 'context_group/:name', :to => 'media_entries#context_group', :as => "context_group"
    end
  end

  ###############################################

  # TODO merge to :media_resources ?? 
  resources :media_sets, :except => :destroy do #-# TODO , :except => :index # the index is only used to create new sets
    member do
      get :abstract
      get :vocabulary
      get :browse
      get :inheritable_contexts
      post :settings
      get :category
      get :parents
    end

    resources :media_entries, :except => :destroy do
      collection do
        delete :remove_multiple
      end
      member do
        delete :media_sets
      end
    end
  end

  ###############################################

  #tmp#  constraints(:id => /\d+/) do

  resources :media_resources do

    collection do
      post :collection
      post :parents
      delete :parents
    end

    member do
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
      post :usage_terms
      get :keywords
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

    resource :settings, only: [:edit,:update,:show]

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

    resources :media_sets, only: [:index, :show] do
      member do
        delete 'delete_with_child_media_resources' 
      end

      resources 'individual_meta_contexts', only: [] do
        collection do
          get 'manage', action: 'manage_individual_meta_contexts', controller: 'media_sets'
        end
        member do
          post 'remove', action: 'remove_individual_meta_context', controller: 'media_sets'
          post 'add', action: 'add_individual_meta_context', controller: 'media_sets'
        end
      end
    end

    resources :media_entries, only: [:index, :show] do
    end

    resources :previews, only: [:show,:destroy]

    resources :groups do
      member do
        get 'form_add_user'
        post 'add_user'
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
        post :create_with_user
      end
      member do
        post :switch_to
      end
    end

    root to: "dashboard#index"

  end

end
