ActiveAdmin.register Player do
  permit_params :firstname, :lastname, :dob, :sexe, :lang, :user_id,
                licences_attributes: [ :id, :num, :hcp, :club ],
                user_attributes: [ :id, :email, :actif, :role, :password, :password_confirmation, :encrypted_password ]

  belongs_to :user, optional: true
  includes :user, :licences

  filter :lastname_cont, as: :string, label: "Name"
  filter :user_email_cont, as: :string, label: "Email"
  filter :licences_num_cont, as: :string, label: "Licence"
  filter :licences_club_cont, as: :string, label: "Club"

  config.sort_order = "lastname_asc"
  config.batch_actions = false

  menu label: "Players", parent: "Players", priority: 0

  action_item "Close", only: [ :show ] do
    link_to "Close", admin_players_path
  end

  index do |player|
    column "Name" do |player|
      link_to player.lastname, admin_player_path(player), method: :get
    end
    column :full_name
    column "Age", :age
    column "Cat"  do |player|
      raw player.icon_age_category
    end
    column "User", :my_user
    column "Club", :my_club
    column "Licences", :my_licence
    column "" do |player|
      button_to "Edit", edit_admin_player_path(player), method: :get, class: "btt btt-edit"
    end
  end

  form do |f|
    f.inputs "Player informations" do
      f.input :firstname
      f.input :lastname
      f.input :dob
      f.input :sexe
      f.input :lang
    end

    f.inputs "Licences" do
      f.has_many :licences, heading: false, allow_destroy: false, new_record: true do |a|
        a.input :num
        a.input :hcp
        a.input :club
        a.input :actif
      end
    end

    f.inputs "User" do
        f.has_many :user, heading: false, allow_destroy: false, new_record: !resource.user do |u|
          u.input :email
          u.input :role
          if u.object.new_record?
            u.input :password
            u.input :password_confirmation
          end
          u.input :actif
        end
    end

    f.actions do
       f.action :submit
       f.cancel_link(url_for(:back))
    end
  end

  show do
    default_main_content
    div do
        button_to "Add licence", new_admin_player_licence_path(player_id: resource.id), method: :get
    end

    panel "Licences" do
      table_for player.licences, class: "table-condensed" do
        column "Licence" do |licence|
          link_to licence.num, admin_player_licence_path(player, licence), method: :get
        end
        column :hcp
        column :club
        column :actif
        column "" do |licence|
          button_to "Edit", edit_admin_player_licence_path(player, licence), method: :get, class: "btt btt-edit"
        end
      end
    end
  end
end
