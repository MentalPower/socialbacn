Socialbacn::Application.routes.draw do
  get "home/index"

  root :to => 'home#index'
  match 'auth/:provider/callback', to: 'sessions#create'
  match 'auth/failure', to: redirect('/')
  match 'signout', to: 'sessions#destroy', as: 'signout'
end
