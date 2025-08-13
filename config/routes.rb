Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :sleep_records, only: %i[index create update] do
        collection do
          get :following
        end
      end
      resources :users, only: [] do
        collection do
          post :follow
          post :unfollow
        end
      end
    end
  end
end
