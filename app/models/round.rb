class Round < ApplicationRecord
  belongs_to :event
  has_many :config_teetimes, dependent: :destroy
  has_many :flights, through: :config_teetimes
  has_many :slots, through: :flights
  has_many :scores, dependent: :destroy

  # Jp
  has_one :course, through: :config_teetimes

  enum :status, [ :pending, :running, :terminated, :suspended, :canceled ]

  validates :hcp_pc, inclusion: { in: 0..100, message: "must be between 0 and 100" }
  validates :status, presence: true
  validates :num, presence: true, numericality: { only_integer: true, greater_than: 0 }

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
end
