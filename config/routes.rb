Rails.application.routes.draw do
  root "categories#index"
  resources :categories, only: %i[show], param: :slug do
    resources :solutions, only: %i[show], param: :slug, path: ""
  end

  resources :categories, only: %i[index], param: :slug
  resources :solutions, only: %i[show index], param: :slug
  resources :offers, only: %i[index show], param: :slug

  resources :contentful_webhooks, only: %i[create]
  post "delete_contentful_entry", to: "contentful_webhooks#destroy"

  get "/search", to: "search#index"
  post "/events", to: "events#create"

  namespace :bfys do
    resources :solutions, only: [:index]
  end

  # Keep this route at the bottom so that it doesn't override the other routes
  get "/:slug", to: "pages#show", as: :page
end
