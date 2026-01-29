ActiveAdmin.register Entry do
  permit_params :event_id, :player_id, :licence_id, :status

  menu false

  includes :event, :player, :licence
  config.batch_actions = false

  controller do
    def create
      @entry = Entry.new(entry_params)
      if @entry.save
        redirect_to admin_tour_event_path(@entry.event.tour_id, @entry.event_id), notice: "Joueur ajouté avec succès à l'événement."
      else
        redirect_back fallback_location: admin_tour_event_path(@entry.event.tour_id, @entry.event_id), alert: "Une erreur s'est produite."
      end
    end

    def update
      super do |format|
        if resource.valid?
          redirect_to admin_tour_event_path(resource.event.tour_id, resource.event_id) and return
        end
      end
    end

    private
      def entry_params
        params.require(:entry).permit(:event_id, :player_id, :status)
      end
  end

  form do |f|
    f.inputs do
      f.input :event
      f.input :player
      if !f.object.new_record?
        f.input :licence, collection: Licence.where(player_id: f.object.player_id).order("num ASC").all.map { |l| [ "#{l.num} (#{l.club})", l.id ] }
      end
      f.input :playercat, collection: f.object.event.playercats.all.map { |pc| [ pc.name, pc.id ] }
      f.input :status
    end
    f.actions do
      f.action :submit
      f.cancel_link(url_for(:back))
    end
  end
end
