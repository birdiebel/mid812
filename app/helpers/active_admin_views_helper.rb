module ActiveAdminViewsHelper
  def status_badge(value, true_text = "YES", false_text = "NO")
    if value
      content_tag(:span, true_text, class: "badge-success")
    else
      content_tag(:span, false_text, class: "badge-danger")
    end
  end

  def against_par_badge(diff_par, par_total)
    return content_tag(:div, content_tag(:strong, "N.A."), class: "div-against-par") if par_total.to_i.zero?

    score = diff_par.to_i
    label = score.positive? ? "+#{score}" : score.to_s
    style = if score.zero?
      "color: green;"
    elsif score.negative?
      "color: red;"
    else
      "color: blue;"
    end

    content_tag(:div, content_tag(:strong, label), class: "div-against-par", style: style)
  end

  def stroke_play_badge(score)
    return content_tag(:div, content_tag(:strong, "N.A."), class: "div-against-par") if score.nil? || score.to_s == "N.A."

    numeric_score = score.to_i
    label = numeric_score.positive? ? "+#{numeric_score}" : numeric_score.to_s
    style = if numeric_score.zero?
      "color: green;"
    elsif numeric_score.negative?
      "color: red;"
    else
      "color: blue;"
    end

    content_tag(:div, content_tag(:strong, label), class: "div-against-par", style: style)
  end
end
