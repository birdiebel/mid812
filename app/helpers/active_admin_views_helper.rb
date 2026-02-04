module ActiveAdminViewsHelper
  def status_badge(value, true_text = "YES", false_text = "NO")
    if value
      content_tag(:span, true_text, class: "badge-success")
    else
      content_tag(:span, false_text, class: "badge-danger")
    end
  end

  def style_for_stroke_play(score)
    case score
    when "N.A."
      "color: #999999;"
    when "even"
      "background-color: #155724; color: white;"
    when /^-/
      "background-color: #721c24; color: white;"
    when /^\+/
      "background-color: #004085; color: white;"
    else
      ""
    end
  end
end
