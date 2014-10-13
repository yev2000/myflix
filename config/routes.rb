Myflix::Application.routes.draw do

  get 'home', to: 'home#index'
  
  resources :videos, only: [:index, :show]

  resources :categories, only: [:index, :show]

  get 'ui(/:action)', controller: 'ui'

end
