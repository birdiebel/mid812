# config/initializers/dartsass.rb
Rails.application.config.dartsass.builds = {
  "application.scss" => "application.css",
  "active_admin.scss" => "active_admin.css",
  "buttons.scss" => "buttons.css",
  "colors.scss" => "colors.css",
  "scorecards.scss" => "scorecards.css",
  "start_lists.scss" => "start_lists.css",
  "pdf.scss" => "pdf.css"
}

Rails.application.config.dartsass.build_options = [ "--quiet-deps", "--silence-deprecation=import" ]
