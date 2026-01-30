class Team < ApplicationRecord
  belongs_to :event
  has_many :entries, dependent: :destroy

  validates :name, presence: true

  enum :status, [ :created, :confirmed, :cancel, :enter, :no_enter ]
end
