class Playercat < ApplicationRecord
  has_and_belongs_to_many :events
  has_and_belongs_to_many :agecats
  has_many :entries

  def self.ransackable_attributes(auth_object = nil)
    [ "agecat_id", "created_at", "hcp_max", "hcp_min", "id",
      "name", "teebox", "updated_at", "version", "sexe", "priority", "actif", "format" ]
  end


  enum :sexe, [ :Men, :Ladies ]
  enum :teebox, [ "Black", "White", "Yellow", "Blue", "Red" ]
  enum :format, [ :single, :team ]

  def icon_teebox
    tee_boxcolor = self.teebox.downcase
    "<div class='bloc-teebox "+tee_boxcolor+"'></div>".html_safe
  end
end
