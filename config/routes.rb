Rails.application.routes.draw do
  root "categories#index"
  resources :categories, only: %i[show index], param: :slug
  resources :solutions, only: %i[show], param: :slug
  get "/search", to: "search#index"
end
