ActiveAdmin.register Round do
  belongs_to :event, optional: true

  permit_params :event_id, :num, :date, :status, :hcp_pc

  menu false
  config.batch_actions = false

  action_item "Close", only: [ :show ] do
    link_to "Close", admin_tour_event_path(resource.event.tour, resource.event, anchor: "rounds")
  end

  # action_item "Scoring", only: [ :show ] do
  #   link_to "Scoring", "/admin/rounds/#{resource.id}/scoring", method: :get
  # end
  member_action :scoring, method: :get do
    @round = Round.find(params[:id])
  end

  member_action :start_list, method: :get do
    @round = Round.find(params[:id])
  end

  member_action :pdf_start_list, method: :get do
    @round = Round.find(params[:id])
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "start_list_pdf",   # Excluding ".pdf" extension.
               template: "admin/rounds/pdf_start_list",
               formats: [ :html ],
               layout: "pdf" # Optional, use 'pdf' to render app/views/layouts/pdf.html.erb
      end
    end
  end

  myTitle = proc { |round| "#{round.event.name} : round #{round.num} on #{round.date} | #{round.status.upcase}" }

  show title: myTitle do
    render "admin/rounds/menu", round: round
    render "admin/rounds/config_times", round: round
    render "admin/rounds/status", round: round
    render "admin/rounds/round_details", round: round
    page_call = params[:page] || "config_times"
    div id: "round_menu_page_call", data: { page_call: page_call }
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
    before_action :prepare_start_list_data, only: [ :show, :start_list ]

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
        redirect_to admin_event_round_path(@round.event, @round), notice: "Round updated successfully."
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

    private

      def prepare_start_list_data
        return unless resource&.event

        @start_list_teams = resource.event.teams.where(status: :enter).includes(:resultcat, :entries).to_a.sort_by(&:total_hcp)
        @team_ids_in_round_slots = resource.slots.where.not(team_id: nil).distinct.pluck(:team_id)
      end
  end
end
