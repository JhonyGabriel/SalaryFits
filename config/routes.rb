Rails.application.routes.draw do
  root "salary_fits#index"
  resources :salary_fits
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
