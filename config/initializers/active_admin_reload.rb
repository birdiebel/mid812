# config/initializers/active_admin_reload.rb
Rails.application.config.to_prepare do
  if Rails.env.development?
    # Reset ActiveAdmin configuration on file changes
    ActiveAdmin.application.unload!
    Rails.application.reload_routes!
  end
end
