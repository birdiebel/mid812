module EventsHelper
  def playercat_checkboxes_collection
    Playercat.all.map do |pc|
      [ pc.name, pc.id, { "data-format" => pc.format.to_s, class: "playercat-checkbox" } ]
    end
  end

  def resultcat_checkboxes_collection
    Resultcat.all.map do |rc|
      [ rc.name, rc.id, { class: "resultcat-checkbox" } ]
    end
  end
end
