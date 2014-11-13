Myflix::Application.routes.draw do

  root              to: 'pages#front'
  get 'home',       to: 'videos#index'

  get 'register',   to: 'users#new'
  get 'sign_in',    to: 'sessions#new'
  get 'logout',     to: 'sessions#destroy'
  get 'my_queue',   to: 'video_queue_entry#index'
  post 'my_queue',  to: 'video_queue_entry#create', as: :add_queue_entry
  post 'update_queue', to: 'video_queue_entry#update', as: :update_queue

  get   'forgot_password',        to: 'passwords#forgot_password'
  get   'reset_password/:token',  to: 'passwords#reset_password', as: :reset_password
  post  'email_reset_link',       to: 'passwords#email_reset_link'
  get   'confirm_password_reset', to: 'passwords#confirm_password_reset'
  post  'update_password',        to: 'passwords#update_password'
  get   'invalid_token',          to: 'passwords#invalid_token', as: :invalid_password_reset_token

  resources :users,  only: [:create, :edit, :update] do
    resources :video_queue_entry, only: [:index, :create, :destroy]
  end

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
