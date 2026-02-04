class Score < ApplicationRecord
  belongs_to :round
  belongs_to :slot
  belongs_to :entry

  enum :status, { partial: 0, completed: 1, invalide: 2 }

  before_validation :assign_start_hole, if: -> { start_hole.blank? }
  before_save :calculate_recu_str

  def self.ransackable_attributes(auth_object = nil)
    [ "brut_str", "created_at", "entry_id", "hole_played", "id", "id_value", "net_str", "recu_str", "round_id", "slot_id", "start_hole", "status", "stb_str", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "entry", "round", "slot" ]
  end

  private

  def assign_start_hole
    return if slot.nil?
    config = slot.flight&.config_teetime
    self.start_hole = config.start_hole if config
  end

  def calculate_recu_str
    return unless entry && slot

    # Get playing_hcp from entry
    hcp = entry.playing_hcp&.to_i
    return unless hcp && hcp > 0

    # Get the tee based on playercat teebox
    playercat = entry.playercat
    return unless playercat

    course = slot.flight&.config_teetime&.course
    return unless course

    tee = course.tees.find_by(teebox: playercat.teebox)
    return unless tee

    # Get stroke index array from tee
    stroke_indexes = tee.str_to_array("stroke_str")
    return unless stroke_indexes.any?

    # Calculate strokes received for each hole
    recu_per_hole = stroke_indexes.map do |stroke_index|
      # Full rounds of strokes
      full_strokes = hcp / 18
      # Extra strokes on hardest holes
      extra_stroke = (hcp % 18) >= stroke_index ? 1 : 0
      full_strokes + extra_stroke
    end

    # Store as comma-separated string
    self.recu_str = recu_per_hole.join(",")

    Rails.logger.debug "Score#calculate_recu_str: hcp=#{hcp}, recu_str=#{self.recu_str}"
  end
end
