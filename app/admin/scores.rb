ActiveAdmin.register Score do
  permit_params :round_id, :slot_id, :entry_id, :team_id, :playing_hcp, :status, :brut_str, :net_str, :stb_str, :hole_played, :start_hole,
                slot_attributes: [ :id, team_attributes: [ :id, :status ] ]

  menu label: "Scores", parent: "Config", priority: 13

  action_item "Back to Round", only: [ :edit ] do
    link_to "Back to Scoring", scoring_admin_round_path(resource.round, anchor: "team-score-#{resource.id}")
  end

  index do
    selectable_column
    id_column
    column :round
    column :slot
    column :entry
    column :team
    column :playing_hcp
    column :status
    column :hole_played
    column :start_hole
    actions
  end

  filter :round
  filter :slot
  filter :entry
  filter :team
  filter :playing_hcp
  filter :status, as: :select, collection: Score.statuses.keys
  filter :hole_played
  filter :start_hole

  form do |f|
    # f.inputs "Score Details" do
    #   f.input :round, as: :select, collection: Round.all.map { |r| [ "Round #{r.id} - #{r.event.name}", r.id ] }
    #   f.input :slot, as: :select, collection: Slot.all.map { |s| [ "Slot #{s.num} - Flight #{s.flight_id}", s.id ] }
    #   f.input :entry, as: :select, collection: Entry.all.includes(:player).map { |e| [ e.player.full_name, e.id ] }
    #   f.input :status, as: :select, collection: Score.statuses.keys
    #   f.input :hole_played
    #   f.input :start_hole
    # end

    # Not Use : see team_score
    f.inputs "Result-Card" do
      puts "Rendering result card partial for score form with round ID  : #{f.object.round_id}"
      render "admin/team_scores/card", f: f, score: f.object
    end

    f.actions do
      f.action :submit
      f.cancel_link scoring_admin_round_path(resource.round, anchor: "team-score-#{resource.id}")
    end
  end

  show do
    attributes_table do
      row :id
      row :round
      row :slot
      row :team
      row :entry do |score|
        score.entry&.player&.full_name || "N/A"
      end
      row :playing_hcp
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
    def permitted_params
      params.permit(
        :_method,
        :authenticity_token,
        :commit,
        :id,
        :team_id,
        :team_status,
        { brut_inputs: {} },
        score: [
          :round_id,
          :slot_id,
          :entry_id,
          :team_id,
          :playing_hcp,
          :status,
          :brut_str,
          :net_str,
          :stb_str,
          :hole_played,
          :start_hole,
          { slot_attributes: [ :id, { team_attributes: [ :id, :status ] } ] }
        ]
      )
    end

    def update
      # all_params = params.to_h
      # puts "Received params: #{all_params.inspect}"

      puts "Updating team #{params[:team_id]} status to #{params[:team_status]}"

      @score = Score.find(params[:id])

      # Update team status if provided
      if params[:team_id].present? && params[:team_status].present?
        puts "Finding team with ID: #{params[:team_id]} with status: #{params[:team_status]}"
        team = Team.find_by(id: params[:team_id])
        team.update(status: params[:team_status]) if team
      end

      if @score.update(permitted_params[:score])
        redirect_to scoring_admin_round_path(resource.round, anchor: "team-score-#{@score.id}"), notice: "Score updated successfully."
      else
        render :edit
      end

      # if @score.update(permitted_params[:score])
      #   redirect_to admin_round_path(@score.round, anchor: "scores-round"), notice: "Score updated successfully."
      # else
      #   render :edit
      # end
    end

    def create
      @score = Score.new(permitted_params[:score])
      if @score.save
        redirect_to scoring_admin_round_path(resource.round, anchor: "team-score-#{@score.id}"), notice: "Score created successfully."
      else
        render :new
      end
    end
  end
end
