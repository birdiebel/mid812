class Flight < ApplicationRecord
  belongs_to :config_teetime
  has_many :slots, dependent: :destroy

  enum :status, { player: 0, gap: 1 }

  def self.ransackable_attributes(auth_object = nil)
    [ "config_teetime_id", "created_at", "id", "num", "status", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "config_teetime" ]
  end

  def set_marker
    nbTeams = self.slots.where.not(team_id: nil).count
    puts "nbTeams: #{nbTeams}"
    teams = self.slots.where.not(team_id: nil)
    slots = self.slots.where.not(team_id: nil)
    puts "Teams in flight #{id}: #{teams.map(&:team_id).join(', ')}"
    marker = {}
    if nbTeams == 2
      marker[slots[0]] = teams[1]
      marker[slots[1]] = teams[0]
    end
    if nbTeams == 3
      marker[slots[0]] = teams[2]
      marker[slots[2]] = teams[1]
      marker[slots[1]] = teams[0]
    end
    if nbTeams == 4
      marker[slots[0]] = teams[3]
      marker[slots[1]] = teams[2]
      marker[slots[3]] = teams[0]
      marker[slots[2]] = teams[1]
    end
    marker
  end

  def myTime
    base_time = config_teetime.start_time
    step_minutes = config_teetime.step
    # nb_slots = config_teetime.nb_slots

    # Calculate the total minutes to add based on flight number and slots
    # total_minutes = (num - 1) * step_minutes * nb_slots
    total_minutes = (num - 1) * step_minutes

    # Calculate the time for this flight
    flight_time = base_time + total_minutes.minutes

    flight_time.strftime("%H:%M")
  end

  def flight_time
    base_time = config_teetime.start_time
    step_minutes = config_teetime.step
    total_minutes = (num - 1) * step_minutes
    base_time + total_minutes.minutes
  end
end
