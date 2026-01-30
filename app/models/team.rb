class Team < ApplicationRecord
  belongs_to :event
  has_many :entries, dependent: :destroy

  accepts_nested_attributes_for :entries, allow_destroy: false, reject_if: :all_blank

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "event_id", "id", "id_value", "name", "status", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "entries", "event" ]
  end

  validates :name, presence: true

  enum :status, { enter: 0, refused: 1, canceled: 2, disqualified: 3, noshow: 4 }

  def total_age
    entries.includes(:player).sum { |entry| entry.player&.age || 0 }
  end

  def total_hcp
    entries.sum(:hcp)
  end
end
