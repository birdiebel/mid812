ActiveAdmin.register_page "add_entry" do
  # menu label: "Add Entry"

  content title: "Recherche de joueurs" do
    panel "Rechercher un joueur par nom" do
      active_admin_form_for :search, url: admin_add_entry_path, method: :get do |f|
        f.inputs do
          f.input :lastname, label: "Nom du joueur"
        end
        f.actions do
          f.action :submit, label: "Rechercher"
        end
      end
    end

    if params.dig(:search, :lastname).present?
      players = Player
        .where("lastname ILIKE ?", "%#{params[:search][:lastname]}%")
        .order(:lastname)
        .limit(15)

      panel "Résultats (max 15)" do
        if players.any?
          table_for players do
            column :full_name
            column "Licences", :my_licence
            column "Club", :my_club
            column "Cat", :icon_age_category
            column :age
          end
        else
          para "Aucun joueur trouvé."
        end
      end
    end
  end
end
