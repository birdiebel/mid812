class Event < ApplicationRecord
  belongs_to :tour
  has_many :event_playercats, dependent: :destroy
  has_many :playercats, through: :event_playercats
  has_many :event_resultcats, dependent: :destroy
  has_many :resultcats, through: :event_resultcats
  has_and_belongs_to_many :courses
  has_many :entries, dependent: :destroy
  has_many :rounds, dependent: :destroy
  has_many :teams, dependent: :destroy

  accepts_nested_attributes_for :event_playercats, allow_destroy: true, reject_if: proc { |attributes| attributes["playercat_id"].blank? }
  accepts_nested_attributes_for :event_resultcats, allow_destroy: true, reject_if: proc { |attributes| attributes["resultcat_id"].blank? }

  after_save :sync_playercats_ids
  after_save :sync_resultcats_ids

  def playercats_ids=(ids)
    @playercats_ids_to_sync = ids.reject(&:blank?).map(&:to_i) if ids.present?
  end

  def playercats_ids
    @playercats_ids_to_sync || playercats.pluck(:id)
  end

  def resultcats_ids=(ids)
    @resultcats_ids_to_sync = ids.reject(&:blank?).map(&:to_i) if ids.present?
  end

  def resultcats_ids
    @resultcats_ids_to_sync || resultcats.pluck(:id)
  end

  def sync_playercats_ids
    return unless @playercats_ids_to_sync

    current_ids = event_playercats.pluck(:playercat_id)
    ids_to_add = @playercats_ids_to_sync - current_ids
    ids_to_remove = current_ids - @playercats_ids_to_sync

    event_playercats.where(playercat_id: ids_to_remove).destroy_all
    ids_to_add.each do |playercat_id|
      event_playercats.create!(playercat_id: playercat_id)
    end

    @playercats_ids_to_sync = nil
  end

  def sync_resultcats_ids
    return unless @resultcats_ids_to_sync

    current_ids = event_resultcats.pluck(:resultcat_id)
    ids_to_add = @resultcats_ids_to_sync - current_ids
    ids_to_remove = current_ids - @resultcats_ids_to_sync

    event_resultcats.where(resultcat_id: ids_to_remove).destroy_all
    ids_to_add.each do |resultcat_id|
      event_resultcats.create!(resultcat_id: resultcat_id)
    end

    @resultcats_ids_to_sync = nil
  end

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
  enum :scoring, [ :stroke_play, :stableford ]

  amoeba do
    enable
    include_associations :playercats
    include_associations :resultcats
  end

  def my_playercats(licence)
    player = licence.player
    hcp = licence.hcp
    sexe = player.sexe
    matched_playercats = nil
    self.playercats.each do |pcat|
      if pcat.sexe == 2 # unisex
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
    self.resultcats.each do |rcat|
      new_event.resultcats << rcat
    end
    new_event
  end
end
