MAdeK::Application.routes.draw do

  root to: 'application#root'

  # RESTful App Routes #########################################################
  # NOTE: they are all 'resources' here, don't confuse with "MediaResources"!

  ## The resources we internally call "MediaResources":
  resources :media_entries, path: 'entries', only: [:index, :show] do
    get 'preview/:size', action: :preview, as: 'preview', on: :member
  end
  resources :collections, only: [:index, :show]
  resources :filter_sets, only: [:index, :show]

  # Static App routes ##########################################################
  # TODO: resource 'users'?
  get 'my', to: 'my#dashboard', as: 'my_dashboard'

  post 'session/sign_in', to: 'sessions#sign_in'
  post 'session/sign_out', to: 'sessions#sign_out'

  # Admin routes ###############################################################
  namespace :admin do
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
        delete 'remove_user_from_group'
      end
    end
    resources :collections, only: [:index, :show] do
      member do
        get :media_entries
        get :collections
        get :filter_sets
      end
    end
    resources :media_entries, only: [:index, :show]
    resources :media_files, only: :show
    resources :previews, only: [:show, :destroy]
    resources :zencoder_jobs, only: :show
    resources :filter_sets, only: [:index, :show]
    root to: 'dashboard#index' 
  end

  # STYLEGUIDE #################################################################
  get 'styleguide', to: 'styleguide#index', as: 'styleguide'
  get 'styleguide/:section', to: 'styleguide#show', as: 'styleguide_section'
  get 'styleguide/:section/:element', to: 'styleguide#element', as: 'styleguide_element'

end
