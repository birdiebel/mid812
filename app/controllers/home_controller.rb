class HomeController < ApplicationController
  def index
  end

  def test_pdf
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "test_pdf", # Excluding ".pdf" extension.
               template: "home/test_pdf",
               formats: [ :html ],
               layout: "pdf" # Optional, use 'pdf' to render app/views/layouts/pdf.html.erb
      end
    end
  end

  def loadadmin
    if user_signed_in? && current_user.role == "admin"
      redirect_to(admin_dashboard_path)
    else
      redirect_to(home_index_path)
    end
  end
end
