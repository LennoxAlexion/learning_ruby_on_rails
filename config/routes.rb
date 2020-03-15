Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html3
  namespace :v1 do
    namespace :weather do
      resources :summary
      resources :locations
    end
  end
end
