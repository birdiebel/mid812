class Round < ApplicationRecord
  belongs_to :event
  has_many :config_teetimes, dependent: :destroy
  has_many :flights, through: :config_teetimes
  has_many :slots, through: :flights
  has_many :scores, dependent: :destroy

  # Jp
  has_one :course, through: :config_teetimes

  enum :status, [ :created, :pending, :running, :terminated, :suspended, :canceled ]

  validates :hcp_pc, inclusion: { in: 0..100, message: "must be between 0 and 100" }
  validates :status, presence: true
  validates :num, presence: true, numericality: { only_integer: true, greater_than: 0 }

  def date_for_display
    date.strftime("%d/%m/%Y")
  end

  def slots_taked
    config_teetimes.joins(flights: :slots).where.not(slots: { team_id: nil }).count
  end

  def start_list_caution
    if slots_taked < event.entries_valid
      "<span class='is_red'>Start list may be incomplete (#{slots_taked} slots occupied for #{event.entries_valid} valid entries)</span>
      <br>
      <span class='is_red'>Review start list</span>".html_safe
    else
      "<span class='is_green'>Start list looks complete (#{slots_taked} slots occupied for #{event.entries_valid} valid entries)</span>".html_safe
    end
  end

  def scoring_slots
    config_teetimes
      .includes(flights: { slots: { team: [ :entries, :resultcat ] } })
      .flat_map { |config_teetime| config_teetime.flights.flat_map(&:slots) }
      .select { |slot| slot.team.present? }
      .sort_by { |slot| [ slot.flight.flight_time, slot.team.num ] }
  end

  def ensure_scores_for_scoring!
    scoring_slots.each do |slot|
      slot.team.entries.each do |entry|
        score = scores.find_or_initialize_by(entry_id: entry.id)
        score_playing_hcp = slot.score_playing_hcp_for(entry)

        if score.new_record?
          score.slot = slot
          score.team_id = slot.team_id
          score.playing_hcp = score_playing_hcp
          score.status ||= :pending
          score.save!
        else
          attributes_to_update = {}
          attributes_to_update[:slot_id] = slot.id if score.slot_id != slot.id
          attributes_to_update[:team_id] = slot.team_id if score.team_id != slot.team_id
          attributes_to_update[:playing_hcp] = score_playing_hcp if score.playing_hcp != score_playing_hcp

          next if attributes_to_update.empty?

          score.update_columns(attributes_to_update.merge(updated_at: Time.current))
        end
      end
    end
  end
end
