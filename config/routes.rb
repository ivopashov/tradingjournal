Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root "dashboard#index"

  post 'trades_import', to: 'trades#import'
  get 'new_trades_import', to: 'trades#new_import'
  resources :trades, only: [:new, :create, :edit, :update]
  resources :dashboard, only: [:show, :index]
end
