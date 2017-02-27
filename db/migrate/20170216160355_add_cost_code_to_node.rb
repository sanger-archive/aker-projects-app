class AddCostCodeToNode < ActiveRecord::Migration[5.0]
  def change
    add_column :nodes, :cost_code, :string
    add_index :nodes, :cost_code
  end
end
