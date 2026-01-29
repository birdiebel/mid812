class Agecat < ApplicationRecord
  has_and_belongs_to_many :playercats

  def self.ransackable_attributes(auth_object = nil)
    [ "age_high", "age_low", "color", "created_at", "id", "name", "short", "updated_at", "year" ]
  end
end
