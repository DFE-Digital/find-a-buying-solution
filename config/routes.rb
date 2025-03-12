Rails.application.routes.draw do
  root "categories#index"
  resources :categories, only: %i[show index], param: :slug
  resources :solutions, only: %i[show], param: :slug
  get "/search", to: "search#index"
  match "/500", as: :internal_server_error, to: "errors#internal_server_error", via: :all
  match "/404", as: :not_found, to: "errors#not_found", via: :all
end
