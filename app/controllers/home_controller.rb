class HomeController < ApplicationController
  def index
  end

  def loadadmin
    if user_signed_in? && current_user.role == "admin"
      redirect_to(admin_dashboard_path)
    else
      redirect_to(home_index_path)
    end
  end
end
