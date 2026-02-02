class Flight < ApplicationRecord
  belongs_to :config_teetime
  has_many :slots, dependent: :destroy

  enum :status, { player: 0, gap: 1 }

  def self.ransackable_attributes(auth_object = nil)
    [ "config_teetime_id", "created_at", "id", "num", "status", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "config_teetime" ]
  end
end
