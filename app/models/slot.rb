class Slot < ApplicationRecord
  belongs_to :flight
  belongs_to :team, optional: true
  has_many :scores, dependent: :destroy

  accepts_nested_attributes_for :team

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "team_id", "flight_id", "id", "num", "playing_hcp", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "team", "flight" ]
  end

  before_update :before_update_callback
  # after_commit :sync_playing_hcps, on: [ :create, :update ]
  def tee
    flight&.config_teetime&.course&.tees&.find_by(teebox: team.entries.first.playercat.teebox) if team && team.entries.exists?
  end

  def before_update_callback
    puts "Before updating Slot #{id}: team_id=#{team_id}, flight_id=#{flight_id}, num=#{num}, playing_hcp=#{playing_hcp}"
    puts "  team_id changed: #{team_id_changed?}, was: #{team_id_was}, now: #{team_id}"
    if team_id?
      team = Team.find_by(id: team_id)
      puts "  Found team: #{team&.id} - #{team&.name}"
      formula_name = self.flight&.config_teetime&.formula&.name
      formula_key = normalize_formula_key(formula_name)
      puts "  Formula: #{formula_name} (#{formula_key})"
      if team && team.entries.exists?
        case

        when formula_key == "single"
          entry = team.entries.first
          computed_hcp = playing_hcp_single(entry)
          self.playing_hcp = computed_hcp

        when formula_key.include?("4bbb") || formula_key.include?("fourball") || formula_key.include?("four ball")
          # Calculate playing_hcp for each player individually
          computed_hcps = team.entries.map do |entry|
            playing_hcp_single(entry)
          end
          # Set slot playing_hcp to the best (lowest) of the team
          self.playing_hcp = computed_hcps.compact.min

        when formula_key.include?("foursome")
          computed_hcp = playing_hcp_foursome(team)
          self.playing_hcp = computed_hcp

        when formula_key.include?("greensome")
          computed_hcp = playing_hcp_greensome(team)
          self.playing_hcp = computed_hcp
        else
          self.playing_hcp = nil
        end
      else
        self.playing_hcp = nil
      end
    else
      self.playing_hcp = nil
    end
  end

  def sync_playing_hcps
    puts "sync_playing_hcps called for Slot #{id}, team_id: #{team_id}"
    return unless team_id?

    team = Team.includes(:entries).find_by(id: team_id)
    puts "  Team found: #{team&.id}, entries: #{team&.entries&.count}"
    return unless team && team.entries.exists?

    formula_name = self.flight&.config_teetime&.formula&.name
    formula_key = normalize_formula_key(formula_name)
    puts "  Formula: #{formula_name} (#{formula_key})"

    case
    when formula_key == "single"
      entry = team.entries.first
      computed_hcp = playing_hcp_single(entry)
      update_column(:playing_hcp, computed_hcp)

    when formula_key.include?("4bbb") || formula_key.include?("fourball") || formula_key.include?("4ball")
      computed_hcps = team.entries.map do |entry|
        playing_hcp_single(entry)
      end
      update_column(:playing_hcp, computed_hcps.compact.min)

    when formula_key.include?("foursome")
      computed_hcp = playing_hcp_foursome(team)
      update_column(:playing_hcp, computed_hcp)

    when formula_key.include?("greensome")
      computed_hcp = playing_hcp_greensome(team)
      update_column(:playing_hcp, computed_hcp)

    else
      update_column(:playing_hcp, nil)
    end
  end

  def playing_hcp_single(entry, round_result: true)
    return nil unless entry
    # Teams
    # team = entry.team
    # Licence
    licence = entry.licence
    # Hcp
    hcp = licence&.hcp || entry.hcp
    return nil if hcp.nil?
    # Playercat.teebox
    teebox_name = entry.playercat&.teebox
    return hcp unless teebox_name
    # Course
    course = self.flight&.config_teetime&.course
    tee = course&.tees&.find_by(teebox: teebox_name)
    return hcp unless tee
    # rating and slope du teebox
    rating = tee.rating
    slope = tee.slope
    par = tee.sum_str("par_str")
    # hcp pourcentage from config_teetime
    hcp_pc = self.flight&.config_teetime&.hcp_pc || 100
    hcp_pd = hcp_pc.to_f / 100.0
    if rating && slope
      # Compute playing_hcp
      hcp = (((hcp * slope) / 113.0 + (rating - par)) * hcp_pd)
      hcp = hcp.round if round_result
    end
    # return hcp with adjustment hcp_pc
    hcp
  end

  def playing_hcp_foursome(team)
    return nil unless team

    individual_playing_hcps = team.entries.first(2).map { |entry| playing_hcp_single(entry) }.compact
    return nil unless individual_playing_hcps.size == 2

    ((individual_playing_hcps.sum) * 0.5).round
  end

  def playing_hcp_greensome(team)
    return nil unless team

    individual_playing_hcps = team.entries.first(2).map do |entry|
      playing_hcp_single(entry, round_result: false)
    end.compact
    return nil unless individual_playing_hcps.size == 2

    low_hcp, high_hcp = individual_playing_hcps.sort
    ((low_hcp * 0.6) + (high_hcp * 0.4)).round
  end

  def normalize_formula_key(formula_name)
    formula_name.to_s.downcase.gsub(/[^a-z0-9]/, "")
  end

  def score_playing_hcp_for(entry)
    return nil unless entry

    nb_cards = flight&.config_teetime&.formula&.nb_cards.to_i

    if nb_cards <= 1
      playing_hcp
    else
      playing_hcp_single(entry)
    end
  end
end
