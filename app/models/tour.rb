class Tour < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    [ "actif", "created_at", "id", "name", "status", "updated_at", "year" ]
  end
  def self.ransackable_associations(auth_object = nil)
    [ "events" ]
  end

  has_many :events, dependent: :destroy
  accepts_nested_attributes_for :events

  enum :status, [ :open, :close ]
end
