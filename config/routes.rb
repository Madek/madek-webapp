# -*- encoding : utf-8 -*-
MAdeK::Application.routes.draw do

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

  match '/import', :to => Upload
  match '/upload.js', :to => Upload
  match '/upload_estimation.js', :to => UploadEstimation
  match '/download', :to => Download
  match '/nagiosstat', :to => Nagiosstat

###############################################

  # TODO only [:index, :show] methods
  resources :media_entries do
    collection do
      get :favorites, :to => "media_entries#index"
      #temp# get :graph
      get :keywords
      post :edit_multiple
      put :update_multiple
      post :edit_multiple_permissions
    end

    member do
      post :toggle_favorites
      post :media_sets
      get :edit_tms
      get :to_snapshot
      #temp# :graph_nodes => :get,
      #temp# :index_browser => :get
      get :image
      get :map
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
    
    resources :media_entries # TODO shallow
    resources :media_sets do
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

  resources :media_sets do
    resources :media_sets
    
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

  #working here#4 plural resources nesting upload_session:id
  resource :upload, :controller => 'upload' do
    member do
      post :set_permissions #working here#4 use update method for all ??
      post :set_media_sets
      get :set_media_sets #working here#4 :get as well ??
      get :import_summary
    end
  end
  
  resource :session

  resource :search, :controller => 'search' do
    member do
      post :filter
    end
  end

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
      end
    end

    resources :media_sets do
      collection do
        get :featured
        post :featured
      end
    end
  end
  
end
