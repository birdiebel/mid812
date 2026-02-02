ActiveAdmin.register Slot do
  permit_params :flight_id, :entry_id, :num, :playing_hcp

  config.batch_actions = false

  menu label: "Slots", parent: "Config", priority: 11

  filter :flight, as: :select
  filter :entry, as: :select
  filter :num
  config.sort_order = "num_asc"

  index do
    column "Num", :num
    column "Flight", :flight
    column "Entry", :entry
    column "Playing HCP", :playing_hcp
    column "" do |slot|
      button_to "Edit", edit_admin_slot_path(slot), method: :get, class: "btt btt-edit"
    end
  end

  form do |f|
    f.inputs "Slot" do
      f.input :flight, as: :select, collection: Flight.all.map { |fl| [ "Flight #{fl.num}", fl.id ] }
      f.input :entry, as: :select, collection: Entry.all.map { |e| [ "#{e.player&.name}", e.id ] }, include_blank: true
      f.input :num, as: :number
      f.input :playing_hcp, as: :number
    end
    f.actions do
       f.action :submit
       f.cancel_link(url_for(:back))
    end
  end
end
