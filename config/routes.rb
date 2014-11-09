Myflix::Application.routes.draw do

  root              to: 'pages#front'
  get 'home',       to: 'videos#index'

  get 'register',   to: 'users#new'
  get 'sign_in',    to: 'sessions#new'
  get 'logout',     to: 'sessions#destroy'
  get 'my_queue',   to: 'video_queue_entry#index'
  post 'my_queue',  to: 'video_queue_entry#create', as: :add_queue_entry
  
  get 'people',     to: "followings#index"

  post 'update_queue', to: 'video_queue_entry#update', as: :update_queue

  resources :users,  only: [:create, :edit, :update, :show] do
    resources :video_queue_entry, only: [:index, :create, :destroy]
  end

  resources :sessions, only: [:create]

  resources :videos, only: [:index, :show] do
    collection do
      get 'search'
    end

    resources :reviews, only: [:create]
  end

  resources :followings, only: [:create, :destroy]

  resources :categories, only: [:index, :show]

  get 'ui(/:action)', controller: 'ui'

  get '*path', to: 'pages#front'

end
