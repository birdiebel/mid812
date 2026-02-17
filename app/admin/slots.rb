ActiveAdmin.register Slot do
  permit_params :flight_id, :team_id, :num, :playing_hcp

  config.batch_actions = false

  menu label: "Slots", parent: "Config", priority: 11

  filter :flight, as: :select
  filter :team, as: :select
  filter :num
  config.sort_order = "flight_id_asc"

  index do
    column "Idx", :id
    column "Num", :num
    column "Flight", :flight
    column "Team ID", :team_id
    column "Team" do |slot|
      slot.team ? slot.team.team_name_short : "No team assigned"
    end
    column "Playing HCP", :playing_hcp
    column "" do |slot|
      button_to "Edit", edit_admin_slot_path(slot), method: :get, class: "btt btt-edit"
    end
  end

  form do |f|
    f.inputs "Slot" do
      f.input :flight, as: :select, collection: Flight.all.map { |fl| [ "Flight #{fl.num}", fl.id ] }
      li do
        label "Team"
        div do
          text_node f.object.team ? f.object.team.team_name_short : "No team assigned"
        end
      end
      f.input :num, as: :number
      f.input :playing_hcp, as: :number
    end
    f.actions do
      f.action :submit
       f.cancel_link(url_for(:back))
    end
  end

  controller do
    def update
      @slot = Slot.find(params[:id])
      puts "Received update for Slot #{@slot.id}: #{permitted_params[:slot].inspect}"
      if @slot.update(permitted_params[:slot])
        puts "Successfully updated Slot #{@slot.id}"
        respond_to do |format|
          format.html { redirect_to admin_slot_path(@slot), notice: "Slot was successfully updated." }
          format.json { render json: { success: true } }
        end
      else
        puts "Failed to update Slot #{@slot.id}: #{@slot.errors.full_messages.join(', ')}"
        respond_to do |format|
          format.html { render :edit }
          format.json { render json: { success: false, errors: @slot.errors }, status: :unprocessable_entity }
        end
      end
    end
  end
end
