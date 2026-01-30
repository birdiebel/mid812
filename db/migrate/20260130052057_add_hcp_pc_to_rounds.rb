class AddHcpPcToRounds < ActiveRecord::Migration[8.1]
  def change
    add_column :rounds, :hcp_pc, :integer, default: 100
    add_check_constraint :rounds, "hcp_pc >= 0 AND hcp_pc <= 100", name: "hcp_pc_range"
  end
end
