class TeamScore < ApplicationRecord
  belongs_to :team
  belongs_to :round

  enum :status, { enter: 0, refused: 1, canceled: 2, disqualified: 3, noshow: 4 }
  # enum :status, { partial: 0, complete: 1, validated: 2, dnf: 3, dns: 4, dsq: 5 }

  validates :team_id, uniqueness: { scope: :round_id }

  def self.ransackable_attributes(auth_object = nil)
    [ "brut_total", "created_at", "hole_played", "id", "net_total",
      "round_id", "status", "stb_total", "stroke_play_score", "team_id", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "round", "team" ]
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
    # Récupère la formule depuis le slot du team
    slot = team.slots.joins(:flight).where(flights: { config_teetime_id: round.config_teetimes.pluck(:id) }).first
    formula = slot&.flight&.config_teetime&.formula
    return unless formula

    # new_status = :enter # Valeur par défaut

    if score_status.present? && score_status == "invalide"
      self.team.status = :disqualified
      self.team.save!
    end

    puts "Setting team #{team_id} status to #{self.team.status} due to score status #{score_status}"

    # Update le status du team si fourni
    self.status = self.team.status 

    case formula.nb_cards
    when 1
      # Single/Foursome/Greensome: copie du score unique
      copy_from_single_score
    when 2
      # 4BBB: calcul best ball
      calculate_best_ball
    end

    save!
  end

  def start_hole
    score = team.entries.first&.scores&.find_by(round: round)
    score&.start_hole || 1
  end

  private

  def copy_from_single_score
    # Cherche le score qui a des données (brut_str present)
    score = nil
    team.entries.each do |e|
      score = e.scores.where(round: round).find { |s| s.brut_str.present? }
      break if score.present?
    end

    # Si aucun score avec données, prend le premier score de la première entry
    score ||= team.entries.first&.scores&.order(:id)&.first
    return unless score

    self.hole_played = score.hole_played || 0
    self.status = team.status
    self.brut_total = score.brut("total").to_i
    self.net_total = score.net("total").to_i
    self.stb_total = score.stb("total").to_i

    # stroke_play_score retourne une string, il faut la convertir
    sp_score = score.stroke_play_score
    self.stroke_play_score = parse_stroke_play_score(sp_score)
  end

  def calculate_best_ball
    scores = team.entries.map { |e| e.scores.find_by(round: round) }.compact
    return if scores.empty?

    # Prend le minimum de hole_played (le plus conservateur)
    self.hole_played = scores.map { |s| s.hole_played || 0 }.min

    # Status: si l'un est complete, le team est complete
    self.status = scores.any? { |s| s.status == "complete" } ? :complete : :partial

    # Pour 4BBB: on prendra le meilleur score par trou
    # Pour l'instant, on prend le meilleur total (à affiner selon les règles)
    brut_totals = scores.map { |s| s.brut("total") || 0 }
    self.brut_total = brut_totals.min

    net_totals = scores.map { |s| s.net("total") || 0 }
    self.net_total = net_totals.min

    stb_totals = scores.map { |s| s.stb("total") || 0 }
    self.stb_total = stb_totals.max

    # Calcul du stroke play score
    sp_scores = scores.map { |s| parse_stroke_play_score(s.stroke_play_score) }.compact
    self.stroke_play_score = sp_scores.min || 0
  end

  def parse_stroke_play_score(sp_score)
    return 0 if sp_score.nil? || sp_score == "N.A."
    return 0 if sp_score == "even"

    # Convertir "+2" => 2, "-3" => -3
    sp_score.to_s.gsub("+", "").to_i
  end
end
