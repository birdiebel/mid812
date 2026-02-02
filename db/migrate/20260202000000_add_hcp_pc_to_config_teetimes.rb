class AddHcpPcToConfigTeetimes < ActiveRecord::Migration[8.1]
  def change
    add_column :config_teetimes, :hcp_pc, :integer
  end
end
