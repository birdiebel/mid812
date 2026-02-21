# frozen_string_literal: true

ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      # Colone de gauche
      column do
        # Running events (running)
        panel "Running Events" do
          render "admin/dashboard/running_events"
        end
        # Online events (online, registration, Waiting)
        panel "On Line Events" do
          render "admin/dashboard/online_events"
        end
        # Future events (created)
        panel "Futures Events" do
          render "admin/dashboard/created_events"
        end
      end
      # Colone de droite
      column do
        # Infos
        panel "Info" do
          para class: "black is_bold" do
            "Infos"
          end
        end
        # Terminated events (terminated, canceled)
        panel "Terminated Events" do
          render "admin/dashboard/terminated_events"
        end
      end
    end
  end
end
