Rails.application.routes.draw do
  namespace :admin do
    get "events/:id/dashboard_event", to: "dashboard_events#show", as: :event_dashboard_event
    patch "events/:id/update_status", to: "event_statuses#update", as: :event_update_status
    patch "rounds/:id/update_status", to: "round_statuses#update", as: :round_update_status
    get "rounds/:id/open_button", to: "rounds_open_button#show", as: :round_open_button
  end
  mount ActionCable.server => "/cable"

  devise_for :users
  get "admin", to: "home#loadadmin"

  # API routes for drag & drop
  namespace :api do
    namespace :v1 do
      patch "slots/:id", to: "slots#update"
      put "slots/:id", to: "slots#update"
    end
  end

  ActiveAdmin.routes(self)
  get "home/index"
  get "home/test_pdf", to: "home#test_pdf", defaults: { format: "pdf" }
  get "up" => "rails/health#show", :as => :rails_health_check
  root "home#index"
end
