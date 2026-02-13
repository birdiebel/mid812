class Team < ApplicationRecord
  belongs_to :event
  belongs_to :resultcat, optional: true
  has_many :entries, dependent: :destroy
  has_many :slots, dependent: :nullify
  has_many :team_scores, dependent: :destroy

  accepts_nested_attributes_for :entries, allow_destroy: false, reject_if: :all_blank

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "event_id", "id", "id_value", "name", "num", "resultcat_id", "status", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "entries", "event", "slots", "team_scores" ]
  end

  validates :name, presence: true
  validates :num, uniqueness: { scope: :event_id }, allow_nil: true

  enum :status, { enter: 0, refused: 1, canceled: 2, disqualified: 3, noshow: 4 }

  before_create :assign_num
  before_update :sync_entries_status
  after_save :update_resultcat, if: -> { !@skip_resultcat_update }

  def running_round
    event.rounds.where(status: "running").first
  end

  def round_hole_played(round_id)
    self.team_scores.find_by(round: round_id)&.hole_played || 0
  end

  # Retourne l'heure de départ du team pour un round donné au format hh:mm
  def start_time_for_round(round_id)
    slot = slots.find { |s| s.flight&.config_teetime&.round_id == round_id }
    time = slot&.flight&.flight_time
    time ? time.strftime("%H:%M") : nil
  end

  def status_scoring
    { enter: 0, canceled: 2, disqualified: 3, noshow: 4 }
  end

  def show_status
    if status.nil?
      "N/A"
    elsif status != "enter"
      "<span style=\"color: red;\">#{status.to_s.humanize}</span>".html_safe
    else
      ""
    end
  end

  def total_age
    entries.includes(:player).sum { |entry| entry.player&.age || 0 }
  end

  def total_hcp
    entries.sum(:hcp)
  end

  def team_name
    entries.map { |e| e.player.full_name }.join(" / ")
  end

  def update_resultcat
    @skip_resultcat_update = true
    get_resultcat
    @skip_resultcat_update = false
  end

  def get_resultcat
    # Reload entries to ensure fresh data
    self.reload
    return if event.nil? || entries.empty?

    # Force reload of event.resultcats
    event.resultcats.reload

    hcp = total_hcp
    sexes = entries.map { |e| e.player&.sexe }.compact.uniq
    ages = entries.map { |e| e.player&.age }.compact

    puts "[Team#get_resultcat] Team #{id}: hcp=#{hcp}, sexes=#{sexes}, ages=#{ages}"
    puts "  Event has #{event.resultcats.count} resultcats"

    event.resultcats.each do |resultcat|
      puts "  Checking resultcat #{resultcat.id} (#{resultcat.name}): hcp_min=#{resultcat.hcp_min}, hcp_max=#{resultcat.hcp_max}, sexe=#{resultcat.sexe}"

      # Check HCP range
      next unless resultcat.hcp_min <= hcp && resultcat.hcp_max >= hcp
      puts "    HCP match!"

      # Check age range (if agecats exist with limits; otherwise no limit)
      if resultcat.agecats.exists?
        age_match = ages.all? do |age|
          resultcat.agecats.any? do |agecat|
            agecat.age_low.present? && agecat.age_high.present? &&
            agecat.age_low <= age && agecat.age_high >= age
          end
        end

        unless age_match
          puts "    Age doesn't match: ages #{ages} don't fit any agecat"
          next
        end
        puts "    Age match!"
      else
        puts "    No age restriction"
      end

      # Check sexe (All matches everything, otherwise must match)
      if resultcat.sexe == "All"
        puts "    Sexe match (All)!"
        self.update_column(:resultcat_id, resultcat.id)
        return resultcat
      elsif sexes.all? { |sexe| sexe.to_s == resultcat.sexe.to_s }
        puts "    Sexe match (#{sexes} == #{resultcat.sexe})!"
        self.update_column(:resultcat_id, resultcat.id)
        return resultcat
      else
        puts "    Sexe doesn't match: #{sexes} vs #{resultcat.sexe}"
      end
    end

    # No category found
    puts "  No resultcat found for team #{id}"
    nil
  end

  def sync_entries_status
    if status_changed?
      entries.each do |entry|
        entry.update_column(:status, status)
      end
    end
  end

  private

    def assign_num
      return if num.present?
      max_num = Team.where(event_id: event_id).maximum(:num) || 0
      self.num = max_num + 1
    end
end
