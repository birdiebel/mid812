ActiveAdmin.register Club do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :id, :name,
                courses_attributes: [ :id, :name, :version, :nb_hole ]
  #
  # or
  #
  # permit_params do
  #   permitted = [:name]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  includes :courses

  config.batch_actions = false

  action_item "Close", only: [ :show ] do
    link_to "Close", admin_clubs_path
  end

  filter :name_cont, as: :string, label: "Name"
  filter :courses_name_cont, as: :string, label: "Course"

  form do |f|
    f.inputs "Club" do
      f.input :name
    end
    # f.inputs 'Courses' do
    #   f.has_many :courses, heading: false, allow_destroy: false, new_record: true do |c|
    #     c.input :name
    #     c.input :version
    #     c.input :nb_hole
    #   end
    # end
    f.actions do
       f.action :submit
       f.cancel_link(url_for(:back))
    end
  end

  index do
    column "Name" do |club|
      link_to club.name, admin_club_path(club), method: :get
    end
    column "" do |club|
      button_to "Edit", edit_admin_club_path(club), method: :get, class: "btt btt-edit"
    end
  end

  show do
    default_main_content

    div do
      button_to "Add course", new_admin_club_course_path(club_id: resource.id), method: :get
    end

    panel "Courses" do
      table_for club.courses do
        column "Name" do |course|
          link_to course.name, admin_club_course_path(club.id, course), method: :get
        end
        column :version
        column :nb_hole
        column "" do |course|
          button_to "Edit", edit_admin_club_course_path(club, course), method: :get, class: "btt btt-edit"
        end
      end
    end
  end
end
