class Tee < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    [ "course_id", "created_at", "dist_str", "id", "par_str", "rating", "slope", "stroke_str", "teebox", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "course" ]
  end

  belongs_to :course

  enum :teebox, [ "Black", "White", "Yellow", "Blue", "Red" ]

  def sum_dist
    dist_str.split(",").map!(&:to_i).sum
  end

  def sum_str(param)
    send(param).split(",").map!(&:to_i).sum
  end

  def icon_teebox
    tee_boxcolor = self.teebox.downcase
    "<div class='bloc-teebox "+tee_boxcolor+"'></div>".html_safe
  end

  def str_to_array(param)
    send(param.downcase).split(",").map!(&:to_i)
  end

  def is_filled
    if sum_str("par_str") == 0
      false
    else
      true
    end
  end
end
