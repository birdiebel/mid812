class Slot < ApplicationRecord
  belongs_to :flight
  belongs_to :team, optional: true
  has_many :scores, dependent: :destroy

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "team_id", "flight_id", "id", "num", "playing_hcp", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "team", "flight" ]
  end

  before_update :before_update_callback
  after_commit :sync_playing_hcps, on: [ :create, :update ]

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
          entry.update_column(:playing_hcp, computed_hcp) if entry
        when formula_key.include?("4bbb") || formula_key.include?("fourball") || formula_key.include?("four ball")
          # Calculate playing_hcp for each player individually
          computed_hcps = team.entries.map do |entry|
            computed_hcp = playing_hcp_single(entry)
            entry.update_column(:playing_hcp, computed_hcp)
            computed_hcp
          end
          # Set slot playing_hcp to the best (lowest) of the team
          self.playing_hcp = computed_hcps.compact.min
        when formula_key.include?("foursome") || formula_key.include?("greensome")
          # Calculate playing_hcp based on team total_hcp, apply to both players
          computed_hcp = playing_hcp_team(team)
          self.playing_hcp = computed_hcp
          team.entries.each do |entry|
            entry.update_column(:playing_hcp, computed_hcp)
          end
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
      entry.update_column(:playing_hcp, computed_hcp) if entry
    when formula_key.include?("4bbb") || formula_key.include?("fourball") || formula_key.include?("4ball")
      computed_hcps = team.entries.map do |entry|
        computed_hcp = playing_hcp_single(entry)
        entry.update_column(:playing_hcp, computed_hcp)
        computed_hcp
      end
      update_column(:playing_hcp, computed_hcps.compact.min)
    when formula_key.include?("foursome") || formula_key.include?("greensome")
      computed_hcp = playing_hcp_team(team)
      update_column(:playing_hcp, computed_hcp)
      team.entries.each do |entry|
        entry.update_column(:playing_hcp, computed_hcp)
      end
    else
      update_column(:playing_hcp, nil)
    end
  end

  def playing_hcp_single(entry)
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
    if rating && slope
      # Compute playing_hcp
      hcp = ((hcp * slope) / 113.0 + (rating - par)).round
    end
    # return hcp
    hcp
  end

  def playing_hcp_team(team)
    return nil unless team
    # Get total HCP
    total_hcp = team.total_hcp
    return nil unless total_hcp

    # Get teebox from first entry (assuming same teebox for team)
    first_entry = team.entries.first
    teebox_name = first_entry&.playercat&.teebox
    return total_hcp unless teebox_name

    # Course
    course = self.flight&.config_teetime&.course
    tee = course&.tees&.find_by(teebox: teebox_name)
    return total_hcp unless tee

    # rating and slope du teebox
    rating = tee.rating
    slope = tee.slope
    par = tee.sum_str("par_str")
    if rating && slope
      # Compute playing_hcp based on total team hcp
      playing_hcp = ((total_hcp * slope) / 113.0 + (rating - par)).round
    else
      playing_hcp = total_hcp
    end

    playing_hcp
  end

  def normalize_formula_key(formula_name)
    formula_name.to_s.downcase.gsub(/[^a-z0-9]/, "")
  end
end
