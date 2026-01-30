class Event < ApplicationRecord
  belongs_to :tour
  has_and_belongs_to_many :playercats
  has_and_belongs_to_many :courses
  has_many :entries, dependent: :destroy
  has_many :rounds, dependent: :destroy

  # Set default values
  before_create :set_default_values

  def set_default_values
    self.date_event ||= Date.current
    self.date_open ||= Date.current
    self.date_close ||= Date.current
    self.actif_round = 1 if self.actif_round.nil?
    self.fee = 0.0 if self.fee.nil?
    self.fee_member = 0.0 if self.fee_member.nil?
  end

  def self.ransackable_associations(auth_object = nil)
    [ "tour" ]
  end
  def self.ransackable_attributes(auth_object = nil)
    [ "actif", "created_at", "id", "name", "status", "tour_id", "updated_at", "format", "date_event", "date_open", "date_close", "nb_rounds" ]
  end

  enum :status, [ :created, :online, :registration, :waiting, :running, :terminated, :canceled ]
  enum :format, [ :single, :team, :bigteam ]

  amoeba do
    enable
    include_associations :playercats
  end

  def my_playercats(licence)
    player = licence.player
    hcp = licence.hcp
    sexe = player.sexe
    matched_playercats = nil
    self.playercats.each do |pcat|
      if pcat.sexe == 2
        if pcat.hcp_max <= hcp && pcat.hcp_min >= hcp && pcat.match_agecat(player.age_category_id)
          matched_playercats = pcat.name
        end
      else
        if pcat.hcp_max <= hcp && pcat.hcp_min >= hcp && pcat.match_sexe(sexe) && pcat.match_agecat(player.age_category_id)
          matched_playercats = pcat.name
        end
      end
    end
    if matched_playercats.nil?
      "N/A".html_safe
    else
      matched_playercats
    end
  end

  def copy_record(new_name)
    new_event = self.dup
    new_event.name = new_name
    new_event.status = :created
    new_event.actif = false
    new_event.actif_round = 1
    new_event.save!
    self.playercats.each do |pcat|
      new_event.playercats << pcat
    end
    new_event
  end
end
