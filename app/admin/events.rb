ActiveAdmin.register Event do
  belongs_to :tour
  includes :tour

  permit_params :name, :status, :actif, :tour_id, :format, :date_event, :date_open, :date_close, :nb_rounds, playercat_ids: []

  menu false
  config.batch_actions = false

  action_item "Close", only: [ :show ] do
    link_to "Close", admin_tour_path(resource.tour_id)
  end

  myTitle = proc { |event| "#{event.tour.name} : #{event.name}" }
  filter :name_cont, as: :string, label: "Name"

  includes :entries, :playercats


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
    panel "Add a Player" do
      # Formulaire de recherche
      div do
        form action: admin_tour_event_path(resource.tour, resource), method: :get do
          div style: "display: flex; gap: 10px; align-items: center;" do
            label "Find by name or licence number :"
            input type: :text, name: :player_lastname, value: params[:player_lastname]
            button "Find", type: :submit
            button "Clear", type: :button, onclick: "window.location='#{admin_tour_event_path(resource.tour, resource)}'"
          end
        end
      end

      # Si une recherche est effectuée
      if params[:player_lastname].present?
        div do
          # Limiter le nombre de joueurs trouvés à 10
          #
          # Exclure les joueurs déjà inscrits à cet événement
          players = Player
            .left_joins(:licences) # Associe la table `licences` via une jointure (si la relation existe)
            .where(
              "players.lastname ILIKE :query OR licences.num ILIKE :query",
              query: "%#{params[:player_lastname].strip}%" # Recherche sur lastname ou licence.num
            )
            .where.not(id: Entry.where(event_id: resource.id).select(:player_id)) # Exclure les joueurs déjà inscrits
            .limit(10)

          h4 "Max 10 players show", style: "color: darkred;"

          if players.any?
            table do
              thead do
                tr do
                  th "Cat"
                  th "Nom complet"
                  th "Genre"
                  th "Licence"
                  th "Club"
                  th "Âge"
                  th "Action"
                end
              end
              tbody do
                players.each do |player|
                  tr do
                    td player.icon_age_category
                    td player.full_name # Remplacez `full_name` par la méthode appropriée pour afficher le nom complet.
                    td player.sexe
                    td player.my_licence # Remplacez `my_licence` par l'attribut ou la méthode correspondant à la licence.
                    td player.my_club # Remplacez `my_club` par l'attribut ou la méthode correspondant au club.
                    td player.age # Remplacez `age` par l'attribut ou la méthode calculant l'âge.

                    # Bouton pour ajouter à la table entries
                    td do
                      if player.licences.exists?
                        link_to "Ajouter", admin_entries_path(entry: { event_id: resource.id, player_id: player.id }), method: :post, class: "button"
                      else
                        span "No licence found", style: "color: red;"
                      end
                    end
                  end
                end
              end
            end
          else
            div "Aucun joueur trouvé."
          end
        end
      end
    end

    panel "Entries list" do
      # Grouper les entrées par statut
      grouped_entries = resource.entries.order(status: :asc, created_at: :desc).group_by(&:status)

      # Parcourir chaque statut et afficher une table pour chaque groupe
      grouped_entries.each do |status, entries|
        div(class: "panel-table-subtitre") do
          "Status :  #{status.presence || 'Undefined'} : #{entries.count}"
        end

        table_for entries do
          column "CAT" do |entry|
            entry.player.icon_age_category
          end
          column do |entry|
            entry.player.full_name
          end
          column "Sexe" do |entry|
            entry.player.sexe
          end
          column "Age" do |entry|
            entry.player.age
          end
          column "Licence" do |entry|
            entry.player.my_licence
          end
          column "Hcp" do |entry|
            entry.hcp
          end
          column "Player Cat" do |entry|
            entry.playercat ? entry.playercat.name : "N/A"
          end
          column "Club" do |entry|
            entry.player.my_club
          end
          column :status
          column :updated_at
          column "" do |entry|
            button_to "Edit", edit_admin_entry_path(entry), method: :get, class: "btt btt-edit"
          end
          column "" do |entry|
            button_to "Delete", admin_entry_path(entry), method: :delete, data: { confirm: "Are you sure?" }, class: "btt btt-cancel"
          end
        end
      end
    end

    panel "Player Categories" do
      table_for event.playercats do |playercat|
          column "name", :name
          column "format", :format
          column "sexe", :sexe
          column "teebox", :teebox
          column "hcp_min", :hcp_min
          column "hcp_max", :hcp_max
          column "version", :version
          column "Age Cat" do |playercat|
            playercat.agecats.map(&:name).join(", ")
          end
      end
    end

    default_main_content
  end

  form do |f|
    f.inputs "Event Details" do
      f.input :tour, as: :select, collection: Tour.all.collect { |tour| [ tour.name, tour.id ] }, include_blank: false
      f.input :name
      f.input :format, as: :select, collection: Event.formats.keys
      f.input :status, as: :select, collection: Event.statuses.keys
      f.input :actif
      # f.input :date_event, as: :datepicker, datepicker_options: { dateFormat: "dd/mm/yy" }
      f.input :date_event, as: :datepicker, input_html: { value: f.object.date_event&.strftime("%m/%d/%Y") }, datepicker_options: { dateFormat: "dd/mm/yy" }
      f.input :date_open, as: :datepicker, input_html: { value: f.object.date_open&.strftime("%m/%d/%Y") }, datepicker_options: { dateFormat: "dd/mm/yy" }
      f.input :date_close, as: :datepicker, input_html: { value: f.object.date_close&.strftime("%m/%d/%Y") }, datepicker_options: { dateFormat: "dd/mm/yy" }
      f.input :nb_rounds, as: :number
      f.input :playercats, as: :check_boxes, collection: Playercat.all.map { |pc| [ pc.name, pc.id ] }
    end
    f.actions do
      f.action :submit
      f.cancel_link(url_for(:back))
    end
  end
end
