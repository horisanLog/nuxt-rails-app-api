Rails.application.routes.draw do
  namespace :api do
    namespace :borrower do
      # auth_token
      resources :auth_token, only:[:create] do
        post :refresh, on: :collection
        delete :destroy, on: :collection
      end
    end
  end
end
