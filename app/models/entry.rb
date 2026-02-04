class Entry < ApplicationRecord
  belongs_to :event
  belongs_to :player
  belongs_to :licence, optional: true
  belongs_to :playercat, optional: true
  belongs_to :team, optional: true

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "event_id", "id", "licence_id", "player_id", "status", "updated_at", "playercat_id", "hcp", "playing_hcp" ]
  end
  def self.ransackable_associations(auth_object = nil)
    [ "event", "player", "licence", "playercat", "team" ]
  end

  ransacker :playing_hcp do
    Arel.sql("(SELECT MAX(playing_hcp) FROM slots WHERE slots.team_id = entries.team_id)")
  end

  enum :status, { enter: 0, refused: 1, canceled: 2, disqualified: 3, noshow: 4 }
  # enum :status, [ :enter, :refused, :canceled, :disqualified, :noshow ]

  after_create :ensure_team
  after_save :add_licence_to_entry
  after_commit :set_team_resultcat, on: [ :create, :update ]
  after_commit :set_team_status, on: [ :create, :update ]

  def ensure_team
    return if team.present? || event.nil? || player.nil?

    team_name = "#{player.firstname} #{player.lastname}"
    team_status = status || :enter

    team = event.teams.create!(
      name: team_name,
      status: team_status
    )
    update(team: team)
  end

  def add_licence_to_entry
    if self.licence_id.nil?
      lic = self.player.licences.first
      hcp = lic.hcp
      if lic
        self.update_column(:licence_id, lic.id)
        self.update_column(:hcp, hcp)
      end
    end
    self.get_playercat
  end

  def set_team_resultcat
    return if team.nil?
    # Force reload of team with entries to ensure fresh data
    reloaded_team = Team.includes(:entries).find(team.id)
    reloaded_team.get_resultcat
  end

  def set_team_status
    return if team.nil?

    reloaded_team = Team.includes(:entries, :event).find(team.id)
    event_format = reloaded_team.event&.format

    if event_format == "team" || event_format == "bigteam"
      new_status = reloaded_team.entries.all?(&:enter?) ? :enter : :refused
    else
      new_status = status
    end

    reloaded_team.update_column(:status, new_status) if new_status.present?
  end

  def get_playercat
    player = self.player
    # licence = self.licence
    age = player.age
    hcp = self.hcp
    Playercat.all.each do |playercat|
      if playercat.events.include?(self.event)
        if playercat.agecats.exists?
          if playercat.agecats.where("age_low <= ? AND age_high >= ?", age, age).exists?
            if playercat.hcp_min <= hcp && playercat.hcp_max >= hcp
                if player.sexe == playercat.sexe
                  self.update_column(:playercat_id, playercat.id)
                  return playercat
                end
            end
          end
        end
      end
    end
    # No Catgory found
    self.update_column(:status, "refused")
    nil
  end
end
