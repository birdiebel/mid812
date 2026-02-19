class Score < ApplicationRecord
  belongs_to :round
  belongs_to :slot, optional: true
  belongs_to :entry, optional: true
  belongs_to :team, optional: true

  accepts_nested_attributes_for :slot

  enum :status, { pending: 0, partial: 1, completed: 2, invalide: 3 }

  before_validation :assign_start_hole, if: -> { start_hole.blank? }
  before_save :calculate_recu_str
  before_save :calculate_net_and_stb_str
  before_save :update_hole_played_and_status
  after_save :update_team_score

  def self.ransackable_attributes(auth_object = nil)
    [ "brut_str", "created_at", "entry_id", "hole_played", "id", "id_value", "net_str", "playing_hcp", "recu_str", "round_id", "slot_id", "start_hole", "status", "stb_str", "team_id", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "entry", "round", "slot", "team" ]
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

  def computed_recu_array
    return [] unless entry && slot

    hcp = effective_playing_hcp_for_recu
    return [] unless hcp && hcp > 0

    tee = course_tee_for_entry
    return [] unless tee

    stroke_indexes = tee.str_to_array("stroke_str")
    return [] unless stroke_indexes.any?

    stroke_indexes.map do |stroke_index|
      full_strokes = hcp / 18
      extra_stroke = (hcp % 18) >= stroke_index ? 1 : 0
      full_strokes + extra_stroke
    end
  end

  def computed_net_array
    return [] unless slot && entry

    nb_hole = course_hole_count
    brut_values = normalized_brut_values(nb_hole)
    recu_values = normalized_recu_values(nb_hole)

    (0...nb_hole).map do |index|
      brut_value = brut_values[index]
      next "" if brut_value.blank?
      next "x" if brut_value == "x" || brut_value.to_i.zero?

      (brut_value.to_i - recu_values[index].to_i).to_s
    end
  end

  def computed_stb_array
    return [] unless slot && entry

    nb_hole = course_hole_count
    net_values = computed_net_array
    par_values = course_tee_for_entry&.str_to_array("par_str") || []

    (0...nb_hole).map do |index|
      net_value = net_values[index].to_s
      next "" if net_value.blank?
      next "x" if net_value == "x"

      stb_value = (par_values[index].to_i - net_value.to_i) + 2
      stb_value.negative? ? "x" : stb_value.to_s
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
    recu_per_hole = computed_recu_array
    return if recu_per_hole.empty?

    # Store as comma-separated string
    self.recu_str = recu_per_hole.join(",")

    Rails.logger.debug "Score#calculate_recu_str: hcp=#{effective_playing_hcp_for_recu}, recu_str=#{self.recu_str}"
  end

  def calculate_net_and_stb_str
    return unless brut_str.present?

    net_values = computed_net_array
    stb_values = computed_stb_array
    return if net_values.empty? && stb_values.empty?

    self.net_str = net_values.join(",") if net_values.any?
    self.stb_str = stb_values.join(",") if stb_values.any?
  end

  def effective_playing_hcp_for_recu
    return playing_hcp.to_i if playing_hcp.present?

    formula_key = slot&.flight&.config_teetime&.formula&.name.to_s.downcase.gsub(/[^a-z0-9]/, "")

    if formula_key.include?("foursome")
      slot&.playing_hcp&.to_i
    else
      slot&.score_playing_hcp_for(entry)&.to_i
    end
  end

  def course_tee_for_entry
    playercat = entry.playercat
    return nil unless playercat

    course = slot.flight&.config_teetime&.course
    return nil unless course

    course.tees.find_by(teebox: playercat.teebox)
  end

  def course_hole_count
    nb_hole = slot&.flight&.config_teetime&.course&.nb_hole.to_i
    nb_hole.positive? ? nb_hole : 18
  end

  def normalized_brut_values(nb_hole)
    values = (brut_str || "").split(",")
    (0...nb_hole).map { |index| values[index].to_s.strip }
  end

  def normalized_recu_values(nb_hole)
    values = if recu_str.present?
      recu_str.split(",")
    else
      computed_recu_array.map(&:to_s)
    end

    (0...nb_hole).map { |index| values[index].to_i }
  end

  def update_hole_played_and_status
    puts "Calculating hole_played and status for Score ID: #{id}, brut_str: #{brut_str}"
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

    if played >= nb_hole
      self.status = :completed
    elsif played > 0
      self.status = :partial
    else
      self.status = :pending
    end
  end

  def update_team_score
    score_team = team || entry&.team
    return unless score_team && round

    team_score = TeamScore.find_or_create_by(team: score_team, round: round)
    team_score.recalculate!(self.status)
  end
end
