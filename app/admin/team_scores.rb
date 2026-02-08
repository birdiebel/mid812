ActiveAdmin.register TeamScore do
  permit_params :team_id, :round_id, :status, :hole_played, :brut_total, :net_total, :stb_total, :stroke_play_score

  menu label: "Team Scores", parent: "Config", priority: 14

  action_item "Recalculate", only: [ :show, :edit ] do
    link_to "Recalculate Score", recalculate_admin_team_score_path(resource), method: :post, data: { confirm: "Recalculate this team score?" }
  end

  member_action :recalculate, method: :post do
    resource.recalculate!
    redirect_to admin_team_score_path(resource), notice: "Team score recalculated successfully."
  end

  index do
    selectable_column
    id_column
    column :team do |ts|
      link_to "Team ##{ts.team.num} - #{ts.team.name}", admin_team_path(ts.team)
    end
    column :round do |ts|
      link_to ts.round.event.name, admin_round_path(ts.round)
    end
    column :status do |ts|
      ts.show_status_ts
    end
    column :hole_played
    column "+-" do |ts|
      ts.stroke_play_score
    end
    column :brut_total
    column :net_total
    column :stb_total
    actions
  end

  filter :team, as: :select, collection: -> { Team.order(:num).map { |t| [ "Team ##{t.num} - #{t.name}", t.id ] } }
  filter :round, as: :select, collection: -> { Round.includes(:event).order("events.name").map { |r| [ r.event.name, r.id ] } }
  filter :status, as: :select, collection: TeamScore.statuses.keys
  filter :hole_played
  filter :brut_total
  filter :net_total
  filter :stb_total

  form do |f|
    f.inputs "Team Score Details" do
      f.input :team, as: :select, collection: Team.order(:num).map { |t| [ "Team ##{t.num} - #{t.name}", t.id ] }
      f.input :round, as: :select, collection: Round.includes(:event).order("events.name").map { |r| [ r.event.name, r.id ] }
      f.input :status, as: :select, collection: TeamScore.statuses.keys
      f.input :hole_played
      f.input :brut_total
      f.input :net_total
      f.input :stb_total
      f.input :stroke_play_score
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :team do |ts|
        link_to "Team ##{ts.team.num} - #{ts.team.name}", admin_team_path(ts.team)
      end
      row :round do |ts|
        link_to ts.round.event.name, admin_round_path(ts.round)
      end
      row :formula do |ts|
        formula = ts.team.slots.first&.flight&.config_teetime&.formula
        if formula
          "#{formula.name} (#{formula.nb_cards} card#{formula.nb_cards > 1 ? 's' : ''})"
        else
          "N/A"
        end
      end
      row :status do |ts|
        status_tag ts.status
      end
      row :hole_played
      row :start_hole do |ts|
        ts.start_hole
      end
      row "Stroke Play Score", :stroke_play_score do |ts|
        if ts.stroke_play_score && ts.stroke_play_score != 0
          ts.stroke_play_score
        else
          "N/A"
        end
      end
      row :brut_total
      row :net_total
      row :stb_total
      row :created_at
      row :updated_at
    end

    panel "Individual Scores" do
      table_for team_score.team.entries do
        column "Player" do |entry|
          entry.player&.full_name || "N/A"
        end
        column "Score" do |entry|
          score = Score.find_by(entry: entry, round: team_score.round)
          if score
            link_to "View Score", admin_score_path(score)
          else
            "No score"
          end
        end
        column "Holes Played" do |entry|
          score = Score.find_by(entry: entry, round: team_score.round)
          score&.hole_played || 0
        end
        column "Status" do |entry|
          score = Score.find_by(entry: entry, round: team_score.round)
          status_tag(score&.status) if score
        end
      end
    end

    active_admin_comments
  end
end
