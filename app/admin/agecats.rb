ActiveAdmin.register Agecat do
  permit_params :name, :short, :age_low, :age_high, :color, :year

  config.batch_actions = false

  menu label: "Age Categories", parent: "Config", priority: 0

  action_item "Close", only: [ :show ] do
    link_to "Close", admin_agecats_path
  end

  filter :name_cont, as: :string, label: "Name"
  config.sort_order = "id_asc"

  index do
    column "ID", :id
    column "Name" do |agecat|
      link_to agecat.name, admin_agecat_path(agecat), method: :get
    end
    column "Age Low", :age_low
    column "Age High", :age_high
    column "Year", :year
    column "Color", :color
    column "" do |agecat|
      button_to "Edit", edit_admin_agecat_path(agecat), method: :get, class: "btt btt-edit"
    end
  end

  form do |f|
    f.inputs "Age Category" do
      f.input :name
      f.input :short
      f.input :age_low
      f.input :age_high
      f.input :color, as: :string, input_html: { class: "colorpicker" }
      f.input :year
    end
    f.actions do
       f.action :submit
       f.cancel_link(url_for(:back))
    end
  end
end
