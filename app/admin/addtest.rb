ActiveAdmin.register_page "addtest" do
  menu false

  # -----------------------------
  # Routes
  # -----------------------------
  page_action :create_entry, method: :post do
    unless params[:event_id].present?
      redirect_to admin_add_entry_path,
                  alert: "Événement manquant"
      return
    end

    event  = Event.find(params[:event_id])
    player = Player.find(params[:player_id])

    if Entry.exists?(player: player, event: event)
      redirect_to admin_add_entry_path(event_id: event.id),
                  alert: "Une entry existe déjà pour ce joueur et cet événement"
    else
      Entry.create!(player: player, event: event)
      redirect_to admin_add_entry_path(event_id: event.id),
      notice: "Entry créée pour #{player.firstname} #{player.lastname}"
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
  content title: "Recherche de joueurs" do
    panel "Rechercher un joueur par nom" do
      active_admin_form_for :search,
            url: admin_add_entry_path,
            params: { lastname: :lastname, event_id: :event_id },
            method: :get do |f|
        f.inputs do
          f.input :lastname, label: "Nom du joueur"
          f.input :event_id, input_html: { value: params[:event_id] }
        end
        f.actions do
          f.action :submit, label: "Rechercher"
        end
      end
    end

    panel "Résultats (max 10)" do
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
              span "Indisponible", :error
            else
              button_to "Créer une entry",
                { action: :create_entry },
                  method: :post,
                  params: {
                    player_id: player.id,
                    event_id: @arbre_context.assigns[:event_id] },
                data: { confirm: "Créer une entry pour cet événement ?" }
            end
          end
        end
      else
        para "Aucun joueur trouvé."
      end
    end
  end
end
