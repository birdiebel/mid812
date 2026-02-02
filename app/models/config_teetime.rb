class ConfigTeetime < ApplicationRecord
  belongs_to :round
  belongs_to :course
  belongs_to :formula, optional: true
  has_many :flights, dependent: :destroy

  validates :start_hole, inclusion: { in: 1..18 }
  validates :nb_slots, inclusion: { in: 1..4 }
  validates :step, presence: true
  validates :start_time, presence: true

  # Set default nb_teams based on entries with status :enter
  before_validation :set_default_nb_teams, on: :create

  def set_default_nb_teams
    if nb_teams.nil? && round&.event
      self.nb_teams = round.event.entries.where(status: :enter).count
    end
  end
end
