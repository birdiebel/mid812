class Resultcat < ApplicationRecord
  has_and_belongs_to_many :agecats
  has_many :event_resultcats, dependent: :destroy
  has_many :events, through: :event_resultcats

  def self.ransackable_attributes(auth_object = nil)
    [ "actif", "agecat_id", "created_at", "hcp_max", "hcp_min", "id", "name", "priority", "sexe", "updated_at", "version" ]
  end
  def self.ransackable_associations(auth_object = nil)
    [ "agecat" ]
  end

  enum :sexe, [ :Men, :Ladies, :All ]
  enum :scoring, [ :stroke_play, :stableford ]

  def scoring_short
    case scoring
    when "stroke_play"
      "SP"
    when "stableford"
      "STB"
    else
      ""
    end
  end
end
