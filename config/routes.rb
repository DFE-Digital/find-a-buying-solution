Rails.application.routes.draw do
  root "categories#index"
  resources :categories, only: %i[show index], param: :slug do
    resources :solutions, only: %i[show index], param: :slug
  end

  resources :solutions, only: %i[show index], param: :slug
  get "/search", to: "search#index"
  post "/events", to: "events#create"

  namespace :bfys do
    resources :solutions, only: [:index]
  end

  # Keep this route at the bottom so that it doesn't override the other routes
  get "/:slug", to: "pages#show", as: :page
end
