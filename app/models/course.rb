class Course < ApplicationRecord
  belongs_to :club
  has_many :tees, dependent: :destroy

  def self.ransackable_attributes(auth_object = nil)
    [ "club_id", "created_at", "id", "name", "updated_at", "version", "nb_hole" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "club" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "tees" ]
  end

  accepts_nested_attributes_for :tees

  after_create :create_tees

  def create_tees
    tee_list = [ "Black", "White", "Yellow", "Blue", "Red" ]
    # init_val = " , , , , , , , , , , , , , , , , , "
    init_val = " ," * (nb_hole)
    tee_list.each do |tb|
      self.tees.create(
        teebox: tb,
        par_str: init_val,
        stroke_str: init_val,
        dist_str: init_val,
        slope: 120,
        rating: 72
      )
    end
  end
end
