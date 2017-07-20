class AddOwnerToNode < ActiveRecord::Migration[5.0]
  def change
    add_reference :nodes, :owner, references: :users, foreign_key: true, index: true
  end
end
