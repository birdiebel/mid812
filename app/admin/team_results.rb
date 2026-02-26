ActiveAdmin.register TeamResult do
  permit_params :event_id, :team_id, :par, :brut, :net, :stb, :position, :points
  menu label: "Results", parent: "Config", priority: 15
  filter :event
  filter :team_name, as: :string, label: "Team Name"
  config.batch_actions = false
end
