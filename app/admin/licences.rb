ActiveAdmin.register Licence do
  permit_params :id, :player_id, :num, :hcp, :club, :actif

  belongs_to :player
  includes :player
  filter :player_lastname, as: :string
  filter :num
  menu false

  action_item "Close", only: [ :show ] do
    link_to "Close", admin_player_path(resource.player)
  end

  index do
    column :id
    column :player, sortable: "player.lastname"
    column :num
    column :hcp
    column :club
    actions
  end

  form do |f|
    f.inputs "Licence" do
      f.input :num
      f.input :hcp
      f.input :club
      f.input :actif
    end
    f.actions do
       f.action :submit
       f.cancel_link(url_for(:back))
    end
  end

  show title: proc { |licence| "Licence : "+licence.player.full_name } do
    panel "Licence" do
      attributes_table_for(resource) do
        row :num
        row :hcp
        row :club
        row :created_at
        row :updated_at
      end
    end
  end
end
