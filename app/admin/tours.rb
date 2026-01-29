ActiveAdmin.register Tour do
  permit_params :name, :status, :actif, :user_id

  menu label: "Tours", parent: "Event", priority: 0
  # menu false
  config.batch_actions = false

  includes :events

  action_item "Close", only: [ :show ] do
    link_to "Close", admin_tours_path
  end

  filter :name_cont, as: :string, label: "Name"

  member_action :copyevent, method: :post do
    event = Event.find(params[:id])
    new_event = event.amoeba_dup
    new_event.name = "#{event.name} (Copy)"
    new_event.save
    redirect_to admin_tour_path(event.tour), notice: "Event copied successfully."
  end

  index do
    column "Name" do |tour|
      link_to tour.name, admin_tour_path(tour), method: :get
    end
    column "Year" do |tour|
      tour.year
    end
    column "Status" do |tour|
      tour.status
    end
    column "" do |tour|
      button_to "Edit", edit_admin_tour_path(tour), method: :get, class: "btt btt-edit"
    end
  end

  form do |f|
    f.inputs "Tour" do
      f.input :name
      f.input :status, as: :select, collection: Tour.statuses.keys
      f.input :actif
      f.input :year
    end
    f.actions do
       f.action :submit
       f.cancel_link(url_for(:back))
    end
  end

  # show do
  #   panel "Events" do
  #     div do
  #       button_to "Add event", new_admin_tour_event_path(tour_id: resource.id), method: :get
  #     end

  #     table_for tour.events do
  #       column "ID", :id
  #       column "Name" do |event|
  #         link_to event.name, admin_tour_event_path(tour, event), method: :get
  #       end
  #       column "Format", :format
  #       column "Status" do |event|
  #         event.status
  #       end
  #       column "date_event" do |event|
  #         l(event.date_event, format: :short) if event.date_event
  #       end
  #       column "date_open" do |event|
  #         l(event.date_open, format: :short) if event.date_open
  #       end
  #       column "date_close" do |event|
  #         l(event.date_close, format: :short) if event.date_close
  #       end
  #       column "nb_rounds" do |event|
  #         event.nb_rounds
  #       end
  #       column "" do |event|
  #         form_for [ :admin, event ], url: copyevent_admin_tour_path(event), method: :post do |f|
  #           # f.submit "Copy Event", class: "btt btt-edit"
  #           f.submit "Copy", button_html: { class: "submit-button", style: "background-color: blue;" }
  #         end
  #       end
  #       column "" do |event|
  #         button_to "Edit", edit_admin_tour_event_path(tour, event), method: :get, class: "btt btt-edit"
  #       end
  #     end
  #   end
  #   default_main_content
  # end

  show do
    columns do
      column do
        panel "Events" do
          div do
            button_to "Add event", new_admin_tour_event_path(tour_id: resource.id), method: :get
          end

          table_for tour.events do
            column "ID", :id
            column "Name" do |event|
              link_to event.name, admin_tour_event_path(tour, event), method: :get
            end
            column "", :format
            column "" do |event|
              event.status
            end
            column "date" do |event|
              l(event.date_event, format: :short) if event.date_event
            end
            column "rounds" do |event|
              event.nb_rounds
            end
            column "" do |event|
              form_for [ :admin, event ], url: copyevent_admin_tour_path(event), method: :post do |f|
                # f.submit "Copy Event", class: "btt btt-edit"
                f.submit "Copy", button_html: { class: "submit-button", style: "background-color: blue;" }
              end
            end
            column "" do |event|
              button_to "Edit", edit_admin_tour_event_path(tour, event), method: :get, class: "btt btt-edit"
            end
          end
        end
      end
      column do
        panel "Tour Details" do
          attributes_table_for tour do
            row :name
            row :status
            row :actif
            row :year
            row :created_at
            row :updated_at
          end
        end
      end
    end
    # default_main_content
  end
end
