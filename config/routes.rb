Rails.application.routes.draw do
  root to: 'application#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'

  resources :projects

  resources :tickets do
    resources :comments, except: [:new, :show]
  end

  resources :tags
  resources :users, only: [:new, :create]
end