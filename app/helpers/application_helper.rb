module ApplicationHelper
  def status_badge(value, true_text = "YES", false_text = "NO")
    if value
      tag.span(true_text, class: "badge-success")
    else
      tag.span(false_text, class: "badge-danger")
    end
  end
end
