Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :users, only: [] do
        member do
          post "sleep_records/clock_in", to: "sleep_records#clock_in"
          post "sleep_records/:sleep_record_id/clock_out", to: "sleep_records#clock_out", as: :sleep_record_clock_out
          get "sleep_records/following", to: "sleep_records#following_records"
          post "follow/:target_id", to: "followings#create", as: :follow
          delete "unfollow/:target_id", to: "followings#destroy", as: :unfollow
        end
      end
    end
  end
end
