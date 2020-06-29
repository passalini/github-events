Rails.application.routes.draw do
  devise_for :users
  root to: "webhooks#index"

  resources :webhooks, only: [:create, :index, :show]
end
