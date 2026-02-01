ActiveAdmin.register Resultcat do
  permit_params :name, :agecat_id, :sexe, :hcp_min, :hcp_max, :version, :priority, :actif

  config.batch_actions = false

  menu label: "Result Categories", parent: "Config", priority: 5

  action_item "Close", only: [ :show ] do
    link_to "Close", admin_resultcats_path
  end

  action_item "Copy", only: [ :show ] do
    link_to "Copy", "/admin/resultcats/#{resource.id}/copy", method: :get
  end

  member_action :copy, method: :get do
    @resultcat = Resultcat.find(params[:id])
  end

  member_action :create_copy, method: :post do
    @original = Resultcat.find(params[:id])
    @copy = @original.dup
    @copy.name = params[:resultcat][:name]
    if @copy.save
      redirect_to admin_resultcat_path(@copy), notice: "Result Category copied successfully."
    else
      redirect_to admin_resultcat_path(@original), alert: "Failed to copy Result Category."
    end
  end

  filter :name_cont, as: :string, label: "Name"
  filter :agecat, as: :select
  filter :version_cont, as: :string, label: "Version"
  config.sort_order = "id_asc"

  index do
    column "ID", :id
    column "Name" do |resultcat|
      link_to resultcat.name, admin_resultcat_path(resultcat), method: :get
    end
    column "Age Category", :agecat
    column "Sexe", :sexe
    column "HCP Min", :hcp_min
    column "HCP Max", :hcp_max
    column "Version", :version
    column "Priority", :priority
    column "Actif", :actif
    column "" do |resultcat|
      div class: "table-btn-action" do
        div do
          button_to "Edit", edit_admin_resultcat_path(resultcat), method: :get, class: "btt btt-edit"
        end
        div do
          button_to "Copy", "/admin/resultcats/#{resultcat.id}/copy", method: :get, class: "btt btt-copy"
        end
      end
    end
  end

  form do |f|
    f.inputs "Result Category" do
      f.input :name
      f.input :agecat, as: :select
      f.input :sexe
      f.input :hcp_min
      f.input :hcp_max
      f.input :version
      f.input :priority
      f.input :actif
    end
    f.actions do
       f.action :submit
       f.cancel_link(url_for(:back))
    end
  end
end
