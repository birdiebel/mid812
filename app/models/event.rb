class Event < ApplicationRecord
  belongs_to :tour
  has_many :event_playercats, dependent: :destroy
  has_many :playercats, through: :event_playercats
  has_many :event_resultcats, dependent: :destroy
  has_many :resultcats, through: :event_resultcats
  has_and_belongs_to_many :courses
  has_many :entries, dependent: :destroy
  has_many :rounds, dependent: :destroy
  has_many :teams, dependent: :destroy

  accepts_nested_attributes_for :event_playercats, allow_destroy: true, reject_if: proc { |attributes| attributes["playercat_id"].blank? }
  accepts_nested_attributes_for :event_resultcats, allow_destroy: true, reject_if: proc { |attributes| attributes["resultcat_id"].blank? }

  validates :name, presence: true
  validate :at_least_one_resultcat
  validate :at_least_one_playercat

  after_save :sync_playercats_ids
  after_save :sync_resultcats_ids

  # Retourne les équipes de l'event avec la somme des brut_total, le détail par round et la position (dense ranking)
  # Seules les équipes avec status = 'enter' sont prises en compte
  # Résultat : array de hashes [{ team: <Team>, brut_total: <somme>, par_round: { round_id => brut_total, ... }, position: <int> }, ...]
  def teams_brut_totals_with_rounds(resultcat_id = nil)
    teams_scope = teams.joins(:resultcat)
      .where(status: :enter, resultcat_id: resultcat_id)
      .where.not(team_scores: { hole_played: 0 })
      .includes(team_scores: :round, resultcat: {})
      .order("resultcats.priority ASC")


    # On prépare le classement selon le scoring du premier team (ou par défaut)
    first_team = teams_scope.first

    resultcat_scoring = first_team&.resultcat&.scoring
    this_order = case resultcat_scoring
    when "stroke_play"
        ->(h) { [ h[:brut_total] ] }
    when "stableford"
        ->(h) { [ -h[:stb_total] ] }
    else
        ->(h) { [ h[:brut_total] ] }
    end

    running_rounds = self.rounds.where(status: "running").first

    if running_rounds.nil?
      return []
    end

    leaderboard = teams_scope.map do |team|
      # Group scores by round
      scores_by_round = team.team_scores.group_by(&:round_id)
      brut_by_round = scores_by_round.transform_values { |scores| scores.sum(&:brut_total) }
      net_by_round = scores_by_round.transform_values { |scores| scores.sum(&:net_total) }
      stb_by_round = scores_by_round.transform_values { |scores| scores.sum(&:stb_total) }

      brut_total = brut_by_round.values.sum
      net_total = net_by_round.values.sum
      stb_total = stb_by_round.values.sum

      team_hole_played = team.round_hole_played(running_rounds.id)

      {
        team: team,
        resultcat_id: team.resultcat_id,
        brut_total: brut_total,
        net_total: net_total,
        stb_total: stb_total,
        brut_by_round: brut_by_round,
        net_by_round: net_by_round,
        stb_by_round: stb_by_round,
        team_hole_played: team_hole_played
      }
    end.sort_by(&this_order)

    position = 1
    previous_total = nil
    leaderboard.each_with_index do |row, idx|
      if previous_total != row[:brut_total]
        position = idx + 1
      end
      row[:position] = position
      previous_total = row[:brut_total]
    end
    leaderboard
  end

  # Retourne score, détail par round et position pour un team donné (seulement si status = 'enter')
  def team_brut_total_with_position(team)
    leaderboard = teams_brut_totals_with_rounds(team.resultcat_id)
    leaderboard.find { |r| r[:team].id == team.id }
  end

  def entries_valid
    entries.where.not(status: :refused).count
  end

  def at_least_one_resultcat
    if resultcats.empty? && (!@resultcats_ids_to_sync || @resultcats_ids_to_sync.empty?)
      errors.add(:base, "Event must have at least one result category")
    end
  end

  def at_least_one_playercat
    if playercats.empty? && (!@playercats_ids_to_sync || @playercats_ids_to_sync.empty?)
      errors.add(:base, "Event must have at least one player category")
    end
  end

  def playercats_ids=(ids)
    @playercats_ids_to_sync = ids.reject(&:blank?).map(&:to_i) if ids.present?
  end

  def playercats_ids
    @playercats_ids_to_sync || playercats.pluck(:id)
  end

  def resultcats_ids=(ids)
    @resultcats_ids_to_sync = ids.reject(&:blank?).map(&:to_i) if ids.present?
  end

  def resultcats_ids
    @resultcats_ids_to_sync || resultcats.pluck(:id)
  end

  def sync_playercats_ids
    return unless @playercats_ids_to_sync

    current_ids = event_playercats.pluck(:playercat_id)
    ids_to_add = @playercats_ids_to_sync - current_ids
    ids_to_remove = current_ids - @playercats_ids_to_sync

    event_playercats.where(playercat_id: ids_to_remove).destroy_all
    ids_to_add.each do |playercat_id|
      event_playercats.create!(playercat_id: playercat_id)
    end

    @playercats_ids_to_sync = nil
  end

  def sync_resultcats_ids
    return unless @resultcats_ids_to_sync

    current_ids = event_resultcats.pluck(:resultcat_id)
    ids_to_add = @resultcats_ids_to_sync - current_ids
    ids_to_remove = current_ids - @resultcats_ids_to_sync

    event_resultcats.where(resultcat_id: ids_to_remove).destroy_all
    ids_to_add.each do |resultcat_id|
      event_resultcats.create!(resultcat_id: resultcat_id)
    end

    @resultcats_ids_to_sync = nil
  end



  # Set default values
  before_create :set_default_values

  def set_default_values
    self.date_event ||= Date.current
    self.date_open ||= Date.current
    self.date_close ||= Date.current
    self.actif_round = 1 if self.actif_round.nil?
    self.fee = 0.0 if self.fee.nil?
    self.fee_member = 0.0 if self.fee_member.nil?
  end

  def self.ransackable_associations(auth_object = nil)
    [ "tour" ]
  end
  def self.ransackable_attributes(auth_object = nil)
    [ "actif", "created_at", "id", "name", "status", "tour_id", "updated_at", "format", "date_event", "date_open", "date_close", "nb_rounds" ]
  end

  enum :status, [ :created, :online, :registration, :waiting, :running, :terminated, :canceled ]
  enum :format, [ :single, :team, :bigteam ]
  enum :scoring, [ :stroke_play, :stableford ]

  amoeba do
    enable
    include_associations :playercats
    include_associations :resultcats
  end

  def my_playercats(licence)
    player = licence.player
    hcp = licence.hcp
    sexe = player.sexe
    matched_playercats = nil
    self.playercats.each do |pcat|
      if pcat.sexe == 2 # unisex
        if pcat.hcp_max <= hcp && pcat.hcp_min >= hcp && pcat.match_agecat(player.age_category_id)
          matched_playercats = pcat.name
        end
      else
        if pcat.hcp_max <= hcp && pcat.hcp_min >= hcp && pcat.match_sexe(sexe) && pcat.match_agecat(player.age_category_id)
          matched_playercats = pcat.name
        end
      end
    end
    if matched_playercats.nil?
      "N/A".html_safe
    else
      matched_playercats
    end
  end

  def copy_record(new_name)
    new_event = self.dup
    new_event.name = new_name
    new_event.status = :created
    new_event.actif = false
    new_event.actif_round = 1
    new_event.save!
    self.playercats.each do |pcat|
      new_event.playercats << pcat
    end
    self.resultcats.each do |rcat|
      new_event.resultcats << rcat
    end
    new_event
  end

  def seed_register_player
    Player.all.each do |player|
      next if self.entries.exists?(player_id: player.id)
      entry = Entry.new
      entry.player = player
      entry.event = self
      entry.save
    end
  end
end
