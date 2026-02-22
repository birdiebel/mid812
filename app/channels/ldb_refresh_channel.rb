class LdbRefreshChannel < ApplicationCable::Channel
  def subscribed
    event_id = params[:event_id].presence
    reject unless event_id

    stream_from("ldb_refresh_event_#{event_id}")
  end
end
