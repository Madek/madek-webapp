# -*- encoding : utf-8 -*-
MAdeK::Application.routes.draw do

=begin #FE#
  resources :resources, :only => :index
  resources :media_sets, :only => :show
  resources :media_entries, :only => :show do
    member do
      get :image
    end
    resources :meta_data do
      collection do
        put :update_multiple
      end
    end
  end
=end  

  wiki_root '/wiki'

  root :to => "application#root"

###############################################
  
  match '/help', :to => "application#help"
  match '/feedback', :to => "application#feedback"
  #old??# match '/catalog', :to => "application#catalog"

  match '/login', :to => "authenticator/zhdk#login"
  match '/logout', :to => "authenticator/zhdk#logout"
  match '/db/login', :to => "authenticator/database_authentication#login"
  match '/db/logout', :to => "authenticator/database_authentication#logout"
  match '/authenticator/zhdk/login_successful/:id', :to => "authenticator/zhdk#login_successful"
  # TODO 0306 remove this method!!! used only for test purposes
  #test_login '/test_login', :controller => 'application', :action => 'test_login'
  
###############################################

  match '/download', :controller => 'download', :action => 'download'
  
  match '/nagiosstat', :to => Nagiosstat


  resources :media_entry_incompletes

###############################################
#NOTE first media_entries and then media_sets

  resources :media_entries do
    collection do
      #temp# get :graph
      get :keywords
      post :edit_multiple
      put :update_multiple
      post :edit_multiple_permissions
      post :media_sets
      delete :media_sets
    end

    member do
      post :media_sets
      delete :media_sets
      get :edit_tms
      get :to_snapshot
      #temp# :graph_nodes => :get,
      #temp# :index_browser => :get
      get :image, :to => "resources#image"
      get :map
      get :browse
    end
    
    resources :permissions do
      collection do
        get :edit_multiple
        put :update_multiple
      end
    end
    
    resources :meta_data do
      collection do
        get :objective
        get :edit_multiple
        put :update_multiple
      end
    end
  end
  
###############################################

  resources :media_sets do #-# TODO , :except => :index # the index is only used to create new sets
    collection do
      post :parents
      delete :parents
    end
    member do
      get :abstract
      get :browse
      get :inheritable_contexts
      post :parents # TODO: remove
      delete :parents # TODO: remove
    end
    
    resources :media_sets #-# only used for FeaturedSet 
    
    resources :permissions do
      collection do
        get :edit_multiple
        put :update_multiple
      end
    end
    
    resources :meta_data do
      collection do
        get :edit_multiple
        put :update_multiple
      end
    end
    
    resources :media_entries do
      collection do
        delete :remove_multiple
        
      end
      member do
        delete :media_sets
      end
    end
  end
  
###############################################

  # TODO only [:index, :show] methods

  resources :resources, :only => [:index, :show] do
    collection do
      post :parents
      delete :parents
      get :favorites, :to => "resources#index"
      get :filter
      post :filter
    end
    
    member do
      post :toggle_favorites
      get :image
    end
  end

  resources :media_files # TODO remove ??

  resources :snapshots do
    collection do
      get :export
    end
    
    resources :meta_data do
      collection do
        get :edit_multiple
        put :update_multiple
      end
    end
  end
  
###############################################
# TODO refactor nested resources to people and make user as single resource

  resources :users, :shallow => true do
    member do
      get :usage_terms
      post :usage_terms
    end
    collection do
      get :usage_terms
    end
    
    resources :resources # TODO shallow
    resources :media_sets, :except => :index do
      member do
        post :add_member # TODO
      end
      
      collection do
        get :add_member
      end
      
      resources :media_entries # TODO shallow
    end 
  end

  resources :people

  resources :groups do
    member do
      post :membership
      delete :membership
    end
  end

###############################################

  # TODO rename :import
  resource :upload, :controller => 'upload' do
    member do
      post :set_permissions # TODO use update method for all ??
      post :set_media_sets
      get :import_summary
      post :estimation
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
    
    resource :meta, :controller => 'meta' do
      member do
        get :export
        get :import
        post :import
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
    
    resources :users do
      member do
        get :switch_to
      end
    end

    resources :people

    resources :groups do
      resources :users do
        member do
          post :membership
          delete :membership
        end
      end
    end

    resource :usage_term

    resources :media_entries do
      collection do
        get :import
        get :dropbox
        post :dropbox
      end
    end

    resources :media_sets do
      collection do
        get :special
        post :special
      end
    end
  end

end
