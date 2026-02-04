ActiveAdmin.register Score do
  permit_params :round_id, :slot_id, :entry_id, :status, :brut_str, :net_str, :stb_str, :hole_played, :start_hole

  menu label: "Scores", parent: "Config", priority: 13

  action_item "Back to Round", only: [ :edit ] do
    link_to "Back to Round", admin_round_path(resource.round, anchor: "scores-round")
  end

  index do
    selectable_column
    id_column
    column :round
    column :slot
    column :entry
    column :status
    column :hole_played
    column :start_hole
    column :brut_str
    column :net_str
    column :stb_str
    column :recu_str
    actions
  end

  filter :round
  filter :slot
  filter :entry
  filter :status, as: :select, collection: Score.statuses.keys
  filter :hole_played
  filter :start_hole

  form do |f|
    f.inputs "Score Details" do
      f.input :round, as: :select, collection: Round.all.map { |r| [ "Round #{r.id} - #{r.event.name}", r.id ] }
      f.input :slot, as: :select, collection: Slot.all.map { |s| [ "Slot #{s.num} - Flight #{s.flight_id}", s.id ] }
      f.input :entry, as: :select, collection: Entry.all.includes(:player).map { |e| [ e.player.full_name, e.id ] }
      f.input :status, as: :select, collection: Score.statuses.keys
      f.input :hole_played
      f.input :start_hole
      f.input :brut_str
      f.input :net_str
      f.input :stb_str
      f.input :recu_str, input_html: { disabled: true }, hint: "Auto-calculated based on playing_hcp and stroke index"
    end
    f.actions do
      f.action :submit
      f.cancel_link admin_round_path(f.object.round, anchor: "scores-round")
    end
  end

  show do
    attributes_table do
      row :id
      row :round
      row :slot
      row :entry do |score|
        score.entry.player.full_name
      end
      row :status
      row :hole_played
      row :start_hole
      row :brut_str
      row :net_str
      row :stb_str
      row :recu_str
      row :created_at
      row :updated_at
    end
  end

  controller do
    def update
      @score = Score.find(params[:id])
      if @score.update(permitted_params[:score])
        redirect_to admin_round_path(@score.round, anchor: "scores-round"), notice: "Score updated successfully."
      else
        render :edit
      end
    end

    def create
      @score = Score.new(permitted_params[:score])
      if @score.save
        redirect_to admin_round_path(@score.round, anchor: "scores-round"), notice: "Score created successfully."
      else
        render :new
      end
    end
  end
end
