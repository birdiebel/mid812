ActiveAdmin.register_page "add_entry" do
  menu false

  # -----------------------------
  # Routes
  # -----------------------------
  page_action :create_entry, method: :post do
    unless params[:event_id].present?
      redirect_to admin_add_entry_path,
                  alert: "Event missing"
      return
    end

    event  = Event.find(params[:event_id])
    player = Player.find(params[:player_id])

    if Entry.exists?(player: player, event: event)
      redirect_to admin_add_entry_path(event_id: event.id),
                  alert: "An entry already exists for this player and event"
    else
      Entry.create!(player: player, event: event)
      redirect_to admin_tour_event_path(event.tour_id, event),
                  notice: "Entry created for #{player.firstname} #{player.lastname}"
    end
  end




  # -----------------------------
  # Controller
  # -----------------------------

  controller do
    def index
      if params[:event_id].present?
        @event = Event.find(params[:event_id])
      else
        @event = Event.find(params[:search][:event_id])
      end

      @event_id = @event.id
      @tour_id = @event.tour_id
      @players = Player.none
      @players_with_entry_ids = []

      # return unless @event && params.dig(:search, :lastname).present?

      if params.dig(:search, :lastname).present?
        @players = Player
          .where("lastname ILIKE ?", "%#{params[:search][:lastname]}%")
          .order(:lastname)
          .limit(10)

        @players_with_entry_ids = Entry
          .where(event_id: @event&.id, player_id: @players.pluck(:id))
          .pluck(:player_id)
      end
    end
  end

  # -----------------------------
  # View
  # -----------------------------
  content title: "Find players" do
    panel "Find by name" do
      active_admin_form_for :search,
            url: admin_add_entry_path,
            params: { lastname: :lastname, event_id: :event_id },
            method: :get do |f|
        f.inputs do
          f.input :lastname, label: "Name"
          f.input :event_id, input_html: { value: arbre_context.assigns[:event_id] }
        end
        f.actions do
          f.action :submit, label: "Find"
        end
      end
      div do
        button_to "Cancel",
          admin_tour_event_path(arbre_context.assigns[:tour_id], arbre_context.assigns[:event_id]),
          method: :get,
          class: "btn-cancel"
      end
    end

    panel "Results (max 10)" do
      if players.present?
        table_for players do |player|
          column :id
          column :firstname
          column :lastname

          column "Statut" do |player|
            if players_with_entry_ids.include?(player.id)
              span "Registered", :warning
            else
              span "Not Registered", :ok
            end
          end

          column "Action" do |player|
            if players_with_entry_ids.include?(player.id)
              span "Unavailable", :error
            else
              button_to "Register",
                { action: :create_entry },
                  method: :post,
                  params: {
                    player_id: player.id,
                    event_id: @arbre_context.assigns[:event_id] },
                    class: "btn-edit",
                data: { confirm: "Create an entry for this event?" }
            end
          end
        end
      else
        para "No players found."
      end
    end
  end
end
