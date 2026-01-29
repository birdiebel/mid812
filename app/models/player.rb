class Player < ApplicationRecord
    belongs_to :user, optional: true
    has_many :licences, dependent: :destroy
    has_many :entries, dependent: :destroy

    def self.ransackable_attributes(auth_object = nil)
        [ "created_at", "dob", "firstname", "id", "lang", "lastname", "sexe", "updated_at", "user_id" ]
    end

    def self.ransackable_associations(auth_object = nil)
        [ "user", "licences" ]
    end

    validates :firstname, presence: true
    validates :lastname, presence: true

    enum :sexe, [ :Men, :Ladies ]
    enum :lang, [ :Fr, :Nl, :En ]

    accepts_nested_attributes_for :licences
    accepts_nested_attributes_for :user


    def full_name
        "#{self.firstname} #{self.lastname}"
    end

    def my_user
        if self.user
             self.user.email
        else
            "<span class='is_red'>X</span>".html_safe
        end
    end

    def my_licence
        if self.licences.empty?
            "<span class='is_red'>X</span>".html_safe
        else
            lic = self.licences.first
            count_lic = self.licences.count
            if count_lic > 1
                "<span class='is_bold'>#{lic.num} (#{lic.hcp}) (#{count_lic})</span>".html_safe
            else
                "<span class='is_bold'>#{lic.num} (#{lic.hcp})</span>".html_safe
            end
        end
    end

    def my_club
        if self.licences.empty?
            "<span class='is_red'>X</span>".html_safe
        else
            lic = self.licences.first
            "<span class=''>#{lic.club}".html_safe
        end
    end

    def age
        now = Date.today
        age = now.year - dob.year
        age -= 1 if (now.month < dob.month) || (now.month == dob.month && now.day < dob.day)
        age
    end

    def age_category_id
        current_year = Date.today.year
        agecats = Agecat.where(year: current_year).order(id: :desc)
        agecats.each do |agecat|
            if age >= agecat.age_low && age <= agecat.age_high
                return agecat.id
            end
        end
    end

    def age_category
        current_year = Date.today.year
        agecats = Agecat.where(year: current_year).order(id: :desc)
        agecats.each do |agecat|
            if age >= agecat.age_low && age <= agecat.age_high
                return agecat.name
            end
        end
        "N/A".html_safe
    end

    def icon_age_category
        current_year = Date.today.year
        agecats = Agecat.where(year: current_year).order(id: :desc)
        agecats.each do |agecat|
            if age >= agecat.age_low && age <= agecat.age_high
                age_color = agecat.color.downcase
                return "<div class='bloc-agecat' style='background-color: #{age_color}; color: white'>
                        #{agecat.short}
                        </div>".html_safe
            end
        end
        "N/A".html_safe
    end
end
