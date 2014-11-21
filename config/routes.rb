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

  get   'forgot_password',        to: 'forgot_passwords#new'
  resources :forgot_passwords, only: [:create]

  get   'reset_password/:token',  to: 'forgot_passwords#reset_password', as: :reset_password
  get   'confirm_password_reset', to: 'forgot_passwords#confirm_password_reset'
  post  'update_password',        to: 'forgot_passwords#update_password'
  get   'invalid_token',          to: 'forgot_passwords#invalid_token', as: :invalid_password_reset_token

  resources :users,  only: [:create, :edit, :update, :show] do
    resources :video_queue_entry, only: [:index, :create, :destroy]
    resources :followings, only: [:create]
  end

  resources :sessions, only: [:create]

  resources :videos, only: [:index, :show] do
    collection do
      get 'search'
    end

    resources :reviews, only: [:create]
  end

  resources :followings, only: [:destroy]

  resources :categories, only: [:index, :show]

  resources :invitations, only: [:new, :create, :show]

  namespace :admin do
    resources :videos, only: [:new, :create, :edit, :update]
  end

  get 'ui(/:action)', controller: 'ui'

end
