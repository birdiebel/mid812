class Round < ApplicationRecord
  belongs_to :event

  enum :status, [ :pending, :running, :terminated, :suspended, :canceled ]
end
