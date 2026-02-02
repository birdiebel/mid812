ActiveAdmin.register Slot do
  permit_params :flight_id, :entry_id, :num, :playing_hcp

  config.batch_actions = false

  menu label: "Slots", parent: "Config", priority: 11

  filter :flight, as: :select
  filter :entry, as: :select
  filter :num
  config.sort_order = "flight_id_asc"

  index do
    column "Num", :num
    column "Flight", :flight
    column "Entry", :entry
    column "Playing HCP", :playing_hcp
    column "" do |slot|
      button_to "Edit", edit_admin_slot_path(slot), method: :get, class: "btt btt-edit"
    end
  end

  form do |f|
    f.inputs "Slot" do
      f.input :flight, as: :select, collection: Flight.all.map { |fl| [ "Flight #{fl.num}", fl.id ] }
      li do
        label "Entry"
        div do
          text_node f.object.entry ? f.object.entry.player&.full_name : "No entry assigned"
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
      if @slot.update(permitted_params[:slot])
        respond_to do |format|
          format.html { redirect_to admin_slot_path(@slot), notice: "Slot was successfully updated." }
          format.json { render json: { success: true } }
        end
      else
        respond_to do |format|
          format.html { render :edit }
          format.json { render json: { success: false, errors: @slot.errors }, status: :unprocessable_entity }
        end
      end
    end
  end
end
