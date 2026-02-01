ActiveAdmin.register Resultcat do
  permit_params :name, :agecat_id, :sexe, :hcp_min, :hcp_max, :version, :priority, :actif

  config.batch_actions = false

  menu label: "Result Categories", parent: "Config", priority: 0

  action_item "Close", only: [ :show ] do
    link_to "Close", admin_resultcats_path
  end

  filter :name_cont, as: :string, label: "Name"
  config.sort_order = "priority_asc"

  index do
    column "Name" do |resultcat|
      link_to resultcat.name, admin_resultcat_path(resultcat), method: :get
    end
    column "Age Category" do |resultcat|
      resultcat.agecat.name if resultcat.agecat
    end
    column "HCP Min", :hcp_min
    column "HCP Max", :hcp_max
    column "Sexe", :sexe
    column "Version", :version
    column "Priority", :priority
    column "Active", :actif
    column "" do |resultcat|
      button_to "Edit", edit_admin_resultcat_path(resultcat), method: :get, class: "btt btt-edit"
    end
  end

  form do |f|
    f.inputs "Result Category" do
      f.input :name
      f.input :agecat, as: :select, collection: Agecat.all.map { |a| [ a.name, a.id ] }
      f.input :sexe, as: :select, collection: Resultcat.sexes.keys
      f.input :hcp_min
      f.input :hcp_max
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
