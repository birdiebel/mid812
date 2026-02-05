class Score < ApplicationRecord
  belongs_to :round
  belongs_to :slot
  belongs_to :entry

  accepts_nested_attributes_for :slot

  enum :status, { partial: 0, completed: 1, invalide: 2 }

  before_validation :assign_start_hole, if: -> { start_hole.blank? }
  before_save :calculate_recu_str
  before_save :update_hole_played_and_status
  after_save :update_team_score

  def self.ransackable_attributes(auth_object = nil)
    [ "brut_str", "created_at", "entry_id", "hole_played", "id", "id_value", "net_str", "recu_str", "round_id", "slot_id", "start_hole", "status", "stb_str", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "entry", "round", "slot" ]
  end

  def brut(var)
    calculate_total(brut_str, var)
  end

  def net(var)
    calculate_total(net_str, var)
  end

  def stb(var)
    calculate_total(stb_str, var)
  end

  def stroke_play_score
    return "N.A." unless brut_str.present?

    # Parse brut values
    brut_values = brut_str.split(",").map { |v| v.blank? || v.strip == "" ? nil : v.to_i }

    # Get only played holes (non-nil, non-zero)
    played_holes = brut_values.each_with_index.select { |v, _| v && v != 0 }.map { |_, i| i }
    return "N.A." if played_holes.empty?

    # Calculate brut total for played holes only
    brut_total = played_holes.sum { |i| brut_values[i] }

    # Get course par
    course = slot&.flight&.config_teetime&.course
    return "N.A." unless course

    tee = course.tees.find_by(teebox: entry&.playercat&.teebox)
    return "N.A." unless tee

    par_array = tee.str_to_array("par_str")

    # Calculate par total for played holes only
    par_total = played_holes.sum { |i| par_array[i] || 0 }
    return "N.A." unless par_total > 0

    difference = brut_total - par_total

    if difference == 0
      "even"
    elsif difference > 0
      "+#{difference}"
    else
      "#{difference}"
    end
  end

  private

  def calculate_total(score_str, var)
    return 0 unless score_str.present?

    values = score_str.split(",").map do |v|
      next 0 if v.blank? || v.strip == "" || v == "x"
      v.to_i
    end

    case var.to_s
    when "front"
      values.first(9).sum
    when "back"
      values.slice(9, 9).sum
    when "total"
      values.sum
    else
      0
    end
  end

  def assign_start_hole
    return if slot.nil?
    config = slot.flight&.config_teetime
    self.start_hole = config.start_hole if config
  end

  def calculate_recu_str
    return unless entry && slot

    # Get playing_hcp from entry
    hcp = entry.playing_hcp&.to_i
    return unless hcp && hcp > 0

    # Get the tee based on playercat teebox
    playercat = entry.playercat
    return unless playercat

    course = slot.flight&.config_teetime&.course
    return unless course

    tee = course.tees.find_by(teebox: playercat.teebox)
    return unless tee

    # Get stroke index array from tee
    stroke_indexes = tee.str_to_array("stroke_str")
    return unless stroke_indexes.any?

    # Calculate strokes received for each hole
    recu_per_hole = stroke_indexes.map do |stroke_index|
      # Full rounds of strokes
      full_strokes = hcp / 18
      # Extra strokes on hardest holes
      extra_stroke = (hcp % 18) >= stroke_index ? 1 : 0
      full_strokes + extra_stroke
    end

    # Store as comma-separated string
    self.recu_str = recu_per_hole.join(",")

    Rails.logger.debug "Score#calculate_recu_str: hcp=#{hcp}, recu_str=#{self.recu_str}"
  end

  def update_hole_played_and_status
    return unless brut_str.present?

    # Get course to determine total holes
    course = slot&.flight&.config_teetime&.course
    return unless course

    nb_hole = course.nb_hole.to_i
    nb_hole = 18 if nb_hole <= 0

    # Parse brut_str and count non-empty holes
    brut_values = brut_str.split(",")
    played = brut_values.count { |v| v.present? && v.strip != "" }

    self.hole_played = played

    # Check if stroke_play and if there are any zeros
    team = slot&.team
    has_zero = brut_values.any? { |v| v.present? && v.to_i == 0 }

    if team&.resultcat&.scoring == "stroke_play" && has_zero
      self.status = :invalide
    else
      if played >= nb_hole
        self.status = :completed
      else
        self.status = :partial
      end
    end
  end

  def update_team_score
    team = entry&.team
    return unless team && round

    team_score = TeamScore.find_or_create_by(team: team, round: round)
    team_score.recalculate!
  end
end
