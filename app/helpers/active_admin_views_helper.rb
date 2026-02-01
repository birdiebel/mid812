module ActiveAdmin
  module ViewsHelper
    def status_badge(value, true_text = "YES", false_text = "NO")
      if value
        content_tag(:span, true_text, class: "badge-success")
      else
        content_tag(:span, false_text, class: "badge-danger")
      end
    end
  end
end
