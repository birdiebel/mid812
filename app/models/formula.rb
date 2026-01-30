class Formula < ApplicationRecord
  validates :name, presence: true
  validates :min_players, :max_players, presence: true, numericality: { greater_than_or_equal_to: 1 }

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "format", "id", "max_players", "min_players", "name", "updated_at" ]
  end
  def self.ransackable_associations(auth_object = nil)
    []
  end

  enum :format, [ :single, :team, :bigteam ]
end
