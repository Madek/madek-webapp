MAdeK::Application.routes.draw do

  root to: 'application#root'

  post 'session/sign_in', to: 'sessions#sign_in'
  post 'session/sign_out', to: 'sessions#sign_out'

  get 'my', to: 'my#dashboard', as: 'my_dashboard'

  get 'media_entries', to: 'media_entries#index'
  get 'collections', to: 'collections#index'
  get 'filter_sets', to: 'filter_sets#index'

  ##### Admin namespace
  namespace :admin do
    root to: 'dashboard#index' 
  end

  ##### STYLEGUIDE (resourceful-ish)
  get 'styleguide', to: 'styleguide#index', as: 'styleguide'
  get 'styleguide/:section', to: 'styleguide#show', as: 'styleguide_section'
  get 'styleguide/:section/:element', to: 'styleguide#element', as: 'styleguide_element'

end
