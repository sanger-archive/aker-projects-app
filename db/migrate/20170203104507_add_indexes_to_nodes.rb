class AddIndexesToNodes < ActiveRecord::Migration[5.0]
  def change
  	add_index :nodes, :name, unique: true
  	add_index :nodes, :parent_id, unique: false
  	add_foreign_key :nodes, :nodes, column: :parent_id
  end
end
