class Slot < ApplicationRecord
  belongs_to :flight
  belongs_to :entry, optional: true

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "entry_id", "flight_id", "id", "num", "playing_hcp", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "entry", "flight" ]
  end
end
