ActionController::Routing::Routes.draw do |map|
  
  map.namespace :dilps2 do |dilps2|
    dilps2.resources :collections do |collection|
      collection.resources :items
    end

    dilps2.resources :groups do |group|
      group.resources :items
    end
  end

end
