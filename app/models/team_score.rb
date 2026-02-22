class TeamScore < ApplicationRecord
  belongs_to :team
  belongs_to :round

  after_commit :broadcast_ldb_refresh, on: %i[create update]

  # enum :status, { enter: 0, refused: 1, canceled: 2, disqualified: 3, noshow: 4 }
  enum :status, { pending: 0, partial: 1, completed: 2, invalide: 3 }

  validates :team_id, uniqueness: { scope: :round_id }

  def self.ransackable_attributes(auth_object = nil)
    %w[
      brut_str
      brut_total
      created_at
      diff_par
      hole_played
      id
      net_str
      net_total
      par_total
      playing_hcp
      recu_str
      round_id
      start_hole
      status
      stb_str
      stb_total
      stroke_play_score
      team_id
      updated_at
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[round team]
  end

  def show_status_ts
    if status.nil?
      "N/A"
    elsif status != "enter"
      "<span style=\"color: red;\">#{status.to_s.humanize}</span>".html_safe
    else
      "Enter"
    end
  end

  def hole_played_show
    hole_played
  end

  # Recalcule le score du team selon la formule
  def recalculate!(score_status = nil)
    puts "param score_status: #{score_status}"

    scores = scores_for_round
    formula = formula_for_round(scores)
    nb_cards = formula&.nb_cards.to_i
    scoring_mode = self.team&.resultcat&.scoring
    return if nb_cards <= 0

    # Update le status du team si fourni
    self.status = score_status if score_status.present?
    case nb_cards
    when 1
      # Single/Foursome/Greensome: copie du score unique
      copy_from_single_score(scores)
    else
      # Multi-cards (4BBB): calcul best ball
      calculate_best_ball(scores)
    end

    if scoring_mode == "stroke_play" && team_invalid_for_stroke_play?
      self.status = :invalide
      self.team.status = :disqualified
    else
      self.team.status = :enter
    end

    self.team.save!

    puts "Setting team #{team_id} status to #{self.team.status} with team_score status #{self.status}"

    save!
  end

  def parse_stroke_play_score(sp_score)
    return 0 if sp_score.nil? || sp_score == "N.A."
    return 0 if sp_score == "even"

    # Convertir "+2" => 2, "-3" => -3
    sp_score.to_s.gsub("+", "").to_i
  end

  def style_for_stroke_play(sp_score)
    if sp_score.nil? || sp_score == "N.A."
      ""
    elsif sp_score.to_i == 0
      "color: green;"
    elsif sp_score.to_i < 0
      "color: red;"
    else
      "color: blue;"
    end
  end

  private

  def copy_from_single_score(scores = nil)
    round_scores = scores.presence || scores_for_round

    # Cherche le score qui a des données (brut_str present)
    score = round_scores.find { |s| s.brut_str.present? }

    # Si aucun score avec données, prend le premier score de la première entry
    score ||= round_scores.first
    return unless score

    self.hole_played = score.hole_played || 0
    self.start_hole = score.start_hole || 1
    self.playing_hcp = score.playing_hcp
    self.brut_str = score.brut_str
    self.net_str = score.net_str
    self.stb_str = score.stb_str
    self.recu_str = score.recu_str
    self.status = score.status || :pending
    self.brut_total = score.brut("total").to_i
    self.net_total = score.net("total").to_i
    self.stb_total = score.stb("total").to_i
    par_and_diff = par_and_diff_for_score(score)
    self.par_total = par_and_diff[:par_total]
    self.diff_par = par_and_diff[:diff_par]

    # stroke_play_score retourne une string, il faut la convertir
    sp_score = score.stroke_play_score
    self.stroke_play_score = parse_stroke_play_score(sp_score)
  end

  def calculate_best_ball(scores = nil)
    scores = scores.presence || scores_for_round
    return if scores.empty?

    course = scores.first.slot&.flight&.config_teetime&.course
    nb_hole = course&.nb_hole.to_i
    nb_hole = 18 if nb_hole <= 0

    brut_arrays =
      scores.map { |score| split_score_array(score.brut_str, nb_hole) }
    net_arrays =
      scores.map { |score| split_score_array(score.net_str, nb_hole) }
    stb_arrays =
      scores.map { |score| split_score_array(score.stb_str, nb_hole) }

    team_brut = build_best_ball_array(brut_arrays, :min)
    team_net = build_best_ball_array(net_arrays, :min)
    team_stb = build_best_ball_array(stb_arrays, :max)

    self.brut_str = team_brut.join(",")
    self.net_str = team_net.join(",")
    self.stb_str = team_stb.join(",")
    self.recu_str = nil
    self.start_hole = scores.first.start_hole || 1
    self.playing_hcp = nil

    # Prend le minimum de hole_played (le plus conservateur)
    self.hole_played = team_brut.count { |value| value.present? }

    if scores.all? { |score| score.status == "completed" }
      self.status = :completed
    elsif scores.any? do |score|
          score.status == "partial" || score.status == "completed"
        end
      self.status = :partial
    else
      self.status = :pending
    end

    # Pour 4BBB: on prendra le meilleur score par trou
    self.brut_total = total_from_team_array(team_brut)
    self.net_total = total_from_team_array(team_net)
    self.stb_total = total_from_team_array(team_stb)

    # Calcul du stroke play score
    sp_scores =
      scores.map { |s| parse_stroke_play_score(s.stroke_play_score) }.compact
    self.stroke_play_score = sp_scores.min || 0

    best_score = scores.min_by { |s| s.brut("total") || 0 }
    par_and_diff = par_and_diff_for_score(best_score)
    self.par_total = par_and_diff[:par_total]
    self.diff_par = par_and_diff[:diff_par]
  end

  def split_score_array(score_str, size)
    values = (score_str || "").split(",")
    (0...size).map { |index| values[index].to_s.strip }
  end

  def build_best_ball_array(arrays, mode)
    return [] if arrays.empty?

    hole_count = arrays.first.size

    (0...hole_count).map do |index|
      hole_values = arrays.map { |array| array[index] }
      numeric_values =
        hole_values.filter_map do |value|
          next if value.blank? || value == "x" || value.to_i.zero?
          value.to_i
        end

      if numeric_values.any?
        selected_value = mode == :max ? numeric_values.max : numeric_values.min
        selected_value.to_s
      elsif hole_values.any? { |value| value == "x" || value == "0" }
        "x"
      else
        ""
      end
    end
  end

  def total_from_team_array(values)
    values.sum do |value|
      integer_value = value.to_i
      integer_value.positive? ? integer_value : 0
    end
  end

  def par_and_diff_for_score(score)
    return { par_total: 0, diff_par: 0 } unless score&.brut_str.present?

    brut_values =
      score
        .brut_str
        .split(",")
        .map { |value| value.blank? || value.strip == "" ? nil : value.to_i }

    played_holes =
      brut_values
        .each_with_index
        .select { |value, _| value && value > 0 }
        .map { |_, index| index }
    return { par_total: 0, diff_par: 0 } if played_holes.empty?

    course = score.slot&.flight&.config_teetime&.course
    return { par_total: 0, diff_par: 0 } unless course

    teebox = score.entry&.playercat&.teebox
    tee = course.tees.find_by(teebox: teebox)
    return { par_total: 0, diff_par: 0 } unless tee

    par_array = tee.str_to_array("par_str")
    par_total = played_holes.sum { |index| par_array[index] || 0 }
    brut_total_played = played_holes.sum { |index| brut_values[index] || 0 }

    { par_total: par_total, diff_par: brut_total_played - par_total }
  end

  def scores_for_round
    team.entries.map { |entry| entry.scores.find_by(round: round) }.compact
  end

  def formula_for_round(scores)
    score_formula =
      scores
        .filter_map { |score| score.slot&.flight&.config_teetime&.formula }
        .first
    return score_formula if score_formula

    slot =
      round
        .slots
        .joins(:flight)
        .where(team_id: team_id)
        .where(
          flights: {
            config_teetime_id: round.config_teetimes.select(:id)
          }
        )
        .order("flights.flight_time ASC")
        .first

    slot&.flight&.config_teetime&.formula
  end

  def team_invalid_for_stroke_play?
    values =
      (brut_str || "").split(",").map { |value| value.to_s.strip.downcase }
    values.any? { |value| value == "0" || value == "x" }
  end

  def broadcast_ldb_refresh
    event_id = team&.event_id
    return unless event_id

    ActionCable.server.broadcast(
      "ldb_refresh_event_#{event_id}",
      {
        type: "scoring_saved",
        event_id: event_id,
        team_id: team_id,
        round_id: round_id
      }
    )
  end
end
