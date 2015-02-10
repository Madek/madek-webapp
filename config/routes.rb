MAdeK::Application.routes.draw do

  root to: 'application#root'

  get 'collections', to: 'collections#index'
  get 'collections/:id', to: 'collections#show'
  get 'collections/:id/images/:size', to: 'collections#image', as: 'collection_image'

  get 'filter_sets', to: 'filter_sets#index'

  get 'media_entries', to: 'media_entries#index'
  get 'media_entries/:id/images/:size', to: 'media_entries#image', as: 'media_entry_image'

  get 'my', to: 'my#dashboard', as: 'my_dashboard'

  post 'session/sign_in', to: 'sessions#sign_in'
  post 'session/sign_out', to: 'sessions#sign_out'

  ##### Admin namespace
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
    root to: 'dashboard#index' 
  end

  ##### STYLEGUIDE (resourceful-ish)
  get 'styleguide', to: 'styleguide#index', as: 'styleguide'
  get 'styleguide/:section', to: 'styleguide#show', as: 'styleguide_section'
  get 'styleguide/:section/:element', to: 'styleguide#element', as: 'styleguide_element'

end
