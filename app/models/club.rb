class Club < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "id", "name", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "courses" ]
  end

  has_many :courses, dependent: :destroy
  accepts_nested_attributes_for :courses
end
