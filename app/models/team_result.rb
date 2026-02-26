class TeamResult < ApplicationRecord
  belongs_to :event
  belongs_to :team

  def self.ransackable_attributes(auth_object = nil)
    [ "brut", "created_at", "event_id", "id", "net", "par", "points", "position", "stb", "team_id", "updated_at" ]
  end
  def self.ransackable_associations(auth_object = nil)
    [ "event", "team" ]
  end

  # Calculations will be implemented at event closure
  # def calculate_result
  #   # Implement the logic to calculate par, brut, net, stb, position, and points based on the team's performance in the event.
  # end
  # Calculations will be implemented at event closure
end
