class AddUuidToNode < ActiveRecord::Migration[5.0]
  def change
  	add_column :nodes, :node_uuid, :string
  end
end
