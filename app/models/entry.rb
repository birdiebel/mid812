class Entry < ApplicationRecord
  belongs_to :event
  belongs_to :player
  belongs_to :licence, optional: true
  belongs_to :playercat, optional: true

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "event_id", "id", "licence_id", "player_id", "status", "updated_at", "playercat_id", "hcp" ]
  end
  def self.ransackable_associations(auth_object = nil)
    [ "event", "player", "licence", "playercat" ]
  end

  enum :status, { enter: 0, refused: 1, canceled: 2, disqualified: 3, noshow: 4 }
  # enum :status, [ :enter, :refused, :canceled, :disqualified, :noshow ]

  after_save :add_licence_to_entry

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
