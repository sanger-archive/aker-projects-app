class AddOwnerToNode < ActiveRecord::Migration[5.0]
  def change
    add_column :nodes, :owner_id, :integer
    add_foreign_key :nodes, :users, column: :owner_id
    add_index :nodes, :owner_id, unique: false    
  end
end
