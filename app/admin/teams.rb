ActiveAdmin.register Team do
  belongs_to :event, optional: true

  permit_params :event_id, :name, :status, entries_attributes: [ :id, :hcp ]

  menu false
  config.batch_actions = false

  index do
    column :id
    column :event
    column :name
    column :status
    column "Total Age" do |team|
      team.total_age
    end
    column "Total Hcp" do |team|
      team.total_hcp.round(1)
    end
    actions
  end

  form do |f|
    f.inputs "Team Details" do
      if params[:team] && params[:team][:event_id]
        f.input :event_id, as: :hidden, input_html: { value: params[:team][:event_id] }
        event = Event.find(params[:team][:event_id])
        f.input :event, as: :select, collection: [ [ event.name, event.id ] ], include_blank: false
      else
        f.input :event, as: :select, collection: Event.all.map { |e| [ e.name, e.id ] }, include_blank: false
      end
      f.input :name
      f.input :status, as: :select, collection: Team.statuses.keys
    end

    f.inputs "Players in this Team" do
      can_add_player = f.object.event&.single? == false && f.object.entries.size < (f.object.event&.max_players || 1)
      f.has_many :entries,
                 allow_destroy: false,
                 new_record: can_add_player,
                 heading: false do |entry_f|
        entry_f.input :player, input_html: { disabled: true }
        entry_f.input :hcp, input_html: { step: :any }
      end
    end
    f.actions do
      f.action :submit
      if f.object.event
        f.cancel_link admin_tour_event_path(f.object.event.tour, f.object.event)
      else
        f.cancel_link :back
      end
    end
  end

  controller do
    def create
      @team = Team.new(permitted_params[:team])
      if @team.save
        redirect_to admin_tour_event_path(@team.event.tour, @team.event), notice: "Team created successfully."
      else
        render :new
      end
    end

    def update
      @team = Team.find(params[:id])
      if @team.update(permitted_params[:team])
        redirect_to admin_tour_event_path(@team.event.tour, @team.event), notice: "Team updated successfully."
      else
        render :edit
      end
    end

    def destroy
      @team = Team.find(params[:id])
      event = @team.event
      @team.destroy
      redirect_to admin_tour_event_path(event.tour, event), notice: "Team deleted successfully."
    end
  end
end
