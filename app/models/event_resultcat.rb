class EventResultcat < ApplicationRecord
  self.table_name = "events_resultcats"

  belongs_to :event
  belongs_to :resultcat
end
