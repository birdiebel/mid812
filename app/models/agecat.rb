class Agecat < ApplicationRecord
  has_and_belongs_to_many :playercats
  has_and_belongs_to_many :resultcats

  # Ransackable attributes for searching and sorting
  # This method is used by the Ransack gem to determine which attributes can be searched or sorted on.
  def self.ransackable_attributes(auth_object = nil)
    [ "age_high", "age_low", "color", "created_at", "id", "name", "short", "updated_at", "year" ]
  end
end
