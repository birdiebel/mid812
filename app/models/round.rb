class Round < ApplicationRecord
  belongs_to :event
  has_many :config_teetimes, dependent: :destroy
  has_many :scores, dependent: :destroy

  enum :status, [ :pending, :running, :terminated, :suspended, :canceled ]

  validates :hcp_pc, inclusion: { in: 0..100, message: "must be between 0 and 100" }
  validates :status, presence: true
  validates :num, presence: true, numericality: { only_integer: true, greater_than: 0 } 
end
