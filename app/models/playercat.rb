class Playercat < ApplicationRecord
  has_and_belongs_to_many :events
  has_and_belongs_to_many :agecats
  has_many :entries

  def self.ransackable_attributes(auth_object = nil)
    [ "agecat_id", "created_at", "hcp_max", "hcp_min", "id",
      "name", "teebox", "updated_at", "version", "sexe", "priority", "actif", "format" ]
  end

  enum :sexe, [ :Men, :Ladies ]
  enum :teebox, { "Black": 0, "White": 1, "Yellow": 2, "Blue": 3, "Red": 4 }
  enum :format, [ :single, :team ]

  default_scope { order(name: :asc, version: :desc) }

  def version_name
    "#{name} ( #{version} )"
  end

  def teebox_index
    self.teebox.index
  end

  def tee
    Tee.find_by(teebox: self.teebox)
  end

  def icon_teebox
    tee_boxcolor = self.teebox.downcase
    "<div class='bloc-teebox "+tee_boxcolor+"'></div>".html_safe
  end

  def icon_teebox_span
    tee_boxcolor = self.teebox.downcase
    "<span class='bloc-teebox-span "+tee_boxcolor+"'></span>".html_safe
  end
end
