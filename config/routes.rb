# -*- encoding : utf-8 -*-

MAdeK::Application.routes.draw do

  root to: "application#root"

  post "session/sign_in", to: "sessions#sign_in"
  post "session/sign_out", to: "sessions#sign_out"

  get "my", to: "my#dashboard", as: "my_dashboard"

end
