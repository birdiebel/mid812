class Round < ApplicationRecord
  belongs_to :event
  has_many :config_teetimes, dependent: :destroy
  has_many :scores, dependent: :destroy

  enum :status, [ :pending, :running, :terminated, :suspended, :canceled ]

  validates :hcp_pc, inclusion: { in: 0..100, message: "must be between 0 and 100" }
end
