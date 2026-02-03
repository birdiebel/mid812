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
        # self.playing_hcp = entry.hcp
        self.playing_hcp = playing_hcp_single(entry)
      else
        self.playing_hcp = nil
      end
    else
      self.playing_hcp = nil
    end
  end

  def playing_hcp_single(entry)
    # Teams
    team = entry.team
    # Licence
    licence = entry.licence
    # Hcp
    hcp = licence.hcp
    # Playercat.teebox
    teebox_name = entry.playercat.teebox
    # Course
    course = self.flight.config_teetime.course
    tee = course.tees.find_by(teebox: teebox_name)
    # rating and slope du teebox
    rating = tee.rating
    slope = tee.slope
    par = tee.sum_str("par_str")
    if rating && slope
      # Compute playing_hcp
      hcp = ((hcp * slope) / 113.0 + (rating - par)).round
    end
    # return hcp
    hcp
  end
end
