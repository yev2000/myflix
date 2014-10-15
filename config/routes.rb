Myflix::Application.routes.draw do

  root              to: 'home#index'
  
  get 'home',       to: 'home#index'
  get 'front',      to: 'home#front'
  get 'register',   to: 'home#register'
  get 'sign_in',    to: 'sessions#new'
  post 'sign_in',   to: 'sessions#create'
  post 'logout',    to: 'sessions#destroy'

  resources :users,  only: [:new, :create, :edit]

  resources :videos, only: [:index, :show] do
    collection do
      get 'search'
    end
  end

  resources :categories, only: [:index, :show]

  get 'ui(/:action)', controller: 'ui'

end
