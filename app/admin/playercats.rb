ActiveAdmin.register Playercat do
  permit_params :name, :agecat_id, :hcp_min, :hcp_max, :version,
                :teebox, :sexe, :priority, :actif, :format, agecat_ids: []

  config.batch_actions = false

  menu label: "Player Categories", parent: "Config", priority: 0

  action_item "Close", only: [ :show ] do
    link_to "Close", admin_playercats_path
  end

  filter :name_cont, as: :string, label: "Name"
  config.sort_order = "priority_asc"

  index do
    column "Name" do |playercat|
      link_to playercat.name, admin_playercat_path(playercat), method: :get
    end
    column "Age Categories" do |playercat|
      playercat.agecats.map(&:name).join(", ").html_safe
    end
    column "Format", :format
    column "HCP Min", :hcp_min
    column "HCP Max", :hcp_max
    column "Sexe", :sexe
    column "Teebox", :teebox
    column "Version", :version
    column "Priority", :priority
    column "Active", :actif
    column "" do |playercat|
      button_to "Edit", edit_admin_playercat_path(playercat), method: :get, class: "btt btt-edit"
    end
  end

  form do |f|
    f.inputs "Player Category" do
      f.input :name
      f.input :format, as: :select, collection: Playercat.formats.keys
      f.input :agecats, as: :check_boxes, collection: Agecat.all.map { |a| [ a.name, a.id ] }
      f.input :hcp_min
      f.input :hcp_max
      f.input :sexe
      f.input :teebox
      f.input :version
      f.input :priority
      f.input :actif
    end
    f.actions do
       f.action :submit
       f.cancel_link(url_for(:back))
    end
  end
end
