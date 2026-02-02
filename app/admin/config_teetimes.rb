ActiveAdmin.register ConfigTeetime do
  belongs_to :round, optional: true

  permit_params :round_id, :course_id, :formula_id, :start_hole, :nb_slots, :step, :nb_teams, :start_time, :hcp_pc

  menu false
  config.batch_actions = false

  index do
    column :round
    column :course
    column :start_hole
    column :nb_slots
    column :step
    column :nb_teams
    column :start_time
    column :hcp_pc
    actions
  end

  form do |f|
    f.inputs "Tee Time Configuration" do
      if params[:config_teetime] && params[:config_teetime][:round_id]
        # New record with round_id in params
        f.input :round_id, as: :hidden, input_html: { value: params[:config_teetime][:round_id] }
        round = Round.find(params[:config_teetime][:round_id])
      elsif f.object.round
        # Existing record with round already set
        round = f.object.round
      else
        # Fallback
        round = nil
      end

      if round
        f.input :round, as: :select, collection: [ [ "#{round.event.name} - Round #{round.num}", round.id ] ], include_blank: false
        f.input :course, as: :select, collection: round.event.courses.map { |c| [ "#{c.club.name} - #{c.name}", c.id ] }, include_blank: false
        event_format = round.event.format
        f.input :formula, as: :select, collection: Formula.where(format: event_format).map { |formula| [ formula.name, formula.id ] }, include_blank: "Select a formula"
        default_nb_teams = round.event.entries.where(status: :enter).count
      else
        f.input :round, as: :select, collection: Round.all.map { |r| [ "#{r.event.name} - Round #{r.num}", r.id ] }, include_blank: false
        f.input :course, as: :select, collection: Course.all.map { |c| [ "#{c.club.name} - #{c.name}", c.id ] }, include_blank: false
        f.input :formula, as: :select, collection: Formula.all.map { |formula| [ formula.name, formula.id ] }, include_blank: "Select a formula"
        default_nb_teams = 0
      end

      f.input :start_hole, as: :number, input_html: { min: 1, max: 18, value: f.object.start_hole || 1 }
      f.input :nb_slots, as: :number, input_html: { min: 1, max: 4, value: f.object.nb_slots || 1 }, label: "Nb Slots (1-4)"
      f.input :step, as: :number, input_html: { value: f.object.step || 10 }, label: "Step (minutes)"
      f.input :nb_teams, as: :number, input_html: { value: f.object.nb_teams || default_nb_teams }, label: "Nb Teams"
      f.input :start_time, as: :string, input_html: { type: :time, value: f.object.start_time&.strftime("%H:%M") || "08:00" }
      f.input :hcp_pc, as: :number, label: "HCP %", input_html: { value: f.object.hcp_pc.presence || round&.hcp_pc }
      f.input :return_to, as: :hidden, input_html: { value: params.dig(:config_teetime, :return_to) || (round && admin_round_path(round)) }
    end
    f.actions do
      f.action :submit
      return_to = params.dig(:config_teetime, :return_to).presence || (f.object.round && admin_round_path(f.object.round))
      f.cancel_link(return_to || :back)
    end
  end

  controller do
    def create
      @config_teetime = ConfigTeetime.new(permitted_params[:config_teetime])
      if @config_teetime.save
        return_to = params.dig(:config_teetime, :return_to).presence
        redirect_to(return_to || admin_round_path(@config_teetime.round), notice: "Tee time configuration created successfully.")
      else
        render :new
      end
    end

    def update
      @config_teetime = ConfigTeetime.find(params[:id])
      if @config_teetime.update(permitted_params[:config_teetime])
        return_to = params.dig(:config_teetime, :return_to).presence
        redirect_to(return_to || admin_round_path(@config_teetime.round), notice: "Tee time configuration updated successfully.")
      else
        render :edit
      end
    end

    def destroy
      @config_teetime = ConfigTeetime.find(params[:id])
      @config_teetime.destroy
      return_to = params.dig(:config_teetime, :return_to).presence || request.referer
      redirect_to(return_to || admin_round_path(@config_teetime.round), notice: "Tee time configuration deleted successfully.")
    end
  end
end
