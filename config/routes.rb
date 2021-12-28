Rails.application.routes.draw do
  namespace :api do
    namespace :borrower do
      # api test action
      resources :hello, only:[:index]
    end
  end
end
