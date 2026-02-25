ActiveAdmin.register Event do
  belongs_to :tour
  includes :tour

  permit_params :name,
                :status,
                :actif,
                :tour_id,
                :format,
                :date_event,
                :date_open,
                :date_close,
                :nb_rounds,
                :fee,
                :fee_member,
                :actif_round,
                :scoring,
                :min_players,
                :max_players,
                course_ids: [],
                playercats_ids: [],
                resultcats_ids: []

  menu false
  config.batch_actions = false

  base_title = ->(event) { "#{event.name}" }
  page_title = ->(event, section_name) { "#{base_title.call(event)} | #{section_name}" }

  action_item "Close", only: [ :show ] do
    link_to "Close", admin_tour_path(resource.tour_id)
  end

  action_item "Close", only: [ :leaderboard ] do
    link_to "Close", admin_tour_event_path(resource.tour, resource)
  end

  action_item "Close", only: [ :entries, :rounds, :player_categories, :courses, :event_details, :event_status ] do
    link_to "Close", admin_tour_path(resource.tour_id)
  end

  member_action :event_dashboard, method: :get do
    @event = Event.find(params[:id])
    @page_title = page_title.call(@event, "Dashboard")
  end

  member_action :leaderboard, method: :get do
    @event = Event.find(params[:id])
    @page_title = page_title.call(@event, "Leaderboard")
  end

  member_action :entries, method: :get do
    @event = Event.find(params[:id])
    @page_title = page_title.call(@event, "Entries")
  end

  member_action :rounds, method: :get do
    @event = Event.find(params[:id])
    @page_title = page_title.call(@event, "Rounds")
  end

  member_action :player_categories, method: :get do
    @event = Event.find(params[:id])
    @page_title = page_title.call(@event, "Player Categories")
  end

  member_action :courses, method: :get do
    @event = Event.find(params[:id])
    @page_title = page_title.call(@event, "Courses")
  end

  member_action :event_details, method: :get do
    @event = Event.find(params[:id])
    @page_title = page_title.call(@event, "Details")
  end

  member_action :event_status, method: :get do
    @event = Event.find(params[:id])
    @page_title = page_title.call(@event, "Status")
  end

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
      button_to "Edit",
                edit_admin_tour_event_path(event.tour, event),
                method: :get,
                class: "btt btt-edit"
    end
  end

  form do |f|
    render partial: "admin/events/form", handlers: [ :arb ], locals: { f: f }
    f.actions do
      f.action :submit
      f.cancel_link(url_for(:back))
    end
  end

  controller do
    helper ActiveAdminViewsHelper

    def show
      redirect_to entries_admin_tour_event_path(resource.tour, resource)
    end
  end
end
