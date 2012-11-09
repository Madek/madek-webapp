# -*- encoding : utf-8 -*-
MAdeK::Application.routes.draw do

  wiki_root '/wiki'
  root :to => "application#root"

#####################################################

  # :action is actually more like a resources that describes part of MediaRsources, such as
  #   my_media_resources or my_sets_and_direct_descendants
  match 'visualization' => 'visualization#put', via: 'put'
  get 'visualization/filtered_resources' => 'visualization#filtered_resources'
  match 'visualization/:action(/:id)', controller: 'visualization'

  #match 'visualization/:action', controller: 'visualization'
  #match 'visualization/*params' => 'visualization#index', via: ['get']
  #match 'visualization/my_sets_and_direct_descendants' => 'visualization#my_sets_and_direct_descendants', via: ['get']

#####################################################

###############################################

  # Mount the KSS engine for CSS styleguide development (development mode only)
  mount Nkss::Engine => '/styleguide' if Rails.env.development?

###############################################

  match '/help', :to => "application#help"
  match '/feedback', :to => "application#feedback"

  match '/login', :to => "authenticator/zhdk#login"
  match '/logout', :to => "authenticator/zhdk#logout"
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

  resources :keywords, only: :index
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
      get :browse
    end
    
    resources :meta_data do
      collection do
        get :edit_multiple
        put :update_multiple
      end
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
      get :browse
      get :inheritable_contexts
      post :settings
      post :parents # TODO: remove
      delete :parents # TODO: remove
      get :category
    end
    
    resources :meta_data do
      collection do
        get :edit_multiple
        put :update_multiple
      end
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
        get :image
      end

      resources :meta_data, only: [:update]
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

###############################################

  # TODO rename :import
  resource :upload, :controller => 'upload', :except => :new do
    member do
      get :permissions
      get :set_media_sets
      put :complete
      get :dropbox
      post :dropbox
    end
  end
  
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
    root :to => "keys#index"

    match '/setup', :to => "setup#show"
    match '/setup/:action', :to => "setup"

    match '/settings', :to => "admin#settings"

    resources :meta_context_groups do
      collection do
        put :reorder
      end
    end
    
    resources :meta_key_definitions

    resources :permission_presets
    
    resource :meta, :controller => 'meta' do
      member do
        get :export
        #old# get :import
        #old# post :import
      end
    end

    resources :keys do
      collection do
        get :mapping
      end
    end

    resources :contexts do
      resources :definitions do
        collection do
          put :reorder
        end
      end
    end

    resources :terms
    
    resources :users, :except => [:new, :create] do
      member do
        get :switch_to
      end
    end

    resources :people do
      resources :users, :only => [:new, :create]
    end

    resources :groups do
      resources :users, :only => [] do
        member do
          post :membership
          delete :membership
        end
      end
    end

    resource :usage_term

    resources :media_sets do
      collection do
        get :special
        post :special
      end
    end
    
    resources :copyrights
        
  end

####################################################################################

end
