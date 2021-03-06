Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root "heat_maps#index"

  # post 'trades_import', to: 'trades#import'
  # get 'new_trades_import', to: 'trades#new_import'
  # resources :trades, only: [:new, :create, :edit, :update]
  resources :heat_maps
  resources :trading_alerts
  # resources :dashboard, only: [:show, :index]
end
