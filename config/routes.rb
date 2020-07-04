Rails.application.routes.draw do
  root 'status#index'
  resources :ig_data, only: :create
  get 'ig_data/:code', to: 'ig_data#show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
