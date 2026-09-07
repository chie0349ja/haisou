Rails.application.routes.draw do
  resources :delivery_records
  resources :stores do
    collection do
      get :autocomplete
      post :quick_create
      patch :bulk_update
    end
  end
  resources :clients do
    collection do
      get :autocomplete
      post :quick_create
      patch :bulk_update
    end
  end

  scope "/admin" do
    resources :allocation_ratios do
      patch :bulk_update, on: :collection
    end
    resources :units do
      patch :bulk_update, on: :collection
    end
    resources :cargo_categories do
      patch :bulk_update, on: :collection
    end
    resources :cargo_category_groups do
      patch :bulk_update, on: :collection
    end
    resources :drivers do
      patch :bulk_update, on: :collection
    end
    resources :vehicles do
      patch :bulk_update, on: :collection
    end
    resources :delivery_companies do
      patch :bulk_update, on: :collection
    end
    resources :courses do
      patch :bulk_update, on: :collection
    end
  end

  namespace :admin do
    resources :reviews, only: :index do
      member do
        patch :approve
        post :merge
      end
    end
  end

  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "delivery_records#index"
end
