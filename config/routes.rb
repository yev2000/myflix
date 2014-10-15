Myflix::Application.routes.draw do

  root              to: 'pages#front'

  get 'home',       to: 'home#index'
  get 'front',      to: 'home#front'
  get 'register',   to: 'users#new'
  get 'sign_in',    to: 'sessions#new'
  post 'sign_in',   to: 'sessions#create'
  get 'logout',    to: 'sessions#destroy'

  resources :users,  only: [:create, :edit, :update]

  resources :videos, only: [:index, :show] do
    collection do
      get 'search'
    end
  end

  resources :categories, only: [:index, :show]

  get 'ui(/:action)', controller: 'ui'

end
