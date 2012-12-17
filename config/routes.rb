# -*- encoding : utf-8 -*-
MAdeK::Application.routes.draw do

  root :to => "application#root"

##### VISUALIZATION

  match 'visualization' => 'visualization#put', via: 'put'
  get 'visualization/filtered_resources' => 'visualization#filtered_resources'
  match 'visualization/:action(/:id)', controller: 'visualization'

##### SEARCH

  get 'search', :to => 'search#search', :as => "search"
  post 'search', :to => 'search#search', :as => "search"
  get 'search/:term', :to => 'search#term', :as => "search_term"

##### EXPLORE

  get 'explore', :to => 'explore#index', :as => "explore"

  get 'explore/catalog', :to => 'explore#catalog', :as => "explore_catalog"
  get 'explore/catalog/:category', :to => 'explore#category', :as => "explore_category"
  get 'explore/catalog/:category/:section', :to => 'explore#section', :as => "explore_section"

  get 'explore/featured_set', :to => 'explore#featured_set', :as => "explore_featured_set"

  get 'explore/keywords', :to => 'explore#keywords', :as => "explore_keywords"

##### MY

  get 'my/media_resources', :to => 'my#media_resources', :as => "my_media_resources"
  get 'my/latest_imports', :to => 'my#latest_imports', :as => "my_latest_imports"
  get 'my/favorites', :to => 'my#favorites', :as => "my_favorites"
  get 'my/keywords', :to => 'my#keywords', :as => "my_keywords"
  get 'my/entrusted_media_resources', :to => 'my#entrusted_media_resources', :as => "my_entrusted_media_resources"
  get 'my/groups', :to => 'my#groups', :as => "my_groups"

##### COLLECTIONS

  put 'collections/add', :to => 'collections#add', :as => "collections_add"
  put 'collections/remove', :to => 'collections#remove', :as => "collections_remove"
  delete 'collections/:id', :to => 'collections#destroy', :as => "collections_destroy"

##### IMPORT

  get  'import' => 'import#start'
  post 'import' => 'import#upload'
  delete 'import' => 'import#destroy'
  get  'import/dropbox' => 'import#dropbox'
  post 'import/dropbox' => 'import#dropbox'
  get  'import/permissions' => 'import#permissions', :as => "permissions_import"
  get  'import/meta_data' => 'import#meta_data', :as => "edit_import"
  get  'import/organize' => 'import#organize'
  put  'import/complete' => 'import#complete'

##### STYLEGUIDE

  mount Nkss::Engine => '/styleguide' if Rails.env.development?

###############################################

  match '/help', :to => "application#help"
  match '/feedback', :to => "application#feedback"

  match '/login', :to => "authenticator/zhdk#login"
  match '/logout', :to => "authenticator/zhdk#logout"
  match '/login_and_return_here', :to => "application#login_and_return_here" 
  match '/db/login', :to => "authenticator/database_authentication#login"
  match '/db/logout', :to => "authenticator/database_authentication#logout"
  match '/authenticator/zhdk/login_successful/:id', :to => "authenticator/zhdk#login_successful"
  
###############################################

  match '/download', :controller => 'download', :action => 'download'
  
  match '/nagiosstat', :to => Nagiosstat


### media_resource_arcs ###############################
   
  match "/media_resource_arcs/:parent_id", controller: "media_resource_arcs", action: "get_arcs_by_parent_id", via: [:get]
  match "/media_resource_arcs/", controller: "media_resource_arcs", action: "get_arcs_by_parent_id", via: [:get]
  match "/media_resource_arcs/", controller: "media_resource_arcs", action: "update_arcs", via: [:put]

################################################

  resources :permissions, :only => :index, :format => true, :constraints => {:format => /json/} do
    collection do
      put :update # TODO merge to media_resources#update ??
    end
  end

  resources :permission_presets, :only => :index, :format => true, :constraints => {:format => /json/}

  resources :meta_context_groups, only: :index

  resources :meta_terms, only: :index
  resources :meta_data, only: [:update] # TODO merge to media_resources#update ??
  resources :copyrights, only: :index


###############################################
#NOTE first media_entries and then media_sets

  # TODO merge to :media_resources ?? 
  resources :media_entries, :except => :destroy do
    collection do
      get :keywords
      post :edit_multiple
      put :update_multiple
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
      match 'context_group/:name', :to => 'media_entries#context_group', :as => "context_group"
    end
  end
  
###############################################

  # TODO merge to :media_resources ?? 
  resources :media_sets, :except => :destroy do #-# TODO , :except => :index # the index is only used to create new sets
    collection do
      post :parents
      delete :parents
    end
    member do
      get :abstract
      get :vocabulary
      get :browse
      get :inheritable_contexts
      post :settings
      post :parents # TODO: remove
      delete :parents # TODO: remove
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

      resources :meta_data, only: [:update]

      resources :meta_data do
        collection do
          get :edit_multiple
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
   
  resource :session

  resources :meta_contexts, :only => :show do
    member do
      get :abstract
    end
  end

#__ Admin namespace __##############################################################
####################################################################################

  namespace :admin do
    match '/setup', :to => "setup#show"
    match '/setup/:action', :to => "setup"
  end

  ActiveAdmin.routes(self)
    
end
