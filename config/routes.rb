Rails.application.routes.draw do
  namespace :api do
    namespace :borrower do
      resources :borrowers, only:[:index]
    end
  end
end
