ActiveAdmin.register Course do
  permit_params :id, :name, :club_id, :version, :nb_hole,
                tees_attributes: [ :id, :course_id, :par_str, :dist_str, :stroke_str, :slope, :rating, :teebox ]
  belongs_to :club
  includes :club, :tees

  action_item "Close", only: [ :show ] do
    link_to "Close", admin_club_path(resource.club_id)
  end

  form do |f|
    f.inputs "Course" do
      f.input :club
      f.input :name
      f.input :version
      f.input :nb_hole
    end
    f.actions do
       f.action :submit
       f.cancel_link(url_for(:back))
    end
  end

  show do
    default_main_content
    panel "Tees" do
      table_for course.tees do
        column  do |tee|
          raw tee.icon_teebox
        end
        column do |tee|
          if tee.is_filled
            raw ""
          else
            raw '<span style="color: red">X<span>'
          end
        end
        column "Teebox" do |tee|
          link_to tee.teebox, admin_tee_path(tee), method: :get
        end
        column "Par", proc { |record| record.sum_str("par_str") }
        column "Long", proc { |record| record.sum_str("dist_str") }
        column :slope
        column :rating
        column "" do |tee|
          button_to "Edit", edit_admin_tee_path(tee), method: :get, class: "btt btt-edit"
        end
      end
    end
  end
end
