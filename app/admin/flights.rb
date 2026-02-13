ActiveAdmin.register Flight do
  permit_params :config_teetime_id, :num, :status

  config.batch_actions = false

  menu label: "Flights", parent: "Config", priority: 10

  filter :config_teetime, as: :select
  filter :num
  filter :status, as: :select, collection: Flight.statuses.keys
  config.sort_order = "num_asc"

  index do
    column "Num", :num
    column "Config Teetime", :config_teetime
    column "Status", :status
    column "" do |flight|
      button_to "Edit", edit_admin_flight_path(flight), method: :get, class: "btt btt-edit"
    end
  end

  form do |f|
    f.inputs "Flight" do
      f.input :config_teetime, as: :select, collection: ConfigTeetime.all.map { |ct| [ "Round #{ct.round.num} - #{ct.course.name}", ct.id ] }
      f.input :num, as: :number
      f.input :status, as: :select, collection: Flight.statuses.keys
    end
    f.actions do
      f.action :submit
       f.cancel_link(url_for(:back))
    end
  end
end
