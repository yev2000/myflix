Myflix::Application.routes.draw do

  root              to: 'pages#front'
  get 'home',       to: 'videos#index'

  get 'register',   to: 'users#new'
  get 'sign_in',    to: 'sessions#new'
  get 'logout',    to: 'sessions#destroy'

  resources :users,  only: [:create, :edit, :update]
  resources :sessions, only: [:create]

  resources :videos, only: [:index, :show] do
    collection do
      get 'search'
    end

    resources :reviews, only: [:create]
  end

  resources :categories, only: [:index, :show]

  get 'ui(/:action)', controller: 'ui'

  get '*path', to: 'pages#front'

end
