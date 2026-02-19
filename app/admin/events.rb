ActiveAdmin.register Event do
  belongs_to :tour
  includes :tour

  permit_params :name, :status, :actif, :tour_id, :format, :date_event, :date_open, :date_close, :nb_rounds, :fee, :fee_member, :actif_round, :scoring, :min_players, :max_players,
                course_ids: [],
                playercats_ids: [],
                resultcats_ids: []

  menu false
  config.batch_actions = false

  action_item "Close", only: [ :show ] do
    link_to "Close", admin_tour_path(resource.tour_id)
  end

  myTitle = proc { |event| "#{event.tour.name} : #{event.name} : #{event.status.upcase}" }
  filter :name_cont, as: :string, label: "Name"

  includes :entries, :playercats, :resultcats


  index do
    column "Name" do |event|
      link_to event.name, admin_tour_event_path(event.tour, event), method: :get
    end
    column "Status" do |event|
      event.status
    end
    column "Playercats" do |event|
      event.playercats.map(&:name).join(", ")
    end
    column "" do |event|
      button_to "Edit", edit_admin_tour_event_path(event.tour, event), method: :get, class: "btt btt-edit"
    end
  end

  show title: myTitle do
    render "admin/events/menu", event: event
    render "admin/events/courses", event: event
    render "admin/events/entries", event: event
    render "admin/events/rounds", event: event
    render "admin/events/player_categories", event: event
    render "admin/events/event_details", event: event
    render "admin/events/event_status", event: event
    render "admin/events/ldb", event: event
    page_call = params[:page] || "entries"
    div id: "round_menu_page_call", data: { page_call: page_call }
  end

  form do |f|
    render partial: "admin/events/form", handlers: [ :arb ], locals: { f: }
    f.actions do
      f.action :submit
      f.cancel_link(url_for(:back))
    end
  end

  controller do
    helper ActiveAdminViewsHelper
  end
end
