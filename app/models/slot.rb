class Slot < ApplicationRecord
  belongs_to :flight
  belongs_to :entry, optional: true

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "entry_id", "flight_id", "id", "num", "playing_hcp", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "entry", "flight" ]
  end

  before_update :before_update_callback

  def before_update_callback
    puts "Before updating Slot #{id}: entry_id=#{entry_id}, flight_id=#{flight_id}, num=#{num}, playing_hcp=#{playing_hcp}"
    if entry_id?
      entry = Entry.find_by(id: entry_id)
      if entry
        self.playing_hcp = entry.hcp
      else
        self.playing_hcp = nil
      end
    else
      self.playing_hcp = nil
    end
  end
end
