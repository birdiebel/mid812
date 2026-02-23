ActiveAdmin.register Round do
  belongs_to :event, optional: true

  permit_params :event_id, :num, :date, :status, :hcp_pc

  menu false
  config.batch_actions = false

  action_item "Close", only: [ :show ] do
    link_to "Close", rounds_admin_tour_event_path(resource.event.tour, resource.event)
  end

  action_item "Close", only: [ :config_times, :round_details, :round_status, :start_list, :scoring ] do
    link_to "Close", rounds_admin_tour_event_path(resource.event.tour, resource.event)
  end

  member_action :config_times, method: :get do
    @round = Round.find(params[:id])
  end

  member_action :round_details, method: :get do
    @round = Round.find(params[:id])
  end

  member_action :round_status, method: :get do
    @round = Round.find(params[:id])
  end

  member_action :scoring, method: :get do
    @round = Round.find(params[:id])
    @round.ensure_scores_for_scoring!
    @slots = @round.scoring_slots

    team_ids = @slots.map(&:team_id).compact.uniq
    team_ids.each do |team_id|
      TeamScore.find_or_create_by(team_id: team_id, round: @round)
    end

    @team_scores_by_team_id = TeamScore.where(round: @round, team_id: team_ids).index_by(&:team_id)
    @team_scores_by_team_id.each_value do |team_score|
      team_score.recalculate! if team_score.brut_total.nil?
    end

    first_entry_ids = @slots.map { |slot| slot.team.entries.first&.id }.compact
    @scores_by_entry_id = Score.where(round: @round, entry_id: first_entry_ids).index_by(&:entry_id)
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
               template: "admin/rounds/pdfs/pdf_start_list",
               formats: [ :html ],
               layout: "pdf" # Optional, use 'pdf' to render app/views/layouts/pdf.html.erb
      end
    end
  end

  member_action :pdf_scorecard, method: :get do
    @round = Round.find(params[:id])
    @round.ensure_scores_for_scoring!
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "scorecard_pdf",   # Excluding ".pdf" extension.
               template: "admin/rounds/pdfs/pdf_scorecard",
               formats: [ :html ],
               page_size: "A5",
               orientation: "Landscape",
               layout: "pdf" # Optional, use 'pdf' to render app/views/layouts/pdf.html.erb
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
    helper ActiveAdminViewsHelper

    before_action :prepare_start_list_data, only: [ :show, :start_list, :config_times, :round_details, :round_status ]

    def show
      redirect_to config_times_admin_round_path(resource)
    end

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
        redirect_to config_times_admin_round_path(@round), notice: "Round updated successfully."
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
