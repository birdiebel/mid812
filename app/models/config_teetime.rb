class ConfigTeetime < ApplicationRecord
  belongs_to :round
  belongs_to :course
  belongs_to :formula, optional: true
  has_many :flights, dependent: :destroy

  def self.ransackable_attributes(auth_object = nil)
    [ "course_id", "created_at", "formula_id", "hcp_pc", "id", "id_value", "nb_slots", "nb_teams", "round_id", "start_hole", "start_time", "step", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "course", "flights", "formula", "round" ]
  end

  validates :start_hole, inclusion: { in: 1..18 }
  validates :nb_slots, inclusion: { in: 1..4 }
  validates :step, presence: true
  validates :start_time, presence: true

  # Set default nb_teams based on entries with status :enter
  before_validation :set_default_nb_teams, on: :create
  after_save :create_or_update_flights

  def set_default_nb_teams
    if nb_teams.nil? && round&.event
      self.nb_teams = round.event.entries.where(status: :enter).count
    end
  end

  def create_or_update_flights
    return if nb_teams.nil? || nb_slots.nil? || nb_slots.zero?

    # Calculate number of flights needed
    nb_flights = (nb_teams.to_f / nb_slots).ceil

    # Get existing flights
    existing_flights = flights.order(:num).to_a

    # Create or update flights
    (1..nb_flights).each do |num|
      flight = existing_flights.find { |f| f.num == num }
      if flight
        flight.update(status: :player) if flight.status != "player"
      else
        flight = flights.create!(num: num, status: :player)
      end

      # Create or update slots for this flight
      create_or_update_slots_for_flight(flight)
    end

    # Delete extra flights if nb_flights decreased
    flights.where("num > ?", nb_flights).destroy_all
  end

  def create_or_update_slots_for_flight(flight)
    existing_slots = flight.slots.order(:num).to_a

    # Create or update slots
    (1..nb_slots).each do |num|
      slot = existing_slots.find { |s| s.num == num }
      unless slot
        flight.slots.create!(num: num, entry_id: nil, playing_hcp: nil)
      end
    end

    # Delete extra slots if nb_slots decreased
    flight.slots.where("num > ?", nb_slots).destroy_all
  end
end
