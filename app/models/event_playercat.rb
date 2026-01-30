class EventPlayercat < ApplicationRecord
  self.table_name = "events_playercats"

  belongs_to :event
  belongs_to :playercat

  # Set scoring to event's scoring by default
  before_validation :set_default_scoring, on: :create

  def set_default_scoring
    self.scoring ||= event.scoring if event
  end

  enum :scoring, [ :stroke_play, :stableford ]
end
