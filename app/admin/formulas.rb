ActiveAdmin.register Formula do
  menu parent: "Config", priority: 1

  permit_params :name, :format, :min_players, :max_players

  index do
    selectable_column
    id_column
    column :name
    column :format
    column :min_players
    column :max_players
    actions
  end

  filter :name
  filter :format, as: :select, collection: Formula.formats.keys

  form do |f|
    f.inputs "Formula Details" do
      f.input :name
      f.input :format, as: :select, collection: Formula.formats.keys
      f.input :min_players, as: :number, input_html: { min: 1 }
      f.input :max_players, as: :number, input_html: { min: 1 }
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :format
      row :min_players
      row :max_players
      row :created_at
      row :updated_at
    end
  end
end
