Myflix::Application.routes.draw do

  get 'home', to: 'home#index'
  
  resources :videos, only: [:index, :show] do
    collection do
      get 'search'
    end
  end

  resources :categories, only: [:index, :show]

  get 'ui(/:action)', controller: 'ui'

end
