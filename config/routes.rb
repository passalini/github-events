Rails.application.routes.draw do
  devise_for :users
  root to: "webhooks#index"

  resources :webhooks, only: :index
  resources :events, only: :create
  resources :issues, only: [] do
    resources :events, only: :index
  end
end
