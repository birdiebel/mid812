ActiveAdmin.register Round do
  belongs_to :event, optional: true

  permit_params :event_id, :num, :date, :status, :hcp_pc

  menu false
  config.batch_actions = false

  myTitle = proc { |round| "#{round.event.name} : round #{round.num} on #{round.date}" }

  show title: myTitle do
    # Menu Navigation with Buttons
    div name: "round-menu", class: "button-group", style: "margin-top: -30px; margin-bottom: -20px;" do
      a href: "#start-list", class: "menu-button menu-event-button", data: { target: "#start-list" } do
        text_node "Start List"
      end
      a href: "#scores", class: "menu-button menu-event-button", data: { target: "#scores" } do
        text_node "Scores"
      end
      a href: "#status", class: "menu-button menu-event-button", data: { target: "#status" } do
        text_node "Status"
      end
      a href: "#round-details", class: "menu-button menu-event-button", data: { target: "#round-details" } do
        text_node "Round Details"
      end
    end
  end


  index do
    column :num
    column :event
    column :date
    column :status
    actions
  end

  form do |f|
    f.inputs "Round Details" do
      if params[:round] && params[:round][:event_id]
        f.input :event_id, as: :hidden, input_html: { value: params[:round][:event_id] }
        f.input :event, as: :select, collection: [ Event.find(params[:round][:event_id]) ].map { |e| [ e.name, e.id ] }, include_blank: false
      else
        f.input :event, as: :select, collection: Event.all.map { |e| [ e.name, e.id ] }, include_blank: false
      end
      f.input :num, as: :number, label: "Round Number"
      f.input :date, as: :datepicker
      f.input :hcp_pc, as: :number, label: "HCP Par/Course", input_html: { value: f.object.hcp_pc || 100, min: 0, max: 100 }
      f.input :status, as: :select, collection: Round.statuses.keys
    end
    f.actions do
      f.action :submit
      f.cancel_link admin_tour_event_path(f.object.event.tour, f.object.event)
    end
  end

  controller do
    def create
      @round = Round.new(permitted_params[:round])
      if @round.save
        redirect_to admin_tour_event_path(@round.event.tour, @round.event), notice: "Round created successfully."
      else
        render :new
      end
    end

    def update
      @round = Round.find(params[:id])
      if @round.update(permitted_params[:round])
        redirect_to admin_tour_event_path(@round.event.tour, @round.event), notice: "Round updated successfully."
      else
        render :edit
      end
    end

    def destroy
      @round = Round.find(params[:id])
      event = @round.event
      @round.destroy
      redirect_to admin_tour_event_path(event.tour, event), notice: "Round deleted successfully."
    end
  end
end
