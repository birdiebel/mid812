ActiveAdmin.register Tee do
  permit_params :id, :course_id, :par_str, :dist_str, :stroke_str, :slope, :rating, :teebox

  includes :course
  config.comments = false
  menu false

  action_item "Close", only: [ :show ] do
    link_to "Close", admin_club_course_path(resource.course.club.id, resource.course.id)
  end

  controller do
    def update
      super do |success, failure|
        success.html { redirect_to admin_club_course_path(resource.course.club_id, resource.course.id) }
      end
    end
  end

  index do
    column :course
    column :teebox
    actions
  end

  form do |f|
    panel "Scorecard" do
        render "admin/tees/score_inputs", { tee: tee }
    end
  end

  show do
    panel "Scorecard" do
      render "admin/tees/scorecard", { tee: tee, course: tee.course }
    end
  end
end
