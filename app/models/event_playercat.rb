class EventPlayercat < ApplicationRecord
  self.table_name = "events_playercats"

  belongs_to :event
  belongs_to :playercat
end
