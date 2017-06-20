class ChangeNameIndexOnNodes < ActiveRecord::Migration[5.0]
  def change
    remove_index :nodes, :name
    add_index :nodes, :name, unique: false
  end
end
