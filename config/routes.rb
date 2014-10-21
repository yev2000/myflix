Myflix::Application.routes.draw do

  root              to: 'pages#front'
  get 'home',       to: 'videos#index'

  get 'register',   to: 'users#new'
  get 'sign_in',    to: 'sessions#new'
  get 'logout',     to: 'sessions#destroy'
  get 'my_queue',   to: 'videoqueue#index'
  post 'my_queue',  to: 'videoqueue#create', as: :add_queue_entry

  resources :users,  only: [:create, :edit, :update] do
    resources :videoqueue, only: [:index, :create]
  end

  resources :sessions, only: [:create]

  resources :videos, only: [:index, :show] do
    collection do
      get 'search'
    end

    member do
      post "create_review"
    end
  end

  resources :categories, only: [:index, :show]

  get 'ui(/:action)', controller: 'ui'

  get '*path', to: 'pages#front'

end
